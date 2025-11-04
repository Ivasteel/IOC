/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$CMES_AUTH
IS
    -- Author  : SHOST
    -- Created : 06.02.2023 15:59:39
    -- Purpose : Автентифікація та авторизація користувачів КМЕС

    c_Cmes_Bank          CONSTANT NUMBER := 1;
    c_Cmes_Ss_Provider   CONSTANT NUMBER := 2;
    c_Cmes_Ss_Receiver   CONSTANT NUMBER := 3;

    FUNCTION Is_Adm_Role_Assigned (p_Cu_Id           IN NUMBER,
                                   p_Cmes_Id         IN NUMBER,
                                   p_Cmes_Owner_Id   IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Adm_Role_Assigned (p_Cmes_Id         IN NUMBER,
                                   p_Cmes_Owner_Id   IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Role_Assigned (p_Cu_Id           IN NUMBER,
                               p_Cmes_Id         IN NUMBER,
                               p_Cmes_Owner_Id   IN NUMBER,
                               p_Cr_Code         IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Is_Role_Assigned (p_Cmes_Id         IN NUMBER,
                               p_Cmes_Owner_Id   IN NUMBER,
                               p_Cr_Code         IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Is_Roles_Assigned (p_Cu_Id           IN NUMBER,
                                p_Cmes_Id         IN NUMBER,
                                p_Cmes_Owner_Id   IN NUMBER,
                                p_Cr_Codes        IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Is_Roles_Assigned (p_Cmes_Id         IN NUMBER,
                                p_Cmes_Owner_Id   IN NUMBER,
                                p_Cr_Codes        IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Get_Role_Id (p_Crr_Code IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Parse_Session (p_Session_Id       VARCHAR2,
                             p_Id           OUT NUMBER,
                             p_Code         OUT VARCHAR2);

    PROCEDURE Check_Session (p_Session_Id   IN     VARCHAR2,
                             p_Cu_Id           OUT NUMBER,
                             p_Cus_Id          OUT NUMBER);

    PROCEDURE Check_Session (p_Session_Id IN VARCHAR2, p_Cu_Id OUT NUMBER);
END Api$cmes_Auth;
/


GRANT EXECUTE ON IKIS_RBM.API$CMES_AUTH TO II01RC_RBM_CMES
/

GRANT EXECUTE ON IKIS_RBM.API$CMES_AUTH TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$CMES_AUTH TO II01RC_RBM_PORTAL
/

GRANT EXECUTE ON IKIS_RBM.API$CMES_AUTH TO PORTAL_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$CMES_AUTH TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$CMES_AUTH TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$CMES_AUTH TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$CMES_AUTH TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$CMES_AUTH TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$CMES_AUTH
IS
    FUNCTION Is_Adm_Role_Assigned (p_Cu_Id           IN NUMBER,
                                   p_Cmes_Id         IN NUMBER,
                                   p_Cmes_Owner_Id   IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Is_Role_Assigned   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Is_Role_Assigned
          FROM Cu_Users2roles  r
               JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr ON r.Cu2r_Cr = Cr.Cr_Id
         WHERE     r.Cu2r_Cu = p_Cu_Id
               AND r.Cu2r_Cmes_Owner_Id = p_Cmes_Owner_Id
               AND r.History_Status = 'A'
               AND Cr.Cr_Cmes = p_Cmes_Id
               AND Cr.Cr_Actual = 'A'
               AND Cr.Cr_Tp = 'A';

        RETURN l_Is_Role_Assigned = 1;
    END;

    FUNCTION Is_Adm_Role_Assigned (p_Cmes_Id         IN NUMBER,
                                   p_Cmes_Owner_Id   IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Is_Adm_Role_Assigned (
                   Cmes_Context.Get_Context (Cmes_Context.g_Cuid),
                   p_Cmes_Id,
                   p_Cmes_Owner_Id);
    END;

    FUNCTION Is_Role_Assigned (p_Cu_Id           IN NUMBER,
                               p_Cmes_Id         IN NUMBER,
                               p_Cmes_Owner_Id   IN NUMBER,
                               p_Cr_Code         IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Role_Assigned   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Role_Assigned
          FROM Cu_Users2roles  r
               JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                   ON r.Cu2r_Cr = Cr.Cr_Id AND Cr.Cr_Actual = 'A'
         WHERE     r.Cu2r_Cu = p_Cu_Id
               AND r.Cu2r_Cmes_Owner_Id = p_Cmes_Owner_Id
               AND r.History_Status = 'A'
               AND Cr.Cr_Cmes = p_Cmes_Id
               AND Cr.Cr_Code = p_Cr_Code;

        RETURN l_Role_Assigned = 1;
    END;

    FUNCTION Is_Role_Assigned (p_Cmes_Id         IN NUMBER,
                               p_Cmes_Owner_Id   IN NUMBER,
                               p_Cr_Code         IN VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Is_Role_Assigned (
                   Cmes_Context.Get_Context (Cmes_Context.g_Cuid),
                   p_Cmes_Id,
                   p_Cmes_Owner_Id,
                   p_Cr_Code);
    END;

    FUNCTION Is_Roles_Assigned (p_Cu_Id           IN NUMBER,
                                p_Cmes_Id         IN NUMBER,
                                p_Cmes_Owner_Id   IN NUMBER,
                                p_Cr_Codes        IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Role_Assigned   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Role_Assigned
          FROM Cu_Users2roles  r
               JOIN Uss_Ndi.v_Ndi_Cmes_Roles Cr
                   ON r.Cu2r_Cr = Cr.Cr_Id AND Cr.Cr_Actual = 'A'
         WHERE     r.Cu2r_Cu = p_Cu_Id
               AND r.Cu2r_Cmes_Owner_Id = p_Cmes_Owner_Id
               AND r.History_Status = 'A'
               AND Cr.Cr_Cmes = p_Cmes_Id
               AND Cr.Cr_Code IN
                       (SELECT (COLUMN_VALUE).Getstringval ()
                          FROM XMLTABLE (
                                   (   '"'
                                    || REPLACE (p_Cr_Codes, ',', '","')
                                    || '"')));

        RETURN l_Role_Assigned = 1;
    END;

    FUNCTION Is_Roles_Assigned (p_Cmes_Id         IN NUMBER,
                                p_Cmes_Owner_Id   IN NUMBER,
                                p_Cr_Codes        IN VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Is_Roles_Assigned (
                   Cmes_Context.Get_Context (Cmes_Context.g_Cuid),
                   p_Cmes_Id,
                   p_Cmes_Owner_Id,
                   p_Cr_Codes);
    END;

    FUNCTION Get_Role_Id (p_Crr_Code IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Cr_Id   NUMBER;
    BEGIN
        SELECT r.Cr_Id
          INTO l_Cr_Id
          FROM Uss_Ndi.v_Ndi_Cmes_Roles r
         WHERE r.Cr_Code = p_Crr_Code;

        RETURN l_Cr_Id;
    END;

    ---------------------------------------------------------------------------
    --                 Парсинг ідентифікатора сесії
    ---------------------------------------------------------------------------
    PROCEDURE Parse_Session (p_Session_Id       VARCHAR2,
                             p_Id           OUT NUMBER,
                             p_Code         OUT VARCHAR2)
    IS
        l_Pos   PLS_INTEGER;
    BEGIN
        l_Pos := INSTR (p_Session_Id, '-');

        IF (l_Pos <= 0)
        THEN
            Raise_Application_Error (-20000, 'Невірний код сесії');
        END IF;

        p_Id := TO_NUMBER (SUBSTR (p_Session_Id, 1, l_Pos - 1));
        p_Code := SUBSTR (p_Session_Id, l_Pos + 1);
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (-20000, 'Невірний код сесії');
    END;

    ---------------------------------------------------------------------------
    --                 Перевірка сесії(для внутрішніх ресурсів)
    ---------------------------------------------------------------------------
    PROCEDURE Check_Session (p_Session_Id   IN     VARCHAR2,
                             p_Cu_Id           OUT NUMBER,
                             p_Cus_Id          OUT NUMBER)
    IS
        l_Id     NUMBER;
        l_Code   VARCHAR2 (40);
    BEGIN
        Parse_Session (p_Session_Id   => p_Session_Id,
                       p_Id           => l_Id,
                       p_Code         => l_Code);

        SELECT s.Cus_Id, s.Cus_Cu
          INTO p_Cus_Id, p_Cu_Id
          FROM Cu_Session s
         WHERE     s.Cus_Id = l_Id
               AND s.Cus_Code = l_Code
               AND s.Cus_Stop_Dt >= SYSDATE
               AND s.History_Status = 'A';
    END;

    ---------------------------------------------------------------------------
    --                 Перевірка сесії(для внутрішніх ресурсів)
    ---------------------------------------------------------------------------
    PROCEDURE Check_Session (p_Session_Id IN VARCHAR2, p_Cu_Id OUT NUMBER)
    IS
        l_Cus_Id   NUMBER;
    BEGIN
        Check_Session (p_Session_Id, p_Cu_Id, l_Cus_Id);
    END;
END Api$cmes_Auth;
/