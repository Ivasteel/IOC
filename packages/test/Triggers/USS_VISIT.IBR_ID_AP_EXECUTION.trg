/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_AP_EXECUTION
    BEFORE INSERT
    ON uss_visit.ap_execution
    FOR EACH ROW
BEGIN
    IF (:NEW.ape_id = 0) OR (:NEW.ape_id IS NULL)
    THEN
        :NEW.ape_id := ID_ap_execution (:NEW.ape_id);
    END IF;
END;
/
