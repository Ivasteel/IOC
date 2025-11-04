/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_APR_INCOME
    BEFORE INSERT
    ON uss_visit.apr_income
    FOR EACH ROW
BEGIN
    IF (:NEW.apri_id = 0) OR (:NEW.apri_id IS NULL)
    THEN
        :NEW.apri_id := ID_apr_income (:NEW.apri_id);
    END IF;
END;
/
