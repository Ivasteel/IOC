/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$ACCRUAL
IS
    -- Author  : VANO
    -- Created : 10.12.2021 15:35:53
    -- Purpose : Фукнції взаємодії з сайтом по нарахуванням

    --Отримання даних по нарахуванням для ЕОС
    PROCEDURE get_accruals (p_pc_id         personalcase.pc_id%TYPE,
                            p_accrual   OUT SYS_REFCURSOR,
                            p_mode          INTEGER := 1);

    PROCEDURE approve_accrual (p_ac_id accrual.ac_id%TYPE);

    PROCEDURE return_accrual (p_ac_id       accrual.ac_id%TYPE,
                              p_reason   IN VARCHAR2);

    PROCEDURE get_accrual_log (p_ac_id         accrual.ac_id%TYPE,
                               p_res_cur   OUT SYS_REFCURSOR);

    -- лог по розрахунку
    PROCEDURE get_rc_log (p_rc_id         rc_log.rcl_rc%TYPE,
                          p_res_cur   OUT SYS_REFCURSOR);

    --Отримання даних по деталям нарахуваннь для ЕОС
    PROCEDURE get_accrual_details (
        p_ac_id           accrual.ac_id%TYPE,
        p_ac_detail   OUT SYS_REFCURSOR,
        p_mode            INTEGER := 1,
        p_month           accrual.ac_month%TYPE := NULL);



    --Розрахунок нарахувань
    PROCEDURE calc_accrual (p_in_mode         INTEGER,
                            p_calc_mode       INTEGER,
                            p_pc_id           personalcase.pc_id%TYPE,
                            p_month           DATE := SYSDATE,
                            p_messages    OUT SYS_REFCURSOR);


    -- #75002: "Протокол розрахунку нарахувань" - заповнення констант
    PROCEDURE SEED_CONSTS (p_ac_id IN NUMBER, p_jbr_id IN DECIMAL);

    -- #75002: "Протокол розрахунку нарахувань"
    PROCEDURE RegisterReport (p_ac_id IN NUMBER, p_jbr_id OUT DECIMAL);



    --Отримання параметрів, за якими користувач може виконати масовий розрахунок нарахувань
    PROCEDURE get_actual_params (p_tp                INTEGER := 1,
                                 p_months_list   OUT SYS_REFCURSOR,
                                 p_org_list      OUT SYS_REFCURSOR);

    --Функція виконання масового розрахунку - реєструє власне перерахунок в таблицю  recalculates і створює відкладену задачу IKIS
    PROCEDURE mass_calc_accrual (
        p_rc_month      IN     DATE,
        p_rc_org_list   IN     recalculates.rc_org_list%TYPE,
        p_rc_tp         IN     recalculates.rc_tp%TYPE,
        p_kaot_ids      IN     recalculates.rc_kaot_list%TYPE,
        p_nst_list      IN     recalculates.rc_nst_list%TYPE,
        p_rc_id            OUT recalculates.rc_id%TYPE,
        p_rc_jb            OUT recalculates.rc_jb%TYPE);

    -- #99137 ознаки
    PROCEDURE get_card_features (p_rcc_id   IN     NUMBER,
                                 res_cur       OUT SYS_REFCURSOR);

    -- розрахунок перерахунку
    PROCEDURE bd_end_calc (p_rc_id       recalculates.rc_id%TYPE,
                           p_rc_jb   OUT recalculates.rc_jb%TYPE);

    -- #79922: Обробити розрахунок
    PROCEDURE approve_recalculates (p_rc_id recalculates.rc_id%TYPE);

    -- Попередні масові нарахування
    PROCEDURE get_mass_calc_list (
        p_rc_id         IN     recalculates.rc_id%TYPE,
        p_rc_dt_start   IN     recalculates.rc_dt%TYPE,
        p_rc_dt_stop    IN     recalculates.rc_dt%TYPE,
        p_rc_month      IN     recalculates.rc_month%TYPE,
        p_rc_org_code   IN     recalculates.rc_org_list%TYPE,
        p_rc_tp         IN     recalculates.rc_tp%TYPE,
        res_cur            OUT SYS_REFCURSOR);


    -- Картка масового нарахування
    PROCEDURE get_mass_calc_card (
        p_rc_id                 IN     recalculates.rc_id%TYPE,
        p_org_id                IN     NUMBER,
        p_pc_num                IN     VARCHAR2,
        p_is_payroll_included   IN     VARCHAR2,
        p_rc_kaot               IN     NUMBER,
        res_cur                    OUT SYS_REFCURSOR);

    -- #85753: Статистика по КАТОТТГ
    PROCEDURE get_mass_calc_card_kaot_stat (p_rc_id   IN     NUMBER,
                                            res_cur      OUT SYS_REFCURSOR);

    --Отримання даних попереднього розрахунку
    PROCEDURE get_prev_calc_accrual (p_pd_id           personalcase.pc_id%TYPE,
                                     p_accrual     OUT SYS_REFCURSOR,
                                     p_ac_detail   OUT SYS_REFCURSOR);

    --Повернення розрахунку нарахувань
    PROCEDURE return_recalculates (p_rc_id recalculates.rc_id%TYPE);

    -- Видалення розрахунку нарахувань
    PROCEDURE delete_recalculates (p_rc_id recalculates.rc_id%TYPE);

    --Масове підтвердження нарахувань
    PROCEDURE approve_accrual_by_params (p_org            accrual.com_org%TYPE,
                                         p_nst            pc_decision.pd_nst%TYPE,
                                         p_month          accrual.ac_month%TYPE,
                                         p_messages   OUT SYS_REFCURSOR);

    --Статистика по нарахуванням
    PROCEDURE get_accual_stats (p_month               accrual.ac_month%TYPE,
                                p_org                 accrual.com_org%TYPE,
                                p_nst                 pc_decision.pd_nst%TYPE,
                                p_by_nis              VARCHAR2 DEFAULT 'F', -- #80574 OPERVIEIEV поглиблена до дільниць
                                p_accrual_stats   OUT SYS_REFCURSOR);

    --#78829 Звіт "Стан рішень"
    PROCEDURE get_pd_stats (p_month          accrual.ac_month%TYPE,
                            p_org            accrual.com_org%TYPE,
                            p_nst            pc_decision.pd_nst%TYPE,
                            p_type    IN     VARCHAR2,
                            res_cur      OUT SYS_REFCURSOR);

    -- #85493: Відчепити від масс.перерахунку
    PROCEDURE unhook_ac_from_rc (p_rc_id IN NUMBER, p_ac_id IN NUMBER);


    -- #90319
    PROCEDURE change_acd_period (p_acd_id         IN NUMBER,
                                 p_acd_start_dt   IN DATE,
                                 p_acd_stop_dt    IN DATE);

    --Знак для іду операції
    FUNCTION xsign (p_op_id NUMBER)
        RETURN NUMBER;

    --Перерахунок ознаки для кандидатів масового перерахунку
    PROCEDURE reset_rcca_value (p_rcca_id rc_candidate_attr.rcca_id%TYPE);

    -- #117351
    PROCEDURE check_post_index (p_npo_Id IN NUMBER, p_rc_id OUT NUMBER);
END DNET$ACCRUAL;
/


