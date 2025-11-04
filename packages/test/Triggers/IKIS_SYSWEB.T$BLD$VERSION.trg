/* Formatted on 8/12/2025 6:11:32 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_SYSWEB.T$BLD$version
    BEFORE INSERT OR UPDATE OF bldv_major_ver, bldv_minor_ver
    ON IKIS_SYSWEB.BLD$VERSION
    FOR EACH ROW
BEGIN
    :NEW.bldv_version := :NEW.bldv_major_ver || '.' || :NEW.bldv_minor_ver;
END;
/
