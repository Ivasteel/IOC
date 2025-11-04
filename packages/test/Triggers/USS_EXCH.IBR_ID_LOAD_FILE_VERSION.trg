/* Formatted on 8/12/2025 5:54:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_VERSION
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_VERSION
    FOR EACH ROW
BEGIN
    IF (:new.lfv_id = 0) OR (:new.lfv_id IS NULL)
    THEN
        :new.lfv_id := id_load_file_version (:new.lfv_id);
    END IF;
END;
/
