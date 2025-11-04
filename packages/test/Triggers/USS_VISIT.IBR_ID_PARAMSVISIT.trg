/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_PARAMSVISIT
    BEFORE INSERT
    ON uss_visit.paramsvisit
    FOR EACH ROW
BEGIN
    IF (:NEW.prm_id = 0) OR (:NEW.prm_id IS NULL)
    THEN
        :NEW.prm_id := ID_paramsvisit (:NEW.prm_id);
    END IF;
END;
/
