/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_MS_NOTIFICATION
    BEFORE INSERT
    ON uss_rpt.ms_notification
    FOR EACH ROW
BEGIN
    IF (:NEW.nt_id = 0) OR (:NEW.nt_id IS NULL)
    THEN
        :NEW.nt_id := ID_ms_notification (:NEW.nt_id);
    END IF;
END;
/
