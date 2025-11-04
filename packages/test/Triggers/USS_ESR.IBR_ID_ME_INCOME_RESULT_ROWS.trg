/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_INCOME_RESULT_ROWS
    BEFORE INSERT
    ON uss_esr.me_income_result_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.misr_id = 0) OR (:NEW.misr_id IS NULL)
    THEN
        :NEW.misr_id := ID_me_income_result_rows (:NEW.misr_id);
    END IF;
END;
/
