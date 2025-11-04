/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PC_DECISION
    BEFORE INSERT
    ON uss_esr.pc_decision
    FOR EACH ROW
BEGIN
    IF (:NEW.pd_id = 0) OR (:NEW.pd_id IS NULL)
    THEN
        :NEW.pd_id := ID_pc_decision (:NEW.pd_id);
    END IF;
END;
/
