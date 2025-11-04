/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.WS$VPO_REQUESTS
IS
    -- Author  : SERHII
    -- Created : 20.03.2024 16:48:39
    -- Purpose : Функці отримання даних для відповідей у веб-сервіс по довідкам ВПО #88506

    -- #88506
    -- скопіювати дані нарахувань в тимчасову таблцю для uss_person.Ws$VPO_Requests.get_accrual_sum
    PROCEDURE fetch_accrual_data (p_pc_id          IN accrual.ac_pc%TYPE,
                                  p_from_dt        IN DATE,
                                  p_to_dt          IN DATE,
                                  p_npt            IN ac_detail.acd_npt%TYPE,
                                  p_access_token   IN VARCHAR2); -- p_access_token - на майбутнє, зараз не використовується

    -- #88506
    -- скопіювати дані виплат в тимчасову таблцю для uss_person.Ws$VPO_Requests.get_payroll_sum
    PROCEDURE fetch_payroll_data (
        p_pc_id             v_pr_sheet_detail.prsd_pc%TYPE,
        p_from_dt           DATE,
        p_to_dt             DATE,
        p_npt               v_pr_sheet_detail.prsd_npt%TYPE,
        p_access_token   IN VARCHAR2); -- p_access_token - на майбутнє, зараз не використовується

    -- #101243
    --Додати для вивантаження доходів з ЄІССС Допомоги, які розраховуються в ЄІССС
    PROCEDURE Set_USS_Incomes (p_sc_id      NUMBER,
                               p_start_dt   DATE,
                               p_stop_dt    DATE);
END Ws$VPO_Requests;
/


