/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_VEA_LOG
    BEFORE INSERT
    ON uss_visit.vea_log
    FOR EACH ROW
BEGIN
    IF (:NEW.veal_id = 0) OR (:NEW.veal_id IS NULL)
    THEN
        :NEW.veal_id := ID_vea_log (:NEW.veal_id);
    END IF;
END;
/
