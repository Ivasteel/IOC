/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_RIGHT_LOG
    BEFORE INSERT
    ON uss_esr.at_right_log
    FOR EACH ROW
BEGIN
    IF (:NEW.arl_id = 0) OR (:NEW.arl_id IS NULL)
    THEN
        :NEW.arl_id := ID_at_right_log (:NEW.arl_id);
    END IF;
END;
/
