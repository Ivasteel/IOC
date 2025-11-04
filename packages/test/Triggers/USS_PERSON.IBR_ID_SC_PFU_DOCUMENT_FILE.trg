/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PFU_DOCUMENT_FILE
    BEFORE INSERT
    ON uss_person.sc_pfu_document_file
    FOR EACH ROW
BEGIN
    IF (:NEW.scpdf_id = 0) OR (:NEW.scpdf_id IS NULL)
    THEN
        :NEW.scpdf_id := ID_sc_pfu_document_file (:NEW.scpdf_id);
    END IF;
END;
/
