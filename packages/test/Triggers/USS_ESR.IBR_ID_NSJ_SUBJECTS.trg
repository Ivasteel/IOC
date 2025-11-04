/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSJ_SUBJECTS
    BEFORE INSERT
    ON uss_esr.nsj_subjects
    FOR EACH ROW
BEGIN
    IF (:NEW.njs_id = 0) OR (:NEW.njs_id IS NULL)
    THEN
        :NEW.njs_id := ID_nsj_subjects (:NEW.njs_id);
    END IF;
END;
/
