/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_DPS_REQUEST_ROWS
    BEFORE INSERT
    ON uss_esr.me_dps_request_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.mprr_id = 0) OR (:NEW.mprr_id IS NULL)
    THEN
        :NEW.mprr_id := ID_me_dps_request_rows (:NEW.mprr_id);
    END IF;
END;
/
