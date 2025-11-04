/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.Ikis_Bi_Auth
IS
    -- Author  : SHOSTAK
    -- Created : 27.01.2020 17:12:13
    -- Purpose :

    TYPE r_User_Attr IS RECORD
    (
        User_Id          NUMBER,
        User_Tp          NUMBER,
        User_Opfu        NUMBER,
        User_Org_Name    VARCHAR2 (250)
    );

    TYPE t_User_Attr IS TABLE OF r_User_Attr;

    FUNCTION Authenticate (p_Username VARCHAR2, p_Password VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_User_Attributes (p_Username VARCHAR2)
        RETURN t_User_Attr
        PIPELINED;

    FUNCTION Get_User_Id (p_Username VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_User_Tp (p_Username VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_User_Opfu (p_Username VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_User_Roles (p_User_Id     NUMBER,
                             p_Delimiter   VARCHAR2 DEFAULT ';')
        RETURN VARCHAR2;
END Ikis_Bi_Auth;
/


/* Formatted on 8/12/2025 6:11:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.Ikis_Bi_Auth
IS
    ---------------------------------------------------------------
    --                   АУТЕНТИФИКАЦИЯ
    ---------------------------------------------------------------
    FUNCTION Authenticate (p_Username VARCHAR2, p_Password VARCHAR2)
        RETURN VARCHAR2
    IS
        v_Wu_Id                    NUMBER;
        c_Bi_Role_Group   CONSTANT NUMBER := 34;
        v_Has_Bi_Role              NUMBER := 0;
    BEGIN
        IF NOT Ikis_Htmldb_Auth.Ikis_Auth (p_Username, p_Password)
        THEN
            Raise_Application_Error (-20000, 'Authentication failed');
        END IF;

        SELECT u.Wu_Id
          INTO v_Wu_Id
          FROM w_Users u
         WHERE u.Wu_Login = UPPER (p_Username);

        --Проверяем наличие одной из ролей группы BI
        SELECT DECODE (COUNT (*), 0, 0, 1)
          INTO v_Has_Bi_Role
          FROM w_Usr2roles  r
               JOIN w_Wrg2role g
                   ON r.Wr_Id = g.Wrgr_Wr AND g.Wrgr_Wrg = c_Bi_Role_Group
         WHERE r.Wu_Id = v_Wu_Id;

        IF v_Has_Bi_Role = 1
        THEN
            RETURN p_Username;
        ELSE
            Raise_Application_Error (-20000, 'Authentication failed');
        END IF;
    END;

    FUNCTION Get_User_Attributes (p_Username VARCHAR2)
        RETURN t_User_Attr
        PIPELINED
    IS
        v_Result   r_User_Attr;
    BEGIN
        SELECT u.Wu_Id,
               u.Wu_Wut,
               u.Wu_Org,
               o.Org_Name
          INTO v_Result
          FROM w_Users u JOIN Ikis_Sys.v_Opfu o ON u.Wu_Org = o.Org_Id
         WHERE u.Wu_Login = UPPER (p_Username);

        PIPE ROW (v_Result);
    END;

    ---------------------------------------------------------------
    --               Получение ИД пользователя
    ---------------------------------------------------------------
    FUNCTION Get_User_Id (p_Username VARCHAR2)
        RETURN NUMBER
    IS
        v_Result   NUMBER;
    BEGIN
        SELECT u.Wu_Id
          INTO v_Result
          FROM w_Users u
         WHERE u.Wu_Login = UPPER (p_Username);

        RETURN v_Result;
    END;

    ---------------------------------------------------------------
    --               Получение типа пользователя
    ---------------------------------------------------------------
    FUNCTION Get_User_Tp (p_Username VARCHAR2)
        RETURN NUMBER
    IS
        v_Result   NUMBER;
    BEGIN
        SELECT u.Wu_Wut
          INTO v_Result
          FROM w_Users u
         WHERE u.Wu_Login = UPPER (p_Username);

        RETURN v_Result;
    END;

    ---------------------------------------------------------------
    --               Получение ОПФУ пользователя
    ---------------------------------------------------------------
    FUNCTION Get_User_Opfu (p_Username VARCHAR2)
        RETURN NUMBER
    IS
        v_Result   NUMBER;
    BEGIN
        SELECT u.Wu_Org
          INTO v_Result
          FROM w_Users u
         WHERE u.Wu_Login = UPPER (p_Username);

        RETURN v_Result;
    END;

    ---------------------------------------------------------------
    --                 Получение списка ролей пользователя
    ---------------------------------------------------------------
    FUNCTION Get_User_Roles (p_User_Id     NUMBER,
                             p_Delimiter   VARCHAR2 DEFAULT ';')
        RETURN VARCHAR2
    IS
        v_Result   VARCHAR2 (32000);
    BEGIN
        SELECT LISTAGG (r.Wr_Name, p_Delimiter) WITHIN GROUP (ORDER BY 1)
          INTO v_Result
          FROM w_Usr2roles  Ur
               JOIN w_Roles r ON Ur.Wr_Id = r.Wr_Id
               JOIN w_Wrg2role g ON r.Wr_Id = g.Wrgr_Wr --Только BI роли
                                                        AND g.Wrgr_Wrg = 34
         WHERE Ur.Wu_Id = p_User_Id;

        RETURN v_Result;
    END;
END Ikis_Bi_Auth;
/