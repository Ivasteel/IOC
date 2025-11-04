/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_FR_LOG
    BEFORE INSERT
    ON uss_esr.fr_log
    FOR EACH ROW
BEGIN
    IF (:NEW.frl_id = 0) OR (:NEW.frl_id IS NULL)
    THEN
        :NEW.frl_id := ID_fr_log (:NEW.frl_id);
    END IF;
END;
/
