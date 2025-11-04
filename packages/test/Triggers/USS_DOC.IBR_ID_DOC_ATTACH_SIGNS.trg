/* Formatted on 8/12/2025 5:47:14 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_DOC_ATTACH_SIGNS
    BEFORE INSERT
    ON uss_doc.doc_attach_signs
    FOR EACH ROW
BEGIN
    IF (:NEW.dats_id = 0) OR (:NEW.dats_id IS NULL)
    THEN
        :NEW.dats_id := ID_doc_attach_signs (:NEW.dats_id);
    END IF;
END;
/
