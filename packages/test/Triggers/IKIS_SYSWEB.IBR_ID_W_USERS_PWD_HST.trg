/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_W_USERS_PWD_HST
    BEFORE INSERT
    ON IKIS_SYSWEB.w_users_pwd_hst
    FOR EACH ROW
BEGIN
    :NEW.wuph_id := ID_w_users_pwd_hst (:NEW.wuph_id);
END;
/
