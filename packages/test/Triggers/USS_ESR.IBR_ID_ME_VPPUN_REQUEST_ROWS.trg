/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_VPPUN_REQUEST_ROWS
    BEFORE INSERT
    ON uss_esr.me_vppun_request_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.mvrr_id = 0) OR (:NEW.mvrr_id IS NULL)
    THEN
        :NEW.mvrr_id := ID_me_vppun_request_rows (:NEW.mvrr_id);
    END IF;
END;
/
