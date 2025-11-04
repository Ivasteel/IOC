/* Formatted on 8/12/2025 5:55:57 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_NST_DOC_CONFIG
    BEFORE INSERT
    ON uss_ndi.ndi_nst_doc_config
    FOR EACH ROW
BEGIN
    IF (:NEW.nndc_id = 0) OR (:NEW.nndc_id IS NULL)
    THEN
        :NEW.nndc_id := ID_ndi_nst_doc_config (:NEW.nndc_id);
    END IF;
END;
/
