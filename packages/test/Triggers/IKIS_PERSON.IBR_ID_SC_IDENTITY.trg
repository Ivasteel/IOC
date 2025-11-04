/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SC_IDENTITY
    BEFORE INSERT
    ON IKIS_PERSON.sc_identity
    FOR EACH ROW
BEGIN
    IF (:NEW.sci_id = 0) OR (:NEW.sci_id IS NULL)
    THEN
        :NEW.sci_id := ID_sc_identity (:NEW.sci_id);
    END IF;
END;
/
