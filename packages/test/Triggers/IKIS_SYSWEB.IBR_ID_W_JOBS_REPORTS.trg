/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_W_JOBS_REPORTS
    BEFORE INSERT
    ON ikis_sysweb.w_jobs_reports
    FOR EACH ROW
BEGIN
    :NEW.jbr_id := ID_w_jobs_reports (:NEW.jbr_id);
END;
/
