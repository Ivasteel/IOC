/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.BIU_WU
    BEFORE INSERT OR UPDATE OF WU_ORG
    ON ikis_sysweb.w_users
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DISABLE
BEGIN
    SELECT x.org_org
      INTO :NEW.wu_org_org
      FROM v$v_opfu_all x
     WHERE x.org_id = :NEW.wu_org;
END;
/
