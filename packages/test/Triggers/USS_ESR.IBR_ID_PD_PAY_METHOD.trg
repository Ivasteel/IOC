/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_PAY_METHOD
    BEFORE INSERT
    ON uss_esr.pd_pay_method
    FOR EACH ROW
BEGIN
    IF (:NEW.pdm_id = 0) OR (:NEW.pdm_id IS NULL)
    THEN
        :NEW.pdm_id := ID_pd_pay_method (:NEW.pdm_id);
    END IF;
END;
/
