/* Formatted on 8/12/2025 5:50:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER USS_ESR.IBR_ID_ME_332VPO_REQUEST_ROWS
    BEFORE INSERT
    ON uss_esr.me_332vpo_request_rows
    FOR EACH ROW
BEGIN
    IF (:NEW.m3rr_id = 0) OR (:NEW.m3rr_id IS NULL)
    THEN
        :NEW.m3rr_id := ID_me_332vpo_request_rows (:NEW.m3rr_id);
    END IF;
END;
/
