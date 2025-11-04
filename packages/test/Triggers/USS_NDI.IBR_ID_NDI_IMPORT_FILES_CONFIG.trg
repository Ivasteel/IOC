/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_IMPORT_FILES_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_import_files_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nffc_id = 0) OR (:NEW.nffc_id IS NULL)
    THEN
        :NEW.nffc_id := ID_ndi_import_files_config (:NEW.nffc_id);
    END IF;
END;
/
