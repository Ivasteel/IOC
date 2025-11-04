/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.CMES_CONTEXT
IS
    -- Author  : SHOSTAK
    -- Created : 24.05.2023 9:24:18 AM
    -- Purpose :

    g_Context   CONSTANT VARCHAR2 (12) := 'CMES';

    g_Cuid      CONSTANT VARCHAR2 (10) := 'CUID';
    g_Owner     CONSTANT VARCHAR2 (10) := 'OID';
    g_Cmes      CONSTANT VARCHAR2 (10) := 'CMES';
    g_Numid     CONSTANT VARCHAR2 (10) := 'NUMID';
    g_Edrpou    CONSTANT VARCHAR2 (10) := 'EDRPOU';
    g_Session   CONSTANT VARCHAR2 (50) := 'SESSION';

    FUNCTION Get_Context (p_Attr IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Set_Dnet_Cmes_Context (p_Session      VARCHAR2,
                                     p_Ip_Address   VARCHAR2 DEFAULT NULL);

    PROCEDURE clear_context;
END Cmes_Context;
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.CMES_CONTEXT
IS
    FUNCTION Get_Context (p_Attr IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN SYS_CONTEXT (
                   g_Context,
                   CASE LOWER (p_Attr)
                       --
                       WHEN 'cuid' THEN g_Cuid
                       --
                       WHEN 'oid' THEN g_Owner
                       --
                       WHEN 'cmes' THEN g_Cmes
                       --
                       WHEN 'numid' THEN g_Numid
                       --
                       WHEN 'edrpou' THEN g_Edrpou
                   --
                   END);
    END;

    PROCEDURE Set_Dnet_Cmes_Context (p_Session      VARCHAR2,
                                     p_Ip_Address   VARCHAR2 DEFAULT NULL)
    IS
        l_Cu_Id           NUMBER;
        l_Cus_Id          NUMBER;
        l_Cmes_Id         NUMBER;
        l_Cmes_Owner_Id   NUMBER;
        l_Numident        VARCHAR2 (10);
        l_Edrpou          VARCHAR2 (10);
    BEGIN
        DBMS_SESSION.Clear_All_Context (g_Context);
        Dnet$cmes_Auth.Check_Session (p_Session, l_Cu_Id, l_Cus_Id);
        DBMS_SESSION.Set_Context (Namespace   => g_Context,
                                  Attribute   => g_Session,
                                  VALUE       => p_Session);
        DBMS_SESSION.Set_Context (Namespace   => g_Context,
                                  Attribute   => g_Cuid,
                                  VALUE       => l_Cu_Id);
        /*SELECT i.Cusi_Cmes,
               i.Cusi_Cmes_Owner_Id,
               i.Cusi_Edrpou,
               i.Cusi_Numident
          INTO l_Cmes_Id,
               l_Cmes_Owner_Id,
               l_Edrpou,
               l_Numident
          FROM Cu_Session_Info i
         WHERE i.Cusi_Cus = l_Cus_Id;
        Dbms_Session.Set_Context(Namespace => g_Context, Attribute => g_Cmes, VALUE => l_Cmes_Id);
        Dbms_Session.Set_Context(Namespace => g_Context, Attribute => g_Owner, VALUE => l_Cmes_Owner_Id);*/
        DBMS_SESSION.Set_Context (Namespace   => g_Context,
                                  Attribute   => g_Edrpou,
                                  VALUE       => l_Edrpou);
        DBMS_SESSION.Set_Context (Namespace   => g_Context,
                                  Attribute   => g_Numid,
                                  VALUE       => l_Numident);
    END;

    PROCEDURE clear_context
    IS
    BEGIN
        --DBMS_SESSION.RESET_PACKAGES;
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        DBMS_SESSION.Clear_All_Context (g_Context);
    END;
END Cmes_Context;
/