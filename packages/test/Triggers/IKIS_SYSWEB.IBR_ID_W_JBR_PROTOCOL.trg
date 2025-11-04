/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_W_JBR_PROTOCOL
    BEFORE INSERT
    ON ikis_sysweb.w_jbr_protocol
    FOR EACH ROW
BEGIN
    :NEW.jp_id := ID_w_jbr_protocol (:NEW.jp_id);
END;
/
