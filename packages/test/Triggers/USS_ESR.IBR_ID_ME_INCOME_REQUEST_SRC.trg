/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_INCOME_REQUEST_SRC
    BEFORE INSERT
    ON uss_esr.me_income_request_src
    FOR EACH ROW
BEGIN
    IF (:NEW.mirs_id = 0) OR (:NEW.mirs_id IS NULL)
    THEN
        :NEW.mirs_id := ID_me_income_request_src (:NEW.mirs_id);
    END IF;
END;
/
