/* Formatted on 8/12/2025 5:54:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_SQL_REPLACE
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_SQL_REPLACE
    FOR EACH ROW
BEGIN
    IF (:new.lfsr_id = 0) OR (:new.lfsr_id IS NULL)
    THEN
        :new.lfsr_id := id_load_file_sql_replace (:new.lfsr_id);
    END IF;
END;
/
