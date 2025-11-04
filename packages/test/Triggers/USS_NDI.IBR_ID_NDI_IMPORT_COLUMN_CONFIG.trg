/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_IMPORT_COLUMN_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_import_column_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nfcc_id = 0) OR (:NEW.nfcc_id IS NULL)
    THEN
        :NEW.nfcc_id := ID_ndi_import_column_config (:NEW.nfcc_id);
    END IF;
END;
/
