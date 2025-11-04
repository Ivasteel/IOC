/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_w_jobs
    BEFORE INSERT
    ON IKIS_SYSWEB.W_JOBS
    FOR EACH ROW
BEGIN
    :NEW.jb_id := ID_w_jobs (:NEW.jb_id);
END;
/
