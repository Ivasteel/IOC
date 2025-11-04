/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_DEDUCTION
    BEFORE INSERT
    ON uss_esr.deduction
    FOR EACH ROW
BEGIN
    IF (:NEW.dn_id = 0) OR (:NEW.dn_id IS NULL)
    THEN
        :NEW.dn_id := ID_deduction (:NEW.dn_id);
    END IF;
END;
/
