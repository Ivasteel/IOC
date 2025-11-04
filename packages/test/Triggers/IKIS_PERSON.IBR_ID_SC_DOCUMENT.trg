/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SC_DOCUMENT
    BEFORE INSERT
    ON IKIS_PERSON.sc_document
    FOR EACH ROW
BEGIN
    IF (:NEW.scd_id = 0) OR (:NEW.scd_id IS NULL)
    THEN
        :NEW.scd_id := ID_sc_document (:NEW.scd_id);
    END IF;
END;
/
