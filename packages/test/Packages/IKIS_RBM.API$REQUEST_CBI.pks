/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_CBI
IS
    -- Author  : SHOSTAK
    -- Created : 24.03.2023 2:32:03 PM
    -- Purpose : Запити до ЦБІ

    Package_Name    CONSTANT VARCHAR2 (50) := 'API$REQUEST_CBI';

    c_Pt_Start_Dt   CONSTANT NUMBER := 80;
    c_Pt_Stop_Dt    CONSTANT NUMBER := 83;

    TYPE r_Prosthetic IS RECORD
    (
        Ar_Id             NUMBER,
        Ar_Wr             VARCHAR2 (250),
        Ar_Date           DATE,
        Ar_Issue_Date     DATE,
        Ar_End_Expl_Dt    DATE
    );

    TYPE t_Prosthetic_List IS TABLE OF r_Prosthetic;

    TYPE r_Car IS RECORD
    (
        Ap_Id           NUMBER,
        Ap_Start_Dt     DATE,
        Ap_Qt           VARCHAR2 (100),
        Ap_Number       VARCHAR2 (50),
        Ap_Iss_Date     DATE,
        Ap_Cancel_Dt    DATE
    );

    TYPE t_Car_List IS TABLE OF r_Car;

    TYPE r_Voucher IS RECORD
    (
        Asr_Id                     NUMBER, --todo: уточнити по назві тегу(в протоколі написано Ar_Id)
        Asr_Date                   DATE,
        Asr_Number                 VARCHAR2 (25),
        Asr_Place                  VARCHAR2 (250),
        Asr_Season                 VARCHAR2 (10),
        Asr_Pfl_Id                 VARCHAR2 (250),
        Asr_Ag_Id_Code             VARCHAR2 (10),
        Asr_Ag_Id_Sanatorium       VARCHAR2 (250),
        Asr_Arrival_Date           DATE,
        Asr_Departure_Date         DATE,
        Asr_Price                  VARCHAR2 (14),
        Asr_Arrival_Fact_Date      DATE,
        Asr_Departure_Fact_Date    DATE,
        Asr_Fact_Price             VARCHAR2 (14),
        Asr_Renounce_Date          DATE,
        Asr_Renounce_Reason        VARCHAR2 (250),
        Asr_Rejection_Date         DATE
    );

    TYPE t_Voucher_List IS TABLE OF r_Voucher;

    TYPE r_Cbi_Info IS RECORD
    (
        Reg_Id_Cbi             NUMBER,
        Rnokpp                 VARCHAR2 (100),
        Ozn_Doc                VARCHAR2 (1),
        Sn_Doc                 VARCHAR2 (100),
        Num_Doc                VARCHAR2 (100),
        Full_Name              VARCHAR2 (250),
        First_Name             VARCHAR2 (250),
        Second_Name            VARCHAR2 (250),
        Birth_Date             DATE,
        Sex                    NUMBER,
        Disabled_Tp            NUMBER,
        Disabled_Number        VARCHAR2 (100),
        Disabled_Date          DATE,
        Disabled_Gr            VARCHAR2 (20),
        Disabled_Pgr           VARCHAR2 (10),
        Cod_Disabled_Cat       VARCHAR2 (20),
        Disabled_Cat           VARCHAR2 (4000),
        Disabled_Type          VARCHAR2 (1),
        Disabled_Date_Begin    DATE,
        Disabled_Date_End      DATE,
        Status_Capacity        VARCHAR2 (25),
        Cnt_Phone              VARCHAR2 (50),
        Adr_Sm                 VARCHAR2 (19),
        Adr_Kt                 VARCHAR2 (19),
        Adr_Full               VARCHAR2 (250),
        Rsun_Name              VARCHAR2 (250),
        Rsun_Date              DATE,
        Nm_Is_Homeless         NUMBER,
        Ain_Pit_Cod            NUMBER,
        Ain_Pit_Name           VARCHAR2 (250),
        Amt_At                 VARCHAR2 (1),
        Prosthetics            t_Prosthetic_List,
        Cars                   t_Car_List,
        Voucheres              t_Voucher_List
    );

    TYPE t_Cbi_Info IS TABLE OF r_Cbi_Info;

    TYPE r_Address IS RECORD
    (
        Post_Index    VARCHAR2 (10),
        Katottg       VARCHAR2 (50),
        Street        VARCHAR2 (4000),
        House         VARCHAR2 (10),
        BLOCK         VARCHAR2 (10),
        Appartment    VARCHAR2 (10)
    );

    TYPE r_Rehab_Ware IS RECORD
    (
        Ware_Id_Uss    NUMBER,
        Ware_Id_Cbi    NUMBER,
        Ware_Iso       VARCHAR2 (100),
        Ware_Name      VARCHAR2 (4000)
    );

    TYPE t_Rehab_Wares IS TABLE OF r_Rehab_Ware;

    TYPE r_Identity_Doc IS RECORD
    (
        Type_         VARCHAR2 (10),
        Seria         VARCHAR2 (10),
        Number_       VARCHAR2 (50),
        Issue_Date    DATE,
        Issue_Org     VARCHAR2 (4000)
    );

    TYPE r_Auth_Person IS RECORD
    (
        Auth_Last_Name      VARCHAR2 (100),
        Auth_First_Name     VARCHAR2 (100),
        Auth_Second_Name    VARCHAR2 (100),
        Auth_Numident       VARCHAR2 (60)
    );

    TYPE r_File IS RECORD
    (
        File_Name       VARCHAR2 (250),
        File_Type       VARCHAR2 (100),                             --MIMETYPE
        File_Content    VARCHAR2 (100) --Код файлу(потім на боці сервісу замінюється вмістом файлу)
    );

    TYPE t_Files IS TABLE OF r_File;

    TYPE r_Add_Diagnosis IS RECORD
    (
        Add_Diagnosis    VARCHAR2 (20)
    );

    TYPE t_Add_Diagnoses IS TABLE OF r_Add_Diagnosis;

    TYPE r_Disability_Org IS RECORD
    (
        Org_Name          VARCHAR2 (250),
        Org_Id            VARCHAR2 (100),
        KATOTTG           VARCHAR2 (20),
        Region_Name       VARCHAR2 (250),
        District_Name     VARCHAR2 (250),
        Community_Name    VARCHAR2 (250),
        City_Name         VARCHAR2 (250),
        Street_Name       VARCHAR2 (250),
        Building          VARCHAR2 (100),
        Room              VARCHAR2 (50),
        Post_Code         VARCHAR2 (6)
    );

    TYPE r_Disability IS RECORD
    (
        Decision_Num              VARCHAR2 (100),
        Decision_Dt               DATE,
        Eval_Dt                   DATE,
        Start_Dt                  DATE,
        Group_                    VARCHAR2 (10),
        Sub_Group                 VARCHAR2 (10),
        Is_Endless                VARCHAR2 (10),
        End_Dt                    DATE,
        Loss_Prof_Ability_Perc    VARCHAR2 (23),
        Main_Diagnosis            VARCHAR2 (4000),
        Add_Diagnoses             t_Add_Diagnoses,
        Reason                    VARCHAR2 (20),
        Org_Data                  r_Disability_Org
    );

    TYPE r_Need_Req IS RECORD
    (
        Req_Id            NUMBER,
        Pers_Id           NUMBER,
        Req_Number        VARCHAR2 (50),
        Req_Date          DATE,
        Src               VARCHAR2 (10),
        Fond_Code         VARCHAR2 (10),
        Numident          VARCHAR2 (10),
        Numident_Check    VARCHAR2 (10),
        Last_Name         VARCHAR2 (100),
        First_Name        VARCHAR2 (100),
        Second_Name       VARCHAR2 (100),
        Birth_Date        DATE,
        Sex               VARCHAR2 (10),
        Pers_State        NUMBER,
        Phone             VARCHAR2 (50),
        Email             VARCHAR2 (100),
        Address_Check     VARCHAR2 (10),
        Actual_Address    r_Address,
        Passport          r_Identity_Doc,
        Auth_Person       r_Auth_Person,
        Wares             t_Rehab_Wares,
        Files             t_Files,
        Disability        r_Disability
    );

    TYPE r_Need_Resp IS RECORD
    (
        Id             NUMBER,
        Result_Code    NUMBER
    );

    TYPE r_Wares_Status_Req IS RECORD
    (
        Ware_Id_Uss        NUMBER,                            --ІД ДЗР в ЄІССС
        Ware_Id_Cbi        NUMBER,                              --ІД ДЗР в ЦБІ
        Cbi_Date           DATE,                            --Дата події в ЦБІ
        Status             VARCHAR2 (10),                   --Статус ДЗР в ЦБІ
        Reject_Reason      VARCHAR2 (4000),                  --Причина відмови
        Ref_Num            VARCHAR2 (100),                 --Номер направлення
        Ref_Dt             DATE,                     --Дата видачі направлення
        Ref_Exp_Dt         DATE,                 --Дата закінчення направлення
        Ware_Issue_Dt      DATE,                             --Дата видачі ДЗР
        Ware_End_Exp_Dt    DATE               --Закінчення строку експлуатації
    );

    PROCEDURE Reg_Delta_Request (
        p_Start_Dt    IN     DATE,
        p_Stop_Dt     IN     DATE,
        p_Plan_Dt     IN     DATE,
        p_Rn_Nrt      IN     Request_Journal.Rn_Nrt%TYPE,
        p_Rn_Hs_Ins   IN     Request_Journal.Rn_Hs_Ins%TYPE,
        p_Rn_Src      IN     Request_Journal.Rn_Src%TYPE,
        p_Rn_Id          OUT Request_Journal.Rn_Id%TYPE);

    FUNCTION Get_Delta_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    FUNCTION Parse_Delta_Resp (p_Response IN OUT NOCOPY CLOB)
        RETURN t_Cbi_Info;

    FUNCTION Parse_Delta_Xml (p_Result_Data IN CLOB)
        RETURN t_Cbi_Info;

    /*
    info:    Побудова запиту на передачу заяви на отримання ДЗР до ЦБІ
    author:  sho
    request: #112501
    */
    FUNCTION Build_Need_Req (p_Need_Req IN OUT NOCOPY r_Need_Req)
        RETURN CLOB;

    /*
    info:    Парсинг відповіді на запит на передачу заяви на отримання ДЗР до ЦБІ
    author:  sho
    request: #112501
    */
    FUNCTION Parse_Need_Resp (p_Response IN CLOB)
        RETURN r_Need_Resp;

    /*
    info:    Парсинг запиту від ЦБІ, щодо факту наявності у особи засбів ДЗР
    author:  sho
    request: 112502
    */
    FUNCTION Parse_Wares_Req (p_Request IN CLOB)
        RETURN r_Need_Req;

    /*
    info:    Парсинг запиту на зміну статуса ДЗР по особі
    author:  sho
    */
    FUNCTION Parse_Wares_Status_Req (p_Request IN CLOB)
        RETURN r_Wares_Status_Req;
