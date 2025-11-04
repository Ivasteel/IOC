/* Formatted on 8/12/2025 6:11:36 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.ikis_sysweb_auth (
    p_username   IN VARCHAR2,
    p_password   IN VARCHAR2)
    RETURN BOOLEAN
AS
BEGIN
    RETURN ikis_htmldb_auth.ikis_auth (p_username, p_password);
END;
/
