/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_LOG
    BEFORE INSERT
    ON uss_esr.at_log
    FOR EACH ROW
BEGIN
    IF (:NEW.atl_id = 0) OR (:NEW.atl_id IS NULL)
    THEN
        :NEW.atl_id := ID_at_log (:NEW.atl_id);
    END IF;
END;
/
