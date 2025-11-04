/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_AP_DOCUMENT_ATTR
    BEFORE INSERT
    ON uss_visit.ap_document_attr
    FOR EACH ROW
BEGIN
    IF (:NEW.apda_id = 0) OR (:NEW.apda_id IS NULL)
    THEN
        :NEW.apda_id := ID_ap_document_attr (:NEW.apda_id);
    END IF;
END;
/
