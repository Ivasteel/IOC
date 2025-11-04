/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_INCOME_SESSION
    BEFORE INSERT
    ON uss_esr.pd_income_session
    FOR EACH ROW
BEGIN
    IF (:NEW.pin_id = 0) OR (:NEW.pin_id IS NULL)
    THEN
        :NEW.pin_id := ID_pd_income_session (:NEW.pin_id);
    END IF;
END;
/
