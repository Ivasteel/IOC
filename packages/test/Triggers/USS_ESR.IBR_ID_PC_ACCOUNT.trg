/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_PC_ACCOUNT
    BEFORE INSERT
    ON uss_esr.pc_account
    FOR EACH ROW
BEGIN
    IF (:NEW.pa_id = 0) OR (:NEW.pa_id IS NULL)
    THEN
        :NEW.pa_id := ID_pc_account (:NEW.pa_id);
    END IF;
END;
/
