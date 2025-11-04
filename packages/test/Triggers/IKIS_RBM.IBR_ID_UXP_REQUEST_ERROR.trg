/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_UXP_REQUEST_ERROR
    BEFORE INSERT
    ON ikis_rbm.uxp_request_error
    FOR EACH ROW
BEGIN
    IF (:NEW.ure_id = 0) OR (:NEW.ure_id IS NULL)
    THEN
        :NEW.ure_id := ID_uxp_request_error (:NEW.ure_id);
    END IF;
END;
/
