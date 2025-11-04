/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SC_CONTACT
    BEFORE INSERT
    ON IKIS_PERSON.sc_contact
    FOR EACH ROW
BEGIN
    IF (:NEW.sct_id = 0) OR (:NEW.sct_id IS NULL)
    THEN
        :NEW.sct_id := ID_sc_contact (:NEW.sct_id);
    END IF;
END;
/
