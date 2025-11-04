/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST
IS
    -- Author  : SHOSTAK
    -- Created : 16.07.2021 18:07:31
    -- Purpose :

    c_Rn_St_New   CONSTANT VARCHAR2 (10) := 'NEW';
    c_Rn_St_Err   CONSTANT VARCHAR2 (10) := 'ERR';
    c_Rn_St_Ok    CONSTANT VARCHAR2 (10) := 'OK';

    PROCEDURE Save_Request_Journal (
        p_Rn_Id          IN     Request_Journal.Rn_Id%TYPE DEFAULT NULL,
        p_Rn_Nrt         IN     Request_Journal.Rn_Nrt%TYPE DEFAULT NULL,
        p_Rn_Hs_Ins      IN     Request_Journal.Rn_Hs_Ins%TYPE DEFAULT NULL,
        p_Rn_Ins_Dt      IN     Request_Journal.Rn_Ins_Dt%TYPE DEFAULT NULL,
        p_Rn_Expect_Dt   IN     Request_Journal.Rn_Expect_Dt%TYPE DEFAULT NULL,
        p_Rn_Worked_Mc   IN     Request_Journal.Rn_Worked_Mc%TYPE DEFAULT NULL,
        p_Rn_St          IN     Request_Journal.Rn_St%TYPE DEFAULT NULL,
        p_Rn_Src         IN     Request_Journal.Rn_Src%TYPE DEFAULT NULL,
        p_Rn_Answer_Dt   IN     Request_Journal.Rn_Answer_Dt%TYPE DEFAULT NULL,
        p_Rn_Ask_Dt      IN     Request_Journal.Rn_Ask_Dt%TYPE DEFAULT NULL,
        p_New_Id            OUT Request_Journal.Rn_Id%TYPE);

    -- 29/04/2024 serhii: розширив для зрізу анкети Rn_Person.Rnp_Scc
    PROCEDURE Save_Rn_Person (
        p_Rnp_Id           IN     Rn_Person.Rnp_Id%TYPE,
        p_Rnp_Rn           IN     Rn_Person.Rnp_Rn%TYPE,
        p_Rnp_Sc           IN     Rn_Person.Rnp_Sc%TYPE,
        p_Rnp_Inn          IN     Rn_Person.Rnp_Inn%TYPE,
        p_Rnp_Ndt          IN     Rn_Person.Rnp_Ndt%TYPE,
        p_Rnp_Doc_Seria    IN     Rn_Person.Rnp_Doc_Seria%TYPE,
        p_Rnp_Doc_Number   IN     Rn_Person.Rnp_Doc_Number%TYPE,
        p_Rnp_Sc_Unique    IN     Rn_Person.Rnp_Sc_Unique%TYPE,
        p_Rnp_Scc          IN     Rn_Person.Rnp_Scc%TYPE DEFAULT NULL,
        p_New_Id              OUT Rn_Person.Rnp_Id%TYPE);

    PROCEDURE Set_Rnp_Sc (p_Rnp_Rn   IN Rn_Person.Rnp_Rn%TYPE,
                          p_Rnp_Sc   IN Rn_Person.Rnp_Sc%TYPE);

    PROCEDURE Save_Rnp_Identity_Info (
        p_Rnpi_Id    IN     Rnp_Identity_Info.Rnpi_Id%TYPE,
        p_Rnpi_Rnp   IN     Rnp_Identity_Info.Rnpi_Rnp%TYPE,
        p_Rnpi_Rn    IN     Rnp_Identity_Info.Rnpi_Rn%TYPE,
        p_Rnpi_Fn    IN     Rnp_Identity_Info.Rnpi_Fn%TYPE,
        p_Rnpi_Ln    IN     Rnp_Identity_Info.Rnpi_Ln%TYPE,
        p_Rnpi_Mn    IN     Rnp_Identity_Info.Rnpi_Mn%TYPE,
        p_New_Id        OUT Rnp_Identity_Info.Rnpi_Id%TYPE);

    PROCEDURE Save_Rn_Common_Info (
        p_Rnc_Rn           IN Rn_Common_Info.Rnc_Rn%TYPE,
        p_Rnc_Pt           IN Rn_Common_Info.Rnc_Pt%TYPE,
        p_Rnc_Val_Int      IN Rn_Common_Info.Rnc_Val_Int%TYPE DEFAULT NULL,
        p_Rnc_Val_Sum      IN Rn_Common_Info.Rnc_Val_Sum%TYPE DEFAULT NULL,
        p_Rnc_Val_Id       IN Rn_Common_Info.Rnc_Val_Id%TYPE DEFAULT NULL,
        p_Rnc_Val_Dt       IN Rn_Common_Info.Rnc_Val_Dt%TYPE DEFAULT NULL,
        p_Rnc_Val_String   IN Rn_Common_Info.Rnc_Val_String%TYPE DEFAULT NULL);

    FUNCTION Get_Rn_Common_Info_String (
        p_Rnc_Rn   IN Rn_Common_Info.Rnc_Rn%TYPE,
        p_Rnc_Pt   IN Rn_Common_Info.Rnc_Pt%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Rn_Common_Info_Dt (p_Rnc_Rn   IN Rn_Common_Info.Rnc_Rn%TYPE,
                                    p_Rnc_Pt   IN Rn_Common_Info.Rnc_Pt%TYPE)
        RETURN DATE;

    FUNCTION Get_Rn_Common_Info_Int (
        p_Rnc_Rn   IN Rn_Common_Info.Rnc_Rn%TYPE,
        p_Rnc_Pt   IN Rn_Common_Info.Rnc_Pt%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Rn_Common_Info_Id (p_Rnc_Rn   IN Rn_Common_Info.Rnc_Rn%TYPE,
                                    p_Rnc_Pt   IN Rn_Common_Info.Rnc_Pt%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Rn_St (p_Rn_Id IN Request_Journal.Rn_Id%TYPE)
        RETURN Request_Journal.Rn_St%TYPE;

    FUNCTION Get_Rn_Sc (p_Rn_Id IN Request_Journal.Rn_Id%TYPE)
        RETURN Rn_Person.Rnp_Sc%TYPE;
END Api$request;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST
IS
    PROCEDURE Save_Request_Journal (
        p_Rn_Id          IN     Request_Journal.Rn_Id%TYPE DEFAULT NULL,
        p_Rn_Nrt         IN     Request_Journal.Rn_Nrt%TYPE DEFAULT NULL,
        p_Rn_Hs_Ins      IN     Request_Journal.Rn_Hs_Ins%TYPE DEFAULT NULL,
        p_Rn_Ins_Dt      IN     Request_Journal.Rn_Ins_Dt%TYPE DEFAULT NULL,
        p_Rn_Expect_Dt   IN     Request_Journal.Rn_Expect_Dt%TYPE DEFAULT NULL,
        p_Rn_Worked_Mc   IN     Request_Journal.Rn_Worked_Mc%TYPE DEFAULT NULL,
        p_Rn_St          IN     Request_Journal.Rn_St%TYPE DEFAULT NULL,
        p_Rn_Src         IN     Request_Journal.Rn_Src%TYPE DEFAULT NULL,
        p_Rn_Answer_Dt   IN     Request_Journal.Rn_Answer_Dt%TYPE DEFAULT NULL,
        p_Rn_Ask_Dt      IN     Request_Journal.Rn_Ask_Dt%TYPE DEFAULT NULL,
        p_New_Id            OUT Request_Journal.Rn_Id%TYPE)
    IS
    BEGIN
        IF p_Rn_Id IS NULL
        THEN
            INSERT INTO Request_Journal (Rn_Nrt,
                                         Rn_Hs_Ins,
                                         Rn_Ins_Dt,
                                         Rn_Expect_Dt,
                                         Rn_Worked_Mc,
                                         Rn_St,
                                         Rn_Src,
                                         Rn_Answer_Dt,
                                         Rn_Ask_Dt)
                 VALUES (p_Rn_Nrt,
                         p_Rn_Hs_Ins,
                         p_Rn_Ins_Dt,
                         p_Rn_Expect_Dt,
                         p_Rn_Worked_Mc,
                         p_Rn_St,
                         p_Rn_Src,
                         p_Rn_Answer_Dt,
                         p_Rn_Ask_Dt)
              RETURNING Rn_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Rn_Id;

            UPDATE Request_Journal
               SET Rn_Worked_Mc = p_Rn_Worked_Mc,
                   Rn_St = p_Rn_St,
                   Rn_Answer_Dt = p_Rn_Answer_Dt,
                   Rn_Ask_Dt = NVL (p_Rn_Ask_Dt, Rn_Ask_Dt)
             WHERE Rn_Id = p_Rn_Id;
        END IF;
    END;

    -- 29/04/2024 serhii: розширив для зрізу анкети Rn_Person.Rnp_Scc
    PROCEDURE Save_Rn_Person (
        p_Rnp_Id           IN     Rn_Person.Rnp_Id%TYPE,
        p_Rnp_Rn           IN     Rn_Person.Rnp_Rn%TYPE,
        p_Rnp_Sc           IN     Rn_Person.Rnp_Sc%TYPE,
        p_Rnp_Inn          IN     Rn_Person.Rnp_Inn%TYPE,
        p_Rnp_Ndt          IN     Rn_Person.Rnp_Ndt%TYPE,
        p_Rnp_Doc_Seria    IN     Rn_Person.Rnp_Doc_Seria%TYPE,
        p_Rnp_Doc_Number   IN     Rn_Person.Rnp_Doc_Number%TYPE,
        p_Rnp_Sc_Unique    IN     Rn_Person.Rnp_Sc_Unique%TYPE,
        p_Rnp_Scc          IN     Rn_Person.Rnp_Scc%TYPE DEFAULT NULL,
        p_New_Id              OUT Rn_Person.Rnp_Id%TYPE)
    IS
    BEGIN
        IF p_Rnp_Id IS NULL
        THEN
            INSERT INTO Rn_Person (Rnp_Rn,
                                   Rnp_Sc,
                                   Rnp_Inn,
                                   Rnp_Ndt,
                                   Rnp_Doc_Seria,
                                   Rnp_Doc_Number,
                                   Rnp_Sc_Unique,
                                   Rnp_Scc)
                 VALUES (p_Rnp_Rn,
                         p_Rnp_Sc,
                         p_Rnp_Inn,
                         p_Rnp_Ndt,
                         p_Rnp_Doc_Seria,
                         p_Rnp_Doc_Number,
                         p_Rnp_Sc_Unique,
                         p_Rnp_Scc)
              RETURNING Rnp_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Rnp_Id;

            UPDATE Rn_Person
               SET Rnp_Rn = p_Rnp_Rn,
                   Rnp_Sc = p_Rnp_Sc,
                   Rnp_Inn = p_Rnp_Inn,
                   Rnp_Ndt = p_Rnp_Ndt,
                   Rnp_Doc_Seria = p_Rnp_Doc_Seria,
                   Rnp_Doc_Number = p_Rnp_Doc_Number,
                   Rnp_Sc_Unique = p_Rnp_Sc_Unique,
                   Rnp_Scc = p_Rnp_Scc
             WHERE Rnp_Id = p_Rnp_Id;
        END IF;
    END;

    PROCEDURE Set_Rnp_Sc (p_Rnp_Rn   IN Rn_Person.Rnp_Rn%TYPE,
                          p_Rnp_Sc   IN Rn_Person.Rnp_Sc%TYPE)
    IS
    BEGIN
        UPDATE Rn_Person
           SET Rnp_Sc = p_Rnp_Sc
         WHERE Rnp_Rn = p_Rnp_Rn;
    END;

    PROCEDURE Save_Rnp_Identity_Info (
        p_Rnpi_Id    IN     Rnp_Identity_Info.Rnpi_Id%TYPE,
        p_Rnpi_Rnp   IN     Rnp_Identity_Info.Rnpi_Rnp%TYPE,
        p_Rnpi_Rn    IN     Rnp_Identity_Info.Rnpi_Rn%TYPE,
        p_Rnpi_Fn    IN     Rnp_Identity_Info.Rnpi_Fn%TYPE,
        p_Rnpi_Ln    IN     Rnp_Identity_Info.Rnpi_Ln%TYPE,
        p_Rnpi_Mn    IN     Rnp_Identity_Info.Rnpi_Mn%TYPE,
        p_New_Id        OUT Rnp_Identity_Info.Rnpi_Id%TYPE)
    IS
    BEGIN
        IF p_Rnpi_Id IS NULL
        THEN
            INSERT INTO Rnp_Identity_Info (Rnpi_Rnp,
                                           Rnpi_Rn,
                                           Rnpi_Fn,
                                           Rnpi_Ln,
                                           Rnpi_Mn)
                 VALUES (p_Rnpi_Rnp,
                         p_Rnpi_Rn,
                         p_Rnpi_Fn,
                         p_Rnpi_Ln,
                         p_Rnpi_Mn)
              RETURNING Rnpi_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Rnpi_Id;

            UPDATE Rnp_Identity_Info
               SET Rnpi_Rnp = p_Rnpi_Rnp,
                   Rnpi_Rn = p_Rnpi_Rn,
                   Rnpi_Fn = p_Rnpi_Fn,
                   Rnpi_Ln = p_Rnpi_Ln,
                   Rnpi_Mn = p_Rnpi_Mn
             WHERE Rnpi_Id = p_Rnpi_Id;
        END IF;
    END;

    PROCEDURE Save_Rn_Common_Info (
        p_Rnc_Rn           IN Rn_Common_Info.Rnc_Rn%TYPE,
        p_Rnc_Pt           IN Rn_Common_Info.Rnc_Pt%TYPE,
        p_Rnc_Val_Int      IN Rn_Common_Info.Rnc_Val_Int%TYPE DEFAULT NULL,
        p_Rnc_Val_Sum      IN Rn_Common_Info.Rnc_Val_Sum%TYPE DEFAULT NULL,
        p_Rnc_Val_Id       IN Rn_Common_Info.Rnc_Val_Id%TYPE DEFAULT NULL,
        p_Rnc_Val_Dt       IN Rn_Common_Info.Rnc_Val_Dt%TYPE DEFAULT NULL,
        p_Rnc_Val_String   IN Rn_Common_Info.Rnc_Val_String%TYPE DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO Rn_Common_Info (Rnc_Rn,
                                    Rnc_Pt,
                                    Rnc_Val_Int,
                                    Rnc_Val_Sum,
                                    Rnc_Val_Id,
                                    Rnc_Val_Dt,
                                    Rnc_Val_String)
             VALUES (p_Rnc_Rn,
                     p_Rnc_Pt,
                     p_Rnc_Val_Int,
                     p_Rnc_Val_Sum,
                     p_Rnc_Val_Id,
                     p_Rnc_Val_Dt,
                     p_Rnc_Val_String);
    END;

    FUNCTION Get_Rn_Common_Info_String (
        p_Rnc_Rn   IN Rn_Common_Info.Rnc_Rn%TYPE,
        p_Rnc_Pt   IN Rn_Common_Info.Rnc_Pt%TYPE)
        RETURN VARCHAR2
    IS
        l_Result   Rn_Common_Info.Rnc_Val_String%TYPE;
    BEGIN
        SELECT MAX (i.Rnc_Val_String)
          INTO l_Result
          FROM Rn_Common_Info i
         WHERE i.Rnc_Rn = p_Rnc_Rn AND i.Rnc_Pt = p_Rnc_Pt;

        RETURN l_Result;
    END;

    FUNCTION Get_Rn_Common_Info_Dt (p_Rnc_Rn   IN Rn_Common_Info.Rnc_Rn%TYPE,
                                    p_Rnc_Pt   IN Rn_Common_Info.Rnc_Pt%TYPE)
        RETURN DATE
    IS
        l_Result   Rn_Common_Info.Rnc_Val_Dt%TYPE;
    BEGIN
        SELECT MAX (i.Rnc_Val_Dt)
          INTO l_Result
          FROM Rn_Common_Info i
         WHERE i.Rnc_Rn = p_Rnc_Rn AND i.Rnc_Pt = p_Rnc_Pt;

        RETURN l_Result;
    END;

    FUNCTION Get_Rn_Common_Info_Int (
        p_Rnc_Rn   IN Rn_Common_Info.Rnc_Rn%TYPE,
        p_Rnc_Pt   IN Rn_Common_Info.Rnc_Pt%TYPE)
        RETURN NUMBER
    IS
        l_Result   Rn_Common_Info.Rnc_Val_Int%TYPE;
    BEGIN
        SELECT MAX (i.Rnc_Val_Int)
          INTO l_Result
          FROM Rn_Common_Info i
         WHERE i.Rnc_Rn = p_Rnc_Rn AND i.Rnc_Pt = p_Rnc_Pt;

        RETURN l_Result;
    END;

    FUNCTION Get_Rn_Common_Info_Id (p_Rnc_Rn   IN Rn_Common_Info.Rnc_Rn%TYPE,
                                    p_Rnc_Pt   IN Rn_Common_Info.Rnc_Pt%TYPE)
        RETURN NUMBER
    IS
        l_Result   Rn_Common_Info.Rnc_Val_Int%TYPE;
    BEGIN
        SELECT MAX (i.Rnc_Val_Id)
          INTO l_Result
          FROM Rn_Common_Info i
         WHERE i.Rnc_Rn = p_Rnc_Rn AND i.Rnc_Pt = p_Rnc_Pt;

        RETURN l_Result;
    END;

    FUNCTION Get_Rn_St (p_Rn_Id IN Request_Journal.Rn_Id%TYPE)
        RETURN Request_Journal.Rn_St%TYPE
    IS
        l_Rn_St   VARCHAR2 (10);
    BEGIN
        SELECT j.Rn_St
          INTO l_Rn_St
          FROM Request_Journal j
         WHERE j.Rn_Id = p_Rn_Id;

        RETURN TRIM (l_Rn_St);
    END;

    FUNCTION Get_Rn_Sc (p_Rn_Id IN Request_Journal.Rn_Id%TYPE)
        RETURN Rn_Person.Rnp_Sc%TYPE
    IS
        l_Rnp_Sc   Rn_Person.Rnp_Sc%TYPE;
    BEGIN
        SELECT p.Rnp_Sc
          INTO l_Rnp_Sc
          FROM Rn_Person p
         WHERE p.Rnp_Rn = p_Rn_Id;

        RETURN l_Rnp_Sc;
    END;
END Api$request;
/