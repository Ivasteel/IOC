/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_W_TYPICAL_ROLE
    BEFORE INSERT
    ON ikis_sysweb.w_typical_role
    FOR EACH ROW
BEGIN
    :NEW.wtr_id := ID_w_typical_role (:NEW.wtr_id);
END;
/
