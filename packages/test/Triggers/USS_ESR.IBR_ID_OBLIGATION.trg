/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_OBLIGATION
    BEFORE INSERT
    ON uss_esr.obligation
    FOR EACH ROW
BEGIN
    IF (:NEW.cto_id = 0) OR (:NEW.cto_id IS NULL)
    THEN
        :NEW.cto_id := ID_obligation (:NEW.cto_id);
    END IF;
END;
/
