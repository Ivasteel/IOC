/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_MON
IS
    -- Author  : KELATEV
    -- Created : 28.02.2025 9:23:46
    -- Purpose :

    Package_Name                   CONSTANT VARCHAR2 (50) := 'API$REQUEST_MON';

    c_Urt_Full_Time_Study_List     CONSTANT NUMBER := 146;
    c_Urt_Info_By_Pupil            CONSTANT NUMBER := 147;
    c_Urt_Dictionary               CONSTANT NUMBER := 148;

    c_Pt_Birth_Dt                  CONSTANT NUMBER := 87;
    c_Pt_Dic                       CONSTANT NUMBER := 517;

    c_Study_Status_Empty           CONSTANT NUMBER := 0;   --особу не знайдено
    c_Study_Status_Ok              CONSTANT NUMBER := 1; --знайдено особу, яка здобуває освіту на денній формі навчання
    c_Study_Status_End             CONSTANT NUMBER := 2; --знайдено особу, яка припинила навчання на денній формі навчання
    c_Study_Status_Notvalid        CONSTANT NUMBER := -1; --обов’язкові поля не заповнено або заповнено неправильно
    c_Study_Status_Many            CONSTANT NUMBER := -2; --знайдено більше однієї особи

    c_Error_Not_Found              CONSTANT NUMBER := 1001; --Не знайдено жодного учня із заданими параметрами
    c_Error_Expelled_Death         CONSTANT NUMBER := 1002; --Відрахований у зв'язку зі смертю дитини
    c_Error_Expelled_Depart        CONSTANT NUMBER := 1003; --Відраховано за заявою у зв'язку з виїздом дитини за кордон (ПМЖ)
    c_Error_Completed              CONSTANT NUMBER := 1004; --Учень закінчив навчання
    c_Error_Not_Attending_School   CONSTANT NUMBER := 1005; --Не відвідує жодної школи

    TYPE r_Profession_Entity IS RECORD
    (
        Prof_Code    VARCHAR2 (100),
        Prof_Name    VARCHAR2 (1000)
    );

    TYPE t_Profession_List IS TABLE OF r_Profession_Entity;

    TYPE r_Study_Entity IS RECORD
    (
        Date_Begin     DATE,
        Date_End       DATE,
        Edrpou         VARCHAR2 (20),
        Ed_Degree      VARCHAR2 (100),
        Ed_Name        VARCHAR2 (1000),
        Sp_Code        VARCHAR2 (100),
        Sp_Name        VARCHAR2 (1000),
        Spz_Code       VARCHAR2 (100),
        Spz_Name       VARCHAR2 (1000),
        Professions    t_Profession_List
    );

    TYPE t_Study_List IS TABLE OF r_Study_Entity;

    TYPE r_Full_Time_Study_Result IS RECORD
    (
        Date_Stop     DATE,
        Status        NUMBER,
        Study_List    t_Study_List
    );

    TYPE r_Full_Time_Study_List_Response IS RECORD
    (
        Full_Time_Study_Result    r_Full_Time_Study_Result
    );

    TYPE r_Address IS RECORD
    (
        Region                VARCHAR2 (250),
        District              VARCHAR2 (250),
        Locality_Type         VARCHAR2 (20),
        Locality              VARCHAR2 (250),
        Street                VARCHAR2 (250),
        House                 VARCHAR2 (50),
        Building_Part         VARCHAR2 (50),
        Building_Part_Type    VARCHAR2 (50),
        Apartment             VARCHAR2 (50)
    );

    TYPE t_Educational_Profiles IS TABLE OF VARCHAR2 (100);

    TYPE r_University IS RECORD
    (
        Edrpo                   VARCHAR2 (20),
        Short_Name              VARCHAR2 (1000),
        Educationl_Type         VARCHAR2 (100),
        Educationl_Type_Code    VARCHAR2 (10),
        Educational_Profiles    t_Educational_Profiles,
        Is_Evacuated            VARCHAR2 (10),
        Address_Evacuated       VARCHAR2 (1000)
    );

    TYPE r_Specialty IS RECORD
    (
        Specialty    VARCHAR2 (1000)
    );

    TYPE t_Specialties IS TABLE OF r_Specialty;

    TYPE r_Education_Form IS RECORD
    (
        Form_Type       VARCHAR2 (100),
        Form_Subtype    VARCHAR2 (100)
    );

    TYPE r_Full_State_Support IS RECORD
    (
        Date_From    DATE,
        Date_By      DATE,
        Stipend      NUMBER
    );

    TYPE r_Parent IS RECORD
    (
        Type_Parent    VARCHAR2 (10),
        Last_Name      VARCHAR2 (250),
        First_Name     VARCHAR2 (250),
        Second_Name    VARCHAR2 (250)
    );

    TYPE t_Parents IS TABLE OF r_Parent;

    TYPE r_Info_By_Pupil_Response IS RECORD
    (
        Last_Name                VARCHAR2 (250),
        First_Name               VARCHAR2 (250),
        Second_Name              VARCHAR2 (250),
        Birthday                 DATE,
        Gender                   VARCHAR2 (10),
        Address_Fact             VARCHAR2 (1000),
        Address                  r_Address,
        University               r_University,
        Night_Stay               VARCHAR2 (50),
        Specialties              t_Specialties,
        Education_Form           r_Education_Form,
        Academic_Year            VARCHAR2 (50),
        Is_Full_State_Support    VARCHAR2 (10),
        Full_State_Support       r_Full_State_Support,
        Parents                  t_Parents
    );

    TYPE r_Data_Dictionary IS RECORD
    (
        Code              VARCHAR2 (10),
        Constant_Сode    VARCHAR2 (100),
        Name_             VARCHAR2 (250)
    );

    TYPE t_Data_Dictionary IS TABLE OF r_Data_Dictionary;

    TYPE r_Dictionary_Response IS RECORD
    (
        Type_Dictionary    VARCHAR2 (10),
        Name_Dictionary    VARCHAR2 (100),
        Data_Dictionary    t_Data_Dictionary
    );

    PROCEDURE Reg_Full_Time_Study_List_Request (
        p_Sc_Id        IN     NUMBER,
        p_Numident     IN     VARCHAR2,
        p_Fn           IN     VARCHAR2,
        p_Ln           IN     VARCHAR2,
        p_Mn           IN     VARCHAR2,
        p_Doc_Ser      IN     VARCHAR2,
        p_Doc_Num      IN     VARCHAR2,
        p_Date_Birth   IN     DATE,
        p_Wu_Id        IN     NUMBER,
        p_Src          IN     VARCHAR2,
        p_Rn_Id           OUT NUMBER);

    FUNCTION Build_Full_Time_Study_List_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Full_Time_Study_List_Resp (p_Response IN CLOB)
        RETURN r_Full_Time_Study_List_Response;

    PROCEDURE Reg_Info_By_Pupil_Request (p_Sc_Id        IN     NUMBER,
                                         p_Numident     IN     VARCHAR2,
                                         p_Fn           IN     VARCHAR2,
                                         p_Ln           IN     VARCHAR2,
                                         p_Mn           IN     VARCHAR2,
                                         p_Doc_Ndt      IN     NUMBER,
                                         p_Doc_Ser      IN     VARCHAR2,
                                         p_Doc_Num      IN     VARCHAR2,
                                         p_Date_Birth   IN     DATE,
                                         p_Wu_Id        IN     NUMBER,
                                         p_Src          IN     VARCHAR2,
                                         p_Rn_Id           OUT NUMBER);

    FUNCTION Build_Info_By_Pupil_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Info_By_Pupil_Resp (p_Response_Data IN CLOB)
        RETURN r_Info_By_Pupil_Response;

    PROCEDURE Reg_Dictionary_Request (p_Type_Dic   IN     VARCHAR2,
                                      p_Wu_Id      IN     NUMBER,
                                      p_Src        IN     VARCHAR2,
                                      p_Rn_Id         OUT NUMBER);

    FUNCTION Build_Dictionary_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Dictionary_Resp (p_Response_Data IN CLOB)
        RETURN r_Dictionary_Response;

    PROCEDURE Get_Respapi_Resp (p_Response        IN            CLOB,
                                p_Data            IN OUT NOCOPY CLOB,
                                p_Error_Code         OUT        VARCHAR2,
                                p_Error_Message      OUT        VARCHAR2);
