/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_W_JOBS_RPT_PARAMS
    BEFORE INSERT
    ON ikis_sysweb.w_jobs_rpt_params
    FOR EACH ROW
BEGIN
    :NEW.jbp_id := ID_w_jobs_rpt_params (:NEW.jbp_id);
END;
/
