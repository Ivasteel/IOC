/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_INCOME_DETAIL
    BEFORE INSERT
    ON uss_esr.pd_income_detail
    FOR EACH ROW
BEGIN
    IF (:NEW.pid_id = 0) OR (:NEW.pid_id IS NULL)
    THEN
        :NEW.pid_id := ID_pd_income_detail (:NEW.pid_id);
    END IF;
END;
/
