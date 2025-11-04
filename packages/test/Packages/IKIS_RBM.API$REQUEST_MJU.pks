/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_MJU
IS
    -- Author  : SHOSTAK
    -- Created : 21.07.2021 17:56:42
    -- Purpose :

    Package_Name                             VARCHAR2 (100) := 'API$REQUEST_MJU';

    c_Result_Code_Ok                CONSTANT NUMBER := 0;
    c_Result_Code_Internal_Err      CONSTANT NUMBER := 1;
    c_Result_Code_Not_Allowed2      CONSTANT NUMBER := 2;
    c_Result_Code_Not_Allowed3      CONSTANT NUMBER := 3;
    c_Result_Code_Not_Allowed4      CONSTANT NUMBER := 4;
    c_Result_Code_Bad_Req           CONSTANT NUMBER := 5;

    c_Death_Delta_Res_Ok            CONSTANT NUMBER := 1;
    c_Death_Delta_Res_No_Data       CONSTANT NUMBER := 0;
    c_Death_Delta_Res_Err           CONSTANT NUMBER := 2;
    c_Death_Delta_Res_In_Progress   CONSTANT NUMBER := 3;

    c_Pt_Birth_Dt                   CONSTANT NUMBER := 87;
    c_Pt_Rnokpp                     CONSTANT NUMBER := 218;
    c_Pt_Cert_Serial                CONSTANT NUMBER := 280;
    c_Pt_Cert_Number                CONSTANT NUMBER := 281;
    c_Pt_Cert_Tp                    CONSTANT NUMBER := 283;
    c_Pt_Cert_Role                  CONSTANT NUMBER := 282;
    c_Pt_Start_Dt                   CONSTANT NUMBER := 90;
    c_Pt_Stop_Dt                    CONSTANT NUMBER := 83;
    c_Pt_Unique_Num                 CONSTANT NUMBER := 462;

    c_Cert_Tp_Birth                 CONSTANT NUMBER := 1;
    c_Cert_Tp_Death                 CONSTANT NUMBER := 2;
    c_Cert_Tp_Change_Name           CONSTANT NUMBER := 3;
    c_Cert_Tp_Marriage              CONSTANT NUMBER := 4;
    c_Cert_Tp_Divorce               CONSTANT NUMBER := 5;

    c_Cert_Role_Child               CONSTANT NUMBER := 1;
    c_Cert_Role_Name_Changer        CONSTANT NUMBER := 7;
    c_Cert_Role_Dead                CONSTANT NUMBER := 4;
    c_Cert_Role_Marriage_Housband   CONSTANT NUMBER := 3;
    c_Cert_Role_Marriage_Wife       CONSTANT NUMBER := 2;
    c_Cert_Role_Divorce_Housband    CONSTANT NUMBER := 5;
    c_Cert_Role_Divorce_Wife        CONSTANT NUMBER := 6;

    c_Nsp_Mju_Data_Ndt_Id           CONSTANT NUMBER := 700;

    TYPE r_Birth_Certificate IS RECORD
    (
        Cert_Serial          VARCHAR2 (10),
        Cert_Number          VARCHAR2 (50),
        Cert_Date            DATE,
        Cert_Org             VARCHAR2 (4000),
        Child_Surname        VARCHAR2 (100),
        Child_Name           VARCHAR2 (100),
        Child_Patronymic     VARCHAR2 (100),
        Child_Birthdate      DATE,
        Father_Surname       VARCHAR2 (100),
        Father_Name          VARCHAR2 (100),
        Father_Patronymic    VARCHAR2 (100),
        Mother_Surname       VARCHAR2 (100),
        Mother_Name          VARCHAR2 (100),
        Mother_Patronymic    VARCHAR2 (100),
        Ar_Numb              VARCHAR2 (200),
        Ar_Composedate       VARCHAR2 (200)
    );

    TYPE t_Birth_Cert_List IS TABLE OF r_Birth_Certificate;

    TYPE r_Death_Cert IS RECORD
    (
        Cert_Serial    VARCHAR2 (10),
        Cert_Number    VARCHAR2 (20),
        Cert_Org       VARCHAR2 (4000),
        Cert_Date      VARCHAR2 (200)
    );

    TYPE t_Death_Cert_List IS TABLE OF r_Death_Cert;

    TYPE r_Death_Act_Record IS RECORD
    (
        Ar_Reg_Number    VARCHAR2 (20),
        Reg_Numb         VARCHAR2 (20),
        Ar_Reg_Date      DATE,
        Date_Death       VARCHAR2 (200),
        Certificates     t_Death_Cert_List
    );

    TYPE t_Death_Act_Record_List IS TABLE OF r_Death_Act_Record;

    TYPE r_Act_Record_Cert IS RECORD
    (
        Cert_Status           NUMBER,
        Cert_Serial           VARCHAR2 (10),
        Cert_Number           VARCHAR2 (11),
        Cert_Serial_Number    VARCHAR2 (21),
        Cert_Org              VARCHAR2 (240),
        Cert_Date             VARCHAR2 (10),
        Surname               VARCHAR2 (54),
        NAME                  VARCHAR2 (54),
        Patronymic            VARCHAR2 (54)
    );

    TYPE r_Act_Record_Cert_List IS TABLE OF r_Act_Record_Cert;

    TYPE r_Birth_Act_Record IS RECORD
    (
        Ar_Reg_Date          DATE,
        Ar_Reg_Number        VARCHAR2 (20),
        Op_Date              DATE,
        Ar_Op_Name           VARCHAR2 (2),
        Reg_Numb             VARCHAR2 (40),
        Child_Surname        VARCHAR2 (54),
        Child_Name           VARCHAR2 (54),
        Child_Patronymic     VARCHAR2 (54),
        Child_Numident       VARCHAR2 (10),
        Child_Date_Birth     VARCHAR2 (10),
        Father_Surname       VARCHAR2 (54),
        Father_Name          VARCHAR2 (54),
        Father_Patronymic    VARCHAR2 (54),
        Father_Numident      VARCHAR2 (10),
        Mother_Surname       VARCHAR2 (54),
        Mother_Name          VARCHAR2 (54),
        Mother_Patronymic    VARCHAR2 (54),
        Mother_Numident      VARCHAR2 (10),
        Certificates         r_Act_Record_Cert_List
    );

    TYPE t_Birth_Act_Record_List IS TABLE OF r_Birth_Act_Record;

    TYPE r_Change_Name_Act_Record IS RECORD
    (
        Ar_Reg_Date           DATE,
        Ar_Reg_Number         VARCHAR2 (20),
        Op_Date               DATE,
        Ar_Op_Name            VARCHAR2 (2),
        Ar_Verification_St    NUMBER,
        Reg_Numb              VARCHAR2 (40),
        Old_Surname           VARCHAR2 (54),
        Old_Name              VARCHAR2 (54),
        Old_Patronymic        VARCHAR2 (54),
        Surname               VARCHAR2 (54),
        NAME                  VARCHAR2 (54),
        Patronymic            VARCHAR2 (54),
        Numident              VARCHAR2 (10),
        Date_Birth            VARCHAR2 (10),
        Doc_Type              VARCHAR2 (2),
        Series_Numb           VARCHAR2 (50),
        Certificates          r_Act_Record_Cert_List
    );

    TYPE t_Change_Name_Act_Record_List IS TABLE OF r_Change_Name_Act_Record;

    TYPE r_Merriage_Act_Record IS RECORD
    (
        Ar_Reg_Date            DATE,
        Ar_Reg_Number          VARCHAR2 (20),
        Op_Date                DATE,
        Ar_Op_Name             VARCHAR2 (2),
        Ar_Verification_St     NUMBER,
        Reg_Numb               VARCHAR2 (40),
        Reg_Numb_Link          VARCHAR2 (40),
        Сompose_Date_Link     VARCHAR2 (10),
        Compose_Org_Link       VARCHAR2 (240),
        Husband_Old_Surname    VARCHAR2 (54),
        Husband_Surname        VARCHAR2 (54),
        Husband_Name           VARCHAR2 (54),
        Husband_Patronymic     VARCHAR2 (54),
        Husband_Numident       VARCHAR2 (10),
        Husband_Date_Birth     VARCHAR2 (10),
        Wife_Old_Surname       VARCHAR2 (54),
        Wife_Surname           VARCHAR2 (54),
        Wife_Name              VARCHAR2 (54),
        Wife_Patronymic        VARCHAR2 (54),
        Wife_Numident          VARCHAR2 (10),
        Wife_Date_Birth        VARCHAR2 (10),
        Certificates           r_Act_Record_Cert_List
    );

    TYPE t_Merriage_Act_Record_List IS TABLE OF r_Merriage_Act_Record;

    TYPE r_Divorce_Act_Record IS RECORD
    (
        Ar_Reg_Date           DATE,
        Ar_Reg_Number         VARCHAR2 (20),
        Op_Date               DATE,
        Ar_Op_Name            VARCHAR2 (2),
        Reg_Numb              VARCHAR2 (40),
        Ar_Verification_St    NUMBER,
        Reason_Divorce        VARCHAR2 (240),
        Mn_Old_Surname        VARCHAR2 (54),
        Mn_Surname            VARCHAR2 (54),
        Mn_Name               VARCHAR2 (54),
        Mn_Patronymic         VARCHAR2 (54),
        Mn_Numident           VARCHAR2 (10),
        Mn_Date_Birth         VARCHAR2 (10),
        Wmn_Old_Surname       VARCHAR2 (54),
        Wmn_Surname           VARCHAR2 (54),
        Wmn_Name              VARCHAR2 (54),
        Wmn_Patronymic        VARCHAR2 (54),
        Wmn_Numident          VARCHAR2 (10),
        Wmn_Date_Birth        VARCHAR2 (10),
        Certificates          r_Act_Record_Cert_List
    );

    TYPE t_Divorce_Act_Record_List IS TABLE OF r_Divorce_Act_Record;

    TYPE t_Nsp_Edr_Main_Data_Record IS RECORD
    (
        Id                        NUMBER,
        --nda_id = 8370 «Статус юридичної особи»
        State                     NUMBER,
        State_Text                VARCHAR2 (250),
        --nda_id = 958 «Організаційно-правова форма»
        Olf_Name                  VARCHAR2 (250),
        Olf_Code                  VARCHAR2 (250),
        --nda_id = 956 «Повне найменування юридичної особи (згідно ЄДР)»
        Names_Name                VARCHAR2 (250),
        --nda_id = 957 «Скорочене найменування юридичної особи (згідно ЄДР)»
        Names_Short               VARCHAR2 (250),
        --nda_id = 972 «індекс» - адреси реєстрації
        Address_Zip               VARCHAR2 (250),
        --nda_id = 974 «населений пункт»
        Address_Parts_Atu         VARCHAR2 (250),
        --nda_id = 2159 «вулиця (ручне введення у випадку відсутності в довіднику)»
        Address_Parts_Street      VARCHAR2 (250),
        --nda_id = 976 «будинок»
        Address_Parts_House       VARCHAR2 (250),
        --nda_id = 977 «корпус»
        Address_Parts_Building    VARCHAR2 (250),
        --nda_id = 978 «офіс/квартира/приміщення (зазначити тільки №)»
        Address_Parts_Num         VARCHAR2 (250),
        --nda_id = 1485 «примітки щодо типу приміщення»
        Address_Parts_Num_Type    VARCHAR2 (250),
        Code                      VARCHAR2 (250),
        --nda_id = 1094 «Посада керівника юридичної особи»
        Head_Position             VARCHAR2 (250),
        --nda_id = 1095 «Прізвище керівника юридичної особи»
        Head_Ln                   VARCHAR2 (250),
        --nda_id = 1096 «Ім’я керівника юридичної особи»
        Head_Fn                   VARCHAR2 (250),
        --nda_id = 1097 «По батькові керівника юридичної особи»
        Head_Mn                   VARCHAR2 (250),
        -- nda_id = 963 «Прізвище»
        Fop_Ln                    VARCHAR2 (250),
        --nda_id = 964 «Ім’я»
        Fop_Fn                    VARCHAR2 (250),
        -- nda_id = 965 «По батькові»
        Fop_Mn                    VARCHAR2 (250)
    );

    TYPE t_Nsp_Edr_Main_Data_List IS TABLE OF t_Nsp_Edr_Main_Data_Record;

    --METHODS
    FUNCTION Get_Word_Number (p_Str        IN VARCHAR2,
                              p_Row        IN NUMBER,
                              p_Splitter   IN VARCHAR2 DEFAULT '#')
        RETURN VARCHAR2;

    PROCEDURE Reg_Birth_Ar_By_Child_Name_And_Birth_Date_Req (
        p_Sc_Id              IN     NUMBER,
        p_Child_Birth_Dt     IN     DATE,
        p_Child_Surname      IN     VARCHAR2,
        p_Child_Name         IN     VARCHAR2,
        p_Child_Patronymic   IN     VARCHAR2,
        p_Rn_Nrt             IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins          IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src             IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id                 OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Birth_Ar_By_Child_Name_And_Birth_Date_Data (
        p_Ur_Id   IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Death_Ar_By_Full_Name_And_Birth_Date_Req (
        p_Sc_Id        IN     NUMBER,
        p_Birth_Dt     IN     DATE,
        p_Surname      IN     VARCHAR2,
        p_Name         IN     VARCHAR2,
        p_Patronymic   IN     VARCHAR2,
        p_Rn_Nrt       IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins    IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Death_Ar_By_Full_Name_And_Birth_Date_Data (
        p_Ur_Id   IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Get_Cert_By_Num_Role_Birth_Date_Req (
        p_Cert_Tp       IN     NUMBER,
        p_Cert_Role     IN     NUMBER,
        p_Cert_Serial   IN     VARCHAR2,
        p_Cert_Number   IN     VARCHAR2,
        p_Date_Birth    IN     DATE,
        p_Sc_Id         IN     NUMBER,
        p_Rn_Nrt        IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins     IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id            OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Get_Cert_By_Num_Role_Birth_Date_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Get_Cert_By_Num_Role_Names_Req (
        p_Cert_Tp       IN     NUMBER,
        p_Cert_Role     IN     NUMBER,
        p_Cert_Serial   IN     VARCHAR2,
        p_Cert_Number   IN     VARCHAR2,
        p_Surname       IN     VARCHAR2,
        p_Name          IN     VARCHAR2,
        p_Patronymic    IN     VARCHAR2,
        p_Sc_Id         IN     NUMBER,
        p_Rn_Nrt        IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins     IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id            OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Get_Cert_By_Num_Role_Names_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Reg_Nsp_Mju_Data_Link_Req (
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Numident    IN     VARCHAR2,
        p_Fn          IN     VARCHAR2,
        p_Doc_Ser     IN     VARCHAR2,
        p_Doc_Num     IN     VARCHAR2);

    PROCEDURE Reg_Nsp_Mju_Data_Req (
        p_Url_Parent   IN     Uxp_Req_Links.Url_Parent%TYPE,
        p_Rn_Nrt       IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins    IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE,
        p_Edr_Id       IN     VARCHAR2);

    PROCEDURE Reg_Nsp_Mju_Sharing_Data_Req (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Numident    IN     VARCHAR2,
        p_Wu_Id       IN     NUMBER DEFAULT NULL);

    PROCEDURE Parse_Nsp_Edr_Resp (
        p_Response                 IN     CLOB,
        p_Nsp_Edr_Main_Data_List      OUT t_Nsp_Edr_Main_Data_List);

    FUNCTION Get_Nsp_Mju_Data_Link (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Get_Nsp_Mju_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Get_Nsp_Mju_Sharing_Response (
        p_Rn_Id                    IN     NUMBER,
        p_Nsp_Edr_Main_Data_List      OUT t_Nsp_Edr_Main_Data_List);

    FUNCTION Parse_Birth_Cert_Resp (p_Response          CLOB,
                                    p_Resutl_Code   OUT NUMBER,
                                    p_Error_Info    OUT VARCHAR2)
        RETURN t_Birth_Cert_List;

    FUNCTION Parse_Death_Ar_Resp (p_Response          CLOB,
                                  p_Resutl_Code   OUT NUMBER,
                                  p_Error_Info    OUT VARCHAR2)
        RETURN t_Death_Act_Record_List;

    PROCEDURE Reg_Death_Delta_Init_Req (
        p_Start_Dt    IN     DATE,
        p_Stop_Dt     IN     DATE,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Delta_Init_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Parse_Death_Delta_Init_Resp (p_Response   IN     CLOB,
                                           p_Order_Id      OUT NUMBER);

    PROCEDURE Reg_Death_Delta_Req (
        p_Parent_Ur   IN     NUMBER,
        p_Order_Id    IN     NUMBER,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Delta_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Parse_Death_Delta_Resp (p_Response   IN     CLOB,
                                      p_Result        OUT NUMBER);

    PROCEDURE Parse_Death_Delta_Resp (p_Response       IN OUT NOCOPY CLOB,
                                      p_Died_Persons      OUT NOCOPY CLOB);

    PROCEDURE Reg_Ar_By_Name_And_Birth_Date_Req (
        p_Sc_Id        IN     NUMBER,
        p_Birth_Dt     IN     DATE,
        p_Surname      IN     VARCHAR2,
        p_Name         IN     VARCHAR2,
        p_Patronymic   IN     VARCHAR2,
        p_Rn_Nrt       IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins    IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE);

    PROCEDURE Reg_Ar_By_Rnokpp_Req (
        p_Sc_Id       IN     NUMBER,
        p_Inn         IN     VARCHAR2,
        p_Role        IN     VARCHAR2,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Ar_By_Rnokpp_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Get_Marriage_Divorce_Ar_By_Wife_Name_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Get_Marriage_Divorce_Ar_By_Husband_Name_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Birth_Ar_Resp (p_Response          CLOB,
                                  p_Resutl_Code   OUT NUMBER,
                                  p_Error_Info    OUT VARCHAR2)
        RETURN t_Birth_Act_Record_List;

    FUNCTION Parse_Change_Name_Ar_Resp (p_Response          CLOB,
                                        p_Resutl_Code   OUT NUMBER,
                                        p_Error_Info    OUT VARCHAR2)
        RETURN t_Change_Name_Act_Record_List;

    FUNCTION Parse_Merriage_Ar_Resp (p_Response          CLOB,
                                     p_Resutl_Code   OUT NUMBER,
                                     p_Error_Info    OUT VARCHAR2)
        RETURN t_Merriage_Act_Record_List;

    FUNCTION Parse_Divorce_Ar_Resp (p_Response          CLOB,
                                    p_Resutl_Code   OUT NUMBER,
                                    p_Error_Info    OUT VARCHAR2)
        RETURN t_Divorce_Act_Record_List;
END Api$request_Mju;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MJU TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MJU TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MJU TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MJU TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MJU TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MJU TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MJU TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MJU TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_MJU
IS
    ---
    --- Отримання слова з рядка за номером
    ---
    FUNCTION Get_Word_Number (p_Str        IN VARCHAR2,
                              p_Row        IN NUMBER,
                              p_Splitter   IN VARCHAR2 DEFAULT '#')
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (250);
    BEGIN
        SELECT String_Parts
          INTO l_Res
          FROM (SELECT ROWNUM Rn, String_Parts
                  FROM (    SELECT REGEXP_SUBSTR (p_Str,
                                                  '[^' || p_Splitter || ']+',
                                                  1,
                                                  LEVEL)    AS String_Parts
                              FROM DUAL
                        CONNECT BY REGEXP_SUBSTR (p_Str,
                                                  '[^' || p_Splitter || ']+',
                                                  1,
                                                  LEVEL)
                                       IS NOT NULL))
         WHERE Rn = p_Row;

        RETURN l_Res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    ----------------------------------------------------------------------
    --    Реєстрація запиту до НАІСу для отримання даних
    --  АЗ про народження за ПІБ та датою народження дитини
    ----------------------------------------------------------------------
    PROCEDURE Reg_Birth_Ar_By_Child_Name_And_Birth_Date_Req (
        p_Sc_Id              IN     NUMBER,
        p_Child_Birth_Dt     IN     DATE,
        p_Child_Surname      IN     VARCHAR2,
        p_Child_Name         IN     VARCHAR2,
        p_Child_Patronymic   IN     VARCHAR2,
        p_Rn_Nrt             IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins          IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src             IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id                 OUT Request_Journal.Rn_Id%TYPE)
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
                                    p_Rnp_Inn          => NULL,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (
            p_Rnpi_Id    => NULL,
            p_Rnpi_Rnp   => l_Rnp_Id,
            p_Rnpi_Rn    => p_Rn_Id,
            p_Rnpi_Fn    => p_Child_Name,
            p_Rnpi_Ln    => p_Child_Surname,
            p_Rnpi_Mn    => p_Child_Patronymic,
            p_New_Id     => l_Rnpi_Id);

        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Child_Birth_Dt);
    END;

    ----------------------------------------------------------------------
    --        Отримання даних для запиту
    -- "отримання АЗ про народження за ПІБ та датою народження дитини"
    ----------------------------------------------------------------------
    FUNCTION Get_Birth_Ar_By_Child_Name_And_Birth_Date_Data (
        p_Ur_Id   IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn             NUMBER;
        l_Child_Birth_Dt    DATE;
        l_Request_Payload   XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Child_Birth_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Birth_Dt);

        SELECT XMLELEMENT (
                   "ArBirthServiceRequest",
                   XMLELEMENT ("ChildBirthDate",
                               TO_CHAR (l_Child_Birth_Dt, 'yyyy-mm-dd')),
                   XMLELEMENT ("ChildName", i.Rnpi_Fn),
                   XMLELEMENT ("ChildPatronymic", i.Rnpi_Mn),
                   XMLELEMENT ("ChildSurname", i.Rnpi_Ln))
          INTO l_Request_Payload
          FROM Rn_Person p JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE p.Rnp_Rn = l_Ur_Rn;

        RETURN l_Request_Payload.Getclobval;
    END;

    ----------------------------------------------------------------------
    --     Реєстрація запиту до НАІСу для
    -- отримання даних АЗ про смерть за ПІБ та датою народження
    ----------------------------------------------------------------------
    PROCEDURE Reg_Death_Ar_By_Full_Name_And_Birth_Date_Req (
        p_Sc_Id        IN     NUMBER,
        p_Birth_Dt     IN     DATE,
        p_Surname      IN     VARCHAR2,
        p_Name         IN     VARCHAR2,
        p_Patronymic   IN     VARCHAR2,
        p_Rn_Nrt       IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins    IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE)
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
                                    p_Rnp_Inn          => NULL,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_Name,
                                            p_Rnpi_Ln    => p_Surname,
                                            p_Rnpi_Mn    => p_Patronymic,
                                            p_New_Id     => l_Rnpi_Id);

        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Birth_Dt);
    END;

    ----------------------------------------------------------------------
    --     Отримання даних для запиту
    -- "отримання даних АЗ про смерть за ПІБ та датою народження"
    ----------------------------------------------------------------------
    FUNCTION Get_Death_Ar_By_Full_Name_And_Birth_Date_Data (
        p_Ur_Id   IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn             NUMBER;
        l_Birth_Dt          DATE;
        l_Request_Payload   XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Birth_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Birth_Dt);

        SELECT XMLELEMENT (
                   "ArServiceRequest",
                   XMLELEMENT ("Name", i.Rnpi_Fn),
                   XMLELEMENT ("OnDate", TO_CHAR (l_Birth_Dt, 'yyyy-mm-dd')),
                   XMLELEMENT ("Patronymic", i.Rnpi_Mn),
                   XMLELEMENT ("Surname", i.Rnpi_Ln))
          INTO l_Request_Payload
          FROM Rn_Person p JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE p.Rnp_Rn = l_Ur_Rn;

        RETURN l_Request_Payload.Getclobval;
    END;

    ----------------------------------------------------------------------
    --     Реєстрація запиту на отримання свідоцтва
    -- за номером та датою народження
    ----------------------------------------------------------------------
    PROCEDURE Reg_Get_Cert_By_Num_Role_Birth_Date_Req (
        p_Cert_Tp       IN     NUMBER,
        p_Cert_Role     IN     NUMBER,
        p_Cert_Serial   IN     VARCHAR2,
        p_Cert_Number   IN     VARCHAR2,
        p_Date_Birth    IN     DATE,
        p_Sc_Id         IN     NUMBER,
        p_Rn_Nrt        IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins     IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id            OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id    NUMBER;
        l_Rnp_Id   NUMBER;
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
                                    p_Rnp_Inn          => NULL,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);
        --Зберігаємо тип свідоцтва
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Cert_Tp,
                                         p_Rnc_Val_String   => p_Cert_Tp);
        --Зберігаємо роль свідоцтва
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Cert_Role,
                                         p_Rnc_Val_String   => p_Cert_Role);
        --Зберігаємо серію свідоцтва
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Cert_Serial,
                                         p_Rnc_Val_String   => p_Cert_Serial);
        --Зберігаємо номер свідоцтва
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Cert_Number,
                                         p_Rnc_Val_String   => p_Cert_Number);
        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Date_Birth);
    END;

    ----------------------------------------------------------------------
    --     Отримання даних для запиту на отримання свідоцтва
    -- за номером та датою народження
    ----------------------------------------------------------------------
    FUNCTION Get_Get_Cert_By_Num_Role_Birth_Date_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn             NUMBER;
        l_Date_Birth        DATE;
        l_Request_Payload   XMLTYPE;
        l_Cert_Tp           NUMBER;
        l_Cert_Role         NUMBER;
        l_Cert_Serial       VARCHAR2 (10);
        l_Cert_Number       VARCHAR2 (50);
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Date_Birth :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Birth_Dt);
        l_Cert_Tp :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Ur_Rn,
                                                   p_Rnc_Pt   => c_Pt_Cert_Tp);
        l_Cert_Role :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Cert_Role);
        l_Cert_Serial :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Cert_Serial);
        l_Cert_Number :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Cert_Number);

        SELECT XMLELEMENT (
                   "CeServiceRequest",
                   XMLELEMENT ("ByParam", l_Cert_Tp),
                   XMLELEMENT ("Role", l_Cert_Role),
                   XMLELEMENT ("DateBirth",
                               TO_CHAR (l_Date_Birth, 'yyyy-mm-dd')),
                   XMLELEMENT ("CertSerial", l_Cert_Serial),
                   XMLELEMENT ("CertNumber", l_Cert_Number))
          INTO l_Request_Payload
          FROM DUAL;

        RETURN l_Request_Payload.Getclobval;
    END;

    ----------------------------------------------------------------------
    --     Реєстрація запиту на отримання свідоцтва
    -- за номером та ПІБ
    ----------------------------------------------------------------------
    PROCEDURE Reg_Get_Cert_By_Num_Role_Names_Req (
        p_Cert_Tp       IN     NUMBER,
        p_Cert_Role     IN     NUMBER,
        p_Cert_Serial   IN     VARCHAR2,
        p_Cert_Number   IN     VARCHAR2,
        p_Surname       IN     VARCHAR2,
        p_Name          IN     VARCHAR2,
        p_Patronymic    IN     VARCHAR2,
        p_Sc_Id         IN     NUMBER,
        p_Rn_Nrt        IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins     IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src        IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id            OUT Request_Journal.Rn_Id%TYPE)
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
                                    p_Rnp_Inn          => NULL,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_Name,
                                            p_Rnpi_Ln    => p_Surname,
                                            p_Rnpi_Mn    => p_Patronymic,
                                            p_New_Id     => l_Rnpi_Id);

        --Зберігаємо тип свідоцтва
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Cert_Tp,
                                         p_Rnc_Val_String   => p_Cert_Tp);
        --Зберігаємо роль свідоцтва
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Cert_Role,
                                         p_Rnc_Val_String   => p_Cert_Role);
        --Зберігаємо серію свідоцтва
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Cert_Serial,
                                         p_Rnc_Val_String   => p_Cert_Serial);
        --Зберігаємо номер свідоцтва
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Cert_Number,
                                         p_Rnc_Val_String   => p_Cert_Number);
    END;

    --------------------------------------------------------------------
    --  Реєстрація запиту до МЮУ для отримання даних з ЄДР
    --------------------------------------------------------------------
    PROCEDURE Reg_Nsp_Mju_Data_Link_Req (
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Numident    IN     VARCHAR2,
        p_Fn          IN     VARCHAR2,
        p_Doc_Ser     IN     VARCHAR2,
        p_Doc_Num     IN     VARCHAR2)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
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

        Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                    p_Rnp_Rn           => p_Rn_Id,
                                    p_Rnp_Sc           => NULL,
                                    p_Rnp_Inn          => p_Numident,
                                    p_Rnp_Ndt          => c_Nsp_Mju_Data_Ndt_Id,
                                    p_Rnp_Doc_Seria    => p_Doc_Ser,
                                    p_Rnp_Doc_Number   => p_Doc_Num,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_Fn,
                                            p_Rnpi_Ln    => NULL,
                                            p_Rnpi_Mn    => NULL,
                                            p_New_Id     => l_Rnpi_Id);
    END;

    PROCEDURE Reg_Nsp_Mju_Data_Req (
        p_Url_Parent   IN     Uxp_Req_Links.Url_Parent%TYPE,
        p_Rn_Nrt       IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins    IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE,
        p_Edr_Id       IN     VARCHAR2)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => SYSDATE,
                                              p_Ur_Urt         => 80,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => NULL,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        Api$uxp_Request.Save_Request_Link (p_Url_Ur       => l_Ur_Id,
                                           p_Url_Root     => p_Url_Parent,
                                           p_Url_Parent   => p_Url_Parent);

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Unique_Num,
                                         p_Rnc_Val_String   => p_Edr_Id);
    END;


    PROCEDURE Reg_Nsp_Mju_Sharing_Data_Req (
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE,
        p_Numident    IN     VARCHAR2,
        p_Wu_Id       IN     NUMBER DEFAULT NULL)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => TRUNC (SYSDATE) - 1,
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
                                         p_Rnc_Val_String   => p_Numident);
    END;

    PROCEDURE Get_Nsp_Mju_Sharing_Response (
        p_Rn_Id                    IN     NUMBER,
        p_Nsp_Edr_Main_Data_List      OUT t_Nsp_Edr_Main_Data_List)
    IS
        l_Resp    CLOB;
        l_Rn_St   VARCHAR2 (10);
    BEGIN
        SELECT Ur_Soap_Resp
          INTO l_Resp
          FROM (SELECT Ur2.Ur_Id,
                       Ur2.Ur_Soap_Resp,
                       MAX (Ur2.Ur_Id) OVER ()     Max_Ur_Id
                  FROM Uxp_Req_Links  Pl
                       JOIN Uxp_Request Ur ON Ur.Ur_Id = Pl.Url_Root
                       JOIN Uxp_Request Ur2 ON Pl.Url_Ur = Ur2.Ur_Id
                 WHERE Ur.Ur_Rn = p_Rn_Id)
         WHERE Ur_Id = Max_Ur_Id;

        Parse_Nsp_Edr_Resp (
            p_Response                 => l_Resp,
            p_Nsp_Edr_Main_Data_List   => p_Nsp_Edr_Main_Data_List);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            SELECT Rj.Rn_St
              INTO l_Rn_St
              FROM Request_Journal Rj
             WHERE Rj.Rn_Id = p_Rn_Id;

            IF TRIM (UPPER (l_Rn_St)) =
               TRIM (UPPER (Api$uxp_Request.c_Ur_St_Ok))
            THEN
                Raise_Application_Error (
                    -20000,
                       'По введеному Коду немає даних в ЄДР. Запит ['
                    || p_Rn_Id
                    || ']');
            ELSIF TRIM (UPPER (l_Rn_St)) =
                  TRIM (UPPER (Api$uxp_Request.c_Ur_St_Err))
            THEN
                Raise_Application_Error (
                    -20000,
                       'При обробці запита ['
                    || p_Rn_Id
                    || '] до ЄДР виникла помилка');
            ELSE
                --Raise_application_error(-20000, 'Запит ще в обробці');
                NULL;
            END IF;
    END;

    ----------------------------------------------------------------------
    --     Отримання даних для запиту на отримання свідоцтва
    -- за номером та ПІБ
    ----------------------------------------------------------------------
    FUNCTION Get_Get_Cert_By_Num_Role_Names_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn             NUMBER;
        l_Request_Payload   XMLTYPE;
        l_Cert_Tp           NUMBER;
        l_Cert_Role         NUMBER;
        l_Cert_Serial       VARCHAR2 (10);
        l_Cert_Number       VARCHAR2 (50);
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Cert_Tp :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Ur_Rn,
                                                   p_Rnc_Pt   => c_Pt_Cert_Tp);
        l_Cert_Role :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Cert_Role);
        l_Cert_Serial :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Cert_Serial);
        l_Cert_Number :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Cert_Number);

        SELECT XMLELEMENT ("CeServiceRequest",
                           XMLELEMENT ("ByParam", l_Cert_Tp),
                           XMLELEMENT ("Role", l_Cert_Role),
                           XMLELEMENT ("CertSerial", l_Cert_Serial),
                           XMLELEMENT ("CertNumber", l_Cert_Number),
                           XMLELEMENT ("Name", i.Rnpi_Fn),
                           XMLELEMENT ("Patronymic", i.Rnpi_Mn),
                           XMLELEMENT ("Surname", i.Rnpi_Ln))
          INTO l_Request_Payload
          FROM Rn_Person p JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE p.Rnp_Rn = l_Ur_Rn;

        RETURN l_Request_Payload.Getclobval;
    END;

    ----------------------------------------------------------------------
    --     Отримання даних для запиту на веріфікацію НСП у МЮУ
    ----------------------------------------------------------------------
    FUNCTION Get_Nsp_Mju_Data_Link (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Req   CLOB;
    BEGIN
        SELECT 'code=' || NVL (p.Rnp_Inn, i.Rnc_Val_String)     Request_Data
          INTO l_Req
          FROM Ikis_Rbm.Uxp_Request  r
               LEFT OUTER JOIN Ikis_Rbm.Rn_Person p ON r.Ur_Rn = p.Rnp_Rn
               LEFT OUTER JOIN Ikis_Rbm.Rn_Common_Info i
                   ON r.Ur_Rn = i.Rnc_Rn AND i.Rnc_Pt = c_Pt_Rnokpp
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Req;
    END;

    FUNCTION Get_Nsp_Mju_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Req   CLOB;
    BEGIN
        SELECT '/' || NVL (p.Rnp_Inn, i.Rnc_Val_String)     Request_Data
          INTO l_Req
          FROM Ikis_Rbm.Uxp_Request  r
               LEFT OUTER JOIN Ikis_Rbm.Rn_Person p ON r.Ur_Rn = p.Rnp_Rn
               LEFT OUTER JOIN Ikis_Rbm.Rn_Common_Info i
                   ON r.Ur_Rn = i.Rnc_Rn AND i.Rnc_Pt = c_Pt_Unique_Num
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Req;
    END;


    ----------------------------------------------------------------------
    --     Парсинг відповіді на запит свідоцтва
    ----------------------------------------------------------------------
    PROCEDURE Parse_Cert_Resp (p_Response      IN     CLOB,
                               p_Result_Data      OUT CLOB,
                               p_Resutl_Code      OUT NUMBER,
                               p_Error_Info       OUT VARCHAR2)
    IS
    BEGIN
                SELECT Ikis_Rbm.Tools.B64_Decode (Resp_Json, 'UTF8'),
                       Result_Code,
                       Error_Info
                  INTO p_Result_Data, p_Resutl_Code, p_Error_Info
                  FROM XMLTABLE (
                           Xmlnamespaces (DEFAULT 'http://tempuri.org/'),
                           '/*'
                           PASSING Xmltype (p_Response)
                           COLUMNS Resp_Json      CLOB PATH 'ResultData',
                                   Result_Code    NUMBER PATH 'ResultCode',
                                   Error_Info     VARCHAR2 (4000) PATH 'ErrorInfo');
    END;

    ----------------------------------------------------------------------
    --     Парсинг відповіді на запит свідоцтва про народження
    ----------------------------------------------------------------------
    FUNCTION Parse_Birth_Cert_Resp (p_Response          CLOB,
                                    p_Resutl_Code   OUT NUMBER,
                                    p_Error_Info    OUT VARCHAR2)
        RETURN t_Birth_Cert_List
    IS
        l_Cert_List     t_Birth_Cert_List;
        l_Result_Data   CLOB;
    BEGIN
        Parse_Cert_Resp (p_Response      => p_Response,
                         p_Result_Data   => l_Result_Data,
                         p_Resutl_Code   => p_Resutl_Code,
                         p_Error_Info    => p_Error_Info);

        IF     l_Result_Data IS NOT NULL
           AND DBMS_LOB.Getlength (l_Result_Data) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'T_BIRTH_CERT_LIST',
                                             'dd.mm.yyyy')
                USING IN l_Result_Data, OUT l_Cert_List;

            RETURN l_Cert_List;
        ELSE
            RETURN NULL;
        END IF;
    END;

    ----------------------------------------------------------------------
    --     Парсинг відповіді на запит актових записів про смерть
    ----------------------------------------------------------------------
    FUNCTION Parse_Death_Ar_Resp (p_Response          CLOB,
                                  p_Resutl_Code   OUT NUMBER,
                                  p_Error_Info    OUT VARCHAR2)
        RETURN t_Death_Act_Record_List
    IS
        l_Ar_List       t_Death_Act_Record_List;
        l_Result_Data   CLOB;
    BEGIN
        Parse_Cert_Resp (p_Response      => p_Response,
                         p_Result_Data   => l_Result_Data,
                         p_Resutl_Code   => p_Resutl_Code,
                         p_Error_Info    => p_Error_Info);

        IF     l_Result_Data IS NOT NULL
           AND DBMS_LOB.Getlength (l_Result_Data) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'T_DEATH_ACT_RECORD_LIST',
                                             'yyyy-mm-dd"T"hh24:mi:ss')
                USING IN l_Result_Data, OUT l_Ar_List;

            RETURN l_Ar_List;
        ELSE
            RETURN NULL;
        END IF;
    END;

    ----------------------------------------------------------------------
    --    Реєстрація запиту на отримання АЗ про смерть за період
    --                        (ініціалізація)
    ----------------------------------------------------------------------
    PROCEDURE Reg_Death_Delta_Init_Req (
        p_Start_Dt    IN     DATE,
        p_Stop_Dt     IN     DATE,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
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
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Stop_Dt,
                                         p_Rnc_Val_Dt   => p_Stop_Dt);
    END;

    ----------------------------------------------------------------------
    --    Формування запиту на отримання АЗ про смерть за період
    --                        (ініціалізація)
    ----------------------------------------------------------------------
    FUNCTION Get_Delta_Init_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn    NUMBER;
        l_Result   XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        SELECT XMLELEMENT (
                   "DracPeriodInitRequest",
                   Xmlattributes ('http://tempuri.org/' AS "xmlns"),
                   XMLELEMENT (
                       "PeriodEnd",
                       TO_CHAR (
                           Api$request.Get_Rn_Common_Info_Dt (
                               p_Rnc_Rn   => l_Ur_Rn,
                               p_Rnc_Pt   => c_Pt_Stop_Dt),
                           'yyyy-mm-dd')),
                   XMLELEMENT (
                       "PeriodStart",
                       TO_CHAR (
                           Api$request.Get_Rn_Common_Info_Dt (
                               p_Rnc_Rn   => l_Ur_Rn,
                               p_Rnc_Pt   => c_Pt_Start_Dt),
                           'yyyy-mm-dd')))
          INTO l_Result
          FROM DUAL;

        RETURN l_Result.Getclobval;
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит на отримання АЗ про смерть за період
    --                        (ініціалізація)
    ----------------------------------------------------------------------
    PROCEDURE Parse_Death_Delta_Init_Resp (p_Response   IN     CLOB,
                                           p_Order_Id      OUT NUMBER)
    IS
    BEGIN
             SELECT Order_Id
               INTO p_Order_Id
               FROM XMLTABLE (Xmlnamespaces (DEFAULT 'http://tempuri.org/'),
                              '/*'
                              PASSING Xmltype (p_Response)
                              COLUMNS Order_Id    NUMBER PATH 'OrderId');
    END;

    ----------------------------------------------------------------------
    --    Реєстрація запиту на отримання АЗ про смерть за період
    --                      (отримання відповіді)
    ----------------------------------------------------------------------
    PROCEDURE Reg_Death_Delta_Req (
        p_Parent_Ur   IN     NUMBER,
        p_Order_Id    IN     NUMBER,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => p_Plan_Dt,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Order_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
                                              p_New_Rn_Id      => p_Rn_Id);

        Api$uxp_Request.Save_Request_Link (p_Url_Ur       => l_Ur_Id,
                                           p_Url_Root     => p_Parent_Ur,
                                           p_Url_Parent   => p_Parent_Ur);
    END;

    ----------------------------------------------------------------------
    --    Формування запиту на отримання АЗ про смерть за період
    --                        (отримання даних)
    ----------------------------------------------------------------------
    FUNCTION Get_Delta_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn    NUMBER;
        l_Result   XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        SELECT XMLELEMENT (
                   "DracPeriodDataRequest",
                   Xmlattributes ('http://tempuri.org/' AS "xmlns"),
                   XMLELEMENT ("OrderId",
                               Api$uxp_Request.Get_Request_Ext_Id (p_Ur_Id)))
          INTO l_Result
          FROM DUAL;

        RETURN l_Result.Getclobval;
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит на отримання АЗ про смерть за період
    --                     (отримання відповіді)
    ----------------------------------------------------------------------
    PROCEDURE Parse_Death_Delta_Resp (p_Response   IN     CLOB,
                                      p_Result        OUT NUMBER)
    IS
    BEGIN
        SELECT Res
          INTO p_Result
          FROM XMLTABLE (Xmlnamespaces (DEFAULT 'http://tempuri.org/'),
                         '/*'
                         PASSING Xmltype (p_Response)
                         COLUMNS Res    NUMBER PATH 'Result');
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит на отримання АЗ про смерть за період
    --                     (отримання відповіді)
    ----------------------------------------------------------------------
    PROCEDURE Parse_Death_Delta_Resp (p_Response       IN OUT NOCOPY CLOB,
                                      p_Died_Persons      OUT NOCOPY CLOB)
    IS
    BEGIN
                 SELECT Died_Persons
                   INTO p_Died_Persons
                   FROM XMLTABLE (Xmlnamespaces (DEFAULT 'http://tempuri.org/'),
                                  '/*'
                                  PASSING Xmltype (p_Response)
                                  COLUMNS Died_Persons    CLOB PATH 'DiedPerson');
    END;

    PROCEDURE Parse_Nsp_Edr_Resp (
        p_Response                 IN     CLOB,
        p_Nsp_Edr_Main_Data_List      OUT t_Nsp_Edr_Main_Data_List)
    IS
        l_Main_Row   t_Nsp_Edr_Main_Data_Record;
    BEGIN
        p_Nsp_Edr_Main_Data_List := t_Nsp_Edr_Main_Data_List ();

        FOR Cmain
            IN (SELECT *
                  FROM JSON_TABLE (
                           p_Response,
                           '$'
                           COLUMNS (
                               Id NUMBER PATH '$.id',
                               State NUMBER PATH '$.state',
                               State_Text VARCHAR2 (250) PATH '$.state_text',
                               Olf_Name VARCHAR2 (250) PATH '$.olf_name',
                               NESTED PATH '$.names[*]'
                                   COLUMNS (
                                       Names_Name
                                           VARCHAR (4000)
                                           PATH '$.name',
                                       Names_Short
                                           VARCHAR (4000)
                                           PATH '$.short'),
                               Address_Zip
                                   VARCHAR2 (250)
                                   PATH '$.address.zip',
                               Address_Parts_Atu
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.atu',
                               Address_Parts_Street
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.street',
                               Address_Parts_House
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.house',
                               Address_Parts_Building
                                   VARCHAR2 (250)
                                   PATH '$.address.parts. building',
                               Address_Parts_Num
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.num',
                               Address_Parts_Num_Type
                                   VARCHAR2 (250)
                                   PATH '$.address.parts.num_type',
                               Code VARCHAR2 (250) PATH '$.code',
                               Founders
                                   VARCHAR2 (4000)
                                   FORMAT JSON
                                   PATH '$.founders',
                               Heads
                                   VARCHAR2 (4000)
                                   FORMAT JSON
                                   PATH '$.heads')))
        LOOP
            l_Main_Row := NULL;
            l_Main_Row.Id := Cmain.Id;
            l_Main_Row.State := Cmain.State;
            l_Main_Row.State_Text := Cmain.State_Text;
            l_Main_Row.Olf_Name := Cmain.Olf_Name;

            BEGIN
                SELECT d.Dic_Value
                  INTO l_Main_Row.Olf_Code
                  FROM Uss_Ndi.v_Ddn_Forms_Mngm d
                 WHERE REPLACE (UPPER (d.Dic_Name), ' ', '') =
                       REPLACE (UPPER (l_Main_Row.Olf_Name), ' ', '');
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;
            END;

            l_Main_Row.Names_Name := Cmain.Names_Name;

            IF l_Main_Row.Olf_Name IS NULL
            THEN
                l_Main_Row.Fop_Ln :=
                    Api$request_Mju.Get_Word_Number (
                        REGEXP_REPLACE (Cmain.Names_Name, ' ', '#'),
                        1);
                l_Main_Row.Fop_Fn :=
                    Api$request_Mju.Get_Word_Number (
                        REGEXP_REPLACE (Cmain.Names_Name, ' ', '#'),
                        2);
                l_Main_Row.Fop_Mn :=
                    Api$request_Mju.Get_Word_Number (
                        REGEXP_REPLACE (Cmain.Names_Name, ' ', '#'),
                        3);
            END IF;

            l_Main_Row.Names_Short := Cmain.Names_Short;
            l_Main_Row.Address_Zip := Cmain.Address_Zip;
            l_Main_Row.Address_Parts_Atu := Cmain.Address_Parts_Atu;
            l_Main_Row.Address_Parts_Street := Cmain.Address_Parts_Street;
            l_Main_Row.Address_Parts_House := Cmain.Address_Parts_House;
            l_Main_Row.Address_Parts_Building := Cmain.Address_Parts_Building;
            l_Main_Row.Address_Parts_Num := Cmain.Address_Parts_Num;
            l_Main_Row.Address_Parts_Num_Type := Cmain.Address_Parts_Num_Type;
            l_Main_Row.Code := Cmain.Code;

            FOR Csecond
                IN (SELECT Role,
                           Role_Text,
                           Last_Name,
                           Position,
                           Api$request_Mju.Get_Word_Number (
                               REGEXP_REPLACE (First_Middle_Name,
                                               ' ',
                                               '#',
                                               1,
                                               1),
                               1)    First_Name,
                           Api$request_Mju.Get_Word_Number (
                               REGEXP_REPLACE (First_Middle_Name,
                                               ' ',
                                               '#',
                                               1,
                                               1),
                               2)    Middle_Name
                      FROM JSON_TABLE (
                               Cmain.Heads,
                               '$[*]'
                               COLUMNS (
                                   Role NUMBER PATH '$.role',
                                   Role_Text
                                       VARCHAR2 (250)
                                       PATH '$.role_text',
                                   Position VARCHAR2 (250) PATH '$.position',
                                   Last_Name
                                       VARCHAR2 (250)
                                       PATH '$.last_name',
                                   First_Middle_Name
                                       VARCHAR2 (250)
                                       PATH '$.first_middle_name'))
                     WHERE Role = 3 AND ROWNUM = 1)
            LOOP
                l_Main_Row.Head_Position :=
                    NVL (Csecond.Position, Csecond.Role_Text);
                l_Main_Row.Head_Ln := Csecond.Last_Name;
                l_Main_Row.Head_Fn := Csecond.First_Name;
                l_Main_Row.Head_Mn := Csecond.Middle_Name;
            END LOOP;

            p_Nsp_Edr_Main_Data_List.EXTEND (1);
            p_Nsp_Edr_Main_Data_List (p_Nsp_Edr_Main_Data_List.COUNT) :=
                l_Main_Row;
        END LOOP;
    END;

    ----------------------------------------------------------------------
    -- Реєстрація запиту до ДРАЦСу для отримання даних АЗ за ПІБ та датою народження
    ----------------------------------------------------------------------
    PROCEDURE Reg_Ar_By_Name_And_Birth_Date_Req (
        p_Sc_Id        IN     NUMBER,
        p_Birth_Dt     IN     DATE,
        p_Surname      IN     VARCHAR2,
        p_Name         IN     VARCHAR2,
        p_Patronymic   IN     VARCHAR2,
        p_Rn_Nrt       IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins    IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src       IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id           OUT Request_Journal.Rn_Id%TYPE)
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
                                    p_Rnp_Inn          => NULL,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        Api$request.Save_Rnp_Identity_Info (p_Rnpi_Id    => NULL,
                                            p_Rnpi_Rnp   => l_Rnp_Id,
                                            p_Rnpi_Rn    => p_Rn_Id,
                                            p_Rnpi_Fn    => p_Name,
                                            p_Rnpi_Ln    => p_Surname,
                                            p_Rnpi_Mn    => p_Patronymic,
                                            p_New_Id     => l_Rnpi_Id);

        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Birth_Dt);
    END;

    ----------------------------------------------------------------------
    -- Реєстрація запиту до ДРАЦСу для отримання даних АЗ за РНОКПП
    ----------------------------------------------------------------------
    PROCEDURE Reg_Ar_By_Rnokpp_Req (
        p_Sc_Id       IN     NUMBER,
        p_Inn         IN     VARCHAR2,
        p_Role        IN     VARCHAR2,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE)
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
                                    p_Rnp_Inn          => p_Inn,
                                    p_Rnp_Ndt          => NULL,
                                    p_Rnp_Doc_Seria    => NULL,
                                    p_Rnp_Doc_Number   => NULL,
                                    p_Rnp_Sc_Unique    => NULL,
                                    p_New_Id           => l_Rnp_Id);

        --Зберігаємо "роль у свідоцтві ДРАЦС"
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Cert_Role,
                                         p_Rnc_Val_String   => p_Role);
    END;

    ----------------------------------------------------------------------
    --  Отримання даних для запиту
    -- "отримання АЗ за РНОКПП"
    ----------------------------------------------------------------------
    FUNCTION Get_Ar_By_Rnokpp_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn             NUMBER;
        l_Role              VARCHAR2 (10);
        l_Request_Payload   XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Role :=
            Api$request.Get_Rn_Common_Info_String (
                p_Rnc_Rn   => l_Ur_Rn,
                p_Rnc_Pt   => c_Pt_Cert_Role);

        SELECT XMLELEMENT ("ArServiceByRnokppRequest",
                           Xmlattributes ('http://tempuri.org/' AS "xmlns"),
                           XMLELEMENT ("Rnokpp", p.Rnp_Inn),
                           XMLELEMENT ("Role", l_Role))
          INTO l_Request_Payload
          FROM Rn_Person p
         WHERE p.Rnp_Rn = l_Ur_Rn;

        RETURN l_Request_Payload.Getclobval;
    END;

    ----------------------------------------------------------------------
    --  Отримання даних для запиту
    -- "отримання АЗ про шлюб/розірвання шлюбу за ПІБ та датою народження дружини"
    ----------------------------------------------------------------------
    FUNCTION Get_Marriage_Divorce_Ar_By_Wife_Name_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn             NUMBER;
        l_Child_Birth_Dt    DATE;
        l_Request_Payload   XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Child_Birth_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Birth_Dt);

        SELECT XMLELEMENT (
                   "ArMarriageDivorceServiceRequest",
                   Xmlattributes ('http://tempuri.org/' AS "xmlns"),
                   XMLELEMENT ("WifeBirthDate",
                               TO_CHAR (l_Child_Birth_Dt, 'yyyy-mm-dd')),
                   XMLELEMENT ("WifeName", i.Rnpi_Fn),
                   XMLELEMENT ("WifePatronymic", i.Rnpi_Mn),
                   XMLELEMENT ("WifeSurname", i.Rnpi_Ln))
          INTO l_Request_Payload
          FROM Rn_Person p JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE p.Rnp_Rn = l_Ur_Rn;

        RETURN l_Request_Payload.Getclobval;
    END;

    ----------------------------------------------------------------------
    --  Отримання даних для запиту
    -- "отримання АЗ про шлюб/розірвання шлюбу за ПІБ та датою народження чоловіка"
    ----------------------------------------------------------------------
    FUNCTION Get_Marriage_Divorce_Ar_By_Husband_Name_Data (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn             NUMBER;
        l_Child_Birth_Dt    DATE;
        l_Request_Payload   XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Child_Birth_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Birth_Dt);

        SELECT XMLELEMENT (
                   "ArMarriageDivorceServiceRequest",
                   Xmlattributes ('http://tempuri.org/' AS "xmlns"),
                   XMLELEMENT ("HusbandBirthDate",
                               TO_CHAR (l_Child_Birth_Dt, 'yyyy-mm-dd')),
                   XMLELEMENT ("HusbandName", i.Rnpi_Fn),
                   XMLELEMENT ("HusbandPatronymic", i.Rnpi_Mn),
                   XMLELEMENT ("HusbandSurname", i.Rnpi_Ln))
          INTO l_Request_Payload
          FROM Rn_Person p JOIN Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE p.Rnp_Rn = l_Ur_Rn;

        RETURN l_Request_Payload.Getclobval;
    END;

    ----------------------------------------------------------------------
    --     Парсинг відповіді на запит актових записів про народження
    ----------------------------------------------------------------------
    FUNCTION Parse_Birth_Ar_Resp (p_Response          CLOB,
                                  p_Resutl_Code   OUT NUMBER,
                                  p_Error_Info    OUT VARCHAR2)
        RETURN t_Birth_Act_Record_List
    IS
        l_Ar_List       t_Birth_Act_Record_List;
        l_Result_Data   CLOB;
    BEGIN
        Parse_Cert_Resp (p_Response      => p_Response,
                         p_Result_Data   => l_Result_Data,
                         p_Resutl_Code   => p_Resutl_Code,
                         p_Error_Info    => p_Error_Info);

        IF     l_Result_Data IS NOT NULL
           AND DBMS_LOB.Getlength (l_Result_Data) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'T_BIRTH_ACT_RECORD_LIST',
                                             'yyyy-mm-dd"T"hh24:mi:ss')
                USING IN l_Result_Data, OUT l_Ar_List;

            RETURN l_Ar_List;
        ELSE
            RETURN NULL;
        END IF;
    END;

    ----------------------------------------------------------------------
    --     Парсинг відповіді на запит актових записів про зміну імені
    ----------------------------------------------------------------------
    FUNCTION Parse_Change_Name_Ar_Resp (p_Response          CLOB,
                                        p_Resutl_Code   OUT NUMBER,
                                        p_Error_Info    OUT VARCHAR2)
        RETURN t_Change_Name_Act_Record_List
    IS
        l_Ar_List       t_Change_Name_Act_Record_List;
        l_Result_Data   CLOB;
    BEGIN
        Parse_Cert_Resp (p_Response      => p_Response,
                         p_Result_Data   => l_Result_Data,
                         p_Resutl_Code   => p_Resutl_Code,
                         p_Error_Info    => p_Error_Info);

        IF     l_Result_Data IS NOT NULL
           AND DBMS_LOB.Getlength (l_Result_Data) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'T_CHANGE_NAME_ACT_RECORD_LIST',
                                             'yyyy-mm-dd"T"hh24:mi:ss')
                USING IN l_Result_Data, OUT l_Ar_List;

            RETURN l_Ar_List;
        ELSE
            RETURN NULL;
        END IF;
    END;

    ----------------------------------------------------------------------
    --     Парсинг відповіді на запит актових записів про шлюб
    ----------------------------------------------------------------------
    FUNCTION Parse_Merriage_Ar_Resp (p_Response          CLOB,
                                     p_Resutl_Code   OUT NUMBER,
                                     p_Error_Info    OUT VARCHAR2)
        RETURN t_Merriage_Act_Record_List
    IS
        l_Ar_List       t_Merriage_Act_Record_List;
        l_Result_Data   CLOB;
    BEGIN
        Parse_Cert_Resp (p_Response      => p_Response,
                         p_Result_Data   => l_Result_Data,
                         p_Resutl_Code   => p_Resutl_Code,
                         p_Error_Info    => p_Error_Info);

        IF     l_Result_Data IS NOT NULL
           AND DBMS_LOB.Getlength (l_Result_Data) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'T_MERRIAGE_ACT_RECORD_LIST',
                                             'yyyy-mm-dd"T"hh24:mi:ss')
                USING IN l_Result_Data, OUT l_Ar_List;

            RETURN l_Ar_List;
        ELSE
            RETURN NULL;
        END IF;
    END;

    ----------------------------------------------------------------------
    --     Парсинг відповіді на запит актових записів про розірвання шлюбу
    ----------------------------------------------------------------------
    FUNCTION Parse_Divorce_Ar_Resp (p_Response          CLOB,
                                    p_Resutl_Code   OUT NUMBER,
                                    p_Error_Info    OUT VARCHAR2)
        RETURN t_Divorce_Act_Record_List
    IS
        l_Ar_List       t_Divorce_Act_Record_List;
        l_Result_Data   CLOB;
    BEGIN
        Parse_Cert_Resp (p_Response      => p_Response,
                         p_Result_Data   => l_Result_Data,
                         p_Resutl_Code   => p_Resutl_Code,
                         p_Error_Info    => p_Error_Info);

        IF     l_Result_Data IS NOT NULL
           AND DBMS_LOB.Getlength (l_Result_Data) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'T_DIVORCE_ACT_RECORD_LIST',
                                             'yyyy-mm-dd"T"hh24:mi:ss')
                USING IN l_Result_Data, OUT l_Ar_List;

            RETURN l_Ar_List;
        ELSE
            RETURN NULL;
        END IF;
    END;
END Api$request_Mju;
/