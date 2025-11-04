/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_LOG_PACKET
    BEFORE INSERT
    ON ikis_rbm.LOG_PACKET
    FOR EACH ROW
BEGIN
    IF (:NEW.lp_id = 0) OR (:NEW.lp_id IS NULL)
    THEN
        :NEW.lp_id := ID_LOG_PACKET (:NEW.lp_id);
    END IF;
END;
/
