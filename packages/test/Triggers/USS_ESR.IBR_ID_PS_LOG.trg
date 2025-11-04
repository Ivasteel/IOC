/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PS_LOG
    BEFORE INSERT
    ON uss_esr.ps_log
    FOR EACH ROW
BEGIN
    IF (:NEW.psl_id = 0) OR (:NEW.psl_id IS NULL)
    THEN
        :NEW.psl_id := ID_ps_log (:NEW.psl_id);
    END IF;
END;
/
