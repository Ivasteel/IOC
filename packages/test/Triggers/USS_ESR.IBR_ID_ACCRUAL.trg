/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ACCRUAL
    BEFORE INSERT
    ON uss_esr.accrual
    FOR EACH ROW
BEGIN
    IF (:NEW.ac_id = 0) OR (:NEW.ac_id IS NULL)
    THEN
        :NEW.ac_id := ID_accrual (:NEW.ac_id);
    END IF;
END;
/
