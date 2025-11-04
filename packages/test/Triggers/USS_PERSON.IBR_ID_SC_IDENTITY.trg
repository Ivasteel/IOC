/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_IDENTITY
    BEFORE INSERT
    ON uss_person.sc_identity
    FOR EACH ROW
BEGIN
    IF (:NEW.sci_id = 0) OR (:NEW.sci_id IS NULL)
    THEN
        :NEW.sci_id := ID_sc_identity (:NEW.sci_id);
    END IF;
END;
/
