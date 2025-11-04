/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_PARAMSPERSON
    BEFORE INSERT
    ON uss_person.paramsperson
    FOR EACH ROW
BEGIN
    IF (:NEW.prm_id = 0) OR (:NEW.prm_id IS NULL)
    THEN
        :NEW.prm_id := ID_paramsperson (:NEW.prm_id);
    END IF;
END;
/
