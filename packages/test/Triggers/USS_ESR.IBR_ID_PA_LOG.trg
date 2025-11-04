/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PA_LOG
    BEFORE INSERT
    ON uss_esr.pa_log
    FOR EACH ROW
BEGIN
    IF (:NEW.pal_id = 0) OR (:NEW.pal_id IS NULL)
    THEN
        :NEW.pal_id := ID_pa_log (:NEW.pal_id);
    END IF;
END;
/
