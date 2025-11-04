/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_MS_METRIC_FACT
    BEFORE INSERT
    ON uss_rpt.ms_metric_fact
    FOR EACH ROW
BEGIN
    IF (:NEW.mtrf_id = 0) OR (:NEW.mtrf_id IS NULL)
    THEN
        :NEW.mtrf_id := ID_ms_metric_fact (:NEW.mtrf_id);
    END IF;
END;
/
