/* Formatted on 8/12/2025 6:00:11 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_VISIT.IBR_ID_VISIT2RNSP_ACTION
    BEFORE INSERT
    ON uss_visit.visit2rnsp_action
    FOR EACH ROW
BEGIN
    IF (:NEW.vra_id = 0) OR (:NEW.vra_id IS NULL)
    THEN
        :NEW.vra_id := ID_visit2rnsp_action (:NEW.vra_id);
    END IF;
END;
/
