/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_IMP_PAYROLL
    BEFORE INSERT
    ON uss_esr.imp_payroll
    FOR EACH ROW
BEGIN
    IF (:NEW.ipr_id = 0) OR (:NEW.ipr_id IS NULL)
    THEN
        :NEW.ipr_id := ID_imp_payroll (:NEW.ipr_id);
    END IF;
END;
/
