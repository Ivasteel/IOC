/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SCCW_LOG
    BEFORE INSERT
    ON uss_person.sccw_log
    FOR EACH ROW
BEGIN
    IF (:NEW.sccwl_id = 0) OR (:NEW.sccwl_id IS NULL)
    THEN
        :NEW.sccwl_id := ID_sccw_log (:NEW.sccwl_id);
    END IF;
END;
/
