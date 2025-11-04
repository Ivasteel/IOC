/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_DID_ikis_utait
    BEFORE INSERT
    ON IKIS_SYS.IKIS_UTAIT
    FOR EACH ROW
BEGIN
    IF dserials.gd_idiap_enabled
    THEN
        :NEW.ut_id := DID_ikis_utait (:NEW.ut_id);
    END IF;
END;
/
