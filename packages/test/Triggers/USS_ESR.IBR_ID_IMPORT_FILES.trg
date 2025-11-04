/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_IMPORT_FILES
    BEFORE INSERT
    ON uss_esr.import_files
    FOR EACH ROW
BEGIN
    IF (:NEW.if_id = 0) OR (:NEW.if_id IS NULL)
    THEN
        :NEW.if_id := ID_import_files (:NEW.if_id);
    END IF;
END;
/
