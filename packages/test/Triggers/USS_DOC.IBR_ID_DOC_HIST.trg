/* Formatted on 8/12/2025 5:47:14 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_DOC.IBR_ID_DOC_HIST
    BEFORE INSERT
    ON uss_doc.doc_hist
    FOR EACH ROW
BEGIN
    IF (:NEW.dh_id = 0) OR (:NEW.dh_id IS NULL)
    THEN
        :NEW.dh_id := ID_doc_hist (:NEW.dh_id);
    END IF;
END;
/
