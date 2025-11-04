/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.IBR_ID_W_MESSAGE_PARAMS
    BEFORE INSERT
    ON ikis_sysweb.w_message_params
    FOR EACH ROW
BEGIN
    :NEW.wmp_id := ID_W_MESSAGE_PARAMS (:NEW.wmp_id);
END;
/
