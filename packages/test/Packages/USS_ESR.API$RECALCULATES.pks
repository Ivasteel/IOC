/* Formatted on 8/12/2025 5:48:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$RECALCULATES
IS
    TYPE t_lock_array IS TABLE OF TOOLS.t_lockhandler;

    -- Purpose : Функції роботи з нарахуваннями

    PROCEDURE write_rc_log (p_rcl_rc        rc_log.rcl_rc%TYPE,
                            p_rcl_hs        rc_log.rcl_hs%TYPE,
                            p_rcl_st        rc_log.rcl_st%TYPE,
                            p_rcl_message   rc_log.rcl_message%TYPE,
                            p_rcl_st_old    rc_log.rcl_st_old%TYPE,
                            p_rcl_tp        rc_log.rcl_tp%TYPE:= 'SYS');

    PROCEDURE org_list_to_work_ids (p_mode INTEGER, --3=Ід-и записів в табилцю tmp_work_ids3
                                                    p_list VARCHAR2);


    -- запуск масового розрахуку з шедулеру
    PROCEDURE calc_accrual_job (p_session   VARCHAR2,
                                p_rc_id     recalculates.rc_id%TYPE);

    -- виконання масового розрахунку - реєструє власне перерахунок в таблицю  recalculates і створює відкладену задачу IKIS
    PROCEDURE mass_calc_accrual (
        p_rc_id             OUT recalculates.rc_id%TYPE,
        p_rc_jb             OUT recalculates.rc_jb%TYPE,
        p_rc_month       IN     recalculates.rc_month%TYPE,
        p_rc_org_list    IN     recalculates.rc_org_list%TYPE,
        p_rc_tp                 recalculates.rc_tp%TYPE DEFAULT NULL, -- #79920 OPERVIEIEV
        p_rc_kaot_list          recalculates.rc_kaot_list%TYPE DEFAULT NULL,
        p_rc_nst_list           recalculates.rc_nst_list%TYPE DEFAULT NULL,
        p_rc_index              recalculates.rc_index%TYPE DEFAULT NULL);

    -- Підтвердження масового розрахунку нарахувань
    PROCEDURE approve_recalculates (p_rc_id recalculates.rc_id%TYPE);

    -- Повернення масового розрахунку нарахувань
    PROCEDURE return_recalculates (p_rc_id recalculates.rc_id%TYPE);

    -- #79920 OPERVIEIEV зняття допомоги ВПО по закінченню бойових дій rc_tp='BD_END'

    -- Підготовка кандидатів на перерахунок/обробку, викликається з mass_calc_accrual через шедулер
    PROCEDURE rc_prepare_job (p_session   VARCHAR2,
                              p_rc_id     recalculates.rc_id%TYPE);

    -- Запуск обробки масового розрахунку, що викликається з інтерфейсу
    PROCEDURE process_rc (p_rc_id       recalculates.rc_id%TYPE,
                          p_rc_jb   OUT recalculates.rc_jb%TYPE);

    -- Розрахунок масового перерахунку, викликається з process_rc через шедулер
    PROCEDURE process_rc_job (p_session   VARCHAR2,
                              p_rc_id     recalculates.rc_id%TYPE);

    -- Логічне видалення масового перерахунку (перевод у rc_st='D')
    PROCEDURE rc_purge (p_rc_id recalculates.rc_id%TYPE);

    /* select dic_code, dic_name from uss_ndi.v_ddn_rc_tp + v_ddn_rc_st + v_ddn_rcc_st
    -- ТИПИ ПЕРЕРАХУНКІВ
    M   Масовий
    P   Індивідуальний
    BD_END  Закінчення бойових дій в громадах
    -- СТАТУСИ ПЕРЕРАХУНКІВ
    Z  Зареєстровано
     P  Підготовано
      Q  Поставлено в чергу
       V  Виконується розрахунок
        R  Розраховано
        E  Помилка розрахунку
    F  Зафіксовано
    D  Знято з розгляду
    -- СТАТУСИ СПРАВ-КАНДИДАТІВ
    P Підготовано
    O Оброблено
    R Розраховано
    */

    -- #80563 OPERVIEIEV доступність ОСЗН (TMP_COM_ORGS) схожа на відомості але не точно
    PROCEDURE init_com_orgs_R;

    -- #80867 відкидаємо частину особових справ
    PROCEDURE patch_tmp_work_ids (p_tmp_work_ids VARCHAR2 DEFAULT NULL);

    -- use parameter to fill tmp_work_ids and get dbms_output

    FUNCTION get_rc_id
        RETURN recalculates.rc_id%TYPE;

    FUNCTION get_rc_tp
        RETURN recalculates.rc_tp%TYPE;

    PROCEDURE unhook_ac_from_rc (p_rc_id   recalculates.rc_id%TYPE,
                                 p_ac_id   accrual.ac_id%TYPE,
                                 p_hs_id   histsession.hs_id%TYPE:= NULL);

    PROCEDURE test;

    PROCEDURE request_locks_by_org (
        p_org_list           recalculates.rc_org_list%TYPE,
        p_app_descr          VARCHAR2,
        p_app_msg            VARCHAR2,
        p_locks       IN OUT t_lock_array);

    PROCEDURE release_locks (p_locks t_lock_array);
END API$RECALCULATES;
/


