/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_RPT_PARAMS
    BEFORE INSERT
    ON uss_rpt.rpt_params
    FOR EACH ROW
BEGIN
    IF (:NEW.rp_id = 0) OR (:NEW.rp_id IS NULL)
    THEN
        :NEW.rp_id := ID_rpt_params (:NEW.rp_id);
    END IF;
END;
/
