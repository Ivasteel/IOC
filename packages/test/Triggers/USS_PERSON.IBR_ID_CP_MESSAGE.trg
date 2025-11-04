/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_CP_MESSAGE
    BEFORE INSERT
    ON uss_person.cp_message
    FOR EACH ROW
BEGIN
    IF (:NEW.cpm_id = 0) OR (:NEW.cpm_id IS NULL)
    THEN
        :NEW.cpm_id := ID_cp_message (:NEW.cpm_id);
    END IF;
END;
/
