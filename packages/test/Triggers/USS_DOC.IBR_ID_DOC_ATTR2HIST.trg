/* Formatted on 8/12/2025 5:47:14 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_doc_attr2hist
    BEFORE INSERT
    ON uss_doc.doc_attr2hist
    FOR EACH ROW
BEGIN
    IF (:NEW.da2h_id = 0) OR (:NEW.da2h_id IS NULL)
    THEN
        :NEW.da2h_id := ID_doc_attr2hist (:NEW.da2h_id);
    END IF;
END;
/
