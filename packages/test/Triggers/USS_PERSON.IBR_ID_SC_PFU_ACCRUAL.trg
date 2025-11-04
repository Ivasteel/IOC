/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PFU_ACCRUAL
    BEFORE INSERT
    ON uss_person.sc_pfu_accrual
    FOR EACH ROW
BEGIN
    IF (:NEW.scpc_id = 0) OR (:NEW.scpc_id IS NULL)
    THEN
        :NEW.scpc_id := ID_sc_pfu_accrual (:NEW.scpc_id);
    END IF;
END;
/
