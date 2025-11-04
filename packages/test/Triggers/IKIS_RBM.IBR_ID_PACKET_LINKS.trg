/* Formatted on 8/12/2025 6:10:55 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_RBM.IBR_ID_PACKET_LINKS
    BEFORE INSERT
    ON ikis_rbm.PACKET_LINKS
    FOR EACH ROW
BEGIN
    IF (:NEW.pl_id = 0) OR (:NEW.pl_id IS NULL)
    THEN
        :NEW.pl_id := ID_PACKET_LINKS (:NEW.pl_id);
    END IF;
END;
/
