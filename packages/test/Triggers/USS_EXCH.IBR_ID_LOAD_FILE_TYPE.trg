/* Formatted on 8/12/2025 5:54:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_TYPE
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_TYPE
    FOR EACH ROW
BEGIN
    IF (:new.lft_id = 0) OR (:new.lft_id IS NULL)
    THEN
        :new.lft_id := id_load_file_type (:new.lft_id);
    END IF;
END;
/
