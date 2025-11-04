/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SCD_EVENT
    BEFORE INSERT
    ON uss_person.scd_event
    FOR EACH ROW
BEGIN
    IF (:NEW.scde_id = 0) OR (:NEW.scde_id IS NULL)
    THEN
        :NEW.scde_id := ID_scd_event (:NEW.scde_id);
    END IF;
END;
/
