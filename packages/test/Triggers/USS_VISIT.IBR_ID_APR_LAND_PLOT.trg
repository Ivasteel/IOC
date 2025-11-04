/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_APR_LAND_PLOT
    BEFORE INSERT
    ON uss_visit.apr_land_plot
    FOR EACH ROW
BEGIN
    IF (:NEW.aprt_id = 0) OR (:NEW.aprt_id IS NULL)
    THEN
        :NEW.aprt_id := ID_apr_land_plot (:NEW.aprt_id);
    END IF;
END;
/
