/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_RNP_IDENTITY_INFO
    BEFORE INSERT
    ON ikis_rbm.rnp_identity_info
    FOR EACH ROW
BEGIN
    IF (:NEW.rnpi_id = 0) OR (:NEW.rnpi_id IS NULL)
    THEN
        :NEW.rnpi_id := ID_rnp_identity_info (:NEW.rnpi_id);
    END IF;
END;
/
