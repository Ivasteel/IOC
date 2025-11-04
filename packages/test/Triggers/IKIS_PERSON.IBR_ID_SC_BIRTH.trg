/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SC_BIRTH
    BEFORE INSERT
    ON IKIS_PERSON.sc_birth
    FOR EACH ROW
BEGIN
    IF (:NEW.scb_id = 0) OR (:NEW.scb_id IS NULL)
    THEN
        :NEW.scb_id := ID_sc_birth (:NEW.scb_id);
    END IF;
END;
/
