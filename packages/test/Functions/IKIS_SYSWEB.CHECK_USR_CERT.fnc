/* Formatted on 8/12/2025 6:11:35 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.Check_Usr_Cert (
    p_User_Id       NUMBER,
    p_Cert_Serial   VARCHAR2,
    p_Cert_Issuer   VARCHAR2)
    RETURN NUMBER
IS
    v_Result   NUMBER;
BEGIN
    --Проверяем принадлежит ли сертификат пользователю
    SELECT DECODE (COUNT (*), 0, 0, 1)
      INTO v_Result
      FROM w_Usr_Cert c
     WHERE     c.Wcr_Wu = p_User_Id
           AND c.Wcr_Cert_Serial = p_Cert_Serial
           AND c.Wcr_Issuer = p_Cert_Issuer
           AND c.Wcr_St = 'A';

    RETURN v_Result;
END Check_Usr_Cert;
/
