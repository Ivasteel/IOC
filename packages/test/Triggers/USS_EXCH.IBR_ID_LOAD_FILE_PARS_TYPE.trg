/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_PARS_TYPE
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_PARS_TYPE
    FOR EACH ROW
BEGIN
    IF (:new.lfpt_id = 0) OR (:new.lfpt_id IS NULL)
    THEN
        :new.lfpt_id := id_load_file_pars_type (:new.lfpt_id);
    END IF;
END;
/
