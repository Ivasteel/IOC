/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AP_DOCUMENT
    BEFORE INSERT
    ON uss_esr.ap_document
    FOR EACH ROW
BEGIN
    IF (:NEW.apd_id = 0) OR (:NEW.apd_id IS NULL)
    THEN
        :NEW.apd_id := ID_ap_document (:NEW.apd_id);
    END IF;
END;
/
