/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_DID_IKIS_PROT_SEANS
    BEFORE INSERT
    ON IKIS_SYS.IKIS_PROT_SEANS
    FOR EACH ROW
BEGIN
    IF dserials.gd_idiap_enabled
    THEN
        :NEW.ps_id := DID_IKIS_PROT_SEANS (:NEW.ps_id);
    END IF;
END;
/
