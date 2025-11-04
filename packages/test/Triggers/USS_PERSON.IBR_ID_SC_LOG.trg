/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_LOG
    BEFORE INSERT
    ON uss_person.sc_log
    FOR EACH ROW
BEGIN
    IF (:NEW.scl_id = 0) OR (:NEW.scl_id IS NULL)
    THEN
        :NEW.scl_id := ID_sc_log (:NEW.scl_id);
    END IF;
END;
/