END Api$request_Mon;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MON TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MON TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MON TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MON TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MON TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_MON
IS
    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- отримання інформації про осіб, які здобувають вищу, фахову передвищу та професійну (професійно-технічну) освіту на денній формі навчання, що здійснює запит за РНОКПП та ПІБ і датою народження
    -- #111340
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Full_Time_Study_List_Request (
        p_Sc_Id        IN     NUMBER,
        p_Numident     IN     VARCHAR2,
        p_Fn           IN     VARCHAR2,
        p_Ln           IN     VARCHAR2,
        p_Mn           IN     VARCHAR2,
        p_Doc_Ser      IN     VARCHAR2,
        p_Doc_Num      IN     VARCHAR2,
        p_Date_Birth   IN     DATE,
        p_Wu_Id        IN     NUMBER,
        p_Src          IN     VARCHAR2,
        p_Rn_Id           OUT NUMBER)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Full_Time_Study_List,
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

        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Date_Birth);
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- отримання інформації про осіб, які здобувають вищу, фахову передвищу та професійну (професійно-технічну) освіту на денній формі навчання, що здійснює запит за РНОКПП та ПІБ і датою народження
    -- #111340
    ---------------------------------------------------------------------------
    FUNCTION Build_Full_Time_Study_List_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id      NUMBER;
        l_Birth_Dt   DATE;
        l_Req_Xml    XMLTYPE;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
        l_Birth_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Rn_Id,
                                               p_Rnc_Pt   => c_Pt_Birth_Dt);

        SELECT XMLELEMENT (
                   "GetEvodByPerson",
                   XMLELEMENT (
                       "RNOKPP",
                       NVL (p.Rnp_Inn, p.Rnp_Doc_Seria || p.Rnp_Doc_Number)),
                   XMLELEMENT ("familyName", NVL (i.Rnpi_Ln, '-')),
                   XMLELEMENT ("givenName", NVL (i.Rnpi_Fn, '-')),
                   XMLELEMENT ("patronymicName", i.Rnpi_Mn),
                   XMLELEMENT ("birthDay",
                               TO_CHAR (l_Birth_Dt, 'yyyy-mm-dd')))    Request_Data
          INTO l_Req_Xml
          FROM Ikis_Rbm.Uxp_Request  r
               JOIN Ikis_Rbm.Rn_Person p ON r.Ur_Rn = p.Rnp_Rn
               JOIN Ikis_Rbm.Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Req_Xml.Getclobval;
    END;

    --------------------------------------------------------------------
    -- Парсинг відповіді на запит на
    -- отримання інформації про осіб, які здобувають вищу, фахову передвищу та професійну (професійно-технічну) освіту на денній формі навчання, що здійснює запит за РНОКПП та ПІБ і датою народження
    -- #111340
    --------------------------------------------------------------------
    FUNCTION Parse_Full_Time_Study_List_Resp (p_Response IN CLOB)
        RETURN r_Full_Time_Study_List_Response
    IS
        l_Resp   r_Full_Time_Study_List_Response;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (
                                 Package_Name,
                                 'R_FULL_TIME_STUDY_LIST_RESPONSE',
                                 'yyyy-mm-dd"T"hh24:mi:ss')
                USING IN p_Response, OUT l_Resp;
        END IF;

        RETURN l_Resp;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання даних по учню
    -- #111340
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Info_By_Pupil_Request (p_Sc_Id        IN     NUMBER,
                                         p_Numident     IN     VARCHAR2,
                                         p_Fn           IN     VARCHAR2,
                                         p_Ln           IN     VARCHAR2,
                                         p_Mn           IN     VARCHAR2,
                                         p_Doc_Ndt      IN     NUMBER,
                                         p_Doc_Ser      IN     VARCHAR2,
                                         p_Doc_Num      IN     VARCHAR2,
                                         p_Date_Birth   IN     DATE,
                                         p_Wu_Id        IN     NUMBER,
                                         p_Src          IN     VARCHAR2,
                                         p_Rn_Id           OUT NUMBER)
    IS
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Info_By_Pupil,
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

        --Зберігаємо дату народження
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                         p_Rnc_Pt       => c_Pt_Birth_Dt,
                                         p_Rnc_Val_Dt   => p_Date_Birth);
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання даних по учню
    -- #111340
    ---------------------------------------------------------------------------
    FUNCTION Build_Info_By_Pupil_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id         NUMBER;
        l_Birth_Dt      DATE;
        l_Req_Payload   CLOB;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
        l_Birth_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Rn_Id,
                                               p_Rnc_Pt   => c_Pt_Birth_Dt);

        SELECT Json_Object (
                   'businessProcessDefinitionKey' VALUE 'getInfoByPupil',
                   'startVariables' VALUE
                       Json_Object (
                           'request' VALUE
                               Json_Object (
                                   'rnokpp' VALUE p.Rnp_Inn,
                                   'lastName' VALUE i.Rnpi_Ln,
                                   'firstName' VALUE i.Rnpi_Fn,
                                   'secondName' VALUE i.Rnpi_Mn,
                                   'birthday' VALUE
                                       TO_CHAR (l_Birth_Dt, 'yyyy-mm-dd'),
                                   'docType' VALUE Uss_Ndi.Tools.Decode_Dict (
                                                       p_Nddc_Tp     => 'NDT_ID',
                                                       p_Nddc_Src    => 'USS',
                                                       p_Nddc_Dest   => 'MON',
                                                       p_Nddc_Code_Src   =>
                                                           p.Rnp_Ndt),
                                   'docSeria' VALUE p.Rnp_Doc_Seria,
                                   'docNumber' VALUE p.Rnp_Doc_Number)))
          INTO l_Req_Payload
          FROM Ikis_Rbm.Uxp_Request  r
               JOIN Ikis_Rbm.Rn_Person p ON r.Ur_Rn = p.Rnp_Rn
               JOIN Ikis_Rbm.Rnp_Identity_Info i ON p.Rnp_Id = i.Rnpi_Rnp
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Req_Payload;
    END;

    --------------------------------------------------------------------
    -- Парсинг відповіді на запит на
    -- Отримання даних по учню
    -- #111340
    --------------------------------------------------------------------
    FUNCTION Parse_Info_By_Pupil_Resp (p_Response_Data IN CLOB)
        RETURN r_Info_By_Pupil_Response
    IS
        l_Data   CLOB;
        l_Resp   r_Info_By_Pupil_Response;
    BEGIN
        IF     p_Response_Data IS NOT NULL
           AND DBMS_LOB.Getlength (p_Response_Data) > 0
        THEN
            EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                              'R_INFO_BY_PUPIL_RESPONSE',
                                              'yyyy-mm-dd"T"hh24:mi:ss')
                USING IN l_Data, OUT l_Resp;

            l_Resp.Gender := UPPER (SUBSTR (l_Resp.Gender, 1, 1));
            l_Resp.University.Is_Evacuated :=
                UPPER (SUBSTR (l_Resp.University.Is_Evacuated, 1, 1));
            l_Resp.Is_Full_State_Support :=
                UPPER (SUBSTR (l_Resp.Is_Full_State_Support, 1, 1));
        END IF;

        RETURN l_Resp;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання довідників
    -- #111340
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Dictionary_Request (p_Type_Dic   IN     VARCHAR2,
                                      p_Wu_Id      IN     NUMBER,
                                      p_Src        IN     VARCHAR2,
                                      p_Rn_Id         OUT NUMBER)
    IS
        l_Ur_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Dictionary,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => p_Type_Dic,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Dic,
                                         p_Rnc_Val_String   => p_Type_Dic);
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання довідників
    -- #111340
    ---------------------------------------------------------------------------
    FUNCTION Build_Dictionary_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id         NUMBER;
        l_Type_Dic      VARCHAR2 (10);
        l_Req_Payload   CLOB;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);
        l_Type_Dic :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Dic);

        SELECT Json_Object (
                   'businessProcessDefinitionKey' VALUE 'getDictionary',
                   'startVariables' VALUE
                       Json_Object (
                           'request' VALUE
                               Json_Object (
                                   'typeDictionary' VALUE l_Type_Dic)))
          INTO l_Req_Payload
          FROM DUAL;

        RETURN l_Req_Payload;
    END;

    --------------------------------------------------------------------
    -- Парсинг відповіді на запит на
    -- Отримання довідників
    -- #111340
    --------------------------------------------------------------------
    FUNCTION Parse_Dictionary_Resp (p_Response_Data IN CLOB)
        RETURN r_Dictionary_Response
    IS
        l_Data   CLOB;
        l_Resp   r_Dictionary_Response;
    BEGIN
        IF     p_Response_Data IS NOT NULL
           AND DBMS_LOB.Getlength (p_Response_Data) > 0
        THEN
            EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                              'R_DICTIONARY_RESPONSE',
                                              'yyyy-mm-dd"T"hh24:mi:ss')
                USING IN l_Data, OUT l_Resp;
        END IF;

        RETURN l_Resp;
    END;

    --------------------------------------------------------------------
    --Отримання блоку з данними із REST-запиту
    --------------------------------------------------------------------
    PROCEDURE Get_Respapi_Resp (p_Response        IN            CLOB,
                                p_Data            IN OUT NOCOPY CLOB,
                                p_Error_Code         OUT        VARCHAR2,
                                p_Error_Message      OUT        VARCHAR2)
    IS
    BEGIN
        SELECT Json_Value (p_Response,
                           '$.resultVariables.response.data'
                           RETURNING CLOB),
               Json_Value (p_Response,
                           '$.resultVariables.response.error.code'),
               Json_Value (p_Response,
                           '$.resultVariables.response.error.message')
          INTO p_Data, p_Error_Code, p_Error_Message
          FROM DUAL;
    END;
END Api$request_Mon;
/