/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_DID_W_USERS_HST
    BEFORE INSERT
    ON IKIS_SYSWEB.W_USERS_HST
    FOR EACH ROW
BEGIN
    IF dserials.gd_idiap_enabled
    THEN
        :NEW.wuh_id := DID_W_USERS_HST (:NEW.wuh_id);
    END IF;
END;
/
