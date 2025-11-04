/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU_USERS2ROLES
    BEFORE INSERT
    ON ikis_rbm.cu_users2roles
    FOR EACH ROW
BEGIN
    IF (:NEW.cu2r_id = 0) OR (:NEW.cu2r_id IS NULL)
    THEN
        :NEW.cu2r_id := ID_cu_users2roles (:NEW.cu2r_id);
    END IF;
END;
/
