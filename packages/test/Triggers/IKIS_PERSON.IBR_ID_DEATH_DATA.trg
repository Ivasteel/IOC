/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_DEATH_DATA
    BEFORE INSERT
    ON IKIS_PERSON.DEATH_DATA
    FOR EACH ROW
BEGIN
    IF (:NEW.dd_id = 0) OR (:NEW.dd_id IS NULL)
    THEN
        :NEW.dd_id := ID_DEATH_DATA (p_id => :NEW.dd_id);
    END IF;
END;
/
