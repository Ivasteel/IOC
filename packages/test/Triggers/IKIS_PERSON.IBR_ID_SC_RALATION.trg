/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SC_RALATION
    BEFORE INSERT
    ON IKIS_PERSON.sc_ralation
    FOR EACH ROW
BEGIN
    IF (:NEW.scr_id = 0) OR (:NEW.scr_id IS NULL)
    THEN
        :NEW.scr_id := ID_sc_ralation (:NEW.scr_id);
    END IF;
END;
/
