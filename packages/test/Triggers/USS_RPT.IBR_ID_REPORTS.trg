/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_REPORTS
    BEFORE INSERT
    ON uss_rpt.reports
    FOR EACH ROW
BEGIN
    IF (:NEW.rpt_id = 0) OR (:NEW.rpt_id IS NULL)
    THEN
        :NEW.rpt_id := ID_reports (:NEW.rpt_id);
    END IF;
END;
/
