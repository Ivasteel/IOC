/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_DID_IKIS_CHANGES
    BEFORE INSERT
    ON IKIS_SYS.IKIS_CHANGES
    FOR EACH ROW
BEGIN
    IF dserials.gd_idiap_enabled
    THEN
        :NEW.ich_id := DID_IKIS_CHANGES (:NEW.ich_id);
    END IF;
END;
/
