/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PAYROLL
IS
    -- Author  : VANO
    -- Created : 26.07.2022 12:17:39
    -- Purpose : Функції роботи з відомостями - статуси, повернення тощо

    -- #75804 Призупинити виплату kolio
    PROCEDURE sheet_stop_pay (p_prs_id      pr_sheet.prs_id%TYPE,
                              P_RNP_ID   IN NUMBER);                 -- #79229

    --Опрацювання результатів при надходженні квитанції КВ-1 (Блокування виплати, якщо код > 0)
    PROCEDURE kv1_proc_pay (p_mode       INTEGER, --1=передача параметрів через параметри функції, 2=передача параметрів через тимчасову табилцю tmp_prs_block
                            p_prs_id     pr_sheet.prs_id%TYPE:= NULL,
                            p_block_tp   VARCHAR2:= NULL);

    --Опрацювання результатів при надходженні квитанції КВ-2 (Блокування виплати, якщо код > 0)
    PROCEDURE kv2_proc_pay (p_mode       INTEGER, --1=передача параметрів через параметри функції, 2=передача параметрів через тимчасову табилцю tmp_prs_block
                            p_prs_id     pr_sheet.prs_id%TYPE:= NULL,
                            p_block_tp   VARCHAR2:= NULL);

    --Опрацювання блокування відомостей АСПОД, які прийшли до жовтня 2022 року включно
    PROCEDURE kv2_asopd_pay (p_mode INTEGER); --2=передача параметрів через тимчасову табилцю tmp_acd_block

    -- Блокування виплати мануальне з інтерфейсу по окремим рядкам
    PROCEDURE na_manual_block (p_prs_id     pr_sheet.prs_id%TYPE:= NULL,
                               p_block_tp   VARCHAR2:= NULL);

    -- Підтвердження виплати мануальне з інтерфейсу по всім рядкам відомості з контролем на загальну виплачену суму
    PROCEDURE na_manual_confirm (p_pr_id    payroll.pr_id%TYPE,
                                 p_pr_sum   DECIMAL);

    -- Повернення "підтвердженого" рядка відомості в стан "нараховано" - для можливості його заблокувати відповідною функцією.
    PROCEDURE kv2_manual_return (p_prs_id pr_sheet.prs_id%TYPE);

    -- Масове повернення "підтвердженого" рядка відомості в стан "нараховано" - для можливості його заблокувати відповідною функцією.
    PROCEDURE kv2_manual_return_mass (p_pr_id payroll.pr_id%TYPE);

    -- Повернення "заблокованого" рядка відомості в стан "нараховано" - для можливості його "підтвердити".
    PROCEDURE pk2_manual_return (p_prs_id pr_sheet.prs_id%TYPE);
END API$PAYROLL;
/


