/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_AP_SERVICE
    BEFORE INSERT
    ON uss_rnsp.ap_service
    FOR EACH ROW
BEGIN
    IF (:NEW.aps_id = 0) OR (:NEW.aps_id IS NULL)
    THEN
        :NEW.aps_id := ID_ap_service (:NEW.aps_id);
    END IF;
END;
/
