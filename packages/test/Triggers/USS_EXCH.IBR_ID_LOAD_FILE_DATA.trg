/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_DATA
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_DATA
    FOR EACH ROW
BEGIN
    IF (:new.lfd_id = 0) OR (:new.lfd_id IS NULL)
    THEN
        :new.lfd_id := id_load_file_data (:new.lfd_id);
    END IF;
END;
/
