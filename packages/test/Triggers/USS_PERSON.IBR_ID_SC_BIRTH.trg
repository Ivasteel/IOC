/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_BIRTH
    BEFORE INSERT
    ON uss_person.sc_birth
    FOR EACH ROW
BEGIN
    IF (:NEW.scb_id = 0) OR (:NEW.scb_id IS NULL)
    THEN
        :NEW.scb_id := ID_sc_birth (:NEW.scb_id);
    END IF;
END;
/
