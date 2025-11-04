/* Formatted on 8/12/2025 6:06:34 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_FINZVIT.IBR_DID_PAYROLL_REESTR
    BEFORE INSERT
    ON ikis_finzvit.payroll_reestr
    FOR EACH ROW
BEGIN
    :NEW.pr_id := DID_payroll_reestr (:NEW.pr_id);
END;
/
