/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.Api$request_Msp
IS
    -- Author  : SHOSTAK
    -- Created : 02.09.2021 15:04:30
    -- Purpose : Запити до Міністерства соціальної політики

    Package_Name                CONSTANT VARCHAR2 (100) := 'API$REQUEST_MSP';

    c_Statement_Id              CONSTANT NUMBER := 188;
    c_Statement_St              CONSTANT NUMBER := 189;
    c_Statement_Dt              CONSTANT NUMBER := 190;
    c_Statement_File            CONSTANT NUMBER := 191;
    c_Statement_Sign            CONSTANT NUMBER := 192;
    c_Statement_Docs            CONSTANT NUMBER := 199;
    c_Statement_Pkg_Id          CONSTANT NUMBER := 318;

    c_Pt_Ssd_Code               CONSTANT NUMBER := 292;
    c_Pt_Start_Dt               CONSTANT NUMBER := 80;

    TYPE r_Vpo_Cert IS RECORD
    (
        Idp_Surname                  VARCHAR2 (200),
        Idp_Name                     VARCHAR2 (200),
        Idp_Patronymic               VARCHAR2 (200),
        Birth_Date                   DATE,
        Birth_Place                  VARCHAR2 (4000),
        Rnokpp                       VARCHAR2 (25),
        Gender                       VARCHAR2 (20),
        Document_Type                NUMBER,
        Document_Serie               VARCHAR2 (100),
        Document_Number              VARCHAR2 (100),
        Document_Date                VARCHAR2 (30),
        Document_Issuer              VARCHAR2 (4000),
        Reg_Address                  VARCHAR2 (4000),
        Fact_Address                 VARCHAR2 (4000),
        Certificate_Number           VARCHAR2 (20),
        Certificate_Date             DATE,
        Certificate_Issuer           VARCHAR2 (4000),
        Certificate_State            VARCHAR2 (100),
        CertificateCancelReasonId    VARCHAR2 (20),               -- #93848-29
        Guid                         VARCHAR2 (100),
        Date_End                     DATE,
        Catottg                      VARCHAR2 (50),
        UID                          VARCHAR2 (100),
        Address_Change               VARCHAR2 (100),
        -- 15/12/2023 serhii: додав за #93848:
        Fact_Address_StreetId        VARCHAR2 (50),
        Fact_Address_StreetName      VARCHAR2 (4000),
        Fact_Address_HouseNum        VARCHAR2 (20),
        Fact_Address_BuildNum        VARCHAR2 (20),
        Fact_Address_FlatNum         VARCHAR2 (20),
        Fact_Address_Atu             VARCHAR2 (50)
    );

    TYPE t_Vpo_Certs IS TABLE OF r_Vpo_Cert;

    TYPE r_Vpo_Info_Resp IS RECORD
    (
        Person         r_Vpo_Cert,
        Accompanied    t_Vpo_Certs,
        Error          CLOB
    );

    TYPE t_Vpo_Info_Resp IS TABLE OF r_Vpo_Info_Resp;

    TYPE r_Vpo_Delta_Resp IS RECORD
    (
        Delta_Date    DATE,
        Delta_Id      NUMBER,
        Delta_Body    t_Vpo_Info_Resp
    );

    TYPE t_Vpo_Delta_Resp IS TABLE OF r_Vpo_Delta_Resp;

    c_Statement_Resp_Code_Ok    CONSTANT NUMBER := 0;

    TYPE r_Statement_Response IS RECORD
    (
        Code_      VARCHAR2 (10),
        MESSAGE    CLOB
    );

    c_Adopt_Resp_Code_Ok        CONSTANT NUMBER := 1;
    c_Adopt_Resp_Code_Bad_Req   CONSTANT NUMBER := 102;

    TYPE r_Adopt_Resp IS RECORD
    (
        Result_Code         NUMBER,
        Result_Tech_Info    CLOB
    );

    PROCEDURE Reg_Save_Statement_Req (
        p_Rn_Nrt             IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins          IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src             IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id                 OUT Request_Journal.Rn_Id%TYPE,
        p_Statement_Id       IN     NUMBER,
        p_Statement_Pkg_Id   IN     NUMBER DEFAULT NULL,
        p_Statement_St       IN     NUMBER,
        p_Statement_Dt       IN     DATE,
        p_Statement_File     IN     VARCHAR2,
        p_Statement_Sign     IN     VARCHAR2,
        p_Statement          IN     CLOB DEFAULT NULL,
        p_Statement_Docs     IN     VARCHAR2);

    PROCEDURE Get_Save_Statement_Data (
        p_Ur_Id             IN     NUMBER,
        p_Statement            OUT SYS_REFCURSOR,
        p_Statement_Scans      OUT SYS_REFCURSOR);

    FUNCTION Parse_Save_Statement_Resp (p_Response CLOB)
        RETURN r_Statement_Response;

    PROCEDURE Reg_Vpo_Info_Req (
        p_Rnokpp      IN     VARCHAR2,
        p_Sc_Id       IN     NUMBER,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Plan_Dt     IN     DATE DEFAULT SYSDATE);

    FUNCTION Get_Vpo_Info_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Vpo_Info_Resp (p_Response IN CLOB)
        RETURN r_Vpo_Info_Resp;

    PROCEDURE Reg_Vpo_Info_Batch_Req (
        p_Start_Dt    IN     DATE,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Vpo_Info_Batch_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Vpo_Info_Batch_Resp (p_Response IN CLOB)
        RETURN t_Vpo_Info_Resp;

    FUNCTION Parse_Vpo_Delta_Resp (p_Response IN CLOB)
        RETURN t_Vpo_Delta_Resp;

    PROCEDURE Reg_Save_Adopt_Req (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Ap_Id       IN     NUMBER,
        p_Ssd_Code    IN     VARCHAR2);

    FUNCTION Get_Ap_Ssd (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Parse_Adopt_Resp (p_Response IN CLOB)
        RETURN r_Adopt_Resp;
END Api$request_Msp;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO SHOST
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO TNIKONOVA
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MSP TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.Api$request_Msp
IS
    -----------------------------------------------------------------------------
    --    Реєстрація запиту на збереження звернення у системі "Соц. громада"
    -----------------------------------------------------------------------------
    PROCEDURE Reg_Save_Statement_Req (
        p_Rn_Nrt             IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins          IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src             IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id                 OUT Request_Journal.Rn_Id%TYPE,
        p_Statement_Id       IN     NUMBER,
        p_Statement_Pkg_Id   IN     NUMBER DEFAULT NULL,
        p_Statement_St       IN     NUMBER,
        p_Statement_Dt       IN     DATE,
        p_Statement_File     IN     VARCHAR2,
        p_Statement_Sign     IN     VARCHAR2,
        p_Statement          IN     CLOB DEFAULT NULL,
        p_Statement_Docs     IN     VARCHAR2      --Перечень срезов документов
                                            )
    IS
        l_Ur_Id       NUMBER;
        l_Parent_Ur   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => NULL,
            p_Ur_Create_Wu   => NULL,
            p_Ur_Ext_Id      => p_Statement_Id,
            p_Ur_Body        => p_Statement,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => p_Rn_Nrt,
            p_Rn_Src         => p_Rn_Src,
            p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
            p_New_Rn_Id      => p_Rn_Id);

        SELECT MAX (Ur_Id)
          INTO l_Parent_Ur
          FROM (  SELECT r.Ur_Id
                    FROM Uxp_Request Rr
                         JOIN Uxp_Request r
                             ON     r.Ur_Urt = Rr.Ur_Urt
                                AND r.Ur_Ext_Id = p_Statement_Id
                                AND r.Ur_St = Api$uxp_Request.c_Ur_St_New
                                AND r.Ur_Id <> Rr.Ur_Id
                   WHERE Rr.Ur_Id = l_Ur_Id
                ORDER BY r.Ur_Create_Dt DESC
                   FETCH FIRST ROW ONLY);

        IF l_Parent_Ur IS NOT NULL
        THEN
            Api$uxp_Request.Save_Request_Link (p_Url_Ur       => l_Ur_Id,
                                               p_Url_Root     => l_Parent_Ur,
                                               p_Url_Parent   => l_Parent_Ur);
        END IF;

        --Зберігаємо параметри запиту
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Statement_Id,
                                         p_Rnc_Val_String   => p_Statement_Id);
        Api$request.Save_Rn_Common_Info (
            p_Rnc_Rn           => p_Rn_Id,
            p_Rnc_Pt           => c_Statement_Pkg_Id,
            p_Rnc_Val_String   => p_Statement_Pkg_Id);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Statement_St,
                                         p_Rnc_Val_String   => p_Statement_St);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Statement_Dt,
                                         p_Rnc_Val_Dt   => p_Statement_Dt);
        Api$request.Save_Rn_Common_Info (
            p_Rnc_Rn           => p_Rn_Id,
            p_Rnc_Pt           => c_Statement_File,
            p_Rnc_Val_String   => p_Statement_File);

        IF p_Statement_Sign IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn           => p_Rn_Id,
                p_Rnc_Pt           => c_Statement_Sign,
                p_Rnc_Val_String   => p_Statement_Sign);
        END IF;

        Api$request.Save_Rn_Common_Info (
            p_Rnc_Rn           => p_Rn_Id,
            p_Rnc_Pt           => c_Statement_Docs,
            p_Rnc_Val_String   => p_Statement_Docs);
    END;

    -----------------------------------------------------------------------------
    --       Отримання даних для запиту
    --  на збереження звернення у системі "Соц. громада"
    -----------------------------------------------------------------------------
    PROCEDURE Get_Save_Statement_Data (
        p_Ur_Id             IN     NUMBER,
        p_Statement            OUT SYS_REFCURSOR,
        p_Statement_Scans      OUT SYS_REFCURSOR)
    IS
        l_Ur_Rn            NUMBER;
        l_Statement_Docs   VARCHAR2 (4000);
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        OPEN p_Statement FOR
            SELECT Api$request.Get_Rn_Common_Info_String (l_Ur_Rn,
                                                          c_Statement_Id)
                       AS Statement_Id,
                   Api$request.Get_Rn_Common_Info_String (l_Ur_Rn,
                                                          c_Statement_Pkg_Id)
                       AS Statement_Pkg_Id,
                   Api$request.Get_Rn_Common_Info_String (l_Ur_Rn,
                                                          c_Statement_St)
                       AS Statement_St,
                   Api$request.Get_Rn_Common_Info_Dt (l_Ur_Rn,
                                                      c_Statement_Dt)
                       AS Statement_Dt,
                   Api$request.Get_Rn_Common_Info_String (l_Ur_Rn,
                                                          c_Statement_File)
                       AS Statement_File_Code,
                   Api$request.Get_Rn_Common_Info_String (l_Ur_Rn,
                                                          c_Statement_Sign)
                       AS Statement_File_Sign_Code
              FROM DUAL;

        l_Statement_Docs :=
            Api$request.Get_Rn_Common_Info_String (l_Ur_Rn, c_Statement_Docs);

        OPEN p_Statement_Scans FOR
            SELECT f.File_Name,
                   NVL (TO_NUMBER (Uss_Ndi.Tools.Decode_Dict (
                                       p_Nddc_Tp   =>
                                           'NDT4AID',
                                       p_Nddc_Src   =>
                                           'VST',                  --Звернення
                                       p_Nddc_Dest   =>
                                           'COM',                 --Соцгромада
                                       p_Nddc_Code_Src   =>
                                           h.Dh_Ndt)),
                        1151)      AS Ref_Doc_Type,      --1151=Інший документ
                   f.File_Code     AS Doc_Code,
                   Fs.File_Code    AS Doc_Sign_Code
              FROM Uss_Doc.v_Doc_Hist  h
                   JOIN Uss_Doc.v_Doc_Attachments a ON h.Dh_Id = a.Dat_Dh
                   JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                   LEFT JOIN Uss_Doc.v_Files Fs
                       ON a.Dat_Sign_File = Fs.File_Id
             WHERE     l_Statement_Docs IS NOT NULL
                   AND h.Dh_Id IN
                           (SELECT TO_NUMBER (COLUMN_VALUE)
                              FROM XMLTABLE (l_Statement_Docs));
    END;

    -----------------------------------------------------------------------------
    --       Парсинг відповіді запиту
    --  на збереження звернення у системі "Соц. громада"
    -----------------------------------------------------------------------------
    FUNCTION Parse_Save_Statement_Resp (p_Response CLOB)
        RETURN r_Statement_Response
    IS
        l_Result   r_Statement_Response;
    BEGIN
            SELECT *
              INTO l_Result
              FROM XMLTABLE (
                       Xmlnamespaces (DEFAULT 'http://www.ioc.gov.ua/community'),
                       '/*/*'
                       PASSING Xmltype (p_Response)
                       COLUMNS Code_      VARCHAR2 (10) PATH 'code',
                               MESSAGE    VARCHAR2 (4000) PATH 'message');

        RETURN l_Result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN l_Result;
    END;

    -----------------------------------------------------------------------------
    --    Реєстрація запиту на отримання довідки ВПО
    -----------------------------------------------------------------------------
    PROCEDURE Reg_Vpo_Info_Req (
        p_Rnokpp      IN     VARCHAR2,
        p_Sc_Id       IN     NUMBER,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Plan_Dt     IN     DATE DEFAULT SYSDATE)
    IS
        l_Ur_Id    NUMBER;
        l_Rnp_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => p_Plan_Dt,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => NULL,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        --Зберігаємо інформацію про особу
        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => p_Sc_Id,
                                    p_Rnp_Inn          => p_Rnokpp,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);
    END;

    -----------------------------------------------------------------------------
    --       Отримання даних для запиту на отримання довідки ВПО
    -----------------------------------------------------------------------------
    FUNCTION Get_Vpo_Info_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn     NUMBER;
        l_Rnokpp    VARCHAR2 (10);
        l_Request   XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        SELECT p.Rnp_Inn
          INTO l_Rnokpp
          FROM Ikis_Rbm.Rn_Person p
         WHERE p.Rnp_Rn = l_Ur_Rn;

        SELECT XMLELEMENT (
                   "s:Envelope",
                   Xmlattributes (
                       'http://schemas.xmlsoap.org/soap/envelope/' AS "s",
                       'http://x-road.eu/xsd/xroad.xsd' AS "xro",
                       'http://ioc.gov.ua/IDPexchangeService' AS "idp"),
                   XMLELEMENT ("s:Header",
                               XMLELEMENT ("xro:id", 'IDP-DIIA-' || p_Ur_Id)),
                   XMLELEMENT (
                       "s:Body",
                       XMLELEMENT (
                           "idp:AppDataReq",
                           XMLELEMENT (
                               "idp:RequestStr",
                               Ikis_Rbm.Tools.B64_Encode (
                                      '{"method":"GET","url":"/idp/getCertificateByRNOKPP/'
                                   || l_Rnokpp
                                   || '","body":null}')))))    AS a
          INTO l_Request
          FROM DUAL;

        RETURN l_Request.Getclobval;
    END;

    -----------------------------------------------------------------------------
    --       Парсинг відповіді на запит на отримання довідки ВПО
    -----------------------------------------------------------------------------
    FUNCTION Parse_Vpo_Info_Resp (p_Response IN CLOB)
        RETURN r_Vpo_Info_Resp
    IS
        l_Json            CLOB;
        l_Vpo_Info_Resp   r_Vpo_Info_Resp;
    BEGIN
              SELECT Ikis_Rbm.Tools.B64_Decode (Resp_Json, 'UTF8'), Fault
                INTO l_Json, l_Vpo_Info_Resp.Error
                FROM XMLTABLE (
                         Xmlnamespaces (
                             'http://schemas.xmlsoap.org/soap/envelope/' AS "s",
                             'http://ioc.gov.ua/IDPexchangeService' AS "idp"),
                         '/*'
                         PASSING Xmltype (p_Response)
                         COLUMNS Resp_Json    CLOB PATH 's:Body/idp:AppDataRes/idp:ResponseStr',
                                 Fault        CLOB PATH 's:Body/s:Fault/faultstring');

        IF l_Vpo_Info_Resp.Error IS NOT NULL
        THEN
            RETURN l_Vpo_Info_Resp;
        END IF;

        IF l_Json IS NOT NULL AND DBMS_LOB.Getlength (l_Json) > 0
        THEN
            EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                              'R_VPO_INFO_RESP',
                                              'dd.mm.yyyy hh24:mi:ss.ff')
                USING IN l_Json, OUT l_Vpo_Info_Resp;
        END IF;

        RETURN l_Vpo_Info_Resp;
    END;

    -----------------------------------------------------------------------------
    --    Реєстрація запиту на масове отримання довідок ВПО
    -----------------------------------------------------------------------------
    PROCEDURE Reg_Vpo_Info_Batch_Req (
        p_Start_Dt    IN     DATE,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => p_Plan_Dt,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => NULL,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Start_Dt,
                                         p_Rnc_Val_Dt   => p_Start_Dt);
    END;

    -----------------------------------------------------------------------------
    --    Отримання даних для запиту на масове отримання довідок ВПО
    -----------------------------------------------------------------------------
    FUNCTION Get_Vpo_Info_Batch_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn      NUMBER;
        l_Start_Dt   DATE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Start_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Start_Dt);
        RETURN 'startDate=' || TO_CHAR (l_Start_Dt, 'yyyy-mm-dd');
    END;

    -----------------------------------------------------------------------------
    --       Парсинг відповіді на запит на отримання довідки ВПО(obsolete)
    -----------------------------------------------------------------------------
    FUNCTION Parse_Vpo_Info_Batch_Resp (p_Response IN CLOB)
        RETURN t_Vpo_Info_Resp
    IS
        l_Vpo_Info_Resp   t_Vpo_Info_Resp;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                              'T_VPO_INFO_RESP',
                                              'dd.mm.yyyy hh24:mi:ss.ff')
                USING IN p_Response, OUT l_Vpo_Info_Resp;
        END IF;

        RETURN l_Vpo_Info_Resp;
    END;

    FUNCTION Parse_Vpo_Delta_Resp (p_Response IN CLOB)
        RETURN t_Vpo_Delta_Resp
    IS
        l_Vpo_Delta_Resp   t_Vpo_Delta_Resp;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                              't_Vpo_Delta_Resp',
                                              'dd.mm.yyyy hh24:mi:ss.ff')
                USING IN p_Response, OUT l_Vpo_Delta_Resp;
        END IF;

        RETURN l_Vpo_Delta_Resp;
    END;

    -----------------------------------------------------------------------------
    --     Реєстрація запиту на збереження звернення в системі ЄІАС "Діти"
    -----------------------------------------------------------------------------
    PROCEDURE Reg_Save_Adopt_Req (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Ap_Id       IN     NUMBER,
        p_Ssd_Code    IN     VARCHAR2)
    IS
        c_Urt_Id   CONSTANT NUMBER := 49;
        l_Ur_Id             NUMBER;
        l_Parent_Ur         NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => c_Urt_Id,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Ap_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        SELECT MAX (Ur_Id)
          INTO l_Parent_Ur
          FROM (  SELECT r.Ur_Id
                    FROM Uxp_Request r
                   WHERE     r.Ur_Urt = c_Urt_Id
                         AND r.Ur_Ext_Id = p_Ap_Id
                         AND r.Ur_St = Api$uxp_Request.c_Ur_St_New
                         AND r.Ur_Id <> l_Ur_Id
                ORDER BY r.Ur_Create_Dt DESC
                   FETCH FIRST ROW ONLY);

        IF l_Parent_Ur IS NOT NULL
        THEN
            Api$uxp_Request.Save_Request_Link (p_Url_Ur       => l_Ur_Id,
                                               p_Url_Root     => l_Parent_Ur,
                                               p_Url_Parent   => l_Parent_Ur);
        END IF;

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Ssd_Code,
                                         p_Rnc_Val_String   => p_Ssd_Code);
    END;

    FUNCTION Get_Ap_Ssd (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        c_Urt_Id   CONSTANT NUMBER := 49;
        l_Rn_Id             NUMBER;
    BEGIN
          SELECT r.Ur_Rn
            INTO l_Rn_Id
            FROM Uxp_Request r
           WHERE r.Ur_Urt = c_Urt_Id AND r.Ur_Ext_Id = p_Ap_Id
        ORDER BY r.Ur_Create_Dt DESC
           FETCH FIRST ROW ONLY;

        RETURN Api$request.Get_Rn_Common_Info_String (l_Rn_Id, c_Pt_Ssd_Code);
    END;

    FUNCTION Parse_Adopt_Resp (p_Response IN CLOB)
        RETURN r_Adopt_Resp
    IS
        l_Result   r_Adopt_Resp;
    BEGIN
                     SELECT *
                       INTO l_Result
                       FROM XMLTABLE (
                                Xmlnamespaces (
                                    'http://schemas.datacontract.org/2004/07/ApplicationsProxy.Wcf.AdoptService'
                                        AS "a"),
                                '/*/*'
                                PASSING Xmltype (p_Response)
                                COLUMNS Result_Code         VARCHAR2 (10) PATH 'a:ResultCode',
                                        Result_Tech_Info    VARCHAR2 (4000) PATH 'a:ResultTechInfo');

        RETURN l_Result;
    END;
END Api$request_Msp;
/