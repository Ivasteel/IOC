/* Formatted on 8/12/2025 5:54:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LS_TABLE_FIELD
    BEFORE INSERT
    ON uss_exch.ls_table_field
    FOR EACH ROW
BEGIN
    IF (:new.ltf_id = 0) OR (:new.ltf_id IS NULL)
    THEN
        :new.ltf_id := id_ls_table_field (:new.ltf_id);
    END IF;
END;
/
