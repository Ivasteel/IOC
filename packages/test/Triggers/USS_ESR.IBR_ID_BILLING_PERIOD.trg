/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_BILLING_PERIOD
    BEFORE INSERT
    ON uss_esr.billing_period
    FOR EACH ROW
BEGIN
    IF (:NEW.bp_id = 0) OR (:NEW.bp_id IS NULL)
    THEN
        :NEW.bp_id := ID_billing_period (:NEW.bp_id);
    END IF;
END;
/
