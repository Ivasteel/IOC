/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_UXP_ACK
    BEFORE INSERT
    ON ikis_rbm.uxp_ack
    FOR EACH ROW
BEGIN
    IF (:NEW.ua_id = 0) OR (:NEW.ua_id IS NULL)
    THEN
        :NEW.ua_id := ID_uxp_ack (:NEW.ua_id);
    END IF;
END;
/
