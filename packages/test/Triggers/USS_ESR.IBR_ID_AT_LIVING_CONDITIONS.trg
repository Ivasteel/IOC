/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_LIVING_CONDITIONS
    BEFORE INSERT
    ON uss_esr.at_living_conditions
    FOR EACH ROW
BEGIN
    IF (:NEW.atlc_id = 0) OR (:NEW.atlc_id IS NULL)
    THEN
        :NEW.atlc_id := ID_at_living_conditions (:NEW.atlc_id);
    END IF;
END;
/
