/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_APR_OTHER_INCOME
    BEFORE INSERT
    ON uss_esr.apr_other_income
    FOR EACH ROW
BEGIN
    IF (:NEW.apro_id = 0) OR (:NEW.apro_id IS NULL)
    THEN
        :NEW.apro_id := ID_apr_other_income (:NEW.apro_id);
    END IF;
END;
/
