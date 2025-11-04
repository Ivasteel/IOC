/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_DSA
IS
    -- Author  : SHOSTAK
    -- Created : 13.07.2023 11:51:57 PM
    -- Purpose :

    Pkg                    VARCHAR2 (100) := 'Api$request_Dsa';
    c_Pt_Rnokpp   CONSTANT NUMBER := 218;

    TYPE r_Sharing_Response IS RECORD
    (
        doc_Type_Id      NUMBER,
        doc_Type_Name    VARCHAR2 (4000),
        court_Name       VARCHAR2 (4000),
        doc_Date         DATE,
        law_Date         DATE,
        case_Num         VARCHAR2 (100),
        reg_Num          VARCHAR2 (100),
        Doc_Id           NUMBER,
        Dh_Id            NUMBER,
        File_Code        VARCHAR2 (100)
    );

    TYPE t_Sharing_Response IS TABLE OF r_Sharing_Response;

    PROCEDURE Reg_Decision_Req (
        p_Rnokpp      IN     VARCHAR2,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Wu_Id       IN     NUMBER DEFAULT NULL);

    FUNCTION Get_Decision_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Get_Sharing_Response (p_Rn_Id      IN     NUMBER,
                                   p_Wu_Id      IN     NUMBER,
                                   p_Response      OUT t_Sharing_Response,
                                   p_Error         OUT VARCHAR2)
        RETURN BOOLEAN;
END Api$request_Dsa;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DSA TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DSA TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DSA TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DSA TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DSA TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DSA TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DSA TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_DSA
IS
    ----------------------------------------------------------------------
    --     Реєстрація запиту на отримання судового рішення
    ----------------------------------------------------------------------
    PROCEDURE Reg_Decision_Req (
        p_Rnokpp      IN     VARCHAR2,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Wu_Id       IN     NUMBER DEFAULT NULL)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => p_Wu_Id,
                                              p_Ur_Ext_Id      => NULL,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Rnokpp,
                                         p_Rnc_Val_String   => p_Rnokpp);
    END;

    ----------------------------------------------------------------------
    --     Отримання даних для запиту на отримання судового рішення
    ----------------------------------------------------------------------
    FUNCTION Get_Decision_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn     NUMBER;
        l_Rnokpp    VARCHAR2 (10);
        l_Request   XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Rnokpp :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Ur_Rn,
                                                   p_Rnc_Pt   => c_Pt_Rnokpp);

        SELECT XMLELEMENT ("mspRequest", --Xmlattributes('http://localhost/IssubService/Issub' AS "xmlns"),
                                         XMLELEMENT ("rnokpp", l_Rnokpp))
          INTO l_Request
          FROM DUAL;

        RETURN l_Request.Getclobval;
    END;

    FUNCTION Parse_Response (p_Xml IN CLOB)
        RETURN t_Sharing_Response
    IS
        l_Result   t_Sharing_Response;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Pkg,
                                         't_Sharing_Response',
                                         'yyyy-mm-dd')
            USING IN p_Xml, OUT l_Result;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    ---------------------------------------------------------------------------
    --     Отримання відповіді на шерінг
    ---------------------------------------------------------------------------
    FUNCTION Get_Sharing_Response (p_Rn_Id      IN     NUMBER,
                                   p_Wu_Id      IN     NUMBER,
                                   p_Response      OUT t_Sharing_Response,
                                   p_Error         OUT VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Ur_Out_Id     NUMBER;
        l_Ur_Out_St     Uxp_Request.Ur_St%TYPE;
        l_Ur_Out_Wu     NUMBER;
        l_Ur_In_Id      NUMBER;
        l_Ur_In_St      Uxp_Request.Ur_St%TYPE;
        l_Ur_Response   CLOB;
    --l_Encoded_Data  CLOB;
    --l_Decoded_Data  CLOB;
    BEGIN
        --Отримуємо стан вихідного запиту на шерінг
        SELECT r.Ur_Id,
               r.Ur_St,
               r.Ur_Create_Wu,
               r.Ur_Error
          INTO l_Ur_Out_Id,
               l_Ur_Out_St,
               l_Ur_Out_Wu,
               p_Error
          FROM Uxp_Request r
         WHERE r.Ur_Rn = p_Rn_Id;

        /*IF l_Ur_Out_Wu <> p_Wu_Id THEN
          Raise_Application_Error(-20000,
                                  'Отримати результат шерінгу може лише користувач, що надіслав запит');
        END IF;*/

        IF l_Ur_Out_St IN
               (Api$uxp_Request.c_Ur_St_New, Api$uxp_Request.c_Ur_St_Err)
        THEN
            RETURN FALSE;
        END IF;

        /*--Отримуємо ІД вхідного запиту
        SELECT MAX(l.Url_Ur)
          INTO l_Ur_In_Id
          FROM Uxp_Req_Links l
         WHERE l.Url_Root = l_Ur_Out_Id;*/
        /*
          IF l_Ur_In_Id IS NULL THEN
            RETURN FALSE;
          END IF;*/

        --Отримуємо стан та вміст вхідного запиту
        SELECT r.Ur_St, r.ur_soap_resp, r.Ur_Error
          INTO l_Ur_In_St, l_Ur_Response, p_Error
          FROM Uxp_Request r
         WHERE r.Ur_Rn = p_Rn_Id;

        IF l_Ur_In_St = Api$uxp_Request.c_Ur_St_Err
        THEN
            RETURN FALSE;
        END IF;

        p_Response := Parse_Response (l_Ur_Response);
        RETURN TRUE;
    END;
END Api$request_Dsa;
/