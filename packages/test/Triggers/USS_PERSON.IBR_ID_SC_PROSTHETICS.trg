/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PROSTHETICS
    BEFORE INSERT
    ON uss_person.sc_prosthetics
    FOR EACH ROW
BEGIN
    IF (:NEW.scar_id = 0) OR (:NEW.scar_id IS NULL)
    THEN
        :NEW.scar_id := ID_sc_prosthetics (:NEW.scar_id);
    END IF;
END;
/
