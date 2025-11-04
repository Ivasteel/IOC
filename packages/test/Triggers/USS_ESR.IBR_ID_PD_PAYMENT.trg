/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_PAYMENT
    BEFORE INSERT
    ON uss_esr.pd_payment
    FOR EACH ROW
BEGIN
    IF (:NEW.pdp_id = 0) OR (:NEW.pdp_id IS NULL)
    THEN
        :NEW.pdp_id := ID_pd_payment (:NEW.pdp_id);
    END IF;
END;
/
