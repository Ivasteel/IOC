/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PFU_PAY_OUT
    BEFORE INSERT
    ON uss_person.sc_pfu_pay_out
    FOR EACH ROW
BEGIN
    IF (:NEW.scpu_id = 0) OR (:NEW.scpu_id IS NULL)
    THEN
        :NEW.scpu_id := ID_sc_pfu_pay_out (:NEW.scpu_id);
    END IF;
END;
/
