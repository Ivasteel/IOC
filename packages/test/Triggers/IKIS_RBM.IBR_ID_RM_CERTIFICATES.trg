/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_RM_CERTIFICATES
    BEFORE INSERT
    ON ikis_rbm.rm_certificates
    FOR EACH ROW
BEGIN
    IF (:NEW.rmc_id = 0) OR (:NEW.rmc_id IS NULL)
    THEN
        :NEW.rmc_id := ID_rm_certificates (:NEW.rmc_id);
    END IF;
END;
/
