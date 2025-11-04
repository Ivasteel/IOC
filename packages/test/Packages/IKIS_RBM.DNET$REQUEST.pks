/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$REQUEST
IS
    -- Author  : SHOSTAK
    -- Created : 02.08.2021 14:40:44
    -- Purpose :

    FUNCTION Handle_In_Request (p_Rn_Id IN NUMBER, p_Request IN CLOB)
        RETURN CLOB;

    FUNCTION Register_In_Request (
        p_Rn_Nrt_Code   IN VARCHAR2,
        p_Rn_St         IN Request_Journal.Rn_St%TYPE DEFAULT NULL,
        p_Rn_Src        IN Request_Journal.Rn_Src%TYPE DEFAULT NULL,
        p_Rn_Ask_Dt     IN Request_Journal.Rn_Ask_Dt%TYPE DEFAULT NULL)
        RETURN NUMBER;

    FUNCTION Save_Rn_Person (
        p_Rnp_Rn           IN Rn_Person.Rnp_Rn%TYPE,
        p_Rnp_Sc           IN Rn_Person.Rnp_Sc%TYPE,
        p_Rnp_Inn          IN Rn_Person.Rnp_Inn%TYPE,
        p_Rnp_Ndt          IN Rn_Person.Rnp_Ndt%TYPE,
        p_Rnp_Doc_Seria    IN Rn_Person.Rnp_Doc_Seria%TYPE,
        p_Rnp_Doc_Number   IN Rn_Person.Rnp_Doc_Number%TYPE,
        p_Rnp_Sc_Unique    IN Rn_Person.Rnp_Sc_Unique%TYPE)
        RETURN NUMBER;

    FUNCTION Save_Rnp_Identity_Info (
        p_Rnpi_Rnp   IN Rnp_Identity_Info.Rnpi_Rnp%TYPE,
        p_Rnpi_Rn    IN Rnp_Identity_Info.Rnpi_Rn%TYPE,
        p_Rnpi_Fn    IN Rnp_Identity_Info.Rnpi_Fn%TYPE,
        p_Rnpi_Ln    IN Rnp_Identity_Info.Rnpi_Ln%TYPE,
        p_Rnpi_Mn    IN Rnp_Identity_Info.Rnpi_Mn%TYPE)
        RETURN NUMBER;
END Dnet$request;
/


