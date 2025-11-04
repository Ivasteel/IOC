/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_AP_PERSON
    BEFORE INSERT
    ON uss_rnsp.ap_person
    FOR EACH ROW
BEGIN
    IF (:NEW.app_id = 0) OR (:NEW.app_id IS NULL)
    THEN
        :NEW.app_id := ID_ap_person (:NEW.app_id);
    END IF;
END;
/
