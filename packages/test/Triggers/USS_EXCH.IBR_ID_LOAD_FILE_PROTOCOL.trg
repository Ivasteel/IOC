/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_PROTOCOL
    BEFORE INSERT
    ON uss_exch.load_file_protocol
    FOR EACH ROW
BEGIN
    IF (:new.lfp_id = 0) OR (:new.lfp_id IS NULL)
    THEN
        :new.lfp_id := id_load_file_protocol (:new.lfp_id);
    END IF;
END;
/
