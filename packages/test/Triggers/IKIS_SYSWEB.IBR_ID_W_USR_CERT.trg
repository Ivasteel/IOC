/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_W_USR_CERT
    BEFORE INSERT
    ON IKIS_SYSWEB.w_usr_cert
    FOR EACH ROW
BEGIN
    :NEW.wcr_id := ID_w_usr_cert (:NEW.wcr_id);
END;
/