/* Formatted on 8/12/2025 5:49:17 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$RECALCULATES
IS
    g_rc_id   recalculates.rc_id%TYPE;
    g_rc_tp   recalculates.rc_tp%TYPE;

    PROCEDURE write_rc_log (p_rcl_rc        rc_log.rcl_rc%TYPE,
                            p_rcl_hs        rc_log.rcl_hs%TYPE,
                            p_rcl_st        rc_log.rcl_st%TYPE,
                            p_rcl_message   rc_log.rcl_message%TYPE,
                            p_rcl_st_old    rc_log.rcl_st_old%TYPE,
                            p_rcl_tp        rc_log.rcl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        IF p_rcl_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        ELSE
            l_hs := p_rcl_hs;
        END IF;

        INSERT INTO rc_log (rcl_id,
                            rcl_rc,
                            rcl_hs,
                            rcl_st,
                            rcl_message,
                            rcl_st_old,
                            rcl_tp)
             VALUES (0,
                     p_rcl_rc,
                     l_hs,
                     p_rcl_st,
                     p_rcl_message,
                     p_rcl_st_old,
                     NVL (p_rcl_tp, 'SYS'));
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка API$RECALCULATES.'
                || $$PLSQL_UNIT
                || ' : '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END write_rc_log;

    PROCEDURE org_list_to_work_ids (p_mode INTEGER, --3=Ід-и записів в табилцю tmp_work_ids3
                                                    p_list VARCHAR2)
    IS
    BEGIN
        IF p_mode = 3
        THEN
            DELETE FROM tmp_work_ids3
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids3 (x_id)
                WITH
                    lst
                    AS
                        (    SELECT   0
                                    + REGEXP_SUBSTR (p_list,
                                                     '[^,]+',
                                                     1,
                                                     LEVEL)    AS x_org
                               FROM DUAL
                         CONNECT BY REGEXP_SUBSTR (p_list,
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)
                                        IS NOT NULL)
                SELECT org_id
                  FROM ikis_sys.opfu, lst
                 WHERE     org_to = 32
                       AND org_st = 'A'
                       AND x_org IN (org_id, org_org);
        END IF;
    END;

    PROCEDURE release_locks (p_locks t_lock_array)
    IS
    BEGIN
        FOR j IN p_locks.FIRST .. p_locks.LAST
        LOOP
            BEGIN
                TOOLS.release_lock (p_locks (j));
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END;

    PROCEDURE request_locks_by_org (
        p_org_list           recalculates.rc_org_list%TYPE,
        p_app_descr          VARCHAR2,
        p_app_msg            VARCHAR2,
        p_locks       IN OUT t_lock_array)
    IS
    BEGIN
        org_list_to_work_ids (3, p_org_list);

        p_locks := t_lock_array ();

        FOR xx IN (SELECT x_id FROM tmp_work_ids3)
        LOOP
            p_locks.EXTEND ();
            p_locks (p_locks.COUNT) :=
                TOOLS.request_lock_with_timeout (
                    p_descr               => p_app_descr || xx.x_id,
                    p_error_msg           => p_app_msg || xx.x_id,
                    p_timeout             => 2,
                    p_release_on_commit   => FALSE);
        END LOOP;
    END;

    PROCEDURE approve_recalculates (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        UPDATE recalculates
           SET rc_st = 'F'
         WHERE rc_id = p_rc_id AND rc_st = 'R';

        IF SQL%ROWCOUNT > 0
        THEN
            l_hs := TOOLS.GetHistSession;

            write_rc_log (p_rc_id,
                          l_hs,
                          'F',
                          NULL,
                          l_recalculate.rc_st);

            FOR xx IN (SELECT ac_id
                         FROM accrual
                        WHERE ac_rc = p_rc_id)
            LOOP
                API$ACCRUAL.approve_accrual_int (2, xx.ac_id, l_hs);
            END LOOP;

            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка API$RECALCULATES.'
                || $$PLSQL_UNIT
                || ' : '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END approve_recalculates;

    PROCEDURE return_recalculates (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_hs           histsession.hs_id%TYPE;
        l_block_list   VARCHAR2 (1700);
    BEGIN
        API$ACCRUAL.init_nst_list (2);

        DELETE FROM uss_esr.tmp_work_ids4
              WHERE 1 = 1;

        INSERT INTO uss_esr.tmp_work_ids4 (x_id)
            SELECT nptc_npt
              FROM uss_esr.tmp_ac_nst_list, uss_ndi.v_ndi_npt_config
             WHERE nptc_nst = x_nst;

        -- Проставляємо статус "розраховано" тільки тим перерахункам, в яких немає нарахувань, включених до відомостей.
        UPDATE recalculates
           SET rc_st = 'R'
         WHERE     rc_id = p_rc_id
               AND rc_st = 'F'
               AND NOT EXISTS
                       (SELECT ac_id
                          FROM accrual, ac_detail, uss_esr.tmp_work_ids4
                         WHERE     ac_rc = rc_id
                               AND acd_ac = ac_id
                               AND acd_prsd IS NOT NULL
                               AND ac_detail.history_status = 'A'
                               AND acd_npt = x_id);

        IF SQL%ROWCOUNT > 0
        THEN
            l_hs := TOOLS.GetHistSession;
            write_rc_log (p_rc_id,
                          l_hs,
                          'R',
                          NULL,
                          'F');

            FOR xx IN (SELECT ac_id
                         FROM accrual
                        WHERE ac_rc = p_rc_id)
            LOOP
                API$ACCRUAL.return_accrual_int (2,
                                                xx.ac_id,
                                                NULL,
                                                l_hs);
            END LOOP;
        ELSE
            SELECT LISTAGG (x_pr || ' (ОСЗН=' || x_org || ')',
                            ', '
                            ON OVERFLOW TRUNCATE '...' WITHOUT COUNT)
                   WITHIN GROUP (ORDER BY x_org, x_pr)
              INTO l_block_list
              FROM (SELECT DISTINCT pr_id AS x_pr, pr.com_org AS x_org
                      FROM uss_esr.accrual,
                           uss_esr.ac_detail,
                           uss_esr.recalculates,
                           uss_esr.pr_sheet_detail,
                           uss_esr.payroll  pr
                     WHERE     ac_rc = rc_id
                           AND acd_ac = ac_id
                           AND acd_prsd IS NOT NULL
                           AND ac_detail.history_status = 'A'
                           AND rc_id = p_rc_id
                           AND rc_st = 'F'
                           AND acd_prsd = prsd_id
                           AND prsd_pr = pr_id
                           AND EXISTS
                                   (SELECT 1
                                      FROM uss_esr.tmp_work_ids4
                                     WHERE acd_npt = x_id));

            raise_application_error (
                -20000,
                   'Рядки нарахувань, створені даним перерахунком, вже потрапили в відомості, не допускається масове повернення нарахувань в Редагується для запобігання масовим перерахункам поточного періоду! Перелік відомостей за № та ОСЗН: '
                || l_block_list);
        END IF;

        COMMIT;
    END return_recalculates;

    PROCEDURE rc_purge (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_recalculate   recalculates%ROWTYPE;
        l_cnt           INTEGER;
    BEGIN
        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        IF l_recalculate.rc_st IN ('P', 'Z')
        THEN
            DELETE FROM rc_candidates
                  WHERE rcc_rc = p_rc_id;

            l_cnt := SQL%ROWCOUNT;

            UPDATE recalculates
               SET rc_st = 'D', rc_count = 0
             WHERE rc_id = p_rc_id;

            write_rc_log (p_rc_id,
                          TOOLS.GetHistSession,
                          'D',
                          CHR (38) || '175#' || l_cnt,
                          l_recalculate.rc_st);

            COMMIT;
        ELSE
            raise_application_error (
                -20000,
                'Видаляти з розгляду перерахунки у станах інших ніж "Зареєстровано" або "Підготовано" - зась!');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (-20000, 'Немає такого перерахунку!');
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка API$RECALCULATES.'
                || $$PLSQL_UNIT
                || ' : '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END rc_purge;

    -- Підготовка кандидатів на перерахунок/обробку, викликається з mass_calc_accrual через шедулер
    PROCEDURE rc_prepare_job (p_session   VARCHAR2,
                              p_rc_id     recalculates.rc_id%TYPE)
    IS
        l_recalculate   recalculates%ROWTYPE;
        l_hs            histsession.hs_id%TYPE;
        l_rcl_message   rc_log.rcl_message%TYPE;
        l_sql           CLOB;
        l_sql_full      CLOB;
        l_cnt           NUMBER;
        l_rc_config     uss_ndi.v_ndi_rc_config%ROWTYPE;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        TOOLS.JobSaveMessage (
            'Починаю розрахунок списку справ-кандидатів для масового перерахунку!');

        --  DNET$CONTEXT.SetDnetEsrContext(p_session);
        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        SELECT *
          INTO l_rc_config
          FROM uss_ndi.v_ndi_rc_config
         WHERE nrcc_rc_tp = l_recalculate.rc_tp;

        DBMS_APPLICATION_INFO.set_module (
            module_name   =>
                   'RC_PREPARE_JOB(rc='
                || p_rc_id
                || ',oszn='
                || l_recalculate.rc_org_list
                || ')',
            action_name   =>
                'Починаю розрахунок кандидатів масового перерахунку');

        --  TOOLS.JobSaveMessage(sql%rowcount);

        l_hs := TOOLS.GetHistSessionA;

        /* EXAMPLE : select 2241 PC_ID from dual where length('#rc_org_list#') is not null and length('#rc_kaot_list#') is not null */

        IF     l_recalculate.rc_tp = 'S_LGW_CHNG'
           AND l_recalculate.rc_nst_list IN ('267',
                                             '265',
                                             '248',
                                             '269',
                                             '268')
        THEN
            raise_application_error (
                -20000,
                'Перерахунок тимчасово відключено в зв''язку з відсутністю змін бюджетних показників!');
        END IF;

        FOR xx
            IN (  SELECT nrcq_tp, nrcq_sql
                    FROM uss_ndi.v_ndi_rc_queries
                   WHERE     nrcq_rc_tp = l_recalculate.rc_tp
                         AND nrcq_tp IN ('INIT_OLIST', 'INIT_NLIST')
                ORDER BY nrcq_order)
        LOOP
            IF xx.nrcq_tp = 'INIT_OLIST'
            THEN
                EXECUTE IMMEDIATE xx.nrcq_sql
                    USING l_recalculate.rc_org_list;
            ELSIF xx.nrcq_tp = 'INIT_NLIST'
            THEN
                EXECUTE IMMEDIATE xx.nrcq_sql
                    USING l_recalculate.rc_nst_list;
            END IF;
        END LOOP;

        FOR xx
            IN (  SELECT nrcq_tp, nrcq_sql
                    FROM uss_ndi.v_ndi_rc_queries
                   WHERE     nrcq_rc_tp = l_recalculate.rc_tp
                         AND nrcq_tp IN ('PREPARE')
                ORDER BY nrcq_order)
        LOOP
            IF xx.nrcq_tp = 'PREPARE'
            THEN
                EXECUTE IMMEDIATE xx.nrcq_sql
                    USING l_recalculate.rc_id;
            END IF;
        END LOOP;

        SELECT nrcq_sql
          INTO l_sql
          FROM uss_ndi.V_NDI_RC_QUERIES
         WHERE nrcq_rc_tp = l_recalculate.rc_tp AND nrcq_tp = 'SQL'
         FETCH FIRST ROW ONLY;

        l_sql := REPLACE (l_sql, '#rc_org_list#', l_recalculate.rc_org_list);
        l_sql :=
            REPLACE (l_sql, '#rc_kaot_list#', l_recalculate.rc_kaot_list);

        l_sql_full :=
               'INSERT INTO RC_CANDIDATES (rcc_id, rcc_st, rcc_rc, rcc_pc, rcc_kaot, rcc_pd, rcc_sc) SELECT 0, ''P'', x_rc, x_pc, x_kaot, x_pd, x_sc FROM ( '
            || CHR (10)
            || l_sql
            || CHR (10)
            || ' )'; --Символ нового рядка, аби коментарі в коді запиту коректно обробились

        --l_rcl_message:='QUERY: '||chr(10)||substr(l_sql_full,1,1000)||chr(10);

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_sql_full);

        TOOLS.JobSaveMessage ('Виконую запит для пошуку справ-кандидатів');

        EXECUTE IMMEDIATE l_sql_full
            USING p_rc_id                                          /*, l_sql*/
                         ;

        l_cnt := SQL%ROWCOUNT;

        TOOLS.JobSaveMessage (
               'Знайдено '
            || l_cnt
            || ' справ-кандидатів, що задовільняють умовам відбору');

        FOR xx
            IN (  SELECT nrcq_tp, nrcq_sql
                    FROM uss_ndi.v_ndi_rc_queries
                   WHERE     nrcq_rc_tp = l_recalculate.rc_tp
                         AND nrcq_tp = 'POSTSCRIPT'
                ORDER BY nrcq_order)
        LOOP
            EXECUTE IMMEDIATE xx.nrcq_sql
                USING l_recalculate.rc_id;
        END LOOP;

        UPDATE recalculates
           SET rc_st = l_rc_config.nrcc_prepare_st, rc_count = l_cnt
         WHERE rc_id = p_rc_id;

        IF l_recalculate.rc_tp = 'BD_END'
        THEN    --Для перерахунку вибрано ТГ (#), відібрано # справ-кандидатів
            write_rc_log (
                p_rc_id,
                l_hs,
                l_rc_config.nrcc_prepare_st,
                   CHR (38)
                || '170#'
                || l_recalculate.rc_kaot_list
                || '#'
                || l_cnt,
                l_recalculate.rc_st);
        ELSIF l_recalculate.rc_tp <> 'M'
        THEN                    --Для перерахунку відібрано # справ-кандидатів
            write_rc_log (p_rc_id,
                          l_hs,
                          l_rc_config.nrcc_prepare_st,
                          CHR (38) || '177#' || l_cnt,
                          l_recalculate.rc_st);
        END IF;

        COMMIT;
        TOOLS.JobSaveMessage (
            'Завершено розрахунок списку справ-кандидатів на масовий перерахунок!');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            TOOLS.JobSaveMessage (
                'Запущено задачу, для якої немає запиту підготовки кандидатів!');
        WHEN OTHERS
        THEN
            ROLLBACK;
            --TOOLS.JobSaveMessage('Запит API$RECALCULATES.'||$$PLSQL_UNIT||' : '||l_sql_full);
            TOOLS.JobSaveMessage (
                   'Помилка API$RECALCULATES.'
                || $$PLSQL_UNIT
                || ' : '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
            l_rcl_message :=
                   l_rcl_message
                || 'QUERY: '
                || CHR (10)
                || l_sql_full
                || CHR (10);
            l_rcl_message :=
                   l_rcl_message
                || 'ERROR: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace;
            write_rc_log (p_rc_id,
                          l_hs,
                          'E',
                          l_rcl_message,
                          l_recalculate.rc_st);
            COMMIT;
    END rc_prepare_job;

    PROCEDURE patch_tmp_work_ids (p_tmp_work_ids VARCHAR2 DEFAULT NULL)
    IS
        l_msg       VARCHAR2 (4000) := ',';
        l_cnt       NUMBER := 0;
        l_curr_to   NUMBER;
    BEGIN
        l_curr_to := TOOLS.GetCurrOrgTo;

        IF p_tmp_work_ids IS NOT NULL
        THEN                                             -- debug mode >> INIT
            DELETE FROM tmp_work_ids;

            INSERT INTO tmp_work_ids (x_id)
                    SELECT   0
                           + REGEXP_SUBSTR (p_tmp_work_ids,
                                            '[^,]+',
                                            1,
                                            LEVEL)    AS x_id
                      FROM DUAL
                CONNECT BY REGEXP_SUBSTR (p_tmp_work_ids,
                                          '[^,]+',
                                          1,
                                          LEVEL)
                               IS NOT NULL;
        END IF;

        /*for cc in ( with PD as ( select pd_pc, pd_pa, -- pd_nst, com_org, -- excessive select list, may be usable for logging
                                        -- pd_num, pd_id, pd_start_dt, pd_stop_dt, pd_st, pd_src,
                                        pdap_id, pdap_start_dt, pdap_stop_dt --, pdap_reason_stop
                                   from uss_esr.pc_decision
                                   join uss_esr.pd_accrual_period on pdap_pd=pd_id and pd_accrual_period.history_status='A'
                                  where pd_pc in ( select x_id from tmp_work_ids ) \*and pd_st='S' *\)
                      select pc_num, p.pd_pc --, p.pd_nst
                        from PD d
                        join PD p on p.pd_pa=d.pd_pa \*KEY*\ and p.pdap_id>d.pdap_id -- not the same, one in pair
                        join uss_esr.personalcase pc on p.pd_pc=pc_id
                       where nvl(d.pdap_stop_dt,sysdate+10000)>nvl(p.pdap_start_dt,sysdate-10000) and nvl(d.pdap_start_dt,sysdate-10000)<nvl(p.pdap_stop_dt,sysdate+10000)
                    order by pc_num
                    ) loop
          delete from tmp_work_ids where x_id=cc.pd_pc;
          if    length(l_msg)<3800 then l_msg:=l_msg||cc.pc_num||',';
          elsif length(l_msg)<3830 then l_msg:=l_msg||'+';
          end if;
          l_cnt:=l_cnt+1;
        end loop;*/

        DELETE FROM tmp_ac_nst_list
              WHERE 1 = 1;

        API$ACCRUAL.init_nst_list (2);

        IF l_curr_to = 40
        THEN
            INSERT INTO tmp_work_ids4 (x_id)
                SELECT DISTINCT u_pc                            --, u_pd, u_dt
                  FROM (WITH
                            all_dt
                            AS
                                (SELECT pd_pa             AS u_pa,
                                        pd_pc             AS u_pc,
                                        pd_id             AS u_pd,
                                        pdap_start_dt     AS u_dt,
                                        0                 AS u_app_key --Замість цього нуля - обчислення додаткового прикладного ключа
                                   FROM uss_esr.pc_decision,
                                        uss_esr.pd_accrual_period  pdap,
                                        tmp_work_ids
                                  WHERE     pdap_pd = pd_id
                                        AND pdap.history_status = 'A'
                                        AND pd_nst IN
                                                (SELECT x_nst
                                                   FROM tmp_ac_nst_list)
                                        AND pd_Pc = x_id
                                 UNION
                                 SELECT pd_pa            AS u_pa,
                                        pd_pc            AS u_pc,
                                        pd_id            AS u_pd,
                                        pdap_stop_dt     AS u_dt,
                                        0                AS u_app_key --Замість цього нуля - обчислення додаткового прикладного ключа
                                   FROM uss_esr.pc_decision,
                                        uss_esr.pd_accrual_period  pdap,
                                        tmp_work_ids
                                  WHERE     pdap_pd = pd_id
                                        AND pdap.history_status = 'A'
                                        AND pd_nst IN
                                                (SELECT x_nst
                                                   FROM tmp_ac_nst_list)
                                        AND pd_Pc = x_id)
                        SELECT *
                          FROM all_dt
                         WHERE 1 <
                               (SELECT COUNT (*)
                                  FROM uss_esr.pc_decision,
                                       uss_esr.pd_accrual_period  pdap
                                 WHERE     pdap_pd = pd_id
                                       AND pdap.history_status = 'A'
                                       AND pd_pa = u_pa
                                       AND u_app_key = 0 --Замість даного порівняння з нулем - додатковий ключ порівняння (наприклад, по утриманцям)
                                       AND u_dt BETWEEN pdap_start_dt
                                                    AND NVL (
                                                            pdap_stop_dt,
                                                            TO_DATE (
                                                                '31.12.2099',
                                                                'DD.MM.YYYY'))))
                 WHERE u_dt >= TO_DATE ('01.03.2022', 'DD.MM.YYYY');
        ELSE
            NULL;

            /*--Спочатку базовий контроль на перетин рішень - немає сенсу виконувати складні контролі по утриманцям чи призначеному одразу по значно більшим таблицям.
            --Обираємо невелику кількість "підозрілих".
            INSERT INTO tmp_work_ids2 (x_id)
              SELECT DISTINCT u_pc--, u_pd, u_dt
              FROM (WITH all_dt AS (SELECT pd_pa AS u_pa, pd_pc AS u_pc, pd_id AS u_pd, pdap_start_dt AS u_dt
                                    FROM uss_esr.pc_decision, uss_esr.pd_accrual_period pdap, uss_esr.tmp_work_ids
                                    WHERE pdap_pd = pd_id
                                      AND pdap.history_status = 'A'
                                      AND pd_nst IN (SELECT x_nst FROM tmp_ac_nst_list)
                                      AND pd_Pc = x_id
                                    UNION
                                    SELECT pd_pa AS u_pa, pd_pc AS u_pc, pd_id AS u_pd, pdap_stop_dt AS u_dt
                                    FROM uss_esr.pc_decision, uss_esr.pd_accrual_period pdap, uss_esr.tmp_work_ids
                                    WHERE pdap_pd = pd_id
                                      AND pdap.history_status = 'A'
                                      AND pd_nst IN (SELECT x_nst FROM tmp_ac_nst_list)
                                      AND pd_Pc = x_id)
                      SELECT *
                      FROM all_dt
                      WHERE 1 < (SELECT COUNT(*)
                                 FROM uss_esr.pc_decision, uss_esr.pd_accrual_period pdap
                                 WHERE pdap_pd = pd_id
                                   AND pdap.history_status = 'A'
                                   AND pd_pa = u_pa
                                   AND u_dt BETWEEN pdap_start_dt and NVL(pdap_stop_dt, to_date('31.12.2099', 'DD.MM.YYYY')))
                  )
              WHERE u_dt >= to_date('01.11.2022', 'DD.MM.YYYY');

            --Основний контроль - на входження утриманців в 2+ рішення, що діють одночасно
            INSERT INTO tmp_work_ids4 (x_id)
              SELECT DISTINCT u_pc--, u_pd, u_dt
              FROM (WITH all_dt AS (SELECT pd_pa AS u_pa, pd_pc AS u_pc, pd_id AS u_pd, pdap_start_dt AS u_dt, pdf_sc AS u_app_key
                                    FROM uss_esr.pc_decision, uss_esr.pd_accrual_period pdap, uss_esr.tmp_work_ids2, uss_esr.pd_family
                                    WHERE pdap_pd = pd_id
                                      AND pdap.history_status = 'A'
                                      AND pd_nst IN (SELECT x_nst FROM tmp_ac_nst_list)
                                      AND pd_Pc = x_id
                                      AND pdf_pd = pd_id
                                    UNION
                                    SELECT pd_pa AS u_pa, pd_pc AS u_pc, pd_id AS u_pd, pdap_stop_dt AS u_dt, pdf_sc AS u_app_key
                                    FROM uss_esr.pc_decision, uss_esr.pd_accrual_period pdap, uss_esr.tmp_work_ids2, uss_esr.pd_family
                                    WHERE pdap_pd = pd_id
                                      AND pdap.history_status = 'A'
                                      AND pd_nst IN (SELECT x_nst FROM tmp_ac_nst_list)
                                      AND pd_Pc = x_id
                                      AND pdf_pd = pd_id)
                      SELECT *
                      FROM all_dt
                      WHERE 1 < (SELECT COUNT(*)
                                 FROM uss_esr.pc_decision, uss_esr.pd_accrual_period pdap, uss_esr.pd_family
                                 WHERE pdap_pd = pd_id
                                   AND pdap.history_status = 'A'
                                   AND pd_pa = u_pa
                                   AND pdf_pd = pd_id
                                   AND u_app_key = pdf_sc
                                   AND u_dt BETWEEN pdap_start_dt and NVL(pdap_stop_dt, to_date('31.12.2099', 'DD.MM.YYYY')))
                  )
              WHERE u_dt >= to_date('01.11.2022', 'DD.MM.YYYY');*/

            --Спочатку базовий контроль на перетин рішень - немає сенсу виконувати складні контролі по утриманцям чи призначеному одразу по значно більшим таблицям.
            --Обираємо невелику кількість "підозрілих".
            INSERT INTO tmp_work_set3 (x_id1,
                                       x_id2,
                                       x_id3,
                                       x_dt1)
                SELECT DISTINCT u_pc,
                                u_pa,
                                u_pd,
                                u_dt                                    --u_pd
                  FROM (WITH
                            all_dt
                            AS
                                (SELECT pd_pa             AS u_pa,
                                        pd_pc             AS u_pc,
                                        pd_id             AS u_pd,
                                        pdap_start_dt     AS u_dt
                                   FROM uss_esr.pc_decision,
                                        uss_esr.pd_accrual_period  pdap,
                                        uss_esr.tmp_work_ids
                                  WHERE     pdap_pd = pd_id
                                        AND pdap.history_status = 'A'
                                        AND pd_nst IN (SELECT x_nst
                                                         FROM tmp_ac_nst_list
                                                        WHERE x_nst <> 249)
                                        AND pd_Pc = x_id
                                 UNION
                                 SELECT pd_pa            AS u_pa,
                                        pd_pc            AS u_pc,
                                        pd_id            AS u_pd,
                                        pdap_stop_dt     AS u_dt
                                   FROM uss_esr.pc_decision,
                                        uss_esr.pd_accrual_period  pdap,
                                        uss_esr.tmp_work_ids
                                  WHERE     pdap_pd = pd_id
                                        AND pdap.history_status = 'A'
                                        AND pd_nst IN (SELECT x_nst
                                                         FROM tmp_ac_nst_list
                                                        WHERE x_nst <> 249)
                                        AND pd_Pc = x_id)
                        SELECT *
                          FROM all_dt
                         WHERE 1 <
                               (SELECT COUNT (DISTINCT pd_id)
                                  FROM uss_esr.pc_decision,
                                       uss_esr.pd_accrual_period  pdap
                                 WHERE     pdap_pd = pd_id
                                       AND pdap.history_status = 'A'
                                       AND pd_pa = u_pa
                                       AND u_dt BETWEEN pdap_start_dt
                                                    AND NVL (
                                                            pdap_stop_dt,
                                                            TO_DATE (
                                                                '31.12.2099',
                                                                'DD.MM.YYYY'))))
                 WHERE u_dt >= TO_DATE ('01.01.2023', 'DD.MM.YYYY');

            --Основний контроль - на входження утриманців в розрахунок 2+ рішеннь, що діють одночасно
            INSERT INTO tmp_work_ids4 (x_id)
                SELECT DISTINCT u_pc                            --, u_pd, u_dt
                  FROM (WITH
                            all_dt
                            AS
                                (SELECT x_id2      AS u_pa,
                                        x_id1      AS u_pc,
                                        x_id3      AS u_pd,
                                        x_dt1      AS u_dt,
                                        pdf_sc     AS u_app_key
                                   FROM tmp_work_set3, uss_esr.pd_family
                                  WHERE pdf_pd = x_id3)
                        SELECT *
                          FROM all_dt
                         WHERE 1 <
                               (SELECT COUNT (DISTINCT pd_id)
                                  FROM uss_esr.pc_decision,
                                       uss_esr.pd_payment         pdp,
                                       uss_esr.pd_detail,
                                       uss_esr.pd_accrual_period  pdap,
                                       uss_esr.pd_family
                                 WHERE     pdp_pd = pd_id
                                       AND pdp.history_status = 'A'
                                       AND u_dt BETWEEN pdp_start_dt
                                                    AND pdp_stop_dt
                                       AND pdap_pd = pd_id
                                       AND pdap.history_status = 'A'
                                       AND u_dt BETWEEN pdap_start_dt
                                                    AND pdap_stop_dt
                                       AND pd_pa = u_pa
                                       AND pdf_pd = pd_id
                                       AND pdd_pdp = pdp_id
                                       AND pdd_key = pdf_id
                                       AND u_app_key = pdf_sc
                                       AND pdd_ndp =
                                           CASE
                                               WHEN pd_ap < 0 THEN 290
                                               ELSE 300
                                           END));
        END IF;

        FOR xx IN (SELECT pc_id, pc_num
                     FROM personalcase, tmp_work_ids4
                    WHERE x_id = pc_id)
        LOOP
            DELETE FROM tmp_work_ids
                  WHERE x_id = xx.pc_id;

            IF LENGTH (l_msg) < 3800
            THEN
                l_msg := l_msg || xx.pc_num || ',';
            ELSIF LENGTH (l_msg) < 3830
            THEN
                l_msg := l_msg || '+';
            END IF;

            l_cnt := l_cnt + 1;
        END LOOP;

        IF l_cnt > 0
        THEN
            IF p_tmp_work_ids IS NOT NULL
            THEN                                                 -- debug mode
                DBMS_OUTPUT.put_line (
                       'З масового нарахування виключено '
                    || l_cnt
                    || ' особових справ, у яких в рішеннях перетинаються періоди призначення, зокрема : '
                    || TRIM (BOTH ',' FROM l_msg));
            ELSE
                TOOLS.JobSaveMessage (
                       'З масового нарахування виключено '
                    || l_cnt
                    || ' особових справ, у яких в рішеннях перетинаються періоди призначення, зокрема : '
                    || TRIM (BOTH ',' FROM l_msg));
            END IF;
        END IF;
    END patch_tmp_work_ids;

    -- Функція для запуску масового розрахуку з шедулеру
    PROCEDURE calc_accrual_job (p_session   VARCHAR2,
                                p_rc_id     recalculates.rc_id%TYPE)
    IS
        l_recalculate   recalculates%ROWTYPE;
        l_messages      SYS_REFCURSOR;
        l_pd_num        pc_decision.pd_num%TYPE;
        l_hs            histsession.hs_id%TYPE;
        l_cnt           NUMBER;
        l_bp_class      VARCHAR2 (3)
            := CASE
                   WHEN SYS_CONTEXT (USS_ESR_CONTEXT.gContext,
                                     USS_ESR_CONTEXT.gUserTP) =
                        '41'
                   THEN
                       'VPO'
                   ELSE
                       'V'
               END;
        l_locks         t_lock_array;
    BEGIN
        DNET$CONTEXT.SetDnetEsrContext (p_session);

        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        request_locks_by_org (
            l_recalculate.rc_org_list,
            'M_RC_EXEC_',
            'Вже виконується операція масового розрахунку або перерахунку по ОСЗН ',
            l_locks);

        DBMS_APPLICATION_INFO.set_module (
            module_name   =>
                   'MCALC_ACCRUAL(rc='
                || p_rc_id
                || ',oszn='
                || l_recalculate.rc_org_list
                || ')',
            action_name   => 'Починаю масовий розрахунок');

        g_rc_id := l_recalculate.rc_id;
        g_rc_tp := l_recalculate.rc_tp;

        UPDATE recalculates
           SET rc_st = 'V'
         WHERE rc_id = p_rc_id;

        l_hs := TOOLS.GetHistSession;
        write_rc_log (p_rc_id,
                      l_hs,
                      'V',
                      NULL,
                      l_recalculate.rc_st);
        TOOLS.JobSaveMessage (
            'Виконую відкладену задачу масового нарахування');
        COMMIT;

        org_list_to_work_ids (3, l_recalculate.rc_org_list);

        IF l_bp_class = 'VPO'
        THEN
            DELETE FROM tmp_work_ids_dn
                  WHERE 1 = 1;

            -- Рішення по допомозі ВПО підчас масового розрахунку переводимо з статусів 'P' до статусів 'S', але зі всіма контролями тощо
            INSERT INTO tmp_work_ids_dn (x_id)
                SELECT DISTINCT pd_id
                  FROM pc_decision pd, personalcase pc, pc_account
                 WHERE     pd_pc = pc_id
                       AND pd_st = 'P'
                       AND pd_nst IN (664)
                       AND pd_pa = pa_id
                       --AND pd.com_org IN (SELECT u_org FROM tmp_org)
                       AND (   pa_org IN (SELECT orgs.x_id
                                            FROM tmp_work_ids3 orgs)
                            OR pa_org IN
                                   (SELECT org_id -- #80564 OPERVEIEV обраний ОСЗН може бути областю
                                      FROM v_opfu
                                     WHERE org_org IN
                                               (SELECT orgs.x_id
                                                  FROM tmp_work_ids3 orgs))
                            OR (    pa_org IS NULL
                                AND (   pd.com_org IN
                                            (SELECT org_id -- #80564 OPERVEIEV обраний ОСЗН може бути областю
                                               FROM v_opfu
                                              WHERE org_org IN
                                                        (SELECT orgs.x_id
                                                           FROM tmp_work_ids3
                                                                orgs))
                                     OR pd.com_org IN
                                            (SELECT orgs.x_id
                                               FROM tmp_work_ids3 orgs))));

            l_cnt := SQL%ROWCOUNT;

            TOOLS.JobSaveMessage (
                   'По допомозі ВПО в статусі "Призначено" : '
                || l_cnt
                || ' рішень, переводимо в статус "Нараховано" ...');

            FOR xx IN (SELECT x_id FROM tmp_work_ids_dn)
            LOOP
                l_cnt := l_cnt - 1;          -- прогрес індикатор на зменшення

                IF     (   MOD (l_cnt, 1000) = 0
                        OR (l_cnt < 1000 AND MOD (l_cnt, 100) = 0))
                   AND l_cnt > 0
                THEN
                    TOOLS.JobSaveMessage (
                        '... лишилось ' || l_cnt || ' рішень');
                END IF;

                BEGIN
                    Dnet$pay_Assignments.APPROVE_DECISION_PAYMENTS (xx.x_id,
                                                                    'P');

                    -- Проставляємо ознаку "є ЕЦП", бо без неї автоматично переведені в Нараховано не будуть розраховуватись
                    UPDATE pc_decision
                       SET pd_hs_head = l_hs
                     WHERE pd_id = xx.x_id AND pd_hs_head IS NULL;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        IF xx.x_id > 0
                        THEN
                            SELECT pd_num
                              INTO l_pd_num
                              FROM pc_decision
                             WHERE pd_id = xx.x_id;

                            TOOLS.JobSaveMessage (
                                   'Помилка зміни статусу на "Нараховано" для рішення з № : '
                                || l_pd_num
                                || ': '
                                || SQLERRM
                                || CHR (10)
                                || DBMS_UTILITY.format_error_stack
                                || DBMS_UTILITY.format_error_backtrace);
                        END IF;
                END;
            END LOOP;

            SELECT COUNT (*) INTO l_cnt FROM tmp_work_ids_dn; -- відзвітуємо знову бо так треба

            TOOLS.JobSaveMessage (
                   'Переведено '
                || l_cnt
                || ' рішень по допомозі ВПО в статус "Нараховано"');
            COMMIT;

            org_list_to_work_ids (3, l_recalculate.rc_org_list);

            -- Підготуємо перелік особових справ для розрахунку нарахувань
            INSERT INTO tmp_work_ids (x_id)
                SELECT DISTINCT pc_id
                  FROM personalcase pc, pc_decision pd, pc_account
                 WHERE     pd_pc = pc_id
                       AND pd_pa = pa_id
                       AND pa_org IN (SELECT u_org FROM tmp_org)
                       --AND pd.com_org IN (SELECT u_org FROM tmp_org)
                       AND (   pa_org IN (SELECT orgs.x_id
                                            FROM tmp_work_ids3 orgs)
                            OR pa_org IN
                                   (SELECT org_id -- #80564 OPERVEIEV обраний ОСЗН може бути областю
                                      FROM v_opfu
                                     WHERE org_org IN
                                               (SELECT orgs.x_id
                                                  FROM tmp_work_ids3 orgs)))
                       AND EXISTS
                               (SELECT 1
                                  FROM pc_decision px
                                 WHERE     px.pd_st IN ('S', 'PS')
                                       AND px.pd_pc = pc_id
                                       AND px.pd_nst IN (20, 664));

            TOOLS.JobSaveMessage (
                   'Знайдено '
                || SQL%ROWCOUNT
                || ' справ з рішеннями ВПО або постраждалих від підриву терористичною федерацією Каховської ГЕС у статусі "Нараховано" '
                || 'для виконання масового нарахування. Запускаю масове нарахування для справ без нарахувань');

            --Формуємо множину особових орахунків для розрахунку на основі рішень, які потрібно розраховувати
            DELETE FROM tmp_work_pa_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_pa_ids (x_pa)
                SELECT DISTINCT pd_pa
                  FROM personalcase pc, pc_decision pd, pc_account
                 WHERE     pd_pc = pc_id
                       AND pd_pa = pa_id
                       AND pa_org IN (SELECT u_org FROM tmp_org)
                       --AND pd.com_org IN (SELECT u_org FROM tmp_org)
                       AND (   pa_org IN (SELECT orgs.x_id
                                            FROM tmp_work_ids3 orgs)
                            OR pa_org IN
                                   (SELECT org_id -- #80564 OPERVEIEV обраний ОСЗН може бути областю
                                      FROM v_opfu
                                     WHERE org_org IN
                                               (SELECT orgs.x_id
                                                  FROM tmp_work_ids3 orgs)))
                       AND EXISTS
                               (SELECT 1
                                  FROM pc_decision px
                                 WHERE     px.pd_st IN ('S', 'PS')
                                       AND px.pd_pc = pc_id
                                       AND px.pd_nst IN (20, 664));
        ELSE -- #80563 OPERVEIEV РОЗРАХУНКИ У РЕГІОНІ (6 допомог ...) мають обмеження
            init_com_orgs_R;

            -- Підготуємо перелік особових справ для розрахунку нарахувань
            INSERT INTO tmp_work_ids (x_id)
                SELECT DISTINCT pc_id
                  FROM personalcase pc, pc_decision pd, pc_account
                 WHERE     pd_pc = pc_id
                       AND pd_st IN ('S', 'PS')
                       AND pd_nst NOT IN (20, 664, 732)
                       AND pd_pa = pa_id
                       AND pa_org IN (SELECT u_org FROM tmp_org)
                       AND pd.com_org IN (SELECT x_id FROM tmp_com_orgs)
                       AND pd.com_org IN (SELECT orgs.x_id
                                            FROM tmp_work_ids3 orgs);

            TOOLS.JobSaveMessage (
                   'Знайдено '
                || SQL%ROWCOUNT
                || ' справ з рішеннями у статусі "Нараховано"/"Призупинено" '
                || 'для виконання масового нарахування. Запускаю масове нарахування для справ без нарахувань');

            --Формуємо множину особових орахунків для розрахунку на основі рішень, які потрібно розраховувати
            DELETE FROM tmp_work_pa_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_pa_ids (x_pa)
                SELECT DISTINCT pd_pa
                  FROM personalcase pc, pc_decision pd, pc_account
                 WHERE     pd_pc = pc_id
                       AND pd_st IN ('S', 'PS')
                       AND pd_nst NOT IN (20, 664, 732)
                       AND pd_pa = pa_id
                       AND pa_org IN (SELECT u_org FROM tmp_org)
                       AND pd.com_org IN (SELECT x_id FROM tmp_com_orgs)
                       AND pd.com_org IN (SELECT orgs.x_id
                                            FROM tmp_work_ids3 orgs);
        END IF;                                            -- l_bp_class='VPO'

        -- #80867 відкидаємо частину особових справ
        TOOLS.JobSaveMessage (
            'Виконую контроль на перетин дії рішень та виключаю такі з масового перерахунку');
        patch_tmp_work_ids;

        --SELECT COUNT(*) INTO l_cnt FROM tmp_work_ids;
        --TOOLS.JobSaveMessage('Передаю '||l_cnt||' справ.');
        -- власне розрахунок нарахувань
        API$ACCRUAL.set_calc_mode (1); --Встановлюємо режим розрахунку - по вхідній множині особових рахунків.
        API$ACCRUAL.calc_accrual (2,
                                  2,
                                  NULL,
                                  l_recalculate.rc_month,
                                  l_messages);

        /*  LOOP
            FETCH l_messages INTO l_row;
            EXIT WHEN l_messages%NOTFOUND;
            TOOLS.JobSaveMessage(l_row.msg_text, l_row.msg_tp);
          END LOOP;
        */

        -- відмітимо фактичні результати розрахунку
        UPDATE accrual
           SET ac_rc = p_rc_id
         WHERE ac_id IN (SELECT c_id FROM tmp_accrual);

        SELECT COUNT (DISTINCT c_pc) INTO l_cnt FROM tmp_accrual;

        UPDATE recalculates
           SET rc_st = 'R', rc_count = l_cnt
         WHERE rc_id = p_rc_id;

        write_rc_log (p_rc_id,
                      l_hs,
                      'R',
                      CHR (38) || '174#' || l_cnt,
                      'V');

        TOOLS.JobSaveMessage (
            'Масове нарахування виконано : ' || l_cnt || ' справ');
        COMMIT;

        release_locks (l_locks);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            release_locks (l_locks);

            UPDATE recalculates
               SET rc_st = 'E'
             WHERE rc_id = p_rc_id AND rc_st IN ('Z', 'V');

            COMMIT;
            TOOLS.JobSaveMessage (
                   'Помилка API$RECALCULATES.'
                || $$PLSQL_UNIT
                || ' : '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END calc_accrual_job;

    -- Функція виконання масового розрахунку - реєструє власне перерахунок в таблицю  recalculates і створює відкладену задачу IKIS
    PROCEDURE mass_calc_accrual (
        p_rc_id          OUT recalculates.rc_id%TYPE,
        p_rc_jb          OUT recalculates.rc_jb%TYPE,
        p_rc_month           recalculates.rc_month%TYPE,
        p_rc_org_list        recalculates.rc_org_list%TYPE,
        p_rc_tp              recalculates.rc_tp%TYPE DEFAULT NULL, -- #79920 OPERVIEIEV
        p_rc_kaot_list       recalculates.rc_kaot_list%TYPE DEFAULT NULL,
        p_rc_nst_list        recalculates.rc_nst_list%TYPE DEFAULT NULL, -- #95954
        p_rc_index           recalculates.rc_index%TYPE DEFAULT NULL)
    IS
        l_rc_id        recalculates.rc_id%TYPE;
        l_lock         TOOLS.t_lockhandler;
        l_com_org      NUMBER := TOOLS.GetCurrOrg;
        l_bp_class     VARCHAR2 (3)
            := CASE
                   WHEN SYS_CONTEXT (USS_ESR_CONTEXT.gContext,
                                     USS_ESR_CONTEXT.gUserTP) =
                        '41'
                   THEN
                       'VPO'
                   ELSE
                       'V'
               END;
        l_msg          VARCHAR2 (500);
        l_cnt          INTEGER;
        l_exec_alg     uss_ndi.v_ndi_rc_config.nrcc_exec_alg%TYPE;
        l_rc_tp_name   uss_ndi.v_ddn_rc_tp.dic_name%TYPE;
    BEGIN
        -- parameters check
        IF p_rc_month IS NULL
        THEN
            raise_application_error (
                -20000,
                'В функцію масового розрахунку не передано місяця!');
        END IF;

        IF p_rc_tp IS NULL
        THEN
            raise_application_error (
                -20000,
                'В функцію масового розрахунку не типу перерахунку!');
        END IF;

        IF                /*(p_rc_tp='BD_END' and p_rc_kaot_list IS NULL) OR*/
           p_rc_org_list IS NULL AND p_rc_tp <> 'INDEX_VF'
        THEN
            raise_application_error (
                -20000,
                'В функцію масового розрахунку не передано перелік регіонів!');
        END IF;

        IF p_rc_month <> TRUNC (p_rc_month, 'MM')
        THEN
            raise_application_error (
                -20000,
                   'В функцію масового розрахунку передано неправильний період: '
                || TO_CHAR (p_rc_month, 'DD.MM.YYYY'));
        END IF;

        IF     p_rc_tp = 'TMP_WO_DN'
           AND p_rc_month <> TO_DATE ('01.12.2022', 'DD.MM.YYYY')
        THEN
            raise_application_error (
                -20000,
                'Даний тип перерахунку - для разового нарахування в грудні для складних випадків, з ігноруванням відрахувань!');
        END IF;

        IF p_rc_org_list IS NOT NULL
        THEN
            org_list_to_work_ids (3, p_rc_org_list);
        END IF;

        -- OPERVIEIEV обраний ОСЗН може бути областю, це ускладнює контроль періодів
        calc$payroll.init_com_orgs (NULL);

        DELETE FROM tmp_com_orgs
              WHERE     x_id NOT IN (SELECT orgs.x_id
                                       FROM tmp_work_ids3 orgs)
                    AND x_id NOT IN
                            (SELECT org_id
                               FROM v_opfu
                              WHERE org_org IN (SELECT orgs.x_id
                                                  FROM tmp_work_ids3 orgs));

        SELECT nrcc_exec_alg
          INTO l_exec_alg
          FROM uss_ndi.v_ndi_rc_config
         WHERE nrcc_rc_tp = p_rc_tp;

        IF l_exec_alg IN ('CND_CONF')
        THEN
            SELECT COUNT (*) INTO l_cnt FROM tmp_com_orgs;

            IF l_cnt > 1
            THEN
                SELECT MIN (dic_name)
                  INTO l_rc_tp_name
                  FROM uss_ndi.v_ddn_rc_tp
                 WHERE dic_value = p_rc_tp;

                raise_application_error (
                    -20000,
                       'Перерахунок <'
                    || l_rc_tp_name
                    || '> (підготовку кандидатів) можна робити тільки по 1 ОСЗН за раз!');
            END IF;
        END IF;

        IF p_rc_tp = 'TEST1'
        THEN
            RETURN;
        END IF;

        -- Перевіряємо розрахункові періоди по переліку ОСЗН на закритість - якщо є закриті - помилка
        SELECT COUNT (*),
               LISTAGG (x_id, ',') WITHIN GROUP (ORDER BY x_id)    AS closed_org_list
          INTO l_cnt, l_msg
          FROM billing_period JOIN tmp_com_orgs ON bp_org = x_id
         WHERE     bp_class = l_bp_class
               AND bp_st = 'Z'
               AND bp_month = p_rc_month;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'Розрахунковий період закритий по наступними ОСЗН (виключить їх зі списку для розрахунку): '
                || l_msg);
        END IF;

        -- Перевіряємо розрахункові періоди по переліку ОСЗН на наявність відкритих - якщо немає відкритого - помилка
        SELECT COUNT (*),
               LISTAGG (x_id, ',') WITHIN GROUP (ORDER BY x_id)    AS closed_org_list
          INTO l_cnt, l_msg
          FROM tmp_com_orgs
         WHERE NOT EXISTS
                   (SELECT 1
                      FROM billing_period
                     WHERE     bp_org = x_id
                           AND bp_class = l_bp_class
                           AND bp_st = 'R'
                           AND bp_month = p_rc_month);

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'Не знайдено відкритого розрахункового періоду по наступними ОСЗН (виключить їх зі списку для розрахунку): '
                || l_msg);
        END IF;

        -- Пошук будь-якого з переданих на розрахунок органів серед списків органів, що прямо зараз знаходяться на розрахунку
        WITH search_orgs AS (SELECT x_id AS x_search FROM tmp_work_ids3)
        SELECT COUNT (*)
          INTO l_cnt
          FROM search_orgs,
               (SELECT rc_org_list     AS x_list
                  FROM recalculates
                 WHERE     rc_month = p_rc_month
                       AND rc_tp = 'M'
                       AND rc_st IN ('V', 'Z'))
         WHERE x_search IN (    SELECT REGEXP_SUBSTR (x_list,
                                                      '[^,]+',
                                                      1,
                                                      LEVEL)
                                  FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (x_list,
                                                      '[^,]+',
                                                      1,
                                                      LEVEL)
                                           IS NOT NULL);

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'По одному з районів вже виконується розрахунок!');
        END IF;

        IF p_rc_tp = 'TEST2'
        THEN
            RETURN;
        END IF;

        -- Захист від повторного натискання
        l_lock :=
            TOOLS.request_lock_with_timeout (
                p_descr               => 'MASS_CALC_ACCRUAL_' || l_com_org,
                p_error_msg           =>
                    'В даний момент вже виконується постановка в чергу масового розрахунку нарахувань!',
                p_timeout             => 2,
                p_release_on_commit   => FALSE);

        --Формуємо реєстраційний запис масового перерахунку
        INSERT INTO recalculates (rc_id,
                                  com_org,
                                  rc_hs_ins,
                                  rc_month,
                                  rc_dt,
                                  rc_st,
                                  rc_tp,
                                  rc_org_list,
                                  rc_kaot_list,
                                  rc_nst_list,
                                  rc_index)
             VALUES (0,
                     l_com_org,
                     TOOLS.GetHistSession,
                     p_rc_month,
                     TRUNC (SYSDATE),
                     'Z',
                     p_rc_tp,
                     p_rc_org_list,
                     p_rc_kaot_list,
                     p_rc_nst_list,
                     p_rc_index)
          RETURNING rc_id
               INTO l_rc_id;

        COMMIT;


        IF l_exec_alg IN ('CND', 'CND_CONF')
        THEN
            TOOLS.SubmitSchedule (
                p_jb       => p_rc_jb,
                p_subsys   => 'USS_ESR',
                p_wjt      => 'MASS_CALC_PREPARE',
                p_what     =>
                       'BEGIN uss_esr.API$RECALCULATES.RC_PREPARE_JOB('''''
                    || USS_ESR_CONTEXT.GetContext ('SESSION')
                    || ''''', '
                    || l_rc_id
                    || '); END;');
        ELSIF l_exec_alg = 'ACC'
        THEN
            TOOLS.SubmitSchedule (
                p_jb       => p_rc_jb,
                p_subsys   => 'USS_ESR',
                p_wjt      => 'MASS_CALC_ACCRUAL_M',
                p_what     =>
                       'BEGIN uss_esr.API$RECALCULATES.calc_accrual_job('''''
                    || USS_ESR_CONTEXT.GetContext ('SESSION')
                    || ''''', '
                    || l_rc_id
                    || '); END;');
        ELSE
            SELECT MIN (dic_name)
              INTO l_rc_tp_name
              FROM uss_ndi.v_ddn_rc_tp
             WHERE dic_value = p_rc_tp;

            raise_application_error (
                -20000,
                   'Не визначено алгоритму виконання перерахунку <'
                || l_rc_tp_name
                || '>!');
        END IF;

        UPDATE recalculates
           SET rc_jb = p_rc_jb
         WHERE rc_id = l_rc_id;

        COMMIT;

        p_rc_id := l_rc_id;

        TOOLS.release_lock (l_lock);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            -- Якщо встигли створити запис масового нарахування - переводимо його в "помилковий".
            IF l_rc_id IS NOT NULL
            THEN
                UPDATE recalculates
                   SET rc_st = 'E'
                 WHERE rc_id = l_rc_id AND rc_st = 'R';

                COMMIT;
            END IF;

            -- Пробуємо прибрати блокування штатно.
            BEGIN
                TOOLS.release_lock (l_lock);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            RAISE;
    END mass_calc_accrual;

    -- Запуск обробки масового розрахунку, що викликається з інтерфейсу
    PROCEDURE process_rc (p_rc_id       recalculates.rc_id%TYPE,
                          p_rc_jb   OUT recalculates.rc_jb%TYPE)
    IS
        l_lock          TOOLS.t_lockhandler;
        l_com_org       NUMBER := TOOLS.GetCurrOrg;
        l_bp_class      VARCHAR2 (3)
            := CASE
                   WHEN SYS_CONTEXT (USS_ESR_CONTEXT.gContext,
                                     USS_ESR_CONTEXT.gUserTP) =
                        '41'
                   THEN
                       'VPO'
                   ELSE
                       'V'
               END;
        l_msg           VARCHAR2 (500);
        l_cnt           INTEGER;
        l_recalculate   recalculates%ROWTYPE;
        l_rcl_message   rc_log.rcl_message%TYPE;
        l_rc_config     uss_ndi.v_ndi_rc_config%ROWTYPE;
        l_rc_tp_name    uss_ndi.v_ddn_rc_tp.dic_name%TYPE;
    BEGIN
        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        SELECT *
          INTO l_rc_config
          FROM uss_ndi.v_ndi_rc_config
         WHERE nrcc_rc_tp = l_recalculate.rc_tp;

        --Для перерахунків, які повинні підтверджуватись ОСЗН, виконуємо зміну статусу.
        IF     l_rc_config.nrcc_exec_alg = 'CND_CONF'
           AND l_recalculate.rc_st = l_rc_config.nrcc_prepare_st
        THEN
            IF     TOOLS.GetCurrOrgTo = 32
               AND l_recalculate.rc_org_list = TOOLS.GetCurrOrg
            THEN
                UPDATE recalculates
                   SET rc_st = 'P'
                 WHERE rc_id = p_rc_id AND rc_st = 'L';

                p_rc_jb := l_recalculate.rc_jb;
                write_rc_log (p_rc_id,
                              TOOLS.GetHistSession,
                              'P',
                              'Підтверджено попередню обробку',
                              'L');
                RETURN;
            ELSE
                p_rc_jb := l_recalculate.rc_jb;
                write_rc_log (
                    p_rc_id,
                    TOOLS.GetHistSession,
                    l_recalculate.rc_st,
                       'Помилка підтвердження - це повинен робити користувач ОСЗН '
                    || l_recalculate.rc_org_list
                    || '!',
                    l_recalculate.rc_st);
                RETURN;
            --SELECT MIN(dic_name) INTO l_rc_tp_name FROM uss_ndi.v_ddn_rc_tp WHERE dic_value = l_recalculate.rc_tp;
            --raise_application_error(-20000, 'Підтвердження кандидатів перерахунку <'||l_rc_tp_name||'> повинен робити працівник відповідного ОСЗН!');
            END IF;
        END IF;

        IF     l_rc_config.nrcc_exec_alg = 'CND_CONF'
           AND l_recalculate.rc_st = 'P'
           AND TOOLS.GetCurrOrgTo = 32
        THEN
            p_rc_jb := l_recalculate.rc_jb;
            write_rc_log (
                p_rc_id,
                TOOLS.GetHistSession,
                l_recalculate.rc_st,
                'Помилка підтвердження - перерахунок вже підтверджено!',
                l_recalculate.rc_st);
            RETURN;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id AND rc_st = 'P' AND rc_tp <> 'M';

        --Перевіряємо на закритість розрахункових періодів
        WITH
            search_orgs
            AS
                (    SELECT TO_NUMBER (REGEXP_SUBSTR (l_recalculate.rc_org_list,
                                                      '[^,]+',
                                                      1,
                                                      LEVEL))    AS x_org
                       FROM DUAL
                 CONNECT BY REGEXP_SUBSTR (l_recalculate.rc_org_list,
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                IS NOT NULL)
        SELECT COUNT (*),
               LISTAGG (x_org, ',') WITHIN GROUP (ORDER BY x_org)    AS closed_org_list
          INTO l_cnt, l_msg
          FROM billing_period JOIN search_orgs ON bp_org = x_org
         WHERE     bp_class = l_bp_class
               AND bp_st = 'Z'
               AND bp_month = l_recalculate.rc_month;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'Розрахунковий період закритий по наступними ОСЗН (виключить їх зі списку для розрахунку): '
                || l_msg);
        END IF;

        IF l_recalculate.rc_tp <> 'INDEX_VF'
        THEN
            --Перевіряємо на наявність відкритих розрахункових періодів
            WITH
                search_orgs
                AS
                    (    SELECT TO_NUMBER (
                                    REGEXP_SUBSTR (l_recalculate.rc_org_list,
                                                   '[^,]+',
                                                   1,
                                                   LEVEL))    AS x_org
                           FROM DUAL
                     CONNECT BY REGEXP_SUBSTR (l_recalculate.rc_org_list,
                                               '[^,]+',
                                               1,
                                               LEVEL)
                                    IS NOT NULL)
            SELECT COUNT (*),
                   LISTAGG (x_org, ',') WITHIN GROUP (ORDER BY x_org)    AS closed_org_list
              INTO l_cnt, l_msg
              FROM search_orgs
             WHERE NOT EXISTS
                       (SELECT 1
                          FROM billing_period
                         WHERE     bp_org = x_org
                               AND bp_class = l_bp_class
                               AND bp_st = 'R'
                               AND bp_month = l_recalculate.rc_month);

            IF l_cnt > 0
            THEN
                raise_application_error (
                    -20000,
                       'Не знайдено відкритого розрахункового періоду по наступними ОСЗН (виключить їх зі списку для розрахунку): '
                    || l_msg);
            END IF;
        END IF;

        -- Пошук будь-якого з переданих на розрахунок органів серед списків органів, що прямо зараз знаходяться на розрахунку
        WITH
            search_orgs
            AS
                (    SELECT REGEXP_SUBSTR (l_recalculate.rc_org_list,
                                           '[^,]+',
                                           1,
                                           LEVEL)    AS x_search
                       FROM DUAL
                 CONNECT BY REGEXP_SUBSTR (l_recalculate.rc_org_list,
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                IS NOT NULL)
        SELECT COUNT (*),
               LISTAGG (x_search, ',') WITHIN GROUP (ORDER BY x_search)    AS closed_org_list
          INTO l_cnt, l_msg
          FROM search_orgs,
               (SELECT rc_org_list     AS x_list
                  FROM recalculates
                 WHERE     rc_month = l_recalculate.rc_month
                       AND rc_tp = 'M'
                       AND rc_st IN ('V', 'Z'))
         WHERE x_search IN (    SELECT REGEXP_SUBSTR (x_list,
                                                      '[^,]+',
                                                      1,
                                                      LEVEL)
                                  FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (x_list,
                                                      '[^,]+',
                                                      1,
                                                      LEVEL)
                                           IS NOT NULL);

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'По районам ' || l_msg || ' вже виконується розрахунок!');
        END IF;

        --  raise_application_error(-20000, 'TEST');

        --Захист від повторного кліку
        l_lock :=
            TOOLS.request_lock_with_timeout (
                p_descr               => 'MASS_CALC_ACCRUAL_' || l_recalculate.com_org,
                p_error_msg           =>
                    'В даний момент вже виконується постановка в чергу масового розрахунку нарахувань!',
                p_timeout             => 2,
                p_release_on_commit   => FALSE);

        TOOLS.SubmitSchedule (
            p_jb       => p_rc_jb,
            p_subsys   => 'USS_ESR',
            p_wjt      => 'MASS_CALC_PROCESS',
            p_what     =>
                   'BEGIN uss_esr.API$RECALCULATES.process_rc_job('''''
                || USS_ESR_CONTEXT.GetContext ('SESSION')
                || ''''', '
                || p_rc_id
                || '); END;');

        UPDATE recalculates
           SET rc_jb = p_rc_jb, rc_st = 'Q'
         WHERE rc_id = p_rc_id;

        write_rc_log (p_rc_id,
                      TOOLS.GetHistSession,
                      'Q',
                      CHR (38) || '173#' || p_rc_jb,
                      l_recalculate.rc_st);
        COMMIT;

        TOOLS.release_lock (l_lock);
    EXCEPTION
        /*WHEN no_data_found THEN
          raise_application_error(-20000, 'Повторна спроба запустити на обробку перерахунок, який або обробляється, або вже оброблено!');*/
        WHEN OTHERS
        THEN
            ROLLBACK;

            UPDATE recalculates
               SET rc_st = 'E'
             WHERE rc_id = p_rc_id;

            write_rc_log (
                p_rc_id,
                TOOLS.GetHistSession,
                'E',
                   SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                l_recalculate.rc_st);
            COMMIT;

            BEGIN                              -- Пробуємо прибрати блокування
                TOOLS.release_lock (l_lock);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            RAISE;
    END process_rc;

    -- Розрахунок масового перерахунку, викликається з process_rc через шедулер
    PROCEDURE process_rc_job (p_session   VARCHAR2,
                              p_rc_id     recalculates.rc_id%TYPE)
    IS
        l_recalculate   recalculates%ROWTYPE;
        l_messages      SYS_REFCURSOR;
        l_pd_num        pc_decision.pd_num%TYPE;
        l_hs            histsession.hs_id%TYPE;
        l_cnt           NUMBER;
        l_locks         t_lock_array;
        l_exec_rc_sql   uss_ndi.v_ndi_rc_queries.nrcq_sql%TYPE;
        l_rc_tp_name    uss_ndi.v_ddn_rc_tp.dic_name%TYPE;
        l_make_acc      uss_ndi.v_ndi_rc_config.nrcc_make_acc%TYPE;
    BEGIN
        --  DNET$CONTEXT.SetDnetEsrContext(p_session);
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        --ikis_sysweb.ikis_debug_pipe.WriteMsg('start');
        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(SQL%ROWCOUNT);

        SELECT NVL (nrcc_make_acc, 'F')
          INTO l_make_acc
          FROM uss_ndi.v_ndi_rc_config
         WHERE nrcc_rc_tp = l_recalculate.rc_tp;

        request_locks_by_org (
            l_recalculate.rc_org_list,
            'M_RC_EXEC_',
            'Вже виконується операція масового розрахунку або перерахунку по ОСЗН ',
            l_locks);

        UPDATE recalculates
           SET rc_st = 'V'
         WHERE rc_id = p_rc_id;

        l_hs := TOOLS.GetHistSession;
        write_rc_log (p_rc_id,
                      l_hs,
                      'V',
                      CHR (38) || '172#' || p_session,
                      l_recalculate.rc_st);
        COMMIT;

        BEGIN
            SELECT nrcq_sql
              INTO l_exec_rc_sql
              FROM uss_ndi.v_ndi_rc_queries
             WHERE nrcq_rc_tp = l_recalculate.rc_tp AND nrcq_tp = 'EXEC_RC';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                SELECT MIN (dic_name)
                  INTO l_rc_tp_name
                  FROM uss_ndi.v_ddn_rc_tp
                 WHERE dic_value = l_recalculate.rc_tp;

                raise_application_error (
                    -20000,
                       'Не визначено алгоритму виконання перерахунку <'
                    || l_rc_tp_name
                    || '>!');
        END;

        EXECUTE IMMEDIATE l_exec_rc_sql
            USING p_rc_id, l_hs;

        IF l_make_acc = 'T'
        THEN                    --Для BD_END виконуємо маніпуляції з рішеннями
            --Готуємо множину для масового розрахунку нарахувань
            INSERT INTO tmp_work_ids (x_id)
                SELECT rcc_pc
                  FROM rc_candidates
                 WHERE rcc_rc = p_rc_id;

            --ikis_sysweb.ikis_debug_pipe.WriteMsg(SQL%ROWCOUNT);

            UPDATE accrual
               SET ac_st = 'E'
             WHERE     ac_st IN ('R',
                                 'RP',
                                 'RV',
                                 'W')
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_work_ids
                             WHERE x_id = ac_pc)
                   AND EXISTS
                           (SELECT 1
                              FROM personalcase pc, billing_period
                             WHERE     ac_pc = pc_id
                                   AND pc.com_org = bp_org
                                   AND bp_class = 'VPO'
                                   AND bp_st = 'R'
                                   AND bp_tp = 'PR'
                                   AND ac_month = bp_month);

            API$ACCRUAL.calc_accrual (2,
                                      2,
                                      NULL,
                                      l_recalculate.rc_month,
                                      l_messages);

            /*  LOOP
                FETCH l_messages INTO l_row;
                EXIT WHEN l_messages%NOTFOUND;
                TOOLS.JobSaveMessage(l_row.msg_text, l_row.msg_tp);
              END LOOP; */

            --Всім реєстраційним записам нахувань, що змінені в розрахунку, проставляємо посилання на масовий перерахунок
            UPDATE accrual
               SET ac_rc = p_rc_id
             WHERE ac_id IN (SELECT c_id FROM tmp_accrual);

            SELECT COUNT (DISTINCT c_pc) INTO l_cnt FROM tmp_accrual;

            --Проставляємо статус Розраховано кандидатам, по яким нарахування хоч якось пораховані
            UPDATE rc_candidates
               SET rcc_st = 'R'
             WHERE     rcc_rc = p_rc_id
                   AND rcc_pc IN (SELECT c_pc FROM tmp_accrual);

            --Проставляємо статус Оброблено кандидатам, по яким не пройшли зміни в нарахуваннях
            UPDATE rc_candidates
               SET rcc_st = 'O'
             WHERE     rcc_rc = p_rc_id
                   AND rcc_pc NOT IN (SELECT c_pc FROM tmp_accrual);
        END IF;

        write_rc_log (
            p_rc_id,
            l_hs,
            'R',
            CHR (38) || '171#' || l_recalculate.rc_count || '#' || l_cnt,
            l_recalculate.rc_st);

        UPDATE recalculates
           SET rc_st = 'R', rc_count = NVL (l_cnt, rc_count)
         WHERE rc_id = p_rc_id;

        COMMIT;

        release_locks (l_locks);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            release_locks (l_locks);
        WHEN OTHERS
        THEN
            ROLLBACK;
            release_locks (l_locks);

            UPDATE recalculates
               SET rc_st = 'E'
             WHERE rc_id = p_rc_id;

            write_rc_log (
                p_rc_id,
                TOOLS.GetHistSession,
                'E',
                   SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                l_recalculate.rc_st);
            COMMIT;
            TOOLS.JobSaveMessage (
                   'Помилка API$RECALCULATES.'
                || $$PLSQL_UNIT
                || ' : '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END process_rc_job;

    -- #80563 OPERVIEIEV
    PROCEDURE init_com_orgs_R
    IS
        l_user_org   NUMBER;
        l_to         NUMBER;
        l_acc        NUMBER;
    BEGIN
        l_user_org := tools.getcurrorg;

        SELECT org_to, org_acc_org
          INTO l_to, l_acc
          FROM v_opfu
         WHERE org_id = l_user_org;

        DELETE FROM TMP_COM_ORGS
              WHERE 1 = 1;

        -- select all available
        IF l_to = 32 AND l_user_org = l_acc
        THEN
            INSERT INTO TMP_COM_ORGS (x_id)
                 VALUES (l_user_org);
        ELSIF l_to = 34
        THEN
            INSERT INTO TMP_COM_ORGS (x_id)
                SELECT org_id
                  FROM v_opfu
                 WHERE org_acc_org = l_user_org AND org_st = 'A';
        ELSIF l_to = 31
        THEN
            INSERT INTO TMP_COM_ORGS (x_id)
                SELECT org_id
                  FROM v_opfu
                 WHERE org_org = l_user_org AND org_st = 'A';
        END IF;
    END init_com_orgs_R;

    FUNCTION get_rc_id
        RETURN recalculates.rc_id%TYPE
    IS
    BEGIN
        RETURN g_rc_id;
    END;

    FUNCTION get_rc_tp
        RETURN recalculates.rc_tp%TYPE
    IS
    BEGIN
        RETURN g_rc_tp;
    END;



    PROCEDURE test
    IS
        s1        VARCHAR2 (4000)
            := 'INSERT INTO RC_CANDIDATES (rcc_id, rcc_st, rcc_rc, rcc_pc) SELECT 0, ''P'', x_rc, pc_id FROM (
WITH params AS (SELECT rc_id AS x_rc, rc_month AS x_period, ADD_MONTHS(rc_month, -1) AS x_period_start, rc_month - 1/86400 AS x_period_stop  FROM uss_esr.recalculates WHERE rc_id = :1),
  pcs AS (SELECT DISTINCT pc_id AS x_pc, pc.com_org AS x_pc_org, x_rc, pc_sc AS x_sc
          FROM uss_esr.personalcase pc, params
          WHERE pc.com_org IN (SELECT orgs.x_id FROM uss_esr.tmp_work_ids3 orgs)
            AND EXISTS (SELECT 1
                        FROM uss_person.v_scd_event, uss_person.v_sc_document
                        WHERE scde_scd = scd_id
                          AND scd_sc = pc_sc
                          AND scde_dt BETWEEN x_period_start AND x_period_stop
                          AND scd_ndt = 10052)),
  pcs_ext AS (SELECT x_pc, x_pc_org, x_rc, x_sc,
                    (SELECT /*MAX(*/scd_dh/*)*/ FROM Uss_Person.v_Sc_Document WHERE scd_sc = x_sc AND scd_st = ''1'' AND scd_ndt = 10052) AS x_dh,
                    (SELECT CASE WHEN scd_stop_dt IS NOT NULL THEN 1 ELSE 0 END FROM Uss_Person.v_Sc_Document WHERE scd_sc = x_sc AND scd_st = ''1'' AND scd_ndt = 10052) AS x_scd_is_stopped,
                    (SELECT COUNT(*)
                     FROM uss_esr.pc_decision, uss_esr.pd_accrual_period, params
                     WHERE pd_pc = x_pc
                       AND pdap_pd = pd_id
                       AND history_status = ''A''
                       AND pd_st = ''S''
                       AND x_period BETWEEN pdap_start_dt AND NVL(pdap_stop_dt, x_period)) x_work_pd_cnt
              FROM pcs),
  pcs_ext2 AS (SELECT x_pc, x_pc_org, x_rc, x_dh, x_work_pd_cnt, x_sc, x_scd_is_stopped,
                      (SELECT to_number(NVL((SELECT nddc_code_dest
                                             FROM uss_ndi.v_ndi_decoding_config
                                             WHERE nddc_tp = ''ORG_MIGR''
                                               AND nddc_code_src = ''5''||LPAD(substr(da_val_string, 1, instr(da_val_string, ''-'') - 1), 4, ''0'')),
                                            ''5''||LPAD(substr(da_val_string, 1, instr(da_val_string, ''-'') - 1), 4, ''0'')))
                       FROM Uss_Doc.v_Doc_Attr2hist h, Uss_Doc.v_Doc_Attributes a
                       WHERE x_dh = h.Da2h_Dh
                         AND h.Da2h_Da = a.Da_Id
                         and a.Da_Nda = 1756
                         and da_val_string like ''%-%'') AS x_dov_org
               FROM pcs_ext)
  SELECT x_pc AS pc_id, x_rc
  FROM pcs_ext2
  WHERE x_work_pd_cnt > 0
    AND (x_dh IS NULL
      OR x_scd_is_stopped = 1
      OR x_dov_org <> x_pc_org)
 )';
        s         VARCHAR2 (4000)
            := 'INSERT INTO RC_CANDIDATES (rcc_id, rcc_st, rcc_rc, rcc_pc) SELECT 0, ''P'', x_rc, pc_id FROM (
