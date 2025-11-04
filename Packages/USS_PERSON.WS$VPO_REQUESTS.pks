/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.WS$VPO_REQUESTS
IS
    -- Author  : SERHII
    -- Created : 12.03.2024 15:36:27
    -- Purpose : Надає дані по довідкам ВПО зовнішнім системам. #88506

    TYPE r_Nazk_VPO_Req IS RECORD
    (
        PersNum    VARCHAR2 (250),
        LN         VARCHAR2 (250),
        FN         VARCHAR2 (250),
        MN         VARCHAR2 (250),
        DocTp      VARCHAR2 (50),
        IPN        VARCHAR2 (50),
        DocSn      VARCHAR2 (50)
    );

    TYPE t_Nazk_VPO_Req IS TABLE OF r_Nazk_VPO_Req;

    TYPE r_Nazk_VPO_Resp IS RECORD
    (
        PersNum                  VARCHAR2 (250),
        AnswerCode               NUMBER,
        AnswerMessage            VARCHAR2 (4000),
        LN                       VARCHAR2 (250),
        FN                       VARCHAR2 (250),
        MN                       VARCHAR2 (250),
        BirthDt                  DATE,
        IPN                      VARCHAR2 (20),
        Gender                   VARCHAR2 (10),
        DocTp                    VARCHAR2 (50),
        DocSer                   VARCHAR2 (50),
        DocNum                   VARCHAR2 (50),
        DocDt                    DATE,
        DocIssuer                VARCHAR2 (4000),
        RegAddressTxt            VARCHAR2 (4000),
        FactAddressTxt           VARCHAR2 (4000),
        GUID                     VARCHAR2 (100),
        CertNum                  VARCHAR2 (50),
        CertDt                   DATE,
        CertIssuer               VARCHAR2 (4000),
        CertSt                   VARCHAR2 (50),
        CertStName               VARCHAR2 (50),
        DateEnd                  DATE,
        CertCancelRsnId          NUMBER,
        KATOTTG                  VARCHAR2 (500),
        FactAddressKATOTTG       VARCHAR2 (500),
        FactAddressStreetId      VARCHAR2 (50),
        FactAddressStreetName    VARCHAR2 (500),
        FactAddressHouse         VARCHAR2 (50),
        FactAddressBuilding      VARCHAR2 (50),
        FactAddressFlat          VARCHAR2 (50),
        Scd_Dh                   sc_document.scd_dh%TYPE
    );

    TYPE t_Nazk_VPO_Resp IS TABLE OF r_Nazk_VPO_Resp;

    PROCEDURE Check_Rights;

    PROCEDURE Write_Access_Event;

    --  serhii Обробка запиту від НФЗК на отримання даних довідок ВПО, нарахованих
    --  та виплачених сум допомоги на проживання ВПО #88506
    FUNCTION Handle_Get_VPO_Sert_Req (p_Request_Id     IN NUMBER,
                                      p_Request_Body   IN CLOB)
        RETURN CLOB;

    -------------------------------------------------------------------------------
    --   Обробка запиту від НФЗК на отримання даних довідок ВПО, нарахованих та
    --   виплачених сум допомоги на проживання ВПО 101511
    -------------------------------------------------------------------------------
    FUNCTION Handle_Get_VPO_Sert_only_Req (p_Request_Id     IN NUMBER,
                                           p_Request_Body   IN CLOB)
        RETURN CLOB;
END Ws$VPO_Requests;
/