/* Formatted on 8/12/2025 5:49:08 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PAYROLL
IS
    PROCEDURE write_prs_log (p_prsl_prs       prs_log.prsl_prs%TYPE,
                             p_prsl_hs        prs_log.prsl_hs%TYPE,
                             p_prsl_st        prs_log.prsl_st%TYPE,
                             p_prsl_message   prs_log.prsl_message%TYPE,
                             p_prsl_st_old    prs_log.prsl_st_old%TYPE,
                             p_prsl_tp        prs_log.prsl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        IF p_prsl_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        ELSE
            l_hs := p_prsl_hs;
        END IF;

        INSERT INTO prs_log (prsl_id,
                             prsl_prs,
                             prsl_hs,
                             prsl_st,
                             prsl_message,
                             prsl_st_old,
                             prsl_tp)
             VALUES (0,
                     p_prsl_prs,
                     l_hs,
                     p_prsl_st,
                     p_prsl_message,
                     p_prsl_st_old,
                     NVL (p_prsl_tp, 'SYS'));
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка API$PAYROLL.'
                || $$PLSQL_UNIT
                || ' : '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END write_prs_log;

    PROCEDURE kv_proc_pay_int (
        p_mode                  INTEGER, --1=за рядками відомості з таблиці tmp_prs_block, 2=за рядками нарахувань з таблиці tmp_acd_block
        p_new_prs_st_ok         VARCHAR2,
        p_exch_code_ok          VARCHAR2,
        p_prs_to_work           VARCHAR2,
        p_new_prs_st_block      VARCHAR2,
        p_new_pcb_tp            VARCHAR2,
        P_RNP_ID             IN NUMBER DEFAULT NULL, -- тільки для інтерактивного зняття
        p_prs_to_work_alt       VARCHAR2 DEFAULT '---',
        p_function_desc         VARCHAR2 DEFAULT 'квитанцією')
    IS
        l_hs   histsession.hs_id%TYPE := TOOLS.GetHistSession;
    BEGIN
        FOR prs
            IN (SELECT *
                  FROM pr_sheet
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM tmp_prs_block
                                 WHERE     prs_id = x_prs
                                       AND x_block_tp = p_exch_code_ok)
                       AND prs_st IN (p_prs_to_work, p_prs_to_work_alt))
        LOOP
            write_prs_log (prs.prs_id,
                           l_hs,
                           p_new_prs_st_ok,
                           CHR (38) || '300',
                           NULL);
        END LOOP;

        --Проставляємо "Підтверджено квитанцією"
        UPDATE pr_sheet
           SET prs_st = p_new_prs_st_ok,
               prs_transfer_dt =
                   NVL (prs_transfer_dt,
                        (SELECT t.tpi_date_enr
                           FROM tmp_ppr_info t
                          WHERE t.tpi_prs = prs_id))     -- #83864 io 20230221
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_prs_block
                         WHERE prs_id = x_prs AND x_block_tp = p_exch_code_ok)
               AND prs_st IN (p_prs_to_work, p_prs_to_work_alt);

        --Якщо є "підтверджені квитанцією", оновлюємо допоміжні (для відображення в інтерфейсах) поля в нарахуванні
        IF SQL%ROWCOUNT > 0
        THEN
            DELETE FROM tmp_work_ids1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids1 (x_id)
                SELECT DISTINCT acd_ac
                  FROM tmp_prs_block, pr_sheet_detail, ac_detail
                 WHERE x_prs = prsd_prs AND acd_prsd = prsd_id;

            --Якщо знайшлись ярдки нарахувань, прив'язані до рядків відомостей, то оновлюємо такі нарахування
            IF SQL%ROWCOUNT > 0
            THEN
                API$ACCRUAL.actuilize_payed_sum (1);
            END IF;

            --Якщо код повернення "Зараховано" - оновлюємо ознаку в деталях відомості
            IF                                             /*p_new_prs_st_ok*/
               p_exch_code_ok = '200'
            THEN                                         -- #83864 io 20230221
                UPDATE pr_sheet_detail
                   SET prsd_is_payed = 'T'
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM tmp_prs_block
                                 WHERE     prsd_prs = x_prs
                                       AND x_block_tp = '200')
                       AND EXISTS
                               (SELECT 1
                                  FROM pr_sheet
                                 WHERE prsd_prs = prs_id AND prs_st = 'KV2')
                       AND (prsd_is_payed = 'F' OR prsd_is_payed IS NULL);

                -- #89850 2023.08.23 Інформування по виплатам ВПО
                IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 (
                       'NOTIFY_VPO_ENABLED',
                       'IKIS_SYS') =
                   'TRUE'
                THEN
                    uss_esr.API$AP_SEND_MESSAGE.Notify_VPO_on_Payroll;
                END IF;
            END IF;
        END IF;

        --Формуємо заготовки записів блокування
        API$PC_BLOCK.CLEAR_BLOCK;     -- DELETE FROM tmp_pc_block WHERE 1 = 1;

        IF p_mode = 1
        THEN
            INSERT INTO tmp_pc_block (b_pc,
                                      b_prs,
                                      b_tp,
                                      b_exch_code,
                                      b_dt,
                                      b_rnp)
                SELECT prs_pc,
                       x_prs,
                       p_new_pcb_tp,
                       x_block_tp,
                       -- #80932 дата блокування - останній день місяця, що передує розрахунковому періоду за органом та типом (bp_class визначаєтья за "впо/не впо")
                       -- Тобто для відомостей ВПО, по періоду 10.2022, період блокування "по 30.09.2022".
                       NVL (
                           x_dt,
                           CASE
                               WHEN pr_npc = 24 THEN pr_month - 1
                               ELSE LAST_DAY (pr_month)
                           END),
                       NVL (
                           p_rnp_id,
                           (SELECT MIN (nrpc_rnp)     AS x_nrp
                              FROM uss_ndi.v_ndi_rnp_config,
                                   uss_ndi.v_ndi_reason_not_pay
                             WHERE     nrpc_exch_code = x_block_tp
                                   AND rnp_pay_tp = pr_pay_tp))
                  FROM tmp_prs_block, pr_sheet, payroll
                 WHERE     prs_id = x_prs
                       AND prs_pr = pr_id
                       AND x_block_tp <> p_exch_code_ok
                       AND prs_st IN
                               (p_prs_to_work,
                                p_prs_to_work_alt,
                                p_new_prs_st_ok                 /*IC #108218*/
                                               )
                       AND prs_st NOT IN ('PP', 'PK1', 'PK2');
        ELSIF p_mode = 2
        THEN
            INSERT INTO tmp_pc_block (b_pc,
                                      b_pd,
                                      b_prs,
                                      b_tp,
                                      b_exch_code,
                                      b_dt,
                                      b_rnp)
                  SELECT ac_pc,
                         acd_pd,
                         NULL,
                         p_new_pcb_tp,
                         MAX (x_block_tp),
                         MIN (
                             NVL (
                                 TRUNC (x_dt),
                                 CASE
                                     WHEN acd_npt = 167 THEN ac_month - 1
                                     ELSE LAST_DAY (ac_month)
                                 END)),
                         MIN (
                             NVL (
                                 p_rnp_id,
                                 (SELECT MIN (nrpc_rnp)     AS x_nrp
                                    FROM uss_ndi.v_ndi_rnp_config,
                                         uss_ndi.v_ndi_reason_not_pay
                                   WHERE     nrpc_exch_code = x_block_tp
                                         AND rnp_pay_tp =
                                             NVL (
                                                 (SELECT pdm_pay_tp
                                                    FROM pd_pay_method pdm
                                                   WHERE     pdm_pd = acd_pd
                                                         AND pdm.history_status =
                                                             'A'
                                                         AND pdm_is_actual =
                                                             'T'),
                                                 'BANK'))))
                    FROM tmp_acd_block, ac_detail d, accrual
                   WHERE     x_acd = acd_id
                         AND d.history_status = 'A'
                         AND acd_ac = ac_id
                         AND acd_imp_pr_num IS NOT NULL
                GROUP BY ac_pc, acd_pd;
        END IF;

        --Якщо хоч один запис блокування створений, формуємо власне записи блокування та посилаємось на них
        IF SQL%ROWCOUNT > 0
        THEN
            IF p_mode = 1
            THEN                   --Для блокувань на основі записів відомості
                UPDATE tmp_pc_block
                   SET b_hs_lock = l_hs,
                       b_pd =
                           (SELECT MAX (acd_pd)
                              FROM pr_sheet_detail, ac_detail
                             WHERE     acd_prsd = prsd_id
                                   AND prsd_prs = b_prs
                                   AND ac_detail.history_status = 'A') --, b_id = id_pc_block(0) -- no need anymore
                 WHERE 1 = 1;
            END IF;

            --Змінюємо рішення, періоди не перераховуємо
            API$PC_BLOCK.decision_block_pp (l_hs);

            --Простовляємо посилання на записи блокування у відповідні рядки відомості
            UPDATE pr_sheet
               SET prs_st = p_new_prs_st_block,
                   (prs_pcb, prs_transfer_dt) =
                       (SELECT b_id, NVL (x_dt, SYSDATE) -- #80932 ми зіпсували b_dt, доведеться повертатись до x_dt
                          FROM tmp_pc_block
                               JOIN tmp_prs_block ON b_prs = x_prs
                         WHERE b_prs = prs_id)
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_pc_block
                         WHERE prs_id = b_prs);

            /*  FOR prs IN (SELECT *
                          FROM pr_sheet
                          WHERE (SELECT 1 FROM tmp_pc_block WHERE prs_id = b_prs))
              LOOP
                write_prs_log(prs.prs_id, l_hs, p_new_prs_st_ok, CHR(38)||'300', NULL);
              END LOOP;*/

            --Простовляємо ознаку випати в Ні для деталей відомості
            UPDATE pr_sheet_detail
               SET prsd_is_payed = 'F'
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_pc_block
                             WHERE prsd_prs = b_prs)
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pr_sheet
                             WHERE prsd_prs = prs_id AND prs_st = 'KV2')
                   AND (prsd_is_payed = 'T' OR prsd_is_payed IS NULL);

            --Готуємо множину записів деталей відомостей для обробки в нарахуваннях
            DELETE FROM tmp_ac_stop_pay
                  WHERE 1 = 1;

            INSERT INTO tmp_ac_stop_pay (x_prsd, x_tp, x_acd)
                SELECT prsd_id, p_new_prs_st_block, TO_NUMBER (0)
                  FROM tmp_pc_block, pr_sheet_detail --На основі рядків відомостей
                 WHERE prsd_prs = b_prs AND b_exch_code <> p_exch_code_ok
                UNION ALL
                SELECT TO_NUMBER (0), p_new_prs_st_block, x_acd
                  FROM tmp_acd_block, ac_detail  --На основі рядків нарахувань
                 WHERE x_acd = acd_id AND history_status = 'A';

            --Зупиняємо виплату в нарахуваннях
            API$ACCRUAL.stop_pay (1);
        END IF;
    END;

    -- Призупинити виплату з інтерфейсу
    PROCEDURE sheet_stop_pay (p_prs_id      pr_sheet.prs_id%TYPE,
                              P_RNP_ID   IN NUMBER)                  -- #79229
    IS
        l_prs   pr_sheet%ROWTYPE;
        l_pr    v_payroll%ROWTYPE;
    BEGIN
        DELETE FROM tmp_acd_block
              WHERE 1 = 1;

        -- інтерактивні перевірки
        SELECT *
          INTO l_prs
          FROM pr_sheet
         WHERE prs_id = p_prs_id;

        SELECT *
          INTO l_pr
          FROM v_payroll
         WHERE pr_id = l_prs.prs_pr;

        IF l_pr.pr_st NOT IN ('C', 'P')
        THEN
            raise_application_error (
                -20000,
                'Блокувати виплату вручну можна тільки рядки відомостей, які перебувають в станах "Нараховано" та "Включено в потребу"!');
        END IF;

        IF l_prs.prs_st <> 'NA' OR l_prs.prs_st IS NULL
        THEN
            raise_application_error (
                -20000,
                'Блокувати виплату вручну можна тільки рядки в стані "Нараховано"!');
        END IF;

        DELETE FROM tmp_prs_block
              WHERE 1 = 1;

        INSERT INTO tmp_prs_block (x_prs, x_block_tp)
             VALUES (p_prs_id, '333');

        kv_proc_pay_int (1,
                         TO_CHAR (NULL), -- хороший наступний prs_st (у нас завжди погано)
                         '300', -- має бути не таке саме як кількома рядками вище
                         'NA',                        -- на місце цього prs_st
                         'PP',           -- поставимо наступний поганий prs_st
                         'HPR', -- константа для pcb_tp -- select * from USS_NDI.V_DDN_PCB_TP
                         P_RNP_ID);

        FOR cd
            IN (  SELECT pd_st, pd_id            -- 0 or 1 lazy developer loop
                    FROM pc_decision
                   WHERE     pd_pa = l_prs.prs_pa
                         AND l_prs.prs_pay_dt BETWEEN pd_start_dt
                                                  AND pd_stop_dt
                ORDER BY pd_id DESC
                   FETCH FIRST ROW ONLY)
        LOOP
            API$PC_DECISION.write_pd_log (cd.pd_id,
                                          NULL,
                                          'PS',
                                          CHR (38) || '121',
                                          cd.pd_st);
        END LOOP;
    /* щоб трохи розвіднілось може допогти оце
    select rnp_id, rnp_code, rnp_pay_tp, rnp_pnp_tp, nrpc_id, nrpc_exch_code, nrpc.rnp_name
    from USS_NDI.V_NDI_REASON_NOT_PAY nrpc
    left join uss_ndi.v_ndi_rnp_config rnp on nrpc_rnp=rnp_id and rnp.history_status='A' and nrpc.history_status='A'
    */
    END;

    --Опрацювання результатів при надходженні квитанції КВ-1 (Блокування виплати, якщо код > 0)
    PROCEDURE kv1_proc_pay (p_mode       INTEGER, --1=передача параметрів через параметри функції, 2=передача параметрів через тимчасову табилцю tmp_prs_block
                            p_prs_id     pr_sheet.prs_id%TYPE:= NULL,
                            p_block_tp   VARCHAR2:= NULL)
    IS
        l_cnt   INTEGER;
    BEGIN
        DELETE FROM tmp_acd_block
              WHERE 1 = 1;

        IF p_mode = 1
        THEN
            DELETE FROM tmp_prs_block
                  WHERE 1 = 1;

            INSERT INTO tmp_prs_block (x_prs, x_block_tp)
                 VALUES (p_prs_id, p_block_tp);
        ELSIF p_mode = 2
        THEN
            SELECT COUNT (*) INTO l_cnt FROM tmp_prs_block;

            IF l_cnt = 0
            THEN
                RETURN;
            END IF;
        ELSE
            raise_application_error (-20000, 'Режим не підтримується!');
        END IF;

        --Обробляємо вхідну множину - прсотавляємо 'KV1' за кодом 100 та 'PK1' за всіма іншими кодами. Для рядкі в статусі NA - нараховано
        kv_proc_pay_int (1,
                         'KV1',
                         '100',
                         'NA',
                         'PK1',
                         'APR');
    END;

    -- Опрацювання результатів  при надходженні квитанції КВ-2 (Блокування виплати, якщо код > 0)
    PROCEDURE kv2_proc_pay (p_mode       INTEGER, --1=передача параметрів через параметри функції, 2=передача параметрів через тимчасову табилцю tmp_prs_block
                            p_prs_id     pr_sheet.prs_id%TYPE:= NULL,
                            p_block_tp   VARCHAR2:= NULL)
    IS
        l_cnt   INTEGER;
    BEGIN
        DELETE FROM tmp_acd_block
              WHERE 1 = 1;

        IF p_mode = 1
        THEN
            DELETE FROM tmp_prs_block
                  WHERE 1 = 1;

            INSERT INTO tmp_prs_block (x_prs, x_block_tp)
                 VALUES (p_prs_id, p_block_tp);
        ELSIF p_mode = 2
        THEN
            SELECT COUNT (*) INTO l_cnt FROM tmp_prs_block;

            IF l_cnt = 0
            THEN
                RETURN;
            END IF;
        ELSE
            raise_application_error (-20000, 'Режим не підтримується!');
        END IF;

        --Обробляємо вхідну множину - прсотавляємо 'KV2' за кодом 200 та 'PK2' за всіма іншими кодами. Для рядкі в статусі KV1 - підтверджено квитанцією 1.
        kv_proc_pay_int (1,
                         'KV2',
                         '200',
                         'KV1',
                         'PK2',
                         'APR',
                         NULL,
                         'NA');
    END;

    --Опрацювання блокування відомостей АСПОД, які прийшли до жовтня 2022 року включно
    PROCEDURE kv2_asopd_pay (p_mode INTEGER) --2=передача параметрів через тимчасову табилцю tmp_acd_block
    IS
        l_cnt   INTEGER;
    BEGIN
        SELECT COUNT (*) INTO l_cnt FROM tmp_acd_block;

        DELETE FROM tmp_prs_block
              WHERE 1 = 1;

        --  raise_application_error(-20000, 'Ще не реалізовано! (передано '||l_cnt||' записів)');

        kv_proc_pay_int (2,
                         'KV2',
                         '---',
                         '---',
                         'PK2',
                         'HPR',
                         NULL,
                         'NA');
    END;

    -- Блокування виплати мануальне з інтерфейсу по окремим рядкам
    PROCEDURE na_manual_block (p_prs_id     pr_sheet.prs_id%TYPE:= NULL,
                               p_block_tp   VARCHAR2:= NULL)
    IS
        l_prs_id   pr_sheet.prs_id%TYPE;
        l_pr_npc   payroll.pr_npc%TYPE;
    BEGIN
        --Контроль на те, що рядок в стані 'NA' та по фіксованій відомості.
        BEGIN
            SELECT prs_id, pr_npc
              INTO l_prs_id, l_pr_npc
              FROM v_payroll, pr_sheet
             WHERE     prs_pr = pr_id
                   AND prs_id = p_prs_id
                   AND prs_st = 'NA'
                   AND pr_st = 'F';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Спроба виконати блокування рядка нефіксованої відомості або рядка не в стані "Нараховано"!');
        END;

        IF l_pr_npc = 24
        THEN
            raise_application_error (
                -20000,
                'Для відомостей по ВПО блокування та підтвердження надходять через квитанції Ощадбанку!');
        END IF;

        IF p_block_tp IN ('100', '200')
        THEN
            raise_application_error (
                -20000,
                'Блокування виплати з причинами, що означають підтвердження виплати - не допускається!');
        END IF;

        kv2_proc_pay (1, p_prs_id, p_block_tp);
    --raise_application_error(-20000, 'na_manual_block');
    END;

    -- Підтвердження виплати мануальне з інтерфейсу по всім рядкам відомості з контролем на загальну виплачену суму
    PROCEDURE na_manual_confirm (p_pr_id    payroll.pr_id%TYPE,
                                 p_pr_sum   DECIMAL)
    IS
        l_sum      pr_sheet.prs_sum%TYPE;
        l_pr_npc   payroll.pr_npc%TYPE;
    BEGIN
        IF p_pr_id IS NULL
        THEN
            raise_application_error (-20000, 'Не вказано відомість!');
        END IF;

        IF p_pr_sum IS NULL OR p_pr_sum <= 0
        THEN
            raise_application_error (
                -20000,
                'Вказано пусту або нульову суму виплати - вкажіть коректну суму виплати!');
        END IF;

        --Контроль на те, що сума по рядкам в станах 'NA' для фізосіб (пенсія банком/поштою, без рядків для юр.осіб) - дорівнюють p_pr_sum.
        SELECT SUM (prs_sum), MAX (pr_npc)
          INTO l_sum, l_pr_npc
          FROM v_payroll, pr_sheet
         WHERE     prs_pr = p_pr_id
               AND prs_pr = pr_id
               AND pr_st = 'F'
               AND prs_st = 'NA'
               AND prs_tp IN ('PP', 'PB');

        IF l_pr_npc = 24
        THEN
            raise_application_error (
                -20000,
                'Для відомостей по ВПО блокування та підтвердження надходять через квитанції Ощадбанку!');
        END IF;

        IF l_sum IS NULL OR l_sum = 0
        THEN
            raise_application_error (
                -20000,
                'Вказано пусту або нульову суму виплати - вкажіть коректну суму виплати!');
        END IF;

        IF p_pr_sum <> l_sum
        THEN
            raise_application_error (
                -20000,
                'Вказана сума виплати не співпадає з сумою по рядкам відомості в стані "Нараховано"!');
        END IF;

        --Формую тимчасову таблицю tmp_prs_block по рядкам в станах 'NA'
        DELETE FROM tmp_prs_block
              WHERE 1 = 1;

        INSERT INTO tmp_prs_block (x_prs, x_block_tp)
            SELECT prs_id, '200'
              FROM v_payroll, pr_sheet
             WHERE     prs_pr = p_pr_id
                   AND prs_pr = pr_id
                   AND pr_st = 'F'
                   AND prs_st = 'NA';

        IF SQL%ROWCOUNT > 0
        THEN
            --Обробляємо множину - прсотавляємо 'KV2' за кодом 200 та 'PK2' за всіма іншими кодами. Для рядків в статусі KV1 - підтверджено квитанцією 1.
            kv_proc_pay_int (1,
                             'KV2',
                             '200',
                             'KV1',
                             'PK2',
                             'APR',
                             NULL,
                             'NA');
        END IF;
    --raise_application_error(-20000, 'na_manual_confirm');
    END;

    -- Повернення "підтвердженого" рядка відомості в стан "нараховано" - для можливості його заблокувати відповідною функцією.
    PROCEDURE kv2_manual_return (p_prs_id pr_sheet.prs_id%TYPE)
    IS
        --l_cnt INTEGER;
        l_prs_id   pr_sheet.prs_id%TYPE;
        l_pr_npc   payroll.pr_npc%TYPE;
    BEGIN
        --Контроль на те, що рядок в стані 'KV2' та відомость фіксована.
        BEGIN
            SELECT prs_id, pr_npc
              INTO l_prs_id, l_pr_npc
              FROM v_payroll, pr_sheet
             WHERE     prs_pr = pr_id
                   AND prs_id = p_prs_id
                   AND prs_st = 'KV2'
                   AND pr_st = 'F';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Спроба виконати повернення рядка нефіксованої відомості або рядка не в стані "Зараховано/виплачено"!');
        END;

        IF l_pr_npc = 24
        THEN
            raise_application_error (
                -20000,
                'Для відомостей по ВПО блокування та підтвердження надходять через квитанції Ощадбанку!');
        END IF;

        --Переводимо рядок відомості в стан NA.
        UPDATE pr_sheet
           SET prs_st = 'NA'
         WHERE prs_id = l_prs_id;
    --  raise_application_error(-20000, 'kv2_manual_return');
    END;

    -- Масове повернення "підтвердженого" рядка відомості в стан "нараховано" - для можливості його заблокувати відповідною функцією.
    PROCEDURE kv2_manual_return_mass (p_pr_id payroll.pr_id%TYPE)
    IS
        --l_cnt INTEGER;
        l_pr_id      pr_sheet.prs_id%TYPE;
        l_pr_npc     payroll.pr_npc%TYPE;
        l_pr_month   payroll.pr_month%TYPE;
        l_cnt        INTEGER;
    BEGIN
        --Контроль на те, що рядок в стані 'KV2' та відомость фіксована.
        BEGIN
              SELECT pr_id,
                     pr_npc,
                     pr_month,
                     COUNT (*)
                INTO l_pr_id,
                     l_pr_npc,
                     l_pr_month,
                     l_cnt
                FROM v_payroll, pr_sheet
               WHERE     prs_pr = pr_id
                     AND prs_pr = p_pr_id
                     AND prs_st = 'KV2'
                     AND pr_st = 'F'
            GROUP BY pr_id, pr_npc, pr_month;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Спроба виконати масове повернення рядків нефіксованої відомості або відсутні рядки в стані "Зараховано/виплачено"!');
        END;

        IF l_pr_npc = 24
        THEN
            raise_application_error (
                -20000,
                'Для відомостей по ВПО блокування та підтвердження надходять через квитанції Ощадбанку!');
        END IF;

        IF 1 = 1                                                         /* */
        THEN
            raise_application_error (
                -20000,
                'По відомості вже є проведені платіжні інструкції - не дозволяється масове повернення "зарахованих/виплачених" рядків таких відомостей в "нараховано"!');
        END IF;

        IF 1 = 1                                                         /* */
        THEN
            raise_application_error (
                -20000,
                'Відомість не за поточний розрахунковий період - не дозволяється масове повернення "зарахованих/виплачених" рядків таких відомостей в "нараховано"!');
        END IF;

        --Переводимо рядок відомості в стан NA.
        UPDATE pr_sheet
           SET prs_st = 'NA'
         WHERE prs_pr = l_pr_id AND prs_st = 'KV2';

        raise_application_error (-20000, 'kv2_manual_return_mass');
    END;

    -- Повернення "заблокованого" рядка відомості в стан "нараховано" - для можливості його "підтвердити".
    PROCEDURE pk2_manual_return (p_prs_id pr_sheet.prs_id%TYPE)
    IS
        --l_cnt_s INTEGER;
        l_cnt_saved    INTEGER;
        l_cnt_actual   INTEGER;
        l_hs           histsession.hs_id%TYPE := NULL;
        l_prs_id       pr_sheet.prs_id%TYPE;
        l_pr_npc       payroll.pr_npc%TYPE;
    BEGIN
        --Контроль на те, що рядок в стані 'PK2' та відомість фіксована.
        BEGIN
            SELECT prs_id, pr_npc
              INTO l_prs_id, l_pr_npc
              FROM v_payroll, pr_sheet
             WHERE     prs_pr = pr_id
                   AND prs_id = p_prs_id
                   AND prs_st = 'PK2'
                   AND pr_st = 'F';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Спроба виконати повернення рядка нефіксованої відомості або рядка не в стані "Заблоковано по КВ2"!');
        END;

        IF l_pr_npc = 24
        THEN
            raise_application_error (
                -20000,
                'Для відомостей по ВПО блокування та підтвердження надходять через квитанції Ощадбанку!');
        END IF;

        --Шукаємо відповідні нарахування, створені при блокуванні, та перевести їх в стан "історичний", якщо це можливо
        --Знаходимо кількість проводок, які треба видалити
        SELECT COUNT (*)
          INTO l_cnt_saved
          FROM pr_sheet_detail, pr_blocked_acd
         WHERE     prsa_prsd = prsd_id
               AND prsd_prs = l_prs_id
               AND history_status = 'A';

        --Знаходимо скільки з них - можна видалити
        SELECT COUNT (*)
          INTO l_cnt_actual
          FROM pr_sheet_detail, pr_blocked_acd prsa, ac_detail acd
         WHERE     prsa_prsd = prsd_id
               AND prsa.history_status = 'A'
               AND prsa_acd_inserted = acd_id
               AND acd_prsd IS NULL
               AND acd_imp_pr_num IS NULL
               AND acd.history_status = 'A'
               AND prsd_prs = l_prs_id;

        IF l_cnt_saved = l_cnt_actual
        THEN
            l_hs := TOOLS.GetHistSession;

            --Створені рядки нарахувань, що створювались під час блокування, переводимо в стан "Історичний".
            UPDATE ac_detail
               SET history_status = 'H'
             WHERE     acd_prsd IS NULL
                   AND acd_imp_pr_num IS NULL
                   AND history_status = 'A'
                   AND acd_id IN
                           (SELECT prsa_acd_inserted
                              FROM pr_blocked_acd prsa, pr_sheet_detail
                             WHERE     prsd_prs = l_prs_id
                                   AND prsd_id = prsa_prsd
                                   AND prsa.history_status = 'A');
        END IF;

        --Блоковані рядки нарахувань, прив'язані до цього запису відомості, переводимо в стан "Актуальний".
        UPDATE ac_detail
           SET history_status = 'A'
         WHERE     acd_prsd IN (SELECT prsd_id
                                  FROM pr_sheet_detail
                                 WHERE prsd_prs = l_prs_id)
               AND history_status = 'H'
               AND acd_id IN
                       (SELECT prsa_acd_blocked
                          FROM pr_blocked_acd prsa, pr_sheet_detail
                         WHERE     prsd_prs = l_prs_id
                               AND prsd_id = prsa_prsd
                               AND prsa.history_status = 'A');

        --Реєстр заблокованих та створених при блокуванні записів операцій по рядкам відомості - в історичні
        UPDATE pr_blocked_acd
           SET history_status = 'H', prsa_hs_del = l_hs
         WHERE EXISTS
                   (SELECT 1
                      FROM pr_sheet_detail
                     WHERE prsd_prs = l_prs_id AND prsd_id = prsa_prsd);

        --Переводимо рядок відомості в стан NA.
        UPDATE pr_sheet
           SET prs_st = 'NA', prs_transfer_dt = NULL, prs_pcb = NULL
         WHERE prs_id = p_prs_id;
    --  raise_application_error(-20000, 'pk2_manual_return');
    END;
BEGIN
    -- Initialization
    NULL;
END API$PAYROLL;
/