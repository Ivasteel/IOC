/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PFU_DOCUMENT_ATTR
    BEFORE INSERT
    ON uss_person.sc_pfu_document_attr
    FOR EACH ROW
BEGIN
    IF (:NEW.scpda_id = 0) OR (:NEW.scpda_id IS NULL)
    THEN
        :NEW.scpda_id := ID_sc_pfu_document_attr (:NEW.scpda_id);
    END IF;
END;
/