END Api$request_Cbi;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_CBI TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_CBI TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_CBI TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_CBI TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_CBI TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_CBI TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_CBI TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_CBI TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_CBI
IS
    -----------------------------------------------------------------------------
    --    Реєстрація запиту на отримання дельти ЦБІ
    -----------------------------------------------------------------------------
    PROCEDURE Reg_Delta_Request (
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

    -----------------------------------------------------------------------------
    --    Отримання даних для запиту на отримання дельти ЦБІ
    -----------------------------------------------------------------------------
    FUNCTION Get_Delta_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn      NUMBER;
        l_Start_Dt   DATE;
        l_Stop_Dt    DATE;
        l_Request    XMLTYPE;
    BEGIN
        l_Ur_Rn := Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);
        l_Start_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Start_Dt);
        l_Stop_Dt :=
            Api$request.Get_Rn_Common_Info_Dt (p_Rnc_Rn   => l_Ur_Rn,
                                               p_Rnc_Pt   => c_Pt_Stop_Dt);

        --todo: уточнити щодо неймспейсів
        SELECT XMLELEMENT (
                   "Disability_Request",
                   Xmlattributes ('http://tempuri.org/' AS "xmlns"),
                   XMLELEMENT ("EndDate", TO_CHAR (l_Stop_Dt, 'yyyy-mm-dd')),
                   XMLELEMENT ("RequestDate",
                               TO_CHAR (l_Start_Dt, 'yyyy-mm-dd')))
          INTO l_Request
          FROM DUAL;

        RETURN l_Request.Getclobval;
    END;

    -----------------------------------------------------------------------------
    --       Парсинг відповіді на запит на отримання дельти ЦБІ
    -----------------------------------------------------------------------------
    FUNCTION Parse_Delta_Resp (p_Response IN OUT NOCOPY CLOB)
        RETURN t_Cbi_Info
    IS
        l_Resp          t_Cbi_Info;
        l_Result_Data   CLOB;
    BEGIN
                --todo: з'ясувати чи буде b64?
                SELECT Ikis_Rbm.Tools.B64_Decode (Result_Data)
                  INTO l_Result_Data
                  FROM XMLTABLE (Xmlnamespaces (DEFAULT 'http://tempuri.org/'),
                                 '/*'
                                 PASSING Xmltype (p_Response)
                                 COLUMNS Result_Data    CLOB PATH 'ResultData');

        IF     l_Result_Data IS NOT NULL
           AND DBMS_LOB.Getlength (l_Result_Data) > 0
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'T_CBI_INFO',
                                             'dd.mm.yyyy')
                USING IN l_Result_Data, OUT l_Resp;
        END IF;

        RETURN l_Resp;
    END;

    FUNCTION Parse_Delta_Xml (p_Result_Data IN CLOB)
        RETURN t_Cbi_Info
    IS
        l_Resp   t_Cbi_Info;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         'T_CBI_INFO',
                                         'dd.mm.yyyy')
            USING IN p_Result_Data, OUT l_Resp;

        RETURN l_Resp;
    END;

    /*
    info:    Побудова запиту на передачу заяви на отримання ДЗР до ЦБІ
    author:  sho
    request: #112501
    */
    FUNCTION Build_Need_Req (p_Need_Req IN OUT NOCOPY r_Need_Req)
        RETURN CLOB
    IS
        l_Req   CLOB;
    BEGIN
        EXECUTE IMMEDIATE Type2json (Package_Name,
                                     'R_NEED_REQ',
                                     'yyyy-mm-dd',
                                     'lowerCamel',
                                     p_Version   => '2025-02-19')
            USING IN p_Need_Req, OUT l_Req;

        RETURN l_Req;
    END;

    /*
    info:    Парсинг відповіді на запит на передачу заяви на отримання ДЗР до ЦБІ
    author:  sho
    request: #112501
    */
    FUNCTION Parse_Need_Resp (p_Response IN CLOB)
        RETURN r_Need_Resp
    IS
        l_Resp   r_Need_Resp;
    BEGIN
        EXECUTE IMMEDIATE Type2jsontable (Package_Name, 'R_NEED_RESP')
            USING IN p_Response, OUT l_Resp;

        RETURN l_Resp;
    END;

    /*
    info:    Парсинг запиту від ЦБІ, щодо факту наявності у особи засбів ДЗР
    author:  sho
    request: 112502
    */
    FUNCTION Parse_Wares_Req (p_Request IN CLOB)
        RETURN r_Need_Req
    IS
        l_Req   r_Need_Req;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (
                             p_Pkg_Name    => Package_Name,
                             p_Type_Name   => 'R_NEED_REQ',
                             p_Date_Fmt    => 'dd.mm.yyyy hh24:mi:ss')
            USING IN p_Request, OUT l_Req;

        RETURN l_Req;
    END;

    /*
    info:    Парсинг запиту на зміну статуса ДЗР по особі
    author:  sho
    */
    FUNCTION Parse_Wares_Status_Req (p_Request IN CLOB)
        RETURN r_Wares_Status_Req
    IS
        l_Req   r_Wares_Status_Req;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (
                             p_Pkg_Name    => Package_Name,
                             p_Type_Name   => 'R_WARES_STATUS_REQ',
                             p_Date_Fmt    => 'dd.mm.yyyy hh24:mi:ss')
            USING IN p_Request, OUT l_Req;

        RETURN l_Req;
    END;
END Api$request_Cbi;
/