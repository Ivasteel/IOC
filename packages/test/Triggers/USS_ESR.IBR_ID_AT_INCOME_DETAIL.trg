/* Formatted on 8/12/2025 5:50:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_AT_INCOME_DETAIL
    BEFORE INSERT
    ON uss_esr.at_income_detail
    FOR EACH ROW
BEGIN
    IF (:NEW.aid_id = 0) OR (:NEW.aid_id IS NULL)
    THEN
        :NEW.aid_id := ID_at_income_detail (:NEW.aid_id);
    END IF;
END;
/
