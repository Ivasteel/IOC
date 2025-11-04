/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PC_ACCRUAL_QUEUE
    BEFORE INSERT
    ON uss_esr.pc_accrual_queue
    FOR EACH ROW
BEGIN
    IF (:NEW.paq_id = 0) OR (:NEW.paq_id IS NULL)
    THEN
        :NEW.paq_id := ID_pc_accrual_queue (:NEW.paq_id);
    END IF;
END;
/
