/* Formatted on 8/12/2025 5:54:18 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LOAD_FILE_DATA_PARS
    BEFORE INSERT
    ON USS_EXCH.LOAD_FILE_DATA_PARS
    FOR EACH ROW
BEGIN
    IF (:new.lfdp_id = 0) OR (:new.lfdp_id IS NULL)
    THEN
        :new.lfdp_id := id_load_file_data_pars (:new.lfdp_id);
    END IF;
END;
/
