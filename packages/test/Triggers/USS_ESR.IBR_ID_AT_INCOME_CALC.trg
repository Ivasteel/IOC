/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_INCOME_CALC
    BEFORE INSERT
    ON uss_esr.at_income_calc
    FOR EACH ROW
BEGIN
    IF (:NEW.aic_id = 0) OR (:NEW.aic_id IS NULL)
    THEN
        :NEW.aic_id := ID_at_income_calc (:NEW.aic_id);
    END IF;
END;
/
