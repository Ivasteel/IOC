/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_EVA_LOG
    BEFORE INSERT
    ON uss_esr.eva_log
    FOR EACH ROW
BEGIN
    IF (:NEW.eval_id = 0) OR (:NEW.eval_id IS NULL)
    THEN
        :NEW.eval_id := ID_eva_log (:NEW.eval_id);
    END IF;
END;
/
