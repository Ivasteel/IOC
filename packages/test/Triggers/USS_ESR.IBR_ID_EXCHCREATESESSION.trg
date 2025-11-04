/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_EXCHCREATESESSION
    BEFORE INSERT
    ON uss_esr.exchcreatesession
    FOR EACH ROW
BEGIN
    IF (:NEW.ecs_id = 0) OR (:NEW.ecs_id IS NULL)
    THEN
        :NEW.ecs_id := ID_exchcreatesession (:NEW.ecs_id);
    END IF;
END;
/
