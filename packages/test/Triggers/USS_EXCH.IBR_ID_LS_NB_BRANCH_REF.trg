/* Formatted on 8/12/2025 5:54:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_EXCH.IBR_ID_LS_NB_BRANCH_REF
    BEFORE INSERT
    ON uss_exch.ls_nb_branch_ref
    FOR EACH ROW
BEGIN
    IF (:new.nbb_id = 0) OR (:new.nbb_id IS NULL)
    THEN
        :new.nbb_id := id_ls_nb_branch_ref (:new.nbb_id);
    END IF;
END;
/
