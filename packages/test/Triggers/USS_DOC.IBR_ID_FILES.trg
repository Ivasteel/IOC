/* Formatted on 8/12/2025 5:47:14 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_FILES
    BEFORE INSERT
    ON uss_doc.files
    FOR EACH ROW
BEGIN
    IF (:NEW.file_id = 0) OR (:NEW.file_id IS NULL)
    THEN
        :NEW.file_id := ID_files (:NEW.file_id);
    END IF;
END;
/
