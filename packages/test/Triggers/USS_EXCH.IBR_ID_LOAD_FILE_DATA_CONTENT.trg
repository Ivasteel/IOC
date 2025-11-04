/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_DATA_CONTENT
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_DATA_CONTENT
    FOR EACH ROW
BEGIN
    IF (:new.lfdc_id = 0) OR (:new.lfdc_id IS NULL)
    THEN
        :new.lfdc_id := id_load_file_data_content (:new.lfdc_id);
    END IF;
END;
/
