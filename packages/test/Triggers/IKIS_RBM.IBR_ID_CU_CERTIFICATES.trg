/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU_CERTIFICATES
    BEFORE INSERT
    ON ikis_rbm.cu_certificates
    FOR EACH ROW
BEGIN
    IF (:NEW.cuc_id = 0) OR (:NEW.cuc_id IS NULL)
    THEN
        :NEW.cuc_id := ID_cu_certificates (:NEW.cuc_id);
    END IF;
END;
/
