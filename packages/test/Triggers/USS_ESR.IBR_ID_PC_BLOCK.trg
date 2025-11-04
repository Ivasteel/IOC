/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PC_BLOCK
    BEFORE INSERT
    ON uss_esr.pc_block
    FOR EACH ROW
BEGIN
    IF (:NEW.pcb_id = 0) OR (:NEW.pcb_id IS NULL)
    THEN
        :NEW.pcb_id := ID_pc_block (:NEW.pcb_id);
    END IF;
END;
/
