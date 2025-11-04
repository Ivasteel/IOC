/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_w_jobs_protocol
    BEFORE INSERT
    ON IKIS_SYSWEB.W_JOBS_PROTOCOL
    FOR EACH ROW
BEGIN
    :NEW.jm_id := ID_w_jobs_protocol (:NEW.jm_id);
END;
/
