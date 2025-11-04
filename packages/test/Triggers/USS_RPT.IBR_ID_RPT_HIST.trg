/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_RPT_HIST
    BEFORE INSERT
    ON uss_rpt.rpt_hist
    FOR EACH ROW
BEGIN
    IF (:NEW.rh_id = 0) OR (:NEW.rh_id IS NULL)
    THEN
        :NEW.rh_id := ID_rpt_hist (:NEW.rh_id);
    END IF;
END;
/
