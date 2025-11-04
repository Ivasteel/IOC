/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_HISTSESSION
    BEFORE INSERT
    ON uss_visit.histsession
    FOR EACH ROW
BEGIN
    IF (:NEW.hs_id = 0) OR (:NEW.hs_id IS NULL)
    THEN
        :NEW.hs_id := ID_histsession (:NEW.hs_id);
    END IF;
END;
/
