/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_PACKET
    BEFORE INSERT
    ON ikis_rbm.PACKET
    FOR EACH ROW
BEGIN
    IF (:NEW.pkt_id = 0) OR (:NEW.pkt_id IS NULL)
    THEN
        :NEW.pkt_id := ID_PACKET (:NEW.pkt_id);
    END IF;
END;
/
