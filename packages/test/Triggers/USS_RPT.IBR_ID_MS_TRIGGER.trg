/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_MS_TRIGGER
    BEFORE INSERT
    ON uss_rpt.ms_trigger
    FOR EACH ROW
BEGIN
    IF (:NEW.trg_id = 0) OR (:NEW.trg_id IS NULL)
    THEN
        :NEW.trg_id := ID_ms_trigger (:NEW.trg_id);
    END IF;
END;
/
