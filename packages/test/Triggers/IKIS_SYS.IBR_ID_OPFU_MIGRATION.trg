/* Formatted on 8/12/2025 6:10:10 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYS.IBR_ID_OPFU_MIGRATION
    BEFORE INSERT
    ON ikis_sys.opfu_migration
    FOR EACH ROW
BEGIN
    :NEW.orgm_id := ID_opfu_migration (:NEW.orgm_id);
END;
/