GRANT EXECUTE ON USS_PERSON.WS$VPO_REQUESTS TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:57:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.WS$VPO_REQUESTS
IS
    -- Constants
    c_Npt_VPO   NUMBER (14) := 167;

    -- Private type declarations
    TYPE r_Nazk_Req IS RECORD
    (
        LastName       VARCHAR2 (250),
        FirstName      VARCHAR2 (250),
        SecondName     VARCHAR2 (250),
        DocType        NUMBER,
        IPN            VARCHAR2 (10),
        DocSN          VARCHAR2 (50),
        PeriodStart    DATE,
        PeriodEnd      DATE
    );

    TYPE r_Cert_Elems IS RECORD
    (
        Sert_No            VARCHAR2 (20),
        Sert_Date          DATE,
        Sert_Iss           VARCHAR2 (4000),
        Rem_Date           DATE,
        Sert_St            VARCHAR2 (100),
        Kat_Ottg           VARCHAR2 (4000),
        Sert_Id            VARCHAR2 (100),
        Adr_Res            VARCHAR2 (4000),
        Adr_Reg            VARCHAR2 (4000),
        Adr_Change_Mark    VARCHAR2 (100),
        SUM_Accr           NUMBER (18, 2),
        SUM_Pay            NUMBER (18, 2),
        Scd_Dh             sc_document.scd_dh%TYPE
    );

    TYPE r_Person_Elems IS RECORD
    (
        Сertificate    r_Cert_Elems,
        Last_Name       VARCHAR2 (200),
        First_Name      VARCHAR2 (200),
        Second_Name     VARCHAR2 (200),
        D_Birth         DATE,
        L_Birth         VARCHAR2 (4000),
        ST              NUMBER,
        Doc_Type        NUMBER,
        IPN             VARCHAR2 (20),
        Doc_SN          VARCHAR2 (20)
    );

    TYPE r_Response_Elems IS RECORD
    (
        Person    r_Person_Elems,
        Reslt     NUMBER
    );



    PROCEDURE Check_Rights
    IS
    BEGIN
        NULL;
    END Check_Rights;

    PROCEDURE Write_Access_Event
    IS
    BEGIN
        NULL;
    END Write_Access_Event;

    FUNCTION Get_Result_XML (p_Result_Code IN NUMBER)
        RETURN CLOB
    IS
        l_Res_xml   XMLTYPE;
    BEGIN
        -- <Result>1</Result> 1-Особу знайдено; 2-Особу не знайдено; 3 – Неможливо однозначно ідентифікувати особу; 9 – Інша помилка.
        SELECT XMLELEMENT ("GetSertVPOandSumResponse",
                           XMLELEMENT ("Result", p_Result_Code))
          INTO l_Res_xml
          FROM DUAL;

        RETURN l_Res_xml.getClobVal;
    END Get_Result_XML;

    FUNCTION Get_Pc_Id (p_sc_id IN NUMBER)
        RETURN NUMBER
    IS
        l_res   uss_esr.v_personalcase.pc_id%TYPE;
    BEGIN
        SELECT pc_id
          INTO l_res
          FROM uss_esr.v_personalcase
         WHERE PC_SC = p_sc_id;

        RETURN l_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END Get_Pc_Id;

    --Отримати суму нарахувань за період #88506
    FUNCTION get_accrual_sum (p_pc_id     NUMBER,
                              p_from_dt   DATE,
                              p_to_dt     DATE,
                              p_npt       NUMBER)
        RETURN NUMBER
    IS
        l_res   NUMBER (18, 2);
    BEGIN
        uss_esr.ws$vpo_requests.fetch_accrual_data (p_pc_id          => p_pc_id,
                                                    p_from_dt        => p_from_dt,
                                                    p_to_dt          => p_to_dt,
                                                    p_npt            => p_npt,
                                                    p_access_token   => NULL);

        SELECT NVL (SUM (x_sum1), 0)
          INTO l_res
          FROM uss_esr.tmp_work_set1
         WHERE x_string1 = 'fetch_accrual_data';

        RETURN l_res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN 0;
    END;

    --Отримати суму виплат за період #88506
    FUNCTION get_payroll_sum (p_pc_id     NUMBER,
                              p_from_dt   DATE,
                              p_to_dt     DATE,
                              p_npt       NUMBER)
        RETURN NUMBER
    IS
        l_res   NUMBER (18, 2);
    BEGIN
        uss_esr.ws$vpo_requests.fetch_payroll_data (p_pc_id          => p_pc_id,
                                                    p_from_dt        => p_from_dt,
                                                    p_to_dt          => p_to_dt,
                                                    p_npt            => p_npt,
                                                    p_access_token   => NULL);

        SELECT NVL (SUM (x_sum1), 0)
          INTO l_res
          FROM uss_esr.tmp_work_set1
         WHERE x_string1 = 'fetch_payroll_data';

        RETURN l_res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN 0;
    END;

    -------------------------------------------------------------------------------
    --   Отримання  довідки ВПО #88506
    --   шукаєм актуальну Довідку ВПО цієї особи (якщо не знайшли актуальної - останню за датою видачі)
    -------------------------------------------------------------------------------
    FUNCTION Get_Vpo_Data (p_sc_id IN NUMBER)
        RETURN r_Cert_Elems
    IS
        l_Rslt   r_Cert_Elems;
    BEGIN
        SELECT t.scd_number,
               t.scd_issued_dt,
               t.scd_issued_who,
               t.scd_st,
               t.scd_dh
          INTO l_Rslt.Sert_No,
               l_Rslt.Sert_Date,
               l_Rslt.Sert_Iss,
               l_Rslt.Sert_St,
               l_Rslt.Scd_Dh
          FROM (SELECT ROW_NUMBER ()
                           OVER (
                               PARTITION BY d.scd_sc, d.scd_ndt
                               ORDER BY
                                   CASE d.scd_st WHEN '1' THEN 0 ELSE 1 END ASC,
                                   d.scd_issued_dt DESC)    rn,
                       d.*
                  FROM v_sc_document d
                 WHERE d.scd_ndt = Load$vpo.c_Ndt_Vpo AND d.scd_sc = p_sc_id)
               t
         WHERE t.rn = 1;

        RETURN l_Rslt;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION Parse_Nazk_Req (p_Request_Body IN CLOB)
        RETURN r_Nazk_Req
    IS
        l_Res   r_Nazk_Req;
    BEGIN
                /*
                    TODO: owner="serhii" category="Optimize" priority="3 - Low" created="29.03.2024"
                    text="можна переписати на Type2xmltable :
                                EXECUTE IMMEDIATE Type2xmltable(Package_Name, 'R_SAVE_PERSON_BENEFIT_CATS_REQ', 'dd.mm.yyyy')
                                  USING IN p_Request_Body, OUT l_Request;
                              EXCEPTION
                                WHEN OTHERS THEN
                                  Raise_Application_Error(-20000, 'Помилка парсингу запиту: ' || SQLERRM);
                              END;"
                    */
                SELECT LastName,
                       FirstName,
                       SecondName,
                       DocType,
                       TO_NUMBER (IPN),
                       DocSN,
                       TO_DATE (PeriodStart, 'DD-MM-YYYY'),
                       TO_DATE (PeriodEnd, 'DD-MM-YYYY')
                  INTO l_Res.LastName,
                       l_Res.FirstName,
                       l_Res.SecondName,
                       l_Res.DocType,
                       l_Res.IPN,
                       l_Res.DocSN,
                       l_Res.PeriodStart,
                       l_Res.PeriodEnd
                  FROM XMLTABLE (
                           '/GetSertVPOandSumRequest'
                           PASSING Xmltype (p_Request_Body)
                           COLUMNS LastName       VARCHAR2 (500) PATH 'Last_Name',
                                   FirstName      VARCHAR2 (500) PATH 'First_Name',
                                   SecondName     VARCHAR2 (500) PATH 'Second_Name',
                                   DocType        VARCHAR2 (500) PATH 'Doc_Type',
                                   IPN            VARCHAR2 (500) PATH 'IPN',
                                   DocSN          VARCHAR2 (500) PATH 'Doc_SN',
                                   PeriodStart    VARCHAR2 (500) PATH 'Period_Start',
                                   PeriodEnd      VARCHAR2 (500) PATH 'Period_End');

        RETURN l_Res;
    END;


    FUNCTION Parse_Nazk_VPO_Req (p_Request_Body IN CLOB)
        RETURN t_Nazk_VPO_Req
    IS
        l_Res   t_Nazk_VPO_Req;
    BEGIN
            SELECT Tools.TrimXMLStr (PersNum),
                   Tools.TrimXMLStr (LN),
                   Tools.TrimXMLStr (FN),
                   Tools.TrimXMLStr (Mn),
                   Tools.TrimXMLStr (DocTp),
                   Tools.TrimXMLStr (IPN),
                   Tools.TrimXMLStr (DocSn)
              BULK COLLECT INTO l_Res
              FROM XMLTABLE ('/GetCertVPORequest/Persons/Person'
                             PASSING Xmltype (p_Request_Body)
                             COLUMNS PersNum    VARCHAR2 (500) PATH 'PersNum',
                                     LN         VARCHAR2 (500) PATH 'Ln',
                                     FN         VARCHAR2 (500) PATH 'Fn',
                                     MN         VARCHAR2 (500) PATH 'Mn',
                                     DocTp      VARCHAR2 (500) PATH 'DocTp',
                                     IPN        VARCHAR2 (500) PATH 'IPN',
                                     DocSN      VARCHAR2 (500) PATH 'DocSn');

        RETURN l_Res;
    END;


    -------------------------------------------------------------------------------
    --   Обробка запиту від НФЗК на отримання даних довідок ВПО, нарахованих та
    --   виплачених сум допомоги на проживання ВПО #88506
    -------------------------------------------------------------------------------
    FUNCTION Handle_Get_VPO_Sert_Req (p_Request_Id     IN NUMBER,
                                      p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Req          r_Nazk_Req;
        l_Sc_Id        Socialcard.Sc_Id%TYPE;
        l_pc_id        uss_esr.v_personalcase.pc_id%TYPE;
        l_Error        VARCHAR2 (2000);
        l_Resp_Xml     XMLTYPE;
        l_Resp         r_Response_Elems;
        l_Found_Cnt    PLS_INTEGER;
        l_Show_Modal   PLS_INTEGER;
        l_Row          Api$socialcard.r_Search_Sc;
        l_Persons      SYS_REFCURSOR;
    BEGIN
        BEGIN
            -- парсим запит
            l_Req := Parse_Nazk_Req (p_Request_Body);
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту' || CHR (10) || SQLERRM);
        END;

        --перевірка на обов'язкові поля
        IF l_Req.LastName IS NULL
        THEN
            l_Error := ' Last_Name;';                 -- || Chr(10) || Chr(13)
        END IF;

        IF l_Req.FirstName IS NULL
        THEN
            l_Error := l_Error || ' First_Name;';
        END IF;

        /*  serhii 29/01/2025 CR: https://redmine.med/issues/88506#note-47
        if l_Req.DocType is null then
          l_Error := l_Error || ' Doc_Type;';
        end if;
        --  serhii 26/04/2024 CR: https://redmine.med/issues/88506#note-44
        if l_Req.DocSN is null then
          l_Error := l_Error || ' Doc_SN;';
        end if;
        */
        IF l_Req.PeriodStart IS NULL
        THEN
            l_Error := l_Error || ' Period_Start;';
        END IF;

        IF l_Req.PeriodEnd IS NULL
        THEN
            l_Error := l_Error || ' Period_End;';
        END IF;

        IF l_Error IS NOT NULL
        THEN                                   -- 102 – некоректні дані запиту
            Raise_Application_Error (
                -20000,
                'У запиті не заповнені всі обов''язкові поля');                                     -- || l_Error
        END IF;

        IF l_Req.PeriodStart > l_Req.PeriodEnd
        THEN
            Raise_Application_Error (
                -20000,
                'Некоректні значення параметрів Дата початку/Дата закінчення періоду отримання даних про суми допомоги');
        END IF;


        /*  Шукаєм особу по атрибутам запиту в реєстрі СРКО:
              Не знайшли - 2-Особу не знайдено;
              Знайшли більше однієї - 3 – Неможливо однозначно ідентифікувати особу;
              Знайшли - Далі шукаєм актуальну Довідку ВПО цієї особи (якщо не знайшли актуальної - останню за датою видачі):
                Не знайшли - 2-Особу не знайдено;
                Знайшли - заповнюємо всі поля в розділі Person - з даних СРКО, в розділі Сertificate - з даних Довідки ВПО.
                Якщо немає даних для обов'язкових полів - 9 – Інша помилка
                Все заповнили - 1-Особу знайдено;
        */
        BEGIN
            -- пошук особи + місця нар.
            Api$socialcard.Search_Sc_By_Params (
                p_Inn          => l_Req.IPN,
                p_Ndt_Id       => l_Req.DocType, -- (6, 7, 8, 9, 11, 13, 37, 673, 10095, 10192)) --NDI_DOCUMENT_TYPE
                p_Doc_Num      => l_Req.DocSN,
                p_Fn           => Clear_Name (l_Req.FirstName),
                p_Ln           => Clear_Name (l_Req.LastName),
                p_Mn           => Clear_Name (l_Req.SecondName),
                p_Esr_Num      => NULL,
                p_Gender       => NULL,
                p_Found_Cnt    => l_Found_Cnt,
                p_Show_Modal   => l_Show_Modal,
                p_Persons      => l_Persons);

            IF l_Found_Cnt = 0
            THEN                                       -- 2-Особу не знайдено;
                RETURN Get_Result_XML (2);
            ELSIF l_Found_Cnt > 1
            THEN             -- 3 – Неможливо однозначно ідентифікувати особу;
                RETURN Get_Result_XML (3);
            ELSIF l_Found_Cnt = 1
            THEN                                          -- 1-Особу знайдено;
                BEGIN
                    FETCH l_Persons INTO l_Row;

                    CLOSE l_Persons;

                    l_Sc_Id := l_Row.app_sc;

                    -- if l_Row.doc_eos is null then return Get_Result_XML(9);
                    -- end if; -- 23/05/2024 serhii: №ЕОС потрібен для розрахунку сум. У #103063 зробили необов'язковими
                    IF l_Row.app_ln IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    ELSE
                        l_Resp.Person.Last_Name := l_Row.app_ln;
                    END IF;

                    IF l_Row.app_fn IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    ELSE
                        l_Resp.Person.First_Name := l_Row.app_fn;
                    END IF;

                    l_Resp.Person.Second_Name := l_Row.app_mn;

                    IF l_Row.birth_dt IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    ELSE
                        l_Resp.Person.D_Birth := l_Row.birth_dt;
                    END IF;

                    IF l_Row.app_gender IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    ELSE
                        l_Resp.Person.ST :=
                            CASE UPPER (l_Row.app_gender)
                                WHEN 'F' THEN 2
                                WHEN 'M' THEN 1
                                ELSE 0
                            END;
                    END IF;

                    IF l_Row.app_ndt IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    ELSE
                        l_Resp.Person.Doc_Type := l_Row.app_ndt;
                    END IF;

                    IF l_Row.app_doc_num IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    ELSE
                        l_Resp.Person.Doc_SN := l_Row.app_doc_num;
                    END IF;

                    l_Resp.Person.IPN := l_Row.app_inn;
                    --get_address
                    l_Resp.Person.L_Birth :=
                        API$SC_TOOLS.get_address (p_sc_id    => l_Sc_Id,
                                                  p_sca_tp   => 1);

                    -- Отримання даних довідки
                    l_Resp.Person.Сertificate := Get_Vpo_Data (l_Sc_Id);

                    IF l_Resp.Person.Сertificate.Sert_No IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    END IF;

                    IF l_Resp.Person.Сertificate.Sert_Date IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    END IF;

                    IF l_Resp.Person.Сertificate.Sert_Iss IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    END IF;

                    IF l_Resp.Person.Сertificate.Sert_St IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    END IF;

                    l_Resp.Person.Сertificate.Kat_Ottg :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Kaot,
                            l_Resp.Person.Сertificate.Scd_Dh);

                    IF l_Resp.Person.Сertificate.Kat_Ottg IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    END IF;

                    l_Resp.Person.Сertificate.Sert_Id :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Guid,
                            l_Resp.Person.Сertificate.Scd_Dh);

                    IF l_Resp.Person.Сertificate.Sert_Id IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    END IF;

                    l_Resp.Person.Сertificate.Adr_Res :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Addr_Fact,
                            l_Resp.Person.Сertificate.Scd_Dh);

                    IF l_Resp.Person.Сertificate.Adr_Res IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    END IF;

                    l_Resp.Person.Сertificate.Adr_Reg :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Addr_Reg,
                            l_Resp.Person.Сertificate.Scd_Dh);

                    IF l_Resp.Person.Сertificate.Adr_Reg IS NULL
                    THEN
                        RETURN Get_Result_XML (9);
                    END IF;

                    l_Resp.Person.Сertificate.Adr_Change_Mark :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Addr_Change,
                            l_Resp.Person.Сertificate.Scd_Dh);

                    -- визначення сум
                    l_pc_id := Get_Pc_Id (l_Sc_Id);

                    IF l_pc_id IS NULL
                    THEN
                        -- 23/05/2024 serhii: #103063-6 Якщо не було нарахувань та виплат, передавати в полях SumAccr, SumPay 0 (нуль)
                        l_Resp.Person.Сertificate.SUM_Accr := 0;
                        l_Resp.Person.Сertificate.SUM_Pay := 0;
                    ELSE
                        --нарахування
                        l_Resp.Person.Сertificate.SUM_Accr :=
                            get_accrual_sum (p_pc_id     => l_pc_id,
                                             p_from_dt   => l_Req.PeriodStart,
                                             p_to_dt     => l_Req.PeriodEnd,
                                             p_npt       => c_Npt_VPO);
                        -- виплати
                        l_Resp.Person.Сertificate.SUM_Pay :=
                            get_payroll_sum (p_pc_id     => l_pc_id,
                                             p_from_dt   => l_Req.PeriodStart,
                                             p_to_dt     => l_Req.PeriodEnd,
                                             p_npt       => c_Npt_VPO);
                    END IF;

                    -- збірка хмл
                    l_Resp.Reslt := 1;

                    SELECT XMLELEMENT (
                               "GetSertVPOandSumResponse",
                               XMLELEMENT ("Result", l_Resp.Reslt),
                               XMLELEMENT (
                                   "Person",
                                   XMLELEMENT ("Last_Name",
                                               l_Resp.Person.Last_Name),
                                   XMLELEMENT ("First_Name",
                                               l_Resp.Person.First_Name),
                                   XMLELEMENT ("Second_Name",
                                               l_Resp.Person.Second_Name),
                                   XMLELEMENT ("D_Birth",
                                               l_Resp.Person.D_Birth),
                                   XMLELEMENT ("L_Birth",
                                               l_Resp.Person.L_Birth),
                                   XMLELEMENT ("ST", l_Resp.Person.ST),
                                   XMLELEMENT ("Doc_Type",
                                               l_Resp.Person.Doc_Type),
                                   XMLELEMENT ("IPN", l_Resp.Person.IPN),
                                   XMLELEMENT ("Doc_SN",
                                               l_Resp.Person.Doc_SN),
                                   XMLELEMENT (
                                       "Сertificate",
                                       XMLELEMENT (
                                           "Sert_No",
                                           l_Resp.Person.Сertificate.Sert_No),
                                       XMLELEMENT (
                                           "Sert_Date",
                                           l_Resp.Person.Сertificate.Sert_Date),
                                       XMLELEMENT (
                                           "Sert_Iss",
                                           l_Resp.Person.Сertificate.Sert_Iss),
                                       XMLELEMENT (
                                           "Rem_Date",
                                           l_Resp.Person.Сertificate.Rem_Date),
                                       XMLELEMENT (
                                           "Sert_St",
                                           l_Resp.Person.Сertificate.Sert_St),
                                       XMLELEMENT (
                                           "Kat_Ottg",
                                           l_Resp.Person.Сertificate.Kat_Ottg),
                                       XMLELEMENT (
                                           "Sert_Id",
                                           l_Resp.Person.Сertificate.Sert_Id),
                                       XMLELEMENT (
                                           "Adr_Res",
                                           l_Resp.Person.Сertificate.Adr_Res),
                                       XMLELEMENT (
                                           "Adr_Reg",
                                           l_Resp.Person.Сertificate.Adr_Reg),
                                       XMLELEMENT (
                                           "Adr_Change_Mark",
                                           l_Resp.Person.Сertificate.Adr_Change_Mark),
                                       XMLELEMENT (
                                           "SUM_Accr",
                                           l_Resp.Person.Сertificate.SUM_Accr),
                                       XMLELEMENT (
                                           "SUM_Pay",
                                           l_Resp.Person.Сertificate.SUM_Pay))))
                      INTO l_Resp_Xml
                      FROM DUAL;

                    RETURN l_Resp_Xml.getClobVal;
                END;
            ELSE                                          -- 9 – Інша помилка.
                RETURN Get_Result_XML (9);
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка обробки запиту' || CHR (10) || SQLERRM);
        END;
    END;

    -------------------------------------------------------------------------------
    --   Обробка запиту від НФЗК на отримання даних довідок ВПО, нарахованих та
    --   виплачених сум допомоги на проживання ВПО 101511
    -------------------------------------------------------------------------------
    FUNCTION Handle_Get_VPO_Sert_only_Req (p_Request_Id     IN NUMBER,
                                           p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Req          t_Nazk_VPO_Req;
        l_Sc_Id        Socialcard.Sc_Id%TYPE;
        l_pc_id        uss_esr.v_personalcase.pc_id%TYPE;
        l_Error        VARCHAR2 (2000);
        l_Resp_Xml     XMLTYPE;
        l_Pers_Resp    r_Nazk_VPO_Resp;
        l_Resp         t_Nazk_VPO_Resp := t_Nazk_VPO_Resp ();
        l_Found_Cnt    PLS_INTEGER;
        l_Show_Modal   PLS_INTEGER;
        l_Row          Api$socialcard.r_Search_Sc;
        l_Ndt_Id       NUMBER;
        l_Persons      SYS_REFCURSOR;
    BEGIN
        BEGIN
            -- парсим запит
            l_Req := Parse_Nazk_VPO_Req (p_Request_Body);
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту' || CHR (10) || SQLERRM);
        END;

        FOR crReq IN (SELECT * FROM TABLE (l_Req))
        LOOP
            l_Pers_Resp := r_Nazk_VPO_Resp ();
            l_Pers_Resp.AnswerCode := 0;

            --Перекодування типу документа
            l_Ndt_Id :=
                Uss_Ndi.Tools.Decode_Dict (p_Nddc_Tp         => 'NDT_ID',
                                           p_Nddc_Src        => 'VPO',
                                           p_Nddc_Dest       => 'USS',
                                           p_Nddc_Code_Src   => crReq.DocTp);


            Api$socialcard.Search_Sc_By_Params (
                p_Inn          => crReq.IPN,
                p_Ndt_Id       => l_Ndt_Id, -- (6, 7, 8, 9, 11, 13, 37, 673, 10095, 10192)) --NDI_DOCUMENT_TYPE
                p_Doc_Num      => crReq.DocSN,
                p_Fn           => Clear_Name (crReq.Fn),
                p_Ln           => Clear_Name (crReq.LN),
                p_Mn           => Clear_Name (crReq.Mn),
                p_Esr_Num      => NULL,
                p_Gender       => NULL,
                p_Found_Cnt    => l_Found_Cnt,
                p_Show_Modal   => l_Show_Modal,
                p_Persons      => l_Persons);

            IF l_Found_Cnt = 0
            THEN                                       -- 2-Особу не знайдено;
                l_Pers_Resp.AnswerCode := 1;
                l_Pers_Resp.AnswerMessage := 'особу не знайдено';
            ELSIF l_Found_Cnt > 1
            THEN             -- 3 – Неможливо однозначно ідентифікувати особу;
                l_Pers_Resp.AnswerCode := 2;
                l_Pers_Resp.AnswerMessage :=
                    'неможливо однозначно ідентифікувати особу';
            ELSIF l_Found_Cnt = 1
            THEN                                          -- 1-Особу знайдено;
                FETCH l_Persons INTO l_Row;

                CLOSE l_Persons;

                l_Sc_Id := l_Row.app_sc;

                --VPO Data
                BEGIN
                    SELECT t.scd_number,
                           t.scd_issued_dt,
                           t.scd_issued_who,
                           CASE WHEN t.scd_st = 1 THEN 50 ELSE 90 END,
                           CASE
                               WHEN t.scd_st = 1 THEN 'діюча'
                               ELSE 'знята з обліку'
                           END,
                           t.scd_stop_dt,
                           t.scd_dh
                      INTO l_Pers_Resp.CertNum,
                           l_Pers_Resp.CertDt,
                           l_Pers_Resp.CertIssuer,
                           l_Pers_Resp.CertSt,
                           l_Pers_Resp.CertStName,
                           l_Pers_Resp.DateEnd,
                           l_Pers_Resp.scd_dh
                      FROM (SELECT ROW_NUMBER ()
                                       OVER (
                                           PARTITION BY d.scd_sc, d.scd_ndt
                                           ORDER BY
                                               CASE d.scd_st
                                                   WHEN '1' THEN 0
                                                   ELSE 1
                                               END ASC,
                                               d.scd_issued_dt DESC)    rn,
                                   d.*
                              FROM v_sc_document d
                             WHERE     d.scd_ndt = Load$vpo.c_Ndt_Vpo
                                   AND d.scd_sc = l_Sc_Id) t
                     WHERE t.rn = 1;


                    l_Pers_Resp.PersNum := crReq.PersNum;
                    l_Pers_Resp.LN := l_Row.app_ln;
                    l_Pers_Resp.FN := l_Row.app_fn;
                    l_Pers_Resp.MN := l_Row.app_mn;
                    l_Pers_Resp.BirthDt := l_Row.birth_dt;
                    l_Pers_Resp.Gender :=
                        CASE UPPER (l_Row.app_gender)
                            WHEN 'M' THEN 1
                            WHEN 'F' THEN 0
                            ELSE l_Row.app_gender
                        END;

                    l_Pers_Resp.DocTp :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Id (
                            Load$vpo.c_Nda_Vpo_Owner_Ndt,
                            l_Pers_Resp.Scd_Dh);

                    SELECT t.scd_seria,
                           t.scd_number,
                           t.scd_issued_dt,
                           t.scd_issued_who
                      INTO l_Pers_Resp.DocSer,
                           l_Pers_Resp.DocNum,
                           l_Pers_Resp.DocDt,
                           l_Pers_Resp.DocIssuer
                      FROM (SELECT ROW_NUMBER ()
                                       OVER (
                                           PARTITION BY d.scd_sc, d.scd_ndt
                                           ORDER BY
                                               CASE d.scd_st
                                                   WHEN '1' THEN 0
                                                   ELSE 1
                                               END ASC,
                                               d.scd_issued_dt DESC)    rn,
                                   d.*
                              FROM v_sc_document d
                             WHERE     d.scd_ndt = l_Pers_Resp.DocTp
                                   AND d.scd_sc = l_Sc_Id) t
                     WHERE t.rn = 1;

                    l_Pers_Resp.IPN := LPAD (l_Row.app_inn, 10, '0');



                    l_Pers_Resp.GUID :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Guid,
                            l_Pers_Resp.Scd_Dh);
                    l_Pers_Resp.KATOTTG :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Kaot,
                            l_Pers_Resp.Scd_Dh);
                    l_Pers_Resp.FactAddressTxt :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Addr_Fact,
                            l_Pers_Resp.Scd_Dh);
                    l_Pers_Resp.RegAddressTxt :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Addr_Reg,
                            l_Pers_Resp.Scd_Dh);

                    l_Pers_Resp.CertCancelRsnId :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Id (
                            Load$vpo.c_Nda_Vpo_CanclRsn,
                            l_Pers_Resp.Scd_Dh);

                    l_Pers_Resp.FactAddressKATOTTG :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_Atu,
                            l_Pers_Resp.Scd_Dh);
                    l_Pers_Resp.FactAddressStreetId :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_StreetId,
                            l_Pers_Resp.Scd_Dh);
                    l_Pers_Resp.FactAddressStreetName :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_StreetName,
                            l_Pers_Resp.Scd_Dh);
                    l_Pers_Resp.FactAddressHouse :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_HouseNum,
                            l_Pers_Resp.Scd_Dh);
                    l_Pers_Resp.FactAddressBuilding :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_BuildNum,
                            l_Pers_Resp.Scd_Dh);
                    l_Pers_Resp.FactAddressFlat :=
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            Load$vpo.c_Nda_Vpo_FlatNum,
                            l_Pers_Resp.Scd_Dh);
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        l_Pers_Resp.AnswerCode := 9;
                        l_Pers_Resp.AnswerMessage :=
                            'дані довідки ВПО не знайдено';
                END;

                l_Resp.EXTEND (1);
                l_Resp (l_Resp.COUNT) := l_Pers_Resp;
            END IF;
        END LOOP;

        SELECT XMLELEMENT (
                   "GetCertVPOResponse",
                   XMLELEMENT (
                       "Certificates",
                       XMLAGG (
                           XMLELEMENT (
                               "Certificate",
                               XMLELEMENT ("PersNum", PersNum),
                               XMLELEMENT ("AnswerCode", AnswerCode),
                               XMLELEMENT ("AnswerMessage", AnswerMessage),
                               XMLELEMENT ("Ln", LN),
                               XMLELEMENT ("Fn", Fn),
                               XMLELEMENT ("Mn", Mn),
                               XMLELEMENT ("BirthDt",
                                           TO_CHAR (BirthDt, 'DD.MM.YYYY')),
                               XMLELEMENT ("IPN", IPN),
                               XMLELEMENT ("Gender", Gender),
                               XMLELEMENT ("DocTp", DocTp),
                               XMLELEMENT ("DocSer", DocSer),
                               XMLELEMENT ("DocNum", DocNum),
                               XMLELEMENT ("DocDt",
                                           TO_CHAR (DocDt, 'DD.MM.YYYY')),
                               XMLELEMENT ("DocIssuer", DocIssuer),
                               XMLELEMENT ("RegAddressTxt", RegAddressTxt),
                               XMLELEMENT ("FactAddressTxt", FactAddressTxt),
                               XMLELEMENT ("GUID ", GUID),
                               XMLELEMENT ("CertNum", CertNum),
                               XMLELEMENT ("CertDt",
                                           TO_CHAR (CertDt, 'DD.MM.YYYY')),
                               XMLELEMENT ("CertIssuer", CertIssuer),
                               XMLELEMENT ("CertSt", CertSt),
                               XMLELEMENT ("CertStName", CertStName),
                               XMLELEMENT ("DateEnd", DateEnd),
                               XMLELEMENT ("CertCancelRsnId",
                                           CertCancelRsnId),
                               XMLELEMENT ("KATOTTG", KATOTTG),
                               XMLELEMENT (
                                   "FactAddress",
                                   XMLELEMENT ("KATOTTG", FactAddressKATOTTG),
                                   XMLELEMENT ("StreetId",
                                               FactAddressStreetId),
                                   XMLELEMENT ("StreetName",
                                               FactAddressStreetName),
                                   XMLELEMENT ("House", FactAddressHouse),
                                   XMLELEMENT ("Building",
                                               FactAddressBuilding),
                                   XMLELEMENT ("Flat", FactAddressFlat))))))
          INTO l_Resp_Xml
          FROM TABLE (l_Resp);

        RETURN l_Resp_Xml.getClobVal;
    END;
BEGIN
    NULL;
END Ws$VPO_Requests;
/