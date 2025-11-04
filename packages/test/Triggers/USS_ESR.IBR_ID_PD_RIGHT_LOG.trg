/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PD_RIGHT_LOG
    BEFORE INSERT
    ON uss_esr.pd_right_log
    FOR EACH ROW
BEGIN
    IF (:NEW.prl_id = 0) OR (:NEW.prl_id IS NULL)
    THEN
        :NEW.prl_id := ID_pd_right_log (:NEW.prl_id);
    END IF;
END;
/
