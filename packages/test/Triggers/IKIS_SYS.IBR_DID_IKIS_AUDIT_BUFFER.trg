/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_DID_IKIS_AUDIT_BUFFER
    BEFORE INSERT
    ON IKIS_SYS.IKIS_AUDIT_BUFFER
    FOR EACH ROW
BEGIN
    IF dserials.gd_idiap_enabled
    THEN
        :NEW.iab_id := DID_IKIS_AUDIT_BUFFER (:NEW.iab_id);
    END IF;
END;
/
