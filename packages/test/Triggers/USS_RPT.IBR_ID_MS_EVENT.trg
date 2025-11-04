/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_MS_EVENT
    BEFORE INSERT
    ON uss_rpt.ms_event
    FOR EACH ROW
BEGIN
    IF (:NEW.evt_id = 0) OR (:NEW.evt_id IS NULL)
    THEN
        :NEW.evt_id := ID_ms_event (:NEW.evt_id);
    END IF;
END;
/
