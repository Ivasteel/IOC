/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AP_SERVICE
    BEFORE INSERT
    ON uss_esr.ap_service
    FOR EACH ROW
BEGIN
    IF (:NEW.aps_id = 0) OR (:NEW.aps_id IS NULL)
    THEN
        :NEW.aps_id := ID_ap_service (:NEW.aps_id);
    END IF;
END;
/
