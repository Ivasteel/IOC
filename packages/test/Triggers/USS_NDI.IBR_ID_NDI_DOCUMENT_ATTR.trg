/* Formatted on 8/12/2025 5:55:56 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_NDI.IBR_ID_NDI_DOCUMENT_ATTR
    BEFORE INSERT
    ON uss_ndi.ndi_document_attr
    FOR EACH ROW
BEGIN
    IF (:NEW.nda_id = 0) OR (:NEW.nda_id IS NULL)
    THEN
        :NEW.nda_id := ID_ndi_document_attr (:NEW.nda_id);
    END IF;
END;
/
