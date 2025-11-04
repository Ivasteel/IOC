/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.Dnet$exch_Uss2ikis
IS
    -- Author  : SHOSTAK
    -- Created : 23.05.2022 3:51:22 PM
    -- Purpose :

    c_Nrt_Search_Person   CONSTANT NUMBER := 24;

    c_Src_Rzo             CONSTANT NUMBER := '13';
    c_Src_Queue           CONSTANT VARCHAR2 (10) := '14';
    c_Src_Pfu             CONSTANT VARCHAR2 (10) := '41'; --USS_NDI.V_DDN_SOURCE.DIC_CODE=41

    c_Ndt_Ppp             CONSTANT NUMBER := 601;
    c_Ndt_Epp             CONSTANT NUMBER := 602;

    c_St_Vf_Rq            CONSTANT VARCHAR2 (10) := 'VR'; -- Потребує верифікації
    c_St_Vf_Wk            CONSTANT VARCHAR2 (10) := 'VW'; -- Виконується верифікація
    c_St_Vf_Ok            CONSTANT VARCHAR2 (10) := 'VO'; -- Успішна верифікація
    c_St_Vf_Er            CONSTANT VARCHAR2 (10) := 'VE'; -- Неуспішна верифікація

    c_Decode_Src_Rzo      CONSTANT VARCHAR2 (10) := 'RZO';
    c_Decode_Src_Vst      CONSTANT VARCHAR2 (10) := 'VST';

    Package_Name          CONSTANT VARCHAR2 (100) := 'DNET$EXCH_USS2IKIS';

    TYPE r_Doc_Attr IS RECORD
    (
        Nda_Id     NUMBER,
        Val_Str    VARCHAR2 (500),
        Val_Dt     DATE,
        Val_Int    NUMBER
    );

    TYPE t_Doc_Attrs IS TABLE OF r_Doc_Attr;

    TYPE r_Doc_File IS RECORD
    (
        File_Code            VARCHAR2 (50),
        File_Name            VARCHAR2 (255),
        File_Content_Type    VARCHAR2 (255),
        File_Hash            VARCHAR2 (59),
        File_Size            NUMBER
    );

    TYPE t_Doc_Files IS TABLE OF r_Doc_File;

    TYPE r_Document IS RECORD
    (
        Doc_Ndt       NUMBER,
        Doc_Sign      CLOB,
        Attributes    t_Doc_Attrs,
        Files         t_Doc_Files
    );

    TYPE t_Docs IS TABLE OF r_Document;

    TYPE r_General IS RECORD
    (
        Ip_Unique    VARCHAR2 (10),
        Ip_Pt        NUMBER (1),
        LN           VARCHAR2 (200),
        Fn           VARCHAR2 (200),
        Mn           VARCHAR2 (200),
        Unzr         VARCHAR2 (100),
        Numident     NUMBER (20),
        Doc_Tp       NUMBER (14),
        Doc_Sn       VARCHAR2 (100),
        Nt           NUMBER (1),
        Sex          NUMBER (1),
        Birthday     DATE,
        Dd_Dt        DATE
    );

    TYPE r_Contacts IS RECORD
    (
        Phone_Mob    VARCHAR2 (100),
        Phone        VARCHAR2 (100),
        e_Mail       VARCHAR2 (100)
    );

    TYPE r_Address IS RECORD
    (
        Addr_Tp      VARCHAR2 (10),
        Kt_Code      VARCHAR2 (100),
        Country      VARCHAR2 (250),
        Region       VARCHAR2 (250),
        District     VARCHAR2 (250),
        Postcode     VARCHAR2 (10),
        City         VARCHAR2 (250),
        Street       VARCHAR2 (250),
        Street_Id    NUMBER (10),
        Building     VARCHAR2 (50),
        Block_       VARCHAR2 (50),
        Apartment    VARCHAR2 (50),
        Note         VARCHAR2 (250)
    );

    TYPE t_Address IS TABLE OF r_Address;

    TYPE r_Feature IS RECORD
    (
        Is_Pension     VARCHAR2 (10),
        Is_Jobless     VARCHAR2 (10),
        Is_Accident    VARCHAR2 (10)
    );

    TYPE r_Pension IS RECORD
    (
        Pens_Tp     NUMBER,
        Begin_Dt    DATE,
        End_Dt      DATE,
        Sum_        NUMBER,
        Number_     VARCHAR2 (20),
        Opfu        NUMBER,
        Pay_Tp      NUMBER,
        Psn         NUMBER
    );

    TYPE r_Person_Info IS RECORD
    (
        General     r_General,
        Contacts    r_Contacts,
        Address     t_Address,
        Feature     r_Feature,
        Pension     r_Pension
    );

    TYPE r_Save_Person_Data_Req IS RECORD
    (
        Person_Info    r_Person_Info,
        Documents      t_Docs
    );

    TYPE r_Doc_Deactivate_Req IS RECORD
    (
        Ip_Unique    VARCHAR2 (100),
        Doc_Ndt      NUMBER,
        Doc_Num      VARCHAR2 (50)
    );

    --Income dsv
    TYPE r_Person_Main IS RECORD
    (
        Kss           VARCHAR2 (10),
        Lastname      VARCHAR2 (250),
        Firstname     VARCHAR2 (250),
        Secondname    VARCHAR2 (250),
        Birthdt       DATE
    );

    TYPE r_Personidentifydoc IS RECORD
    (
        Rn            NUMBER,
        Ceadoctype    NUMBER,
        Serialnum     VARCHAR2 (250)
    );

    TYPE r_Requestperiod IS RECORD
    (
        Startdt    DATE,
        Stopdt     DATE
    );

    TYPE t_Personidentifydocs IS TABLE OF r_Personidentifydoc;

    TYPE r_Income_Dsv_Req IS RECORD
    (
        Person                r_Person_Main,
        Personidentifydocs    t_Personidentifydocs,
        Requestperiod         r_Requestperiod
    );

    TYPE r_Income IS RECORD
    (
        Startdt    DATE,
        Stopdt     DATE,
        Paycode    NUMBER (14),
        Sum_Val    NUMBER (18, 2)
    );

    TYPE t_Incomes IS TABLE OF r_Income;

    --категорії пільг особи
    TYPE r_Benefit_Cat IS RECORD
    (
        Catcode           VARCHAR2 (10),
        Catfromdt         DATE,
        Cattilldt         DATE,
        Incomesdt         DATE,
        Incomesbenefit    NUMBER (1),
        Aprovedocs        t_Docs
    );

    TYPE t_Benefit_Cats IS TABLE OF r_Benefit_Cat;

    TYPE r_Family_Person_Info IS RECORD
    (
        Relationtp     NUMBER (1),
        Submitter      VARCHAR2 (10),
        Address        t_Address,
        Person_Info    r_Person_Info
    );

    TYPE t_Family_Info IS TABLE OF r_Family_Person_Info;

    --категорії пільг особи
    TYPE r_Save_Person_Benefit_Cats_Req IS RECORD
    (
        Person_Info    r_Person_Info,
        Documents      t_Docs,
        Address        t_Address,
        Benefitcats    t_Benefit_Cats, -- 02/04/2024 serhii: Person_Benefit_Cats_Info renamed to BenefitCats by #95404
        Familyinfo     t_Family_Info
    );

    g_Sc_Id                        NUMBER;
    g_Is_Temp_Error                BOOLEAN;

    PROCEDURE Reg_Search_Person_Req (p_Numident   IN     VARCHAR2,
                                     p_Ln         IN     VARCHAR2,
                                     p_Fn         IN     VARCHAR2,
                                     p_Mn         IN     VARCHAR2,
                                     p_Doc_Tp     IN     NUMBER,
                                     p_Doc_Num    IN     VARCHAR2,
                                     p_Gender     IN     VARCHAR2,
                                     p_Wu_Id      IN     NUMBER,
                                     p_Src        IN     VARCHAR2,
                                     p_Rn_Id         OUT NUMBER);

    PROCEDURE Handle_Search_Person_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2);

    PROCEDURE Save_Person_Info (p_Ur_Id         IN     NUMBER,
                                p_Person_Info   IN     XMLTYPE,
                                p_Sc_Id            OUT NUMBER,
                                p_Is_New           OUT BOOLEAN);

    PROCEDURE Save_Person_Contact (p_Contact IN XMLTYPE, p_Sct_Id OUT NUMBER);

    PROCEDURE Save_Person_Addresses (p_Sc_Id              NUMBER,
                                     p_Addresses   IN     XMLTYPE,
                                     p_Scc_Sca        OUT NUMBER,
                                     p_Scb_Sca        OUT NUMBER);

    PROCEDURE Save_Person_Feature (p_Sc_Id IN NUMBER, p_Feature IN XMLTYPE);

    PROCEDURE Save_Pension (p_Sc_Id     IN     NUMBER,
                            p_Pension   IN     XMLTYPE,
                            p_Scp_Id       OUT VARCHAR2);

    PROCEDURE Save_Documents (p_Sc_Id         IN NUMBER,
                              p_Docs          IN t_Docs,
                              p_Invalid_Ipn   IN BOOLEAN DEFAULT FALSE);

    PROCEDURE Save_Doc_Attributes (p_Dh_Id IN NUMBER, p_Attrs t_Doc_Attrs);

    PROCEDURE Save_Doc_Attachments (p_Dh_Id   IN NUMBER,
                                    p_Files   IN t_Doc_Files);

    PROCEDURE Get_Person_Search_Result (p_Rn_Id     IN     NUMBER,
                                        p_Rn_St        OUT VARCHAR2,
                                        p_Esr_Num      OUT VARCHAR2);

    --проставити дату початку/закінчення дії пільг(Sc_Benefit_Category/Sc_Benefit_Type) на підставі документів
    PROCEDURE Set_Sc_Benefit_Stop_Dt (
        p_Scbc_Id   IN Sc_Benefit_Category.Scbc_Id%TYPE);

    FUNCTION Handle_Save_Pp_Req (p_Request_Id     IN NUMBER,
                                 p_Request_Body   IN CLOB)
        RETURN CLOB;

    FUNCTION Handle_Destroy_Pp_Req (p_Request_Id     IN NUMBER,
                                    p_Request_Body   IN CLOB)
        RETURN CLOB;

    /*
    info:    Отримання відповіді на запит по доходам для однієї особи
    author:  sho/lev
    request: #100296
    */
    FUNCTION Get_Incomes_Row (p_Row_Id IN NUMBER, p_Request IN XMLTYPE)
        RETURN XMLTYPE;

    FUNCTION Handle_Get_Incomes_Req (p_Ur_Id IN NUMBER,               --ignore
                                                        p_Request IN CLOB)
        RETURN CLOB;

    -- info:   отримання документів що підтверджують пільгову категорію учасника звернення
    -- params: p_scbc_id - ідентифікатор запису по пільговій категорії
    -- note:
    FUNCTION Get_Person_Benefit_Cat_Docs (
        p_Scbc_Id   Sc_Benefit_Docs.Scbd_Scbc%TYPE)
        RETURN XMLTYPE;

    FUNCTION Get_Person_Benefit_Cat_Data (
        p_Scbc_Id   Sc_Benefit_Docs.Scbd_Scbc%TYPE)
        RETURN XMLTYPE;

    FUNCTION Handle_Get_Benefit_Cat_Req (p_Request_Id     IN NUMBER,
                                         p_Request_Body   IN CLOB)
        RETURN CLOB;

    FUNCTION Handle_Put_Benefit_Cat_Req (p_Request_Id     IN NUMBER,
                                         p_Request_Body   IN CLOB)
        RETURN CLOB;

    PROCEDURE Run_Get_Avg_Month_Income;

    PROCEDURE Register_Get_Avg_Month_Income (
        p_Scpp_List   IN OWA_UTIL.Num_Arr,
        p_Start_Dt    IN DATE,
        p_Stop_Dt     IN DATE);

    FUNCTION Handle_Put_Avg_Month_Income_Req (p_Ur_Id     IN NUMBER,  --ignore
                                              p_Request   IN CLOB)
        RETURN CLOB;

    -- Обробка запиту від ПФУ на збереження інформації по призначенню виплат в ПФУ
    FUNCTION Handle_Save_Pc_Decision (p_Request_Id     IN NUMBER,
                                      p_Request_Body   IN CLOB)
        RETURN CLOB;

    -- Обробка запиту від ПФУ на збереження інформації по довіднику ikis_ndi.ndi_payment_type_request
    FUNCTION Handle_Save_Ndi_Payment_Type_Request (p_Request_Id     IN NUMBER,
                                                   p_Request_Body   IN CLOB)
        RETURN CLOB;

    -- Обробка запиту від ПФУ на збереження розшифровки даних по виплатам по рішенням
    FUNCTION Handle_Save_Payment_Sum_Request (p_Request_Id     IN NUMBER,
                                              p_Request_Body   IN CLOB)
        RETURN CLOB;

    FUNCTION Handle_Put_Subsidy_Benefit_Req (p_Ur_Id     IN NUMBER,
                                             p_Request   IN CLOB)
        RETURN CLOB;

    FUNCTION Handle_Put_Accrual_Req (p_Ur_Id IN NUMBER, p_Request IN CLOB)
        RETURN CLOB;

    FUNCTION Handle_Put_Payroll_Req (p_Ur_Id IN NUMBER, p_Request IN CLOB)
        RETURN CLOB;

    FUNCTION Handle_Put_Suspended_Decision_Req (p_Ur_Id     IN NUMBER,
                                                p_Request   IN CLOB)
        RETURN CLOB;

    FUNCTION Save_Benefit_Cat_Pre_Vf (
        p_Benefit_Cat   IN r_Benefit_Cat,
        p_Scdi_Id       IN Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
        p_Src           IN VARCHAR2 DEFAULT c_Src_Pfu)
        RETURN Sc_Benefit_Category%ROWTYPE;

    FUNCTION Save_Sc_Scpp_Family (
        p_Family_Prs   r_Family_Person_Info,
        p_Scdi_Id      Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
        p_Un_Id        NUMBER)
        RETURN NUMBER;
END Dnet$exch_Uss2ikis;
/


GRANT EXECUTE ON USS_PERSON.DNET$EXCH_USS2IKIS TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.DNET$EXCH_USS2IKIS TO II01RC_USS_PERSON_SVC
/

GRANT EXECUTE ON USS_PERSON.DNET$EXCH_USS2IKIS TO IKIS_RBM
/

GRANT EXECUTE ON USS_PERSON.DNET$EXCH_USS2IKIS TO SERVICE_PROXY
/

GRANT EXECUTE ON USS_PERSON.DNET$EXCH_USS2IKIS TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.DNET$EXCH_USS2IKIS TO USS_EXCH
/

