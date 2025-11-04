/* Formatted on 8/12/2025 5:54:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LS_DATA_REF
    BEFORE INSERT
    ON uss_exch.ls_data_ref
    FOR EACH ROW
BEGIN
    IF (:new.ldr_id = 0) OR (:new.ldr_id IS NULL)
    THEN
        :new.ldr_id := id_ls_data_ref (:new.ldr_id);
    END IF;
END;
/
