/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PAYROLL
    BEFORE INSERT
    ON uss_esr.payroll
    FOR EACH ROW
BEGIN
    IF (:NEW.pr_id = 0) OR (:NEW.pr_id IS NULL)
    THEN
        :NEW.pr_id := ID_payroll (:NEW.pr_id);
    END IF;
END;
/
