/* Formatted on 8/12/2025 5:46:29 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_CEA.IBR_ID_FILE_CONTENT
    BEFORE INSERT
    ON uss_cea.file_content
    FOR EACH ROW
BEGIN
    IF (:NEW.fc_id = 0) OR (:NEW.fc_id IS NULL)
    THEN
        :NEW.fc_id := ID_file_content (:NEW.fc_id);
    END IF;
END;
/
