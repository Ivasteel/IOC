/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_DOC.API$AUTH
IS
    -- Author  : SHOSTAK
    -- Created : 26.05.2021 8:46:17
    -- Purpose :

    ------------------------------------------------------------------
    --Регистрация приложения
    ------------------------------------------------------------------
    PROCEDURE Register_App (p_App_Name              IN     VARCHAR2,
                            p_App_Code              IN     VARCHAR2,
                            p_App_Description       IN     VARCHAR2,
                            p_App_Token_Expire_Dt   IN     DATE,
                            p_App_User_Auth_Db      IN     VARCHAR2,
                            p_App_User_Auth_Proc    IN     VARCHAR2,
                            p_App_Token                OUT VARCHAR2);

    ------------------------------------------------------------------
    --Обновление токена приложения
    ------------------------------------------------------------------
    FUNCTION Refresh_App_Token (p_App_Token             IN VARCHAR2,
                                p_App_Token_Expire_Dt   IN DATE)
        RETURN VARCHAR2;

    FUNCTION Get_App_Code (p_App_Id NUMBER)
        RETURN VARCHAR2;
END Api$auth;
/


/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_DOC.API$AUTH
IS
    ------------------------------------------------------------------
    --Генерация токена приложения
    ------------------------------------------------------------------
    FUNCTION Generate_App_Token
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LOWER (DBMS_RANDOM.String (Opt => 'x', Len => 32));
    END;

    ------------------------------------------------------------------
    --Создание токена приложения
    ------------------------------------------------------------------
    FUNCTION Create_App_Token (p_App_Id IN NUMBER, p_Token_Expire_Dt IN DATE)
        RETURN VARCHAR2
    IS
        v_Result   VARCHAR2 (32);
    BEGIN
        v_Result := Generate_App_Token;

        INSERT INTO App_Tokens (Apt_Id,
                                Apt_App,
                                Apt_Hash,
                                Apt_Create_Dt,
                                Apt_Expire_Dt,
                                Apt_St)
             VALUES (NULL,
                     p_App_Id,
                     Hash_Md5_String (v_Result),
                     SYSDATE,
                     p_Token_Expire_Dt,
                     'A');

        RETURN v_Result;
    END;

    ------------------------------------------------------------------
    --Регистрация приложения
    ------------------------------------------------------------------
    PROCEDURE Register_App (p_App_Name              IN     VARCHAR2,
                            p_App_Code              IN     VARCHAR2,
                            p_App_Description       IN     VARCHAR2,
                            p_App_Token_Expire_Dt   IN     DATE,
                            p_App_User_Auth_Db      IN     VARCHAR2,
                            p_App_User_Auth_Proc    IN     VARCHAR2,
                            p_App_Token                OUT VARCHAR2)
    IS
        v_App_Id   NUMBER;
    BEGIN
        INSERT INTO Api_Applications (App_Id,
                                      App_Name,
                                      App_Code,
                                      App_Description,
                                      App_Reg_Dt,
                                      App_User_Auth_Db,
                                      App_User_Auth_Proc)
             VALUES (NULL,
                     p_App_Name,
                     p_App_Code,
                     p_App_Description,
                     SYSDATE,
                     p_App_User_Auth_Db,
                     p_App_User_Auth_Proc)
          RETURNING App_Id
               INTO v_App_Id;

        p_App_Token :=
            Create_App_Token (p_App_Id            => v_App_Id,
                              p_Token_Expire_Dt   => p_App_Token_Expire_Dt);
    END;

    ------------------------------------------------------------------
    --Проверка токена приложения
    ------------------------------------------------------------------
    FUNCTION Authencticate_App_Token (p_App_Token   IN     VARCHAR2,
                                      p_App_Id         OUT NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        SELECT MAX (t.Apt_App)
          INTO p_App_Id
          FROM App_Tokens t
         WHERE     t.Apt_Hash = Hash_Md5_String (p_App_Token)
               AND t.Apt_St = 'A'
               AND t.Apt_Expire_Dt > SYSDATE;

        RETURN p_App_Id IS NOT NULL;
    END;

    ------------------------------------------------------------------
    --Обновление токена приложения
    ------------------------------------------------------------------
    FUNCTION Refresh_App_Token (p_App_Token             IN VARCHAR2,
                                p_App_Token_Expire_Dt   IN DATE)
        RETURN VARCHAR2
    IS
        v_App_Id   NUMBER;
    BEGIN
        IF NOT Authencticate_App_Token (p_App_Token   => p_App_Token,
                                        p_App_Id      => v_App_Id)
        THEN
            Raise_Application_Error (-20000, 'Токен не аутентифіковано');
        END IF;

        UPDATE App_Tokens t
           SET t.Apt_St = 'H'
         WHERE t.Apt_App = v_App_Id;

        RETURN Create_App_Token (p_App_Id            => v_App_Id,
                                 p_Token_Expire_Dt   => p_App_Token_Expire_Dt);
    END;

    FUNCTION Get_App_Code (p_App_Id NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Api_Applications.App_Code%TYPE;
    BEGIN
        SELECT a.App_Code
          INTO l_Result
          FROM Api_Applications a
         WHERE a.App_Id = p_App_Id;

        RETURN l_Result;
    END;
END Api$auth;
/