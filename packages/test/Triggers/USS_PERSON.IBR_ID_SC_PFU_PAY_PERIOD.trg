/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PFU_PAY_PERIOD
    BEFORE INSERT
    ON uss_person.sc_pfu_pay_period
    FOR EACH ROW
BEGIN
    IF (:NEW.scp3_id = 0) OR (:NEW.scp3_id IS NULL)
    THEN
        :NEW.scp3_id := ID_sc_pfu_pay_period (:NEW.scp3_id);
    END IF;
END;
/
