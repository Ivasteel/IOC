/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_AGG_INT_HELP
    BEFORE INSERT
    ON uss_rpt.agg_int_help
    FOR EACH ROW
BEGIN
    IF (:NEW.aih_id = 0) OR (:NEW.aih_id IS NULL)
    THEN
        :NEW.aih_id := ID_agg_int_help (:NEW.aih_id);
    END IF;
END;
/
