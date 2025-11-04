/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CALC$PAYROLL
IS
    -- Author  : VANO
    -- Created : 22.07.2021 9:24:22
    -- Purpose : Розрахунок виплатних відомостей

    g_TraceMsgEnabled   INTEGER := 1;

    PROCEDURE create_payroll (
        p_tp          payroll.pr_tp%TYPE,
        p_org         payroll.com_org%TYPE,
        p_month       DATE,
        p_day_start   INTEGER,
        p_day_stop    INTEGER,
        p_pay_tp      VARCHAR2,
        p_npc         NUMBER,
        p_pe_code     USS_NDI.v_ddn_pe_code.DIC_VALUE%TYPE DEFAULT '1' -- Режим створення #79218 OPERVIEIEV 08.2022
                                                                      );

    PROCEDURE fix_payroll (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE approve_payroll (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE send_payroll (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE make_payroll_reestr (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE delete_payroll (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE unfix_payroll (p_pr_id payroll.pr_id%TYPE);

    --Отримання серії та номеру паспорту з документів звернення
    FUNCTION get_pasp_info (p_mode INTEGER, p_ap appeal.ap_id%TYPE)
        RETURN VARCHAR2;

    FUNCTION get_fuctionary (p_org NUMBER, p_tp VARCHAR2)
        RETURN VARCHAR2;

    -- #80146 OPERVIEIEV новая идеология доступности ОСЗН (и новая табличка TMP_COM_ORGS)
    PROCEDURE init_com_orgs (p_org              NUMBER,
                             p_user_org_force   NUMBER DEFAULT NULL /*for test*/
                                                                   );

    PROCEDURE init_access_params;

    PROCEDURE SaveTraceMsg (p_msg VARCHAR2, p_type VARCHAR2 DEFAULT 'I');
--  FUNCTION split_num2(p_str IN VARCHAR2, p_delim IN VARCHAR2 := '#') RETURN VARCHAR2 sql_macro;

END CALC$PAYROLL;
/


/* Formatted on 8/12/2025 5:49:18 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CALC$PAYROLL
IS
    g_user_type   VARCHAR2 (250);
    g_bp_class    billing_period.bp_class%TYPE;

    PROCEDURE SaveTraceMsg (p_msg VARCHAR2, p_type VARCHAR2 DEFAULT 'I')
    IS
    BEGIN
        IF g_TraceMsgEnabled = 1
        THEN
            TOOLS.jobsavemessage (p_msg, p_type);
        ELSIF g_TraceMsgEnabled = 2
        THEN
            DBMS_OUTPUT.put_line (p_msg);
        END IF;
    END;

    PROCEDURE write_prs_log (p_prsl_pr        prs_log.prsl_pr%TYPE,
                             p_prsl_prs       prs_log.prsl_prs%TYPE,
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
                             prsl_pr,
                             prsl_prs,
                             prsl_hs,
                             prsl_st,
                             prsl_message,
                             prsl_st_old,
                             prsl_tp)
             VALUES (0,
                     p_prsl_pr,
                     p_prsl_prs,
                     l_hs,
                     p_prsl_st,
                     p_prsl_message,
                     p_prsl_st_old,
                     NVL (p_prsl_tp, 'SYS'));
    EXCEPTION
        WHEN OTHERS
        THEN
            SaveTraceMsg (
                   'Помилка CALC$PAYROLL.'
                || $$PLSQL_UNIT
                || ' : '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                'E');
    END write_prs_log;

    FUNCTION split_num2 (p_str IN VARCHAR2, p_delim IN VARCHAR2:= '#')
        RETURN VARCHAR2
        SQL_MACRO
    IS
    BEGIN
        RETURN q'{
    select trim(regexp_substr(p_str,'[^' || p_delim || ']+', 1, level)) as substring
    from dual
    connect by regexp_substr(p_str, '[^' || p_delim || ']+', 1, level) is not null
  }';
    END;

    -- #80146 OPERVIEIEV новая идеология доступности ОСЗН (и новая табличка TMP_COM_ORGS)
    PROCEDURE init_com_orgs (p_org              NUMBER,
                             p_user_org_force   NUMBER DEFAULT NULL /*for test*/
                                                                   )
    IS
        l_user_org   NUMBER;
        l_to         NUMBER;
        l_acc        NUMBER;
    BEGIN
        l_user_org := NVL (p_user_org_force, tools.getcurrorg);

        SELECT org_to, org_acc_org
          INTO l_to, l_acc
          FROM v_opfu
         WHERE org_id = l_user_org;

        DELETE FROM TMP_COM_ORGS
              WHERE 1 = 1;

        -- select all available
        IF l_to = 40
        THEN
            INSERT INTO TMP_COM_ORGS (x_id)
                SELECT org_id
                  FROM v_opfu
                 WHERE org_to = 32 AND org_st = 'A';
        ELSIF l_to = 32 AND l_user_org = l_acc
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
        THEN                                                         -- #80830
            INSERT INTO TMP_COM_ORGS (x_id)
                SELECT org_id
                  FROM v_opfu
                 WHERE org_org = l_user_org AND org_st = 'A';
        END IF;

        -- delete not selected
        IF p_org IS NOT NULL
        THEN
            IF l_to = 40
            THEN                                                       -- GIOC
                SELECT org_to
                  INTO l_to
                  FROM v_opfu
                 WHERE org_id = p_org;

                IF l_to = 31
                THEN                                      -- can select REGION
                    DELETE FROM TMP_COM_ORGS
                          WHERE x_id NOT IN
                                    (SELECT org_id
                                       FROM v_opfu
                                      WHERE org_org = p_org AND org_st = 'A');
                ELSE                                          -- or single ORG
                    DELETE FROM TMP_COM_ORGS
                          WHERE x_id != p_org;
                END IF;
            ELSE                  -- any other user can select only single ORG
                DELETE FROM TMP_COM_ORGS
                      WHERE x_id != p_org;
            END IF;
        END IF;

        /* -- testing - comment this block when done */
        IF p_user_org_force IS NOT NULL
        THEN
            DECLARE
                l_msg   VARCHAR2 (4000);
            BEGIN
                FOR cx IN (SELECT x_id FROM TMP_COM_ORGS)
                LOOP
                    l_msg := l_msg || cx.x_id || ',';
                END LOOP;

                SaveTraceMsg (
                       'L_USR ['
                    || l_user_org
                    || '] P_ORG ['
                    || p_org
                    || '] FORCE_USR ['
                    || p_user_org_force
                    || '] L_TO ['
                    || l_to
                    || '] L_ACC ['
                    || l_acc
                    || '] >> '
                    || RTRIM (l_msg, ','));
            END;
        END IF;
    END init_com_orgs;

    PROCEDURE get_pc_4_payroll (p_tp          payroll.pr_tp%TYPE,
                                p_month       payroll.pr_month%TYPE,
                                p_start_day   payroll.pr_start_day%TYPE,
                                p_stop_day    payroll.pr_stop_day%TYPE,
                                p_pay_tp      payroll.pr_pay_tp%TYPE,
                                p_npc         payroll.pr_npc%TYPE)
    IS
        l_start_dt          payroll.pr_start_dt%TYPE;
        l_stop_dt           payroll.pr_stop_dt%TYPE;
        l_month             payroll.pr_month%TYPE;
        l_user_type         VARCHAR2 (250);
        l_bp_class          VARCHAR2 (10);
        l_org_assembly_tp   uss_ndi.v_ndi_payment_codes.npc_org_assembly_tp%TYPE;
        l_half_st           VARCHAR2 (10);
    BEGIN
        l_user_type :=
            SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gUserTP);
        l_bp_class := CASE WHEN l_user_type = '41' THEN 'VPO' ELSE 'V' END;

        SELECT npc_org_assembly_tp
          INTO l_org_assembly_tp
          FROM uss_ndi.v_ndi_payment_codes
         WHERE npc_id = p_npc;

        l_month := TRUNC (p_month, 'MM');
        l_start_dt := TRUNC (p_month, 'MM') + p_start_day - 1;
        l_stop_dt := TRUNC (p_month, 'MM') + p_stop_day - 1;
        l_half_st :=
            CASE l_bp_class WHEN 'VPO' THEN 'RP' WHEN 'V' THEN 'RV' END;

        --  SaveTraceMsg('l_half_st='||l_half_st, 'I');
        --  SaveTraceMsg('l_org_assembly_tp='||l_org_assembly_tp, 'I');

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        --Основна відомість
        IF p_tp IN ('M')
        THEN
            --початок місяця розрахунку відомості або кінець місяця розрахунку відомості - в періоді виплати,
            --або період виплати - в періоді розрахунку відомості

            IF l_org_assembly_tp = 'PC'
            THEN
                --Знаходження ЕОС-кандидатів (прив'язаних до ОСЗН з параметрів), по яким є проводки нарахуваннь, не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'NR'
                      FROM personalcase pc, TMP_COM_ORGS
                     WHERE     pc.com_org = x_id
                           AND pc_st = 'R'
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           pc_decision,
                                           pd_pay_method  pdm,
                                           tmp_ac_nst_list
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND acd_pd = pd_id
                                           AND ac_pc = pc_id
                                           AND ac_month IN
                                                   (l_month,
                                                    ADD_MONTHS (l_month, -1),
                                                    ADD_MONTHS (l_month, -2))
                                           AND ac_st IN ('R', l_half_st)
                                           AND acd_prsd IS NULL
                                           AND acd_imp_pr_num IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND pdm_pd = pd_id
                                           AND pdm.history_status = 'A'
                                           AND pdm_is_actual = 'T'
                                           AND (   pdm_pay_tp = p_pay_tp
                                                OR p_pay_tp = 'ALL')
                                           AND (   pd_st = 'S'
                                                OR (    pd_st = 'PS'
                                                    AND acd_can_use_in_pr =
                                                        'T'))
                                           AND pd_nst = x_nst);

                IF p_npc = 24
                THEN
                    INSERT INTO tmp_work_set2 (x_id1, x_string1)
                        SELECT pc_id, 'NR'
                          FROM uss_esr.personalcase pc, TMP_COM_ORGS
                         WHERE     pc.com_org = x_id
                               AND pc_id = 2349379
                               AND EXISTS
                                       (SELECT 1
                                          FROM uss_esr.accrual,
                                               uss_esr.ac_detail  acd
                                         WHERE     acd_ac = ac_id
                                               AND ac_pc = pc_id
                                               AND acd.history_status = 'A'
                                               AND acd_prsd IS NULL
                                               AND acd_imp_pr_num IS NULL);
                END IF;

                --Знаходження ЕОС-кандидатів (прив'язаних до ОСЗН з параметрів), по яким є проводки доручень, не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'ED'
                      FROM personalcase pc, TMP_COM_ORGS
                     WHERE     pc.com_org = x_id
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           tmp_ac_nst_list,
                                           uss_ndi.v_ndi_npt_config,
                                           errand  ed
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND nptc_npt = acd_npt
                                           AND nptc_nst = x_nst
                                           AND ac_month IN
                                                   (l_month,
                                                    ADD_MONTHS (l_month, -1),
                                                    ADD_MONTHS (l_month, -2))
                                           AND acd_prsd IS NULL
                                           AND acd_imp_pr_num IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND acd_ed = ed_id
                                           AND ed_pc = pc_id
                                           AND (   ed_pay_tp = p_pay_tp
                                                OR p_pay_tp = 'ALL')
                                           AND ed_st = 'R'
                                           AND (   pc_st = 'R'
                                                OR (    pc_st = 'Z'
                                                    AND acd_ed IS NOT NULL)));
            ELSIF l_org_assembly_tp IN ('PD', 'PA')
            THEN
                --Знаходження ЕОС-кандидатівю, по яким є рішення прив'язані до ОСЗН з параметрів, по яким є проводки нарахуваннь, не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'NR'
                      FROM personalcase   pc,
                           TMP_COM_ORGS,
                           pc_decision,
                           pd_pay_method  pdm,
                           tmp_ac_nst_list,
                           pc_account
                     WHERE     pa_org = x_id
                           AND pd_pc = pc_id
                           AND pd_nst = x_nst
                           AND pa_pc = pc_id
                           AND pd_pa = pa_id
                           AND pdm_pd = pd_id
                           AND pc_st = 'R'
                           AND pdm.history_status = 'A'
                           AND pdm_is_actual = 'T'
                           AND (pdm_pay_tp = p_pay_tp OR p_pay_tp = 'ALL')
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND acd_pd = pd_id
                                           AND ac_pc = pc_id
                                           AND ac_month IN
                                                   (l_month,
                                                    ADD_MONTHS (l_month, -1),
                                                    ADD_MONTHS (l_month, -2))
                                           AND ac_st IN ('R', l_half_st)
                                           AND acd_prsd IS NULL
                                           AND acd_imp_pr_num IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND (   pd_st = 'S'
                                                OR (    pd_st = 'PS'
                                                    AND acd_can_use_in_pr =
                                                        'T')));

                --      SaveTraceMsg('found pc`s='||SQL%ROWCOUNT, 'I');

                --Знаходження ЕОС-кандидатів, по яким є доручення (отримані з проводок рішень, прив'язаних до ОСЗН з параметрів), по яким є проводки не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'ED'
                      FROM personalcase pc, TMP_COM_ORGS, pc_account
                     WHERE     pa_org = x_id
                           AND pa_pc = pc_id
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           tmp_ac_nst_list,
                                           uss_ndi.v_ndi_npt_config,
                                           errand  ed,
                                           pc_decision
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND nptc_npt = acd_npt
                                           AND nptc_nst = x_nst
                                           AND ac_month IN
                                                   (l_month,
                                                    ADD_MONTHS (l_month, -1),
                                                    ADD_MONTHS (l_month, -2))
                                           AND acd_prsd IS NULL
                                           AND acd_imp_pr_num IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND acd_ed = ed_id
                                           AND ed_pc = pc_id
                                           AND (   ed_pay_tp = p_pay_tp
                                                OR p_pay_tp = 'ALL')
                                           AND ed_st = 'R'
                                           AND (   pc_st = 'R'
                                                OR (    pc_st = 'Z'
                                                    AND acd_ed IS NOT NULL))
                                           AND acd_pd = pd_id
                                           AND pd_pa = pa_id
                                           AND pd_pc = pc_id);
            END IF;
        /*    INSERT INTO tmp_pc_to_calc (ptc_pc, ptc_start_dt, ptc_stop_dt)
              SELECT pc_id, l_start_dt, l_stop_dt --Знаходження ЕОС-кандидатів (прив'язаних до ОСЗН з параметрів), по яким є проводки, не включені в відомості
              FROM personalcase pc, accrual, TMP_COM_ORGS\*tmp_work_ids*\
              WHERE pc.com_org = x_id
                AND ac_pc = pc_id
                AND ac_month IN (l_month, ADD_MONTHS(l_month, -1), ADD_MONTHS(l_month, -2))
                AND ((l_bp_class = 'VPO' AND ac_st IN ('R', 'RP'))
                  OR (l_bp_class = 'V' AND ac_st IN ('R', 'RV')))
                AND (EXISTS (SELECT 1
                            FROM ac_detail, uss_ndi.v_ndi_payment_type, pc_decision, pd_pay_method pdm, tmp_ac_nst_list
                            WHERE acd_ac = ac_id
                              AND acd_npt = npt_id
                              AND npt_npc = p_npc
                              AND acd_pd = pd_id
                              AND acd_prsd IS NULL AND acd_imp_pr_num is null -- #79967 OPERVIEIEV
                              AND ac_detail.history_status = 'A'
                              AND pdm_pd = pd_id
                              AND pdm.history_status = 'A'
                              AND pdm_is_actual = 'T'
                              AND (pdm_pay_tp = p_pay_tp OR p_pay_tp = 'ALL')
                              AND (pd_st = 'S' --+vano 20221022 Тільки по "Нарахованим" рішенням створюємо відомості - призупинені ігноруємо!
                                OR (pd_st = 'PS' AND acd_can_use_in_pr = 'T')) --+ 84512 20220224 Явно дозволені рядки по призупиненим рішенням - в відомість
                              AND pd_nst = x_nst
                              AND (pc_st = 'R'  OR (pc_st = 'Z' AND acd_ed IS NOT NULL)) --всі проводки по діючій справі або тільки разові доручення по закритій
                              AND l_org_assembly_tp = 'PC')
                  OR EXISTS (SELECT 1
                            FROM ac_detail, uss_ndi.v_ndi_payment_type, errand, tmp_ac_nst_list, uss_ndi.v_ndi_npt_config
                            WHERE acd_ac = ac_id
                              AND acd_npt = npt_id
                              AND npt_npc = p_npc
                              AND nptc_npt = acd_npt
                              AND nptc_nst = x_nst
                              AND acd_prsd IS NULL AND acd_imp_pr_num is null -- #79967 OPERVIEIEV
                              AND ac_detail.history_status = 'A'
                              AND acd_ed = ed_id
                              AND (ed_pay_tp = p_pay_tp OR p_pay_tp = 'ALL')
                              AND ed_st = 'R'
                              AND (pc_st = 'R' OR (pc_st = 'Z' AND acd_ed IS NOT NULL)) --всі проводки по діючій справі або тільки разові доручення по закритій
                              ))
                UNION
                SELECT pd_pc, l_start_dt, l_stop_dt --Знаходження ЕОС-кандидатів, по рішщенням яких (прив'язаних до ОСЗН з параметрів) є проводки, не включені в відомості
                FROM accrual, TMP_COM_ORGS, ac_detail, uss_ndi.v_ndi_payment_type, pc_decision pd, pd_pay_method pdm, tmp_ac_nst_list
                WHERE pd.com_org = x_id
                  AND ac_pc = pd_pc
                  AND ac_month IN (l_month, ADD_MONTHS(l_month, -1), ADD_MONTHS(l_month, -2))
                  AND ac_st IN ('R', 'RV', 'RP')
                  AND acd_ac = ac_id
                  AND acd_npt = npt_id
                  AND npt_npc = p_npc
                  AND acd_pd = pd_id
                  AND acd_prsd IS NULL AND acd_imp_pr_num IS NULL
                  AND ac_detail.history_status = 'A'
                  AND pdm_pd = pd_id
                  AND pdm.history_status = 'A'
                  AND pdm_is_actual = 'T'
                  AND (pdm_pay_tp = p_pay_tp OR p_pay_tp = 'ALL')
                  AND (pd_st = 'S' OR (pd_st = 'PS' AND acd_can_use_in_pr = 'T'))
                  AND pd_nst = x_nst
                  AND acd_ed IS NULL
                  AND l_org_assembly_tp = 'PD';*/


        ELSIF p_tp IN ('MD')
        THEN
            IF l_org_assembly_tp = 'PC'
            THEN
                --Знаходження ЕОС-кандидатів (прив'язаних до ОСЗН з параметрів), по яким є проводки відрахувань держутримання, не включені в відомості держутримання
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'DN'
                      FROM personalcase pc, TMP_COM_ORGS
                     WHERE     pc.com_org = x_id
                           AND pc_st = 'R'
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           pc_decision,
                                           tmp_ac_nst_list,
                                           deduction,
                                           uss_ndi.v_ndi_deduction
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND acd_pd = pd_id
                                           AND ac_pc = pc_id
                                           AND ac_month IN
                                                   (l_month,
                                                    ADD_MONTHS (l_month, -1),
                                                    ADD_MONTHS (l_month, -2))
                                           AND ac_st IN ('R', l_half_st)
                                           AND acd_prsd_sa IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND (   pd_st = 'S'
                                                OR (    pd_st = 'PS'
                                                    AND acd_can_use_in_pr =
                                                        'T'))
                                           AND pd_nst = x_nst
                                           AND acd_dn = dn_id
                                           AND dn_ndn = ndn_id
                                           AND ndn_calc_step = 'F'
                                           AND (   acd_can_use_in_sa = 'T'
                                                OR acd_can_use_in_sa IS NULL));
            ELSIF l_org_assembly_tp IN ('PD', 'PA')
            THEN
                --Знаходження ЕОС-кандидатівю, по яким є рішення прив'язані до ОСЗН з параметрів, по яким є проводки нарахуваннь, не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'NR'
                      FROM personalcase  pc,
                           TMP_COM_ORGS,
                           pc_decision,
                           tmp_ac_nst_list,
                           pc_account
                     WHERE     pa_org = x_id
                           AND pd_pc = pc_id
                           AND pd_nst = x_nst
                           AND pa_pc = pc_id
                           AND pd_pa = pa_id
                           AND pc_st = 'R'
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           deduction,
                                           uss_ndi.v_ndi_deduction
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND acd_pd = pd_id
                                           AND ac_pc = pc_id
                                           AND ac_month IN
                                                   (l_month,
                                                    ADD_MONTHS (l_month, -1),
                                                    ADD_MONTHS (l_month, -2))
                                           AND ac_st IN ('R', l_half_st)
                                           AND acd_prsd_sa IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND (   pd_st = 'S'
                                                OR (    pd_st = 'PS'
                                                    AND acd_can_use_in_pr =
                                                        'T'))
                                           AND acd_dn = dn_id
                                           AND dn_ndn = ndn_id
                                           AND ndn_calc_step = 'F'
                                           AND (   acd_can_use_in_sa = 'T'
                                                OR acd_can_use_in_sa IS NULL));
            --      SaveTraceMsg('found pc`s='||SQL%ROWCOUNT, 'I');
            END IF;
        ELSIF p_tp IN ('A')
        THEN
            --початок місяця розрахунку відомості або кінець місяця розрахунку відомості - в періоді виплати,
            --або період виплати - в періоді розрахунку відомості

            IF l_org_assembly_tp = 'PC'
            THEN
                --Знаходження ЕОС-кандидатів (прив'язаних до ОСЗН з параметрів), по яким є проводки нарахуваннь, не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'NR'
                      FROM personalcase pc, TMP_COM_ORGS
                     WHERE     pc.com_org = x_id
                           AND pc_st = 'R'
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           pc_decision,
                                           pd_pay_method  pdm,
                                           tmp_ac_nst_list
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND acd_pd = pd_id
                                           AND ac_pc = pc_id
                                           AND ac_st IN ('R', l_half_st)
                                           AND acd_prsd IS NULL
                                           AND acd_imp_pr_num IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND pdm_pd = pd_id
                                           AND pdm.history_status = 'A'
                                           AND pdm_is_actual = 'T'
                                           AND (   pdm_pay_tp = p_pay_tp
                                                OR p_pay_tp = 'ALL')
                                           AND (   pd_st = 'S'
                                                OR (    pd_st = 'PS'
                                                    AND acd_can_use_in_pr =
                                                        'T'))
                                           AND pd_nst = x_nst);

                --Знаходження ЕОС-кандидатів (прив'язаних до ОСЗН з параметрів), по яким є проводки доручень, не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'ED'
                      FROM personalcase pc, TMP_COM_ORGS
                     WHERE     pc.com_org = x_id
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           tmp_ac_nst_list,
                                           uss_ndi.v_ndi_npt_config,
                                           errand  ed
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND nptc_npt = acd_npt
                                           AND nptc_nst = x_nst
                                           AND acd_prsd IS NULL
                                           AND acd_imp_pr_num IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND acd_ed = ed_id
                                           AND ed_pc = pc_id
                                           AND (   ed_pay_tp = p_pay_tp
                                                OR p_pay_tp = 'ALL')
                                           AND ed_st = 'R'
                                           AND (   pc_st = 'R'
                                                OR (    pc_st = 'Z'
                                                    AND acd_ed IS NOT NULL)));
            ELSIF l_org_assembly_tp IN ('PD', 'PA')
            THEN
                --Знаходження ЕОС-кандидатівю, по яким є рішення прив'язані до ОСЗН з параметрів, по яким є проводки нарахуваннь, не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'NR'
                      FROM personalcase   pc,
                           TMP_COM_ORGS,
                           pc_decision,
                           pd_pay_method  pdm,
                           tmp_ac_nst_list,
                           pc_account
                     WHERE     pa_org = x_id
                           AND pd_pc = pc_id
                           AND pd_nst = x_nst
                           AND pa_pc = pc_id
                           AND pd_pa = pa_id
                           AND pdm_pd = pd_id
                           AND pc_st = 'R'
                           AND pdm.history_status = 'A'
                           AND pdm_is_actual = 'T'
                           AND (pdm_pay_tp = p_pay_tp OR p_pay_tp = 'ALL')
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND acd_pd = pd_id
                                           AND ac_pc = pc_id
                                           AND ac_st IN ('R', l_half_st)
                                           AND acd_prsd IS NULL
                                           AND acd_imp_pr_num IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND (   pd_st = 'S'
                                                OR (    pd_st = 'PS'
                                                    AND acd_can_use_in_pr =
                                                        'T')));

                --Знаходження ЕОС-кандидатів, по яким є доручення (отримані з проводок рішень, прив'язаних до ОСЗН з параметрів), по яким є проводки не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'ED'
                      FROM personalcase pc, TMP_COM_ORGS, pc_account
                     WHERE     pa_org = x_id
                           AND pa_pc = pc_id
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           tmp_ac_nst_list,
                                           uss_ndi.v_ndi_npt_config,
                                           errand  ed,
                                           pc_decision
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND nptc_npt = acd_npt
                                           AND nptc_nst = x_nst
                                           AND acd_prsd IS NULL
                                           AND acd_imp_pr_num IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND acd_ed = ed_id
                                           AND ed_pc = pc_id
                                           AND (   ed_pay_tp = p_pay_tp
                                                OR p_pay_tp = 'ALL')
                                           AND ed_st = 'R'
                                           AND (   pc_st = 'R'
                                                OR (    pc_st = 'Z'
                                                    AND acd_ed IS NOT NULL))
                                           AND acd_pd = pd_id
                                           AND pd_pa = pa_id
                                           AND pd_pc = pc_id);
            END IF;
        /* INSERT INTO tmp_pc_to_calc (ptc_pc, ptc_start_dt, ptc_stop_dt)
           SELECT DISTINCT pc_id, l_start_dt, l_stop_dt
           FROM personalcase pc, accrual, TMP_COM_ORGS\*tmp_work_ids*\
           WHERE pc.com_org = x_id
             AND ac_pc = pc_id
             --AND ac_month = l_month
             AND ((l_bp_class = 'VPO' AND ac_st IN ('R', 'RP'))
               OR (l_bp_class = 'V' AND ac_st IN ('R', 'RV')))
             AND (EXISTS (SELECT 1
                         FROM ac_detail, uss_ndi.v_ndi_payment_type, pc_decision, pd_pay_method pdm, tmp_ac_nst_list
                         WHERE acd_ac = ac_id
                           AND acd_npt = npt_id
                           AND npt_npc = p_npc
                           AND acd_pd = pd_id
                           AND acd_prsd IS NULL AND acd_imp_pr_num is null -- #79967 OPERVIEIEV
                           AND ac_detail.history_status = 'A'
                           AND pdm_pd = pd_id
                           AND pdm.history_status = 'A'
                           AND pdm_is_actual = 'T'
                           AND (pdm_pay_tp = p_pay_tp OR p_pay_tp = 'ALL')
                           AND (pd_st = 'S' --+vano 20221022 Тільки по "Нарахованим" рішенням створюємо відомості - призупинені ігноруємо!
                             OR (pd_st = 'PS' AND acd_can_use_in_pr = 'T')) --+ 84512 20220224 Явно дозволені рядки по призупиненим рішенням - в відомість
                           AND pd_nst = x_nst
                           AND (pc_st = 'R'  OR (pc_st = 'Z' AND acd_ed IS NOT NULL)) --всі проводки по діючій справі або тільки разові доручення по закритій
                           AND l_org_assembly_tp = 'PC')
               OR EXISTS (SELECT 1
                         FROM ac_detail, uss_ndi.v_ndi_payment_type, errand, tmp_ac_nst_list, uss_ndi.v_ndi_npt_config
                         WHERE acd_ac = ac_id
                           AND acd_npt = npt_id
                           AND npt_npc = p_npc
                           AND nptc_npt = acd_npt
                           AND nptc_nst = x_nst
                           AND acd_prsd IS NULL AND acd_imp_pr_num is null -- #79967 OPERVIEIEV
                           AND ac_detail.history_status = 'A'
                           AND acd_ed = ed_id
                           AND (ed_pay_tp = p_pay_tp OR p_pay_tp = 'ALL')
                           AND ed_st = 'R'
                           AND (pc_st = 'R' OR (pc_st = 'Z' AND acd_ed IS NOT NULL)) --всі проводки по діючій справі або тільки разові доручення по закритій
                           ))
           UNION
           SELECT pd_pc, l_start_dt, l_stop_dt
           FROM accrual, TMP_COM_ORGS, ac_detail, uss_ndi.v_ndi_payment_type, pc_decision pd, pd_pay_method pdm, tmp_ac_nst_list
           WHERE pd.com_org = x_id
             AND ac_pc = pd_pc
             AND ac_st IN ('R', 'RV', 'RP')
             AND acd_ac = ac_id
             AND acd_npt = npt_id
             AND npt_npc = p_npc
             AND acd_pd = pd_id
             AND acd_prsd IS NULL
             AND acd_imp_pr_num IS NULL
             AND ac_detail.history_status = 'A'
             AND pdm_pd = pd_id
             AND pdm.history_status = 'A'
             AND pdm_is_actual = 'T'
             AND (pdm_pay_tp = p_pay_tp OR p_pay_tp = 'ALL')
             AND (pd_st = 'S'
               OR (pd_st = 'PS' AND acd_can_use_in_pr = 'T'))
             AND pd_nst = x_nst
             AND acd_ed IS NULL
             AND l_org_assembly_tp = 'PD';*/
        ELSIF p_tp IN ('AD')
        THEN
            IF l_org_assembly_tp = 'PC'
            THEN
                --Знаходження ЕОС-кандидатів (прив'язаних до ОСЗН з параметрів), по яким є проводки нарахуваннь, не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'NR'
                      FROM personalcase pc, TMP_COM_ORGS
                     WHERE     pc.com_org = x_id
                           AND pc_st = 'R'
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           pc_decision,
                                           tmp_ac_nst_list,
                                           deduction,
                                           uss_ndi.v_ndi_deduction
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND acd_pd = pd_id
                                           AND ac_pc = pc_id
                                           AND ac_st IN ('R', l_half_st)
                                           AND acd_prsd_sa IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND (   pd_st = 'S'
                                                OR (    pd_st = 'PS'
                                                    AND acd_can_use_in_pr =
                                                        'T'))
                                           AND pd_nst = x_nst
                                           AND acd_dn = dn_id
                                           AND dn_ndn = ndn_id
                                           AND ndn_calc_step = 'F'
                                           AND (   acd_can_use_in_sa = 'T'
                                                OR acd_can_use_in_sa IS NULL));
            ELSIF l_org_assembly_tp IN ('PD', 'PA')
            THEN
                --Знаходження ЕОС-кандидатівю, по яким є рішення прив'язані до ОСЗН з параметрів, по яким є проводки нарахуваннь, не включені в відомості
                INSERT INTO tmp_work_set2 (x_id1, x_string1)
                    SELECT pc_id, 'NR'
                      FROM personalcase  pc,
                           TMP_COM_ORGS,
                           pc_decision,
                           tmp_ac_nst_list,
                           pc_account
                     WHERE     pa_org = x_id
                           AND pd_pc = pc_id
                           AND pd_nst = x_nst
                           AND pa_pc = pc_id
                           AND pd_pa = pa_id
                           AND pc_st = 'R'
                           AND EXISTS
                                   (SELECT 1
                                      FROM accrual,
                                           ac_detail,
                                           uss_ndi.v_ndi_payment_type,
                                           deduction,
                                           uss_ndi.v_ndi_deduction
                                     WHERE     acd_ac = ac_id
                                           AND acd_npt = npt_id
                                           AND npt_npc = p_npc
                                           AND acd_pd = pd_id
                                           AND ac_pc = pc_id
                                           AND ac_st IN ('R', l_half_st)
                                           AND acd_prsd_sa IS NULL
                                           AND ac_detail.history_status = 'A'
                                           AND acd_op IN
                                                   (SELECT x_id
                                                      FROM tmp_work_ids3)
                                           AND (   pd_st = 'S'
                                                OR (    pd_st = 'PS'
                                                    AND acd_can_use_in_pr =
                                                        'T'))
                                           AND acd_dn = dn_id
                                           AND dn_ndn = ndn_id
                                           AND ndn_calc_step = 'F'
                                           AND (   acd_can_use_in_sa = 'T'
                                                OR acd_can_use_in_sa IS NULL));
            END IF;
        END IF;

        INSERT INTO tmp_pc_to_calc (ptc_pc, ptc_start_dt, ptc_stop_dt)
            SELECT DISTINCT x_id1, l_start_dt, l_stop_dt
              FROM tmp_work_set2;
    END;

    --Отримання серії та номеру паспорту з документів звернення
    FUNCTION get_pasp_info (p_mode INTEGER, p_ap appeal.ap_id%TYPE)
        RETURN VARCHAR2
    IS
        l_id    ap_person.app_id%TYPE := NULL;
        l_rez   VARCHAR2 (250);
    BEGIN
        IF p_mode = 1
        THEN
            SELECT MAX (app_id)
              INTO l_id
              FROM ap_person
             WHERE app_ap = p_ap AND app_tp = 'Z' AND history_Status = 'A';

            IF l_id IS NOT NULL
            THEN
                l_rez :=
                    NVL (API$PC_DECISION.get_doc_string (l_id, 6, 3),
                         API$PC_DECISION.get_doc_string (l_id, 7, 9));
            END IF;
        ELSIF p_mode = 2
        THEN
            SELECT MAX (app_sc)
              INTO l_id
              FROM ap_person
             WHERE app_ap = p_ap AND app_tp = 'Z' AND history_Status = 'A';

            IF l_id IS NOT NULL
            THEN
                l_rez := uss_person.api$sc_tools.get_doc_num (l_id);
            END IF;
        END IF;

        RETURN l_rez;
    END;

    FUNCTION get_fuctionary (p_org NUMBER, p_tp VARCHAR2)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (250);
    BEGIN
        SELECT MAX (
                      fnc_ln
                   || ' '
                   || SUBSTR (fnc_fn, 1, 1)
                   || '. '
                   || SUBSTR (fnc_mn, 1, 1)
                   || '. ')
               KEEP (DENSE_RANK LAST ORDER BY fnc_id)
          INTO l_rez
          FROM uss_ndi.v_ndi_functionary
         WHERE com_org = p_org AND fnc_tp = p_tp;

        RETURN l_rez;
    END;

    PROCEDURE create_payroll (
        p_tp          payroll.pr_tp%TYPE,
        p_org         payroll.com_org%TYPE,
        p_month       DATE,
        p_day_start   INTEGER,
        p_day_stop    INTEGER,
        p_pay_tp      VARCHAR2,
        p_npc         NUMBER,
        p_pe_code     USS_NDI.v_ddn_pe_code.DIC_VALUE%TYPE DEFAULT '1' -- Режим створення #79218 OPERVIEIEV 08.2022
                                                                      )
    IS
        l_start_dt                 payroll.pr_start_dt%TYPE;
        l_stop_dt                  payroll.pr_stop_dt%TYPE;
        l_com_org                  payroll.com_org%TYPE;
        l_pr_cnt                   INTEGER;
        l_cnt                      INTEGER;
        --  l_last_prs_number VARCHAR2(20);
        l_portion                  INTEGER := 10;
        l_vpo_npc_id               NUMBER;
        l_kah_npc_id               NUMBER;
        l_ob_nb_id                 NUMBER;
        --  l_org_to NUMBER;
        l_vpo_code                 paramsesr.prm_value%TYPE;
        l_kah_code                 paramsesr.prm_value%TYPE;
        l_oschad_mfo               paramsesr.prm_value%TYPE;
        --l_kah_oschad_mfo paramsesr.prm_value%TYPE;
        l_kah_oschad_decode_list   paramsesr.prm_value%TYPE;
        l_day_start                INTEGER;
        l_day_stop                 INTEGER;
        l_msg                      VARCHAR2 (4000);
        l_prm_org                  v_opfu%ROWTYPE;
        l_lock_org                 NUMBER;
        l_lock                     TOOLS.t_lockhandler;
        l_org_assembly_tp          uss_ndi.v_ndi_payment_codes.npc_org_assembly_tp%TYPE;
        l_main_pr_tp               payroll.pr_tp%TYPE;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        DBMS_APPLICATION_INFO.set_action (
            action_name   =>
                'org=' || p_org || ';month=' || TO_CHAR (p_month, 'MM.YYYY'));

        IF p_org = -1
        THEN
            raise_application_error (
                -20000,
                'Відомості можна створювати по області або по району! Виберіть конкретну область або конкретний район!');
        END IF;

        SELECT *
          INTO l_prm_org
          FROM v_opfu
         WHERE org_id = p_org;

        IF l_prm_org.org_to = 32
        THEN
            l_lock_org := l_prm_org.org_org;
        ELSIF l_prm_org.org_to = 31
        THEN
            l_lock_org := l_prm_org.org_id;
        ELSE
            raise_application_error (
                -20000,
                'Відомості можна створювати по області або по району!');
        END IF;

        SaveTraceMsg (
               'Перевіряю, чи не виконуються інші задачі створення відомостей по області '
            || l_lock_org
            || '.');

        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'CREATE_PAYROLL_' || l_lock_org,
                p_error_msg   =>
                       'В даний момент вже виконується створення відомостей по області (або районам області) '
                    || l_lock_org
                    || '! Спробуйте через декілька хвилин.');

        init_access_params; --Користувач ІОЦ створює відомості ВПО--Користувач УСЗН/ДСЗН створює всі інші відомості

        --  l_com_org := sys_context(USS_ESR_CONTEXT.gContext,USS_ESR_CONTEXT.gORG);
        SELECT npc_org_assembly_tp
          INTO l_org_assembly_tp
          FROM uss_ndi.v_ndi_payment_codes
         WHERE npc_id = p_npc;

        -- #80146 OPERVIEIEV
        init_com_orgs (p_org);
        API$ACCRUAL.init_nst_list (4);

        IF g_bp_class = 'V'
        THEN
            INSERT INTO tmp_ac_nst_list (x_nst)
                SELECT 20
                  FROM DUAL
                 WHERE NOT EXISTS
                           (SELECT 1
                              FROM tmp_ac_nst_list
                             WHERE x_nst = 20);
        END IF;

        DELETE FROM tmp_work_ids3
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids3 (x_id)
            SELECT op_id
              FROM uss_ndi.v_ndi_op --+vano20221025 В мігрованих даних купа різних операцій, які поки що ігноруємо. Без цього - пустишки відомостей будуються.
             WHERE    (    p_tp IN ('M', 'A')
                       AND op_id IN (1,
                                     2,
                                     3,
                                     127,
                                     128,
                                     133,
                                     143,
                                     183,
                                     184,
                                     196,
                                     197,
                                     202,
                                     203,
                                     212,
                                     213,
                                     222,
                                     237,
                                     256,
                                     257,
                                     217,
                                     216,
                                     10,
                                     33,
                                     123,
                                     124,
                                     125,
                                     278,
                                     280,
                                     30,
                                     31                                /*,32*/
                                       ))
                   OR (    p_tp IN ('MD', 'AD')
                       AND op_id IN (123,
                                     124,
                                     125,
                                     278,
                                     280,
                                     30,
                                     31                                /*,32*/
                                       ));

        l_vpo_code := TOOLS.ggp ('PR_VPO_CODE');
        l_kah_code := TOOLS.ggp ('PR_KAH_CODE');

        SELECT npc_id
          INTO l_vpo_npc_id
          FROM uss_ndi.v_ndi_payment_codes npc
         WHERE npc.npc_code = l_vpo_code;

        SELECT npc_id
          INTO l_kah_npc_id
          FROM uss_ndi.v_ndi_payment_codes npc
         WHERE npc.npc_code = l_kah_code;

        IF p_npc = l_vpo_npc_id
        THEN         --  #77084 Всі пакети допомоги ВПО формуються на Ощадбанк
            l_oschad_mfo := TOOLS.ggp ('PR_OSCHAD_MFO');

            SELECT nb_id --Головний Ощад повинен бути лише один. Не більше і не менше. Інше - помилка в довіднику
              INTO l_ob_nb_id
              FROM uss_ndi.v_ndi_bank b
             WHERE     b.nb_mfo = l_oschad_mfo
                   AND b.history_status = 'A'
                   AND nb_nb IS NULL;
        ELSIF p_npc = l_kah_npc_id AND l_lock_org = 56500
        THEN         --  #77084 Всі пакети допомоги ВПО формуються на Ощадбанк
            l_oschad_mfo := TOOLS.ggp ('PR_KAH_OSCHAD_MFO');

            --l_kah_oschad_decode_list := TOOLS.ggp('PR_KAH_OSCHAD_DECODE_LIST');
            SELECT nb_id --Головний Ощад повинен бути лише один. Не більше і не менше. Інше - помилка в довіднику
              INTO l_ob_nb_id
              FROM uss_ndi.v_ndi_bank b
             WHERE     b.nb_mfo = l_oschad_mfo
                   AND b.history_status = 'A'
                   AND nb_nb IS NULL;
        END IF;

        SaveTraceMsg (
            'Починаю перевірку параметрів та наявності даних для формування відомостей!');

        l_com_org :=
            SYS_CONTEXT (uss_esr_context.gContext, uss_esr_context.gORG);
        --l_start_dt := TRUNC(p_month, 'MM') + p_day_start - 1;
        --l_stop_dt := TRUNC(p_month, 'MM') + p_day_stop - 1;

        l_start_dt := TRUNC (p_month, 'MM') + 3;
        l_stop_dt := TRUNC (p_month, 'MM') + 24;
        l_day_start := 4;
        l_day_stop := 25;

        --Очищуємо таблицю, в якій будемо накопичувати список тих установ, по яким виявлені помилки.
        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        --Перевірки на створення відомостей
        IF p_tp IS NULL
        THEN
            SaveTraceMsg ('Не вказано типу відомості!', 'E');
            SaveTraceMsg ('Завершено створення відомості!', 'E');
            TOOLS.release_lock (l_lock);
            RETURN;
        ELSIF p_day_start IS NULL OR p_day_stop IS NULL
        THEN
            SaveTraceMsg ('Не вказано діапазону днів виплати!', 'E');
            SaveTraceMsg ('Завершено створення відомості!', 'E');
            TOOLS.release_lock (l_lock);
            RETURN;
        ELSIF p_pay_tp IS NULL
        THEN
            SaveTraceMsg ('Не вказано способу виплати!', 'E');
            SaveTraceMsg ('Завершено створення відомості!', 'E');
            TOOLS.release_lock (l_lock);
            RETURN;
        END IF;

        --Перевіряємо кожен УСЗН
        FOR xx IN (SELECT x_id AS org_id FROM TMP_COM_ORGS)
        LOOP
            SELECT COUNT (*)
              INTO l_cnt
              FROM billing_period
             WHERE     com_org =
                       CASE
                           WHEN g_bp_class = 'V' THEN xx.org_id
                           ELSE l_com_org
                       END
                   AND bp_org = xx.org_id
                   AND bp_tp = 'PR'
                   AND bp_st = 'R'
                   AND bp_month = p_month
                   AND bp_class = g_bp_class;

            IF l_cnt = 0
            THEN
                SaveTraceMsg (
                       'Період ('
                    || TO_CHAR (p_month, 'MM.YYYY')
                    || ') - не відкритий для установи '
                    || xx.org_id
                    || '! Створити основну відомость - неможливо!',
                    'E');

                INSERT INTO tmp_work_set1 (x_id1)
                     VALUES (xx.org_id);
            END IF;
        END LOOP;

        /*  FOR xx IN (SELECT x_id AS org_id, dic_value AS pay_tp, dic_name AS pay_tp_name FROM tmp_work_ids, (SELECT * FROM uss_ndi.v_ddn_apm_tp WHERE dic_value = p_pay_tp OR (p_pay_tp = 'ALL' AND dic_value IN ('BANK', 'POST'))))
          LOOP
            SELECT COUNT(*) INTO l_pr_cnt FROM payroll WHERE com_org = xx.org_id AND pr_month < p_month AND pr_pay_tp = xx.pay_tp AND pr_npc = p_npc;
            IF l_pr_cnt > 0 THEN
              SaveTraceMsg('За попередні періоди для установи '||xx.org_id||' знайдено ще не зафіксовані банком/поштою відомісті - спочатку треба їх виплатити!');
              INSERT INTO tmp_work_set1 (x_id1) VALUES (xx.org_id);
            END IF;
          END LOOP;*/

        IF p_tp IN ('M', 'MD')
        THEN
            --Перевіряємо кожен УСЗН
            FOR xx
                IN (SELECT x_id          AS org_id,
                           dic_value     AS pay_tp,
                           dic_name      AS pay_tp_name
                      FROM TMP_COM_ORGS,
                           (SELECT *
                              FROM uss_ndi.v_ddn_apm_tp
                             WHERE    (    p_tp IN ('M')
                                       AND (   dic_value = p_pay_tp
                                            OR (    p_pay_tp = 'ALL'
                                                AND dic_value IN
                                                        ('BANK', 'POST'))))
                                   OR (    p_tp IN ('MD')
                                       AND dic_value IN ('BANK'))))
            LOOP
                SELECT COUNT (*)
                  INTO l_pr_cnt
                  FROM payroll
                 WHERE     com_org = xx.org_id
                       AND pr_tp = p_tp
                       AND pr_month = p_month
                       AND pr_pay_tp = xx.pay_tp
                       AND pr_npc = p_npc;

                IF l_pr_cnt > 0
                THEN
                    SaveTraceMsg (
                           'На вказаний період ('
                        || TO_CHAR (l_start_dt, 'DD.MM.YYYY')
                        || '-'
                        || TO_CHAR (l_stop_dt, 'DD.MM.YYYY')
                        || ') для установи '
                        || xx.org_id
                        || ' вже створено основну відомість типу виплати "'
                        || xx.pay_tp_name
                        || '"!',
                        'E');

                    INSERT INTO tmp_work_set1 (x_id1)
                         VALUES (xx.org_id);
                END IF;
            END LOOP;
        ELSIF p_tp IN ('A', 'AD')
        THEN
            l_main_pr_tp :=
                CASE WHEN p_tp = 'A' THEN 'M' WHEN p_tp = 'AD' THEN 'MD' END;

            --Перевіряємо кожен УСЗН
            FOR xx
                IN (SELECT x_id          AS org_id,
                           dic_value     AS pay_tp,
                           dic_name      AS pay_tp_name
                      FROM TMP_COM_ORGS                       /*tmp_work_ids*/
                                       ,
                           (SELECT *
                              FROM uss_ndi.v_ddn_apm_tp
                             WHERE    dic_value = p_pay_tp
                                   OR (    p_pay_tp = 'ALL'
                                       AND dic_value IN ('BANK', 'POST'))))
            LOOP
                SELECT COUNT (*)
                  INTO l_pr_cnt
                  FROM payroll
                 WHERE     com_org = xx.org_id
                       AND pr_tp = l_main_pr_tp
                       AND pr_month = p_month
                       AND pr_pay_tp = xx.pay_tp
                       AND pr_npc = p_npc;

                IF l_pr_cnt = 0
                THEN
                    SaveTraceMsg (
                           'За вказаний період ('
                        || TO_CHAR (p_month, 'MM.YYYY')
                        || ') для установи '
                        || xx.org_id
                        || ' не створено основну відомість типу виплати "'
                        || xx.pay_tp_name
                        || '"!',
                        'E');

                    INSERT INTO tmp_work_set1 (x_id1)
                         VALUES (xx.org_id);
                END IF;

                SELECT COUNT (*)
                  INTO l_pr_cnt
                  FROM payroll
                 WHERE     com_org = xx.org_id
                       AND pr_tp = l_main_pr_tp
                       AND pr_month = p_month
                       AND pr_st IN ('C', 'P')
                       AND pr_pay_tp = xx.pay_tp
                       AND pr_npc = p_npc;

                IF l_pr_cnt > 0
                THEN
                    SaveTraceMsg (
                           'За вказаний період ('
                        || TO_CHAR (p_month, 'MM.YYYY')
                        || ') для установи '
                        || xx.org_id
                        || ' ще не фіксовано банком/поштою основну відомість  типу виплати "'
                        || xx.pay_tp_name
                        || '"!',
                        'E');

                    INSERT INTO tmp_work_set1 (x_id1)
                         VALUES (xx.org_id);
                END IF;

                SELECT COUNT (*)
                  INTO l_pr_cnt
                  FROM payroll
                 WHERE     com_org = xx.org_id
                       AND pr_tp = l_main_pr_tp
                       AND pr_month = p_month
                       AND pr_st IN ('C', 'P')
                       AND pr_pay_tp = xx.pay_tp
                       AND pr_npc = p_npc;

                IF l_pr_cnt > 0
                THEN
                    SaveTraceMsg (
                           'За вказаний період ('
                        || TO_CHAR (p_month, 'MM.YYYY')
                        || ') для установи '
                        || xx.org_id
                        || ' додаткову відомість типу виплати "'
                        || xx.pay_tp_name
                        || '" ще не фіксовано - спочатку треба виплатити!',
                        'E');

                    INSERT INTO tmp_work_set1 (x_id1)
                         VALUES (xx.org_id);
                END IF;
            END LOOP;
        END IF;

        --Видаляємо накопичений список установ з помилками з основного списку.
        DELETE FROM TMP_COM_ORGS                              /*tmp_work_ids*/
                                 w
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_work_set1 s
                          WHERE w.x_id = s.x_id1);

        --Отримуємо перелік справ для відомостей.
        get_pc_4_payroll (p_tp,
                          p_month,
                          4,
                          25,
                          p_pay_tp,
                          p_npc);

        FOR xx
            IN (  SELECT org_code,
                         org_name,
                         npc_code,
                         npc_name,
                         dic_name
                    FROM TMP_COM_ORGS,
                         uss_ndi.v_ddn_apm_tp,
                         v_opfu,
                         uss_ndi.v_ndi_payment_codes
                   WHERE     (dic_value = p_pay_tp OR p_pay_tp = 'ALL')
                         AND dic_value IN ('BANK', 'POST')
                         AND p_tp = 'M'
                         AND x_id = org_id
                         AND npc_id = p_npc
                         AND EXISTS
                                 (SELECT 1
                                    FROM payroll
                                   WHERE     x_id = com_org
                                         AND pr_tp = p_tp
                                         AND pr_pay_tp = dic_value
                                         AND pr_month = p_month
                                         AND pr_npc = p_npc
                                         AND pr_stop_day >= l_day_start
                                         AND pr_start_day <= l_day_stop)
                ORDER BY 1, 3)
        LOOP
            SaveTraceMsg (
                   'Вже є основна відомость виду ['
                || xx.npc_code
                || '. '
                || xx.npc_name
                || '] з типом виплати ['
                || xx.dic_name
                || '] для органу призначення ['
                || xx.org_code
                || '. '
                || xx.org_name
                || '] на вказаний період і вказані дні виплат!',
                'E');
        END LOOP;

        INSERT INTO tmp_payroll (t_org,
                                 t_tp,
                                 t_month,
                                 t_start_day,
                                 t_stop_day,
                                 t_pay_tp,
                                 t_npc)
            SELECT x_id,
                   p_tp,
                   p_month,
                   l_day_start,
                   l_day_stop,
                   dic_value,
                   p_npc
              FROM TMP_COM_ORGS, uss_ndi.v_ddn_apm_tp
             WHERE     (dic_value = p_pay_tp OR p_pay_tp = 'ALL')
                   AND (   (    p_tp IN ('M', 'A')
                            AND dic_value IN ('BANK', 'POST'))
                        OR (p_tp IN ('MD', 'AD') AND dic_value IN ('BANK')))
                   AND (   p_tp IN ('A', 'AD')
                        OR (    p_tp IN ('M', 'MD')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM payroll
                                      WHERE     x_id = com_org
                                            AND pr_tp = p_tp
                                            AND pr_month = p_month
                                            AND pr_pay_tp = dic_value
                                            AND pr_npc = p_npc
                                            AND pr_stop_day >= l_day_start
                                            AND pr_start_day <= l_day_stop)));

        SaveTraceMsg ('Заготовок відомостей: ' || SQL%ROWCOUNT);

        UPDATE tmp_payroll
           SET t_id = id_payroll (0),
               t_period_start_dt =
                   CASE
                       WHEN    (p_tp IN ('A', 'AD') AND p_pe_code = '2')
                            OR p_pe_code IN ('21', '4', '5')
                       THEN
                           TO_DATE ('01.01.2020', 'DD.MM.YYYY')
                       WHEN    p_tp IN ('M', 'MD')
                            OR (p_tp IN ('A', 'AD') AND p_pe_code = '1')
                       THEN
                           DECODE (g_bp_class,
                                   'VPO', t_month,
                                   ADD_MONTHS (t_month, 1))
                       ELSE
                           NULL
                   END,
               t_period_stop_dt =
                   CASE
                       WHEN    p_tp IN ('M', 'MD')
                            OR (p_tp IN ('A', 'AD') AND p_pe_code = '1')
                            OR p_pe_code IN ('21', '4', '5')
                       THEN
                           DECODE (g_bp_class,
                                   'VPO', LAST_DAY (t_month),
                                   LAST_DAY (t_month))
                       WHEN p_tp IN ('A', 'AD') AND p_pe_code = '2'
                       THEN
                           DECODE (
                               g_bp_class,
                               'VPO', LAST_DAY (ADD_MONTHS (t_month, -1)),
                               LAST_DAY (t_month))
                       ELSE
                           NULL
                   END
         WHERE 1 = 1;

        -- ми щойно у цій таблиці накопичували список установ, по яким виявлені помилки (но то таке)
        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        -- деталі нарахувань які буде використано у відомості
        INSERT INTO tmp_work_set1 (x_id1, x_id2, x_id3)
            SELECT acd_id,
                   t_id,
                   CASE
                       WHEN acd_op IN (123,
                                       124,
                                       30,
                                       31                              /*,32*/
                                         )
                       THEN
                           NULL
                       ELSE
                           acd_ed
                   END
              FROM tmp_payroll,
                   tmp_pc_to_calc,
                   accrual,
                   ac_detail,
                   pc_decision   pd,
                   uss_ndi.v_ndi_payment_type,
                   pc_account,
                   personalcase  pc
             WHERE     ptc_pc = pd_pc
                   AND pd_pa = pa_id
                   AND pa_pc = pc_id
                   AND acd_pd = pd_id
                   AND ac_pc = ptc_pc
                   AND acd_ac = ac_id
                   AND acd_npt = npt_id
                   AND pd_pc = pc_id
                   AND (   (    acd_ed IS NULL
                            AND (   pd_st = 'S' --+vano 20221022 Тільки по "Нарахованим" рішенням створюємо відомості - призупинені ігноруємо!
                                 OR (    pd_st IN ('S', 'PS')
                                     AND acd_can_use_in_pr = 'T'))) --+ 84512 20220224 Явно дозволені рядки по призупиненим рішенням - в відомість
                        OR (    acd_ed IS NOT NULL
                            AND EXISTS
                                    (SELECT 1
                                       FROM errand
                                      WHERE ed_id = acd_ed AND ed_st = 'R')))
                   AND (   (t_tp = 'M' AND t_month = ac_month)
                        OR t_tp = 'A'
                        OR p_pe_code IN ('21', '4', '5'))
                   AND (   (l_org_assembly_tp = 'PC' AND pc.com_org = t_org)
                        OR (    l_org_assembly_tp IN ('PD', 'PA')
                            AND pa_org = t_org))
                   AND (   (    acd_start_dt <= t_period_stop_dt -- верхня межа
                            AND acd_stop_dt >= t_period_start_dt) -- нижня межа
                        OR (    ac_pc = 2349379
                            AND acd_start_dt <= t_period_stop_dt))
                   AND accrual.history_status = 'A'
                   AND ac_detail.history_status = 'A'
                   AND acd_op IN (SELECT x_id FROM tmp_work_ids3) --+vano20221025 В мігрованих даних купа різних операцій, які поки що ігноруємо. Без цього - пустишки відомостей будуються.
                   AND (   (    acd_ed IS NULL
                            AND EXISTS
                                    (SELECT 1
                                       FROM pd_pay_method pdm
                                      WHERE     pdm_pd = pd_id
                                            AND pdm.history_status = 'A'
                                            AND pdm_is_actual = 'T'
                                            AND (   (    p_tp IN ('M', 'A')
                                                     AND pdm_pay_tp =
                                                         t_pay_tp)
                                                 OR p_tp IN ('MD', 'AD'))
                                            AND pdm_pay_dt BETWEEN t_start_day
                                                               AND t_stop_day))
                        OR (    acd_ed IS NOT NULL
                            AND EXISTS
                                    (SELECT 1
                                       FROM errand
                                      WHERE     acd_ed = ed_id
                                            AND ed_st = 'R'
                                            AND ed_pay_tp = t_pay_tp
                                            AND ed_pay_dt BETWEEN t_start_day
                                                              AND t_stop_day)))
                   -- and bp.com_org = l_com_org and bp.bp_org = t_org and AND bp_tp = 'PR' AND bp_st = 'R' AND bp_month = p_month AND bp_class = l_bp_class
                   AND npt_npc = t_npc
                   AND (   (g_bp_class = 'VPO' AND ac_st IN ('R', 'RP')) --ВПО тільки по діючим та "діюче по ВПО"
                        OR (    p_npc = 57
                            AND g_bp_class = 'V'
                            AND ac_st IN ('R', 'RV', 'RP')) --каховська допомога по "не ВПО" та по будь-яким діючим
                        OR (g_bp_class = 'V' AND ac_st IN ('R', 'RV'))) --Не ВПО - тільки по дічим та "діюче по допомогам"
                   AND (   (    p_npc <> 57
                            AND (   pc_st = 'R'
                                 OR (pc_st = 'Z' AND acd_ed IS NOT NULL))) --всі проводки по діючій справі або тільки разові доручення по закритій
                        OR (p_npc = 57 AND acd_ed IS NULL)) --Каховська допомога - без разових доручнь
                   AND (   p_pe_code IN ('1', '2', '21') --По 1/2/21 - будь-які проводки.
                        OR (p_pe_code = '4' AND acd_ed IS NULL) --По 4 - без разових доручень
                        OR (p_pe_code = '5' AND acd_ed IS NOT NULL)) --По 5 - тільки разові доручення
                   AND (       p_tp IN ('M', 'A')
                           AND acd_prsd IS NULL
                           AND acd_imp_pr_num IS NULL
                        OR (    p_tp IN ('MD', 'AD')
                            AND acd_prsd_sa IS NULL
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.deduction,
                                            uss_ndi.v_ndi_deduction
                                      WHERE     acd_dn = dn_id
                                            AND dn_ndn = ndn_id
                                            AND ndn_calc_step = 'F')));

        --RETURN;
        --ikis_sysweb.ikis_debug_pipe.WriteMsg(SQL%ROWCOUNT);

        --Повідомляємо користувачу, що деякі відомості створені не будуть
        FOR xx IN (SELECT npc_code,
                          npc_name,
                          dic_name,
                          org_code,
                          org_name
                     FROM tmp_payroll,
                          uss_ndi.v_ndi_payment_codes,
                          uss_ndi.v_ddn_apm_tp,
                          v_opfu
                    WHERE     t_org = org_id
                          AND t_npc = npc_id
                          AND t_pay_tp = dic_value
                          AND NOT EXISTS
                                  (SELECT 1
                                     FROM tmp_work_set1
                                    WHERE t_id = x_id2))
        LOOP
            SaveTraceMsg (
                   'Для створення відомості виду ['
                || xx.npc_code
                || '. '
                || xx.npc_name
                || '] з типом виплати ['
                || xx.dic_name
                || '] з органу призначення ['
                || xx.org_code
                || '. '
                || xx.org_name
                || '] не знайдено діючих у вказаному періоді нарахувань!',
                'E');
        END LOOP;

        DELETE FROM tmp_payroll
              WHERE NOT EXISTS
                        (SELECT 1
                           FROM tmp_work_set1
                          WHERE t_id = x_id2);

        SELECT COUNT (*) INTO l_pr_cnt FROM tmp_payroll;

        IF l_pr_cnt = 0
        THEN
            SaveTraceMsg (
                'Не знайдено даних для формування відомостей за вказаними параметрами.',
                'E');
            TOOLS.release_lock (l_lock);
            RETURN;
        END IF;

        SaveTraceMsg ('Розпочато формування відомостей (нарахування).');

        INSERT INTO payroll (pr_id,
                             pr_tp,
                             pr_create_dt,
                             pr_start_dt,
                             pr_stop_dt,
                             pr_st,
                             com_org,
                             pr_pib_bookkeeper,
                             pr_pib_head,
                             pr_code,
                             pr_start_day,
                             pr_stop_day,
                             pr_pay_tp,
                             pr_npc,
                             pr_month,
                             pr_src)
            SELECT t_id,
                   t_tp,
                   SYSDATE,
                   l_start_dt,
                   l_stop_dt,
                   'C',
                   t_org,
                   CALC$PAYROLL.get_fuctionary (t_org, 'P'),
                   CALC$PAYROLL.get_fuctionary (t_org, 'B'),
                   p_pe_code,                                        -- #79218
                   t_start_day,
                   t_stop_day,
                   t_pay_tp,
                   t_npc,
                   t_month,
                   '0'
              FROM tmp_payroll;

        DELETE FROM tmp_prsd
              WHERE 1 = 1;

        --Пишемо нарахування
        INSERT INTO tmp_prsd (d_pr,
                              d_pc,
                              d_pd,
                              d_dn,
                              d_npt,
                              d_month,
                              d_tp,
                              d_ed,
                              d_sum,
                              d_ids,
                              d_ids_cnt)
              SELECT x_id2,
                     ac_pc,
                     acd_pd,
                     CASE WHEN acd_op IN (10, 33) THEN NULL ELSE acd_dn END,
                     acd_npt,
                     TRUNC (acd_start_dt, 'MM'),
                     CASE WHEN acd_op IN (10, 33) THEN 'RDN' ELSE 'PWI' END,
                     NVL (acd_ed, 0),
                     SUM (api$accrual.xsign (acd_op) * acd_sum),
                        '#'
                     || LISTAGG (x_id1, '#') WITHIN GROUP (ORDER BY x_id1)
                     || '#',
                     COUNT (*)
                FROM tmp_work_set1, ac_detail, accrual
               WHERE     x_id1 = acd_id
                     AND acd_ac = ac_id
                     AND acd_op IN (1,
                                    2,
                                    3,
                                    127,
                                    128,
                                    133,
                                    143,
                                    183,
                                    184,
                                    196,
                                    197,
                                    202,
                                    203,
                                    212,
                                    213,
                                    222,
                                    237,
                                    256,
                                    257,
                                    217,
                                    216,
                                    10,
                                    33)
                     AND ac_detail.history_status = 'A'
            GROUP BY x_id2,
                     ac_pc,
                     acd_pd,
                     CASE WHEN acd_op IN (10, 33) THEN NULL ELSE acd_dn END,
                     acd_npt,
                     TRUNC (acd_start_dt, 'MM'),
                     CASE WHEN acd_op IN (10, 33) THEN 'RDN' ELSE 'PWI' END,
                     NVL (acd_ed, 0);

        --Пишемо відрахування
        INSERT INTO tmp_prsd (d_pr,
                              d_pc,
                              d_pd,
                              d_dn,
                              d_npt,
                              d_month,
                              d_ed,
                              d_sum,
                              d_tp,
                              d_dpp,
                              d_ids,
                              d_ids_cnt)
              SELECT x_id2,
                     ac_pc,
                     MAX (acd_pd),
                     acd_dn,
                     CASE WHEN acd_npt = 337 THEN 167 ELSE acd_npt END, --!!! ТОЛЬКО ДЛЯ ВПО - ПЕРЕКОДИРОВКА КОДА ВЫПЛАТЫ 1006 В 327.
                     TRUNC (acd_start_dt, 'MM'),
                     0, --NVL(acd_ed, 0), --для відрахуваннь не вказуються документи однрахових виплат.
                     -1 * SUM (api$accrual.xsign (acd_op) * acd_sum),
                     MAX (
                         CASE
                             WHEN ndn_calc_step = 'F' THEN 'PRUT'
                             WHEN ndn_id IN (5, 6, 7) THEN 'PRAL'
                             WHEN ndn_id IN (8) THEN 'PROZ'
                             WHEN ndn_id IN (89) THEN 'PROP'
                             WHEN ndn_id IS NULL THEN 'PROZ'
                             ELSE 'PROZ'
                         END),
                     MAX (dn_dpp),
                        '#'
                     || LISTAGG (x_id1, '#') WITHIN GROUP (ORDER BY x_id1)
                     || '#',
                     COUNT (*)
                FROM tmp_work_set1,
                     ac_detail,
                     accrual,
                     deduction,
                     uss_ndi.v_ndi_deduction
               WHERE     x_id1 = acd_id
                     AND acd_ac = ac_id
                     AND acd_dn = dn_id(+)
                     AND dn_ndn = ndn_id(+)
                     AND acd_op IN (123,
                                    124,
                                    125,
                                    278,
                                    280,
                                    30,
                                    31                                 /*,32*/
                                      )
                     AND ac_detail.history_status = 'A'
            GROUP BY x_id2,
                     ac_pc,                                       /*acd_pd, */
                     acd_dn,
                     CASE WHEN acd_npt = 337 THEN 167 ELSE acd_npt END,
                     TRUNC (acd_start_dt, 'MM'),
                     NVL (acd_ed, 0);

        --Контроль на вказаність юрособи-отримувача та параметрів рахунку юр-особи
        SELECT LISTAGG (x_num, ', ' ON OVERFLOW TRUNCATE WITH COUNT)
                   WITHIN GROUP (ORDER BY x_num)
          INTO l_msg
          FROM (  SELECT d_dn,
                         dn_in_doc_num || ' (ЕОС=' || pc_num || ')'
                             AS x_num,
                         COUNT (DISTINCT dppa_id)
                    FROM tmp_prsd,
                         personalcase,
                         deduction,
                         uss_ndi.ndi_pay_person    ur,
                         uss_ndi.ndi_pay_person_acc acc
                   WHERE     d_dpp = ur.dpp_id(+)
                         AND ur.history_status(+) = 'A'
                         AND dpp_id = dppa_dpp(+)
                         AND acc.history_status(+) = 'A'
                         AND acc.dppa_is_main(+) = '1'
                         AND d_dn = dn_id
                         AND d_pc = pc_id
                         AND d_tp IN ('PRUT',
                                      'PRAL',
                                      'PROZ',
                                      'PROP')
                GROUP BY d_dn, dn_in_doc_num || ' (ЕОС=' || pc_num || ')'
                  HAVING COUNT (DISTINCT dppa_id) <> 1);

        IF l_msg IS NOT NULL
        THEN
            SaveTraceMsg (
                'Знайдено некоректність в даних про спосіб переказу коштів отримувачам відрахувань (не вказано основний рахунок або декілька актуальних записів)!',
                'E');
            SaveTraceMsg (
                'Перелік таких рішень (№ рішення та в дужках - № ЕОС) про відрахування/переплати:',
                'E');
            SaveTraceMsg (l_msg, 'E');
            raise_application_error (
                -20000,
                'Не можу продовжувати формування відомості.');
        END IF;

        UPDATE tmp_prsd ma
           SET d_pd_last =
                   (SELECT MAX (sl.d_pd)
                      FROM tmp_prsd sl
                     WHERE sl.d_pc = ma.d_pc AND sl.d_pr = ma.d_pr)
         WHERE 1 = 1;

        UPDATE tmp_prsd ma
           SET d_dpp =
                   (SELECT dn_dpp
                      FROM deduction
                     WHERE dn_id = d_dn)
         WHERE d_dn IS NOT NULL;

        DELETE FROM tmp_prs
              WHERE 1 = 1;

        IF p_tp IN ('M', 'A')
        THEN
            INSERT INTO tmp_prs (s_tp,
                                 s_pr,
                                 s_pd,
                                 s_ed,
                                 s_sum)
                  SELECT 'NR',
                         d_pr,
                         d_pd_last,
                         d_ed,
                         SUM (CASE
                                  WHEN d_tp IN ('PWI', 'RDN')
                                  THEN
                                      d_sum
                                  WHEN d_tp IN ('PRUT',
                                                'PRAL',
                                                'PROZ',
                                                'PROP')
                                  THEN
                                      0 - d_sum
                              END)
                    FROM tmp_prsd
                GROUP BY d_pr, d_pd_last, d_ed;

            --Контроль на дублікати даних про спосіб виплати по "pdm_is_actual = 'T'". У всіх інших таблицях дублікатів не повинно бути
            SELECT LISTAGG (pd_num, ', ' ON OVERFLOW TRUNCATE WITH COUNT)
                       WITHIN GROUP (ORDER BY pd_num)
              INTO l_msg
              FROM (  SELECT pd_id, pd_num, COUNT (DISTINCT pdm_id)
                        FROM tmp_prs,
                             pd_pay_method z,
                             uss_person.v_sc_change,
                             pc_decision
                       WHERE     s_pd = pdm_pd
                             AND z.history_status = 'A'
                             AND pdm_is_actual = 'T'
                             AND pdm_pd = s_pd
                             AND s_pd = pd_id
                             AND pdm_scc = scc_id
                             AND pdm_pd = pd_id
                    GROUP BY pd_id, pd_num
                      HAVING COUNT (DISTINCT pdm_id) > 1);

            IF l_msg IS NOT NULL
            THEN
                SaveTraceMsg (
                    'Знайдено некоректність в даних про спосіб виплати (декілька актуальних записів?) по наступним рішенням:',
                    'E');
                SaveTraceMsg (l_msg, 'E');
                raise_application_error (
                    -20000,
                    'Не можу продовжувати формування відомості.');
            END IF;

            --!!!Очистка от тех, у кого сумма отчислений получилась больше, чем сумма начислений
            FOR xx IN (SELECT pc_num, s_sum
                         FROM tmp_prs, pc_decision, personalcase
                        WHERE s_pd = pd_id AND pd_pc = pc_id AND s_sum < 0)
            LOOP
                SaveTraceMsg (
                       '!!! Сума відрахувань по справі '
                    || xx.pc_num
                    || ' перевищує суму нарахувань (різниця: '
                    || xx.s_sum
                    || ') - виплачувати від`ємну суму не можу, виключаю справу з відомості!',
                    'E');
            END LOOP;
        END IF;

        --Генерауємо ід-и рядків відомості
        UPDATE tmp_prs
           SET s_id = id_pr_sheet (0)
         WHERE 1 = 1;

        UPDATE tmp_prsd
           SET d_prs =
                   (SELECT s_id
                      FROM tmp_prs
                     WHERE d_pr = s_pr AND d_pd_last = s_pd AND d_ed = s_ed)
         WHERE 1 = 1;

        --Для поверненнь зайво утриманих коштів - в них немає PD - рішення про призначення, є тільки посилання на відрахування
        UPDATE tmp_prsd
           SET d_prs =
                   (SELECT s_id
                      FROM tmp_prs
                     WHERE d_pr = s_pr AND d_ed = s_ed)
         WHERE d_prs IS NULL;

        IF p_tp IN ('M', 'A')
        THEN
            DELETE FROM tmp_prsd
                  WHERE EXISTS
                            (SELECT 1
                               FROM tmp_prs
                              WHERE d_prs = s_id AND s_sum < 0);

            DELETE FROM tmp_prs
                  WHERE s_sum < 0;
        END IF;

        --Створюємо записи відомості для відрахувань
        INSERT INTO tmp_prs (s_tp,
                             s_pr,
                             s_dpp,
                             s_sum)
              SELECT CASE d_tp
                         WHEN 'PRUT' THEN 'AUU'
                         WHEN 'PROP' THEN 'ADV'
                         ELSE 'ABU'
                     END,
                     d_pr,
                     d_dpp,
                     SUM (d_sum)
                FROM tmp_prsd, deduction
               WHERE d_dn = dn_id
            /*AND ((p_tp IN ('M', 'A') AND d_tp IN ('PRAL', 'PROZ', 'PROP'))
              OR (p_tp IN ('MD', 'AD') AND d_tp IN ('PRUT')))*/
            GROUP BY CASE d_tp
                         WHEN 'PRUT' THEN 'AUU'
                         WHEN 'PROP' THEN 'ADV'
                         ELSE 'ABU'
                     END,
                     d_pr,
                     d_dpp;

        --Генерауємо ід-и рядків відомості
        UPDATE tmp_prs
           SET s_id = id_pr_sheet (0)
         WHERE s_id IS NULL;

        UPDATE tmp_prsd
           SET d_prs_dn =
                   (SELECT s_id
                      FROM tmp_prs
                     WHERE     d_pr = s_pr
                           AND d_dpp = s_dpp
                           AND CASE d_tp
                                   WHEN 'PRUT' THEN 'AUU'
                                   WHEN 'PROP' THEN 'ADV'
                                   ELSE 'ABU'
                               END =
                               s_tp)
         WHERE d_tp IN ('PRUT',
                        'PRAL',
                        'PROZ',
                        'PROP');

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_prsd
         WHERE /*((p_tp IN ('M', 'A') AND d_tp IN ('PRAL', 'PROZ', 'PROP'))
             OR (p_tp IN ('MD', 'AD') AND d_tp IN ('PRUT')))
           AND */
                   d_tp IN ('PRUT',
                            'PRAL',
                            'PROZ',
                            'PROP')
               AND d_prs_dn IS NULL;

        IF l_cnt > 0
        THEN
            SaveTraceMsg (
                'Помилка формування рядків відомості для отримувачів відрахувань - не вдалось ідентифікувати рядки відомості для деталей!',
                'E');
        END IF;

        --Проставляємо дані отримувача по дорученням разової виплати
        UPDATE tmp_prs
           SET (s_sc, s_scc) =
                   (SELECT scc_sc, scc_id
                      FROM errand, uss_person.v_sc_change
                     WHERE s_ed = ed_id AND ed_scc = scc_id)
         WHERE s_tp = 'NR' AND s_ed > 0;

        --Проставляємо дані отримувача за методом виплати рішення
        UPDATE tmp_prs
           SET (s_sc, s_scc) =
                   (SELECT scc_sc, scc_id
                      FROM pd_pay_method, uss_person.v_sc_change
                     WHERE     s_pd = pdm_pd
                           AND history_status = 'A'
                           AND pdm_is_actual = 'T'
                           AND pdm_pd = s_pd
                           AND pdm_scc = scc_id)
         WHERE s_tp = 'NR' AND s_sc IS NULL;

        --Якщо не проставився отримувач за методом виплати рішення, проставляємо з рішення-справи
        UPDATE tmp_prs
           SET (s_sc, s_scc) =
                   (SELECT pc_sc, pd_scc
                      FROM pc_decision, personalcase
                     WHERE s_pd = pd_id AND pd_pc = pc_id)
         WHERE s_sc IS NULL AND s_tp = 'NR';

        --!!!Якщо отримувач по зверненню не співпадає з "власником справи" - беремо з звернення. Хоча потрбіно було б копіювати його в рішення !!!
        --Це закрито правильною ініціалізацією рішення та pd_payment. Томо додано "s_sc IS NULL".
        UPDATE tmp_prs
           SET s_sc =
                   (SELECT app_sc
                      FROM pc_decision, ap_payment am, ap_person app
                     WHERE     s_pd = pd_id
                           AND pd_ap = apm_ap
                           AND apm_app = app_id
                           AND am.history_Status = 'A'
                           AND app.history_Status = 'A'),
               s_scc =
                   (SELECT pdm_scc
                      FROM pd_pay_method
                     WHERE     s_pd = pdm_pd
                           AND history_status = 'A'
                           AND pdm_is_actual = 'T')
         WHERE     EXISTS
                       (SELECT 1
                          FROM pc_decision, ap_payment am, ap_person app
                         WHERE     s_pd = pd_id
                               AND pd_ap = apm_ap
                               AND apm_app = app_id
                               AND app_sc IS NOT NULL
                               AND am.history_Status = 'A'
                               AND app.history_Status = 'A'
                               AND app_sc <> s_sc)
               AND s_sc IS NULL
               AND s_tp = 'NR';

        --Шукаємо анкету отримувача, якщо ще не знайшлась --!!! На цьому кроці - зазвичай вже реально одні помилки
        UPDATE tmp_prs
           SET s_scc =
                   NVL (
                       (SELECT pdm_scc
                          FROM pd_pay_method
                         WHERE     s_pd = pdm_pd
                               AND history_status = 'A'
                               AND pdm_is_actual = 'T'),
                       (SELECT sc_scc
                          FROM uss_person.v_socialcard
                         WHERE s_sc = sc_id))
         WHERE s_scc IS NULL AND s_tp = 'NR';

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt > 0
        THEN
            SaveTraceMsg (
                   '!!! Виявлено '
                || l_cnt
                || ' неоднозначностей з ідентифікацією отримувача!',
                'I');
        END IF;

        --Формую таблицю перекодування банків
        --Якщо з будь-якою філією банку або з самим банком є договір, то використовуємо відповідну флію банку. Якщо договору немає, значить що в параметрах вказано, те і використовуємо
        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        INSERT INTO tmp_work_set3 (x_id1, x_id2, x_id3)
            SELECT nb_id,
                   t_org,
                   NVL (
                       (SELECT nbc_nb
                          FROM uss_ndi.v_ndi_nb_contract nbc
                         WHERE     nbc_nb IN
                                       (SELECT sl.nb_id
                                          FROM uss_ndi.v_ndi_bank sl
                                         WHERE    ma.nb_id IN
                                                      (sl.nb_id, sl.nb_nb)
                                               OR ma.nb_nb IN
                                                      (sl.nb_id, sl.nb_nb))
                               AND nbc.history_status = 'A'
                               AND nbc.nbc_is_actual = 'T'
                               AND nbc.com_org = t_org),
                       ma.nb_id)
              FROM uss_ndi.v_ndi_bank  ma,
                   (SELECT DISTINCT t_org
                      FROM tmp_payroll);

        --  SELECT COUNT(DISTINCT s_id) INTO l_cnt FROM tmp_prs WHERE 1 = 1;
        --  SaveTraceMsg('l_cnt='||l_cnt);
        --  SELECT COUNT(s_id) INTO l_cnt FROM tmp_prs WHERE 1 = 1;
        --  SaveTraceMsg('l_cnt='||l_cnt);
        --return;
        --SaveTraceMsg('l_kah_oschad_decode_list='||l_kah_oschad_decode_list);
        --SaveTraceMsg('l_kah_npc_id='||l_kah_npc_id);
        --SaveTraceMsg('l_lock_org='||l_lock_org);

        --Вставляємо в базу рядки відомості для виплати отримувачу допомоги
        IF p_tp IN ('M', 'A')
        THEN
              INSERT ALL
                WHEN x_pay_tp = 'BANK'
                THEN                                               --если банк
                    INTO pr_sheet (prs_id,
                                   prs_pr,
                                   prs_pc,
                                   prs_pa,
                                   prs_num,
                                   prs_pc_num,
                                   prs_tp,
                                   prs_nb,
                                   prs_account,
                                   prs_fn,
                                   prs_ln,
                                   prs_mn,
                                   prs_inn,
                                   prs_sum,
                                   prs_pay_dt,
                                   prs_doc_num,
                                   prs_st,
                                   prs_ed)
                      VALUES (
                                 s_id,
                                 t_id,
                                 pd_pc,
                                 pd_pa,
                                 0,
                                 pc_num,
                                 'PB'                       /*виплата банком*/
                                     ,
                                 x_nb_ex,
                                 x_account,
                                 sci_fn,
                                 sci_ln,
                                 sci_mn,
                                 sci_inn,
                                 s_sum,
                                 TO_DATE (
                                        LPAD ('' || NVL (x_pay_dt, 1),
                                              2,
                                              '0')
                                     || TO_CHAR (l_start_dt, '.MM.YYYY'),
                                     'DD.MM.YYYY'),
                                 x_doc_num,
                                 'NA',
                                 s_ed_x)
                WHEN x_pay_tp = 'POST'
                THEN                                              --если почта
                    INTO pr_sheet (prs_id,
                                   prs_pr,
                                   prs_pc,
                                   prs_pa,
                                   prs_num,
                                   prs_pc_num,
                                   prs_tp,
                                   prs_fn,
                                   prs_ln,
                                   prs_mn,
                                   prs_index,
                                   prs_address,
                                   prs_kaot,
                                   prs_street,
                                   prs_ns,
                                   prs_building,
                                   prs_block,
                                   prs_apartment,
                                   prs_inn,
                                   prs_sum,
                                   prs_pay_dt,
                                   prs_doc_num,
                                   prs_st,
                                   prs_nd,
                                   prs_ed)
                      VALUES (
                                 s_id,
                                 t_id,
                                 pd_pc,
                                 pd_pa,
                                 0,
                                 pc_num,
                                 'PP',                          --Пенся почтой
                                 sci_fn,
                                 sci_ln,
                                 sci_mn,
                                 x_index,
                                 x_address,
                                 x_kaot,
                                 x_street_ex,
                                 x_ns,
                                 x_building,
                                 x_block,
                                 x_apartment,
                                 sci_inn,
                                 s_sum,
                                 TO_DATE (
                                        LPAD ('' || NVL (x_pay_dt, 1),
                                              2,
                                              '0')
                                     || TO_CHAR (l_start_dt, '.MM.YYYY'),
                                     'DD.MM.YYYY'),
                                 x_doc_num,
                                 'NA',
                                 x_nd,
                                 s_ed_x)
                WITH
                    src_accounts
                    AS
                        (SELECT s_id              AS x_id,
                                pdm_nb            AS x_nb,
                                pdm_pay_tp        AS x_pay_tp,
                                pdm_index         AS x_index,
                                pdm_street        AS x_street,
                                pdm_kaot          AS x_kaot,
                                pdm_ns            AS x_ns,
                                pdm_building      AS x_building,
                                pdm_block         AS x_block,
                                pdm_apartment     AS x_apartment,
                                pdm_pay_dt        AS x_pay_dt,
                                pd_ap             AS x_ap,
                                pdm_nd            AS x_nd,
                                pdm_account       AS x_account
                           FROM tmp_prs, pd_pay_method, pc_decision
                          WHERE     s_ed = 0
                                AND s_pd = pdm_pd
                                AND history_status = 'A'
                                AND pdm_is_actual = 'T'
                                AND s_pd = pd_id
                         UNION ALL
                         SELECT s_id,
                                ed_nb,
                                ed_pay_tp,
                                ed_index,
                                ed_street,
                                ed_kaot,
                                ed_ns,
                                ed_building,
                                ed_block,
                                ed_apartment,
                                ed_pay_dt,
                                ed_ap,
                                ed_nd,
                                ed_account
                           FROM tmp_prs, errand
                          WHERE s_ed > 0 AND s_ed = ed_id),
                    accounts
                    AS
                        (SELECT acc.*,
                                   NVL (
                                       x_street,
                                       (SELECT    (CASE
                                                       WHEN nsrt_name
                                                                IS NOT NULL
                                                       THEN
                                                           nsrt_name || ' '
                                                       ELSE
                                                           ''
                                                   END)
                                               || ns_name
                                          FROM uss_ndi.v_ndi_street
                                               LEFT JOIN
                                               uss_ndi.V_NDI_STREET_TYPE
                                                   ON ns_nsrt = nsrt_id
                                         WHERE x_ns = ns_id))
                                || ', '
                                || x_building
                                || CASE
                                       WHEN x_block IS NOT NULL
                                       THEN
                                           ' корп. ' || x_block
                                   END
                                || CASE
                                       WHEN x_apartment IS NOT NULL
                                       THEN
                                           ', кв. ' || x_apartment
                                   END                        AS x_address,
                                NVL (
                                    x_street,
                                    (SELECT    (CASE
                                                    WHEN nsrt_name
                                                             IS NOT NULL
                                                    THEN
                                                        nsrt_name || ' '
                                                    ELSE
                                                        ''
                                                END)
                                            || ns_name
                                       FROM uss_ndi.v_ndi_street
                                            LEFT JOIN
                                            uss_ndi.V_NDI_STREET_TYPE
                                                ON ns_nsrt = nsrt_id
                                      WHERE x_ns = ns_id))    AS x_street_ex,
                                get_pasp_info (2, x_ap)       AS x_doc_num --!!! Мабуть, потрібно замінити на вичитку документу за ED_SCC для доручень !!!.
                           FROM src_accounts acc)
                SELECT /*+ index(sc_document ifk_scd_sc)*/
                       s_id,
                       pd_pc,
                       pd_pa,
                       CASE
                           WHEN p_npc = l_vpo_npc_id
                           THEN
                               l_ob_nb_id                              -- Ощад
                           WHEN     p_npc = l_kah_npc_id
                                AND l_lock_org = 56500
                                AND INSTR (l_kah_oschad_decode_list,
                                              '#'
                                           || (SELECT nb_mfo
                                                 FROM uss_ndi.v_ndi_bank
                                                WHERE nb_id = x_nb)
                                           || '#') > 0
                           THEN
                               l_ob_nb_id -- Ощад для обдаровинх з херсонського ДСЗН по постраждалим від каховської ГЕС
                           WHEN s_ed > 0
                           THEN
                               (SELECT x_id3
                                  FROM tmp_work_set3
                                 WHERE x_id1 = x_nb AND x_id2 = t_org)
                           ELSE
                               (SELECT x_id3
                                  FROM tmp_work_set3
                                 WHERE x_id1 = x_nb AND x_id2 = t_org)
                       END
                           AS x_nb_ex,
                       pc_num,
                       x_account,
                       sci_fn,
                       sci_ln,
                       sci_mn,
                       uss_person.api$sc_tools.get_numident (s_sc)
                           AS sci_inn, -- (SELECT MAX(scd_number) FROM uss_person.v_sc_document sc WHERE scd_sc = s_sc AND scd_ndt = 5 AND scd_st IN ('1', 'A')) AS sci_inn,
                       x_pay_tp,
                       x_index,
                       x_address,
                       x_kaot,
                       x_street_ex,
                       x_ns,
                       x_building,
                       x_block,
                       x_apartment,
                       t_id,
                       s_sum,
                       x_pay_dt,
                       x_doc_num,
                       x_nd,
                       CASE WHEN s_ed > 0 THEN s_ed END
                           AS s_ed_x
                  FROM tmp_payroll,
                       tmp_prs,
                       personalcase,
                       pc_decision  pd,
                       uss_person.v_sc_change,
                       uss_person.v_sc_identity,
                       accounts
                 WHERE     s_pd = pd_id
                       AND s_tp = 'NR'
                       AND pd_pc = pc_id
                       AND s_scc = scc_id
                       AND scc_sci = sci_id
                       AND t_id = s_pr
                       AND x_id = s_id;
        END IF;

        --return;
        --Вставляємо в базу рядки відомості для виплати отримувачу відрахування
        IF p_tp IN ('M',
                    'A',
                    'MD',
                    'AD')
        THEN
            INSERT INTO pr_sheet (prs_id,
                                  prs_pr,
                                  prs_num,
                                  prs_tp,
                                  prs_nb,
                                  prs_account,
                                  prs_fn,
                                  prs_inn,
                                  prs_sum,
                                  prs_st,
                                  prs_dpp)
                SELECT s_id,
                       t_id,
                       0,
                       s_tp,
                       dppa_nb,
                       dppa_account,
                       dpp_name,
                       dpp_tax_code,
                       s_sum,
                       'NA',
                       s_dpp
                  FROM tmp_payroll,
                       tmp_prs,
                       uss_ndi.ndi_pay_person      ur,
                       uss_ndi.ndi_pay_person_acc  acc
                 WHERE     t_id = s_pr
                       AND s_tp IN ('AUU', 'ABU', 'ADV')
                       AND s_dpp = dpp_id
                       AND ur.history_status = 'A'
                       AND dpp_id = dppa_dpp
                       AND acc.history_status = 'A'
                       AND dppa_is_main = '1';
        END IF;

        --Передрозрахунок ід-ів таблиці PRSD
        UPDATE tmp_prsd
           SET d_id = id_pr_sheet_detail (0)
         WHERE d_pd IS NOT NULL;

        --return;
        --Формуємо кінцеві рядки деталей рядків відомості
        INSERT INTO pr_sheet_detail (prsd_id,
                                     prsd_prsd,
                                     prsd_prs,
                                     prsd_prs_dn,
                                     prsd_pc,
                                     prsd_pa,
                                     prsd_tp,
                                     prsd_pr,
                                     prsd_month,
                                     prsd_sum,
                                     prsd_is_payed,
                                     prsd_full_sum,
                                     prsd_npt)
            SELECT d_id,
                   NULL,
                   CASE WHEN p_tp IN ('M', 'A') THEN d_prs ELSE d_prs_dn END,
                   d_prs_dn,
                   pd_pc,
                   pd_pa,
                   d_tp,
                   d_pr,
                   d_month,
                   d_sum,
                   'F',
                   d_sum,
                   d_npt
              FROM tmp_prsd, pc_decision
             WHERE d_pd = pd_id;

        --RETURN;
        FOR xx
            IN (  SELECT acd_id x_acd, COUNT (DISTINCT d_id) x_cnt
                    FROM ac_detail, tmp_prsd, accrual
                   WHERE     acd_ac = ac_id
                         AND d_pc = ac_pc
                         AND (   d_pd = acd_pd
                              OR (    d_pd_last = acd_pd
                                  AND d_tp IN ('PRUT',
                                               'PRAL',
                                               'PROZ',
                                               'PROP'))
                              OR (d_pd IS NULL AND acd_pd IS NULL))
                         AND (   d_dn = acd_dn
                              OR (    d_dn IS NULL
                                  AND acd_dn IS NULL
                                  AND d_tp IN ('PRUT',
                                               'PRAL',
                                               'PROZ',
                                               'PROP')
                                  AND acd_op IN (123,
                                                 124,
                                                 125,
                                                 278,
                                                 280,
                                                 30,
                                                 31                    /*,32*/
                                                   ))
                              OR (    d_dn IS NULL
                                  AND acd_dn IS NULL
                                  AND d_tp IN ('PWI', 'RDN')
                                  AND acd_op IN (1,
                                                 2,
                                                 3,
                                                 127,
                                                 128,
                                                 133,
                                                 143,
                                                 183,
                                                 184,
                                                 196,
                                                 197,
                                                 202,
                                                 203,
                                                 212,
                                                 213,
                                                 222,
                                                 237,
                                                 256,
                                                 257,
                                                 217,
                                                 216,
                                                 10,
                                                 33))
                              OR (    d_dn IS NULL
                                  AND acd_dn IS NOT NULL
                                  AND d_tp IN ('RDN')
                                  AND acd_op IN (10, 33)))
                         AND (   (acd_op NOT IN (10, 33))
                              OR (    acd_op IN (10, 33)
                                  AND d_ed = acd_ed
                                  AND d_tp IN ('RDN')))
                         AND d_npt = CASE
                                         WHEN     acd_op IN (123,
                                                             124,
                                                             125,
                                                             278,
                                                             280,
                                                             30,
                                                             31        /*,32*/
                                                               )
                                              AND acd_npt = 337
                                         THEN
                                             167
                                         ELSE
                                             acd_npt
                                     END
                         AND d_month = TRUNC (acd_start_dt, 'MM')
                         AND d_ed = NVL (acd_ed, 0)
                         AND acd_op IN (SELECT x_id FROM tmp_work_ids3)
                         AND ac_detail.history_status = 'A'
                         AND EXISTS
                                 (SELECT 1
                                    FROM tmp_work_set1
                                   WHERE acd_id = x_id1)
                GROUP BY acd_id)
        LOOP
            IF xx.x_cnt > 1
            THEN
                SaveTraceMsg (
                       '!!! Неоднозначно визначається рядок відомості для рядка нарахувань. ID='
                    || xx.x_acd
                    || '!',
                    'E');
            END IF;
        END LOOP;

        --Проставляємо в нарахування ід-и рядків, до яких вони були включені
        IF p_tp IN ('M', 'A')
        THEN                     --Для відомостей виплати отримувачам допомоги
            UPDATE ac_detail
               SET acd_prsd =
                       (SELECT d_id
                          FROM tmp_prsd
                         WHERE d_ids LIKE '%#' || acd_id || '#%')
             WHERE     acd_op IN (SELECT x_id FROM tmp_work_ids3)
                   AND ac_detail.history_status = 'A'
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_work_set1
                             WHERE acd_id = x_id1);
        /*UPDATE ac_detail
          SET acd_prsd = (SELECT DISTINCT d_id
                          FROM tmp_prsd, accrual
                          WHERE acd_ac = ac_id
                            AND d_pc = ac_pc
                            AND (d_pd = acd_pd OR (d_pd_last = acd_pd AND d_tp IN ('PRUT','PRAL', 'PROZ', 'PROP')) OR (d_pd IS NULL  AND acd_pd IS NULL))
                            AND (d_dn = acd_dn
                              OR (d_dn IS NULL AND acd_dn IS NULL AND d_tp IN ('PRUT','PRAL', 'PROZ', 'PROP') AND acd_op IN (123,124,125,278,280, 30,31\*,32*\))
                              OR (d_dn IS NULL AND acd_dn IS NULL AND d_tp IN ('PWI') AND acd_op IN (1,2,3,127,128,133,143,183,184,196,197,202,203,212,213,222,237,256,257,217,216))
                              OR (d_dn IS NULL AND acd_dn IS NOT NULL AND d_tp IN ('RDN') AND acd_op IN (10, 33)))
                            AND ((acd_op not IN (10, 33))
                              OR (acd_op IN (10, 33) AND d_ed = acd_ed AND d_tp IN ('RDN')))
                            AND d_npt = CASE WHEN acd_op IN (123,124,125,278,280, 30,31\*,32*\) AND acd_npt = 337 THEN 167 ELSE acd_npt END
                            AND d_month = TRUNC(acd_start_dt, 'MM')
                            AND (d_ed = NVL(acd_ed, 0) OR (d_tp IN ('PRUT','PRAL', 'PROZ', 'PROP'))))
          WHERE acd_op IN (SELECT x_id FROM tmp_work_ids3)
            AND ac_detail.history_status = 'A'
            AND EXISTS (SELECT 1
                        FROM tmp_work_set1
                        WHERE acd_id = x_id1);*/
        ELSIF p_tp IN ('MD', 'AD')
        THEN                 --Для відомостей виплати отримувачам відрахуваннь
            UPDATE ac_detail
               SET acd_prsd_sa =
                       (SELECT d_id
                          FROM tmp_prsd
                         WHERE d_ids LIKE '%#' || acd_id || '#%')
             WHERE     acd_op IN (SELECT x_id FROM tmp_work_ids3)
                   AND ac_detail.history_status = 'A'
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_work_set1
                             WHERE acd_id = x_id1);
        /*UPDATE ac_detail
          SET acd_prsd_sa = (SELECT DISTINCT d_id
                             FROM tmp_prsd, accrual
                             WHERE acd_ac = ac_id
                               AND d_pc = ac_pc
                               AND (d_pd = acd_pd OR (d_pd_last = acd_pd AND d_tp IN ('PRUT','PRAL', 'PROZ', 'PROP')) OR (d_pd IS NULL  AND acd_pd IS NULL))
                               AND (d_dn = acd_dn
                                 OR (d_dn IS NULL AND acd_dn IS NULL AND d_tp IN ('PRUT','PRAL', 'PROZ', 'PROP') AND acd_op IN (123,124,125,278,280, 30,31\*,32*\))
                                 OR (d_dn IS NULL AND acd_dn IS NULL AND d_tp IN ('PWI') AND acd_op IN (1,2,3,127,128,133,143,183,184,196,197,202,203,212,213,222,237,256,257,217,216))
                                 OR (d_dn IS NULL AND acd_dn IS NOT NULL AND d_tp IN ('RDN') AND acd_op IN (10, 33)))
                               AND ((acd_op not IN (10, 33))
                                 OR (acd_op IN (10, 33) AND d_ed = acd_ed AND d_tp IN ('RDN')))
                               AND d_npt = CASE WHEN acd_op IN (123,124,125,278,280, 30,31\*,32*\) AND acd_npt = 337 THEN 167 ELSE acd_npt END
                               AND d_month = TRUNC(acd_start_dt, 'MM')
                               AND (d_ed = NVL(acd_ed, 0) OR (d_tp IN ('PRUT','PRAL', 'PROZ', 'PROP'))))
          WHERE acd_op IN (SELECT x_id FROM tmp_work_ids3)
            AND ac_detail.history_status = 'A'
            AND EXISTS (SELECT 1
                        FROM tmp_work_set1
                        WHERE acd_id = x_id1);*/
        END IF;

        --return;
        --Перевіряємо, чи правильно ми проставили всі зв'язки всіх рядків проводок з рядками відомості. Контроль по ІД-ам (кількість та склад). !!! Якщо буде "підторможувати" на великих районах - необхідно переписати на лінійний запит.
        FOR xx IN (SELECT d_id, d_ids_cnt, d_ids FROM tmp_prsd)
        LOOP
            IF p_tp IN ('M', 'A')
            THEN
                SELECT COUNT (*),
                          '#'
                       || LISTAGG (acd_id, '#')
                              WITHIN GROUP (ORDER BY acd_id)
                       || '#'
                  INTO l_cnt, l_msg
                  FROM ac_detail
                 WHERE acd_prsd = xx.d_id;
            ELSIF p_tp IN ('MD', 'AD')
            THEN
                SELECT COUNT (*),
                          '#'
                       || LISTAGG (acd_id, '#')
                              WITHIN GROUP (ORDER BY acd_id)
                       || '#'
                  INTO l_cnt, l_msg
                  FROM ac_detail
                 WHERE acd_prsd_sa = xx.d_id;
            END IF;

            IF    xx.d_ids_cnt <> l_cnt
               OR NVL (l_msg, '-') <> NVL (xx.d_ids, '-')
            THEN
                raise_application_error (
                    -20000,
                       'Для проводок <'
                    || xx.d_ids
                    || '> некоректно проставлений зв''язок з деталлю виплатної відомості!');
            END IF;
        END LOOP;

        /*
          SELECT count(*)
          INTO l_cnt
          FROM ac_detail, tmp_work_set1
          WHERE acd_id = x_id1
            AND acd_prsd IS NULL;
        return;
          IF l_cnt > 0 THEN
            raise_application_error(-20000, 'У '||l_cnt||' використаних для формуваннях відомості проводках не проставилось посилання на детялі відомостей!');
          END IF;*/

        --Оновлюємо дані про суми виплаченого (включеного у відомості) по реєстраційному запису нарахувань
        DELETE FROM tmp_work_ids1
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids1 (x_id)
            SELECT acd_ac
              FROM tmp_work_set1, ac_detail
             WHERE acd_id = x_id1 AND ac_detail.history_status = 'A';

        API$ACCRUAL.actuilize_payed_sum (1);

        ---Визначаємо номери відомостей
        FOR xx IN (SELECT t_id, t_month, t_pay_tp
                     FROM tmp_payroll
                    WHERE t_pay_tp = 'POST')
        LOOP
            IF xx.t_pay_tp = 'POST'
            THEN
                MERGE INTO pr_sheet prs
                     USING (SELECT prs_id                                   AS u_id, --вычисляем максимальный номер ведомости по уже сформированным по prs_pay_dt, prs_nd, prs_index - ведомостям в этом месяце
                                     NVL (
                                         (SELECT MAX (sprs.prs_num)
                                            FROM payroll spr, pr_sheet sprs
                                           WHERE     sprs.prs_pr = spr.pr_id
                                                 AND spr.pr_pay_tp = 'POST'
                                                 AND spr.pr_month =
                                                     xx.t_month
                                                 AND sprs.prs_index =
                                                     ma.prs_index
                                                 AND (   sprs.prs_nd =
                                                         ma.prs_nd
                                                      OR (    sprs.prs_nd
                                                                  IS NULL
                                                          AND ma.prs_nd
                                                                  IS NULL)) /*
AND sprs.prs_pay_dt = ma.prs_pay_dt*/
                                                                           ),
                                         0)
                                   + DENSE_RANK ()
                                         OVER (
                                             PARTITION BY prs_index
                                             ORDER BY
                                                 prs_index,
                                                 prs_nd,
                                                 prs_pay_dt,
                                                 TRUNC (
                                                       x_rownum
                                                     / (l_portion + 1)))    u_number --номери відомостей рахуємо по даті виплати, індексу та порціям (10 людей на відомість)
                              FROM (SELECT prs_pr                  AS pr_id,
                                           prs_id,
                                           prs_inn,
                                           prs_nd,
                                           prs_pay_dt,
                                           prs_index,
                                           ROW_NUMBER ()
                                               OVER (
                                                   PARTITION BY prs_index,
                                                                prs_pay_dt
                                                   ORDER BY
                                                       prs_index,
                                                       prs_nd,
                                                       prs_pay_dt,
                                                       prs_inn)    AS x_rownum
                                      FROM pr_sheet
                                     WHERE prs_pr = xx.t_id) ma)
                        ON (prs_id = u_id)
                WHEN MATCHED
                THEN
                    UPDATE SET prs_num = u_number;
            ELSIF xx.t_pay_tp = 'BANK'
            THEN
                MERGE INTO pr_sheet prs
                     USING (SELECT prs_id                                      AS u_id, --вычисляем максимальный номер ведомости по уже сформированным по prs_pay_dt, prs_nb - ведомостям в этом месяце
                                     NVL (
                                         (SELECT MAX (sprs.prs_num)
                                            FROM payroll spr, pr_sheet sprs
                                           WHERE     sprs.prs_pr = spr.pr_id
                                                 AND spr.pr_pay_tp = 'BANK'
                                                 AND spr.pr_month =
                                                     xx.t_month
                                                 AND sprs.prs_nb = ma.prs_nb
                                                 AND sprs.prs_pay_dt =
                                                     ma.prs_pay_dt),
                                         0)
                                   + DENSE_RANK ()
                                         OVER (ORDER BY prs_nb, prs_pay_dt)    u_number --номери відомостей рахуємо по даті виплати та банку
                              FROM pr_sheet ma
                             WHERE prs_pr = xx.t_id)
                        ON (prs_id = u_id)
                WHEN MATCHED
                THEN
                    UPDATE SET prs_num = u_number;
            END IF;
        END LOOP;

        UPDATE payroll
           SET (pr_sum, pr_pc_cnt) =
                   (SELECT SUM (
                               CASE
                                   WHEN    (    pr_tp IN ('M', 'A')
                                            AND prs_tp IN ('PP', 'PB'))
                                        OR pr_tp IN ('MD', 'AD')
                                   THEN
                                       prs_sum
                               END),
                           COUNT (
                               DISTINCT
                                   CASE
                                       WHEN pr_tp IN ('M', 'A') THEN prs_pc
                                       WHEN pr_tp IN ('MD', 'AD') THEN prs_id
                                   END)
                      FROM pr_sheet
                     WHERE prs_pr = pr_id)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_payroll
                     WHERE t_id = pr_id);

        FOR l_pr IN (SELECT *
                       FROM payroll, tmp_payroll
                      WHERE t_id = pr_id)
        LOOP
            --Створено відомість: id=#, тип=#, орган=#, код створення=#, місяць=#, спосіб виплати=#, кількість=#, сума=#, код відомості=#
            write_prs_log (
                l_pr.pr_id,
                NULL,
                TOOLS.GetHistSession,
                'C',
                   CHR (38)
                || '299#'
                || l_pr.pr_id
                || '#'
                || l_pr.pr_tp
                || '#'
                || l_pr.com_org
                || '#'
                || l_pr.pr_code
                || '#'
                || l_pr.pr_month
                || '#'
                || l_pr.pr_pay_tp
                || '#'
                || l_pr.pr_pc_cnt
                || '#'
                || l_pr.pr_sum
                || '#'
                || l_pr.pr_npc,
                NULL);
        END LOOP;

        l_cnt := 0;
        l_msg := ',';

        IF p_tp IN ('M', 'A')
        THEN
            FOR cc
                IN (WITH
                        p
                        AS
                            (  SELECT prs_id                         AS p_prs,
                                      prs_pc                         AS p_pc,
                                      prs_sum                        AS p_sum,
                                      prs_pc_num                     AS p_pc_num,
                                      t_org                          AS p_org, -- prsd_id AS p_prsd,
                                      SUM (
                                          DECODE (prsd_tp,
                                                  'PWI', prsd_sum,
                                                  'RDN', prsd_sum,
                                                  -1 * prsd_sum))    p_d_sum
                                 FROM uss_esr.PR_SHEET_DETAIL prsd
                                      JOIN uss_esr.PR_SHEET prs
                                          ON prsd_prs = prs_id
                                      JOIN tmp_payroll ON t_id = prs_pr -- filter HERE
                             GROUP BY prs_id,
                                      prs_pc,
                                      prs_sum,
                                      prs_pc_num,
                                      t_org                     /*,  prsd_id*/
                                           ),
                        a
                        AS
                            (  SELECT prsd_prs    AS a_prs, --  prsd_id AS a_prsd,
                                      NVL (
                                          SUM (
                                                api$accrual.xsign (acd_op)
                                              * acd_sum),
                                          0)      AS a_sum
                                 FROM uss_esr.pr_sheet_detail prsd
                                      LEFT JOIN uss_esr.ac_detail acd
                                          ON     acd_prsd = prsd_id
                                             AND acd.history_status = 'A'
                                             AND acd_st != 'U'   /*OP_ID=125*/
                                      JOIN tmp_payroll ON t_id = prsd_pr -- filter HERE
                                WHERE prsd_prs IS NOT NULL
                             GROUP BY prsd_prs                  /*,  prsd_id*/
                                              )
                      SELECT p_org,
                             p_pc_num,
                             p_sum,
                             p_d_sum,
                             a_sum
                        FROM p JOIN a ON p_prs = a_prs   --AND p_prsd = a_prsd
                       WHERE    p_sum != p_d_sum
                             OR p_sum != a_sum
                             OR p_d_sum != a_sum
                    ORDER BY 1, 2)
            LOOP
                IF LENGTH (l_msg) < 3800
                THEN
                    l_msg :=
                           l_msg
                        || ' ОСЗН '
                        || cc.p_org
                        || ' ЕОС '
                        || cc.p_pc_num
                        || ' ('
                        || cc.p_sum
                        || '~'
                        || cc.p_d_sum
                        || '~'
                        || cc.a_sum
                        || '),';
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;
        ELSIF p_tp IN ('MD', 'AD')
        THEN
            FOR cc
                IN (WITH
                        p
                        AS
                            (  SELECT prs_id             AS p_prs,
                                      prs_pc             AS p_pc,
                                      prs_sum            AS p_sum,
                                      prs_pc_num         AS p_pc_num,
                                      t_org              AS p_org, -- prsd_id AS p_prsd,
                                      SUM (prsd_sum)     p_d_sum
                                 FROM uss_esr.PR_SHEET_DETAIL prsd
                                      JOIN uss_esr.PR_SHEET prs
                                          ON prsd_prs = prs_id
                                      JOIN tmp_payroll ON t_id = prs_pr -- filter HERE
                             GROUP BY prs_id,
                                      prs_pc,
                                      prs_sum,
                                      prs_pc_num,
                                      t_org                     /*,  prsd_id*/
                                           ),
                        a
                        AS
                            (  SELECT prsd_prs    AS a_prs, --  prsd_id AS a_prsd,
                                      NVL (
                                          SUM (
                                                -1
                                              * api$accrual.xsign (acd_op)
                                              * acd_sum),
                                          0)      AS a_sum
                                 FROM uss_esr.pr_sheet_detail prsd
                                      LEFT JOIN uss_esr.ac_detail acd
                                          ON     acd_prsd_sa = prsd_id
                                             AND acd.history_status = 'A'
                                             AND acd_st != 'U'   /*OP_ID=125*/
                                      JOIN tmp_payroll ON t_id = prsd_pr -- filter HERE
                                WHERE prsd_prs IS NOT NULL
                             GROUP BY prsd_prs                  /*,  prsd_id*/
                                              )
                      SELECT p_org,
                             p_pc_num,
                             p_sum,
                             p_d_sum,
                             a_sum
                        FROM p JOIN a ON p_prs = a_prs   --AND p_prsd = a_prsd
                       WHERE    p_sum != p_d_sum
                             OR p_sum != a_sum
                             OR p_d_sum != a_sum
                    ORDER BY 1, 2)
            LOOP
                IF LENGTH (l_msg) < 3800
                THEN
                    l_msg :=
                           l_msg
                        || ' ОСЗН '
                        || cc.p_org
                        || ' ЕОС '
                        || cc.p_pc_num
                        || ' ('
                        || cc.p_sum
                        || '~'
                        || cc.p_d_sum
                        || '~'
                        || cc.a_sum
                        || '),';
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;
        END IF;

        --return;
        IF l_cnt > 0
        THEN
            SaveTraceMsg (
                   'Невідповідність сум у '
                || l_cnt
                || ' рядках відомостей, зокрема для :'
                || TRIM (BOTH ',' FROM l_msg),
                'E');
            raise_application_error (
                -20000,
                   'Невідповідність сум у '
                || l_cnt
                || ' рядках відомостей, деталі у протоколі');
        END IF;

        l_cnt := 0;
        l_msg := ',';

        IF p_tp IN ('M', 'A')
        THEN
            FOR xx
                IN (SELECT prs_id         AS p_prs,
                           prs_pc         AS p_pc,
                           prs_sum        AS p_sum,
                           prs_pc_num     AS p_pc_num,
                           t_org          AS p_org,
                           prsd_id        AS p_prsd,
                           prsd_sum       AS p_d_sum
                      FROM uss_esr.PR_SHEET_DETAIL,
                           uss_esr.PR_SHEET,
                           tmp_payroll
                     WHERE     prsd_prs = prs_id
                           AND t_id = prs_pr
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM uss_esr.ac_detail acd
                                     WHERE     acd_prsd = prsd_id
                                           AND acd.history_status = 'A'))
            LOOP
                IF LENGTH (l_msg) < 3800
                THEN
                    l_msg :=
                           l_msg
                        || ' ОСЗН '
                        || xx.p_org
                        || ' ЕОС '
                        || xx.p_pc_num
                        || ' ('
                        || xx.p_sum
                        || '~'
                        || xx.p_d_sum
                        || '),';
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;
        ELSIF p_tp IN ('MD', 'AD')
        THEN
            FOR xx
                IN (SELECT prs_id         AS p_prs,
                           prs_pc         AS p_pc,
                           prs_sum        AS p_sum,
                           prs_pc_num     AS p_pc_num,
                           t_org          AS p_org,
                           prsd_id        AS p_prsd,
                           prsd_sum       AS p_d_sum
                      FROM uss_esr.PR_SHEET_DETAIL,
                           uss_esr.PR_SHEET,
                           tmp_payroll
                     WHERE     prsd_prs = prs_id
                           AND t_id = prs_pr
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM uss_esr.ac_detail acd
                                     WHERE     acd_prsd_sa = prsd_id
                                           AND acd.history_status = 'A'))
            LOOP
                IF LENGTH (l_msg) < 3800
                THEN
                    l_msg :=
                           l_msg
                        || ' ОСЗН '
                        || xx.p_org
                        || ' ЕОС '
                        || xx.p_pc_num
                        || ' ('
                        || xx.p_sum
                        || '~'
                        || xx.p_d_sum
                        || '),';
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;
        END IF;

        IF l_cnt > 0
        THEN
            SaveTraceMsg (
                   'У '
                || l_cnt
                || ' деталях рядків відомостей виявлено відсутність прив''язки до рядків проводок, зокрема для :'
                || TRIM (BOTH ',' FROM l_msg),
                'E');
            raise_application_error (
                -20000,
                   'У '
                || l_cnt
                || ' деталях рядків відомостей виявлено відсутність прив''язки до рядків проводок, деталі у протоколі');
        END IF;

        --return;
        l_cnt := 0;
        l_msg := ',';

        IF p_tp IN ('M', 'A')
        THEN
            FOR xx
                IN (SELECT prs_id         AS p_prs,
                           prs_pc         AS p_pc,
                           prs_sum        AS p_sum,
                           prs_pc_num     AS p_pc_num,
                           t_org          AS p_org,
                           prsd_id        AS p_prsd,
                           prsd_sum       AS p_d_sum
                      FROM uss_esr.PR_SHEET_DETAIL,
                           uss_esr.PR_SHEET,
                           tmp_payroll
                     WHERE     prsd_prs = prs_id
                           AND t_id = prs_pr
                           AND prsd_sum <>
                               NVL (
                                   (SELECT   DECODE (prsd_tp,
                                                     'PWI', 1,
                                                     'RDN', 1,
                                                     -1)
                                           * SUM (
                                                   api$accrual.xsign (acd_op)
                                                 * acd_sum)
                                      FROM uss_esr.ac_detail acd
                                     WHERE     acd_prsd = prsd_id
                                           AND acd.history_status = 'A'),
                                   0))
            LOOP
                IF LENGTH (l_msg) < 3800
                THEN
                    l_msg :=
                           l_msg
                        || ' ОСЗН '
                        || xx.p_org
                        || ' ЕОС '
                        || xx.p_pc_num
                        || ' ('
                        || xx.p_sum
                        || '~'
                        || xx.p_d_sum
                        || '),';
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;
        ELSIF p_tp IN ('MD', 'AD')
        THEN
            FOR xx
                IN (SELECT prs_id         AS p_prs,
                           prs_pc         AS p_pc,
                           prs_sum        AS p_sum,
                           prs_pc_num     AS p_pc_num,
                           t_org          AS p_org,
                           prsd_id        AS p_prsd,
                           prsd_sum       AS p_d_sum
                      FROM uss_esr.PR_SHEET_DETAIL,
                           uss_esr.PR_SHEET,
                           tmp_payroll
                     WHERE     prsd_prs = prs_id
                           AND t_id = prs_pr
                           AND prsd_sum <>
                               NVL (
                                   (SELECT SUM (
                                                 -1
                                               * api$accrual.xsign (acd_op)
                                               * acd_sum)
                                      FROM uss_esr.ac_detail acd
                                     WHERE     acd_prsd_sa = prsd_id
                                           AND acd.history_status = 'A'),
                                   0))
            LOOP
                IF LENGTH (l_msg) < 3800
                THEN
                    l_msg :=
                           l_msg
                        || ' ОСЗН '
                        || xx.p_org
                        || ' ЕОС '
                        || xx.p_pc_num
                        || ' ('
                        || xx.p_sum
                        || '~'
                        || xx.p_d_sum
                        || '),';
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;
        END IF;

        IF l_cnt > 0
        THEN
            SaveTraceMsg (
                   'У '
                || l_cnt
                || ' деталях рядків відомостей виявлено неспівпадіння суми та суми  прив''язаних до неї рядків проводок, зокрема для :'
                || TRIM (BOTH ',' FROM l_msg),
                'E');
            raise_application_error (
                -20000,
                   'У '
                || l_cnt
                || ' деталях рядків відомостей виявлено неспівпадіння суми та суми  прив''язаних до неї рядків проводок, деталі у протоколі');
        END IF;


        SaveTraceMsg ('Завершено формування відомості (нарахування)!');
        TOOLS.release_lock (l_lock);
        RETURN;
    END create_payroll;

    PROCEDURE approve_payroll (p_pr_id payroll.pr_id%TYPE)
    IS
    BEGIN
        -- переводим из C в P
        UPDATE payroll
           SET pr_st = 'P'
         WHERE pr_id = p_pr_id AND pr_st = 'C';

        write_prs_log (p_pr_id,
                       NULL,
                       TOOLS.GetHistSession,
                       'P',
                       CHR (38) || '294',
                       'C');
    END approve_payroll;

    PROCEDURE send_payroll (p_pr_id payroll.pr_id%TYPE)
    IS
    BEGIN
        -- #80146 OPERVIEIEV
        init_com_orgs (NULL);

        -- переводим из P в V
        UPDATE payroll
           SET pr_st = 'V'
         WHERE     pr_id = p_pr_id
               AND pr_st = 'P'
               AND com_org IN (SELECT x_id FROM TMP_COM_ORGS);

        write_prs_log (p_pr_id,
                       NULL,
                       TOOLS.GetHistSession,
                       'V',
                       CHR (38) || '295',
                       'P');
    END send_payroll;

    PROCEDURE fix_payroll (p_pr_id payroll.pr_id%TYPE)
    IS
    BEGIN
        make_payroll_reestr (p_pr_id);

        -- переводим из V в F
        UPDATE payroll
           SET pr_st = 'F', pr_fix_dt = SYSDATE
         WHERE pr_id = p_pr_id AND pr_st = 'V';

        write_prs_log (p_pr_id,
                       NULL,
                       TOOLS.GetHistSession,
                       'F',
                       CHR (38) || '296',
                       'V');
    END fix_payroll;

    PROCEDURE make_payroll_reestr (p_pr_id payroll.pr_id%TYPE)
    IS
        l_cnt   INTEGER;
        l_pr    payroll%ROWTYPE;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM payroll_reestr
         WHERE pe_src = 0 AND pe_src_entity = p_pr_id AND pe_st <> 'NEW';

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'По відомості вже сформовано платіжні доручення - оновити реєстр по відомості не можу!');
        END IF;

        --Видаляємо старі записи по відомості
        DELETE FROM payroll_reestr
              WHERE pe_src = 0 AND pe_src_entity = p_pr_id AND pe_st = 'NEW';

        --  io 20221230  реєстри на пошту з урахуванням індексів та вузлів зв`язку
        SELECT *
          INTO l_pr
          FROM payroll
         WHERE pr_id = p_pr_id;

        --Додаємо записи по відомості
        IF l_pr.pr_pay_tp = 'BANK'
        THEN
            INSERT INTO payroll_reestr (pe_id,
                                        pe_pe_master,
                                        pe_src,
                                        pe_src_entity,
                                        pe_rbm_pkt,
                                        pe_bnk_rbm_code,
                                        com_org,
                                        pe_tp,
                                        pe_code,
                                        pe_name,
                                        pe_pay_tp,
                                        pe_nb,
                                        pe_pay_dt,
                                        pe_row_cnt,
                                        pe_st,
                                        pe_sum,
                                        pe_po,
                                        pe_dt,
                                        pe_src_create_dt,
                                        pe_exclude_sum,
                                        pe_nbg,
                                        pe_npc,
                                        pe_pr,
                                        pe_class)
                  SELECT 0,
                         NULL,
                         NVL (pr_src, '0'),
                         prs_pr,
                         NULL,
                         NULL,
                         pr.com_org,
                         DECODE (pr_tp,  'M', '1',  'A', '2'),
                         npc_code,
                         pr_tp.dic_name,
                         CASE
                             WHEN prs_tp IN ('PB') THEN '2'
                             WHEN prs_tp IN ('PP') THEN '1'
                         END,
                         prs_nb,
                         prs_pay_dt,
                         COUNT (DISTINCT prs_id),
                         'NEW',
                         SUM (CASE
                                  WHEN prsd_tp IN ('PWI', 'RDN')
                                  THEN
                                      prsd_sum
                                  WHEN prsd_tp IN ('PRUT',
                                                   'PRAL',
                                                   'PROZ',
                                                   'PROP')
                                  THEN
                                      0 - prsd_sum
                              END),
                         NULL,
                         SYSDATE,
                         SYSDATE,
                         NULL,
                         npt_nbg,
                         npt_npc,
                         prs_pr,
                         'AID'
                    FROM pr_sheet,
                         payroll            pr,
                         uss_ndi.v_ddn_pr_tp pr_tp,
                         uss_ndi.v_ndi_payment_type,
                         uss_ndi.v_ndi_payment_codes,
                         pr_sheet_detail
                   WHERE     prs_pr = pr_id
                         AND prs_pr = p_pr_id
                         AND prsd_prs = prs_id
                         AND pr_tp = pr_tp.dic_value
                         AND prsd_npt = npt_id
                         AND pr_npc = npc_id
                         AND (prs_st IN ('NA') OR prs_st IS NULL)
                GROUP BY NVL (pr_src, '0'),
                         prs_pr,
                         pr.com_org,
                         pr_tp,
                         npc_code,
                         pr_tp.dic_name,
                         prs_tp,
                         prs_nb,
                         prs_pay_dt,
                         npt_nbg,
                         npt_npc;
        ELSE
            INSERT INTO payroll_reestr (pe_id,
                                        pe_pe_master,
                                        pe_src,
                                        pe_src_entity,
                                        pe_rbm_pkt,
                                        pe_bnk_rbm_code,
                                        com_org,
                                        pe_tp,
                                        pe_code,
                                        pe_name,
                                        pe_pay_tp,
                                        pe_nb,
                                        pe_pay_dt,
                                        pe_row_cnt,
                                        pe_st,
                                        pe_sum,
                                        pe_po,
                                        pe_dt,
                                        pe_src_create_dt,
                                        pe_exclude_sum,
                                        pe_nbg,
                                        pe_npc,
                                        pe_pr,
                                        pe_bnk_code,
                                        pe_filia_code,
                                        pe_class)
                  SELECT 0,
                         NULL,
                         NVL (pr_src, '0'),
                         prs_pr,
                         NULL,
                         NULL,
                         pr.com_org,
                         DECODE (pr_tp,  'M', '1',  'A', '2'),
                         npc_code,
                         pr_tp.dic_name,
                         CASE
                             WHEN prs_tp IN ('PB') THEN '2'
                             WHEN prs_tp IN ('PP') THEN '1'
                         END,
                         prs_nb,
                         prs_pay_dt,
                         COUNT (*),
                         'NEW',
                         SUM (CASE
                                  WHEN prsd_tp IN ('PWI', 'RDN')
                                  THEN
                                      prsd_sum
                                  WHEN prsd_tp IN ('PRUT',
                                                   'PRAL',
                                                   'PROZ',
                                                   'PROP')
                                  THEN
                                      0 - prsd_sum
                              END),
                         NULL,
                         SYSDATE,
                         SYSDATE,
                         NULL,
                         npt_nbg,
                         npt_npc,
                         prs_pr,
                         cn.ncn_code,
                         LPAD (s.prs_index, 5, '0')
                             AS prs_index,
                         'AID'
                    FROM pr_sheet_detail
                         JOIN pr_sheet s ON prsd_prs = prs_id
                         JOIN payroll pr ON prs_pr = pr_id
                         JOIN uss_ndi.v_ddn_pr_tp pr_tp
                             ON pr_tp = pr_tp.dic_value
                         JOIN uss_ndi.v_ndi_payment_type ON prsd_npt = npt_id
                         JOIN uss_ndi.v_ndi_payment_codes ON pr_npc = npc_id
                         LEFT JOIN uss_ndi.v_ndi_post_office ind
                             ON     ind.npo_index = s.prs_index
                                AND ind.history_status = 'A'
                         LEFT JOIN uss_ndi.v_ndi_comm_node cn
                             ON     cn.ncn_id = ind.npo_ncn
                                AND cn.history_status = 'A'
                   WHERE     prs_pr = pr_id
                         AND prs_pr = p_pr_id
                         AND pr_pay_tp = 'POST'
                         AND (prs_st IN ('NA') OR prs_st IS NULL)
                GROUP BY NVL (pr_src, '0'),
                         prs_pr,
                         pr.com_org,
                         pr_tp,
                         npc_code,
                         pr_tp.dic_name,
                         prs_tp,
                         prs_nb,
                         prs_pay_dt,
                         npt_nbg,
                         npt_npc,
                         cn.ncn_code,
                         s.prs_index
                ORDER BY pr.com_org,
                         cn.ncn_code,
                         s.prs_index,
                         prs_pay_dt;
        END IF;

        INSERT INTO payroll_reestr (pe_id,
                                    pe_pe_master,
                                    pe_src,
                                    pe_src_entity,
                                    pe_rbm_pkt,
                                    pe_bnk_rbm_code,
                                    com_org,
                                    pe_tp,
                                    pe_code,
                                    pe_name,
                                    pe_pay_tp,
                                    pe_nb,
                                    pe_pay_dt,
                                    pe_row_cnt,
                                    pe_st,
                                    pe_sum,
                                    pe_po,
                                    pe_dt,
                                    pe_src_create_dt,
                                    pe_exclude_sum,
                                    pe_nbg,
                                    pe_npc,
                                    pe_pr,
                                    pe_class,
                                    pe_dpp)
              SELECT 0,
                     NULL,
                     NVL (pr_src, '0'),
                     prs_pr,
                     NULL,
                     NULL,
                     pr.com_org,
                     DECODE (pr_tp,  'M', '1',  'A', '2'),
                     npc_code,
                     pr_tp.dic_name,
                     '2',
                     prs_nb,
                     TO_DATE ('10.' || TO_CHAR (l_pr.pr_month, 'MM.YYYY'),
                              'DD.MM.YYYY'),
                     COUNT (DISTINCT prs_id),
                     'NEW',
                     SUM (CASE
                              WHEN prsd_tp IN ('PRUT',
                                               'PRAL',
                                               'PROZ',
                                               'PROP')
                              THEN
                                  prsd_sum
                          END),
                     NULL,
                     SYSDATE,
                     SYSDATE,
                     NULL,
                     npt_nbg,
                     npt_npc,
                     prs_pr,
                     'DDS',
                     prs_dpp
                FROM pr_sheet,
                     payroll            pr,
                     uss_ndi.v_ddn_pr_tp pr_tp,
                     uss_ndi.v_ndi_payment_type,
                     uss_ndi.v_ndi_payment_codes,
                     pr_sheet_detail
               WHERE     prs_pr = pr_id
                     AND prs_pr = p_pr_id
                     AND prsd_prs_dn = prs_id
                     AND pr_tp = pr_tp.dic_value
                     AND prsd_npt = npt_id
                     AND pr_npc = npc_id
                     AND prs_tp IN ('AUU', 'ABU', 'ADV')
                     AND (prs_st IN ('NA') OR prs_st IS NULL)
            GROUP BY NVL (pr_src, '0'),
                     prs_pr,
                     pr.com_org,
                     pr_tp,
                     npc_code,
                     pr_tp.dic_name,
                     prs_tp,
                     prs_nb,
                     prs_pay_dt,
                     npt_nbg,
                     npt_npc,
                     prs_dpp;
    END make_payroll_reestr;

    PROCEDURE delete_payroll (p_pr_id payroll.pr_id%TYPE)
    IS
        l_pr_st   payroll.pr_st%TYPE;
        l_org     NUMBER;
        l_pr      payroll%ROWTYPE;
        l_msg     VARCHAR2 (500);
        l_cnt     INTEGER;
    BEGIN
        -- #80146 OPERVIEIEV
        init_com_orgs (NULL);

        SELECT pr_st, x_id
          INTO l_pr_st, l_org
          FROM v_payroll LEFT JOIN TMP_COM_ORGS ON x_id = com_org
         WHERE pr_id = p_pr_id;

        SELECT *
          INTO l_pr
          FROM payroll
         WHERE pr_id = p_pr_id;

        IF l_pr_st NOT IN ('C')
        THEN
            raise_application_error (
                -20000,
                'Відомість не в стані Нараховано - таку відомість видаляти не можна!');
        END IF;

        IF l_org IS NULL
        THEN
            raise_application_error (
                -20000,
                'Відомість належить ОСЗН недоступному даному користувачу!');
        END IF;

        SELECT COUNT (*),
               SUBSTR (
                      'Знайдено '
                   || COUNT (*)
                   || ' відомостей, зроблених пізнише цієї - видалення неможливе. Перелік пізніших відомостей: '
                   || LISTAGG (
                             '№'
                          || pr_id
                          || ' ('
                          || TO_CHAR (pr_month, 'YYYY.MM')
                          || '-'
                          || dic_name
                          || ')',
                          ','
                          ON OVERFLOW TRUNCATE WITH COUNT)
                      WITHIN GROUP (ORDER BY pr_id),
                   1,
                   500)
          INTO l_cnt, l_msg
          FROM payroll, uss_ndi.v_ddn_pr_tp
         WHERE     com_org = l_pr.com_org
               AND pr_npc = l_pr.pr_npc
               AND (   (l_pr.pr_tp IN ('M', 'A') AND pr_tp IN ('M', 'A'))
                    OR (l_pr.pr_tp IN ('MD', 'AD') AND pr_tp IN ('MD', 'AD')))
               AND pr_pay_tp = l_pr.pr_pay_tp
               AND pr_id > l_pr.pr_id
               AND pr_tp = dic_value;

        TOOLS.raise_exception (l_cnt, l_msg);

        UPDATE uss_esr.exchangefiles
           SET ef_pr = NULL
         WHERE     ef_pr = p_pr_id
               AND EXISTS
                       (SELECT 1
                          FROM uss_esr.payroll
                         WHERE pr_id = ef_pr AND pr_st = 'C')
               AND (   ef_pkt IS NULL                   --Пакет не створювався
                    OR EXISTS
                           (SELECT 1
                              FROM ikis_rbm.v_packet
                             WHERE ef_pkt = pkt_id AND pkt_st = 'D')); --Пакет видалено

        --Відв'язуємо використані рядки нарахування від деталей відомості
        IF l_pr.pr_tp IN ('M', 'A')
        THEN
            UPDATE ac_detail
               SET acd_prsd = NULL
             WHERE EXISTS
                       (SELECT 1
                          FROM pr_sheet_detail, pr_sheet
                         WHERE     prs_pr = p_pr_id
                               AND prsd_prs = prs_id
                               AND acd_prsd = prsd_id);

            DELETE FROM pr_blocked_acd
                  WHERE EXISTS
                            (SELECT 1
                               FROM pr_sheet, pr_sheet_detail
                              WHERE     prs_pr = p_pr_id
                                    AND prsd_prs = prs_id
                                    AND prsa_prsd = prsd_id);
        ELSIF l_pr.pr_tp IN ('MD', 'AD')
        THEN
            UPDATE ac_detail
               SET acd_prsd_sa = NULL
             WHERE EXISTS
                       (SELECT 1
                          FROM pr_sheet_detail, pr_sheet
                         WHERE     prs_pr = p_pr_id
                               AND prsd_prs = prs_id
                               AND prsd_prs_dn = prs_id
                               AND acd_prsd_sa = prsd_id);
        END IF;

        DELETE FROM pr_sheet_detail
              WHERE EXISTS
                        (SELECT 1
                           FROM pr_sheet
                          WHERE prs_pr = p_pr_id AND prsd_prs = prs_id);

        DELETE FROM pr_sheet
              WHERE prs_pr = p_pr_id;

        DELETE FROM payroll
              WHERE pr_id = p_pr_id;

        --Видалено відомість: id=#, тип=#, орган=#, код створення=#, місяць=#, спосіб виплати=#, кількість=#, сума=#, код відомості=#
        write_prs_log (
            p_pr_id,
            NULL,
            TOOLS.GetHistSession,
            NULL,
               CHR (38)
            || '297#'
            || l_pr.pr_id
            || '#'
            || l_pr.pr_tp
            || '#'
            || l_pr.com_org
            || '#'
            || l_pr.pr_code
            || '#'
            || l_pr.pr_month
            || '#'
            || l_pr.pr_pay_tp
            || '#'
            || l_pr.pr_pc_cnt
            || '#'
            || l_pr.pr_sum
            || '#'
            || l_pr.pr_npc,
            'C');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                'Відомості с вказаним ID-ом не знайдено в БД!');
    END delete_payroll;

    PROCEDURE init_access_params
    IS
    BEGIN
        g_user_type :=
            SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gUserTP);
        g_bp_class := CASE WHEN g_user_type = '41' THEN 'VPO' ELSE 'V' END;
    END;

    PROCEDURE unfix_payroll (p_pr_id payroll.pr_id%TYPE)
    IS
        l_cnt     INTEGER;
        l_pr_st   payroll.pr_st%TYPE;
        l_org     NUMBER;
    BEGIN
        init_com_orgs (NULL);

        SELECT pr_st, x_id
          INTO l_pr_st, l_org
          FROM v_payroll LEFT JOIN TMP_COM_ORGS ON x_id = com_org
         WHERE pr_id = p_pr_id;

        IF l_pr_st NOT IN ('F', 'P')
        THEN
            raise_application_error (
                -20000,
                'Відомість не в стані Фіксовано/Передано - таку відомість розфіксувати не можна!');
        END IF;

        IF l_org IS NULL
        THEN
            raise_application_error (
                -20000,
                'Відомість належить ОСЗН недоступному даному користувачу!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM uss_esr.payroll_reestr q
         WHERE     q.pe_pr IN
                       (SELECT pr_id
                          FROM uss_esr.payroll xx
                         WHERE pr_st IN ('F', 'P') AND pr_id = p_pr_id)
               AND (q.pe_rbm_pkt IS NOT NULL OR pe_po IS NOT NULL)
               AND pe_pr = p_pr_id;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'По відомості вже сформовані файли для передачі на виплату або створений платіжний документ - розфіксувати не можна!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM uss_esr.payroll_reestr q
         WHERE     q.pe_pr IN
                       (SELECT pr_id
                          FROM uss_esr.payroll xx
                         WHERE pr_st IN ('F', 'P') AND pr_id = p_pr_id)
               AND q.pe_rbm_pkt IS NULL
               AND pe_po IS NULL
               AND pe_pr = p_pr_id;

        IF l_cnt > 0
        THEN
            DELETE FROM uss_esr.payroll_reestr q
                  WHERE     q.pe_pr IN
                                (SELECT pr_id
                                   FROM uss_esr.payroll
                                  WHERE     pr_st IN ('F', 'P')
                                        AND pr_id = p_pr_id)
                        AND q.pe_rbm_pkt IS NULL
                        AND pe_po IS NULL
                        AND pe_pr = p_pr_id;
        END IF;

        UPDATE uss_esr.payroll
           SET pr_st = 'C', pr_fix_dt = NULL
         WHERE pr_st IN ('F', 'P') AND pr_id = p_pr_id;

        write_prs_log (p_pr_id,
                       NULL,
                       TOOLS.GetHistSession,
                       'C',
                       CHR (38) || '297',
                       l_pr_st);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                'Відомості с вказаним ID-ом не знайдено в БД!');
    END unfix_payroll;
BEGIN
    init_access_params;
END CALC$PAYROLL;
/