WITH params AS (SELECT rc_id AS x_rc, rc_month AS x_period, ADD_MONTHS(rc_month, -1) AS x_period_start, rc_month - 1/86400 AS x_period_stop  FROM uss_esr.recalculates WHERE rc_id = :1),
  pcs AS (SELECT DISTINCT pc_id AS x_pc, pc.com_org AS x_pc_org, x_rc, pc_sc AS x_sc
          FROM uss_esr.personalcase pc, params
          WHERE pc.com_org IN (SELECT orgs.x_id FROM uss_esr.tmp_work_ids3 orgs)
            AND EXISTS (SELECT 1
                        FROM uss_person.v_scd_event, uss_person.v_sc_document
                        WHERE scde_scd = scd_id
                          AND scd_sc = pc_sc
                          AND scde_dt BETWEEN x_period_start AND x_period_stop
                          AND scd_ndt = 10052)),
 pcs_ext AS (SELECT x_pc, x_pc_org, x_rc, x_sc,
                    (SELECT /*MAX(*/scd_dh/*)*/ FROM Uss_Person.v_Sc_Document WHERE scd_sc = x_sc AND scd_st = ''1'' AND scd_ndt = 10052) AS x_dh,
                    (SELECT CASE WHEN scd_stop_dt IS NOT NULL THEN 1 ELSE 0 END FROM Uss_Person.v_Sc_Document WHERE scd_sc = x_sc AND scd_st = ''1'' AND scd_ndt = 10052) AS x_scd_is_stopped,
                    (SELECT COUNT(*)
                     FROM uss_esr.pc_decision, uss_esr.pd_accrual_period, params
                     WHERE pd_pc = x_pc
                       AND pdap_pd = pd_id
                       AND history_status = ''A''
                       AND pd_st = ''S''
                       AND x_period BETWEEN pdap_start_dt AND NVL(pdap_stop_dt, x_period)) x_work_pd_cnt
              FROM pcs)     ,
  pcs_ext2 AS (SELECT x_pc, x_pc_org, x_rc, x_dh, x_work_pd_cnt, x_sc, x_scd_is_stopped,
                      (SELECT to_number(NVL((SELECT nddc_code_dest
                                             FROM uss_ndi.v_ndi_decoding_config
                                             WHERE nddc_tp = ''ORG_MIGR''
                                               AND nddc_code_src = ''5''||LPAD(substr(da_val_string, 1, instr(da_val_string, ''-'') - 1), 4, ''0'')),
                                            ''5''||LPAD(substr(da_val_string, 1, instr(da_val_string, ''-'') - 1), 4, ''0'')))
                       FROM Uss_Doc.v_Doc_Attr2hist h, Uss_Doc.v_Doc_Attributes a
                       WHERE x_dh = h.Da2h_Dh
                         AND h.Da2h_Da = a.Da_Id
                         and a.Da_Nda = 1756
                         and da_val_string like ''%-%'') AS x_dov_org
               FROM pcs_ext)
  SELECT x_pc AS pc_id, x_rc
  FROM pcs_ext2
 )';
        p_rc_id   INTEGER := 1;
    BEGIN
        EXECUTE IMMEDIATE s
            USING p_rc_id                                          /*, l_sql*/
                         ;
    END;

    PROCEDURE unhook_ac_from_rc (p_rc_id   recalculates.rc_id%TYPE,
                                 p_ac_id   accrual.ac_id%TYPE,
                                 p_hs_id   histsession.hs_id%TYPE:= NULL)
    IS
        l_recalculate   v_recalculates%ROWTYPE;
        l_pc_num        personalcase.pc_num%TYPE;
        l_ac_st         accrual.ac_st%TYPE;
        l_hs            histsession.hs_id%TYPE;
    BEGIN
        BEGIN
            SELECT *
              INTO l_recalculate
              FROM v_recalculates
             WHERE rc_id = p_rc_id AND rc_id = p_rc_id AND rc_st = 'F';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Не знайдено масового перерахунку в стані Зафіксовано по переданим параметрам!');
        END;

        BEGIN
            SELECT pc_num, ac_st
              INTO l_pc_num, l_ac_st
              FROM accrual, v_personalcase
             WHERE ac_rc = p_rc_id AND ac_id = p_ac_id AND ac_pc = pc_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Не знайдено нарахування, причепленого до масового перерахунку в стані Зафіксовано, по переданим параметрам!');
        END;

        l_hs := NVL (p_hs_id, TOOLS.GetHistSession);

        UPDATE accrual
           SET ac_rc = NULL
         WHERE ac_id = p_ac_id AND ac_rc = p_rc_id;

        write_rc_log (p_rc_id,
                      l_hs,
                      l_recalculate.rc_st,
                      CHR (38) || '185#' || l_pc_num,
                      l_recalculate.rc_st);
        API$ACCRUAL.write_ac_log (p_ac_id,
                                  l_hs,
                                  l_ac_st,
                                  CHR (38) || '186#' || p_rc_id,
                                  l_ac_st);
    END;
BEGIN
    -- Initialization
    NULL;
END API$RECALCULATES;
/