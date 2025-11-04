/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_DID_IKIS_REPL_PACK_PAR
    BEFORE INSERT
    ON IKIS_SYS.IKIS_REPL_PACK_PAR
    FOR EACH ROW
BEGIN
    IF dserials.gd_idiap_enabled
    THEN
        :NEW.irpp_id := DID_IKIS_REPL_PACK_PAR (:NEW.irpp_id);
    END IF;
END;
/
