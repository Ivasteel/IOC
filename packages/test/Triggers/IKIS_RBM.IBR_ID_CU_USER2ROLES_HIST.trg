/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU_USER2ROLES_HIST
    BEFORE INSERT
    ON ikis_rbm.cu_user2roles_hist
    FOR EACH ROW
BEGIN
    IF (:NEW.cu2rh_id = 0) OR (:NEW.cu2rh_id IS NULL)
    THEN
        :NEW.cu2rh_id := ID_cu_user2roles_hist (:NEW.cu2rh_id);
    END IF;
END;
/
