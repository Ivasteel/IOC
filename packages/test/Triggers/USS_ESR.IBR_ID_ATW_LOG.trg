/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ATW_LOG
    BEFORE INSERT
    ON uss_esr.atw_log
    FOR EACH ROW
BEGIN
    IF (:NEW.atwl_id = 0) OR (:NEW.atwl_id IS NULL)
    THEN
        :NEW.atwl_id := ID_atw_log (:NEW.atwl_id);
    END IF;
END;
/
