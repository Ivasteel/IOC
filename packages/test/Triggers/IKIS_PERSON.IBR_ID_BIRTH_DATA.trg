/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_BIRTH_DATA
    BEFORE INSERT
    ON IKIS_PERSON.BIRTH_DATA
    FOR EACH ROW
BEGIN
    IF (:NEW.bd_id = 0) OR (:NEW.bd_id IS NULL)
    THEN
        :NEW.bd_id := ID_BIRTH_DATA (p_id => :NEW.bd_id);
    END IF;
END;
/
