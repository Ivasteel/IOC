/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_DOCUMENT_CLASS
    BEFORE INSERT
    ON uss_ndi.ndi_document_class
    FOR EACH ROW
BEGIN
    IF (:NEW.ndc_id = 0) OR (:NEW.ndc_id IS NULL)
    THEN
        :NEW.ndc_id := ID_ndi_document_class (:NEW.ndc_id);
    END IF;
END;
/
