/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_RESULTS
    BEFORE INSERT
    ON uss_esr.at_results
    FOR EACH ROW
BEGIN
    IF (:NEW.atr_id = 0) OR (:NEW.atr_id IS NULL)
    THEN
        :NEW.atr_id := ID_at_results (:NEW.atr_id);
    END IF;
END;
/
