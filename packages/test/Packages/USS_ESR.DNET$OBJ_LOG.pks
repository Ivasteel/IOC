/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$OBJ_LOG
IS
    -- Author  : VANO
    -- Created : 16.12.2021 13:52:33
    -- Purpose : Функції отримання протоколу для відображення в інтерфейсі

    PROCEDURE get_object_log (p_obj_tp        VARCHAR2,
                              p_obj_id        NUMBER,
                              p_res_cur   OUT SYS_REFCURSOR);
END DNET$OBJ_LOG;
/


GRANT EXECUTE ON USS_ESR.DNET$OBJ_LOG TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$OBJ_LOG TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$OBJ_LOG
IS
    PROCEDURE get_object_log (p_obj_tp        VARCHAR2,
                              p_obj_id        NUMBER,
                              p_res_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        CASE p_obj_tp
            WHEN 'ACCRUAL'
            THEN
                dnet$accrual.get_accrual_log (p_obj_id, p_res_cur);
            WHEN 'DEDUCTION'
            THEN
                dnet$personal_case.get_deduction_log (p_obj_id, p_res_cur);
            WHEN 'DECISION'
            THEN
                dnet$pay_assignments.get_decision_log (p_obj_id, p_res_cur);
            WHEN 'PC_DATA_ORDERING'
            THEN
                dnet$pay_assignments.get_pco_log (p_obj_id, p_res_cur);
            WHEN 'APPEAL'
            THEN
                dnet$personal_case.get_ap_log (p_obj_id, p_res_cur);
            WHEN 'BILLING'
            THEN
                dnet$billing_period.get_log_list (p_obj_id, p_res_cur);
            WHEN 'RECALC'
            THEN
                dnet$accrual.get_rc_log (p_obj_id, p_res_cur);
            WHEN 'MEMORANDUM'
            THEN
                dnet$memorandum.get_memorandum_log (p_obj_id, p_res_cur);
            WHEN 'ERRAND'
            THEN
                dnet$errand.get_errand_log (p_obj_id, p_res_cur);
            WHEN 'MASS_EXCHANGE'
            THEN
                dnet$mass_exchange.get_mass_exchange_log (p_obj_id,
                                                          p_res_cur);
            WHEN 'IMPORT_FILE'
            THEN
                DNET$IMPORT_FILES.get_if_log (p_obj_id, p_res_cur);
            WHEN 'ACT'
            THEN
                DNET$ACT_ASSIGNMENT.GET_ACT_LOG (p_obj_id, p_res_cur);
            WHEN 'ALIMONY'
            THEN
                Dnet$personal_Case.GET_ALIMONY_LOG (p_obj_id, p_res_cur);
            WHEN 'PR_LOG'
            THEN
                DNET$PAYMENT_INFO.get_pr_log (p_obj_id, p_res_cur);
            WHEN 'PRS_LOG'
            THEN
                DNET$PAYMENT_INFO.get_prs_log (p_obj_id, p_res_cur);
            WHEN 'ACT_WARES'
            THEN
                DNET$DZR_ACT_PROVIDE.GET_ACT_WARES_LOG (p_obj_id, p_res_cur);
            ELSE
                OPEN p_res_cur FOR SELECT * FROM DUAL;
        END CASE;
    END;
END dnet$obj_log;
/