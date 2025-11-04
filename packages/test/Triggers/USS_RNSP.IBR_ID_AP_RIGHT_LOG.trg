/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_AP_RIGHT_LOG
    BEFORE INSERT
    ON uss_rnsp.ap_right_log
    FOR EACH ROW
BEGIN
    IF (:NEW.aprl_id = 0) OR (:NEW.aprl_id IS NULL)
    THEN
        :NEW.aprl_id := ID_ap_right_log (:NEW.aprl_id);
    END IF;
END;
/
