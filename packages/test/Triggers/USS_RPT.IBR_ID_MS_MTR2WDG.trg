/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_MS_MTR2WDG
    BEFORE INSERT
    ON uss_rpt.ms_mtr2wdg
    FOR EACH ROW
BEGIN
    IF (:NEW.m2w_id = 0) OR (:NEW.m2w_id IS NULL)
    THEN
        :NEW.m2w_id := ID_ms_mtr2wdg (:NEW.m2w_id);
    END IF;
END;
/