GRANT EXECUTE ON USS_ESR.WS$VPO_REQUESTS TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.WS$VPO_REQUESTS TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.WS$VPO_REQUESTS TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.WS$VPO_REQUESTS TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.WS$VPO_REQUESTS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:50:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.WS$VPO_REQUESTS
IS
    -- #88506 скопіювати дані нарахувань в тимчасову таблцю для uss_person.Ws$VPO_Requests.get_accrual_sum
    PROCEDURE fetch_accrual_data (p_pc_id          IN accrual.ac_pc%TYPE,
                                  p_from_dt        IN DATE,
                                  p_to_dt          IN DATE,
                                  p_npt            IN ac_detail.acd_npt%TYPE,
                                  p_access_token   IN VARCHAR2)
    IS
    BEGIN
        INSERT INTO tmp_work_set1 (x_sum1,
                                   x_dt1,
                                   x_dt2,
                                   x_string1)
            SELECT ad.acd_sum,
                   ad.acd_start_dt,
                   ad.acd_stop_dt,
                   'fetch_accrual_data'
              FROM accrual  a
                   JOIN ac_detail ad
                       ON ad.acd_ac = a.ac_id AND ad.history_status = 'A'
                   JOIN uss_ndi.v_ndi_op op
                       ON op.op_id = ad.acd_op AND op.op_tp1 = 'NR'
             WHERE     a.history_status = 'A'
                   AND ad.acd_npt = p_npt
                   AND a.ac_pc = p_pc_id
                   AND TRUNC (p_from_dt) <= TRUNC (ad.acd_ac_stop_dt)
                   AND TRUNC (p_to_dt) >= TRUNC (ad.acd_ac_start_dt);
    END fetch_accrual_data;

    -- #88506 скопіювати дані виплат в тимчасову таблцю для uss_person.Ws$VPO_Requests.get_payroll_sum
    PROCEDURE fetch_payroll_data (
        p_pc_id             v_pr_sheet_detail.prsd_pc%TYPE,
        p_from_dt           DATE,
        p_to_dt             DATE,
        p_npt               v_pr_sheet_detail.prsd_npt%TYPE,
        p_access_token   IN VARCHAR2)
    IS
    BEGIN
        INSERT INTO tmp_work_set1 (x_sum1, x_dt1, x_string1)
            SELECT prsd.prsd_full_sum, prsd.prsd_month, 'fetch_payroll_data'
              FROM uss_esr.v_pr_sheet_detail prsd
             --join uss_esr.v_pr_sheet prs on prs.prs_id=prsd.prsd_prs
             WHERE     prsd.prsd_tp = 'PWI'
                   AND prsd.prsd_npt = p_npt
                   AND prsd.prsd_pc = p_pc_id
                   AND TRUNC (prsd.prsd_month) BETWEEN TRUNC (p_from_dt)
                                                   AND TRUNC (p_to_dt);
    END fetch_payroll_data;

    -- #101243
    --Додати для вивантаження доходів з ЄІССС Допомоги, які розраховуються в ЄІССС
    PROCEDURE Set_USS_Incomes (p_sc_id      NUMBER,
                               p_start_dt   DATE,
                               p_stop_dt    DATE)
    IS
    BEGIN
        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1,
                                   x_string1,
                                   x_sum1,
                                   x_dt1)
            SELECT pc_sc,
                   pfu_code,
                   acd_sum,
                   acd_start_dt                                  --, nddc_dest
              FROM (SELECT pc.pc_sc,
                           t.nddc_code_dest                           AS pfu_code,
                           ad.acd_sum,
                           ad.acd_start_dt,
                           t.nddc_dest,
                           uss_esr.api$appeal.Get_Ap_Doc_Str (pd_ap,
                                                              'FP',
                                                              797,
                                                              '-')    AS x_inv
                      FROM personalcase  pc
                           JOIN accrual ac ON pc.pc_id = ac.ac_pc
                           JOIN AC_Detail ad ON ad.acd_ac = ac.ac_id
                           JOIN pc_decision ON pd_id = ad.acd_pd
                           --              JOIN ap_person app ON app_ap = pd_ap AND app.app_sc = pc_sc AND app.history_status = 'A'
                           JOIN uss_ndi.v_NDI_DECODING_CONFIG t
                               ON     t.nddc_code_src = ad.acd_npt
                                  AND t.nddc_tp = 'NPT_ID'
                                  AND t.nddc_src = 'USS'
                                  AND t.nddc_dest IN ('PFU', 'PFU_', 'PFU_A')
                     WHERE     ad.ACD_IMP_PR_NUM IS NULL
                           AND ad.history_status = 'A'
                           AND pc_sc = p_sc_id
                           AND ad.acd_start_dt BETWEEN p_start_dt
                                                   AND p_stop_dt)
             WHERE (   nddc_dest = 'PFU'
                    OR nddc_dest = 'PFU_' AND x_inv != 'DIA'
                    OR nddc_dest = 'PFU_A' AND x_inv = 'DIA');
    /*
        select pc_sc, pfu_code, acd_sum, acd_start_dt--, nddc_dest
        from (  SELECT pc.pc_sc, t.nddc_code_dest AS pfu_code, ad.acd_sum, ad.acd_start_dt, t.nddc_dest
                FROM personalcase pc
                  JOIN accrual   ac ON pc.pc_id = ac.ac_pc
                  JOIN AC_Detail ad ON ad.acd_ac = ac.ac_id
                  JOIN uss_ndi.v_NDI_DECODING_CONFIG t ON t.nddc_code_src = ad.acd_npt
                                                      AND t.nddc_tp = 'NPT_ID'
                                                      AND t.nddc_src = 'USS'
                                                      AND t.nddc_dest IN ('PFU', 'PFU_', 'PFU_A')
                WHERE ad.ACD_IMP_PR_NUM IS NULL
                  AND ad.history_status = 'A'
                  AND pc_sc = p_sc_id
                  AND ad.acd_start_dt = p_dt
             )
        WHERE ( nddc_dest = 'PFU'
                OR
                nddc_dest = 'PFU_'  AND NVL(uss_person.API$SC_TOOLS.get_inv_child(pc_sc),'-') != 'DIA'
                OR
                nddc_dest = 'PFU_A' AND NVL(uss_person.API$SC_TOOLS.get_inv_child(pc_sc),'-') = 'DIA'
              );
    */
    END;
BEGIN
    -- Initialization
    NULL;
END Ws$VPO_Requests;
/