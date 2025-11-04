/* Formatted on 8/12/2025 5:47:13 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_DOC.Hash_Md5_String (p_String VARCHAR2)
    RETURN VARCHAR2
IS
BEGIN
    RETURN Sys.DBMS_CRYPTO.Hash (UTL_RAW.Cast_To_Raw (p_String), 2);
END Hash_Md5_String;
/
