/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_NT_SEND_LOG
    BEFORE INSERT
    ON uss_person.nt_send_log
    FOR EACH ROW
BEGIN
    IF (:NEW.ntsl_id = 0) OR (:NEW.ntsl_id IS NULL)
    THEN
        :NEW.ntsl_id := ID_nt_send_log (:NEW.ntsl_id);
    END IF;
END;
/
