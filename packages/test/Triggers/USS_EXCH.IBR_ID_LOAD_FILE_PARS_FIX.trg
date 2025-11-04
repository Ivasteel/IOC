/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_PARS_FIX
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_PARS_FIX
    FOR EACH ROW
BEGIN
    IF (:new.lfpf_id = 0) OR (:new.lfpf_id IS NULL)
    THEN
        :new.lfpf_id := id_load_file_pars_fix (:new.lfpf_id);
    END IF;
END;
/
