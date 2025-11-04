/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_IMPORT_RECORD_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_import_record_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nfrc_id = 0) OR (:NEW.nfrc_id IS NULL)
    THEN
        :NEW.nfrc_id := ID_ndi_import_record_config (:NEW.nfrc_id);
    END IF;
END;
/
