/* Formatted on 8/12/2025 5:47:14 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_DOCUMENTS
    BEFORE INSERT
    ON uss_doc.documents
    FOR EACH ROW
BEGIN
    IF (:NEW.doc_id = 0) OR (:NEW.doc_id IS NULL)
    THEN
        :NEW.doc_id := ID_documents (:NEW.doc_id);
    END IF;
END;
/
