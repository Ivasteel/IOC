/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_UXP_REQUEST
    BEFORE INSERT
    ON ikis_rbm.uxp_request
    FOR EACH ROW
BEGIN
    IF (:NEW.ur_id = 0) OR (:NEW.ur_id IS NULL)
    THEN
        :NEW.ur_id := ID_uxp_request (:NEW.ur_id);
    END IF;
END;
/
