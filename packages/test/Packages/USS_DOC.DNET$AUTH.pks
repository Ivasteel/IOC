/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_DOC.DNET$AUTH
IS
    -- Author  : SHOSTAK
    -- Created : 26.05.2021 8:43:59
    -- Purpose :

    ------------------------------------------------------------------
    --Получение действующих токенов и настроек приложений
    ------------------------------------------------------------------
    PROCEDURE Get_Auth_Settings (p_Apps     OUT SYS_REFCURSOR,
                                 p_Tokens   OUT SYS_REFCURSOR);
END Dnet$auth;
/


GRANT EXECUTE ON USS_DOC.DNET$AUTH TO DNET_PROXY
/

GRANT EXECUTE ON USS_DOC.DNET$AUTH TO II01RC_USS_DOC_WEB
/

GRANT EXECUTE ON USS_DOC.DNET$AUTH TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_DOC.DNET$AUTH
IS
    ------------------------------------------------------------------
    --Получение действующих токенов и настроек приложений
    ------------------------------------------------------------------
    PROCEDURE Get_Auth_Settings (p_Apps     OUT SYS_REFCURSOR,
                                 p_Tokens   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Apps FOR SELECT a.App_Id, a.App_Code
                          FROM Api_Applications a;

        OPEN p_Tokens FOR SELECT t.Apt_App, t.Apt_Hash
                            FROM App_Tokens t
                           WHERE t.Apt_St = 'A' AND t.Apt_Expire_Dt > SYSDATE;
    END;
END Dnet$auth;
/