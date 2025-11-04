/* Formatted on 8/12/2025 5:57:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SCD_LOG
    BEFORE INSERT
    ON uss_person.scd_log
    FOR EACH ROW
BEGIN
    IF (:NEW.scdl_id = 0) OR (:NEW.scdl_id IS NULL)
    THEN
        :NEW.scdl_id := ID_scd_log (:NEW.scdl_id);
    END IF;
END;
/
