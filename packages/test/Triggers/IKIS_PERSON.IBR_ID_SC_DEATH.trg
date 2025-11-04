/* Formatted on 8/12/2025 6:07:20 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_PERSON.IBR_ID_SC_DEATH
    BEFORE INSERT
    ON IKIS_PERSON.sc_death
    FOR EACH ROW
BEGIN
    IF (:NEW.sch_id = 0) OR (:NEW.sch_id IS NULL)
    THEN
        :NEW.sch_id := ID_sc_death (:NEW.sch_id);
    END IF;
END;
/
