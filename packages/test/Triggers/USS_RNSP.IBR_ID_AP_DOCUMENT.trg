/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_AP_DOCUMENT
    BEFORE INSERT
    ON uss_rnsp.ap_document
    FOR EACH ROW
BEGIN
    IF (:NEW.apd_id = 0) OR (:NEW.apd_id IS NULL)
    THEN
        :NEW.apd_id := ID_ap_document (:NEW.apd_id);
    END IF;
END;
/
