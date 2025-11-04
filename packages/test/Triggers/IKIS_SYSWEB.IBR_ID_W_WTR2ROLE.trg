/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_W_WTR2ROLE
    BEFORE INSERT
    ON ikis_sysweb.w_wtr2role
    FOR EACH ROW
BEGIN
    :NEW.wtrr_id := ID_w_wtr2role (:NEW.wtrr_id);
END;
/
