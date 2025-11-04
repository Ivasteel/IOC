/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$RPT_ACCRUAL
IS
    -- Author  : BOGDAN
    -- Created : 19.12.2023 16:59:21
    -- Purpose : Звіти масових нарахувань

    PROCEDURE register_report (p_rt_id    IN     rpt_templates.rt_id%TYPE,
                               p_rc_id    IN     payroll.pr_id%TYPE,
                               p_jbr_id      OUT DECIMAL);
END DNET$RPT_ACCRUAL;
/


GRANT EXECUTE ON USS_ESR.DNET$RPT_ACCRUAL TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$RPT_ACCRUAL TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$RPT_ACCRUAL
IS
    -- info:   Отримання ідентифікатора шаблону по коду
    -- params: p_rt_code - код шаблону
    -- note:
    FUNCTION get_rt_by_code (p_rt_code IN rpt_templates.rt_code%TYPE)
        RETURN NUMBER
    IS
        v_rt_id   rpt_templates.rt_id%TYPE;
    BEGIN
        SELECT rt_id
          INTO v_rt_id
          FROM v_rpt_templates
         WHERE rt_code = p_rt_code;

        RETURN v_rt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання коду шаблону по ідентифікатору
    -- params: p_rt_id - ідентифікатор шаблону
    -- note:
    FUNCTION get_rt_code (p_rt_id IN rpt_templates.rt_id%TYPE)
        RETURN VARCHAR2
    IS
        v_rt_code   rpt_templates.rt_code%TYPE;
    BEGIN
        SELECT rt_code
          INTO v_rt_code
          FROM v_rpt_templates
         WHERE rt_id = p_rt_id;

        RETURN v_rt_code;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- #92280 Інформація щодо стану призначення субсидій на оплату житлово-комунальних послуг станом на
    FUNCTION RC_LGW_CHNG_1 (p_rc_id   IN NUMBER,
                            p_rt_id   IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id    NUMBER;
        l_sql       VARCHAR2 (32000);
        l_sql_tot   VARCHAR2 (32000);
    BEGIN
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        FOR xx IN (SELECT t.rc_dt,
                          t.rc_month,
                          (SELECT LISTAGG (z.nst_name)
                                      WITHIN GROUP (ORDER BY 1)
                             FROM uss_ndi.v_ndi_service_type z
                            WHERE z.nst_id IN
                                      (    SELECT REGEXP_SUBSTR (
                                                      text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)    AS z_rdt_id
                                             FROM (SELECT t.rc_nst_list    AS text
                                                     FROM DUAL)
                                       CONNECT BY LENGTH (
                                                      REGEXP_SUBSTR (
                                                          text,
                                                          '[^(\,)]+',
                                                          1,
                                                          LEVEL)) >
                                                  0))    AS nst_list,
                          t.rc_org_list
                     FROM recalculates t
                    WHERE t.rc_id = p_rc_id)
        LOOP
            RDM$RTFL.AddParam (l_jbr_id,
                               'rc_name',
                               'по зміні бюджетних показників');
            RDM$RTFL.AddParam (l_jbr_id,
                               'rc_period',
                               TO_CHAR (xx.rc_month, 'MM.YYYY'));
            RDM$RTFL.AddParam (l_jbr_id,
                               'rc_dt',
                               TO_CHAR (xx.rc_dt, 'DD.MM.YYYY'));
            RDM$RTFL.AddParam (l_jbr_id, 'org_list', xx.rc_org_list);
            RDM$RTFL.AddParam (l_jbr_id, 'rc_nst_list', xx.nst_list);
        END LOOP;

        --rdm$rtfl.SetFileName(l_jbr_id, 'Субсидії_ЖКП_призначення' || '_' || to_char(SYSDATE, 'YYYYMMDDHH24MISS') || '.XLS');

        l_sql :=
            q'[WITH rc_params AS (SELECT rc_id AS e_rc, rc_month AS e_dt FROM uss_esr.v_recalculates WHERE rc_id = :rc_id#),
                   dates AS (SELECT e_dt AS w_dt, e_dt AS w_month FROM rc_params UNION ALL SELECT e_dt - 1 AS w_dt, e_dt AS w_month FROM rc_params),
                   pd_data AS (SELECT pd_pc AS x_pc, pd_id AS x_pd, pc_sc AS x_sc, e_dt AS x_start_dt, pd_stop_dt AS x_stop_dt, pdm_pay_tp AS x_pay_tp
                               FROM uss_esr.v_pc_decision, uss_esr.v_personalcase, uss_esr.v_pd_pay_method, rc_params
                               WHERE EXISTS (SELECT 1 FROM uss_esr.v_rc_candidates, uss_esr.v_pd_payment WHERE rcc_rc = e_rc AND rcc_pd = pdp_pd AND pdp_pd = pd_id)
                                 AND pd_pc = pc_id
                                 AND pdm_pd = pd_id
                                 AND history_Status = 'A'
                                 AND pdm_is_actual = 'T'),
                   pdp_data_new AS (SELECT x_pc, x_pd, x_sc, pdp_npt AS x_npt, SUM(pdp_sum) AS x_sum, MIN(x_start_dt) AS x_start_dt, MAX(x_stop_dt) AS x_stop_dt, MAX(x_pay_tp) AS x_pay_tp
                                    FROM pd_data, rc_params, uss_esr.v_pd_payment
                                    WHERE pdp_pd = x_pd
                                      AND pdp_rc = e_rc
                                      AND e_dt BETWEEN pdp_start_dt AND pdp_stop_dt
                                    GROUP BY x_pc, x_pd, x_sc, pdp_npt),
                   pdp_data_old AS (SELECT x_pc AS o_pc, x_pd AS o_pd, x_sc AS o_sc, pdp_npt AS o_npt, SUM(pdp_sum) AS o_sum
                                    FROM pd_data, rc_params, uss_esr.v_pd_payment pdp
                                    WHERE pdp_pd = x_pd
                                      AND pdp.history_status = 'A'
                                      AND e_dt - 1 BETWEEN pdp_start_dt AND pdp_stop_dt
                                    GROUP BY x_pc, x_pd, x_sc, pdp_npt)
                SELECT (SELECT pc_num FROM uss_esr.v_personalcase WHERE pc_id = x_pc) AS z_eos_num,
                       (SELECT pd_num FROM uss_esr.v_pc_decision WHERE pd_id = x_pd) AS z_pd_num,
                       (uss_person.api$sc_tools.GET_PIB(x_sc)) AS z_pib,
                       (SELECT npt_code FROM uss_ndi.v_ndi_payment_type WHERE npt_id = x_npt) AS z_npt_code,
                       to_char(o_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS z_old_sum,
                       to_char(x_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS z_new_sum,
                       to_char(x_start_dt, 'DD.MM.YYYY') AS z_start_dt,
                       to_char(x_stop_dt, 'DD.MM.YYYY') AS z_stop_dt,
                       (SELECT dic_sname FROM uss_ndi.V_DDN_APM_TP WHERE dic_value = x_pay_tp) AS z_pay_type,
                       rownum as n
                FROM pdp_data_new
                LEFT OUTER JOIN pdp_data_old ON (x_pd = o_pd AND x_npt = o_npt)
                order by z_pd_num
     ]';

        l_sql_tot :=
            q'[WITH rc_params AS (SELECT rc_id AS e_rc, rc_month AS e_dt FROM uss_esr.v_recalculates WHERE rc_id = :rc_id#),
                   dates AS (SELECT e_dt AS w_dt, e_dt AS w_month FROM rc_params UNION ALL SELECT e_dt - 1 AS w_dt, e_dt AS w_month FROM rc_params),
                   pd_data AS (SELECT pd_pc AS x_pc, pd_id AS x_pd, pc_sc AS x_sc, e_dt AS x_start_dt, pd_stop_dt AS x_stop_dt, pdm_pay_tp AS x_pay_tp
                               FROM uss_esr.v_pc_decision, uss_esr.v_personalcase, uss_esr.v_pd_pay_method, rc_params
                               WHERE EXISTS (SELECT 1 FROM uss_esr.v_rc_candidates, uss_esr.v_pd_payment WHERE rcc_rc = e_rc AND rcc_pd = pdp_pd AND pdp_pd = pd_id)
                                 AND pd_pc = pc_id
                                 AND pdm_pd = pd_id
                                 AND history_Status = 'A'
                                 AND pdm_is_actual = 'T'),
                   pdp_data_new AS (SELECT x_pc, x_pd, x_sc, pdp_npt AS x_npt, SUM(pdp_sum) AS x_sum, MIN(x_start_dt) AS x_start_dt, MAX(x_stop_dt) AS x_stop_dt, MAX(x_pay_tp) AS x_pay_tp
                                    FROM pd_data, rc_params, uss_esr.v_pd_payment
                                    WHERE pdp_pd = x_pd
                                      AND pdp_rc = e_rc
                                      AND e_dt BETWEEN pdp_start_dt AND pdp_stop_dt
                                    GROUP BY x_pc, x_pd, x_sc, pdp_npt),
                   pdp_data_old AS (SELECT x_pc AS o_pc, x_pd AS o_pd, x_sc AS o_sc, pdp_npt AS o_npt, SUM(pdp_sum) AS o_sum
                                    FROM pd_data, rc_params, uss_esr.v_pd_payment pdp
                                    WHERE pdp_pd = x_pd
                                      AND pdp.history_status = 'A'
                                      AND e_dt - 1 BETWEEN pdp_start_dt AND pdp_stop_dt
                                    GROUP BY x_pc, x_pd, x_sc, pdp_npt)
                SELECT to_char(sum(o_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS z_old_sum_summ,
                       to_char(sum(x_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS z_new_sum_summ
                FROM pdp_data_new
                LEFT OUTER JOIN pdp_data_old ON (x_pd = o_pd AND x_npt = o_npt)
     ]';

        l_sql := REPLACE (l_sql, ':rc_id#', p_rc_id);
        RDM$RTFL.AddDataSet (l_jbr_id, 'main_ds', l_sql);

        l_sql_tot := REPLACE (l_sql_tot, ':rc_id#', p_rc_id);
        RDM$RTFL.AddDataSet (l_jbr_id, 'total_ds', l_sql_tot);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    FUNCTION RC_LGW_CHNG_2 (p_rc_id   IN NUMBER,
                            p_rt_id   IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id    NUMBER;
        l_sql       VARCHAR2 (32000);
        l_sql_tot   VARCHAR2 (32000);
    BEGIN
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        RDM$RTFL.AddDataSet (
            l_jbr_id,
            'ds_m',
               '
        SELECT pc.pc_num,
               d.pd_num,
               a.pa_num,
               (SELECT max(s.nst_name) FROM uss_ndi.v_ndi_service_type s where s.nst_id = d.pd_Nst) as nst_name,
               to_char(r.rc_month, ''DD.MM.YYYY'') as date_st,
               uss_person.api$sc_tools.GET_PIB(pc.pc_sc) as pib,
               uss_person.api$sc_tools.get_address(pc.pc_sc, 3) as addr,
               pd_id as pd_main
          FROM uss_esr.v_rc_candidates t
          join uss_esr.v_recalculates r on (r.rc_id = t.rcc_rc)
          join uss_esr.v_personalcase pc on (pc.pc_id = t.rcc_pc)
          join uss_esr.v_pc_decision d on (d.pd_id = t.rcc_pd)
          join uss_esr.v_pc_account a on (a.pa_id = d.pd_pa)
         where t.rcc_rc = '
            || p_rc_id
            || '
    ');

        RDM$RTFL.AddDataSet (
            l_jbr_id,
            'ds',
               '
        SELECT to_char(t.pdp_start_dt, ''DD.MM.YYYY'') as c1,
               to_char(t.pdp_stop_dt, ''DD.MM.YYYY'') as c2,
               to_char(t.pdp_sum, ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''', '''''''''')  as c3,
               p.npt_code as c4
          FROM uss_esr.v_pd_payment t
          join uss_ndi.v_ndi_payment_type p on (p.npt_id = t.pdp_npt)
         where t.pdp_rc = '
            || p_rc_id
            || '
    ');

        RDM$RTFL.AddRelation (l_jbr_id,
                              'ds_m',
                              'pd_main',
                              'ds',
                              'pdp_pd');

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    PROCEDURE register_report (p_rt_id    IN     rpt_templates.rt_id%TYPE,
                               p_rc_id    IN     payroll.pr_id%TYPE,
                               p_jbr_id      OUT DECIMAL)
    IS
    BEGIN
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.register_report',
            action_name   =>
                   'p_rt_id='
                || TO_CHAR (p_rt_id)
                || ';'
                || 'p_rc_id='
                || TO_CHAR (p_rc_id));

        p_jbr_id :=
            CASE get_rt_code (p_rt_id)
                WHEN 'RC_LGW_CHNG_1' THEN RC_LGW_CHNG_1 (p_rc_id, p_rt_id)
                WHEN 'RC_LGW_CHNG_2' THEN RC_LGW_CHNG_2 (p_rc_id, p_rt_id)
                ELSE NULL
            END;
    END;
BEGIN
    NULL;
END DNET$RPT_ACCRUAL;
/