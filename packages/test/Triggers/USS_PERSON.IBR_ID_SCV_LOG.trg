/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SCV_LOG
    BEFORE INSERT
    ON uss_person.scv_log
    FOR EACH ROW
BEGIN
    IF (:NEW.scvl_id = 0) OR (:NEW.scvl_id IS NULL)
    THEN
        :NEW.scvl_id := ID_scv_log (:NEW.scvl_id);
    END IF;
END;
/
