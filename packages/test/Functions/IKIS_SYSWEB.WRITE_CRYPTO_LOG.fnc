/* Formatted on 8/12/2025 6:11:36 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.Write_Crypto_Log (
    p_Event_Tp     VARCHAR2,
    p_Event_Info   CLOB,
    p_Wu_Id        NUMBER)
    RETURN NUMBER
IS
    v_Wcl_Id           NUMBER;
    v_Message          w_Crypto_Log.Wcl_Message%TYPE;
    v_Url              w_Crypto_Log.Wcl_Url%TYPE;
    v_Function         w_Crypto_Log.Wcl_Function%TYPE;
    v_Issuer_Ocsp      w_Crypto_Log.Wcl_Issuer_Ocsp%TYPE;
    v_Is_Desktop       w_Crypto_Log.Wcl_Is_Desktop%TYPE;
    v_Platform         w_Crypto_Log.Wcl_Platform%TYPE;
    v_User_Agent       w_Crypto_Log.Wcl_User_Agent%TYPE;
    v_Is_Key_From_Fs   w_Crypto_Log.Wcl_Is_Key_From_Fs%TYPE;
    v_Error_Id         w_Crypto_Log.Wcl_Error_Id%TYPE;
    v_Signed_Data      w_Crypto_Log.Wcl_Signed_Data%TYPE;
    v_Sign             w_Crypto_Log.Wcl_Sign%TYPE;
    v_Details          w_Crypto_Log.Wcl_Details%TYPE;
    v_Wu_Login         VARCHAR2 (30);
    v_Max_Msg_Length   NUMBER;
    v_Audit_Message    VARCHAR2 (4000);
BEGIN
    SELECT MESSAGE,
           DECODE (Is_Desktop, 'true', 'T', 'F'),
           Platform,
           User_Agent,
           Url_,
           DECODE (Is_Key_From_Fs, 'true', 'T', 'F'),
           Issuer_Ocsp,
           Caller,
           Error_Id,
           Signed_Data,
           SIGN,
           Details
      INTO v_Message,
           v_Is_Desktop,
           v_Platform,
           v_User_Agent,
           v_Url,
           v_Is_Key_From_Fs,
           v_Issuer_Ocsp,
           v_Function,
           v_Error_Id,
           v_Signed_Data,
           v_Sign,
           v_Details
      FROM JSON_TABLE (p_Event_Info,
                       '$[*]'
                       COLUMNS--
                              MESSAGE VARCHAR2 (4000) PATH '$.message',
                       Is_Desktop VARCHAR2 (10) PATH '$.isDesktop',
                       Platform VARCHAR2 (4000) PATH '$.platform',
                       User_Agent VARCHAR2 (4000) PATH '$.userAgent',
                       Url_ VARCHAR2 (4000) PATH '$.url',
                       Is_Key_From_Fs VARCHAR2 (10) PATH '$.isKeyFromFS',
                       Issuer_Ocsp VARCHAR2 (1000) PATH '$.issuerOcsp',
                       Caller VARCHAR2 (4000) PATH '$.caller',
                       Error_Id VARCHAR2 (30) PATH '$.errorId',
                       /*Signed_Data VARCHAR2(32000) Path '$.signedData',*/
                        --LEV 10.09.2021 змінено тип поля (нижче) так як на 19-ом Оракл вказаний тип викликав помилку
                       Signed_Data CLOB PATH '$.signedData',
                       /*Sign VARCHAR2(4000) Path '$.sign',*/
                        --LEV 10.09.2021 змінено тип поля (нижче) так як на 19-ом Оракл вказаний тип викликав помилку
                       SIGN CLOB PATH '$.sign',
                       Details VARCHAR2 (4000) PATH '$.details');

    INSERT INTO w_Crypto_Log (Wcl_Id,
                              Wcl_Dt,
                              Wcl_Event_Tp,
                              Wcl_Message,
                              Wcl_Url,
                              Wcl_Function,
                              Wcl_Issuer_Ocsp,
                              Wcl_Is_Desktop,
                              Wcl_Platform,
                              Wcl_User_Agent,
                              Wcl_Is_Key_From_Fs,
                              Wcl_Wu,
                              Wcl_Error_Id,
                              Wcl_Signed_Data,
                              Wcl_Sign,
                              Wcl_Details)
         VALUES (Sq_Id_w_Crypto_Log.NEXTVAL,
                 SYSDATE,
                 p_Event_Tp,
                 v_Message,
                 v_Url,
                 v_Function,
                 v_Issuer_Ocsp,
                 v_Is_Desktop,
                 v_Platform,
                 v_User_Agent,
                 v_Is_Key_From_Fs,
                 p_Wu_Id,
                 v_Error_Id,
                 v_Signed_Data,
                 v_Sign,
                 v_Details)
      RETURNING Wcl_Id
           INTO v_Wcl_Id;

    COMMIT;

    IF p_Event_Tp = 'ERROR'
    THEN
        SELECT MAX (u.Wu_Login)
          INTO v_Wu_Login
          FROM w_Users u
         WHERE u.Wu_Id = p_Wu_Id;

        IF v_Wu_Login IS NULL
        THEN
            RETURN v_Wcl_Id;
        END IF;

        v_Audit_Message :=
               'У користувача <'
            || v_Wu_Login
            || '> виникла помилка під час роботи криптографічного модуля: <:msg>; АЦСК: <'
            || v_Issuer_Ocsp
            || '>; Функція: <'
            || v_Function
            || '>; З використанням агента: <'
            || CASE WHEN v_Is_Desktop = 'T' THEN 'так' ELSE 'ні' END
            || '>';

        v_Max_Msg_Length := 4000 - LENGTH (v_Audit_Message);

        v_Audit_Message :=
            REPLACE (v_Audit_Message,
                     ':msg',
                     SUBSTR (v_Message, 1, v_Max_Msg_Length));

        Ikis_Sys.Ikis_Audit.Writemsg (p_Msg_Type     => 'WEB_CRYPTO_ERR',
                                      p_Msg_Text     => v_Audit_Message,
                                      p_Msg_Ess_Id   => p_Wu_Id);
        COMMIT;
    END IF;

    RETURN v_Wcl_Id;
END Write_Crypto_Log;
/


GRANT EXECUTE ON IKIS_SYSWEB.WRITE_CRYPTO_LOG TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.WRITE_CRYPTO_LOG TO USS_ESR
/

GRANT EXECUTE ON IKIS_SYSWEB.WRITE_CRYPTO_LOG TO USS_NDI
/

GRANT EXECUTE ON IKIS_SYSWEB.WRITE_CRYPTO_LOG TO USS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.WRITE_CRYPTO_LOG TO USS_RNSP
/

GRANT EXECUTE ON IKIS_SYSWEB.WRITE_CRYPTO_LOG TO USS_VISIT
/
