/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_DOCUMENT_ATTR
    BEFORE INSERT
    ON uss_esr.at_document_attr
    FOR EACH ROW
BEGIN
    IF (:NEW.atda_id = 0) OR (:NEW.atda_id IS NULL)
    THEN
        :NEW.atda_id := ID_at_document_attr (:NEW.atda_id);
    END IF;
END;
/
