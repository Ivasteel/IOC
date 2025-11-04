/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSJ_LOG
    BEFORE INSERT
    ON uss_esr.nsj_log
    FOR EACH ROW
BEGIN
    IF (:NEW.njl_id = 0) OR (:NEW.njl_id IS NULL)
    THEN
        :NEW.njl_id := ID_nsj_log (:NEW.njl_id);
    END IF;
END;
/
