/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_INCOME_LOG
    BEFORE INSERT
    ON uss_esr.pd_income_log
    FOR EACH ROW
BEGIN
    IF (:NEW.pil_id = 0) OR (:NEW.pil_id IS NULL)
    THEN
        :NEW.pil_id := ID_pd_income_log (:NEW.pil_id);
    END IF;
END;
/
