/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_MS_METRIC
    BEFORE INSERT
    ON uss_rpt.ms_metric
    FOR EACH ROW
BEGIN
    IF (:NEW.mtr_id = 0) OR (:NEW.mtr_id IS NULL)
    THEN
        :NEW.mtr_id := ID_ms_metric (:NEW.mtr_id);
    END IF;
END;
/
