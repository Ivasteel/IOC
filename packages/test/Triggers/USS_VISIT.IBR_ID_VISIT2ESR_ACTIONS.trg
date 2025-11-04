/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_VISIT2ESR_ACTIONS
    BEFORE INSERT
    ON uss_visit.visit2esr_actions
    FOR EACH ROW
BEGIN
    IF (:NEW.vea_id = 0) OR (:NEW.vea_id IS NULL)
    THEN
        :NEW.vea_id := ID_visit2esr_actions (:NEW.vea_id);
    END IF;
END;
/
