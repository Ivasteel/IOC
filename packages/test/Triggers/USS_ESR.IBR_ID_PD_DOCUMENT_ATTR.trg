/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_DOCUMENT_ATTR
    BEFORE INSERT
    ON uss_esr.pd_document_attr
    FOR EACH ROW
BEGIN
    IF (:NEW.pdoa_id = 0) OR (:NEW.pdoa_id IS NULL)
    THEN
        :NEW.pdoa_id := ID_pd_document_attr (:NEW.pdoa_id);
    END IF;
END;
/
