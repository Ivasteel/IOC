/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NRR_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_nrr_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nruc_id = 0) OR (:NEW.nruc_id IS NULL)
    THEN
        :NEW.nruc_id := ID_ndi_nrr_config (:NEW.nruc_id);
    END IF;
END;
/
