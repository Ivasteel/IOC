/* Formatted on 8/12/2025 5:59:01 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RPT.IBR_ID_MS_ACK
    BEFORE INSERT
    ON uss_rpt.ms_ack
    FOR EACH ROW
BEGIN
    IF (:NEW.ack_id = 0) OR (:NEW.ack_id IS NULL)
    THEN
        :NEW.ack_id := ID_ms_ack (:NEW.ack_id);
    END IF;
END;
/
