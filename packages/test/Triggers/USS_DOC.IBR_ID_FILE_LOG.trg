/* Formatted on 8/12/2025 5:47:14 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_FILE_LOG
    BEFORE INSERT
    ON uss_doc.file_log
    FOR EACH ROW
BEGIN
    IF (:NEW.fl_id = 0) OR (:NEW.fl_id IS NULL)
    THEN
        :NEW.fl_id := ID_file_log (:NEW.fl_id);
    END IF;
END;
/
