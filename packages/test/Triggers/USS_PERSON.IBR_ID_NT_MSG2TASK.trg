/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_NT_MSG2TASK
    BEFORE INSERT
    ON uss_person.nt_msg2task
    FOR EACH ROW
BEGIN
    IF (:NEW.ntmt_id = 0) OR (:NEW.ntmt_id IS NULL)
    THEN
        :NEW.ntmt_id := ID_nt_msg2task (:NEW.ntmt_id);
    END IF;
END;
/
