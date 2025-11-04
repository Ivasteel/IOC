/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_ACCRUAL_PERIOD
    BEFORE INSERT
    ON uss_esr.pd_accrual_period
    FOR EACH ROW
BEGIN
    IF (:NEW.pdap_id = 0) OR (:NEW.pdap_id IS NULL)
    THEN
        :NEW.pdap_id := ID_pd_accrual_period (:NEW.pdap_id);
    END IF;
END;
/
