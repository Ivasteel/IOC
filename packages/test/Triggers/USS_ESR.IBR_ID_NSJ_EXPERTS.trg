/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_NSJ_EXPERTS
    BEFORE INSERT
    ON uss_esr.nsj_experts
    FOR EACH ROW
BEGIN
    IF (:NEW.nje_id = 0) OR (:NEW.nje_id IS NULL)
    THEN
        :NEW.nje_id := ID_nsj_experts (:NEW.nje_id);
    END IF;
END;
/
