/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_APP_VERSIONS
    BEFORE INSERT
    ON uss_visit.app_versions
    FOR EACH ROW
BEGIN
    IF (:NEW.av_id = 0) OR (:NEW.av_id IS NULL)
    THEN
        :NEW.av_id := ID_app_versions (:NEW.av_id);
    END IF;
END;
/
