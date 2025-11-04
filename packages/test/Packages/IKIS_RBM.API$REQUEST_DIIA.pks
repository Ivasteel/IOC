/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_DIIA
IS
    -- Author  : SHOSTAK
    -- Created : 09.06.2022 2:16:09 PM
    -- Purpose :

    Package_Name             CONSTANT VARCHAR2 (100) := 'API$REQUEST_DIIA';

    c_Urt_Sharing            CONSTANT NUMBER := 36;
    c_Urt_Edrato             CONSTANT NUMBER := 133;
    c_Urt_Edrato_List        CONSTANT NUMBER := 134;
    c_Urt_Street_List        CONSTANT NUMBER := 135;
    c_Urt_Edra               CONSTANT NUMBER := 136;
    c_Urt_Address            CONSTANT NUMBER := 137;
    c_Urt_Geocoding          CONSTANT NUMBER := 138;
    c_Urt_Geocoding_Edrato   CONSTANT NUMBER := 139;

    c_Pt_Num                 CONSTANT NUMBER := 110;
    c_Pt_Date                CONSTANT NUMBER := 89;
    c_Pt_Version             CONSTANT NUMBER := 514;
    c_Pt_Point               CONSTANT NUMBER := 515;
    c_Pt_Bbox                CONSTANT NUMBER := 516;
    c_Pt_Text                CONSTANT NUMBER := 505;
    c_Pt_Comment             CONSTANT NUMBER := 259;
    c_Pt_Count               CONSTANT NUMBER := 222;
    c_Pt_Percent             CONSTANT NUMBER := 317;

    TYPE t_String_List IS TABLE OF VARCHAR2 (200);

    --ІД КАРТКА
    TYPE r_Internal_Passport IS RECORD
    (
        Residence_Ua       VARCHAR2 (4000),
        Doc_Number         VARCHAR2 (9),
        Gender_Ua          VARCHAR2 (10),
        Nationality_Ua     VARCHAR2 (30),
        Last_Name_Ua       VARCHAR2 (100),
        First_Name_Ua      VARCHAR2 (100),
        Middle_Name_Ua     VARCHAR2 (100),
        Birthday           DATE,
        Birth_Place_Ua     VARCHAR2 (4000),
        Issue_Date         DATE,
        Expiration_Date    DATE,
        Record_Number      VARCHAR2 (14),
        Department         VARCHAR2 (4000),
        Gender_En          VARCHAR2 (10),
        Lastname_En        VARCHAR2 (100),
        Firstname_En       VARCHAR2 (100)
    );

    --ЗАКОРДОННИЙ ПАСПОРТ
    TYPE r_Foreign_Passport IS RECORD
    (
        Residence_Ua       VARCHAR2 (4000),
        Doc_Number         VARCHAR2 (8),
        Gender_Ua          VARCHAR2 (10),
        Nationality_Ua     VARCHAR2 (30),
        Last_Name_Ua       VARCHAR2 (100),
        First_Name_Ua      VARCHAR2 (100),
        Middle_Name_Ua     VARCHAR2 (100),
        Birthday           DATE,
        Birth_Place_Ua     VARCHAR2 (4000),
        Issue_Date         DATE,
        Expiration_Date    DATE,
        Record_Number      VARCHAR2 (14),
        Department_Ua      VARCHAR2 (4000),
        Country_Code       VARCHAR2 (3),
        Gender_En          VARCHAR2 (10),
        Lastname_En        VARCHAR2 (100),
        Firstname_En       VARCHAR2 (100),
        Department_En      VARCHAR2 (4000)
    );

    --РНОКПП
    TYPE r_Taxpayer_Card IS RECORD
    (
        Creation_Date     DATE,
        Doc_Number        VARCHAR2 (10),
        Last_Name_Ua      VARCHAR2 (100),
        First_Name_Ua     VARCHAR2 (100),
        Middle_Name_Ua    VARCHAR2 (100),
        Birthday          DATE
    );

    --СВІДОЦТВО ПРО НАРОДЖЕННЯ
    TYPE r_Birth_Doc IS RECORD
    (
        Serie         VARCHAR2 (7),
        Number_       VARCHAR2 (6),
        Department    VARCHAR2 (4000),
        Issue_Date    DATE
    );

    TYPE r_Child IS RECORD
    (
        Last_Name      VARCHAR2 (100),
        First_Name     VARCHAR2 (100),
        Middle_Name    VARCHAR2 (100),
        Birth_Date     DATE,
        Birth_Place    VARCHAR2 (4000)
    );

    TYPE r_Parent IS RECORD
    (
        Full_Name    VARCHAR2 (300)
    );

    TYPE r_Parents IS RECORD
    (
        Mother    r_Parent,
        Father    r_Parent
    );

    TYPE r_Bith_Act IS RECORD
    (
        Name_                 VARCHAR2 (100),
        Registration_Place    VARCHAR2 (4000)
    );

    TYPE r_Birth_Certificate IS RECORD
    (
        Document    r_Birth_Doc,
        Child       r_Child,
        Parents     r_Parents,
        Act         r_Bith_Act
    );

    TYPE r_Sharing_Response IS RECORD
    (
        Internal_Passport    r_Internal_Passport,
        Foreign_Passport     r_Foreign_Passport,
        Taxpayer_Card        r_Taxpayer_Card,
        Birth_Certificate    r_Birth_Certificate,
        File_Name            VARCHAR2 (250),
        File_Data            BLOB,
        File_Sign            BLOB
    );

    TYPE r_Doc_Attr IS RECORD
    (
        Nda_Id     NUMBER,
        Val_Str    VARCHAR2 (4000),
        Val_Dt     DATE,
        Val_Id     NUMBER
    );

    TYPE t_Doc_Attrs IS TABLE OF r_Doc_Attr;

    TYPE r_Identifier IS RECORD
    (
        Local_Id      VARCHAR2 (100),
        Namespace     VARCHAR2 (100),
        Version_Id    VARCHAR2 (25)
    );

    TYPE r_Pronunciation IS RECORD
    (
        Pronunciation_Sound_Link    VARCHAR2 (100),
        Pronunciation_Ipa           VARCHAR2 (100)
    );

    TYPE r_Spelling IS RECORD
    (
        Text                      VARCHAR2 (100),
        Script                    VARCHAR2 (100),
        Transliteration_Scheme    VARCHAR2 (100)
    );

    TYPE r_Edra_Xlink IS RECORD
    (
        Href      VARCHAR2 (1000),
        Atu_Id    VARCHAR2 (100),
        Title     VARCHAR2 (1000)
    );

    TYPE t_Edra_Xlinks IS TABLE OF r_Edra_Xlink;

    --Положення геопросторового об’єкта
    TYPE r_Geographic_Position IS RECORD
    (
        Geometry         XMLTYPE,
        Specification    r_Edra_Xlink,
        Method           r_Edra_Xlink,
        Default_         VARCHAR2 (10)
    );

    TYPE t_Geographic_Position IS TABLE OF r_Geographic_Position;

    TYPE r_Geographical_Name IS RECORD
    (
        Language_             VARCHAR2 (3),
        Nativeness            VARCHAR2 (100), --https://inspire.ec.europa.eu/codelist/NativenessValue
        Name_Status           VARCHAR2 (100), --https://inspire.ec.europa.eu/codelist/NameStatusValue
        Source_Of_Name        VARCHAR2 (100),
        Pronunciation         r_Pronunciation,
        Spelling              r_Spelling,
        Grammatical_Gender    VARCHAR2 (100), --https://inspire.ec.europa.eu/codelist/GrammaticalGenderValue
        Grammatical_Number    VARCHAR2 (100) --https://inspire.ec.europa.eu/codelist/GrammaticalNumberValue
    );

    TYPE r_Residence_Of_Authority IS RECORD
    (
        Name_    r_Geographical_Name
    );

    TYPE r_Administrative_Unit IS RECORD
    (
        Id                        VARCHAR2 (100),
        National_Code             VARCHAR2 (100),
        Inspire_Id                r_Identifier,
        National_Level            VARCHAR2 (10), --https://inspire.ec.europa.eu/codelist/AdministrativeHierarchyLevel
        National_Level_Name       VARCHAR2 (100),
        Country                   VARCHAR2 (2),
        Name_                     r_Geographical_Name,
        Residence_Of_Authority    r_Residence_Of_Authority,
        Begin_Lifespan_Version    DATE,
        End_Lifespan_Version      DATE,
        Valid_From                DATE,
        Valid_To                  DATE,
        Lower_Level_Unit          t_Edra_Xlinks,
        Upper_Level_Unit          t_Edra_Xlinks,
        Administered_By           r_Edra_Xlink,
        Boundary                  t_Edra_Xlinks
    );

    TYPE r_Locator_Designator IS RECORD
    (
        Designator    VARCHAR2 (100),
        Type_         r_Edra_Xlink
    );

    TYPE t_Locator_Designator IS TABLE OF r_Locator_Designator;

    TYPE r_Locator_Name IS RECORD
    (
        Name_    r_Geographical_Name,
        Type_    r_Edra_Xlink
    );

    TYPE t_Locator_Name IS TABLE OF r_Locator_Name;

    TYPE r_Address_Locator IS RECORD
    (
        Level_             r_Edra_Xlink,
        Within_Scope_Of    r_Edra_Xlink,
        Designator         t_Locator_Designator,
        Name_              t_Locator_Name
    );

    TYPE t_Address_Locator IS TABLE OF r_Address_Locator;

    --ЄДРА. Основний набір даних про адресу
    TYPE r_Address IS RECORD
    (
        Id                        VARCHAR2 (100),
        Inspire_Id                r_Identifier,
        Alternative_Identifier    VARCHAR2 (1000),
        Position                  t_Geographic_Position,
        Status                    r_Edra_Xlink,
        Locator                   t_Address_Locator,
        Valid_From                DATE,
        Valid_To                  DATE,
        Begin_Lifespan_Version    DATE,
        End_Lifespan_Version      DATE,
        Parcel                    t_Edra_Xlinks,
        Parent_Address            r_Edra_Xlink,
        Building                  t_Edra_Xlinks,
        Component                 t_Edra_Xlinks
    );

    TYPE t_Address IS TABLE OF r_Address;

    --Компонент адреси, що містить набір даних про адміністративно- територіальну одиницю
    TYPE r_Admin_Unit_Name IS RECORD
    (
        Id                        VARCHAR2 (100),
        Inspire_Id                r_Identifier,
        Alternative_Identifier    VARCHAR2 (1000),
        Position                  t_Geographic_Position,
        Valid_From                DATE,
        Valid_To                  DATE,
        Begin_Lifespan_Version    DATE,
        End_Lifespan_Version      DATE,
        Status                    r_Edra_Xlink,
        Situated_Within           t_Edra_Xlinks,
        Name_                     r_Geographical_Name,
        Level_                    r_Edra_Xlink, --https://inspire.ec.europa.eu/codelist/AdministrativeHierarchyLevel
        Admin_Unit                t_Edra_Xlinks
    );

    TYPE t_Admin_Unit_Name IS TABLE OF r_Admin_Unit_Name;

    TYPE r_Name_Parts IS RECORD
    (
        Part     VARCHAR2 (100),
        Type_    r_Edra_Xlink
    );

    TYPE t_Name_Parts IS TABLE OF r_Name_Parts;

    TYPE r_Thoroughfare_Name_Value IS RECORD
    (
        Name_         r_Geographical_Name,
        Name_Parts    t_Name_Parts
    );

    TYPE t_Thoroughfare_Name_Value IS TABLE OF r_Thoroughfare_Name_Value;

    --Компонент адреси, який містить набір даних про транспортний шлях
    TYPE r_Thoroughfare_Name IS RECORD
    (
        Id                        VARCHAR2 (100),
        Inspire_Id                r_Identifier,
        Alternative_Identifier    VARCHAR2 (1000),
        Position                  t_Geographic_Position,
        Valid_From                DATE,
        Valid_To                  DATE,
        Begin_Lifespan_Version    DATE,
        End_Lifespan_Version      DATE,
        Status                    r_Edra_Xlink,
        Situated_Within           t_Edra_Xlinks,
        Name_                     t_Thoroughfare_Name_Value,
        Transport_Link            t_Edra_Xlinks
    );

    TYPE t_Thoroughfare_Name IS TABLE OF r_Thoroughfare_Name;

    TYPE r_Address_Area_Name IS RECORD
    (
        Id                        VARCHAR2 (100),
        Inspire_Id                r_Identifier,
        Alternative_Identifier    VARCHAR2 (1000),
        Position                  t_Geographic_Position,
        Valid_From                DATE,
        Valid_To                  DATE,
        Begin_Lifespan_Version    DATE,
        End_Lifespan_Version      DATE,
        Status                    r_Edra_Xlink,
        Situated_Within           t_Edra_Xlinks,
        Name_                     r_Geographical_Name,
        Named_Place               t_Edra_Xlinks
    );

    TYPE t_Address_Area_Name IS TABLE OF r_Address_Area_Name;

    TYPE r_Edra_Member IS RECORD
    (
        Address              t_Address,
        Thoroughfare_Name    t_Thoroughfare_Name,
        Address_Area_Name    t_Address_Area_Name,
        Admin_Unit_Name      t_Admin_Unit_Name
    );

    PROCEDURE Reg_Sharing_Request (p_Barcode    IN     VARCHAR2,
                                   p_Skip_Pdf   IN     VARCHAR2,
                                   p_Wu_Id      IN     NUMBER,
                                   p_Src        IN     VARCHAR2,
                                   p_Com_Org    IN     NUMBER,
                                   p_Rn_Id         OUT NUMBER);

    PROCEDURE Handle_Sharing_Resp (p_Ur_Id      IN     NUMBER,
                                   p_Response   IN     CLOB,
                                   p_Error      IN OUT VARCHAR2);

    PROCEDURE Link_Sharing_Requests (p_Rn_In_Id        IN NUMBER,
                                     p_Ur_Out_Ext_Id   IN VARCHAR2);

    FUNCTION Get_Sharing_Response (p_Rn_Id      IN     NUMBER,
                                   p_Wu_Id      IN     NUMBER,
                                   p_Response      OUT r_Sharing_Response,
                                   p_Error         OUT VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Get_Shared_Doc_Attrs (p_Shared_Doc   IN     r_Sharing_Response,
                                   p_Doc_Ndt         OUT NUMBER)
        RETURN t_Doc_Attrs;

    PROCEDURE Reg_Edrato_Request (
        p_Sc_Id         IN     NUMBER,
        p_Atu_Id        IN     VARCHAR2,
        p_Atu_Version   IN     VARCHAR2 DEFAULT NULL,
        p_Date          IN     DATE DEFAULT NULL,
        p_Wu_Id         IN     NUMBER,
        p_Src           IN     VARCHAR2,
        p_Rn_Id            OUT NUMBER);

    FUNCTION Build_Edrato_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Edrato_Resp (p_Response CLOB)
        RETURN r_Administrative_Unit;

    PROCEDURE Reg_Edrato_List_Request (
        p_Sc_Id    IN     NUMBER,
        p_Atu_Id   IN     VARCHAR2,
        p_Bbox     IN     VARCHAR2 DEFAULT NULL,
        p_Point    IN     VARCHAR2 DEFAULT NULL,
        p_Date     IN     DATE DEFAULT NULL,
        p_Wu_Id    IN     NUMBER,
        p_Src      IN     VARCHAR2,
        p_Rn_Id       OUT NUMBER);

    FUNCTION Build_Edrato_List_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Edrato_List_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks;

    PROCEDURE Reg_Street_List_Request (
        p_Sc_Id    IN     NUMBER,
        p_Atu_Id   IN     VARCHAR2,
        p_Bbox     IN     VARCHAR2 DEFAULT NULL,
        p_Point    IN     VARCHAR2 DEFAULT NULL,
        p_Date     IN     DATE DEFAULT NULL,
        p_Wu_Id    IN     NUMBER,
        p_Src      IN     VARCHAR2,
        p_Rn_Id       OUT NUMBER);

    FUNCTION Build_Street_List_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Street_List_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks;

    PROCEDURE Reg_Edra_Request (p_Sc_Id         IN     NUMBER,
                                p_Atu_Id        IN     VARCHAR2,
                                p_Atu_Version   IN     VARCHAR2 DEFAULT NULL,
                                p_Date          IN     DATE DEFAULT NULL,
                                p_Wu_Id         IN     NUMBER,
                                p_Src           IN     VARCHAR2,
                                p_Rn_Id            OUT NUMBER);

    FUNCTION Build_Edra_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Edra_Resp (p_Response CLOB)
        RETURN r_Edra_Member;

    PROCEDURE Reg_Address_Request (p_Sc_Id    IN     NUMBER,
                                   --p_Atu_Id      IN VARCHAR2 DEFAULT NULL,
                                   p_Parent   IN     VARCHAR2,
                                   p_Bbox     IN     VARCHAR2 DEFAULT NULL,
                                   p_Point    IN     VARCHAR2 DEFAULT NULL,
                                   p_Date     IN     DATE DEFAULT NULL,
                                   p_Wu_Id    IN     NUMBER,
                                   p_Src      IN     VARCHAR2,
                                   p_Rn_Id       OUT NUMBER);

    FUNCTION Build_Address_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Address_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks;

    PROCEDURE Reg_Geocoding_Request (
        p_Sc_Id         IN     NUMBER,
        p_Atu_Id        IN     VARCHAR2,
        p_Search_Text   IN     VARCHAR2,
        p_Limit         IN     NUMBER DEFAULT 5,
        p_Similarity    IN     FLOAT DEFAULT 0.5,
        p_Nocache       IN     NUMBER DEFAULT 1,
        p_Register      IN     VARCHAR2 DEFAULT NULL,
        p_Wu_Id         IN     NUMBER,
        p_Src           IN     VARCHAR2,
        p_Rn_Id            OUT NUMBER);

    FUNCTION Build_Geocoding_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Geocoding_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks;

    PROCEDURE Reg_Geocoding_Edrato_Request (
        p_Sc_Id         IN     NUMBER,
        p_Search_Text   IN     VARCHAR2,
        p_Limit         IN     NUMBER DEFAULT 5,
        p_Similarity    IN     FLOAT DEFAULT 0.5,
        p_Nocache       IN     NUMBER DEFAULT 1,
        p_Register      IN     VARCHAR2 DEFAULT NULL,    --V_DDN_EDRA_REGISTER
        p_Wu_Id         IN     NUMBER,
        p_Src           IN     VARCHAR2,
        p_Rn_Id            OUT NUMBER);

    FUNCTION Build_Geocoding_Edrato_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Geocoding_Edrato_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks;
END Api$request_Diia;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DIIA TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DIIA TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DIIA TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DIIA TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DIIA TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DIIA TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DIIA TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_DIIA TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_DIIA
IS
    --------------------------------------------------------------------------
    --Генерація UUID4
    --------------------------------------------------------------------------
    FUNCTION Generate_Req_Uid
        RETURN VARCHAR2
    IS
        l_Uuid     RAW (16);
        l_Result   VARCHAR2 (40);
    BEGIN
        l_Uuid := Sys.DBMS_CRYPTO.Randombytes (16);
        l_Result :=
            (UTL_RAW.Overlay (
                 UTL_RAW.Bit_Or (
                     UTL_RAW.Bit_And (UTL_RAW.SUBSTR (l_Uuid, 7, 1), '0F'),
                     '40'),
                 l_Uuid,
                 7));
        l_Result :=
            LOWER (
                   SUBSTR (l_Result, 1, 8)
                || '-'
                || SUBSTR (l_Result, 9, 4)
                || '-'
                || SUBSTR (l_Result, 13, 4)
                || '-'
                || SUBSTR (l_Result, 17, 4)
                || '-'
                || SUBSTR (l_Result, 21));

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    --                Реєстрація запиту на шерінг
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Sharing_Request (p_Barcode    IN     VARCHAR2,
                                   p_Skip_Pdf   IN     VARCHAR2,
                                   p_Wu_Id      IN     NUMBER,
                                   p_Src        IN     VARCHAR2,
                                   p_Com_Org    IN     NUMBER,
                                   p_Rn_Id         OUT NUMBER)
    IS
        l_Req_Xml       XMLTYPE;
        l_Ur_Id         NUMBER;
        l_Req_Uid       VARCHAR2 (36);
        l_Branch_Id     VARCHAR2 (250);
        l_Ns   CONSTANT VARCHAR2 (100) := 'AcquirersDocumentRequest';
    BEGIN
        l_Req_Uid := Generate_Req_Uid;

        l_Branch_Id :=
            NVL (Ikis_Sys.Ikis_Common.Getopfuparam ('DIIA_BRNCH', p_Com_Org),
                 Ikis_Sys.Ikis_Common.Getopfuparam ('DIIA_BRNCH', 50000));

        SELECT XMLELEMENT (
                   "DiiaAcquirersDocumentRequest1",
                   XMLELEMENT (
                       "DiiaAcquirersDocumentRequest",
                       --
                       XMLELEMENT (
                           "acquirerToken",
                           Xmlattributes (l_Ns AS "xmlns"),
                           Ikis_Sys.Ikis_Common.Getapptparam ('DIIA_TOKEN')),
                       XMLELEMENT ("branchid",
                                   Xmlattributes (l_Ns AS "xmlns"),
                                   l_Branch_Id),
                       XMLELEMENT ("barcode",
                                   Xmlattributes (l_Ns AS "xmlns"),
                                   p_Barcode),
                       XMLELEMENT ("requestd",
                                   Xmlattributes (l_Ns AS "xmlns"),
                                   l_Req_Uid),
                       XMLELEMENT ("skipPdf",
                                   Xmlattributes (l_Ns AS "xmlns"),
                                   DECODE (p_Skip_Pdf, 'T', 'true', 'false'))))
          INTO l_Req_Xml
          FROM DUAL;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Sharing,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => l_Req_Uid,
            p_Ur_Body        => l_Req_Xml.Getclobval,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);
    END;

    ---------------------------------------------------------------------------
    --                Обробка відповіді на запит шерінгу
    ---------------------------------------------------------------------------
    PROCEDURE Handle_Sharing_Resp (p_Ur_Id      IN     NUMBER,
                                   p_Response   IN     CLOB,
                                   p_Error      IN OUT VARCHAR2)
    IS
        l_Success   VARCHAR2 (10);
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            RETURN;
        END IF;

        UPDATE Uxp_Request r
           SET r.Ur_Body = NULL
         WHERE r.Ur_Id = p_Ur_Id;

            SELECT Success, Error
              INTO l_Success, p_Error
              FROM XMLTABLE (
                       Xmlnamespaces (DEFAULT 'AcquirersDocumentRequest'),
                       '/*'
                       PASSING Xmltype (p_Response)
                       COLUMNS --
                               Success    VARCHAR2 (10) PATH 'success',
                               Error      CLOB PATH 'error');
    END;

    ---------------------------------------------------------------------------
    --     Звязування вихідного запиту на шерінг з
    --     вхідним запитом від Дії
    ---------------------------------------------------------------------------
    PROCEDURE Link_Sharing_Requests (p_Rn_In_Id        IN NUMBER,
                                     p_Ur_Out_Ext_Id   IN VARCHAR2)
    IS
        l_Ur_Out_Id   NUMBER;
        l_Ur_In_Id    NUMBER;
    BEGIN
        --Отримуємо ІД вихідного запиту
        SELECT r.Ur_Id
          INTO l_Ur_Out_Id
          FROM Uxp_Request r
         WHERE r.Ur_Ext_Id = p_Ur_Out_Ext_Id AND r.Ur_Urt = c_Urt_Sharing;

        --Отримуємо ІД вхідного запиту
        SELECT r.Ur_Id
          INTO l_Ur_In_Id
          FROM Uxp_Request r
         WHERE r.Ur_Rn = p_Rn_In_Id;

        --Повязуємо запити
        Api$uxp_Request.Save_Request_Link (p_Url_Ur       => l_Ur_In_Id,
                                           p_Url_Root     => l_Ur_Out_Id,
                                           p_Url_Parent   => l_Ur_Out_Id);
    END;

    ---------------------------------------------------------------------------
    --     Отримання відповіді на шерінг
    ---------------------------------------------------------------------------
    FUNCTION Get_Sharing_Response (p_Rn_Id      IN     NUMBER,
                                   p_Wu_Id      IN     NUMBER,
                                   p_Response      OUT r_Sharing_Response,
                                   p_Error         OUT VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Ur_Out_Id       NUMBER;
        l_Ur_Out_St       Uxp_Request.Ur_St%TYPE;
        l_Ur_Out_Wu       NUMBER;
        l_Ur_In_Id        NUMBER;
        l_Ur_In_St        Uxp_Request.Ur_St%TYPE;
        l_Ur_In_Request   CLOB;
        l_Encoded_Data    CLOB;
        l_Decoded_Data    CLOB;
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

        IF l_Ur_Out_Wu <> p_Wu_Id
        THEN
            Raise_Application_Error (
                -20000,
                'Отримати результат шерінгу може лише користувач, що надіслав запит');
        END IF;

        IF l_Ur_Out_St IN
               (Api$uxp_Request.c_Ur_St_New, Api$uxp_Request.c_Ur_St_Err)
        THEN
            RETURN FALSE;
        END IF;

        --Отримуємо ІД вхідного запиту
        SELECT MAX (l.Url_Ur)
          INTO l_Ur_In_Id
          FROM Uxp_Req_Links l
         WHERE l.Url_Root = l_Ur_Out_Id;

        IF l_Ur_In_Id IS NULL
        THEN
            RETURN FALSE;
        END IF;

        --Отримуємо стан та вміст вхідного запиту
        SELECT r.Ur_St, r.Ur_Soap_Req, r.Ur_Error
          INTO l_Ur_In_St, l_Ur_In_Request, p_Error
          FROM Uxp_Request r
         WHERE r.Ur_Id = l_Ur_In_Id;

        IF l_Ur_In_St = Api$uxp_Request.c_Ur_St_Err
        THEN
            RETURN FALSE;
        END IF;

                 SELECT Encoded_Data,
                        File_Name,
                        Tools.Decode_Base64 (File_Data),
                        Tools.Decode_Base64 (File_Sign)
                   INTO l_Encoded_Data,
                        p_Response.File_Name,
                        p_Response.File_Data,
                        p_Response.File_Sign
                   FROM XMLTABLE (
                            Xmlnamespaces (
                                'http://schemas.xmlsoap.org/soap/envelope/'
                                    AS "soapenv"),
                            '/*/soapenv:Body/DiiaAcquirersDocumentResponse'
                            PASSING Xmltype (l_Ur_In_Request)
                            COLUMNS Encoded_Data    CLOB PATH 'encodedData',
                                    File_Name       VARCHAR2 (1000) PATH 'fileName',
                                    File_Data       CLOB PATH 'file',
                                    File_Sign       CLOB PATH 'fileSign');

        l_Decoded_Data := Tools.B64_Decode (l_Encoded_Data, 'UTF8');

        CASE
            WHEN LOWER (p_Response.File_Name) LIKE 'internal-passport%'
            THEN
                EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                                  'R_INTERNAL_PASSPORT',
                                                  'dd.mm.yyyy')
                    USING IN l_Decoded_Data, OUT p_Response.Internal_Passport;
            WHEN LOWER (p_Response.File_Name) LIKE 'foreign-passport%'
            THEN
                EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                                  'R_FOREIGN_PASSPORT',
                                                  'dd.mm.yyyy')
                    USING IN l_Decoded_Data, OUT p_Response.Foreign_Passport;
            WHEN LOWER (p_Response.File_Name) LIKE 'taxpayer-card%'
            THEN
                EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                                  'R_TAXPAYER_CARD',
                                                  'dd.mm.yyyy')
                    USING IN l_Decoded_Data, OUT p_Response.Taxpayer_Card;
            WHEN LOWER (p_Response.File_Name) LIKE 'birth-certificate%'
            THEN
                EXECUTE IMMEDIATE Type2jsontable (Package_Name,
                                                  'R_BIRTH_CERTIFICATE',
                                                  'dd.mm.yyyy')
                    USING IN l_Decoded_Data, OUT p_Response.Birth_Certificate;
        END CASE;

        RETURN TRUE;
    END;

    ---------------------------------------------------------------------------
    --  Конвертація даних отриманих за допомогою шерінгу у атрибути документа
    ---------------------------------------------------------------------------
    FUNCTION Get_Shared_Doc_Attrs (p_Shared_Doc   IN     r_Sharing_Response,
                                   p_Doc_Ndt         OUT NUMBER)
        RETURN t_Doc_Attrs
    IS
        l_Doc_Attrs   t_Doc_Attrs;

        PROCEDURE Add_Attr (p_Nda_Id    NUMBER,
                            p_Val_Str   VARCHAR2 DEFAULT NULL,
                            p_Val_Dt    DATE DEFAULT NULL,
                            p_Val_Id    NUMBER DEFAULT NULL)
        IS
        BEGIN
            l_Doc_Attrs.EXTEND ();
            l_Doc_Attrs (l_Doc_Attrs.COUNT).Nda_Id := p_Nda_Id;
            l_Doc_Attrs (l_Doc_Attrs.COUNT).Val_Str := p_Val_Str;
            l_Doc_Attrs (l_Doc_Attrs.COUNT).Val_Dt := p_Val_Dt;
            l_Doc_Attrs (l_Doc_Attrs.COUNT).Val_Id := p_Val_Id;
        END;
    BEGIN
        l_Doc_Attrs := t_Doc_Attrs ();

        CASE
            WHEN LOWER (p_Shared_Doc.File_Name) LIKE 'internal-passport%'
            THEN
                DECLARE
                    l_Pasp   r_Internal_Passport;
                BEGIN
                    p_Doc_Ndt := 7;
                    l_Pasp := p_Shared_Doc.Internal_Passport;
                    Add_Attr (9, p_Val_Str => l_Pasp.Doc_Number);
                    Add_Attr (14, p_Val_Dt => l_Pasp.Issue_Date);
                    Add_Attr (13, p_Val_Str => l_Pasp.Department);
                    Add_Attr (810, p_Val_Str => l_Pasp.Record_Number);
                    Add_Attr (10, p_Val_Dt => l_Pasp.Expiration_Date);
                    Add_Attr (607, p_Val_Dt => l_Pasp.Birthday);

                    Add_Attr (2376, p_Val_Str => l_Pasp.Last_Name_Ua);
                    Add_Attr (2377, p_Val_Str => l_Pasp.First_Name_Ua);
                    Add_Attr (2378, p_Val_Str => l_Pasp.Middle_Name_Ua);
                END;
            WHEN LOWER (p_Shared_Doc.File_Name) LIKE 'foreign-passport%'
            THEN
                DECLARE
                    l_Pasp   r_Foreign_Passport;
                BEGIN
                    p_Doc_Ndt := 11;
                    l_Pasp := p_Shared_Doc.Foreign_Passport;
                    Add_Attr (33, p_Val_Str => l_Pasp.Doc_Number);
                    Add_Attr (34, p_Val_Dt => l_Pasp.Issue_Date);
                    Add_Attr (35, p_Val_Str => l_Pasp.Department_Ua);
                    Add_Attr (38, p_Val_Dt => l_Pasp.Expiration_Date);
                    Add_Attr (2329, p_Val_Dt => l_Pasp.Birthday);

                    Add_Attr (2385, p_Val_Str => l_Pasp.Last_Name_Ua);
                    Add_Attr (2386, p_Val_Str => l_Pasp.First_Name_Ua);
                    Add_Attr (2387, p_Val_Str => l_Pasp.Middle_Name_Ua);
                END;
            WHEN LOWER (p_Shared_Doc.File_Name) LIKE 'taxpayer-card%'
            THEN
                DECLARE
                    l_Ipn   r_Taxpayer_Card;
                BEGIN
                    p_Doc_Ndt := 5;
                    l_Ipn := p_Shared_Doc.Taxpayer_Card;
                    Add_Attr (1, p_Val_Str => l_Ipn.Doc_Number);
                END;
            WHEN LOWER (p_Shared_Doc.File_Name) LIKE 'birth-certificate%'
            THEN
                DECLARE
                    l_Crt   r_Birth_Certificate;
                BEGIN
                    p_Doc_Ndt := 37;
                    l_Crt := p_Shared_Doc.Birth_Certificate;
                    Add_Attr (
                        90,
                        p_Val_Str   =>
                            l_Crt.Document.Serie || l_Crt.Document.Number_);
                    Add_Attr (94, p_Val_Dt => l_Crt.Document.Issue_Date);
                    Add_Attr (93, p_Val_Str => l_Crt.Document.Department);
                    Add_Attr (
                        92,
                        p_Val_Str   =>
                               l_Crt.Child.Last_Name
                            || ' '
                            || l_Crt.Child.First_Name
                            || ' '
                            || l_Crt.Child.Middle_Name);
                    Add_Attr (91, p_Val_Dt => l_Crt.Child.Birth_Date);
                    Add_Attr (679,
                              p_Val_Str   => l_Crt.Parents.Mother.Full_Name);
                    Add_Attr (680,
                              p_Val_Str   => l_Crt.Parents.Father.Full_Name);
                END;
        END CASE;

        RETURN l_Doc_Attrs;
    END;

    ---------------------------------------------------------------------------
    -- Допоміжні утіліти по парсингу даних від ЄДРА
    -- #111341
    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Identifier (p_Source IN OUT NOCOPY XMLTYPE)
        RETURN r_Identifier
    IS
        l_Result   r_Identifier;
    BEGIN
               SELECT *
                 INTO l_Result
                 FROM XMLTABLE (
                          '/*/*'
                          PASSING p_Source
                          COLUMNS Local_Id      VARCHAR2 (100) PATH '*:localId',
                                  Namespace     VARCHAR2 (100) PATH '*:namespace',
                                  Version_Id    VARCHAR2 (25) PATH '*:versionId');

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Xlink (p_Source IN OUT NOCOPY XMLTYPE)
        RETURN r_Edra_Xlink
    IS
        l_Result   r_Edra_Xlink;
    BEGIN
        FOR Rec
            IN (  SELECT *
                    FROM XMLTABLE (
                             '/*'
                             PASSING p_Source
                             COLUMNS Href     VARCHAR2 (1000) PATH '@*:href',
                                     Title    VARCHAR2 (1000) PATH '@*:title'))
        LOOP
            l_Result.Href := Rec.Href;
            l_Result.Title := Rec.Title;

            IF INSTR (Rec.Href, '?id=') > 0
            THEN
                l_Result.Atu_Id :=
                    SUBSTR (Rec.Href, INSTR (Rec.Href, '?id=') + 4);
            END IF;
        END LOOP;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Xlinks (p_Source IN OUT NOCOPY XMLTYPE)
        RETURN t_Edra_Xlinks
    IS
        l_Result   t_Edra_Xlinks;
    BEGIN
        FOR Rec
            IN (  SELECT *
                    FROM XMLTABLE (
                             '/*'
                             PASSING p_Source
                             COLUMNS Href     VARCHAR2 (1000) PATH '@*:href',
                                     Title    VARCHAR2 (1000) PATH '@*:title'))
        LOOP
            IF l_Result IS NULL
            THEN
                l_Result := t_Edra_Xlinks ();
            END IF;

            l_Result.EXTEND;
            l_Result (l_Result.COUNT).Href := Rec.Href;
            l_Result (l_Result.COUNT).Title := Rec.Title;

            IF INSTR (Rec.Href, '?id=') > 0
            THEN
                l_Result (l_Result.COUNT).Atu_Id :=
                    SUBSTR (Rec.Href, INSTR (Rec.Href, '?id=') + 4);
            END IF;
        END LOOP;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Geographical_Name (p_Source IN OUT NOCOPY XMLTYPE)
        RETURN r_Geographical_Name
    IS
        l_Result   r_Geographical_Name;
    BEGIN
        FOR Rec
            IN (               SELECT *
                                 FROM XMLTABLE (
                                          '/*/*'
                                          PASSING p_Source
                                          COLUMNS Language_             VARCHAR2 (3) PATH '*:language',
                                                  Nativeness            VARCHAR2 (100) PATH '*:nativeness/@*:title',
                                                  Name_Status           VARCHAR2 (100) PATH '*:nameStatus/@*:title',
                                                  Source_Of_Name        VARCHAR2 (100) PATH '*:sourceOfName',
                                                  Pronunciation         XMLTYPE PATH '*:pronunciation',
                                                  Spelling              XMLTYPE PATH '*:spelling',
                                                  Grammatical_Gender    VARCHAR2 (100) PATH '*:grammaticalGender/@*:title',
                                                  Grammatical_Number    VARCHAR2 (100) PATH '*:grammaticalNumber/@*:title'))
        LOOP
            l_Result.Language_ := Rec.Language_;
            l_Result.Nativeness := Rec.Nativeness;
            l_Result.Name_Status := Rec.Name_Status;
            l_Result.Source_Of_Name := Rec.Source_Of_Name;
            l_Result.Grammatical_Gender := Rec.Grammatical_Gender;
            l_Result.Grammatical_Number := Rec.Grammatical_Number;

            IF Rec.Pronunciation IS NOT NULL
            THEN
                BEGIN
                                         SELECT *
                                           INTO l_Result.Pronunciation
                                           FROM XMLTABLE (
                                                    '/*/*'
                                                    PASSING Rec.Pronunciation
                                                    COLUMNS Pronunciation_Sound_Link    VARCHAR2 (100) PATH '*:pronunciationSoundLink',
                                                            Pronunciation_Ipa           VARCHAR2 (100) PATH '*:pronunciationIPA');
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;
                END;
            END IF;

            IF Rec.Spelling IS NOT NULL
            THEN
                BEGIN
                                       SELECT *
                                         INTO l_Result.Spelling
                                         FROM XMLTABLE (
                                                  '/*/*'
                                                  PASSING Rec.Spelling
                                                  COLUMNS Text                      VARCHAR2 (100) PATH '*:text',
                                                          Script                    VARCHAR2 (100) PATH '*:script',
                                                          Transliteration_Scheme    VARCHAR2 (100) PATH '*:transliterationScheme');
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;
                END;
            END IF;
        END LOOP;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Geographical_Position (
        p_Source   IN OUT NOCOPY XMLTYPE)
        RETURN t_Geographic_Position
    IS
        l_Result   t_Geographic_Position;
    BEGIN
        FOR Rec
            IN (          SELECT *
                            FROM XMLTABLE (
                                     '/*/*'
                                     PASSING p_Source
                                     COLUMNS Geometry         XMLTYPE PATH '*:geometry',
                                             Specification    XMLTYPE PATH '*:specification',
                                             Method           XMLTYPE PATH '*:method',
                                             Default_         VARCHAR2 (10) PATH '*:default'))
        LOOP
            IF l_Result IS NULL
            THEN
                l_Result := t_Geographic_Position ();
            END IF;

            l_Result.EXTEND;
            l_Result (l_Result.COUNT).Geometry := Rec.Geometry;
            l_Result (l_Result.COUNT).Specification :=
                Parse_Edra_Xlink (Rec.Specification);
            l_Result (l_Result.COUNT).Method := Parse_Edra_Xlink (Rec.Method);
            l_Result (l_Result.COUNT).Default_ := Rec.Default_;
        END LOOP;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Residence_Of_Authority (
        p_Source   IN OUT NOCOPY XMLTYPE)
        RETURN r_Residence_Of_Authority
    IS
        l_Result   r_Residence_Of_Authority;
    BEGIN
        FOR Rec
            IN (  SELECT *
                    FROM XMLTABLE ('/*/*'
                                   PASSING p_Source
                                   COLUMNS Name_    XMLTYPE PATH '*:name'))
        LOOP
            l_Result.Name_ := Parse_Edra_Geographical_Name (Rec.Name_);
        END LOOP;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Address (p_Source IN OUT NOCOPY XMLTYPE)
        RETURN t_Address
    IS
        l_Result   t_Address;
    BEGIN
        FOR Rec
            IN (                   SELECT *
                                     FROM XMLTABLE (
                                              '/*'
                                              PASSING p_Source
                                              COLUMNS Id                        VARCHAR2 (250) PATH '@*:id',
                                                      Inspire_Id                XMLTYPE PATH '*:inspireId',
                                                      Alternative_Identifier    VARCHAR2 (1000) PATH '*:alternativeIdentifier',
                                                      Position                  XMLTYPE PATH '*:position',
                                                      Status                    XMLTYPE PATH '*:status',
                                                      Locator                   XMLTYPE PATH '*:locator',
                                                      Valid_From                VARCHAR2 (10) PATH '*:validFrom',
                                                      Valid_To                  VARCHAR2 (10) PATH '*:validTo',
                                                      Begin_Lifespan_Version    VARCHAR2 (19) PATH '*:beginLifespanVersion',
                                                      End_Lifespan_Version      VARCHAR2 (19) PATH '*:endLifespanVersion',
                                                      Parcel                    XMLTYPE PATH '*:parcel',
                                                      Parent_Address            XMLTYPE PATH '*:parentAddress',
                                                      Building                  XMLTYPE PATH '*:building',
                                                      Component                 XMLTYPE PATH '*:component'))
        LOOP
            DECLARE
                l_Item   r_Address;
            BEGIN
                l_Item.Id := Rec.Id;
                l_Item.Inspire_Id := Parse_Edra_Identifier (Rec.Inspire_Id);
                l_Item.Alternative_Identifier := Rec.Alternative_Identifier;
                l_Item.Position :=
                    Parse_Edra_Geographical_Position (Rec.Position);
                l_Item.Status := Parse_Edra_Xlink (Rec.Status);
                l_Item.Valid_From := TO_DATE (Rec.Valid_From, 'yyyy-mm-dd');
                l_Item.Valid_To := TO_DATE (Rec.Valid_To, 'yyyy-mm-dd');
                l_Item.Begin_Lifespan_Version :=
                    TO_DATE (Rec.Begin_Lifespan_Version,
                             'yyyy-mm-dd hh24:mi:ss');
                l_Item.End_Lifespan_Version :=
                    TO_DATE (Rec.End_Lifespan_Version,
                             'yyyy-mm-dd hh24:mi:ss');
                l_Item.Parcel := Parse_Edra_Xlinks (Rec.Parcel);
                l_Item.Parent_Address :=
                    Parse_Edra_Xlink (Rec.Parent_Address);
                l_Item.Building := Parse_Edra_Xlinks (Rec.Building);
                l_Item.Component := Parse_Edra_Xlinks (Rec.Component);

                IF Rec.Locator IS NOT NULL
                THEN
                    FOR Rec_Locator
                        IN (            SELECT *
                                          FROM XMLTABLE (
                                                   '/*/*'
                                                   PASSING Rec.Locator
                                                   COLUMNS Level_             XMLTYPE PATH '*:level',
                                                           Within_Scope_Of    XMLTYPE PATH '*:withinScopeOf',
                                                           Designator         XMLTYPE PATH '*:designator',
                                                           Name_              XMLTYPE PATH '*:name'))
                    LOOP
                        DECLARE
                            l_Item_Locator   r_Address_Locator;
                        BEGIN
                            l_Item_Locator.Level_ :=
                                Parse_Edra_Xlink (Rec_Locator.Level_);
                            l_Item_Locator.Within_Scope_Of :=
                                Parse_Edra_Xlink (
                                    Rec_Locator.Within_Scope_Of);

                            IF Rec_Locator.Designator IS NOT NULL
                            THEN
                                FOR Rec_Designator
                                    IN (       SELECT *
                                                 FROM XMLTABLE (
                                                          '/*/*'
                                                          PASSING Rec_Locator.Designator
                                                          COLUMNS Designator    VARCHAR2 (100) PATH '*:designator',
                                                                  Type_         XMLTYPE PATH '*:type'))
                                LOOP
                                    IF l_Item_Locator.Designator IS NULL
                                    THEN
                                        l_Item_Locator.Designator :=
                                            t_Locator_Designator ();
                                    END IF;

                                    l_Item_Locator.Designator.EXTEND;
                                    l_Item_Locator.Designator (
                                        l_Item_Locator.Designator.COUNT).Designator :=
                                        Rec_Designator.Designator;
                                    l_Item_Locator.Designator (
                                        l_Item_Locator.Designator.COUNT).Type_ :=
                                        Parse_Edra_Xlink (
                                            Rec_Designator.Type_);
                                END LOOP;
                            END IF;

                            IF Rec_Locator.Name_ IS NOT NULL
                            THEN
                                FOR Rec_Name
                                    IN (  SELECT *
                                            FROM XMLTABLE (
                                                     '/*/*'
                                                     PASSING Rec_Locator.Name_
                                                     COLUMNS Name_    XMLTYPE PATH '*:name',
                                                             Type_    XMLTYPE PATH '*:type'))
                                LOOP
                                    IF l_Item_Locator.Name_ IS NULL
                                    THEN
                                        l_Item_Locator.Name_ :=
                                            t_Locator_Name ();
                                    END IF;

                                    l_Item_Locator.Name_.EXTEND;
                                    l_Item_Locator.Name_ (
                                        l_Item_Locator.Name_.COUNT).Name_ :=
                                        Parse_Edra_Geographical_Name (
                                            Rec_Name.Name_);
                                    l_Item_Locator.Name_ (
                                        l_Item_Locator.Name_.COUNT).Type_ :=
                                        Parse_Edra_Xlink (Rec_Name.Type_);
                                END LOOP;
                            END IF;

                            IF l_Item.Locator IS NULL
                            THEN
                                l_Item.Locator := t_Address_Locator ();
                            END IF;

                            l_Item.Locator.EXTEND;
                            l_Item.Locator (l_Item.Locator.COUNT) :=
                                l_Item_Locator;
                        END;
                    END LOOP;
                END IF;

                IF l_Result IS NULL
                THEN
                    l_Result := t_Address ();
                END IF;

                l_Result.EXTEND;
                l_Result (l_Result.COUNT) := l_Item;
            END;
        END LOOP;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Thoroughfare_Name (p_Source IN OUT NOCOPY XMLTYPE)
        RETURN t_Thoroughfare_Name
    IS
        l_Result   t_Thoroughfare_Name;
    BEGIN
        FOR Rec
            IN (                   SELECT *
                                     FROM XMLTABLE (
                                              '/*'
                                              PASSING p_Source
                                              COLUMNS Id                        VARCHAR2 (250) PATH '@*:id',
                                                      Inspire_Id                XMLTYPE PATH '*:inspireId',
                                                      Alternative_Identifier    VARCHAR2 (1000) PATH '*:alternativeIdentifier',
                                                      Position                  XMLTYPE PATH '*:position',
                                                      Valid_From                VARCHAR2 (10) PATH '*:validFrom',
                                                      Valid_To                  VARCHAR2 (10) PATH '*:validTo',
                                                      Begin_Lifespan_Version    VARCHAR2 (19) PATH '*:beginLifespanVersion',
                                                      End_Lifespan_Version      VARCHAR2 (19) PATH '*:endLifespanVersion',
                                                      Status                    XMLTYPE PATH '*:status',
                                                      Situated_Within           XMLTYPE PATH '*:situatedWithin',
                                                      Name_                     XMLTYPE PATH '*:name',
                                                      Transport_Link            XMLTYPE PATH '*:transportLink'))
        LOOP
            DECLARE
                l_Item   r_Thoroughfare_Name;
            BEGIN
                l_Item.Id := Rec.Id;
                l_Item.Inspire_Id := Parse_Edra_Identifier (Rec.Inspire_Id);
                l_Item.Alternative_Identifier := Rec.Alternative_Identifier;
                l_Item.Position :=
                    Parse_Edra_Geographical_Position (Rec.Position);
                l_Item.Valid_From := TO_DATE (Rec.Valid_From, 'yyyy-mm-dd');
                l_Item.Valid_To := TO_DATE (Rec.Valid_To, 'yyyy-mm-dd');
                l_Item.Begin_Lifespan_Version :=
                    TO_DATE (Rec.Begin_Lifespan_Version,
                             'yyyy-mm-dd hh24:mi:ss');
                l_Item.End_Lifespan_Version :=
                    TO_DATE (Rec.End_Lifespan_Version,
                             'yyyy-mm-dd hh24:mi:ss');
                l_Item.Status := Parse_Edra_Xlink (Rec.Status);
                l_Item.Situated_Within :=
                    Parse_Edra_Xlinks (Rec.Situated_Within);
                l_Item.Transport_Link :=
                    Parse_Edra_Xlinks (Rec.Transport_Link);

                IF Rec.Name_ IS NOT NULL
                THEN
                    FOR Rec_Name
                        IN (       SELECT *
                                     FROM XMLTABLE (
                                              '/*/*'
                                              PASSING Rec.Name_
                                              COLUMNS Name_         XMLTYPE PATH '*:name',
                                                      Name_Parts    XMLTYPE PATH '*:nameParts'))
                    LOOP
                        DECLARE
                            l_Item_Name   r_Thoroughfare_Name_Value;
                        BEGIN
                            l_Item_Name.Name_ :=
                                Parse_Edra_Geographical_Name (Rec_Name.Name_);

                            IF Rec_Name.Name_Parts IS NOT NULL
                            THEN
                                FOR Rec_Name_Parts
                                    IN (  SELECT *
                                            FROM XMLTABLE (
                                                     '/*/*'
                                                     PASSING Rec_Name.Name_Parts
                                                     COLUMNS Part     VARCHAR2 (100) PATH '*:part',
                                                             Type_    XMLTYPE PATH '*:type'))
                                LOOP
                                    IF l_Item_Name.Name_Parts IS NULL
                                    THEN
                                        l_Item_Name.Name_Parts :=
                                            t_Name_Parts ();
                                    END IF;

                                    l_Item_Name.Name_Parts.EXTEND;
                                    l_Item_Name.Name_Parts (
                                        l_Item_Name.Name_Parts.COUNT).Part :=
                                        Rec_Name_Parts.Part;
                                    l_Item_Name.Name_Parts (
                                        l_Item_Name.Name_Parts.COUNT).Type_ :=
                                        Parse_Edra_Xlink (
                                            Rec_Name_Parts.Type_);
                                END LOOP;
                            END IF;

                            IF l_Item.Name_ IS NULL
                            THEN
                                l_Item.Name_ := t_Thoroughfare_Name_Value ();
                            END IF;

                            l_Item.Name_.EXTEND;
                            l_Item.Name_ (l_Item.Name_.COUNT) := l_Item_Name;
                        END;
                    END LOOP;
                END IF;

                IF l_Result IS NULL
                THEN
                    l_Result := t_Thoroughfare_Name ();
                END IF;

                l_Result.EXTEND;
                l_Result (l_Result.COUNT) := l_Item;
            END;
        END LOOP;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Address_Area_Name (p_Source IN OUT NOCOPY XMLTYPE)
        RETURN t_Address_Area_Name
    IS
        l_Result   t_Address_Area_Name;
    BEGIN
        FOR Rec
            IN (                   SELECT *
                                     FROM XMLTABLE (
                                              '/*'
                                              PASSING p_Source
                                              COLUMNS Id                        VARCHAR2 (250) PATH '@*:id',
                                                      Inspire_Id                XMLTYPE PATH '*:inspireId',
                                                      Alternative_Identifier    VARCHAR2 (1000) PATH '*:alternativeIdentifier',
                                                      Position                  XMLTYPE PATH '*:position',
                                                      Valid_From                VARCHAR2 (10) PATH '*:validFrom',
                                                      Valid_To                  VARCHAR2 (10) PATH '*:validTo',
                                                      Begin_Lifespan_Version    VARCHAR2 (19) PATH '*:beginLifespanVersion',
                                                      End_Lifespan_Version      VARCHAR2 (19) PATH '*:endLifespanVersion',
                                                      Status                    XMLTYPE PATH '*:status',
                                                      Situated_Within           XMLTYPE PATH '*:situatedWithin',
                                                      Name_                     XMLTYPE PATH '*:name',
                                                      Named_Place               XMLTYPE PATH '*:namedPlace'))
        LOOP
            DECLARE
                l_Item   r_Address_Area_Name;
            BEGIN
                l_Item.Id := Rec.Id;
                l_Item.Inspire_Id := Parse_Edra_Identifier (Rec.Inspire_Id);
                l_Item.Alternative_Identifier := Rec.Alternative_Identifier;
                l_Item.Position :=
                    Parse_Edra_Geographical_Position (Rec.Position);
                l_Item.Valid_From := TO_DATE (Rec.Valid_From, 'yyyy-mm-dd');
                l_Item.Valid_To := TO_DATE (Rec.Valid_To, 'yyyy-mm-dd');
                l_Item.Begin_Lifespan_Version :=
                    TO_DATE (Rec.Begin_Lifespan_Version,
                             'yyyy-mm-dd hh24:mi:ss');
                l_Item.End_Lifespan_Version :=
                    TO_DATE (Rec.End_Lifespan_Version,
                             'yyyy-mm-dd hh24:mi:ss');
                l_Item.Status := Parse_Edra_Xlink (Rec.Status);
                l_Item.Situated_Within :=
                    Parse_Edra_Xlinks (Rec.Situated_Within);
                l_Item.Name_ := Parse_Edra_Geographical_Name (Rec.Name_);
                l_Item.Named_Place := Parse_Edra_Xlinks (Rec.Named_Place);

                IF l_Result IS NULL
                THEN
                    l_Result := t_Address_Area_Name ();
                END IF;

                l_Result.EXTEND;
                l_Result (l_Result.COUNT) := l_Item;
            END;
        END LOOP;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    FUNCTION Parse_Edra_Admin_Unit_Name (p_Source IN OUT NOCOPY XMLTYPE)
        RETURN t_Admin_Unit_Name
    IS
        l_Result   t_Admin_Unit_Name;
    BEGIN
        FOR Rec
            IN (                   SELECT *
                                     FROM XMLTABLE (
                                              '/*'
                                              PASSING p_Source
                                              COLUMNS Id                        VARCHAR2 (250) PATH '@*:id',
                                                      Inspire_Id                XMLTYPE PATH '*:inspireId',
                                                      Alternative_Identifier    VARCHAR2 (1000) PATH '*:alternativeIdentifier',
                                                      Position                  XMLTYPE PATH '*:position',
                                                      Valid_From                VARCHAR2 (10) PATH '*:validFrom',
                                                      Valid_To                  VARCHAR2 (10) PATH '*:validTo',
                                                      Begin_Lifespan_Version    VARCHAR2 (19) PATH '*:beginLifespanVersion',
                                                      End_Lifespan_Version      VARCHAR2 (19) PATH '*:endLifespanVersion',
                                                      Status                    XMLTYPE PATH '*:status',
                                                      Situated_Within           XMLTYPE PATH '*:situatedWithin',
                                                      Name_                     XMLTYPE PATH '*:name',
                                                      Level_                    XMLTYPE PATH '*:level',
                                                      Admin_Unit                XMLTYPE PATH '*:adminUnit'))
        LOOP
            DECLARE
                l_Item   r_Admin_Unit_Name;
            BEGIN
                l_Item.Id := Rec.Id;
                l_Item.Inspire_Id := Parse_Edra_Identifier (Rec.Inspire_Id);
                l_Item.Alternative_Identifier := Rec.Alternative_Identifier;
                l_Item.Position :=
                    Parse_Edra_Geographical_Position (Rec.Position);
                l_Item.Valid_From := TO_DATE (Rec.Valid_From, 'yyyy-mm-dd');
                l_Item.Valid_To := TO_DATE (Rec.Valid_To, 'yyyy-mm-dd');
                l_Item.Begin_Lifespan_Version :=
                    TO_DATE (Rec.Begin_Lifespan_Version,
                             'yyyy-mm-dd hh24:mi:ss');
                l_Item.End_Lifespan_Version :=
                    TO_DATE (Rec.End_Lifespan_Version,
                             'yyyy-mm-dd hh24:mi:ss');
                l_Item.Status := Parse_Edra_Xlink (Rec.Status);
                l_Item.Situated_Within :=
                    Parse_Edra_Xlinks (Rec.Situated_Within);
                l_Item.Name_ := Parse_Edra_Geographical_Name (Rec.Name_);
                l_Item.Level_ := Parse_Edra_Xlink (Rec.Level_);
                l_Item.Admin_Unit := Parse_Edra_Xlinks (Rec.Admin_Unit);

                IF l_Result IS NULL
                THEN
                    l_Result := t_Admin_Unit_Name ();
                END IF;

                l_Result.EXTEND;
                l_Result (l_Result.COUNT) := l_Item;
            END;
        END LOOP;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання інформації про адміністративно-територіальну одиницю або територію територіальної громади
    -- #111341
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Edrato_Request (
        p_Sc_Id         IN     NUMBER,
        p_Atu_Id        IN     VARCHAR2,
        p_Atu_Version   IN     VARCHAR2 DEFAULT NULL,
        p_Date          IN     DATE DEFAULT NULL,
        p_Wu_Id         IN     NUMBER,
        p_Src           IN     VARCHAR2,
        p_Rn_Id            OUT NUMBER)
    IS
        l_Req_Uid   VARCHAR2 (36);
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
    BEGIN
        IF     p_Atu_Id NOT LIKE 'UA.ATU._.%'
           AND NOT REGEXP_LIKE (p_Atu_Id, '^[0-9]+$')
        THEN
            Raise_Application_Error (
                -20000,
                'Підтримується лише ідентифікатори адміністративно-територіальних одиниць (UA.ATU.*.*)');
        END IF;

        l_Req_Uid := Generate_Req_Uid;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Edrato,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => l_Req_Uid,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        IF p_Sc_Id IS NOT NULL
        THEN
            Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                        p_Rnp_Rn           => p_Rn_Id,
                                        p_Rnp_Sc           => p_Sc_Id,
                                        p_Rnp_Inn          => NULL,
                                        p_Rnp_Ndt          => NULL,
                                        p_Rnp_Doc_Seria    => NULL,
                                        p_Rnp_Doc_Number   => NULL,
                                        p_Rnp_Sc_Unique    => NULL,
                                        p_New_Id           => l_Rnp_Id);
        END IF;

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Num,
                                         p_Rnc_Val_String   => p_Atu_Id);

        IF p_Atu_Version IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn           => p_Rn_Id,
                p_Rnc_Pt           => c_Pt_Version,
                p_Rnc_Val_String   => p_Atu_Version);
        END IF;

        IF p_Date IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                             p_Rnc_Pt       => c_Pt_Date,
                                             p_Rnc_Val_Dt   => p_Date);
        END IF;
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання інформації про адміністративно-територіальну одиницю або територію територіальної громади
    -- #111341
    ---------------------------------------------------------------------------
    FUNCTION Build_Edrato_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id         NUMBER;
        l_Atu_Id        VARCHAR2 (100);
        l_Atu_Version   VARCHAR2 (100);
        l_View_Dt       DATE;
        l_Req_Xml       XMLTYPE;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        l_Atu_Id :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Num);
        l_Atu_Version :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Version);
        l_View_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Rn_Id,
                                               p_Rnc_Pt   => c_Pt_Date);

        SELECT XMLELEMENT (
                   "edrato",
                   Xmlattributes (
                       'http://www.dataaccess.com/webservicesserver/'
                           AS "xmlns"),
                   XMLELEMENT (
                       "id",
                          l_Atu_Id
                       || CASE
                              WHEN l_Atu_Version IS NOT NULL
                              THEN
                                  ':' || l_Atu_Version
                          END),
                   CASE
                       WHEN l_View_Dt IS NOT NULL
                       THEN
                           XMLELEMENT ("date",
                                       TO_CHAR (l_View_Dt, 'yyyy-mm-dd'))
                   END)
          INTO l_Req_Xml
          FROM DUAL;

        RETURN l_Req_Xml.Getclobval;
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит
    -- Отримання інформації про адміністративно-територіальну одиницю або територію територіальної громади
    -- #111341
    ----------------------------------------------------------------------
    FUNCTION Parse_Edrato_Resp (p_Response CLOB)
        RETURN r_Administrative_Unit
    IS
        l_Resp   r_Administrative_Unit;
    BEGIN
        FOR Rec
            IN (                   SELECT *
                                     FROM XMLTABLE (
                                              '*:AdministrativeUnit'
                                              PASSING Xmltype.Createxml (p_Response)
                                              COLUMNS Id                        VARCHAR2 (250) PATH '@*:id',
                                                      National_Code             VARCHAR2 (100) PATH '*:nationalCode',
                                                      Inspire_Id                XMLTYPE PATH '*:inspireId',
                                                      National_Level            VARCHAR2 (10) PATH '*:nationalLevel/@*:title',
                                                      National_Level_Name       VARCHAR2 (100) PATH '*:nationalLevelName',
                                                      Country                   VARCHAR2 (2) PATH '*:country',
                                                      Name_                     XMLTYPE PATH '*:name',
                                                      Residence_Of_Authority    XMLTYPE PATH '*:residenceOfAuthority',
                                                      Begin_Lifespan_Version    VARCHAR2 (19) PATH '*:beginLifespanVersion',
                                                      End_Lifespan_Version      VARCHAR2 (19) PATH '*:endLifespanVersion',
                                                      Valid_From                VARCHAR2 (10) PATH '*:validFrom',
                                                      Valid_To                  VARCHAR2 (10) PATH '*:validTo',
                                                      Lower_Level_Unit          XMLTYPE PATH '*:lowerLevelUnit',
                                                      Upper_Level_Unit          XMLTYPE PATH '*:upperLevelUnit',
                                                      Administered_By           XMLTYPE PATH '*:administeredBy',
                                                      Boundary                  XMLTYPE PATH '*:boundary'))
        LOOP
            l_Resp.Id := Rec.Id;
            l_Resp.National_Code := Rec.National_Code;
            l_Resp.Inspire_Id := Parse_Edra_Identifier (Rec.Inspire_Id);
            l_Resp.National_Level := Rec.National_Level;
            l_Resp.National_Level_Name := Rec.National_Level_Name;
            l_Resp.Country := Rec.Country;
            l_Resp.Name_ := Parse_Edra_Geographical_Name (Rec.Name_);
            l_Resp.Residence_Of_Authority :=
                Parse_Edra_Residence_Of_Authority (
                    Rec.Residence_Of_Authority);
            l_Resp.Begin_Lifespan_Version :=
                TO_DATE (Rec.Begin_Lifespan_Version, 'yyyy-mm-dd hh24:mi:ss');
            l_Resp.End_Lifespan_Version :=
                TO_DATE (Rec.End_Lifespan_Version, 'yyyy-mm-dd hh24:mi:ss');
            l_Resp.Valid_From := TO_DATE (Rec.Valid_From, 'yyyy-mm-dd');
            l_Resp.Valid_To := TO_DATE (Rec.Valid_To, 'yyyy-mm-dd');
            l_Resp.Lower_Level_Unit :=
                Parse_Edra_Xlinks (Rec.Lower_Level_Unit);
            l_Resp.Upper_Level_Unit :=
                Parse_Edra_Xlinks (Rec.Upper_Level_Unit);
            l_Resp.Administered_By := Parse_Edra_Xlink (Rec.Administered_By);
            l_Resp.Boundary := Parse_Edra_Xlinks (Rec.Boundary);
        END LOOP;

        RETURN l_Resp;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання інформації про адміністративно-територіальну одиницю за глобальним ідентифікатором
    -- #111341
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Edrato_List_Request (
        p_Sc_Id    IN     NUMBER,
        p_Atu_Id   IN     VARCHAR2,
        p_Bbox     IN     VARCHAR2 DEFAULT NULL,
        p_Point    IN     VARCHAR2 DEFAULT NULL,
        p_Date     IN     DATE DEFAULT NULL,
        p_Wu_Id    IN     NUMBER,
        p_Src      IN     VARCHAR2,
        p_Rn_Id       OUT NUMBER)
    IS
        l_Req_Uid   VARCHAR2 (36);
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
    BEGIN
        IF p_Atu_Id NOT LIKE 'UA.ATU._.%'
        THEN
            Raise_Application_Error (
                -20000,
                'Підтримується лише ідентифікатори адміністративно-територіальних одиниць (UA.ATU.*.*)');
        END IF;

        l_Req_Uid := Generate_Req_Uid;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Edrato_List,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => l_Req_Uid,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        IF p_Sc_Id IS NOT NULL
        THEN
            Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                        p_Rnp_Rn           => p_Rn_Id,
                                        p_Rnp_Sc           => p_Sc_Id,
                                        p_Rnp_Inn          => NULL,
                                        p_Rnp_Ndt          => NULL,
                                        p_Rnp_Doc_Seria    => NULL,
                                        p_Rnp_Doc_Number   => NULL,
                                        p_Rnp_Sc_Unique    => NULL,
                                        p_New_Id           => l_Rnp_Id);
        END IF;

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Num,
                                         p_Rnc_Val_String   => p_Atu_Id);

        IF p_Bbox IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                             p_Rnc_Pt           => c_Pt_Bbox,
                                             p_Rnc_Val_String   => p_Bbox);
        END IF;

        IF p_Point IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                             p_Rnc_Pt           => c_Pt_Point,
                                             p_Rnc_Val_String   => p_Point);
        END IF;

        IF p_Date IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                             p_Rnc_Pt       => c_Pt_Date,
                                             p_Rnc_Val_Dt   => p_Date);
        END IF;
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання інформації про адміністративно-територіальну одиницю за глобальним ідентифікатором
    -- #111341
    ---------------------------------------------------------------------------
    FUNCTION Build_Edrato_List_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id     NUMBER;
        l_Atu_Id    VARCHAR2 (100);
        l_Bbox      VARCHAR2 (4000);
        l_Point     VARCHAR2 (1000);
        l_View_Dt   DATE;
        l_Req_Xml   XMLTYPE;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        l_Atu_Id :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Num);
        l_Bbox :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Bbox);
        l_Point :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Point);
        l_View_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Rn_Id,
                                               p_Rnc_Pt   => c_Pt_Date);

        SELECT XMLELEMENT (
                   "edratoList",
                   Xmlattributes (
                       'http://www.dataaccess.com/webservicesserver/'
                           AS "xmlns"),
                   XMLELEMENT ("parent", l_Atu_Id), --Ідентифікатор батківсбкого об'єкта
                   CASE
                       WHEN l_Bbox IS NOT NULL
                       THEN
                           XMLELEMENT ("bbox", l_Bbox) --Полігон у форматі WKT
                   END,
                   CASE
                       WHEN l_Point IS NOT NULL
                       THEN
                           XMLELEMENT ("point", l_Point) --Точка у форматі WKT
                   END,
                   CASE
                       WHEN l_View_Dt IS NOT NULL
                       THEN
                           XMLELEMENT ("date",
                                       TO_CHAR (l_View_Dt, 'yyyy-mm-dd'))
                   END)
          INTO l_Req_Xml
          FROM DUAL;

        RETURN l_Req_Xml.Getclobval;
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит
    -- Отримання інформації про адміністративно-територіальну одиницю за глобальним ідентифікатором
    -- #111341
    ----------------------------------------------------------------------
    FUNCTION Parse_Edrato_List_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks
    IS
        l_Resp   t_Edra_Xlinks;
    BEGIN
        FOR Rec
            IN (   SELECT *
                     FROM XMLTABLE ('*:edratoList'
                                    PASSING Xmltype.Createxml (p_Response)
                                    COLUMNS Edrato    XMLTYPE PATH '*:edrato'))
        LOOP
            l_Resp := Parse_Edra_Xlinks (Rec.Edrato);
        END LOOP;

        RETURN l_Resp;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання списку вулиць за ідентифікатором вищого рівня
    -- #111341
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Street_List_Request (
        p_Sc_Id    IN     NUMBER,
        p_Atu_Id   IN     VARCHAR2,
        p_Bbox     IN     VARCHAR2 DEFAULT NULL,
        p_Point    IN     VARCHAR2 DEFAULT NULL,
        p_Date     IN     DATE DEFAULT NULL,
        p_Wu_Id    IN     NUMBER,
        p_Src      IN     VARCHAR2,
        p_Rn_Id       OUT NUMBER)
    IS
        l_Req_Uid   VARCHAR2 (36);
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
    BEGIN
        IF p_Atu_Id NOT LIKE 'UA.ATU._.%'
        THEN
            Raise_Application_Error (
                -20000,
                'Підтримується лише ідентифікатори адміністративно-територіальних одиниць (UA.ATU.*.*)');
        END IF;

        l_Req_Uid := Generate_Req_Uid;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Street_List,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => l_Req_Uid,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        IF p_Sc_Id IS NOT NULL
        THEN
            Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                        p_Rnp_Rn           => p_Rn_Id,
                                        p_Rnp_Sc           => p_Sc_Id,
                                        p_Rnp_Inn          => NULL,
                                        p_Rnp_Ndt          => NULL,
                                        p_Rnp_Doc_Seria    => NULL,
                                        p_Rnp_Doc_Number   => NULL,
                                        p_Rnp_Sc_Unique    => NULL,
                                        p_New_Id           => l_Rnp_Id);
        END IF;

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Num,
                                         p_Rnc_Val_String   => p_Atu_Id);

        IF p_Bbox IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                             p_Rnc_Pt           => c_Pt_Bbox,
                                             p_Rnc_Val_String   => p_Bbox);
        END IF;

        IF p_Point IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                             p_Rnc_Pt           => c_Pt_Point,
                                             p_Rnc_Val_String   => p_Point);
        END IF;

        IF p_Date IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                             p_Rnc_Pt       => c_Pt_Date,
                                             p_Rnc_Val_Dt   => p_Date);
        END IF;
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання списку вулиць за ідентифікатором вищого рівня
    -- #111341
    ---------------------------------------------------------------------------
    FUNCTION Build_Street_List_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id     NUMBER;
        l_Atu_Id    VARCHAR2 (100);
        l_Bbox      VARCHAR2 (4000);
        l_Point     VARCHAR2 (1000);
        l_View_Dt   DATE;
        l_Req_Xml   XMLTYPE;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        l_Atu_Id :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Num);
        l_Bbox :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Bbox);
        l_Point :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Point);
        l_View_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Rn_Id,
                                               p_Rnc_Pt   => c_Pt_Date);

        SELECT XMLELEMENT (
                   "streetList",
                   Xmlattributes (
                       'http://www.dataaccess.com/webservicesserver/'
                           AS "xmlns"),
                   XMLELEMENT ("parent", l_Atu_Id), --Ідентифікатор батківсбкого об'єкта
                   CASE
                       WHEN l_Bbox IS NOT NULL
                       THEN
                           XMLELEMENT ("bbox", l_Bbox) --Полігон у форматі WKT
                   END,
                   CASE
                       WHEN l_Point IS NOT NULL
                       THEN
                           XMLELEMENT ("point", l_Point) --Точка у форматі WKT
                   END,
                   CASE
                       WHEN l_View_Dt IS NOT NULL
                       THEN
                           XMLELEMENT ("date",
                                       TO_CHAR (l_View_Dt, 'yyyy-mm-dd'))
                   END)
          INTO l_Req_Xml
          FROM DUAL;

        RETURN l_Req_Xml.Getclobval;
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит
    -- Отримання списку вулиць за ідентифікатором вищого рівня
    -- #111341
    ----------------------------------------------------------------------
    FUNCTION Parse_Street_List_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks
    IS
        l_Resp   t_Edra_Xlinks;
    BEGIN
        FOR Rec
            IN (   SELECT *
                     FROM XMLTABLE ('*:streetList'
                                    PASSING Xmltype.Createxml (p_Response)
                                    COLUMNS Street    XMLTYPE PATH '*:street'))
        LOOP
            l_Resp := Parse_Edra_Xlinks (Rec.Street);
        END LOOP;

        RETURN l_Resp;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання з ЄДРА об’єкту за глобальним ідентіфікатором
    -- #111341
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Edra_Request (p_Sc_Id         IN     NUMBER,
                                p_Atu_Id        IN     VARCHAR2,
                                p_Atu_Version   IN     VARCHAR2 DEFAULT NULL,
                                p_Date          IN     DATE DEFAULT NULL,
                                p_Wu_Id         IN     NUMBER,
                                p_Src           IN     VARCHAR2,
                                p_Rn_Id            OUT NUMBER)
    IS
        l_Req_Uid   VARCHAR2 (36);
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
    BEGIN
        l_Req_Uid := Generate_Req_Uid;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Edra,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => l_Req_Uid,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        IF p_Sc_Id IS NOT NULL
        THEN
            Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                        p_Rnp_Rn           => p_Rn_Id,
                                        p_Rnp_Sc           => p_Sc_Id,
                                        p_Rnp_Inn          => NULL,
                                        p_Rnp_Ndt          => NULL,
                                        p_Rnp_Doc_Seria    => NULL,
                                        p_Rnp_Doc_Number   => NULL,
                                        p_Rnp_Sc_Unique    => NULL,
                                        p_New_Id           => l_Rnp_Id);
        END IF;

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Num,
                                         p_Rnc_Val_String   => p_Atu_Id);

        IF p_Atu_Version IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn           => p_Rn_Id,
                p_Rnc_Pt           => c_Pt_Version,
                p_Rnc_Val_String   => p_Atu_Version);
        END IF;

        IF p_Date IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                             p_Rnc_Pt       => c_Pt_Date,
                                             p_Rnc_Val_Dt   => p_Date);
        END IF;
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання з ЄДРА об’єкту за глобальним ідентіфікатором
    -- #111341
    ---------------------------------------------------------------------------
    FUNCTION Build_Edra_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id         NUMBER;
        l_Atu_Id        VARCHAR2 (100);
        l_Atu_Version   VARCHAR2 (100);
        l_View_Dt       DATE;
        l_Req_Xml       XMLTYPE;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        l_Atu_Id :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Num);
        l_Atu_Version :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Version);
        l_View_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Rn_Id,
                                               p_Rnc_Pt   => c_Pt_Date);

        SELECT XMLELEMENT (
                   "edra",
                   Xmlattributes (
                       'http://www.dataaccess.com/webservicesserver/'
                           AS "xmlns"),
                   XMLELEMENT (
                       "id",
                          l_Atu_Id
                       || CASE
                              WHEN l_Atu_Version IS NOT NULL
                              THEN
                                  ':' || l_Atu_Version
                          END),
                   CASE
                       WHEN l_View_Dt IS NOT NULL
                       THEN
                           XMLELEMENT ("date",
                                       TO_CHAR (l_View_Dt, 'yyyy-mm-dd'))
                   END)
          INTO l_Req_Xml
          FROM DUAL;

        RETURN l_Req_Xml.Getclobval;
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит
    -- Отримання з ЄДРА об’єкту за глобальним ідентіфікатором
    -- #111341
    ----------------------------------------------------------------------
    FUNCTION Parse_Edra_Resp (p_Response CLOB)
        RETURN r_Edra_Member
    IS
        l_Resp   r_Edra_Member;
    BEGIN
        FOR Rec
            IN (              SELECT *
                                FROM XMLTABLE (
                                         '*:member'
                                         PASSING Xmltype.Createxml (p_Response)
                                         COLUMNS Address              XMLTYPE PATH '*:Address',
                                                 Thoroughfare_Name    XMLTYPE PATH '*:ThoroughfareName',
                                                 Address_Area_Name    XMLTYPE PATH '*:AddressAreaName',
                                                 Admin_Unit_Name      XMLTYPE PATH '*:AdminUnitName'))
        LOOP
            l_Resp.Address := Parse_Edra_Address (Rec.Address);
            l_Resp.Thoroughfare_Name :=
                Parse_Edra_Thoroughfare_Name (Rec.Thoroughfare_Name);
            l_Resp.Address_Area_Name :=
                Parse_Edra_Address_Area_Name (Rec.Address_Area_Name);
            l_Resp.Admin_Unit_Name :=
                Parse_Edra_Admin_Unit_Name (Rec.Admin_Unit_Name);
        END LOOP;

        RETURN l_Resp;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання адреси за ідентифікатором
    -- #111341
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Address_Request (p_Sc_Id    IN     NUMBER,
                                   --p_Atu_Id      IN VARCHAR2 DEFAULT NULL,
                                   p_Parent   IN     VARCHAR2,
                                   p_Bbox     IN     VARCHAR2 DEFAULT NULL,
                                   p_Point    IN     VARCHAR2 DEFAULT NULL,
                                   p_Date     IN     DATE DEFAULT NULL,
                                   p_Wu_Id    IN     NUMBER,
                                   p_Src      IN     VARCHAR2,
                                   p_Rn_Id       OUT NUMBER)
    IS
        l_Req_Uid   VARCHAR2 (36);
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
    BEGIN
        --Якщо виконувати пошук за ідентифікатором вулиці то буде повертатися тип даних r_Edra_Member (інформація про обєкт)
        /*IF p_Atu_Id NOT LIKE 'UA.ADR.B.%' THEN
          Raise_Application_Error(-20000,
                                  'Підтримується лише ідентифікатори адресс (UA.ADR.B.*)');
        END IF;*/
        IF p_Parent NOT LIKE 'UA.ADR._.%'
        THEN
            Raise_Application_Error (
                -20000,
                'Підтримується лише ідентифікатори групи адресс (UA.ADR.*.*)');
        END IF;

        l_Req_Uid := Generate_Req_Uid;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Address,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => l_Req_Uid,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        IF p_Sc_Id IS NOT NULL
        THEN
            Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                        p_Rnp_Rn           => p_Rn_Id,
                                        p_Rnp_Sc           => p_Sc_Id,
                                        p_Rnp_Inn          => NULL,
                                        p_Rnp_Ndt          => NULL,
                                        p_Rnp_Doc_Seria    => NULL,
                                        p_Rnp_Doc_Number   => NULL,
                                        p_Rnp_Sc_Unique    => NULL,
                                        p_New_Id           => l_Rnp_Id);
        END IF;

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Num,
                                         p_Rnc_Val_String   => p_Parent);

        IF p_Bbox IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                             p_Rnc_Pt           => c_Pt_Bbox,
                                             p_Rnc_Val_String   => p_Bbox);
        END IF;

        IF p_Point IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                             p_Rnc_Pt           => c_Pt_Point,
                                             p_Rnc_Val_String   => p_Point);
        END IF;

        IF p_Date IS NOT NULL
        THEN
            Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                             p_Rnc_Pt       => c_Pt_Date,
                                             p_Rnc_Val_Dt   => p_Date);
        END IF;
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання адреси за ідентифікатором
    -- #111341
    ---------------------------------------------------------------------------
    FUNCTION Build_Address_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id     NUMBER;
        l_Atu_Id    VARCHAR2 (100);
        l_Bbox      VARCHAR2 (4000);
        l_Point     VARCHAR2 (1000);
        l_View_Dt   DATE;
        l_Req_Xml   XMLTYPE;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        l_Atu_Id :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Num);
        l_Bbox :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Bbox);
        l_Point :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Point);
        l_View_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Rn_Id,
                                               p_Rnc_Pt   => c_Pt_Date);

        SELECT XMLELEMENT (
                   "address",
                   Xmlattributes (
                       'http://www.dataaccess.com/webservicesserver/'
                           AS "xmlns"),
                   --Xmlelement("id", p_Atu_Id),--Ідентифікатор адреси
                   XMLELEMENT ("parent", l_Atu_Id), --Ідентифікатор об'єкта вищого рівня
                   CASE
                       WHEN l_Bbox IS NOT NULL
                       THEN
                           XMLELEMENT ("bbox", l_Bbox) --Полігон у форматі WKT
                   END,
                   CASE
                       WHEN l_Point IS NOT NULL
                       THEN
                           XMLELEMENT ("point", l_Point) --Точка у форматі WKT
                   END,
                   CASE
                       WHEN l_View_Dt IS NOT NULL
                       THEN
                           XMLELEMENT ("date",
                                       TO_CHAR (l_View_Dt, 'yyyy-mm-dd'))
                   END)
          INTO l_Req_Xml
          FROM DUAL;

        RETURN l_Req_Xml.Getclobval;
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит
    -- Отримання адреси за ідентифікатором
    -- #111341
    ----------------------------------------------------------------------
    FUNCTION Parse_Address_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks
    IS
        l_Resp   t_Edra_Xlinks;
    BEGIN
        FOR Rec
            IN (    SELECT *
                      FROM XMLTABLE ('*:addressList'
                                     PASSING Xmltype.Createxml (p_Response)
                                     COLUMNS Address    XMLTYPE PATH '*:address'))
        LOOP
            l_Resp := Parse_Edra_Xlinks (Rec.Address);
        END LOOP;

        RETURN l_Resp;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання інформації за повнотекстовим пошуком в межах населеного пункту з вказанням типу об’єкта
    -- #111341
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Geocoding_Request (
        p_Sc_Id         IN     NUMBER,
        p_Atu_Id        IN     VARCHAR2,
        p_Search_Text   IN     VARCHAR2,
        p_Limit         IN     NUMBER DEFAULT 5,
        p_Similarity    IN     FLOAT DEFAULT 0.5,
        p_Nocache       IN     NUMBER DEFAULT 1,
        p_Register      IN     VARCHAR2 DEFAULT NULL,    --V_DDN_EDRA_REGISTER
        p_Wu_Id         IN     NUMBER,
        p_Src           IN     VARCHAR2,
        p_Rn_Id            OUT NUMBER)
    IS
        l_Req_Uid   VARCHAR2 (36);
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
    BEGIN
        l_Req_Uid := Generate_Req_Uid;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Geocoding,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => l_Req_Uid,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        IF p_Sc_Id IS NOT NULL
        THEN
            Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                        p_Rnp_Rn           => p_Rn_Id,
                                        p_Rnp_Sc           => p_Sc_Id,
                                        p_Rnp_Inn          => NULL,
                                        p_Rnp_Ndt          => NULL,
                                        p_Rnp_Doc_Seria    => NULL,
                                        p_Rnp_Doc_Number   => NULL,
                                        p_Rnp_Sc_Unique    => NULL,
                                        p_New_Id           => l_Rnp_Id);
        END IF;

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Num,
                                         p_Rnc_Val_String   => p_Atu_Id);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Text,
                                         p_Rnc_Val_String   => p_Search_Text);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Comment,
                                         p_Rnc_Val_String   => p_Register);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => p_Rn_Id,
                                         p_Rnc_Pt        => c_Pt_Count,
                                         p_Rnc_Val_Int   => p_Limit);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => p_Rn_Id,
                                         p_Rnc_Pt        => c_Pt_Percent,
                                         p_Rnc_Val_Int   => p_Similarity);
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання інформації за повнотекстовим пошуком в межах населеного пункту з вказанням типу об’єкта
    -- #111341
    ---------------------------------------------------------------------------
    FUNCTION Build_Geocoding_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id        NUMBER;
        l_Atu_Id       VARCHAR2 (100);
        l_Text         VARCHAR2 (4000);
        l_Register     VARCHAR2 (10);
        l_Limit        NUMBER;
        l_Similarity   NUMBER;
        l_Req_Xml      XMLTYPE;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        l_Atu_Id :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Num);
        l_Text :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Text);
        l_Register :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Comment);
        l_Limit :=
            Api$request.Get_Rn_Common_Info_Int (p_Rnc_Rn   => l_Rn_Id,
                                                p_Rnc_Pt   => c_Pt_Count);
        l_Similarity :=
            Api$request.Get_Rn_Common_Info_Int (p_Rnc_Rn   => l_Rn_Id,
                                                p_Rnc_Pt   => c_Pt_Percent);

        IF l_Similarity > 1
        THEN
            l_Similarity := l_Similarity / 100;
        END IF;

        IF l_Similarity > 1
        THEN
            l_Similarity := 1;
        END IF;

        SELECT XMLELEMENT (
                   "geocoding",
                   Xmlattributes (
                       'http://www.dataaccess.com/webservicesserver/'
                           AS "xmlns"),
                   XMLELEMENT ("id", l_Atu_Id),
                   XMLELEMENT ("searchtext", l_Text),
                   CASE
                       WHEN l_Limit IS NOT NULL
                       THEN
                           XMLELEMENT ("limit", l_Limit)
                   END,
                   CASE
                       WHEN l_Similarity IS NOT NULL
                       THEN
                           XMLELEMENT ("similarity", l_Similarity)
                   END,
                   XMLELEMENT ("nocache", '1'),
                   CASE
                       WHEN l_Register IS NOT NULL
                       THEN
                           XMLELEMENT ("register", l_Register)
                   END)
          INTO l_Req_Xml
          FROM DUAL;

        RETURN l_Req_Xml.Getclobval;
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит
    -- Отримання інформації за повнотекстовим пошуком в межах населеного пункту з вказанням типу об’єкта
    -- #111341
    ----------------------------------------------------------------------
    FUNCTION Parse_Geocoding_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks
    IS
        l_Resp   t_Edra_Xlinks;
    BEGIN
        FOR Rec
            IN (   SELECT *
                     FROM XMLTABLE ('*:geocoding'
                                    PASSING Xmltype.Createxml (p_Response)
                                    COLUMNS Street    XMLTYPE PATH '*:street'))
        LOOP
            l_Resp := Parse_Edra_Xlinks (Rec.Street);
        END LOOP;

        RETURN l_Resp;
    END;

    ---------------------------------------------------------------------------
    -- Реєстрація запиту на
    -- Отримання інформації про адміністративно-територіальну одиницю за текстовим запитом із зазначенням типів об’єктів
    -- #111341
    ---------------------------------------------------------------------------
    PROCEDURE Reg_Geocoding_Edrato_Request (
        p_Sc_Id         IN     NUMBER,
        p_Search_Text   IN     VARCHAR2,
        p_Limit         IN     NUMBER DEFAULT 5,
        p_Similarity    IN     FLOAT DEFAULT 0.5,
        p_Nocache       IN     NUMBER DEFAULT 1,
        p_Register      IN     VARCHAR2 DEFAULT NULL,    --V_DDN_EDRA_REGISTER
        p_Wu_Id         IN     NUMBER,
        p_Src           IN     VARCHAR2,
        p_Rn_Id            OUT NUMBER)
    IS
        l_Req_Uid   VARCHAR2 (36);
        l_Ur_Id     NUMBER;
        l_Rnp_Id    NUMBER;
    BEGIN
        l_Req_Uid := Generate_Req_Uid;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Urt_Geocoding_Edrato,
            p_Ur_Create_Wu   => p_Wu_Id,
            p_Ur_Ext_Id      => l_Req_Uid,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => NULL,
            p_Rn_Src         => p_Src,
            p_Rn_Hs_Ins      => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_New_Rn_Id      => p_Rn_Id);

        IF p_Sc_Id IS NOT NULL
        THEN
            Api$request.Save_Rn_Person (p_Rnp_Id           => NULL,
                                        p_Rnp_Rn           => p_Rn_Id,
                                        p_Rnp_Sc           => p_Sc_Id,
                                        p_Rnp_Inn          => NULL,
                                        p_Rnp_Ndt          => NULL,
                                        p_Rnp_Doc_Seria    => NULL,
                                        p_Rnp_Doc_Number   => NULL,
                                        p_Rnp_Sc_Unique    => NULL,
                                        p_New_Id           => l_Rnp_Id);
        END IF;

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Text,
                                         p_Rnc_Val_String   => p_Search_Text);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => p_Rn_Id,
                                         p_Rnc_Pt           => c_Pt_Comment,
                                         p_Rnc_Val_String   => p_Register);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => p_Rn_Id,
                                         p_Rnc_Pt        => c_Pt_Count,
                                         p_Rnc_Val_Int   => p_Limit);
        Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => p_Rn_Id,
                                         p_Rnc_Pt        => c_Pt_Percent,
                                         p_Rnc_Val_Int   => p_Similarity);
    END;

    ---------------------------------------------------------------------------
    -- Формування даних для запиту на
    -- Отримання інформації про адміністративно-територіальну одиницю за текстовим запитом із зазначенням типів об’єктів
    -- #111341
    ---------------------------------------------------------------------------
    FUNCTION Build_Geocoding_Edrato_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Rn_Id        NUMBER;
        l_Text         VARCHAR2 (4000);
        l_Register     VARCHAR2 (10);
        l_Limit        NUMBER;
        l_Similarity   NUMBER;
        l_Req_Xml      XMLTYPE;
    BEGIN
        l_Rn_Id := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Ur_Id);

        l_Text :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Text);
        l_Register :=
            Api$request.Get_Rn_Common_Info_String (p_Rnc_Rn   => l_Rn_Id,
                                                   p_Rnc_Pt   => c_Pt_Comment);
        l_Limit :=
            Api$request.Get_Rn_Common_Info_Int (p_Rnc_Rn   => l_Rn_Id,
                                                p_Rnc_Pt   => c_Pt_Count);
        l_Similarity :=
            Api$request.Get_Rn_Common_Info_Int (p_Rnc_Rn   => l_Rn_Id,
                                                p_Rnc_Pt   => c_Pt_Percent);

        IF l_Similarity > 1
        THEN
            l_Similarity := 1;
        END IF;

        SELECT XMLELEMENT (
                   "geocodingEdrato",
                   Xmlattributes (
                       'http://www.dataaccess.com/webservicesserver/'
                           AS "xmlns"),
                   XMLELEMENT ("searchtext", l_Text),
                   CASE
                       WHEN l_Limit IS NOT NULL
                       THEN
                           XMLELEMENT ("limit", l_Limit)
                   END,
                   CASE
                       WHEN l_Similarity IS NOT NULL
                       THEN
                           XMLELEMENT ("similarity", l_Similarity)
                   END,
                   XMLELEMENT ("nocache", '1'),
                   CASE
                       WHEN l_Register IS NOT NULL
                       THEN
                           XMLELEMENT ("register", l_Register)
                   END)
          INTO l_Req_Xml
          FROM DUAL;

        RETURN l_Req_Xml.Getclobval;
    END;

    ----------------------------------------------------------------------
    -- Парсинг відповіді на запит
    -- Отримання інформації про адміністративно-територіальну одиницю за текстовим запитом із зазначенням типів об’єктів
    -- #111341
    ----------------------------------------------------------------------
    FUNCTION Parse_Geocoding_Edrato_Resp (p_Response CLOB)
        RETURN t_Edra_Xlinks
    IS
        l_Resp   t_Edra_Xlinks;
    BEGIN
        FOR Rec
            IN (   SELECT *
                     FROM XMLTABLE ('*:geocodingEdrato'
                                    PASSING Xmltype.Createxml (p_Response)
                                    COLUMNS Edrato    XMLTYPE PATH '*:edrato'))
        LOOP
            l_Resp := Parse_Edra_Xlinks (Rec.Edrato);
        END LOOP;

        RETURN l_Resp;
    END;
END Api$request_Diia;
/