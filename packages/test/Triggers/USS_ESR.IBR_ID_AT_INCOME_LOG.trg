/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_INCOME_LOG
    BEFORE INSERT
    ON uss_esr.at_income_log
    FOR EACH ROW
BEGIN
    IF (:NEW.ail_id = 0) OR (:NEW.ail_id IS NULL)
    THEN
        :NEW.ail_id := ID_at_income_log (:NEW.ail_id);
    END IF;
END;
/
