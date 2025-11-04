/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_NT_SEND_TASK
    BEFORE INSERT
    ON uss_person.nt_send_task
    FOR EACH ROW
BEGIN
    IF (:NEW.ntst_id = 0) OR (:NEW.ntst_id IS NULL)
    THEN
        :NEW.ntst_id := ID_nt_send_task (:NEW.ntst_id);
    END IF;
END;
/