GRANT EXECUTE ON USS_ESR.DNET$ACCRUAL TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$ACCRUAL TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$ACCRUAL
IS
    -- #99611: перевірка доступу до операцій з перерахунками
    PROCEDURE check_roles (p_rc_id    IN NUMBER,
                           p_action   IN VARCHAR2 DEFAULT 'NONE')
    IS
        l_org_to         NUMBER := tools.GetCurrOrgTo;
        l_org            NUMBER := tools.GetCurrOrg;
        l_cnt            NUMBER;
        l_recalculates   recalculates%ROWTYPE;
        l_rc_config      uss_ndi.v_ndi_rc_config%ROWTYPE;
    BEGIN
        IF (l_org_to != 32)
        THEN
            RETURN;
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM v_recalculates t
         WHERE t.rc_id = p_rc_id;

        SELECT *
          INTO l_recalculates
          FROM recalculates
         WHERE rc_id = p_rc_id;

        SELECT *
          INTO l_rc_config
          FROM uss_ndi.v_ndi_rc_config
         WHERE nrcc_rc_tp = l_recalculates.rc_tp;

        --      raise_application_error(-20000, p_action||l_rc_config.nrcc_exec_alg||l_recalculates.rc_st||l_recalculates.rc_org_list||'-'||tools.GetCurrOrgTo);
        IF     p_action = 'PROCESS'
           AND l_rc_config.nrcc_exec_alg = 'CND_CONF'
           AND l_recalculates.rc_st = 'L'
           AND tools.GetCurrOrg = l_recalculates.rc_org_list
        THEN
            RETURN;
        ELSIF (l_cnt = 0)
        THEN
            raise_application_error (-20000, 'Операція недоступна!');
        END IF;
    END;

    --Отримання даних по нарахуванням для ЕОС
    PROCEDURE get_accruals (p_pc_id         personalcase.pc_id%TYPE,
                            p_accrual   OUT SYS_REFCURSOR,
                            p_mode          INTEGER := 1)
    IS
    BEGIN
        tools.WriteMsg ('DNET$ACCRUAL.' || $$PLSQL_UNIT);

        IF p_mode = 1
        THEN
            OPEN p_accrual FOR
                  SELECT ac_id
                             AS ac_id,
                         ac_pc,
                         ac_month,
                         ac_assign_sum,
                         ac_else_dn_sum,
                         ac_st,
                         history_status,
                         ac_delta_recalc,
                         ac_delta_pay,
                         ac_payed_sum,
                         TO_CHAR (ac_month,
                                  'YYYY month',
                                  'NLS_DATE_LANGUAGE=UKRAINIAN')
                             AS ac_period,
                         ADD_MONTHS (ac_month, 1) - ac_month
                             AS ac_days_count,
                         (SELECT dic_name
                            FROM uss_ndi.v_ddn_ac_st
                           WHERE dic_value = ac_st)
                             AS ac_st_name
                    FROM v_accrual_by_pc t --, (select level as zz from dual connect by level < 3)
                   WHERE ac_pc = p_pc_id
                ORDER BY ac_month DESC;
        ELSIF p_mode = 2
        THEN
            OPEN p_accrual FOR
                  SELECT DISTINCT
                         NULL
                             AS ac_id,
                         p_pc_id
                             AS ac_pc,
                         TRUNC (acd_start_dt, 'MM')
                             AS ac_month,
                         NULL
                             AS ac_assign_sum,
                         NULL
                             AS ac_else_dn_sum,
                         NULL
                             AS ac_st,
                         NULL
                             AS history_status,
                         NULL
                             AS ac_delta_recalc,
                         NULL
                             AS ac_delta_pay,
                         NULL
                             AS ac_payed_sum,
                         TO_CHAR (TRUNC (acd_start_dt, 'MM'),
                                  'YYYY month',
                                  'NLS_DATE_LANGUAGE=UKRAINIAN')
                             AS ac_period,
                           ADD_MONTHS (TRUNC (acd_start_dt, 'MM'), 1)
                         - TRUNC (acd_start_dt, 'MM')
                             AS ac_days_count,
                         NULL
                             AS ac_st_name
                    FROM v_ac_detail, v_accrual_by_pc t --, (select level as zz from dual connect by level < 3)
                   WHERE acd_ac = ac_id AND ac_pc = p_pc_id
                ORDER BY TRUNC (acd_start_dt, 'MM') DESC;
        ELSE
            OPEN p_accrual FOR SELECT * FROM DUAL;
        END IF;
    END;

    --Отримання даних по деталям нарахуваннь для ЕОС
    PROCEDURE get_accrual_details (
        p_ac_id           accrual.ac_id%TYPE,
        p_ac_detail   OUT SYS_REFCURSOR,
        p_mode            INTEGER := 1,
        p_month           accrual.ac_month%TYPE := NULL)
    IS
    BEGIN
        tools.WriteMsg ('DNET$ACCRUAL.' || $$PLSQL_UNIT);

        IF p_mode = 1
        THEN
            OPEN p_ac_detail FOR
                  SELECT acd_id,
                         acd_ac,
                         acd_op,
                         acd_npt,
                         acd_start_dt,
                         acd_stop_dt,
                         acd_sum,
                         acd_month_sum,
                         acd_delta_recalc,
                         acd_delta_pay,
                         acd_dn,
                         acd_pd,
                         acd_ac_start_dt,
                         acd_ac_stop_dt,
                         acd_is_indexed,
                         acd_st,
                         t.history_status,
                         acd_payed_sum,
                         (SELECT op_order || '. ' || op_name
                            FROM uss_ndi.v_ndi_op
                           WHERE acd_op = op_id)
                             AS acd_op_name,
                         (SELECT npt_name
                            FROM uss_ndi.v_ndi_payment_type
                           WHERE acd_npt = npt_id)
                             AS acd_npt_name,
                         (SELECT npt_code
                            FROM uss_ndi.v_ndi_payment_type
                           WHERE acd_npt = npt_id)
                             AS acd_npt_code,
                         acd_stop_dt - acd_start_dt + 1
                             AS acd_days_count,
                         (SELECT dpp_name
                            FROM uss_ndi.v_ndi_pay_person, deduction
                           WHERE acd_dn = dn_id AND dn_dpp = dpp_id)
                             AS acd_dn_name,
                         pd.pd_num
                             AS acd_pd_num,
                         pd.com_org
                             AS pd_org,
                         (SELECT dic_name
                            FROM uss_ndi.v_ddn_ac_st
                           WHERE dic_value = acd_st)
                             AS acd_st_name,
                         CASE
                             WHEN r.pr_tp NOT IN ('AD', 'MD') THEN r.pr_fix_dt
                         END
                             AS pr_fix_dt,
                         CASE WHEN r.pr_tp NOT IN ('AD', 'MD') THEN r.pr_id END
                             AS pr_id,
                         CASE
                             WHEN ur.pr_tp IN ('AD', 'MD') THEN ur.pr_fix_dt
                         END
                             AS pr_fix_dt_jur,
                         CASE WHEN ur.pr_tp IN ('AD', 'MD') THEN ur.pr_id END
                             AS pr_id_jur,
                         r.pr_st,
                         t.acd_imp_pr_num,
                         rc.rc_dt,
                         d.prsd_prs,
                         ud.prsd_prs
                             AS prsd_prs_jur
                    FROM ac_detail t
                         LEFT JOIN pc_decision pd ON (pd.pd_id = t.acd_pd)
                         JOIN v_accrual_by_pc a ON (a.ac_id = t.acd_ac)
                         LEFT JOIN recalculates rc ON (rc.rc_id = a.ac_rc)
                         LEFT JOIN pr_sheet_detail d
                             ON (d.prsd_id = t.acd_prsd)
                         LEFT JOIN payroll r ON (r.pr_id = d.prsd_pr)
                         LEFT JOIN pr_sheet_detail ud
                             ON (ud.prsd_id = t.acd_prsd_sa)
                         LEFT JOIN payroll ur ON (ur.pr_id = ud.prsd_pr)
                   WHERE acd_ac = p_ac_id AND t.history_status = 'A'
                ORDER BY TRUNC (acd_start_dt, 'MM'),
                         acd_op_name,
                         acd_npt_code,
                         acd_start_dt;
        ELSIF p_mode = 2
        THEN
            OPEN p_ac_detail FOR
                  SELECT acd_id,
                         acd_ac,
                         acd_op,
                         acd_npt,
                         acd_start_dt,
                         acd_stop_dt,
                         acd_sum,
                         acd_month_sum,
                         acd_delta_recalc,
                         acd_delta_pay,
                         acd_dn,
                         acd_pd,
                         ac_month
                             AS acd_ac_start_dt,
                         LAST_DAY (ac_month)
                             AS acd_ac_stop_dt,
                         acd_is_indexed,
                         acd_st,
                         t.history_status,
                         acd_payed_sum,
                         (SELECT op_order || '. ' || op_name
                            FROM uss_ndi.v_ndi_op
                           WHERE acd_op = op_id)
                             AS acd_op_name,
                         (SELECT npt_name
                            FROM uss_ndi.v_ndi_payment_type
                           WHERE acd_npt = npt_id)
                             AS acd_npt_name,
                         (SELECT npt_code
                            FROM uss_ndi.v_ndi_payment_type
                           WHERE acd_npt = npt_id)
                             AS acd_npt_code,
                         acd_stop_dt - acd_start_dt + 1
                             AS acd_days_count,
                         (SELECT dpp_name
                            FROM uss_ndi.v_ndi_pay_person, deduction
                           WHERE acd_dn = dn_id AND dn_dpp = dpp_id)
                             AS acd_dn_name,
                         pd.pd_num
                             AS acd_pd_num,
                         pd.com_org
                             AS pd_org,
                         (SELECT dic_name
                            FROM uss_ndi.v_ddn_ac_st
                           WHERE dic_value = acd_st)
                             AS acd_st_name,
                         CASE
                             WHEN r.pr_tp NOT IN ('AD', 'MD') THEN r.pr_fix_dt
                         END
                             AS pr_fix_dt,
                         CASE WHEN r.pr_tp NOT IN ('AD', 'MD') THEN r.pr_id END
                             AS pr_id,
                         CASE
                             WHEN ur.pr_tp IN ('AD', 'MD') THEN ur.pr_fix_dt
                         END
                             AS pr_fix_dt_jur,
                         CASE WHEN ur.pr_tp IN ('AD', 'MD') THEN ur.pr_id END
                             AS pr_id_jur,
                         r.pr_st,
                         t.acd_imp_pr_num,
                         rc.rc_dt,
                         d.prsd_prs,
                         ud.prsd_prs
                             AS prsd_prs_jur
                    FROM ac_detail t
                         LEFT JOIN pc_decision pd ON (pd.pd_id = t.acd_pd)
                         JOIN v_accrual_by_pc a ON (a.ac_id = t.acd_ac)
                         LEFT JOIN recalculates rc ON (rc.rc_id = a.ac_rc)
                         LEFT JOIN pr_sheet_detail d
                             ON (d.prsd_id = t.acd_prsd)
                         LEFT JOIN payroll r ON (r.pr_id = d.prsd_pr)
                         LEFT JOIN pr_sheet_detail ud
                             ON (ud.prsd_id = t.acd_prsd_sa)
                         LEFT JOIN payroll ur ON (ur.pr_id = ud.prsd_pr)
                   WHERE     ac_pc = p_ac_id
                         AND acd_start_dt BETWEEN TRUNC (p_month, 'MM')
                                              AND LAST_DAY (
                                                      TRUNC (p_month, 'MM'))
                         AND t.history_status = 'A'
                ORDER BY TRUNC (acd_start_dt, 'MM'),
                         acd_op_name,
                         acd_npt_code,
                         acd_start_dt;
        ELSE
            OPEN p_ac_detail FOR SELECT * FROM DUAL;
        END IF;
    END;

    PROCEDURE approve_accrual (p_ac_id accrual.ac_id%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$ACCRUAL.' || $$PLSQL_UNIT);
        API$ACCRUAL.approve_accrual (p_ac_id);
    END;

    PROCEDURE approve_accrual_by_params (p_org            accrual.com_org%TYPE,
                                         p_nst            pc_decision.pd_nst%TYPE,
                                         p_month          accrual.ac_month%TYPE,
                                         p_messages   OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$ACCRUAL.approve_accrual_by_params (p_org,
                                               p_nst,
                                               p_month,
                                               p_messages);
    END;

    PROCEDURE return_accrual (p_ac_id       accrual.ac_id%TYPE,
                              p_reason   IN VARCHAR2)
    IS
    BEGIN
        API$ACCRUAL.return_accrual (p_ac_id, p_reason);
    END;

    PROCEDURE approve_recalculates (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_rc_tp   VARCHAR2 (10);
    BEGIN
        /*SELECT MAX(t.rc_tp)
          INTO l_rc_tp
          FROM recalculates t
         WHERE t.rc_id = p_rc_id;  */

        check_roles (p_rc_id);

        API$RECALCULATES.approve_recalculates (p_rc_id);
    END;

    PROCEDURE return_recalculates (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_rc_tp   VARCHAR2 (10);
    BEGIN
        /*SELECT MAX(t.rc_tp)
          INTO l_rc_tp
          FROM recalculates t
         WHERE t.rc_id = p_rc_id; */

        check_roles (p_rc_id);

        API$RECALCULATES.return_recalculates (p_rc_id);
    END;

    PROCEDURE delete_recalculates (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_rc_tp   VARCHAR2 (10);
    BEGIN
        check_roles (p_rc_id);

        SELECT MAX (t.rc_tp)
          INTO l_rc_tp
          FROM recalculates t
         WHERE t.rc_id = p_rc_id;

        IF (l_rc_tp = 'BD_END')
        THEN
            API$RECALCULATES.rc_purge (p_rc_id);
        END IF;
    END;

    PROCEDURE get_accrual_log (p_ac_id         accrual.ac_id%TYPE,
                               p_res_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res_cur FOR
              SELECT acl_id                                                   AS log_id,
                     acl_ac                                                   AS log_obj,
                     acl_tp                                                   AS log_tp,
                     st.dic_name                                              AS log_st_name,
                     sto.dic_name                                             AS log_st_old_name,
                     hs_dt                                                    AS log_hs_dt,
                     tools.GetUserLogin (hs_wu)                               AS log_hs_author,
                     uss_ndi.RDM$MSG_TEMPLATE.getmessagetext (acl_message)    AS log_message
                FROM ac_log
                     LEFT JOIN uss_ndi.v_ddn_ac_st st
                         ON (st.dic_value = acl_st)
                     LEFT JOIN uss_ndi.v_ddn_ac_st sto
                         ON (sto.dic_value = acl_st_old)
                     LEFT JOIN v_histsession ON (hs_id = acl_hs)
               WHERE acl_ac = p_ac_id
            ORDER BY hs_dt;
    END;

    PROCEDURE get_rc_log (p_rc_id         rc_log.rcl_rc%TYPE,
                          p_res_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res_cur FOR
              SELECT t.rcl_id                                                   AS log_id,
                     t.rcl_rc                                                   AS log_obj,
                     t.rcl_tp                                                   AS log_tp,
                     st.dic_name                                                AS log_st_name,
                     sto.dic_name                                               AS log_st_old_name,
                     hs_dt                                                      AS log_hs_dt,
                     tools.GetUserLogin (hs_wu)                                 AS log_hs_author,
                     uss_ndi.RDM$MSG_TEMPLATE.getmessagetext (t.rcl_message)    AS log_message
                FROM rc_log t
                     LEFT JOIN uss_ndi.v_ddn_rc_st st
                         ON (st.dic_value = t.rcl_st)
                     LEFT JOIN uss_ndi.v_ddn_rc_st sto
                         ON (sto.dic_value = t.rcl_st_old)
                     LEFT JOIN v_histsession ON (hs_id = t.rcl_hs)
               WHERE t.rcl_rc = p_rc_id
            ORDER BY hs_dt;
    END;

    --Розрахунок нарахувань
    PROCEDURE calc_accrual (p_in_mode         INTEGER,
                            p_calc_mode       INTEGER,
                            p_pc_id           personalcase.pc_id%TYPE,
                            p_month           DATE := SYSDATE,
                            p_messages    OUT SYS_REFCURSOR)
    IS
    BEGIN
        --Формуємо множину особових орахунків для розрахунку на основі рішень, які потрібно розраховувати
        DELETE FROM tmp_work_pa_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_pa_ids (x_pa)
            SELECT DISTINCT pd_pa
              FROM personalcase pc, pc_decision pd
             WHERE     pd_pc = pc_id
                   AND pd_pc = p_pc_id
                   AND pd.com_org IN (SELECT u_org FROM tmp_org);

        API$ACCRUAL.set_calc_mode (1);
        API$ACCRUAL.calc_accrual (p_in_mode,
                                  p_calc_mode,
                                  p_pc_id,
                                  p_month,
                                  p_messages);
    END;

    -- #75002: "Протокол розрахунку нарахувань" - заповнення констант
    PROCEDURE SEED_CONSTS (p_ac_id IN NUMBER, p_jbr_id IN DECIMAL)
    IS
    BEGIN
        -- constants
        FOR xx
            IN (SELECT *
                  FROM (SELECT TO_CHAR (TRUNC (t.ac_month, 'MM'),
                                        'DD.MM.YYYY')
                                   AS start_dt,
                               TO_CHAR (LAST_DAY (t.ac_month), 'DD.MM.YYYY')
                                   AS stop_dt,
                               ptp.DIC_SNAME
                                   AS pay_method,
                               CASE
                                   WHEN pdm_pay_tp = 'POST'
                                   THEN
                                       pdm_index
                                   WHEN pdm_pay_tp = 'BANK'
                                   THEN
                                          b.nb_mfo
                                       || ' '
                                       || b.nb_name
                                       || ' '
                                       || pm.pdm_account
                               END
                                   AS post_office,
                               CASE
                                   WHEN pdm_pay_tp = 'BANK' THEN 'БАНК'
                                   ELSE 'ВІДДІЛЕННЯ ЗВ’ЯЗКУ'
                               END
                                   AS post_name,
                               pa.pa_num
                                   AS or_num,
                               NULL
                                   AS statement_tp,
                               NULL
                                   AS pay_month,
                               ROW_NUMBER ()
                                   OVER (ORDER BY d.pd_dt DESC, d.pd_num)
                                   AS rn
                          FROM v_accrual_by_pc  t
                               JOIN v_pc_account pa ON (pa.pa_pc = t.ac_pc)
                               JOIN pc_decision d ON (d.pd_pc = t.ac_pc)
                               LEFT JOIN Pd_Pay_Method pm
                                   ON (    pm.pdm_pd = d.pd_id
                                       AND pm.pdm_is_actual = 'T'
                                       AND pm.history_status = 'A')
                               LEFT JOIN uss_ndi.V_DDN_APM_TP ptp
                                   ON (ptp.DIC_VALUE = pm.pdm_pay_tp)
                               LEFT JOIN uss_ndi.v_ndi_bank b
                                   ON (b.nb_id = pm.pdm_nb)) t
                 WHERE rn = 1)
        LOOP
            RDM$RTFL.AddParam (p_jbr_id, 'start_dt', xx.start_dt);
            RDM$RTFL.AddParam (p_jbr_id, 'stop_dt', xx.stop_dt);
            RDM$RTFL.AddParam (p_jbr_id, 'pay_method', xx.pay_method);
            RDM$RTFL.AddParam (p_jbr_id, 'post_office', xx.post_office);
            RDM$RTFL.AddParam (p_jbr_id, 'or_num', xx.or_num);
            RDM$RTFL.AddParam (p_jbr_id, 'statement_tp', xx.statement_tp);
            RDM$RTFL.AddParam (p_jbr_id, 'pay_month', xx.pay_month);
            RDM$RTFL.AddParam (p_jbr_id, 'post_name', xx.post_name);
        END LOOP;
    END;

    -- #75002: "Протокол розрахунку нарахувань"
    PROCEDURE RegisterReport (p_ac_id IN NUMBER, p_jbr_id OUT DECIMAL)
    IS
        l_rt_id   NUMBER;
    BEGIN
        SELECT t.rt_id
          INTO l_rt_id
          FROM rpt_templates t
         WHERE t.rt_code = 'CALC_PROTOCOL_R1';

        p_jbr_id := rdm$rtfl.InitReport (l_rt_id);

        rdm$rtfl.AddDataSet (
            p_jbr_id,
            'ds',
               'SELECT pt.npt_name AS pay_tp,
            pt.npt_code AS pay_code,
            to_char(t.acd_start_dt, ''MM'') AS accr_month,
            to_char(t.acd_start_dt, ''YYYY'') AS accr_year,
            t. acd_stop_dt - t.acd_start_dt + 1 AS days_qnt,
            to_char(t.acd_sum, ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')  AS sum_p,
            to_char(t.acd_payed_sum, ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''') AS sum_v,
            to_char(t.acd_delta_recalc, ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')  AS sum_t
       FROM uss_esr.v_ac_detail t
       JOIN uss_ndi.v_ndi_payment_type pt ON (pt.npt_id = t.acd_npt)
      where t.acd_ac = '
            || p_ac_id
            || '
        AND t.history_status = ''A''
      ORDER BY acd_start_dt, npt_code, acd_op');


        rdm$rtfl.AddDataSet (
            p_jbr_id,
            'summary',
               'SELECT to_char(t.ac_assign_sum, ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')  AS sum_p,
            to_char(t.ac_else_dn_sum, ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''') AS sum_v,
            to_char(t.ac_delta_recalc, ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')  AS sum_t
       FROM uss_esr.v_accrual_by_pc t
      where t.ac_id = '
            || p_ac_id);

        rdm$rtfl.AddScript (
            p_jbr_id,
            'constants',
               'begin uss_esr.DNET$ACCRUAL.SEED_CONSTS('
            || p_ac_id
            || ', '
            || p_jbr_id
            || '); end;');

        /*-- constants
        FOR xx IN (SELECT *
                     FROM (SELECT to_char(trunc(t.ac_month, 'MM'), 'DD.MM.YYYY') AS start_dt,
                                  to_char(last_day(t.ac_month), 'DD.MM.YYYY') AS stop_dt,
                                  ptp.DIC_SNAME AS pay_method,
                                  CASE WHEN d.pd_pay_tp = 'POST' THEN d.pd_index
                                       WHEN d.pd_pay_tp = 'BANK' THEN b.nb_mfo || ' ' || b.nb_name || ' ' || d.pd_account
                                  END AS post_office,
                                  pa.pa_num AS or_num,
                                  NULL AS statement_tp,
                                  NULL AS pay_month,
                                  row_number() over (ORDER BY d.pd_dt DESC, d.pd_num) AS rn
                             FROM v_accrual_by_pc t
                             JOIN v_pc_account pa ON (pa.pa_pc = t.ac_pc)
                             JOIN pc_decision d ON (d.pd_pc = t.ac_pc)
                             LEFT JOIN uss_ndi.V_DDN_APM_TP ptp ON (ptp.DIC_VALUE = d.pd_pay_tp)
                             LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = d.Pdm_Nb)
                           ) t
                     WHERE rn = 1
                  )
        LOOP
          RDM$RTFL.AddParam(p_jbr_id, 'start_dt', xx.start_dt);
          RDM$RTFL.AddParam(p_jbr_id, 'stop_dt', xx.stop_dt);
          RDM$RTFL.AddParam(p_jbr_id, 'pay_method', xx.pay_method);
          RDM$RTFL.AddParam(p_jbr_id, 'post_office', xx.post_office);
          RDM$RTFL.AddParam(p_jbr_id, 'or_num', xx.or_num);
          RDM$RTFL.AddParam(p_jbr_id, 'statement_tp', xx.statement_tp);
          RDM$RTFL.AddParam(p_jbr_id, 'pay_month', xx.pay_month);
        END LOOP; */

        rdm$rtfl.PutReportToWorkingQueue (p_jbr_id);
    END;



    --Отримання параметрів, за якими користувач може виконати масовий розрахунок нарахувань
    PROCEDURE get_actual_params (p_tp                INTEGER := 1,
                                 p_months_list   OUT SYS_REFCURSOR,
                                 p_org_list      OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$ACCRUAL.get_month_list (p_tp, p_months_list);
        API$ACCRUAL.get_org_list (p_tp, p_org_list);
    END;

    --Функція виконання масового розрахунку - реєструє власне перерахунок в таблицю  recalculates і створює відкладену задачу IKIS
    PROCEDURE mass_calc_accrual (
        p_rc_month      IN     DATE,
        p_rc_org_list   IN     recalculates.rc_org_list%TYPE,
        p_rc_tp         IN     recalculates.rc_tp%TYPE,
        p_kaot_ids      IN     recalculates.rc_kaot_list%TYPE,
        p_nst_list      IN     recalculates.rc_nst_list%TYPE,
        p_rc_id            OUT recalculates.rc_id%TYPE,
        p_rc_jb            OUT recalculates.rc_jb%TYPE)
    IS
    BEGIN
        --raise_application_error(-20000, 'p_rc_org_list='|| p_rc_org_list );
        uss_esr.Api$recalculates.mass_calc_accrual (p_rc_id,
                                                    p_rc_jb,
                                                    p_rc_month,
                                                    p_rc_org_list,
                                                    p_rc_tp,
                                                    p_kaot_ids,
                                                    p_nst_list);
    --uss_esr.API$ACCRUAL.mass_calc_accrual(p_rc_id, p_rc_jb, p_rc_month/*to_date(p_rc_month, 'DD.MM.YYYY')*/, p_rc_org_list);
    END;

    -- розрахунок перерахунку
    PROCEDURE bd_end_calc (p_rc_id       recalculates.rc_id%TYPE,
                           p_rc_jb   OUT recalculates.rc_jb%TYPE)
    IS
    BEGIN
        check_roles (p_rc_id, 'PROCESS');
        api$recalculates.process_rc (p_rc_id, p_rc_jb);
    END;


    -- Попередні масові нарахування
    PROCEDURE get_mass_calc_list (
        p_rc_id         IN     recalculates.rc_id%TYPE,
        p_rc_dt_start   IN     recalculates.rc_dt%TYPE,
        p_rc_dt_stop    IN     recalculates.rc_dt%TYPE,
        p_rc_month      IN     recalculates.rc_month%TYPE,
        p_rc_org_code   IN     recalculates.rc_org_list%TYPE,
        p_rc_tp         IN     recalculates.rc_tp%TYPE,
        res_cur            OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER := tools.GetCurrOrgTo;
        l_org      NUMBER := tools.getcurrorg;
        l_flag     NUMBER;
    BEGIN
        --raise_application_error(-20000, 'p_rc_tp='|| p_rc_tp );
        IF (p_rc_id IS NOT NULL AND l_org_to = 32)
        THEN
            SELECT COUNT (*)
              INTO l_flag
              FROM uss_esr.recalculates t
             WHERE     t.rc_id = p_rc_id
                   AND t.rc_tp IN ('S_VPO_51',
                                   'S_VPO_131',
                                   'S_VPO_133',
                                   'S_VPO_13_6',
                                   'PA_DN_18',
                                   'S_VPO_INC',
                                   'S_PAT_PAY');
        END IF;

        IF (       l_org_to = 32
               AND p_rc_tp IN ('S_VPO_51',
                               'S_VPO_131',
                               'S_VPO_133',
                               'PA_DN_18',
                               'S_VPO_13_6',
                               'S_VPO_INC',
                               'S_PAT_PAY')
            OR l_flag > 0)
        THEN
            OPEN res_cur FOR
                  SELECT rc_id,
                         com_org,
                         rc_hs_ins,
                         rc_month,
                         rc_dt,
                         rc_st,
                         rc_count,
                         rc_org_list,
                         rc_index,
                         rc_pc,
                         CASE
                             WHEN rc_tp = 'S_VPO_13_6' THEN 'S_VPO_133'
                             ELSE rc_tp
                         END
                             AS rc_tp,
                         rc_jb,
                         rc_hs_fix,
                         rc_kaot_list,
                         rc_nst_list,
                         hs.hs_dt
                             AS rc_hs_dt,
                         st.dic_name
                             AS rc_st_name,
                         tp.dic_name
                             AS rc_tp_name,
                         s.nst_code || ' ' || s.nst_name
                             AS rc_nst_name,
                         NVL (nrcc_cand_view_alg, 'PC')
                             AS rc_cand_view_alg,
                         NVL (nrcc_show_kaot_stat, 'F')
                             AS rc_show_kaot_stat,
                         NVL (nrcc_block_buttons32, 'F')
                             AS rc_block_buttons32,
                         NVL (nrcc_show_nst_filter, 'F')
                             AS rc_show_nst_filter,
                         NVL (nrcc_exec_alg, 'CND')
                             AS rc_exec_alg,
                         NVL (nrcc_show_index, 'F')
                             AS rc_show_index
                    FROM uss_esr.recalculates t
                         JOIN histsession hs ON (hs.hs_id = t.rc_hs_ins)
                         JOIN uss_ndi.v_ddn_rc_st st
                             ON (st.dic_value = t.rc_st)
                         JOIN uss_ndi.v_ddn_rc_tp tp
                             ON (tp.DIC_VALUE = t.rc_tp)
                         JOIN uss_ndi.v_ndi_rc_config nrcc
                             ON (rc_tp = nrcc_rc_tp)
                         LEFT JOIN uss_ndi.v_ndi_service_type s
                             ON (s.nst_id = t.rc_nst_list) -- поки тут завжди одна послуга буде
                   WHERE     t.rc_tp IN ('S_VPO_51',
                                         'S_VPO_131',
                                         'S_VPO_133',
                                         'PA_DN_18',
                                         'S_VPO_13_6',
                                         'S_VPO_INC',
                                         'S_PAT_PAY')
                         AND (p_rc_id IS NULL OR t.rc_id = p_rc_id)
                         AND (   (    p_rc_dt_start IS NULL
                                  AND p_rc_dt_stop IS NOT NULL
                                  AND t.rc_dt <= p_rc_dt_stop)
                              OR (    p_rc_dt_start IS NOT NULL
                                  AND p_rc_dt_stop IS NULL
                                  AND t.rc_dt >= p_rc_dt_start)
                              OR (    p_rc_dt_start IS NOT NULL
                                  AND p_rc_dt_stop IS NOT NULL
                                  AND t.rc_dt BETWEEN p_rc_dt_start
                                                  AND p_rc_dt_stop)
                              OR (    p_rc_dt_start IS NULL
                                  AND p_rc_dt_stop IS NULL
                                  AND 1 = 1))
                         AND (p_rc_month IS NULL OR t.rc_month = p_rc_month)
                         AND (p_rc_tp IS NULL OR t.rc_tp = p_rc_tp)
                         AND t.rc_org_list LIKE '%' || l_org || '%'
                ORDER BY rc_hs_ins DESC;
        ELSE
            OPEN res_cur FOR
                  SELECT rc_id,
                         com_org,
                         rc_hs_ins,
                         rc_month,
                         rc_dt,
                         rc_st,
                         rc_count,
                         rc_org_list,
                         rc_pc,
                         CASE
                             WHEN rc_tp = 'S_VPO_13_6' THEN 'S_VPO_133'
                             ELSE rc_tp
                         END
                             AS rc_tp,
                         rc_jb,
                         rc_hs_fix,
                         rc_kaot_list,
                         rc_nst_list,
                         rc_index,
                         hs.hs_dt
                             AS rc_hs_dt,
                         st.dic_name
                             AS rc_st_name,
                         tp.dic_name
                             AS rc_tp_name,
                         s.nst_code || ' ' || s.nst_name
                             AS rc_nst_name,
                         NVL (nrcc_cand_view_alg, 'PC')
                             AS rc_cand_view_alg,
                         NVL (nrcc_show_kaot_stat, 'F')
                             AS rc_show_kaot_stat,
                         NVL (nrcc_block_buttons32, 'F')
                             AS rc_block_buttons32,
                         NVL (nrcc_show_nst_filter, 'F')
                             AS rc_show_nst_filter,
                         NVL (nrcc_exec_alg, 'CND')
                             AS rc_exec_alg,
                         NVL (nrcc_show_index, 'F')
                             AS rc_show_index
                    FROM uss_esr.v_recalculates t
                         JOIN histsession hs ON (hs.hs_id = t.rc_hs_ins)
                         JOIN uss_ndi.v_ddn_rc_st st
                             ON (st.dic_value = t.rc_st)
                         JOIN uss_ndi.v_ddn_rc_tp tp
                             ON (tp.DIC_VALUE = t.rc_tp)
                         JOIN uss_ndi.v_ndi_rc_config nrcc
                             ON (rc_tp = nrcc_rc_tp)
                         LEFT JOIN uss_ndi.v_ndi_service_type s
                             ON (s.nst_id = t.rc_nst_list) -- поки тут завжди одна послуга буде
                   WHERE     t.rc_tp IN ('M',
                                         'BD_END',
                                         'TMP_WO_DN',
                                         'S_VPO_18',
                                         'S_VPO_REF',
                                         'S_EXT_VS',
                                         'S_MF_STOP',
                                         'S_ODEATH',
                                         'S_EXT_2NST',
                                         'S_LGW_CHNG',
                                         'S_VPO_51',
                                         'S_VPO_30_2',
                                         'S_VPO_131',
                                         'S_VPO_133',
                                         'PA_DN_18',
                                         'S_VPO_13_6',
                                         'S_VPO_INC',
                                         'S_PAT_PAY',
                                         'S_VPO_INV',
                                         'INDEX_VF')
                         AND (p_rc_id IS NULL OR t.rc_id = p_rc_id)
                         AND (   (    p_rc_dt_start IS NULL
                                  AND p_rc_dt_stop IS NOT NULL
                                  AND t.rc_dt <= p_rc_dt_stop)
                              OR (    p_rc_dt_start IS NOT NULL
                                  AND p_rc_dt_stop IS NULL
                                  AND t.rc_dt >= p_rc_dt_start)
                              OR (    p_rc_dt_start IS NOT NULL
                                  AND p_rc_dt_stop IS NOT NULL
                                  AND t.rc_dt BETWEEN p_rc_dt_start
                                                  AND p_rc_dt_stop)
                              OR (    p_rc_dt_start IS NULL
                                  AND p_rc_dt_stop IS NULL
                                  AND 1 = 1))
                         AND (p_rc_month IS NULL OR t.rc_month = p_rc_month)
                         AND (p_rc_tp IS NULL OR t.rc_tp = p_rc_tp)
                         AND (   p_rc_org_code IS NULL
                              OR t.rc_org_list LIKE p_rc_org_code)
                ORDER BY rc_hs_ins DESC;
        END IF;
    END;

    -- Картка масового нарахування
    PROCEDURE get_mass_calc_card (
        p_rc_id                 IN     recalculates.rc_id%TYPE,
        p_org_id                IN     NUMBER,
        p_pc_num                IN     VARCHAR2,
        p_is_payroll_included   IN     VARCHAR2,
        p_rc_kaot               IN     NUMBER,
        res_cur                    OUT SYS_REFCURSOR)
    IS
        l_only100   NUMBER
            := CASE
                   WHEN p_org_id IS NULL AND p_pc_num IS NULL THEN 1
                   ELSE 0
               END;
        l_rc_tp     VARCHAR2 (10);
    BEGIN
        SELECT MAX (t.rc_tp)
          INTO l_rc_tp
          FROM recalculates t
         WHERE t.rc_id = p_rc_id;

        -- #79922: BD_END - список справ в rc_candidates буде знаходитись;
        IF (l_rc_tp <> 'M')
        THEN
            OPEN res_cur FOR
                  SELECT t.*,
                         pc.pc_id,
                         pc.pc_num,
                         uss_person.api$sc_tools.GET_PIB (
                             pc.pc_sc)                      AS pib,
                         uss_person.api$sc_tools.GET_PIB (
                             t.rcc_sc)                      AS pib_rcc,
                         (SELECT dic_name
                            FROM uss_ndi.v_ddn_rcc_st z
                           WHERE z.dic_value = t.rcc_st)    AS ac_st_name,
                         d.pd_num,
                         (SELECT MAX (nst_name)
                            FROM uss_ndi.v_ndi_service_type z
                           WHERE nst_Id = d.pd_nst)         AS nst_name
                    FROM rc_candidates t
                         JOIN personalcase pc ON (pc.pc_id = t.rcc_pc)
                         LEFT JOIN pc_decision d ON (d.pd_id = t.rcc_pd)
                   WHERE     t.rcc_rc = p_rc_id
                         -- AND (p_org_id IS NULL OR t.com_org = p_org_id)
                         AND (   p_pc_num IS NULL
                              OR pc.pc_num LIKE p_pc_num || '%')
                         AND (l_only100 = 1 AND ROWNUM <= 100 OR l_only100 = 0)
                         AND (p_rc_kaot IS NULL OR t.rcc_kaot = p_rc_kaot)
                ORDER BY pib;

            RETURN;
        END IF;

        OPEN res_cur FOR
              SELECT t.*,
                     pc.pc_id,
                     pc.pc_num,
                     uss_person.api$sc_tools.GET_PIB (pc.pc_sc)
                         AS pib,
                     (SELECT dic_name
                        FROM uss_ndi.v_ddn_ac_st
                       WHERE ac_st = dic_value)
                         AS ac_st_name,
                     (SELECT CASE WHEN COUNT (*) > 0 THEN 'T' ELSE 'F' END
                        FROM DUAL
                       WHERE EXISTS
                                 (SELECT *
                                    FROM ac_detail zd
                                   WHERE     zd.acd_ac = t.ac_id
                                         AND (   zd.acd_prsd IS NOT NULL
                                              OR zd.acd_imp_pr_num IS NOT NULL)))
                         AS is_payroll_included
                FROM v_accrual_by_pc t
                     JOIN v_personalcase pc ON (pc.pc_id = t.ac_pc)
               WHERE     t.ac_rc = p_rc_id
                     AND (p_org_id IS NULL OR t.com_org = p_org_id)
                     AND (p_pc_num IS NULL OR pc.pc_num LIKE p_pc_num || '%')
                     AND (l_only100 = 1 AND ROWNUM <= 100 OR l_only100 = 0)
                     AND (   p_is_payroll_included = 'F'
                          OR     p_is_payroll_included = 'T'
                             AND EXISTS
                                     (SELECT *
                                        FROM ac_detail zd
                                       WHERE     zd.acd_ac = t.ac_id
                                             AND (   zd.acd_prsd IS NOT NULL
                                                  OR zd.acd_imp_pr_num
                                                         IS NOT NULL)))
            ORDER BY pib;
    END;

    -- #99137 ознаки
    PROCEDURE get_card_features (p_rcc_id   IN     NUMBER,
                                 res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*, at.nda_name, at.nda_can_edit
              FROM rc_candidate_attr  t
                   JOIN uss_ndi.v_ndi_document_attr at
                       ON (at.nda_id = t.rcca_nda)
             WHERE t.rcca_rcc = p_rcc_id;
    END;

    -- #85753: Статистика по КАТОТТГ
    PROCEDURE get_mass_calc_card_kaot_stat (p_rc_id   IN     NUMBER,
                                            res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   RTRIM (
                          CASE
                              WHEN     l1_name IS NOT NULL
                                   AND l1_name != temp_name
                              THEN
                                  l1_name || ', '
                          END
                       || CASE
                              WHEN     l2_name IS NOT NULL
                                   AND l2_name != temp_name
                              THEN
                                  l2_name || ', '
                          END
                       || CASE
                              WHEN     l3_name IS NOT NULL
                                   AND l3_name != temp_name
                              THEN
                                  l3_name || ', '
                          END
                       || CASE
                              WHEN     l4_name IS NOT NULL
                                   AND l4_name != temp_name
                              THEN
                                  l4_name || ', '
                          END
                       || CASE
                              WHEN     l5_name IS NOT NULL
                                   AND l5_name != temp_name
                              THEN
                                  l5_name || ', '
                          END
                       || temp_name,
                       ',')    AS kaot_name
              FROM (  SELECT m.kaot_id,
                             m.kaot_name    AS temp_name,
                             CASE
                                 WHEN Kaot_Kaot_L1 = Kaot_Id
                                 THEN
                                     Kaot_Name
                                 ELSE
                                     (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                        FROM uss_ndi.v_Ndi_Katottg X1,
                                             uss_ndi.v_Ddn_Kaot_Tp
                                       WHERE     X1.Kaot_Id = m.Kaot_Kaot_L1
                                             AND Kaot_Tp = Dic_Value)
                             END            AS l1_name,
                             CASE
                                 WHEN Kaot_Kaot_L2 = Kaot_Id
                                 THEN
                                     Kaot_Name
                                 ELSE
                                     (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                        FROM uss_ndi.v_Ndi_Katottg X1,
                                             uss_ndi.v_Ddn_Kaot_Tp
                                       WHERE     X1.Kaot_Id = m.Kaot_Kaot_L2
                                             AND Kaot_Tp = Dic_Value)
                             END            AS l2_name,
                             CASE
                                 WHEN Kaot_Kaot_L3 = Kaot_Id
                                 THEN
                                     Kaot_Name
                                 ELSE
                                     (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                        FROM uss_ndi.v_Ndi_Katottg X1,
                                             uss_ndi.v_Ddn_Kaot_Tp
                                       WHERE     X1.Kaot_Id = m.Kaot_Kaot_L3
                                             AND Kaot_Tp = Dic_Value)
                             END            AS l3_name,
                             CASE
                                 WHEN Kaot_Kaot_L4 = Kaot_Id
                                 THEN
                                     Kaot_Name
                                 ELSE
                                     (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                        FROM uss_ndi.v_Ndi_Katottg X1,
                                             uss_ndi.v_Ddn_Kaot_Tp
                                       WHERE     X1.Kaot_Id = m.Kaot_Kaot_L4
                                             AND Kaot_Tp = Dic_Value)
                             END            AS l4_name,
                             CASE
                                 WHEN Kaot_Kaot_L5 = Kaot_Id
                                 THEN
                                     Kaot_Name
                                 ELSE
                                     (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                        FROM uss_ndi.v_Ndi_Katottg X1,
                                             uss_ndi.v_Ddn_Kaot_Tp
                                       WHERE     X1.Kaot_Id = m.Kaot_Kaot_L5
                                             AND Kaot_Tp = Dic_Value)
                             END            AS l5_name,
                             COUNT (*)      AS rc_cnt
                        FROM rc_candidates t
                             JOIN uss_ndi.v_ndi_katottg m
                                 ON (m.kaot_id = t.rcc_kaot)
                       WHERE t.rcc_rc = p_rc_id
                    GROUP BY m.kaot_id,
                             m.kaot_name,
                             m.kaot_kaot_l1,
                             m.kaot_kaot_l2,
                             m.kaot_kaot_l3,
                             m.kaot_kaot_l4,
                             m.kaot_kaot_l5) t;
    END;

    --Отримання даних попереднього розрахунку
    PROCEDURE get_prev_calc_accrual (p_pd_id           personalcase.pc_id%TYPE,
                                     p_accrual     OUT SYS_REFCURSOR,
                                     p_ac_detail   OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$ACCRUAL.prev_calc_accrual (p_pd_id);

        OPEN p_accrual FOR
            SELECT c_id
                       AS ac_id,
                   c_pc
                       AS ac_pc,
                   c_month
                       AS ac_month,
                   c_assign_sum
                       AS ac_assign_sum,
                   NULL
                       AS ac_idx_sum,
                   NULL
                       AS ac_tax_pdfo,
                   NULL
                       AS ac_tax_mil,
                   c_else_dn_sum
                       AS ac_else_dn_sum,
                   c_post_sum
                       AS ac_post_sum,
                   'E'
                       AS ac_st,
                   'A'
                       AS history_status,
                   c_delta_recalc
                       AS ac_delta_recalc,
                   c_delta_pay
                       AS ac_delta_pay,
                   NULL
                       AS ac_payed_sum,
                   TO_CHAR (c_month,
                            'YYYY month',
                            'NLS_DATE_LANGUAGE=UKRAINIAN')
                       AS ac_period,
                   ADD_MONTHS (c_month, 1) - c_month
                       AS ac_days_count,
                   (SELECT dic_name
                      FROM uss_ndi.v_ddn_ac_st
                     WHERE dic_value = 'E')
                       AS ac_st_name
              FROM tmp_accrual;

        OPEN p_ac_detail FOR
            SELECT a_id
                       AS acd_id,
                   a_ac
                       AS acd_ac,
                   a_op
                       AS acd_op,
                   a_npt
                       AS acd_npt,
                   a_start_dt
                       AS acd_start_dt,
                   a_stop_dt
                       AS acd_stop_dt,
                   a_sum
                       AS acd_sum,
                   NULL
                       AS acd_idx_sum,
                   a_month_sum
                       AS acd_month_sum,
                   NULL
                       AS acd_idx_month_sum,
                   a_delta_recalc
                       AS acd_delta_recalc,
                   a_delta_pay
                       AS acd_delta_pay,
                   a_dn
                       AS acd_dn,
                   a_pd
                       AS acd_pd,
                   a_ac_start_dt
                       AS acd_ac_start_dt,
                   a_ac_stop_dt
                       AS acd_ac_stop_dt,
                   NULL
                       AS acd_is_indexed,
                   'E'
                       AS acd_st,
                   'A'
                       AS history_status,
                   NULL
                       AS acd_payed_sum,
                   (SELECT op_name
                      FROM uss_ndi.v_ndi_op
                     WHERE a_op = op_id)
                       AS acd_op_name,
                   (SELECT npt_name
                      FROM uss_ndi.v_ndi_payment_type
                     WHERE a_npt = npt_id)
                       AS acd_npt_name,
                   (SELECT npt_code
                      FROM uss_ndi.v_ndi_payment_type
                     WHERE a_npt = npt_id)
                       AS acd_npt_code,
                   a_stop_dt - a_start_dt + 1
                       AS acd_days_count,
                   (SELECT dpp_name
                      FROM uss_ndi.v_ndi_pay_person, deduction
                     WHERE a_dn = dn_id AND dn_dpp = dpp_id)
                       AS acd_dn_name,
                   (SELECT pd_num
                      FROM pc_decision
                     WHERE a_pd = pd_id)
                       AS acd_pd_num,
                   (SELECT dic_name
                      FROM uss_ndi.v_ddn_ac_st
                     WHERE dic_value = 'E')
                       AS acd_st_name
              FROM tmp_ac_detail t;
    END;

    --Статистика по нарахуванням
    PROCEDURE get_accual_stats (p_month               accrual.ac_month%TYPE,
                                p_org                 accrual.com_org%TYPE,
                                p_nst                 pc_decision.pd_nst%TYPE,
                                p_by_nis              VARCHAR2 DEFAULT 'F', -- #80574 OPERVIEIEV поглиблена до дільниць
                                p_accrual_stats   OUT SYS_REFCURSOR)
    IS
        l_user_type   VARCHAR2 (250);
        l_bp_class    billing_period.bp_class%TYPE;
    BEGIN
        l_user_type :=
            SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gUserTP);
        l_bp_class := CASE WHEN l_user_type = '41' THEN 'VPO' ELSE 'V' END;

        calc$payroll.init_com_orgs (NULL);                           -- #80574

        IF p_by_nis = 'F'
        THEN                                                       -- OLD CODE
            INSERT INTO tmp_accrual_stats (tas_org, tas_nst)
                SELECT org_id, nst_id
                  FROM v_opfu, uss_ndi.v_ndi_service_type
                 WHERE     org_org = p_org                           --Область
                       AND (   (    l_bp_class = 'VPO'
                                AND org_id IN (SELECT u_org FROM tmp_org))
                            OR org_id IN (SELECT x_id FROM tmp_com_orgs)) -- #80146 OPERVIEIEV
                       AND org_to = 32                                --Райони
                       AND nst_id IN
                               (SELECT ncc_nst
                                  FROM uss_ndi.v_ndi_nst_calc_config
                                 WHERE ncc_nst = p_nst OR NVL (p_nst, 0) = 0);

            UPDATE tmp_accrual_stats
               SET tas_pc_cnt =
                       (SELECT COUNT (DISTINCT pd_pc)
                          FROM pc_decision x
                         WHERE     pd_nst = tas_nst
                               AND x.com_org = tas_org
                               AND (   (    pd_start_dt <= LAST_DAY (p_month)
                                        AND pd_stop_dt >= p_month)
                                    OR pd_start_dt IS NULL)
                               AND pd_st NOT IN ('V')),
                   tas_pd_s_cnt =
                       (SELECT COUNT (DISTINCT pd_pc)
                          FROM pc_decision x
                         WHERE     pd_nst = tas_nst
                               AND x.com_org = tas_org
                               AND pd_start_dt <= LAST_DAY (p_month)
                               AND pd_stop_dt >= p_month
                               AND pd_st IN ('S')),
                   tas_pd_w_cnt =
                       (SELECT COUNT (DISTINCT pd_pc)
                          FROM pc_decision x
                         WHERE     pd_nst = tas_nst
                               AND x.com_org = tas_org
                               -- 20220804: Тетяна Д. тому треба рахувати кількість рішень "в роботі" взагалі не обмежуючись місяцем
                               --AND pd_start_dt <= LAST_DAY(p_month) AND pd_stop_dt >= p_month
                               AND pd_st NOT IN ('S', 'V')),
                   tas_ac_cnt =
                       (SELECT COUNT (DISTINCT ac_pc)
                          FROM accrual x, ac_detail, uss_ndi.v_ndi_npt_config
                         WHERE     x.com_org = tas_org
                               AND acd_ac = ac_id
                               --AND acd_op = 1
                               AND acd_op NOT BETWEEN 278 AND 284
                               AND acd_npt = nptc_npt
                               AND nptc_nst = tas_nst
                               AND ac_month = p_month
                               AND ac_detail.history_status = 'A'),
                   tas_ac_R_cnt =
                       (SELECT COUNT (DISTINCT ac_pc)
                          FROM accrual x, ac_detail, uss_ndi.v_ndi_npt_config
                         WHERE     x.com_org = tas_org
                               AND acd_ac = ac_id
                               --AND acd_op = 1
                               AND acd_op NOT BETWEEN 278 AND 284
                               AND acd_npt = nptc_npt
                               AND nptc_nst = tas_nst
                               AND ac_month = p_month
                               AND ac_st IN
                                       ('R',
                                        DECODE (l_bp_class, 'V', 'RV', 'RP'))
                               AND ac_detail.history_status = 'A'),
                   tas_ac_P_cnt =
                       (SELECT COUNT (DISTINCT prs_pc)    -- #80597 OPERVIEIEV
                          FROM pr_sheet  prs,
                               payroll   pr,
                               pr_sheet_detail,
                               uss_ndi.v_ndi_npt_config
                         WHERE     pr.com_org = tas_org
                               AND NVL (prs_st, 'NA') = 'NA'
                               AND prs_pr = pr_id
                               AND pr_month = p_month
                               AND prsd_prs = prs_id
                               AND nptc_npt = prsd_npt
                               AND nptc_nst = tas_nst)
             WHERE 1 = 1;
        ELSE                                               -- rewritten #80574
            INSERT INTO tmp_accrual_stats (tas_org, tas_nst, tas_nis) -- для невизначених дільниць / користувачів
                SELECT org_id, ncc_nst, 0
                  FROM v_opfu  v
                       JOIN uss_ndi.v_ndi_nst_calc_config
                           ON ncc_nst = p_nst OR NVL (p_nst, 0) = 0
                 WHERE     org_org = p_org
                       AND org_to = 32
                       AND (   l_user_type = '41'
                            OR org_id IN (SELECT x_id FROM tmp_com_orgs))
                UNION                    -- для існуючих дільниць по довіднику
                SELECT org_id, ncc_nst, nis_id
                  FROM v_opfu  v
                       JOIN uss_ndi.v_ndi_nst_calc_config
                           ON ncc_nst = p_nst OR NVL (p_nst, 0) = 0
                       JOIN uss_ndi.v_ndi_site nis ON nis.com_org = v.org_id
                 WHERE     org_org = p_org
                       AND org_to = 32
                       AND (   l_user_type = '41'
                            OR org_id IN (SELECT x_id FROM tmp_com_orgs));

            UPDATE tmp_accrual_stats
               SET tas_pc_cnt =
                       (SELECT COUNT (DISTINCT pd_pc)
                          FROM pc_decision  x
                               LEFT JOIN uss_ndi.v_ndi_nis_users nisu
                                   ON x.com_wu = nisu.nisu_wu
                         WHERE     pd_nst = tas_nst
                               AND x.com_org = tas_org
                               AND NVL (tas_nis, 0) = NVL (nisu_nis, 0)
                               AND (   (    pd_start_dt <= LAST_DAY (p_month)
                                        AND pd_stop_dt >= p_month)
                                    OR pd_start_dt IS NULL)
                               AND pd_st NOT IN ('V')),
                   tas_pd_s_cnt =
                       (SELECT COUNT (DISTINCT pd_pc)
                          FROM pc_decision  x
                               LEFT JOIN uss_ndi.v_ndi_nis_users nisu
                                   ON x.com_wu = nisu.nisu_wu
                         WHERE     pd_nst = tas_nst
                               AND x.com_org = tas_org
                               AND NVL (tas_nis, 0) = NVL (nisu_nis, 0)
                               AND pd_start_dt <= LAST_DAY (p_month)
                               AND pd_stop_dt >= p_month
                               AND pd_st IN ('S')),
                   tas_pd_w_cnt =
                       (SELECT COUNT (DISTINCT pd_pc)
                          FROM pc_decision  x
                               LEFT JOIN uss_ndi.v_ndi_nis_users nisu
                                   ON x.com_wu = nisu.nisu_wu
                         WHERE     pd_nst = tas_nst
                               AND x.com_org = tas_org
                               AND NVL (tas_nis, 0) = NVL (nisu_nis, 0)
                               AND pd_st NOT IN ('S', 'V')),
                   tas_ac_cnt =
                       (SELECT COUNT (DISTINCT ac_pc)
                          FROM accrual  x
                               JOIN ac_detail acd ON acd_ac = ac_id
                               JOIN pc_decision pd ON pd_id = acd_pd
                               JOIN uss_ndi.v_ndi_npt_config
                                   ON acd_npt = nptc_npt
                               LEFT JOIN uss_ndi.v_ndi_nis_users nisu
                                   ON pd.com_wu = nisu.nisu_wu
                         WHERE     x.com_org = tas_org
                               AND acd_op NOT BETWEEN 278 AND 284
                               AND nptc_nst = tas_nst
                               AND NVL (tas_nis, 0) = NVL (nisu_nis, 0)
                               AND ac_month = p_month
                               AND acd.history_status = 'A'),
                   tas_ac_R_cnt =
                       (SELECT COUNT (DISTINCT ac_pc)
                          FROM accrual  x
                               JOIN ac_detail acd ON acd_ac = ac_id
                               JOIN pc_decision pd ON pd_id = acd_pd
                               JOIN uss_ndi.v_ndi_npt_config
                                   ON acd_npt = nptc_npt
                               LEFT JOIN uss_ndi.v_ndi_nis_users nisu
                                   ON pd.com_wu = nisu.nisu_wu
                         WHERE     x.com_org = tas_org
                               AND acd_op NOT BETWEEN 278 AND 284
                               AND nptc_nst = tas_nst
                               AND NVL (tas_nis, 0) = NVL (nisu_nis, 0)
                               AND ac_month = p_month
                               AND ac_st IN
                                       ('R',
                                        DECODE (l_bp_class, 'V', 'RV', 'RP'))
                               AND acd.history_status = 'A');

            IF p_by_nis = 'T'
            THEN                --  штатний параметр "розбиваємо по дільницям"
                UPDATE tmp_accrual_stats
                   SET tas_ac_P_cnt =
                           (SELECT COUNT (DISTINCT prs_pc)
                              FROM pr_sheet  prs
                                   JOIN payroll pr ON prs_pr = pr_id
                                   JOIN pr_sheet_detail prsd
                                       ON prsd_prs = prs_id
                                   JOIN ac_detail acd
                                       ON     acd_prsd = prsd_id
                                          AND acd_op NOT BETWEEN 278 AND 284
                                          AND acd.history_status = 'A'
                                   JOIN pc_decision pd ON acd_pd = pd_id
                                   JOIN uss_ndi.v_ndi_npt_config
                                       ON nptc_npt = prsd_npt
                                   LEFT JOIN uss_ndi.v_ndi_nis_users nisu
                                       ON pd.com_wu = nisu.nisu_wu
                             WHERE     pr.com_org = tas_org
                                   AND nptc_nst = tas_nst
                                   AND NVL (tas_nis, 0) = NVL (nisu_nis, 0)
                                   AND pr_month = p_month
                                   AND NVL (prs_st, 'NA') = 'NA');
            ELSE
                -- якщо попередній запит вб'є швидкодію (а він вб'є)
                -- є варіант примусово відносити рядки ВВ до НЕВИЗНАЧЕНОЇ дільниці
                UPDATE tmp_accrual_stats
                   SET tas_ac_P_cnt =
                           (SELECT COUNT (DISTINCT prs_pc)
                              FROM pr_sheet  prs,
                                   payroll   pr,
                                   pr_sheet_detail,
                                   uss_ndi.v_ndi_npt_config
                             WHERE     pr.com_org = tas_org
                                   AND NVL (prs_st, 'NA') = 'NA'
                                   AND prs_pr = pr_id
                                   AND pr_month = p_month
                                   AND prsd_prs = prs_id
                                   AND prsd_npt = nptc_npt
                                   AND nptc_nst = tas_nst)
                 -- а ще краще приховати цю колонку для варіанту форми "з дільницями"
                 WHERE tas_nis = 0;
            END IF;
        END IF;                                                    -- p_by_nis

        OPEN p_accrual_stats FOR
            SELECT tas_org,
                   tas_nst,
                   tas_pc_cnt,
                   tas_pd_s_cnt,
                   tas_pd_w_cnt,
                   tas_ac_cnt,
                   tas_ac_r_cnt,
                   org_name,
                   nst_name,
                   tas_nis,
                   nis_name,
                   tas_ac_p_cnt
              FROM tmp_accrual_stats
                   JOIN v_opfu ON tas_org = org_id
                   JOIN uss_ndi.v_ndi_service_type ON tas_nst = nst_id
                   LEFT JOIN uss_ndi.v_ndi_site ON tas_nis = nis_id;
    END get_accual_stats;

    -- #78829 Звіт "Стан рішень" ALL-IN-ONE OPERVIEIEV 07.2022
    PROCEDURE get_pd_stats (p_month          accrual.ac_month%TYPE,
                            p_org            accrual.com_org%TYPE, -- очикуємо обласний рівень
                            p_nst            pc_decision.pd_nst%TYPE, -- 0 або NULL означає "всі"
                            p_type    IN     VARCHAR2, -- тип групування   "MAIN" - "Не групувати", "ORG" - "За регіоном", "NST" - "За послугою"
                            res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            WITH
                tmp_pd_stat
                AS
                    ( --  агреговані дані де "стани рішень" є полем групування (розкидані по рядках)
                       SELECT NVL (pd.com_org, 0)        tpds_org, -- фактичний підрозділ рішення
                              NVL (o.org_obl, 0)         tpds_org_obl,
                              TRUNC (pd.pd_dt, 'MM')     tpds_month,
                              pd.pd_nst                  tpds_nst,
                              pd.pd_st                   tpds_st,
                              COUNT (*)                  tpds_cnt,
                              SUM (pdp.pdp_sum)          tpds_sum
                         FROM pc_decision pd
                              JOIN pd_payment pdp
                                  ON     pdp.pdp_pd = pd.pd_id
                                     AND pdp.history_status = 'A'
                              LEFT JOIN
                              (SELECT p.org_id      porg_id,
                                      p.org_name    porg_name,
                                      p.org_to      porg_to,
                                      d.org_id,
                                      d.org_name,
                                      d.org_to,
                                      CASE
                                          WHEN d.org_to = 31
                                          THEN
                                              d.org_id
                                          WHEN p.org_to = 31
                                          THEN
                                              p.org_id
                                          WHEN    NVL (d.org_to, 40) = 40
                                               OR NVL (p.org_to, 30) = 30
                                          THEN
                                              50001
                                      END           org_obl -- обласний рівень
                                 FROM v_opfu_esr d
                                      JOIN v_opfu_esr p ON d.org_org = p.org_id
                                WHERE        /*d.org_st='A' and p.org_st='A'*/
                                      1 = 1) o
                                  ON pd.com_org = o.org_id
                        WHERE     pd_dt BETWEEN TRUNC (p_month, 'MM')
                                            AND LAST_DAY (p_month) -- ОСНОВНИЙ ОБОВЯЗКОВИЙ ФІЛЬТР
                              --            AND o.org_id IN ( SELECT u_org FROM tmp_org ) -- Тільки те, що доступно користувачу, ХТО ЦЕ ІНІЦІАЛІЗУЄ ?
                              AND (o.org_obl = p_org OR NVL (p_org, 0) = 0)
                              AND (pd.pd_nst = p_nst OR NVL (p_nst, 0) = 0)
                     GROUP BY NVL (pd.com_org, 0),
                              NVL (o.org_obl, 0),
                              TRUNC (pd.pd_dt, 'MM'),
                              pd.pd_nst,
                              pd.pd_st) -- тут ми робимо PIVOT по станам рішень і враховуємо тип групування
              SELECT tpds_month,
                     DECODE (p_type, 'ORG', 0, tpds_nst)
                         tpds_nst,
                     DECODE (p_type, 'ORG', 'X', nst_name)
                         nst_name,                     -- адаптивне групування
                     DECODE (p_type, 'NST', 0, tpds_org)
                         tpds_org,
                     DECODE (p_type, 'NST', 0, tpds_org_obl)
                         tpds_org_olb,
                     DECODE (p_type, 'NST', 'X', d.org_name)
                         org_name,
                     DECODE (p_type, 'NST', 'X', o.org_name)
                         obl_name,               -- схлопуємо якщо не потрібне
                     SUM (CASE
                              WHEN tpds_st IN ('R0',
                                               'R1',
                                               'WD',
                                               'K',
                                               'W',
                                               'E')
                              THEN
                                  tpds_sum
                              ELSE
                                  0
                          END)
                         wrk_sum,
                     SUM (CASE
                              WHEN tpds_st IN ('R0',
                                               'R1',
                                               'WD',
                                               'K',
                                               'W',
                                               'E')
                              THEN
                                  tpds_cnt
                              ELSE
                                  0
                          END)
                         wrk_cnt,                                  -- В роботі
                     SUM (CASE WHEN tpds_st IN ('P') THEN tpds_sum ELSE 0 END)
                         priz_sum,
                     SUM (CASE WHEN tpds_st IN ('P') THEN tpds_cnt ELSE 0 END)
                         priz_cnt,                               -- Призначено
                     SUM (CASE WHEN tpds_st IN ('V') THEN tpds_sum ELSE 0 END)
                         vidm_sum,
                     SUM (CASE WHEN tpds_st IN ('V') THEN tpds_cnt ELSE 0 END)
                         vidm_cnt,                               -- Відмовлено
                     SUM (CASE WHEN tpds_st IN ('R2') THEN tpds_sum ELSE 0 END)
                         pidt_sum,
                     SUM (CASE WHEN tpds_st IN ('R2') THEN tpds_cnt ELSE 0 END)
                         pidt_cnt,                             -- Підтверджено
                     SUM (CASE WHEN tpds_st IN ('S') THEN tpds_sum ELSE 0 END)
                         done_sum,
                     SUM (CASE WHEN tpds_st IN ('S') THEN tpds_cnt ELSE 0 END)
                         done_cnt,                                   -- Діючих
                     SUM (CASE WHEN tpds_st IN ('PS') THEN tpds_sum ELSE 0 END)
                         susp_sum,
                     SUM (CASE WHEN tpds_st IN ('PS') THEN tpds_cnt ELSE 0 END)
                         susp_cnt,                              -- Призупинено
                     -- всі ПІДЗВІТНІ статуси, не всі по базі ! -- select dic_code, dic_name from uss_ndi.V_DDN_PD_ST -- BTW
                     SUM (CASE
                              WHEN tpds_st IN ('R0',
                                               'R1',
                                               'R2',
                                               'WD',
                                               'K',
                                               'W',
                                               'E',
                                               'P',
                                               'V',
                                               'S',
                                               'PS')
                              THEN
                                  tpds_sum
                              ELSE
                                  0
                          END)
                         all_sum,
                     SUM (CASE
                              WHEN tpds_st IN ('R0',
                                               'R1',
                                               'R2',
                                               'WD',
                                               'K',
                                               'W',
                                               'E',
                                               'P',
                                               'V',
                                               'S',
                                               'PS')
                              THEN
                                  tpds_cnt
                              ELSE
                                  0
                          END)
                         all_cnt
                FROM tmp_pd_stat pd
                     JOIN uss_ndi.v_ndi_service_type nst
                         ON tpds_nst = nst.nst_id
                     JOIN v_opfu_esr d ON d.org_id = tpds_org
                     JOIN v_opfu_esr o ON o.org_id = tpds_org_obl
            GROUP BY tpds_month,
                     DECODE (p_type, 'ORG', 0, tpds_nst),
                     DECODE (p_type, 'ORG', 'X', nst_name),
                     DECODE (p_type, 'NST', 0, tpds_org),
                     DECODE (p_type, 'NST', 0, tpds_org_obl),
                     DECODE (p_type, 'NST', 'X', d.org_name),
                     DECODE (p_type, 'NST', 'X', o.org_name);
    END get_pd_stats;

    -- #85493: Відчепити від масс.перерахунку
    PROCEDURE unhook_ac_from_rc (p_rc_id IN NUMBER, p_ac_id IN NUMBER)
    IS
    BEGIN
        API$RECALCULATES.unhook_ac_from_rc (p_rc_id, p_ac_id);
    END;

    -- #90319
    PROCEDURE change_acd_period (p_acd_id         IN NUMBER,
                                 p_acd_start_dt   IN DATE,
                                 p_acd_stop_dt    IN DATE)
    IS
        l_row   ac_detail%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_row
          FROM ac_detail t
         WHERE t.acd_id = p_acd_id;

        IF (l_row.ACD_IMP_PR_NUM IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Заборонено редагувати запис, який не був виплаченим в АСОПД');
        END IF;

        IF (   p_acd_start_dt IS NULL
            OR TRUNC (p_acd_start_dt, 'MM') !=
               TRUNC (l_row.acd_start_dt, 'MM'))
        THEN
            raise_application_error (
                -20000,
                'Дату початку можна змінити лише в межах місяця!');
        END IF;

        IF (   p_acd_stop_dt IS NULL
            OR TRUNC (p_acd_stop_dt, 'MM') != TRUNC (l_row.acd_stop_dt, 'MM'))
        THEN
            raise_application_error (
                -20000,
                'Дату закынчення можна змінити лише в межах місяця!');
        END IF;

        UPDATE ac_detail t
           SET t.acd_start_dt = p_acd_start_dt, t.acd_stop_dt = p_acd_stop_dt
         WHERE t.acd_id = p_acd_id;
    END;


    --Знак для іду операції
    FUNCTION xsign (p_op_id NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        RETURN api$accrual.xsign (p_op_id);
    END;

    PROCEDURE reset_rcca_value (p_rcca_id rc_candidate_attr.rcca_id%TYPE)
    IS
    BEGIN
        API$PD_OPERATIONS.reset_rcca_value (p_rcca_id);
    END;

    -- #117351
    PROCEDURE check_post_index (p_npo_Id IN NUMBER, p_rc_id OUT NUMBER)
    IS
        l_rc_jb   NUMBER;
        l_idx     VARCHAR2 (10);
    BEGIN
        SELECT t.npo_index
          INTO l_idx
          FROM uss_ndi.v_ndi_post_office t
         WHERE t.npo_id = p_npo_Id;

        uss_esr.API$RECALCULATES.mass_calc_accrual (
            p_rc_id         => p_rc_id,
            p_rc_jb         => l_rc_jb,
            p_rc_month      => TRUNC (SYSDATE, 'MM'),
            p_rc_org_list   => NULL,
            p_rc_tp         => 'INDEX_VF',
            p_rc_index      => l_idx);
    END;
BEGIN
    -- Initialization
    NULL;
END DNET$ACCRUAL;
/