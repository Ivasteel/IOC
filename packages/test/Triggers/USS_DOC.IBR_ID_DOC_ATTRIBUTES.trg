/* Formatted on 8/12/2025 5:47:14 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_DOC_ATTRIBUTES
    BEFORE INSERT
    ON uss_doc.doc_attributes
    FOR EACH ROW
BEGIN
    IF (:NEW.da_id = 0) OR (:NEW.da_id IS NULL)
    THEN
        :NEW.da_id := ID_doc_attributes (:NEW.da_id);
    END IF;
END;
/
