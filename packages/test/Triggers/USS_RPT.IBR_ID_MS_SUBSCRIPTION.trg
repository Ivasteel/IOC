/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_MS_SUBSCRIPTION
    BEFORE INSERT
    ON uss_rpt.ms_subscription
    FOR EACH ROW
BEGIN
    IF (:NEW.sub_id = 0) OR (:NEW.sub_id IS NULL)
    THEN
        :NEW.sub_id := ID_ms_subscription (:NEW.sub_id);
    END IF;
END;
/
