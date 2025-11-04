/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_RN_DOCUMENT_ATTR
    BEFORE INSERT
    ON uss_rnsp.rn_document_attr
    FOR EACH ROW
BEGIN
    IF (:NEW.rnda_id = 0) OR (:NEW.rnda_id IS NULL)
    THEN
        :NEW.rnda_id := ID_rn_document_attr (:NEW.rnda_id);
    END IF;
END;
/
