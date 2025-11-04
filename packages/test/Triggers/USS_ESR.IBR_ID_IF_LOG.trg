/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_IF_LOG
    BEFORE INSERT
    ON uss_esr.if_log
    FOR EACH ROW
BEGIN
    IF (:NEW.ifl_id = 0) OR (:NEW.ifl_id IS NULL)
    THEN
        :NEW.ifl_id := ID_if_log (:NEW.ifl_id);
    END IF;
END;
/
