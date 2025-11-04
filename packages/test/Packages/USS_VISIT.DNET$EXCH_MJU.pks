/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$EXCH_MJU
IS
    -- Author  : KELATEV
    -- Created : 07.01.2025 12:22:45
    -- Purpose :

    Package_Name             CONSTANT VARCHAR2 (100) := 'DNET$EXCH_MJU';

    c_Src_Dracs              CONSTANT VARCHAR2 (10) := 'DRACS';
    c_Ap_Tp                  CONSTANT VARCHAR2 (10) := 'V';
    c_Service5               CONSTANT NUMBER := 250;
    c_Service6               CONSTANT NUMBER := 862;

    c_Err_Code_Fail          CONSTANT NUMBER := -20400;
    c_Err_Code_Not_Allowed   CONSTANT NUMBER := -20403;

    TYPE r_Official_Servant_Info IS RECORD
    (
        Authority_Name      VARCHAR2 (250),
        Office_Branch_Id    VARCHAR2 (1000),
        Family_Name         VARCHAR2 (250),
        Given_Name          VARCHAR2 (250),
        Patronymic_Name     VARCHAR2 (250)
    );

    TYPE r_Official_Servant_Info2 IS RECORD
    (
        Family_Name        VARCHAR2 (250),
        Given_Name         VARCHAR2 (250),
        Patronymic_Name    VARCHAR2 (250)
    );

    TYPE r_Act_Record_Of_Birth IS RECORD
    (
        Act_Record_Number        VARCHAR2 (250),
        Issue_Date               DATE,
        Office_Branch_Id         VARCHAR2 (1000),
        Official_Servant_Info    r_Official_Servant_Info2
    );

    TYPE r_Cbi IS RECORD
    (
        Cb_Issuer          VARCHAR2 (1000),
        Cb_Issue_Date      DATE,
        Document_Serial    VARCHAR2 (50),
        Document_Number    VARCHAR2 (50)
    );

    TYPE r_Notification_Channels IS RECORD
    (
        Notification_Phone    VARCHAR2 (250),
        Notification_Email    VARCHAR2 (250)
    );

    TYPE r_Child_Info IS RECORD
    (
        Family_Name        VARCHAR2 (250),
        Given_Name         VARCHAR2 (250),
        Patronymic_Name    VARCHAR2 (250),
        Birth_Date         DATE,
        Gender             VARCHAR2 (250)
    );

    TYPE r_Child_Born IS RECORD
    (
        Children_Were_Born    NUMBER,
        Child_Born_Order      NUMBER,
        Child_Born_Alive      VARCHAR2 (10)
    );

    TYPE r_Registration_Address IS RECORD
    (
        Country             VARCHAR2 (250),
        Country_Id          NUMBER,
        Postbox             VARCHAR2 (250),
        Region              VARCHAR2 (250),
        Region_Id           NUMBER,
        District            VARCHAR2 (250),
        District_Id         NUMBER,
        Cityname            VARCHAR2 (250),
        Cityid              NUMBER,
        City_Koatuu         VARCHAR2 (250),
        City_Type           VARCHAR2 (250),
        City_Type_Id        NUMBER,
        Street_Name         VARCHAR2 (250),
        Street_Id           NUMBER,
        Street_Type_Name    VARCHAR2 (250),
        Street_Type_Id      NUMBER,
        Building_Number     VARCHAR2 (250),
        Building_Part       VARCHAR2 (250),
        Apartment           VARCHAR2 (250)
    );

    TYPE r_Identity_Document IS RECORD
    (
        Passport_Type_Id    NUMBER,
        Document_Serial     VARCHAR2 (200),
        Document_Number     VARCHAR2 (100),
        Issue_Date          DATE,
        Issuer_Id           VARCHAR2 (1000),
        Expiry_Date         DATE
    );

    TYPE r_Parent_Info IS RECORD
    (
        Family_Name             VARCHAR2 (250),
        Given_Name              VARCHAR2 (250),
        Patronymic_Name         VARCHAR2 (250),
        Gender                  VARCHAR2 (250),
        Birth_Date              DATE,
        Citizenship             VARCHAR2 (10),
        Citizen_Country         VARCHAR2 (10),
        Registration_Address    r_Registration_Address,
        Identity_Document       r_Identity_Document,
        Unzr                    VARCHAR2 (100),
        Rnokpp                  VARCHAR2 (100),
        Rnokpp_Refusal          VARCHAR2 (100)
    );

    TYPE r_Cbs_Post_Channel_Info IS RECORD
    (
        Postbox                       VARCHAR2 (100),
        Postal_Service_Branch_Name    VARCHAR2 (1000)
    );

    TYPE r_Cbs_Bank_Channel_Info IS RECORD
    (
        Cbs_Bank_Account    VARCHAR2 (250),
        Cbs_Bank_Name       VARCHAR2 (1000),
        Cbs_Bank_Edrpou     VARCHAR2 (100),
        Cbs_Bank_Mfo        VARCHAR2 (100)
    );

    TYPE r_Child_Born_Stipend IS RECORD
    (
        Cbs_Parent_Recipient     VARCHAR2 (250),
        Cbs_Channel              VARCHAR2 (20),
        Cbs_Post_Channel_Info    r_Cbs_Post_Channel_Info,
        Cbs_Bank_Channel_Info    r_Cbs_Bank_Channel_Info
    );

    TYPE r_Certificate_Of_Birth IS RECORD
    (
        Cb_Issuer          VARCHAR2 (250),
        Cb_Issue_Date      DATE,
        Document_Serial    VARCHAR2 (250),
        Document_Number    VARCHAR2 (250),
        Ar_Date            DATE,
        Ar_Number          VARCHAR2 (250),
        Ar_Issuer          VARCHAR2 (1000)
    );

    TYPE r_Other_Childr_Info IS RECORD
    (
        Family_Name             VARCHAR2 (250),
        Given_Name              VARCHAR2 (250),
        Patronymic_Name         VARCHAR2 (250),
        Birth_Date              DATE,
        Certificate_Of_Birth    r_Certificate_Of_Birth
    );

    TYPE t_Large_Family_Info_List IS TABLE OF r_Other_Childr_Info;

    TYPE r_Lf_Child_Names IS RECORD
    (
        Family_Name        VARCHAR2 (250),
        Given_Name         VARCHAR2 (250),
        Patronymic_Name    VARCHAR2 (250)
    );

    TYPE t_Lf_Child_Names_List IS TABLE OF r_Lf_Child_Names;

    TYPE r_Lf_Certificates IS RECORD
    (
        Lf_Cert_Parents    VARCHAR2 (10),
        Lf_Cert_Child      VARCHAR2 (10),
        Lf_Child_Names     t_Lf_Child_Names_List
    );

    TYPE r_Application_Data IS RECORD
    (
        Request_Id               VARCHAR2 (250),
        Application_Date         DATE,
        Typeservice1             VARCHAR2 (10),
        Typeservice2             VARCHAR2 (10),
        Typeservice3             VARCHAR2 (10),
        Typeservice4             VARCHAR2 (10),
        Typeservice5             VARCHAR2 (10),
        Typeservice6             VARCHAR2 (10),
        Typeservice7             VARCHAR2 (10),
        Official_Servant_Info    r_Official_Servant_Info,
        Act_Record_Of_Birth      r_Act_Record_Of_Birth,
        Cbi                      r_Cbi,
        Rnokpp                   VARCHAR2 (100),
        Unzr                     VARCHAR2 (100),
        Notification_Channels    r_Notification_Channels,
        Child_Info               r_Child_Info,
        Child_Citizenship        VARCHAR2 (10),
        Citizen_Country          VARCHAR2 (10),
        Child_Born               r_Child_Born,
        Mother_Info              r_Parent_Info,
        Father_Info              r_Parent_Info,
        Child_Born_Stipend       r_Child_Born_Stipend,
        Large_Family_Info        t_Large_Family_Info_List,
        Lf_Certificates          r_Lf_Certificates
    );

    TYPE r_Application_Result_Response IS RECORD
    (
        Request_Id                VARCHAR2 (250),
        Request_Receive_Status    NUMBER,
        Fault_Details             VARCHAR2 (4000)
    );

    --METHODS
    FUNCTION Parse_Application_Data_Req (p_Request_Body IN CLOB)
        RETURN r_Application_Data;

    FUNCTION Handle_Dracs_Application_Request (p_Request_Id     IN NUMBER,
                                               p_Request_Body   IN CLOB)
        RETURN CLOB;

    PROCEDURE Reg_Dracs_Application_Result_Req (
        p_Ap_Id     IN NUMBER,
        p_Ap_St     IN VARCHAR2,
        p_Message   IN VARCHAR2 DEFAULT NULL);

    FUNCTION Get_Dracs_Application_Result_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Handle_Dracs_Application_Result_Req (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);
END Dnet$exch_Mju;
/


