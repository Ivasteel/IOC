/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NDA_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_nda_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nac_id = 0) OR (:NEW.nac_id IS NULL)
    THEN
        :NEW.nac_id := ID_ndi_nda_config (:NEW.nac_id);
    END IF;
END;
/
