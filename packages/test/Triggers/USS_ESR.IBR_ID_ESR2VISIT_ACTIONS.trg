/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ESR2VISIT_ACTIONS
    BEFORE INSERT
    ON uss_esr.esr2visit_actions
    FOR EACH ROW
BEGIN
    IF (:NEW.eva_id = 0) OR (:NEW.eva_id IS NULL)
    THEN
        :NEW.eva_id := ID_esr2visit_actions (:NEW.eva_id);
    END IF;
END;
/
