/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_MVE
IS
    -- Author  : SHOSTAK
    -- Created : 24.03.2023 4:34:39 PM
    -- Purpose : Запити до міністерства ветеранів

    Package_Name       CONSTANT VARCHAR2 (50) := 'API$REQUEST_MVE';

    TYPE r_Address IS RECORD
    (
        "addressType"       VARCHAR2 (30),
        "addressCode"       VARCHAR2 (20),
        "postcode"          VARCHAR2 (10),
        "addressStreet"     VARCHAR2 (250),
        "buildingNumber"    VARCHAR2 (50),
        "corpNumber"        VARCHAR2 (50),
        "flatNumber"        VARCHAR2 (50),
        "isHomeless"        BOOLEAN
    );

    TYPE r_Person_Category IS RECORD
    (
        "category"        VARCHAR2 (10),
        "NbcNormAct"      VARCHAR2 (4000),
        "seriesNumber"    VARCHAR2 (10),
        "docNumber"       VARCHAR2 (50),
        "docDateFrom"     DATE,
        "companyText"     VARCHAR2 (4000),
        "docDateTo"       DATE
    );

    TYPE t_Person_Catefory_List IS TABLE OF r_Person_Category;

    TYPE r_Benefit_Usage IS RECORD
    (
        "benefitL4Code"              VARCHAR2 (10),
        "benefitL4Name"              VARCHAR2 (4000),
        "categoryCode"               VARCHAR2 (10),
        "categoryName"               VARCHAR2 (4000),
        "socialPaymentPercentage"    VARCHAR2 (10),
        "benefitDateFrom"            DATE,
        "benefitDateTo"              DATE,
        --
        --"socialPaymentType"   VARCHAR2(10),
        "socialPaymentAmount"        NUMBER,
        "benefitUsedState"           VARCHAR2 (4000)
    );

    TYPE t_Benefit_Usage_List IS TABLE OF r_Benefit_Usage;

    TYPE r_decision_Info IS RECORD
    (
        "pdPayTp"      VARCHAR2 (10),
        "pdStartDt"    DATE,
        "pdStopDt"     DATE
    );

    TYPE t_decisions_Info IS TABLE OF r_decision_Info;

    TYPE r_Disability_Data IS RECORD
    (
        "disabilityGroup"          VARCHAR2 (10),
        "disabilityDateFrom"       DATE,
        "isDisabilityPerpetual"    BOOLEAN,
        "diasabilityReason"        VARCHAR2 (1000),
        "diagnosisNosology"        VARCHAR2 (4000),
        "isAmputationMoreOne"      BOOLEAN
    );

    TYPE t_Disability_Data IS TABLE OF r_Disability_Data;

    TYPE r_Disability_Rehab IS RECORD
    (
        "rehabItem"                        VARCHAR2 (4000),
        "requestRehabItemProvisionDate"    DATE,
        "rehabItemProvisionDate"           DATE,
        "rehabItemDateTo"                  DATE
    );

    TYPE t_Disability_Rehab_List IS TABLE OF r_Disability_Rehab;

    TYPE r_Car_Provision IS RECORD
    (
        "caseStartDate"            DATE,
        "priorityQueueCategory"    VARCHAR2 (200),
        "caseNumber"               VARCHAR2 (200),
        "provisionDate"            DATE,
        "caseEndDate"              DATE
    );

    TYPE t_Car_Provision_List IS TABLE OF r_Car_Provision;

    TYPE r_Sanatory_Provision IS RECORD
    (
        "requestDate"                 DATE,
        "requestNumber"               VARCHAR2 (200),
        "recommendedRestPlaces"       VARCHAR2 (4000),
        "recommendedSeason"           VARCHAR2 (200),
        "sanTreatProfile"             VARCHAR2 (4000),
        "organizationProviderCode"    VARCHAR2 (10),
        "organizationProviderName"    VARCHAR2 (4000),
        "contractServiceStartDate"    DATE,
        "contractServiceEndDate"      DATE,
        "contractSum"                 NUMBER (10, 2),
        "refusalActDate"              DATE,
        "refusalActNumber"            VARCHAR2 (200),
        "caseEndDate"                 DATE
    );

    TYPE t_Sanatory_Provision_List IS TABLE OF r_Sanatory_Provision;

    TYPE r_Create_Vet_Request IS RECORD
    (
        "firstName"                 VARCHAR2 (200),
        "middleName"                VARCHAR2 (200),
        "lastName"                  VARCHAR2 (200),
        "dateBirth"                 DATE,
        "personGender"              VARCHAR2 (200),
        "rnokpp"                    VARCHAR2 (10),
        "mainPersonDocType"         VARCHAR2 (200),
        "docSeriesNumber"           VARCHAR2 (200),
        "primaryPhone"              VARCHAR2 (200),
        "primaryAddress"            r_Address,
        "personCategoryListData"    t_Person_Catefory_List,
        "benefitUsageListData"      t_Benefit_Usage_List,
        "decisionsInfo"             t_decisions_Info,
        "disabilityListData"        t_Disability_Data,
        "disabilityRehab"           t_Disability_Rehab_List,
        "carProvision"              t_Car_Provision_List,
        "sanTreatmentData"          t_Sanatory_Provision_List,
        "reasonTo"                  VARCHAR2 (200),
        "endDate"                   DATE
    );

    TYPE r_Mve_Response IS RECORD
    (
        Status_Code    VARCHAR2 (10),
        MESSAGE        VARCHAR2 (4000)
    );

    c_Status_Code_Ok   CONSTANT NUMBER := '0';

    PROCEDURE Reg_Create_Vet_Req (
        p_Sc_Id       IN     NUMBER,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Build_Create_Vet_Req (
        p_Create_Vet_Request   IN OUT NOCOPY r_Create_Vet_Request)
        RETURN CLOB;

    FUNCTION Parse_Create_Vet_Resp (p_Response IN CLOB)
        RETURN r_Mve_Response;
END Api$request_Mve;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVE TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVE TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVE TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVE TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVE TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MVE TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_MVE
IS
    --------------------------------------------------------------------
    --  Реєстрація запиту на передачу інформації про ветерана
    --------------------------------------------------------------------
    PROCEDURE Reg_Create_Vet_Req (
        p_Sc_Id       IN     NUMBER,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE)
    IS
        l_Ur_Id    NUMBER;
        l_Rnp_Id   NUMBER;
    BEGIN
        Api$uxp_Request.Register_Out_Request (p_Ur_Plan_Dt     => p_Plan_Dt,
                                              p_Ur_Urt         => NULL,
                                              p_Ur_Create_Wu   => NULL,
                                              p_Ur_Ext_Id      => p_Sc_Id,
                                              p_Ur_Body        => NULL,
                                              p_New_Id         => l_Ur_Id,
                                              p_Rn_Nrt         => p_Rn_Nrt,
                                              p_Rn_Src         => p_Rn_Src,
                                              p_Rn_Hs_Ins      => p_Rn_Hs_Ins,
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
    END;

    --------------------------------------------------------------------
    --  Формування даних для запиту на передачу інформації про ветерана
    --------------------------------------------------------------------
    FUNCTION Build_Create_Vet_Req (
        p_Create_Vet_Request   IN OUT NOCOPY r_Create_Vet_Request)
        RETURN CLOB
    IS
        l_Req   CLOB;
    BEGIN
        EXECUTE IMMEDIATE Type2json (Package_Name,
                                     'R_CREATE_VET_REQUEST',
                                     'yyyy-mm-dd')
            USING IN p_Create_Vet_Request, OUT l_Req;

        RETURN '{"data": [' || l_Req || ']}';
    END;

    --------------------------------------------------------------------
    --  Парсинг відповіді на запит на передачу інформації про ветерана
    --------------------------------------------------------------------
    FUNCTION Parse_Create_Vet_Resp (p_Response IN CLOB)
        RETURN r_Mve_Response
    IS
        l_Resp   r_Mve_Response;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            EXECUTE IMMEDIATE Type2jsontable (Package_Name, 'R_MVE_RESPONSE')
                USING IN p_Response, OUT l_Resp;
        END IF;

        RETURN l_Resp;
    END;
END Api$request_Mve;
/