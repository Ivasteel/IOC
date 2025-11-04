/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_RPT_FILES
    BEFORE INSERT
    ON uss_rpt.rpt_files
    FOR EACH ROW
BEGIN
    IF (:NEW.rf_id = 0) OR (:NEW.rf_id IS NULL)
    THEN
        :NEW.rf_id := ID_rpt_files (:NEW.rf_id);
    END IF;
END;
/
