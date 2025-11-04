/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_PFU
IS
    -- Author  : SHOSTAK
    -- Created : 27.07.2021 17:38:32
    -- Purpose :

    c_Pt_Birth_Dt         CONSTANT NUMBER := 87;

    c_Pt_Period_Begin     CONSTANT NUMBER := 167;
    c_Pt_Period_End       CONSTANT NUMBER := 168;

    c_Pt_Upszn_Case_Num   CONSTANT NUMBER := 181;
    c_Pt_Upszn_Cod        CONSTANT NUMBER := 182;
    c_Pt_Upszn_Ozn_Sub    CONSTANT NUMBER := 183;

    c_Pt_Visit_Tp         CONSTANT NUMBER := 135;
    c_Pt_Visit_Id         CONSTANT NUMBER := 172;

    c_Pt_Is_Reg_Person    CONSTANT NUMBER := 221;
    c_Pt_Gender           CONSTANT NUMBER := 220;

    -- serhii 25/04/2024 #100872
    c_Pt_Me_Id            CONSTANT NUMBER := 489;

    c_Pt_Scdi_Id          CONSTANT NUMBER := 509;

    TYPE r_Common_Response IS RECORD
    (
        Response_Body       CLOB,
        Result_Code         NUMBER,
        Result_Tech_Info    VARCHAR (4000)
    );

    PROCEDURE Reg_Upszn_Person_Data_Req (
        p_Sc_Id          IN     NUMBER,
        p_Rn_Nrt         IN     Request_Journal.Rn_Nrt%TYPE,
        p_Cod_Upszn             VARCHAR2,
        p_Case_Number           NUMBER,
        p_Num_Kss               VARCHAR2,
        p_Pn                    VARCHAR2,
        p_Ndt_Id                NUMBER,
        p_Doc_Ser               VARCHAR2,
        p_Doc_Nom               VARCHAR2,
        p_Ln                    VARCHAR2,
        p_Nm                    VARCHAR2,
        p_Ftn                   VARCHAR2,
        p_Birthday              DATE,
        p_Period_Start          DATE,
        p_Period_Stop           DATE,
        p_Ozn_Sub               NUMBER,
        p_Rn_Hs_Ins      IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src         IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id             OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Upszn_Person_Data_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Visit_Req (
        p_Rn_Nrt       IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins    IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE,
        p_Ur_Ext_Id    IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Sc_Id        IN     NUMBER,
        p_Visit_Tp     IN     VARCHAR2,
        p_Numident     IN     VARCHAR2,
        p_Ln           IN     VARCHAR2,
        p_Fn           IN     VARCHAR2,
        p_Mn           IN     VARCHAR2,
        p_Doc_Seria    IN     VARCHAR2,
        p_Doc_Number   IN     VARCHAR2);

    FUNCTION Get_Reg_Visit_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Visit_Result_Req (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Visit_Id    IN     NUMBER);

    FUNCTION Get_Visit_Result_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Get_Person_Unique_Req (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Is_Reg      IN     VARCHAR2,
        p_Numident    IN     VARCHAR2,
        p_Ln          IN     VARCHAR2,
        p_Fn          IN     VARCHAR2,
        p_Mn          IN     VARCHAR2,
        p_Doc_Tp      IN     NUMBER,
        p_Doc_Num     IN     VARCHAR2,
        p_Gender      IN     VARCHAR2,
        p_Birthday    IN     VARCHAR2);

    FUNCTION Get_Person_Unique_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Common_Response (p_Response IN CLOB)
        RETURN r_Common_Response;

    -- serhii 25/04/2024 #100872
    PROCEDURE Reg_Put_Person_Vpo_Aid_Info_Req (
        p_Me_Id       IN     Rn_Common_Info.Rnc_Val_Int%TYPE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE);

    -- serhii 25/04/2024 #100872
    FUNCTION Put_Person_Vpo_Aid_Info_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Run_Get_Avg_Month_Income (
        p_Body           IN OUT NOCOPY CLOB,
        p_Period_Start                 DATE,
        p_Period_Stop                  DATE,
        p_Rn_Id             OUT        Request_Journal.Rn_Id%TYPE);

    PROCEDURE Reg_Me_Incomes_Req (
        p_Me_Id        IN     Rn_Common_Info.Rnc_Val_Int%TYPE,
        p_Ur_Plan_Dt   IN     Uxp_Request.Ur_Plan_Dt%TYPE,
        p_Ur_Ext_Id    IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Me_Incomes_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Put_Moz_Data_Req (
        p_Scdi_Id     IN     NUMBER,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Put_Moz_Data_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;
END Api$request_Pfu;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_PFU TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_PFU TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_PFU TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_PFU TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_PFU TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_PFU TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_PFU TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_PFU TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_PFU
IS
    -------------------------------------------------------------------------
    --                   Реєстрація запиту від УПСЗН до ПФУ
    --                  для отримання інформації про доходи
    -------------------------------------------------------------------------
    PROCEDURE Reg_Upszn_Person_Data_Req (
        p_Sc_Id          IN     NUMBER,
        p_Rn_Nrt         IN     Request_Journal.Rn_Nrt%TYPE,
        p_Cod_Upszn             VARCHAR2,
        p_Case_Number           NUMBER,
        p_Num_Kss               VARCHAR2,
        p_Pn                    VARCHAR2,
        p_Ndt_Id                NUMBER,   --Тип документа из ndi_document_type
        p_Doc_Ser               VARCHAR2,
        p_Doc_Nom               VARCHAR2,
        p_Ln                    VARCHAR2,
        p_Nm                    VARCHAR2,
        p_Ftn                   VARCHAR2,
        p_Birthday              DATE,
        p_Period_Start          DATE,
        p_Period_Stop           DATE,
        p_Ozn_Sub               NUMBER,
        p_Rn_Hs_Ins      IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src         IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id             OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
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
                                    p_Rnp_Inn          => p_Pn,
                                    p_Rnp_Ndt          => p_Ndt_Id,
                                    p_Rnp_Doc_Seria    => p_Doc_Ser,
                                    p_Rnp_Doc_Number   => p_Doc_Nom,
                                    p_Rnp_Sc_Unique    => p_Num_Kss,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_Nm,
                                            p_Rnpi_Ln    => p_Ln,
                                            p_Rnpi_Mn    => p_Ftn,
                                            p_New_Id     => l_Rnpi_Id);

        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Birthday);
        --Зберігаємо період за який запитуємо дані
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Period_Begin,
                                         p_Rnc_Val_Dt   => p_Period_Start);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Period_End,
                                         p_Rnc_Val_Dt   => p_Period_Stop);
        --Зберігаємо інщі дані
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Upszn_Case_Num,
                                         p_Rnc_Val_String   => p_Case_Number);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Upszn_Cod,
                                         p_Rnc_Val_String   => p_Cod_Upszn);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Upszn_Ozn_Sub,
                                         p_Rnc_Val_String   => p_Ozn_Sub);
    END;

    -------------------------------------------------------------------------
    --           Отримання даних для відправки запиту від УПСЗН до ПФУ
    --                  для отримання інформації про доходи
    -------------------------------------------------------------------------
    FUNCTION Get_Upszn_Person_Data_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn              NUMBER;
        l_Cod_Upszn          VARCHAR2 (17);
        l_Birthday           DATE;
        l_Case_Number        VARCHAR2 (10);
        l_Period_Start       DATE;
        l_Period_Stop        DATE;
        l_Ozn_Sub            NUMBER;
        l_Request_Body       XMLTYPE;
        l_Request_Body_B64   CLOB;
        l_Request_Payload    XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        l_Cod_Upszn :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Upszn_Cod);
        l_Birthday :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Birth_Dt);
        l_Case_Number :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Upszn_Case_Num);
        l_Period_Start :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Period_Begin);
        l_Period_Stop :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Period_End);
        l_Ozn_Sub :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Upszn_Ozn_Sub);

        SELECT XMLELEMENT (
                   "UPSZN_ISSUES",
                   XMLELEMENT ("EXTERNAL_ID", l_Ur_Rn),
                   XMLELEMENT ("COD_UPSZN", l_Cod_Upszn),
                   XMLELEMENT ("DATE_UPSZN",
                               TO_CHAR (j.Rn_Ins_Dt, 'DDMMYYYYHH24MISS')),
                   (SELECT XMLELEMENT (
                               "PERSONS",
                               XMLAGG (
                                   XMLELEMENT (
                                       "PERSON",
                                       XMLELEMENT ("ID_ISSUE", ROWNUM),
                                       XMLELEMENT ("CASE_NUMBER",
                                                   l_Case_Number),
                                       XMLELEMENT ("NUM_KSS",
                                                   p.Rnp_Sc_Unique),
                                       XMLELEMENT ("PN", p.Rnp_Inn),
                                       XMLELEMENT (
                                           "DOC_TYPE",
                                           DECODE (p.Rnp_Ndt,
                                                   6, 1,
                                                   7, 2,
                                                   165, 3)),
                                       XMLELEMENT ("DOC_SER",
                                                   p.Rnp_Doc_Seria),
                                       XMLELEMENT ("DOC_NOM",
                                                   p.Rnp_Doc_Number),
                                       XMLELEMENT ("LN", i.Rnpi_Ln),
                                       XMLELEMENT ("NM", i.Rnpi_Fn),
                                       XMLELEMENT ("FTN", i.Rnpi_Mn),
                                       XMLELEMENT (
                                           "BIRTHDAY",
                                           TO_CHAR (l_Birthday, 'DDMMYYYY')),
                                       XMLELEMENT (
                                           "PERIOD_START",
                                           TO_CHAR (l_Period_Start,
                                                    'DDMMYYYY')),
                                       XMLELEMENT (
                                           "PERIOD_STOP",
                                           TO_CHAR (l_Period_Stop,
                                                    'DDMMYYYY')),
                                       XMLELEMENT ("OZN_SUB", l_Ozn_Sub))))
                      FROM Rn_Person  p
                           JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
                     WHERE p.Rnp_Rn = j.Rn_Id))
          INTO l_Request_Body
          FROM Request_Journal j
         WHERE j.Rn_Id = l_Ur_Rn;

        --l_Request_Body_B64 := Tools.B64_Encode(l_Request_Body.Getclobval, 'UTF8');
        l_Request_Body_B64 :=
            Tools.encode_base64 (
                Tools.ConvertC2BUTF8 (l_Request_Body.Getclobval));

        SELECT XMLELEMENT ("CommonRequest",
                           XMLELEMENT ("Body", l_Request_Body_B64))
          INTO l_Request_Payload
          FROM DUAL;

        RETURN l_Request_Payload.Getclobval;
    END;

    -------------------------------------------------------------------------------
    --               Реєстрація запиту на реєстрацію звернення
    -------------------------------------------------------------------------------
    PROCEDURE Reg_Visit_Req (
        p_Rn_Nrt       IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins    IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE,
        p_Ur_Ext_Id    IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Sc_Id        IN     NUMBER,
        p_Visit_Tp     IN     VARCHAR2,
        p_Numident     IN     VARCHAR2,
        p_Ln           IN     VARCHAR2,
        p_Fn           IN     VARCHAR2,
        p_Mn           IN     VARCHAR2,
        p_Doc_Seria    IN     VARCHAR2,
        p_Doc_Number   IN     VARCHAR2)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Ur_Ext_Id,
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
                                    p_Rnp_Inn          => p_Numident,
                                    p_Rnp_Ndt          => 6,         --паспорт
                                    p_Rnp_Doc_Seria    => p_Doc_Seria,
                                    p_Rnp_Doc_Number   => p_Doc_Number,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_Fn,
                                            p_Rnpi_Ln    => p_Ln,
                                            p_Rnpi_Mn    => p_Mn,
                                            p_New_Id     => l_Rnpi_Id);
        --Зберігаємо тип звернення
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Visit_Tp,
                                         p_Rnc_Val_String   => p_Visit_Tp);
    END;

    -------------------------------------------------------------------------------
    --         Отримання даних для запиту на реєстрацію звернення
    -------------------------------------------------------------------------------
    FUNCTION Get_Reg_Visit_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn              NUMBER;
        l_Request_Body       XMLTYPE;
        l_Request_Body_B64   CLOB;
        l_Request_Payload    XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        SELECT XMLELEMENT (
                   "RegisterVisitRequest",
                   XMLELEMENT (
                       "Visit_Tp",
                       Api$request.Get_Rn_Common_Info_String (l_Ur_Rn,
                                                              c_Pt_Visit_Tp)),
                   XMLELEMENT ("Numident", p.Rnp_Inn),
                   XMLELEMENT ("Doc_Num",
                               p.Rnp_Doc_Seria || p.Rnp_Doc_Number),
                   XMLELEMENT ("Ln", i.Rnpi_Ln),
                   XMLELEMENT ("Fn", i.Rnpi_Fn),
                   XMLELEMENT ("Mn", i.Rnpi_Mn))
          INTO l_Request_Body
          FROM Request_Journal  j
               JOIN Rn_Person p ON j.Rn_Id = p.Rnp_Rn
               JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE j.Rn_Id = l_Ur_Rn;

        l_Request_Body_B64 :=
            Tools.B64_Encode (l_Request_Body.Getclobval, 'UTF8');

        SELECT XMLELEMENT ("CommonRequest",
                           XMLELEMENT ("Body", l_Request_Body_B64))
          INTO l_Request_Payload
          FROM DUAL;

        RETURN l_Request_Payload.Getclobval;
    END;

    -------------------------------------------------------------------------------
    --       Реєстрація запиту на отримання результату виконання звернення
    -------------------------------------------------------------------------------
    PROCEDURE Reg_Visit_Result_Req (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Visit_Id    IN     NUMBER)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Ur_Ext_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        --Зберігаємо ІД звернення
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Visit_Id,
                                         p_Rnc_Val_String   => p_Visit_Id);
    END;

    -------------------------------------------------------------------------------
    --  Отримання даних для запиту на отримання результату виконання звернення
    -------------------------------------------------------------------------------
    FUNCTION Get_Visit_Result_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn              NUMBER;
        l_Request_Body       XMLTYPE;
        l_Request_Body_B64   CLOB;
        l_Request_Payload    XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        SELECT XMLELEMENT (
                   "GetVisitResultRequest",
                   XMLELEMENT (
                       "Visit_Id",
                       Api$request.Get_Rn_Common_Info_String (l_Ur_Rn,
                                                              c_Pt_Visit_Id)))
          INTO l_Request_Body
          FROM DUAL;

        l_Request_Body_B64 :=
            Tools.B64_Encode (l_Request_Body.Getclobval, 'UTF8');

        SELECT XMLELEMENT ("CommonRequest",
                           XMLELEMENT ("Body", l_Request_Body_B64))
          INTO l_Request_Payload
          FROM DUAL;

        RETURN l_Request_Payload.Getclobval;
    END;

    -------------------------------------------------------------------------------
    --   Реєстрація запиту на пошук/реєстрацію особи в РЗО
    -------------------------------------------------------------------------------
    PROCEDURE Reg_Get_Person_Unique_Req (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Is_Reg      IN     VARCHAR2,
        p_Numident    IN     VARCHAR2,
        p_Ln          IN     VARCHAR2,
        p_Fn          IN     VARCHAR2,
        p_Mn          IN     VARCHAR2,
        p_Doc_Tp      IN     NUMBER,
        p_Doc_Num     IN     VARCHAR2,
        p_Gender      IN     VARCHAR2,
        p_Birthday    IN     VARCHAR2)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Ur_Ext_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        --Зберігаємо інформацію про особу
        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => NULL,
                                    p_Rnp_Inn          => p_Numident,
                                    p_Rnp_Ndt          => p_Doc_Tp,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => p_Doc_Num,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_Fn,
                                            p_Rnpi_Ln    => p_Ln,
                                            p_Rnpi_Mn    => p_Mn,
                                            p_New_Id     => l_Rnpi_Id);

        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Birthday);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Is_Reg_Person,
                                         p_Rnc_Val_String   => p_Is_Reg);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Gender,
                                         p_Rnc_Val_String   => p_Gender);
    END;

    -------------------------------------------------------------------------------
    --  Отримання даних для запиту на пошук/реєстрацію особи в РЗО
    -------------------------------------------------------------------------------
    FUNCTION Get_Person_Unique_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn              NUMBER;
        l_Request_Body       XMLTYPE;
        l_Request_Body_B64   CLOB;
        l_Request_Payload    XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        SELECT XMLELEMENT (
                   "GetPersonUniqueRequest",
                   XMLELEMENT (
                       "Is_Reg",
                       Api$request.Get_Rn_Common_Info_String (
                           l_Ur_Rn,
                           c_Pt_Is_Reg_Person)),
                   XMLELEMENT ("Numident", p.Rnp_Inn),
                   XMLELEMENT ("Doc_Tp",
                               Uss_Ndi.Tools.Decode_Dict (
                                   p_Nddc_Tp         => 'NDT_ID',
                                   p_Nddc_Src        => 'VST',
                                   p_Nddc_Dest       => 'RZO',
                                   p_Nddc_Code_Src   => p.Rnp_Ndt)),
                   XMLELEMENT ("Doc_Num",
                               p.Rnp_Doc_Seria || p.Rnp_Doc_Number),
                   XMLELEMENT ("Ln", i.Rnpi_Ln),
                   XMLELEMENT ("Fn", i.Rnpi_Fn),
                   XMLELEMENT ("Mn", i.Rnpi_Mn),
                   XMLELEMENT (
                       "Birthday",
                       TO_CHAR (
                           Api$request.Get_Rn_Common_Info_Dt (l_Ur_Rn,
                                                              c_Pt_Birth_Dt),
                           'dd.mm.yyyy')),
                   XMLELEMENT ("Sex",
                               Uss_Ndi.Tools.Decode_Dict (
                                   p_Nddc_Tp     => 'GENDER',
                                   p_Nddc_Src    => 'VST',
                                   p_Nddc_Dest   => 'RZO',
                                   p_Nddc_Code_Src   =>
                                       Api$request.Get_Rn_Common_Info_String (
                                           l_Ur_Rn,
                                           c_Pt_Gender))))
          INTO l_Request_Body
          FROM Ikis_Rbm.Rn_Person  p
               JOIN Ikis_Rbm.Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE p.Rnp_Rn = l_Ur_Rn;

        l_Request_Body_B64 :=
            Tools.B64_Encode (l_Request_Body.Getclobval, 'UTF8');

        SELECT XMLELEMENT ("CommonRequest",
                           XMLELEMENT ("Body", l_Request_Body_B64))
          INTO l_Request_Payload
          FROM DUAL;

        RETURN l_Request_Payload.Getclobval;
    END;

    -------------------------------------------------------------------------------
    --  Обгортка відповіді на універсальний запит до ПФУ
    -------------------------------------------------------------------------------
    FUNCTION Parse_Common_Response (p_Response IN CLOB)
        RETURN r_Common_Response
    IS
        l_Common_Response   r_Common_Response;
    BEGIN
                     SELECT Resp_Body, Result_Code, Result_Tech_Info
                       INTO l_Common_Response
                       FROM XMLTABLE (
                                Xmlnamespaces (DEFAULT 'http://tempuri.org/'),
                                '/*'
                                PASSING Xmltype (p_Response)
                                COLUMNS Resp_Body           CLOB PATH 'Body',
                                        Result_Code         NUMBER PATH 'ResultCode',
                                        Result_Tech_Info    VARCHAR2 (4000) PATH 'ResultTechInfo');

        l_Common_Response.Response_Body :=
            Tools.B64_Decode (l_Common_Response.Response_Body, 'UTF8');

        RETURN l_Common_Response;
    END;

    -- #100872 serhii - Реєстрація запиту до ПФУ для проведення перерахунку по ПКМУ 332 п.п.5.1, 13.1, 13.2
    PROCEDURE Reg_Put_Person_Vpo_Aid_Info_Req (
        p_Me_Id       IN     Rn_Common_Info.Rnc_Val_Int%TYPE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Ur_Ext_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => p_Rn_Id,
                                         p_Rnc_Pt        => c_Pt_Me_Id,
                                         p_Rnc_Val_Int   => p_Me_Id);
    END;

    --  serhii 25/04/2024 #100872 NRT_QUERY_FUNC
    FUNCTION Put_Person_Vpo_Aid_Info_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn          NUMBER;
        l_Request_Body   XMLTYPE;
    --l_Me_Id             NUMBER(14);
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        --l_Me_Id := Api$request.Get_Rn_Common_Info_Int(p_Rnc_Rn => l_Ur_Rn, p_Rnc_Pt => c_Pt_Me_Id);

        SELECT XMLELEMENT (
                   "PutPersonVpoAidInfoReq",
                   XMLELEMENT ("ReqId", l_Ur_Rn),
                   (SELECT XMLELEMENT (
                               "Persons",
                               XMLAGG (
                                   XMLELEMENT (
                                       "Person",
                                       XMLELEMENT ("id", r.m3rr_id),
                                       XMLELEMENT ("ScId", r.m3rr_sc),
                                       XMLELEMENT (
                                           "Person_Info",
                                           XMLELEMENT (
                                               "General",
                                               XMLELEMENT ("Ip_Unique",
                                                           r.m3rr_ip_unique),
                                               -- Ip_Unique не передаємо. Див: #100873-note29
                                               XMLELEMENT ("Ln", r.m3rr_ln),
                                               XMLELEMENT ("Fn", r.m3rr_fn),
                                               XMLELEMENT ("Mn", r.m3rr_mn),
                                               XMLELEMENT ("Unzr",
                                                           r.m3rr_unzr),
                                               XMLELEMENT ("Numident",
                                                           r.m3rr_numident),
                                               XMLELEMENT ("Doc_Tp",
                                                           r.m3rr_doc_tp),
                                               -- Decode(p.Rnp_Ndt, 6, 1, 7, 2, 165, 3)
                                               XMLELEMENT ("Doc_Sn",
                                                           r.m3rr_doc_sn),
                                               XMLELEMENT (
                                                   "Birthday",
                                                   TO_CHAR (r.m3rr_birthday,
                                                            'YYYY-MM-DD')))),
                                       XMLELEMENT (
                                           "PPPRDt",
                                           TO_CHAR (r.m3rr_pppr_dt,
                                                    'YYYY-MM-DD')),
                                       XMLELEMENT (
                                           "AccrDt",
                                           TO_CHAR (r.m3rr_accr_dt,
                                                    'YYYY-MM-DD')),
                                       XMLELEMENT ("ReqTp", r.m3rr_req_tp))))
                      FROM uss_esr.v_me_332vpo_request_rows r
                     WHERE r.m3rr_req_id = l_Ur_Rn--AND r.m3rr_me = p_me_id
                                                  ))
          INTO l_Request_Body
          FROM DUAL;

        RETURN l_Request_Body.Getclobval;
    END;

    --#95391 - Реєстрація запиту на розрахунок середньомісячного сукупного доходу сім’ї пільговика в ПФУ
    PROCEDURE Run_Get_Avg_Month_Income (
        p_Body           IN OUT NOCOPY CLOB,
        p_Period_Start                 DATE,
        p_Period_Stop                  DATE,
        p_Rn_Id             OUT        Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => NULL,
            p_Ur_Create_Wu   => NULL,
            p_Ur_Ext_Id      => NULL,
            p_Ur_Body        => p_Body,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => 84           /*IKIS.Common.GetAvgMonthIncome*/
                                  ,
            p_Rn_Src         => 'USS',
            p_Rn_Hs_Ins      => Tools.Gethistsession,
            p_New_Rn_Id      => p_Rn_Id);
        --Зберігаємо період за який запитуємо дані
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Period_Begin,
                                         p_Rnc_Val_Dt   => p_Period_Start);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Period_End,
                                         p_Rnc_Val_Dt   => p_Period_Stop);
    END;

    -------------------------------------------------------------------------
    --                     Реєстрація запиту до ПФУ
    --           для масового отримання інформації про доходи
    -- #107929
    -------------------------------------------------------------------------
    PROCEDURE Reg_Me_Incomes_Req (
        p_Me_Id        IN     Rn_Common_Info.Rnc_Val_Int%TYPE,
        p_Ur_Plan_Dt   IN     Uxp_Request.Ur_Plan_Dt%TYPE,
        p_Ur_Ext_Id    IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => p_Ur_Plan_Dt,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Ur_Ext_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => 115,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => NULL,
                                              p_New_Rn_Id      => p_Rn_Id);
    END;

    -------------------------------------------------------------------------
    --           Отримання даних для відправки запиту до ПФУ
    --           для масового отримання інформації про доходи
    -- #107929
    -------------------------------------------------------------------------
    FUNCTION Get_Me_Incomes_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn              NUMBER;
        l_Request_Body       XMLTYPE;
        l_Request_Body_B64   CLOB;
        l_Request_Payload    XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        SELECT XMLELEMENT (
                   "UPSZN_ISSUES",
                   XMLELEMENT ("EXTERNAL_ID", l_Ur_Rn),
                   XMLELEMENT ("COD_UPSZN", NULL),
                   XMLELEMENT ("DATE_UPSZN",
                               TO_CHAR (j.Rn_Ins_Dt, 'DDMMYYYYHH24MISS')),
                   (SELECT XMLELEMENT (
                               "PERSONS",
                               XMLAGG (
                                   XMLELEMENT (
                                       "PERSON",
                                       XMLELEMENT ("ID_ISSUE", s.Mirs_Id),
                                       XMLELEMENT ("CASE_NUMBER", NULL),
                                       XMLELEMENT ("NUM_KSS",
                                                   r.Mirr_Ip_Unique),
                                       XMLELEMENT ("PN", r.Mirr_Numident),
                                       XMLELEMENT (
                                           "DOC_TYPE",
                                           DECODE (r.Mirr_Doc_Tp,
                                                   6, 1,
                                                   7, 2,
                                                   165, 3)),
                                       XMLELEMENT ("DOC_SER", r.Mirr_Doc_Ser),
                                       XMLELEMENT (
                                           "DOC_NOM",
                                           --ПФУ зі своєї сторони приймають тільки певні документи
                                           --та довжиною документу не більше 10 символів
                                           CASE
                                               WHEN     Mirr_Doc_Tp IN
                                                            (6, 7, 165)
                                                    AND LENGTH (Mirr_Doc_Num) <=
                                                        10
                                               THEN
                                                   r.Mirr_Doc_Num
                                           END),
                                       XMLELEMENT ("LN", r.Mirr_Ln),
                                       XMLELEMENT ("NM", r.Mirr_Fn),
                                       XMLELEMENT ("FTN", r.Mirr_Mn),
                                       XMLELEMENT (
                                           "BIRTHDAY",
                                           TO_CHAR (r.Mirr_Birth_Dt,
                                                    'DDMMYYYY')),
                                       XMLELEMENT (
                                           "PERIOD_START",
                                           TO_CHAR (r.Mirr_Period_Start_Dt,
                                                    'DDMMYYYY')),
                                       XMLELEMENT (
                                           "PERIOD_STOP",
                                           TO_CHAR (r.Mirr_Period_Stop_Dt,
                                                    'DDMMYYYY')),
                                       XMLELEMENT ("OZN_SUB", NULL))))
                      FROM Uss_Esr.v_Me_Income_Request_Rows  r,
                           Uss_Esr.v_Me_Income_Request_Src   s
                     WHERE r.Mirr_Id = s.Mirs_Mirr AND s.Mirs_Rn = j.Rn_Id))
          INTO l_Request_Body
          FROM Request_Journal j
         WHERE j.Rn_Id = l_Ur_Rn;

        -- l_Request_Body_B64 := Tools.B64_Encode(l_Request_Body.Getclobval, 'UTF8');
        l_Request_Body_B64 :=
            Tools.encode_base64 (
                Tools.ConvertC2BUTF8 (l_Request_Body.Getclobval));

        SELECT XMLELEMENT ("CommonRequest",
                           XMLELEMENT ("Body", l_Request_Body_B64))
          INTO l_Request_Payload
          FROM DUAL;

        RETURN l_Request_Payload.Getclobval;
    END;

    -------------------------------------------------------------------------
    --                     Реєстрація запиту до ПФУ
    --           для передачі відомостей від МОЗ про встановлення інвалідності та
    --       призначення ДЗР тимчасового або постійного застосування/використання
    -- #112503
    -------------------------------------------------------------------------
    PROCEDURE Reg_Put_Moz_Data_Req (
        p_Scdi_Id     IN     NUMBER,
        p_Ur_Ext_Id   IN     Uxp_Request.Ur_Ext_Id%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        --Реєструємо запит в черзі Трембіти
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Ur_Ext_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => 130,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => NULL,
                                              p_New_Rn_Id      => p_Rn_Id);

        --Ід користувача проміжних данних
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => p_Rn_Id,
                                         p_Rnc_Pt        => c_Pt_Scdi_Id,
                                         p_Rnc_Val_Int   => p_Scdi_Id);
    END;

    -------------------------------------------------------------------------
    --           Формування даних від МОЗ до ПФУ
    --       для передачі відомостей від МОЗ про встановлення інвалідності та
    --   призначення ДЗР тимчасового або постійного застосування/використання
    -------------------------------------------------------------------------
    FUNCTION Get_Put_Moz_Data_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn              NUMBER;
        l_Scdi_Id            NUMBER;

        l_Request_Body       XMLTYPE;
        l_Request_Body_B64   CLOB;
        l_Request_Payload    XMLTYPE;

        l_Frm_Dt             VARCHAR2 (20) := 'DDMMYYYY';
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Scdi_Id :=
            Api$request.Get_Rn_Common_Info_Int (p_Rnc_Rn   => l_Ur_Rn,
                                                p_Rnc_Pt   => c_Pt_Scdi_Id);

        SELECT XMLELEMENT (
                   "PutMozDataRequest",
                   XMLELEMENT ("ReqId", d.Scdi_Ext_Ident),
                   XMLELEMENT ("Ln", d.Scdi_Ln),
                   XMLELEMENT ("Fn", d.Scdi_Fn),
                   XMLELEMENT ("Mn", d.Scdi_Mn),
                   XMLELEMENT ("BirthDt",
                               TO_CHAR (d.Scdi_Birthday, l_Frm_Dt)),
                   XMLELEMENT ("Numident", d.Scdi_Numident),
                   XMLELEMENT (
                       "NoNumident",
                       CASE
                           WHEN EXISTS
                                    (SELECT 1
                                       FROM Uss_Person.v_Sc_Pfu_Document d
                                      WHERE     d.Scpo_Scdi = d.Scdi_Id
                                            AND d.Scpo_Ndt = 10117)
                           THEN
                               1
                           ELSE
                               0
                       END),
                   XMLELEMENT ("DocTp", d.Scdi_Doc_Tp),
                   XMLELEMENT ("DocSn", d.Scdi_Doc_Sn),
                   XMLELEMENT (
                       "OrgData",
                       XMLELEMENT ("OrgName", z.Scmz_Org_Name),
                       XMLELEMENT ("OrgId", z.Scmz_Org_Id),
                       XMLELEMENT ("KATOTTG",
                                   COALESCE (z.Scmz_City_Id,
                                             z.Scmz_Community_Id,
                                             z.Scmz_District_Id,
                                             z.Scmz_Region_Id)),
                       XMLELEMENT ("RegionName", z.Scmz_Region_Name),
                       XMLELEMENT ("DistrictName", z.Scmz_District_Name),
                       XMLELEMENT ("CommunityName", z.Scmz_Community_Name),
                       XMLELEMENT ("CityName", z.Scmz_City_Name),
                       XMLELEMENT ("StreetName", z.Scmz_Street_Name),
                       XMLELEMENT ("Building", z.Scmz_Building),
                       XMLELEMENT ("Room", z.Scmz_Room),
                       XMLELEMENT ("PostCode", z.Scmz_Post_Code)),
                   XMLELEMENT ("EvalDt", TO_CHAR (a.Scma_Eval_Dt, l_Frm_Dt)),
                   XMLELEMENT (
                       "DecisionData",
                       XMLELEMENT ("DecisionNum", a.Scma_Decision_Num),
                       XMLELEMENT ("DecisionDt",
                                   TO_CHAR (a.Scma_Decision_Dt, l_Frm_Dt))),
                   XMLELEMENT (
                       "DisabilityData",
                       XMLELEMENT (
                           "IsGroup",
                           DECODE (a.Scma_Is_Group,  'T', 1,  'F', 0)),
                       XMLELEMENT ("StartDt",
                                   TO_CHAR (a.Scma_Start_Dt, l_Frm_Dt)),
                       XMLELEMENT ("Group", a.Scma_Group),
                       XMLELEMENT ("MainDiagnosis", a.Scma_Main_Diagnosis),
                       XMLELEMENT (
                           "AddDiagnoses",
                           (    SELECT XMLAGG (
                                           XMLELEMENT (
                                               "AddDiagnosis",
                                               REGEXP_SUBSTR (
                                                   a.Scma_Add_Diagnoses,
                                                   '[^,]+',
                                                   1,
                                                   LEVEL)))
                                  FROM DUAL
                            CONNECT BY LEVEL <=
                                         LENGTH (a.Scma_Add_Diagnoses)
                                       - LENGTH (
                                             REPLACE (a.Scma_Add_Diagnoses,
                                                      ','))
                                       + 1)),
                       XMLELEMENT (
                           "IsEndless",
                           DECODE (a.Scma_Is_Endless,  'T', 1,  'F', 0)),
                       XMLELEMENT ("EndDt",
                                   TO_CHAR (a.Scma_End_Dt, l_Frm_Dt)),
                       XMLELEMENT (
                           "Reasons",
                           (    SELECT XMLAGG (
                                           XMLELEMENT (
                                               "Reason",
                                               REGEXP_SUBSTR (a.Scma_Reasons,
                                                              '[^,]+',
                                                              1,
                                                              LEVEL)))
                                  FROM DUAL
                            CONNECT BY LEVEL <=
                                         LENGTH (a.Scma_Reasons)
                                       - LENGTH (
                                             REPLACE (a.Scma_Reasons, ','))
                                       + 1)),
                       XMLELEMENT ("IsPrev",
                                   DECODE (a.Scma_Is_Prev,  'T', 1,  'F', 0))),
                   XMLELEMENT (
                       "LossProfAbilityData",
                       XMLELEMENT (
                           "IsLossProfAbility",
                           DECODE (a.Scma_Is_Loss_Prof_Ability,
                                   'T', 1,
                                   'F', 0)),
                       XMLELEMENT ("DiseaseDt",
                                   TO_CHAR (a.Scma_Disease_Dt, l_Frm_Dt)),
                       XMLELEMENT (
                           "LossProfAbilityDataRec",
                           (SELECT XMLAGG (
                                       XMLELEMENT (
                                           "Row",
                                           XMLELEMENT (
                                               "LossProfAbilityStartDt",
                                               TO_CHAR (
                                                   l.scml_loss_prof_ability_dt,
                                                   l_Frm_Dt)),
                                           XMLELEMENT (
                                               "LossProfAbilityPerc",
                                               TRIM (
                                                   TO_CHAR (
                                                       l.Scml_Loss_Prof_Ability_Perc,
                                                       '9999999999990D99',
                                                       'NLS_NUMERIC_CHARACTERS=''. '''))),
                                           XMLELEMENT (
                                               "LossProfAbilityCause",
                                               l.Scml_Loss_Prof_Ability_Cause)))
                              FROM Uss_Person.v_Sc_Moz_Loss_Prof_Ability l
                             WHERE l.Scml_Scdi = d.Scdi_Id)),
                       /*Xmlelement("LossProfAbilityStartDt",
                                  To_Char(a.Scma_Loss_Prof_Ability_Dt, l_Frm_Dt)),
                       Xmlelement("LossProfAbilityPerc",
                                  TRIM(To_Char(a.Scma_Loss_Prof_Ability_Perc,
                                               '9999999999990D99',
                                               'NLS_NUMERIC_CHARACTERS=''. '''))),
                       Xmlelement("LossProfAbilityCause", a.Scma_Loss_Prof_Ability_Cause),*/
                       XMLELEMENT ("ReexamDt",
                                   TO_CHAR (a.Scma_Reexam_Dt, l_Frm_Dt))),
                   XMLELEMENT (
                       "EvalTempDisData",
                       XMLELEMENT (
                           "IsExtTempDis",
                           DECODE (a.Scma_Is_Ext_Temp_Dis,  'T', 1,  'F', 0)),
                       XMLELEMENT (
                           "ExtTempDisDt",
                           TO_CHAR (a.Scma_Ext_Temp_Dis_Dt, l_Frm_Dt))),
                   XMLELEMENT (
                       "EvalDeathDisData",
                       XMLELEMENT (
                           "IsDeathDisConn",
                           DECODE (a.Scma_Is_Death_Dis_Conn,
                                   'T', 1,
                                   'F', 0))),
                   XMLELEMENT ("IsPfuRec",
                               DECODE (a.Scma_Is_Pfu_Rec,  'T', 1,  'F', 0)),
                   XMLELEMENT ("AddNeeds", a.Scma_Add_Needs))
          INTO l_Request_Body
          FROM Uss_Person.v_Sc_Pfu_Data_Ident  d
               JOIN Uss_Person.v_Sc_Moz_Assessment a
                   ON a.Scma_Scdi = d.Scdi_Id
               JOIN Uss_Person.v_Sc_Moz_Zoz z ON z.Scmz_Scdi = d.Scdi_Id
         WHERE d.Scdi_Id = l_Scdi_Id;

        RETURN l_Request_Body.Getclobval;
    END;
END Api$request_Pfu;
/