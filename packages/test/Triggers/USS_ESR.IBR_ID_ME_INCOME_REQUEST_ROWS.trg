/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_INCOME_REQUEST_ROWS
    BEFORE INSERT
    ON uss_esr.me_income_request_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.mirr_id = 0) OR (:NEW.mirr_id IS NULL)
    THEN
        :NEW.mirr_id := ID_me_income_request_rows (:NEW.mirr_id);
    END IF;
END;
/
