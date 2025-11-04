/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_ID_OPFU_NAME
    BEFORE INSERT
    ON IKIS_SYS.opfu_name
    FOR EACH ROW
BEGIN
    :NEW.opn_id := ID_opfu_name (:NEW.opn_id);
END;
/
