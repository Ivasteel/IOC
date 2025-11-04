/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_DOC.USS_DOC_CONTEXT
IS
    -- Author  : SHOSTAK
    -- Created : 05.06.2023 9:21:17 PM
    -- Purpose :

    g_Context   CONSTANT VARCHAR2 (10) := 'USS_DOC';
    g_Uid       CONSTANT VARCHAR2 (10) := 'USSUID';
    g_Cuid      CONSTANT VARCHAR2 (10) := 'CMESUID';
    g_App       CONSTANT VARCHAR2 (10) := 'APP';

    FUNCTION Get_Context (p_Attr IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Set_App_Context (p_App_Id IN NUMBER);

    PROCEDURE Set_Context_Uss (p_Session_Id IN VARCHAR2);

    PROCEDURE Set_Context_Cmes (p_Session_Id IN VARCHAR2);
END Uss_Doc_Context;
/


/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_DOC.USS_DOC_CONTEXT
IS
    FUNCTION Get_Context (p_Attr IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Value   VARCHAR2 (100);
    BEGIN
        l_Value :=
            SYS_CONTEXT (
                g_Context,
                CASE LOWER (p_Attr)
                    WHEN 'ussuid' THEN g_Uid
                    WHEN 'cmesuid' THEN g_Cuid
                    WHEN 'app' THEN g_App
                END);

        RETURN l_Value;
    END;

    PROCEDURE Set_App_Context (p_App_Id IN NUMBER)
    IS
    BEGIN
        DBMS_SESSION.Set_Context (Namespace   => g_Context,
                                  Attribute   => g_App,
                                  VALUE       => p_App_Id);
    END;

    PROCEDURE Set_Context_Uss (p_Session_Id IN VARCHAR2)
    IS
        l_User   VARCHAR2 (50);
        l_Uid    NUMBER;
        l_Wut    NUMBER;
        l_Org    NUMBER;
        l_Trc    VARCHAR2 (10);
    BEGIN
        Ikis_Sysweb.Ikis_Dnet_Auth.Checksession (
            p_Session_Id   => p_Session_Id,
            p_Login        => l_User);
        Ikis_Sysweb.Getuserattr (p_Username   => l_User,
                                 p_Uid        => l_Uid,
                                 p_Wut        => l_Wut,
                                 p_Org        => l_Org,
                                 p_Trc        => l_Trc);
        DBMS_SESSION.Set_Context (Namespace   => g_Context,
                                  Attribute   => g_Uid,
                                  VALUE       => l_Uid);
    END;

    PROCEDURE Set_Context_Cmes (p_Session_Id IN VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Ikis_Rbm.Api$cmes_Auth.Check_Session (p_Session_Id   => p_Session_Id,
                                              p_Cu_Id        => l_Cu_Id);
        DBMS_SESSION.Set_Context (Namespace   => g_Context,
                                  Attribute   => g_Cuid,
                                  VALUE       => l_Cu_Id);
    END;
END Uss_Doc_Context;
/