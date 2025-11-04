/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_MS_WIDGET
    BEFORE INSERT
    ON uss_rpt.ms_widget
    FOR EACH ROW
BEGIN
    IF (:NEW.wdg_id = 0) OR (:NEW.wdg_id IS NULL)
    THEN
        :NEW.wdg_id := ID_ms_widget (:NEW.wdg_id);
    END IF;
END;
/
