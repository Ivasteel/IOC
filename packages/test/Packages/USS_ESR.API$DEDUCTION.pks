/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$DEDUCTION
IS
    -- Author  : VANO
    -- Created : 08.12.2021 11:08:27
    -- Purpose : Функції роботи з відрахуваннями

    g_write_messages_to_output   INTEGER := 0;

    PROCEDURE write_dn_log (p_dnl_dn        dn_log.dnl_dn%TYPE,
                            p_dnl_hs        dn_log.dnl_hs%TYPE,
                            p_dnl_st        dn_log.dnl_st%TYPE,
                            p_dnl_message   dn_log.dnl_message%TYPE,
                            p_dnl_st_old    dn_log.dnl_st_old%TYPE,
                            p_dnl_tp        dn_log.dnl_tp%TYPE:= 'SYS');

    PROCEDURE init_deduction_by_appeals (p_mode           INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                         p_ap_id          appeal.ap_id%TYPE,
                                         p_messages   OUT SYS_REFCURSOR);

    PROCEDURE init_deduction_by_state_alimony (
        p_mode              INTEGER,   --1=з p_ps_id, 2=з таблиці tmp_work_ids
        p_ps_id             pc_state_alimony.ps_id%TYPE,
        p_messages   IN OUT TOOLS.t_messages,
        p_hs_id             histsession.hs_id%TYPE := NULL);

    --Функція формування відрахуваннь на основі знайдених переплат
    PROCEDURE init_deduction_by_accrual (
        p_mode              INTEGER,               --2=з таблиці tmp_work_ids1
        p_messages   IN OUT TOOLS.t_messages);

    PROCEDURE approve_deduction (p_dn_id deduction.dn_id%TYPE);

    PROCEDURE reject_deduction (p_dn_id       deduction.dn_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL);

    --Відміна рішення щодо переплати
    PROCEDURE cancel_deduction (p_dn_id       deduction.dn_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL);

    PROCEDURE save_deduction (
        p_dn_id               deduction.dn_id%TYPE,
        p_dn_reason           deduction.dn_reason%TYPE,
        p_dn_debt_limit_prc   deduction.dn_debt_limit_prc%TYPE);

    --Обробка звернень по згоді на добровільне поверенння переплат
    PROCEDURE process_deduction_by_appeal (
        p_mode        INTEGER,
        p_ap_id       appeal.ap_id%TYPE,
        p_dn_id   OUT deduction.dn_id%TYPE);

    -- #79263: збереження картки переплат
    PROCEDURE save_overpay_card (
        p_dn_id               IN NUMBER,
        p_dn_reason           IN VARCHAR2,
        p_dn_debt_limit_prc   IN deduction.dn_debt_limit_prc%TYPE,
        p_dn_pa               IN deduction.dn_pa%TYPE);

    --Проведення поверення коштів
    --Через таблицю tmp_work_set1 вказуються:
    --Погашення боргу: x_strin1='SL' + x_id1=dn_id + x_sum1=сума
    --Надміру сплачені кошти: x_strin1='RT' + x_sum1=сума
    PROCEDURE process_rr_list (p_rrl_id rr_list.rrl_id%TYPE);

    --Відкат операції проведення поверення
    PROCEDURE return_rr_list (p_rrl_id rr_list.rrl_id%TYPE);

    PROCEDURE renew_deduction (p_dn_id      deduction.dn_id%TYPE,
                               p_renew_dt   dn_detail.dnd_start_dt%TYPE);

    --Закриття "аліментного" рішення
    PROCEDURE close_deduction (p_dn_id deduction.dn_id%TYPE, p_close_dt DATE);

    --Контроль історії відрахування
    PROCEDURE check_dn_hist (p_dn_id deduction.dn_id%TYPE);
END API$DEDUCTION;
/


