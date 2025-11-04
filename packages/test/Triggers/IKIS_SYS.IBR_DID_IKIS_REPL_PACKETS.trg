/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_DID_IKIS_REPL_PACKETS
    BEFORE INSERT
    ON IKIS_SYS.IKIS_REPL_PACKETS
    FOR EACH ROW
BEGIN
    IF dserials.gd_idiap_enabled
    THEN
        :NEW.irp_id := DID_IKIS_REPL_PACKETS (:NEW.irp_id);
    END IF;
END;
/
