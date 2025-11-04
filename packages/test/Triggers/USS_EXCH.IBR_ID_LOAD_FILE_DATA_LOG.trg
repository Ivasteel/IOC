/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_DATA_LOG
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_DATA_LOG
    FOR EACH ROW
BEGIN
    IF (:new.lfdl_id = 0) OR (:new.lfdl_id IS NULL)
    THEN
        :new.lfdl_id := id_load_file_data_log (:new.lfdl_id);
    END IF;
END;
/
