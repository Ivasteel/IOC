/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_FR_BASE
    BEFORE INSERT
    ON uss_esr.fr_base
    FOR EACH ROW
BEGIN
    IF (:NEW.frb_id = 0) OR (:NEW.frb_id IS NULL)
    THEN
        :NEW.frb_id := ID_fr_base (:NEW.frb_id);
    END IF;
END;
/
