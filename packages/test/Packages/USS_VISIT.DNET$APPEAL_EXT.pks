/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$APPEAL_EXT
IS
    -- Author  : SHOSTAK
    -- Created : 04.08.2021 8:45:02
    -- Purpose : обробка звернень зовнішніми ресурсами

    Package_Name             CONSTANT VARCHAR2 (100) := 'DNET$APPEAL_EXT';

    c_Xml_Dt_Fmt             CONSTANT VARCHAR2 (30) := 'dd.mm.yyyy hh24:mi:ss';

    c_Community_Ndt_In       CONSTANT NUMBER := 678;
    c_Community_Ndt_Out      CONSTANT NUMBER := 682;

    c_Decision_Ndt           CONSTANT NUMBER := 10051;

    c_Err_Code_Bad_Req       CONSTANT NUMBER := -20002;
    c_Err_Code_Not_Allowed   CONSTANT NUMBER := -20005;
    c_Err_Code_Not_Found     CONSTANT NUMBER := -20006;

    --Атрибути докумена
    TYPE r_Ap_Document_Attr IS RECORD
    (
        Apda_Id            Ap_Document_Attr.Apda_Id%TYPE,
        Apda_Nda           Ap_Document_Attr.Apda_Nda%TYPE,
        Apda_Val_String    Ap_Document_Attr.Apda_Val_String%TYPE,
        Apda_Val_Int       Ap_Document_Attr.Apda_Val_Int%TYPE,
        Apda_Val_Dt        VARCHAR2 (30),
        Apda_Val_Id        Ap_Document_Attr.Apda_Val_Id%TYPE,
        Apda_Val_Sum       VARCHAR2 (30),
        Apda_Apd           Ap_Document_Attr.Apda_Apd%TYPE,
        Deleted            NUMBER
    );

    TYPE t_Ap_Document_Attrs IS TABLE OF r_Ap_Document_Attr;

    TYPE t_String_List IS TABLE OF VARCHAR2 (100);

    TYPE r_Diia_Error IS RECORD
    (
        Code       VARCHAR2 (100),
        MESSAGE    VARCHAR2 (4000)
    );

    TYPE r_Diia_Response IS RECORD
    (
        Error    r_Diia_Error
    );

    /* #113826 serhii: 10336 - JSON до заяви про намір на отримання БСД */

    -- Тип для документа
    TYPE r_document IS RECORD
    (
        type_             VARCHAR2 (50),
        serie             VARCHAR2 (10),
        number_           VARCHAR2 (20),
        issueDate         DATE,
        expirationDate    DATE,
        recordNumber      VARCHAR2 (20),
        authority         VARCHAR2 (100)
    );

    TYPE t_document IS TABLE OF r_document;

    -- Тип для місця реєстрації
    TYPE r_registration_place IS RECORD
    (
        type_         VARCHAR2 (50),
        katottg       VARCHAR2 (20),
        city          VARCHAR2 (50),
        streetType    VARCHAR2 (20),
        streetName    VARCHAR2 (50),
        building      VARCHAR2 (20),
        block_        VARCHAR2 (20),
        appartment    VARCHAR2 (20)
    );

    TYPE t_registration_place IS TABLE OF r_registration_place;

    -- Тип для партнера
    TYPE r_partner IS RECORD
    (
        firstName     VARCHAR2 (50),
        lastName      VARCHAR2 (50),
        middleName    VARCHAR2 (50),
        rnokpp        VARCHAR2 (20),
        passport      r_document
    );

    -- Тип для сертифікату
    TYPE r_certificate IS RECORD
    (
        type_        VARCHAR2 (20),
        series       VARCHAR2 (10),
        number_      VARCHAR2 (20),
        issueDate    DATE,
        issuer       VARCHAR2 (50),
        partner      r_partner
    );

    -- Тип для сімейного стану
    TYPE r_marital_status IS RECORD
    (
        type_          VARCHAR2 (20),
        certificate    r_certificate
    );

    -- Тип для доходів
    TYPE r_income_tax IS RECORD
    (
        incomeAccrued            NUMBER,
        incomePaid               NUMBER,
        taxCharged               NUMBER,
        taxTransferred           NUMBER,
        signOfIncomePrivilege    VARCHAR2 (20),
        dateOfEmployment         DATE,
        dateOfDismissal          DATE
    );

    TYPE r_sources_of_income IS RECORD
    (
        taxAgent        VARCHAR2 (50),
        nameTaxAgent    VARCHAR2 (100)
    );

    TYPE r_income IS RECORD
    (
        resultIncome       VARCHAR2 (100),
        sourcesOfIncome    r_sources_of_income,
        incomeTax          r_income_tax
    );

    TYPE t_income IS TABLE OF r_income;

    -- Тип для періоду запиту доходів
    TYPE r_request_period IS RECORD
    (
        beginQuarter    NUMBER,
        beginYear       NUMBER,
        endQuarter      NUMBER,
        endYear         NUMBER
    );

    -- Тип для звіту про доходи
    TYPE r_income_statement IS RECORD
    (
        requestPeriod    r_request_period,
        incomes          t_income
    );

    -- Тип для страхових виплат
    TYPE r_payment IS RECORD
    (
        month_         VARCHAR2 (10),
        sumPayment     NUMBER,
        sympType       VARCHAR2 (20),
        socFKod        VARCHAR2 (20),
        codeInsurer    VARCHAR2 (20),
        payInsurer     VARCHAR2 (20),
        isPens         BOOLEAN
    );

    TYPE t_payment IS TABLE OF r_payment;

    TYPE r_insuranceExp IS RECORD
    (
        years     NUMBER,
        months    NUMBER,
        days      NUMBER
    );

    -- Тип для соціального страхування
    TYPE r_social_insurance IS RECORD
    (
        periodStart     DATE,
        periodStop      DATE,
        payments        t_payment,
        insuranceExp    r_insuranceExp
    );

    -- Тип для нерухомості
    TYPE r_address IS RECORD
    (
        katottg       VARCHAR2 (20),
        city          VARCHAR2 (50),
        streetType    VARCHAR2 (20),
        streetName    VARCHAR2 (50),
        building      VARCHAR2 (20),
        block_        VARCHAR2 (20),
        appartment    VARCHAR2 (20)
    );

    TYPE r_realty IS RECORD
    (
        reType          VARCHAR2 (50),
        prKind          VARCHAR2 (50),
        cdType          VARCHAR2 (50),
        regDate         DATE,
        area            NUMBER,
        prCommonKind    VARCHAR2 (20),
        partSize        NUMBER,
        idEdra          VARCHAR2 (20),
        address         r_address
    );

    TYPE t_realty IS TABLE OF r_realty;

    -- Тип для пошкодженої нерухомості
    TYPE r_damaged_realty IS RECORD
    (
        objectName     VARCHAR2 (100),
        idEdra         VARCHAR2 (20),
        destroyDt      DATE,
        destroyCat     VARCHAR2 (50),
        fullDestroy    BOOLEAN,
        address        r_address
    );

    TYPE t_damaged_realty IS TABLE OF r_damaged_realty;

    -- Тип для транспортних засобів
    TYPE r_vehicle IS RECORD
    (
        vehicleType    VARCHAR2 (50),
        prodYear       VARCHAR2 (4),
        purchDate      DATE
    );

    TYPE t_vehicle IS TABLE OF r_vehicle;

    -- Тип для освіти
    TYPE r_education IS RECORD
    (
        edName       VARCHAR2 (100),
        edrpou       VARCHAR2 (20),
        dateBegin    DATE,
        dateEnd      DATE,
        dateStop     DATE
    );

    TYPE t_education IS TABLE OF r_education;

    -- Тип для фінансових операцій
    TYPE r_financial_transactions IS RECORD
    (
        notBuyingProperty      BOOLEAN,
        notBuyingCurrencies    BOOLEAN,
        noDeposits             BOOLEAN
    );

    -- Тип для контактів
    TYPE r_contacts IS RECORD
    (
        email    VARCHAR2 (100),
        phone    VARCHAR2 (20)
    );

    -- Тип для члена сім'ї
    TYPE r_family_member_data IS RECORD
    (
        firstName                      VARCHAR2 (50),
        lastName                       VARCHAR2 (50),
        middleName                     VARCHAR2 (50),
        birthDate                      DATE,
        rnokpp                         VARCHAR2 (20),
        gender                         VARCHAR2 (10),
        hasDisabilities                BOOLEAN,
        isInternallyDisplacedPerson    BOOLEAN,
        documents                      t_document,
        birthPlace                     VARCHAR2 (100),
        residenceRegistrationPlace     r_address,
        incomeStatement                r_income_statement,
        socialInsurance                r_social_insurance,
        realty                         t_realty,
        damagedRealty                  t_damaged_realty,
        vehicles                       t_vehicle,
        education                      t_education,
        financialTransactions          r_financial_transactions
    );

    TYPE r_family_member IS RECORD
    (
        familyMemberType    VARCHAR2 (20),
        data_               r_family_member_data
    );

    TYPE t_family IS TABLE OF r_family_member;

    -- Тип заявника
    TYPE r_applicant IS RECORD
    (
        firstName                      VARCHAR2 (50),
        lastName                       VARCHAR2 (50),
        middleName                     VARCHAR2 (50),
        birthDate                      DATE,
        rnokpp                         VARCHAR2 (20),
        gender                         VARCHAR2 (10),
        isInternallyDisplacedPerson    BOOLEAN,
        documents                      t_document,
        birthPlace                     VARCHAR2 (100),
        registrationPlace              t_registration_place,
        maritalStatus                  r_marital_status,
        incomeStatement                r_income_statement,
        socialInsurance                r_social_insurance,
        realty                         t_realty,
        damagedRealty                  t_damaged_realty,
        vehicles                       t_vehicle,
        education                      t_education,
        financialTransactions          r_financial_transactions,
        contacts                       r_contacts
    );

    -- Дані звернення
    TYPE r_Apl_Data IS RECORD
    (
        applicant    r_applicant,
        family       t_family
    );

    -- Звернення
    TYPE r_Application IS RECORD
    (
        requestId        VARCHAR2 (50),
        creationDate     DATE,
        data_            r_Apl_Data,
        dataSignature    VARCHAR2 (100)
    );

    -- root node
    TYPE r_Appeal_Data IS RECORD
    (
        Application    r_Application
    );

    /* #113826 serhii: 10336 - JSON до заяви про намір на отримання БСД */


    FUNCTION To_Money (p_Str VARCHAR2)
        RETURN NUMBER;

    FUNCTION Ap_Edit_Allowed (p_Ap_St IN VARCHAR2, p_Ap_Tp IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Get_Ap_Info (p_Ap_Id                  NUMBER,
                           p_Ap_Doc             OUT NUMBER,
                           p_Doc_Edit_Allowed   OUT VARCHAR2,
                           p_Docs_Cur           OUT SYS_REFCURSOR,
                           p_Files_Cur          OUT SYS_REFCURSOR);

    FUNCTION Get_Services_Xml (p_Ap_Id IN NUMBER)
        RETURN XMLTYPE;

    FUNCTION Get_Persons_Xml (p_Ap_Id IN NUMBER)
        RETURN XMLTYPE;

    FUNCTION Get_Payments_Xml (p_Ap_Id IN NUMBER)
        RETURN XMLTYPE;

    FUNCTION Get_Attribute_Xml (p_Apda_Id           IN NUMBER,
                                p_Apda_Apd          IN NUMBER,
                                p_Apda_Nda          IN NUMBER,
                                p_Apda_Val_Int      IN NUMBER,
                                p_Apda_Val_Dt       IN DATE,
                                p_Apda_Val_String   IN VARCHAR2,
                                p_Apda_Val_Id       IN NUMBER,
                                p_Apda_Val_Sum      IN NUMBER)
        RETURN XMLTYPE;

    FUNCTION Get_Documents_Xml (p_Ap_Id      IN NUMBER,
                                p_Ndt_List   IN VARCHAR2 DEFAULT NULL)
        RETURN XMLTYPE;

    FUNCTION Get_Declaration_Xml (p_Ap_Id IN NUMBER)
        RETURN XMLTYPE;

    FUNCTION Get_Appeal_Xml (p_Ap_Id   IN NUMBER,
                             p_Rn_Id   IN NUMBER DEFAULT NULL)
        RETURN CLOB;

    PROCEDURE Save_Appeal (p_Ap_Id            IN OUT Appeal.Ap_Id%TYPE,
                           p_Ap_Is_Second     IN     Appeal.Ap_Is_Second%TYPE,
                           p_Ap_Tp            IN     Appeal.Ap_Tp%TYPE,
                           p_Ap_Reg_Dt        IN     Appeal.Ap_Reg_Dt%TYPE,
                           p_Ap_Src           IN     Appeal.Ap_Src%TYPE,
                           p_Ap_Doc           IN     Appeal.Ap_Doc%TYPE,
                           p_Ap_Ext_Ident     IN     VARCHAR2,
                           p_Ap_Com_Org       IN     VARCHAR2,
                           p_Ap_Services      IN     CLOB,
                           p_Ap_Persons       IN     CLOB,
                           p_Ap_Payments      IN     CLOB,
                           p_Ap_Documents     IN     CLOB,
                           p_Ap_Declaration   IN     CLOB,
                           p_Rn_Id            IN     NUMBER,
                           p_Saved_Appeal        OUT CLOB --XML збереженного звернення
                                                         );

    FUNCTION Decline_Appeal (p_Request IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Write_Error (p_Apl_Ap NUMBER, p_Apl_Message VARCHAR2);

    PROCEDURE Write_Log (p_Apl_Ap        NUMBER,
                         p_Apl_Message   VARCHAR2,
                         p_Apl_Tp        VARCHAR2 DEFAULT NULL);

    FUNCTION Get_Appeal_List_Xml (p_Ap_Search_Filter IN CLOB)
        RETURN CLOB;

    FUNCTION Get_Ndi_Xml (p_Ndi_Filter IN CLOB)
        RETURN CLOB;

    FUNCTION Get_Dic_Dv_Xml (p_Dic_Name IN VARCHAR2)
        RETURN XMLTYPE;

    FUNCTION Get_Dic_Xml (p_Dic_Name      IN VARCHAR,
                          p_Table_Name    IN VARCHAR2,
                          p_Field_Id      IN VARCHAR2,
                          p_Field_Name    IN VARCHAR2,
                          p_Field_Sname   IN VARCHAR2)
        RETURN XMLTYPE;

    FUNCTION Get_Ssd_Dic_Xml
        RETURN XMLTYPE;

    FUNCTION Decode_Ap_St (p_Ap_St               IN VARCHAR2,
                           p_Ap_Tp               IN VARCHAR2,
                           p_Ap_Is_Ext_Process   IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Get_Appeal_Process (p_Ap_Process_Filter   IN     CLOB,
                                  p_Rn_Id               IN     NUMBER,
                                  p_Ap_Log_Xml             OUT CLOB,
                                  p_Main_Cur               OUT SYS_REFCURSOR,
                                  p_Files_Cur              OUT SYS_REFCURSOR,
                                  p_Ap_Docs_Xml            OUT CLOB);

    FUNCTION Get_Person_Docs_Xml (p_Filter IN VARCHAR2)
        RETURN CLOB;

    PROCEDURE Get_Doc_Identifiers (p_Apd_Id    IN     NUMBER,
                                   p_Apd_Doc      OUT NUMBER,
                                   p_Apd_Dh       OUT NUMBER);

    PROCEDURE Get_Doc_Id (p_ap_id    IN     NUMBER,
                          p_ndt_id   IN     NUMBER,
                          p_app_id   IN     NUMBER,
                          o_apd_id      OUT NUMBER);

    PROCEDURE Save_Community_Doc (p_Aps_Id          IN     NUMBER,
                                  p_File_Hash       IN     VARCHAR2,
                                  p_Apd_Doc            OUT NUMBER,
                                  p_Apd_Dh             OUT NUMBER,
                                  p_File_Modified      OUT VARCHAR2);

    PROCEDURE Save_Community_Status_Sub (p_Aps_Id          IN     NUMBER,
                                         p_Status          IN     NUMBER,
                                         p_Status_Dt       IN     DATE,
                                         p_Code            IN     VARCHAR2,
                                         p_Message         IN     VARCHAR2,
                                         p_Apd_Doc         IN     NUMBER,
                                         p_Apd_Dh          IN     NUMBER,
                                         p_Rn_Id           IN     NUMBER,
                                         p_Error_Code         OUT NUMBER,
                                         p_Error_Message      OUT VARCHAR2);

    PROCEDURE Save_Community_Status_Aid (p_Aps_Id          IN     NUMBER,
                                         p_Status          IN     NUMBER,
                                         p_Status_Dt       IN     DATE,
                                         p_Code            IN     VARCHAR2,
                                         p_Message         IN     VARCHAR2,
                                         p_Decision_Dt     IN     DATE,
                                         p_Start_Dt        IN     DATE,
                                         p_Stop_Dt         IN     DATE,
                                         p_Aid_Sum         IN     NUMBER,
                                         p_Refuse_Reason   IN     VARCHAR2,
                                         p_Rn_Id           IN     NUMBER,
                                         p_Error_Code         OUT NUMBER,
                                         p_Error_Message      OUT VARCHAR2);

    FUNCTION Ssd2com_Org (p_Ssd_Code IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Save_Adopt_Status (p_Request IN CLOB);

    PROCEDURE Save_Vpo_Crt (p_Ap_Id IN NUMBER);

    PROCEDURE Save_Adopt_Person_Info (p_Rn_Id          IN NUMBER,
                                      p_Request_Body   IN BLOB);

    PROCEDURE Create_Decision_Doc (
        p_Ap_Id           IN NUMBER,
        p_Start_Dt        IN DATE DEFAULT NULL,
        p_Stop_Dt         IN DATE DEFAULT NULL,
        p_Aid_Sum         IN NUMBER DEFAULT NULL,
        p_Refuse_Reason   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Reg_Diia_Status_Send_Req (
        p_Ap_Id         IN NUMBER,
        p_Ap_St         IN VARCHAR2,
        p_Message       IN VARCHAR2 DEFAULT NULL,
        p_Decision_Dt   IN DATE DEFAULT NULL,
        p_Start_Dt      IN DATE DEFAULT NULL,
        p_Stop_Dt       IN DATE DEFAULT NULL,
        p_Sum           IN NUMBER DEFAULT NULL,
        p_Error         IN VARCHAR2 DEFAULT NULL);

    FUNCTION Get_Diia_Status_Send_Req (p_Ur_Id        IN     NUMBER,
                                       p_Url_Params      OUT VARCHAR2)
        RETURN CLOB;

    PROCEDURE Handle_Diia_Status_Send_Req (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2);
END Dnet$appeal_Ext;
/


GRANT EXECUTE ON USS_VISIT.DNET$APPEAL_EXT TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.DNET$APPEAL_EXT TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:00:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$APPEAL_EXT
IS
    FUNCTION To_Money (p_Str VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        IF p_Str IS NULL
        THEN
            RETURN NULL;
        END IF;

        RETURN TO_NUMBER (REPLACE (p_Str, ',', '.'),
                          '9999999999D99999',
                          'NLS_NUMERIC_CHARACTERS=''.,''');
    END;

    PROCEDURE Save_Rn_Ap (p_Rn_Id IN NUMBER, p_Ap_Id IN NUMBER)
    IS
    BEGIN
        Ikis_Rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                                  p_Rnc_Pt       => 209,
                                                  p_Rnc_Val_Id   => p_Ap_Id);
    END;

    FUNCTION Ap_Edit_Allowed (p_Ap_St IN VARCHAR2, p_Ap_Tp IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        CASE
            WHEN     p_Ap_Tp IN
                         (Api$appeal.c_Ap_Tp_Help, Api$appeal.c_Ap_Tp_Subs)
                 AND p_Ap_St NOT IN
                         (Api$appeal.c_Ap_St_Wait_Docs,
                          Api$appeal.c_Ap_St_Returned,
                          Api$appeal.c_Ap_St_Not_Verified)
            THEN
                RETURN 'F';
            ELSE
                RETURN 'T';
        END CASE;
    END;

    PROCEDURE Check_Ap_Integrity (p_Ap_Id         IN NUMBER,
                                  p_Table         IN VARCHAR2,
                                  p_Id_Field      IN VARCHAR2,
                                  p_Ap_Field      IN VARCHAR2,
                                  p_Id_Val           NUMBER,
                                  p_Entity_Name   IN VARCHAR2)
    IS
        l_Ap_Id   NUMBER;
    BEGIN
        IF NVL (p_Id_Val, -1) < 0
        THEN
            RETURN;
        END IF;

        EXECUTE IMMEDIATE   'SELECT MAX('
                         || p_Ap_Field
                         || ') FROM '
                         || p_Table
                         || ' WHERE '
                         || p_Id_Field
                         || '= :p_id'
            INTO l_Ap_Id
            USING p_Id_Val;

        IF l_Ap_Id IS NULL
        THEN
            Raise_Application_Error (
                c_Err_Code_Bad_Req,
                p_Entity_Name || '(ІД=' || p_Id_Val || ') не знайдено');
        END IF;

        IF l_Ap_Id <> p_Ap_Id
        THEN
            Raise_Application_Error (
                c_Err_Code_Bad_Req,
                   p_Entity_Name
                || '(ІД='
                || p_Id_Val
                || ') знайдено в іншому звернені');
        END IF;
    END;

    PROCEDURE Check_Apr_Integrity (p_Apr_Id        IN NUMBER,
                                   p_Table         IN VARCHAR2,
                                   p_Id_Field      IN VARCHAR2,
                                   p_Apr_Field     IN VARCHAR2,
                                   p_Id_Val           NUMBER,
                                   p_Entity_Name   IN VARCHAR2)
    IS
        l_Apr_Id   NUMBER;
    BEGIN
        IF NVL (p_Id_Val, -1) < 0
        THEN
            RETURN;
        END IF;

        EXECUTE IMMEDIATE   'SELECT MAX('
                         || p_Apr_Field
                         || ') FROM '
                         || p_Table
                         || ' WHERE '
                         || p_Id_Field
                         || '= :p_id'
            INTO l_Apr_Id
            USING p_Id_Val;

        IF l_Apr_Id IS NULL
        THEN
            Raise_Application_Error (
                c_Err_Code_Bad_Req,
                p_Entity_Name || '(ІД=' || p_Id_Val || ') не знайдено');
        END IF;

        IF l_Apr_Id <> p_Apr_Id
        THEN
            Raise_Application_Error (
                c_Err_Code_Bad_Req,
                   p_Entity_Name
                || '(ІД='
                || p_Id_Val
                || ') знайдено в іншій декларації');
        END IF;
    END;

    ---------------------------------------------------------------------
    --                Отримання даних звернення
    --                (перед збереженням)
    ---------------------------------------------------------------------
    PROCEDURE Get_Ap_Info (p_Ap_Id                  NUMBER,
                           p_Ap_Doc             OUT NUMBER,
                           p_Doc_Edit_Allowed   OUT VARCHAR2,
                           p_Docs_Cur           OUT SYS_REFCURSOR,
                           p_Files_Cur          OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.Writemsg ('DNET$APPEAL_EXT.' || $$PLSQL_UNIT);

        BEGIN
            SELECT a.Ap_Doc,
                   Dnet$appeal_Ext.Ap_Edit_Allowed (p_Ap_St   => a.Ap_St,
                                                    p_Ap_Tp   => a.Ap_Tp)
              INTO p_Ap_Doc, p_Doc_Edit_Allowed
              FROM Appeal a
             WHERE a.Ap_Id = p_Ap_Id
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Raise_Application_Error (
                    c_Err_Code_Not_Found,
                    'Звернення з ІД ' || p_Ap_Id || ' не знайдено');
        END;

        --Документи
        OPEN p_Docs_Cur FOR
            SELECT d.Apd_Id,
                   d.Apd_Ndt,
                   d.Apd_Doc,
                   d.Apd_Dh
              FROM Ap_Document d
             WHERE d.Apd_Ap = p_Ap_Id AND d.History_Status = 'A';

        --Вкладення документів
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT Apd_Dh
              FROM Ap_Document
             WHERE Apd_Ap = p_Ap_Id AND History_Status = 'A';

        Uss_Doc.Api$documents.Get_Signed_Attachments (p_Res => p_Files_Cur);
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

            Check_Ap_Integrity (p_Ap_Id         => p_Ap_Id,
                                p_Table         => 'Ap_Service',
                                p_Ap_Field      => 'Aps_Ap',
                                p_Id_Field      => 'Aps_Id',
                                p_Id_Val        => p_Ap_Services (i).Aps_Id,
                                p_Entity_Name   => 'Послугу');

            Api$appeal.Save_Service (
                p_Aps_Id    => p_Ap_Services (i).Aps_Id,
                p_Aps_Nst   => p_Ap_Services (i).Aps_Nst,
                p_Aps_Ap    => p_Ap_Id,
                p_Aps_St    => NVL (p_Ap_Services (i).Aps_St, 'R'),
                p_New_Id    => p_Ap_Services (i).New_Id);
        END LOOP;
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
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.App_Id
                  FROM Ap_Person  o
                       LEFT JOIN TABLE (p_Ap_Persons) n
                           ON o.App_Id = n.App_Id
                 WHERE o.App_Ap = p_Ap_Id AND n.App_Id IS NULL)
        LOOP
            Api$appeal.Delete_Person (Rec.App_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR i IN 1 .. p_Ap_Persons.COUNT
        LOOP
            SELECT MAX (c.Sc_Id)
              INTO l_Sc_Id
              FROM Uss_Person.v_Socialcard c
             WHERE c.Sc_Unique = p_Ap_Persons (i).App_Esr_Num;

            Check_Ap_Integrity (p_Ap_Id         => p_Ap_Id,
                                p_Table         => 'Ap_Person',
                                p_Ap_Field      => 'App_Ap',
                                p_Id_Field      => 'App_Id',
                                p_Id_Val        => p_Ap_Persons (i).App_Id,
                                p_Entity_Name   => 'Учасника');

            --Зберігаємо особу
            Api$appeal.Save_Person (
                p_App_Id        => p_Ap_Persons (i).App_Id,
                p_App_Ap        => p_Ap_Id,
                p_App_Tp        => p_Ap_Persons (i).App_Tp,
                p_App_Inn       => p_Ap_Persons (i).App_Inn,
                p_App_Ndt       => p_Ap_Persons (i).App_Ndt,
                p_App_Doc_Num   => p_Ap_Persons (i).App_Doc_Num,
                p_App_Fn        => p_Ap_Persons (i).App_Fn,
                p_App_Mn        => p_Ap_Persons (i).App_Mn,
                p_App_Ln        => p_Ap_Persons (i).App_Ln,
                p_App_Esr_Num   => p_Ap_Persons (i).App_Esr_Num,
                p_App_Gender    =>
                    SUBSTR (UPPER (p_Ap_Persons (i).App_Gender), 1, 1),
                p_App_Vf        => NULL,
                p_App_Sc        => l_Sc_Id,
                p_App_Num       => p_Ap_Persons (i).App_Num,
                p_New_Id        => p_Ap_Persons (i).New_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                 ЗБЕРЕЖЕННЯ СПОСОБІВ ВИПЛАТ
    ---------------------------------------------------------------------
    PROCEDURE Save_Payments (p_Ap_Id         IN     NUMBER,
                             p_Ap_Payments   IN OUT Api$appeal.t_Ap_Payments,
                             p_Ap_Services   IN     Api$appeal.t_Ap_Services,
                             p_Ap_Persons    IN     Api$appeal.t_Ap_Persons)
    IS
        l_New_Id     NUMBER;
        l_Apm_Nb     Ap_Payment.Apm_Nb%TYPE;
        l_Apm_Kaot   Ap_Payment.Apm_Kaot%TYPE;
        l_Cnt        NUMBER := 0;
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Apm_Id
                  FROM Ap_Payment  o
                       LEFT JOIN TABLE (p_Ap_Payments) n
                           ON o.Apm_Id = n.Apm_Id
                 WHERE o.Apm_Ap = p_Ap_Id AND n.Apm_Id IS NULL)
        LOOP
            Api$appeal.Delete_Payment (Rec.Apm_Id);
        END LOOP;

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
            l_Cnt := l_Cnt + 1;

            --20220406: убрал контроль по просьбе КЕВ
            /*IF l_Cnt > 1 THEN
              Raise_Application_Error(c_Err_Code_Bad_Req,
                                      'Збереженя декількох способів виплати не підтримується');
            END IF;*/
            --Визначаємо банк за МФО(від ДІЇ не приходить ІД банку)
            SELECT MAX (b.Nb_Id)
              INTO l_Apm_Nb
              FROM Uss_Ndi.v_Ndi_Bank b
             WHERE     b.Nb_Mfo = Rec.Apm_Mfo
                   --Визначаємо ІД головного відділення банку(що немає посилання на батьківський)
                   AND (b.Nb_Nb IS NULL --#92481: за виключенням Райфайзену
                                        OR b.Nb_Nb = 59)
                   AND b.History_Status = 'A';

            SELECT MAX (k.Kaot_Id)
              INTO l_Apm_Kaot
              FROM Uss_Ndi.v_Ndi_Katottg k
             WHERE k.Kaot_Code = Rec.Apm_Katottg_Code;

            Check_Ap_Integrity (p_Ap_Id         => p_Ap_Id,
                                p_Table         => 'Ap_Payment',
                                p_Ap_Field      => 'Apm_Ap',
                                p_Id_Field      => 'Apm_Id',
                                p_Id_Val        => Rec.Apm_Id,
                                p_Entity_Name   => 'Спосіб виплати');

            Api$appeal.Save_Payment (
                p_Apm_Id             => Rec.Apm_Id,
                p_Apm_Ap             => p_Ap_Id,
                p_Apm_Aps            => Rec.Aps_Id,
                p_Apm_App            => Rec.App_Id,
                p_Apm_Tp             => Rec.Apm_Tp,
                p_Apm_Index          => Rec.Apm_Index,
                p_Apm_Kaot           => l_Apm_Kaot,
                p_Apm_Nb             => l_Apm_Nb,
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

    PROCEDURE Decode_Attr_Val_In (p_Nda_Id       IN     NUMBER,
                                  p_Val_Id       IN OUT NUMBER,
                                  p_Val_String   IN OUT VARCHAR2)
    IS
    BEGIN
        IF p_Nda_Id IN (580, 604) AND p_Val_String IS NOT NULL
        THEN
            SELECT MAX (k.Kaot_Id), MAX (k.Kaot_Name)
              INTO p_Val_Id, p_Val_String
              FROM Uss_Ndi.v_Ndi_Katottg k
             WHERE k.Kaot_Code = p_Val_String;

            p_Val_String := NULL;
        END IF;
    END;

    PROCEDURE Decode_Attr_Val_Out (p_Nda_Id       IN     NUMBER,
                                   p_Val_Id       IN OUT NUMBER,
                                   p_Val_String   IN OUT VARCHAR2)
    IS
    BEGIN
        IF p_Nda_Id IN (580, 604) AND p_Val_Id IS NOT NULL
        THEN
            SELECT MAX (k.Kaot_Code)
              INTO p_Val_String
              FROM Uss_Ndi.v_Ndi_Katottg k
             WHERE k.Kaot_Id = p_Val_Id;

            p_Val_Id := NULL;
        END IF;
    END;

    ---------------------------------------------------------------------
    --             ЗБЕРЕЖЕННЯ АТРИБУТІВ ДОКУМЕНТА
    ---------------------------------------------------------------------
    PROCEDURE Save_Document_Attrs (p_Ap_Id       IN     NUMBER,
                                   p_Apd_Id      IN     NUMBER,
                                   p_Apd_Attrs   IN OUT t_Ap_Document_Attrs)
    IS
        l_New_Id   NUMBER;

        FUNCTION Try_Parse_Dt (p_Apda_Nda      IN NUMBER,
                               p_Apda_Val_Dt   IN VARCHAR2)
            RETURN DATE
        IS
            l_Nda_Name   VARCHAR2 (4000);
        BEGIN
            RETURN TO_DATE (p_Apda_Val_Dt, c_Xml_Dt_Fmt);
        EXCEPTION
            WHEN OTHERS
            THEN
                SELECT MAX (a.Nda_Name)
                  INTO l_Nda_Name
                  FROM Uss_Ndi.v_Ndi_Document_Attr a
                 WHERE a.Nda_Id = p_Apda_Nda;

                Raise_Application_Error (
                    c_Err_Code_Bad_Req,
                    'Некорекний формат дати в атрибуті ' || l_Nda_Name);
        END;
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Apda_Id
                  FROM Ap_Document_Attr  o
                       LEFT JOIN TABLE (p_Apd_Attrs) n
                           ON o.Apda_Nda = n.Apda_Nda
                 WHERE o.Apda_Apd = p_Apd_Id AND n.Apda_Id IS NULL)
        LOOP
            Api$appeal.Delete_Document_Attr (Rec.Apda_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR Rec IN (SELECT a.Apda_Id,
                           a.Apda_Nda,
                           a.Apda_Val_Int                AS Val_Int,
                           a.Apda_Val_Dt                 AS Val_Dt,
                           a.Apda_Val_String             AS Val_String,
                           a.Apda_Val_Id                 AS Val_Id,
                           To_Money (a.Apda_Val_Sum)     AS Val_Sum
                      FROM TABLE (p_Apd_Attrs) a)
        LOOP
            IF Rec.Apda_Id > 0
            THEN
                DECLARE
                    l_Apda_Apd   NUMBER;
                BEGIN
                    SELECT MAX (a.Apda_Apd)
                      INTO l_Apda_Apd
                      FROM Ap_Document_Attr a
                     WHERE a.Apda_Id = Rec.Apda_Id;

                    IF l_Apda_Apd IS NULL
                    THEN
                        Raise_Application_Error (
                            c_Err_Code_Bad_Req,
                               'Не знайдено атрибут документа ІД='
                            || Rec.Apda_Id);
                    END IF;

                    IF l_Apda_Apd <> p_Apd_Id
                    THEN
                        Raise_Application_Error (
                            c_Err_Code_Bad_Req,
                               'Атрибут документа з ІД='
                            || Rec.Apda_Id
                            || ' знайдено в іншому документі');
                    END IF;
                END;
            END IF;

            Decode_Attr_Val_In (Rec.Apda_Nda,
                                p_Val_Id       => Rec.Val_Id,
                                p_Val_String   => Rec.Val_String);
            Api$appeal.Save_Document_Attr (
                p_Apda_Id           => Rec.Apda_Id,
                p_Apda_Ap           => p_Ap_Id,
                p_Apda_Apd          => p_Apd_Id,
                p_Apda_Nda          => Rec.Apda_Nda,
                p_Apda_Val_Int      => Rec.Val_Int,
                p_Apda_Val_Dt       => Try_Parse_Dt (Rec.Apda_Nda, Rec.Val_Dt),
                p_Apda_Val_String   => Rec.Val_String,
                p_Apda_Val_Id       => Rec.Val_Id,
                p_Apda_Val_Sum      => Rec.Val_Sum,
                p_New_Id            => l_New_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                   ЗБЕРЕЖЕННЯ ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Save_Documents_10336 (
        p_Ap_Id         IN NUMBER,
        p_App_Id        IN NUMBER,
        p_App_Tp        IN VARCHAR2,
        p_Appeal_Data   IN r_Appeal_Data,
        p_Ap_Persons    IN Api$appeal.t_Ap_Persons,
        p_Src_Id        IN VARCHAR2)
    IS
        l_app_id                NUMBER;
        l_applicant             Dnet$appeal_Ext.r_applicant;
        l_income                Dnet$appeal_Ext.t_income;
        l_socialInsurance       Dnet$appeal_Ext.t_payment;
        l_realty                Dnet$appeal_Ext.t_realty;
        l_damagedRealty         Dnet$appeal_Ext.t_damaged_realty;
        l_vehicles              Dnet$appeal_Ext.t_vehicle;
        l_family                Dnet$appeal_Ext.t_family;
        l_documents             Dnet$appeal_Ext.t_document;
        -- Декларація про доходи (шапка apr_%)
        r_ap_declaration        ap_declaration%ROWTYPE;
        -- Члени сім`ї
        r_apr_person            apr_person%ROWTYPE;
        -- Доходи членів сім`ї
        r_apr_income            apr_income%ROWTYPE;
        -- Житлові приміщення
        r_apr_living_quarters   apr_living_quarters%ROWTYPE;
        -- Транспортні засоби
        r_apr_vehicle           apr_vehicle%ROWTYPE;

        l_apd_id                NUMBER;
        l_apda_id               NUMBER;
        l_ndt_id                NUMBER;
        l_nda_id                NUMBER;
        l_doc_id                NUMBER;
        l_dh_id                 NUMBER;
        l_gender                CHAR (1);

        FUNCTION getDateBeginQuarter (i_beginQuarter   IN NUMBER,
                                      i_beginYear      IN NUMBER)
            RETURN DATE
        IS
            p_ret   DATE;
        BEGIN
            p_ret :=
                TO_DATE (
                       CASE i_beginQuarter
                           WHEN 1 THEN '01'
                           WHEN 2 THEN '04'
                           WHEN 3 THEN '07'
                           WHEN 4 THEN '10'
                           ELSE NULL
                       END
                    || '.'
                    || i_beginYear,
                    'mm.yyyy');
            RETURN p_ret;
        EXCEPTION
            WHEN OTHERS
            THEN
                RETURN NULL;
        END;

        FUNCTION getDateEndQuarter (i_endQuarter   IN NUMBER,
                                    i_endYear      IN NUMBER)
            RETURN DATE
        IS
            p_ret   DATE;
        BEGIN
            p_ret :=
                LAST_DAY (
                    TO_DATE (
                           CASE i_endQuarter
                               WHEN 1 THEN '03'
                               WHEN 2 THEN '06'
                               WHEN 3 THEN '09'
                               WHEN 4 THEN '12'
                               ELSE NULL
                           END
                        || '.'
                        || i_endYear,
                        'mm.yyyy'));
            RETURN p_ret;
        EXCEPTION
            WHEN OTHERS
            THEN
                RETURN NULL;
        END;
    BEGIN
        l_applicant := p_Appeal_Data.Application.data_.applicant;
        l_income := l_applicant.incomeStatement.incomes;
        l_socialInsurance := l_applicant.socialInsurance.payments;
        l_realty := l_applicant.realty;
        l_damagedRealty := l_applicant.damagedRealty;
        l_vehicles := l_applicant.vehicles;
        l_family := p_Appeal_Data.Application.data_.family;

        BEGIN
              SELECT *
                INTO r_ap_declaration
                FROM Ap_Declaration d
               WHERE d.Apr_Ap = p_Ap_Id
            ORDER BY d.apr_id DESC
               FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        SELECT com_org
          INTO r_ap_declaration.com_org
          FROM Appeal a
         WHERE a.ap_id = p_Ap_Id;

        IF r_ap_declaration.Apr_Id IS NOT NULL
        THEN
            UPDATE apr_person p
               SET p.history_status = 'H'
             WHERE     p.aprp_apr = r_ap_declaration.Apr_Id
                   AND p.history_status = 'A';

            UPDATE apr_income p
               SET p.history_status = 'H'
             WHERE     p.apri_apr = r_ap_declaration.Apr_Id
                   AND p.history_status = 'A';

            UPDATE apr_living_quarters p
               SET p.history_status = 'H'
             WHERE     p.aprl_apr = r_ap_declaration.Apr_Id
                   AND p.history_status = 'A';

            UPDATE apr_vehicle p
               SET p.history_status = 'H'
             WHERE     p.aprv_apr = r_ap_declaration.Apr_Id
                   AND p.history_status = 'A';
        END IF;

        BEGIN
            SELECT NVL (App_Id, p_Ap_Id),
                   App_Ln,
                   App_Fn,
                   App_Mn
              INTO l_app_id,
                   r_ap_declaration.apr_ln,
                   r_ap_declaration.apr_fn,
                   r_ap_declaration.apr_mn
              FROM (  SELECT *
                        FROM TABLE (p_Ap_Persons)
                       WHERE App_Tp = 'Z' AND NVL (Deleted, 0) = 0
                    ORDER BY App_Id
                       FETCH FIRST ROW ONLY);
        EXCEPTION
            WHEN OTHERS
            THEN
                r_ap_declaration.apr_fn := l_applicant.firstName;
                r_ap_declaration.apr_mn := l_applicant.middleName;
                r_ap_declaration.apr_ln := l_applicant.lastName;
        END;

        r_ap_declaration.Apr_Start_Dt :=
            getDateBeginQuarter (
                l_applicant.incomeStatement.requestPeriod.beginQuarter,
                l_applicant.incomeStatement.requestPeriod.beginYear);
        r_ap_declaration.Apr_Stop_Dt :=
            getDateEndQuarter (
                l_applicant.incomeStatement.requestPeriod.endQuarter,
                l_applicant.incomeStatement.requestPeriod.endYear);

        -- Шапка
        Api$appeal.Save_Declaration (
            p_Apr_Id          => r_ap_declaration.Apr_Id,
            p_Apr_Ap          => p_Ap_Id,
            p_Apr_Fn          => r_ap_declaration.Apr_Fn,
            p_Apr_Mn          => r_ap_declaration.Apr_Mn,
            p_Apr_Ln          => r_ap_declaration.Apr_Ln,
            p_Apr_Residence   => r_ap_declaration.Apr_Residence,
            p_Com_Org         => r_ap_declaration.com_org,
            p_Apr_Vf          => r_ap_declaration.Apr_Vf,
            p_Apr_Start_Dt    => r_ap_declaration.Apr_Start_Dt,
            p_Apr_Stop_Dt     => r_ap_declaration.Apr_Stop_Dt,
            p_New_Id          => r_ap_declaration.Apr_Id);
        r_apr_person.aprp_apr := r_ap_declaration.Apr_Id;
        r_apr_person.aprp_fn := l_applicant.firstName;
        r_apr_person.aprp_mn := l_applicant.middleName;
        r_apr_person.aprp_ln := l_applicant.lastName;
        r_apr_person.aprp_tp := 'Z';
        r_apr_person.aprp_inn := l_applicant.rnokpp;
        l_gender :=
            CASE
                WHEN UPPER (l_applicant.gender) IN ('M', 'MALE') THEN 'M'
                ELSE 'W'
            END;

        --Зберігаємо члена родини
        Api$appeal.Save_Apr_Person (p_Aprp_Id      => r_apr_person.Aprp_Id,
                                    p_Aprp_Apr     => r_ap_declaration.Apr_Id,
                                    p_Aprp_Fn      => r_apr_person.Aprp_Fn,
                                    p_Aprp_Mn      => r_apr_person.Aprp_Mn,
                                    p_Aprp_Ln      => r_apr_person.Aprp_Ln,
                                    p_Aprp_Tp      => r_apr_person.Aprp_Tp,
                                    p_Aprp_Inn     => r_apr_person.Aprp_Inn,
                                    p_Aprp_Notes   => NULL,
                                    p_Aprp_App     => l_app_id,
                                    p_New_Id       => r_apr_person.Aprp_Id);

        IF l_income IS NOT NULL
        THEN
            FOR i IN 1 .. l_income.COUNT
            LOOP
                r_apr_income.apri_id := NULL;
                r_apr_income.apri_apr := r_ap_declaration.Apr_Id;

                SELECT MAX (dic_code)
                  INTO r_apr_income.apri_tp
                  FROM uss_ndi.v_ddn_apri_tp t
                 WHERE    UPPER (t.dic_name) =
                          UPPER (l_income (i).resultIncome)
                       OR dic_code = l_income (i).resultIncome;

                r_apr_income.apri_sum :=
                    Dnet$appeal_Ext.To_Money (
                        TO_CHAR (l_income (i).incomeTax.incomeAccrued));
                r_apr_income.apri_source :=
                    l_income (i).sourcesOfIncome.nameTaxAgent;
                r_apr_income.apri_aprp := r_apr_person.Aprp_Id;
                r_apr_income.Apri_Start_Dt :=
                    l_income (i).incomeTax.dateOfEmployment;
                r_apr_income.Apri_Stop_Dt :=
                    l_income (i).incomeTax.dateOfDismissal;

                --Зберігаємо запис Доходи членів сім`ї
                Api$appeal.Save_Apr_Income (
                    p_Apri_Id            => r_apr_income.apri_id,
                    p_Apri_Apr           => r_apr_income.apri_apr,
                    p_Apri_Ln_Initials   => NULL,
                    p_Apri_Tp            => r_apr_income.apri_tp,
                    p_Apri_Sum           => r_apr_income.apri_sum,
                    p_Apri_Source        => r_apr_income.apri_source,
                    p_Apri_Aprp          => r_apr_income.apri_aprp,
                    p_Apri_Start_Dt      => r_apr_income.Apri_Start_Dt,
                    p_Apri_Stop_Dt       => r_apr_income.Apri_Stop_Dt,
                    p_New_Id             => r_apr_income.apri_id);
            END LOOP;
        END IF;

        IF l_socialInsurance IS NOT NULL
        THEN
            FOR i IN 1 .. l_socialInsurance.COUNT
            LOOP
                r_apr_income.apri_id := NULL;
                r_apr_income.apri_apr := r_ap_declaration.Apr_Id;

                SELECT MAX (dic_code)
                  INTO r_apr_income.apri_tp
                  FROM uss_ndi.v_ddn_apri_tp t
                 WHERE     t.dic_st = 'A'
                       AND (   UPPER (t.dic_name) =
                               UPPER (l_socialInsurance (i).sympType)
                            OR dic_code = l_socialInsurance (i).sympType);

                r_apr_income.apri_sum :=
                    Dnet$appeal_Ext.To_Money (
                        TO_CHAR (l_socialInsurance (i).sumPayment));
                r_apr_income.apri_source :=
                       l_socialInsurance (i).socFKod
                    || ';'
                    || l_socialInsurance (i).codeInsurer;
                r_apr_income.apri_aprp := r_apr_person.Aprp_Id;
                r_apr_income.Apri_Start_Dt :=
                    l_applicant.socialInsurance.periodStart;
                r_apr_income.Apri_Stop_Dt :=
                    l_applicant.socialInsurance.periodStop;

                --Зберігаємо запис Доходи членів сім`ї (соцвиплати)
                Api$appeal.Save_Apr_Income (
                    p_Apri_Id            => r_apr_income.apri_id,
                    p_Apri_Apr           => r_apr_income.apri_apr,
                    p_Apri_Ln_Initials   => NULL,
                    p_Apri_Tp            => r_apr_income.apri_tp,
                    p_Apri_Sum           => r_apr_income.apri_sum,
                    p_Apri_Source        => r_apr_income.apri_source,
                    p_Apri_Aprp          => r_apr_income.apri_aprp,
                    p_Apri_Start_Dt      => r_apr_income.Apri_Start_Dt,
                    p_Apri_Stop_Dt       => r_apr_income.Apri_Stop_Dt,
                    p_New_Id             => r_apr_income.apri_id);
            END LOOP;
        END IF;

        IF l_realty IS NOT NULL
        THEN
            FOR i IN 1 .. l_realty.COUNT
            LOOP
                r_apr_living_quarters.aprl_id := NULL;
                r_apr_living_quarters.aprl_apr := r_ap_declaration.Apr_Id;
                r_apr_living_quarters.aprl_area := l_realty (i).area;
                r_apr_living_quarters.aprl_address :=
                       l_realty (i).address.katottg
                    || ';'
                    || l_realty (i).address.city
                    || ';'
                    || l_realty (i).address.streetType
                    || ' '
                    || l_realty (i).address.streetName
                    || ';'
                    || l_realty (i).address.building
                    || ';'
                    || l_realty (i).address.block_
                    || ';'
                    || l_realty (i).address.appartment;
                r_apr_living_quarters.aprl_aprp := r_apr_person.Aprp_Id;

                SELECT NVL (MAX (dic_code),
                            SUBSTR (l_realty (i).reType, 1, 10))
                  INTO r_apr_living_quarters.aprl_tp
                  FROM uss_ndi.v_ddn_aprl_tp
                 WHERE UPPER (dic_name) = UPPER (l_realty (i).reType);

                r_apr_living_quarters.aprl_ch :=
                    SUBSTR (l_realty (i).idEdra, 1, 10);

                --Зберігаємо запис Житлові приміщення
                Api$appeal.Save_Apr_Living_Quarters (
                    p_Aprl_Id            => r_apr_living_quarters.aprl_id,
                    p_Aprl_Apr           => r_apr_living_quarters.aprl_apr,
                    p_Aprl_Ln_Initials   => NULL,
                    p_Aprl_Area          => r_apr_living_quarters.aprl_area,
                    p_Aprl_Qnt           => NULL,
                    p_Aprl_Address       => r_apr_living_quarters.aprl_address,
                    p_Aprl_Aprp          => r_apr_living_quarters.aprl_aprp,
                    p_Aprl_Tp            => r_apr_living_quarters.aprl_tp,
                    p_Aprl_Ch            => r_apr_living_quarters.aprl_ch,
                    p_New_Id             => r_apr_living_quarters.aprl_id);
            END LOOP;
        END IF;

        IF l_damagedRealty IS NOT NULL
        THEN
            FOR i IN 1 .. l_damagedRealty.COUNT
            LOOP
                r_apr_living_quarters.aprl_id := NULL;
                r_apr_living_quarters.aprl_apr := r_ap_declaration.Apr_Id;
                r_apr_living_quarters.aprl_area := NULL;
                r_apr_living_quarters.aprl_address :=
                       l_damagedRealty (i).address.katottg
                    || ';'
                    || l_damagedRealty (i).address.city
                    || ';'
                    || l_damagedRealty (i).address.streetType
                    || ' '
                    || l_damagedRealty (i).address.streetName
                    || ';'
                    || l_damagedRealty (i).address.building
                    || ';'
                    || l_damagedRealty (i).address.block_
                    || ';'
                    || l_damagedRealty (i).address.appartment;
                r_apr_living_quarters.aprl_aprp := r_apr_person.Aprp_Id;

                SELECT NVL (MAX (dic_code),
                            SUBSTR (l_damagedRealty (i).objectName, 1, 10))
                  INTO r_apr_living_quarters.aprl_tp
                  FROM uss_ndi.v_ddn_aprl_tp
                 WHERE UPPER (dic_name) =
                       UPPER (l_damagedRealty (i).objectName);

                r_apr_living_quarters.aprl_ch := UPPER ('damaged');

                --Зберігаємо запис Пошкоджене/знищене майно
                Api$appeal.Save_Apr_Living_Quarters (
                    p_Aprl_Id            => r_apr_living_quarters.aprl_id,
                    p_Aprl_Apr           => r_apr_living_quarters.aprl_apr,
                    p_Aprl_Ln_Initials   => NULL,
                    p_Aprl_Area          => r_apr_living_quarters.aprl_area,
                    p_Aprl_Qnt           => NULL,
                    p_Aprl_Address       => r_apr_living_quarters.aprl_address,
                    p_Aprl_Aprp          => r_apr_living_quarters.aprl_aprp,
                    p_Aprl_Tp            => r_apr_living_quarters.aprl_tp,
                    p_Aprl_Ch            => r_apr_living_quarters.aprl_ch,
                    p_New_Id             => r_apr_living_quarters.aprl_id);
            END LOOP;
        END IF;

        IF l_vehicles IS NOT NULL
        THEN
            FOR i IN 1 .. l_vehicles.COUNT
            LOOP
                r_apr_vehicle.aprv_id := NULL;
                r_apr_vehicle.aprv_apr := r_ap_declaration.Apr_Id;
                r_apr_vehicle.aprv_car_brand := l_vehicles (i).vehicleType;
                r_apr_vehicle.aprv_license_plate := NULL;
                r_apr_vehicle.aprv_production_year := l_vehicles (i).prodYear;
                r_apr_vehicle.aprv_is_social_car := NULL;
                r_apr_vehicle.aprv_aprp := r_apr_person.Aprp_Id;

                --Зберігаємо запис Транспортні засоби
                Api$appeal.Save_Apr_Vehicle (
                    p_Aprv_Id              => r_apr_vehicle.aprv_id,
                    p_Aprv_Apr             => r_apr_vehicle.aprv_apr,
                    p_Aprv_Ln_Initials     => NULL,
                    p_Aprv_Car_Brand       => r_apr_vehicle.aprv_car_brand,
                    p_Aprv_License_Plate   => r_apr_vehicle.aprv_license_plate,
                    p_Aprv_Production_Year   =>
                        r_apr_vehicle.aprv_production_year,
                    p_Aprv_Is_Social_Car   => r_apr_vehicle.aprv_is_social_car,
                    p_Aprv_Aprp            => r_apr_vehicle.aprv_aprp,
                    p_New_Id               => r_apr_vehicle.aprv_id);
            END LOOP;
        END IF;

        l_ndt_id := 605;                                    -- Анкета учасника
        dnet$appeal_ext.GET_DOC_ID (p_ap_id    => p_Ap_Id,
                                    p_ndt_id   => l_ndt_id,
                                    p_app_id   => l_app_id,
                                    o_apd_id   => l_apd_id);

        IF l_apd_id IS NULL
        THEN
            Uss_Doc.Api$documents.Save_Document (
                p_Doc_Id          => NULL,
                p_Doc_Ndt         => l_ndt_id,
                p_Doc_Actuality   => 'U',
                p_New_Id          => l_doc_id);
            Uss_Doc.Api$documents.Save_Doc_Hist (p_Dh_Id          => NULL,
                                                 p_Dh_Doc         => l_doc_id,
                                                 p_Dh_Sign_Alg    => NULL,
                                                 p_Dh_Ndt         => l_ndt_id,
                                                 p_Dh_Sign_File   => NULL,
                                                 p_Dh_Actuality   => 'U',
                                                 p_Dh_Dt          => SYSDATE,
                                                 p_Dh_Wu          => NULL,
                                                 p_Dh_Src         => p_Src_Id,
                                                 p_New_Id         => l_dh_id);
            Api$appeal.Save_Document (p_Apd_Id    => NULL,
                                      p_Apd_Ap    => p_ap_id,
                                      p_Apd_Ndt   => l_ndt_id,
                                      p_Apd_Doc   => l_doc_id,
                                      p_Apd_Vf    => NULL,
                                      p_Apd_App   => l_app_id,
                                      p_New_Id    => l_apd_id,
                                      p_Com_Wu    => NULL,
                                      p_Apd_Dh    => l_dh_id,
                                      p_Apd_Aps   => NULL,
                                      p_Apd_Src   => p_Src_Id);
        END IF;

        l_ndt_id :=
            CASE UPPER (l_applicant.maritalStatus.certificate.type_)
                WHEN UPPER ('marriage') THEN 100         -- Свідоцтво про шлюб
                WHEN UPPER ('divorce') THEN 284 -- Свідоцтво про розірвання шлюбу
                ELSE NULL
            END;

        IF l_ndt_id IS NOT NULL
        THEN
            dnet$appeal_ext.GET_DOC_ID (p_ap_id    => p_Ap_Id,
                                        p_ndt_id   => l_ndt_id,
                                        p_app_id   => l_app_id,
                                        o_apd_id   => l_apd_id);
            Api$appeal.Delete_Document (l_apd_id);
            Api$appeal.Save_Document (p_Apd_Id    => NULL,
                                      p_Apd_Ap    => p_ap_id,
                                      p_Apd_Ndt   => l_ndt_id,
                                      p_Apd_Doc   => NULL,
                                      p_Apd_Vf    => NULL,
                                      p_Apd_App   => l_app_id,
                                      p_New_Id    => l_apd_id,
                                      p_Com_Wu    => NULL,
                                      p_Apd_Dh    => NULL,
                                      p_Apd_Aps   => NULL,
                                      p_Apd_Src   => p_Src_Id);

            FOR Rec
                IN (-- Свідоцтво про шлюб
                    -- серія та номер документа
                    SELECT 253
                               nda_id,
                           NULL
                               Val_Int,
                           NULL
                               Val_Dt,
                              l_applicant.maritalStatus.certificate.series
                           || l_applicant.maritalStatus.certificate.number_
                               Val_String,
                           NULL
                               Val_Id,
                           NULL
                               Val_Sum
                      FROM DUAL
                     WHERE l_ndt_id = 100
                    UNION ALL
                    -- дата видачі
                    SELECT 255
                               nda_id,
                           NULL
                               Val_Int,
                           l_applicant.maritalStatus.certificate.issueDate
                               Val_Dt,
                           NULL
                               Val_String,
                           NULL
                               Val_Id,
                           NULL
                               Val_Sum
                      FROM DUAL
                     WHERE l_ndt_id = 100
                    UNION ALL
                    -- ким видано
                    SELECT 254
                               nda_id,
                           NULL
                               Val_Int,
                           NULL
                               Val_Dt,
                           l_applicant.maritalStatus.certificate.issuer
                               Val_String,
                           NULL
                               Val_Id,
                           NULL
                               Val_Sum
                      FROM DUAL
                     WHERE l_ndt_id = 100
                    UNION ALL
                    -- РНОКПП нареченого/РНОКПП нареченої
                    SELECT CASE WHEN l_gender = 'M' THEN 8532 ELSE 8526 END
                               nda_id,
                           NULL
                               Val_Int,
                           NULL
                               Val_Dt,
                           l_applicant.maritalStatus.certificate.partner.rnokpp
                               Val_String,
                           NULL
                               Val_Id,
                           NULL
                               Val_Sum
                      FROM DUAL
                     WHERE l_ndt_id = 100
                    UNION ALL
                    -- ПІБ нареченого/ПІБ нареченої
                    SELECT CASE WHEN l_gender = 'M' THEN 2434 ELSE 2433 END
                               nda_id,
                           NULL
                               Val_Int,
                           NULL
                               Val_Dt,
                              l_applicant.maritalStatus.certificate.partner.lastName
                           || ' '
                           || l_applicant.maritalStatus.certificate.partner.firstName
                           || ' '
                           || l_applicant.maritalStatus.certificate.partner.middleName
                               Val_String,
                           NULL
                               Val_Id,
                           NULL
                               Val_Sum
                      FROM DUAL
                     WHERE l_ndt_id = 100
                    -- Свідоцтво про розірвання шлюбу
                    -- серія та номер документа
                    UNION ALL
                    SELECT 2435
                               nda_id,
                           NULL
                               Val_Int,
                           NULL
                               Val_Dt,
                              l_applicant.maritalStatus.certificate.series
                           || l_applicant.maritalStatus.certificate.number_
                               Val_String,
                           NULL
                               Val_Id,
                           NULL
                               Val_Sum
                      FROM DUAL
                     WHERE l_ndt_id = 284
                    UNION ALL
                    -- дата видачі
                    SELECT 2436
                               nda_id,
                           NULL
                               Val_Int,
                           l_applicant.maritalStatus.certificate.issueDate
                               Val_Dt,
                           NULL
                               Val_String,
                           NULL
                               Val_Id,
                           NULL
                               Val_Sum
                      FROM DUAL
                     WHERE l_ndt_id = 284
                    UNION ALL
                    -- ким видано
                    SELECT 2437
                               nda_id,
                           NULL
                               Val_Int,
                           NULL
                               Val_Dt,
                           l_applicant.maritalStatus.certificate.issuer
                               Val_String,
                           NULL
                               Val_Id,
                           NULL
                               Val_Sum
                      FROM DUAL
                     WHERE l_ndt_id = 284
                    UNION ALL
                    -- ПІБ нареченого/ПІБ нареченої
                    SELECT CASE WHEN l_gender = 'M' THEN 2439 ELSE 2438 END
                               nda_id,
                           NULL
                               Val_Int,
                           NULL
                               Val_Dt,
                              l_applicant.maritalStatus.certificate.partner.lastName
                           || ' '
                           || l_applicant.maritalStatus.certificate.partner.firstName
                           || ' '
                           || l_applicant.maritalStatus.certificate.partner.middleName
                               Val_String,
                           NULL
                               Val_Id,
                           NULL
                               Val_Sum
                      FROM DUAL
                     WHERE l_ndt_id = 284)
            LOOP
                Api$appeal.Save_Document_Attr (
                    p_Apda_Id           => NULL,
                    p_Apda_Ap           => p_ap_id,
                    p_Apda_Apd          => l_apd_id,
                    p_Apda_Nda          => Rec.nda_id,
                    p_Apda_Val_Int      => Rec.Val_Int,
                    p_Apda_Val_Dt       => Rec.Val_Dt,
                    p_Apda_Val_String   => Rec.Val_String,
                    p_Apda_Val_Id       => Rec.Val_Id,
                    p_Apda_Val_Sum      => Rec.Val_Sum,
                    p_New_Id            => l_apda_id);
            END LOOP;
        END IF;

        ----------------------------------------------------------------------------
        -- Контейнет "family" ------------------------------------------------------
        ----------------------------------------------------------------------------
        IF l_family IS NOT NULL
        THEN
            FOR i IN 1 .. l_family.COUNT
            LOOP
                l_app_id := NULL;

                BEGIN
                      -- пошук особи по ІПН
                      SELECT GREATEST (App_Id, NVL (New_Id, -1))
                        INTO l_app_id
                        FROM TABLE (p_Ap_Persons) t
                       WHERE     t.App_Inn = l_family (i).data_.rnokpp
                             AND NVL (Deleted, 0) = 0
                    ORDER BY App_Id
                       FETCH FIRST ROW ONLY;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

                IF     l_app_id IS NULL
                   AND l_family (i).data_.documents IS NOT NULL
                THEN
                    FOR ii IN 1 .. l_family (i).data_.documents.COUNT
                    LOOP
                        BEGIN
                              -- пошук по документу
                              SELECT GREATEST (App_Id, NVL (New_Id, -1))
                                INTO l_app_id
                                FROM TABLE (p_Ap_Persons) t
                               WHERE     t.App_Doc_Num =
                                            l_family (i).data_.documents (ii).serie
                                         || l_family (i).data_.documents (ii).number_
                                     AND NVL (Deleted, 0) = 0
                            ORDER BY App_Id
                               FETCH FIRST ROW ONLY;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                NULL;
                        END;

                        EXIT WHEN NVL (l_app_id, 0) > 0;
                    END LOOP;                                            -- ii
                END IF;

                IF l_app_id IS NULL
                THEN
                    Raise_Application_Error (
                        c_Err_Code_Not_Found,
                           'Не знайдено особу '
                        || l_family (i).data_.lastName
                        || ' '
                        || l_family (i).data_.firstName
                        || ' '
                        || l_family (i).data_.middleName
                        || ' у зверненні: '
                        || p_ap_id);
                END IF;

                r_apr_person.Aprp_Id := NULL;
                r_apr_person.aprp_apr := r_ap_declaration.Apr_Id;
                r_apr_person.aprp_fn := l_family (i).data_.firstName;
                r_apr_person.aprp_mn := l_family (i).data_.middleName;
                r_apr_person.aprp_ln := l_family (i).data_.lastName;
                r_apr_person.aprp_tp := l_family (i).familyMemberType;
                r_apr_person.aprp_inn := l_family (i).data_.rnokpp;

                l_gender :=
                    CASE
                        WHEN UPPER (l_family (i).data_.gender) IN
                                 ('M', 'MALE')
                        THEN
                            'M'
                        ELSE
                            'W'
                    END;

                --Зберігаємо члена родини
                Api$appeal.Save_Apr_Person (
                    p_Aprp_Id      => r_apr_person.Aprp_Id,
                    p_Aprp_Apr     => r_ap_declaration.Apr_Id,
                    p_Aprp_Fn      => r_apr_person.Aprp_Fn,
                    p_Aprp_Mn      => r_apr_person.Aprp_Mn,
                    p_Aprp_Ln      => r_apr_person.Aprp_Ln,
                    p_Aprp_Tp      => r_apr_person.Aprp_Tp,
                    p_Aprp_Inn     => r_apr_person.Aprp_Inn,
                    p_Aprp_Notes   => NULL,
                    p_Aprp_App     => l_app_id,
                    p_New_Id       => r_apr_person.Aprp_Id);

                l_income := l_family (i).data_.incomeStatement.incomes;

                IF l_income IS NOT NULL
                THEN
                    FOR i IN 1 .. l_income.COUNT
                    LOOP
                        r_apr_income.apri_id := NULL;
                        r_apr_income.apri_apr := r_ap_declaration.Apr_Id;

                        SELECT MAX (dic_code)
                          INTO r_apr_income.apri_tp
                          FROM uss_ndi.v_ddn_apri_tp t
                         WHERE    UPPER (t.dic_name) =
                                  UPPER (l_income (i).resultIncome)
                               OR dic_code = l_income (i).resultIncome;

                        r_apr_income.apri_sum :=
                            Dnet$appeal_Ext.To_Money (
                                TO_CHAR (
                                    l_income (i).incomeTax.incomeAccrued));
                        r_apr_income.apri_source :=
                            l_income (i).sourcesOfIncome.nameTaxAgent;
                        r_apr_income.apri_aprp := r_apr_person.Aprp_Id;
                        r_apr_income.Apri_Start_Dt :=
                            l_income (i).incomeTax.dateOfEmployment;
                        r_apr_income.Apri_Stop_Dt :=
                            l_income (i).incomeTax.dateOfDismissal;

                        --Зберігаємо запис Доходи членів сім`ї
                        Api$appeal.Save_Apr_Income (
                            p_Apri_Id            => r_apr_income.apri_id,
                            p_Apri_Apr           => r_apr_income.apri_apr,
                            p_Apri_Ln_Initials   => NULL,
                            p_Apri_Tp            => r_apr_income.apri_tp,
                            p_Apri_Sum           => r_apr_income.apri_sum,
                            p_Apri_Source        => r_apr_income.apri_source,
                            p_Apri_Aprp          => r_apr_income.apri_aprp,
                            p_Apri_Start_Dt      => r_apr_income.Apri_Start_Dt,
                            p_Apri_Stop_Dt       => r_apr_income.Apri_Stop_Dt,
                            p_New_Id             => r_apr_income.apri_id);
                    END LOOP;
                END IF;
            END LOOP;                                                     -- i
        END IF;
    END Save_Documents_10336;

    PROCEDURE Save_Documents (
        p_Ap_Id          IN     NUMBER,
        p_Ap_Documents   IN OUT Api$appeal.t_Ap_Documents,
        p_Ap_Persons     IN     Api$appeal.t_Ap_Persons,
        p_Src_Id         IN     VARCHAR2)
    IS
        l_Ap_Document_Attrs   t_Ap_Document_Attrs;
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Apd_Id
                  FROM Ap_Document  o
                       LEFT JOIN TABLE (p_Ap_Documents) n
                           ON o.Apd_Id = n.Apd_Id
                 WHERE o.Apd_Ap = p_Ap_Id AND n.Apd_Id IS NULL)
        LOOP
            Api$appeal.Delete_Document (Rec.Apd_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR Rec
            IN (SELECT d.*,
                       GREATEST (p.App_Id, NVL (p.New_Id, -1))     AS App_Id,
                       p.App_Tp
                  FROM TABLE (p_Ap_Documents)  d
                       LEFT JOIN TABLE (p_Ap_Persons) p
                           ON d.Apd_App = p.App_Id)
        LOOP
            Check_Ap_Integrity (p_Ap_Id         => p_Ap_Id,
                                p_Table         => 'Ap_Document',
                                p_Ap_Field      => 'Apd_Ap',
                                p_Id_Field      => 'Apd_Id',
                                p_Id_Val        => Rec.Apd_Id,
                                p_Entity_Name   => 'Документ');

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
                                      p_Apd_Src   => p_Src_Id,
                                      p_Apd_Aps   => NULL);

            IF Rec.Attributes IS NOT NULL
            THEN
                BEGIN
                    --Парсимо атрибути документа
                    EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                                     't_Ap_Document_Attrs',
                                                     TRUE,
                                                     FALSE)
                        BULK COLLECT INTO l_Ap_Document_Attrs
                        USING Rec.Attributes;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        Raise_Application_Error (
                            c_Err_Code_Bad_Req,
                               'Помилка парсингу: '
                            || CHR (13)
                            || SQLERRM
                            || CHR (13)
                            || DBMS_UTILITY.Format_Error_Backtrace);
                END;

                --Зберігаємо атрибути документа
                Save_Document_Attrs (p_Ap_Id       => p_Ap_Id,
                                     p_Apd_Id      => Rec.Apd_Id,
                                     p_Apd_Attrs   => l_Ap_Document_Attrs);
            END IF;

            IF Rec.Apd_Ndt = 10336
            THEN                                  -- IC #113826 Окрема обробка
                DECLARE
                    l_File_Data     CLOB;
                    l_Appeal_Data   r_Appeal_Data;
                BEGIN
                    IF Rec.Apd_Attachments IS NOT NULL
                    THEN
                        SELECT EXTRACT (Rec.Apd_Attachments, '/*/File_Data').Getclobval ()
                          INTO l_File_Data
                          FROM DUAL;

                        IF     l_File_Data IS NOT NULL
                           AND DBMS_LOB.Getlength (l_File_Data) > 0
                        THEN                                    -- Зайшов JSON
                            l_File_Data := tools.b64_decode (l_File_Data);

                            EXECUTE IMMEDIATE Type2jsontable (
                                                 p_Pkg_Name   =>
                                                     'DNET$APPEAL_EXT',
                                                 p_Type_Name   =>
                                                     'R_APPEAL_DATA',
                                                 p_Date_Fmt   => 'yyyy-mm-dd')
                                USING IN l_File_Data, OUT l_Appeal_Data;

                            Save_Documents_10336 (
                                p_Ap_Id         => p_Ap_Id,
                                p_App_Id        => Rec.App_Id,
                                p_App_Tp        => Rec.App_Tp,
                                p_Appeal_Data   => l_Appeal_Data,
                                p_Ap_Persons    => p_Ap_Persons,
                                p_Src_Id        => p_Src_Id);
                        END IF;
                    END IF;
                END;
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --              ЗБЕРЕЖЕННЯ ШАПКИ ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Ap_Declaration (
        p_Ap_Id            IN     Appeal.Ap_Id%TYPE,
        p_Com_Org          IN     NUMBER,
        p_Ap_Persons       IN     Api$appeal.t_Ap_Persons,
        p_Ap_Declaration   IN OUT Api$appeal.r_Ap_Declaration)
    IS
    BEGIN
        IF p_Ap_Declaration.Apr_Id < 0
        THEN
            SELECT NVL (MAX (d.Apr_Id), p_Ap_Declaration.Apr_Id)
              INTO p_Ap_Declaration.Apr_Id
              FROM Ap_Declaration d
             WHERE d.Apr_Ap = p_Ap_Id;
        ELSE
            Check_Ap_Integrity (p_Ap_Id         => p_Ap_Id,
                                p_Table         => 'Ap_Declaration',
                                p_Ap_Field      => 'Apr_Ap',
                                p_Id_Field      => 'Apr_Id',
                                p_Id_Val        => p_Ap_Declaration.Apr_Id,
                                p_Entity_Name   => 'Декларацію');
        END IF;

        --#70674
        SELECT MAX (App_Ln), MAX (App_Fn), MAX (App_Mn)
          INTO p_Ap_Declaration.Apr_Ln,
               p_Ap_Declaration.Apr_Fn,
               p_Ap_Declaration.Apr_Mn
          FROM (  SELECT *
                    FROM TABLE (p_Ap_Persons)
                   WHERE App_Tp = 'Z' AND NVL (Deleted, 0) = 0
                ORDER BY App_Id
                   FETCH FIRST ROW ONLY);

        Api$appeal.Save_Declaration (
            p_Apr_Id          => p_Ap_Declaration.Apr_Id,
            p_Apr_Ap          => p_Ap_Id,
            p_Apr_Fn          => p_Ap_Declaration.Apr_Fn,
            p_Apr_Mn          => p_Ap_Declaration.Apr_Mn,
            p_Apr_Ln          => p_Ap_Declaration.Apr_Ln,
            p_Apr_Residence   => p_Ap_Declaration.Apr_Residence,
            p_Com_Org         => p_Com_Org,
            p_Apr_Vf          => p_Ap_Declaration.Apr_Vf,
            p_Apr_Start_Dt    =>
                TO_DATE (p_Ap_Declaration.Apr_Start_Dt, c_Xml_Dt_Fmt),
            p_Apr_Stop_Dt     =>
                TO_DATE (p_Ap_Declaration.Apr_Stop_Dt, c_Xml_Dt_Fmt),
            p_New_Id          => p_Ap_Declaration.Apr_Id);
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ АНКЕТИ УЧАСНИКА #79305
    ---------------------------------------------------------------------
    PROCEDURE Save_Ankt (p_Ap_Id    IN NUMBER,
                         p_Ap_Src   IN VARCHAR2,
                         p_App_Id      NUMBER,
                         p_Flags    IN VARCHAR2)
    IS
        c_Ndt_Ankt   CONSTANT NUMBER := 605;

        l_Doc_Id              NUMBER;
        l_Dh_Id               NUMBER;
        l_Apd_Id              NUMBER;
    BEGIN
        SELECT MAX (d.Apd_Id)
          INTO l_Apd_Id
          FROM Ap_Document d
         WHERE     d.Apd_App = p_App_Id
               AND d.History_Status = 'A'
               AND d.Apd_Ndt = 605;

        IF l_Apd_Id IS NULL
        THEN
            Uss_Doc.Api$documents.Save_Document (
                p_Doc_Id          => NULL,
                p_Doc_Ndt         => c_Ndt_Ankt,
                p_Doc_Actuality   => 'U',
                p_New_Id          => l_Doc_Id);
            Uss_Doc.Api$documents.Save_Doc_Hist (
                p_Dh_Id          => NULL,
                p_Dh_Doc         => l_Doc_Id,
                p_Dh_Sign_Alg    => NULL,
                p_Dh_Ndt         => c_Ndt_Ankt,
                p_Dh_Sign_File   => NULL,
                p_Dh_Actuality   => 'U',
                p_Dh_Dt          => SYSDATE,
                p_Dh_Wu          => NULL,
                p_Dh_Src         => p_Ap_Src,
                p_New_Id         => l_Dh_Id);
            Api$appeal.Save_Document (p_Apd_Id    => NULL,
                                      p_Apd_Ap    => p_Ap_Id,
                                      p_Apd_Ndt   => c_Ndt_Ankt,
                                      p_Apd_Doc   => l_Doc_Id,
                                      p_Apd_Vf    => NULL,
                                      p_Apd_App   => p_App_Id,
                                      p_New_Id    => l_Apd_Id,
                                      p_Com_Wu    => NULL,
                                      p_Apd_Dh    => l_Dh_Id,
                                      p_Apd_Aps   => NULL,
                                      p_Apd_Src   => p_Ap_Src);
        END IF;

        FOR Rec
            IN (SELECT TO_NUMBER (COLUMN_VALUE)     AS Flag_Id
                  FROM XMLTABLE (p_Flags))
        LOOP
            DECLARE
                l_Apda_Id   NUMBER;
                l_Nda_Id    NUMBER;
            BEGIN
                l_Nda_Id :=
                    TO_NUMBER (Uss_Ndi.Tools.Decode_Dict (
                                   p_Nddc_Tp         => 'NDA_ID',
                                   p_Nddc_Src        => 'DIIA',
                                   p_Nddc_Dest       => 'VST',
                                   p_Nddc_Code_Src   => Rec.Flag_Id));

                IF l_Nda_Id IS NULL
                THEN
                    CONTINUE;
                END IF;

                Api$appeal.Save_Document_Attr (
                    p_Apda_Id           => NULL,
                    p_Apda_Ap           => p_Ap_Id,
                    p_Apda_Apd          => l_Apd_Id,
                    p_Apda_Nda          => l_Nda_Id,
                    p_Apda_Val_Int      => NULL,
                    p_Apda_Val_Dt       => NULL,
                    p_Apda_Val_String   => 'T',
                    p_Apda_Val_Id       => NULL,
                    p_Apda_Val_Sum      => NULL,
                    p_New_Id            => l_Apda_Id);
            END;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ЧЛЕНІВ РОДИНИ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Persons (
        p_Ap_Id         IN     NUMBER,
        p_Ap_Src        IN     VARCHAR2,
        p_Apr_Id        IN     Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Persons   IN OUT Api$appeal.t_Apr_Persons,
        p_Ap_Persons    IN     Api$appeal.t_Ap_Persons)
    IS
        l_Apr_App   NUMBER;
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Aprp_Id
                  FROM Apr_Person  o
                       LEFT JOIN TABLE (p_Apr_Persons) n
                           ON o.Aprp_Id = n.Aprp_Id
                 WHERE o.Aprp_Apr = p_Apr_Id AND n.Aprp_Id IS NULL)
        LOOP
            Api$appeal.Delete_Apr_Person (Rec.Aprp_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR i IN 1 .. p_Apr_Persons.COUNT
        LOOP
            Check_Apr_Integrity (p_Apr_Id        => p_Apr_Id,
                                 p_Table         => 'Apr_Person',
                                 p_Apr_Field     => 'Aprp_Apr',
                                 p_Id_Field      => 'Aprp_Id',
                                 p_Id_Val        => p_Apr_Persons (i).Aprp_Id,
                                 p_Entity_Name   => 'Учасника');

            SELECT MAX (GREATEST (p.App_Id, NVL (p.New_Id, -1)))
              INTO l_Apr_App
              FROM TABLE (p_Ap_Persons) p
             WHERE App_Id = p_Apr_Persons (i).Aprp_App;

            --Зберігаємо члена родини
            Api$appeal.Save_Apr_Person (
                p_Aprp_Id      => p_Apr_Persons (i).Aprp_Id,
                p_Aprp_Apr     => p_Apr_Id,
                p_Aprp_Fn      => p_Apr_Persons (i).Aprp_Fn,
                p_Aprp_Mn      => p_Apr_Persons (i).Aprp_Mn,
                p_Aprp_Ln      => p_Apr_Persons (i).Aprp_Ln,
                p_Aprp_Tp      => p_Apr_Persons (i).Aprp_Tp,
                p_Aprp_Inn     => p_Apr_Persons (i).Aprp_Inn,
                p_Aprp_Notes   => NULL,
                p_Aprp_App     => l_Apr_App,
                p_New_Id       => p_Apr_Persons (i).New_Id);

            IF p_Apr_Persons (i).Aprp_Notes IS NOT NULL
            THEN
                --#79305
                Save_Ankt (p_Ap_Id    => p_Ap_Id,
                           p_Ap_Src   => p_Ap_Src,
                           p_App_Id   => l_Apr_App,
                           p_Flags    => p_Apr_Persons (i).Aprp_Notes);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ДОХОДІВ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Incomes (p_Apr_Id        IN Ap_Declaration.Apr_Id%TYPE,
                                p_Apr_Persons   IN Api$appeal.t_Apr_Persons,
                                p_Apr_Incomes   IN Api$appeal.t_Apr_Incomes)
    IS
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Apri_Id
                  FROM Apr_Income  o
                       LEFT JOIN TABLE (p_Apr_Incomes) n
                           ON o.Apri_Id = n.Apri_Id
                 WHERE o.Apri_Apr = p_Apr_Id AND n.Apri_Id IS NULL)
        LOOP
            Api$appeal.Delete_Apr_Income (Rec.Apri_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR Rec
            IN (SELECT i.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Incomes)  i
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON i.Apri_Aprp = p.Aprp_Id)
        LOOP
            Check_Apr_Integrity (p_Apr_Id        => p_Apr_Id,
                                 p_Table         => 'Apr_Income',
                                 p_Apr_Field     => 'APRI_APR',
                                 p_Id_Field      => 'APRI_ID',
                                 p_Id_Val        => Rec.Apri_Id,
                                 p_Entity_Name   => 'Запис про доходи');

            --Зберігаємо запис
            Api$appeal.Save_Apr_Income (
                p_Apri_Id            => Rec.Apri_Id,
                p_Apri_Apr           => p_Apr_Id,
                p_Apri_Ln_Initials   => NULL,
                p_Apri_Tp            => Rec.Apri_Tp,
                p_Apri_Sum           => To_Money (Rec.Apri_Sum),
                p_Apri_Source        => Rec.Apri_Source,
                p_Apri_Aprp          => Rec.Aprp_Id,
                p_Apri_Start_Dt      => NULL,                      --todo: ???
                p_Apri_Stop_Dt       => NULL,
                p_New_Id             => Rec.Apri_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ЗЕМЕЛЬНИХ ДІЛЯНОК З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Land_Plots (
        p_Apr_Id           IN Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Persons      IN Api$appeal.t_Apr_Persons,
        p_Apr_Land_Plots   IN Api$appeal.t_Apr_Land_Plots)
    IS
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Aprt_Id
                  FROM Apr_Land_Plot  o
                       LEFT JOIN TABLE (p_Apr_Land_Plots) n
                           ON o.Aprt_Id = n.Aprt_Id
                 WHERE o.Aprt_Apr = p_Apr_Id AND n.Aprt_Id IS NULL)
        LOOP
            Api$appeal.Delete_Apr_Land_Plot (Rec.Aprt_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR Rec
            IN (SELECT l.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Land_Plots)  l
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON l.Aprt_Aprp = p.Aprp_Id)
        LOOP
            Check_Apr_Integrity (p_Apr_Id        => p_Apr_Id,
                                 p_Table         => 'Apr_Land_Plot',
                                 p_Apr_Field     => 'APRT_APR',
                                 p_Id_Field      => 'APRT_ID',
                                 p_Id_Val        => Rec.Aprt_Id,
                                 p_Entity_Name   => 'Земельну ділянку');
            --Зберігаємо запис
            Api$appeal.Save_Apr_Land_Plot (
                p_Aprt_Id            => Rec.Aprt_Id,
                p_Aprt_Apr           => p_Apr_Id,
                p_Aprt_Ln_Initials   => NULL,
                p_Aprt_Area          => Rec.Aprt_Area,
                p_Aprt_Ownership     => Rec.Aprt_Ownership,
                p_Aprt_Purpose       => Rec.Aprt_Purpose,
                p_Aprt_Aprp          => Rec.Aprp_Id,
                p_New_Id             => Rec.Aprt_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ЖИТЛОВИХ ПРИМІЩЕНЬ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Living_Quarters (
        p_Apr_Id                IN Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Persons           IN Api$appeal.t_Apr_Persons,
        p_Apr_Living_Quarters   IN Api$appeal.t_Apr_Living_Quarters)
    IS
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Aprl_Id
                  FROM Apr_Living_Quarters  o
                       LEFT JOIN TABLE (p_Apr_Living_Quarters) n
                           ON o.Aprl_Id = n.Aprl_Id
                 WHERE o.Aprl_Apr = p_Apr_Id AND n.Aprl_Id IS NULL)
        LOOP
            Api$appeal.Delete_Apr_Living_Quarters (Rec.Aprl_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR Rec
            IN (SELECT q.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Living_Quarters)  q
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON q.Aprl_Aprp = p.Aprp_Id)
        LOOP
            Check_Apr_Integrity (p_Apr_Id        => p_Apr_Id,
                                 p_Table         => 'Apr_Living_Quarters',
                                 p_Apr_Field     => 'Aprl_Apr',
                                 p_Id_Field      => 'Aprl_Id',
                                 p_Id_Val        => Rec.Aprl_Id,
                                 p_Entity_Name   => 'Житлове приміщення');
            --Зберігаємо запис
            Api$appeal.Save_Apr_Living_Quarters (
                p_Aprl_Id            => Rec.Aprl_Id,
                p_Aprl_Apr           => p_Apr_Id,
                p_Aprl_Ln_Initials   => NULL,
                p_Aprl_Area          => Rec.Aprl_Area,
                p_Aprl_Qnt           => Rec.Aprl_Qnt,
                p_Aprl_Address       => Rec.Aprl_Address,
                p_Aprl_Aprp          => Rec.Aprp_Id,
                p_Aprl_Tp            => Rec.Aprl_Tp,
                p_Aprl_Ch            => Rec.Aprl_Ch,
                p_New_Id             => Rec.Aprl_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ДОДАТКОВИХ ДЖЕРЕЛ ІСНУВАННЯ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Other_Incomes (
        p_Apr_Id              IN Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Persons         IN Api$appeal.t_Apr_Persons,
        p_Apr_Other_Incomes   IN Api$appeal.t_Apr_Other_Incomes)
    IS
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Apro_Id
                  FROM Apr_Other_Income  o
                       LEFT JOIN TABLE (p_Apr_Other_Incomes) n
                           ON o.Apro_Id = n.Apro_Id
                 WHERE o.Apro_Apr = p_Apr_Id AND n.Apro_Id IS NULL)
        LOOP
            Api$appeal.Delete_Apr_Other_Income (Rec.Apro_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR Rec
            IN (SELECT o.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Other_Incomes)  o
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON o.Apro_Aprp = p.Aprp_Id)
        LOOP
            Check_Apr_Integrity (
                p_Apr_Id        => p_Apr_Id,
                p_Table         => 'Apr_Other_Income',
                p_Apr_Field     => 'Apro_Apr',
                p_Id_Field      => 'Apro_Id',
                p_Id_Val        => Rec.Apro_Id,
                p_Entity_Name   => 'Додаткове джерело існування');

            --Зберігаємо запис
            Api$appeal.Save_Apr_Other_Income (
                p_Apro_Id             => Rec.Apro_Id,
                p_Apro_Apr            => p_Apr_Id,
                p_Apro_Tp             => Rec.Apro_Tp,
                p_Apro_Income_Info    => Rec.Apro_Income_Info,
                p_Apro_Income_Usage   => Rec.Apro_Income_Usage,
                p_Apro_Aprp           => Rec.Aprp_Id,
                p_New_Id              => Rec.Apro_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ВІДОМОСТЕЙ ПРО ВИТРАТИ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Spendings (
        p_Apr_Id          IN Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Persons     IN Api$appeal.t_Apr_Persons,
        p_Apr_Spendings   IN Api$appeal.t_Apr_Spendings)
    IS
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Aprs_Id
                  FROM Apr_Spending  o
                       LEFT JOIN TABLE (p_Apr_Spendings) n
                           ON o.Aprs_Id = n.Aprs_Id
                 WHERE o.Aprs_Apr = p_Apr_Id AND n.Aprs_Id IS NULL)
        LOOP
            Api$appeal.Delete_Apr_Spending (Rec.Aprs_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR Rec
            IN (SELECT s.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Spendings)  s
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON s.Aprs_Aprp = p.Aprp_Id)
        LOOP
            Check_Apr_Integrity (p_Apr_Id        => p_Apr_Id,
                                 p_Table         => 'Apr_Spending',
                                 p_Apr_Field     => 'Aprs_Apr',
                                 p_Id_Field      => 'Aprs_Id',
                                 p_Id_Val        => Rec.Aprs_Id,
                                 p_Entity_Name   => 'Відомості про витрати');

            --Зберігаємо запис
            Api$appeal.Save_Apr_Spending (
                p_Aprs_Id            => Rec.Aprs_Id,
                p_Aprs_Apr           => p_Apr_Id,
                p_Aprs_Ln_Initials   => NULL,
                p_Aprs_Tp            => Rec.Aprs_Tp,
                p_Aprs_Cost_Type     => Rec.Aprs_Cost_Type,
                p_Aprs_Cost          => To_Money (Rec.Aprs_Cost),
                p_Aprs_Dt            => TO_DATE (Rec.Aprs_Dt, c_Xml_Dt_Fmt),
                p_Aprs_Aprp          => Rec.Aprp_Id,
                p_New_Id             => Rec.Aprs_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ТРАНСПОРТНИХ ЗАСОБІВ З ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Apr_Vehicles (
        p_Apr_Id         IN Ap_Declaration.Apr_Id%TYPE,
        p_Apr_Persons    IN Api$appeal.t_Apr_Persons,
        p_Apr_Vehicles   IN Api$appeal.t_Apr_Vehicles)
    IS
    BEGIN
        --Видаляємо записи які наявні у зверненні, але відсутні у запиті
        FOR Rec
            IN (SELECT o.Aprv_Id
                  FROM Apr_Vehicle  o
                       LEFT JOIN TABLE (p_Apr_Vehicles) n
                           ON o.Aprv_Id = n.Aprv_Id
                 WHERE o.Aprv_Apr = p_Apr_Id AND n.Aprv_Id IS NULL)
        LOOP
            Api$appeal.Delete_Apr_Vehicle (Rec.Aprv_Id);
        END LOOP;

        --Зберігаємо дані з запиту
        FOR Rec
            IN (SELECT v.*,
                       GREATEST (p.Aprp_Id, NVL (p.New_Id, -1))    AS Aprp_Id
                  FROM TABLE (p_Apr_Vehicles)  v
                       LEFT JOIN TABLE (p_Apr_Persons) p
                           ON v.Aprv_Aprp = p.Aprp_Id)
        LOOP
            Check_Apr_Integrity (p_Apr_Id        => p_Apr_Id,
                                 p_Table         => 'Apr_Vehicle',
                                 p_Apr_Field     => 'Aprv_Apr',
                                 p_Id_Field      => 'Aprv_Id',
                                 p_Id_Val        => Rec.Aprv_Id,
                                 p_Entity_Name   => 'Транспортний засіб');

            --Зберігаємо запис
            Api$appeal.Save_Apr_Vehicle (
                p_Aprv_Id                => Rec.Aprv_Id,
                p_Aprv_Apr               => p_Apr_Id,
                p_Aprv_Ln_Initials       => NULL,
                p_Aprv_Car_Brand         => Rec.Aprv_Car_Brand,
                p_Aprv_License_Plate     => Rec.Aprv_License_Plate,
                p_Aprv_Production_Year   => Rec.Aprv_Production_Year,
                p_Aprv_Is_Social_Car     => Rec.Aprv_Is_Social_Car,
                p_Aprv_Aprp              => Rec.Aprp_Id,
                p_New_Id                 => Rec.Aprv_Id);
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                    ЗБЕРЕЖЕННЯ ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Save_Declaration (
        p_Ap_Id             IN     Appeal.Ap_Id%TYPE,
        p_Ap_Src            IN     Appeal.Ap_Src%TYPE,
        p_Com_Org           IN     Appeal.Com_Org%TYPE,
        p_Declaration_Dto   IN OUT Api$appeal.r_Declaration_Dto,
        p_Ap_Persons        IN     Api$appeal.t_Ap_Persons)
    IS
    BEGIN
        Tools.Writemsg ('DNET$APPEAL_EXT.' || $$PLSQL_UNIT);
        Save_Ap_Declaration (p_Ap_Id,
                             p_Com_Org,
                             p_Ap_Persons,
                             p_Declaration_Dto.Declaration);

        IF p_Declaration_Dto.Persons IS NOT NULL
        THEN
            --Зберігаємо учасників
            Save_Apr_Persons (
                p_Ap_Id         => p_Ap_Id,
                p_Ap_Src        => p_Ap_Src,
                p_Apr_Id        => p_Declaration_Dto.Declaration.Apr_Id,
                p_Apr_Persons   => p_Declaration_Dto.Persons,
                p_Ap_Persons    => p_Ap_Persons);
        END IF;

        IF p_Declaration_Dto.Incomes IS NOT NULL
        THEN
            --Зберігаємо доходи
            Save_Apr_Incomes (
                p_Apr_Id        => p_Declaration_Dto.Declaration.Apr_Id,
                p_Apr_Persons   => p_Declaration_Dto.Persons,
                p_Apr_Incomes   => p_Declaration_Dto.Incomes);
        END IF;

        IF p_Declaration_Dto.Other_Incomes IS NOT NULL
        THEN
            --Зберігаємо додаткові джерела доходів
            Save_Apr_Other_Incomes (
                p_Apr_Id              => p_Declaration_Dto.Declaration.Apr_Id,
                p_Apr_Persons         => p_Declaration_Dto.Persons,
                p_Apr_Other_Incomes   => p_Declaration_Dto.Other_Incomes);
        END IF;

        IF p_Declaration_Dto.Spendings IS NOT NULL
        THEN
            --Зберігаємо витрати
            Save_Apr_Spendings (
                p_Apr_Id          => p_Declaration_Dto.Declaration.Apr_Id,
                p_Apr_Persons     => p_Declaration_Dto.Persons,
                p_Apr_Spendings   => p_Declaration_Dto.Spendings);
        END IF;

        IF p_Declaration_Dto.Land_Plots IS NOT NULL
        THEN
            --Зберігаємо земельні ділянки
            Save_Apr_Land_Plots (
                p_Apr_Id           => p_Declaration_Dto.Declaration.Apr_Id,
                p_Apr_Persons      => p_Declaration_Dto.Persons,
                p_Apr_Land_Plots   => p_Declaration_Dto.Land_Plots);
        END IF;

        IF p_Declaration_Dto.Living_Qurters IS NOT NULL
        THEN
            --Зберігаємо житлові приміщення
            Save_Apr_Living_Quarters (
                p_Apr_Id                => p_Declaration_Dto.Declaration.Apr_Id,
                p_Apr_Persons           => p_Declaration_Dto.Persons,
                p_Apr_Living_Quarters   => p_Declaration_Dto.Living_Qurters);
        END IF;

        IF p_Declaration_Dto.Vehicles IS NOT NULL
        THEN
            --Зберігаємо транспортні засоби
            Save_Apr_Vehicles (
                p_Apr_Id         => p_Declaration_Dto.Declaration.Apr_Id,
                p_Apr_Persons    => p_Declaration_Dto.Persons,
                p_Apr_Vehicles   => p_Declaration_Dto.Vehicles);
        END IF;
    END;

    ---------------------------------------------------------------------
    --              ЗБЕРЕЖЕННЯ ІПН #92351
    ---------------------------------------------------------------------
    PROCEDURE Save_Ipn (p_Ap_Id IN NUMBER, p_Ap_Src IN VARCHAR2)
    IS
    BEGIN
        FOR Rec
            IN (SELECT p.App_Id, p.App_Inn
                  FROM Ap_Person p
                 WHERE     p.App_Ap = p_Ap_Id
                       AND p.History_Status = 'A'
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM Ap_Document d
                                 WHERE     d.Apd_App = p.App_Id
                                       AND d.Apd_Ndt = 5
                                       AND d.History_Status = 'A'))
        LOOP
            IF    NULLIF (Rec.App_Inn, '0000000000') IS NULL
               OR NOT REGEXP_LIKE (Rec.App_Inn, '^[0-9]{10}$')
            THEN
                CONTINUE;
            END IF;

            DECLARE
                l_Doc_Id    NUMBER;
                l_Dh_Id     NUMBER;
                l_Apd_Id    NUMBER;
                l_Apda_Id   NUMBER;
            BEGIN
                Uss_Doc.Api$documents.Save_Document (
                    p_Doc_Id          => NULL,
                    p_Doc_Ndt         => 5,
                    p_Doc_Actuality   => 'U',
                    p_New_Id          => l_Doc_Id);
                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => NULL,
                    p_Dh_Doc         => l_Doc_Id,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Ndt         => 5,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   => 'U',
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => NULL,
                    p_Dh_Src         => p_Ap_Src,
                    p_New_Id         => l_Dh_Id);
                Api$appeal.Save_Document (p_Apd_Id    => NULL,
                                          p_Apd_Ap    => p_Ap_Id,
                                          p_Apd_Ndt   => 5,
                                          p_Apd_Doc   => l_Doc_Id,
                                          p_Apd_Vf    => NULL,
                                          p_Apd_App   => Rec.App_Id,
                                          p_New_Id    => l_Apd_Id,
                                          p_Com_Wu    => NULL,
                                          p_Apd_Dh    => l_Dh_Id,
                                          p_Apd_Aps   => NULL,
                                          p_Apd_Src   => p_Ap_Src);

                Api$appeal.Save_Document_Attr (
                    p_Apda_Id           => NULL,
                    p_Apda_Ap           => p_Ap_Id,
                    p_Apda_Apd          => l_Apd_Id,
                    p_Apda_Nda          => 1,
                    p_Apda_Val_Int      => NULL,
                    p_Apda_Val_Dt       => NULL,
                    p_Apda_Val_String   => Rec.App_Inn,
                    p_Apda_Val_Id       => NULL,
                    p_Apda_Val_Sum      => NULL,
                    p_New_Id            => l_Apda_Id);
            END;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --              ЗБЕРЕЖЕННЯ ВІДМОВИ ІПН #92351
    ---------------------------------------------------------------------
    PROCEDURE Save_Ipn_Refuse (p_Ap_Id IN NUMBER, p_Ap_Src IN VARCHAR2)
    IS
    BEGIN
        FOR Rec
            IN (SELECT p.App_Id
                  FROM Ap_Person  p
                       JOIN Ap_Document d
                           ON     p.App_Id = d.Apd_App
                              AND d.Apd_Ndt = 605
                              AND d.History_Status = 'A'
                       JOIN Ap_Document_Attr a
                           ON     d.Apd_Id = a.Apda_Apd
                              --якщо вказано атрибут відмова від РНОКПП
                              AND a.Apda_Nda = 640
                              AND a.Apda_Val_String = 'T'
                              AND a.History_Status = 'A'
                 WHERE     p.App_Ap = p_Ap_Id
                       AND p.History_Status = 'A'
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM Ap_Document d
                                 WHERE     d.Apd_App = p.App_Id
                                       AND d.Apd_Ndt = 10117
                                       AND d.History_Status = 'A'))
        LOOP
            DECLARE
                l_Doc_Id   NUMBER;
                l_Dh_Id    NUMBER;
                l_Apd_Id   NUMBER;
            BEGIN
                Uss_Doc.Api$documents.Save_Document (
                    p_Doc_Id          => NULL,
                    p_Doc_Ndt         => 10117,
                    p_Doc_Actuality   => 'U',
                    p_New_Id          => l_Doc_Id);
                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => NULL,
                    p_Dh_Doc         => l_Doc_Id,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Ndt         => 10117,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   => 'U',
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => NULL,
                    p_Dh_Src         => p_Ap_Src,
                    p_New_Id         => l_Dh_Id);
                Api$appeal.Save_Document (p_Apd_Id    => NULL,
                                          p_Apd_Ap    => p_Ap_Id,
                                          p_Apd_Ndt   => 10117,
                                          p_Apd_Doc   => l_Doc_Id,
                                          p_Apd_Vf    => NULL,
                                          p_Apd_App   => Rec.App_Id,
                                          p_New_Id    => l_Apd_Id,
                                          p_Com_Wu    => NULL,
                                          p_Apd_Dh    => l_Dh_Id,
                                          p_Apd_Aps   => NULL,
                                          p_Apd_Src   => p_Ap_Src);
            END;
        END LOOP;
    END;

    PROCEDURE Generate_Aid_Docs (p_Ap_Id IN NUMBER, p_Ap_Src IN VARCHAR2)
    IS
    BEGIN
        IF NOT Aps_Exist (p_Ap_Id, '269,248,265,267')
        THEN
            RETURN;
        END IF;

        Save_Ipn (p_Ap_Id, p_Ap_Src);
        Save_Ipn_Refuse (p_Ap_Id, p_Ap_Src);
    END;


    FUNCTION Get_Services_Xml (p_Ap_Id IN NUMBER)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLAGG (
                   XMLELEMENT ("AppealsSocService",
                               XMLELEMENT ("Aps_Id", s.Aps_Id),
                               XMLELEMENT ("Aps_Nst", s.Aps_Nst),
                               XMLELEMENT ("Aps_St", s.Aps_St),
                               XMLELEMENT ("Aps_Status_Name", St.Dic_Name)))
          INTO l_Result
          FROM Ap_Service  s
               JOIN Uss_Ndi.v_Ddn_Aps_St St ON s.Aps_St = St.Dic_Value
         WHERE s.Aps_Ap = p_Ap_Id AND s.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Persons_Xml (p_Ap_Id IN NUMBER)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLAGG (XMLELEMENT ("AppealsPerson",
                                   XMLELEMENT ("App_Id", p.App_Id),
                                   XMLELEMENT ("App_Tp", p.App_Tp),
                                   XMLELEMENT ("App_Inn", p.App_Inn),
                                   XMLELEMENT ("App_Ndt", p.App_Ndt),
                                   XMLELEMENT ("App_Doc_Num", p.App_Doc_Num),
                                   XMLELEMENT ("App_Fn", p.App_Fn),
                                   XMLELEMENT ("App_Mn", p.App_Mn),
                                   XMLELEMENT ("App_Ln", p.App_Ln),
                                   XMLELEMENT ("App_Esr_Num", p.App_Esr_Num),
                                   XMLELEMENT ("App_Gender", p.App_Gender)))
          INTO l_Result
          FROM Ap_Person p
         WHERE p.App_Ap = p_Ap_Id AND p.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Payments_Xml (p_Ap_Id IN NUMBER)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLAGG (
                   XMLELEMENT (
                       "AppealsPayment",
                       XMLELEMENT ("Apm_Id", Apm_Id),
                       XMLELEMENT ("Apm_Aps", Apm_Aps),
                       XMLELEMENT ("Apm_App", Apm_App),
                       XMLELEMENT ("Apm_Tp", Apm_Tp),
                       XMLELEMENT ("Apm_Index", Apm_Index),
                       XMLELEMENT ("Apm_Katottg_Code", k.Kaot_Code),
                       XMLELEMENT ("Apm_Mfo", b.Nb_Mfo),
                       XMLELEMENT ("Apm_Account", Apm_Account),
                       XMLELEMENT ("Apm_Need_Account", Apm_Need_Account)))
          INTO l_Result
          FROM Ap_Payment  Pm
               LEFT JOIN Uss_Ndi.v_Ndi_Bank b ON Apm_Nb = b.Nb_Id
               LEFT JOIN Uss_Ndi.v_Ndi_Katottg k ON Pm.Apm_Kaot = k.Kaot_Id
         WHERE Apm_Ap = p_Ap_Id AND Pm.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Attribute_Xml (p_Apda_Id           IN NUMBER,
                                p_Apda_Apd          IN NUMBER,
                                p_Apda_Nda          IN NUMBER,
                                p_Apda_Val_Int      IN NUMBER,
                                p_Apda_Val_Dt       IN DATE,
                                p_Apda_Val_String   IN VARCHAR2,
                                p_Apda_Val_Id       IN NUMBER,
                                p_Apda_Val_Sum      IN NUMBER)
        RETURN XMLTYPE
    IS
        l_Attr              XMLTYPE;
        l_Apda_Val_Id       NUMBER := p_Apda_Val_Id;
        l_Apda_Val_String   Ap_Document_Attr.Apda_Val_String%TYPE
                                := p_Apda_Val_String;
    BEGIN
        Decode_Attr_Val_Out (p_Nda_Id       => p_Apda_Nda,
                             p_Val_Id       => l_Apda_Val_Id,
                             p_Val_String   => l_Apda_Val_String);

        SELECT XMLELEMENT (
                   "Attribute",
                   XMLELEMENT ("Apda_Id", p_Apda_Id),
                   XMLELEMENT ("Apda_Apd", p_Apda_Apd),
                   XMLELEMENT ("Apda_Nda", p_Apda_Nda),
                   CASE
                       WHEN p_Apda_Val_Int IS NOT NULL
                       THEN
                           XMLELEMENT ("Apda_Val_Int", p_Apda_Val_Int)
                   END,
                   CASE
                       WHEN p_Apda_Val_Dt IS NOT NULL
                       THEN
                           XMLELEMENT ("Apda_Val_Dt",
                                       TO_CHAR (p_Apda_Val_Dt, c_Xml_Dt_Fmt))
                   END,
                   CASE
                       WHEN l_Apda_Val_String IS NOT NULL
                       THEN
                           XMLELEMENT ("Apda_Val_String", l_Apda_Val_String)
                   END,
                   CASE
                       WHEN l_Apda_Val_Id IS NOT NULL
                       THEN
                           XMLELEMENT ("Apda_Val_Id", l_Apda_Val_Id)
                   END,
                   CASE
                       WHEN p_Apda_Val_Sum IS NOT NULL
                       THEN
                           XMLELEMENT ("Apda_Val_Sum", p_Apda_Val_Sum)
                   END)
          INTO l_Attr
          FROM DUAL;

        RETURN l_Attr;
    END;

    FUNCTION Get_Documents_Xml (p_Ap_Id      IN NUMBER,
                                p_Ndt_List   IN VARCHAR2 DEFAULT NULL)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLAGG (
                   XMLELEMENT (
                       "AppealsDocument",
                       XMLELEMENT ("Apd_Id", Apd_Id),
                       XMLELEMENT ("Apd_Ndt", Apd_Ndt),
                       XMLELEMENT ("Apd_App", Apd_App),
                       --АТРИБУТИ
                       XMLELEMENT (
                           "Attributes",
                           (SELECT XMLAGG (
                                       Get_Attribute_Xml (
                                           p_Apda_Id        => Apda_Id,
                                           p_Apda_Apd       => Apda_Apd,
                                           p_Apda_Nda       => Apda_Nda,
                                           p_Apda_Val_Int   => Apda_Val_Int,
                                           p_Apda_Val_Dt    => Apda_Val_Dt,
                                           p_Apda_Val_String   =>
                                               Apda_Val_String,
                                           p_Apda_Val_Id    => Apda_Val_Id,
                                           p_Apda_Val_Sum   => Apda_Val_Sum))
                              FROM Ap_Document_Attr
                             WHERE Apda_Apd = Apd_Id AND History_Status = 'A')),
                       XMLELEMENT (
                           "ArrayOfDcoumentAttachments",
                           (SELECT XMLAGG (
                                       XMLELEMENT (
                                           "Attachment",
                                           XMLELEMENT (
                                               "File",
                                               XMLELEMENT ("File_Name",
                                                           f.File_Name),
                                               XMLELEMENT ("File_Mime_Type",
                                                           f.File_Mime_Type),
                                               XMLELEMENT ("File_Size",
                                                           f.File_Size),
                                               XMLELEMENT ("File_Hash",
                                                           f.File_Hash),
                                               XMLELEMENT (
                                                   "File_Create_Dt",
                                                   TO_CHAR (f.File_Create_Dt,
                                                            c_Xml_Dt_Fmt)),
                                               XMLELEMENT ("Index",
                                                           Da.Dat_Num),
                                               XMLELEMENT ("File_Code",
                                                           f.File_Code)),
                                           XMLELEMENT (
                                               "FileECP",
                                               XMLELEMENT ("File_Name",
                                                           s.File_Name),
                                               XMLELEMENT ("File_Mime_Type",
                                                           s.File_Mime_Type),
                                               XMLELEMENT ("File_Size",
                                                           s.File_Size),
                                               XMLELEMENT ("File_Hash",
                                                           s.File_Hash),
                                               XMLELEMENT (
                                                   "File_Create_Dt",
                                                   TO_CHAR (s.File_Create_Dt,
                                                            c_Xml_Dt_Fmt)),
                                               XMLELEMENT ("Index",
                                                           Da.Dat_Num),
                                               XMLELEMENT ("File_Code",
                                                           s.File_Code))))
                              FROM Uss_Doc.v_Doc_Attachments  Da
                                   JOIN Uss_Doc.v_Files f
                                       ON Da.Dat_File = f.File_Id
                                   LEFT JOIN Uss_Doc.v_Files s
                                       ON Da.Dat_Sign_File = s.File_Id
                             WHERE Da.Dat_Dh = Apd_Dh))))
          INTO l_Result
          FROM Ap_Document
         WHERE     Apd_Ap = p_Ap_Id
               AND History_Status = 'A'
               AND (   p_Ndt_List IS NULL
                    OR (    p_Ndt_List IS NOT NULL
                        AND Apd_Ndt IN
                                (SELECT TO_NUMBER (COLUMN_VALUE)
                                   FROM XMLTABLE (p_Ndt_List))));

        RETURN l_Result;
    END;

    FUNCTION Get_Declaration_Xml (p_Ap_Id IN NUMBER)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLELEMENT (
                   "Declaration",
                   XMLELEMENT (
                       "Declaration",
                       XMLELEMENT ("Apr_Id", Apr_Id),
                       XMLELEMENT ("Apr_Fn", Apr_Fn),
                       XMLELEMENT ("Apr_Mn", Apr_Mn),
                       XMLELEMENT ("Apr_Ln", Apr_Ln),
                       XMLELEMENT ("Apr_Residence", Apr_Residence),
                       XMLELEMENT ("Apr_Start_Dt",
                                   TO_CHAR (Apr_Start_Dt, c_Xml_Dt_Fmt)),
                       XMLELEMENT ("Apr_Stop_Dt",
                                   TO_CHAR (Apr_Stop_Dt, c_Xml_Dt_Fmt))), --ЧЛЕНИ СІМ’Ї
                   XMLELEMENT (
                       "Persons",
                       (SELECT XMLAGG (
                                   XMLELEMENT (
                                       "row",
                                       XMLELEMENT ("Aprp_Id", Aprp_Id),
                                       XMLELEMENT ("Aprp_App", Aprp_App),
                                       XMLELEMENT ("Aprp_Fn", Aprp_Fn),
                                       XMLELEMENT ("Aprp_Mn", Aprp_Mn),
                                       XMLELEMENT ("Aprp_Ln", Aprp_Ln),
                                       XMLELEMENT ("Aprp_Tp", Aprp_Tp),
                                       XMLELEMENT ("Aprp_Inn", Aprp_Inn),
                                       XMLELEMENT ("Aprp_Notes", Aprp_Notes)))
                          FROM Apr_Person
                         WHERE Aprp_Apr = Apr_Id AND History_Status = 'A')),
                   --ДОХОДИ
                   XMLELEMENT (
                       "Incomes",
                       (SELECT XMLAGG (
                                   XMLELEMENT (
                                       "row",
                                       XMLELEMENT ("Apri_Id", Apri_Id),
                                       XMLELEMENT ("Apri_Aprp", Apri_Aprp),
                                       XMLELEMENT ("Apri_Tp", Apri_Tp),
                                       XMLELEMENT ("Apri_Sum", Apri_Sum),
                                       XMLELEMENT ("Apri_Source",
                                                   Apri_Source)))
                          FROM Apr_Income
                         WHERE Apri_Apr = Apr_Id AND History_Status = 'A')),
                   --ЖИТЛОВІ ПРИМІЩЕННЯ
                   XMLELEMENT (
                       "LivingQuarters",
                       (SELECT XMLAGG (
                                   XMLELEMENT (
                                       "row",
                                       XMLELEMENT ("Aprl_Id", Aprl_Id),
                                       XMLELEMENT ("Aprl_Aprp", Aprl_Aprp),
                                       XMLELEMENT ("Aprl_Area", Aprl_Area),
                                       XMLELEMENT ("Aprl_Qnt", Aprl_Qnt),
                                       XMLELEMENT ("Aprl_Address",
                                                   Aprl_Address),
                                       XMLELEMENT ("Aprl_Tp", Aprl_Tp),
                                       XMLELEMENT ("Aprl_Ch", Aprl_Ch)))
                          FROM Apr_Living_Quarters
                         WHERE Aprl_Apr = Apr_Id AND History_Status = 'A')),
                   --ТРАНСПОРТНІ ЗАСОБИ
                   XMLELEMENT (
                       "Vehicles",
                       (SELECT XMLAGG (
                                   XMLELEMENT (
                                       "row",
                                       XMLELEMENT ("Aprv_Id", Aprv_Id),
                                       XMLELEMENT ("Aprv_Aprp", Aprv_Aprp),
                                       XMLELEMENT ("Aprv_Car_Brand",
                                                   Aprv_Car_Brand),
                                       XMLELEMENT ("Aprv_License_Plate",
                                                   Aprv_License_Plate),
                                       XMLELEMENT ("Aprv_Production_Year",
                                                   Aprv_Production_Year),
                                       XMLELEMENT ("Aprv_Is_Social_Car",
                                                   Aprv_Is_Social_Car)))
                          FROM Apr_Vehicle
                         WHERE Aprv_Apr = Apr_Id AND History_Status = 'A')),
                   --ЗЕМЕЛЬНІ ДІЛЯНКИ
                   XMLELEMENT (
                       "LandPlots",
                       (SELECT XMLAGG (
                                   XMLELEMENT (
                                       "row",
                                       XMLELEMENT ("Aprt_Id", Aprt_Id),
                                       XMLELEMENT ("Aprt_Aprp", Aprt_Aprp),
                                       XMLELEMENT ("Aprt_Area", Aprt_Area),
                                       XMLELEMENT ("Aprt_Ownership",
                                                   Aprt_Ownership),
                                       XMLELEMENT ("Aprt_Purpose",
                                                   Aprt_Purpose)))
                          FROM Apr_Land_Plot
                         WHERE Aprt_Apr = Apr_Id AND History_Status = 'A')),
                   --ІНЩІ ДЖЕРЕЛА ДОХОДІВ
                   XMLELEMENT (
                       "OtherIncomes",
                       (SELECT XMLAGG (
                                   XMLELEMENT (
                                       "row",
                                       XMLELEMENT ("Apro_Id", Apro_Id),
                                       XMLELEMENT ("Apro_Aprp", Apro_Aprp),
                                       XMLELEMENT ("Apro_Tp", Apro_Tp),
                                       XMLELEMENT ("Apro_Income_Info",
                                                   Apro_Income_Info),
                                       XMLELEMENT ("Apro_Income_Usage",
                                                   Apro_Income_Usage)))
                          FROM Apr_Other_Income
                         WHERE Apro_Apr = Apr_Id AND History_Status = 'A')),
                   --ВИТРАТИ
                   XMLELEMENT (
                       "Spendings",
                       (SELECT XMLAGG (
                                   XMLELEMENT (
                                       "row",
                                       XMLELEMENT ("Aprs_Id", Aprs_Id),
                                       XMLELEMENT ("Aprs_Aprp", Aprs_Aprp),
                                       XMLELEMENT ("Aprs_Tp", Aprs_Tp),
                                       XMLELEMENT ("Aprs_Cost_Type",
                                                   Aprs_Cost_Type),
                                       XMLELEMENT ("Aprs_Cost", Aprs_Cost),
                                       XMLELEMENT (
                                           "Aprs_Dt",
                                           TO_CHAR (Aprs_Dt, c_Xml_Dt_Fmt))))
                          FROM Apr_Spending
                         WHERE Aprs_Apr = Apr_Id AND History_Status = 'A')))
          INTO l_Result
          FROM Ap_Declaration
         WHERE Apr_Ap = p_Ap_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_Appeal_Xml (p_Ap_Id   IN NUMBER,
                             p_Rn_Id   IN NUMBER DEFAULT NULL)
        RETURN CLOB
    IS
        l_Result   XMLTYPE;
    BEGIN
        IF p_Rn_Id IS NOT NULL
        THEN
            Save_Rn_Ap (p_Rn_Id => p_Rn_Id, p_Ap_Id => p_Ap_Id);
        END IF;

        SELECT XMLELEMENT (
                   "Appeal",
                   --ШАПКА ЗВЕРНЕННЯ
                   XMLELEMENT ("Ap_Id", a.Ap_Id),
                   XMLELEMENT ("Ap_Num", a.Ap_Num),
                   XMLELEMENT ("Ap_Reg_Dt",
                               TO_CHAR (a.Ap_Reg_Dt, c_Xml_Dt_Fmt)),
                   XMLELEMENT ("Ap_Tp", a.Ap_Tp),
                   XMLELEMENT (
                       "Com_Org",
                       CASE
                           WHEN a.Ap_Tp = 'ADOPT'
                           THEN
                               Ikis_Rbm.Api$request_Msp.Get_Ap_Ssd (Ap_Id)
                           ELSE
                               TO_CHAR (a.Com_Org)
                       END),
                   XMLELEMENT ("Ap_Is_Second", a.Ap_Is_Second),
                   XMLELEMENT ("Ap_Ext_Ident", a.Ap_Ext_Ident),
                   XMLELEMENT ("Ap_St", a.Ap_St),
                   XMLELEMENT ("Ap_Status_Name", s.Dic_Name),
                   --ПОСЛУГИ
                   XMLELEMENT ("ArrayOfAppealsSocService",
                               Get_Services_Xml (Ap_Id)),
                   --УЧАСНИКИ
                   XMLELEMENT ("ArrayOfAppealsPerson",
                               Get_Persons_Xml (Ap_Id)),
                   --ВИПЛАТНІ РЕКВІЗИТИ
                   XMLELEMENT ("ArrayOfAppealsPayment",
                               Get_Payments_Xml (Ap_Id)),
                   --ДОКУМЕНТИ
                   XMLELEMENT ("ArrayOfAppealsDocument",
                               Get_Documents_Xml (Ap_Id)),
                   --ДЕКЛАРАЦІЯ
                   Get_Declaration_Xml (Ap_Id))
          INTO l_Result
          FROM Appeal a JOIN Uss_Ndi.v_Ddn_Ap_St s ON a.Ap_St = s.Dic_Value
         WHERE a.Ap_Id = p_Ap_Id;

        RETURN l_Result.Getclobval;
    END;

    PROCEDURE Check_Appeal_Access (p_Ap_Id IN NUMBER, p_Src IN VARCHAR2)
    IS
        l_Is_Allowed   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Is_Allowed
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id AND a.Ap_Src = p_Src;

        IF l_Is_Allowed <> 1
        THEN
            Raise_Application_Error (
                c_Err_Code_Not_Allowed,
                   'Доступ до звернення '
                || p_Ap_Id
                || ' для джерела '
                || p_Src
                || ' заборонено');
        END IF;
    END;

    --==============================================================--
    --  Чи буде звернення відпрацьовуватись лише у зовніщній системи
    --==============================================================--
    FUNCTION Is_Ext_Process (p_Ap_Id IN NUMBER, p_Ap_Tp IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Is_Ext_Process   VARCHAR2 (10);
    BEGIN
        IF Api$appeal.Get_Ap_Src (p_Ap_Id) = 'DIIA'
        THEN
            IF p_Ap_Tp IN ('S', 'ADOPT', 'VPO')
            THEN
                RETURN 'T';
            ELSIF p_Ap_Tp IN ('V', 'REG')
            THEN                                                     --#103439
                SELECT COALESCE (--Найвищій приорітет має налаштування по району
                                 MAX (c.Nnec_Is_Ext_Process),
                                 --Потім по області
                                 MAX (Cc.Nnec_Is_Ext_Process),
                                 --Якщо не вказано налаштування використовується значення встановлене при збержені звернення
                                 --(від Дії зберігаємо - T, від СГ - F)
                                 MAX (a.Ap_Is_Ext_Process))
                  INTO l_Is_Ext_Process
                  FROM Appeal  a
                       JOIN Ikis_Sys.v_Opfu o ON a.Com_Org = o.Org_Id
                       LEFT JOIN Ap_Service s
                           ON a.Ap_Id = s.Aps_Ap AND s.History_Status = 'A'
                       --Налаштування по району
                       LEFT JOIN Uss_Ndi.v_Ndi_Nst_Ext_Config c
                           ON     a.Com_Org = c.Nnec_Org
                              AND s.Aps_Nst = c.Nnec_Nst
                       --Налаштування по області
                       LEFT JOIN Uss_Ndi.v_Ndi_Nst_Ext_Config Cc
                           ON     o.Org_Org = Cc.Nnec_Org
                              AND s.Aps_Nst = Cc.Nnec_Nst
                 WHERE a.Ap_Id = p_Ap_Id;

                RETURN l_Is_Ext_Process;
            END IF;
        END IF;

        RETURN 'F';
    END;

    --114386
    FUNCTION Get_Document_Content (
        p_Ap_Documents   IN OUT NOCOPY Api$appeal.t_Ap_Documents,
        p_Ndt_Id         IN            NUMBER,
        p_File_Data      IN OUT NOCOPY CLOB)
        RETURN BOOLEAN
    IS
    BEGIN
        IF p_Ap_Documents IS NOT NULL
        THEN
            FOR i IN 1 .. p_Ap_Documents.COUNT
            LOOP
                IF p_Ap_Documents (i).Apd_Ndt = p_Ndt_Id
                THEN
                    IF p_Ap_Documents (i).Apd_Attachments IS NOT NULL
                    THEN
                        SELECT EXTRACT (p_Ap_Documents (i).Apd_Attachments,
                                        '/*/File_Data').Getclobval ()
                          INTO p_File_Data
                          FROM DUAL;

                        RETURN     p_File_Data IS NOT NULL
                               AND DBMS_LOB.Getlength (p_File_Data) > 0;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        RETURN FALSE;
    END;

    -- 113826
    FUNCTION Parse_Json_Atch_10336 (p_File_Data CLOB)
        RETURN r_Appeal_Data
    IS
        l_Res   r_Appeal_Data;
    BEGIN
        IF p_File_Data IS NOT NULL
        THEN
            EXECUTE IMMEDIATE Type2jsontable (
                                 p_Pkg_Name    => 'DNET$APPEAL_EXT',
                                 p_Type_Name   => 'R_APPEAL_DATA',
                                 p_Date_Fmt    => 'yyyy-mm-dd')
                USING IN p_File_Data, OUT l_Res;
        END IF;

        RETURN l_Res;
    END;

    -- 113826
    PROCEDURE Save_10336_Data (p_File_Data IN CLOB)
    IS
        l_Json   CLOB;
        l_Req    r_Appeal_Data;
    BEGIN
        IF p_File_Data IS NULL OR DBMS_LOB.getlength (p_File_Data) = 0
        THEN
            NULL;                                                    --RETURN;
        ELSE
                  SELECT x.file_data
                    INTO l_Json
                    FROM XMLTABLE ('/File_Data'
                                   PASSING XMLTYPE (p_File_Data)
                                   COLUMNS file_data    CLOB PATH '.') x;

            l_Json := tools.b64_decode (l_Json);
            l_Req := Parse_Json_Atch_10336 (l_Json);
        END IF;
    END;

    ---------------------------------------------------------------------
    --                    ЗБЕРЕЖЕННЯ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Save_Appeal (p_Ap_Id            IN OUT Appeal.Ap_Id%TYPE,
                           p_Ap_Is_Second     IN     Appeal.Ap_Is_Second%TYPE,
                           p_Ap_Tp            IN     Appeal.Ap_Tp%TYPE,
                           p_Ap_Reg_Dt        IN     Appeal.Ap_Reg_Dt%TYPE,
                           p_Ap_Src           IN     Appeal.Ap_Src%TYPE,
                           p_Ap_Doc           IN     Appeal.Ap_Doc%TYPE,
                           p_Ap_Ext_Ident     IN     VARCHAR2,
                           p_Ap_Com_Org       IN     VARCHAR2,
                           p_Ap_Services      IN     CLOB,
                           p_Ap_Persons       IN     CLOB,
                           p_Ap_Payments      IN     CLOB,
                           p_Ap_Documents     IN     CLOB,
                           p_Ap_Declaration   IN     CLOB,
                           p_Rn_Id            IN     NUMBER,
                           p_Saved_Appeal        OUT CLOB --XML збереженного звернення
                                                         )
    IS
        l_Is_New              BOOLEAN;
        l_Ap_Services         Api$appeal.t_Ap_Services;
        l_Ap_Persons          Api$appeal.t_Ap_Persons;
        l_Ap_Payments         Api$appeal.t_Ap_Payments;
        l_Ap_Documents        Api$appeal.t_Ap_Documents;
        l_Ap_Declaration      Api$appeal.r_Declaration_Dto;
        l_Ap_St               Appeal.Ap_St%TYPE;
        l_Ap_Is_Ext_Process   Appeal.Ap_Is_Ext_Process%TYPE;
        l_Com_Org             Appeal.Com_Org%TYPE;
        l_Org_Org             NUMBER;
        l_Org_St              VARCHAR2 (10);
        l_Com_Org_Orig        VARCHAR2 (100) := p_Ap_Com_Org;
        l_Hs_Id               Histsession.Hs_Id%TYPE;
        l_Lock_Handle         Tools.t_Lockhandler;
    BEGIN
        Tools.Writemsg ('DNET$APPEAL_EXT.' || $$PLSQL_UNIT);

        IF p_Ap_Tp = 'VPO'
        THEN
            Raise_Application_Error (c_Err_Code_Bad_Req,
                                     'Обробку звернень припинено');
        END IF;

        l_Is_New := NVL (p_Ap_Id, 0) < 0;

        IF NOT l_Is_New
        THEN
            SELECT MAX (a.Ap_St)
              INTO l_Ap_St
              FROM Appeal a
             WHERE a.Ap_Id = p_Ap_Id;

            IF l_Ap_St IS NULL
            THEN
                Raise_Application_Error (
                    c_Err_Code_Not_Found,
                    'Звернення з ІД ' || p_Ap_Id || ' не знайдено');
            END IF;

            Check_Appeal_Access (p_Ap_Id, p_Ap_Src);

            --2021.08.05: згідно усної постановки К.Я. редагування зверенення можливе лише в статусі "Очікування документів"
            IF NOT Dnet$appeal_Ext.Ap_Edit_Allowed (p_Ap_St   => l_Ap_St,
                                                    p_Ap_Tp   => p_Ap_Tp) =
                   'T'
            THEN
                Raise_Application_Error (
                    c_Err_Code_Not_Allowed,
                    'Редагування звернення в поточному статусі заборонено');
            END IF;
        ELSE
            --IF p_Ap_Tp IN (Api$appeal.c_Ap_Tp_Ehelp, Api$appeal.c_Ap_Tp_Adopt) THEN
            Ikis_Sys.Ikis_Lock.Request_Lock (
                p_Permanent_Name      => Tools.Ginstance_Lock_Name,
                p_Var_Name            => 'AP_SAVE' || p_Ap_Tp || p_Ap_Ext_Ident,
                p_Errmessage          => NULL,
                p_Lockhandler         => l_Lock_Handle,
                p_Timeout             => 3600,
                p_Release_On_Commit   => TRUE);

            SELECT MAX (Ap_Id)
              INTO p_Ap_Id
              FROM (  SELECT a.Ap_Id
                        FROM Appeal a
                       WHERE     a.Ap_Ext_Ident = p_Ap_Ext_Ident
                             AND a.Ap_Tp = p_Ap_Tp
                    ORDER BY a.Ap_Create_Dt
                       FETCH FIRST ROW ONLY);

            IF p_Ap_Id IS NOT NULL
            THEN
                p_Saved_Appeal := Get_Appeal_Xml (p_Ap_Id);
                RETURN;
            END IF;
        --END IF;
        END IF;

        --Парсинг вхідних даних
        BEGIN
            l_Ap_Services := Api$appeal.Parse_Services (p_Ap_Services);
            l_Ap_Persons := Api$appeal.Parse_Persons (p_Ap_Persons);
            l_Ap_Payments := Api$appeal.Parse_Payments (p_Ap_Payments);
            l_Ap_Documents := Api$appeal.Parse_Documents (p_Ap_Documents);
            l_Ap_Declaration :=
                Api$appeal.Parse_Declaration (p_Ap_Declaration);
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    c_Err_Code_Bad_Req,
                       'Помилка парсингу: '
                    || CHR (13)
                    || SQLERRM
                    || CHR (13)
                    || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        --Визначаємо район в залежності від типу звернення
        IF p_Ap_Tp IN (Api$appeal.c_Ap_Tp_Subs,
                       Api$appeal.c_Ap_Tp_Vpo,
                       Api$appeal.c_Ap_Tp_Ehelp,
                       'D')
        THEN
            l_Com_Org := 50000;
        ELSIF p_Ap_Tp IN (Api$appeal.c_Ap_Tp_Help, 'REG')
        THEN                                                         --#103439
            --Оримуємо ІД району
            l_Com_Org := Api$community.Decode_Org (p_Ap_Com_Org);

            IF l_Com_Org IS NULL
            THEN
                Raise_Application_Error (c_Err_Code_Bad_Req,
                                         'Не визначено район');
            END IF;

            --Отримуємо ІД області
            SELECT o.Org_Org, o.Org_St
              INTO l_Org_Org, l_Org_St
              FROM Ikis_Sys.v_Opfu o
             WHERE o.Org_Id = l_Com_Org;

            --Якщо район не активний - беремо перший район з області
            IF l_Org_St <> 'A'
            THEN
                  SELECT o.Org_Id
                    INTO l_Com_Org
                    FROM Ikis_Sys.v_Opfu o
                   WHERE o.Org_Org = l_Org_Org AND o.Org_St = 'A'
                ORDER BY o.Org_Id
                   FETCH FIRST ROW ONLY;

                IF l_Com_Org IS NULL
                THEN
                    Raise_Application_Error (c_Err_Code_Bad_Req,
                                             'Не визначено район');
                END IF;
            END IF;
        ELSIF p_Ap_Tp = Api$appeal.c_Ap_Tp_Adopt
        THEN
            l_Com_Org := Ssd2com_Org (p_Ssd_Code => l_Com_Org_Orig);
        END IF;

        IF NVL (l_Com_Org, -1) <> l_Com_Org_Orig
        THEN
            --Зберігаємо оригінальний код району до атрибута технічного документа, для подальшої передачі в інщі системи
            Uss_Doc.Api$documents.Save_Doc_Attr (
                p_Dh_Id     =>
                    Uss_Doc.Api$documents.Get_Last_Doc_Hist (p_Ap_Doc),
                p_Nda_Id    => 2328,
                p_Val_Str   => l_Com_Org_Orig);
        END IF;

        Api$appeal.Save_Appeal (
            p_Ap_Id               => p_Ap_Id,
            p_Ap_Num              => NULL,
            p_Ap_Reg_Dt           => p_Ap_Reg_Dt,
            p_Ap_Create_Dt        => SYSDATE,
            p_Ap_Src              => p_Ap_Src,
            p_Ap_St               => l_Ap_St,
            p_Com_Org             => l_Com_Org,
            p_Ap_Dest_Org         => l_Com_Org,
            --Через помилку в протоколі обміну з Дією, перекодуємо ознаку "навпаки"
            p_Ap_Is_Second        =>
                CASE NVL (p_Ap_Is_Second, 'F') WHEN 'F' THEN 'T' ELSE 'F' END,
            p_Ap_Vf               => NULL,
            p_Com_Wu              => NULL,
            p_Ap_Tp               => p_Ap_Tp,
            p_New_Id              => p_Ap_Id,
            p_Ap_Ext_Ident        => p_Ap_Ext_Ident,
            p_Ap_Doc              => p_Ap_Doc,
            p_Ap_Is_Ext_Process   => 'T');

        Save_Rn_Ap (p_Rn_Id => p_Rn_Id, p_Ap_Id => p_Ap_Id);

        --Збереження послуг
        IF l_Ap_Services IS NOT NULL
        THEN
            Save_Services (p_Ap_Id, l_Ap_Services);
        END IF;

        --ЗБЕРЕЖЕННЯ УЧАСНИКІВ
        IF l_Ap_Persons IS NOT NULL
        THEN
            Save_Persons (p_Ap_Id, l_Ap_Persons);
        END IF;

        --ЗБЕРЕЖЕННЯ СПОСОБІВ ВИПЛАТ
        IF l_Ap_Payments IS NOT NULL
        THEN
            Save_Payments (p_Ap_Id,
                           l_Ap_Payments,
                           l_Ap_Services,
                           l_Ap_Persons);
        END IF;

        --ЗБЕРЕЖЕННЯ ДОКУМЕНТІВ
        IF l_Ap_Documents IS NOT NULL
        THEN
            Save_Documents (p_Ap_Id,
                            l_Ap_Documents,
                            l_Ap_Persons,
                            p_Ap_Src);
        END IF;

        --ГЕНЕРАЦІЯ ДОКУМЕНТІВ ДЛЯ ДОПОМОГ
        Generate_Aid_Docs (p_Ap_Id, p_Ap_Src);

        --ЗБЕРЕЖЕННЯ ДЕКЛАРАЦІЇ
        IF l_Ap_Declaration.Declaration.Apr_Id IS NOT NULL
        THEN
            Save_Declaration (p_Ap_Id,
                              p_Ap_Src,
                              l_Com_Org,
                              l_Ap_Declaration,
                              l_Ap_Persons);
        END IF;

        l_Ap_St :=
            CASE
                --20231002: За постановкою О.Зиновець(#92632) звернення на допомогу від дії йдуть не ручгне опрацювання.
                --На це є дві причини:
                --1. Звернення містять помилки, що потребують виправлення
                --2. В МСП немає відповідальної особи від імені якої можна відправляти запити до ДПС.
                --   При редагуванні такою особою стане користувч, що візьме звернення в роботу
                WHEN     p_Ap_Src = Api$appeal.c_Src_Diia
                     AND p_Ap_Tp IN (Api$appeal.c_Ap_Tp_Help, 'REG') --#103439
                     AND NOT (   Api$appeal.Document_Exists (p_Ap_Id, 10100)
                              OR Api$appeal.Document_Exists (p_Ap_Id, 10101))
                THEN
                    'J'
                --#103439
                WHEN p_Ap_Src IN ('PFU') AND p_Ap_Tp = 'REG'
                THEN
                    'V'                                             --Виконано
                ELSE
                    Api$appeal.c_Ap_St_Reg
            END;

        --Визначаємо чи буде звернення опрацьовуватись в ЄІССС
        l_Ap_Is_Ext_Process := Is_Ext_Process (p_Ap_Id, p_Ap_Tp);

        UPDATE Appeal a
           SET a.Ap_Is_Ext_Process = l_Ap_Is_Ext_Process, a.Ap_St = l_Ap_St
         WHERE a.Ap_Id = p_Ap_Id;

        l_Hs_Id := Tools.Gethistsession ();

        --Пишемо повідомлення в журнал
        Api$appeal.Write_Log (
            p_Apl_Ap   => p_Ap_Id,
            p_Apl_Hs   => l_Hs_Id,
            p_Apl_St   => l_Ap_St,
            p_Apl_Message   =>
                CASE
                    WHEN p_Ap_Id IS NULL THEN CHR (38) || '1'
                    ELSE CHR (38) || '2'
                END);

        IF p_Ap_Tp = Api$appeal.c_Ap_Tp_Ehelp
        THEN
            DECLARE
                l_Aps_Id   NUMBER;
            BEGIN
                --Для звернень на єДопомогу створюємо контейнери довідок ВПО, для подальшої верифікації в реєстрі ВПО
                Save_Vpo_Crt (p_Ap_Id => p_Ap_Id);
                --Створюємо послугу "Меморандум"
                Api$appeal.Save_Service (p_Aps_Id    => NULL,
                                         p_Aps_Nst   => 732,
                                         p_Aps_Ap    => p_Ap_Id,
                                         p_Aps_St    => 'R',
                                         p_New_Id    => l_Aps_Id);
            END;
        END IF;

        --Формуємо відповідь
        p_Saved_Appeal := Get_Appeal_Xml (p_Ap_Id);
    -- p_Saved_Appeal := l_File_Data;
    END;

    FUNCTION Get_Last_Apl_Message (p_Apl_Ap IN NUMBER, p_Apl_St IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Log.Apl_Message%TYPE;
    BEGIN
          SELECT Uss_Ndi.Rdm$msg_Template.Getmessagetext (l.Apl_Message)
            INTO l_Result
            FROM Ap_Log l JOIN Histsession s ON l.Apl_Hs = s.Hs_Id
           WHERE l.Apl_Ap = p_Apl_Ap AND l.Apl_St = p_Apl_St
        ORDER BY s.Hs_Dt DESC
           FETCH FIRST ROW ONLY;

        RETURN l_Result;
    END;

    ----------------------------------------------------------------------------
    --               Відхилення звернення
    ----------------------------------------------------------------------------
    FUNCTION Decline_Appeal (p_Request IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Ap_Id        NUMBER;
        l_Ap_St        Appeal.Ap_St%TYPE;
        l_Is_Allowed   VARCHAR2 (10);
        l_Message      VARCHAR2 (4000);
        l_Result       XMLTYPE;
    BEGIN
        BEGIN
              SELECT Ap_Id
                INTO l_Ap_Id
                FROM XMLTABLE ('/*'
                               PASSING Xmltype (p_Request)
                               COLUMNS Ap_Id    NUMBER PATH 'Ap_Id');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    c_Err_Code_Bad_Req,
                       'Помилка парсингу: '
                    || CHR (13)
                    || SQLERRM
                    || CHR (13)
                    || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        BEGIN
            SELECT a.Ap_St
              INTO l_Ap_St
              FROM Appeal a
             WHERE a.Ap_Id = l_Ap_Id
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Raise_Application_Error (
                    c_Err_Code_Bad_Req,
                    'Звернення з ІД ' || l_Ap_Id || ' не знайдено');
        END;

        IF Api$ap_Processing.Cancel_Appeals (l_Ap_Id)
        THEN
            l_Message := 'Заяву успішно відхилено.';
            l_Is_Allowed := 'T';
        ELSE
            l_Message := 'На поточному етапі відхилення заяви неможливе.';
            l_Is_Allowed := 'F';
        END IF;

        SELECT XMLELEMENT ("AppealDeclineResult",
                           XMLELEMENT ("Success", l_Is_Allowed),
                           XMLELEMENT ("Message", l_Message))
          INTO l_Result
          FROM DUAL;

        RETURN l_Result.Getstringval;
    END;

    ----------------------------------------------------------------------------
    --         Створення запису з інформацією про помилку в журналі звернення
    ----------------------------------------------------------------------------
    PROCEDURE Write_Error (p_Apl_Ap NUMBER, p_Apl_Message VARCHAR2)
    IS
        l_Ap_St    Appeal.Ap_St%TYPE;
        l_Apl_Id   Ap_Log.Apl_Id%TYPE;
    BEGIN
        SELECT a.Ap_St
          INTO l_Ap_St
          FROM Appeal a
         WHERE a.Ap_Id = p_Apl_Ap;

        SELECT MAX (l.Apl_Id)
          INTO l_Apl_Id
          FROM Ap_Log l
         WHERE l.Apl_Ap = p_Apl_Ap AND l.Apl_Message = p_Apl_Message;

        IF l_Apl_Id IS NULL
        THEN
            Api$appeal.Write_Log (
                p_Apl_Ap        => p_Apl_Ap,
                p_Apl_Hs        => Tools.Gethistsession,
                p_Apl_St        => l_Ap_St,
                p_Apl_Message   => p_Apl_Message,
                p_Apl_Tp        => Api$appeal.c_Apl_Tp_Terror);
        ELSE
            --На випадок, якщо помилка повторюється, просто оновлюємо час в журналі
            --для запобігання створення великої кількості дублів
            UPDATE Ap_Log l
               SET l.Apl_Hs = Tools.Gethistsession
             WHERE l.Apl_Id = l_Apl_Id;
        END IF;
    END;

    ----------------------------------------------------------------------------
    --             Створення запису в журналі звернення
    ----------------------------------------------------------------------------
    PROCEDURE Write_Log (p_Apl_Ap        NUMBER,
                         p_Apl_Message   VARCHAR2,
                         p_Apl_Tp        VARCHAR2 DEFAULT NULL)
    IS
        l_Ap_St   Appeal.Ap_St%TYPE;
    BEGIN
        SELECT a.Ap_St
          INTO l_Ap_St
          FROM Appeal a
         WHERE a.Ap_Id = p_Apl_Ap;

        Api$appeal.Write_Log (
            p_Apl_Ap        => p_Apl_Ap,
            p_Apl_Hs        => Tools.Gethistsession,
            p_Apl_St        => l_Ap_St,
            p_Apl_Message   => p_Apl_Message,
            p_Apl_Tp        => NVL (p_Apl_Tp, Api$appeal.c_Apl_Tp_Tinfo));
    END;

    ----------------------------------------------------------------------------
    --                Отримання переліку звернень за фільтрами
    ----------------------------------------------------------------------------
    FUNCTION Get_Appeal_List_Xml (p_Ap_Search_Filter IN CLOB)
        RETURN CLOB
    IS
        l_Result   XMLTYPE;
    BEGIN
        FOR Rec
            IN (            SELECT *
                              FROM XMLTABLE (
                                       '/*'
                                       PASSING Xmltype (p_Ap_Search_Filter)
                                       COLUMNS Numident           VARCHAR2 (12) PATH 'Numident',
                                               App_Ndt            NUMBER PATH 'App_Ndt',
                                               App_Doc_Num        VARCHAR2 (50) PATH 'App_Doc_Num',
                                               App_Fn             VARCHAR2 (50) PATH 'App_Fn',
                                               App_Mn             VARCHAR2 (50) PATH 'App_Mn',
                                               App_Ln             VARCHAR2 (50) PATH 'App_Ln',
                                               Period_Start_Dt    VARCHAR2 (30) PATH 'Period_Start_Dt',
                                               Period_Stop_Dt     VARCHAR2 (30) PATH 'Period_Stop_Dt',
                                               Ap_Tp              VARCHAR2 (10) PATH 'Ap_Tp'))
        LOOP
            SELECT XMLAGG (
                       XMLELEMENT (
                           "AppealRow",
                           XMLELEMENT ("Ap_Num", Ap_Num),
                           XMLELEMENT ("Ap_Reg_Dt", Ap_Reg_Dt),
                           XMLELEMENT ("Ap_Tp", Ap_Tp),
                           XMLELEMENT ("Ap_St", Ap_St),
                           XMLELEMENT ("Ap_St_Name", Ap_St),
                           XMLELEMENT (
                               "Aps_List",
                               (SELECT LISTAGG (t.Nst_Name, ', ')
                                           WITHIN GROUP (ORDER BY Aps_Id)
                                  FROM Ap_Service  s
                                       JOIN Uss_Ndi.v_Ndi_Service_Type t
                                           ON s.Aps_Nst = t.Nst_Id
                                 WHERE     Aps_Id = Ap_Id
                                       AND s.History_Status = 'A'))))
              INTO l_Result
              FROM Appeal  a
                   JOIN Uss_Ndi.v_Ddn_Ap_St St ON Ap_St = St.Dic_Value
             WHERE     1 = 1
                   AND a.Ap_Reg_Dt BETWEEN NVL (Rec.Period_Start_Dt,
                                                a.Ap_Reg_Dt)
                                       AND NVL (Rec.Period_Stop_Dt,
                                                a.Ap_Reg_Dt)
                   AND a.Ap_Tp = NVL (Rec.Ap_Tp, a.Ap_Tp)
                   --РНОКПП
                   AND (   Rec.Numident IS NULL
                        OR EXISTS
                               (SELECT NULL
                                  FROM Uss_Visit.Ap_Person z
                                 WHERE     z.App_Ap = a.Ap_Id
                                       AND z.App_Tp = 'Z'
                                       AND z.App_Inn = TRIM (Rec.Numident)))
                   --НОМЕР ДОКУМЕНТА
                   AND (   Rec.App_Doc_Num IS NULL
                        OR EXISTS
                               (SELECT NULL
                                  FROM Uss_Visit.Ap_Person z
                                 WHERE     z.App_Ap = a.Ap_Id
                                       AND z.App_Tp = 'Z'
                                       AND z.App_Doc_Num =
                                           TRIM (Rec.App_Doc_Num)
                                       AND z.App_Ndt = Rec.App_Ndt))
                   --ПРІЗВИЩЕ
                   AND (   Rec.App_Ln IS NULL
                        OR EXISTS
                               (SELECT NULL
                                  FROM Uss_Visit.Ap_Person z
                                 WHERE     z.App_Ap = a.Ap_Id
                                       AND z.App_Tp = 'Z'
                                       AND LOWER (z.App_Ln) LIKE
                                                  '%'
                                               || LOWER (TRIM (Rec.App_Ln))
                                               || '%'))
                   --ІМ’Я
                   AND (   Rec.App_Fn IS NULL
                        OR EXISTS
                               (SELECT NULL
                                  FROM Uss_Visit.Ap_Person z
                                 WHERE     z.App_Ap = a.Ap_Id
                                       AND z.App_Tp = 'Z'
                                       AND LOWER (z.App_Fn) LIKE
                                                  '%'
                                               || LOWER (TRIM (Rec.App_Fn))
                                               || '%'))
                   --ПО БАТЬКОВІ
                   AND (   Rec.App_Mn IS NULL
                        OR EXISTS
                               (SELECT NULL
                                  FROM Uss_Visit.Ap_Person z
                                 WHERE     z.App_Ap = a.Ap_Id
                                       AND z.App_Tp = 'Z'
                                       AND LOWER (z.App_Mn) LIKE
                                                  '%'
                                               || LOWER (TRIM (Rec.App_Mn))
                                               || '%'));
        END LOOP;

        SELECT XMLELEMENT ("AppealsList", l_Result) INTO l_Result FROM DUAL;

        RETURN l_Result.Getclobval;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                c_Err_Code_Bad_Req,
                   'Помилка парсингу: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    ----------------------------------------------------------------------------
    --                Отримання довідників
    ----------------------------------------------------------------------------
    FUNCTION Get_Ndi_Xml (p_Ndi_Filter IN CLOB)
        RETURN CLOB
    IS
        l_Dict_List   t_String_List;
        l_Result      XMLTYPE;
    BEGIN
        BEGIN
                  SELECT REGEXP_SUBSTR (REPLACE (Dict_List, ' '),
                                        '[^,]+',
                                        1,
                                        LEVEL)
                    BULK COLLECT INTO l_Dict_List
                    FROM XMLTABLE (
                             '/*'
                             PASSING Xmltype (p_Ndi_Filter)
                             COLUMNS Dict_List    VARCHAR2 (4000) PATH 'Dict_List')
              CONNECT BY REGEXP_SUBSTR (REPLACE (Dict_List, ' '),
                                        '[^,]+',
                                        1,
                                        LEVEL)
                             IS NOT NULL;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    c_Err_Code_Bad_Req,
                       'Помилка парсингу: '
                    || CHR (13)
                    || SQLERRM
                    || CHR (13)
                    || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        SELECT XMLAGG (CASE LOWER (COLUMN_VALUE)
                           WHEN 'apda_ndt'
                           THEN
                               Get_Dic_Xml (COLUMN_VALUE,
                                            'v_ndi_document_type',
                                            'ndt_id',
                                            'ndt_name',
                                            'ndt_name_short')
                           WHEN 'ssd'
                           THEN
                               Get_Ssd_Dic_Xml
                           ELSE
                               Get_Dic_Dv_Xml (COLUMN_VALUE)
                       END)
          INTO l_Result
          FROM TABLE (l_Dict_List);

        SELECT XMLELEMENT ("Dictionaries", l_Result) INTO l_Result FROM DUAL;

        RETURN l_Result.Getclobval;
    END;

    FUNCTION Get_Dic_Dv_Xml (p_Dic_Name IN VARCHAR2)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        EXECUTE IMMEDIATE 'SELECT
	Xmlelement("' || p_Dic_Name || '",
			Xmlagg(Xmlelement("row",
						 Xmlelement("id", dic_value),
						 Xmlelement("name", dic_name),
						 Xmlelement("sname", dic_sname))))
	FROM USS_NDI.V_DDN_' || p_Dic_Name
            INTO l_Result;

        RETURN l_Result;
    END;

    FUNCTION Get_Dic_Xml (p_Dic_Name      IN VARCHAR,
                          p_Table_Name    IN VARCHAR2,
                          p_Field_Id      IN VARCHAR2,
                          p_Field_Name    IN VARCHAR2,
                          p_Field_Sname   IN VARCHAR2)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        EXECUTE IMMEDIATE   'SELECT
	Xmlelement("'
                         || p_Dic_Name
                         || '",
			Xmlagg(Xmlelement("row",
						 Xmlelement("id", '
                         || p_Field_Id
                         || '),
						 Xmlelement("name", '
                         || p_Field_Name
                         || '),
						 Xmlelement("sname", '
                         || p_Field_Sname
                         || '))))
	FROM USS_NDI.'
                         || p_Table_Name
                         || q'[ WHERE HISTORY_STATUS='A']'
            INTO l_Result;

        RETURN l_Result;
    END;

    FUNCTION Get_Ssd_Dic_Xml
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLELEMENT (
                   "SSD",
                   XMLAGG (
                       XMLELEMENT (
                           "row",
                           XMLELEMENT ("id", s.Ncs_Id),
                           XMLELEMENT ("parent_id", s.Ncs_Ncs),
                           XMLELEMENT ("KATOTTG", k.Kaot_Code),
                           XMLELEMENT ("code", s.Ncs_Code),
                           XMLELEMENT ("name", s.Ncs_Name),
                           XMLELEMENT ("address", s.Ncs_Address),
                           XMLELEMENT ("contacts", s.Ncs_Contacts),
                           XMLELEMENT ("status", s.History_Status),
                           XMLELEMENT ("adopt", s.Ncs_Adopt),
                           XMLELEMENT ("advice", s.Ncs_Advice),
                           XMLELEMENT ("ps_dbst", s.Ncs_Ps_Dbst),
                           XMLELEMENT ("guardianship", s.Ncs_Guardianship))))
          INTO l_Result
          FROM Uss_Ndi.v_Ndi_Children_Service  s
               LEFT JOIN Uss_Ndi.v_Ndi_Katottg k ON s.Ncs_Kaot = k.Kaot_Id;

        RETURN l_Result;
    END;

    FUNCTION Decode_Ap_St (p_Ap_St               IN VARCHAR2,
                           p_Ap_Tp               IN VARCHAR2,
                           p_Ap_Is_Ext_Process   IN VARCHAR2          --Ignore
                                                            )
        RETURN VARCHAR2
    IS
    BEGIN
        --Для субсидій і усиновлення виключаємо технічні статуси
        IF     p_Ap_Tp IN (Api$appeal.c_Ap_Tp_Subs, Api$appeal.c_Ap_Tp_Adopt)
           AND p_Ap_St IN ('F',
                           'VW',
                           'VO',
                           'VE')
        THEN
            RETURN 'N';
        END IF;

        --Для допомог
        /*IF p_Ap_Tp = Api$appeal.c_Ap_Tp_Help THEN
          IF p_Ap_Is_Ext_Process = 'T' THEN
            IF p_Ap_St IN ('F', 'VW', 'VO') THEN
              RETURN 'N';
            END IF;
          END IF;
        END IF;*/

        RETURN p_Ap_St;
    END;

    ----------------------------------------------------------------------------
    --                Отримання стану обробки звернення
    ----------------------------------------------------------------------------
    PROCEDURE Get_Appeal_Process (p_Ap_Process_Filter   IN     CLOB,
                                  p_Rn_Id               IN     NUMBER,
                                  p_Ap_Log_Xml             OUT CLOB,
                                  p_Main_Cur               OUT SYS_REFCURSOR,
                                  p_Files_Cur              OUT SYS_REFCURSOR,
                                  p_Ap_Docs_Xml            OUT CLOB)
    IS
        l_Ap_Id              NUMBER;
        l_Is_Include_Files   VARCHAR2 (10);
        l_Apl_Log_Xml        XMLTYPE;
        l_Ap_St              Appeal.Ap_St%TYPE;
        l_Ap_Vf              NUMBER;
        l_Ap_Tp              Appeal.Ap_Tp%TYPE;
        l_Ap_Docs_Xml        XMLTYPE;
    BEGIN
        BEGIN
                         SELECT Ap_Id, Is_Include_Files
                           INTO l_Ap_Id, l_Is_Include_Files
                           FROM XMLTABLE (
                                    '/*'
                                    PASSING Xmltype (p_Ap_Process_Filter)
                                    COLUMNS Ap_Id               NUMBER PATH 'Ap_Id',
                                            Is_Include_Files    VARCHAR2 (10) PATH 'Is_Include_Files');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    c_Err_Code_Bad_Req,
                       'Помилка парсингу: '
                    || CHR (13)
                    || SQLERRM
                    || CHR (13)
                    || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        Save_Rn_Ap (p_Rn_Id => p_Rn_Id, p_Ap_Id => l_Ap_Id);

        SELECT MAX (l.Ap_St), MAX (l.Ap_Vf), MAX (l.Ap_Tp)
          INTO l_Ap_St, l_Ap_Vf, l_Ap_Tp
          FROM Appeal l
         WHERE l.Ap_Id = l_Ap_Id;

        IF l_Ap_St IS NULL
        THEN
            Raise_Application_Error (
                c_Err_Code_Not_Found,
                'Звернення з ІД ' || l_Ap_Id || ' не знайдено');
        END IF;

        --Журнал обробки звернення
        WITH
            Apl
            AS
                (SELECT Hs_Dt
                            AS Apl_Dt,
                        Decode_Ap_St (l.Apl_St, l_Ap_Tp, a.Ap_Is_Ext_Process)
                            AS Apl_St,
                        CASE
                            WHEN Apl_Tp = Api$appeal.c_Apl_Tp_Terror
                            THEN
                                'Помилка обробки'
                            ELSE
                                Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                    Apl_Message)
                        END
                            AS Apl_Message,
                        CASE
                            WHEN Apl_Tp = Api$appeal.c_Apl_Tp_Terror
                            THEN
                                Apl_Message
                        END
                            AS Apl_Tech_Info
                   FROM Uss_Visit.Ap_Log  l
                        JOIN Uss_Visit.Appeal a ON l.Apl_Ap = a.Ap_Id
                        JOIN Uss_Visit.Histsession s ON l.Apl_Hs = s.Hs_Id
                  WHERE     Apl_Ap = l_Ap_Id
                        AND Apl_Tp IN
                                (Api$appeal.c_Apl_Tp_Sys,
                                 Api$appeal.c_Apl_Tp_Terror,
                                 Api$appeal.c_Apl_Tp_Usr)
                        AND l_Ap_Tp <> Api$appeal.c_Ap_Tp_Ehelp
                        AND (   (    a.ap_src = 'DIIA'
                                 AND NVL (l.apl_st, '-1') <> 'O')
                             OR a.ap_src != 'DIIA') --#106772 -- скриваємо технічний статус
                 --#78769
                 -- AND NOT (l_Ap_Tp = Api$appeal.c_Ap_Tp_Help AND l.Apl_Tp = Api$appeal.c_Apl_Tp_Terror)
                 --Повідомлення для єДопомоги
                 UNION ALL
                 SELECT *
                   FROM (  SELECT Hs_Dt    AS Apl_Dt,
                                  l.Apl_St,
                                  CASE
                                      WHEN Apl_Tp = Api$appeal.c_Apl_Tp_Terror
                                      THEN
                                          'Помилка обробки'
                                      ELSE
                                          Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                              Apl_Message)
                                  END      AS Apl_Message,
                                  CASE
                                      WHEN Apl_Tp = Api$appeal.c_Apl_Tp_Terror
                                      THEN
                                          Apl_Message
                                  END      AS Apl_Tech_Info
                             FROM Ap_Log l
                                  JOIN Uss_Visit.Histsession s
                                      ON l.Apl_Hs = s.Hs_Id
                            WHERE     Apl_Ap = l_Ap_Id
                                  AND Apl_Tp IN
                                          (Api$appeal.c_Apl_Tp_Sys,
                                           Api$appeal.c_Apl_Tp_Terror,
                                           Api$appeal.c_Apl_Tp_Usr)
                                  AND l_Ap_Tp = Api$appeal.c_Ap_Tp_Ehelp
                                  AND l.Apl_St IN ('V', 'X', 'NS')
                         ORDER BY s.Hs_Dt DESC, l.Apl_Id DESC
                            FETCH FIRST ROW ONLY)
                 UNION ALL
                 SELECT SYSDATE                  AS Apl_Dt,
                        a.Ap_St                  AS Apl_St,
                        Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                            CHR (38) || '79')    AS Apl_Message,
                        NULL                     AS Apl_Tech_Info
                   FROM Appeal a
                  WHERE     a.Ap_Id = l_Ap_Id
                        AND a.Ap_Tp = Api$appeal.c_Ap_Tp_Ehelp
                        AND a.Ap_St NOT IN ('V', 'X', 'NS')),
            --Разом з журналом віддаємо помилки з протоколу верифікації
            Vfl
            AS
                (SELECT l.Vfl_Dt                           AS Apl_Dt,
                        Api$appeal.c_Ap_St_Not_Verified    AS Apl_St,
                        CASE
                            WHEN l.Vfl_Tp = Api$verification.c_Vfl_Tp_Terror
                            THEN
                                'Помилка обробки'
                            ELSE
                                Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                    l.Vfl_Message)
                        END                                AS Apl_Message,
                        CASE
                            WHEN l.Vfl_Tp = Api$verification.c_Vfl_Tp_Terror
                            THEN
                                l.Vfl_Message
                        END                                AS Apl_Tech_Info
                   FROM Vf_Log l
                  WHERE     l_Ap_Tp = Api$appeal.c_Ap_Tp_Help
                        AND l_Ap_St = Api$appeal.c_Ap_St_Not_Verified
                        AND l.Vfl_Vf IN
                                (    SELECT t.Vf_Id
                                       FROM Verification t
                                      WHERE t.Vf_Nvt <>
                                            Api$verification.c_Nvt_Rzo_Search
                                 START WITH t.Vf_Id = l_Ap_Vf
                                 CONNECT BY PRIOR t.Vf_Id = t.Vf_Vf_Main)
                        AND l.Vfl_Tp IN ('W', 'E', 'T')) --todo: очікуємо від дії відповідь чи потрібно їм повертати технічні помилки
        SELECT XMLAGG (XMLELEMENT (
                           "AppealLogRow",
                           XMLELEMENT ("Apl_Dt",
                                       TO_CHAR (Apl_Dt, c_Xml_Dt_Fmt)),
                           XMLELEMENT ("Apl_St", Apl_St),
                           XMLELEMENT ("Apl_St_Name", n.Dic_Name),
                           XMLELEMENT ("Apl_Message", Apl_Message),
                           XMLELEMENT ("Apl_Tech_Info", Apl_Tech_Info))
                       ORDER BY Apl_Dt)
          INTO l_Apl_Log_Xml
          FROM (SELECT * FROM Vfl
                UNION ALL
                SELECT * FROM Apl)
               JOIN Uss_Ndi.v_Ddn_Ap_St n ON Apl_St = n.Dic_Value;

        p_Ap_Log_Xml := l_Apl_Log_Xml.Getclobval;

        OPEN p_Main_Cur FOR
            SELECT a.Ap_Id,
                   Decode_Ap_St (a.Ap_St, a.Ap_Tp, a.Ap_Is_Ext_Process)
                       AS Ap_St,
                   s.Dic_Name
                       AS Ap_St_Name
              FROM Appeal  a
                   JOIN Uss_Ndi.v_Ddn_Ap_St s
                       ON Decode_Ap_St (a.Ap_St,
                                        a.Ap_Tp,
                                        a.Ap_Is_Ext_Process) =
                          s.Dic_Value
             WHERE a.Ap_Id = l_Ap_Id;

        IF l_Is_Include_Files = 'T'
        THEN
            --Вкладення документів
            Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

            INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
                SELECT DISTINCT Apd_Dh
                  FROM Ap_Document  d
                       JOIN Uss_Ndi.v_Ndi_Document_Type t
                           ON Apd_Ndt = t.Ndt_Id AND t.Ndt_Inout = 'out'
                 WHERE     Apd_Ap = l_Ap_Id
                       AND d.History_Status = 'A'
                       --Виключаємо вихідні документи, що прийшли від Дії
                       AND NOT EXISTS
                               (SELECT NULL
                                  FROM Uss_Doc.v_Doc_Hist h
                                 WHERE     h.Dh_Doc = d.Apd_Doc
                                       AND h.Dh_Src IN
                                               (Api$appeal.c_Src_Diia));

            Uss_Doc.Api$documents.Get_Attachments (p_Doc_Id        => NULL,
                                                   p_Dh_Id         => NULL,
                                                   p_Res           => p_Files_Cur,
                                                   p_Params_Mode   => 3);
        END IF;

        l_Ap_Docs_Xml :=
            Get_Documents_Xml (p_Ap_Id      => l_Ap_Id,
                               p_Ndt_List   => TO_CHAR (c_Decision_Ndt));

        IF l_Ap_Docs_Xml IS NOT NULL
        THEN
            p_Ap_Docs_Xml := l_Ap_Docs_Xml.Getclobval;
        END IF;
    END;

    FUNCTION Get_Person_Docs_Xml (p_Filter IN VARCHAR2)
        RETURN CLOB
    IS
        l_Inn               VARCHAR2 (12);
        l_Ndt               NUMBER;
        l_Doc_Num           VARCHAR2 (50);
        l_Fn                VARCHAR2 (50);
        l_Mn                VARCHAR2 (50);
        l_Ln                VARCHAR2 (50);
        l_Esr_Num           VARCHAR2 (20);
        l_App_Ndt           NUMBER;

        l_Found_Cnt         NUMBER;
        l_Show_Modal        NUMBER;
        l_Sc_Id             NUMBER;
        l_Name_Similarity   NUMBER;

        l_Result            XMLTYPE;
    BEGIN
        BEGIN
                SELECT Inn,
                       Ndt,
                       Doc_Num,
                       Fn,
                       Mn,
                       LN,
                       Esr_Num,
                       App_Ndt
                  INTO l_Inn,
                       l_Ndt,
                       l_Doc_Num,
                       l_Fn,
                       l_Mn,
                       l_Ln,
                       l_Esr_Num,
                       l_App_Ndt
                  FROM XMLTABLE ('/*'
                                 PASSING Xmltype (p_Filter)
                                 COLUMNS Inn        VARCHAR2 (12) PATH 'Inn',
                                         Ndt        NUMBER PATH 'Ndt',
                                         Doc_Num    VARCHAR2 (50) PATH 'Doc_Num',
                                         Fn         VARCHAR2 (50) PATH 'Fn',
                                         Mn         VARCHAR2 (50) PATH 'Mn',
                                         LN         VARCHAR2 (50) PATH 'Ln',
                                         Esr_Num    VARCHAR2 (20) PATH 'Esr_Num',
                                         App_Ndt    NUMBER PATH 'App_Ndt');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    c_Err_Code_Bad_Req,
                       'Помилка парсингу: '
                    || CHR (13)
                    || SQLERRM
                    || CHR (13)
                    || DBMS_UTILITY.Format_Error_Backtrace);
        END;

        IF    (l_Inn IS NULL AND l_Doc_Num IS NULL AND l_Esr_Num IS NULL)
           OR l_App_Ndt IS NULL
        THEN
            Raise_Application_Error (c_Err_Code_Bad_Req,
                                     'Не вказано обов’язкові параметри');
        END IF;

        Uss_Person.Api$socialcard.Search_Sc_By_Params (
            p_Inn          => l_Inn,
            p_Ndt_Id       => l_Ndt,
            p_Doc_Num      => l_Doc_Num,
            p_Fn           => l_Fn,
            p_Ln           => l_Ln,
            p_Mn           => l_Mn,
            p_Esr_Num      => l_Esr_Num,
            p_Gender       => NULL,
            p_Show_Modal   => l_Show_Modal,
            p_Found_Cnt    => l_Found_Cnt);

        IF l_Found_Cnt <> 1
        THEN
            Raise_Application_Error (c_Err_Code_Not_Found,
                                     'Не визначено особу');
        END IF;

        SELECT i.x_Id,
               UTL_MATCH.Edit_Distance_Similarity (
                   UPPER (Si.Sco_Fn || Si.Sco_Mn || Si.Sco_Ln),
                   UPPER (l_Fn || l_Mn || l_Ln))
          INTO l_Sc_Id, l_Name_Similarity
          FROM Uss_Person.Tmp_Work_Ids  i
               JOIN Uss_Person.v_Sc_Info Si ON i.x_Id = Si.Sco_Id;

        IF l_Esr_Num IS NULL AND l_Inn IS NULL AND l_Name_Similarity < 80
        THEN
            Raise_Application_Error (c_Err_Code_Not_Found,
                                     'Не визначено особу');
        END IF;

          SELECT XMLELEMENT (
                     "AppealsDocument",
                     XMLELEMENT ("Apd_Ndt", d.Scd_Ndt),
                     --Атрибути
                     XMLELEMENT (
                         "ArrayOfDocumentAttributes",
                         (SELECT XMLAGG (XMLELEMENT (
                                             "Attribute",
                                             XMLELEMENT ("Apda_Id", a.Da_Id),
                                             XMLELEMENT ("Apda_Apd", d.Scd_Doc),
                                             XMLELEMENT ("Apda_Nda", a.Da_Nda),
                                             XMLELEMENT ("Apda_Val_Int",
                                                         a.Da_Val_Int),
                                             XMLELEMENT ("Apda_Val_Dt",
                                                         a.Da_Val_Dt),
                                             XMLELEMENT ("Apda_Val_String",
                                                         a.Da_Val_String),
                                             XMLELEMENT ("Apda_Val_Sum",
                                                         a.Da_Val_Sum),
                                             XMLELEMENT ("Apda_Val_Id",
                                                         a.Da_Val_Id))
                                         ORDER BY n.Nda_Order)
                            FROM Uss_Doc.v_Doc_Attr2hist h
                                 JOIN Uss_Doc.v_Doc_Attributes a
                                     ON h.Da2h_Da = a.Da_Id
                                 JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                     ON a.Da_Nda = n.Nda_Id
                           WHERE h.Da2h_Dh = d.Scd_Dh)))
            INTO l_Result
            FROM Uss_Person.v_Sc_Document d
           WHERE     d.Scd_Sc = l_Sc_Id
                 AND d.Scd_Ndt = l_App_Ndt
                 AND d.Scd_St IN ('1', 'A')
                 AND d.Scd_Dh IS NOT NULL
        ORDER BY d.Scd_Id DESC
           FETCH FIRST ROW ONLY;

        RETURN l_Result.Getclobval;
    END;

    PROCEDURE Get_Doc_Identifiers (p_Apd_Id    IN     NUMBER,
                                   p_Apd_Doc      OUT NUMBER,
                                   p_Apd_Dh       OUT NUMBER)
    IS
    BEGIN
        SELECT d.Apd_Doc, d.Apd_Ndt
          INTO p_Apd_Doc, p_Apd_Dh
          FROM Ap_Document d
         WHERE d.Apd_Id = p_Apd_Id;
    END;

    PROCEDURE Get_Doc_Id (p_ap_id    IN     NUMBER,
                          p_ndt_id   IN     NUMBER,
                          p_app_id   IN     NUMBER,
                          o_apd_id      OUT NUMBER)
    IS
    BEGIN
        SELECT MAX (d.apd_id)
          INTO o_apd_id
          FROM ap_document d
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = p_ndt_id
               AND (d.apd_app = p_app_id OR p_app_id IS NULL)
               AND d.history_status = 'A';
    END Get_Doc_Id;

    --------------------------------------------------------------------------
    --       Збереження документа з метаданими звернення від Соцгромади
    --------------------------------------------------------------------------
    PROCEDURE Save_Community_Doc (p_Aps_Id          IN     NUMBER,
                                  p_File_Hash       IN     VARCHAR2,
                                  p_Apd_Doc            OUT NUMBER,
                                  p_Apd_Dh             OUT NUMBER,
                                  p_File_Modified      OUT VARCHAR2)
    IS
        l_File_Hash   Uss_Doc.v_Files.File_Hash%TYPE;
        l_Ap_Id       NUMBER;
        l_Apd_Id      NUMBER;
    BEGIN
        SELECT MAX (s.Aps_Ap)
          INTO l_Ap_Id
          FROM Ap_Service s
         WHERE s.Aps_Id = p_Aps_Id;

        --Отримуємо ідентифіктори вихідного документа, що містить метадані звернення
        SELECT MAX (d.Apd_Id),
               MAX (d.Apd_Doc),
               MAX (d.Apd_Dh),
               MAX (f.File_Hash)
          INTO l_Apd_Id,
               p_Apd_Doc,
               p_Apd_Dh,
               l_File_Hash
          FROM Ap_Document  d
               JOIN Uss_Doc.v_Doc_Attachments Da ON d.Apd_Dh = Da.Dat_Dh
               JOIN Uss_Doc.v_Files f ON Da.Dat_File = f.File_Id
         WHERE     d.Apd_Ap = l_Ap_Id
               AND d.Apd_Ndt = c_Community_Ndt_Out
               AND d.History_Status = 'A';

        IF p_Apd_Doc IS NULL
        THEN
            Uss_Doc.Api$documents.Save_Document (
                p_Doc_Id          => p_Apd_Doc,
                p_Doc_Ndt         => c_Community_Ndt_Out,
                p_Doc_Actuality   =>
                    Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                p_New_Id          => p_Apd_Doc);
        END IF;

        p_File_Modified :=
            CASE
                WHEN NVL (l_File_Hash, '-') <> p_File_Hash THEN 'T'
                ELSE 'F'
            END;

        --Створюємо новий зріз, якщо це новий документ,
        --або якщо метедані звернення було змінено
        IF p_Apd_Dh IS NULL OR p_File_Modified = 'T'
        THEN
            Uss_Doc.Api$documents.Save_Doc_Hist (
                p_Dh_Id          => NULL,
                p_Dh_Doc         => p_Apd_Doc,
                p_Dh_Sign_Alg    => NULL,
                p_Dh_Ndt         => c_Community_Ndt_Out,
                p_Dh_Sign_File   => NULL,
                p_Dh_Actuality   =>
                    Uss_Doc.Api$documents.c_Doc_Actuality_Undefined,
                p_Dh_Dt          => SYSDATE,
                p_Dh_Wu          => NULL,
                p_Dh_Src         => Api$appeal.c_Src_Community,
                p_New_Id         => p_Apd_Dh);
        END IF;

        IF l_Apd_Id IS NULL
        THEN
            INSERT INTO Ap_Document (Apd_Id,
                                     Apd_Ap,
                                     Apd_Ndt,
                                     Apd_Doc,
                                     History_Status,
                                     Apd_Dh)
                 VALUES (NULL,
                         l_Ap_Id,
                         c_Community_Ndt_Out,
                         p_Apd_Doc,
                         'A',
                         p_Apd_Dh);
        ELSE
            UPDATE Ap_Document d
               SET d.Apd_Dh = p_Apd_Dh
             WHERE d.Apd_Id = l_Apd_Id AND d.Apd_Dh <> p_Apd_Dh;
        END IF;
    END;

    --------------------------------------------------------------------------
    --     Збереження інформації про зміну статуса звернення в Соцгромаді
    --                           (Субсидії)
    --------------------------------------------------------------------------
    PROCEDURE Save_Community_Status_Sub (p_Aps_Id          IN     NUMBER,
                                         p_Status          IN     NUMBER,
                                         p_Status_Dt       IN     DATE,
                                         p_Code            IN     VARCHAR2,
                                         p_Message         IN     VARCHAR2,
                                         p_Apd_Doc         IN     NUMBER,
                                         p_Apd_Dh          IN     NUMBER,
                                         p_Rn_Id           IN     NUMBER,
                                         p_Error_Code         OUT NUMBER,
                                         p_Error_Message      OUT VARCHAR2)
    IS
        l_Aps_Id                      NUMBER;
        l_Ap_Id                       NUMBER;
        l_Ap_St_Old                   Appeal.Ap_St%TYPE;
        l_Ap_St_New                   Appeal.Ap_St%TYPE;
        l_Hs                          NUMBER;
        l_Apl_Message                 Ap_Log.Apl_Message%TYPE;
        l_Apl_Tp                      Ap_Log.Apl_Tp%TYPE;
        l_Doc_Exists                  NUMBER;
        c_Error_Not_Found    CONSTANT NUMBER := 1;
        c_Error_Unknown_St   CONSTANT NUMBER := 2;
    BEGIN
        p_Error_Code := 0;
        l_Aps_Id := p_Aps_Id;

        SELECT MAX (s.Aps_Ap), MAX (a.Ap_St)
          INTO l_Ap_Id, l_Ap_St_Old
          FROM Ap_Service s JOIN Appeal a ON s.Aps_Ap = a.Ap_Id
         WHERE s.Aps_Id = l_Aps_Id;

        IF l_Ap_Id IS NULL
        THEN
            p_Error_Code := c_Error_Not_Found;
            p_Error_Message := 'Послуга з ІД ' || p_Aps_Id || ' не знайдена';
            RETURN;
        END IF;

        Save_Rn_Ap (p_Rn_Id => p_Rn_Id, p_Ap_Id => l_Ap_Id);

        IF p_Status IS NOT NULL
        THEN
            l_Ap_St_New :=
                Uss_Ndi.Tools.Decode_Dict (
                    p_Nddc_Tp         => 'AP_ST',
                    p_Nddc_Src        => Api$appeal.c_Src_Community,
                    p_Nddc_Dest       => Api$appeal.c_Src_Vst,
                    p_Nddc_Code_Src   => p_Status);

            IF l_Ap_St_New IS NULL
            THEN
                p_Error_Code := c_Error_Unknown_St;
                p_Error_Message := 'Невідомий статус ' || p_Status;
                RETURN;
            END IF;

            IF l_Ap_St_New <> l_Ap_St_Old
            THEN
                --Змінюємо статус звернення
                UPDATE Appeal a
                   SET a.Ap_St = l_Ap_St_New
                 WHERE a.Ap_Id = l_Ap_Id;
            END IF;
        END IF;

        --Зберігаємо рееєстраційний запис документу з метаданними звернення
        SELECT SIGN (COUNT (*))
          INTO l_Doc_Exists
          FROM Ap_Document d
         WHERE d.Apd_Doc = p_Apd_Doc;

        IF l_Doc_Exists <> 1
        THEN
            INSERT INTO Ap_Document (Apd_Ap,
                                     Apd_Ndt,
                                     Apd_Doc,
                                     Apd_App,
                                     Apd_Dh,
                                     History_Status)
                 VALUES (l_Ap_Id,
                         c_Community_Ndt_Out,
                         p_Apd_Doc,
                         NULL,
                         p_Apd_Dh,
                         'A');
        END IF;

        --Визначаємо тип та вміст повідомлення для запису в журнал обробки зверення
        /*IF p_Subs_Decision = c_Subs_Decision_Declined
        THEN
         --Звернення відхилено
         l_Apl_Message := p_Refuse_Reason;
         l_Apl_Tp := Api$appeal.c_Apl_Tp_Sys;
        ELS*/
        IF p_Code <> '0'
        THEN
            --Технічна помилка на боці Соцгромади
            l_Apl_Message := p_Message;
            l_Apl_Tp := Api$appeal.c_Apl_Tp_Terror;
        ELSIF l_Ap_St_New <> l_Ap_St_Old
        THEN
            --Зміна статусу в ЄІССС
            l_Apl_Message := CHR (38) || '2';
            l_Apl_Tp := Api$appeal.c_Apl_Tp_Sys;
        END IF;

        Reg_Diia_Status_Send_Req (p_Ap_Id     => l_Ap_Id,
                                  p_Ap_St     => l_Ap_St_New,
                                  p_Message   => l_Apl_Message);

        IF l_Apl_Message IS NULL
        THEN
            RETURN;
        END IF;

        INSERT INTO Histsession (Hs_Id, Hs_Wu, Hs_Dt)
             VALUES (0, NULL, NVL (p_Status_Dt, SYSDATE))
          RETURNING Hs_Id
               INTO l_Hs;

        --Створюємо запис в журналі
        --#73983 2021,12,09
        Api$appeal.Write_Log (
            p_Apl_Ap        => l_Ap_Id,
            p_Apl_Hs        => l_Hs,
            p_Apl_St        => NVL (l_Ap_St_New, l_Ap_St_Old),
            p_Apl_Message   => l_Apl_Message,
            p_Apl_St_Old    =>
                CASE
                    WHEN     l_Ap_St_New IS NOT NULL
                         AND l_Ap_St_New <> l_Ap_St_Old
                    THEN
                        l_Ap_St_Old
                END,
            p_Apl_Tp        => l_Apl_Tp);
    END;

    --------------------------------------------------------------------------
    --  Створення документа по рішенню
    --------------------------------------------------------------------------
    PROCEDURE Create_Decision_Doc (
        p_Ap_Id           IN NUMBER,
        p_Start_Dt        IN DATE DEFAULT NULL,
        p_Stop_Dt         IN DATE DEFAULT NULL,
        p_Aid_Sum         IN NUMBER DEFAULT NULL,
        p_Refuse_Reason   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        FOR Rec
            IN (  SELECT s.Aps_Id,
                         s.Aps_Nst,
                         s.Aps_St,
                         p.App_Id
                    FROM Uss_Visit.Ap_Service s
                         JOIN Uss_Visit.Ap_Person p
                             ON     s.Aps_Ap = p.App_Ap
                                AND p.App_Tp = 'Z'
                                AND p.History_Status = 'A'
                   WHERE s.Aps_Ap = p_Ap_Id AND s.History_Status = 'A'
                ORDER BY s.Aps_Id)
        LOOP
            DECLARE
                l_Apd_Id    NUMBER;
                l_Doc_Id    NUMBER;
                l_Dh_Id     NUMBER;
                l_Apda_Id   NUMBER;
            BEGIN
                Uss_Doc.Api$documents.Save_Document (
                    p_Doc_Id          => NULL,
                    p_Doc_Ndt         => c_Decision_Ndt,
                    p_Doc_Actuality   => 'A',
                    p_New_Id          => l_Doc_Id);
                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => NULL,
                    p_Dh_Doc         => l_Doc_Id,
                    p_Dh_Ndt         => c_Decision_Ndt,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   => 'A',
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => NULL,
                    p_Dh_Src         => Api$appeal.c_Src_Community,
                    p_New_Id         => l_Dh_Id);
                /*Uss_Doc.Api$documents.Save_Doc_Attr(p_Dh_Id => l_Dh_Id, p_Nda_Id => 1747, p_Val_Str => Rec.Aps_Nst);
                Uss_Doc.Api$documents.Save_Doc_Attr(p_Dh_Id => l_Dh_Id, p_Nda_Id => 1748, p_Val_Str => Rec.Aps_St);
                Uss_Doc.Api$documents.Save_Doc_Attr(p_Dh_Id => l_Dh_Id, p_Nda_Id => 1750, p_Val_Dt => p_Start_Dt);
                Uss_Doc.Api$documents.Save_Doc_Attr(p_Dh_Id => l_Dh_Id, p_Nda_Id => 1751, p_Val_Dt => p_Stop_Dt);
                Uss_Doc.Api$documents.Save_Doc_Attr(p_Dh_Id => l_Dh_Id, p_Nda_Id => 1752, p_Val_Sum => p_Aid_Sum);
                Uss_Doc.Api$documents.Save_Doc_Attr(p_Dh_Id => l_Dh_Id, p_Nda_Id => 1753, p_Val_Str => p_Refuse_Reason);*/
                Api$appeal.Save_Document (
                    p_Apd_Id    => NULL,
                    p_Apd_Ap    => p_Ap_Id,
                    p_Apd_Ndt   => c_Decision_Ndt,
                    p_Apd_Doc   => l_Doc_Id,
                    p_Apd_Vf    => NULL,
                    p_Apd_App   => Rec.App_Id,
                    p_New_Id    => l_Apd_Id,
                    p_Com_Wu    => NULL,
                    p_Apd_Dh    => l_Dh_Id,
                    p_Apd_Aps   => Rec.Aps_Id,
                    p_Apd_Src   => Api$appeal.c_Src_Community);

                Api$appeal.Save_Document_Attr (
                    p_Apda_Id           => NULL,
                    p_Apda_Ap           => p_Ap_Id,
                    p_Apda_Apd          => l_Apd_Id,
                    p_Apda_Nda          => 1747,
                    p_Apda_Val_String   => Rec.Aps_Nst,
                    p_New_Id            => l_Apda_Id);
                Api$appeal.Save_Document_Attr (
                    p_Apda_Id           => NULL,
                    p_Apda_Ap           => p_Ap_Id,
                    p_Apda_Apd          => l_Apd_Id,
                    p_Apda_Nda          => 1748,
                    p_Apda_Val_String   => Rec.Aps_St,
                    p_New_Id            => l_Apda_Id);
                Api$appeal.Save_Document_Attr (p_Apda_Id       => NULL,
                                               p_Apda_Ap       => p_Ap_Id,
                                               p_Apda_Apd      => l_Apd_Id,
                                               p_Apda_Nda      => 1750,
                                               p_Apda_Val_Dt   => p_Start_Dt,
                                               p_New_Id        => l_Apda_Id);
                Api$appeal.Save_Document_Attr (p_Apda_Id       => NULL,
                                               p_Apda_Ap       => p_Ap_Id,
                                               p_Apda_Apd      => l_Apd_Id,
                                               p_Apda_Nda      => 1751,
                                               p_Apda_Val_Dt   => p_Stop_Dt,
                                               p_New_Id        => l_Apda_Id);
                Api$appeal.Save_Document_Attr (p_Apda_Id        => NULL,
                                               p_Apda_Ap        => p_Ap_Id,
                                               p_Apda_Apd       => l_Apd_Id,
                                               p_Apda_Nda       => 1752,
                                               p_Apda_Val_Sum   => p_Aid_Sum,
                                               p_New_Id         => l_Apda_Id);
                Api$appeal.Save_Document_Attr (
                    p_Apda_Id           => NULL,
                    p_Apda_Ap           => p_Ap_Id,
                    p_Apda_Apd          => l_Apd_Id,
                    p_Apda_Nda          => 1753,
                    p_Apda_Val_String   => p_Refuse_Reason,
                    p_New_Id            => l_Apda_Id);
            END;
        END LOOP;
    END;

    --------------------------------------------------------------------------
    --    Обробка зміни статуса в рамках пакету заяв ВПО
    --------------------------------------------------------------------------
    PROCEDURE Handle_Pkg_Vpo_Status (p_Aps_Id         IN     NUMBER,
                                     p_Status         IN     NUMBER,
                                     p_Code           IN     VARCHAR2,
                                     p_Message        IN     VARCHAR2,
                                     p_Rn_Id          IN     NUMBER,
                                     p_Change_Ap_St      OUT BOOLEAN)
    IS
        l_Vf_Id   NUMBER;
    BEGIN
        --Отримуємо ІД верифікації для пакетного ВПО
        SELECT MAX (d.Apd_Vf)
          INTO l_Vf_Id
          FROM Ap_Document d
         WHERE d.Apd_Aps = p_Aps_Id AND d.History_Status = 'A';

        --УСПІШНА ВЕРИФІКАЦІЯ
        IF p_Status IN (12, 5)
        THEN
            Api$verification.Link_Request2verification (l_Vf_Id, p_Rn_Id);
            --Змінюємо статус верифікації
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Done,
                p_Vfl_Message   => 'Верифікацію завершено успішно');
            Api$verification.Set_Verification_Status (
                p_Vf_Id       => l_Vf_Id,
                p_Vf_St       => Api$verification.c_Vf_St_Ok,
                p_Vf_Own_St   => Api$verification.c_Vf_St_Ok);
        --ВЕРИФІКАЦІЮ НЕ ПРОЙДЕНО
        ELSIF p_Status = 11 OR p_Code <> '0'
        THEN
            /*UPDATE Ap_Service s
              SET s.Aps_St = 'ERR'
            WHERE s.Aps_Id = p_Aps_Id;*/

            Api$verification.Link_Request2verification (l_Vf_Id, p_Rn_Id);
            Api$verification.Write_Vf_Log (
                l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Terror,
                p_Vfl_Message   => p_Message);
            Api$verification.Write_Vf_Log (
                p_Vf_Id         => l_Vf_Id,
                p_Vfl_Tp        => Api$verification.c_Vfl_Tp_Error,
                p_Vfl_Message   => 'Верифікацію заяви не пройдено');
            Api$verification.Set_Verification_Status (
                p_Vf_Id       => l_Vf_Id,
                p_Vf_St       => Api$verification.c_Vf_St_Not_Verified,
                p_Vf_Own_St   => Api$verification.c_Vf_St_Not_Verified);
        END IF;

        IF p_Status = 5
        THEN
            --Змінюємо статус послуги "Взяття на облік ВПО" на "Надано"
            /*UPDATE Ap_Service s
              SET s.Aps_St = 'N'
            WHERE s.Aps_Id = p_Aps_Id;*/

            --Якщо в пакетному звернені ВПО, заява на облік пройшла перевірку,
            --то статус всього звернення не змінюється
            p_Change_Ap_St := FALSE;
        ELSE
            p_Change_Ap_St := TRUE;
        END IF;
    END;

    --------------------------------------------------------------------------
    --     Збереження інформації про зміну статуса звернення в Соцгромаді
    --                           (Допомога одиноким матерям)
    --------------------------------------------------------------------------
    PROCEDURE Save_Community_Status_Aid (p_Aps_Id          IN     NUMBER,
                                         p_Status          IN     NUMBER,
                                         p_Status_Dt       IN     DATE,
                                         p_Code            IN     VARCHAR2,
                                         p_Message         IN     VARCHAR2,
                                         p_Decision_Dt     IN     DATE,
                                         p_Start_Dt        IN     DATE,
                                         p_Stop_Dt         IN     DATE,
                                         p_Aid_Sum         IN     NUMBER,
                                         p_Refuse_Reason   IN     VARCHAR2,
                                         p_Rn_Id           IN     NUMBER,
                                         p_Error_Code         OUT NUMBER,
                                         p_Error_Message      OUT VARCHAR2)
    IS
        l_Aps_Id                      NUMBER;
        l_Ap_Id                       NUMBER;
        l_Change_Ap_St                BOOLEAN;
        l_Ap_Is_Ext_Process           Appeal.Ap_Is_Ext_Process%TYPE;
        l_Ap_St_New                   Appeal.Ap_St%TYPE;
        l_Ap_St_Old                   Appeal.Ap_St%TYPE;
        l_Ap_St_Changed               BOOLEAN := FALSE;
        l_Hs                          NUMBER;
        l_Apl_Message                 Ap_Log.Apl_Message%TYPE;
        l_Apl_Tp                      Ap_Log.Apl_Tp%TYPE;
        c_Error_Not_Found    CONSTANT NUMBER := 1;
        c_Error_Unknown_St   CONSTANT NUMBER := 2;
        l_Diia_Msg                    VARCHAR2 (4000);
        l_Diia_Error                  VARCHAR2 (4000);
    BEGIN
        p_Error_Code := 0;
        l_Aps_Id := p_Aps_Id;

        SELECT MAX (s.Aps_Ap), MAX (a.Ap_St), MAX (a.Ap_Is_Ext_Process)
          INTO l_Ap_Id, l_Ap_St_Old, l_Ap_Is_Ext_Process
          FROM Ap_Service s JOIN Appeal a ON s.Aps_Ap = a.Ap_Id
         WHERE s.Aps_Id = l_Aps_Id;

        IF l_Ap_Id IS NULL
        THEN
            p_Error_Code := c_Error_Not_Found;
            p_Error_Message := 'Послуга з ІД ' || p_Aps_Id || ' не знайдена';
            RETURN;
        END IF;

        Save_Rn_Ap (p_Rn_Id => p_Rn_Id, p_Ap_Id => l_Ap_Id);

        IF l_Ap_Is_Ext_Process = 'F'
        THEN
            --Якщо обробка виконується на боці ЄІССС
            RETURN;
        END IF;

        IF p_Status IS NOT NULL
        THEN
            l_Ap_St_New :=
                Uss_Ndi.Tools.Decode_Dict (
                    p_Nddc_Tp         => 'AP_ST',
                    p_Nddc_Src        => Api$appeal.c_Src_Community,
                    p_Nddc_Dest       => Api$appeal.c_Src_Vst,
                    p_Nddc_Code_Src   => p_Status);

            IF l_Ap_St_New IS NULL
            THEN
                p_Error_Code := c_Error_Unknown_St;
                p_Error_Message := 'Невідомий статус ' || p_Status;
                RETURN;
            END IF;
        END IF;

        --Обробка зміни статуса в рамках пакету заяв ВПО
        IF Aps_Exists (l_Ap_Id, 664) AND Aps_Exists (l_Ap_Id, 781)
        THEN
            IF l_Ap_St_New = 'S'
            THEN
                --24102022: для звернень ВПО, що оброблюються на боці ЄІССС статус S не зберігаємо. Узгоджено з КЕВ
                --TODO: подумати щодо конфігурації
                RETURN;
            END IF;

            Handle_Pkg_Vpo_Status (p_Aps_Id         => l_Aps_Id,
                                   p_Status         => p_Status,
                                   p_Code           => p_Code,
                                   p_Message        => p_Message,
                                   p_Rn_Id          => p_Rn_Id,
                                   p_Change_Ap_St   => l_Change_Ap_St);

            IF NOT l_Change_Ap_St
            THEN
                RETURN;
            END IF;
        END IF;

        --Змінюємо статус звернення
        UPDATE Appeal a
           SET a.Ap_St = l_Ap_St_New
         WHERE a.Ap_Id = l_Ap_Id AND a.Ap_St <> l_Ap_St_New;

        l_Ap_St_Changed := SQL%ROWCOUNT > 0;

        --Визначаємо тип та вміст повідомлення для запису в журнал обробки зверення
        IF p_Code <> '0'
        THEN
            --Технічна помилка на боці Соцгромади
            l_Apl_Message := p_Message;
            l_Diia_Error := p_Message;
            l_Apl_Tp := Api$appeal.c_Apl_Tp_Terror;
        ELSIF l_Ap_St_Changed
        THEN
            --Зміна статусу в соцгромаді
            IF p_Status = '16'                                 --ПРИЗНАЧЕНО(V)
            THEN
                l_Apl_Message :=
                       CHR (38)
                    || 29
                    || '#'
                    || TO_CHAR (p_Decision_Dt, 'dd.mm.yyyy')
                    || '#'
                    || TO_CHAR (p_Start_Dt, 'dd.mm.yyyy')
                    || '#'
                    || TO_CHAR (p_Stop_Dt, 'dd.mm.yyyy')
                    || '#'
                    || TO_CHAR (p_Aid_Sum);

                --Змінюємо статус послуги
                UPDATE Ap_Service s
                   SET s.Aps_St = 'P'
                 WHERE s.Aps_Id = l_Aps_Id;

                --Створюємо документ "Рішення про призначення"
                Create_Decision_Doc (p_Ap_Id      => l_Ap_Id,
                                     p_Start_Dt   => p_Start_Dt,
                                     p_Stop_Dt    => p_Stop_Dt,
                                     p_Aid_Sum    => p_Aid_Sum);
            ELSIF p_Status = '17'                              --ВІДМОВЛЕНО(X)
            THEN
                l_Apl_Message :=
                       CHR (38)
                    || 30
                    || '#'
                    || TO_CHAR (p_Decision_Dt, 'dd.mm.yyyy')
                    || '#'
                    || p_Refuse_Reason;

                --Змінюємо статус послуги
                UPDATE Ap_Service s
                   SET s.Aps_St = 'V'
                 WHERE s.Aps_Id = l_Aps_Id;

                --Створюємо документ "Рішення про призначення"
                Create_Decision_Doc (p_Ap_Id           => l_Ap_Id,
                                     p_Refuse_Reason   => p_Refuse_Reason);

                l_Diia_Msg := p_Refuse_Reason;
            ELSIF p_Status = '14'                   --ОЧІКУВАННЯ ДОКУМЕНТІВ(W)
            THEN
                l_Apl_Message :=
                    RTRIM (p_Refuse_Reason, '.') || '. ' || p_Message;
                l_Diia_Msg := p_Refuse_Reason;
            ELSE
                l_Apl_Message := CHR (38) || 23 || '#@341@' || p_Status;
            END IF;

            l_Apl_Tp := Api$appeal.c_Apl_Tp_Sys;
        END IF;

        IF l_Ap_St_New IN ('W',
                           'X',
                           'V',
                           'P')
        THEN
            --Відправляємо в Дію запит про зміну статуса
            Reg_Diia_Status_Send_Req (
                p_Ap_Id         => l_Ap_Id,
                p_Ap_St         =>
                    CASE
                        WHEN l_Diia_Error IS NOT NULL OR l_Ap_St_New = 'P'
                        THEN
                            'error'
                        ELSE
                            l_Ap_St_New
                    END,
                p_Message       => l_Diia_Msg,
                p_Decision_Dt   => p_Decision_Dt,
                p_Start_Dt      => p_Start_Dt,
                p_Stop_Dt       => p_Stop_Dt,
                p_Sum           => p_Aid_Sum,
                p_Error         => l_Diia_Error);
        END IF;

        IF l_Apl_Message IS NULL
        THEN
            RETURN;
        END IF;

        INSERT INTO Histsession (Hs_Id, Hs_Wu, Hs_Dt)
             VALUES (0, NULL, NVL (p_Status_Dt, SYSDATE))
          RETURNING Hs_Id
               INTO l_Hs;

        --Створюємо запис в журналі
        --#73983 2021,12,09
        Api$appeal.Write_Log (
            p_Apl_Ap        => l_Ap_Id,
            p_Apl_Hs        => l_Hs,
            p_Apl_St        => NVL (l_Ap_St_New, l_Ap_St_Old),
            p_Apl_Message   => l_Apl_Message,
            p_Apl_St_Old    =>
                CASE
                    WHEN     l_Ap_St_New IS NOT NULL
                         AND l_Ap_St_New <> l_Ap_St_Old
                    THEN
                        l_Ap_St_Old
                END,
            p_Apl_Tp        => l_Apl_Tp);
    END;

    --------------------------------------------------------------------------
    --  Перекодування коду служби захисту дітей в ІД ОСЗН
    --------------------------------------------------------------------------
    FUNCTION Ssd2com_Org (p_Ssd_Code IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Com_Org   NUMBER;
    BEGIN
        SELECT MAX (s.Ncs_Org)
          INTO l_Com_Org
          FROM Uss_Ndi.v_Ndi_Children_Service s
         WHERE s.Ncs_Code = p_Ssd_Code;

        RETURN NVL (l_Com_Org, 50000);
    END;

    --------------------------------------------------------------------------
    --  Обробка запиту на зміну статуса звернення по усиновленню
    --------------------------------------------------------------------------
    PROCEDURE Save_Adopt_Status (p_Request IN CLOB)
    IS
        l_Ap_Id           Appeal.Ap_Id%TYPE;
        l_Ap_St           Appeal.Ap_St%TYPE;
        l_Ap_St_Dt        DATE;
        l_Message         VARCHAR2 (4000);
        l_Ap_St_Old       Appeal.Ap_St%TYPE;
        l_Is_Correct_St   NUMBER;
        l_Hs              NUMBER;
    BEGIN
        BEGIN
                 SELECT Ap_St,
                        TO_DATE (Ap_St_Dt, 'dd.mm.yyyy hh24:mi:ss'),
                        Ap_Id,
                        MESSAGE
                   INTO l_Ap_St,
                        l_Ap_St_Dt,
                        l_Ap_Id,
                        l_Message
                   FROM XMLTABLE (
                            '/*'
                            PASSING Xmltype (p_Request)
                            COLUMNS Ap_St       VARCHAR2 (10) PATH 'Ap_St',
                                    Ap_St_Dt    VARCHAR (30) PATH 'Ap_St_Dt',
                                    Ap_Id       NUMBER PATH 'Ap_Id',
                                    MESSAGE     VARCHAR2 (4000) PATH 'Message');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        SELECT MAX (a.Ap_St)
          INTO l_Ap_St_Old
          FROM Appeal a
         WHERE a.Ap_Id = l_Ap_Id AND a.Ap_Tp = 'ADOPT';

        IF l_Ap_St_Old IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'Звернення з ІД ' || l_Ap_Id || ' не знайдено');
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Is_Correct_St
          FROM Uss_Ndi.v_Ddn_Ap_St s
         WHERE s.Dic_Value = l_Ap_St;

        IF l_Is_Correct_St <> 1
        THEN
            Raise_Application_Error (
                -20000,
                'Некоректний статус звернення - ' || l_Ap_St);
        END IF;

        --Змінюємо статус звернення
        UPDATE Appeal a
           SET a.Ap_St = l_Ap_St
         WHERE a.Ap_Id = l_Ap_Id;

        --Відправляємо в Дію запит про зміну статуса
        Reg_Diia_Status_Send_Req (p_Ap_Id     => l_Ap_Id,
                                  p_Ap_St     => l_Ap_St,
                                  p_Message   => l_Message);

        INSERT INTO Histsession (Hs_Id, Hs_Wu, Hs_Dt)
             VALUES (0, NULL, NVL (l_Ap_St_Dt, SYSDATE))
          RETURNING Hs_Id
               INTO l_Hs;

        --Створюємо запис в журналі
        Api$appeal.Write_Log (p_Apl_Ap        => l_Ap_Id,
                              p_Apl_Hs        => l_Hs,
                              p_Apl_St        => l_Ap_St,
                              p_Apl_Message   => l_Message,
                              p_Apl_St_Old    => l_Ap_St_Old,
                              p_Apl_Tp        => Api$appeal.c_Apl_Tp_Sys);
    END;

    PROCEDURE Save_Vpo_Crt (p_Ap_Id IN NUMBER)
    IS
    BEGIN
        FOR Rec
            IN (SELECT p.App_Id
                  FROM Ap_Person p
                 WHERE     p.App_Ap = p_Ap_Id
                       AND p.History_Status = 'A'
                       AND NOT EXISTS
                               (SELECT NULL
                                  FROM Ap_Document d
                                 WHERE     d.Apd_App = p.App_Id
                                       AND d.Apd_Ndt =
                                           Api$appeal.c_Apd_Ndt_Vpo_Crt
                                       AND d.History_Status = 'A'))
        LOOP
            DECLARE
                l_Doc_Id   NUMBER;
                l_Dh_Id    NUMBER;
                l_Apd_Id   NUMBER;
            BEGIN
                --Зберігаємо документ та зріз в архів
                Uss_Doc.Api$documents.Save_Document (
                    p_Doc_Id          => NULL,
                    p_Doc_Ndt         => Api$appeal.c_Apd_Ndt_Vpo_Crt,
                    p_Doc_Actuality   => 'A',
                    p_New_Id          => l_Doc_Id);
                Uss_Doc.Api$documents.Save_Doc_Hist (
                    p_Dh_Id          => NULL,
                    p_Dh_Doc         => l_Doc_Id,
                    p_Dh_Sign_Alg    => NULL,
                    p_Dh_Ndt         => Api$appeal.c_Apd_Ndt_Vpo_Crt,
                    p_Dh_Sign_File   => NULL,
                    p_Dh_Actuality   => 'A',
                    p_Dh_Dt          => SYSDATE,
                    p_Dh_Wu          => Tools.Getcurrwu,
                    p_Dh_Src         => Api$appeal.c_Src_Vst,
                    p_New_Id         => l_Dh_Id);
                Api$appeal.Save_Document (
                    p_Apd_Id                => NULL,
                    p_Apd_Ap                => p_Ap_Id,
                    p_Apd_Ndt               => Api$appeal.c_Apd_Ndt_Vpo_Crt,
                    p_Apd_Doc               => l_Doc_Id,
                    p_Apd_Vf                => NULL,
                    p_Apd_App               => Rec.App_Id,
                    p_New_Id                => l_Apd_Id,
                    p_Com_Wu                => Tools.Getcurrwu,
                    p_Apd_Dh                => l_Dh_Id,
                    p_Apd_Aps               => NULL,
                    p_Apd_Tmp_To_Del_File   => NULL,
                    p_Apd_Src               => Api$appeal.c_Src_Vst);
            END;
        END LOOP;
    END;

    PROCEDURE Save_Adopt_Person_Info (p_Rn_Id          IN NUMBER,
                                      p_Request_Body   IN BLOB)
    IS
        l_Rnp_Id    NUMBER;
        l_Rnpi_Id   NUMBER;
    BEGIN
        FOR Rec
            IN (    SELECT *
                      FROM XMLTABLE (
                               '/*'
                               PASSING Xmltype (
                                           Tools.Convertb2c (p_Request_Body,
                                                             'utf8'))
                               COLUMNS LN         VARCHAR2 (255) PATH 'LastName',
                                       Fn         VARCHAR2 (255) PATH 'FirstName',
                                       Mn         VARCHAR2 (255) PATH 'MiddleName',
                                       Inn        VARCHAR2 (20) PATH 'Inn',
                                       Bdt        VARCHAR2 (30) PATH 'DateOfBirth',
                                       Doc_Num    VARCHAR2 (50) PATH 'DocumentNumber',
                                       Ndt        NUMBER PATH 'DocumentType'))
        LOOP
            IF Rec.LN IS NULL
            THEN
                Raise_Application_Error (c_Err_Code_Bad_Req,
                                         'Не вказано прізвище');
            END IF;

            IF Rec.Fn IS NULL
            THEN
                Raise_Application_Error (c_Err_Code_Bad_Req,
                                         'Не вказано ім`я');
            END IF;

            IF     Rec.Inn IS NULL
               AND (Rec.Ndt IS NULL OR Rec.Doc_Num IS NULL)
               AND Rec.Bdt IS NULL
            THEN
                IF Rec.Ndt IS NULL
                THEN
                    Raise_Application_Error (c_Err_Code_Bad_Req,
                                             'Не вказано тип документа');
                END IF;

                IF Rec.Doc_Num IS NULL
                THEN
                    Raise_Application_Error (c_Err_Code_Bad_Req,
                                             'Не вказано номер документа');
                END IF;

                IF Rec.Bdt IS NULL
                THEN
                    Raise_Application_Error (c_Err_Code_Bad_Req,
                                             'Не вказано дату народження');
                END IF;

                IF Rec.Inn IS NULL
                THEN
                    Raise_Application_Error (c_Err_Code_Bad_Req,
                                             'Не вказано РНОКПП');
                END IF;
            END IF;

            Ikis_Rbm.Api$request.Save_Rn_Person (
                p_Rnp_Id           => NULL,
                p_Rnp_Rn           => p_Rn_Id,
                p_Rnp_Sc           => NULL,
                p_Rnp_Inn          => Rec.Inn,
                p_Rnp_Ndt          => Rec.Ndt,
                p_Rnp_Doc_Seria    => NULL,
                p_Rnp_Doc_Number   => Rec.Doc_Num,
                p_Rnp_Sc_Unique    => NULL,
                p_New_Id           => l_Rnp_Id);

            Ikis_Rbm.Api$request.Save_Rnp_Identity_Info (
                p_Rnpi_Id    => NULL,
                p_Rnpi_Rnp   => l_Rnp_Id,
                p_Rnpi_Rn    => p_Rn_Id,
                p_Rnpi_Fn    => Rec.Fn,
                p_Rnpi_Ln    => Rec.LN,
                p_Rnpi_Mn    => Rec.Mn,
                p_New_Id     => l_Rnpi_Id);

            IF Rec.Bdt IS NOT NULL
            THEN
                Ikis_Rbm.Api$request.Save_Rn_Common_Info (
                    p_Rnc_Rn       => p_Rn_Id,
                    p_Rnc_Pt       => 87,
                    p_Rnc_Val_Dt   => TO_DATE (Rec.Bdt, 'dd.mm.yyyy'));
            END IF;

            RETURN;
        END LOOP;

        Raise_Application_Error (c_Err_Code_Bad_Req, 'Не вказано дані особи');
    END;

    FUNCTION Get_Diia_Task_Template_Id (p_Ap_Id NUMBER)
        RETURN NUMBER
    IS
        l_Task_Template_Id   NUMBER;
    BEGIN
        SELECT TO_NUMBER (MAX (Uss_Ndi.Tools.Decode_Dict (
                                   p_Nddc_Tp         => 'NST_ID',
                                   p_Nddc_Src        => 'VST',
                                   p_Nddc_Dest       => 'DIIA',
                                   p_Nddc_Code_Src   => Aps_Nst)))
          INTO l_Task_Template_Id
          FROM (SELECT MIN (s.Aps_Nst)     AS Aps_Nst
                  FROM Ap_Service s
                 WHERE s.Aps_Ap = p_Ap_Id AND s.History_Status = 'A');

        RETURN l_Task_Template_Id;
    END;

    --------------------------------------------------------------------------
    --  Реєстрація запиту на передачу статусу звернення до ДІЇ
    --------------------------------------------------------------------------
    PROCEDURE Reg_Diia_Status_Send_Req (
        p_Ap_Id         IN NUMBER,
        p_Ap_St         IN VARCHAR2,
        p_Message       IN VARCHAR2 DEFAULT NULL,
        p_Decision_Dt   IN DATE DEFAULT NULL,
        p_Start_Dt      IN DATE DEFAULT NULL,
        p_Stop_Dt       IN DATE DEFAULT NULL,
        p_Sum           IN NUMBER DEFAULT NULL,
        p_Error         IN VARCHAR2 DEFAULT NULL)
    IS
        l_Ap_Src                    Appeal.Ap_Src%TYPE;
        l_Ap_Vf                     NUMBER;
        l_Ur_Id                     NUMBER;
        l_Rn_Id                     NUMBER;
        c_Ur_Urt           CONSTANT NUMBER := 53;
        c_Rn_Nrt           CONSTANT NUMBER := 53;
        --Константи для параметрів запиту
        c_Pt_Ap_Vf         CONSTANT NUMBER := 310;
        c_Pt_Ap_St         CONSTANT NUMBER := 311;
        c_Pt_Message       CONSTANT NUMBER := 259;
        c_Pt_Decision_Dt   CONSTANT NUMBER := 94;
        c_Pt_Start_Dt      CONSTANT NUMBER := 90;
        c_Pt_Stop_Dt       CONSTANT NUMBER := 83;
        c_Pt_Sum           CONSTANT NUMBER := 268;
        c_Pt_Error         CONSTANT NUMBER := 242;

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
        SELECT a.Ap_Src, a.Ap_Vf
          INTO l_Ap_Src, l_Ap_Vf
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        IF l_Ap_Src <> Api$appeal.c_Src_Diia
        THEN
            RETURN;
        END IF;

        --Не надсилаємо запит в Дію, якщо не визначено task-template-id для послуги
        IF Get_Diia_Task_Template_Id (p_Ap_Id) IS NULL
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
        Add_Param (c_Pt_Decision_Dt, p_Val_Dt => p_Decision_Dt);
        Add_Param (c_Pt_Start_Dt, p_Val_Dt => p_Start_Dt);
        Add_Param (c_Pt_Stop_Dt, p_Val_Dt => p_Stop_Dt);
        Add_Param (
            c_Pt_Sum,
            p_Val_Str   =>
                TO_CHAR (p_Sum,
                         'FM9999999999999990D00',
                         'NLS_NUMERIC_CHARACTERS=''.,'''));
        Add_Param (c_Pt_Error, p_Val_Str => p_Error);

        Save_Rn_Ap (p_Rn_Id => l_Rn_Id, p_Ap_Id => p_Ap_Id);
    END;

    --------------------------------------------------------------------------
    -- Отримання даних для запиту на зміну статуса звернення в Дії
    --------------------------------------------------------------------------
    FUNCTION Get_Diia_Status_Send_Req (p_Ur_Id        IN     NUMBER,
                                       p_Url_Params      OUT VARCHAR2)
        RETURN CLOB
    IS
        --Константи для параметрів запиту
        c_Pt_Ap_Vf         CONSTANT NUMBER := 310;
        c_Pt_Ap_St         CONSTANT NUMBER := 311;
        c_Pt_Message       CONSTANT NUMBER := 259;
        c_Pt_Decision_Dt   CONSTANT NUMBER := 94;
        c_Pt_Start_Dt      CONSTANT NUMBER := 90;
        c_Pt_Stop_Dt       CONSTANT NUMBER := 83;
        c_Pt_Sum           CONSTANT NUMBER := 268;
        c_Pt_Error         CONSTANT NUMBER := 242;

        l_Ur                        Ikis_Rbm.v_Uxp_Request%ROWTYPE;
        l_Ap_Id                     Appeal.Ap_Id%TYPE;
        l_Ap_St                     Appeal.Ap_St%TYPE;
        l_Ap_Vf                     Appeal.Ap_Vf%TYPE;
        l_Message                   VARCHAR2 (4000);
        l_Ap_Ext_Ident              Appeal.Ap_Ext_Ident%TYPE;
        l_Req_Obj                   Json_Obj;
        l_Document                  Json_Obj;
        l_Ulr_Params                Json_Obj;

        PROCEDURE Add_Param (p_Param      VARCHAR2,
                             p_Val        VARCHAR2,
                             p_Add_Null   BOOLEAN DEFAULT FALSE)
        IS
        BEGIN
            IF p_Val IS NULL AND NOT p_Add_Null
            THEN
                RETURN;
            END IF;

            l_Document.Push (p_Param, p_Val);
        END;

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

        l_Ur := Ikis_Rbm.Api$uxp_Request.Get_vRequest (p_Ur_Id => p_Ur_Id);
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

        l_Document := NEW Json_Obj ();
        Add_Param ('status', l_Ap_St);
        Add_Param ('reason', l_Message, p_Add_Null => TRUE);
        Add_Param ('startDt',
                   TO_CHAR (Get_Val_Dt (c_Pt_Start_Dt), 'dd.mm.yyyy'));
        Add_Param ('stopDt',
                   TO_CHAR (Get_Val_Dt (c_Pt_Stop_Dt), 'dd.mm.yyyy'));
        Add_Param ('decisionDt',
                   TO_CHAR (Get_Val_Dt (c_Pt_Decision_Dt), 'dd.mm.yyyy'));
        Add_Param ('sum', Get_Val_Str (c_Pt_Sum));
        Add_Param ('error', Get_Val_Str (c_Pt_Error));
        l_Req_Obj := NEW Json_Obj ();
        l_Req_Obj.Push ('document', l_Document);

        SELECT a.Ap_Ext_Ident
          INTO l_Ap_Ext_Ident
          FROM Appeal a
         WHERE a.Ap_Id = l_Ap_Id;

        l_Ulr_Params := NEW Json_Obj ();
        l_Ulr_Params.Push ('workflow_id', l_Ap_Ext_Ident);
        l_Ulr_Params.Push ('task_template_id',
                           Get_Diia_Task_Template_Id (l_Ap_Id));
        p_Url_Params := l_Ulr_Params.TO_CLOB;

        RETURN l_Req_Obj.TO_CLOB;
    END;

    --------------------------------------------------------------------------
    -- Обробка відповіді на запит на зміну статуса звернення в Дії
    --------------------------------------------------------------------------
    PROCEDURE Handle_Diia_Status_Send_Req (p_Ur_Id      IN     NUMBER,
                                           p_Response   IN     CLOB,
                                           p_Error      IN OUT VARCHAR2)
    IS
        l_Response   r_Diia_Response;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            BEGIN
                EXECUTE IMMEDIATE Type2jsontable (
                                     p_Pkg_Name    => Package_Name,
                                     p_Type_Name   => 'R_DIIA_RESPONSE')
                    USING IN p_Response, OUT l_Response;

                p_Error := l_Response.Error.MESSAGE;

                IF p_Error IS NOT NULL
                THEN
                    Write_Error (
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
END Dnet$appeal_Ext;
/