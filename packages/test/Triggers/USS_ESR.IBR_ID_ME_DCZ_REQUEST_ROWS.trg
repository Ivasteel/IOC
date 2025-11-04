/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_DCZ_REQUEST_ROWS
    BEFORE INSERT
    ON uss_esr.me_dcz_request_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.mdrr_id = 0) OR (:NEW.mdrr_id IS NULL)
    THEN
        :NEW.mdrr_id := ID_me_dcz_request_rows (:NEW.mdrr_id);
    END IF;
END;
/
