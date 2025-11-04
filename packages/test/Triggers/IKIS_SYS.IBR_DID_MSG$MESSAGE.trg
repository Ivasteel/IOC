/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_DID_MSG$MESSAGE
    BEFORE INSERT
    ON IKIS_SYS.MSG$MESSAGE
    FOR EACH ROW
BEGIN
    IF dserials.gd_idiap_enabled
    THEN
        :NEW.mes_id := DID_MSG$MESSAGE (:NEW.mes_id);
    END IF;
END;
/
