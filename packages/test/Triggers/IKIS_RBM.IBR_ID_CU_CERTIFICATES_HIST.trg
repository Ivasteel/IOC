/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_CU_CERTIFICATES_HIST
    BEFORE INSERT
    ON ikis_rbm.cu_certificates_hist
    FOR EACH ROW
BEGIN
    IF (:NEW.cuch_id = 0) OR (:NEW.cuch_id IS NULL)
    THEN
        :NEW.cuch_id := ID_cu_certificates_hist (:NEW.cuch_id);
    END IF;
END;
/
