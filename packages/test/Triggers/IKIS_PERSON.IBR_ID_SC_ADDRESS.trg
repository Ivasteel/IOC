/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SC_ADDRESS
    BEFORE INSERT
    ON IKIS_PERSON.sc_address
    FOR EACH ROW
BEGIN
    IF (:NEW.sca_id = 0) OR (:NEW.sca_id IS NULL)
    THEN
        :NEW.sca_id := ID_sc_address (:NEW.sca_id);
    END IF;
END;
/