GRANT EXECUTE ON IKIS_RBM.DNET$REQUEST TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.DNET$REQUEST TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:10:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$REQUEST
IS
    -----------------------------------------------------------------
    --        "Універсальний" обробник вхідних запитів
    -----------------------------------------------------------------
    FUNCTION Handle_In_Request (p_Rn_Id IN NUMBER, p_Request IN CLOB)
        RETURN CLOB
    IS
        l_Nrt_Work_Func   Uss_Ndi.v_Ndi_Request_Type.Nrt_Work_Func%TYPE;
        l_Response        CLOB;
    BEGIN
        SELECT t.Nrt_Work_Func
          INTO l_Nrt_Work_Func
          FROM Request_Journal  j
               JOIN Uss_Ndi.v_Ndi_Request_Type t ON j.Rn_Nrt = t.Nrt_Id
         WHERE j.Rn_Id = p_Rn_Id;

        EXECUTE IMMEDIATE   'begin :p_response :='
                         || l_Nrt_Work_Func
                         || '(p_rn_id=>:p_rn_id, p_request=>:p_Request); end;'
            USING OUT l_Response, IN p_Rn_Id, IN p_Request;

        RETURN l_Response;
    END;

    -----------------------------------------------------------------
    --        Реєстрація вхідного запиту
    -----------------------------------------------------------------
    FUNCTION Register_In_Request (
        p_Rn_Nrt_Code   IN VARCHAR2,
        p_Rn_St         IN Request_Journal.Rn_St%TYPE DEFAULT NULL,
        p_Rn_Src        IN Request_Journal.Rn_Src%TYPE DEFAULT NULL,
        p_Rn_Ask_Dt     IN Request_Journal.Rn_Ask_Dt%TYPE DEFAULT NULL)
        RETURN NUMBER
    IS
        l_Rn_Nrt   Request_Journal.Rn_Nrt%TYPE;
        l_Rn_Id    Request_Journal.Rn_Id%TYPE;
    BEGIN
        SELECT t.Nrt_Id
          INTO l_Rn_Nrt
          FROM Uss_Ndi.v_Ndi_Request_Type t
         WHERE t.Nrt_Code = p_Rn_Nrt_Code;

        Api$request.Save_Request_Journal (p_Rn_Id          => NULL,
                                          p_Rn_Nrt         => l_Rn_Nrt,
                                          p_Rn_Hs_Ins      => NULL,
                                          p_Rn_Ins_Dt      => SYSDATE,
                                          p_Rn_Expect_Dt   => NULL,
                                          p_Rn_Worked_Mc   => NULL,
                                          p_Rn_St          => p_Rn_St,
                                          p_Rn_Src         => p_Rn_Src,
                                          p_Rn_Answer_Dt   => NULL,
                                          p_Rn_Ask_Dt      => p_Rn_Ask_Dt,
                                          p_New_Id         => l_Rn_Id);

        RETURN l_Rn_Id;
    END;

    -----------------------------------------------------------------
    --        Збереження особи в запиті
    -----------------------------------------------------------------
    FUNCTION Save_Rn_Person (
        p_Rnp_Rn           IN Rn_Person.Rnp_Rn%TYPE,
        p_Rnp_Sc           IN Rn_Person.Rnp_Sc%TYPE,
        p_Rnp_Inn          IN Rn_Person.Rnp_Inn%TYPE,
        p_Rnp_Ndt          IN Rn_Person.Rnp_Ndt%TYPE,
        p_Rnp_Doc_Seria    IN Rn_Person.Rnp_Doc_Seria%TYPE,
        p_Rnp_Doc_Number   IN Rn_Person.Rnp_Doc_Number%TYPE,
        p_Rnp_Sc_Unique    IN Rn_Person.Rnp_Sc_Unique%TYPE)
        RETURN NUMBER
    IS
        l_Rnp_Id   Rn_Person.Rnp_Id%TYPE;
    BEGIN
        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rnp_Rn,
                                    p_Rnp_Sc           => p_Rnp_Sc,
                                    p_Rnp_Inn          => p_Rnp_Inn,
                                    p_Rnp_Ndt          => p_Rnp_Ndt,
                                    p_Rnp_Doc_Seria    => p_Rnp_Doc_Seria,
                                    p_Rnp_Doc_Number   => p_Rnp_Doc_Number,
                                    p_Rnp_Sc_Unique    => p_Rnp_Sc_Unique,
                                    p_New_Id           => l_Rnp_Id);

        RETURN l_Rnp_Id;
    END;

    -----------------------------------------------------------------
    --      Збереження додаткової інформації про особу в запиті
    -----------------------------------------------------------------
    FUNCTION Save_Rnp_Identity_Info (
        p_Rnpi_Rnp   IN Rnp_Identity_Info.Rnpi_Rnp%TYPE,
        p_Rnpi_Rn    IN Rnp_Identity_Info.Rnpi_Rn%TYPE,
        p_Rnpi_Fn    IN Rnp_Identity_Info.Rnpi_Fn%TYPE,
        p_Rnpi_Ln    IN Rnp_Identity_Info.Rnpi_Ln%TYPE,
        p_Rnpi_Mn    IN Rnp_Identity_Info.Rnpi_Mn%TYPE)
        RETURN NUMBER
    IS
        l_Rnpi_Id   Rnp_Identity_Info.Rnpi_Id%TYPE;
    BEGIN
        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => p_Rnpi_Rnp,
                                            p_Rnpi_Rn    => p_Rnpi_Rn,
                                            p_Rnpi_Fn    => p_Rnpi_Fn,
                                            p_Rnpi_Ln    => p_Rnpi_Ln,
                                            p_Rnpi_Mn    => p_Rnpi_Mn,
                                            p_New_Id     => l_Rnpi_Id);

        RETURN l_Rnpi_Id;
    END;
END Dnet$request;
/