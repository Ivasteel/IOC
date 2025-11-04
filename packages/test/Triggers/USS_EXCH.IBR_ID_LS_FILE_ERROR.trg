/* Formatted on 8/12/2025 5:54:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LS_FILE_ERROR
    BEFORE INSERT
    ON uss_exch.ls_file_error
    FOR EACH ROW
BEGIN
    IF (:new.lfe_id = 0) OR (:new.lfe_id IS NULL)
    THEN
        :new.lfe_id := id_ls_file_error (:new.lfe_id);
    END IF;
END;
/
