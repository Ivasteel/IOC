/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.Get_Util_Binary (
    p_Wut_Code          VARCHAR2,
    p_Wut_Version       VARCHAR2,
    p_Wut_Binary    OUT BLOB)
IS
BEGIN
    SELECT u.Wut_Binary
      INTO p_Wut_Binary
      FROM w_Utils u
     WHERE u.Wut_Code = p_Wut_Code AND u.Wut_Version = p_Wut_Version;
END Get_Util_Binary;
/


GRANT EXECUTE ON IKIS_SYSWEB.GET_UTIL_BINARY TO DNET_PROXY
/
