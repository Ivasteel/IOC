/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_RC_LOG
    BEFORE INSERT
    ON uss_esr.rc_log
    FOR EACH ROW
BEGIN
    IF (:NEW.rcl_id = 0) OR (:NEW.rcl_id IS NULL)
    THEN
        :NEW.rcl_id := ID_rc_log (:NEW.rcl_id);
    END IF;
END;
/
