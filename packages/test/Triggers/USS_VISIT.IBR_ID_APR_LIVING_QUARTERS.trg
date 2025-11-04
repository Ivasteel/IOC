/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_APR_LIVING_QUARTERS
    BEFORE INSERT
    ON uss_visit.apr_living_quarters
    FOR EACH ROW
BEGIN
    IF (:NEW.aprl_id = 0) OR (:NEW.aprl_id IS NULL)
    THEN
        :NEW.aprl_id := ID_apr_living_quarters (:NEW.aprl_id);
    END IF;
END;
/
