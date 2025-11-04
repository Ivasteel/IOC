/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_DID_MSG$SUBSCRABER
    BEFORE INSERT
    ON IKIS_SYS.MSG$SUBSCRABER
    FOR EACH ROW
BEGIN
    IF dserials.gd_idiap_enabled
    THEN
        :NEW.ms_id := DID_MSG$SUBSCRABER (:NEW.ms_id);
    END IF;
END;
/
