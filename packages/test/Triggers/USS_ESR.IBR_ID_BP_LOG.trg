/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_BP_LOG
    BEFORE INSERT
    ON uss_esr.bp_log
    FOR EACH ROW
BEGIN
    IF (:NEW.bpl_id = 0) OR (:NEW.bpl_id IS NULL)
    THEN
        :NEW.bpl_id := ID_bp_log (:NEW.bpl_id);
    END IF;
END;
/
