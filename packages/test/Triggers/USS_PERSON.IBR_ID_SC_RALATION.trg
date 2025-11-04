/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_RALATION
    BEFORE INSERT
    ON uss_person.sc_ralation
    FOR EACH ROW
BEGIN
    IF (:NEW.scr_id = 0) OR (:NEW.scr_id IS NULL)
    THEN
        :NEW.scr_id := ID_sc_ralation (:NEW.scr_id);
    END IF;
END;
/
