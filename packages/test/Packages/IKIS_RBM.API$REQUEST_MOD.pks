/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_MOD
IS
    -- Author  : KELATEV
    -- Created : 13.02.2025 9:17:34
    -- Purpose : Запити до МО (МінОборони)

    Package_Name                                         CONSTANT VARCHAR2 (50) := 'API$REQUEST_MOD';

    c_Urt_Evod_By_Person                                 CONSTANT NUMBER := 141;
    c_Urt_Get_Doc_Cause_By_Personal_Identifier           CONSTANT NUMBER := 142;
    c_Urt_Get_Vlk_And_Doc_Cause_By_Document_Identifier   CONSTANT NUMBER
                                                                      := 143 ;

    c_Pt_Guid                                            CONSTANT NUMBER
                                                                      := 463 ;
    c_Pt_Period_Begin                                    CONSTANT NUMBER
                                                                      := 167 ;
    c_Pt_Period_End                                      CONSTANT NUMBER
                                                                      := 168 ;
    c_Pt_Event_Dt                                        CONSTANT NUMBER
                                                                      := 97 ;
    c_Pt_Doc_Dt                                          CONSTANT NUMBER
                                                                      := 80 ;
    c_Pt_Doc_Ndt                                         CONSTANT NUMBER
                                                                      := 329 ;
    c_Pt_Doc_Num                                         CONSTANT NUMBER
                                                                      := 123 ;
    c_Pt_If_Last_Needed                                  CONSTANT NUMBER
                                                                      := 263 ;

    c_Default_Rnokpp_Ndt_Id                              CONSTANT NUMBER := 5;

    TYPE r_Evod_Response IS RECORD
    (
        Result_Code             NUMBER,
        Guid                    VARCHAR2 (250),
        Surname                 VARCHAR2 (250),
        Name_                   VARCHAR2 (250),
        Patronymic              VARCHAR2 (250),
        Rnokpp                  VARCHAR2 (100),
        Date_Birth              DATE,
        Win                     VARCHAR2 (250), --Унікальний номер особи (ВІН)
        RANK                    VARCHAR2 (250),                       --Звання
        Vos_Name                VARCHAR2 (1000),            --Найменування ВОС
        Vos_Cod                 VARCHAR2 (10),              --Код ВОС (6 цифр)
        Account_Type            VARCHAR2 (250), --Вид обліку: Солдат, Офіцер, Призовник
        Account_Status          VARCHAR2 (250), --Статус обліку: на обліку, знятий, виключений
        Reason                  VARCHAR2 (250),    --Причина зняття/виключення
        Reservation_Status      VARCHAR2 (250),      --V_DDN_MO_RESERVATION_ST
        Reservation_End_Date    DATE,
        Tcc_Name                VARCHAR2 (1000), --ТЦК та СП, де стоїть на обліку
        Vlk_Type                VARCHAR2 (250), --Придатність: Тимчасово непридатний; непридатний в мирний час, обмежено придатний в воєнний; придатний; непридатний з виключенням з військового обліку
        Vlk_Date                DATE,
        Deferral                VARCHAR2 (10), --Відстрочка: 0 - немає відстрочки; >0 - є відстрочка
        Deferral_End_Date       DATE,
        Wanted                  VARCHAR2 (10), --Розшук: 0 - не в розшуку; >0 - в розшуку
        Mildoc_Type             VARCHAR2 (10),            --V_DDN_MO_MILDOC_TP
        Mildoc_Se               VARCHAR2 (100),
        Mildoc_Num              VARCHAR2 (100),
        Conscript_Status        VARCHAR2 (10) --Статус документу військовозобов’я-заного--V_DDN_MO_CONSCRIPT_ST
    );

    TYPE r_Signature IS RECORD
    (
        Sign_Owner_Full_Name      VARCHAR2 (1000),
        Sign_Owner_Title          VARCHAR2 (250),
        Sign_Owner_Edrpou_Code    VARCHAR2 (20),
        Sign_Owner_Org_Name       VARCHAR2 (1000),
        Sign_Owner_Org_Unit       VARCHAR2 (1000),
        Sign_Serial_Number        VARCHAR2 (100),
        Sign_Time_Stamp           VARCHAR2 (100),
        Sign_Issuer               VARCHAR2 (1000)
    );

    TYPE t_Doc_Cause_Signature_List IS TABLE OF r_Signature;

    TYPE r_Doc_Cause IS RECORD
    (
        Doc_Cause_Guid                VARCHAR2 (100),
        Doc_Type_Guid                 VARCHAR2 (100),
        Doc_Type_Name                 VARCHAR2 (1000),
        Doc_Cause_Number              VARCHAR2 (100),
        Doc_Cause_Date                DATE,
        Doc_Cause_Institution_Id      VARCHAR2 (100),
        Doc_Cause_Institution_Name    VARCHAR2 (1000),
        Doc_Cause_Event_Date          DATE,
        Doc_Cause_Event_Desc          VARCHAR2 (4000),
        Doc_Cause_Circumstance        VARCHAR2 (1000),
        Doc_Cause_Consequence         VARCHAR2 (1000),
        Doc_Cause_Safety_Equipment    VARCHAR2 (10),
        Infringement                  VARCHAR2 (10),
        Intoxication                  VARCHAR2 (10),
        Self_Harm                     VARCHAR2 (10),
        Doc_Cause_Signature_List      t_Doc_Cause_Signature_List
    );

    TYPE t_Doc_Cause_List IS TABLE OF r_Doc_Cause;

    TYPE r_Doc_Cause_Response IS RECORD
    (
        Person_Name1                 VARCHAR2 (250),
        Person_Name2                 VARCHAR2 (250),
        Person_Name3                 VARCHAR2 (250),
        Person_Birth_Date            DATE,
        Personal_Identifier_Type     VARCHAR2 (10),
        Personal_Identifier_Value    VARCHAR2 (50),
        Doc_Cause_List               t_Doc_Cause_List,
        Err_Code                     NUMBER
    );

    PROCEDURE Reg_Evod_By_Person_Request (p_Sc_Id      IN     NUMBER,
                                          p_Numident   IN     VARCHAR2,
                                          p_Fn         IN     VARCHAR2,
                                          p_Ln         IN     VARCHAR2,
                                          p_Mn         IN     VARCHAR2,
                                          p_Doc_Ser    IN     VARCHAR2,
                                          p_Doc_Num    IN     VARCHAR2,
                                          p_Wu_Id      IN     NUMBER,
                                          p_Src        IN     VARCHAR2,
                                          p_Rn_Id         OUT NUMBER);

    FUNCTION Build_Evod_By_Person_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Evod_Resp (p_Response IN CLOB)
        RETURN r_Evod_Response;

    FUNCTION Decode_Identifier_Type (p_Doc_Ndt IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Encode_Identifier_Type (p_Personal_Identifier_Type IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Decode_Doc_Type_Demo (p_Doc_Ndt IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Decode_Doc_Type (p_Doc_Ndt IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Reg_Doc_Cause_By_Personal_Identifier_Request (
        p_Sc_Id                  IN     NUMBER,
        p_Fn                     IN     VARCHAR2,
        p_Ln                     IN     VARCHAR2,
        p_Mn                     IN     VARCHAR2,
        p_Numident               IN     VARCHAR2,
        p_Doc_Ndt                IN     NUMBER,
        p_Doc_Ser                IN     VARCHAR2,
        p_Doc_Num                IN     VARCHAR2,
        p_Creation_Start_Dt      IN     DATE DEFAULT NULL,
        p_Creation_End_Dt        IN     DATE DEFAULT NULL,
        p_Institution_Guid       IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Cause_Event_Date   IN     DATE DEFAULT NULL,
        p_Doc_Cause_Date         IN     DATE DEFAULT NULL,
        p_Doc_Cause_Number       IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Cause_Ndt          IN     NUMBER DEFAULT NULL,
        p_If_Last_Needed         IN     VARCHAR2 DEFAULT NULL,
        p_Wu_Id                  IN     NUMBER,
        p_Src                    IN     VARCHAR2,
        p_Rn_Id                     OUT NUMBER);

    FUNCTION Build_Doc_Cause_By_Personal_Identifier_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Doc_Cause_By_Document_Identifier_Request (
        p_Sc_Id      IN     NUMBER,
        p_Doc_Ndt    IN     NUMBER,
        p_Doc_Guid   IN     VARCHAR2,
        p_Wu_Id      IN     NUMBER,
        p_Src        IN     VARCHAR2,
        p_Rn_Id         OUT NUMBER);

    FUNCTION Build_Doc_Cause_By_Document_Identifier_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Doc_Cause_Resp (p_Response IN CLOB)
        RETURN r_Doc_Cause_Response;
END Api$request_Mod;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MOD TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:10:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_MOD
IS
    FUNCTION Get_Prm_Value (p_Param IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   Param_Rbm.Prm_Value%TYPE;
    BEGIN
        SELECT p.Prm_Value
          INTO l_Result
          FROM Param_Rbm p
         WHERE p.Prm_Code = p_Param;

        RETURN l_Result;
    END;

    ------------------------------------------------------------------------------
    --      Отримання реквізитів виконавця запиту
    ------------------------------------------------------------------------------
    PROCEDURE Get_Executor_Info (p_Executor_Wu       IN     NUMBER,
                                 p_Executor_Rnokpp      OUT VARCHAR2)
    IS
        l_Username   VARCHAR2 (50);
        l_Pib        VARCHAR2 (1000);
        l_Wut        NUMBER;
        l_Org        NUMBER;
        l_Org_Org    NUMBER;
        l_Trc        NUMBER;
    BEGIN
        Ikis_Sysweb.Get_User_Attr (p_Wu_Id      => p_Executor_Wu,
                                   p_Username   => l_Username,
                                   p_Pib        => l_Pib,
                                   p_Wut        => l_Wut,
                                   p_Org        => l_Org,
                                   p_Org_Org    => l_Org_Org,
                                   p_Trc        => l_Trc,
                                   p_Numid      => p_Executor_Rnokpp);

        --ІД картка БК
        IF p_Executor_Rnokpp LIKE 'П%'
        THEN
            p_Executor_Rnokpp := SUBSTR (p_Executor_Rnokpp, 2, 9);
        --Паспорт БК
        ELSIF p_Executor_Rnokpp LIKE 'БК%'
        THEN
            p_Executor_Rnokpp := SUBSTR (p_Executor_Rnokpp, 3, 8);
        END IF;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання за ПІБ та РНОКПП особи відомостей про облікові дані, наявні в військово-обліковому документі особи
    -- #111339
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Evod_By_Person_Request (p_Sc_Id      IN     NUMBER,
                                          p_Numident   IN     VARCHAR2,
                                          p_Fn         IN     VARCHAR2,
                                          p_Ln         IN     VARCHAR2,
                                          p_Mn         IN     VARCHAR2,
                                          p_Doc_Ser    IN     VARCHAR2,
                                          p_Doc_Num    IN     VARCHAR2,
                                          p_Wu_Id      IN     NUMBER,
                                          p_Src        IN     VARCHAR2,
                                          p_Rn_Id         OUT NUMBER)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Evod_By_Person,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => p_Sc_Id,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => p_Sc_Id,
                                    p_Rnp_Inn          => p_Numident,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => p_Doc_Ser,
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
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання за ПІБ та РНОКПП особи відомостей про облікові дані, наявні в військово-обліковому документі особи
    -- #111339
    ---------------------------------------------------------------------------
    FUNCTION Build_Evod_By_Person_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Req_Xml   XMLTYPE;
    BEGIN
        SELECT XMLELEMENT (
                   "GetEvodByPerson",
                   XMLELEMENT (
                       "RNOKPP",
                       NVL (p.Rnp_Inn, p.Rnp_Doc_Seria || p.Rnp_Doc_Number)),
                   XMLELEMENT ("surname", i.Rnpi_Ln),
                   XMLELEMENT ("name", i.Rnpi_Fn),
                   XMLELEMENT ("patronymic", i.Rnpi_Mn))    Request_Data
          INTO l_Req_Xml
          FROM Ikis_Rbm.Uxp_Request  r
               JOIN Ikis_Rbm.Rn_Person p ON r.Ur_Rn = p.Rnp_Rn
               JOIN Ikis_Rbm.Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Req_Xml.Getclobval;
    END;

    --------------------------------------------------------------------
    -- Парсинг відповіді на запит на
    -- Отримання за ПІБ та РНОКПП особи відомостей про облікові дані, наявні в військово-обліковому документі особи
    -- #111339
    --------------------------------------------------------------------
    FUNCTION Parse_Evod_Resp (p_Response IN CLOB)
        RETURN r_Evod_Response
    IS
        l_Resp   r_Evod_Response;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'R_EVOD_RESPONSE',
                                             'dd.mm.yyyy')
                USING IN p_Response, OUT l_Resp;
        END IF;

        RETURN l_Resp;
    END;

    FUNCTION Decode_Identifier_Type (p_Doc_Ndt IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (100);
    BEGIN
        l_Result :=
            CASE p_Doc_Ndt
                WHEN 5 THEN 'TaxId'
                WHEN 6 THEN 'Passport'
                WHEN 7 THEN 'Passport'
                WHEN 11 THEN 'IinternationalPassport'
                WHEN 10355 THEN 'DiplomaticPassport'
                WHEN 10356 THEN 'OfficialPassport'
                WHEN 10357 THEN 'SeafarerCard'
                WHEN 10358 THEN 'CrewMemberCard'
                WHEN 10359 THEN 'ReturnToUkraineCard'
                WHEN 13 THEN 'TemporaryCardNationalUkrainian'
                WHEN 10361 THEN 'IinternationaApatridCard'
                WHEN 8 THEN 'PermanentResidencePermit'
                WHEN 9 THEN 'TemporaryResidencePermit'
                WHEN 10362 THEN 'MigrantCard'
                WHEN 14 THEN 'RefugeeCard'
                WHEN 10363 THEN 'IinternationaRefugeeCard'
                WHEN 807 THEN 'AdditionalProtectedCard'
                WHEN 10364 THEN 'IinternationaAdditionalProtectedCard'
                WHEN 37 THEN 'BirthCertificate'
                WHEN 673 THEN 'BirthCertificate'
                ELSE NULL
            END;
        RETURN l_Result;
    END;

    FUNCTION Encode_Identifier_Type (p_Personal_Identifier_Type IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        l_Result :=
            CASE p_Personal_Identifier_Type
                WHEN 'TaxId' THEN 5
                WHEN 'Passport' THEN 6
                WHEN 'IinternationalPassport' THEN 11
                WHEN 'DiplomaticPassport' THEN 10355
                WHEN 'OfficialPassport' THEN 10356
                WHEN 'SeafarerCard' THEN 10357
                WHEN 'CrewMemberCard' THEN 10358
                WHEN 'ReturnToUkraineCard' THEN 10359
                WHEN 'TemporaryCardNationalUkrainian' THEN 13
                WHEN 'IinternationaApatridCard' THEN 10361
                WHEN 'PermanentResidencePermit' THEN 8
                WHEN 'TemporaryResidencePermit' THEN 9
                WHEN 'MigrantCard' THEN 10362
                WHEN 'RefugeeCard' THEN 14
                WHEN 'IinternationaRefugeeCard' THEN 10363
                WHEN 'AdditionalProtectedCard' THEN 807
                WHEN 'IinternationaAdditionalProtectedCard' THEN 10364
                WHEN 'BirthCertificate' THEN 37
                ELSE NULL
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_Doc_Type_Demo (p_Doc_Ndt IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (100);
    BEGIN
        l_Result :=
            CASE p_Doc_Ndt
                WHEN '1' THEN '702C414A-2145-4186-985B-2141F3D71C4D' --Довідка ВЛК
                WHEN '2' THEN '53161C54-B653-4C62-A6DB-45FE5FA5D3F8' --Свідоцтво про хворобу
                WHEN '3' THEN 'B705BCD4-6968-4164-8392-405371B5A474' --Протокол засідання шВЛК
                WHEN '4' THEN '96694A6A-170B-429C-B67A-65B6A91D8E93' --Довідка про обставини травми
                WHEN '5' THEN 'F586B6D0-D14F-4C2E-9AD0-AC9088131C57' --Витяг з протоколу засідання штатної ВЛК
                ELSE NULL
            END;
        RETURN l_Result;
    END;

    FUNCTION Decode_Doc_Type (p_Doc_Ndt IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (100);
    BEGIN
        l_Result :=
            CASE p_Doc_Ndt
                WHEN 0 THEN '702C414A-2145-4186-985B-2141F3D71C4D' --Довідка ВЛК
                WHEN 248 THEN '53161C54-B653-4C62-A6DB-45FE5FA5D3F8' --Свідоцтво про хворобу
                WHEN 0 THEN 'B705BCD4-6968-4164-8392-405371B5A474' --Протокол засідання шВЛК
                WHEN 10340 THEN '96694A6A-170B-429C-B67A-65B6A91D8E93' --Довідка про обставини травми
                WHEN 0 THEN 'F586B6D0-D14F-4C2E-9AD0-AC9088131C57' --Витяг з протоколу засідання штатної ВЛК
                ELSE NULL
            END;
        RETURN l_Result;
    END;

    FUNCTION Encode_Doc_Type (p_Doc_Type_Guid IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        l_Result :=
            CASE p_Doc_Type_Guid
                WHEN '702C414A-2145-4186-985B-2141F3D71C4D' THEN --Довідка ВЛК
                                                                 0
                WHEN '53161C54-B653-4C62-A6DB-45FE5FA5D3F8' THEN --Свідоцтво про хворобу
                                                                 248
                WHEN 'B705BCD4-6968-4164-8392-405371B5A474' THEN --Протокол засідання шВЛК
                                                                 0
                WHEN '96694A6A-170B-429C-B67A-65B6A91D8E93' THEN --Довідка про обставини травми
                                                                 10340
                WHEN 'F586B6D0-D14F-4C2E-9AD0-AC9088131C57' THEN --Витяг з протоколу засідання штатної ВЛК
                                                                 0
                ELSE NULL
            END;
        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання інформації про обставини отримання травми та/або документи-підстави причинних зв'язків щодо особи
    -- #111339
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Doc_Cause_By_Personal_Identifier_Request (
        p_Sc_Id                  IN     NUMBER,
        p_Fn                     IN     VARCHAR2,
        p_Ln                     IN     VARCHAR2,
        p_Mn                     IN     VARCHAR2,
        p_Numident               IN     VARCHAR2,
        p_Doc_Ndt                IN     NUMBER,
        p_Doc_Ser                IN     VARCHAR2,
        p_Doc_Num                IN     VARCHAR2,
        p_Creation_Start_Dt      IN     DATE DEFAULT NULL,
        p_Creation_End_Dt        IN     DATE DEFAULT NULL,
        p_Institution_Guid       IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Cause_Event_Date   IN     DATE DEFAULT NULL,
        p_Doc_Cause_Date         IN     DATE DEFAULT NULL,
        p_Doc_Cause_Number       IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Cause_Ndt          IN     NUMBER DEFAULT NULL,
        p_If_Last_Needed         IN     VARCHAR2 DEFAULT NULL,           --T/F
        p_Wu_Id                  IN     NUMBER,
        p_Src                    IN     VARCHAR2,
        p_Rn_Id                     OUT NUMBER)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Get_Doc_Cause_By_Personal_Identifier,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => p_Sc_Id,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => p_Sc_Id,
                                    p_Rnp_Inn          => p_Numident,
                                    p_Rnp_Ndt          => p_Doc_Ndt,
                                    p_Rnp_Doc_Seria    => p_Doc_Ser,
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

        IF p_Creation_Start_Dt IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn       => p_Rn_Id,
                p_Rnc_Pt       => c_Pt_Period_Begin,
                p_Rnc_Val_Dt   => p_Creation_Start_Dt);
        END IF;

        IF p_Creation_End_Dt IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn       => p_Rn_Id,
                p_Rnc_Pt       => c_Pt_Period_End,
                p_Rnc_Val_Dt   => p_Creation_End_Dt);
        END IF;

        IF p_Institution_Guid IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn           => p_Rn_Id,
                p_Rnc_Pt           => c_Pt_Guid,
                p_Rnc_Val_String   => p_Institution_Guid);
        END IF;

        IF p_Doc_Cause_Event_Date IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn       => p_Rn_Id,
                p_Rnc_Pt       => c_Pt_Event_Dt,
                p_Rnc_Val_Dt   => p_Doc_Cause_Event_Date);
        END IF;

        IF p_Doc_Cause_Date IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn       => p_Rn_Id,
                p_Rnc_Pt       => c_Pt_Doc_Dt,
                p_Rnc_Val_Dt   => p_Doc_Cause_Date);
        END IF;

        IF p_Doc_Cause_Ndt IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn       => p_Rn_Id,
                p_Rnc_Pt       => c_Pt_Doc_Ndt,
                p_Rnc_Val_Id   => p_Doc_Cause_Ndt);
        END IF;

        IF p_Doc_Cause_Number IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn           => p_Rn_Id,
                p_Rnc_Pt           => c_Pt_Doc_Num,
                p_Rnc_Val_String   => p_Doc_Cause_Number);
        END IF;

        IF p_If_Last_Needed IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn           => p_Rn_Id,
                p_Rnc_Pt           => c_Pt_If_Last_Needed,
                p_Rnc_Val_String   => p_If_Last_Needed);
        END IF;
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання інформації про обставини отримання травми та/або документи-підстави причинних зв'язків щодо особи
    -- #111339
    ---------------------------------------------------------------------------
    FUNCTION Build_Doc_Cause_By_Personal_Identifier_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Uxp_Request            Uxp_Request%ROWTYPE;
        l_Executor_Edrpou        VARCHAR2 (13);
        l_Executor_Rnokpp        VARCHAR2 (10);
        l_Creation_Start         DATE;
        l_Creation_End           DATE;
        l_Institution_Guid       VARCHAR2 (100);
        l_Doc_Cause_Event_Date   DATE;
        l_Doc_Cause_Date         DATE;
        l_Doc_Cause_Ndt          VARCHAR2 (10);                      --NUMBER;
        l_Doc_Cause_Number       VARCHAR2 (100);
        l_If_Last_Needed         VARCHAR2 (10);

        l_Request_Payload        XMLTYPE;
    BEGIN
        l_Uxp_Request := Api$uxp_Request.Get_Request (p_Ur_Id => p_Ur_Id);

        IF l_Uxp_Request.Ur_Create_Wu IS NOT NULL
        THEN
            Get_Executor_Info (p_Executor_Wu       => l_Uxp_Request.Ur_Create_Wu,
                               p_Executor_Rnokpp   => l_Executor_Rnokpp);
        ELSE
            l_Executor_Rnokpp := Get_Prm_Value ('DPS_EXECUTOR_RNOKPP');
        END IF;

        l_Executor_Edrpou := Get_Prm_Value ('DPS_EXECUTOR_EDRPOU');

        l_Creation_Start :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Period_Begin);
        l_Creation_End :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Period_End);
        l_Institution_Guid :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Guid);
        l_Doc_Cause_Event_Date :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Event_Dt);
        l_Doc_Cause_Date :=
            Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Doc_Dt);
        l_Doc_Cause_Ndt :=
            Api$request.Get_Rn_Common_Info_String    /*Get_Rn_Common_Info_Id*/
                                                  (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Doc_Ndt);
        l_Doc_Cause_Number :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Doc_Num);
        l_If_Last_Needed :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_If_Last_Needed);

        SELECT XMLELEMENT (
                   "GetDocCauseByPersonalIdentifier",
                   XMLELEMENT ("PersonName1", i.Rnpi_Ln),
                   XMLELEMENT ("PersonName2", i.Rnpi_Fn),
                   XMLELEMENT ("PersonName3", i.Rnpi_Mn),
                   XMLELEMENT (
                       "PersonalIdentifierType",
                       Decode_Identifier_Type (
                           NVL2 (p.Rnp_Inn, 5, p.Rnp_Ndt))),
                   --Uss_Ndi.Tools.Decode_Dict(p_Nddc_Tp => 'SCHM', p_Nddc_Src => 'USS', p_Nddc_Dest => 'UXP', p_Nddc_Code_Src => p_Doc_Ndt)
                   XMLELEMENT (
                       "PersonalIdentifierValue",
                       NVL (p.Rnp_Inn, p.Rnp_Doc_Seria || p.Rnp_Doc_Number)),
                   XMLELEMENT ("CreationStartDate",
                               TO_CHAR (l_Creation_Start, 'yyyy-mm-dd')),
                   XMLELEMENT ("CreationEndDate",
                               TO_CHAR (l_Creation_End, 'yyyy-mm-dd')),
                   XMLELEMENT ("InstitutionGUID", l_Institution_Guid),
                   XMLELEMENT (
                       "DocCauseEventDate",
                       TO_CHAR (l_Doc_Cause_Event_Date, 'yyyy-mm-dd')),
                   XMLELEMENT ("DocCauseDate",
                               TO_CHAR (l_Doc_Cause_Date, 'yyyy-mm-dd')),
                   XMLELEMENT ("DocCauseNumber", l_Doc_Cause_Number),
                   XMLELEMENT ("DocTypeGUID",
                               Decode_Doc_Type_Demo (l_Doc_Cause_Ndt)),
                   XMLELEMENT (
                       "IfLastNeeded",
                       CASE l_If_Last_Needed
                           WHEN 'T' THEN 1
                           WHEN 'F' THEN 0
                       END),
                   XMLELEMENT ("executorRNOKPP", l_Executor_Rnokpp),
                   XMLELEMENT ("executorEDRPOU", l_Executor_Edrpou))    Request_Data
          INTO l_Request_Payload
          FROM Ikis_Rbm.Uxp_Request  r
               JOIN Ikis_Rbm.Rn_Person p ON r.Ur_Rn = p.Rnp_Rn
               JOIN Ikis_Rbm.Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Request_Payload.Getclobval;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання інформації про обставини отримання травми та/або документи-підстави причинних зв'язків щодо особи
    -- #111339
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Doc_Cause_By_Document_Identifier_Request (
        p_Sc_Id      IN     NUMBER,
        p_Doc_Ndt    IN     NUMBER,
        p_Doc_Guid   IN     VARCHAR2,
        p_Wu_Id      IN     NUMBER,
        p_Src        IN     VARCHAR2,
        p_Rn_Id         OUT NUMBER)
    IS
        l_Ur_Id    NUMBER;
        l_Rnp_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         =>
                c_Urt_Get_Vlk_And_Doc_Cause_By_Document_Identifier,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => p_Sc_Id,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => p_Sc_Id,
                                    p_Rnp_Inn          => NULL,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Doc_Ndt,
                                         p_Rnc_Val_Id   => p_Doc_Ndt);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Guid,
                                         p_Rnc_Val_String   => p_Doc_Guid);
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання інформації про обставини отримання травми та/або документи-підстави причинних зв'язків щодо особи
    -- #111339
    ---------------------------------------------------------------------------
    FUNCTION Build_Doc_Cause_By_Document_Identifier_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Uxp_Request       Uxp_Request%ROWTYPE;
        l_Executor_Edrpou   VARCHAR2 (13);
        l_Executor_Rnokpp   VARCHAR2 (10);
        l_Doc_Ndt           VARCHAR2 (10);                           --NUMBER;
        l_Doc_Guid          VARCHAR2 (100);

        l_Request_Payload   XMLTYPE;
    BEGIN
        l_Uxp_Request := Api$uxp_Request.Get_Request (p_Ur_Id => p_Ur_Id);

        IF l_Uxp_Request.Ur_Create_Wu IS NOT NULL
        THEN
            Get_Executor_Info (p_Executor_Wu       => l_Uxp_Request.Ur_Create_Wu,
                               p_Executor_Rnokpp   => l_Executor_Rnokpp);
        ELSE
            l_Executor_Rnokpp := Get_Prm_Value ('DPS_EXECUTOR_RNOKPP');
        END IF;

        l_Executor_Edrpou := Get_Prm_Value ('DPS_EXECUTOR_EDRPOU');

        l_Doc_Ndt :=
            Api$request.Get_Rn_Common_Info_String    /*Get_Rn_Common_Info_Id*/
                                                  (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Doc_Ndt);
        l_Doc_Guid :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Uxp_Request.Ur_Rn,
                p_Rnc_Pt   => c_Pt_Guid);

        SELECT XMLELEMENT (
                   "GetVLKandDocCauseByDocumentIdentifier",
                   XMLELEMENT ("DocTypeGUID",
                               Decode_Doc_Type_Demo (l_Doc_Ndt)),
                   XMLELEMENT ("DocGUID", l_Doc_Guid),
                   XMLELEMENT ("executorRNOKPP", l_Executor_Rnokpp),
                   XMLELEMENT ("executorEDRPOU", l_Executor_Edrpou))    Request_Data
          INTO l_Request_Payload
          FROM DUAL;

        RETURN l_Request_Payload.Getclobval;
    END;

    --------------------------------------------------------------------
    -- Парсинг відповіді на запит на
    -- Отримання інформації про обставини отримання травми та/або документи-підстави причинних зв'язків щодо особи
    -- #111339
    --------------------------------------------------------------------
    FUNCTION Parse_Doc_Cause_Resp (p_Response IN CLOB)
        RETURN r_Doc_Cause_Response
    IS
        l_Resp   r_Doc_Cause_Response;

        FUNCTION Bool_Decode (p_Code IN VARCHAR2)
            RETURN VARCHAR2
        IS
        BEGIN
            RETURN CASE
                       WHEN p_Code = 'true' THEN 'T'
                       WHEN p_Code = 'false' THEN 'F'
                       ELSE p_Code
                   END;
        END;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'R_DOC_CAUSE_RESPONSE',
                                             'yyyy-mm-dd"T"hh24:mi:ss')
                USING IN p_Response, OUT l_Resp;
        END IF;

        IF l_Resp.Doc_Cause_List IS NOT NULL
        THEN
            FOR i IN 1 .. l_Resp.Doc_Cause_List.COUNT
            LOOP
                l_Resp.Doc_Cause_List (i).Doc_Cause_Safety_Equipment :=
                    Bool_Decode (
                        l_Resp.Doc_Cause_List (i).Doc_Cause_Safety_Equipment);
                l_Resp.Doc_Cause_List (i).Infringement :=
                    Bool_Decode (l_Resp.Doc_Cause_List (i).Infringement);
                l_Resp.Doc_Cause_List (i).Intoxication :=
                    Bool_Decode (l_Resp.Doc_Cause_List (i).Intoxication);
                l_Resp.Doc_Cause_List (i).Self_Harm :=
                    Bool_Decode (l_Resp.Doc_Cause_List (i).Self_Harm);
            END LOOP;
        END IF;

        RETURN l_Resp;
    END;
END Api$request_Mod;
/