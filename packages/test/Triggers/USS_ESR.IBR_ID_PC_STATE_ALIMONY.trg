/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PC_STATE_ALIMONY
    BEFORE INSERT
    ON uss_esr.pc_state_alimony
    FOR EACH ROW
BEGIN
    IF (:NEW.ps_id = 0) OR (:NEW.ps_id IS NULL)
    THEN
        :NEW.ps_id := ID_pc_state_alimony (:NEW.ps_id);
    END IF;
END;
/
