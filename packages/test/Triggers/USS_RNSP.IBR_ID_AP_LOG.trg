/* Formatted on 8/12/2025 5:58:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_RNSP.IBR_ID_AP_LOG
    BEFORE INSERT
    ON uss_rnsp.ap_log
    FOR EACH ROW
BEGIN
    IF (:NEW.apl_id = 0) OR (:NEW.apl_id IS NULL)
    THEN
        :NEW.apl_id := ID_ap_log (:NEW.apl_id);
    END IF;
END;
/
