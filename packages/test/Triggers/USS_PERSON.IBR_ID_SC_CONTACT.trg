/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_CONTACT
    BEFORE INSERT
    ON uss_person.sc_contact
    FOR EACH ROW
BEGIN
    IF (:NEW.sct_id = 0) OR (:NEW.sct_id IS NULL)
    THEN
        :NEW.sct_id := ID_sc_contact (:NEW.sct_id);
    END IF;
END;
/
