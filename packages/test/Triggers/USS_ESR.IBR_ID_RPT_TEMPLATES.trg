/* Formatted on 8/12/2025 5:50:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_RPT_TEMPLATES
    BEFORE INSERT
    ON uss_esr.rpt_templates
    FOR EACH ROW
BEGIN
    IF (:NEW.rt_id = 0) OR (:NEW.rt_id IS NULL)
    THEN
        :NEW.rt_id := ID_rpt_templates (:NEW.rt_id);
    END IF;
END;
/
