/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_DATA_JOBS
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_DATA_JOBS
    FOR EACH ROW
BEGIN
    IF (:new.lfdj_id = 0) OR (:new.lfdj_id IS NULL)
    THEN
        :new.lfdj_id := id_load_file_data_jobs (:new.lfdj_id);
    END IF;
END;
/
