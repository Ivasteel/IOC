/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_AP_DOCUMENT
    BEFORE INSERT
    ON uss_visit.ap_document
    FOR EACH ROW
BEGIN
    IF (:NEW.apd_id = 0) OR (:NEW.apd_id IS NULL)
    THEN
        :NEW.apd_id := ID_ap_document (:NEW.apd_id);
    END IF;
END;
/