/* Formatted on 8/12/2025 5:48:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$DEDUCTION
IS
    PROCEDURE write_dn_log (p_dnl_dn        dn_log.dnl_dn%TYPE,
                            p_dnl_hs        dn_log.dnl_hs%TYPE,
                            p_dnl_st        dn_log.dnl_st%TYPE,
                            p_dnl_message   dn_log.dnl_message%TYPE,
                            p_dnl_st_old    dn_log.dnl_st_old%TYPE,
                            p_dnl_tp        dn_log.dnl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := NVL (p_dnl_hs, TOOLS.GetHistSession);

        INSERT INTO dn_log (dnl_id,
                            dnl_dn,
                            dnl_hs,
                            dnl_st,
                            dnl_message,
                            dnl_st_old,
                            dnl_tp)
             VALUES (0,
                     p_dnl_dn,
                     l_hs,
                     p_dnl_st,
                     p_dnl_message,
                     p_dnl_st_old,
                     NVL (p_dnl_tp, 'SYS'));
    END;

    PROCEDURE debug_write_1 (p_table_name VARCHAR2)
    IS
    BEGIN
        IF g_write_messages_to_output = 1
        THEN
            EXECUTE IMMEDIATE   'begin BLD$IMPEXP.debug_table_data(''USS_ESR'', '''
                             || p_table_name
                             || ''', ''where dnd_dn = 58476 order by dnd_start_dt desc'', ''TAB''); end;';
        END IF;
    END;

    PROCEDURE check_dn_hist (p_dn_id deduction.dn_id%TYPE)
    IS
        l_cnt   INTEGER;
        l_msg   VARCHAR2 (500);
    BEGIN
        WITH
            dnh
            AS
                (SELECT DISTINCT dnd_start_dt     AS x_dt
                   FROM uss_esr.dn_detail
                  WHERE history_status = 'A' AND dnd_dn = p_dn_id)
        SELECT COUNT (*),
               LISTAGG (TO_CHAR (x_dt, 'DD.MM.YYYY'), ',')
                   WITHIN GROUP (ORDER BY x_dt)
          INTO l_cnt, l_msg
          FROM dnh
         WHERE 1 <
               (SELECT COUNT (*)
                  FROM uss_esr.dn_detail
                 WHERE     dnd_dn = p_dn_id
                       AND history_status = 'A'
                       AND x_dt >= dnd_start_dt
                       AND (x_dt <= dnd_stop_dt OR dnd_stop_dt IS NULL));

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'Помилка маніпуляцій з історією відраухвання! В результаті змін виявлено дублікати або перетини історії на дати <'
                || l_msg
                || '>. dn='
                || p_dn_id);
        END IF;
    END;

    --Функція формування відрахуваннь на основі звернення
    PROCEDURE init_deduction_by_appeals (p_mode           INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                         p_ap_id          appeal.ap_id%TYPE,
                                         p_messages   OUT SYS_REFCURSOR)
    IS
        l_com_org       pc_decision.com_org%TYPE;
        l_com_wu        pc_decision.com_wu%TYPE;
        l_lock_init     TOOLS.t_lockhandler;
        l_cnt           INTEGER;
        g_messages      TOOLS.t_messages := TOOLS.t_messages ();
        l_hs            histsession.hs_id%TYPE;
        l_have_errors   INTEGER := 0;
    BEGIN
        l_com_org := TOOLS.GetCurrOrg;
        l_com_wu := TOOLS.GetCurrWu;
        l_lock_init :=
            TOOLS.request_lock (
                p_descr   => 'INIT_DEDUCTION_' || p_ap_id,
                p_error_msg   =>
                       'В даний момент вже виконується створення відрахувань по зверненню '
                    || p_ap_id
                    || '!');

        IF l_com_org IS NULL
        THEN
            raise_application_error (-20000,
                                     'Не можу визначити орган призначення!');
        END IF;

        IF l_com_wu IS NULL
        THEN
            raise_application_error (-20000,
                                     'Не можу визначити користувача!');
        END IF;

        IF p_mode = 1 AND p_ap_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT ap_id
                  FROM v_appeal
                 WHERE ap_id = p_ap_id AND ap_st IN ('O') AND ap_tp = 'A';

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, v_appeal
             WHERE x_id = ap_id AND ap_st IN ('O');
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування відрахувань не передано зверненнь!');
        END IF;

        TOOLS.add_message (g_messages,
                           'W',
                           'Розпочинаю формування відрахувань!');

        FOR xx
            IN (SELECT ap_num,
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_string (ap_id,
                                                                10244,
                                                                4297),
                           API$APPEAL.get_ap_o_doc_string (ap_id, 10031, 886))
                           AS x_unit,
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_id (ap_id,
                                                            10244,
                                                            4298),
                           (SELECT MIN (ndn_id)
                              FROM uss_ndi.v_ndi_deduction
                             WHERE ndn_nst = aps_nst))
                           AS x_ndn
                  FROM tmp_work_ids,
                       appeal,
                       ap_service    aps,
                       personalcase  pc
                 WHERE     ap_id = x_id
                       AND ap_tp = 'A'
                       AND ap_pc IS NOT NULL
                       AND aps_ap = ap_id
                       AND aps.history_status = 'A'
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM deduction
                                 WHERE dn_ap = ap_id)
                       AND ap_pc = pc_id)
        LOOP
            IF xx.x_unit IS NULL
            THEN
                l_have_errors := l_have_errors + 1;
                TOOLS.add_message (
                    g_messages,
                    'E',
                       'В зверненні '
                    || xx.ap_num
                    || ' не вказано одиницю відрахування!');
            END IF;

            IF xx.x_ndn IS NULL
            THEN
                l_have_errors := l_have_errors + 1;
                TOOLS.add_message (
                    g_messages,
                    'E',
                       'В зверненні '
                    || xx.ap_num
                    || ' не не можу визначити тип відрахування!');
            END IF;
        END LOOP;

        IF l_have_errors = 0
        THEN
            l_hs := TOOLS.GetHistSession;

            INSERT INTO deduction (dn_id,
                                   dn_pc,
                                   dn_ndn,
                                   dn_in_doc_tp,
                                   dn_in_doc_num,
                                   dn_in_doc_dt,
                                   dn_out_doc_num,
                                   dn_out_doc_dt,
                                   dn_unit,
                                   dn_st,
                                   history_status,
                                   dn_debt_total,
                                   dn_debt_current,
                                   dn_is_min_pay,
                                   dn_start_dt,
                                   dn_stop_dt,
                                   dn_unlock_dt,
                                   com_org,
                                   dn_ps,
                                   dn_ap,
                                   dn_dpp,
                                   dn_hs_ins,
                                   dn_debt_limit_prc,
                                   dn_pa,
                                   dn_tp,
                                   dn_params_src)
                SELECT 0,
                       ap_pc,
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_id (ap_id,
                                                            10244,
                                                            4298),
                           (SELECT MIN (ndn_id)
                              FROM uss_ndi.v_ndi_deduction
                             WHERE ndn_nst = aps_nst)),
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_string (ap_id,
                                                                10244,
                                                                4303),
                           API$APPEAL.get_ap_o_doc_string (ap_id, 10031, 944)),
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_string (ap_id,
                                                                10244,
                                                                4302),
                           API$APPEAL.get_ap_o_doc_string (ap_id, 10031, 928)),
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_dt (ap_id,
                                                            10244,
                                                            4301),
                           API$APPEAL.get_ap_o_doc_dt (ap_id, 10031, 927)),
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_string (ap_id,
                                                                10244,
                                                                4304),
                           API$APPEAL.get_ap_o_doc_string (ap_id, 10031, 945)),
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_dt (ap_id,
                                                            10244,
                                                            4305),
                           API$APPEAL.get_ap_o_doc_dt (ap_id, 10031, 946)),
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_string (ap_id,
                                                                10244,
                                                                4297),
                           API$APPEAL.get_ap_o_doc_string (ap_id, 10031, 886)),
                       'E',
                       'A',
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_sum (ap_id,
                                                             10244,
                                                             4296),
                           API$APPEAL.get_ap_o_doc_sum (ap_id, 10031, 885)),
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_sum (ap_id,
                                                             10244,
                                                             4296),
                           API$APPEAL.get_ap_o_doc_sum (ap_id, 10031, 885)),
                       'F',
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_dt (ap_id,
                                                            10244,
                                                            4294),
                           API$APPEAL.get_ap_o_doc_dt (ap_id, 10031, 880)),
                       DECODE (
                           aps_nst,
                           603, TO_DATE ('31.12.2099', 'DD.MM.YYYY'),
                           API$APPEAL.get_ap_o_doc_dt (ap_id, 10031, 943)),
                       NULL,
                       pc.com_org,
                       NULL,
                       ap_id,
                       (SELECT dppa_dpp
                          FROM ap_payment, uss_ndi.v_ndi_pay_person_acc
                         WHERE apm_ap = ap_id AND apm_dppa = dppa_id),
                       l_hs,
                       DECODE (
                           aps_nst,
                           603, DECODE (
                                    API$APPEAL.get_ap_o_doc_string (ap_id,
                                                                    10244,
                                                                    4297),
                                    'PD', API$APPEAL.get_ap_o_doc_sum (ap_id,
                                                                       10244,
                                                                       4299),
                                    20),
                           API$APPEAL.get_ap_o_doc_sum (ap_id, 10031, 926)),
                       NULL,
                       (SELECT ndn_dn_tp
                          FROM uss_ndi.v_ndi_deduction
                         WHERE ndn_id =
                               DECODE (
                                   aps_nst,
                                   603, API$APPEAL.get_ap_o_doc_id (ap_id,
                                                                    10244,
                                                                    4298),
                                   (SELECT MIN (x.ndn_id)
                                      FROM uss_ndi.v_ndi_deduction x
                                     WHERE x.ndn_nst = aps_nst))),
                       CASE
                           WHEN NVL (
                                    API$APPEAL.get_ap_o_doc_string (ap_id,
                                                                    10031,
                                                                    4367),
                                    'T') =
                                'T'
                           THEN
                               'DND'
                           ELSE
                               'DNP'
                       END
                  FROM tmp_work_ids,
                       appeal,
                       ap_service    aps,
                       personalcase  pc
                 WHERE     ap_id = x_id
                       AND ap_tp = 'A'
                       AND ap_pc IS NOT NULL
                       AND aps_ap = ap_id
                       AND aps.history_status = 'A'
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM deduction
                                 WHERE dn_ap = ap_id)
                       AND ap_pc = pc_id;

            INSERT INTO dn_detail (dnd_id,
                                   dnd_dn,
                                   dnd_start_dt,
                                   dnd_stop_dt,
                                   dnd_tp,
                                   dnd_value,
                                   history_status,
                                   dnd_psc,
                                   dnd_value_prefix,
                                   dnd_dppa)
                SELECT 0,
                       dn_id,
                       dn_start_dt,
                       dn_stop_dt,
                       dn_unit,
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_sum (ap_id,
                                                             10244,
                                                             4299),
                           API$APPEAL.get_ap_o_doc_sum (ap_id, 10031, 887)),
                       'A',
                       NULL,
                       DECODE (
                           aps_nst,
                           603, API$APPEAL.get_ap_o_doc_sum (ap_id,
                                                             10244,
                                                             4300),
                           API$APPEAL.get_ap_o_doc_sum (ap_id, 10031, 890)),
                       (SELECT apm_dppa
                          FROM ap_payment
                         WHERE apm_ap = ap_id)
                  FROM tmp_work_ids,
                       appeal,
                       ap_service  aps,
                       deduction
                 WHERE     ap_id = x_id
                       AND ap_tp = 'A'
                       AND ap_pc IS NOT NULL
                       AND aps_ap = ap_id
                       AND aps.history_status = 'A'
                       AND dn_ap = ap_id
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM dn_detail
                                 WHERE dnd_dn = dn_id);

            INSERT INTO dn_person (dnp_id,
                                   dnp_dn,
                                   dnp_sc,
                                   dnp_start_dt,
                                   dnp_stop_dt,
                                   history_status,
                                   dnp_birth_dt,
                                   dnp_tp,
                                   dnp_value,
                                   dnp_value_prefix,
                                   dnp_nl_tp,
                                   dnp_nl_value,
                                   dnp_nl_value_prefix)
                SELECT 0,
                       dn_id,
                       app.app_sc,
                       api$appeal.get_doc_dt (app_id, 10032, 888)
                           AS birth_dt,
                       api$appeal.get_doc_dt (app_id, 10238, 4284)
                           AS stop_dt,
                       'A',
                       api$appeal.get_doc_dt (app_id, 10032, 888)
                           AS birth_dt,
                       NVL (api$appeal.get_doc_string (app_id, 10238, 4281),
                            dn_unit)
                           AS dnp_tp,
                       api$appeal.get_doc_sum (app_id, 10238, 4282)
                           AS dnp_value,
                       api$appeal.get_doc_sum (app_id, 10238, 4283)
                           AS dnp_value_prefix,
                       CASE
                           WHEN api$appeal.get_doc_string (app_id,
                                                           10238,
                                                           4285) IN
                                    ('30', '50')
                           THEN
                               'PL'
                       END
                           dnp_nl_tp,
                       DECODE (
                           api$appeal.get_doc_string (app_id, 10238, 4285),
                           '30', 30,
                           '50', 50,
                           NULL)
                           AS dnp_nl_value,
                       NULL
                           AS dnp_nl_value_prefix
                  FROM tmp_work_ids
                       JOIN deduction ON dn_ap = x_id                  --ap_id
                       JOIN ap_person app
                           ON     app_ap = dn_ap
                              AND app_tp = 'FA'
                              AND app.history_status = 'A'
                 WHERE NOT EXISTS
                           (SELECT 1
                              FROM dn_person
                             WHERE dnp_dn = dn_id);


            --Переводимо звернення в стан 'WD' = Опрацювання рішення, якщо хоча б одне відрахування створене
            API$APPEAL.mark_appeal_working (2,
                                            2,
                                            NULL,
                                            l_cnt);

            IF l_cnt = 0
            THEN
                TOOLS.add_message (
                    g_messages,
                    'W',
                    'Відрахувань за зверненням не знайдено, стан звернення не змінено!');
            END IF;

            --Перевіряємо, чи коректно змінили історію по відрахуванням
            FOR xx IN (SELECT dn_id
                         FROM deduction
                        WHERE dn_hs_ins = l_hs
                       UNION
                       SELECT dnd_dn
                         FROM dn_detail
                        WHERE dnd_hs_ins = l_hs OR dnd_hs_del = l_hs)
            LOOP
                check_dn_hist (xx.dn_id);
            END LOOP;

            --Пишемо протокол обробки
            FOR xx IN (SELECT dn_id
                         FROM deduction
                        WHERE dn_hs_ins = l_hs)
            LOOP
                write_dn_log (xx.dn_id,
                              NULL,
                              'E',
                              CHR (38) || '39',
                              NULL,
                              'SYS');
            END LOOP;
        END IF;

        TOOLS.release_lock (l_lock_init);

        TOOLS.add_message (g_messages,
                           'W',
                           'Завершую формування відрахувань!');

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;

    --Функція формування відрахуваннь на основі держутримання
    PROCEDURE init_deduction_by_state_alimony (
        p_mode              INTEGER, --1=з p_ps_id, 2=з таблиці tmp_work_ids_dn
        p_ps_id             pc_state_alimony.ps_id%TYPE,
        p_messages   IN OUT TOOLS.t_messages,
        p_hs_id             histsession.hs_id%TYPE := NULL)
    IS
        l_com_org     pc_decision.com_org%TYPE;
        l_com_wu      pc_decision.com_wu%TYPE;
        l_lock_init   TOOLS.t_lockhandler;
        l_cnt         INTEGER;
        l_id          deduction.dn_id%TYPE;
        --g_messages TOOLS.t_messages := TOOLS.t_messages();
        l_hs          histsession.hs_id%TYPE;
    BEGIN
        l_com_org := TOOLS.GetCurrOrg;
        l_com_wu := TOOLS.GetCurrWu;
        l_lock_init :=
            TOOLS.request_lock (
                p_descr   => 'INIT_DEDUCTION_BY_PS_' || p_ps_id,
                p_error_msg   =>
                       'В даний момент вже виконується створення відрахувань по держутриманню '
                    || p_ps_id
                    || '!');

        IF l_com_org IS NULL
        THEN
            raise_application_error (-20000,
                                     'Не можу визначити орган призначення!');
        END IF;

        IF l_com_wu IS NULL
        THEN
            raise_application_error (-20000,
                                     'Не можу визначити користувача!');
        END IF;

        --return;
        IF p_mode = 1 AND p_ps_id IS NOT NULL
        THEN
            raise_application_error (-20000, 'Режим не підтримується!');
        /*    DELETE FROM tmp_work_ids_dn WHERE 1 = 1;
            INSERT INTO tmp_work_ids_dn (x_id)
              SELECT ps_id
              FROM v_pc_state_alimony
              WHERE ps_id = p_ps_id
                AND ps_st IN ('P');

            l_cnt := SQL%ROWCOUNT;*/
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM v_pc_state_alimony, tmp_work_ids_dn
             WHERE x_id = ps_id AND ps_st IN ('P');

            IF l_cnt = 0
            THEN
                SELECT COUNT (*)
                  INTO l_cnt
                  FROM v_ps_changes, tmp_work_ids_dn
                 WHERE x_id = psc_ps AND history_status = 'A';
            END IF;
        END IF;

        --return;
        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування відрахувань по держутриманню не передано записів держутримання!');
        END IF;

        TOOLS.add_message (p_messages,
                           'W',
                           'Розпочинаю формування відрахувань!');

        l_hs := NVL (p_hs_id, TOOLS.GetHistSession);

        INSERT INTO deduction (dn_id,
                               dn_pc,
                               dn_ndn,
                               dn_in_doc_tp,
                               dn_in_doc_num,
                               dn_in_doc_dt,
                               dn_out_doc_num,
                               dn_out_doc_dt,
                               dn_unit,
                               dn_st,
                               history_status,
                               dn_debt_total,
                               dn_debt_current,
                               dn_is_min_pay,
                               dn_debt_post,
                               dn_prc_above,
                               dn_block_dt,
                               dn_block_reason,
                               dn_start_dt,
                               dn_stop_dt,
                               dn_unlock_dt,
                               com_org,
                               dn_ps,
                               dn_ap,
                               dn_dpp,
                               dn_hs_ins,
                               dn_pa,
                               dn_tp,
                               dn_params_src)
            SELECT 0,
                   ap_pc,
                   67,
                   'Звернення',
                   ap_num,
                   TRUNC (ap_reg_dt),
                   NULL,
                   NULL,
                   'PD',
                   'E',
                   'A',
                   NULL,
                   NULL,
                   'F',
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   x_start_dt,
                   NULL,
                   NULL,
                   l_com_org,
                   ps_id,
                   ap_id,
                   ps_dpp,
                   l_hs,
                   x_pa,
                   'D',
                   'DND'
              FROM tmp_work_ids_dn,
                   v_pc_state_alimony,
                   ps_changes  psc,
                   appeal,
                   ap_service  aps,
                   tmp_work_pa_ids,
                   pc_account
             WHERE     NOT EXISTS
                           (SELECT 1
                              FROM deduction
                             WHERE dn_ap = ap_id)
                   AND ps_id = x_id
                   AND psc_ps = ps_id
                   AND ps_ap = ap_id
                   AND aps_ap = ap_id
                   AND aps.history_status = 'A'
                   AND (   ap_tp IN ('U')        --Звернення держутримання або
                        OR (    ap_tp = 'V'            --Звернення по допомогу
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_service sx
                                      WHERE     sx.aps_ap = ap_id
                                            AND sx.aps_nst = 248
                                            AND sx.history_Status = 'A') --з послугою "особам з інвалідністю
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_document apd, ap_person app
                                      WHERE     apd_app = app_id
                                            AND apd_ap = ap_id
                                            AND apd_app = app_id
                                            AND apd_ndt = 10034
                                            AND apd.history_Status = 'A'
                                            AND app.history_status = 'A'))) --і наявністю довідки про зарахування
                   AND ap_pc IS NOT NULL
                   AND psc.history_status = 'A'
                   AND x_action = 'IN_NEW'
                   AND ap_pc = pa_pc
                   AND pa_id = x_pa
                   AND x_nst IN (1, 3, 248);

        IF SQL%ROWCOUNT = 0
        THEN
            TOOLS.add_message (p_messages,
                               'W',
                               'Відрахувань за держутриманням не створено!');
        END IF;

        INSERT INTO dn_detail (dnd_id,
                               dnd_dn,
                               dnd_start_dt,
                               dnd_stop_dt,
                               dnd_tp,
                               dnd_value,
                               history_status,
                               dnd_psc,
                               dnd_value_prefix,
                               dnd_dppa,
                               dnd_hs_ins)
            WITH
                work_ids_dn
                AS
                    (SELECT z.*,
                            (SELECT MIN (app_id)
                               FROM ap_person app, ap_document apd
                              WHERE     app_ap = ps_ap
                                    AND app.history_status = 'A'
                                    AND apd.history_status = 'A'
                                    AND apd_app = app_id
                                    AND apd_ndt = 10033)    AS x_app_10033
                       FROM tmp_work_ids_dn z, pc_state_alimony
                      WHERE ps_id = x_id)
            SELECT 0,
                   dn_id,
                   dn_start_dt,
                   dn_stop_dt,
                   dn_unit,
                   API$APPEAL.get_doc_sum (x_app_10033, 10033, 902),
                   'A',
                   psc_id,
                   NULL,
                   psc_dppa,
                   l_hs
              FROM work_ids_dn,
                   v_pc_state_alimony,
                   appeal,
                   ap_service  aps,
                   deduction,
                   ap_person,
                   ps_changes  psc
             WHERE     ps_id = x_id
                   AND (   ap_tp IN ('U')        --Звернення держутримання або
                        OR (    ap_tp = 'V'            --Звернення по допомогу
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_service dx
                                      WHERE     dx.aps_ap = ap_id
                                            AND dx.aps_nst = 248
                                            AND dx.history_Status = 'A') --з послугою "особам з інвалідністю
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_document apd
                                      WHERE     apd_ap = ap_id
                                            AND apd_app = app_id
                                            AND apd_ndt = 10034
                                            AND apd.history_Status = 'A'))) --і наявністю довідки про зарахування
                   AND ap_pc IS NOT NULL
                   AND aps_ap = ap_id
                   AND aps.history_status = 'A'
                   AND dn_ap = ap_id
                   AND ps_ap = ap_id
                   AND app_ap = ap_id
                   AND app_sc = ps_sc
                   AND psc_ps = ps_id
                   AND psc.history_status = 'A'
                   --AND psc_start_dt = dn_start_dt
                   AND NOT EXISTS
                           (SELECT 1
                              FROM dn_detail
                             WHERE dnd_dn = dn_id)
                   AND x_action = 'IN_NEW';

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_ids_dn
         WHERE x_action IN ('IN', 'OUT');

        IF l_cnt > 0
        THEN
            DELETE FROM tmp_dn_detail
                  WHERE 1 = 1;

            INSERT INTO tmp_dn_detail (z_id,
                                       z_dn,
                                       z_start_dt,
                                       z_stop_dt,
                                       z_tp,
                                       z_value,
                                       z_psc,
                                       z_value_prefix,
                                       z_dppa)
                SELECT dnd_id,
                       dnd_dn,
                       dnd_start_dt,
                       dnd_stop_dt,
                       dnd_tp,
                       dnd_value,
                       dnd_psc,
                       dnd_value_prefix,
                       dnd_dppa
                  FROM deduction dn, dn_detail dnd, uss_ndi.v_ndi_deduction
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM tmp_work_ids_dn
                                 WHERE     dn_ps = x_id
                                       AND x_action IN ('IN', 'OUT'))
                       AND dnd_dn = dn_id
                       AND dn.history_status = 'A'
                       AND dnd.history_status = 'A'
                       AND dn_ndn = ndn_id
                       AND ndn_calc_step = 'F';

            api$hist.init_work;

            --По записам оновлення стану - створуємо потрібні записи історії
            INSERT INTO tmp_unh_old_list (ol_obj,
                                          ol_hst,
                                          ol_begin,
                                          ol_end)
                SELECT z_dn, z_id, z_start_dt, z_stop_dt FROM tmp_dn_detail;

            INSERT INTO tmp_unh_work_list (work_obj,
                                           work_hst,
                                           work_begin,
                                           work_end)
                SELECT dn_id,
                       0,
                       x_start_dt,
                       x_stop_dt                 --прибув/вибув + вибув/прибув
                  FROM tmp_work_ids_dn, deduction d, uss_ndi.v_ndi_deduction
                 WHERE     x_action IN ('IN', 'OUT')
                       AND d.history_status = 'A'
                       AND dn_ps = x_id
                       AND dn_ndn = ndn_id
                       AND ndn_calc_step = 'F';

            api$hist.setup_history (2,
                                    NULL,
                                    NULL,
                                    NULL);

            -- закриття записів, які видаляються
            UPDATE dn_detail
               SET history_status = 'H', dnd_hs_del = l_hs
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_unh_to_prp
                         WHERE tprp_hst = dnd_id);

            --return;
            -- додавання нової історії
            INSERT INTO dn_detail (dnd_id,
                                   dnd_dn,
                                   dnd_start_dt,
                                   dnd_stop_dt,
                                   dnd_tp,
                                   dnd_value,
                                   history_status,
                                   dnd_psc,
                                   dnd_value_prefix,
                                   dnd_dppa,
                                   dnd_hs_ins)
                SELECT 0,
                       dnd_dn,
                       rz_begin,
                       rz_end,
                       dnd_tp,
                       dnd_value,
                       'A',
                       dnd_psc,
                       dnd_value_prefix,
                       dnd_dppa,
                       l_hs
                  FROM tmp_unh_rz_list, dn_detail --Додавання періодів, по яким не змінюються параметри
                 WHERE     rz_hst <> 0
                       AND (rz_begin <= rz_end OR rz_end IS NULL)
                       AND dnd_id = rz_hst
                UNION ALL
                SELECT 0,
                       dn_id,
                       rz_begin,
                       rz_end,
                       dn_unit,
                       CASE
                           WHEN psc_st = 'OUT'
                           THEN
                               NULL
                           ELSE
                               COALESCE (
                                   (SELECT MAX (z_value)
                                      FROM tmp_dn_detail sl1
                                     WHERE     z_dn = dn_id
                                           AND z_start_dt =
                                               (SELECT MAX (sl2.z_start_dt)
                                                  FROM tmp_dn_detail sl2
                                                 WHERE     sl2.z_dn = dn_id
                                                       AND z_value
                                                               IS NOT NULL
                                                       AND sl2.z_start_dt <
                                                           rz_begin)),
                                   (SELECT MAX (dnd_value)
                                      FROM dn_detail d
                                     WHERE     dnd_dn = dn_id
                                           AND d.history_status = 'H'
                                           AND rz_begin BETWEEN dnd_start_dt
                                                            AND rz_begin), --якщо попереднього запису з даними немає, шукаємо в історії на цей період
                                   (SELECT MAX (dnd_value)
                                      FROM dn_detail d
                                     WHERE dnd_dn = dn_id)) --якщо і в історії на дату немає, то беремо взагалі по всій деталізації відрахування
                       END,
                       'A',
                       x_psc,
                       NULL,
                       CASE
                           WHEN psc_st = 'OUT'
                           THEN
                               NULL
                           ELSE
                               (SELECT MAX (z_dppa)
                                  FROM tmp_dn_detail sl1
                                 WHERE     z_dn = dn_id
                                       AND z_start_dt =
                                           (SELECT MAX (sl2.z_start_dt)
                                              FROM tmp_dn_detail sl2
                                             WHERE     sl2.z_dn = dn_id
                                                   AND z_value IS NOT NULL
                                                   AND sl2.z_start_dt <
                                                       rz_begin))
                       END,
                       l_hs
                  FROM tmp_unh_rz_list,
                       deduction,
                       tmp_work_ids_dn,
                       ps_changes,
                       uss_ndi.v_ndi_deduction --Додавання періодів, по яким змінюються параметри
                 WHERE     rz_hst = 0
                       AND (rz_begin <= rz_end OR rz_end IS NULL)
                       AND rz_obj = dn_id
                       AND rz_begin = x_start_dt
                       AND dn_ps = x_id
                       AND x_action IN ('IN', 'OUT')
                       AND x_psc = psc_id
                       AND dn_ndn = ndn_id
                       AND ndn_calc_step = 'F';

            SELECT COUNT (*), MAX (dn_id)
              INTO l_cnt, l_id
              FROM dn_detail  d,
                   deduction,
                   tmp_work_ids_dn,
                   tmp_unh_rz_list,
                   ps_changes,
                   uss_ndi.v_ndi_deduction
             WHERE     d.history_status = 'A'
                   AND dnd_dn = dn_id
                   AND dn_ps = x_id
                   AND dnd_value IS NULL
                   AND rz_hst = 0
                   AND rz_begin = dnd_start_dt
                   AND x_action = 'IN'
                   AND dnd_psc = psc_id
                   AND psc_st = 'IN'
                   AND dn_ndn = ndn_id
                   AND ndn_calc_step = 'F';

            debug_write_1 ('dn_detail');

            --    return;
            IF l_cnt > 0
            THEN
                raise_application_error (
                    -20000,
                       'Функція зміни історії відрахування не змогла визначити відсоток/чисельник параметрів відрахування! dn='
                    || l_id);
            END IF;
        END IF;

        --Переводимо звернення в стан 'WD' = Опрацювання рішення, якщо хоча б одне відрахування створене
        --API$APPEAL.mark_appeal_working(2, 2, NULL, l_cnt);

        --Перевіряємо, чи коректно змінили історію по відрахуванням
        FOR xx IN (SELECT dn_id
                     FROM deduction
                    WHERE dn_hs_ins = l_hs
                   UNION
                   SELECT dnd_dn
                     FROM dn_detail
                    WHERE dnd_hs_ins = l_hs OR dnd_hs_del = l_hs)
        LOOP
            check_dn_hist (xx.dn_id);
        END LOOP;

        --Пишемо протокол обробки
        FOR xx IN (SELECT dn_id
                     FROM deduction
                    WHERE dn_hs_ins = l_hs)
        LOOP
            write_dn_log (xx.dn_id,
                          NULL,
                          'E',
                          CHR (38) || '44',
                          NULL,
                          'SYS');
        END LOOP;

        TOOLS.add_message (p_messages,
                           'W',
                           'Завершую формування відрахувань!');

        TOOLS.release_lock (l_lock_init);
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.release_lock (l_lock_init);
            RAISE;
    END;

    --Функція формування відрахуваннь на основі знайдених переплат
    PROCEDURE init_deduction_by_accrual (
        p_mode              INTEGER,               --2=з таблиці tmp_work_ids2
        p_messages   IN OUT TOOLS.t_messages)
    IS
        l_com_org   pc_decision.com_org%TYPE;
        l_cnt       INTEGER;
        l_hs        histsession.hs_id%TYPE;
        l_ndn       deduction.dn_ndn%TYPE;
        l_ndn_sa    deduction.dn_ndn%TYPE;
    BEGIN
        TOOLS.add_message (p_messages,
                           'W',
                           'Розпочинаю формування відрахувань!');

        IF p_mode IS NULL OR p_mode <> 2
        THEN
            raise_application_error (-20000, 'Режим не підтримується!');
        END IF;

        l_com_org := TOOLS.GetCurrOrg;

        IF l_com_org IS NULL
        THEN
            raise_application_error (-20000,
                                     'Не можу визначити орган призначення!');
        END IF;


        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_ids2, ac_detail
         WHERE x_id = acd_id;

        IF l_cnt = 0
        THEN
            TOOLS.add_message (
                p_messages,
                'I',
                'В функцію формування відрахувань не передано рядків нарахувань!');
            RETURN;
        --raise_application_error(-20000, 'В функцію формування відрахувань не передано рядків нарахувань!');
        END IF;


        --Формуємо множину відрахувань
        DELETE FROM tmp_work_idba
              WHERE 1 = 1;

        INSERT INTO tmp_work_idba (x_id1,
                                   x_id2,
                                   x_dt1,
                                   x_nst,
                                   x_pa,
                                   x_op,
                                   x_sum1)
              SELECT ac_pc,
                     ac.com_org,
                     ac_month,
                     pa_nst,
                     pa_id,
                     acd_op,
                     SUM (acd_sum)
                FROM tmp_work_ids2,
                     ac_detail,
                     accrual ac,
                     uss_ndi.v_ndi_npt_config,
                     pc_account,
                     pc_decision
               WHERE     acd_id = x_id
                     AND acd_ac = ac_id
                     AND acd_npt = nptc_npt
                     AND pa_pc = ac.ac_pc
                     AND pa_nst = nptc_nst
                     AND acd_pd = pd_id
                     AND pd_pa = pa_id
            GROUP BY ac_pc,
                     ac.com_org,
                     ac_month,
                     pa_nst,
                     pa_id,
                     acd_op;

        --Якщо знайшлось хоч одне відрахування - пишемо його в базу
        IF SQL%ROWCOUNT > 0
        THEN
            l_hs := TOOLS.GetHistSession;

            l_ndn := TOOLS.ggpn ('ACCRUAL_NDN');
            l_ndn_sa := TOOLS.ggpn ('ACCRUAL_NDN_SA');

            UPDATE tmp_work_idba
               SET x_id3 = id_deduction (0)
             WHERE 1 = 1;

            --Створюємо відрахування та 1 деталь для кожного - з періодом в 1 місяць.
            INSERT ALL
              INTO deduction (dn_id,
                              dn_pc,
                              dn_ndn,
                              dn_in_doc_tp,
                              dn_in_doc_num,
                              dn_in_doc_dt,
                              dn_out_doc_num,
                              dn_out_doc_dt,
                              dn_unit,
                              dn_st,
                              history_status,
                              dn_debt_total,
                              dn_debt_current,
                              dn_is_min_pay,
                              dn_debt_post,
                              dn_prc_above,
                              dn_block_dt,
                              dn_block_reason,
                              dn_start_dt,
                              dn_stop_dt,
                              dn_unlock_dt,
                              com_org,
                              dn_ps,
                              dn_ap,
                              dn_dpp,
                              dn_hs_ins,
                              dn_debt_limit_prc,
                              dn_tp,
                              dn_pa,
                              dn_params_src,
                              dn_reason)
            VALUES (x_dn,
                    x_pc,
                    DECODE (x_op,  6, l_ndn,  30, l_ndn_sa),
                    'Переплата',
                    x_org || '-' || x_dn,
                    TRUNC (SYSDATE),
                    NULL,
                    NULL,
                    'PD',
                    'E',
                    'A',
                    x_sum1,
                    x_sum1,
                    'F',
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    x_dt1,
                    LAST_DAY (x_dt1),
                    NULL,
                    x_org,
                    NULL,
                    NULL,
                    x_dpp,
                    l_hs,
                    20,
                    'R',
                    x_pa,
                    'DND',
                    DECODE (x_op, 30, '15'))
              INTO dn_detail (dnd_id,
                              dnd_dn,
                              dnd_start_dt,
                              dnd_stop_dt,
                              dnd_tp,
                              dnd_value,
                              history_status,
                              dnd_psc,
                              dnd_value_prefix,
                              dnd_dppa)
            VALUES (0,
                    x_dn,
                    ADD_MONTHS (x_dt1, 1),
                    TO_DATE ('31.12.2099', 'DD.MM.YYYY'),
                    'PD',
                    20,
                    'A',
                    NULL,
                    NULL,
                    NULL)
                SELECT x_id1                           AS x_pc,
                       x_id2                           AS x_org,
                       x_id3                           AS x_dn,
                       x_dt1,
                       x_sum1,
                       x_pa,
                       x_op,
                       (SELECT dpp_id
                          FROM uss_ndi.v_ndi_pay_person
                         WHERE     history_status = 'A'
                               AND dpp_tp = 'OSZN'
                               AND dpp_org = 50000)    AS x_dpp
                  FROM tmp_work_idba, pc_account, personalcase pc
                 WHERE x_pa = pa_id AND x_id1 = pc_id;

            --dbms_output.put_line('Створено відрахувань: '||SQL%ROWCOUNT);

            --Проставляємо в рядки нарахувань посилання на відрахування
            UPDATE ac_detail
               SET acd_st = CASE WHEN acd_op = 6 THEN 'U' ELSE acd_st END,
                   /*acd_dn = (SELECT x_id3
                             FROM tmp_work_idba, accrual, uss_ndi.v_ndi_npt_config, pc_account, pc_decision
                             WHERE acd_ac = ac_id
                               AND ac_pc = x_id1
                               AND ac_month = x_dt1
                               AND acd_npt = nptc_npt
                               AND nptc_nst = pa_nst
                               AND pa_pc = ac_pc
                               AND x_pa = pa_id
                               AND x_nst = pa_nst
                               AND acd_pd = pd_id
                               AND pd_pa = pa_id),*/
                   acd_dn_src =
                       (SELECT x_id3
                          FROM tmp_work_idba,
                               accrual,
                               uss_ndi.v_ndi_npt_config,
                               pc_account,
                               pc_decision
                         WHERE     acd_ac = ac_id
                               AND ac_pc = x_id1
                               AND ac_month = x_dt1
                               AND acd_npt = nptc_npt
                               AND nptc_nst = pa_nst
                               AND pa_pc = ac_pc
                               AND x_pa = pa_id
                               AND x_nst = pa_nst
                               AND acd_pd = pd_id
                               AND pd_pa = pa_id
                               AND acd_op = x_op)
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids2
                         WHERE acd_id = x_id);

            --dbms_output.put_line('Оновлено рядкив нарахувань: '||SQL%ROWCOUNT);

            --Перевіряємо, чи коректно змінили історію по відрахуванням
            FOR xx IN (SELECT dn_id
                         FROM deduction
                        WHERE dn_hs_ins = l_hs
                       UNION
                       SELECT dnd_dn
                         FROM dn_detail
                        WHERE dnd_hs_ins = l_hs OR dnd_hs_del = l_hs)
            LOOP
                check_dn_hist (xx.dn_id);
            END LOOP;

            --Пишемо протокол обробки
            FOR xx IN (SELECT dn_id
                         FROM deduction
                        WHERE dn_hs_ins = l_hs)
            LOOP
                write_dn_log (xx.dn_id,
                              NULL,
                              'E',
                              CHR (38) || '89',
                              NULL,
                              'SYS');
            END LOOP;
        END IF;

        TOOLS.add_message (p_messages,
                           'W',
                           'Завершую формування відрахувань!');
    END;

    PROCEDURE approve_deduction (p_dn_id deduction.dn_id%TYPE)
    IS
        l_new_st   deduction.dn_st%TYPE;
        l_ps_st    pc_state_alimony.ps_st%TYPE := '-';
        l_dn       deduction%ROWTYPE;
        l_org      pc_account.pa_org%TYPE;
    BEGIN
        SELECT dn.*
          INTO l_dn
          FROM deduction dn, personalcase pc, pc_account
         WHERE     dn_id = p_dn_id
               AND dn_pc = pc_id
               AND dn_pa = pa_id
               --AND pc.com_org IN (SELECT u_org FROM tmp_org)
               AND pa_org IN (SELECT u_org FROM tmp_org);

        l_new_st :=
            CASE
                WHEN l_dn.dn_st = 'E' THEN 'W'
                WHEN l_dn.dn_st = 'W' THEN 'R'
            END;

        IF     l_dn.dn_ndn = TOOLS.ggpn ('ACCRUAL_NDN_SA')
           AND (l_dn.dn_reason IS NULL OR l_dn.dn_reason <> '15')
        THEN
            raise_application_error (
                -20000,
                'Не можна змінювати причину для рішення по переплаті типу "переплата - повне держ утримання"!');
        END IF;

        IF l_dn.dn_tp IN ('R', 'HM') AND l_dn.dn_reason IS NULL
        THEN
            raise_application_error (
                -20000,
                'Вкажіть причину для рішення по переплаті!');
        END IF;

        IF l_dn.dn_ps IS NOT NULL
        THEN
            SELECT ps_st
              INTO l_ps_st
              FROM pc_state_alimony
             WHERE ps_id = l_dn.dn_ps;
        END IF;

        IF    (    l_dn.dn_st = 'E'
               AND NOT (   TOOLS.is_role_assigned ('W_ESR_WORK')
                        OR TOOLS.is_role_assigned ('W_ESR_PAY_OPER')))
           OR (    l_dn.dn_st = 'W'
               AND NOT (   TOOLS.is_role_assigned ('W_ESR_MWORK')
                        OR TOOLS.is_role_assigned ('W_ESR_PAY_MOPER')))
        THEN
            raise_application_error (-20000,
                                     'У вас немає доступу до цієї функції!');
        END IF;

        IF l_dn.dn_dpp IS NULL
        THEN
            raise_application_error (-20000, 'Не вказано отримувача !');
        END IF;

        IF l_dn.dn_pa IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не вказано ОР, з якого стягується відрахування!');
        END IF;

        DBMS_OUTPUT.put_line ('l_ps_st=' || l_ps_st);
        DBMS_OUTPUT.put_line ('l_new_st=' || l_new_st);

        IF l_ps_st IN ('S', 'P', 'W') AND l_new_st = 'R'
        THEN
            raise_application_error (
                -20000,
                'Для затвердження відрахування по держутриманню, запис держутримання повинен бути в статусі Діюче або Припинено перебування - тобто Держутримання потрібно затвердити!');
        END IF;

        UPDATE deduction t
           SET dn_st = l_new_st, dn_hs_return = NULL
         WHERE     dn_id = p_dn_id
               AND dn_st = l_dn.dn_st
               AND l_new_st IS NOT NULL;

        IF SQL%ROWCOUNT > 0
        THEN
            write_dn_log (p_dn_id,
                          NULL,
                          l_new_st,
                          CHR (38) || '40',
                          l_dn.dn_st,
                          'SYS');
        END IF;

        --Для відрахувань по переплатам - проставляємо рядкам відповідних нарахувань стан "Z" - зафіксовано.
        IF l_new_st = 'R' AND l_dn.dn_tp = 'R'
        THEN
            UPDATE ac_detail
               SET acd_st = 'Z'
             WHERE     (acd_dn_src = p_dn_id OR acd_dn = p_dn_id)
                   AND acd_st = 'U'
                   AND acd_op IN (6                                   /*, 30*/
                                   );
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            SELECT MIN (pa_org)
              INTO l_org
              FROM deduction, pc_account
             WHERE dn_pa = pa_id AND dn_id = p_dn_id;

            raise_application_error (
                -20000,
                   'Не передано відрахування або немає доступу до ОР відрахування в ОСЗН '
                || l_org
                || '!');
    END;

    PROCEDURE reject_deduction (p_dn_id       deduction.dn_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL)
    IS
        l_hs           histsession.hs_id%TYPE;
        l_new_st       deduction.dn_st%TYPE;
        l_old_st       deduction.dn_st%TYPE;
        l_st_name      uss_ndi.v_ddn_dn_st.dic_name%TYPE;
        l_nst          pc_account.pa_nst%TYPE;
        l_bp_class     billing_period.bp_class%TYPE;
        l_curr_month   accrual.ac_month%TYPE;
        l_org          personalcase.com_org%TYPE;
        l_com_org      personalcase.com_org%TYPE;
        l_acc_org      personalcase.com_org%TYPE;
        l_pc           personalcase.pc_id%TYPE;
        l_dn_tp        deduction.dn_tp%TYPE;
        l_sum          ac_detail.acd_sum%TYPE;
        l_cnt          INTEGER;
    BEGIN
        IF NOT (   TOOLS.is_role_assigned ('W_ESR_MWORK')
                OR TOOLS.is_role_assigned ('W_ESR_PAY_MOPER'))
        THEN
            raise_application_error (-20000,
                                     'У вас немає доступу до цієї функції!');
        END IF;

        SELECT dn_st,
               dic_name,
               CASE WHEN dn_st = 'W' THEN 'E' WHEN dn_st = 'R' THEN 'W' END,
               pa_nst,
               pc.com_org,
               pc_id,
               dn_tp
          INTO l_old_st,
               l_st_name,
               l_new_st,
               l_nst,
               l_org,
               l_pc,
               l_dn_tp
          FROM deduction,
               uss_ndi.v_ddn_dn_st,
               pc_account,
               personalcase  pc
         WHERE     dn_id = p_dn_id
               AND dn_st = dic_value
               AND dn_pa = pa_id
               AND dn_pc = pc_id
               --AND pc.com_org IN (SELECT u_org FROM tmp_org)
               AND pa_org IN (SELECT u_org FROM tmp_org);

        IF l_old_st NOT IN ('W', 'R')
        THEN
            raise_application_error (
                -20000,
                   'Проект відрахування неможливо повернути на доопрацювання з статусу '
                || l_st_name
                || '!');
        END IF;

        l_hs := tools.GetHistSession;

        UPDATE deduction t
           SET dn_st = l_new_st, dn_hs_return = l_hs
         WHERE dn_id = p_dn_id AND dn_st = l_old_st AND l_new_st IS NOT NULL;

        --Для відрахувань по переплатам при переведенні з "Діючий" в "Передано на візування" - проставляємо рядкам відповідних нарахувань history_Status - видалений.
        IF l_new_st = 'W' AND l_old_st = 'R' AND l_dn_tp IN ('R', 'HM')
        THEN
            l_bp_class := CASE WHEN l_nst = 664 THEN 'VPO' ELSE 'V' END;

            SELECT bp_month
              INTO l_curr_month
              FROM billing_period
             WHERE     bp_tp = 'PR'
                   AND bp_org = l_org
                   AND bp_class = l_bp_class
                   AND bp_st = 'R';

            SELECT SUM (CASE WHEN op_tp1 = 'DN' THEN acd_sum END), COUNT (*)
              INTO l_sum, l_cnt
              FROM ac_detail, uss_ndi.v_ndi_op
             WHERE     (acd_dn = p_dn_id OR acd_dn_src = p_dn_id)
                   AND acd_op = op_id
                   AND (op_tp1 = 'DN' OR acd_op = 5)
                   AND EXISTS
                           (SELECT 1
                              FROM accrual
                             WHERE     ac_pc = l_pc
                                   AND ac_month = l_curr_month
                                   AND acd_ac = ac_id)
                   AND acd_prsd IS NULL
                   AND acd_imp_pr_num IS NULL
                   AND history_status = 'A';

            IF l_cnt > 0
            THEN
                UPDATE ac_detail
                   SET history_status = 'H'
                 WHERE     (acd_dn = p_dn_id OR acd_dn_src = p_dn_id)
                       AND (   acd_op IN (SELECT op_id
                                            FROM uss_ndi.v_ndi_op
                                           WHERE op_tp1 = 'DN')
                            OR acd_op = 5)
                       AND EXISTS
                               (SELECT 1
                                  FROM accrual
                                 WHERE     ac_pc = l_pc
                                       AND ac_month = l_curr_month
                                       AND acd_ac = ac_id)
                       AND acd_prsd IS NULL
                       AND acd_imp_pr_num IS NULL
                       AND history_status = 'A';

                UPDATE deduction
                   SET dn_debt_current =
                           NVL (dn_debt_current, 0) + NVL (l_sum, 0)
                 WHERE dn_id = p_dn_id;
            END IF;
        END IF;

        IF SQL%ROWCOUNT > 0
        THEN
            write_dn_log (p_dn_id,
                          l_hs,
                          l_new_st,
                          CHR (38) || '41',
                          l_old_st,
                          'SYS');

            IF p_reason IS NOT NULL
            THEN
                write_dn_log (p_dn_id,
                              l_hs,
                              l_new_st,
                              p_reason,
                              l_old_st,
                              'USR');
            --API$PC_DECISION.write_pd_log(p_dn_id, l_hs, l_new_st, p_reason, l_old_st, 'USR');
            END IF;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            SELECT MIN (pa_org)
              INTO l_org
              FROM deduction, pc_account
             WHERE dn_pa = pa_id AND dn_id = p_dn_id;

            raise_application_error (
                -20000,
                   'Не передано відрахування або немає доступу до ОР відрахування в ОСЗН '
                || l_org
                || '!');
    END;

    --Відміна рішення щодо переплати
    PROCEDURE cancel_deduction (p_dn_id       deduction.dn_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL)
    IS
        l_hs         histsession.hs_id%TYPE;
        l_new_st     deduction.dn_st%TYPE;
        l_old_st     deduction.dn_st%TYPE;
        l_st_name    uss_ndi.v_ddn_dn_st.dic_name%TYPE;
        l_tp         deduction.dn_tp%TYPE;
        l_pc         deduction.dn_pc%TYPE;
        l_start_dt   ac_detail.acd_start_dt%TYPE;
        l_org        pc_account.pa_org%TYPE;
    BEGIN
        IF NOT (   TOOLS.is_role_assigned ('W_ESR_WORK')
                OR TOOLS.is_role_assigned ('W_ESR_PAY_OPER'))
        THEN
            raise_application_error (-20000,
                                     'У вас немає доступу до цієї функції!');
        END IF;

        SELECT dn_st,
               dic_name,
               'D',
               dn_tp,
               dn_pc
          INTO l_old_st,
               l_st_name,
               l_new_st,
               l_tp,
               l_pc
          FROM deduction,
               uss_ndi.v_ddn_dn_st,
               personalcase  pc,
               pc_account
         WHERE     dn_id = p_dn_id
               AND dn_st = dic_value
               AND dn_pc = pc_id
               AND dn_pa = pa_id
               --AND pc.com_org IN (SELECT u_org FROM tmp_org)
               AND pa_org IN (SELECT u_org FROM tmp_org);

        IF l_tp NOT IN ('R', 'HM')
        THEN
            raise_application_error (
                -20000,
                'Вімінити можна тільки рішення щодо переплати!');
        END IF;

        IF l_old_st NOT IN ('E')
        THEN
            raise_application_error (
                -20000,
                'Відміняти можна тільки рішення щодо переплати в статусі Редагується!');
        END IF;

        l_hs := tools.GetHistSession;

        UPDATE deduction t
           SET dn_st = l_new_st, dn_hs_return = l_hs
         WHERE dn_id = p_dn_id AND dn_st = 'E';

        IF SQL%ROWCOUNT > 0
        THEN
            --Переводимо рядки суми-основи рішення щодо переплати в історичний стан (це дозволить при перерахунках
            --наступних отримати знов повну суму нарахування при порівнянні з новонарахованим. Наприклад: документ з'явився
            --в жовтні, а відміну і перерахунок роблять в листопаді)
            UPDATE ac_detail
               SET history_status = 'H'
             WHERE     (acd_dn = p_dn_id OR acd_dn_src = p_dn_id)
                   AND acd_op IN (6);

            write_dn_log (p_dn_id,
                          l_hs,
                          l_new_st,
                          CHR (38) || '128',
                          l_old_st,
                          'SYS');

            IF p_reason IS NOT NULL
            THEN
                write_dn_log (p_dn_id,
                              l_hs,
                              l_new_st,
                              p_reason,
                              l_old_st,
                              'USR');
            END IF;

            --Обраховуємо мінімальний місяць, який необхідно перераховувати (якщо відміняємо переплату, то, вірогідно,
            --відновили рішення
            SELECT MIN (acd_start_dt)
              INTO l_start_dt
              FROM ac_detail
             WHERE     acd_dn = p_dn_id
                   AND acd_op IN (6)
                   AND history_status = 'A';

            IF l_start_dt IS NOT NULL
            THEN
                API$PERSONALCASE.add_pc_accrual_queue (l_pc,
                                                       'DN',
                                                       l_start_dt,
                                                       NULL,
                                                       p_dn_id,
                                                       l_hs);
                write_dn_log (
                    p_dn_id,
                    l_hs,
                    l_new_st,
                    CHR (38) || '129#' || TO_CHAR (l_start_dt, 'DD.MM.YYYY'),
                    l_old_st,
                    'SYS');
            END IF;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            SELECT MIN (pa_org)
              INTO l_org
              FROM deduction, pc_account
             WHERE dn_pa = pa_id AND dn_id = p_dn_id;

            raise_application_error (
                -20000,
                   'Не передано відрахування або немає доступу до ОР відрахування в ОСЗН '
                || l_org
                || '!');
    END;

    --Закриття "аліментного" рішення
    PROCEDURE close_deduction (p_dn_id deduction.dn_id%TYPE, p_close_dt DATE)
    IS
        l_hs             histsession.hs_id%TYPE;
        l_new_st         deduction.dn_st%TYPE;
        l_old_st         deduction.dn_st%TYPE;
        l_st_name        uss_ndi.v_ddn_dn_st.dic_name%TYPE;
        l_calc_step      uss_ndi.v_ndi_deduction.ndn_calc_step%TYPE;
        l_tp             deduction.dn_tp%TYPE;
        l_pc             deduction.dn_pc%TYPE;
        l_start_dt       ac_detail.acd_start_dt%TYPE;
        l_debt_current   deduction.dn_debt_current%TYPE;
        l_dnd_to_work    dn_detail.dnd_id%TYPE;
        l_org            pc_account.pa_org%TYPE;
    BEGIN
        IF NOT (TOOLS.is_role_assigned ('W_ESR_PAY_MOPER'))
        THEN
            raise_application_error (-20000,
                                     'У вас немає доступу до цієї функції!');
        END IF;

        SELECT dn_st,
               dic_name,
               'ZH',
               dn_tp,
               dn_pc,
               ndn_calc_step,
               dn_debt_current
          INTO l_old_st,
               l_st_name,
               l_new_st,
               l_tp,
               l_pc,
               l_calc_step,
               l_debt_current
          FROM deduction,
               uss_ndi.v_ddn_dn_st,
               personalcase  pc,
               uss_ndi.v_ndi_deduction,
               uss_esr.pc_account
         WHERE     dn_id = p_dn_id
               AND dn_st = dic_value
               AND dn_pc = pc_id
               AND dn_ndn = ndn_id
               AND dn_pa = pa_id
               AND pa_org IN (SELECT u_org FROM tmp_org);

        /*IF l_tp NOT IN ('D') THEN
          raise_application_error(-20000, 'Закрити можна тільки рішення аліментного типу!');
        END IF;*/

        IF l_calc_step NOT IN ('S')
        THEN
            raise_application_error (
                -20000,
                'Не можна цією функцією закривати відрахування типу "держутримання"!');
        END IF;

        IF l_old_st NOT IN ('R')
        THEN
            raise_application_error (
                -20000,
                'Закрити можна тільки рішення по відрахуванню в статусі Діюче!');
        END IF;

        l_hs := tools.GetHistSession;

        UPDATE deduction t
           SET dn_st = l_new_st, dn_hs_return = l_hs
         WHERE     dn_id = p_dn_id
               AND dn_st = 'R'
               --AND dn_tp = 'D'
               AND EXISTS
                       (SELECT 1
                          FROM uss_ndi.v_ndi_deduction
                         WHERE dn_ndn = ndn_id AND ndn_calc_step = 'S');

        IF SQL%ROWCOUNT > 0
        THEN
            write_dn_log (p_dn_id,
                          l_hs,
                          l_new_st,
                          CHR (38) || '255#' || TO_CHAR (l_debt_current),
                          l_old_st,
                          'SYS');
        END IF;

        SELECT MAX (dnd_id)
          INTO l_dnd_to_work
          FROM dn_detail
         WHERE     dnd_dn = p_dn_id
               AND history_status = 'A'
               AND p_close_dt > dnd_start_dt
               AND p_close_dt <= NVL (dnd_stop_dt, p_close_dt);

        UPDATE dn_detail
           SET dnd_hs_del = l_hs, history_Status = 'H'
         WHERE     dnd_dn = p_dn_id
               AND history_status = 'A'
               AND p_close_dt <= NVL (dnd_stop_dt, p_close_dt);

        INSERT INTO dn_detail (dnd_id,
                               dnd_dn,
                               dnd_start_dt,
                               dnd_stop_dt,
                               dnd_tp,
                               dnd_value,
                               history_status,
                               dnd_psc,
                               dnd_value_prefix,
                               dnd_dppa,
                               dnd_hs_ins,
                               dnd_hs_del,
                               dnd_nl_tp,
                               dnd_nl_value,
                               dnd_nl_value_prefix)
            SELECT 0,
                   dnd_dn,
                   dnd_start_dt,
                   p_close_dt,
                   dnd_tp,
                   dnd_value,
                   'A',
                   dnd_psc,
                   dnd_value_prefix,
                   dnd_dppa,
                   l_hs,
                   NULL,
                   dnd_nl_tp,
                   dnd_nl_value,
                   dnd_nl_value_prefix
              FROM dn_detail
             WHERE dnd_id = l_dnd_to_work;

        check_dn_hist (p_dn_id);
    --    raise_application_error(-20000, sql%rowcount||'-'||p_close_dt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            SELECT MIN (pa_org)
              INTO l_org
              FROM deduction, pc_account
             WHERE dn_pa = pa_id AND dn_id = p_dn_id;

            raise_application_error (
                -20000,
                   'Не передано відрахування або немає доступу до ОР відрахування в ОСЗН '
                || l_org
                || '!');
    END;

    PROCEDURE save_deduction (
        p_dn_id               deduction.dn_id%TYPE,
        p_dn_reason           deduction.dn_reason%TYPE,
        p_dn_debt_limit_prc   deduction.dn_debt_limit_prc%TYPE)
    IS
        l_dn    deduction%ROWTYPE;
        l_org   pc_account.pa_org%TYPE;
    BEGIN
        IF NOT (   TOOLS.is_role_assigned ('W_ESR_WORK')
                OR TOOLS.is_role_assigned ('W_ESR_PAY_OPER'))
        THEN
            raise_application_error (-20000,
                                     'У вас немає доступу до цієї функції!');
        END IF;

        SELECT dn.*
          INTO l_dn
          FROM deduction dn, personalcase pc, pc_account
         WHERE     dn_id = p_dn_id
               AND dn_pc = pc_id
               --AND pc.com_org IN (SELECT u_org FROM tmp_org)
               AND dn_pa = pa_id
               AND pa_org IN (SELECT u_org FROM tmp_org);

        IF NOT (l_dn.dn_tp = 'R' AND l_dn.dn_st = 'E')
        THEN
            raise_application_error (
                -20000,
                'Переплату не в статусі "Редагується" змінювати не можна!');
        END IF;

        UPDATE deduction
           SET dn_reason = p_dn_reason,
               dn_debt_limit_prc =
                   CASE
                       WHEN dn_have_agreement = 'F' THEN p_dn_debt_limit_prc
                       ELSE dn_debt_limit_prc
                   END
         WHERE dn_id = p_dn_id;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            SELECT MIN (pa_org)
              INTO l_org
              FROM deduction, pc_account
             WHERE dn_pa = pa_id AND dn_id = p_dn_id;

            raise_application_error (
                -20000,
                   'Не передано відрахування або немає доступу до ОР відрахування в ОСЗН '
                || l_org
                || '!');
    END;

    --Обробка звернень по згоді на добровільне поверенння переплат
    PROCEDURE process_deduction_by_appeal (
        p_mode        INTEGER,                    --1=через параметри, 2=через
        p_ap_id       appeal.ap_id%TYPE,
        p_dn_id   OUT deduction.dn_id%TYPE)
    IS
        l_hs    histsession.hs_id%TYPE;
        l_cnt   INTEGER;
    BEGIN
        IF p_mode = 1 AND p_ap_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT ap_id
                  FROM v_appeal
                 WHERE ap_id = p_ap_id AND ap_st IN ('O') AND ap_tp = 'PP';

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, v_appeal
             WHERE x_id = ap_id AND ap_st IN ('O') AND ap_tp = 'PP';
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування зміни параметрів відрахувань по переплатам не передано зверненнь!');
        END IF;

        --Обраховуємо перелік відрахувань, яких стосується згода по зверненню
        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1,
                                   x_id2,
                                   x_sum1,
                                   x_sum2,
                                   x_string1,
                                   x_string2)
            WITH
                apdata
                AS
                    (SELECT ap_id
                                AS q_ap,
                            ap_pc
                                AS q_pc,
                            TO_NUMBER (
                                NVL (
                                    api$appeal.get_doc_string (app_id,
                                                               289,
                                                               2327),
                                    0))
                                AS q_nst,
                            api$appeal.get_doc_string (app_id, 289, 2529)
                                AS q_dn_unit,
                            api$appeal.get_doc_sum (app_id, 289, 2530)
                                AS q_value,
                            api$appeal.get_doc_sum (app_id, 289, 2531)
                                AS q_value_prefix
                       FROM tmp_work_ids, appeal, ap_person
                      WHERE     app_ap = x_id
                            AND app_ap = ap_id
                            AND app_tp = 'O'
                            AND x_id = ap_id)
            SELECT dn_id,
                   q_ap,
                   q_value            AS x_value,
                   q_value_prefix     AS x_value_prefix,
                   dn_st,
                   q_dn_unit          AS x_dn_unit
              FROM apdata, deduction, pc_account
             WHERE     q_pc = dn_pc
                   AND dn_pa = pa_id
                   AND q_nst = pa_nst
                   AND dn_st = 'E'
                   AND dn_tp IN ('R', 'HM')
                   AND q_value > 0
                   AND pa_org IN (SELECT u_org FROM tmp_org);

        --Оновлюємо ознаку наявності згоди та відсоток зі згоди
        UPDATE deduction d
           SET d.dn_have_agreement = 'T',
               (dn_ap                                  /*, dn_debt_limit_prc*/
                     ) =
                   (SELECT x_id2                                  /*, x_sum1*/
                      FROM tmp_work_set1
                     WHERE x_id1 = dn_id)
         WHERE     dn_st = 'E'
               AND dn_tp IN ('R', 'HM')
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_set1
                         WHERE x_id1 = dn_id);

        UPDATE dn_detail
           SET (dnd_value, dnd_value_prefix, dnd_tp) =
                   (SELECT x_sum1, x_sum2, x_string2
                      FROM tmp_work_set1
                     WHERE x_id1 = dnd_dn)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set1
                         WHERE x_id1 = dnd_dn)
               AND history_Status = 'A';

        IF SQL%ROWCOUNT > 0
        THEN
            l_hs := TOOLS.GetHistSession;

            FOR xx
                IN (SELECT x_id1,
                           x_id2,
                           x_sum1,
                           x_string1
                      FROM tmp_work_set1)
            LOOP
                write_dn_log (xx.x_id1,
                              l_hs,
                              xx.x_string1,
                              CHR (38) || '93#' || xx.x_sum1,
                              xx.x_string1,
                              'SYS');
                p_dn_id := xx.x_id1;
                --!!!!!!Тут нужен вызов, который зверення в переменной xx.x_id2 переведёт в "Оброблено" в ESR и поставит в очередь на передачу этого статуса и сообщения в лог в VISIT
                api$esr_action.PrepareWrite_Visit_ap_st (
                    p_eva_ap        => xx.x_id2,
                    p_eva_st_new    => 'V',
                    p_eva_message   => CHR (38) || '93#' || xx.x_sum1,
                    p_hs_ins        => l_hs);
            END LOOP;
        ELSE
            IF p_mode = 1
            THEN
                raise_application_error (
                    -20000,
                    'Не можливо обробити звернення. Можливі причини: або не знайдено одержувача допомоги, або не введено у зверненні розмір відрахувань більший за нуль, або не знайдено рішення про переплату в статусі "Редагується"');
            END IF;
        END IF;
    END;


    -- #79263: збереження картки переплат
    PROCEDURE save_overpay_card (
        p_dn_id               IN NUMBER,
        p_dn_reason           IN VARCHAR2,
        p_dn_debt_limit_prc   IN deduction.dn_debt_limit_prc%TYPE,
        p_dn_pa               IN deduction.dn_pa%TYPE)
    IS
        l_st    VARCHAR2 (10);
        l_pa    deduction.dn_pa%TYPE;
        l_org   pc_account.pa_org%TYPE;
    BEGIN
        SELECT t.dn_st,
               (SELECT pa_id
                  FROM pc_account
                 WHERE pa_pc = pc_id AND pa_id = p_dn_pa)
          INTO l_st, l_pa
          FROM deduction t, personalcase pc, pc_account
         WHERE     t.dn_id = p_dn_id
               AND dn_pc = pc_id
               --AND pc.com_org IN (SELECT u_org FROM tmp_org)
               AND dn_pa = pa_id
               AND pa_org IN (SELECT u_org FROM tmp_org);

        IF NOT (   TOOLS.is_role_assigned ('W_ESR_WORK')
                OR TOOLS.is_role_assigned ('W_ESR_PAY_OPER'))
        THEN
            raise_application_error (-20000,
                                     'У вас немає доступу до цієї функції!');
        END IF;

        IF (l_st IS NULL OR l_st != 'E')
        THEN
            raise_application_error (-20000,
                                     'Переплату не можна редагувати!');
        END IF;

        IF l_pa IS NULL AND p_dn_pa IS NOT NULL
        THEN
            raise_application_error (
                -20000,
                'Спроба прив`язати відрахування до особового рахунка іншого ЕОС!');
        END IF;

        UPDATE deduction t
           SET t.dn_reason = p_dn_reason,
               t.dn_debt_limit_prc = p_dn_debt_limit_prc,
               dn_pa = p_dn_pa
         WHERE t.dn_id = p_dn_id;

        write_dn_log (p_dn_id,
                      NULL,
                      l_st,
                      CHR (38) || '272#' || p_dn_debt_limit_prc,
                      l_st,
                      'SYS');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            SELECT MIN (pa_org)
              INTO l_org
              FROM deduction, pc_account
             WHERE dn_pa = pa_id AND dn_id = p_dn_id;

            raise_application_error (
                -20000,
                   'Не передано відрахування або немає доступу до ОР відрахування в ОСЗН '
                || l_org
                || '!');
    END;

    PROCEDURE check_rr_list (p_rrl_id rr_list.rrl_id%TYPE)
    IS
        l_cnt       INTEGER;
        l_sum       rr_list.rrl_sum_return%TYPE;
        l_rr_list   rr_list%ROWTYPE;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_set1
         WHERE    (    x_id1 IS NOT NULL
                   AND x_sum1 IS NOT NULL
                   AND x_dt1 IS NOT NULL
                   AND x_string1 = 'SL')
               OR (    x_sum1 IS NOT NULL
                   AND x_dt1 IS NOT NULL
                   AND x_string1 = 'RT');

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'Не передано рядків з вказаним відрахуванням та сумою погашення боргу або з сумою надмірного повернення!');
        END IF;

        /*  SELECT COUNT(*) INTO l_cnt FROM tmp_work_set1 WHERE x_sum1 IS NOT NULL AND x_string1 = 'RT';

          IF l_cnt = 0 THEN
            raise_application_error(-20000, 'Не передано рядків з сумою надмірного повернення!');
          END IF;*/

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_set1
         WHERE     x_string1 IS NOT NULL
               AND (x_sum1 IS NULL OR (x_id1 IS NULL AND x_string1 = 'SL'));

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'Передано '
                || l_cnt
                || ' рядків з некоректними параметрами рознесення - не вказано суму або відрахування для погашення боргу!');
        END IF;

        SELECT COUNT (DISTINCT dn_pc)
          INTO l_cnt
          FROM tmp_work_set1, deduction
         WHERE x_id1 = dn_id AND x_string1 = 'SL';

        IF l_cnt > 1
        THEN
            raise_application_error (
                -20000,
                'Не можна розносити суму поверення по 2 і більше ЕОС!');
        END IF;

        SELECT SUM (x_sum1)
          INTO l_sum
          FROM tmp_work_set1
         WHERE x_string1 IS NOT NULL;

        SELECT *
          INTO l_rr_list
          FROM rr_list
         WHERE rrl_id = p_rrl_id;

        IF l_rr_list.rrl_sum_return IS NULL
        THEN
            raise_application_error (-20000, 'Не вказано суму повернення!');
        END IF;

        IF l_rr_list.rrl_sum_return < 0
        THEN
            raise_application_error (
                -20000,
                'Cума повернення не може бути менше нуля!');
        END IF;

        IF l_sum <> l_rr_list.rrl_sum_return OR l_sum IS NULL
        THEN
            raise_application_error (
                -20000,
                'Сума в рядках рознесення повинна дорівнювати сумі повернення!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_set1
         WHERE x_sum1 <= 0;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Сума рознесення не може бути менше нуля!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_set1
         WHERE x_dt1 IS NULL AND x_string1 IS NOT NULL;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'Не вказано період віднесення сумма в '
                || l_cnt
                || ' рядках!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_set1, deduction
         WHERE     x_id1 = dn_id
               AND x_string1 = 'SL'
               AND x_sum1 > dn_debt_current;

        IF l_sum <> l_rr_list.rrl_sum_return
        THEN
            raise_application_error (
                -20000,
                   'В '
                || l_cnt
                || ' рядках вказано суму погашення боргу більшу за наявну поточну суму боргу! Рознесіть на інші борги чи в "надміру повернута сума"');
        END IF;
    END;

    --Проведення поверення коштів
    --Через таблицю tmp_work_set1 вказуються:
    --Погашення боргу: x_strin1='SL' + x_id1=dn_id + x_sum1=сума
    --Надміру сплачені кошти: x_strin1='RT' + x_sum1=сума
    PROCEDURE process_rr_list (p_rrl_id rr_list.rrl_id%TYPE)
    IS
        l_cnt          INTEGER;
        l_sum          rr_list.rrl_sum_return%TYPE;
        l_rr_list      rr_list%ROWTYPE;
        l_bp_class     billing_period.bp_class%TYPE;
        l_org          personalcase.com_org%TYPE;
        l_curr_month   accrual.ac_month%TYPE;
        l_ac_id        accrual.ac_id%TYPE;
        l_hs           histsession.hs_id%TYPE;
    BEGIN
        check_rr_list (p_rrl_id);

        SELECT *
          INTO l_rr_list
          FROM rr_list
         WHERE rrl_id = p_rrl_id;

        SELECT com_org
          INTO l_org
          FROM personalcase
         WHERE pc_id = l_rr_list.rrl_pc;

        l_bp_class :=
            CASE
                WHEN SYS_CONTEXT (USS_ESR_CONTEXT.gContext,
                                  USS_ESR_CONTEXT.gUserTP) =
                     '41'
                THEN
                    'VPO'
                ELSE
                    'V'
            END;

        SELECT bp_month
          INTO l_curr_month
          FROM billing_period
         WHERE     bp_tp = 'PR'
               AND bp_org = l_org
               AND bp_class = l_bp_class
               AND bp_st = 'R';

        SELECT MIN (ac_id)
          INTO l_ac_id
          FROM accrual
         WHERE ac_pc = l_rr_list.rrl_pc AND ac_month = l_curr_month;

        IF l_ac_id IS NULL
        THEN
            INSERT INTO accrual (ac_id,
                                 ac_pc,
                                 ac_month,
                                 history_status,
                                 com_org)
                 VALUES (0,
                         l_rr_list.rrl_pc,
                         l_curr_month,
                         'A',
                         l_org)
              RETURNING ac_id
                   INTO l_ac_id;
        END IF;

        --Пишемо операції в таблицю операцій
        INSERT INTO ac_detail (acd_id,
                               acd_ac,
                               acd_op,
                               acd_npt,
                               acd_start_dt,
                               acd_stop_dt,
                               acd_sum,
                               acd_dn,
                               acd_ac_start_dt,
                               acd_ac_stop_dt,
                               acd_st,
                               history_status,
                               acd_rrl)
            SELECT 0,
                   l_ac_id,
                   CASE x_string1 WHEN 'SL' THEN 8 WHEN 'RT' THEN 7 END,
                   NULL,
                   TRUNC (NVL (x_dt1, l_curr_month), 'MM'),
                   LAST_DAY (NVL (x_dt1, l_curr_month)),
                   x_sum1,
                   x_id1,
                   l_curr_month,
                   LAST_DAY (l_curr_month),
                   'E',
                   'A',
                   p_rrl_id
              FROM tmp_work_set1
             WHERE x_string1 IN ('SL', 'RT');

        --Зменшуємо суму поточного боргу по відрахуванню на суму відповідних операцій
        UPDATE deduction
           SET dn_debt_current =
                     dn_debt_current
                   - NVL (
                         (SELECT SUM (acd_sum)
                            FROM ac_detail d
                           WHERE     acd_dn = dn_id
                                 AND acd_rrl = p_rrl_id
                                 AND acd_op = 8
                                 AND d.history_status = 'A'),
                         0)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set1
                     WHERE x_id1 = dn_id);

        UPDATE tmp_work_set1
           SET x_string2 =
                   (SELECT    dn_st
                           || CASE
                                  WHEN     dn_debt_current = 0
                                       AND dn_tp IN ('R', 'HM')
                                       AND dn_st = 'R'
                                  THEN
                                      'Z'
                                  ELSE
                                      dn_st
                              END
                      FROM deduction
                     WHERE dn_id = x_id1)
         WHERE 1 = 1;

        --Закриваємо відрахування типу "переплата", в яких сума боргу тепер дорівнює 0
        UPDATE deduction
           SET dn_st = 'Z'
         WHERE     dn_debt_current = 0
               AND dn_tp IN ('R', 'HM')
               AND dn_st = 'R'
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_set1
                         WHERE x_id1 = dn_id);

        l_hs := TOOLS.GetHistSession;

        FOR xx IN (SELECT x_id1                        AS x_dn,
                          x_string1                    AS x_tp,
                          SUBSTR (x_string2, 1, 1)     AS x_old_st,
                          SUBSTR (x_string2, 2, 1)     AS x_new_st,
                          x_sum1                       AS x_sum
                     FROM tmp_work_set1, deduction
                    WHERE x_id1 = dn_id)
        LOOP
            write_dn_log (xx.x_dn,
                          l_hs,
                          xx.x_new_st,
                          CHR (38) || '189#' || xx.x_sum,
                          xx.x_old_st,
                          'SYS');
        END LOOP;

        FOR xx
            IN (SELECT DISTINCT
                       x_id1                        AS x_dn,
                       SUBSTR (x_string2, 1, 1)     AS x_old_st,
                       SUBSTR (x_string2, 2, 1)     AS x_new_st
                  FROM tmp_work_set1, deduction
                 WHERE x_id1 = dn_id AND x_string2 = 'RZ')
        LOOP
            write_dn_log (xx.x_dn,
                          l_hs,
                          xx.x_new_st,
                          CHR (38) || '190',
                          xx.x_old_st,
                          'SYS');
        END LOOP;
    --  raise_application_error(-20000, 'В розробці!');
    END;

    --Відкат операції проведення поверення
    PROCEDURE return_rr_list (p_rrl_id rr_list.rrl_id%TYPE)
    IS
        l_rr_list   rr_list%ROWTYPE;
        l_hs        histsession.hs_id%TYPE;
    BEGIN
        SELECT *
          INTO l_rr_list
          FROM rr_list
         WHERE rrl_id = p_rrl_id;

        IF l_rr_list.rrl_st <> 'P'
        THEN
            raise_application_error (
                -20000,
                'Відкат рознесення повернення коштів можна робити тільки на записах в стані Оброблено');
        END IF;

        FOR xx
            IN (SELECT dn_id
                  FROM deduction
                 WHERE EXISTS
                           (SELECT 1
                              FROM ac_detail d
                             WHERE     acd_rrl = p_rrl_id
                                   AND acd_dn = dn_id
                                   AND acd_rrl = p_rrl_id
                                   AND acd_op = 8
                                   AND d.history_status = 'A'))
        LOOP
            l_hs := NVL (l_hs, TOOLS.GetHistSession);
            write_dn_log (xx.dn_id,
                          l_hs,
                          'R',
                          CHR (38) || '191',
                          'Z',
                          'SYS');
        END LOOP;

        UPDATE deduction
           SET dn_debt_current =
                     dn_debt_current
                   + NVL (
                         (SELECT SUM (acd_sum)
                            FROM ac_detail d
                           WHERE     acd_dn = dn_id
                                 AND acd_rrl = p_rrl_id
                                 AND acd_op = 8
                                 AND d.history_status = 'A'),
                         0),
               dn_st = CASE WHEN dn_st = 'Z' THEN 'R' ELSE dn_st END
         WHERE EXISTS
                   (SELECT 1
                      FROM ac_detail d
                     WHERE     acd_rrl = p_rrl_id
                           AND acd_dn = dn_id
                           AND acd_rrl = p_rrl_id
                           AND acd_op = 8
                           AND d.history_status = 'A');


        UPDATE ac_detail
           SET history_status = 'H'
         WHERE history_status = 'A' AND acd_rrl = p_rrl_id;
    --  raise_application_error(-20000, 'В розробці! ()');
    END;

    PROCEDURE renew_deduction (p_dn_id      deduction.dn_id%TYPE,
                               p_renew_dt   dn_detail.dnd_start_dt%TYPE)
    IS
        l_deduction   v_deduction%ROWTYPE;
        l_dnd_old     dn_detail%ROWTYPE;
        l_start_dt    dn_detail.dnd_start_dt%TYPE;
        l_hs          histsession.hs_id%TYPE;
    BEGIN
        IF NOT TOOLS.is_role_assigned ('W_ESR_PAY_OPER')
        THEN
            raise_application_error (-20000,
                                     'У вас немає доступу до цієї функції!');
        END IF;

        SELECT *
          INTO l_deduction
          FROM v_deduction
         WHERE dn_id = p_dn_id;

        IF     l_deduction.dn_tp = 'R'
           AND l_deduction.dn_debt_current > 0
           AND l_deduction.dn_st IN ('Z', 'ZH')
        THEN
            l_start_dt := TRUNC (p_renew_dt, 'MM');

            IF l_start_dt < ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 1)
            THEN
                l_start_dt := ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 1);
            END IF;

            --Знаходимо останній діючий запис історії параметрів відрахування - з нього будемо робити актуальний запис з дати відновлення.
            SELECT *
              INTO l_dnd_old
              FROM dn_detail
             WHERE     history_Status = 'A'
                   AND dnd_dn = p_dn_id
                   AND dnd_start_dt =
                       (SELECT MAX (m.dnd_start_dt)
                          FROM dn_detail m
                         WHERE m.history_Status = 'A' AND m.dnd_dn = p_dn_id);

            l_hs := TOOLS.GetHistSession;

            IF l_start_dt BETWEEN l_dnd_old.dnd_start_dt
                              AND NVL (l_dnd_old.dnd_stop_dt,
                                       SYSDATE + 10000)
            THEN
                --Видаляємо вже існуючій на дату l_start_dt запис
                UPDATE dn_detail
                   SET history_Status = 'H', dnd_hs_del = l_hs
                 WHERE dnd_id = l_dnd_old.dnd_id;

                --Замість існуючого на дату l_start_dt запису пишему запис з скороченим строком дії
                l_dnd_old.dnd_id := NULL;
                l_dnd_old.dnd_stop_dt := l_start_dt - 1;
                l_dnd_old.dnd_hs_ins := l_hs;

                INSERT INTO dn_detail
                     VALUES l_dnd_old;
            END IF;

            --Видаляємо всі записи історії після нової дати відновлення відрахування
            UPDATE dn_detail
               SET history_Status = 'H', dnd_hs_del = l_hs
             WHERE dnd_dn = p_dn_id AND dnd_start_dt > l_start_dt;

            --Пишемо новий запис історії з параметрами з останнього запису параметрів.
            l_dnd_old.dnd_id := NULL;
            l_dnd_old.dnd_start_dt := l_start_dt;
            l_dnd_old.dnd_stop_dt := TO_DATE ('31.12.2099', 'DD.MM.YYYY');
            l_dnd_old.dnd_hs_ins := l_hs;

            INSERT INTO dn_detail
                 VALUES l_dnd_old;

            UPDATE deduction
               SET dn_st = 'R'
             WHERE dn_id = p_dn_id;

            check_dn_hist (p_dn_id);

            write_dn_log (
                p_dn_id,
                NULL,
                'E',
                CHR (38) || '249#' || TO_CHAR (l_start_dt, 'DD.MM.YYYY'),
                NULL,
                'SYS');
        ELSE
            raise_application_error (
                -20000,
                'Поновлювати можна тільки закриті відрахування типів "кредит", "переплата", "борг" тощо і з ненульовим поточним боргом!');
        END IF;
    END;
--

BEGIN
    -- INITIALIZATION
    NULL;
END API$DEDUCTION;
/