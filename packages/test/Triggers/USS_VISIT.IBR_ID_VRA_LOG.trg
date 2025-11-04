/* Formatted on 8/12/2025 6:00:12 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_VRA_LOG
    BEFORE INSERT
    ON uss_visit.vra_log
    FOR EACH ROW
BEGIN
    IF (:NEW.vral_id = 0) OR (:NEW.vral_id IS NULL)
    THEN
        :NEW.vral_id := ID_vra_log (:NEW.vral_id);
    END IF;
END;
/
