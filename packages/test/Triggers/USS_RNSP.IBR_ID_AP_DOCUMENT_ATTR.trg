/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_AP_DOCUMENT_ATTR
    BEFORE INSERT
    ON uss_rnsp.ap_document_attr
    FOR EACH ROW
BEGIN
    IF (:NEW.apda_id = 0) OR (:NEW.apda_id IS NULL)
    THEN
        :NEW.apda_id := ID_ap_document_attr (:NEW.apda_id);
    END IF;
END;
/
