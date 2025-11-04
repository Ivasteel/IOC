/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_APR_VEHICLE
    BEFORE INSERT
    ON uss_visit.apr_vehicle
    FOR EACH ROW
BEGIN
    IF (:NEW.aprv_id = 0) OR (:NEW.aprv_id IS NULL)
    THEN
        :NEW.aprv_id := ID_apr_vehicle (:NEW.aprv_id);
    END IF;
END;
/
