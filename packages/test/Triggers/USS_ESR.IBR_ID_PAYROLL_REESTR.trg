/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PAYROLL_REESTR
    BEFORE INSERT
    ON uss_esr.payroll_reestr
    FOR EACH ROW
BEGIN
    IF (:NEW.pe_id = 0) OR (:NEW.pe_id IS NULL)
    THEN
        :NEW.pe_id := ID_payroll_reestr (:NEW.pe_id);
    END IF;
END;
/
