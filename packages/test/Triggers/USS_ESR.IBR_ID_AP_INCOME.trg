/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AP_INCOME
    BEFORE INSERT
    ON uss_esr.ap_income
    FOR EACH ROW
BEGIN
    IF (:NEW.api_id = 0) OR (:NEW.api_id IS NULL)
    THEN
        :NEW.api_id := ID_ap_income (:NEW.api_id);
    END IF;
END;
/
