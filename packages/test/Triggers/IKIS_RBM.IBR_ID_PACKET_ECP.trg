/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_PACKET_ECP
    BEFORE INSERT
    ON IKIS_RBM.PACKET_ECP
    FOR EACH ROW
BEGIN
    IF (:NEW.pce_id = 0) OR (:NEW.pce_id IS NULL)
    THEN
        :NEW.pce_id := ID_PACKET_ECP (:NEW.pce_id);
    END IF;
END;
/
