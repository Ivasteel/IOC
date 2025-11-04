/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_PARS_DLM
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_PARS_DLM
    FOR EACH ROW
BEGIN
    IF (:new.lfpd_id = 0) OR (:new.lfpd_id IS NULL)
    THEN
        :new.lfpd_id := id_load_file_pars_dlm (:new.lfpd_id);
    END IF;
END;
/
