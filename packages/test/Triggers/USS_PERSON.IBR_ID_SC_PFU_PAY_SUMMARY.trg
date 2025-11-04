/* Formatted on 8/12/2025 5:57:19 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_PERSON.IBR_ID_SC_PFU_PAY_SUMMARY
    BEFORE INSERT
    ON uss_person.sc_pfu_pay_summary
    FOR EACH ROW
BEGIN
    IF (:NEW.scpp_id = 0) OR (:NEW.scpp_id IS NULL)
    THEN
        :NEW.scpp_id := ID_sc_pfu_pay_summary (:NEW.scpp_id);
    END IF;
END;
/
