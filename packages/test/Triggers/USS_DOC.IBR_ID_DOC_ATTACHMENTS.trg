/* Formatted on 8/12/2025 5:47:14 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_DOC_ATTACHMENTS
    BEFORE INSERT
    ON uss_doc.doc_attachments
    FOR EACH ROW
BEGIN
    IF (:NEW.dat_id = 0) OR (:NEW.dat_id IS NULL)
    THEN
        :NEW.dat_id := ID_doc_attachments (:NEW.dat_id);
    END IF;
END;
/
