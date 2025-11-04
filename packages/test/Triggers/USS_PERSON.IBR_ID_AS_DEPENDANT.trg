/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_AS_DEPENDANT
    BEFORE INSERT
    ON uss_person.as_dependant
    FOR EACH ROW
BEGIN
    IF (:NEW.asd_id = 0) OR (:NEW.asd_id IS NULL)
    THEN
        :NEW.asd_id := ID_as_dependant (:NEW.asd_id);
    END IF;
END;
/
