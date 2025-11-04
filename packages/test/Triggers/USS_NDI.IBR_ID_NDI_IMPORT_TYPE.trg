/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_IMPORT_TYPE
    BEFORE INSERT
    ON uss_ndi.ndi_import_type
    FOR EACH ROW
BEGIN
    IF (:NEW.nfit_id = 0) OR (:NEW.nfit_id IS NULL)
    THEN
        :NEW.nfit_id := ID_ndi_import_type (:NEW.nfit_id);
    END IF;
END;
/
