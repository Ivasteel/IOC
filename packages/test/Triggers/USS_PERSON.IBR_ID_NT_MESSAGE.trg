/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_NT_MESSAGE
    BEFORE INSERT
    ON uss_person.nt_message
    FOR EACH ROW
BEGIN
    IF (:NEW.ntm_id = 0) OR (:NEW.ntm_id IS NULL)
    THEN
        :NEW.ntm_id := ID_nt_message (:NEW.ntm_id);
    END IF;
END;
/
