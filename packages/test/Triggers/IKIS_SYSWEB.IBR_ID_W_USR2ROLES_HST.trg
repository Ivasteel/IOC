/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_W_USR2ROLES_HST
    BEFORE INSERT
    ON IKIS_SYSWEB.w_usr2roles_hst
    FOR EACH ROW
BEGIN
    :NEW.wu2rh_id := ID_w_usr2roles_hst (:NEW.wu2rh_id);
END;
/
