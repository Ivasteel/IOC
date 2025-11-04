/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_MINFIN_REQUEST_ROWS
    BEFORE INSERT
    ON uss_esr.me_minfin_request_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.memr_id = 0) OR (:NEW.memr_id IS NULL)
    THEN
        :NEW.memr_id := ID_me_minfin_request_rows (:NEW.memr_id);
    END IF;
END;
/