GRANT EXECUTE ON USS_PERSON.DNET$EXCH_USS2IKIS TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.DNET$EXCH_USS2IKIS TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.DNET$EXCH_USS2IKIS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:57:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.Dnet$exch_Uss2ikis
IS
    FUNCTION To_Money (p_Str VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (REPLACE (p_Str, ',', '.'),
                          '9999999999D99999',
                          'NLS_NUMERIC_CHARACTERS=''.,''');
    END;

    --=============================================================================
    --                         ОБРОБКА ДОКУМЕНТІВ
    --=============================================================================
    FUNCTION Parse_Documents (p_Docs_Xml IN CLOB)
        RETURN t_Docs
    IS
        l_Docs   t_Docs;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (Package_Name, 'T_DOCS')
            USING IN p_Docs_Xml, OUT l_Docs;

        RETURN l_Docs;
    END;

    FUNCTION Is_Doc_Attrs_Modified (p_Dh_Id       IN NUMBER,
                                    p_Doc_Attrs      t_Doc_Attrs)
        RETURN BOOLEAN
    IS
        l_Is_Modified   NUMBER;
    BEGIN
        WITH
            Old_Attrs
            AS
                (SELECT a.*
                   FROM Uss_Doc.v_Doc_Attr2hist  h
                        JOIN Uss_Doc.v_Doc_Attributes a
                            ON h.Da2h_Da = a.Da_Id
                  WHERE h.Da2h_Dh = p_Dh_Id)
        SELECT MAX (
                   CASE
                       WHEN    o.Da_Nda IS NULL
                            OR NVL (n.Val_Int, -9999999999) <>
                               NVL (o.Da_Val_Int, -9999999999)
                            OR NVL (n.Val_Str, '###') <>
                               NVL (o.Da_Val_String, '###')
                            OR NVL (n.Val_Dt,
                                    TO_DATE ('01.01.1000', 'dd.mm.yyyy')) <>
                               NVL (o.Da_Val_Dt,
                                    TO_DATE ('01.01.1000', 'dd.mm.yyyy'))
                       THEN
                           1
                       ELSE
                           0
                   END)
          INTO l_Is_Modified
          FROM TABLE (p_Doc_Attrs)  n
               FULL OUTER JOIN Old_Attrs o ON n.Nda_Id = o.Da_Nda;

        RETURN NVL (l_Is_Modified, 0) = 1;
    END;

    FUNCTION Is_Doc_Files_Modified (p_Dh_Id       IN NUMBER,
                                    p_Doc_Files      t_Doc_Files)
        RETURN BOOLEAN
    IS
        l_Is_Modified   NUMBER;
    BEGIN
        WITH
            Old_Attach
            AS
                (SELECT a.Dat_File     AS File_Id
                   FROM Uss_Doc.v_Doc_Attachments a
                  WHERE a.Dat_Dh = p_Dh_Id),
            New_Attach
            AS
                (SELECT NVL (f.File_Id, -1)     AS File_Id
                   FROM TABLE (p_Doc_Files)  a
                        LEFT JOIN Uss_Doc.v_Files f
                            ON a.File_Code = f.File_Code)
        SELECT MAX (
                   CASE
                       WHEN o.File_Id IS NULL OR n.File_Id IS NULL THEN 1
                       ELSE 0
                   END)
          INTO l_Is_Modified
          FROM New_Attach  n
               FULL OUTER JOIN Old_Attach o ON n.File_Id = o.File_Id;

        RETURN NVL (l_Is_Modified, 0) = 1;
    END;

    FUNCTION Get_Attr_Val_Str (p_Doc_Attrs   IN t_Doc_Attrs,
                               p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Val   VARCHAR2 (500);
    BEGIN
        SELECT MAX (Val_Str)
          INTO l_Val
          FROM TABLE (p_Doc_Attrs)  a
               JOIN Uss_Ndi.v_Ndi_Decoding_Config c
                   ON     c.Nddc_Tp = 'NDA_ID'
                      AND c.Nddc_Src = 'RZO'
                      AND c.Nddc_Dest = 'USS'
                      AND TO_CHAR (a.Nda_Id) = c.Nddc_Code_Src
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON     TO_NUMBER (c.Nddc_Code_Dest) = n.Nda_Id
                      AND n.Nda_Class = p_Nda_Class;

        RETURN l_Val;
    END;

    FUNCTION Get_Attr_Val_Dt (p_Doc_Attrs   IN t_Doc_Attrs,
                              p_Nda_Class   IN VARCHAR2)
        RETURN DATE
    IS
        l_Val   DATE;
    BEGIN
        SELECT MAX (Val_Dt)
          INTO l_Val
          FROM TABLE (p_Doc_Attrs)  a
               JOIN Uss_Ndi.v_Ndi_Decoding_Config c
                   ON     c.Nddc_Tp = 'NDA_ID'
                      AND c.Nddc_Src = 'RZO'
                      AND c.Nddc_Dest = 'USS'
                      AND TO_CHAR (a.Nda_Id) = c.Nddc_Code_Src
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON     TO_NUMBER (c.Nddc_Code_Dest) = n.Nda_Id
                      AND n.Nda_Class = p_Nda_Class;

        RETURN l_Val;
    END;

    FUNCTION Get_Attr_Val_Int (p_Doc_Attrs   IN t_Doc_Attrs,
                               p_Nda_Class   IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Val   NUMBER;
    BEGIN
        SELECT MAX (Val_Int)
          INTO l_Val
          FROM TABLE (p_Doc_Attrs)  a
               JOIN Uss_Ndi.v_Ndi_Decoding_Config c
                   ON     c.Nddc_Tp = 'NDA_ID'
                      AND c.Nddc_Src = 'RZO'
                      AND c.Nddc_Dest = 'USS'
                      AND TO_CHAR (a.Nda_Id) = c.Nddc_Code_Src
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON     TO_NUMBER (c.Nddc_Code_Dest) = n.Nda_Id
                      AND n.Nda_Class = p_Nda_Class;

        RETURN l_Val;
    END;

    PROCEDURE Save_Documents (p_Sc_Id         IN NUMBER,
                              p_Docs          IN t_Docs,
                              p_Invalid_Ipn   IN BOOLEAN DEFAULT FALSE)
    IS
        l_Ndt_Ndc   Uss_Ndi.v_Ndi_Document_Type.Ndt_Ndc%TYPE;
    BEGIN
        FOR i IN 1 .. p_Docs.COUNT
        LOOP
            DECLARE
                l_Doc_Id   NUMBER;
                l_Dh_Id    NUMBER;
                l_Scd_Id   NUMBER;
                l_Ndt_Id   NUMBER;
                l_Attrs    Api$socialcard.t_Doc_Attrs;
            BEGIN
                l_Ndt_Id :=
                    Uss_Ndi.Tools.Decode_Dict (
                        p_Nddc_Tp         => 'NDT_ID',
                        p_Nddc_Src        => 'RZO',
                        p_Nddc_Dest       => 'USS',
                        p_Nddc_Code_Src   => p_Docs (i).Doc_Ndt);

                IF l_Ndt_Id IS NULL
                THEN
                    CONTINUE;
                END IF;

                IF     l_Ndt_Id = 5
                   AND (   Get_Attr_Val_Str (p_Docs (i).Attributes, 'DSN') =
                           '0000000000'
                        OR p_Invalid_Ipn)
                THEN
                    CONTINUE;
                END IF;

                SELECT a.Nda_Id,
                       Val_Str,
                       Val_Dt,
                       Val_Int,
                       NULL     AS Val_Id
                  BULK COLLECT INTO l_Attrs
                  FROM TABLE (p_Docs (i).Attributes)  a
                       --Пересвідчуємось, що атрибут є в довіднику
                       JOIN Uss_Ndi.v_Ndi_Document_Attr n
                           ON a.Nda_Id = n.Nda_Id AND n.Nda_Ndt = l_Ndt_Id;

                SELECT MAX (Ndt_Ndc)
                  INTO l_Ndt_Ndc
                  FROM Uss_Ndi.v_Ndi_Document_Type
                 WHERE Ndt_Id = l_Ndt_Id;

                --Ідентифікаційні документи та відмову від РНОКПП - не змінюємо цим завантаженням. #92013
                IF     l_Ndt_Ndc IS NOT NULL
                   AND l_Ndt_Ndc <> 13
                   AND l_Ndt_Id <> 10117
                THEN
                    Api$socialcard.Save_Document (p_Sc_Id         => p_Sc_Id,
                                                  p_Ndt_Id        => l_Ndt_Id,
                                                  p_Doc_Attrs     => l_Attrs,
                                                  p_Src_Id        => c_Src_Rzo,
                                                  p_Src_Code      => 'RZO',
                                                  p_Scd_Note      => NULL,
                                                  p_Scd_Id        => l_Scd_Id,
                                                  p_Doc_Id        => l_Doc_Id,
                                                  p_Dh_Id         => l_Dh_Id,
                                                  p_Set_Feature   => TRUE);

                    Save_Doc_Attachments (p_Dh_Id   => l_Dh_Id,
                                          p_Files   => p_Docs (i).Files);
                END IF;
            END;
        END LOOP;
    END;

    FUNCTION Decode_Attr_Val (p_Nda_Id IN NUMBER, p_Val_Str IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (500);
    BEGIN
        CASE p_Nda_Id
            WHEN 349
            THEN
                SELECT DECODE (p_Val_Str,  'І', '1',  'ІІ', '2',  'ІІІ', '3')
                  INTO l_Result
                  FROM DUAL;
            ELSE
                l_Result := p_Val_Str;
        END CASE;

        RETURN l_Result;
    END;

    PROCEDURE Save_Doc_Attributes (p_Dh_Id IN NUMBER, p_Attrs t_Doc_Attrs)
    IS
    BEGIN
        IF p_Attrs IS NULL
        THEN
            RETURN;
        END IF;

        FOR i IN 1 .. p_Attrs.COUNT
        LOOP
            DECLARE
                l_Nda_Id   NUMBER;
                l_Da_Id    NUMBER;
            BEGIN
                l_Nda_Id :=
                    Uss_Ndi.Tools.Decode_Dict (
                        p_Nddc_Tp         => 'NDA_ID',
                        p_Nddc_Src        => 'RZO',
                        p_Nddc_Dest       => 'USS',
                        p_Nddc_Code_Src   => p_Attrs (i).Nda_Id);

                IF l_Nda_Id IS NULL
                THEN
                    CONTINUE;
                END IF;

                Uss_Doc.Api$documents.Save_Attribute (
                    p_Da_Nda          => l_Nda_Id,
                    p_Da_Val_String   =>
                        Decode_Attr_Val (l_Nda_Id, p_Attrs (i).Val_Str),
                    p_Da_Val_Int      => p_Attrs (i).Val_Int,
                    p_Da_Val_Dt       => p_Attrs (i).Val_Dt,
                    p_Da_Val_Id       => NULL,
                    p_Da_Val_Sum      => NULL,
                    p_Da_Id           => l_Da_Id);
                Uss_Doc.Api$documents.Save_Attr_In_Hist (
                    p_Da2h_Da   => l_Da_Id,
                    p_Da2h_Dh   => p_Dh_Id);
            END;
        END LOOP;
    END;

    PROCEDURE Save_Doc_Attachments (p_Dh_Id   IN NUMBER,
                                    p_Files   IN t_Doc_Files)
    IS
    BEGIN
        IF p_Files IS NULL
        THEN
            RETURN;
        END IF;

        FOR i IN 1 .. p_Files.COUNT
        LOOP
            DECLARE
                l_File_Id   NUMBER;
                l_Dat_Id    NUMBER;
            BEGIN
                --Перевіряємо файл на наявність по коду+хеш
                IF p_Files (i).File_Hash IS NOT NULL
                THEN
                    SELECT MAX (File_Id)
                      INTO l_File_Id
                      FROM Uss_Doc.v_Files f
                     WHERE     f.File_Code = p_Files (i).File_Code
                           AND f.File_Hash = p_Files (i).File_Hash;
                END IF;

                IF l_File_Id IS NULL
                THEN
                    Uss_Doc.Api$documents.Save_File (
                        p_File_Id            => NULL,
                        p_File_Thumb         => NULL,
                        p_File_Code          => p_Files (i).File_Code,
                        p_File_Name          => p_Files (i).File_Name,
                        p_File_Mime_Type     => p_Files (i).File_Content_Type,
                        p_File_Description   => NULL,
                        p_File_Create_Dt     => SYSDATE,
                        p_File_Wu            => NULL,
                        p_File_App           => 2,
                        p_File_Hash          => p_Files (i).File_Hash,
                        p_File_Size          => p_Files (i).File_Size,
                        p_New_Id             => l_File_Id);
                END IF;

                Uss_Doc.Api$documents.Save_Attachment (
                    p_Dat_Id          => NULL,
                    p_Dat_Num         => NULL,
                    p_Dat_File        => l_File_Id,
                    p_Dat_Dh          => p_Dh_Id,
                    p_Dat_Sign_File   => NULL,
                    p_Dat_Hs          => Uss_Doc.Tools.Gethistsession,
                    p_New_Id          => l_Dat_Id);
            END;
        END LOOP;
    END;

    -------------------------------------------------------------------------------
    --   Реєстрація запиту на пошук особи в РЗО
    -------------------------------------------------------------------------------
    PROCEDURE Reg_Search_Person_Req (p_Numident   IN     VARCHAR2,
                                     p_Ln         IN     VARCHAR2,
                                     p_Fn         IN     VARCHAR2,
                                     p_Mn         IN     VARCHAR2,
                                     p_Doc_Tp     IN     NUMBER,
                                     p_Doc_Num    IN     VARCHAR2,
                                     p_Gender     IN     VARCHAR2,
                                     p_Wu_Id      IN     NUMBER,
                                     p_Src        IN     VARCHAR2,
                                     p_Rn_Id         OUT NUMBER)
    IS
    BEGIN
        tools.validate_param (p_Numident);
        tools.validate_param (p_Ln);
        tools.validate_param (p_Fn);
        tools.validate_param (p_Mn);
        tools.validate_param (p_Doc_Num);
        tools.validate_param (p_Gender);
        tools.validate_param (p_Src);

        --Переіряємо чи є вже незавершений запит з такими параметрами
        SELECT MAX (j.Rn_Id)
          INTO p_Rn_Id
          FROM Ikis_Rbm.v_Request_Journal  j
               JOIN Ikis_Rbm.v_Rn_Common_Infp i
                   ON     j.Rn_Id = i.Rnc_Rn
                      AND i.Rnc_Pt =
                          Ikis_Rbm.Api$request_Pfu.c_Pt_Is_Reg_Person
                      AND i.Rnc_Val_String = 'T'
               JOIN Ikis_Rbm.v_Rn_Person p
                   ON     j.Rn_Id = p.Rnp_Rn
                      AND NVL (p.Rnp_Inn, '-') =
                          COALESCE (p_Numident, p.Rnp_Inn, '-')
                      AND NVL (p.Rnp_Doc_Seria || p.Rnp_Doc_Number, '-') =
                          NVL (p_Doc_Num, '-')
               JOIN Ikis_Rbm.v_Rnp_Identity_Info Id
                   ON     p.Rnp_Id = Id.Rnpi_Rnp
                      AND NVL (Id.Rnpi_Ln || Id.Rnpi_Fn || Id.Rnpi_Mn, '-') =
                          NVL (p_Ln || p_Fn || p_Mn, '-')
         WHERE     j.Rn_Nrt = c_Nrt_Search_Person
               AND j.Rn_St = Ikis_Rbm.Api$request.c_Rn_St_New;

        IF p_Rn_Id IS NOT NULL
        THEN
            RETURN;
        END IF;

        Ikis_Rbm.Api$request_Pfu.Reg_Get_Person_Unique_Req (
            p_Rn_Nrt      => c_Nrt_Search_Person,
            p_Rn_Hs_Ins   => Ikis_Rbm.Tools.Gethistsession (p_Wu_Id),
            p_Rn_Src      => p_Src,
            p_Rn_Id       => p_Rn_Id,
            p_Ur_Ext_Id   => NULL,
            p_Is_Reg      => 'F',
            p_Numident    => p_Numident,
            p_Ln          => p_Ln,
            p_Fn          => p_Fn,
            p_Mn          => p_Mn,
            p_Doc_Tp      => p_Doc_Tp,
            p_Doc_Num     => p_Doc_Num,
            p_Gender      => p_Gender,
            p_Birthday    => NULL);
    END;

    -------------------------------------------------------------------------------
    --   Обробка відповіді на запит на пошу особи в РЗО
    -------------------------------------------------------------------------------
    PROCEDURE Handle_Search_Person_Resp (p_Ur_Id      IN     NUMBER,
                                         p_Response   IN     CLOB,
                                         p_Error      IN OUT VARCHAR2)
    IS
        l_Response_Body      CLOB;
        l_Response_Payload   CLOB;

        l_Result             NUMBER;
        l_Error              VARCHAR2 (4000);
        l_Is_New             BOOLEAN;
        l_Person_Info        XMLTYPE;
        l_Documents          XMLTYPE;
    BEGIN
        g_Sc_Id := NULL;
        g_Is_Temp_Error := FALSE;

        IF p_Error IS NOT NULL
        THEN
            RETURN;
        END IF;

              --Парсимо відповідь
              SELECT Resp_Body
                INTO l_Response_Body
                FROM XMLTABLE (Xmlnamespaces (DEFAULT 'http://tempuri.org/'),
                               '/*'
                               PASSING Xmltype (p_Response)
                               COLUMNS Resp_Body    CLOB PATH 'Body');

        l_Response_Payload :=
            Ikis_Rbm.Tools.B64_Decode (l_Response_Body, 'UTF8');


        IF    l_Response_Payload IS NULL
           OR DBMS_LOB.Getlength (l_Response_Payload) = 0
        THEN
            p_Error := 'Відповідь від РЗО порожня';
            RETURN;
        END IF;

                SELECT Result_,
                       Error,
                       Person_Info,
                       Documents
                  INTO l_Result,
                       l_Error,
                       l_Person_Info,
                       l_Documents
                  FROM XMLTABLE ('/*'
                                 PASSING Xmltype (l_Response_Payload)
                                 COLUMNS Result_        NUMBER PATH 'Result',
                                         --Answer VARCHAR2(4000) Path 'Answer',
                                         Error          VARCHAR2 (4000) PATH 'Error',
                                         Person_Info    XMLTYPE PATH 'Person_Info',
                                         Documents      XMLTYPE PATH 'Documents');

        IF l_Error IS NOT NULL
        THEN
            p_Error := l_Error;
            g_Is_Temp_Error := l_Result IS NULL;
            RETURN;
        END IF;

        IF l_Result IS NULL
        THEN
            g_Is_Temp_Error := TRUE;
            RETURN;
        END IF;



        IF l_Person_Info IS NULL
        THEN
            p_Error := 'Відомості про особу відсутні';
            RETURN;
        END IF;

        --Зберігаємо інформацію про особу
        Save_Person_Info (p_Ur_Id         => p_Ur_Id,
                          p_Person_Info   => l_Person_Info,
                          p_Sc_Id         => g_Sc_Id,
                          p_Is_New        => l_Is_New);

        IF l_Is_New
        THEN
            DECLARE
                l_Docs   t_Docs;
            BEGIN
                l_Docs := Parse_Documents (l_Documents.Getclobval);
                --Зберігаємо документи особи
                Save_Documents (p_Sc_Id => g_Sc_Id, p_Docs => l_Docs);
                --Заповнюємо анкету особи
                Uss_Person.Api$socialcard.Init_Sc_Info (p_Sc_Id => g_Sc_Id);
            END;
        END IF;
    END;

    PROCEDURE Save_Person_Info (p_Ur_Id         IN     NUMBER,
                                p_Person_Info   IN     XMLTYPE,
                                p_Sc_Id            OUT NUMBER,
                                p_Is_New           OUT BOOLEAN)
    IS
        l_Scc_Id        NUMBER;
        l_Sci_Id        NUMBER;
        l_Scb_Id        NUMBER;
        l_Scb_Sca       NUMBER;
        l_Scc_Sca       NUMBER;
        l_Sct_Id        NUMBER;
        l_Scp_Id        NUMBER;
        l_Rn_Id         NUMBER;
        l_Lock_Handle   Ikis_Sys.Ikis_Lock.t_Lockhandler;
    BEGIN
        FOR Rec
            IN (      SELECT *
                        FROM XMLTABLE (
                                 '/*'
                                 PASSING p_Person_Info
                                 COLUMNS Ip_Unique    VARCHAR2 (20) PATH 'General/Ip_Unique',
                                         Ip_Pt        NUMBER PATH 'General/Ip_Pt',
                                         LN           VARCHAR2 (200) PATH 'General/Ln',
                                         Fn           VARCHAR2 (200) PATH 'General/Fn',
                                         Mn           VARCHAR2 (200) PATH 'General/Mn',
                                         Sex          VARCHAR2 (2) PATH 'General/Sex',
                                         Nt           VARCHAR2 (2) PATH 'General/Nt',
                                         Birthday     VARCHAR2 (20) PATH 'General/Birthday',
                                         Contacts     XMLTYPE PATH 'Contacts',
                                         Address      XMLTYPE PATH 'Address',
                                         Feature      XMLTYPE PATH 'Feature',
                                         Pension      XMLTYPE PATH 'Pension'))
        LOOP
            IF Rec.Ip_Unique IS NULL
            THEN
                Raise_Application_Error (-20000, 'Не заповнено ПЕОКЗО');
            END IF;

            Ikis_Sys.Ikis_Lock.Request_Lock (
                p_Permanent_Name      => 'USS_PERSON:',
                p_Var_Name            => 'SC_UNIQUE_' || Rec.Ip_Unique,
                p_Errmessage          =>
                       'Вже виконується збереження соц. картки з ПЕОКЗО '
                    || Rec.Ip_Unique,
                p_Lockhandler         => l_Lock_Handle,
                p_Timeout             => 3600,
                p_Release_On_Commit   => TRUE);

            SELECT MAX (c.Sc_Id)
              INTO p_Sc_Id
              FROM Uss_Person.v_Socialcard c
             WHERE c.Sc_Unique = Rec.Ip_Unique AND c.Sc_St = '1';

            l_Rn_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

            IF p_Sc_Id IS NOT NULL
            THEN
                p_Is_New := FALSE;
                --TODO: узгодити алгоритм актуалізації соцкартки
                Ikis_Rbm.Api$request.Set_Rnp_Sc (p_Rnp_Rn   => l_Rn_Id,
                                                 p_Rnp_Sc   => p_Sc_Id);
                RETURN;
            END IF;

            p_Is_New := TRUE;

            --Створюємо соціальну картку
            Uss_Person.Api$socialcard.Save_Socialcard (
                p_Sc_Id          => NULL,
                p_Sc_Unique      => Rec.Ip_Unique,
                p_Sc_Create_Dt   => SYSDATE,
                p_Sc_Scc         => NULL,
                p_Sc_Src         => c_Src_Rzo,
                p_Sc_St          => Rec.Ip_Pt,
                p_New_Id         => p_Sc_Id);

            Ikis_Rbm.Api$request.Set_Rnp_Sc (p_Rnp_Rn   => l_Rn_Id,
                                             p_Rnp_Sc   => p_Sc_Id);

            --Зберігаємо основну інформацію про особу
            Uss_Person.Api$socialcard.Save_Sc_Identity (
                p_Sci_Id            => NULL,
                p_Sci_Sc            => p_Sc_Id,
                p_Sci_Fn            => Clear_Name (Rec.Fn),
                p_Sci_Ln            => Clear_Name (Rec.LN),
                p_Sci_Mn            => Clear_Name (Rec.Mn),
                p_Sci_Gender        => Uss_Ndi.Tools.Decode_Dict_Reverse (
                                          p_Nddc_Tp          => 'GENDER',
                                          p_Nddc_Src         => 'VST',
                                          p_Nddc_Dest        => 'RZO',
                                          p_Nddc_Code_Dest   => Rec.Sex),
                p_Sci_Nationality   => Rec.Nt,
                p_New_Id            => l_Sci_Id);

            IF Rec.Birthday IS NOT NULL
            THEN
                --Зберігаємо інформацію про народження
                Uss_Person.Api$socialcard.Save_Sc_Birh (
                    p_Scb_Id     => NULL,
                    p_Scb_Sc     => p_Sc_Id,
                    p_Scb_Sca    => l_Scb_Sca,
                    p_Scb_Scd    => NULL,                              --todo!
                    p_Scb_Dt     => TO_DATE (Rec.Birthday, 'dd.mm.yyyy'),
                    p_Scb_Note   => NULL,
                    p_Scb_Src    => c_Src_Rzo,
                    p_Scb_Ln     => NULL,                                  --?
                    p_New_Id     => l_Scb_Id);
            END IF;

            --Зберігаємо контактну інформацію
            Save_Person_Contact (p_Contact   => Rec.Contacts,
                                 p_Sct_Id    => l_Sct_Id);
            --Зберігаємо адреси
            Save_Person_Addresses (p_Sc_Id       => p_Sc_Id,
                                   p_Addresses   => Rec.Address,
                                   p_Scc_Sca     => l_Scc_Sca,
                                   p_Scb_Sca     => l_Scb_Sca);
            --Зберігаємо особливості особи
            Save_Person_Feature (p_Sc_Id => p_Sc_Id, p_Feature => Rec.Feature);
            --Зберігаємо інформацію щодо пенсії
            Save_Pension (p_Sc_Id     => p_Sc_Id,
                          p_Pension   => Rec.Pension,
                          p_Scp_Id    => l_Scp_Id);
            --Створюємо зріз соцкартки
            Uss_Person.Api$socialcard.Save_Sc_Change (
                p_Scc_Id          => NULL,
                p_Scc_Sc          => p_Sc_Id,
                p_Scc_Create_Dt   => SYSDATE,
                p_Scc_Src         => c_Src_Rzo,
                p_Scc_Sct         => l_Sct_Id,
                p_Scc_Sci         => l_Sci_Id,
                p_Scc_Scb         => l_Scb_Id,
                p_Scc_Sca         => l_Scc_Sca,
                p_Scc_Sch         => NULL,                             --todo!
                p_Scc_Scp         => l_Scp_Id,
                p_Scc_Src_Dt      => NULL,
                p_New_Id          => l_Scc_Id);
            Uss_Person.Api$socialcard.Set_Sc_Scc (p_Sc_Id    => p_Sc_Id,
                                                  p_Sc_Scc   => l_Scc_Id);
        END LOOP;
    END;

    PROCEDURE Save_Person_Contact (p_Contact IN XMLTYPE, p_Sct_Id OUT NUMBER)
    IS
    BEGIN
        FOR Rec
            IN (      SELECT *
                        FROM XMLTABLE (
                                 '/*'
                                 PASSING p_Contact
                                 COLUMNS Phone        VARCHAR2 (100) PATH 'Phone',
                                         Phone_Mob    VARCHAR2 (100) PATH 'Phone_Mob',
                                         Fax          VARCHAR2 (100) PATH 'Fax',
                                         Note         VARCHAR2 (4000) PATH 'Note'))
        LOOP
            Uss_Person.Api$socialcard.Save_Sc_Contact (
                p_Sct_Id          => NULL,
                p_Sct_Phone_Mob   => Rec.Phone_Mob,
                p_Sct_Phone_Num   => Rec.Phone,
                p_Sct_Fax_Num     => Rec.Fax,
                p_Sct_Email       => NULL,
                p_Sct_Note        => Rec.Note,
                p_New_Id          => p_Sct_Id);
        END LOOP;
    END;

    PROCEDURE Save_Person_Addresses (p_Sc_Id       IN     NUMBER,
                                     p_Addresses   IN     XMLTYPE,
                                     p_Scc_Sca        OUT NUMBER,
                                     p_Scb_Sca        OUT NUMBER)
    IS
    BEGIN
        FOR Rec
            IN (       SELECT x.*,
                              k.Kaot_Id,
                              k.Kaot_Kaot_L1,
                              k.Kaot_Tp
                         FROM XMLTABLE (
                                  '/*/*'
                                  PASSING p_Addresses
                                  COLUMNS Addr_Tp       NUMBER PATH 'Addr_Tp',
                                          Kt_Code       VARCHAR2 (20) PATH 'Kt_Code',
                                          Country       VARCHAR2 (250) PATH 'Country',
                                          Region        VARCHAR2 (250) PATH 'Region',
                                          District      VARCHAR2 (250) PATH 'District',
                                          Postcode      VARCHAR2 (250) PATH 'Postcode',
                                          City          VARCHAR2 (250) PATH 'City',
                                          Street        VARCHAR2 (250) PATH 'Street',
                                          Building      VARCHAR2 (50) PATH 'Building',
                                          BLOCK         VARCHAR2 (50) PATH 'Block',
                                          Appartment    VARCHAR2 (50) PATH 'Appartment',
                                          Note          VARCHAR2 (250) PATH 'Note')
                              x
                              LEFT JOIN Uss_Ndi.v_Ndi_Katottg k
                                  ON x.Kt_Code = k.Kaot_Code
                     ORDER BY Addr_Tp)
        LOOP
            DECLARE
                l_Sca_Id   NUMBER;
            BEGIN
                Uss_Person.Api$socialcard.Save_Sc_Address (
                    p_Sca_Sc          => p_Sc_Id,
                    p_Sca_Tp          => Rec.Addr_Tp,
                    p_Sca_Kaot        => Rec.Kaot_Id,
                    p_Sca_Nc          => NULL,
                    p_Sca_Country     => Rec.Country,
                    p_Sca_Region      => Rec.Region,
                    p_Sca_District    => Rec.District,
                    p_Sca_Postcode    => Rec.Postcode,
                    p_Sca_City        => Rec.City,
                    p_Sca_Street      => Rec.Street,
                    p_Sca_Building    => Rec.Building,
                    p_Sca_Block       => Rec.Block,
                    p_Sca_Apartment   => Rec.Appartment,
                    p_Sca_Note        => Rec.Note,
                    p_Sca_Src         => c_Src_Rzo,
                    p_Sca_Create_Dt   => SYSDATE, -- Доробити передачу актуальної дати
                    o_Sca_Id          => l_Sca_Id);

                IF Rec.Addr_Tp = 1
                THEN
                    p_Scb_Sca := l_Sca_Id;
                END IF;

                p_Scc_Sca := l_Sca_Id;
            END;
        END LOOP;
    END;

    FUNCTION Flag (p_Num IN NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE WHEN p_Num = 1 THEN 'T' ELSE 'F' END;
    END;

    PROCEDURE Save_Person_Feature (p_Sc_Id IN NUMBER, p_Feature IN XMLTYPE)
    IS
        l_Scf_Id   NUMBER;
    BEGIN
        FOR Rec
            IN (        SELECT *
                          FROM XMLTABLE (
                                   '/*'
                                   PASSING p_Feature
                                   COLUMNS Is_Pension     VARCHAR2 (1) PATH 'Is_Pension',
                                           Is_Jobless     VARCHAR2 (1) PATH 'Is_Jobless',
                                           Is_Accident    VARCHAR2 (1) PATH 'Is_Accident'))
        LOOP
            Uss_Person.Api$socialcard.Save_Sc_Feature (
                p_Scf_Id              => NULL,
                p_Scf_Sc              => p_Sc_Id,
                p_Scf_Is_Taxpayer     => NULL,
                p_Scf_Is_Migrant      => NULL,
                p_Scf_Is_Pension      => Flag (Rec.Is_Pension),
                p_Scf_Is_Intpension   => NULL,
                p_Scf_Is_Dead         => NULL,                            --??
                p_Scf_Is_Jobless      => Flag (Rec.Is_Jobless),
                p_Scf_Is_Accident     => Flag (Rec.Is_Accident),
                p_Scf_Is_Dasabled     => NULL,
                p_New_Id              => l_Scf_Id);
        END LOOP;
    END;

    PROCEDURE Save_Pension (p_Sc_Id     IN     NUMBER,
                            p_Pension   IN     XMLTYPE,
                            p_Scp_Id       OUT VARCHAR2)
    IS
    BEGIN
        FOR Rec
            IN (       SELECT *
                         FROM XMLTABLE (
                                  '/*'
                                  PASSING p_Pension
                                  COLUMNS Pens_Tp       NUMBER PATH 'Pens_Tp',
                                          Begin_Dt      VARCHAR2 (20) PATH 'Begin_Dt',
                                          End_Dt        VARCHAR2 (20) PATH 'End_Dt',
                                          Sum_Pens      VARCHAR2 (20) PATH 'Sum',
                                          Pnf_Number    VARCHAR2 (20) PATH 'Number',
                                          Opfu          NUMBER PATH 'Opfu',
                                          Pay_Tp        NUMBER PATH 'Pay_Tp',
                                          Psn           NUMBER PATH 'Psn'))
        LOOP
            Uss_Person.Api$socialcard.Save_Sc_Pension (
                p_Scp_Id              => NULL,
                p_Scp_Scd             => NULL,
                p_Scp_Is_Pension      => 'T',
                p_Scp_Is_Intpension   => NULL,
                p_Scp_Intpension_Dt   => NULL,
                p_Scp_Note            => NULL,
                p_Scp_Pnf_Number      => Rec.Pnf_Number,
                p_Scp_Org             => Rec.Opfu,
                p_Scp_Pens_Tp         => Rec.Pens_Tp,               --decode??
                p_Scp_Begin_Dt        => TO_DATE (Rec.Begin_Dt, 'dd.mm.yyyy'),
                p_Scp_End_Dt          => TO_DATE (Rec.End_Dt, 'dd.mm.yyyy'),
                p_Scp_Psn             => Rec.Psn,                   --decode??
                p_Scp_Recalc_Dt       => NULL,
                p_Scp_Pay_Tp          => Rec.Pay_Tp,                --decode??
                p_Scp_Legal_Act       => NULL,
                p_Scp_Sc              => p_Sc_Id,
                p_Scp_Sum_Pens        => To_Money (Rec.Sum_Pens),
                p_Scp_Dh              => NULL,
                p_New_Id              => p_Scp_Id);
        END LOOP;
    END;

    FUNCTION Get_Document (p_Docs IN t_Docs, p_Doc_Ndt IN NUMBER)
        RETURN r_Document
    IS
    BEGIN
        FOR i IN 1 .. p_Docs.COUNT
        LOOP
            IF Uss_Ndi.Tools.Decode_Dict (
                   p_Nddc_Tp         => 'NDT_ID',
                   p_Nddc_Src        => 'RZO',
                   p_Nddc_Dest       => 'USS',
                   p_Nddc_Code_Src   => p_Docs (i).Doc_Ndt) = p_Doc_Ndt
            THEN
                RETURN p_Docs (i);
            END IF;
        END LOOP;

        RETURN NULL;
    END;

    PROCEDURE Get_Person_Search_Result (p_Rn_Id     IN     NUMBER,
                                        p_Rn_St        OUT VARCHAR2,
                                        p_Esr_Num      OUT VARCHAR2)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        p_Rn_St := Ikis_Rbm.Api$request.Get_Rn_St (p_Rn_Id);

        IF p_Rn_St = Ikis_Rbm.Api$request.c_Rn_St_Ok
        THEN
            l_Sc_Id := Ikis_Rbm.Api$request.Get_Rn_Sc (p_Rn_Id);

            SELECT c.Sc_Unique
              INTO p_Esr_Num
              FROM Uss_Person.v_Socialcard c
             WHERE c.Sc_Id = l_Sc_Id;
        END IF;
    END;

    FUNCTION Find_Sc (p_Income_Dsv_Req r_Income_Dsv_Req)
        RETURN NUMBER
    IS
        l_Sc_Id        NUMBER;
        l_Sc_Id1       NUMBER;
        l_Ndt_Id       NUMBER;
        l_Doc_Serial   VARCHAR2 (50);
        l_Doc_Num      VARCHAR2 (50);
        l_Sc_Unique    VARCHAR2 (10);
    BEGIN
        --якщо є іпн
        FOR Cur
            IN (  SELECT Rn, Ceadoctype, Serialnum
                    FROM TABLE (p_Income_Dsv_Req.Personidentifydocs)
                ORDER BY CASE WHEN Ceadoctype = 5 THEN 0 ELSE Ceadoctype END)
        LOOP
            IF Cur.Ceadoctype = 5
            THEN
                IF NOT REGEXP_LIKE (TRIM (Cur.Serialnum), '^[0-9]{10}$')
                THEN
                    CONTINUE;
                END IF;

                l_Ndt_Id := Cur.Ceadoctype;
                l_Doc_Serial := NULL;
                l_Doc_Num := TRIM (Cur.Serialnum);
                l_Sc_Id :=
                    Load$socialcard.Load_Sc (
                        p_Fn            => p_Income_Dsv_Req.Person.Firstname,
                        p_Ln            => p_Income_Dsv_Req.Person.Lastname,
                        p_Mn            => p_Income_Dsv_Req.Person.Secondname,
                        p_Gender        => 'V',
                        p_Nationality   => -1,
                        p_Src_Dt        => SYSDATE,
                        p_Birth_Dt      => p_Income_Dsv_Req.Person.Birthdt,
                        p_Inn_Num       => l_Doc_Num,
                        p_Inn_Ndt       => l_Ndt_Id,
                        p_Doc_Ser       => NULL,
                        p_Doc_Num       => NULL,
                        p_Doc_Ndt       => NULL,
                        p_Src           => NULL,
                        p_Sc            => l_Sc_Id1,
                        p_Sc_Unique     => l_Sc_Unique,
                        p_Mode          => 1);

                IF l_Sc_Id > 0
                THEN
                    RETURN l_Sc_Id;
                END IF;
            END IF;

            IF Cur.Ceadoctype != 5
            THEN
                l_Ndt_Id :=
                    CASE
                        WHEN REGEXP_LIKE (Cur.Serialnum, '^(\d){9}$')
                        THEN
                            7                                 -- новій паспорт
                        WHEN REGEXP_LIKE (Cur.Serialnum,
                                          '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            6                      -- старій паспорт из архива
                        WHEN REGEXP_LIKE (
                                 Cur.Serialnum,
                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            37                     -- свидетельство о рождении
                        ELSE
                            NULL
                    END;
                l_Doc_Serial :=
                    CASE
                        WHEN REGEXP_LIKE (Cur.Serialnum, '^(\d){9}$')
                        THEN
                            NULL
                        WHEN REGEXP_LIKE (Cur.Serialnum,
                                          '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (Cur.Serialnum, 1, 2)
                        WHEN REGEXP_LIKE (
                                 Cur.Serialnum,
                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (Cur.Serialnum, 1, 4)
                        ELSE
                            NULL
                    END;
                l_Doc_Num :=
                    CASE
                        WHEN REGEXP_LIKE (Cur.Serialnum, '^(\d){9}$')
                        THEN
                            Cur.Serialnum
                        WHEN REGEXP_LIKE (Cur.Serialnum,
                                          '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (Cur.Serialnum, -6, 6)
                        WHEN REGEXP_LIKE (
                                 Cur.Serialnum,
                                 '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                        THEN
                            SUBSTR (Cur.Serialnum, -6, 6)
                        ELSE
                            NULL
                    END;

                l_Sc_Id :=
                    Load$socialcard.Load_Sc (
                        p_Fn            => p_Income_Dsv_Req.Person.Firstname,
                        p_Ln            => p_Income_Dsv_Req.Person.Lastname,
                        p_Mn            => p_Income_Dsv_Req.Person.Secondname,
                        p_Gender        => 'V',
                        p_Nationality   => -1,
                        p_Src_Dt        => SYSDATE,
                        p_Birth_Dt      => p_Income_Dsv_Req.Person.Birthdt,
                        p_Inn_Num       => NULL,
                        p_Inn_Ndt       => NULL,
                        p_Doc_Ser       => l_Doc_Serial,
                        p_Doc_Num       => l_Doc_Num,
                        p_Doc_Ndt       => l_Ndt_Id,
                        p_Src           => NULL,
                        p_Sc            => l_Sc_Id1,
                        p_Sc_Unique     => l_Sc_Unique,
                        p_Mode          => 1);

                IF l_Sc_Id > 0
                THEN
                    RETURN l_Sc_Id;
                END IF;
            END IF;

            l_Sc_Id1 := NULL;
            l_Doc_Serial := NULL;
            l_Doc_Num := NULL;
            l_Ndt_Id := NULL;
        END LOOP;

        RETURN l_Sc_Id;
    END;

    --Процедура збереження проміжних документів в обмінах з ПФУ
    --#95404-63
    --Пошук Типів документів/атрибутів документів вимкнений для більш швидкого опрацювання запиту
    --Пошук наших типів буде виконуватися у процесі верифікації
    PROCEDURE Save_Sc_Pfu_Document (
        p_Sc_Id      IN     Sc_Pfu_Data_Ident.Scdi_Sc%TYPE,
        p_Scdi_Id    IN     Sc_Pfu_Data_Ident.Scdi_Id%TYPE,
        p_Document   IN     r_Document,
        p_Scpo_Id       OUT Sc_Pfu_Document.Scpo_Id%TYPE)
    IS
        l_Ndt_Id   NUMBER;
    BEGIN
        IF p_Document.Attributes IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                   'Відсутні атрибути у документі '
                || TO_CHAR (p_Document.Doc_Ndt));
        END IF;

        l_Ndt_Id :=
            Uss_Ndi.Tools.Decode_Dict (
                p_Nddc_Tp         => 'NDT_ID',
                p_Nddc_Src        => 'RZO',
                p_Nddc_Dest       => 'USS',
                p_Nddc_Code_Src   => p_Document.Doc_Ndt);

        Api$socialcard_Ext.Save_Document (
            p_Scpo_Id        => p_Scpo_Id,
            p_Scpo_Sc        => p_Sc_Id,
            p_Scpo_Scdi      => p_Scdi_Id,
            p_Scpo_Ndt       => l_Ndt_Id,
            p_Scpo_Pfu_Ndt   => p_Document.Doc_Ndt,
            p_Scpo_St        => c_St_Vf_Rq,
            p_Scpo_Scd       => NULL);

        IF p_Document.Attributes IS NOT NULL
        THEN
            FOR j IN 1 .. p_Document.Attributes.COUNT
            LOOP
                DECLARE
                    l_Attr     r_Doc_Attr;
                    l_Nda_Id   Sc_Pfu_Document_Attr.Scpda_Nda%TYPE;
                BEGIN
                    l_Attr := p_Document.Attributes (j);
                    l_Nda_Id :=
                        Uss_Ndi.Tools.Decode_Dict (
                            p_Nddc_Tp         => 'NDA_ID',
                            p_Nddc_Src        => 'RZO',
                            p_Nddc_Dest       => 'USS',
                            p_Nddc_Code_Src   => l_Attr.Nda_Id);
                    Api$socialcard_Ext.Save_Doc_Attr (
                        p_Scpda_Scpo         => p_Scpo_Id,
                        p_Scpda_Nda          => l_Nda_Id,
                        p_Scpda_Val_Int      => l_Attr.Val_Int,
                        p_Scpda_Val_Dt       => l_Attr.Val_Dt,
                        p_Scpda_Val_String   => l_Attr.Val_Str,
                        p_Scpda_St           => c_St_Vf_Rq,
                        p_Scpda_Pfu_Nda      => l_Attr.Nda_Id);
                END;
            END LOOP;
        END IF;

        IF p_Document.Files IS NOT NULL
        THEN
            FOR j IN 1 .. p_Document.Files.COUNT
            LOOP
                DECLARE
                    l_File   r_Doc_File;
                BEGIN
                    l_File := p_Document.Files (j);

                    INSERT INTO Sc_Pfu_Document_File (Scpdf_Id,
                                                      Scpdf_Scpo,
                                                      Scpdf_Code,
                                                      Scpdf_Name,
                                                      Scpdf_Content_Type,
                                                      Scpdf_Hash,
                                                      Scpdf_Size,
                                                      Scpdf_St)
                         VALUES (0,
                                 p_Scpo_Id,
                                 l_File.File_Code,
                                 l_File.File_Name,
                                 l_File.File_Content_Type,
                                 l_File.File_Hash,
                                 l_File.File_Size,
                                 c_St_Vf_Rq);
                END;
            END LOOP;
        END IF;
    END;

    PROCEDURE Save_Sc_Pfu_Document (p_Documents   IN OUT NOCOPY XMLTYPE,
                                    p_Scdi_Id     IN            NUMBER,
                                    p_Sc_Id       IN            NUMBER)
    IS
        l_Request_Documents   Dnet$exch_Uss2ikis.t_Docs;
    BEGIN
        BEGIN
            --Парсимо запит
            IF p_documents IS NOT NULL
            THEN
                EXECUTE IMMEDIATE type2xmltable (
                                     dnet$exch_uss2ikis.package_name,
                                     'T_DOCS',
                                     'dd.mm.yyyy')
                    USING IN p_documents.Getclobval (),
                          OUT l_request_documents;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20020,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        FOR i IN 1 .. l_request_documents.COUNT
        LOOP
            DECLARE
                l_Scpo_Id   NUMBER;
            BEGIN
                Save_Sc_Pfu_Document (p_Sc_Id      => p_Sc_Id,
                                      p_Scdi_Id    => p_Scdi_Id,
                                      p_Document   => l_request_documents (i),
                                      p_Scpo_Id    => l_Scpo_Id);
            END;
        END LOOP;
    END;

    PROCEDURE Save_Sc_Pfu_Data_Ident (p_Person_Info   IN     r_Person_Info,
                                      p_Ur_Id         IN     NUMBER,
                                      p_Scdi_Id          OUT NUMBER)
    IS
        l_Scpa_Id   NUMBER;
    BEGIN
        Api$socialcard_Ext.Save_Data_Ident (
            p_Scdi_Id          => p_Scdi_Id,
            p_Scdi_Sc          => NULL,
            p_Scdi_Ip_Unique   => p_Person_Info.General.Ip_Unique,
            p_Scdi_Ip_Pt       => p_Person_Info.General.Ip_Pt,
            p_Scdi_Ln          => Clear_Name (p_Person_Info.General.LN),
            p_Scdi_Fn          => Clear_Name (p_Person_Info.General.Fn),
            p_Scdi_Mn          => Clear_Name (p_Person_Info.General.Mn),
            p_Scdi_Unzr        => p_Person_Info.General.Unzr,
            p_Scdi_Numident    => p_Person_Info.General.Numident,
            p_Scdi_Doc_Tp      => p_Person_Info.General.Doc_Tp,
            p_Scdi_Doc_Sn      => p_Person_Info.General.Doc_Sn,
            p_Scdi_Nt          => p_Person_Info.General.Nt,
            p_Scdi_Sex         => NVL (Uss_Ndi.Tools.Decode_Dict_Reverse (
                                           p_Nddc_Tp     => 'GENDER',
                                           p_Nddc_Src    => 'VST',
                                           p_Nddc_Dest   => 'RZO',
                                           p_Nddc_Code_Dest   =>
                                               p_Person_Info.General.Sex),
                                       p_Person_Info.General.Sex),
            p_Scdi_Birthday    => p_Person_Info.General.Birthday,
            p_Scdi_Dd_Dt       => p_Person_Info.General.Dd_Dt,
            p_Rn_Id            => Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id),
            p_Phone_Mob        => p_Person_Info.Contacts.Phone_Mob,
            p_Phone_Num        => p_Person_Info.Contacts.Phone,
            p_Email            => p_Person_Info.Contacts.e_Mail,
            p_Nrt_Id           =>
                Ikis_Rbm.Api$uxp_Request.Get_Ur_Nrt (p_Ur_Id),
            p_Ext_Ident        => NULL);

        IF p_Person_Info.Address IS NOT NULL
        THEN
            FOR i IN 1 .. p_Person_Info.Address.COUNT
            LOOP
                Api$socialcard_Ext.Save_Address (
                    p_Scpa_Id          => l_Scpa_Id,
                    p_Scpa_Sc          => NULL,
                    p_Scpa_Scdi        => p_Scdi_Id,
                    p_Scpa_Tp          => p_Person_Info.Address (i).Addr_Tp,
                    p_Scpa_Kaot_Code   => p_Person_Info.Address (i).Kt_Code,
                    p_Scpa_Postcode    => p_Person_Info.Address (i).Postcode,
                    p_Scpa_City        => p_Person_Info.Address (i).City,
                    p_Scpa_Street      => p_Person_Info.Address (i).Street,
                    p_Scpa_Building    => p_Person_Info.Address (i).Building,
                    p_Scpa_Block       => p_Person_Info.Address (i).Block_,
                    p_Scpa_Apartment   => p_Person_Info.Address (i).Apartment);
            END LOOP;
        END IF;
    END;

    PROCEDURE Save_Sc_Pfu_Data_Ident (p_Person_Info   IN OUT NOCOPY XMLTYPE,
                                      p_Ur_Id         IN            NUMBER,
                                      p_Scdi_Id          OUT        NUMBER,
                                      p_Sc_Id            OUT        NUMBER)
    IS
        l_Request_Person_Info   Dnet$exch_Uss2ikis.r_Person_Info;
    BEGIN
        IF p_Person_Info IS NULL
        THEN
            RETURN;
        END IF;

        BEGIN
            --Парсимо запит
            EXECUTE IMMEDIATE Type2xmltable (Dnet$exch_Uss2ikis.Package_Name,
                                             'R_PERSON_INFO',
                                             'dd.mm.yyyy')
                USING IN p_Person_Info.Getclobval (),
                      OUT l_Request_Person_Info;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20020,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        Save_Sc_Pfu_Data_Ident (p_Person_Info   => l_Request_Person_Info,
                                p_Ur_Id         => p_Ur_Id,
                                p_Scdi_Id       => p_Scdi_Id);
    END;

    /*
                     --#81903
                     -- IC #100302 AND Sil.Sil_Inc IN ()-не використовувати
                       AND Sil.Sil_Inc IN (1,
                                           2,
                                           3,
                                           5,
                                           6,
                                           7,
                                           8,
                                           9,
                                           10,
                                           14,
                                           15,
                                           17,
                                           18,
                                           19,
                                           20,
                                           21,
                                           22,
                                           23,
                                           26,
                                           27,
                                           28,
                                           29,
                                           30,
                                           31,
                                           32,
                                           35,
                                           36,
                                           37,
                                           38,
                                           39,
                                           40,
                                           41,
                                           42,
                                           43,
                                           44,
                                           45,
                                           46,
                                           50,
                                           52,
                                           53,
                                           80,
                                           81 --#89759 #89759 20231115
                                           ) --Sbond 20230216 додав 15 і 23 по пороханню Олени Г
                                           */
    PROCEDURE Get_Sc_Incomes (p_Sc_Id      IN     NUMBER,
                              p_Start_Dt   IN     DATE,
                              p_Stop_Dt    IN     DATE,
                              p_Incomes       OUT t_Incomes)
    IS
    BEGIN
        uss_esr.Ws$VPO_Requests.Set_USS_Incomes (p_sc_id      => p_Sc_Id,
                                                 p_start_dt   => p_Start_Dt,
                                                 p_stop_dt    => p_Stop_Dt);
        p_Incomes := t_Incomes ();

        FOR Cur
            IN (  SELECT Sil.Sil_Sc,
                         TRUNC (Sil.Sil_Accrual_Dt, 'MM')     Sil_Accrual_Dt,
                         Sil.Sil_Inc,
                         SUM (Sil.Sil_Sum)                    Sil_Sum
                    FROM (SELECT Sil_Sc,
                                 Sil_Accrual_Dt,
                                 Sil_Inc,
                                 Sil_Sum
                            FROM Sc_Income_Link
                           WHERE     Sil_Sc = p_Sc_Id
                                 AND Sil_Accrual_Dt BETWEEN p_Start_Dt
                                                        AND p_Stop_Dt
                          UNION ALL
                          SELECT x_id1,
                                 x_dt1,
                                 TO_NUMBER (
                                     x_string1 DEFAULT NULL ON CONVERSION ERROR),
                                 x_sum1
                            FROM uss_esr.tmp_work_set1) Sil
                GROUP BY Sil.Sil_Sc,
                         TRUNC (Sil.Sil_Accrual_Dt, 'MM'),
                         Sil.Sil_Inc
                ORDER BY 2)
        LOOP
            p_Incomes.EXTEND ();
            p_Incomes (p_Incomes.COUNT).Startdt := Cur.Sil_Accrual_Dt;
            p_Incomes (p_Incomes.COUNT).Stopdt :=
                LAST_DAY (Cur.Sil_Accrual_Dt);
            p_Incomes (p_Incomes.COUNT).Paycode := Cur.Sil_Inc;
            p_Incomes (p_Incomes.COUNT).Sum_Val := Cur.Sil_Sum;
        END LOOP;
    END;

    --проставити дату початку/закінчення дії пільг(Sc_Benefit_Category/Sc_Benefit_Type) на підставі документів
    PROCEDURE Set_Sc_Benefit_Stop_Dt (
        p_Scbc_Id   IN Sc_Benefit_Category.Scbc_Id%TYPE)
    IS
        CURSOR Cur IS
            SELECT NVL (d.Scd_Start_Dt, d.Scd_Issued_Dt)     Start_Dt,
                   d.Scd_Stop_Dt                             Stop_Dt
              FROM Uss_Person.Sc_Benefit_Docs Bd, Uss_Person.Sc_Document d
             WHERE     Bd.Scbd_Scbc = p_Scbc_Id
                   AND d.Scd_Id = Bd.Scbd_Scd
                   AND d.Scd_St IN ('A', '1')
                   AND d.Scd_Stop_Dt =
                       (SELECT MAX (D2.Scd_Stop_Dt)
                          FROM Uss_Person.Sc_Benefit_Docs  Bd2,
                               Uss_Person.Sc_Document      D2
                         WHERE     Bd2.Scbd_Scbc = Bd.Scbd_Scbc
                               AND D2.Scd_Id = Bd2.Scbd_Scd
                               AND D2.Scd_St IN ('A', '1'));

        r   Cur%ROWTYPE;
    BEGIN
        OPEN Cur;

        FETCH Cur INTO r;

        CLOSE Cur;

        IF r.Stop_Dt IS NOT NULL
        THEN
            UPDATE Sc_Benefit_Category Bc
               SET Bc.Scbc_Start_Dt = r.Start_Dt, Bc.Scbc_Stop_Dt = r.Stop_Dt
             WHERE Bc.Scbc_Id = p_Scbc_Id;

            UPDATE Sc_Benefit_Type Bt
               SET Bt.Scbt_Start_Dt = r.Start_Dt, Bt.Scbt_Stop_Dt = r.Stop_Dt
             WHERE Bt.Scbt_Scbc = p_Scbc_Id;
        END IF;
    END Set_Sc_Benefit_Stop_Dt;

    -------------------------------------------------------------------------------
    --   Обробка запиту від ПФУ на збереження ЕПП/ППП
    -------------------------------------------------------------------------------
    FUNCTION Handle_Save_Pp_Req (p_Request_Id     IN NUMBER,          --ignore
                                 p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Request       r_Save_Person_Data_Req;
        l_Sc_Id         NUMBER;
        l_Scf_Id        NUMBER;
        l_Invalid_Ipn   BOOLEAN := FALSE;
    BEGIN
        BEGIN
            --Парсимо запит
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'R_SAVE_PERSON_DATA_REQ',
                                             'dd.mm.yyyy')
                USING IN p_Request_Body, OUT l_Request;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        IF l_Request.Person_Info.General.Ip_Unique IS NULL
        THEN
            Raise_Application_Error (-20000, 'У запиті відсутній ПЕОКЗО');
        END IF;

        IF l_Request.Documents.COUNT = 0
        THEN
            Raise_Application_Error (-20000, 'У запиті відсутні документи');
        END IF;

        --Шукаємо соцкартку по ПЕОКЗО
        SELECT MAX (c.Sc_Id)
          INTO l_Sc_Id
          FROM Socialcard c
         WHERE c.Sc_Unique = l_Request.Person_Info.General.Ip_Unique;

        --Якщо соцкарту не знайдено по ПЕОКЗО
        IF l_Sc_Id IS NULL
        THEN
            DECLARE
                l_Pp_Attrs    t_Doc_Attrs;
                l_Inn_Attrs   t_Doc_Attrs;
                l_Pasp        r_Document;
                l_Sc_Unique   VARCHAR2 (100);
                l_Doc_Ser     VARCHAR2 (10);
                l_Doc_Num     VARCHAR2 (50);
            BEGIN
                l_Pp_Attrs :=
                    NVL (Get_Document (l_Request.Documents, 602).Attributes,
                         Get_Document (l_Request.Documents, 601).Attributes);
                l_Inn_Attrs :=
                    Get_Document (l_Request.Documents, 5).Attributes;
                l_Pasp := Get_Document (l_Request.Documents, 6);

                IF l_Pasp.Attributes IS NULL
                THEN
                    l_Pasp := Get_Document (l_Request.Documents, 7);
                END IF;

                l_Doc_Num := Get_Attr_Val_Str (l_Pasp.Attributes, 'DSN');
                Split_Doc_Number (p_Ndt_Id       => l_Pasp.Doc_Ndt,
                                  p_Doc_Number   => l_Doc_Num,
                                  p_Doc_Serial   => l_Doc_Ser);

                --Шукаємо картку за атрибутами ПП або створюємо нову
                l_Sc_Id :=
                    Load$socialcard.Load_Sc (
                        p_Fn            =>
                            Clear_Name (
                                NVL (l_Request.Person_Info.General.Fn,
                                     Get_Attr_Val_Str (l_Pp_Attrs, 'FN'))),
                        p_Ln            =>
                            Clear_Name (
                                NVL (l_Request.Person_Info.General.LN,
                                     Get_Attr_Val_Str (l_Pp_Attrs, 'LN'))),
                        p_Mn            =>
                            Clear_Name (
                                NVL (l_Request.Person_Info.General.Mn,
                                     Get_Attr_Val_Str (l_Pp_Attrs, 'MN'))),
                        p_Gender        => Uss_Ndi.Tools.Decode_Dict_Reverse (
                                              p_Nddc_Tp     => 'GENDER',
                                              p_Nddc_Src    => 'VST',
                                              p_Nddc_Dest   => 'RZO',
                                              p_Nddc_Code_Dest   =>
                                                  l_Request.Person_Info.General.Sex),
                        p_Nationality   => l_Request.Person_Info.General.Nt,
                        p_Src_Dt        =>
                            Get_Attr_Val_Dt (l_Pp_Attrs, 'DGVDT'),
                        p_Birth_Dt      =>
                            NVL (l_Request.Person_Info.General.Birthday,
                                 Get_Attr_Val_Dt (l_Pp_Attrs, 'BDT')),
                        p_Inn_Num       =>
                            Get_Attr_Val_Str (l_Inn_Attrs, 'DSN'),
                        p_Inn_Ndt       => 5,
                        p_Doc_Ser       => l_Doc_Ser,
                        p_Doc_Num       => l_Doc_Num,
                        p_Doc_Ndt       => l_Pasp.Doc_Ndt,
                        p_Src           => c_Src_Rzo,
                        p_Sc_Unique     => l_Sc_Unique,
                        p_Sc            => l_Sc_Id);

                l_Invalid_Ipn := Load$socialcard.g_Ipn_Invalid;

                IF NVL (l_Sc_Id, -1) < 1
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Помилка пошуку/створення соцкартки');
                END IF;

                --Зберігаємо ПЕОКЗО до соцкартки(тільки у разі, якщо вона тимчасова)
                UPDATE Socialcard c
                   SET c.Sc_Unique = l_Request.Person_Info.General.Ip_Unique,
                       c.Sc_St = '1'
                 WHERE c.Sc_Id = l_Sc_Id AND c.Sc_St = '4';

                IF SQL%ROWCOUNT > 0
                THEN
                    UPDATE Sc_Info i
                       SET i.Sco_Unique =
                               l_Request.Person_Info.General.Ip_Unique
                     WHERE i.Sco_Id = l_Sc_Id;
                END IF;
            END;
        END IF;

        --Зберігаємо ПП та інщі документи
        Save_Documents (p_Sc_Id         => l_Sc_Id,
                        p_Docs          => l_Request.Documents,
                        p_Invalid_Ipn   => l_Invalid_Ipn);
        --Зберігаємо соціальні ознаки
        l_Scf_Id := Api$socialcard.Get_Sc_Scf (l_Sc_Id);
        Uss_Person.Api$socialcard.Save_Sc_Feature (
            p_Scf_Id              => l_Scf_Id,
            p_Scf_Sc              => l_Sc_Id,
            p_Scf_Is_Taxpayer     => NULL,
            p_Scf_Is_Migrant      => NULL,
            p_Scf_Is_Pension      => NULL,
            p_Scf_Is_Intpension   => NULL,
            p_Scf_Is_Dead         => NULL,
            p_Scf_Is_Jobless      =>
                Flag (l_Request.Person_Info.Feature.Is_Jobless),
            p_Scf_Is_Accident     =>
                Flag (l_Request.Person_Info.Feature.Is_Accident),
            p_Scf_Is_Dasabled     => NULL,
            p_New_Id              => l_Scf_Id);
        RETURN NULL;
    END;

    -------------------------------------------------------------------------------
    --   Обробка запиту від ПФУ на знищення ЕПП/ППП
    -------------------------------------------------------------------------------
    FUNCTION Handle_Destroy_Pp_Req (p_Request_Id     IN NUMBER,       --ignore
                                    p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Request   r_Doc_Deactivate_Req;
        l_Sc_Id     NUMBER;
        l_Ndt_Id    NUMBER;
    BEGIN
        BEGIN
            --Парсимо запит
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             'r_Doc_Deactivate_Req',
                                             'dd.mm.yyyy')
                USING IN p_Request_Body, OUT l_Request;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        SELECT MAX (c.Sc_Id)
          INTO l_Sc_Id
          FROM Socialcard c
         WHERE c.Sc_Unique = l_Request.Ip_Unique;

        IF l_Sc_Id IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                   'Не знайдено соціальну картку з ПЕОКЗО'
                || l_Request.Ip_Unique);
        END IF;

        l_Ndt_Id :=
            Uss_Ndi.Tools.Decode_Dict (p_Nddc_Tp         => 'NDT_ID',
                                       p_Nddc_Src        => 'RZO',
                                       p_Nddc_Dest       => 'USS',
                                       p_Nddc_Code_Src   => l_Request.Doc_Ndt);

        FOR c
            IN (SELECT Scd_Id
                  FROM Sc_Document d
                 WHERE     d.Scd_Sc = l_Sc_Id
                       AND d.Scd_Ndt = l_Ndt_Id
                       AND d.Scd_St = '1'
                       AND d.Scd_Number = l_Request.Doc_Num)
        LOOP
            UPDATE Sc_Document d
               SET d.Scd_St = '2'
             WHERE Scd_Id = c.Scd_Id;

            --Робимо перерахунок ознаки "Особа з інвалідністю"
            Api$feature.Recalc_Disability_Feature (p_Scd_Id => c.Scd_Id);
        END LOOP;

        RETURN NULL;
    END;

    /*
    info:    Отримання відповіді на запит по доходам для однієї особи
    author:  sho/lev
    request: #100296
    */
    FUNCTION Get_Incomes_Row (p_Row_Id IN NUMBER, p_Request IN XMLTYPE)
        RETURN XMLTYPE
    IS
        l_Request           r_Income_Dsv_Req;
        l_Sc_Id             NUMBER;
        l_Incomes           t_Incomes;
        l_Answercode        NUMBER;
        l_Answermessage     VARCHAR2 (4000);
        l_Xml_Technanswer   XMLTYPE;
        l_Xml_Incomes       XMLTYPE;
        l_Frm               VARCHAR2 (20) := 'FM999999999999990.90';
        l_Result            XMLTYPE;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
               SELECT Kss,
                      Lastname,
                      Firstname,
                      Secondname,
                      TO_DATE (Birthdate, 'yyyy-mm-dd'),       /*persondocs,*/
                      TO_DATE (Startdt, 'yyyy-mm-dd'),
                      TO_DATE (Stopdt, 'yyyy-mm-dd')
                 INTO l_Request.Person.Kss,
                      l_Request.Person.Lastname,
                      l_Request.Person.Firstname,
                      l_Request.Person.Secondname,
                      l_Request.Person.Birthdt,
                      l_Request.Requestperiod.Startdt,
                      l_Request.Requestperiod.Stopdt
                 FROM XMLTABLE (
                          '/row'
                          PASSING p_Request
                          COLUMNS Kss           VARCHAR2 (500) PATH 'Person/KSS',
                                  Lastname      VARCHAR2 (500) PATH 'Person/Ln',
                                  Firstname     VARCHAR2 (500) PATH 'Person/Fn',
                                  Secondname    VARCHAR2 (500) PATH 'Person/Mn',
                                  Birthdate     VARCHAR2 (500) PATH 'Person/BirthDt',
                                  Startdt       VARCHAR2 (500) PATH 'Period/StartDt',
                                  Stopdt        VARCHAR2 (500) PATH 'Period/StopDt');

        l_Request.Personidentifydocs := t_Personidentifydocs ();

        FOR Rec
            IN (       SELECT *
                         FROM XMLTABLE (
                                  '/row/Documents/row'
                                  PASSING p_Request
                                  COLUMNS Rn            NUMBER PATH 'Rn',
                                          Ceadoctype    NUMBER PATH 'DocTp',
                                          Serialnum     VARCHAR2 (250) PATH 'DocSn'))
        LOOP
            l_Request.Personidentifydocs.EXTEND ();
            l_Request.Personidentifydocs (l_Request.Personidentifydocs.COUNT).Rn :=
                Rec.Rn;
            l_Request.Personidentifydocs (l_Request.Personidentifydocs.COUNT).Ceadoctype :=
                Rec.Ceadoctype;
            l_Request.Personidentifydocs (l_Request.Personidentifydocs.COUNT).Serialnum :=
                Rec.Serialnum;
        END LOOP;

        l_Sc_Id := Find_Sc (l_Request);

        IF l_Sc_Id > 0
        THEN
            Get_Sc_Incomes (l_Sc_Id,
                            l_Request.Requestperiod.Startdt,
                            l_Request.Requestperiod.Stopdt,
                            l_Incomes);
            l_Answercode := 0;
        ELSE
            l_Answercode := 1;                                     --not found
            l_Answermessage := 'Особу не знайдено';
        END IF;

        SELECT XMLELEMENT ("TechnAnswer",
                           XMLELEMENT ("AnswerCode", l_Answercode),
                           XMLELEMENT ("AnswerMessage", l_Answermessage))
          INTO l_Xml_Technanswer
          FROM DUAL;

        SELECT XMLELEMENT (
                   "Incomes",
                   (SELECT XMLAGG (XMLELEMENT (
                                       "row",
                                       XMLFOREST (
                                           TO_CHAR (Startdt, 'yyyy-mm-dd')
                                               AS "StartDt",
                                           TO_CHAR (Stopdt, 'yyyy-mm-dd')
                                               AS "StopDt",
                                           Paycode AS "PayCode",
                                           TO_CHAR (Sum_Val, l_Frm) AS "Sum"))
                                   ORDER BY Paycode, Startdt)
                      FROM TABLE (l_Incomes) t))
          INTO l_Xml_Incomes
          FROM DUAL;

        SELECT XMLELEMENT ("row",
                           XMLELEMENT ("Id", p_Row_Id),
                           l_Xml_Technanswer,
                           l_Xml_Incomes)
          INTO l_Result
          FROM DUAL;

        COMMIT;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------------------
    --   Обробка запиту від ПФУ на отримання доходів
    -------------------------------------------------------------------------------
    FUNCTION Handle_Get_Incomes_Req (p_Ur_Id IN NUMBER,               --ignore
                                                        p_Request IN CLOB)
        RETURN CLOB
    IS
        l_Response   XMLTYPE;
    BEGIN
            SELECT XMLELEMENT (
                       "PutIncomesRequest",
                       XMLELEMENT (
                           "Persons",
                           --
                           XMLAGG (
                               Get_Incomes_Row (p_Row_Id    => Row_Id,
                                                p_Request   => Request))))
              INTO l_Response
              FROM XMLTABLE (
                       '/*/Persons/*'
                       PASSING Xmltype (p_Request)
                       COLUMNS --
                               Row_Id     NUMBER PATH 'Id',
                               Request    XMLTYPE PATH '/*');

        RETURN l_Response.Getclobval ();
    END;

    -- info:   отримання документів що підтверджують пільгову категорію учасника звернення
    -- params: p_scbc_id - ідентифікатор запису по пільговій категорії
    -- note:
    FUNCTION Get_Person_Benefit_Cat_Docs (
        p_Scbc_Id   Sc_Benefit_Docs.Scbd_Scbc%TYPE)
        RETURN XMLTYPE
    IS
        l_Xml   XMLTYPE;
    BEGIN
        SELECT XMLELEMENT ("BenefitCatAproveDocs", XMLAGG (Doc_Row))
          INTO l_Xml
          FROM (SELECT XMLELEMENT ("row", XMLELEMENT ("Doc_Ndt", d.Scd_Ndt) /*, ikis_person.exchange_person.get_doc_attrs_cea(d.doc_id)*/
                                                                           )    AS Doc_Row
                  FROM Sc_Benefit_Docs  Bd
                       JOIN Sc_Document d ON d.Scd_Id = Bd.Scbd_Scd
                 WHERE Bd.Scbd_Scbc = p_Scbc_Id);

        RETURN l_Xml;
    END;

    -- info:   отримання переліку пільг категорії учасника звернення
    -- params: p_scbc_id - ідентифікатор запису по пільговій категорії
    -- note:
    FUNCTION Get_Person_Benefit_Cat_Data (
        p_Scbc_Id   Sc_Benefit_Docs.Scbd_Scbc%TYPE)
        RETURN XMLTYPE
    IS
        l_Xml   XMLTYPE;
    BEGIN
        SELECT XMLELEMENT ("BenefitsData", XMLAGG (Doc_Row))
          INTO l_Xml
          FROM (SELECT XMLELEMENT (
                           "row",
                           XMLELEMENT ("Code", t.Nbt_Code),
                           XMLELEMENT ("Name", t.Nbt_Name),
                           NVL2 (
                               c.Nbc_Benefit_Amount,
                               XMLELEMENT (
                                   "Percent",
                                   TRIM (
                                       TO_CHAR (
                                           c.Nbc_Benefit_Amount,
                                           '990D00',
                                           'NLS_NUMERIC_CHARACTERS='', '''))),
                               NULL))    AS Doc_Row
                  FROM Uss_Person.Sc_Benefit_Type  Bt
                       JOIN Uss_Ndi.v_Ndi_Benefit_Type t
                           ON     Bt.Scbt_Nbt = t.Nbt_Id
                              AND t.History_Status = 'A'
                       JOIN Sc_Benefit_Category Bc
                           ON Bc.Scbc_Id = bt.scbt_scbc
                       JOIN Uss_Ndi.v_Ndi_Benefit_Category c
                           ON c.Nbc_Id = Bc.Scbc_Nbc
                 WHERE     Bt.Scbt_Scbc = p_Scbc_Id
                       AND Bt.Scbt_St = 'A'
                       AND (   Bt.Scbt_Stop_Dt IS NULL
                            OR Bt.Scbt_stop_Dt > TRUNC (SYSDATE)));

        RETURN l_Xml;
    END;

    -- info:   отримання інформації про пільгові категорії особи
    -- params: p_sc_id - ідентифікатор особи
    -- note:
    FUNCTION Get_Person_Benefit_Cats_Info (p_Sc_Id Socialcard.Sc_Id%TYPE)
        RETURN XMLTYPE
    IS
        l_Xml   XMLTYPE;
    BEGIN
          SELECT XMLAGG (
                     XMLELEMENT (
                         "row",
                         XMLELEMENT ("CatCode", c.Nbc_Code),
                         XMLELEMENT ("CatName", c.Nbc_Name),
                         Get_Person_Benefit_Cat_Docs (Bc.Scbc_Id),
                         XMLELEMENT (
                             "IncomesBenefit",
                             DECODE (
                                 CASE
                                     WHEN EXISTS
                                              (SELECT 1
                                                 FROM uss_person.sc_benefit_extend
                                                WHERE     scbe_sc = Bc.Scbc_Sc
                                                      AND scbe_nbc IS NOT NULL)
                                     THEN
                                         (SELECT scbe_is_have_sb_right
                                            FROM uss_person.sc_benefit_extend
                                           WHERE     scbe_sc = Bc.Scbc_Sc
                                                 AND scbe_nbc = Bc.Scbc_Nbc
                                                 AND scbe_id =
                                                     (SELECT MAX (scbe_id)
                                                        FROM uss_person.sc_benefit_extend
                                                       WHERE     scbe_sc =
                                                                 Bc.Scbc_Sc
                                                             AND scbe_nbc =
                                                                 Bc.Scbc_Nbc))
                                     ELSE
                                         (SELECT scbe_is_have_sb_right
                                            FROM uss_person.sc_benefit_extend
                                           WHERE     scbe_sc = Bc.Scbc_Sc
                                                 AND scbe_id =
                                                     (SELECT MAX (scbe_id)
                                                        FROM uss_person.sc_benefit_extend
                                                       WHERE scbe_sc =
                                                             Bc.Scbc_Sc))
                                 END,
                                 'T', 1,
                                 0)),
                         XMLELEMENT (
                             "IsPriorityCat",
                             CASE
                                 WHEN EXISTS
                                          (SELECT 1
                                             FROM uss_person.sc_benefit_type bt,
                                                  uss_ndi.v_ndi_benefit_type t,
                                                  uss_person.v_b_lgot       j
                                            WHERE     scbt_scbc = bc.scbc_id
                                                  AND bt.scbt_st = 'A'
                                                  AND (   bt.scbt_stop_dt
                                                              IS NULL
                                                       OR bt.scbt_stop_dt >
                                                          TRUNC (SYSDATE))
                                                  AND bt.scbt_nbt = t.nbt_id
                                                  AND t.history_status = 'A'
                                                  AND j.lgot_code = t.nbt_code
                                                  AND j.lgot_cdtip IN (5, 6))
                                 THEN
                                     1
                                 ELSE
                                     0
                             END),
                         Get_Person_Benefit_Cat_Data (Bc.Scbc_Id)))
            INTO l_Xml
            FROM Sc_Benefit_Category Bc
                 JOIN Uss_Ndi.v_Ndi_Benefit_Category c
                     ON c.Nbc_Id = Bc.Scbc_Nbc
           WHERE Bc.Scbc_Sc = p_Sc_Id AND Bc.Scbc_St = 'A'
        ORDER BY c.Nbc_Code;

        IF l_Xml IS NOT NULL
        THEN
            SELECT XMLELEMENT ("BenefitCats", l_Xml) INTO l_Xml FROM DUAL;
        END IF;

        RETURN l_Xml;
    END;

    -------------------------------------------------------------------------------
    --   Обробка запиту від ПФУ на отримання категорій пільговика
    -------------------------------------------------------------------------------
    FUNCTION Handle_Get_Benefit_Cat_Req (p_Request_Id     IN NUMBER,  --ignore
                                         p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Request            r_Income_Dsv_Req;
        l_Sc_Id              Socialcard.Sc_Id%TYPE;
        l_Xml                XMLTYPE;
        l_Answercode         NUMBER;
        l_Answermessage      VARCHAR2 (4000);
        l_Xml_Technanswer    XMLTYPE;
        l_Xml_Benefit_Cats   XMLTYPE;
        l_Answer             CLOB;
    BEGIN
               SELECT Kss,
                      Lastname,
                      Firstname,
                      Secondname,
                      TO_DATE (Birthdate, 'yyyy-mm-dd')
                 INTO l_Request.Person.Kss,
                      l_Request.Person.Lastname,
                      l_Request.Person.Firstname,
                      l_Request.Person.Secondname,
                      l_Request.Person.Birthdt
                 FROM XMLTABLE (
                          '/GetBenefitCatsRequest'
                          PASSING Xmltype (p_Request_Body)
                          COLUMNS Kss           VARCHAR2 (500) PATH 'Person/KSS',
                                  Lastname      VARCHAR2 (500) PATH 'Person/Ln',
                                  Firstname     VARCHAR2 (500) PATH 'Person/Fn',
                                  Secondname    VARCHAR2 (500) PATH 'Person/Mn',
                                  Birthdate     VARCHAR2 (500) PATH 'Person/BirthDt');

        l_Request.Personidentifydocs := t_Personidentifydocs ();

        FOR Rec
            IN (       SELECT *
                         FROM XMLTABLE (
                                  '/GetBenefitCatsRequest/Documents/row'
                                  PASSING Xmltype (p_Request_Body)
                                  COLUMNS Rn            NUMBER PATH 'Rn',
                                          Ceadoctype    NUMBER PATH 'DocTp',
                                          Serialnum     VARCHAR2 (250) PATH 'DocSn'))
        LOOP
            l_Request.Personidentifydocs.EXTEND ();
            l_Request.Personidentifydocs (l_Request.Personidentifydocs.COUNT).Rn :=
                Rec.Rn;
            l_Request.Personidentifydocs (l_Request.Personidentifydocs.COUNT).Ceadoctype :=
                Rec.Ceadoctype;
            l_Request.Personidentifydocs (l_Request.Personidentifydocs.COUNT).Serialnum :=
                Rec.Serialnum;
        END LOOP;

        --пошук особи по номеру ПЕОКЗО
        IF l_Request.Person.Kss IS NOT NULL
        THEN
            SELECT MAX (c.Sc_Id)
              INTO l_Sc_Id
              FROM Socialcard c
             WHERE c.Sc_Unique = l_Request.Person.Kss;
        END IF;

        --пошук особи по документам
        IF l_Sc_Id IS NULL
        THEN
            l_Sc_Id := Find_Sc (l_Request);
        END IF;

        IF l_Sc_Id > 0
        THEN
            l_Xml_Benefit_Cats := Get_Person_Benefit_Cats_Info (l_Sc_Id);

            IF l_Xml_Benefit_Cats IS NULL
            THEN
                l_Answercode := 2;
                l_Answermessage := 'категорії пільговика по особі відсутні';
            END IF;
        ELSE
            l_Answercode := 1;
            l_Answermessage := 'не знайдено особу';
        END IF;

        SELECT XMLELEMENT (
                   "TechnAnswer",
                   XMLELEMENT ("AnswerCode", COALESCE (l_Answercode, 0)),
                   XMLELEMENT ("AnswerMessage", l_Answermessage))
          INTO l_Xml_Technanswer
          FROM DUAL;

        SELECT XMLELEMENT ("GetBenefitCatsResponse",
                           l_Xml_Technanswer,
                           l_Xml_Benefit_Cats)
          INTO l_Xml
          FROM DUAL;

        l_Answer := l_Xml.Getclobval ();
        RETURN l_Answer;
    END;

    -- #95404-23 Дані щодо подовження строку дії пільг по ПКМУ389
    --p_Scpp_Id та p_Scpf_Id передавати тільки в тому випадку коли пільга діє на основі сім'ї, а не індивідуально
    PROCEDURE Save_Benefit_Extend (
        p_Sc_Id              IN sc_benefit_extend.scbe_sc%TYPE,
        p_Scdi_Id            IN sc_benefit_extend.scbe_scdi%TYPE, --Ід рядка даних осіб в ПФУ
        p_Extend_Dt          IN DATE,
        p_Is_Have_Sb_Right   IN VARCHAR2,                                --T/F
        p_Nbc                IN NUMBER,
        p_Scpp_Id            IN sc_benefit_extend.scbe_scpp%TYPE, --Ід рядка зведеної інформації по призначенню виплат в ПФУ
        p_Scpf_Id            IN sc_benefit_extend.scbe_scpf%TYPE --Ід рядка даних про родину щодо призначеної виплати ПФУ
                                                                )
    IS
    BEGIN
        INSERT INTO sc_benefit_extend (scbe_sc,
                                       scbe_scdi,
                                       scbe_extend_dt,
                                       scbe_is_fa_calculated,
                                       scbe_is_have_sb_right,
                                       scbe_create_dt,
                                       scbe_scbs,
                                       scbe_nbc,
                                       scbe_scpp,
                                       scbe_scpf,
                                       scbe_st)
             VALUES (p_Sc_Id,
                     p_Scdi_Id,
                     p_Extend_Dt,
                     NULL,
                     p_is_have_sb_right,
                     SYSDATE,
                     NULL,
                     p_nbc,
                     p_Scpp_Id,
                     p_Scpf_Id,
                     'VR');
    END;

    -- #95404-23 Дані щодо подовження строку дії пільг по ПКМУ389
    PROCEDURE Save_Benefit_Extend (
        p_Sc_Id         IN sc_benefit_extend.scbe_sc%TYPE,
        p_Benefit_Cat   IN r_Benefit_Cat)
    IS
    BEGIN
        INSERT INTO sc_benefit_extend (scbe_sc,
                                       scbe_extend_dt,
                                       scbe_is_fa_calculated,
                                       scbe_is_have_sb_right,
                                       scbe_create_dt,
                                       scbe_scbs,
                                       scbe_st)
                 VALUES (
                            p_Sc_Id,
                            p_Benefit_Cat.Incomesdt,
                            NULL,
                            DECODE (p_Benefit_Cat.Incomesbenefit,
                                    1, 'T',
                                    0, 'F',
                                    NULL),
                            SYSDATE,
                            NULL,
                            'A');
    END;

    -- info:   збереження пільгових категорій особи
    -- params: p_sc_id - ідентифікатор особи
    --         p_benefit_cats - масив інформації про категорії пільговика
    -- note:
    PROCEDURE Save_Benefit_Cats (p_Sc_Id          IN NUMBER,
                                 p_Benefit_Cats   IN t_Benefit_Cats)
    IS
        v_Nbc_Id    NUMBER (14);
        v_Scbc_Id   Sc_Benefit_Category.Scbc_Id%TYPE;
    BEGIN
        FOR i IN 1 .. p_Benefit_Cats.COUNT
        LOOP
            SELECT Nbc_Id
              INTO v_Nbc_Id
              FROM Uss_Ndi.v_Ndi_Benefit_Category c
             WHERE c.Nbc_Code = p_Benefit_Cats (i).CatCode;

            --збереження пільгової категорії
            IF v_Nbc_Id IS NOT NULL
            THEN
                Api$socialcard.Set_Sc_Benefits (
                    p_Scbc_Sc         => p_Sc_Id,
                    p_Scbc_Nbc        => v_Nbc_Id,
                    p_Scbc_Start_Dt   => p_Benefit_Cats (i).Catfromdt,
                    p_Scbc_Stop_Dt    => p_Benefit_Cats (i).Cattilldt,
                    p_Scbc_Src        => '14',
                    p_Scbc_Id         => v_Scbc_Id);

                --збереження документів які підтверджують пільгову категорію
                IF v_Scbc_Id IS NOT NULL
                THEN
                    FOR j IN 1 .. p_Benefit_Cats (i).AproveDocs.COUNT
                    LOOP
                        DECLARE
                            l_Doc_Id    NUMBER;
                            l_Dh_Id     NUMBER;
                            l_Scd_Id    NUMBER;
                            l_Ndt_Id    NUMBER;
                            l_Attrs     Api$socialcard.t_Doc_Attrs;
                            l_Ndt_Ndc   Uss_Ndi.v_Ndi_Document_Type.Ndt_Ndc%TYPE;
                        BEGIN
                            l_Ndt_Id :=
                                Uss_Ndi.Tools.Decode_Dict (
                                    p_Nddc_Tp     => 'NDT_ID',
                                    p_Nddc_Src    => 'VST',
                                    p_Nddc_Dest   => 'USS',
                                    p_Nddc_Code_Src   =>
                                        p_Benefit_Cats (i).AproveDocs (j).Doc_Ndt);

                            IF l_Ndt_Id IS NULL
                            THEN
                                CONTINUE;
                            END IF;

                            SELECT Nda_Id,
                                   Val_Str,
                                   Val_Dt,
                                   Val_Int,
                                   NULL     AS Val_Id
                              BULK COLLECT INTO l_Attrs
                              FROM (SELECT Uss_Ndi.Tools.Decode_Dict (
                                               p_Nddc_Tp         => 'NDA_ID',
                                               p_Nddc_Src        => 'VST',
                                               p_Nddc_Dest       => 'USS',
                                               p_Nddc_Code_Src   => Nda_Id)
                                               AS Nda_Id,
                                           Val_Str,
                                           Val_Dt,
                                           Val_Int
                                      FROM TABLE (
                                               p_Benefit_Cats (i).AproveDocs (
                                                   j).Attributes))
                             WHERE Nda_Id IS NOT NULL;

                            SELECT MAX (Ndt_Ndc)
                              INTO l_Ndt_Ndc
                              FROM Uss_Ndi.v_Ndi_Document_Type
                             WHERE Ndt_Id = l_Ndt_Id;

                            --Ідентифікаційні документи та відмову від РНОКПП - не змінюємо цим завантаженням. #92013
                            IF     l_Ndt_Ndc IS NOT NULL
                               AND l_Ndt_Ndc <> 13
                               AND l_Ndt_Id <> 10117
                            THEN
                                Api$socialcard.Save_Document (
                                    p_Sc_Id         => p_Sc_Id,
                                    p_Ndt_Id        => l_Ndt_Id,
                                    p_Doc_Attrs     => l_Attrs,
                                    p_Src_Id        => '14',
                                    p_Src_Code      => 'VST',
                                    p_Scd_Note      => NULL,
                                    p_Scd_Id        => l_Scd_Id,
                                    p_Doc_Id        => l_Doc_Id,
                                    p_Dh_Id         => l_Dh_Id,
                                    p_Set_Feature   => TRUE);

                                Save_Doc_Attachments (
                                    p_Dh_Id   => l_Dh_Id,
                                    p_Files   =>
                                        p_Benefit_Cats (i).AproveDocs (j).Files);

                                --збереження розвязки
                                IF l_Scd_Id IS NOT NULL
                                THEN
                                    INSERT INTO Sc_Benefit_Docs (Scbd_Id,
                                                                 Scbd_Scbc,
                                                                 Scbd_Scd)
                                         VALUES (0, v_Scbc_Id, l_Scd_Id);
                                END IF;
                            END IF;
                        END;
                    END LOOP;

                    --проставити дату початку/закінчення дії пільг на підставі документів
                    Set_Sc_Benefit_Stop_Dt (p_Scbc_Id => v_Scbc_Id);
                END IF;

                -- #95404-23 Дані щодо подовження строку дії пільг по ПКМУ389
                IF    p_Benefit_Cats (i).Incomesdt IS NOT NULL
                   OR p_Benefit_Cats (i).Incomesbenefit IS NOT NULL
                THEN
                    Save_Benefit_Extend (p_Sc_Id, p_Benefit_Cats (i));
                END IF;
            END IF;
        END LOOP;
    END;

    PROCEDURE Save_Adress (p_Adress   IN XMLTYPE,
                           p_Sc_Id    IN Sc_Address.Sca_Sc%TYPE --id соц.карти
                                                               )
    IS
        CURSOR Cur IS
                  SELECT t.*,
                         Kt.Kaot_Id,
                         Kt.Kaot_Kaot_L1,
                         Kt.Kaot_Tp,
                         NULL     Adr_Upd_Dt                      --, null Src
                    FROM XMLTABLE (
                             '/Address/row'
                             PASSING p_Adress
                             COLUMNS Addr_Tp      VARCHAR2 (1) PATH 'Addr_Tp',
                                     --тип адреси 3- регистрації, 2-проживання, 4- Місце проживання пільговика
                                     Kt_Code      VARCHAR2 (100) PATH 'Kt_Code',
                                     Country      VARCHAR2 (250) PATH 'Country',
                                     Region       VARCHAR2 (250) PATH 'Region',
                                     District     VARCHAR2 (250) PATH 'District',
                                     Postcode     VARCHAR2 (10) PATH 'Postcode',
                                     City         VARCHAR2 (250) PATH 'City',
                                     Street       VARCHAR2 (250) PATH 'Street',
                                     Street_Id    NUMBER (10) PATH 'Street_id',
                                     Building     VARCHAR2 (50) PATH 'Building',
                                     Block_       VARCHAR2 (50) PATH 'Block',
                                     Apartment    VARCHAR2 (50) PATH 'Apartment',
                                     /*Adr_Upd_Dt DATE Path 'adr_upd_dt', --дата зміни адреси
                                     Src VARCHAR2(25) Path 'src',*/
                                     Note         VARCHAR2 (250) PATH 'Note') t,
                         Uss_Ndi.v_Ndi_Katottg Kt
                   WHERE Kt.Kaot_Code(+) = t.Kt_Code;

        c          Cur%ROWTYPE;

        l_Sca_Id   NUMBER;
    BEGIN
        OPEN Cur;

        FETCH Cur INTO c;

        CLOSE Cur;

        Uss_Person.Api$socialcard.Save_Sc_Address (
            p_Sca_Sc          => p_Sc_Id,
            p_Sca_Tp          => c.Addr_Tp, -- тип "Місце проживання пільговика" = USS_NDI.V_DDN_SCA_TP
            p_Sca_Kaot        => c.Kaot_Id,
            p_Sca_Nc          => NULL,
            p_Sca_Country     => 'УКРАЇНА',
            p_Sca_Region      => c.Region,
            p_Sca_District    => c.District,
            p_Sca_Postcode    => c.Postcode,
            p_Sca_City        => c.City,
            p_Sca_Street      => c.Street,
            p_Sca_Building    => c.Building,
            p_Sca_Block       => c.Block_,
            p_Sca_Apartment   => c.Apartment,
            p_Sca_Note        => c.Note,
            p_Sca_Src         => c_Src_Pfu,                            --c.Src
            p_Sca_Create_Dt   => NVL (c.Adr_Upd_Dt, SYSDATE),
            o_Sca_Id          => l_Sca_Id);
    END Save_Adress;

    FUNCTION Get_Katottg_Id (p_Kt_Code IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Res   NUMBER (14);
    BEGIN
        SELECT t.Kaot_Id
          INTO l_Res
          FROM Uss_Ndi.v_Ndi_Katottg t
         WHERE t.Kaot_Code = p_Kt_Code;

        RETURN l_Res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END Get_Katottg_Id;

    FUNCTION Get_Street_Name (p_Sreet_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (250);
    BEGIN
        SELECT t.ns_name
          INTO l_Res
          FROM uss_ndi.v_ndi_street t
         WHERE t.ns_id = p_Sreet_Id;

        RETURN l_Res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END Get_Street_Name;

    -------------------------------------------------------------------------------
    --   Обробка запиту від ПФУ на збереження категорій пільговика
    -------------------------------------------------------------------------------
    FUNCTION Handle_Put_Benefit_Cat_Req (p_Request_Id     IN NUMBER,
                                         p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Request           r_Save_Person_Benefit_Cats_Req;
        l_Sc_Id             NUMBER;
        l_Xml_Technanswer   XMLTYPE;
        l_Clob              CLOB;
        l_Answercode        NUMBER;
        l_Answermessage     VARCHAR2 (4000);
        l_Invalid_Ipn       BOOLEAN := FALSE;
        l_Scdi_Id           sc_pfu_data_ident.scdi_id%TYPE;
        l_Scbc_Row          sc_benefit_category%ROWTYPE;
        l_Scpa_Id           sc_pfu_address.scpa_id%TYPE;
        l_Scpf_Id           sc_scpp_family.scpf_id%TYPE;
        l_Rn_Id             NUMBER (14);
    BEGIN
        BEGIN
            --Парсимо запит
            EXECUTE IMMEDIATE Type2xmltable (
                                 Package_Name,
                                 'R_SAVE_PERSON_BENEFIT_CATS_REQ',
                                 'dd.mm.yyyy')
                USING IN p_Request_Body, OUT l_Request;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        Save_Sc_Pfu_Data_Ident (p_Person_Info   => l_Request.Person_Info,
                                p_Ur_Id         => p_Request_Id,
                                p_Scdi_Id       => l_Scdi_Id);

        IF l_Request.Documents IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'В запиті відсутні дані документів що посвідчують особу.');
        ELSE
            FOR i IN 1 .. l_Request.Documents.COUNT
            LOOP
                DECLARE
                    l_Scpo_Id   sc_pfu_document.scpo_id%TYPE;
                BEGIN
                    Save_Sc_Pfu_Document (
                        p_Sc_Id      => NULL,
                        p_Scdi_Id    => l_Scdi_Id,
                        p_Document   => l_Request.Documents (i),
                        p_Scpo_Id    => l_Scpo_Id);
                END;
            END LOOP;
        END IF;

        IF l_Request.BenefitCats IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'В запиті відсутні дані щодо пільгових категорій.');
        ELSE
            FOR i IN 1 .. l_Request.BenefitCats.COUNT
            LOOP
                l_Scbc_Row :=
                    Save_Benefit_Cat_Pre_Vf (
                        p_Benefit_Cat   => l_Request.BenefitCats (i),
                        p_Scdi_Id       => l_Scdi_Id,
                        p_Src           => c_Src_Pfu);

                -- #95404-23 Дані щодо подовження строку дії пільг по ПКМУ389
                IF    l_Request.BenefitCats (i).IncomesDt IS NOT NULL
                   OR l_Request.BenefitCats (i).IncomesBenefit IS NOT NULL
                THEN
                    INSERT INTO sc_benefit_extend (scbe_extend_dt,
                                                   scbe_is_fa_calculated,
                                                   scbe_is_have_sb_right,
                                                   scbe_create_dt,
                                                   scbe_scbs,
                                                   scbe_nbc,
                                                   scbe_scdi,
                                                   scbe_scpp,
                                                   scbe_scpf,
                                                   scbe_st)
                             VALUES (
                                        l_Request.BenefitCats (i).IncomesDt,
                                        NULL,
                                        DECODE (
                                            l_Request.BenefitCats (i).IncomesBenefit,
                                            1, 'T',
                                            0, 'F',
                                            NULL),
                                        SYSDATE,
                                        NULL,
                                        l_Scbc_Row.Scbc_Nbc,
                                        l_Scdi_Id,
                                        NULL,
                                        NULL,
                                        c_St_Vf_Rq);
                END IF;
            END LOOP;
        END IF;

        -- Адреси особи
        IF l_Request.Address IS NOT NULL
        THEN
            FOR i IN 1 .. l_Request.Address.COUNT
            LOOP
                DECLARE
                    l_Scpa_Id   NUMBER;
                BEGIN
                    Api$socialcard_Ext.Save_Address (
                        p_Scpa_Id          => l_Scpa_Id,
                        p_Scpa_Sc          => NULL,
                        p_Scpa_Scdi        => l_Scdi_Id,
                        p_Scpa_Tp          => l_Request.Address (i).Addr_Tp,
                        p_Scpa_Kaot_Code   => l_Request.Address (i).Kt_Code,
                        p_Scpa_Postcode    => l_Request.Address (i).Postcode,
                        p_Scpa_City        => l_Request.Address (i).City,
                        p_Scpa_Street      => l_Request.Address (i).Street,
                        p_Scpa_Building    => l_Request.Address (i).Building,
                        p_Scpa_Block       => l_Request.Address (i).Block_,
                        p_Scpa_Apartment   => l_Request.Address (i).Apartment);
                END;
            END LOOP;
        END IF;

        -- Інформація про сім’ю
        IF l_Request.Familyinfo IS NOT NULL
        THEN
            FOR i IN 1 .. l_Request.Familyinfo.COUNT
            LOOP
                l_Scpf_Id :=
                    Save_Sc_Scpp_Family (
                        p_Family_Prs   => l_Request.Familyinfo (i),
                        p_Scdi_Id      => l_Scdi_Id,
                        p_Un_Id        => p_Request_Id);
            END LOOP;
        END IF;

        /*   serhii: не маємо для цього Sc_Id
        --Реєструємо запит до Мінвету
        Dnet$exch_Mve.Reg_Create_Vet_Req(p_Sc_Id => l_Sc_Id);
         */

        SELECT XMLELEMENT (
                   "TECHNANSWER",
                   XMLELEMENT ("ANSWERCODE", COALESCE (l_Answercode, 0)),
                   XMLELEMENT ("ANSWERMESSAGE", l_Answermessage))
          INTO l_Xml_Technanswer
          FROM DUAL;

        l_Clob := l_Xml_Technanswer.Getclobval ();
        RETURN l_Clob;
    END;

    --#95391, IKIS.Common.GetAvgMonthIncome
    --Сервіс запит на розрахунок середньомісячного сукупного доходу сім’ї пільговика
    PROCEDURE Run_Get_Avg_Month_Income
    IS
        l_month_count   NUMBER;
        l_calc_dt       DATE;
        l_start_dt      DATE;
        l_stop_dt       DATE;

        CURSOR l_cur (calc_dt IN DATE)
        IS
            SELECT s.scpp_id
              FROM sc_pfu_pay_summary s
             WHERE     (   s.scpp_pfu_pd_stop_dt IS NULL
                        OR s.scpp_pfu_pd_stop_dt > calc_dt) --Дія рішення актуальна
                   AND s.scpp_pfu_pd_st = 'S'   --Рішення у статусі нараховано
                   AND NVL (s.history_status, 'A') = 'A' --Рішення не історичне
                   AND (s.scpp_stop_dt IS NULL OR s.scpp_stop_dt > calc_dt) --Дія пільги актуальна
                   AND s.scpp_suspended_dt IS NULL    --Рішення не призупинено
                   AND EXISTS
                           (SELECT 1
                              FROM uss_person.sc_scpp_family f
                             WHERE     f.scpf_scpp = s.scpp_id
                                   AND NVL (f.history_status, 'A') = 'A'
                                   AND EXISTS
                                           (SELECT 1
                                              FROM uss_person.sc_benefit_category
                                                   bc
                                             WHERE     NVL (bc.scbc_st, 'A') IN
                                                           ('A',
                                                            'VR',
                                                            'VW',
                                                            'VO') --окрім архівних та неуспішної верифікації
                                                   AND bc.scbc_sc = f.scpf_sc
                                                   AND bc.scbc_nbc IN
                                                           (SELECT nbc_id
                                                              FROM uss_ndi.v_ndi_benefit_category
                                                             WHERE nbc_income_check =
                                                                   'T')
                                                   AND (   bc.scbc_stop_dt
                                                               IS NULL
                                                        OR bc.scbc_stop_dt >
                                                           calc_dt)));

        l_scpp_list     OWA_UTIL.num_arr;
    BEGIN
        --Подовження виконується з 01 січня до кінця року, тому дохід береться за попередні 6 місяців (з червня по грудень включно
        l_month_count := 6;
        l_calc_dt := TRUNC (SYSDATE, 'DD');
        l_stop_dt := LAST_DAY (ADD_MONTHS (l_calc_dt, -1));
        l_start_dt :=
            TRUNC (ADD_MONTHS (l_stop_dt, -1 * l_month_count), 'MM');

        OPEN l_cur (l_calc_dt);

        LOOP
            FETCH l_cur BULK COLLECT INTO l_scpp_list LIMIT 50;

            Register_Get_Avg_Month_Income (p_scpp_list   => l_scpp_list,
                                           p_start_dt    => l_start_dt,
                                           p_stop_dt     => l_stop_dt);

            EXIT WHEN l_cur%NOTFOUND;
        END LOOP;

        CLOSE l_cur;
    END;

    -- #95391 - Реєстрація запиту на розрахунок середньомісячного сукупного доходу сім’ї пільговика в ПФУ
    PROCEDURE Register_Get_Avg_Month_Income (
        p_scpp_list   IN OWA_UTIL.num_arr,
        p_start_dt    IN DATE,
        p_stop_dt     IN DATE)
    IS
        l_frm_date    VARCHAR2 (20) := 'yyyy-mm-dd';
        l_frm_money   VARCHAR2 (20) := 'FM999999999999990D90';

        l_body        CLOB;
        l_ur_id       NUMBER;
        l_rn_id       NUMBER;
    BEGIN
        DBMS_LOB.Createtemporary (Lob_Loc => l_body, Cache => TRUE);
        DBMS_LOB.Open (Lob_Loc => l_body, Open_Mode => DBMS_LOB.Lob_Readwrite);
        DBMS_LOB.Append (l_body, '<GetAvgMonthIncomeRequest>');

        FOR i IN 1 .. p_scpp_list.COUNT
        LOOP
            DECLARE
                l_incomes       uss_person.dnet$exch_uss2ikis.t_incomes;
                l_xml_incomes   XMLTYPE;
                l_family_info   XMLTYPE;
                l_xml           XMLTYPE;
            BEGIN
                FOR c
                    IN (SELECT scpf.scpf_sc                 AS x_sc,
                               TO_NUMBER (sco_numident)     AS x_numident,
                               (  SELECT TO_CHAR (d.scd_ndt)
                                    FROM uss_person.v_sc_document d
                                         JOIN uss_ndi.v_ndi_document_type dt
                                             ON d.scd_ndt = dt.ndt_id
                                   WHERE     d.scd_sc = sco_id
                                         AND dt.ndt_ndc = 13
                                         AND d.scd_st = '1'
                                ORDER BY d.scd_ndt, d.scd_id ASC
                                   FETCH FIRST ROW ONLY)    AS x_doc_type,
                               (  SELECT d.scd_seria || d.scd_number
                                    FROM uss_person.v_sc_document d
                                         JOIN uss_ndi.v_ndi_document_type dt
                                             ON d.scd_ndt = dt.ndt_id
                                   WHERE     d.scd_sc = sco_id
                                         AND dt.ndt_ndc = 13
                                         AND d.scd_st = '1'
                                ORDER BY d.scd_ndt, d.scd_id ASC
                                   FETCH FIRST ROW ONLY)    AS x_doc_num,
                               sco_fn                       AS x_fn,
                               sco_mn                       AS x_mn,
                               sco_ln                       AS x_ln,
                               sco_birth_dt                 AS x_birth_dt
                          FROM uss_person.sc_scpp_family  scpf,
                               uss_person.v_sc_info       sco
                         WHERE     scpf.scpf_scpp = p_scpp_list (i)
                               AND NVL (scpf.history_status, 'A') = 'A'
                               AND scpf_sc IS NOT NULL
                               AND scpf_sc = sco_id
                        UNION ALL
                        SELECT NULL                   AS x_sc,
                               scdi.scdi_numident     AS x_numident,
                               scdi.scdi_doc_tp       AS x_doc_type,
                               scdi.scdi_doc_sn       AS x_doc_num,
                               scdi.scdi_fn           AS x_fn,
                               scdi.scdi_mn           AS x_mn,
                               scdi.scdi_ln           AS x_ln,
                               scdi.scdi_birthday     AS x_birth_dt
                          FROM uss_person.sc_scpp_family     scpf,
                               uss_person.sc_pfu_data_ident  scdi
                         WHERE     scpf.scpf_scpp = p_scpp_list (i)
                               AND NVL (scpf.history_status, 'A') = 'A'
                               AND scpf_sc IS NULL
                               AND scpf_scdi = scdi.scdi_id)
                LOOP
                    IF c.x_sc IS NOT NULL
                    THEN
                        Get_Sc_Incomes (c.x_sc,
                                        p_start_dt,
                                        p_stop_dt,
                                        l_Incomes);
                    END IF;

                    SELECT XMLELEMENT (
                               "Incomes",
                               (SELECT XMLAGG (XMLELEMENT (
                                                   "row",
                                                   XMLFOREST (
                                                       TO_CHAR (startdt,
                                                                l_frm_date)
                                                           AS "StartDt",
                                                       TO_CHAR (stopdt,
                                                                l_frm_date)
                                                           AS "StopDt",
                                                       paycode AS "PayCode",
                                                       TO_CHAR (
                                                           sum_val,
                                                           l_frm_money,
                                                           'NLS_NUMERIC_CHARACTERS=''. ''')
                                                           AS "Sum"))
                                               ORDER BY paycode, startdt)
                                  FROM TABLE (l_incomes) t))
                      INTO l_xml_incomes
                      FROM DUAL;

                    SELECT XMLCONCAT (
                               l_family_info,
                               XMLELEMENT (
                                   "row",
                                   XMLELEMENT ("KSS", NULL),
                                   XMLELEMENT ("Numident", c.x_numident),
                                   XMLELEMENT ("Doc_Type", c.x_doc_type),
                                   XMLELEMENT ("Doc_Num", c.x_doc_num),
                                   XMLELEMENT ("Fn", c.x_fn),
                                   XMLELEMENT ("Mn", c.x_mn),
                                   XMLELEMENT ("Ln", c.x_ln),
                                   XMLELEMENT (
                                       "Birthday",
                                       TO_CHAR (c.x_birth_dt, l_frm_date)),
                                   l_xml_incomes))
                      INTO l_family_info
                      FROM DUAL;
                END LOOP;

                SELECT XMLELEMENT ("row",
                                   XMLELEMENT ("Id", p_scpp_list (i)),
                                   XMLELEMENT ("FamilyInfo", l_family_info))
                  INTO l_xml
                  FROM DUAL;

                DBMS_LOB.Append (l_body, l_xml.getclobval ());
                DBMS_LOB.Append (l_body, CHR (10));
            END;
        END LOOP;

        DBMS_LOB.Append (l_body, '</GetAvgMonthIncomeRequest>');

        --Реєструємо запит в черзі Трембіти
        ikis_rbm.api$request_pfu.Run_Get_Avg_Month_Income (
            p_Body           => l_body,
            p_Period_Start   => p_start_dt,
            p_Period_Stop    => p_stop_dt,
            p_Rn_Id          => l_rn_id);
    END;

    --#95392, USS.Common.PutAvgMonthIncome
    --Сервіс отримання результату розрахунку середньомісячного сукупного доходу сім’ї пільговика
    FUNCTION Handle_Put_Avg_Month_Income_Req (p_Ur_Id     IN NUMBER,  --ignore
                                              p_Request   IN CLOB)
        RETURN CLOB
    IS
        l_Rn_Id    NUMBER;
        l_Result   NUMBER := 1; /*1 - оновлення виконано успішно чи від'ємний код помилки*/
        l_Error    VARCHAR2 (32000);
        l_Clob     CLOB;
    BEGIN
        IF (p_Request IS NULL) OR (DBMS_LOB.Getlength (p_Request) = 0)
        THEN
            Raise_Application_Error (-20000, 'Вхідний запит пустий');
        END IF;

        --Запит може бути як окремий тільки на одну особу (Id - пусте)
        --Запит може надавати пільгу на всіх членів сімї (Id - присутній, бо це буде відовідь на IKIS.Common.GetAvgMonthIncome)

        --якщо категорій декілька дані будуть відправлятися атомарно

        DBMS_LOB.Createtemporary (Lob_Loc => l_Clob, Cache => TRUE);
        DBMS_LOB.Open (Lob_Loc => l_Clob, Open_Mode => DBMS_LOB.Lob_Readwrite);
        DBMS_LOB.Append (l_Clob, '<PutAvgMonthIncomeResponse>');

        FOR c
            IN (             SELECT id,
                                    USSId,
                                    Person_Info,
                                    CatCode,
                                    TO_DATE (IncomesBenefitDt, 'dd-mm-yyyy')
                                        IncomesBenefitDt,
                                    IncomesBenefit,
                                    ROWNUM
                               FROM XMLTABLE (
                                        '*/row'
                                        PASSING xmltype (p_Request)
                                        COLUMNS id                  NUMBER PATH 'Id',
                                                USSId               NUMBER PATH 'USSId',
                                                Person_Info         XMLTYPE PATH 'Person_Info',
                                                CatCode             VARCHAR2 (10) PATH 'CatCode',
                                                IncomesBenefitDt    VARCHAR2 (50) PATH 'IncomesBenefitDt',
                                                IncomesBenefit      NUMBER PATH 'IncomesBenefit'))
        LOOP
            SAVEPOINT Svp_Handle_Put_Subsidy_Benefit;

            DECLARE
                l_Sc_Id     Sc_Pfu_Data_Ident.Scdi_Sc%TYPE;
                l_Scdi_Id   Sc_Pfu_Data_Ident.Scdi_Id%TYPE;
                l_Nbc_Id    OWA_UTIL.num_arr;
            BEGIN
                l_Result := NULL;
                l_Error := NULL;

                SELECT Nbc_Id
                  BULK COLLECT INTO l_Nbc_Id
                  FROM Uss_Ndi.v_Ndi_Benefit_Category c
                 WHERE c.Nbc_Code IN (    SELECT REGEXP_SUBSTR (c.CatCode,
                                                                '[^,]+',
                                                                1,
                                                                LEVEL)    AS CatCode
                                            FROM DUAL
                                      CONNECT BY REGEXP_SUBSTR (c.CatCode,
                                                                '[^,]+',
                                                                1,
                                                                LEVEL)
                                                     IS NOT NULL);

                --При відсутності категорій створюємо пусту
                IF l_Nbc_Id.COUNT = 0
                THEN
                    l_Nbc_Id (1) := NULL;
                END IF;

                IF c.USSId IS NULL
                THEN
                    --пільга діє в рамках індивідуального розрахунку по особі в Person_Info
                    Save_Sc_Pfu_Data_Ident (p_Person_Info   => c.Person_Info,
                                            p_Ur_Id         => p_Ur_Id,
                                            p_Scdi_Id       => l_Scdi_Id,
                                            p_Sc_Id         => l_Sc_Id);

                    --Наявність соц.картки заявника критична
                    IF l_Sc_Id IS NULL
                    THEN
                        Raise_Application_Error (
                            -20001,
                            'Помилка пошуку соціальної картки (sc_id)');
                        CONTINUE;
                    END IF;

                    FOR n IN 1 .. l_Nbc_Id.COUNT
                    LOOP
                        Save_Benefit_Extend (
                            p_Sc_Id              => l_Sc_Id,
                            p_Scdi_Id            => l_Scdi_Id,
                            p_Extend_Dt          => c.IncomesBenefitDt,
                            p_Is_Have_Sb_Right   =>
                                CASE c.Incomesbenefit
                                    WHEN 1 THEN 'T'
                                    WHEN 0 THEN 'F'
                                    ELSE NULL
                                END,
                            p_Nbc                => l_Nbc_Id (n),
                            p_Scpp_Id            => NULL,
                            p_Scpf_Id            => NULL);
                    END LOOP;
                ELSE
                    --пільга діє в рамках розрахунку по сім'ї, на основі Scpp_Id (атрибут в запиті - Id)
                    FOR j
                        IN (SELECT scpf.scpf_sc,
                                   scpf.scpf_scdi,
                                   scpf.scpf_id,
                                   scpf.scpf_scpp
                              FROM uss_person.sc_scpp_family scpf
                             WHERE     scpf.scpf_scpp = c.USSId
                                   AND NVL (scpf.history_status, 'A') = 'A')
                    LOOP
                        FOR n IN 1 .. l_Nbc_Id.COUNT
                        LOOP
                            Save_Benefit_Extend (
                                p_Sc_Id              => j.scpf_sc,
                                p_Scdi_Id            => j.scpf_scdi,
                                p_Extend_Dt          => c.IncomesBenefitDt,
                                p_Is_Have_Sb_Right   =>
                                    CASE c.Incomesbenefit
                                        WHEN 1 THEN 'T'
                                        WHEN 0 THEN 'F'
                                        ELSE NULL
                                    END,
                                p_Nbc                => l_Nbc_Id (n),
                                p_Scpp_Id            => j.scpf_scpp,
                                p_Scpf_Id            => j.scpf_id);
                        END LOOP;
                    END LOOP;
                END IF;

                l_Result := 1;                           /*оновлення успішно*/
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK TO Svp_Handle_Put_Subsidy_Benefit;

                    l_Result := SQLCODE;
                    l_Error := SQLERRM;

                    --помилка ORA
                    IF l_Result > -20000
                    THEN
                        l_Error :=
                               l_Error
                            || CHR (10)
                            || DBMS_UTILITY.Format_Error_Backtrace;
                    END IF;

                    ikis_rbm.Api$uxp_Request.Save_Request_Error (
                        p_Ure_Ur        => p_Ur_Id,
                        p_Ure_Row_Id    => c.Id,
                        p_Ure_Row_Num   => c.ROWNUM,
                        p_Ure_Error     => l_Error);
            END;

            --результат обробки
            DBMS_LOB.Append (
                l_Clob,
                   '<row>'
                || '<Id>'
                || c.Id
                || '</Id>'
                || '<Result>'
                || l_Result
                || '</Result>'
                || '<Error>'
                || l_Error
                || '</Error>'
                || '</row>'
                || CHR (10));
        END LOOP;

        DBMS_LOB.Append (l_Clob, '</PutAvgMonthIncomeResponse>');

        RETURN l_Clob;
    END;

    PROCEDURE Create_Socialcard (p_Request_Body            XMLTYPE,
                                 p_main_ip_unique   IN OUT VARCHAR2)
    IS
        l_Cnt_Pers   INTEGER := 0;
        l_Sc_Id      Socialcard.Sc_Id%TYPE;             --Ід соціальної картки
        l_Request    Dnet$exch_Uss2ikis.r_Save_Person_Benefit_Cats_Req; --для соц.картки
        l_IsFirst    BOOLEAN := TRUE;
    BEGIN
        FOR c
            IN (             SELECT Personinfo,
                                    Aprp_Marital_St,
                                    Aprp_Fml_Rltn_Tp,
                                    sex,
                                    birth_dt,
                                    numident,
                                    pass_serial,
                                    pass_number
                               FROM XMLTABLE (
                                        'PersInfo/row'
                                        PASSING p_Request_Body
                                        COLUMNS Personinfo          XMLTYPE PATH 'SocialCard',
                                                Ip_Unique           VARCHAR2 (250) PATH 'ip_unique',
                                                Aprp_Marital_St     VARCHAR2 (250) PATH 'aprp_marital_st',
                                                Aprp_Fml_Rltn_Tp    VARCHAR2 (250) PATH 'aprp_fml_rltn_tp',
                                                sex                 VARCHAR2 (250) PATH 'sex',
                                                birth_dt            VARCHAR2 (250) PATH 'birth_dt',
                                                numident            VARCHAR2 (250) PATH 'numident',
                                                pass_serial         VARCHAR2 (250) PATH 'pass_serial',
                                                pass_number         VARCHAR2 (250) PATH 'pass_number'))
        LOOP
            l_Request := NULL;
            l_Sc_Id := NULL;

            BEGIN
                --Парсимо запит
                EXECUTE IMMEDIATE Type2xmltable (
                                     Dnet$exch_Uss2ikis.Package_Name,
                                     'R_SAVE_PERSON_BENEFIT_CATS_REQ',
                                     'dd.mm.yyyy')
                    USING IN c.Personinfo.Getclobval (), OUT l_Request;
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_Application_Error (
                        -20020,
                        'Помилка парсингу запиту: ' || SQLERRM);
            END;

            IF l_Request.Person_Info.General.Ip_Unique IS NULL
            THEN
                --У запиті відсутній ПЕОКЗО
                CONTINUE;
            END IF;

            SELECT MAX (Sc.Sc_Id)
              INTO l_Sc_Id
              FROM Socialcard Sc
             WHERE     Sc.Sc_Unique = l_Request.Person_Info.General.Ip_Unique
                   AND Sc.Sc_St = '1';

            --Якщо соцкарту не знайдено по ПЕОКЗО
            IF l_Sc_Id IS NULL
            THEN
                DECLARE
                    l_Sc_Id2      NUMBER;
                    l_Inn_Attrs   Dnet$exch_Uss2ikis.t_Doc_Attrs;
                    l_Pasp        Dnet$exch_Uss2ikis.r_Document;
                    l_Sc_Unique   VARCHAR2 (100)
                        := l_Request.Person_Info.General.Ip_Unique;
                    l_Doc_Ser     VARCHAR2 (10);
                    l_Doc_Num     VARCHAR2 (50);
                    l_IPN         VARCHAR2 (20);
                    l_Birthday    DATE;
                    l_Gender      VARCHAR2 (20);
                BEGIN
                    --дані з документів
                    l_Inn_Attrs :=
                        Get_Document (l_Request.Documents, 5).Attributes;
                    l_Pasp := Get_Document (l_Request.Documents, 6);

                    IF l_Pasp.Attributes IS NULL
                    THEN
                        l_Pasp := Get_Document (l_Request.Documents, 7);
                    END IF;

                    l_Doc_Num := Get_Attr_Val_Str (l_Pasp.Attributes, 'DSN');

                    l_IPN := Get_Attr_Val_Str (l_Inn_Attrs, 'DSN');
                    l_Birthday := l_Request.Person_Info.General.Birthday;
                    l_Gender :=
                        Uss_Ndi.Tools.Decode_Dict_Reverse (
                            p_Nddc_Tp     => 'GENDER',
                            p_Nddc_Src    => 'VST',
                            p_Nddc_Dest   => 'RZO',
                            p_Nddc_Code_Dest   =>
                                l_Request.Person_Info.General.Sex);

                    --якщо у документах відсутні дані:
                    l_IPN := NVL (l_IPN, c.numident);

                    IF l_Doc_Num IS NULL
                    THEN
                        IF c.pass_serial IS NULL
                        THEN
                            l_Pasp.Doc_Ndt := 7;                   --id картка
                        ELSE
                            l_Pasp.Doc_Ndt := 6;                     --паспорт
                        END IF;

                        --l_Doc_Ser:= c.pass_serial;
                        l_Doc_Num := c.pass_serial || c.pass_number;

                        IF l_Doc_Num IS NULL
                        THEN
                            l_Pasp.Doc_Ndt := NULL;
                        END IF;

                        l_Gender := NVL (l_Gender, c.sex);
                    END IF;

                    Split_Doc_Number (p_Ndt_Id       => l_Pasp.Doc_Ndt,
                                      p_Doc_Number   => l_Doc_Num,
                                      p_Doc_Serial   => l_Doc_Ser);

                    --#98448 3. При створенні та пошуку картки РНОКПП доповнювати спереду нулями якщо кількість цифр менша 10
                    IF l_IPN IS NOT NULL
                    THEN
                        l_IPN := LPAD (l_IPN, 10, '0');
                    END IF;

                    --#98448 2. ПРи уcпішному результат пошуку персональні дані (ПІБ, РНОКПП, Документ, ДР) не оновлювати
                    --Шукаємо картку
                    l_Sc_Id :=
                        Load$socialcard.Load_Sc (
                            p_Fn          =>
                                Clear_Name (l_Request.Person_Info.General.Fn),
                            p_Ln          =>
                                Clear_Name (l_Request.Person_Info.General.LN),
                            p_Mn          =>
                                Clear_Name (l_Request.Person_Info.General.Mn),
                            p_Gender      => l_Gender,
                            p_Nationality   =>
                                l_Request.Person_Info.General.Nt,
                            p_Src_Dt      =>
                                Get_Attr_Val_Dt (l_Pasp.Attributes, 'DGVDT'),
                            p_Birth_Dt    => l_Birthday,
                            p_Inn_Num     => l_IPN,
                            p_Inn_Ndt     => 5,
                            p_Doc_Ser     => l_Doc_Ser,
                            p_Doc_Num     => l_Doc_Num,
                            p_Doc_Ndt     => l_Pasp.Doc_Ndt,
                            p_Src         => Dnet$exch_Uss2ikis.c_Src_Queue,
                            p_Sc_Unique   => l_Sc_Unique,
                            p_Sc          => l_Sc_Id2,
                            p_Mode        => Load$socialcard.c_Mode_Search);

                    --картку не знайшли, спроба створити нову
                    IF COALESCE (l_Sc_Id, -1) < 1
                    THEN
                        l_Sc_Id :=
                            Load$socialcard.Load_Sc (
                                p_Fn          =>
                                    Clear_Name (
                                        l_Request.Person_Info.General.Fn),
                                p_Ln          =>
                                    Clear_Name (
                                        l_Request.Person_Info.General.LN),
                                p_Mn          =>
                                    Clear_Name (
                                        l_Request.Person_Info.General.Mn),
                                p_Gender      => l_Gender,
                                p_Nationality   =>
                                    l_Request.Person_Info.General.Nt,
                                p_Src_Dt      =>
                                    Get_Attr_Val_Dt (l_Pasp.Attributes,
                                                     'DGVDT'),
                                p_Birth_Dt    => l_Birthday,
                                p_Inn_Num     => l_IPN,
                                p_Inn_Ndt     => 5,
                                p_Doc_Ser     => l_Doc_Ser,
                                p_Doc_Num     => l_Doc_Num,
                                p_Doc_Ndt     => l_Pasp.Doc_Ndt,
                                p_Src         => Dnet$exch_Uss2ikis.c_Src_Queue,
                                p_Sc_Unique   => l_Sc_Unique,
                                p_Sc          => l_Sc_Id2,
                                p_Mode        =>
                                    Load$socialcard.c_Mode_Search_Update_Create);
                    END IF;

                    IF COALESCE (l_Sc_Id, -1) < 1
                    THEN
                        --raise_application_error(-20011, 'Помилка пошуку/створення соцкартки');

                        IF     p_main_ip_unique =
                               l_Request.Person_Info.General.Ip_Unique
                           AND l_IsFirst
                        THEN
                            raise_application_error (
                                -20022,
                                   'Помилка Load$socialcard.Load_Sc():'
                                || ' Fn='
                                || l_Request.Person_Info.General.Fn
                                || ' Ln='
                                || l_Request.Person_Info.General.LN
                                || ' Mn='
                                || l_Request.Person_Info.General.Mn
                                || ' Gender='
                                || l_Gender
                                || ' Nationality='
                                || l_Request.Person_Info.General.Nt
                                || ' Src_Dt='
                                || TO_CHAR (
                                       Get_Attr_Val_Dt (l_Pasp.Attributes,
                                                        'DGVDT'),
                                       'dd.mm.yyyy')
                                || ' Birth_Dt='
                                || TO_CHAR (l_Birthday, 'dd.mm.yyyy')
                                || ' Inn_Num='
                                || l_IPN
                                || ' Doc_Ser='
                                || l_Doc_Ser
                                || ' Doc_Num='
                                || l_Doc_Num
                                || ' Doc_Ndt='
                                || l_Pasp.Doc_Ndt
                                || ' Sc_Unique='
                                || l_Request.Person_Info.General.Ip_Unique);
                        ELSE
                            NULL; --якщо це картки членів домогосподарства (не заявника), то не критично. на заявника перевірка в основнфй процедурі
                        END IF;
                    ELSE
                        l_Cnt_Pers := l_Cnt_Pers + 1;

                        --Зберігаємо ПЕОКЗО до соцкартки(тільки у разі, якщо вона тимчасова)
                        UPDATE Socialcard c
                           SET c.Sc_Unique =
                                   l_Request.Person_Info.General.Ip_Unique,
                               c.Sc_St = '1'
                         WHERE c.Sc_Id = l_Sc_Id AND c.Sc_St = '4';

                        --тимчасова
                        IF SQL%ROWCOUNT > 0
                        THEN
                            UPDATE Sc_Info i
                               SET i.Sco_Unique =
                                       l_Request.Person_Info.General.Ip_Unique
                             WHERE i.Sco_Id = l_Sc_Id;
                        --#98448 1. виключити з умов пошуку карти СРКО наступну умову: ЕПОКЗО (IP_UNIQUE) дорівнює ЄРР ІД (SC_UNIQUE)
                        --тому для MAIN НЕ тимчасової (Sc_St = '1'), але l_Sc_Unique <> ip_unique - заміна ip_unique ПФ на існуючий Sc_Unique МСП
                        ELSIF     p_main_ip_unique =
                                  l_Request.Person_Info.General.Ip_Unique
                              AND l_IsFirst
                        THEN
                            l_IsFirst := FALSE; --беру тільки перший вхід, бо буває декілька мусорних MAIN
                            p_main_ip_unique := l_Sc_Unique;
                        END IF;
                    END IF;
                END;
            ELSE
                l_Cnt_Pers := l_Cnt_Pers + 1;
            END IF;
        END LOOP;

        IF l_Cnt_Pers = 0
        THEN
            Raise_Application_Error (
                -20021,
                'Відсутня інформація по членах домогосподарства для створення соцкарток');
        END IF;
    END;

    --деталізація призначених виплат по рішенню
    PROCEDURE Create_Sc_Scpp_Detail (
        p_Scpp_Id      Sc_Pfu_Pay_Summary.Scpp_Id%TYPE,
        p_Sc_Id        Socialcard.Sc_Id%TYPE,
        p_Detail_Sum   XMLTYPE)
    IS
        --загальна сума призначених виплат
        l_Scpp_Sum   NUMBER := 0;
    BEGIN
        DELETE FROM Sc_Scpp_Detail d
              WHERE d.Scpd_Scpp = p_Scpp_Id;

        FOR d
            IN (       SELECT Pfu_Npt_Id,
                              Pfu_Npt_Cd,
                              Nbc.Nbc_Id,
                              TO_DATE (Start_Dt, 'dd-mm-yyyy')     Start_Dt,
                              TO_DATE (Stop_Dt, 'dd-mm-yyyy')      Stop_Dt,
                              Dp_Sum
                         FROM XMLTABLE (
                                  'detail_sum/row'
                                  PASSING p_Detail_Sum
                                  COLUMNS Pfu_Npt_Id    VARCHAR2 (50) PATH 'pfu_npt_id',
                                          Pfu_Npt_Cd    VARCHAR2 (50) PATH 'pfu_npt_cd',
                                          Nbc_Code      VARCHAR2 (50) PATH 'pfu_nbc_code', --код пільгової категорії
                                          Start_Dt      VARCHAR2 (50) PATH 'start_dt',
                                          Stop_Dt       VARCHAR2 (50) PATH 'stop_dt',
                                          Dp_Sum        VARCHAR2 (50) PATH 'dp_sum')
                              x,
                              Uss_Ndi.v_Ndi_Benefit_Category Nbc
                        WHERE Nbc.Nbc_Code(+) = x.Nbc_Code)
        LOOP
            l_Scpp_Sum := l_Scpp_Sum + NVL (d.Dp_Sum, 0);

            INSERT INTO Sc_Scpp_Detail d (Scpd_Scpp,
                                          Scpd_Sc,
                                          Scpd_Service_Tp,
                                          Scpd_Nppt,
                                          Scpd_Nbc,
                                          Scpd_Start_Dt,
                                          Scpd_Stop_Dt,
                                          Scpd_Sum)
                 VALUES (p_Scpp_Id,
                         p_Sc_Id,
                         d.Pfu_Npt_Cd,
                         d.Pfu_Npt_Id,
                         d.Nbc_Id,
                         d.Start_Dt,
                         d.Stop_Dt,
                         d.Dp_Sum);
        END LOOP;

        --загальна сума призначених виплат
        UPDATE Sc_Pfu_Pay_Summary t
           SET t.Scpp_Sum = l_Scpp_Sum
         WHERE t.Scpp_Id = p_Scpp_Id;
    END;

    -- Обробка запиту від ПФУ на збереження інформації по призначенню виплат в ПФУ
    FUNCTION Handle_Save_Pc_Decision (p_Request_Id     IN NUMBER,     --ignore
                                      p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        CURSOR Cur (p_Scpp_Pfu_Pd_Id Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Id%TYPE)
        IS
            SELECT p.Scpp_Id,
                   p.Scpp_Sc       Sc_Id,
                   --Ід соціальної картки
                   p.Scpp_Schh     Schh_Id,
                   --Ід домогосподарства
                   h.Schh_Sca      Sca_Id                          --Ід адреси
              FROM Sc_Pfu_Pay_Summary p, Sc_Household h
             WHERE     p.Scpp_Pfu_Pd_Id = p_Scpp_Pfu_Pd_Id
                   AND h.Schh_Id(+) = p.Scpp_Schh;

        r_Old              Cur%ROWTYPE;

        CURSOR Cur_Kaot (p_Kaot_Code VARCHAR2)
        IS
            SELECT t.Kaot_Id, t.Kaot_Kaot_L1, t.Kaot_Tp
              FROM Uss_Ndi.v_Ndi_Katottg t
             WHERE t.Kaot_Code = p_Kaot_Code OR t.Kaot_Koatuu = p_Kaot_Code;

        r_Kaot             Cur_Kaot%ROWTYPE;

        l_Scpp_Id          Sc_Pfu_Pay_Summary.Scpp_Id%TYPE; --Ід рядка зведеної інформації по призначенню виплат в ПФУ
        l_Sc_Id            Socialcard.Sc_Id%TYPE;       --Ід соціальної картки
        l_Schh_Id          Sc_Household.Schh_Id%TYPE;    --Ід домогосподарства
        l_Sca_Id           Sc_Address.Sca_Id%TYPE;                 --Ід адреси

        l_main_ip_unique   VARCHAR2 (100);                   -- ip_unique MAIN

        l_Sca_Tp           NUMBER; -- Тип домогосподарства 4-"Місце проживання пільговика"/5-Субсідія/пільга

        l_Cod_Res          NUMBER := 0;
        l_Error            VARCHAR2 (32000);
        l_Clob             CLOB;
    BEGIN
        IF    (p_Request_Body IS NULL)
           OR (DBMS_LOB.Getlength (p_Request_Body) = 0)
        THEN
            Raise_Application_Error (-20000, 'Вхідний запит пустий');
        END IF;

        DBMS_SESSION.Set_Nls ('NLS_NUMERIC_CHARACTERS', ''', ''');
        DBMS_SESSION.Set_Nls ('NLS_DATE_FORMAT', q'['DD.MM.RRRR']');

        DBMS_LOB.Createtemporary (Lob_Loc => l_Clob, Cache => TRUE);
        DBMS_LOB.Open (Lob_Loc => l_Clob, Open_Mode => DBMS_LOB.Lob_Readwrite);
        DBMS_LOB.Append (l_Clob, '<table>');

        FOR c
            IN (            SELECT Dul_Id, /*to_date(change_dt, 'dd-mm-yyyy')*/
                                   SYSDATE
                                       Change_Dt,
                                   Kaot,
                                   Postcode,
                                   District,
                                   Region,
                                   City,
                                   Street,
                                   Building,
                                   BLOCK,
                                   Apartment,
                                   Full_Area,
                                   Heating_Area,
                                   NVL (TO_DATE (Adres_Upd_Dt, 'dd-mm-yyyy'), SYSDATE)
                                       Adres_Upd_Dt,
                                   Schh_Id,
                                   Ip_Unique,
                                   Pfu_Pd_Id,
                                   Pfu_Pd_Num,
                                   TO_DATE (Pfu_Pd_Dt, 'dd-mm-yyyy')
                                       Pfu_Pd_Dt,
                                   Pfu_Pd_St,
                                   Pd_Pay_Tp,
                                   TO_DATE (Pfu_Pd_Start_Dt, 'dd-mm-yyyy')
                                       Pfu_Pd_Start_Dt,
                                   TO_DATE (Pfu_Pd_Stop_Dt, 'dd-mm-yyyy')
                                       Pfu_Pd_Stop_Dt,
                                   Pfu_Com_Org,
                                   Personinfo,
                                   Detail_Sum
                              FROM XMLTABLE (
                                       'table/row'
                                       PASSING Xmltype.Createxml (p_Request_Body)
                                       COLUMNS Dul_Id             VARCHAR2 (250) PATH 'dul_id',
                                               --change_dt  VARCHAR2(250) Path 'change_dt',

                                               --sc_address
                                               Kaot               VARCHAR2 (250) PATH 'kaot',
                                               Postcode           VARCHAR2 (250) PATH 'postcode',
                                               District           VARCHAR2 (250) PATH 'district',
                                               Region             VARCHAR2 (250) PATH 'region',
                                               City               VARCHAR2 (250) PATH 'city',
                                               Street             VARCHAR2 (250) PATH 'street',
                                               Building           VARCHAR2 (250) PATH 'building',
                                               BLOCK              VARCHAR2 (250) PATH 'block',
                                               Apartment          VARCHAR2 (250) PATH 'apartment',
                                               --sc_household
                                               Full_Area          VARCHAR2 (250) PATH 'full_area', --загальна площа
                                               Heating_Area       VARCHAR2 (250) PATH 'heating_area', --опалювальна площа
                                               Adres_Upd_Dt       VARCHAR2 (250) PATH 'adres_upd_dt', --дата зміни адреси домогосподарства
                                               Schh_Id            VARCHAR2 (250) PATH 'schh_id', --ід домогосподарства
                                               Ip_Unique          VARCHAR2 (250) PATH 'ip_unique', --Унікальний номер ЕПОКЗО
                                               --SC_PFU_PAY_SUMMARY
                                               Pfu_Pd_Id          VARCHAR2 (250) PATH 'pfu_pd_id', --Ід рішення в ПФУ
                                               Pfu_Pd_Num         VARCHAR2 (250) PATH 'pfu_pd_num', --номер рішення в ПФУ
                                               Pfu_Pd_Dt          VARCHAR2 (250) PATH 'pfu_pd_dt', --дата  рішення в ПФУ
                                               Pfu_Pd_St          VARCHAR2 (250) PATH 'pfu_pd_st', --статус рішення в ПФУ
                                               Pd_Pay_Tp          VARCHAR2 (250) PATH 'pd_pay_tp', --Тип виплати
                                               Pfu_Pd_Start_Dt    VARCHAR2 (250) PATH 'pfu_pd_start_dt',
                                               Pfu_Pd_Stop_Dt     VARCHAR2 (250) PATH 'pfu_pd_stop_dt',
                                               Pfu_Com_Org        VARCHAR2 (250) PATH 'pfu_com_org',
                                               --scpp_sum VARCHAR2(250)        Path 'scpp_sum'
                                               Personinfo         XMLTYPE PATH 'PersInfo',
                                               Detail_Sum         XMLTYPE PATH 'detail_sum'))
        LOOP
            SAVEPOINT Svp_Handle_Save_Pc_Decision;

            BEGIN
                l_Cod_Res := NULL;
                l_Error := NULL;

                r_Old := NULL;

                OPEN Cur (c.Pfu_Pd_Id);

                FETCH Cur INTO r_Old;

                CLOSE Cur;

                --uss_person.Dnet$exch_Uss2ikis.Handle_Save_Pp_Req

                l_Scpp_Id := r_Old.Scpp_Id;
                l_Schh_Id := r_Old.Schh_Id;
                l_Sc_Id := r_Old.Sc_Id;
                l_Sca_Id := r_Old.Sca_Id;

                l_main_ip_unique := c.Ip_Unique;

                --створення соц.карт членив родини
                Create_Socialcard (p_Request_Body     => c.Personinfo,
                                   p_main_ip_unique   => l_main_ip_unique);

                --пошук соц.карти отримувача субсідії
                SELECT MAX (Sc.Sc_Id)
                  INTO l_Sc_Id
                  FROM Socialcard Sc
                 WHERE Sc.Sc_Unique = l_main_ip_unique           --c.Ip_Unique
                                                       AND Sc.Sc_St = '1';

                --Якщо соцкарту не знайдено по ПЕОКЗО
                IF l_Sc_Id IS NULL
                THEN
                    Raise_Application_Error (
                        -20010,
                           'Помилка пошуку соцкартки MAIN ip_unique='
                        || c.Ip_Unique);
                END IF;

                OPEN Cur_Kaot (c.Kaot);

                FETCH Cur_Kaot INTO r_Kaot;

                CLOSE Cur_Kaot;

                --адреса USS_NDI.V_DDN_SCA_TP p_Sca_Tp
                CASE c.Pd_Pay_Tp
                    WHEN 'BENEFIT'
                    THEN
                        l_Sca_Tp := 4;
                    WHEN 'SUBSIDY'
                    THEN
                        l_Sca_Tp := 5;
                    ELSE
                        Raise_Application_Error (
                            -20012,
                               'Невизначений тип виплат pd_pay_tp: '
                            || c.Pd_Pay_Tp);
                END CASE;

                Uss_Person.Api$socialcard.Save_Sc_Address (
                    p_Sca_Sc          => l_Sc_Id,
                    p_Sca_Tp          => l_Sca_Tp, -- тип "Місце проживання пільговика" = USS_NDI.V_DDN_SCA_TP
                    p_Sca_Kaot        => r_Kaot.Kaot_Id,
                    p_Sca_Nc          => NULL,
                    p_Sca_Country     => 'УКРАЇНА',
                    p_Sca_Region      => c.Region,
                    p_Sca_District    => c.District,
                    p_Sca_Postcode    => c.Postcode,
                    p_Sca_City        => c.City,
                    p_Sca_Street      => c.Street,
                    p_Sca_Building    => c.Building,
                    p_Sca_Block       => c.Block,
                    p_Sca_Apartment   => c.Apartment,
                    p_Sca_Note        => NULL,
                    p_Sca_Src         => c_Src_Pfu,
                    p_Sca_Create_Dt   => NVL (c.Adres_Upd_Dt, SYSDATE),
                    o_Sca_Id          => l_Sca_Id);

                --перезаписати домогосподарство
                IF l_Schh_Id IS NOT NULL
                THEN
                    UPDATE Sc_Household t
                       SET Schh_Full_Area = c.Full_Area,
                           Schh_Heating_Area = c.Heating_Area,
                           Schh_Sca = l_Sca_Id
                     WHERE t.Schh_Id = l_Schh_Id;
                ELSE
                    --нове домогосподарство
                    Api$socialcard.Save_Sc_Household (
                        p_Schh_Id             => l_Schh_Id,
                        p_Schh_Sc             => l_Sc_Id,
                        p_Schh_Sca            => l_Sca_Id,
                        p_Schh_Full_Area      => c.Full_Area,
                        p_Schh_Heating_Area   => c.Heating_Area);
                END IF;

                --перезаписати рішення
                IF l_Scpp_Id IS NOT NULL
                THEN
                    UPDATE Sc_Pfu_Pay_Summary t
                       SET Scpp_Pfu_Payment_Tp = c.Pd_Pay_Tp,
                           Scpp_Pfu_Pd_Dt = c.Pfu_Pd_Dt,
                           Scpp_Pfu_Pd_Start_Dt = c.Pfu_Pd_Start_Dt,
                           Scpp_Pfu_Pd_Stop_Dt = c.Pfu_Pd_Stop_Dt,
                           Scpp_Pfu_Pd_St = c.Pfu_Pd_St,
                           Scpp_Change_Dt = c.Change_Dt,
                           Scpp_Pfu_Com_Org = c.Pfu_Com_Org,
                           Scpp_Schh = l_Schh_Id
                     WHERE t.Scpp_Id = l_Scpp_Id;
                ELSE
                    --нове рішення
                    Api$socialcard.Save_Sc_Pfu_Pay_Summary (
                        p_Scpp_Id                => l_Scpp_Id,
                        p_Scpp_Sc                => l_Sc_Id,
                        p_Scpp_Pfu_Pd_Id         => c.Pfu_Pd_Id,
                        p_Scpp_Pfu_Payment_Tp    => c.Pd_Pay_Tp,
                        p_Scpp_Pfu_Pd_Dt         => c.Pfu_Pd_Dt,
                        p_Scpp_Pfu_Pd_Start_Dt   => c.Pfu_Pd_Start_Dt,
                        p_Scpp_Pfu_Pd_Stop_Dt    => c.Pfu_Pd_Stop_Dt,
                        p_Scpp_Pfu_Pd_St         => c.Pfu_Pd_St,
                        p_Scpp_Change_Dt         => c.Change_Dt,
                        p_Scpp_Sum               => NULL,
                        p_Scpp_Schh              => l_Schh_Id,
                        p_Scpp_St                => 'A',
                        p_Scpp_Pfu_Com_Org       => c.Pfu_Com_Org);
                END IF;

                --Дані про родину щодо призначеної виплати ПФУ
                FOR f
                    IN (             SELECT Ip_Unique2, Aprp_Marital_St, Aprp_Fml_Rltn_Tp
                                       FROM XMLTABLE (
                                                'PersInfo/row'
                                                PASSING c.Personinfo
                                                COLUMNS Ip_Unique2          VARCHAR2 (250) PATH 'ip_unique',
                                                        Aprp_Marital_St     VARCHAR2 (250) PATH 'aprp_marital_st',
                                                        Aprp_Fml_Rltn_Tp    VARCHAR2 (250) PATH 'aprp_fml_rltn_tp'))
                LOOP
                    DECLARE
                        l_Scpf_Sc_Id   NUMBER;        --Соцкартка члена родини
                    BEGIN
                        SELECT MAX (Sc.Sc_Id)
                          INTO l_Scpf_Sc_Id
                          FROM Socialcard Sc
                         WHERE     Sc.Sc_Unique =
                                   CASE
                                       WHEN c.Ip_Unique = f.Ip_Unique2
                                       THEN
                                           l_main_ip_unique
                                       ELSE
                                           f.Ip_Unique2
                                   END
                               AND Sc.Sc_St = '1';

                        IF l_Scpf_Sc_Id IS NOT NULL
                        THEN
                            UPDATE Sc_Scpp_Family t
                               SET Scpf_Sc_Main = l_Sc_Id,
                                   Scpf_Relation_Tp = f.Aprp_Fml_Rltn_Tp,
                                   Scpf_Marital_St = f.Aprp_Marital_St
                             WHERE     t.Scpf_Scpp = l_Scpp_Id
                                   AND t.Scpf_Sc = l_Scpf_Sc_Id;

                            IF SQL%ROWCOUNT = 0
                            THEN
                                Api$socialcard.Save_Sc_Scpp_Family (
                                    p_Scpf_Id            => l_Scpf_Sc_Id,
                                    p_Scpf_Scpp          => l_Scpp_Id, --Ід рядка зведеної інформації по призначенню виплат в ПФУ
                                    p_Scpf_Sc            => l_Scpf_Sc_Id, --Соцкартка члена родини
                                    p_Scpf_Sc_Main       => l_Sc_Id, --Соцкартка отримувача виплати ПФУ
                                    p_Scpf_Relation_Tp   => f.Aprp_Fml_Rltn_Tp,
                                    p_Scpf_Marital_St    => f.Aprp_Marital_St);
                            END IF;
                        ELSE
                            --raise_application_error(-20003, 'Помилка пошуку соцкартки ip_unique='||f.ip_unique2);
                            NULL;            --не знайшли соцкарту, пропустити
                        END IF;
                    END;
                END LOOP;

                --деталізація призначених виплат по рішенню
                Create_Sc_Scpp_Detail (p_Scpp_Id      => l_Scpp_Id,
                                       p_Sc_Id        => l_Sc_Id,
                                       p_Detail_Sum   => c.Detail_Sum);

                l_Cod_Res := 1;
            --uss_person.dnet$socialcard.get_person_subsidy_list

            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK TO Svp_Handle_Save_Pc_Decision;

                    l_Cod_Res := SQLCODE;
                    l_Error := SQLERRM;

                    --помилка ORA
                    IF l_Cod_Res > -20000
                    THEN
                        l_Error :=
                               l_Error
                            || CHR (10)
                            || DBMS_UTILITY.Format_Error_Backtrace;
                    END IF;
            END;

           <<end_Work>>
            NULL;
            --результат обробки
            DBMS_LOB.Append (
                l_Clob,
                   '<row><dul_id>'
                || c.Dul_Id
                || '</dul_id><pfu_pd_id>'
                || c.Pfu_Pd_Id
                || '</pfu_pd_id>'
                || '<result>'
                || l_Cod_Res
                || '</result><error>'
                || l_Error
                || '</error></row>'
                || CHR (10));
        END LOOP;

        DBMS_LOB.Append (l_Clob, '</table>');

        RETURN l_Clob;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка Обробки запита від ПФУ: '
                || SQLCODE
                || ' '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -- Обробка запиту від ПФУ на збереження інформації по довіднику ikis_ndi.ndi_payment_type
    FUNCTION Handle_Save_Ndi_Payment_Type_Request (p_Request_Id     IN NUMBER, --ignore
                                                   p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Xml      XMLTYPE;
        l_Result   NUMBER := 0;
        l_Error    VARCHAR2 (32000);
    BEGIN
        IF    (p_Request_Body IS NULL)
           OR (DBMS_LOB.Getlength (p_Request_Body) = 0)
        THEN
            Raise_Application_Error (-20000, 'Вхідний запит пустий');
        END IF;

        BEGIN
            FOR c
                IN (          SELECT Dul_Id,
                                     Npt_Id,
                                     Npt_Code,
                                     Npt_Name,
                                     Npt_Legal_Act
                                FROM XMLTABLE (
                                         'table/row'
                                         PASSING Xmltype (p_Request_Body)
                                         COLUMNS Dul_Id           VARCHAR2 (250) PATH 'dul_id',
                                                 Npt_Id           VARCHAR2 (250) PATH 'npt_id',
                                                 Npt_Code         VARCHAR2 (250) PATH 'npt_code',
                                                 Npt_Name         VARCHAR2 (1000) PATH 'npt_name',
                                                 Npt_Legal_Act    VARCHAR2 (4000) PATH 'npt_legal_act'))
            LOOP
                --UPDATE ndi_payment_type
                Uss_Ndi.Api$dic_Visit.Set_Ndi_Pfu_Payment_Type (
                    p_Nppt_Id          => c.Npt_Id,
                    p_Nppt_Code        => c.Npt_Code,
                    p_Nppt_Name        => c.Npt_Name,
                    p_Nppt_Legal_Act   => c.Npt_Legal_Act);
            END LOOP;

            l_Result := 1;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_Result := SQLCODE;
                l_Error := SQLERRM;

                --помилка ORA
                IF l_Result > -20000
                THEN
                    l_Error :=
                           l_Error
                        || CHR (10)
                        || DBMS_UTILITY.Format_Error_Backtrace;
                END IF;
        END;

        SELECT XMLELEMENT ("req",
                           XMLELEMENT ("result", l_Result),
                           XMLELEMENT ("error", l_Error))
          INTO l_Xml
          FROM DUAL;

        RETURN l_Xml.Getclobval ();
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20030,
                   'Помилка Обробки запита від ПФУ: '
                || SQLCODE
                || ' '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -- Обробка запиту від ПФУ на збереження розшифровки даних по виплатам по рішенням
    FUNCTION Handle_Save_Payment_Sum_Request (p_Request_Id     IN NUMBER, --ignore
                                              p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        /*cursor cur(p_pfu_pd_id sc_pfu_pay_summary.scpp_pfu_pd_id%type) is
        select p.scpp_id,            --Ід зведеної інфи
               p.scpp_sc    sc_id,   --Ід соціальної картки
               p.scpp_schh  schh_id  --Ід домогосподарства
          from sc_pfu_pay_summary p
         where p.scpp_pfu_pd_id = p_pfu_pd_id;*/
        CURSOR Cur (p_Pfu_Pd_Id   Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Id%TYPE,
                    p_Year        INTEGER,
                    p_Month       INTEGER)
        IS
            SELECT --+ index(p3 I_SCP3_SET1)
                   p.Scpp_Id,
                   --Ід зведеної інфи
                   p.Scpp_Sc      Sc_Id,
                   --Ід соціальної картки
                   p.Scpp_Schh    Schh_Id,
                   --Ід домогосподарства
                   SUM (
                       CASE p_Month
                           WHEN 1 THEN Scp3_Sum_M1
                           WHEN 2 THEN Scp3_Sum_M2
                           WHEN 3 THEN Scp3_Sum_M3
                           WHEN 4 THEN Scp3_Sum_M4
                           WHEN 5 THEN Scp3_Sum_M5
                           WHEN 6 THEN Scp3_Sum_M6
                           WHEN 7 THEN Scp3_Sum_M7
                           WHEN 8 THEN Scp3_Sum_M8
                           WHEN 9 THEN Scp3_Sum_M9
                           WHEN 10 THEN Scp3_Sum_M10
                           WHEN 11 THEN Scp3_Sum_M11
                           WHEN 12 THEN Scp3_Sum_M12
                       END)
                       OVER ()    Sum_All
              FROM Uss_Person.Sc_Pfu_Pay_Summary  p,
                   Uss_Person.Sc_Pfu_Pay_Period   P3
             WHERE     p.Scpp_Pfu_Pd_Id = p_Pfu_Pd_Id
                   AND P3.Scp3_Scpp(+) = p.Scpp_Id
                   AND P3.Scp3_Year(+) = p_Year;

        l_r        Cur%ROWTYPE;

        /*cursor chck_request_id(p_scpp_id number, p_pfu_acd number) is
          select p3.scp3_pfu_acd from sc_pfu_pay_period p3
           where p3.scp3_scpp = p_scpp_id
             and p3.scp3_pfu_acd = p_pfu_acd;
        r_chck_request_id chck_request_id%rowtype;*/

        l_Result   NUMBER := 0;
        l_Error    VARCHAR2 (32000);
        l_Clob     CLOB;

        PROCEDURE Update_Sc_Pfu_Pay_Period (p_Scpp_Id   NUMBER,
                                            p_Year      INTEGER,
                                            p_Month     INTEGER,
                                            p_Npt_Id    NUMBER,
                                            p_Uro_Id    NUMBER,
                                            p_Nbc_Id    NUMBER,
                                            p_Sum       NUMBER)
        IS
        BEGIN
            UPDATE --+ index(p3 I_SCP3_SET1)
                   Sc_Pfu_Pay_Period P3
               SET Scp3_Pfu_Acd = p_Uro_Id,
                   Scp3_Change_Dt = SYSDATE,
                   Scp3_Nbc = NVL (p_Nbc_Id, Scp3_Nbc), --не треба перетирати категорію!
                   Scp3_Sum_M1 =
                       CASE
                           WHEN p_Month = 1 THEN NVL (Scp3_Sum_M1, 0) + p_Sum
                           ELSE Scp3_Sum_M1
                       END,
                   Scp3_Sum_M2 =
                       CASE
                           WHEN p_Month = 2 THEN NVL (Scp3_Sum_M2, 0) + p_Sum
                           ELSE Scp3_Sum_M2
                       END,
                   Scp3_Sum_M3 =
                       CASE
                           WHEN p_Month = 3 THEN NVL (Scp3_Sum_M3, 0) + p_Sum
                           ELSE Scp3_Sum_M3
                       END,
                   Scp3_Sum_M4 =
                       CASE
                           WHEN p_Month = 4 THEN NVL (Scp3_Sum_M4, 0) + p_Sum
                           ELSE Scp3_Sum_M4
                       END,
                   Scp3_Sum_M5 =
                       CASE
                           WHEN p_Month = 5 THEN NVL (Scp3_Sum_M5, 0) + p_Sum
                           ELSE Scp3_Sum_M5
                       END,
                   Scp3_Sum_M6 =
                       CASE
                           WHEN p_Month = 6 THEN NVL (Scp3_Sum_M6, 0) + p_Sum
                           ELSE Scp3_Sum_M6
                       END,
                   Scp3_Sum_M7 =
                       CASE
                           WHEN p_Month = 7 THEN NVL (Scp3_Sum_M7, 0) + p_Sum
                           ELSE Scp3_Sum_M7
                       END,
                   Scp3_Sum_M8 =
                       CASE
                           WHEN p_Month = 8 THEN NVL (Scp3_Sum_M8, 0) + p_Sum
                           ELSE Scp3_Sum_M8
                       END,
                   Scp3_Sum_M9 =
                       CASE
                           WHEN p_Month = 9 THEN NVL (Scp3_Sum_M9, 0) + p_Sum
                           ELSE Scp3_Sum_M9
                       END,
                   Scp3_Sum_M10 =
                       CASE
                           WHEN p_Month = 10
                           THEN
                               NVL (Scp3_Sum_M10, 0) + p_Sum
                           ELSE
                               Scp3_Sum_M10
                       END,
                   Scp3_Sum_M11 =
                       CASE
                           WHEN p_Month = 11
                           THEN
                               NVL (Scp3_Sum_M11, 0) + p_Sum
                           ELSE
                               Scp3_Sum_M11
                       END,
                   Scp3_Sum_M12 =
                       CASE
                           WHEN p_Month = 12
                           THEN
                               NVL (Scp3_Sum_M12, 0) + p_Sum
                           ELSE
                               Scp3_Sum_M12
                       END
             WHERE     P3.Scp3_Scpp = p_Scpp_Id
                   AND P3.Scp3_Year = p_Year
                   AND P3.Scp3_Nppt = NVL (p_Npt_Id, P3.Scp3_Nppt);
        END Update_Sc_Pfu_Pay_Period;
    BEGIN
        IF    (p_Request_Body IS NULL)
           OR (DBMS_LOB.Getlength (p_Request_Body) = 0)
        THEN
            Raise_Application_Error (-20000, 'Вхідний запит пустий');
        END IF;

        DBMS_SESSION.Set_Nls ('NLS_NUMERIC_CHARACTERS', ''', ''');

        DBMS_LOB.Createtemporary (Lob_Loc => l_Clob, Cache => TRUE);
        DBMS_LOB.Open (Lob_Loc => l_Clob, Open_Mode => DBMS_LOB.Lob_Readwrite);
        DBMS_LOB.Append (l_Clob, '<table>');

        FOR c
            IN (         SELECT Dul_Id,
                                Pfu_Pd_Id,
                                Uro_Id,
                                Is_Overwrite,
                                TO_DATE (Calc_Dt, 'dd-mm-yyyy')
                                    Calc_Dt,
                                EXTRACT (MONTH FROM TO_DATE (Calc_Dt, 'dd-mm-yyyy'))
                                    Mm,
                                EXTRACT (YEAR FROM TO_DATE (Calc_Dt, 'dd-mm-yyyy'))
                                    Yyyy,
                                Acd_Sum_All,
                                Ac_Detail
                           FROM XMLTABLE (
                                    'table/row'
                                    PASSING Xmltype.Createxml (p_Request_Body)
                                    COLUMNS Dul_Id          VARCHAR2 (250) PATH 'dul_id',
                                            Uro_Id          VARCHAR2 (250) PATH 'uro_id',
                                            Pfu_Pd_Id       VARCHAR2 (250) PATH 'pfu_pd_id',
                                            --pfu_ac_id    VARCHAR2(250) Path 'pfu_ac_id',
                                            Is_Overwrite    VARCHAR2 (1) PATH 'is_overwrite', --ознака, за якою дані повністю перезаписуються('T'), інакше - стандартно update('F')
                                            Calc_Dt         VARCHAR2 (250) PATH 'calc_dt',
                                            Acd_Sum_All     NUMBER PATH 'acd_sum_all',
                                            Ac_Detail       XMLTYPE PATH 'ac_detail')
                                x)
        LOOP
            SAVEPOINT Svp_Handle_Save_Payment_Sum_Request;

            BEGIN
                l_Result := 0;
                l_Error := NULL;

                l_r := NULL;

                --open cur(p_pfu_pd_id => c.pfu_pd_id);
                OPEN Cur (p_Pfu_Pd_Id   => c.Pfu_Pd_Id,
                          p_Year        => c.Yyyy,
                          p_Month       => c.Mm);

                FETCH Cur INTO l_r;

                CLOSE Cur;

                CASE
                    WHEN l_r.Scpp_Id IS NULL
                    THEN
                        Raise_Application_Error (-20001, 'scpp_id');
                    WHEN l_r.Sc_Id IS NULL
                    THEN
                        Raise_Application_Error (-20002, 'scpp_sc');
                    --WHEN l_r.Schh_Id IS NULL THEN
                    --  Raise_Application_Error(-20003, 'scpp_schh');
                    ELSE
                        NULL;
                END CASE;

                --перевірка на повторну передачу даних сервісов (якщо сервіс завис, і шле один і той же пакет даних)
                /*r_chck_request_id:= null;
                open chck_request_id(p_scpp_id => l_r.scpp_id, p_pfu_acd => c.uro_id);
                fetch chck_request_id into r_chck_request_id; close chck_request_id;*/

                --зачистити суми
                IF c.Is_Overwrite = 'T'
                THEN
                    Update_Sc_Pfu_Pay_Period (p_Scpp_Id   => l_r.Scpp_Id,
                                              p_Year      => c.Yyyy,
                                              p_Month     => c.Mm,
                                              p_Npt_Id    => NULL,
                                              p_Uro_Id    => c.Uro_Id,
                                              p_Nbc_Id    => NULL,
                                              p_Sum       => NULL);
                --не співпала передана раніше сума з поточною - перезаписати
                --ELSIF Nvl(l_r.Sum_All, 0) <> Nvl(c.Acd_Sum_All, 0) THEN
                ELSE
                    Update_Sc_Pfu_Pay_Period (p_Scpp_Id   => l_r.Scpp_Id,
                                              p_Year      => c.Yyyy,
                                              p_Month     => c.Mm,
                                              p_Npt_Id    => NULL,
                                              p_Uro_Id    => c.Uro_Id,
                                              p_Nbc_Id    => NULL,
                                              p_Sum       => NULL);

                    FOR d
                        IN (       SELECT Pfu_Acd_Id,
                                          Pfu_Npt_Id,
                                          Nbc.Nbc_Id,
                                          TO_DATE (Start_Dt, 'dd-mm-yyyy')
                                              Start_Dt,
                                          TO_CHAR (TO_DATE (Start_Dt, 'dd-mm-yyyy'),
                                                   'mm')
                                              Mm,
                                          TO_CHAR (TO_DATE (Start_Dt, 'dd-mm-yyyy'),
                                                   'yyyy')
                                              Yyyy,
                                          Acd_Sum
                                     FROM XMLTABLE (
                                              'ac_detail/row'
                                              PASSING (c.Ac_Detail)
                                              COLUMNS Pfu_Acd_Id    VARCHAR2 (50) PATH 'pfu_acd_id',
                                                      Pfu_Npt_Id    VARCHAR2 (50) PATH 'pfu_npt_id',
                                                      Nbc_Code      VARCHAR2 (50) PATH 'pfu_nbc_code', --код пільгової категорії
                                                      Start_Dt      VARCHAR2 (50) PATH 'start_dt',
                                                      Acd_Sum       NUMBER PATH 'acd_sum')
                                          x,
                                          Uss_Ndi.v_Ndi_Benefit_Category Nbc
                                    WHERE Nbc.Nbc_Code(+) = x.Nbc_Code)
                    LOOP
                        Update_Sc_Pfu_Pay_Period (p_Scpp_Id   => l_r.Scpp_Id,
                                                  p_Year      => c.Yyyy,
                                                  p_Month     => c.Mm,
                                                  p_Npt_Id    => d.Pfu_Npt_Id,
                                                  p_Uro_Id    => c.Uro_Id,
                                                  p_Nbc_Id    => d.Nbc_Id,
                                                  p_Sum       => d.Acd_Sum);

                        IF SQL%ROWCOUNT = 0
                        THEN
                            INSERT INTO Sc_Pfu_Pay_Period (Scp3_Id,
                                                           Scp3_Sc,
                                                           Scp3_Scpp,
                                                           Scp3_Schh,
                                                           Scp3_Nppt,
                                                           Scp3_Nbc,
                                                           Scp3_Change_Dt,
                                                           Scp3_Year,
                                                           Scp3_Pfu_Acd,
                                                           Scp3_Sum_M1,
                                                           Scp3_Sum_M2,
                                                           Scp3_Sum_M3,
                                                           Scp3_Sum_M4,
                                                           Scp3_Sum_M5,
                                                           Scp3_Sum_M6,
                                                           Scp3_Sum_M7,
                                                           Scp3_Sum_M8,
                                                           Scp3_Sum_M9,
                                                           Scp3_Sum_M10,
                                                           Scp3_Sum_M11,
                                                           Scp3_Sum_M12)
                                 VALUES (NULL,
                                         l_r.Sc_Id,
                                         l_r.Scpp_Id,
                                         l_r.Schh_Id,
                                         d.Pfu_Npt_Id,
                                         d.Nbc_Id,
                                         SYSDATE,
                                         d.Yyyy,
                                         c.Uro_Id,
                                         DECODE (d.Mm, 1, d.Acd_Sum),
                                         DECODE (d.Mm, 2, d.Acd_Sum),
                                         DECODE (d.Mm, 3, d.Acd_Sum),
                                         DECODE (d.Mm, 4, d.Acd_Sum),
                                         DECODE (d.Mm, 5, d.Acd_Sum),
                                         DECODE (d.Mm, 6, d.Acd_Sum),
                                         DECODE (d.Mm, 7, d.Acd_Sum),
                                         DECODE (d.Mm, 8, d.Acd_Sum),
                                         DECODE (d.Mm, 9, d.Acd_Sum),
                                         DECODE (d.Mm, 10, d.Acd_Sum),
                                         DECODE (d.Mm, 11, d.Acd_Sum),
                                         DECODE (d.Mm, 12, d.Acd_Sum));
                        --returning scp3_id into r_scp3.scp3_id;
                        END IF;
                    END LOOP;
                END IF;

                l_Result := 1;
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK TO Svp_Handle_Save_Payment_Sum_Request;

                    l_Result := SQLCODE;
                    l_Error := SQLERRM;

                    --помилка ORA
                    IF l_Result > -20000
                    THEN
                        l_Error :=
                               l_Error
                            || CHR (10)
                            || DBMS_UTILITY.Format_Error_Backtrace;
                    END IF;
            END;

            --результат обробки
            DBMS_LOB.Append (
                l_Clob,
                   '<row><dul_id>'
                || c.Dul_Id
                || '</dul_id>'
                || --'<pfu_ac_id>'||c.pfu_ac_id||'</pfu_ac_id>'||
                   '<result>'
                || l_Result
                || '</result><error>'
                || l_Error
                || '</error></row>'
                || CHR (10));
        END LOOP;

        DBMS_LOB.Append (l_Clob, '</table>');

        RETURN l_Clob;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20040,
                   'Помилка Обробки запита від ПФУ: '
                || SQLCODE
                || ' '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --#95400, USS.Common.PutSubsidyBenefit заміна Handle_Save_Pc_Decision
    --Сервіс отримання інформації щодо рішення про призначення/відмову субсидій/пільг до Єдиного соціального реєстру
    FUNCTION Handle_Put_Subsidy_Benefit_Req (p_Ur_Id     IN NUMBER,   --ignore
                                             p_Request   IN CLOB)
        RETURN CLOB
    IS
        l_Rn_Id        NUMBER;
        l_Result       NUMBER := 0;                  /*0 – оновлення успішно*/
        l_Error        VARCHAR2 (32000);
        l_Schh_Id      Sc_Household.Schh_Id%TYPE;
        l_Clob         CLOB;
        l_Empty_Loop   BOOLEAN := TRUE;
    BEGIN
        IF (p_Request IS NULL) OR (DBMS_LOB.Getlength (p_Request) = 0)
        THEN
            Raise_Application_Error (-20000, 'Вхідний запит пустий');
        END IF;

        DBMS_SESSION.Set_Nls ('NLS_NUMERIC_CHARACTERS', ''', ''');
        DBMS_SESSION.Set_Nls ('NLS_DATE_FORMAT', q'['DD.MM.RRRR']');

        DBMS_LOB.Createtemporary (Lob_Loc => l_Clob, Cache => TRUE);
        DBMS_LOB.Open (Lob_Loc => l_Clob, Open_Mode => DBMS_LOB.Lob_Readwrite);
        DBMS_LOB.Append (l_Clob, '<Persons>');

        FOR c
            IN (                 SELECT Id,
                                        PersonInfo,
                                        Documents,
                                        Katottg,
                                        City,
                                        Streetname,
                                        Building,
                                        BLOCK,
                                        Apartment,
                                        Householdid,
                                        Isseparatebill,
                                        Fullarea,
                                        Heatingarea,
                                        Floorcnt,
                                        Buildtp,
                                        Famtp,
                                        Incomeamount,
                                        Avgincomeamount,
                                        Pcnum,
                                        Usshouseholid,
                                        Pdid,
                                        Pdnum,
                                        Pdtp,
                                        TO_DATE (Apregdt, 'dd-mm-yyyy')     Apregdt,
                                        Normact,
                                        Src,
                                        Refusersn,
                                        TO_DATE (Startdt, 'dd-mm-yyyy')     Startdt,
                                        TO_DATE (Stopdt, 'dd-mm-yyyy')      Stopdt,
                                        Pdstartdt,
                                        Pdtpsum,
                                        Pdsgsum,
                                        Pdfeatures,
                                        Incomeincludemark,
                                        Subsidybenefitdetail,
                                        Familyinfo,
                                        ROWNUM
                                   FROM XMLTABLE (
                                            '/PutSubsidyBenefit/Row'
                                            PASSING Xmltype (p_Request)
                                            COLUMNS Id                      NUMBER PATH 'Id',
                                                    PersonInfo              XMLTYPE PATH 'Person_Info',
                                                    Documents               XMLTYPE PATH 'Documents',
                                                    --Household
                                                    Katottg                 VARCHAR2 (250) PATH 'Household/KATOTTG',
                                                    City                    VARCHAR2 (250) PATH 'Household/City',
                                                    Streetname              VARCHAR2 (250) PATH 'Household/StreetName',
                                                    Building                VARCHAR2 (250) PATH 'Household/Building',
                                                    BLOCK                   VARCHAR2 (250) PATH 'Household/Block',
                                                    Apartment               VARCHAR2 (250) PATH 'Household/Apartment',
                                                    Householdid             NUMBER PATH 'Household/HouseholdId',
                                                    Isseparatebill          VARCHAR2 (10) PATH 'Household/IsSeparateBill',
                                                    Fullarea                NUMBER PATH 'Household/FullArea',
                                                    Heatingarea             NUMBER PATH 'Household/HeatingArea',
                                                    Floorcnt                NUMBER PATH 'Household/FloorCnt',
                                                    Buildtp                 NUMBER PATH 'Household/BuildTp',
                                                    Famtp                   NUMBER PATH 'Household/FamTp',
                                                    --SubsidyBenefitInfo
                                                    Incomeamount            NUMBER PATH 'SubsidyBenefitInfo/IncomeAmount',
                                                    Avgincomeamount         NUMBER PATH 'SubsidyBenefitInfo/AvgIncomeAmount',
                                                    Pcnum                   VARCHAR2 (250) PATH 'SubsidyBenefitInfo/PcNum',
                                                    Usshouseholid           VARCHAR2 (250) PATH 'SubsidyBenefitInfo/UssHouseholId',
                                                    Pdid                    NUMBER PATH 'SubsidyBenefitInfo/PdId',
                                                    Pdnum                   VARCHAR2 (250) PATH 'SubsidyBenefitInfo/PdNum',
                                                    Pdtp                    VARCHAR2 (250) PATH 'SubsidyBenefitInfo/PdTp',
                                                    Apregdt                 VARCHAR2 (250) PATH 'SubsidyBenefitInfo/ApRegDt',
                                                    Normact                 VARCHAR2 (250) PATH 'SubsidyBenefitInfo/NormAct',
                                                    Src                     VARCHAR2 (250) PATH 'SubsidyBenefitInfo/Src',
                                                    Refusersn               VARCHAR2 (250) PATH 'SubsidyBenefitInfo/RefuseRsn',
                                                    Startdt                 VARCHAR2 (250) PATH 'SubsidyBenefitInfo/StartDt',
                                                    Stopdt                  VARCHAR2 (250) PATH 'SubsidyBenefitInfo/StopDt',
                                                    Pdstartdt               VARCHAR2 (250) PATH 'SubsidyBenefitInfo/PdStartDt',
                                                    Pdtpsum                 NUMBER PATH 'SubsidyBenefitInfo/PdTPSum',
                                                    Pdsgsum                 NUMBER PATH 'SubsidyBenefitInfo/PdSGSum',
                                                    Pdfeatures              XMLTYPE PATH 'PdFeatures',
                                                    Incomeincludemark       VARCHAR2 (250) PATH 'IncomeIncludeMark',
                                                    Subsidybenefitdetail    XMLTYPE PATH 'SubsidyBenefitDetail',
                                                    Familyinfo              XMLTYPE PATH 'FamilyInfo'))
        LOOP
            SAVEPOINT Svp_Handle_Put_Subsidy_Benefit;

            DECLARE
                l_Scdi_Main     Sc_Pfu_Data_Ident.Scdi_Id%TYPE;
                l_Sc_Main       Socialcard.Sc_Id%TYPE;

                l_Sca_Id        Sc_Address.Sca_Id%TYPE;            --Ід адреси
                l_Scpa_Id       Sc_Pfu_Address.Scpa_Id%TYPE;       --Ід адреси
                l_Sca_Tp        NUMBER; -- Тип домогосподарства 4-"Місце проживання пільговика"/5-Субсідія/пільга
                l_Sca_Kaot      Sc_Address.Sca_Kaot%TYPE;

                l_Scpp_Id       Sc_Pfu_Pay_Summary.Scpp_Id%TYPE;
                l_Pd_Id         Sc_Pfu_Pay_Summary.Scpp_Pfu_Pd_Id%TYPE;
                l_Pd_Features   Sc_Pfu_Pay_Summary.Scpp_Pd_Features%TYPE;
            BEGIN
                l_Empty_Loop := FALSE;
                l_Schh_Id := NULL;
                l_Result := NULL;
                l_Error := NULL;

                Save_Sc_Pfu_Data_Ident (p_Person_Info   => c.PersonInfo,
                                        p_Ur_Id         => p_Ur_Id,
                                        p_Scdi_Id       => l_Scdi_Main,
                                        p_Sc_Id         => l_Sc_Main);
                Save_Sc_Pfu_Document (p_Documents   => c.Documents,
                                      p_Scdi_Id     => l_Scdi_Main,
                                      p_Sc_Id       => l_Sc_Main);

                --Наявність соц.картки заявника критична
                IF l_Scdi_Main IS NULL
                THEN
                    Raise_Application_Error (-20001,
                                             'Помилка пошуку особи заявника');
                END IF;

                BEGIN
                     SELECT LISTAGG (item, ',')
                       INTO l_Pd_Features
                       FROM XMLTABLE ('/PdFeatures/row'
                                      PASSING c.Pdfeatures
                                      COLUMNS item    VARCHAR2 (100) PATH '.');
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

                --шукаємо домогосподарство та рішення за ідентифікаторами які зберігаються в ПФУ (можуть бути обидва відсутні)
                IF c.Usshouseholid IS NOT NULL OR c.Householdid IS NOT NULL
                THEN
                    BEGIN
                        SELECT h.Schh_Id,
                               h.Schh_Sca,
                               h.Schh_Scpa,
                               p.Scpp_Id,
                               p.Scpp_Pfu_Pd_Id
                          INTO l_Schh_Id,
                               l_Sca_Id,
                               l_Scpa_Id,
                               l_Scpp_Id,
                               l_Pd_Id
                          FROM Sc_Household h, Sc_Pfu_Pay_Summary p
                         WHERE     (   h.Schh_Id = c.Usshouseholid
                                    OR h.Schh_Pfu_Id = c.Householdid)
                               AND p.Scpp_Schh(+) = h.Schh_Id
                               AND NVL (p.history_status(+), 'A') = 'A';
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;
                    END;
                END IF;

                --шукаємо домогосподарство та рішення за ІД рішенням ПФУ
                IF l_Schh_Id IS NULL
                THEN
                    BEGIN
                        SELECT h.Schh_Id,
                               h.Schh_Sca,
                               h.Schh_Scpa,
                               p.Scpp_Id,
                               p.Scpp_Pfu_Pd_Id
                          INTO l_Schh_Id,
                               l_Sca_Id,
                               l_Scpa_Id,
                               l_Scpp_Id,
                               l_Pd_Id
                          FROM Sc_Pfu_Pay_Summary p, Sc_Household h
                         WHERE     p.Scpp_Pfu_Pd_Id = c.Pdid
                               AND h.Schh_Id(+) = p.Scpp_Schh
                               AND NVL (p.history_status, 'A') = 'A';
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;
                    END;
                END IF;

                --адреса USS_NDI.V_DDN_SCA_TP
                CASE c.Pdtp
                    WHEN 'BENEFIT'
                    THEN
                        l_Sca_Tp := 4;
                    WHEN 'SUBSIDY'
                    THEN
                        l_Sca_Tp := 5;
                    ELSE
                        Raise_Application_Error (
                            -20012,
                            'Невизначений тип виплат pd_tp: ' || c.Pdtp);
                END CASE;

                api$socialcard.Save_Sc_Pfu_Address (
                    p_Scpa_Id          => l_Scpa_Id,
                    p_Scpa_Sc          => l_Sc_Main,
                    p_Scpa_Scdi        => l_Scdi_Main,
                    p_Scpa_Tp          => l_Sca_Tp,
                    p_Scpa_Kaot_Code   => c.Katottg,
                    p_Scpa_Postcode    => NULL,
                    p_Scpa_City        => c.City,
                    p_Scpa_Street      => c.Streetname,
                    p_Scpa_Building    => c.Building,
                    p_Scpa_Block       => c.Block,
                    p_Scpa_Apartment   => c.Apartment,
                    p_Scpa_St          => 'VR');

                --перезаписати домогосподарство
                IF l_Schh_Id IS NOT NULL
                THEN
                    UPDATE Sc_Household t
                       SET Schh_Full_Area = c.Fullarea,
                           Schh_Heating_Area = c.Heatingarea,
                           Schh_Sca = l_Sca_Id,
                           Schh_Scpa = l_Scpa_Id,
                           Schh_Pfu_Id = c.Householdid,
                           Schh_Is_Separate_Bill =
                               DECODE (UPPER (c.Isseparatebill),
                                       'TRUE', 'T',
                                       'FALSE', 'F',
                                       c.Isseparatebill),
                           Schh_Floor_Cnt = c.Floorcnt,
                           Schh_Build_Tp = c.Buildtp,
                           Schh_Fam_Tp = c.Famtp
                     WHERE t.Schh_Id = l_Schh_Id;
                ELSE
                    --нове домогосподарство
                    Api$socialcard.Save_Sc_Household (
                        p_Schh_Id                 => l_Schh_Id,
                        p_Schh_Sc                 => l_Sc_Main,
                        p_Schh_Scdi               => l_Scdi_Main,
                        p_Schh_Sca                => l_Sca_Id,
                        p_Schh_Scpa               => l_Scpa_Id,
                        p_Schh_Full_Area          => c.Fullarea,
                        p_Schh_Heating_Area       => c.Heatingarea,
                        p_Schh_Pfu_Id             => c.Householdid,
                        p_Schh_Is_Separate_Bill   =>
                            CASE UPPER (c.Isseparatebill)
                                WHEN 'TRUE' THEN 'T'
                                WHEN 'FALSE' THEN 'F'
                                ELSE c.Isseparatebill
                            END,
                        p_Schh_Floor_Cnt          => c.Floorcnt,
                        p_Schh_Build_Tp           => c.Buildtp,
                        p_Schh_Fam_Tp             => c.Famtp);
                END IF;

                --Якщо по існуючому рішеню прийшла відмова, то закриваємо його
                IF l_Scpp_Id IS NOT NULL AND c.Pdid = l_Pd_Id
                THEN
                    UPDATE Sc_Pfu_Pay_Summary t
                       SET Scpp_Pfu_Payment_Tp = c.Pdtp,
                           Scpp_Pfu_Pd_Dt = c.Apregdt,
                           Scpp_Pfu_Pd_Start_Dt = c.Pdstartdt,
                           Scpp_Pfu_Pd_Stop_Dt =
                               CASE
                                   WHEN c.Refusersn IS NULL THEN NULL
                                   ELSE SYSDATE
                               END,
                           Scpp_Pfu_Pd_St =
                               CASE
                                   WHEN c.Refusersn IS NULL THEN 'S'
                                   ELSE 'V'
                               END,
                           Scpp_Pfu_Refuse_Reason = c.Refusersn,
                           Scpp_Income_Amount = c.incomeamount,
                           Scpp_Avg_Income_Amount = c.avgincomeamount,
                           Scpp_Pd_Features = l_Pd_Features,
                           Scpp_Income_Include_Mark = c.Incomeincludemark,
                           Scpp_Change_Dt = SYSDATE,
                           Scpp_Schh = l_Schh_Id,
                           Scpp_Scdi = l_Scdi_Main
                     WHERE t.Scpp_Id = l_Scpp_Id;
                ELSE
                    IF l_Scpp_Id IS NOT NULL
                    THEN
                        UPDATE Sc_Pfu_Pay_Summary t
                           SET Scpp_Pfu_Pd_Stop_Dt = SYSDATE,
                               Scpp_Change_Dt = SYSDATE
                         WHERE     t.Scpp_Id = l_Scpp_Id
                               AND Scpp_Pfu_Pd_Stop_Dt IS NULL;
                    END IF;

                    --нове рішення
                    Api$socialcard.Save_Sc_Pfu_Pay_Summary (
                        p_Scpp_Id                    => l_Scpp_Id,
                        p_Scpp_Sc                    => l_Sc_Main,
                        p_Scpp_Pfu_Pd_Id             => c.Pdid,
                        p_Scpp_Pfu_Payment_Tp        => c.Pdtp,
                        p_Scpp_Pfu_Pd_Dt             => c.Apregdt,
                        p_Scpp_Pfu_Pd_Start_Dt       => c.Pdstartdt,
                        p_Scpp_Pfu_Pd_Stop_Dt        =>
                            CASE
                                WHEN c.Refusersn IS NULL THEN NULL
                                ELSE SYSDATE
                            END,
                        p_Scpp_Pfu_Pd_St             =>
                            CASE
                                WHEN c.Refusersn IS NULL THEN 'S'
                                ELSE 'V'
                            END,
                        p_Scpp_Change_Dt             => SYSDATE,
                        p_Scpp_Sum                   => NULL,
                        p_Scpp_Schh                  => l_Schh_Id,
                        p_Scpp_St                    => 'VR',
                        p_Scpp_Pfu_Com_Org           => NULL,
                        p_Scpp_Scdi                  => l_Scdi_Main,
                        p_Scpp_Income_Amount         => c.incomeamount,
                        p_Scpp_Avg_Income_Amount     => c.avgincomeamount,
                        p_Scpp_Pfu_Pc_Num            => c.pcnum,
                        p_Scpp_Pfu_Pd_Num            => c.pdnum,
                        p_Scpp_Pfu_Appeal_Dt         => c.ApRegDt,
                        p_Scpp_Pfu_Norm_Act          => c.Normact,
                        p_Scpp_Pfu_Scr               => c.src,
                        p_Scpp_Pfu_Refuse_Reason     => c.refusersn,
                        p_Scpp_Start_Dt              => c.startdt,
                        p_Scpp_Stop_Dt               => c.stopdt,
                        p_Scpp_Pd_Features           => l_Pd_Features,
                        p_Scpp_Income_Include_Mark   => c.Incomeincludemark);
                END IF;

                --деталізація призначених виплат по рішенню
                DECLARE
                    --загальна сума призначених виплат
                    l_Scpp_Sum   NUMBER := 0;
                BEGIN
                    DELETE FROM Sc_Scpp_Detail d
                          WHERE d.Scpd_Scpp = l_Scpp_Id;

                    --Призначена сума субсидії / пільги на ТП (річний (1 раз в рік)
                    --в звітності рахується сума лише в одному місяця коли AppealDate=DecisionStartDate)
                    IF c.Pdtpsum IS NOT NULL
                    THEN
                        l_Scpp_Sum := l_Scpp_Sum + NVL (c.Pdtpsum, 0);

                        INSERT INTO Sc_Scpp_Detail d (Scpd_Scpp,
                                                      Scpd_Sc,
                                                      Scpd_Service_Tp,
                                                      Scpd_Nppt,
                                                      Scpd_Nbc,
                                                      Scpd_Start_Dt,
                                                      Scpd_Stop_Dt,
                                                      Scpd_Sum,
                                                      Scpd_St,
                                                      Scpd_Scdi)
                             VALUES (l_Scpp_Id,
                                     l_Sc_Main,
                                     '130',
                                     (SELECT Nppt_Id
                                        FROM Uss_Ndi.v_Ndi_Pfu_Payment_Type
                                       WHERE Nppt_Code = '130'),
                                     NULL,
                                     c.Apregdt,
                                     LAST_DAY (c.Apregdt),
                                     c.PdTPSum,
                                     'VR',
                                     l_Scdi_Main);
                    END IF;

                    --Призначена сума субсидії / пільги на СГ (річний (1 раз в рік)
                    --в звітності рахується сума лише в одному місяця коли AppealDate=DecisionStartDate)
                    IF c.Pdsgsum IS NOT NULL
                    THEN
                        l_Scpp_Sum := l_Scpp_Sum + NVL (c.Pdsgsum, 0);

                        INSERT INTO Sc_Scpp_Detail d (Scpd_Scpp,
                                                      Scpd_Sc,
                                                      Scpd_Service_Tp,
                                                      Scpd_Nppt,
                                                      Scpd_Nbc,
                                                      Scpd_Start_Dt,
                                                      Scpd_Stop_Dt,
                                                      Scpd_Sum,
                                                      Scpd_St,
                                                      Scpd_Scdi)
                             VALUES (l_Scpp_Id,
                                     l_Sc_Main,
                                     '140',
                                     (SELECT Nppt_Id
                                        FROM Uss_Ndi.v_Ndi_Pfu_Payment_Type
                                       WHERE Nppt_Code = '140'),
                                     NULL,
                                     c.Apregdt,
                                     LAST_DAY (c.Apregdt),
                                     c.PdSGSum,
                                     'VR',
                                     l_Scdi_Main);
                    END IF;

                    FOR d
                        IN (             SELECT Nppt_Id,
                                                Servicecode,
                                                Electricity_Zone,
                                                Tariffsum,
                                                Orgcode,
                                                Servicenorm,
                                                Gkpsum1,
                                                Gkpsum2,
                                                Gkpsum3,
                                                Gkpsum4
                                           FROM XMLTABLE (
                                                    '*/row'
                                                    PASSING c.Subsidybenefitdetail
                                                    COLUMNS Servicecode         VARCHAR2 (10) PATH 'ServiceCode',
                                                            Electricity_Zone    VARCHAR2 (1) PATH 'Zone',
                                                            Tariffsum           NUMBER PATH 'TariffSum',
                                                            Orgcode             VARCHAR2 (10) PATH 'OrgCode',
                                                            Servicenorm         NUMBER PATH 'ServiceNorm',
                                                            Gkpsum1             NUMBER PATH 'GKPSum1', --сума за місяць (квітень)
                                                            Gkpsum2             NUMBER PATH 'GKPSum2', --сума за місяць (травень-вересень)
                                                            Gkpsum3             NUMBER PATH 'GKPSum3', --сума за місяць (жовтень)
                                                            Gkpsum4             NUMBER PATH 'GKPSum4' --сума за місяць (листопад-березень)
                                                                                                     )
                                                x,
                                                Uss_Ndi.v_Ndi_Pfu_Payment_Type Nppt
                                          WHERE Nppt_Code(+) = x.Servicecode)
                    LOOP
                        DECLARE
                            l_Sum   NUMBER := 0;
                        BEGIN
                            --Розбиваємо з c.StartDt по c.StopDt, на місяці та проходимо по ним
                            --суми розкидуємо по групах (GKPSum1, GKPSum2, ...), та в кожній групі вираховуємо період дії
                            FOR r
                                IN (WITH
                                        Months
                                        AS
                                            (    SELECT ADD_MONTHS (
                                                            TRUNC (c.Startdt,
                                                                   'MM'),
                                                            LEVEL - 1)    AS Begin_Dt
                                                   FROM DUAL
                                             CONNECT BY ADD_MONTHS (
                                                            TRUNC (c.Startdt,
                                                                   'MM'),
                                                            LEVEL - 1) <=
                                                        TRUNC (c.Stopdt,
                                                               'MM'))
                                      SELECT TO_NUMBER (
                                                 TO_CHAR (Begin_Dt, 'MM'))    Month_Num
                                        FROM Months
                                    ORDER BY Begin_Dt)
                            LOOP
                                IF    r.Month_Num BETWEEN 1 AND 3
                                   OR r.Month_Num BETWEEN 11 AND 12
                                THEN
                                    l_Sum := l_Sum + NVL (d.Gkpsum4, 0);
                                ELSIF r.Month_Num = 4
                                THEN
                                    l_Sum := l_Sum + NVL (d.Gkpsum1, 0);
                                ELSIF r.Month_Num BETWEEN 5 AND 9
                                THEN
                                    l_Sum := l_Sum + NVL (d.Gkpsum2, 0);
                                ELSIF r.Month_Num = 10
                                THEN
                                    l_Sum := l_Sum + NVL (d.Gkpsum3, 0);
                                END IF;
                            END LOOP;

                            IF l_Sum > 0
                            THEN
                                l_Scpp_Sum := l_Scpp_Sum + l_Sum;

                                INSERT INTO Sc_Scpp_Detail d (
                                                Scpd_Scpp,
                                                Scpd_Sc,
                                                Scpd_Service_Tp,
                                                Scpd_Nppt,
                                                Scpd_Nbc,
                                                Scpd_Start_Dt,
                                                Scpd_Stop_Dt,
                                                Scpd_Sum,
                                                Scpd_Scdi,
                                                Scpd_Electricity_Zone,
                                                Scpd_Tariff_Sum,
                                                Scpd_Org_Code,
                                                Scpd_Service_Norm,
                                                Scpd_Gkp_Sum1,
                                                Scpd_Gkp_Sum2,
                                                Scpd_Gkp_Sum3,
                                                Scpd_Gkp_Sum4,
                                                Scpd_St)
                                     VALUES (l_Scpp_Id,
                                             l_Sc_Main,
                                             d.Servicecode,
                                             d.Nppt_Id,
                                             NULL,
                                             c.Startdt,
                                             c.Stopdt,
                                             l_Sum,
                                             l_Scdi_Main,
                                             d.Electricity_Zone,
                                             d.Tariffsum,
                                             d.Orgcode,
                                             d.Servicenorm,
                                             d.Gkpsum1,
                                             d.Gkpsum2,
                                             d.Gkpsum3,
                                             d.Gkpsum4,
                                             'VR');
                            END IF;
                        END;
                    END LOOP;

                    --загальна сума призначених виплат
                    UPDATE Sc_Pfu_Pay_Summary t
                       SET t.Scpp_Sum = l_Scpp_Sum
                     WHERE t.Scpp_Id = l_Scpp_Id;
                END;

                --Дані про родину щодо призначеної виплати ПФУ
                UPDATE Sc_Scpp_Family
                   SET history_status = 'H'
                 WHERE     Scpf_Scpp = l_Scpp_Id
                       AND NVL (history_status, 'A') = 'A';

                FOR f
                    IN (          SELECT PersonInfo,
                                         Documents,
                                         Relationtp,
                                         Incapacitycat,
                                         Isvpo
                                    FROM XMLTABLE (
                                             '*/row'
                                             PASSING c.Familyinfo
                                             COLUMNS PersonInfo       XMLTYPE PATH 'Person_Info',
                                                     Documents        XMLTYPE PATH 'Documents',
                                                     Relationtp       VARCHAR2 (250) PATH 'RelationTp',
                                                     Incapacitycat    VARCHAR2 (250) PATH 'IncapacityCat',
                                                     Isvpo            VARCHAR2 (250) PATH 'IsVpo'))
                LOOP
                    DECLARE
                        l_Sc_Id     NUMBER;           --Соцкартка члена родини
                        l_Scdi_Id   NUMBER;
                        l_Scpf_Id   NUMBER;
                    BEGIN
                        IF f.Relationtp = 'MAIN'                   /*Заявник*/
                        THEN
                            l_Sc_Id := l_Sc_Main;
                            l_Scdi_Id := l_Scdi_Main;
                        ELSE
                            Save_Sc_Pfu_Data_Ident (
                                p_Person_Info   => f.PersonInfo,
                                p_Ur_Id         => p_Ur_Id,
                                p_Scdi_Id       => l_Scdi_Id,
                                p_Sc_Id         => l_Sc_Id);
                            Save_Sc_Pfu_Document (
                                p_Documents   => f.Documents,
                                p_Scdi_Id     => l_Scdi_Id,
                                p_Sc_Id       => l_Sc_Id);
                        END IF;

                        IF l_Scdi_Id IS NOT NULL
                        THEN
                            UPDATE Sc_Scpp_Family t
                               SET Scpf_Sc_Main = l_Sc_Main,
                                   Scpf_Scdi_Main = l_Scdi_Main,
                                   Scpf_Relation_Tp = f.Relationtp,
                                   Scpf_Incapacity_Category = f.Incapacitycat,
                                   Scpf_Is_Vpo = f.Isvpo
                             WHERE     t.Scpf_Scpp = l_Scpp_Id
                                   AND t.Scpf_Scdi_Main = l_Scdi_Id;

                            IF SQL%ROWCOUNT = 0
                            THEN
                                Api$socialcard.Save_Sc_Scpp_Family (
                                    p_Scpf_Id                    => l_Scpf_Id,
                                    p_Scpf_Scpp                  => l_Scpp_Id,
                                    p_Scpf_Sc                    => l_Sc_Id, --Соцкартка члена родини
                                    p_Scpf_Sc_Main               => l_Sc_Main, --Соцкартка отримувача виплати ПФУ
                                    p_Scpf_Scdi                  => l_Scdi_Id,
                                    p_Scpf_Scdi_Main             => l_Scdi_Main,
                                    p_Scpf_Relation_Tp           => f.Relationtp,
                                    p_Scpf_Marital_St            => NULL,
                                    p_Scpf_Incapacity_Category   =>
                                        f.Incapacitycat,
                                    p_Scpf_Is_Vpo                => f.Isvpo,
                                    p_Scpf_St                    => 'VR');
                            END IF;

                            IF c.Incomeincludemark IN ('1', '2')
                            THEN
                                Save_Benefit_Extend (
                                    p_Sc_Id              => l_Sc_Id,
                                    p_Scdi_Id            => l_Scdi_Id,
                                    p_Extend_Dt          => c.Pdstartdt,
                                    p_Is_Have_Sb_Right   =>
                                        CASE c.Incomeincludemark
                                            WHEN 1 THEN 'T'
                                            WHEN 2 THEN 'F'
                                            ELSE NULL
                                        END,
                                    p_Nbc                => 2,
                                    p_Scpp_Id            => l_Scpp_Id,
                                    p_Scpf_Id            => l_Scpf_Id);
                            END IF;
                        ELSE
                            NULL;            --не знайшли соцкарту, пропустити
                        END IF;
                    END;
                END LOOP;


                l_Result := 0;                           /*оновлення успішно*/
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK TO Svp_Handle_Put_Subsidy_Benefit;

                    l_Result := SQLCODE;
                    l_Error := SQLERRM;

                    --помилка ORA
                    IF l_Result > -20000
                    THEN
                        l_Error :=
                               l_Error
                            || CHR (10)
                            || DBMS_UTILITY.Format_Error_Backtrace;
                    END IF;

                    ikis_rbm.Api$uxp_Request.Save_Request_Error (
                        p_Ure_Ur        => p_Ur_Id,
                        p_Ure_Row_Id    => c.Id,
                        p_Ure_Row_Num   => c.ROWNUM,
                        p_Ure_Error     => l_Error);
            END;

            --результат обробки
            DBMS_LOB.Append (
                l_Clob,
                   '<row>'
                || '<Id>'
                || c.Id
                || '</Id>'
                || '<AnswerCode>'
                || l_Result
                || '</AnswerCode>'
                || '<AnswerMessage>'
                || l_Error
                || '</AnswerMessage>'
                || '<UssHouseholdId>'
                || CASE WHEN l_Result = 0 THEN l_Schh_Id END
                || '</UssHouseholdId>'
                || '</row>'
                || CHR (10));
        END LOOP;

        IF l_Empty_Loop
        THEN
            DBMS_LOB.Append (
                l_Clob,
                   '<row>'
                || '<Id>-1</Id>'
                || '<AnswerCode>-20000</AnswerCode>'
                || '<AnswerMessage>Масив записів порожній</AnswerMessage>'
                || '<UssHouseholdId></UssHouseholdId>'
                || '</row>'
                || CHR (10));
        END IF;

        DBMS_LOB.Append (l_Clob, '</Persons>');

        RETURN l_Clob;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20030,
                   'Помилка Обробки запита від ПФУ: '
                || SQLCODE
                || ' '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --#100876, USS.Common.PutAccrual
    --Сервіс збереження інформації щодо розшифровки даних по нарахуванням по рішенням
    FUNCTION Handle_Put_Accrual_Req (p_Ur_Id IN NUMBER,               --ignore
                                                        p_Request IN CLOB)
        RETURN CLOB
    IS
        l_Result   NUMBER := 1; /*1 - оновлення виконано успішно чи від'ємний код помилки*/
        l_Error    VARCHAR2 (32000);
        l_Clob     CLOB;
    BEGIN
        IF (p_Request IS NULL) OR (DBMS_LOB.Getlength (p_Request) = 0)
        THEN
            Raise_Application_Error (-20000, 'Вхідний запит пустий');
        END IF;

        DBMS_SESSION.Set_Nls ('NLS_NUMERIC_CHARACTERS', ''', ''');

        DBMS_LOB.Createtemporary (Lob_Loc => l_Clob, Cache => TRUE);
        DBMS_LOB.Open (Lob_Loc => l_Clob, Open_Mode => DBMS_LOB.Lob_Readwrite);
        DBMS_LOB.Append (l_Clob, '<PutAccrualResponse>');

        FOR c
            IN (     SELECT id,
                            PfuPdId,
                            PfuRcId,
                            AcDetail,
                            ROWNUM
                       FROM XMLTABLE ('*/row'
                                      PASSING xmltype (p_Request)
                                      COLUMNS id          NUMBER PATH 'Id',
                                              PfuPdId     NUMBER PATH 'PfuPdId',
                                              PfuRcId     NUMBER PATH 'PfuRcId',
                                              AcDetail    XMLTYPE PATH 'AcDetail'))
        LOOP
            SAVEPOINT Svp_Handle_Put_Accrual;

            DECLARE
                l_Scpp_Id   Sc_Pfu_Pay_Summary.Scpp_Id%TYPE;
                l_Schh_Id   Sc_Pfu_Pay_Summary.Scpp_Schh%TYPE;
                l_Sc_Id     Sc_Pfu_Pay_Summary.Scpp_Sc%TYPE;
                l_Scdi_Id   Sc_Pfu_Pay_Summary.Scpp_Scdi%TYPE;
            BEGIN
                l_Result := NULL;
                l_Error := NULL;

                --шукаємо рішення за ІД рішенням ПФУ
                BEGIN
                    SELECT p.Scpp_Id,
                           p.Scpp_Schh,
                           p.Scpp_Sc,
                           Scpp_Scdi
                      INTO l_Scpp_Id,
                           l_Schh_Id,
                           l_Sc_Id,
                           l_Scdi_Id
                      FROM Sc_Pfu_Pay_Summary p
                     WHERE     p.Scpp_Pfu_Pd_Id = c.PfuPdId
                           AND NVL (p.history_status, 'A') = 'A';
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

                IF l_Scpp_Id IS NULL
                THEN
                    Raise_Application_Error (-20001,
                                             'Рішення (scpp_id) не знайдено');
                END IF;

                --PfuRcId + PfuPdId являється ключом, якщо є існуюча комбінація то необхідно її закрити
                DECLARE
                    l_scpc_list   OWA_UTIL.num_arr;
                BEGIN
                    SELECT scpc_id
                      BULK COLLECT INTO l_scpc_list
                      FROM Sc_Pfu_Accrual
                     WHERE     scpc_scpp = l_Scpp_Id
                           AND scpc_pfu_rc_id = c.PfuRcId
                           AND NVL (history_status, 'A') = 'A';

                    FORALL i IN 1 .. l_scpc_list.COUNT
                        UPDATE sc_pfu_accrual
                           SET history_status = 'H'
                         WHERE scpc_id = l_scpc_list (i);
                END;

                --занести нові суми
                FOR d
                    IN (        SELECT TO_DATE (AcdDt, 'mm-yyyy')
                                           AcdDt,
                                       TO_DATE (AcdAcDt, 'mm-yyyy')
                                           AcdAcDt,
                                       ServiceCode,
                                       AcdSum,
                                       TO_CHAR (TO_DATE (AcdAcDt, 'mm-yyyy'), 'mm')
                                           Mm,
                                       TO_CHAR (TO_DATE (AcdAcDt, 'mm-yyyy'), 'yyyy')
                                           Yyyy
                                  FROM XMLTABLE (
                                           '*/row'
                                           PASSING c.AcDetail
                                           COLUMNS AcdDt          VARCHAR2 (250) PATH 'AcdDt',
                                                   AcdAcDt        VARCHAR2 (250) PATH 'AcdAcDt',
                                                   ServiceCode    VARCHAR2 (10) PATH 'ServiceCode', /*uss_ndi.ndi_pfu_payment_type*/
                                                   AcdSum         NUMBER PATH 'AcdSum'))
                LOOP
                    DECLARE
                        l_Nppt_Id   NUMBER;
                    BEGIN
                        SELECT MAX (nppt_id)
                          INTO l_Nppt_Id
                          FROM uss_ndi.v_ndi_pfu_payment_type
                         WHERE nppt_code = d.ServiceCode;

                        INSERT INTO sc_pfu_accrual (scpc_id,
                                                    scpc_sc,
                                                    scpc_scdi,
                                                    scpc_scpp,
                                                    scpc_schh,
                                                    scpc_nppt,
                                                    scpc_change_dt,
                                                    scpc_acd_dt,
                                                    scpc_acd_ac_dt,
                                                    scpc_acd_sum,
                                                    scpc_pfu_rc_id,
                                                    scpc_service_code,
                                                    scpc_st,
                                                    history_status)
                             VALUES (0,
                                     l_Sc_Id,
                                     l_Scdi_Id,
                                     l_Scpp_Id,
                                     l_Schh_Id,
                                     l_Nppt_Id,
                                     SYSDATE,
                                     d.AcdDt,
                                     d.AcdAcDt,
                                     d.AcdSum,
                                     c.PfuRcId,
                                     d.ServiceCode,
                                     'VO',
                                     'A');
                    END;
                END LOOP;

                l_Result := 1;              /*1 - оновлення виконано успішно*/
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK TO Svp_Handle_Put_Accrual;

                    l_Result := SQLCODE;
                    l_Error := SQLERRM;

                    --помилка ORA
                    IF l_Result > -20000
                    THEN
                        l_Error :=
                               l_Error
                            || CHR (10)
                            || DBMS_UTILITY.Format_Error_Backtrace;
                    END IF;

                    ikis_rbm.Api$uxp_Request.Save_Request_Error (
                        p_Ure_Ur        => p_Ur_Id,
                        p_Ure_Row_Id    => c.Id,
                        p_Ure_Row_Num   => c.ROWNUM,
                        p_Ure_Error     => l_Error);
            END;

            --результат обробки
            DBMS_LOB.Append (
                l_Clob,
                   '<row>'
                || '<Id>'
                || c.Id
                || '</Id>'
                || '<PfuPdId>'
                || c.PfuPdId
                || '</PfuPdId>'
                || '<Result>'
                || l_Result
                || '</Result>'
                || '<Error>'
                || l_Error
                || '</Error>'
                || '</row>'
                || CHR (10));
        END LOOP;

        DBMS_LOB.Append (l_Clob, '</PutAccrualResponse>');

        RETURN l_Clob;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20030,
                   'Помилка Обробки запита від ПФУ: '
                || SQLCODE
                || ' '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --#95402, USS.Common.PutPayroll
    --Сервіс збереження даних виплатної відомості
    FUNCTION Handle_Put_Payroll_Req (p_Ur_Id IN NUMBER,               --ignore
                                                        p_Request IN CLOB)
        RETURN CLOB
    IS
        l_Rn_Id    NUMBER;
        l_Result   NUMBER := 1; /*1 - оновлення виконано успішно чи від'ємний код помилки*/
        l_Error    VARCHAR2 (32000);
        l_Clob     CLOB;
    BEGIN
        IF (p_Request IS NULL) OR (DBMS_LOB.Getlength (p_Request) = 0)
        THEN
            Raise_Application_Error (-20000, 'Вхідний запит пустий');
        END IF;

        DBMS_SESSION.Set_Nls ('NLS_NUMERIC_CHARACTERS', ''', ''');

        DBMS_LOB.Createtemporary (Lob_Loc => l_Clob, Cache => TRUE);
        DBMS_LOB.Open (Lob_Loc => l_Clob, Open_Mode => DBMS_LOB.Lob_Readwrite);
        DBMS_LOB.Append (l_Clob, '<PutPayrollResponse>');

        FOR c
            IN (       SELECT id,
                              PcNum,
                              PdPayMd,
                              PrsAccount,
                              PersonInfo,
                              Documents,
                              SGTPMark,
                              TO_DATE (PrsPayDt, 'dd-mm-yyyy')     PrsPayDt,
                              PrsSum,
                              PrId,
                              PrsId,
                              ROWNUM
                         FROM XMLTABLE (
                                  'PutPayrollRequest/row'
                                  PASSING xmltype (p_Request)
                                  COLUMNS id            NUMBER PATH 'Id',
                                          PcNum         VARCHAR2 (50) PATH 'PcNum',
                                          PdPayMd       VARCHAR2 (50) PATH 'PdPayMd',
                                          PrsAccount    VARCHAR2 (29) PATH 'PrsAccount',
                                          PersonInfo    XMLTYPE PATH 'Person_Info',
                                          Documents     XMLTYPE PATH 'Documents',
                                          SGTPMark      NUMBER PATH 'SGTPMark',
                                          PrsPayDt      VARCHAR2 (50) PATH 'PrsPayDt',
                                          PrsSum        NUMBER PATH 'PrsSum',
                                          PrId          NUMBER PATH 'PrId',
                                          PrsId         NUMBER PATH 'PrsId'))
        LOOP
            SAVEPOINT Svp_Handle_Put_Payroll;

            DECLARE
                l_Scdi_Id    Sc_Pfu_Data_Ident.Scdi_Id%TYPE;
                l_Sc_Id      Sc_Pfu_Data_Ident.Scdi_Sc%TYPE;
                l_Scpu_Id    Sc_Pfu_Pay_Out.Scpu_Id%TYPE;
                l_Scpu_Sum   Sc_Pfu_Pay_Out.Scpu_Sum%TYPE;
                l_skip       BOOLEAN := FALSE;
            BEGIN
                l_Result := NULL;
                l_Error := NULL;

                Save_Sc_Pfu_Data_Ident (p_Person_Info   => c.PersonInfo,
                                        p_Ur_Id         => p_Ur_Id,
                                        p_Scdi_Id       => l_Scdi_Id,
                                        p_Sc_Id         => l_Sc_Id);
                Save_Sc_Pfu_Document (p_Documents   => c.Documents,
                                      p_Scdi_Id     => l_Scdi_Id,
                                      p_Sc_Id       => l_Sc_Id);

                --Наявність соц.картки заявника критична
                IF l_Scdi_Id IS NULL
                THEN
                    Raise_Application_Error (
                        -20001,
                        'Помилка створення особи заявника (scdi)');
                    CONTINUE;
                END IF;

                --Перевірка на існування дублікату рядка відомості
                SELECT MAX (scpu_id), MAX (Scpu_Sum)
                  INTO l_Scpu_Id, l_Scpu_Sum
                  FROM Sc_Pfu_Pay_Out
                 WHERE     scpu_pr_id = c.PrId
                       AND scpu_prs_id = c.PrsId
                       AND NVL (history_status, 'A') = 'A';

                --Якщо у крайньому випадку запис існує, але сума відрізняється, то запис буде переведений до архівного статусу
                IF l_Scpu_Id IS NOT NULL AND l_Scpu_Sum <> c.PrsSum
                THEN
                    UPDATE Sc_Pfu_Pay_Out
                       SET history_status = 'H'
                     WHERE     scpu_id = l_scpu_id
                           AND NVL (history_status, 'A') = 'A';
                --Якщо це звичайний дублікат то ігноруємо додавання
                ELSIF l_Scpu_Id IS NOT NULL
                THEN
                    l_skip := TRUE;
                END IF;

                IF NOT l_skip
                THEN
                    INSERT INTO Sc_Pfu_Pay_Out (scpu_id,
                                                scpu_sc,
                                                scpu_scdi,
                                                scpu_pdu_pc_num,
                                                scpu_pfu_pay_method,
                                                scpu_account,
                                                scpu_sgtp_mark,
                                                scpu_pay_dt,
                                                scpu_sum,
                                                scpu_pr_id,
                                                scpu_prs_id,
                                                scpu_st,
                                                history_status)
                         VALUES (0,
                                 l_Sc_Id,
                                 l_Scdi_Id,
                                 c.PcNum,
                                 c.PdPayMd,
                                 c.PrsAccount,
                                 c.SGTPMark,
                                 c.PrsPayDt,
                                 c.PrsSum,
                                 c.PrId,
                                 c.PrsId,
                                 'VR',
                                 'A');
                END IF;

                l_Result := 1;              /*1 - оновлення виконано успішно*/
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK TO Svp_Handle_Put_Payroll;

                    l_Result := SQLCODE;
                    l_Error := SQLERRM;

                    --помилка ORA
                    IF l_Result > -20000
                    THEN
                        l_Error :=
                               l_Error
                            || CHR (10)
                            || DBMS_UTILITY.Format_Error_Backtrace;
                    END IF;

                    ikis_rbm.Api$uxp_Request.Save_Request_Error (
                        p_Ure_Ur        => p_Ur_Id,
                        p_Ure_Row_Id    => c.Id,
                        p_Ure_Row_Num   => c.ROWNUM,
                        p_Ure_Error     => l_Error);
            END;

            --результат обробки
            DBMS_LOB.Append (
                l_Clob,
                   '<row><Id>'
                || c.Id
                || '</Id><Result>'
                || l_Result
                || '</Result><Error>'
                || l_Error
                || '</Error></row>'
                || CHR (10));
        END LOOP;

        DBMS_LOB.Append (l_Clob, '</PutPayrollResponse>');

        RETURN l_Clob;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20030,
                   'Помилка Обробки запита від ПФУ: '
                || SQLCODE
                || ' '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    --#100877, USS.Common.PutSuspendedDecision
    --Сервіс отримання інформації по призупиненим рішенням
    FUNCTION Handle_Put_Suspended_Decision_Req (p_Ur_Id     IN NUMBER, --ignore
                                                p_Request   IN CLOB)
        RETURN CLOB
    IS
        l_Xml      XMLTYPE;
        l_Result   NUMBER := 0; /*0 – інформація отримана успішно, 1 – не вдалося знайти рішення, 9 – інша помилка*/
        l_Error    VARCHAR2 (32000);
        l_Clob     CLOB;
    BEGIN
        IF (p_Request IS NULL) OR (DBMS_LOB.Getlength (p_Request) = 0)
        THEN
            Raise_Application_Error (-20000, 'Вхідний запит пустий');
        END IF;

        DBMS_LOB.Createtemporary (Lob_Loc => l_Clob, Cache => TRUE);
        DBMS_LOB.Open (Lob_Loc => l_Clob, Open_Mode => DBMS_LOB.Lob_Readwrite);
        DBMS_LOB.Append (l_Clob, '<PutSuspendedDecisionResponseRequest>');

        FOR c
            IN (        SELECT id,
                               PdId,
                               TO_DATE (SuspDt, 'dd.mm.yyyy')                SuspDt,
                               SuspRsnName,
                               SuspRsnCode,
                               TO_DATE (OperDt, 'dd.mm.yyyy hh24:mi:ss')     OperDt,
                               ROWNUM
                          FROM XMLTABLE (
                                   '*/row'
                                   PASSING xmltype (p_Request)
                                   COLUMNS id             NUMBER PATH 'Id',
                                           PdId           NUMBER PATH 'PdId',
                                           SuspDt         VARCHAR2 (250) PATH 'SuspDt',
                                           SuspRsnName    VARCHAR2 (500) PATH 'SuspRsnName',
                                           SuspRsnCode    VARCHAR2 (250) PATH 'SuspRsnCode',
                                           OperDt         VARCHAR2 (250) PATH 'OperDt'))
        LOOP
            SAVEPOINT Svp_Handle_Put_Suspended_Decision;

            DECLARE
                l_Scpp_Id   Sc_Pfu_Pay_Summary.Scpp_Id%TYPE;
                l_Oper_Dt   DATE;
            BEGIN
                l_Result := NULL;
                l_Error := NULL;

                --шукаємо рішення за ІД рішенням ПФУ
                BEGIN
                    SELECT p.Scpp_Id
                      INTO l_Scpp_Id
                      FROM Sc_Pfu_Pay_Summary p
                     WHERE     p.Scpp_Pfu_Pd_Id = c.PdId
                           AND NVL (history_status, 'A') = 'A';
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

                --Якщо по існуючому рішеню прийшла відмова, то закриваємо його
                IF l_Scpp_Id IS NOT NULL
                THEN
                    SELECT scpp_suspended_oper_dt
                      INTO l_Oper_Dt
                      FROM sc_pfu_pay_summary
                     WHERE Scpp_Id = l_Scpp_Id;

                    IF    l_Oper_Dt > c.OperDt
                       OR (l_Oper_Dt IS NOT NULL AND c.OperDt IS NULL)
                    THEN
                        NULL; --У нас вже зберігається більш актуальна операція, операцію що поступила в чергу ігноруємо
                    ELSIF c.SuspDt IS NULL
                    THEN
                        --операція відновлення рішення після призупинення
                        UPDATE sc_pfu_pay_summary
                           SET scpp_suspended_dt = NULL,
                               scpp_suspended_reason = c.SuspRsnCode, --RESTORE
                               scpp_suspended_name = c.SuspRsnName,
                               scpp_pfu_pd_st = 'S',
                               scpp_change_dt = SYSDATE,
                               scpp_suspended_oper_dt = c.OperDt
                         WHERE scpp_id = l_scpp_id;
                    ELSE
                        --операція призупинення рішення
                        UPDATE sc_pfu_pay_summary
                           SET scpp_suspended_dt = c.SuspDt,
                               scpp_suspended_reason = c.SuspRsnCode, --V_DDN_SCPP_SUSPENDED_REASON
                               scpp_suspended_name = c.SuspRsnName,
                               scpp_pfu_pd_st = 'PS',
                               scpp_change_dt = SYSDATE,
                               scpp_suspended_oper_dt = c.OperDt
                         WHERE scpp_id = l_scpp_id;
                    END IF;

                    l_result := 0;             /*інформація отримана успішно*/
                ELSE
                    l_result := 1;
                    l_error := 'Не вдалося знайти рішення';
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK TO Svp_Handle_Put_Suspended_Decision;

                    l_result := SQLCODE;
                    l_error := SQLERRM;

                    --помилка ORA
                    IF l_result > -20000
                    THEN
                        l_error :=
                               l_error
                            || CHR (10)
                            || DBMS_UTILITY.Format_Error_Backtrace;
                    END IF;

                    ikis_rbm.Api$uxp_Request.Save_Request_Error (
                        p_Ure_Ur        => p_Ur_Id,
                        p_Ure_Row_Id    => c.Id,
                        p_Ure_Row_Num   => c.ROWNUM,
                        p_Ure_Error     => l_Error);

                    l_result := 9;                            /*інша помилка*/
            END;

            --результат обробки
            DBMS_LOB.Append (
                l_Clob,
                   '<row><Id>'
                || c.Id
                || '</Id><Technanswer><AnswerCode>'
                || l_Result
                || '</AnswerCode><AnswerMessage>'
                || l_Error
                || '</AnswerMessage></Technanswer></row>'
                || CHR (10));
        END LOOP;

        DBMS_LOB.Append (l_Clob, '</PutSuspendedDecisionResponseRequest>');

        RETURN l_Clob;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20030,
                   'Помилка Обробки запита від ПФУ: '
                || SQLCODE
                || ' '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -- 13/07/2024 serhii: #95404 Попереднє збереження категорії пільги з прив'язкою до scdi_id
    FUNCTION Save_Benefit_Cat_Pre_Vf (
        p_Benefit_Cat   IN r_Benefit_Cat,
        p_Scdi_Id       IN sc_pfu_data_ident.scdi_id%TYPE,
        p_Src           IN VARCHAR2 DEFAULT c_Src_Pfu)
        RETURN sc_benefit_category%ROWTYPE
    IS
        l_Nbc_Id     NUMBER (14);
        l_Scbc_Id    sc_benefit_category.scbc_id%TYPE := NULL;
        l_Scpo_Id    sc_pfu_document.scpo_id%TYPE;
        l_Scbc_Row   sc_benefit_category%ROWTYPE;
    BEGIN
        /* 13/07/2024 serhii #95404
            Збереження пільг (Sc_Benefit_Type), закриття історичних даних тут не виконується.
            Це потрібно реалізувати на етапі верифікації та після прив'язки до Sc_Id (СРКО)
        */
        IF p_Benefit_Cat.AproveDocs IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'В запиті відсутні дані документів що підтверджують категорії пільговика.');
        END IF;

        SELECT Nbc_Id
          INTO l_Nbc_Id
          FROM Uss_Ndi.v_Ndi_Benefit_Category c
         WHERE c.Nbc_Code = p_Benefit_Cat.CatCode;

        --збереження пільгової категорії
        IF l_Nbc_Id IS NOT NULL
        THEN
            INSERT INTO Sc_Benefit_Category (scbc_nbc,
                                             scbc_start_dt,
                                             scbc_stop_dt,
                                             scbc_src,
                                             scbc_create_dt,
                                             scbc_modify_dt,
                                             scbc_st,
                                             scbc_scdi)
                 VALUES (l_Nbc_Id,
                         p_Benefit_Cat.CatFromDt,
                         p_Benefit_Cat.CatTillDt,
                         p_Src,
                         SYSDATE,
                         NULL,
                         c_St_Vf_Rq,
                         p_Scdi_Id)
              RETURNING scbc_id,
                        scbc_sc,
                        scbc_nbc,
                        scbc_start_dt,
                        scbc_stop_dt,
                        scbc_src,
                        scbc_create_dt,
                        scbc_modify_dt,
                        scbc_st,
                        scbc_scdi
                   INTO l_Scbc_Row;

            -- Документи що підтверджують категорії пільговика
            FOR i IN 1 .. p_Benefit_Cat.AproveDocs.COUNT
            LOOP
                Save_Sc_Pfu_Document (
                    p_Sc_Id      => NULL,
                    p_Scdi_Id    => p_Scdi_Id,
                    p_Document   => p_Benefit_Cat.AproveDocs (i),
                    p_Scpo_Id    => l_Scpo_Id);

                -- прив'язка документа до категорії
                INSERT INTO sc_benefit_docs (scbd_scbc,
                                             scbd_scd,
                                             scbd_scpo,
                                             scbd_st)
                     VALUES (l_Scbc_Row.Scbc_Id,
                             NULL,
                             l_Scpo_Id,
                             c_St_Vf_Rq);
            END LOOP;
        /* після визначення СРКО
        --проставити дату початку/закінчення дії пільг на підставі документів
        Set_Sc_Benefit_Stop_Dt(p_Scbc_Id => v_Scbc_Id); */
        END IF;

        RETURN l_Scbc_Row;
    END Save_Benefit_Cat_Pre_Vf;

    -- Інформація про сім’ю пільговика
    FUNCTION Save_Sc_Scpp_Family (
        p_Family_Prs   r_Family_Person_Info,
        p_Scdi_Id      sc_pfu_data_ident.scdi_id%TYPE,
        p_Un_Id        NUMBER)
        RETURN NUMBER
    IS
        l_Scpf_Scdi   sc_scpp_family.scpf_scdi%TYPE;
        l_Scpf_Id     sc_scpp_family.scpf_id%TYPE;
    BEGIN
        IF p_Family_Prs.Relationtp IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'В запиті відсутні дані про ступінь родинного зв’язку члена сім’ї пільговика.');
        END IF;

        Save_Sc_Pfu_Data_Ident (p_Person_Info   => p_Family_Prs.Person_Info,
                                p_Ur_Id         => p_Un_Id,
                                p_Scdi_Id       => l_Scpf_Scdi);

        Api$socialcard.Save_Sc_Scpp_Family (
            p_Scpf_Id                    => l_Scpf_Id,
            p_Scpf_Scpp                  => NULL,
            p_Scpf_Sc                    => NULL,
            p_Scpf_Sc_Main               => NULL,
            p_Scpf_Scdi                  => l_Scpf_Scdi,
            p_Scpf_Scdi_Main             => p_Scdi_Id,
            p_Scpf_Relation_Tp           => p_Family_Prs.RelationTp,
            p_Scpf_Marital_St            => NULL,
            p_Scpf_Incapacity_Category   => NULL,
            p_Scpf_Is_Vpo                => NULL,
            p_Scpf_St                    => c_St_Vf_Rq);
        RETURN l_Scpf_Id;
    END Save_Sc_Scpp_Family;
BEGIN
    NULL;
END Dnet$exch_Uss2ikis;
/