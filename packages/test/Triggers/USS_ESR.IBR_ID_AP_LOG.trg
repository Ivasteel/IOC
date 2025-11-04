/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AP_LOG
    BEFORE INSERT
    ON uss_esr.ap_log
    FOR EACH ROW
BEGIN
    IF (:NEW.apl_id = 0) OR (:NEW.apl_id IS NULL)
    THEN
        :NEW.apl_id := ID_ap_log (:NEW.apl_id);
    END IF;
END;
/
