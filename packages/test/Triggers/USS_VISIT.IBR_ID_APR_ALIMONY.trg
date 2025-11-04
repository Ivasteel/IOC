/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_APR_ALIMONY
    BEFORE INSERT
    ON uss_visit.apr_alimony
    FOR EACH ROW
BEGIN
    IF (:NEW.apra_id = 0) OR (:NEW.apra_id IS NULL)
    THEN
        :NEW.apra_id := ID_apr_alimony (:NEW.apra_id);
    END IF;
END;
/
