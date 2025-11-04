/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU_ROLE_REQUEST
    BEFORE INSERT
    ON ikis_rbm.cu_role_request
    FOR EACH ROW
BEGIN
    IF (:NEW.crr_id = 0) OR (:NEW.crr_id IS NULL)
    THEN
        :NEW.crr_id := ID_cu_role_request (:NEW.crr_id);
    END IF;
END;
/