GRANT EXECUTE ON USS_VISIT.DNET$EXCH_MJU TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:00:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$EXCH_MJU
IS
    --Атрибути докумена
    TYPE r_Ap_Document_Attr IS RECORD
    (
        Apda_Id            Ap_Document_Attr.Apda_Id%TYPE,
        Apda_Nda           Ap_Document_Attr.Apda_Nda%TYPE,
        Apda_Val_String    Ap_Document_Attr.Apda_Val_String%TYPE,
        Apda_Val_Int       Ap_Document_Attr.Apda_Val_Int%TYPE,
        Apda_Val_Dt        Ap_Document_Attr.Apda_Val_Dt%TYPE,
        Apda_Val_Id        Ap_Document_Attr.Apda_Val_Id%TYPE,
        Apda_Val_Sum       VARCHAR2 (30),
        Apda_Apd           Ap_Document_Attr.Apda_Apd%TYPE
    );

    TYPE t_Ap_Document_Attrs IS TABLE OF r_Ap_Document_Attr;

    FUNCTION Parse_Application_Parent_Info (p_Req      IN XMLTYPE,
                                            p_Frm_Dt   IN VARCHAR2)
        RETURN r_Parent_Info
    IS
        l_Data   r_Parent_Info;
    BEGIN
                     SELECT Clear_Name (Family_Name),
                            Clear_Name (Given_Name),
                            Clear_Name (Patronymic_Name),
                            Tools.Try_Parse_Dt (Birth_Date, p_Frm_Dt)      Birth_Date,
                            Gender,
                            Citizenship,
                            Citizen_Country,
                            Country,
                            Country_Id,
                            Postbox,
                            Region,
                            Region_Id,
                            District,
                            District_Id,
                            Cityname,
                            Cityid,
                            City_Koatuu,
                            City_Type,
                            City_Type_Id,
                            Street_Name,
                            Street_Id,
                            Street_Type_Name,
                            Street_Type_Id,
                            Building_Number,
                            Building_Part,
                            Apartment,
                            Passport_Type_Id,
                            Document_Serial,
                            Document_Number,
                            Tools.Try_Parse_Dt (Issue_Date, p_Frm_Dt)      Issue_Date,
                            Issuer_Id,
                            Tools.Try_Parse_Dt (Expiry_Date, p_Frm_Dt)     Expiry_Date,
                            Unzr,
                            Rnokpp,
                            Rnokpp_Refusal
                       INTO l_Data.Family_Name,
                            l_Data.Given_Name,
                            l_Data.Patronymic_Name,
                            l_Data.Birth_Date,
                            l_Data.Gender,
                            l_Data.Citizenship,
                            l_Data.Citizen_Country,
                            l_Data.Registration_Address.Country,
                            l_Data.Registration_Address.Country_Id,
                            l_Data.Registration_Address.Postbox,
                            l_Data.Registration_Address.Region,
                            l_Data.Registration_Address.Region_Id,
                            l_Data.Registration_Address.District,
                            l_Data.Registration_Address.District_Id,
                            l_Data.Registration_Address.Cityname,
                            l_Data.Registration_Address.Cityid,
                            l_Data.Registration_Address.City_Koatuu,
                            l_Data.Registration_Address.City_Type,
                            l_Data.Registration_Address.City_Type_Id,
                            l_Data.Registration_Address.Street_Name,
                            l_Data.Registration_Address.Street_Id,
                            l_Data.Registration_Address.Street_Type_Name,
                            l_Data.Registration_Address.Street_Type_Id,
                            l_Data.Registration_Address.Building_Number,
                            l_Data.Registration_Address.Building_Part,
                            l_Data.Registration_Address.Apartment,
                            l_Data.Identity_Document.Passport_Type_Id,
                            l_Data.Identity_Document.Document_Serial,
                            l_Data.Identity_Document.Document_Number,
                            l_Data.Identity_Document.Issue_Date,
                            l_Data.Identity_Document.Issuer_Id,
                            l_Data.Identity_Document.Expiry_Date,
                            l_Data.Unzr,
                            l_Data.Rnokpp,
                            l_Data.Rnokpp_Refusal
                       FROM XMLTABLE (
                                '/*'
                                PASSING p_Req
                                COLUMNS Family_Name         VARCHAR2 (250) PATH '*:familyName',
                                        Given_Name          VARCHAR2 (250) PATH '*:givenName',
                                        Patronymic_Name     VARCHAR2 (250) PATH '*:patronymicName',
                                        Birth_Date          VARCHAR2 (20) PATH '*:birthDate',
                                        Gender              VARCHAR2 (250) PATH '*:gender',
                                        Citizenship         VARCHAR2 (10) PATH '*:citizenship',
                                        Citizen_Country     VARCHAR2 (10) PATH '*:citizenCountry',
                                        Country             VARCHAR2 (250) PATH '*:RegistrationAddress/*:Country',
                                        Country_Id          NUMBER PATH '*:RegistrationAddress/*:CountryID',
                                        Postbox             VARCHAR2 (250) PATH '*:RegistrationAddress/*:Postbox',
                                        Region              VARCHAR2 (250) PATH '*:RegistrationAddress/*:Region',
                                        Region_Id           NUMBER PATH '*:RegistrationAddress/*:RegionID',
                                        District            VARCHAR2 (250) PATH '*:RegistrationAddress/*:District',
                                        District_Id         NUMBER PATH '*:RegistrationAddress/*:DistrictID',
                                        Cityname            VARCHAR2 (250) PATH '*:RegistrationAddress/*:CityName',
                                        Cityid              NUMBER PATH '*:RegistrationAddress/*:CityID',
                                        City_Koatuu         VARCHAR2 (250) PATH '*:RegistrationAddress/*:CityKOATUU',
                                        City_Type           VARCHAR2 (250) PATH '*:RegistrationAddress/*:CityType',
                                        City_Type_Id        NUMBER PATH '*:RegistrationAddress/*:CityTypeID',
                                        Street_Name         VARCHAR2 (250) PATH '*:RegistrationAddress/*:StreetName',
                                        Street_Id           NUMBER PATH '*:RegistrationAddress/*:StreetID',
                                        Street_Type_Name    VARCHAR2 (250) PATH '*:RegistrationAddress/*:StreetTypeName',
                                        Street_Type_Id      NUMBER PATH '*:RegistrationAddress/*:StreetTypeID',
                                        Building_Number     VARCHAR2 (250) PATH '*:RegistrationAddress/*:BuildingNumber',
                                        Building_Part       VARCHAR2 (250) PATH '*:RegistrationAddress/*:BuildingPart',
                                        Apartment           VARCHAR2 (250) PATH '*:RegistrationAddress/*:Apartment',
                                        Passport_Type_Id    NUMBER PATH '*:identityDocument/*:passportTypeID',
                                        Document_Serial     VARCHAR2 (200) PATH '*:identityDocument/*:documentSerial',
                                        Document_Number     VARCHAR2 (100) PATH '*:identityDocument/*:documentNumber',
                                        Issue_Date          VARCHAR2 (20) PATH '*:identityDocument/*:IssueDate',
                                        Issuer_Id           VARCHAR2 (1000) PATH '*:identityDocument/*:IssuerID',
                                        Expiry_Date         VARCHAR2 (20) PATH '*:identityDocument/*:ExpiryDate',
                                        Unzr                VARCHAR2 (100) PATH '*:UNZR',
                                        Rnokpp              VARCHAR2 (100) PATH '*:RNOKPP',
                                        Rnokpp_Refusal      VARCHAR2 (100) PATH '*:RNOKPPRefusal');

        RETURN l_Data;
    END;

    FUNCTION Parse_Application_Child_Born_Stipend (p_Req IN XMLTYPE)
        RETURN r_Child_Born_Stipend
    IS
        l_Data   r_Child_Born_Stipend;
    BEGIN
                               SELECT Cbs_Parent_Recipient,
                                      Cbs_Channel,
                                      Postbox,
                                      Postal_Service_Branch_Name,
                                      Cbs_Bank_Account,
                                      Cbs_Bank_Name,
                                      Cbs_Bank_Edrpou,
                                      Cbs_Bank_Mfo
                                 INTO l_Data.Cbs_Parent_Recipient,
                                      l_Data.Cbs_Channel,
                                      l_Data.Cbs_Post_Channel_Info.Postbox,
                                      l_Data.Cbs_Post_Channel_Info.Postal_Service_Branch_Name,
                                      l_Data.Cbs_Bank_Channel_Info.Cbs_Bank_Account,
                                      l_Data.Cbs_Bank_Channel_Info.Cbs_Bank_Name,
                                      l_Data.Cbs_Bank_Channel_Info.Cbs_Bank_Edrpou,
                                      l_Data.Cbs_Bank_Channel_Info.Cbs_Bank_Mfo
                                 FROM XMLTABLE (
                                          '/*'
                                          PASSING p_Req
                                          COLUMNS Cbs_Parent_Recipient          VARCHAR2 (250) PATH '*:CBSParentRecipient',
                                                  Cbs_Channel                   VARCHAR2 (250) PATH '*:CBSChannel',
                                                  Postbox                       VARCHAR2 (100) PATH '*:CBSPostChannelInfo/*:Postbox',
                                                  Postal_Service_Branch_Name    VARCHAR2 (1000) PATH '*:CBSPostChannelInfo/*:PostalServiceBranchName',
                                                  Cbs_Bank_Account              VARCHAR2 (250) PATH '*:CBSBankChannelInfo/*:CBSBankAccount',
                                                  Cbs_Bank_Name                 VARCHAR2 (1000) PATH '*:CBSBankChannelInfo/*:CBSBankName',
                                                  Cbs_Bank_Edrpou               VARCHAR2 (100) PATH '*:CBSBankChannelInfo/*:CBSBankEDRPOU',
                                                  Cbs_Bank_Mfo                  VARCHAR2 (100) PATH '*:CBSBankChannelInfo/*:CBSBankMFO');

        RETURN l_Data;
    END;

    FUNCTION Parse_Application_Large_Family_Info (p_Req      IN XMLTYPE,
                                                  p_Frm_Dt   IN VARCHAR2)
        RETURN t_Large_Family_Info_List
    IS
        l_Data   t_Large_Family_Info_List := t_Large_Family_Info_List ();
        l_i      NUMBER := 0;
    BEGIN
        FOR c
            IN (            SELECT *
                              FROM XMLTABLE (
                                       '/*/*'
                                       PASSING p_Req
                                       COLUMNS Family_Name        VARCHAR2 (250) PATH '*:familyName',
                                               Given_Name         VARCHAR2 (250) PATH '*:givenName',
                                               Patronymic_Name    VARCHAR2 (250) PATH '*:patronymicName',
                                               Birth_Date         VARCHAR2 (20) PATH '*:birthDate',
                                               Cb_Issuer          VARCHAR2 (250) PATH '*:certificateOfBirth/*:CBIssuer',
                                               Cb_Issue_Date      VARCHAR2 (20) PATH '*:certificateOfBirth/*:CBIssueDate',
                                               Document_Serial    VARCHAR2 (250) PATH '*:certificateOfBirth/*:documentSerial',
                                               Document_Number    VARCHAR2 (250) PATH '*:certificateOfBirth/*:documentNumber',
                                               Ar_Date            VARCHAR2 (20) PATH '*:certificateOfBirth/*:ARDate',
                                               Ar_Number          VARCHAR2 (250) PATH '*:certificateOfBirth/*:ARNumber',
                                               Ar_Issuer          VARCHAR2 (1000) PATH '*:certificateOfBirth/*:ARIssuer'))
        LOOP
            DECLARE
                l_Item   r_Other_Childr_Info;
            BEGIN
                l_Item.Family_Name := Clear_Name (c.Family_Name);
                l_Item.Given_Name := Clear_Name (c.Given_Name);
                l_Item.Patronymic_Name := Clear_Name (c.Patronymic_Name);
                l_Item.Birth_Date :=
                    Tools.Try_Parse_Dt (c.Birth_Date, p_Frm_Dt);
                l_Item.Certificate_Of_Birth.Cb_Issuer := c.Cb_Issuer;
                l_Item.Certificate_Of_Birth.Cb_Issue_Date :=
                    Tools.Try_Parse_Dt (c.Cb_Issue_Date, p_Frm_Dt);
                l_Item.Certificate_Of_Birth.Document_Serial :=
                    c.Document_Serial;
                l_Item.Certificate_Of_Birth.Document_Number :=
                    c.Document_Number;
                l_Item.Certificate_Of_Birth.Ar_Date :=
                    Tools.Try_Parse_Dt (c.Ar_Date, p_Frm_Dt);
                l_Item.Certificate_Of_Birth.Ar_Number := c.Ar_Number;
                l_Item.Certificate_Of_Birth.Ar_Issuer := c.Ar_Issuer;

                l_Data.EXTEND;
                l_i := l_i + 1;
                l_Data (l_i) := l_Item;
            END;
        END LOOP;

        RETURN l_Data;
    END;

    FUNCTION Parse_Application_Lf_Certificates (p_Req IN XMLTYPE)
        RETURN r_Lf_Certificates
    IS
        l_Data             r_Lf_Certificates;
        l_Lf_Child_Names   XMLTYPE;
    BEGIN
                    SELECT Lf_Cert_Parents, Lf_Cert_Child, Lf_Child_Names
                      INTO l_Data.Lf_Cert_Parents, l_Data.Lf_Cert_Child, l_Lf_Child_Names
                      FROM XMLTABLE (
                               '/*'
                               PASSING p_Req
                               COLUMNS Lf_Cert_Parents    VARCHAR2 (10) PATH '*:LFCertParents',
                                       Lf_Cert_Child      VARCHAR2 (10) PATH '*:LFCertChild',
                                       Lf_Child_Names     XMLTYPE PATH '*:LFChildNames');

                    SELECT Clear_Name (Family_Name),
                           Clear_Name (Given_Name),
                           Clear_Name (Patronymic_Name)
                      BULK COLLECT INTO l_Data.Lf_Child_Names
                      FROM XMLTABLE (
                               '/*'
                               PASSING l_Lf_Child_Names
                               COLUMNS Family_Name        VARCHAR2 (250) PATH '*:familyName',
                                       Given_Name         VARCHAR2 (250) PATH '*:givenName',
                                       Patronymic_Name    VARCHAR2 (250) PATH '*:patronymicName');

        RETURN l_Data;
    END;

    /*
    info:    Парсинг звернення по послузі Є-Малятко
    author:  kelatev
    request: #103589
    */
    FUNCTION Parse_Application_Data_Req (p_Request_Body IN CLOB)
        RETURN r_Application_Data
    IS
        l_Data     r_Application_Data;
        l_Frm_Dt   VARCHAR2 (20) := 'yyyy-mm-dd';
    BEGIN
        FOR Rec
            IN (                        SELECT *
                                          FROM XMLTABLE (
                                                   '*:ApplicationData'
                                                   PASSING Xmltype.Createxml (p_Request_Body)
                                                   COLUMNS Request_Id                     VARCHAR2 (250) PATH '*:requestID',
                                                           Application_Date               VARCHAR2 (20) PATH '*:applicationDate',
                                                           Type_Service1                  VARCHAR2 (10) PATH '*:TypeService1',
                                                           Type_Service2                  VARCHAR2 (10) PATH '*:TypeService2',
                                                           Type_Service3                  VARCHAR2 (10) PATH '*:TypeService3',
                                                           Type_Service4                  VARCHAR2 (10) PATH '*:TypeService4',
                                                           Type_Service5                  VARCHAR2 (10) PATH '*:TypeService5',
                                                           Type_Service6                  VARCHAR2 (10) PATH '*:TypeService6',
                                                           Type_Service7                  VARCHAR2 (10) PATH '*:TypeService7',
                                                           Servant_Authority_Name         VARCHAR2 (250) PATH '*:officialServantInfo/*:authorityName',
                                                           Servant_Office_Branch_Id       VARCHAR2 (250) PATH '*:officialServantInfo/*:officeBranchID',
                                                           Servant_Family_Name            VARCHAR2 (250) PATH '*:officialServantInfo/*:familyName',
                                                           Servant_Given_Name             VARCHAR2 (250) PATH '*:officialServantInfo/*:givenName',
                                                           Servant_Patronymic_Name        VARCHAR2 (250) PATH '*:officialServantInfo/*:patronymicName',
                                                           Act_Number                     VARCHAR2 (250) PATH '*:actRecordOfBirth/*:actRecordNumber',
                                                           Act_Issue_Date                 VARCHAR2 (250) PATH '*:actRecordOfBirth/*:IssueDate',
                                                           Act_Office_Branch_Id           VARCHAR2 (1000) PATH '*:actRecordOfBirth/*:officeBranchID',
                                                           Act_Servant_Family_Name        VARCHAR2 (250) PATH '*:actRecordOfBirth/*:officialServantInfo/*:familyName',
                                                           Act_Servant_Given_Name         VARCHAR2 (250) PATH '*:actRecordOfBirth/*:officialServantInfo/*:givenName',
                                                           Act_Servant_Patronymic_Name    VARCHAR2 (250) PATH '*:actRecordOfBirth/*:officialServantInfo/*:patronymicName',
                                                           Cb_Issuer                      VARCHAR2 (1000) PATH '*:CBI/*:CBIssuer',
                                                           Cb_Issue_Date                  VARCHAR2 (20) PATH '*:CBI/*:CBIssueDate',
                                                           Cb_Document_Serial             VARCHAR2 (50) PATH '*:CBI/*:documentSerial',
                                                           Cb_Document_Number             VARCHAR2 (50) PATH '*:CBI/*:documentNumber',
                                                           Rnokpp                         VARCHAR2 (50) PATH '*:RNOKPP',
                                                           Unzr                           VARCHAR2 (50) PATH '*:UNZR',
                                                           Notification_Phone             VARCHAR2 (50) PATH '*:notificationChannels/*:notificationPhone',
                                                           Notification_Email             VARCHAR2 (50) PATH '*:notificationChannels/*:notificationEmail',
                                                           Child_Family_Name              VARCHAR2 (250) PATH '*:childInfo/*:familyName',
                                                           Child_Given_Name               VARCHAR2 (250) PATH '*:childInfo/*:givenName',
                                                           Child_Patronymic_Name          VARCHAR2 (250) PATH '*:childInfo/*:patronymicName',
                                                           Child_Birth_Date               VARCHAR2 (20) PATH '*:childInfo/*:birthDate',
                                                           Child_Gender                   VARCHAR2 (250) PATH '*:childInfo/*:gender',
                                                           Child_Citizenship              VARCHAR2 (10) PATH '*:childCitizenship',
                                                           Child_Citizen_Country          VARCHAR2 (10) PATH '*:citizenCountry',
                                                           Children_Were_Born             NUMBER PATH '*:childBorn/*:childrenWereBorn',
                                                           Child_Born_Order               NUMBER PATH '*:childBorn/*:childBornOrder',
                                                           Child_Born_Alive               VARCHAR2 (10) PATH '*:childBorn/*:childBornAlive',
                                                           Mother_Info                    XMLTYPE PATH '*:motherInfo',
                                                           Father_Info                    XMLTYPE PATH '*:fatherInfo',
                                                           Child_Born_Stipend             XMLTYPE PATH '*:childBornStipend',
                                                           Large_Family_Info              XMLTYPE PATH '*:largeFamilyInfo',
                                                           Lf_Certificates                XMLTYPE PATH '*:LFCertificates'))
        LOOP
            l_Data.Request_Id := Rec.Request_Id;
            l_Data.Application_Date :=
                Tools.Try_Parse_Dt (Rec.Application_Date, l_Frm_Dt);
            l_Data.Typeservice1 := Rec.Type_Service1;
            l_Data.Typeservice2 := Rec.Type_Service2;
            l_Data.Typeservice3 := Rec.Type_Service3;
            l_Data.Typeservice4 := Rec.Type_Service4;
            l_Data.Typeservice5 := Rec.Type_Service5;
            l_Data.Typeservice6 := Rec.Type_Service6;
            l_Data.Typeservice7 := Rec.Type_Service7;

            l_Data.Official_Servant_Info.Authority_Name :=
                Rec.Servant_Authority_Name;
            l_Data.Official_Servant_Info.Office_Branch_Id :=
                Rec.Servant_Office_Branch_Id;
            l_Data.Official_Servant_Info.Family_Name :=
                Clear_Name (Rec.Servant_Family_Name);
            l_Data.Official_Servant_Info.Given_Name :=
                Clear_Name (Rec.Servant_Given_Name);
            l_Data.Official_Servant_Info.Patronymic_Name :=
                Clear_Name (Rec.Servant_Patronymic_Name);

            l_Data.Act_Record_Of_Birth.Act_Record_Number := Rec.Act_Number;
            l_Data.Act_Record_Of_Birth.Issue_Date :=
                Tools.Try_Parse_Dt (Rec.Act_Issue_Date, l_Frm_Dt);
            l_Data.Act_Record_Of_Birth.Office_Branch_Id :=
                Rec.Act_Office_Branch_Id;
            l_Data.Act_Record_Of_Birth.Official_Servant_Info.Family_Name :=
                Clear_Name (Rec.Act_Servant_Family_Name);
            l_Data.Act_Record_Of_Birth.Official_Servant_Info.Given_Name :=
                Clear_Name (Rec.Act_Servant_Given_Name);
            l_Data.Act_Record_Of_Birth.Official_Servant_Info.Patronymic_Name :=
                Clear_Name (Rec.Act_Servant_Patronymic_Name);

            l_Data.Cbi.Cb_Issuer := Rec.Cb_Issuer;
            l_Data.Cbi.Cb_Issue_Date :=
                Tools.Try_Parse_Dt (Rec.Cb_Issue_Date, l_Frm_Dt);
            l_Data.Cbi.Document_Serial := Rec.Cb_Document_Serial;
            l_Data.Cbi.Document_Number := Rec.Cb_Document_Number;
            l_Data.Rnokpp := Rec.Rnokpp;
            l_Data.Unzr := Rec.Unzr;
            l_Data.Notification_Channels.Notification_Phone :=
                Rec.Notification_Phone;
            l_Data.Notification_Channels.Notification_Email :=
                Rec.Notification_Email;

            l_Data.Child_Info.Family_Name :=
                Clear_Name (Rec.Child_Family_Name);
            l_Data.Child_Info.Given_Name := Clear_Name (Rec.Child_Given_Name);
            l_Data.Child_Info.Patronymic_Name :=
                Clear_Name (Rec.Child_Patronymic_Name);
            l_Data.Child_Info.Birth_Date :=
                Tools.Try_Parse_Dt (Rec.Child_Birth_Date, l_Frm_Dt);
            l_Data.Child_Info.Gender := SUBSTR (Rec.Child_Gender, -1);
            l_Data.Child_Citizenship := Rec.Child_Citizenship;
            l_Data.Citizen_Country := Rec.Child_Citizen_Country;
            l_Data.Child_Born.Children_Were_Born := Rec.Children_Were_Born;
            l_Data.Child_Born.Child_Born_Order := Rec.Child_Born_Order;
            l_Data.Child_Born.Child_Born_Alive :=
                UPPER (SUBSTR (Rec.Child_Born_Alive, 1, 1));

            l_Data.Mother_Info :=
                Parse_Application_Parent_Info (Rec.Mother_Info,
                                               p_Frm_Dt   => l_Frm_Dt);
            l_Data.Father_Info :=
                Parse_Application_Parent_Info (Rec.Father_Info,
                                               p_Frm_Dt   => l_Frm_Dt);
            l_Data.Child_Born_Stipend :=
                Parse_Application_Child_Born_Stipend (Rec.Child_Born_Stipend);
            l_Data.Large_Family_Info :=
                Parse_Application_Large_Family_Info (Rec.Large_Family_Info,
                                                     p_Frm_Dt   => l_Frm_Dt);
            l_Data.Lf_Certificates :=
                Parse_Application_Lf_Certificates (Rec.Lf_Certificates);
        END LOOP;

        RETURN l_Data;
    END;

    ---------------------------------------------------------------------
    --               Функція робить красивий фортам для номеру телефону
    ---------------------------------------------------------------------
    FUNCTION Format_Phone (p_Phone_Num IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Phone_Num   VARCHAR2 (32767);
    BEGIN
        l_Phone_Num := REGEXP_REPLACE (p_Phone_Num, '[^0-9]');

        l_Phone_Num :=
            REGEXP_REPLACE (l_Phone_Num,
                            '3?8?([0-9]{3})([0-9]{3})([0-9]{2})([0-9]{2})',
                            '(\1) \2-\3-\4');

        IF LENGTH (l_Phone_Num) != 15
        THEN
            l_Phone_Num := p_Phone_Num;
        END IF;

        RETURN l_Phone_Num;
    END;

    ---------------------------------------------------------------------
    --               Конвертація даних заявки в звернення
    ---------------------------------------------------------------------
    PROCEDURE Decode_Application_Data (
        p_Data                IN     r_Application_Data,
        p_Com_Org                OUT NUMBER,
        p_Ap_Services            OUT Api$appeal.t_Ap_Services,
        p_Ap_Persons             OUT Api$appeal.t_Ap_Persons,
        p_Ap_Payments            OUT Api$appeal.t_Ap_Payments,
        p_Ap_Documents           OUT Api$appeal.t_Ap_Documents,
        p_Ap_Document_Attrs      OUT t_Ap_Document_Attrs)
    IS
        l_Is_Large_Family       BOOLEAN := FALSE;
        l_Is_Applicant_Father   BOOLEAN := FALSE;
        l_Applicant             r_Parent_Info;
        l_Apd_Id                NUMBER := 0;
        l_Apda_Id               NUMBER := 0;

        TYPE Date_Arr IS TABLE OF DATE
            INDEX BY BINARY_INTEGER;

        l_Birth_Dt              Date_Arr;

        PROCEDURE Append_Attr (
            p_Apda_Apd       IN Ap_Document_Attr.Apda_Apd%TYPE,
            p_Apda_Nda       IN Ap_Document_Attr.Apda_Nda%TYPE,
            p_Apda_Val_Str   IN Ap_Document_Attr.Apda_Val_String%TYPE DEFAULT NULL,
            p_Apda_Val_Int   IN Ap_Document_Attr.Apda_Val_Int%TYPE DEFAULT NULL,
            p_Apda_Val_Dt    IN Ap_Document_Attr.Apda_Val_Dt%TYPE DEFAULT NULL,
            p_Apda_Val_Id    IN Ap_Document_Attr.Apda_Val_Id%TYPE DEFAULT NULL,
            p_Apda_Val_Sum   IN VARCHAR2 DEFAULT NULL)
        IS
            l_Item   r_Ap_Document_Attr;
        BEGIN
            IF     p_Apda_Val_Str IS NULL
               AND p_Apda_Val_Int IS NULL
               AND p_Apda_Val_Dt IS NULL
               AND p_Apda_Val_Id IS NULL
               AND p_Apda_Val_Sum IS NULL
            THEN
                RETURN;
            END IF;

            IF p_Ap_Document_Attrs IS NULL
            THEN
                p_Ap_Document_Attrs := t_Ap_Document_Attrs ();
            END IF;

            p_Ap_Document_Attrs.EXTEND;

            l_Item.Apda_Nda := p_Apda_Nda;
            l_Item.Apda_Val_String := p_Apda_Val_Str;
            l_Item.Apda_Val_Int := p_Apda_Val_Int;
            l_Item.Apda_Val_Dt := p_Apda_Val_Dt;
            l_Item.Apda_Val_Id := p_Apda_Val_Id;
            l_Item.Apda_Val_Sum := p_Apda_Val_Sum;
            l_Item.Apda_Apd := p_Apda_Apd;

            l_Apda_Id := l_Apda_Id - 1;
            l_Item.Apda_Id := l_Apda_Id;
            p_Ap_Document_Attrs (-1 * l_Apda_Id) := l_Item;
        END;
    BEGIN
        --Ініціалізація масивів
        p_Ap_Services := Api$appeal.t_Ap_Services ();
        p_Ap_Persons := Api$appeal.t_Ap_Persons ();
        p_Ap_Payments := Api$appeal.t_Ap_Payments ();
        p_Ap_Documents := Api$appeal.t_Ap_Documents ();
        p_Ap_Document_Attrs := t_Ap_Document_Attrs ();

        --Service
        DECLARE
            l_Item   Api$appeal.r_Ap_Service;
        BEGIN
            l_Item.Aps_Id := -1;
            l_Item.Aps_St := 'R';

            IF p_Data.Typeservice5 = '1'
            THEN
                l_Item.Aps_Nst := c_Service5;
            ELSIF p_Data.Typeservice6 = '1'
            THEN
                l_Item.Aps_Nst := c_Service6;
                l_Is_Large_Family := TRUE;
            END IF;

            IF l_Item.Aps_Nst IS NOT NULL
            THEN
                p_Ap_Services := Api$appeal.t_Ap_Services (l_Item);
            END IF;
        END;

        --Перевірка особи отримувача допомоги
        l_Is_Applicant_Father :=
            LOWER (p_Data.Child_Born_Stipend.Cbs_Parent_Recipient) = 'батько';
        l_Applicant :=
            CASE
                WHEN l_Is_Applicant_Father THEN p_Data.Father_Info
                ELSE p_Data.Mother_Info
            END;

        --Person
        DECLARE
            l_Item   Api$appeal.r_Ap_Person;
        BEGIN
            l_Item.App_Id := -1;
            l_Item.App_Num := 1;
            l_Item.App_Tp := 'Z';                                    --Заявник
            l_Item.App_Inn := l_Applicant.Rnokpp;
            l_Item.App_Ndt :=
                Uss_Ndi.Tools.Decode_Dict (
                    p_Nddc_Tp     => 'NDT_ID',
                    p_Nddc_Src    => 'DRACS',
                    p_Nddc_Dest   => 'VST',
                    p_Nddc_Code_Src   =>
                        l_Applicant.Identity_Document.Passport_Type_Id);
            l_Item.App_Doc_Num :=
                   TRIM (l_Applicant.Identity_Document.Document_Serial)
                || TRIM (l_Applicant.Identity_Document.Document_Number);

            IF     l_Item.App_Ndt = 6
               AND REGEXP_LIKE (l_Item.App_Doc_Num, '^[0-9]{9}$')
            THEN
                l_Item.App_Ndt := 7;
            END IF;

            l_Item.App_Fn := l_Applicant.Given_Name;
            l_Item.App_Ln := l_Applicant.Family_Name;
            l_Item.App_Mn := l_Applicant.Patronymic_Name;
            l_Item.App_Gender :=
                SUBSTR (UPPER (NVL (l_Applicant.Gender, 'V')), -1, 1);
            l_Birth_Dt (l_Item.App_Num) := l_Applicant.Birth_Date;
            p_Ap_Persons.EXTEND;
            p_Ap_Persons (1) := l_Item;
        END;

        DECLARE
            l_Item   Api$appeal.r_Ap_Person;
        BEGIN
            l_Item.App_Id := -2;
            l_Item.App_Num := 2;
            l_Item.App_Tp := 'FP';                                --Утриманець
            l_Item.App_Inn := p_Data.Rnokpp;
            l_Item.App_Ndt := '37';
            l_Item.App_Doc_Num :=
                p_Data.Cbi.Document_Serial || p_Data.Cbi.Document_Number;
            l_Item.App_Fn := p_Data.Child_Info.Given_Name;
            l_Item.App_Ln := p_Data.Child_Info.Family_Name;
            l_Item.App_Mn := p_Data.Child_Info.Patronymic_Name;
            l_Item.App_Gender :=
                SUBSTR (UPPER (NVL (p_Data.Child_Info.Gender, 'V')), -1, 1);
            l_Birth_Dt (l_Item.App_Num) := p_Data.Child_Info.Birth_Date;
            p_Ap_Persons.EXTEND;
            p_Ap_Persons (2) := l_Item;
        END;

        FOR i IN 1 .. p_Data.Large_Family_Info.COUNT
        LOOP
            DECLARE
                l_Item   Api$appeal.r_Ap_Person;
            BEGIN
                l_Item.App_Id := -2 - i;
                l_Item.App_Num := 2 + i;
                l_Item.App_Tp := 'FP';                            --Утриманець
                l_Item.App_Inn := NULL;
                l_Item.App_Ndt := '37';
                l_Item.App_Doc_Num :=
                       p_Data.Large_Family_Info (i).Certificate_Of_Birth.Document_Serial
                    || p_Data.Large_Family_Info (i).Certificate_Of_Birth.Document_Number;
                l_Item.App_Fn := p_Data.Large_Family_Info (i).Given_Name;
                l_Item.App_Ln := p_Data.Large_Family_Info (i).Family_Name;
                l_Item.App_Mn := p_Data.Large_Family_Info (i).Patronymic_Name;
                l_Birth_Dt (l_Item.App_Num) :=
                    p_Data.Large_Family_Info (i).Birth_Date;
                l_Item.App_Gender := 'V';
                p_Ap_Persons.EXTEND;
                p_Ap_Persons (2 + i) := l_Item;
            END;
        END LOOP;

        FOR i IN 1 .. p_Ap_Persons.COUNT
        LOOP
            DECLARE
                l_Doc_Ser   VARCHAR2 (10);
                l_Doc_Num   VARCHAR2 (50);
            BEGIN
                l_Doc_Ser :=
                    REGEXP_SUBSTR (p_Ap_Persons (i).App_Doc_Num,
                                   '^[^(0-9)]{2}');

                IF l_Doc_Ser IS NOT NULL
                THEN
                    l_Doc_Num :=
                        LTRIM (p_Ap_Persons (i).App_Doc_Num, l_Doc_Ser);
                ELSE
                    l_Doc_Num := TRIM (p_Ap_Persons (i).App_Doc_Num);
                END IF;

                p_Ap_Persons (i).App_Sc :=
                    Uss_Person.Load$socialcard.Load_Sc (
                        p_Fn            => p_Ap_Persons (i).App_Fn,
                        p_Ln            => p_Ap_Persons (i).App_Ln,
                        p_Mn            => p_Ap_Persons (i).App_Mn,
                        p_Gender        => p_Ap_Persons (i).App_Gender,
                        p_Nationality   => '1',
                        p_Src_Dt        => NULL,
                        p_Birth_Dt      => l_Birth_Dt (i),
                        p_Inn_Num       => p_Ap_Persons (i).App_Inn,
                        p_Inn_Ndt       => 5,
                        p_Doc_Ser       => l_Doc_Ser,
                        p_Doc_Num       => l_Doc_Num,
                        p_Doc_Ndt       => p_Ap_Persons (i).App_Ndt,
                        p_Src           => NULL,
                        p_Sc            => p_Ap_Persons (i).App_Sc,
                        p_Sc_Unique     => p_Ap_Persons (i).App_Esr_Num,
                        p_Mode          =>
                            Uss_Person.Load$socialcard.c_Mode_Search);
            END;
        END LOOP;

        --Payment
        DECLARE
            l_Item   Api$appeal.r_Ap_Payment;
        BEGIN
            l_Item.Apm_Id := -1;
            l_Item.Apm_Aps := -1;
            l_Item.Apm_App := -1;
            l_Item.Apm_Tp :=
                CASE p_Data.Child_Born_Stipend.Cbs_Channel
                    WHEN 'bank_account' THEN 'BANK'
                    ELSE 'POST'
                END;
            l_Item.Apm_Need_Account := 'F';

            IF l_Item.Apm_Tp = 'POST'
            THEN
                l_Item.Apm_Index :=
                    p_Data.Child_Born_Stipend.Cbs_Post_Channel_Info.Postbox;

                SELECT MAX (Npo_Kaot)
                  INTO l_Item.Apm_Kaot
                  FROM Uss_Ndi.v_Ndi_Post_Office
                 WHERE Npo_Index = l_Item.Apm_Index AND History_Status = 'A';
            ELSE
                l_Item.Apm_Account :=
                    p_Data.Child_Born_Stipend.Cbs_Bank_Channel_Info.Cbs_Bank_Account;
                l_Item.Apm_Mfo :=
                    p_Data.Child_Born_Stipend.Cbs_Bank_Channel_Info.Cbs_Bank_Mfo;

                --Визначаємо банк за МФО(не приходить ІД банку)
                SELECT MAX (b.Nb_Id)
                  INTO l_Item.Apm_Nb
                  FROM Uss_Ndi.v_Ndi_Bank b
                 WHERE     b.Nb_Mfo = l_Item.Apm_Mfo
                       --Визначаємо ІД головного відділення банку(що немає посилання на батьківський)
                       AND (b.Nb_Nb IS NULL --#92481: за виключенням Райфайзену
                                            OR b.Nb_Nb = 59)
                       AND b.History_Status = 'A';
            END IF;

            p_Ap_Payments := Api$appeal.t_Ap_Payments (l_Item);
        END;

        --Document
        DECLARE
            l_Item        Api$appeal.r_Ap_Document;
            l_Kaot_Id     Uss_Ndi.v_Ndi_Katottg.Kaot_Id%TYPE;
            l_Kaot_Code   Uss_Ndi.v_Ndi_Katottg.Kaot_Code%TYPE;
            l_Kaot_L3     Uss_Ndi.v_Ndi_Katottg.Kaot_Kaot_L3%TYPE;
            l_Nsrt_Id     Uss_Ndi.v_Ndi_Street_Type.Nsrt_Id%TYPE;
        BEGIN
            SELECT MAX (Kaot_Id), MAX (Kaot_Code), MAX (a.Kaot_Kaot_L3)
              INTO l_Kaot_Id, l_Kaot_Code, l_Kaot_L3
              FROM Uss_Ndi.v_Ndi_Katottg a
             WHERE     Kaot_Koatuu =
                       l_Applicant.Registration_Address.City_Koatuu
                   AND a.Kaot_St = 'A';

            SELECT MAX (Nsrt_Id)
              INTO l_Nsrt_Id
              FROM Uss_Ndi.v_Ndi_Street_Type
             WHERE     Nsrt_Name =
                       l_Applicant.Registration_Address.Street_Type_Name
                   AND History_Status = 'A';

            SELECT MAX (Nok_Org)
              INTO p_Com_Org
              FROM Uss_Ndi.v_Ndi_Org2kaot k
             WHERE k.Nok_Kaot = l_Kaot_Id AND k.History_Status = 'A';

            IF p_Com_Org IS NULL
            THEN
                SELECT MAX (Nok_Org)
                  INTO p_Com_Org
                  FROM Uss_Ndi.v_Ndi_Org2kaot k
                 WHERE k.Nok_Kaot = l_Kaot_L3 AND k.History_Status = 'A';
            END IF;

            IF p_Com_Org IS NULL
            THEN
                p_Com_Org := 50000;
            END IF;

            l_Apd_Id := l_Apd_Id - 1;
            l_Item.Apd_Id := l_Apd_Id;
            l_Item.Apd_Ndt := 600;
            l_Item.Apd_App := -1;
            Append_Attr (
                l_Apd_Id,
                605,
                p_Apda_Val_Str   =>
                    Format_Phone (
                        p_Data.Notification_Channels.Notification_Phone));
            Append_Attr (
                l_Apd_Id,
                811,
                p_Apda_Val_Str   =>
                    p_Data.Notification_Channels.Notification_Email);
            Append_Attr (l_Apd_Id,
                         667,
                         p_Apda_Val_Dt   => l_Applicant.Birth_Date);
            Append_Attr (
                l_Apd_Id,
                604,
                p_Apda_Val_Str   =>
                       Uss_Ndi.Api$dic_Common.Get_Katottg_Name (l_Kaot_Id)
                    || ', '
                    || l_Kaot_Code,
                p_Apda_Val_Id   => l_Kaot_Id);
            Append_Attr (
                l_Apd_Id,
                594,
                p_Apda_Val_Str   => l_Applicant.Registration_Address.Apartment);
            Append_Attr (
                l_Apd_Id,
                595,
                p_Apda_Val_Str   =>
                    l_Applicant.Registration_Address.Building_Part);
            Append_Attr (
                l_Apd_Id,
                596,
                p_Apda_Val_Str   =>
                    l_Applicant.Registration_Address.Building_Number);
            Append_Attr (
                l_Apd_Id,
                598,
                p_Apda_Val_Str   => l_Applicant.Registration_Address.Cityname);
            Append_Attr (
                l_Apd_Id,
                599,
                p_Apda_Val_Str   => l_Applicant.Registration_Address.Postbox);
            Append_Attr (
                l_Apd_Id,
                600,
                p_Apda_Val_Str   => l_Applicant.Registration_Address.District);
            Append_Attr (
                l_Apd_Id,
                601,
                p_Apda_Val_Str   => l_Applicant.Registration_Address.Region);
            Append_Attr (
                l_Apd_Id,
                603,
                p_Apda_Val_Str   => l_Applicant.Registration_Address.Country);
            Append_Attr (
                l_Apd_Id,
                788,
                p_Apda_Val_Str   =>
                    l_Applicant.Registration_Address.Street_Name);
            Append_Attr (
                l_Apd_Id,
                2304,
                p_Apda_Val_Str   =>
                    NVL (TO_CHAR (l_Nsrt_Id),
                         l_Applicant.Registration_Address.Street_Type_Name));

            p_Ap_Documents.EXTEND;
            p_Ap_Documents (-1 * l_Apd_Id) := l_Item;
        END;

        DECLARE
            l_Item   Api$appeal.r_Ap_Document;
        BEGIN
            l_Apd_Id := l_Apd_Id - 1;
            l_Item.Apd_Id := l_Apd_Id;
            l_Item.Apd_Ndt := p_Ap_Persons (1).App_Ndt;
            l_Item.Apd_App := -1;

            FOR c
                IN (SELECT a.Nda_Id,
                           l_Applicant.Family_Name     AS x_String,
                           NULL                        AS x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Item.Apd_Ndt
                           AND a.Nda_Class = 'LN'
                           AND a.History_Status = 'A'
                    UNION ALL
                    SELECT a.Nda_Id,
                           l_Applicant.Given_Name     AS x_String,
                           NULL                       AS x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Item.Apd_Ndt
                           AND a.Nda_Class = 'FN'
                           AND a.History_Status = 'A'
                    UNION ALL
                    SELECT a.Nda_Id,
                           l_Applicant.Patronymic_Name     AS x_String,
                           NULL                            AS x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Item.Apd_Ndt
                           AND a.Nda_Class = 'MN'
                           AND a.History_Status = 'A'
                    UNION ALL
                    SELECT a.Nda_Id,
                           NULL                       AS x_String,
                           l_Applicant.Birth_Date     AS x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Item.Apd_Ndt
                           AND a.Nda_Class = 'BDT'
                           AND a.History_Status = 'A'
                    UNION ALL
                    SELECT a.Nda_Id,
                           NULL                                         AS x_String,
                           l_Applicant.Identity_Document.Expiry_Date    AS x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Item.Apd_Ndt
                           AND a.Nda_Class = 'DSPDT'
                           AND a.History_Status = 'A'
                    UNION ALL
                    SELECT a.Nda_Id,
                           NULL                                        AS x_String,
                           l_Applicant.Identity_Document.Issue_Date    AS x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Item.Apd_Ndt
                           AND a.Nda_Class = 'DGVDT'
                           AND a.History_Status = 'A'
                    UNION ALL
                    SELECT a.Nda_Id,
                           l_Applicant.Identity_Document.Issuer_Id
                               AS x_String,
                           NULL
                               AS x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Item.Apd_Ndt
                           AND a.Nda_Class = 'DORG'
                           AND a.History_Status = 'A'
                    UNION ALL
                    SELECT a.Nda_Id,
                              TRIM (
                                  l_Applicant.Identity_Document.Document_Serial)
                           || TRIM (
                                  l_Applicant.Identity_Document.Document_Number)
                               AS x_String,
                           NULL
                               AS x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Item.Apd_Ndt
                           AND a.Nda_Class = 'DSN'
                           AND a.History_Status = 'A')
            LOOP
                Append_Attr (l_Apd_Id,
                             c.Nda_Id,
                             p_Apda_Val_Str   => c.x_String,
                             p_Apda_Val_Dt    => c.x_Dt);
            END LOOP;

            p_Ap_Documents.EXTEND;
            p_Ap_Documents (-1 * l_Apd_Id) := l_Item;
        END;

        --5/10117
        DECLARE
            l_Item   Api$appeal.r_Ap_Document;
        BEGIN
            l_Apd_Id := l_Apd_Id - 1;
            l_Item.Apd_Id := l_Apd_Id;
            l_Item.Apd_App := -1;

            IF l_Applicant.Rnokpp IS NOT NULL
            THEN
                l_Item.Apd_Ndt := 5;
                Append_Attr (l_Apd_Id,
                             1,
                             p_Apda_Val_Str   => l_Applicant.Rnokpp);
            ELSE
                l_Item.Apd_Ndt := 10117;
            END IF;

            p_Ap_Documents.EXTEND;
            p_Ap_Documents (-1 * l_Apd_Id) := l_Item;
        END;

        --605
        DECLARE
            l_Item   Api$appeal.r_Ap_Document;
        BEGIN
            l_Apd_Id := l_Apd_Id - 1;
            l_Item.Apd_Id := l_Apd_Id;
            l_Item.Apd_App := -1;
            l_Item.Apd_Ndt := 605;
            Append_Attr (l_Apd_Id, 649, p_Apda_Val_Str => 'Z');

            IF l_Applicant.Rnokpp IS NULL
            THEN
                Append_Attr (l_Apd_Id, 640, p_Apda_Val_Str => 'T'); --Відмова від використання РНОКПП
            END IF;

            IF l_Is_Large_Family
            THEN
                Append_Attr (l_Apd_Id, 646, p_Apda_Val_Str => 'T'); --Мати/батько
                Append_Attr (l_Apd_Id, 828, p_Apda_Val_Str => 'T'); --Одружений/Одружена
            END IF;

            p_Ap_Documents.EXTEND;
            p_Ap_Documents (-1 * l_Apd_Id) := l_Item;
        END;

        --Пошук документу 10108 в СРКО
        IF l_Is_Large_Family
        THEN
            IF p_Ap_Persons (1).App_Sc IS NOT NULL
            THEN
                DECLARE
                    l_Scd_Dh   NUMBER;
                    l_Ndt_Id   NUMBER := 10108;
                    l_Item     Api$appeal.r_Ap_Document;
                BEGIN
                    SELECT MAX (Scd_Dh)
                      INTO l_Scd_Dh
                      FROM Uss_Person.v_Sc_Document d
                     WHERE     d.Scd_Sc = p_Ap_Persons (1).App_Sc
                           AND d.Scd_Ndt = l_Ndt_Id
                           AND d.Scd_St = '1';

                    IF l_Scd_Dh IS NOT NULL
                    THEN
                        l_Apd_Id := l_Apd_Id - 1;
                        l_Item.Apd_Id := l_Apd_Id;
                        l_Item.Apd_App := -1;
                        l_Item.Apd_Ndt := l_Ndt_Id;

                        Append_Attr (
                            l_Apd_Id,
                            2273,
                            p_Apda_Val_Str   =>
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 2273,
                                    p_Dh_Id    => l_Scd_Dh)); --Номер документа
                        Append_Attr (
                            l_Apd_Id,
                            2274,
                            p_Apda_Val_Dt   =>
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 2274,
                                    p_Dh_Id    => l_Scd_Dh)); --Дата видачі документа
                        Append_Attr (
                            l_Apd_Id,
                            2275,
                            p_Apda_Val_Dt   =>
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 2275,
                                    p_Dh_Id    => l_Scd_Dh)); --Документ дійсний до
                        Append_Attr (
                            l_Apd_Id,
                            2276,
                            p_Apda_Val_Str   =>
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 2276,
                                    p_Dh_Id    => l_Scd_Dh));     --Ким видано
                        Append_Attr (
                            l_Apd_Id,
                            2277,
                            p_Apda_Val_Str   =>
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 2277,
                                    p_Dh_Id    => l_Scd_Dh));     --Код району
                        Append_Attr (
                            l_Apd_Id,
                            2278,
                            p_Apda_Val_Str   =>
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 2278,
                                    p_Dh_Id    => l_Scd_Dh)); --Номер картки пільговика
                        Append_Attr (
                            l_Apd_Id,
                            2279,
                            p_Apda_Val_Dt   =>
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 2279,
                                    p_Dh_Id    => l_Scd_Dh));    --Пільговик з
                        Append_Attr (
                            l_Apd_Id,
                            2280,
                            p_Apda_Val_Dt   =>
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 2280,
                                    p_Dh_Id    => l_Scd_Dh));   --Пільговик по

                        p_Ap_Documents.EXTEND;
                        p_Ap_Documents (-1 * l_Apd_Id) := l_Item;
                    END IF;
                END;
            END IF;
        END IF;

        DECLARE
            l_Item   Api$appeal.r_Ap_Document;
        BEGIN
            l_Apd_Id := l_Apd_Id - 1;
            l_Item.Apd_Id := l_Apd_Id;
            l_Item.Apd_Ndt := 37;
            l_Item.Apd_App := -2;
            Append_Attr (
                l_Apd_Id,
                90,
                p_Apda_Val_Str   =>
                    p_Data.Cbi.Document_Serial || p_Data.Cbi.Document_Number);
            Append_Attr (l_Apd_Id,
                         91,
                         p_Apda_Val_Dt   => p_Data.Child_Info.Birth_Date);
            Append_Attr (l_Apd_Id, 93, p_Apda_Val_Str => p_Data.Cbi.Cb_Issuer);
            Append_Attr (l_Apd_Id,
                         94,
                         p_Apda_Val_Dt   => p_Data.Cbi.Cb_Issue_Date);
            Append_Attr (
                l_Apd_Id,
                3620,
                p_Apda_Val_Str   =>
                    p_Data.Act_Record_Of_Birth.Act_Record_Number);
            Append_Attr (
                l_Apd_Id,
                3619,
                p_Apda_Val_Dt   => p_Data.Act_Record_Of_Birth.Issue_Date);
            Append_Attr (l_Apd_Id, 870, p_Apda_Val_Str => p_Data.Unzr);
            Append_Attr (l_Apd_Id, 8529, p_Apda_Val_Str => p_Data.Rnokpp);
            Append_Attr (
                l_Apd_Id,
                92,
                p_Apda_Val_Str   =>
                    TRIM (
                           p_Data.Child_Info.Family_Name
                        || ' '
                        || p_Data.Child_Info.Given_Name
                        || ' '
                        || p_Data.Child_Info.Patronymic_Name));
            Append_Attr (
                l_Apd_Id,
                679,
                p_Apda_Val_Str   =>
                    TRIM (
                           p_Data.Mother_Info.Family_Name
                        || ' '
                        || p_Data.Mother_Info.Given_Name
                        || ' '
                        || p_Data.Mother_Info.Patronymic_Name));
            Append_Attr (l_Apd_Id,
                         8530,
                         p_Apda_Val_Str   => p_Data.Mother_Info.Rnokpp);
            Append_Attr (
                l_Apd_Id,
                680,
                p_Apda_Val_Str   =>
                    TRIM (
                           p_Data.Father_Info.Family_Name
                        || ' '
                        || p_Data.Father_Info.Given_Name
                        || ' '
                        || p_Data.Father_Info.Patronymic_Name));
            Append_Attr (l_Apd_Id,
                         8531,
                         p_Apda_Val_Str   => p_Data.Father_Info.Rnokpp);
            Append_Attr (l_Apd_Id,
                         2293,
                         p_Apda_Val_Str   => 'ДРАЦС',
                         p_Apda_Val_Id    => 1);
            Append_Attr (l_Apd_Id, 2294, p_Apda_Val_Dt => SYSDATE);

            p_Ap_Documents.EXTEND;
            p_Ap_Documents (-1 * l_Apd_Id) := l_Item;
        END;

        IF p_Data.Rnokpp IS NOT NULL
        THEN
            DECLARE
                l_Item   Api$appeal.r_Ap_Document;
            BEGIN
                l_Apd_Id := l_Apd_Id - 1;
                l_Item.Apd_Id := l_Apd_Id;
                l_Item.Apd_App := -2;
                l_Item.Apd_Ndt := 5;
                Append_Attr (l_Apd_Id, 1, p_Apda_Val_Str => p_Data.Rnokpp);
                p_Ap_Documents.EXTEND;
                p_Ap_Documents (-1 * l_Apd_Id) := l_Item;
            END;
        END IF;

        DECLARE
            l_Item   Api$appeal.r_Ap_Document;
        BEGIN
            l_Apd_Id := l_Apd_Id - 1;
            l_Item.Apd_Id := l_Apd_Id;
            l_Item.Apd_App := -2;
            l_Item.Apd_Ndt := 605;
            Append_Attr (l_Apd_Id, 649, p_Apda_Val_Str => 'B');
            Append_Attr (l_Apd_Id, 8458, p_Apda_Val_Str => 'T');
            p_Ap_Documents.EXTEND;
            p_Ap_Documents (-1 * l_Apd_Id) := l_Item;
        END;

        IF l_Is_Large_Family
        THEN
            FOR i IN 1 .. p_Data.Large_Family_Info.COUNT
            LOOP
                DECLARE
                    l_Item    Api$appeal.r_Ap_Document;
                    l_Child   r_Other_Childr_Info
                                  := p_Data.Large_Family_Info (i);
                BEGIN
                    l_Apd_Id := l_Apd_Id - 1;
                    l_Item.Apd_Id := l_Apd_Id;
                    l_Item.Apd_App := -2 - i;
                    l_Item.Apd_Ndt := 37;

                    Append_Attr (
                        l_Apd_Id,
                        90,
                        p_Apda_Val_Str   =>
                               l_Child.Certificate_Of_Birth.Document_Serial
                            || l_Child.Certificate_Of_Birth.Document_Number);
                    Append_Attr (l_Apd_Id,
                                 91,
                                 p_Apda_Val_Dt   => l_Child.Birth_Date);
                    Append_Attr (
                        l_Apd_Id,
                        93,
                        p_Apda_Val_Str   =>
                            l_Child.Certificate_Of_Birth.Cb_Issuer);
                    Append_Attr (
                        l_Apd_Id,
                        94,
                        p_Apda_Val_Dt   =>
                            l_Child.Certificate_Of_Birth.Cb_Issue_Date);
                    Append_Attr (
                        l_Apd_Id,
                        3620,
                        p_Apda_Val_Str   =>
                            l_Child.Certificate_Of_Birth.Ar_Number);
                    Append_Attr (
                        l_Apd_Id,
                        3619,
                        p_Apda_Val_Dt   =>
                            l_Child.Certificate_Of_Birth.Ar_Date);
                    Append_Attr (
                        l_Apd_Id,
                        92,
                        p_Apda_Val_Str   =>
                            TRIM (
                                   l_Child.Family_Name
                                || ' '
                                || l_Child.Given_Name
                                || ' '
                                || l_Child.Patronymic_Name));
                    Append_Attr (
                        l_Apd_Id,
                        679,
                        p_Apda_Val_Str   =>
                            TRIM (
                                   p_Data.Mother_Info.Family_Name
                                || ' '
                                || p_Data.Mother_Info.Given_Name
                                || ' '
                                || p_Data.Mother_Info.Patronymic_Name));
                    Append_Attr (
                        l_Apd_Id,
                        8530,
                        p_Apda_Val_Str   => p_Data.Mother_Info.Rnokpp);
                    Append_Attr (
                        l_Apd_Id,
                        680,
                        p_Apda_Val_Str   =>
                            TRIM (
                                   p_Data.Father_Info.Family_Name
                                || ' '
                                || p_Data.Father_Info.Given_Name
                                || ' '
                                || p_Data.Father_Info.Patronymic_Name));
                    Append_Attr (
                        l_Apd_Id,
                        8531,
                        p_Apda_Val_Str   => p_Data.Father_Info.Rnokpp);
                    Append_Attr (l_Apd_Id,
                                 2293,
                                 p_Apda_Val_Str   => 'ДРАЦС',
                                 p_Apda_Val_Id    => 1);
                    Append_Attr (l_Apd_Id, 2294, p_Apda_Val_Dt => SYSDATE);

                    p_Ap_Documents.EXTEND;
                    p_Ap_Documents (-1 * l_Apd_Id) := l_Item;
                END;
            END LOOP;
        END IF;
    END;

    PROCEDURE Save_Rn_Ap (p_Rn_Id IN NUMBER, p_Ap_Id IN NUMBER)
    IS
    BEGIN
        Ikis_Rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                                  p_Rnc_Pt       => 209,
                                                  p_Rnc_Val_Id   => p_Ap_Id);
    END;

    ---------------------------------------------------------------------
    --                     ОЧИСТКА ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Clear_Appeal (p_Ap_Id IN NUMBER)
    IS
    BEGIN
        FOR Rec IN (SELECT o.App_Id
                      FROM Ap_Person o
                     WHERE o.App_Ap = p_Ap_Id AND History_Status = 'A')
        LOOP
            Api$appeal.Delete_Person (Rec.App_Id);
        END LOOP;

        FOR Rec IN (SELECT o.Apm_Id
                      FROM Ap_Payment o
                     WHERE o.Apm_Ap = p_Ap_Id AND History_Status = 'A')
        LOOP
            Api$appeal.Delete_Payment (Rec.Apm_Id);
        END LOOP;

        FOR Rec IN (SELECT o.Apd_Id
                      FROM Ap_Document o
                     WHERE o.Apd_Ap = p_Ap_Id AND History_Status = 'A')
        LOOP
            Api$appeal.Delete_Document (Rec.Apd_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                    ЗБЕРЕЖЕННЯ ПОСЛУГ
    ---------------------------------------------------------------------
    PROCEDURE Save_Services (p_Ap_Id         IN     NUMBER,
                             p_Ap_Services   IN OUT Api$appeal.t_Ap_Services)
    IS
    BEGIN
        --Зберігаємо дані з запиту
        FOR i IN 1 .. p_Ap_Services.COUNT
        LOOP
            SELECT MAX (s.Aps_Id)
              INTO p_Ap_Services (i).New_Id
              FROM Ap_Service s
             WHERE     s.Aps_Ap = p_Ap_Id
                   AND s.History_Status = 'A'
                   AND s.Aps_Nst = p_Ap_Services (i).Aps_Nst;

            IF p_Ap_Services (i).New_Id IS NOT NULL
            THEN
                CONTINUE;
            END IF;

            Api$appeal.Save_Service (
                p_Aps_Id    => p_Ap_Services (i).Aps_Id,
                p_Aps_Nst   => p_Ap_Services (i).Aps_Nst,
                p_Aps_Ap    => p_Ap_Id,
                p_Aps_St    => NVL (p_Ap_Services (i).Aps_St, 'R'),
                p_New_Id    => p_Ap_Services (i).New_Id);
        END LOOP;

        IF p_Ap_Services.COUNT = 0
        THEN
            Raise_Application_Error (c_Err_Code_Fail,
                                     'Незнайдена підтримувана послуга');
        END IF;
    END;

    ---------------------------------------------------------------------
    --                     ЗБЕРЕЖЕННЯ ОСІБ
    ---------------------------------------------------------------------
    PROCEDURE Save_Persons (
        p_Ap_Id        IN            NUMBER,
        p_Ap_Persons   IN OUT NOCOPY Api$appeal.t_Ap_Persons)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        --Зберігаємо дані з запиту
        --Перероблено на First/Last для випадку коли видалені всі окрім нової дитини
        FOR i IN p_Ap_Persons.FIRST .. p_Ap_Persons.LAST
        LOOP
            SELECT MAX (c.Sc_Id)
              INTO l_Sc_Id
              FROM Uss_Person.v_Socialcard c
             WHERE c.Sc_Unique = p_Ap_Persons (i).App_Esr_Num;

            --Зберігаємо особу
            Api$appeal.Save_Person (
                p_App_Id        => -1,
                p_App_Ap        => p_Ap_Id,
                p_App_Tp        => p_Ap_Persons (i).App_Tp,
                p_App_Inn       => p_Ap_Persons (i).App_Inn,
                p_App_Ndt       => p_Ap_Persons (i).App_Ndt,
                p_App_Doc_Num   => p_Ap_Persons (i).App_Doc_Num,
                p_App_Fn        => p_Ap_Persons (i).App_Fn,
                p_App_Mn        => p_Ap_Persons (i).App_Mn,
                p_App_Ln        => p_Ap_Persons (i).App_Ln,
                p_App_Esr_Num   => p_Ap_Persons (i).App_Esr_Num,
                p_App_Gender    => p_Ap_Persons (i).App_Gender,
                p_App_Vf        => NULL,
                p_App_Sc        => l_Sc_Id,
                p_App_Num       => p_Ap_Persons (i).App_Num,
                p_New_Id        => p_Ap_Persons (i).New_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                 ЗБЕРЕЖЕННЯ СПОСОБІВ ВИПЛАТ
    ---------------------------------------------------------------------
    PROCEDURE Save_Payments (p_Ap_Id         IN NUMBER,
                             p_Ap_Payments   IN Api$appeal.t_Ap_Payments,
                             p_Ap_Services   IN Api$appeal.t_Ap_Services,
                             p_Ap_Persons    IN Api$appeal.t_Ap_Persons)
    IS
        l_New_Id   NUMBER;
    BEGIN
        --Зберігаємо дані з запиту
        FOR Rec
            IN (SELECT p.*,
                       GREATEST (s.Aps_Id, NVL (s.New_Id, -1))      AS Aps_Id,
                       GREATEST (Pr.App_Id, NVL (Pr.New_Id, -1))    AS App_Id
                  FROM TABLE (p_Ap_Payments)  p
                       LEFT JOIN TABLE (p_Ap_Services) s
                           ON p.Apm_Aps = s.Aps_Id
                       LEFT JOIN TABLE (p_Ap_Persons) Pr
                           ON p.Apm_App = Pr.App_Id)
        LOOP
            Api$appeal.Save_Payment (
                p_Apm_Id             => Rec.Apm_Id,
                p_Apm_Ap             => p_Ap_Id,
                p_Apm_Aps            => Rec.Aps_Id,
                p_Apm_App            => Rec.App_Id,
                p_Apm_Tp             => Rec.Apm_Tp,
                p_Apm_Index          => Rec.Apm_Index,
                p_Apm_Kaot           => Rec.Apm_Kaot,
                p_Apm_Nb             => Rec.Apm_Nb,
                p_Apm_Account        => Rec.Apm_Account,
                p_Apm_Need_Account   => Rec.Apm_Need_Account,
                p_Apm_Street         => Rec.Apm_Street,
                p_Apm_Ns             => Rec.Apm_Ns,
                p_Apm_Building       => Rec.Apm_Building,
                p_Apm_Block          => Rec.Apm_Block,
                p_Apm_Apartment      => Rec.Apm_Apartment,
                p_Apm_Dppa           => NULL,
                p_New_Id             => l_New_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                   ЗБЕРЕЖЕННЯ ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Save_Documents (p_Ap_Id               IN NUMBER,
                              p_Ap_Documents        IN Api$appeal.t_Ap_Documents,
                              p_Ap_Persons          IN Api$appeal.t_Ap_Persons,
                              p_Ap_Document_Attrs   IN t_Ap_Document_Attrs)
    IS
    BEGIN
        --Зберігаємо дані з запиту
        FOR Rec
            IN (SELECT d.*, GREATEST (p.App_Id, NVL (p.New_Id, -1)) AS App_Id
                  FROM TABLE (p_Ap_Documents)  d
                       JOIN TABLE (p_Ap_Persons) p ON d.Apd_App = p.App_Id)
        LOOP
            DECLARE
                l_Temp_Apd   NUMBER := Rec.Apd_Id;
            BEGIN
                Uss_Doc.Api$documents.Save_Document (
                    p_Doc_Id          => NULL,
                    p_Doc_Ndt         => Rec.Apd_Ndt,
                    p_Doc_Actuality   => 'U',
                    p_New_Id          => Rec.Apd_Doc);
                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => NULL,
                    p_Dh_Doc         => Rec.Apd_Doc,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Ndt         => Rec.Apd_Ndt,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   => 'U',
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => NULL,
                    p_Dh_Src         => c_Src_Dracs,
                    p_New_Id         => Rec.Apd_Dh);

                --Зберігаємо документ
                Api$appeal.Save_Document (p_Apd_Id    => Rec.Apd_Id,
                                          p_Apd_Ap    => p_Ap_Id,
                                          p_Apd_Ndt   => Rec.Apd_Ndt,
                                          p_Apd_Doc   => Rec.Apd_Doc,
                                          p_Apd_Vf    => NULL,
                                          p_Apd_App   => Rec.App_Id,
                                          p_New_Id    => Rec.Apd_Id,
                                          p_Com_Wu    => NULL,
                                          p_Apd_Dh    => Rec.Apd_Dh,
                                          p_Apd_Src   => c_Src_Dracs,
                                          p_Apd_Aps   => NULL);

                --Зберігаємо атрибути документа
                FOR i IN 1 .. p_Ap_Document_Attrs.COUNT
                LOOP
                    DECLARE
                        l_New_Id   NUMBER;
                        l_Item     r_Ap_Document_Attr
                                       := p_Ap_Document_Attrs (i);
                    BEGIN
                        IF l_Item.Apda_Apd = l_Temp_Apd
                        THEN
                            Api$appeal.Save_Document_Attr (
                                p_Apda_Id           => l_Item.Apda_Id,
                                p_Apda_Ap           => p_Ap_Id,
                                p_Apda_Apd          => Rec.Apd_Id,
                                p_Apda_Nda          => l_Item.Apda_Nda,
                                p_Apda_Val_Int      => l_Item.Apda_Val_Int,
                                p_Apda_Val_Dt       => l_Item.Apda_Val_Dt,
                                p_Apda_Val_String   => l_Item.Apda_Val_String,
                                p_Apda_Val_Id       => l_Item.Apda_Val_Id,
                                p_Apda_Val_Sum      => l_Item.Apda_Val_Sum,
                                p_New_Id            => l_New_Id);
                        END IF;
                    END;
                END LOOP;
            END;
        END LOOP;
    END;

    /*
    info:    Пошук звернення для можливості додавання новонародженої дитини
             з тої самої сімї до існуючого звернення
    author:  kelatev
    request: #103589
    */
    FUNCTION Find_Similar_Family (p_Data IN r_Application_Data)
        RETURN NUMBER
    IS
        l_Ap_Id   NUMBER;
    BEGIN
        SELECT MAX (Ap_Id)
          INTO l_Ap_Id
          FROM Appeal a
         WHERE     Ap_Tp = Dnet$exch_Mju.c_Ap_Tp
               AND Ap_Src = Dnet$exch_Mju.c_Src_Dracs
               AND Ap_St = Api$appeal.c_Ap_St_Reg_In_Work
               AND EXISTS
                       (SELECT 1
                          FROM Ap_Service s
                         WHERE     s.Aps_Ap = Ap_Id
                               AND s.Aps_Nst =
                                   CASE
                                       WHEN p_Data.Typeservice5 = '1'
                                       THEN
                                           Dnet$exch_Mju.c_Service5
                                       WHEN p_Data.Typeservice6 = '1'
                                       THEN
                                           Dnet$exch_Mju.c_Service6
                                   END
                               AND s.History_Status = 'A')
               AND EXISTS
                       (SELECT 1
                          FROM Ap_Person p, Ap_Document d
                         WHERE     p.App_Ap = Ap_Id
                               AND p.App_Tp = 'FP'
                               AND p.App_Num = 2 --Перевіряємо саме по основній дитині
                               AND p.History_Status = 'A'
                               AND d.Apd_App = App_Id
                               AND d.Apd_Ap = Ap_Id
                               AND d.Apd_Ndt = 37
                               AND d.History_Status = 'A'
                               AND EXISTS
                                       (SELECT 1
                                          FROM Ap_Document_Attr Da
                                         WHERE     Da.Apda_Apd = Apd_Id
                                               AND Da.History_Status = 'A'
                                               AND Da.Apda_Nda = 91
                                               AND Da.Apda_Val_Dt BETWEEN   p_Data.Child_Info.Birth_Date
                                                                          - 2
                                                                      AND   p_Data.Child_Info.Birth_Date
                                                                          + 2)
                               AND (   EXISTS
                                           (SELECT 1
                                              FROM Ap_Document_Attr Da
                                             WHERE     Da.Apda_Apd = Apd_Id
                                                   AND Da.History_Status =
                                                       'A'
                                                   AND Da.Apda_Nda = 8530
                                                   AND Da.Apda_Val_String =
                                                       p_Data.Mother_Info.Rnokpp)
                                    OR p_Data.Mother_Info.Rnokpp IS NULL)
                               AND EXISTS
                                       (SELECT 1
                                          FROM Ap_Document_Attr Da
                                         WHERE     Da.Apda_Apd = Apd_Id
                                               AND Da.History_Status = 'A'
                                               AND Da.Apda_Nda = 679
                                               AND Da.Apda_Val_String =
                                                   TRIM (
                                                          p_Data.Mother_Info.Family_Name
                                                       || ' '
                                                       || p_Data.Mother_Info.Given_Name
                                                       || ' '
                                                       || p_Data.Mother_Info.Patronymic_Name))
                               AND (   EXISTS
                                           (SELECT 1
                                              FROM Ap_Document_Attr Da
                                             WHERE     Da.Apda_Apd = Apd_Id
                                                   AND Da.History_Status =
                                                       'A'
                                                   AND Da.Apda_Nda = 8531
                                                   AND Da.Apda_Val_String =
                                                       p_Data.Father_Info.Rnokpp)
                                    OR p_Data.Father_Info.Rnokpp IS NULL)
                               AND EXISTS
                                       (SELECT 1
                                          FROM Ap_Document_Attr Da
                                         WHERE     Da.Apda_Apd = Apd_Id
                                               AND Da.History_Status = 'A'
                                               AND Da.Apda_Nda = 680
                                               AND Da.Apda_Val_String =
                                                   TRIM (
                                                          p_Data.Father_Info.Family_Name
                                                       || ' '
                                                       || p_Data.Father_Info.Given_Name
                                                       || ' '
                                                       || p_Data.Father_Info.Patronymic_Name)));

        RETURN l_Ap_Id;
    END;

    /*
    info:    Перевірка звернення на принадлежність джерела
    author:  kelatev
    request: #103589
    */
    PROCEDURE Check_Appeal_Access (p_Ap_Id IN NUMBER)
    IS
        l_Is_Allowed   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Is_Allowed
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id AND a.Ap_Src = c_Src_Dracs;

        IF l_Is_Allowed <> 1
        THEN
            Raise_Application_Error (
                c_Err_Code_Not_Allowed,
                   'Доступ до звернення '
                || p_Ap_Id
                || ' для джерела '
                || c_Src_Dracs
                || ' заборонено');
        END IF;
    END;

    /*
    info:    Обробка запиту на отримання звернення по послузі Є-Малятко
    author:  kelatev
    request: #103589
    */
    FUNCTION Handle_Dracs_Application_Request (p_Request_Id     IN NUMBER,
                                               p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Data                     r_Application_Data;
        l_Rn_Id                    NUMBER;

        l_Request_Receive_Status   NUMBER;
        l_Fault_Code               NUMBER;
        l_Fault_Details            VARCHAR2 (1000);
        l_Response                 XMLTYPE;

        l_Ap_Id                    NUMBER;
        l_Similar_Ap               NUMBER;
        l_Ap_St                    VARCHAR2 (10);
        l_Com_Org                  NUMBER;
        l_Hs_Id                    Histsession.Hs_Id%TYPE;
        l_Ap_Services              Api$appeal.t_Ap_Services;
        l_Ap_Persons               Api$appeal.t_Ap_Persons;
        l_Ap_Payments              Api$appeal.t_Ap_Payments;
        l_Ap_Documents             Api$appeal.t_Ap_Documents;
        l_Ap_Document_Attrs        t_Ap_Document_Attrs;

        l_Lock_Handle              Tools.t_Lockhandler;
    BEGIN
        l_Rn_Id :=
            Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id => p_Request_Id);

        BEGIN
            BEGIN
                l_Data :=
                    Parse_Application_Data_Req (
                        p_Request_Body   => p_Request_Body);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Ikis_Rbm.Api$uxp_Request.Save_Request_Error (
                        p_Ure_Ur        => p_Request_Id,
                        p_Ure_Row_Id    => 1,
                        p_Ure_Row_Num   => 1,
                        p_Ure_Error     =>
                               SQLERRM
                            || CHR (13)
                            || DBMS_UTILITY.Format_Error_Stack
                            || DBMS_UTILITY.Format_Error_Backtrace);

                    Raise_Application_Error (c_Err_Code_Fail,
                                             'Помилка парсингу запиту');
            END;

            SELECT MAX (Ap_Id), MAX (Ap_St)
              INTO l_Ap_Id, l_Ap_St
              FROM (  SELECT a.Ap_Id, a.Ap_St
                        FROM Appeal a
                       WHERE     a.Ap_Ext_Ident = l_Data.Request_Id
                             AND a.Ap_Tp = c_Ap_Tp
                             AND a.Ap_Src = c_Src_Dracs
                    ORDER BY a.Ap_Create_Dt
                       FETCH FIRST ROW ONLY);

            IF l_Ap_Id IS NULL
            THEN
                Ikis_Sys.Ikis_Lock.Request_Lock (
                    p_Permanent_Name      => Tools.Ginstance_Lock_Name,
                    p_Var_Name            =>
                           'AP_SAVE'
                        || c_Ap_Tp
                        || c_Src_Dracs
                        || l_Data.Request_Id,
                    p_Errmessage          => NULL,
                    p_Lockhandler         => l_Lock_Handle,
                    p_Timeout             => 3600,
                    p_Release_On_Commit   => TRUE);

                l_Similar_Ap := Find_Similar_Family (p_Data => l_Data);
            ELSE
                Check_Appeal_Access (l_Ap_Id);

                IF NOT Dnet$appeal_Ext.Ap_Edit_Allowed (p_Ap_St   => l_Ap_St,
                                                        p_Ap_Tp   => c_Ap_Tp) =
                       'T'
                THEN
                    Raise_Application_Error (
                        c_Err_Code_Not_Allowed,
                        'Редагування звернення в поточному статусі заборонено');
                END IF;
            END IF;

            --Конвертація
            Decode_Application_Data (
                p_Data                => l_Data,
                p_Com_Org             => l_Com_Org,
                p_Ap_Services         => l_Ap_Services,
                p_Ap_Persons          => l_Ap_Persons,
                p_Ap_Payments         => l_Ap_Payments,
                p_Ap_Documents        => l_Ap_Documents,
                p_Ap_Document_Attrs   => l_Ap_Document_Attrs);

            IF l_Similar_Ap IS NOT NULL
            THEN
                Save_Rn_Ap (p_Rn_Id => l_Rn_Id, p_Ap_Id => l_Similar_Ap);

                --В l_Ap_Persons залишаємо лише нову дитину (прибираємо заявника та інших дітей)
                FOR i IN 1 .. l_Ap_Persons.COUNT
                LOOP
                    IF i <> 2
                    THEN
                        l_Ap_Persons.Delete (i);
                    END IF;
                END LOOP;

                l_Ap_Persons (2).App_Num := NULL;

                --ЗБЕРЕЖЕННЯ НОВОГО УЧАСНИКІВ
                Save_Persons (l_Similar_Ap, l_Ap_Persons);
                --ЗБЕРЕЖЕННЯ ДОКУМЕНТІВ
                Save_Documents (l_Similar_Ap,
                                l_Ap_Documents,
                                l_Ap_Persons,
                                l_Ap_Document_Attrs);

                SELECT Ap_St
                  INTO l_Ap_St
                  FROM Appeal
                 WHERE Ap_Id = l_Similar_Ap;

                l_Hs_Id := Tools.Gethistsession ();
                --Пишемо повідомлення в журнал
                Api$appeal.Write_Log (
                    p_Apl_Ap   => l_Similar_Ap,
                    p_Apl_Hs   => l_Hs_Id,
                    p_Apl_St   => l_Ap_St,
                    p_Apl_Message   =>
                           CHR (38)
                        || '378#'
                        || TRIM (
                                  l_Ap_Persons (2).App_Ln
                               || ' '
                               || l_Ap_Persons (2).App_Fn
                               || ' '
                               || l_Ap_Persons (2).App_Mn));
            ELSE
                l_Ap_St := Api$appeal.c_Ap_St_Reg_In_Work;

                Api$appeal.Save_Appeal (
                    p_Ap_Id               => l_Ap_Id,
                    p_Ap_Num              => NULL,
                    p_Ap_Reg_Dt           => l_Data.Application_Date,
                    p_Ap_Create_Dt        => SYSDATE,
                    p_Ap_Src              => c_Src_Dracs,
                    p_Ap_St               => l_Ap_St,
                    p_Com_Org             => l_Com_Org,
                    p_Ap_Dest_Org         => l_Com_Org,
                    p_Ap_Is_Second        => 'F',
                    p_Ap_Vf               => NULL,
                    p_Com_Wu              => NULL,
                    p_Ap_Tp               => c_Ap_Tp,
                    p_New_Id              => l_Ap_Id,
                    p_Ap_Ext_Ident        => l_Data.Request_Id,
                    p_Ap_Doc              => NULL,
                    p_Ap_Is_Ext_Process   => 'F');

                Save_Rn_Ap (p_Rn_Id => l_Rn_Id, p_Ap_Id => l_Ap_Id);

                Clear_Appeal (p_Ap_Id => l_Ap_Id);

                --Збереження послуг
                IF l_Ap_Services IS NOT NULL
                THEN
                    Save_Services (l_Ap_Id, l_Ap_Services);
                END IF;

                --ЗБЕРЕЖЕННЯ УЧАСНИКІВ
                IF l_Ap_Persons IS NOT NULL
                THEN
                    Save_Persons (l_Ap_Id, l_Ap_Persons);
                END IF;

                --ЗБЕРЕЖЕННЯ СПОСОБІВ ВИПЛАТ
                IF l_Ap_Payments IS NOT NULL
                THEN
                    Save_Payments (l_Ap_Id,
                                   l_Ap_Payments,
                                   l_Ap_Services,
                                   l_Ap_Persons);
                END IF;

                --ЗБЕРЕЖЕННЯ ДОКУМЕНТІВ
                IF l_Ap_Documents IS NOT NULL
                THEN
                    Save_Documents (l_Ap_Id,
                                    l_Ap_Documents,
                                    l_Ap_Persons,
                                    l_Ap_Document_Attrs);
                END IF;

                l_Hs_Id := Tools.Gethistsession ();
                --Пишемо повідомлення в журнал
                Api$appeal.Write_Log (
                    p_Apl_Ap   => l_Ap_Id,
                    p_Apl_Hs   => l_Hs_Id,
                    p_Apl_St   => l_Ap_St,
                    p_Apl_Message   =>
                        CASE
                            WHEN l_Ap_Id IS NULL THEN CHR (38) || '1'
                            ELSE CHR (38) || '2'
                        END);
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                IF SQLCODE > -20000
                THEN
                    l_Fault_Code := 400;
                    l_Fault_Details :=
                        'Запит має помилку або не може бути оброблений';

                    Ikis_Rbm.Api$uxp_Request.Save_Request_Error (
                        p_Ure_Ur        => p_Request_Id,
                        p_Ure_Row_Id    => 1,
                        p_Ure_Row_Num   => 1,
                        p_Ure_Error     =>
                               SQLERRM
                            || CHR (13)
                            || DBMS_UTILITY.Format_Error_Stack
                            || DBMS_UTILITY.Format_Error_Backtrace);
                ELSE
                    l_Fault_Code := (SQLCODE + 20000) * -1;
                    l_Fault_Details :=
                        REPLACE (SQLERRM, 'ORA' || SQLCODE || ': ', '');
                END IF;
        END;

       <<resp>>
        IF l_Fault_Code IS NULL
        THEN
            l_Request_Receive_Status := 0;      -- інформацію прийнято успішно
            l_Fault_Code := 0;
        ELSE
            l_Request_Receive_Status := 1; -- повідомлення не пройшло технічну верифікацію
        END IF;

        SELECT XMLELEMENT (
                   "ApplicationDataResponse",
                   XMLELEMENT ("requestID", l_Data.Request_Id),
                   XMLELEMENT ("requestReceiveStatus",
                               l_Request_Receive_Status),
                   XMLELEMENT ("faultCode", l_Fault_Code),
                   XMLELEMENT ("faultDetails", l_Fault_Details))
          INTO l_Response
          FROM DUAL;

        RETURN l_Response.Getclobval;
    END;

    --------------------------------------------------------------------------
    --  Реєстрація запиту на передачу статусу звернення до ДРАЦС
    --------------------------------------------------------------------------
    PROCEDURE Reg_Dracs_Application_Result_Req (
        p_Ap_Id     IN NUMBER,
        p_Ap_St     IN VARCHAR2,
        p_Message   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Ap_Src                Appeal.Ap_Src%TYPE;
        l_Ap_Vf                 NUMBER;
        l_Ur_Id                 NUMBER;
        l_Rn_Id                 NUMBER;
        c_Ur_Urt       CONSTANT NUMBER := 132;
        c_Rn_Nrt       CONSTANT NUMBER := 132;
        --Константи для параметрів запиту
        c_Pt_Ap_Vf     CONSTANT NUMBER := 310;
        c_Pt_Ap_St     CONSTANT NUMBER := 311;
        c_Pt_Message   CONSTANT NUMBER := 259;

        PROCEDURE Add_Param (p_Param     IN NUMBER,
                             p_Val_Str   IN VARCHAR2 DEFAULT NULL,
                             p_Val_Dt    IN DATE DEFAULT NULL,
                             p_Val_Id    IN NUMBER DEFAULT NULL)
        IS
        BEGIN
            IF p_Val_Str IS NULL AND p_Val_Dt IS NULL AND p_Val_Id IS NULL
            THEN
                RETURN;
            END IF;

            Ikis_Rbm.Api$request.Save_Rn_Common_Info (
                p_Rnc_Rn           => l_Rn_Id,
                p_Rnc_Pt           => p_Param,
                p_Rnc_Val_String   => p_Val_Str,
                p_Rnc_Val_Dt       => p_Val_Dt,
                p_Rnc_Val_Id       => l_Ap_Vf);
        END;
    BEGIN
        --Для ДРАЦС необхідні лише кінцеві статуси, без проміжних
        IF p_Ap_St NOT IN ('V',
                           'VE',
                           'X',
                           'D')
        THEN
            RETURN;
        END IF;

        SELECT a.Ap_Src, a.Ap_Vf
          INTO l_Ap_Src, l_Ap_Vf
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        IF l_Ap_Src <> c_Src_Dracs
        THEN
            RETURN;
        END IF;

        Ikis_Rbm.Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE + INTERVAL '5' MINUTE,
            p_Ur_Urt         => c_Ur_Urt,
            p_Ur_Create_Wu   => NULL,
            p_Ur_Ext_Id      => p_Ap_Id,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => c_Rn_Nrt,
            p_Rn_Src         => l_Ap_Src,
            p_Rn_Hs_Ins      => NULL,
            p_New_Rn_Id      => l_Rn_Id);

        IF p_Ap_St = Api$appeal.c_Ap_St_Not_Verified AND l_Ap_Vf IS NOT NULL
        THEN
            Add_Param (c_Pt_Ap_Vf, p_Val_Id => l_Ap_Vf);
        END IF;

        Add_Param (c_Pt_Ap_St, p_Val_Str => p_Ap_St);
        Add_Param (c_Pt_Message, p_Val_Str => p_Message);

        Save_Rn_Ap (p_Rn_Id => l_Rn_Id, p_Ap_Id => p_Ap_Id);
    END;

    --------------------------------------------------------------------------
    -- Отримання даних для запиту на зміну статуса звернення в ДРАЦС
    --------------------------------------------------------------------------
    FUNCTION Get_Dracs_Application_Result_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        --Константи для параметрів запиту
        c_Pt_Ap_Vf     CONSTANT NUMBER := 310;
        c_Pt_Ap_St     CONSTANT NUMBER := 311;
        c_Pt_Message   CONSTANT NUMBER := 259;

        l_Ur                    Ikis_Rbm.v_Uxp_Request%ROWTYPE;
        l_Ap_Id                 Appeal.Ap_Id%TYPE;
        l_Ap_St                 Appeal.Ap_St%TYPE;
        l_Ap_Vf                 Appeal.Ap_Vf%TYPE;
        l_Message               VARCHAR2 (4000);
        l_Error_Code            VARCHAR2 (10);
        l_Error_Text            VARCHAR2 (4000);
        l_Ap_Ext_Ident          Appeal.Ap_Ext_Ident%TYPE;
        l_Request_Payload       XMLTYPE;

        FUNCTION Get_Val_Str (p_Param NUMBER)
            RETURN VARCHAR2
        IS
        BEGIN
            RETURN Ikis_Rbm.Api$request.Get_Rn_Common_Info_String (
                       l_Ur.Ur_Rn,
                       p_Param);
        END;

        FUNCTION Get_Val_Dt (p_Param NUMBER)
            RETURN DATE
        IS
        BEGIN
            RETURN Ikis_Rbm.Api$request.Get_Rn_Common_Info_Dt (l_Ur.Ur_Rn,
                                                               p_Param);
        END;

        FUNCTION Get_Val_Id (p_Param NUMBER)
            RETURN NUMBER
        IS
        BEGIN
            RETURN Ikis_Rbm.Api$request.Get_Rn_Common_Info_Id (l_Ur.Ur_Rn,
                                                               p_Param);
        END;
    BEGIN
        IF Ikis_Rbm.Api$uxp_Request.Is_Same_Request_In_Queue (p_Ur_Id)
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    =>
                    'По цьому зверненню є інший запит в черзі');
        END IF;

        l_Ur := Ikis_Rbm.Api$uxp_Request.Get_Vrequest (p_Ur_Id => p_Ur_Id);
        l_Ap_Id := l_Ur.Ur_Ext_Id;

        l_Ap_St := Get_Val_Str (c_Pt_Ap_St);
        l_Ap_Vf := Get_Val_Id (c_Pt_Ap_Vf);
        l_Message := Get_Val_Str (c_Pt_Message);

        IF     l_Message IS NULL
           AND l_Ap_St = Api$appeal.c_Ap_St_Not_Verified
           AND l_Ap_Vf IS NOT NULL
        THEN
            --Формуємо повідомлення щодо причин неуспішної верифікації
            SELECT LISTAGG (
                          CASE
                              WHEN p.App_Id IS NOT NULL
                              THEN
                                     p.App_Ln
                                  || ' '
                                  || p.App_Fn
                                  || ' '
                                  || p.App_Mn
                                  || ': '
                          END
                       || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                              l.Vfl_Message),
                       ';' || CHR (13) || CHR (10))
                   WITHIN GROUP (ORDER BY l.Vfl_Id)
              INTO l_Message
              FROM Vf_Log  l
                   JOIN Verification v ON l.Vfl_Vf = v.Vf_Id
                   JOIN Verification Vv ON v.Vf_Vf_Main = Vv.Vf_Id
                   LEFT JOIN Ap_Person p
                       ON Vv.Vf_Obj_Tp = 'P' AND Vv.Vf_Obj_Id = p.App_Id
             WHERE     l.Vfl_Vf IN
                           (    SELECT t.Vf_Id
                                  FROM Verification t
                                 WHERE t.Vf_Nvt <>
                                       Api$verification.c_Nvt_Rzo_Search
                            START WITH t.Vf_Id = l_Ap_Vf
                            CONNECT BY PRIOR t.Vf_Id = t.Vf_Vf_Main)
                   AND l.Vfl_Tp IN ('W', 'E');

            --#112668, у разі відсутності Попереджень або Помилок виводимо Технічні помилки
            IF l_Message IS NULL
            THEN
                SELECT LISTAGG (
                              CASE
                                  WHEN p.App_Id IS NOT NULL
                                  THEN
                                         p.App_Ln
                                      || ' '
                                      || p.App_Fn
                                      || ' '
                                      || p.App_Mn
                                      || ': '
                              END
                           || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                  l.Vfl_Message),
                           ';' || CHR (13) || CHR (10))
                       WITHIN GROUP (ORDER BY l.Vfl_Id)
                  INTO l_Message
                  FROM Vf_Log  l
                       JOIN Verification v ON l.Vfl_Vf = v.Vf_Id
                       JOIN Verification Vv ON v.Vf_Vf_Main = Vv.Vf_Id
                       LEFT JOIN Ap_Person p
                           ON Vv.Vf_Obj_Tp = 'P' AND Vv.Vf_Obj_Id = p.App_Id
                 WHERE     l.Vfl_Vf IN
                               (    SELECT t.Vf_Id
                                      FROM Verification t
                                     WHERE t.Vf_Nvt <>
                                           Api$verification.c_Nvt_Rzo_Search
                                START WITH t.Vf_Id = l_Ap_Vf
                                CONNECT BY PRIOR t.Vf_Id = t.Vf_Vf_Main)
                       AND l.Vfl_Tp IN ('T');
            END IF;
        ELSIF l_Message IS NOT NULL
        THEN
            l_Message := Uss_Ndi.Rdm$msg_Template.Getmessagetext (l_Message);
        END IF;

        SELECT a.Ap_Ext_Ident
          INTO l_Ap_Ext_Ident
          FROM Appeal a
         WHERE a.Ap_Id = l_Ap_Id;

        IF l_Ap_St IN ('VE', 'X', 'D')
        THEN
            l_Error_Code := l_Ap_St;
            l_Error_Text := l_Message;
            l_Message := NULL;
            l_Ap_St := 0;
        ELSE
            l_Ap_St := 1;
        END IF;

        SELECT XMLELEMENT (
                   "dracs:ApplicationResult",
                   Xmlattributes (
                       'http://nais.gov.ua/api/sevdeir/DRACS'
                           AS "xmlns:dracs"),
                   XMLELEMENT ("dracs:requestID", l_Ap_Ext_Ident),
                   XMLELEMENT ("dracs:serviceProcessingStatus", l_Ap_St),
                   XMLELEMENT ("dracs:serviceProcessingResult", l_Message),
                   XMLELEMENT ("dracs:serviceProcessingResult", l_Error_Code),
                   XMLELEMENT ("dracs:serviceProcessingResult", l_Error_Text))
          INTO l_Request_Payload
          FROM DUAL;

        RETURN l_Request_Payload.Getclobval;
    END;

    --------------------------------------------------------------------------
    -- Обробка відповіді на запит на зміну статуса звернення в ДРАЦС
    --------------------------------------------------------------------------
    PROCEDURE Handle_Dracs_Application_Result_Req (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_Response   r_Application_Result_Response;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            BEGIN
                EXECUTE IMMEDIATE Type2xmltable (
                                     p_Pkg_Name   => Package_Name,
                                     p_Type_Name   =>
                                         'R_APPLICATION_RESULT_RESPONSE')
                    USING IN p_Response, OUT l_Response;

                --Request_Receive_Status: 0 - інформацію прийнято успішно, 1 - повідомлення не пройшло технічну верифікацію
                p_Error := l_Response.Fault_Details;

                IF p_Error IS NOT NULL
                THEN
                    Dnet$appeal_Ext.Write_Error (
                        p_Apl_Ap        =>
                            Ikis_Rbm.Api$uxp_Request.Get_Request_Ext_Id (
                                p_Ur_Id),
                        p_Apl_Message   => p_Error);
                END IF;

                RETURN;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;
        END IF;

        IF p_Error IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 60,
                p_Delay_Reason    => p_Error);
        END IF;
    END;
END Dnet$exch_Mju;
/