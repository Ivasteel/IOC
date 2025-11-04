/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AP_PAYMENT
    BEFORE INSERT
    ON uss_esr.ap_payment
    FOR EACH ROW
BEGIN
    IF (:NEW.apm_id = 0) OR (:NEW.apm_id IS NULL)
    THEN
        :NEW.apm_id := ID_ap_payment (:NEW.apm_id);
    END IF;
END;
/
