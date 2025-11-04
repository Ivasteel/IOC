/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_AGG_EHELP
    BEFORE INSERT
    ON uss_rpt.agg_ehelp
    FOR EACH ROW
BEGIN
    IF (:NEW.ae_id = 0) OR (:NEW.ae_id IS NULL)
    THEN
        :NEW.ae_id := ID_agg_ehelp (:NEW.ae_id);
    END IF;
END;
/
