/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU_USERS2CMES
    BEFORE INSERT
    ON ikis_rbm.cu_users2cmes
    FOR EACH ROW
BEGIN
    IF (:NEW.cu2cmes_id = 0) OR (:NEW.cu2cmes_id IS NULL)
    THEN
        :NEW.cu2cmes_id := ID_cu_users2cmes (:NEW.cu2cmes_id);
    END IF;
END;
/
