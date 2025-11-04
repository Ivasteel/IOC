/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_SQL
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_SQL
    FOR EACH ROW
BEGIN
    IF (:new.lfs_id = 0) OR (:new.lfs_id IS NULL)
    THEN
        :new.lfs_id := id_load_file_sql (:new.lfs_id);
    END IF;
END;
/
