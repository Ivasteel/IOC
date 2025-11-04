/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.UNLOAD$VPO
IS
    -- Author  : SHOSTAK
    -- Created : 26.12.2023 5:08:12 PM
    -- Purpose :

    c_Pt_Start_Dt   CONSTANT NUMBER := 80;

    FUNCTION Handle_Delta_Request (p_Request_Id     IN NUMBER,
                                   p_Request_Body   IN CLOB)
        RETURN CLOB;

    FUNCTION Clear_Csv (p_Text IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Process_Delta_Request (p_Ur_Id IN NUMBER, p_Request IN CLOB --Ignore
                                                                         );

    /*
    info:    Обробка запиту на дельту змін по ВПО
    author:  sho
    request: #106583
    */
    FUNCTION Handle_Delta_Ext_Request (p_Request_Id     IN NUMBER,
                                       p_Request_Body   IN CLOB)
        RETURN CLOB;

    /*
    info:    Формування відповідей на запити дельти ВПО(для інших організацій)
    author:  sho
    request: #106637
    note:
    */
    PROCEDURE Process_Delta_Ext_Request (p_Ur_Id     IN NUMBER,
                                         p_Request   IN CLOB          --Ignore
                                                            );

    /*
    info:    Отримання інформації про внутрішньо переміщену особу
    author:  sho
    request: #106583
    */
    FUNCTION Handle_Displaced_Person_Request (p_Request_Id     IN NUMBER,
                                              p_Request_Body   IN CLOB)
        RETURN CLOB;

    FUNCTION Build_Street_Tp (p_Street_Id     IN VARCHAR2,
                              p_Street_Type   IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Build_Street_Name (p_Street_Id     IN VARCHAR2,
                                p_Street_Name   IN VARCHAR2,
                                p_Street_Type   IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2;

    /*
    info:    Отримання адреси зареєстрованого місця проживання
    author:  kelatev
    request: #111333
    */
    FUNCTION Get_Domicile_Xml (p_Sc_Id IN NUMBER)
        RETURN XMLTYPE;

    FUNCTION Get_Domicile_Json (p_Sc_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Cert_Status_Xml (p_Scd_St IN VARCHAR2, p_Scd_Dh IN NUMBER)
        RETURN XMLTYPE;

    FUNCTION Get_Cert_Status_Json (p_Scd_St IN VARCHAR2, p_Scd_Dh IN NUMBER)
        RETURN VARCHAR2;
END Unload$vpo;
/


GRANT EXECUTE ON USS_PERSON.UNLOAD$VPO TO II01RC_USS_PERSON_SVC
/

GRANT EXECUTE ON USS_PERSON.UNLOAD$VPO TO IKIS_RBM
/

GRANT EXECUTE ON USS_PERSON.UNLOAD$VPO TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:57:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.UNLOAD$VPO
IS
    -----------------------------------------------------------------------------
    --   Обробка запиту на дельту ВПО
    -----------------------------------------------------------------------------
    FUNCTION Handle_Delta_Request (p_Request_Id     IN NUMBER,
                                   p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Start_Dt   DATE;
        l_Response   XMLTYPE;
    BEGIN
        BEGIN
                 SELECT TO_DATE (Start_Dt, 'dd.mm.yyyy hh24:mi:ss')
                   INTO l_Start_Dt
                   FROM XMLTABLE (
                            '/*'
                            PASSING Xmltype (p_Request_Body)
                            COLUMNS Start_Dt    VARCHAR2 (20) PATH '/StartDt');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        Ikis_Rbm.Api$request.Save_Rn_Common_Info (
            p_Rnc_Rn       => Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Request_Id),
            p_Rnc_Pt       => c_Pt_Start_Dt,
            p_Rnc_Val_Dt   => l_Start_Dt);

        Ikis_Rbm.Api$uxp_Files.Create_File (p_Ur_Id => p_Request_Id);
        Ikis_Rbm.Api$background.Register_Background (
            p_Ur_Id         => p_Request_Id,
            p_Ubq_Content   => NULL);

        SELECT XMLELEMENT ("UrId", p_Request_Id) INTO l_Response FROM DUAL;

        RETURN l_Response.Getclobval;
    END;

    FUNCTION Clear_Csv (p_Text IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN REPLACE (REPLACE (REPLACE (p_Text, ';'), CHR (10)), CHR (13));
    END;

    -----------------------------------------------------------------------------
    --   Отримання курсору з довідками ВПО
    -----------------------------------------------------------------------------
    FUNCTION Get_Vpo_Certs (p_Start_Dt IN DATE)
        RETURN SYS_REFCURSOR
    IS
        l_Result   SYS_REFCURSOR;
    BEGIN
        OPEN l_Result FOR
            WITH
                Docs
                AS
                    (  SELECT MAX (e.Scde_Dt)     AS Modify_Dt,
                              d.Scd_Id,
                              d.Scd_Issued_Dt,
                              d.Scd_Issued_Who,
                              d.Scd_Dh,
                              d.Scd_Sc,
                              d.Scd_St
                         FROM Scd_Event e
                              JOIN Sc_Document d
                                  ON     e.Scde_Scd = d.Scd_Id
                                     AND d.Scd_Ndt = 10052
                        WHERE     e.Scde_Dt >= p_Start_Dt
                              AND e.Scde_Event IN ('CR', 'CL', 'UP')
                     GROUP BY d.Scd_Id,
                              d.Scd_Issued_Dt,
                              d.Scd_Issued_Who,
                              d.Scd_Dh,
                              d.Scd_Sc,
                              d.Scd_St),
                Docs_Data
                AS
                    (SELECT Modify_Dt,
                            Scd_Id,
                            Scd_Issued_Dt,
                            Scd_Issued_Who,
                            Scd_Dh,
                            Scd_Sc,
                            Scd_St,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 2440,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Guid,
                            --(SELECT MAX(a.Da_Val_String)
                            --   FROM Uss_Doc.Doc_Attr2hist h
                            --  JOIN Uss_Doc.Doc_Attributes a
                            --    ON h.Da2h_Da = a.Da_Id
                            --   AND a.Da_Nda = 2440
                            -- WHERE h.Da2h_Dh = d.Scd_Dh) AS x_Guid,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 1756,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Number,
                            --(SELECT MAX(a.Da_Val_String)
                            --    FROM Uss_Doc.Doc_Attr2hist h
                            --   JOIN Uss_Doc.Doc_Attributes a
                            --      ON h.Da2h_Da = a.Da_Id
                            --    AND a.Da_Nda = 1756
                            --   WHERE h.Da2h_Dh = d.Scd_Dh) AS x_Number,
                            Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                p_Nda_Id   => 1757,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Issued_Dt,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 1759,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Issuer,
                            Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                p_Nda_Id   => 1760,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Date_End,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 4480,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Cancel_Reason,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 2458,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Addr_Reg,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 2457,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Addr_Fact,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 2833,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Addr_Change,
                            Uss_Doc.Api$documents.Get_Attr_Val_Id (
                                p_Nda_Id   => 2292,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Reg_Kaot_Id,
                            Uss_Doc.Api$documents.Get_Attr_Val_Id (
                                p_Nda_Id   => 4492,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Faсt_Kaot_Id,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 5551,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Faсt_Street_Id,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 4485,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Faсt_Street_Name,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 4487,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Faсt_House_Num,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 4488,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Faсt_Build_Num,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 4489,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Faсt_Flat
                       FROM Docs d)
            SELECT    --дата модифікації
                      TO_CHAR (d.Modify_Dt, 'dd.mm.yyyy hh24:mi:ss')
                   || ';'
                   || --Прізвище
                      REPLACE (i.Sci_Ln, ';')
                   || ';'
                   || --Ім'я
                      REPLACE (i.Sci_Fn, ';')
                   || ';'
                   || --По батькові
                      REPLACE (i.Sci_Mn, ';')
                   || ';'
                   || --ДН
                      TO_CHAR (b.Scb_Dt, 'dd.mm.yyyy')
                   || ';'
                   || --Місце народження
                      NULL
                   || ';'
                   || --РНОКПП
                       (SELECT MAX (Dd.Scd_Number)
                          FROM Sc_Document Dd
                         WHERE     Dd.Scd_Sc = d.Scd_Sc
                               AND Dd.Scd_Ndt = 5
                               AND Dd.Scd_St = '1')
                   || ';'
                   || --Стать
                      i.Sci_Gender
                   || ';'
                   || --Документ що посвыдчуэ особу
                       (SELECT              --Тип документу що посвідчує особу
                                  MAX (Pp.Scd_Ndt)
                               || ';'
                               || --Серія документу
                                  MAX (Pp.Scd_Seria)
                               || ';'
                               || --Номер документу
                                  MAX (Pp.Scd_Number)
                               || ';'
                               || --Дата видачі документу
                                  MAX (Pp.Scd_Issued_Dt)
                               || ';'
                               || --Орган який видав документ
                                  REPLACE (MAX (Pp.Scd_Issued_Who), ';')
                          FROM (  SELECT p.Scd_Ndt,
                                         p.Scd_Seria,
                                         p.Scd_Number,
                                         p.Scd_Issued_Dt,
                                         p.Scd_Issued_Who
                                    FROM Sc_Document p
                                         JOIN Uss_Ndi.v_Ndi_Document_Type t
                                             ON p.Scd_Ndt = t.Ndt_Id
                                         JOIN Uss_Ndi.v_Ndi_Document_Class c
                                             ON     t.Ndt_Ndc = c.Ndc_Id
                                                AND c.Ndc_Id = 13
                                   WHERE p.Scd_Sc = d.Scd_Sc AND p.Scd_St = '1'
                                ORDER BY p.Scd_Id DESC
                                   FETCH FIRST ROW ONLY) Pp)
                   || ';'
                   || --Адреса зареєстрованого місця проживання
                      REPLACE (REPLACE (REPLACE (x_Addr_Reg, ';'), CHR (10)),
                               CHR (13))             /*Clear_Csv(x_Addr_Reg)*/
                   || ';'
                   || --Адреса фактичного місця
                      REPLACE (
                          REPLACE (REPLACE (x_Addr_Fact, ';'), CHR (10)),
                          CHR (13))                 /*Clear_Csv(x_Addr_Fact)*/
                   || ';'
                   || --GUID
                      REPLACE (x_Guid, ';')
                   || ';'
                   || --ParentGUID
                      NULL
                   || ';'
                   || --CertificateNumber
                      REPLACE (x_Number, ';')
                   || ';'
                   || --CertificateDate
                      TO_CHAR (x_Issued_Dt, 'dd.mm.yyyy')
                   || ';'
                   || --CertificateIssuer
                      REPLACE (x_Issuer, ';')
                   || ';'
                   || --CertificateState
                      --Uss_Doc.Api$documents.Get_Attr_Val_Str(p_Nda_Id => 1855, p_Dh_Id => d.Scd_Dh)
                      DECODE (d.Scd_St, '1', 'A', 'H')
                   || ';'
                   || --CertificateStateName
                      --Decode(Uss_Doc.Api$documents.Get_Attr_Val_Str(p_Nda_Id => 1855, p_Dh_Id => d.Scd_Dh), 'A', 'Діюча', 'Не діюча')
                      DECODE (d.Scd_St, '1', 'Діюча', 'Не діюча')
                   || ';'
                   || --DateEnd
                      TO_CHAR (x_Date_End, 'dd.mm.yyyy')
                   || ';'
                   || --CertificateCancelReasonId
                      x_Cancel_Reason
                   || ';'
                   || --CatoTtg
                       (SELECT k.Kaot_Code
                          FROM Uss_Ndi.v_Ndi_Katottg k
                         WHERE k.Kaot_Id = x_Reg_Kaot_Id)
                   || ';'
                   || --AddressChange
                      x_Addr_Change
                   || ';'
                   || --FactAddressAtu
                       (SELECT k.Kaot_Code
                          FROM Uss_Ndi.v_Ndi_Katottg k
                         WHERE k.Kaot_Id = x_Faсt_Kaot_Id)
                   || ';'
                   || --FactAddressStreetId
                      x_Faсt_Street_Id
                   || ';'
                   || --FactAddressStreetName
                      REPLACE (
                          REPLACE (REPLACE (x_Faсt_Street_Name, ';'),
                                   CHR (10)),
                          CHR (13))           /*Clear_Csv(x_Faсt_Street_Name)*/
                   || ';'
                   || --FactAddressHouseNum
                      REPLACE (
                          REPLACE (REPLACE (x_Faсt_House_Num, ';'),
                                   CHR (10)),
                          CHR (13))             /*Clear_Csv(x_Faсt_House_Num)*/
                   || ';'
                   || --FactAddressBuildNum
                      REPLACE (
                          REPLACE (REPLACE (x_Faсt_Build_Num, ';'),
                                   CHR (10)),
                          CHR (13))             /*Clear_Csv(x_Faсt_Build_Num)*/
                   || ';'
                   || --FactAddressFlatNum
                      REPLACE (
                          REPLACE (REPLACE (x_Faсt_Flat, ';'), CHR (10)),
                          CHR (13))                  /*Clear_Csv(x_Faсt_Flat)*/
                   || ';'
              FROM Docs_Data  d
                   JOIN Socialcard c
                       ON d.Scd_Sc = c.Sc_Id AND c.Sc_St IN ('1', '4')
                   JOIN Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
                   JOIN Sc_Identity i ON Cc.Scc_Sci = i.Sci_Id
                   LEFT JOIN Sc_Birth b
                       ON Cc.Scc_Scb = b.Scb_Id AND Cc.Scc_Scb <> -1
                   LEFT JOIN Sc_Address Ba ON b.Scb_Sca = Ba.Sca_Id;

        RETURN l_Result;
    END;

    -----------------------------------------------------------------------------
    --  Формування відповіді на запит дельти ВПО
    -----------------------------------------------------------------------------
    PROCEDURE Build_Delta_Response (p_Ur_Id IN NUMBER)
    IS
        l_Uf_Id        NUMBER;
        l_Start_Dt     DATE;
        l_Vpo_Certs    SYS_REFCURSOR;
        c_Csv_Header   VARCHAR2 (4000)
            := 'ModifyDt;IdpSurname;IdpName;IdpPatronymic;BirthDate;BirthPlace;RNOKPP;Gender;DocumentType;DocumentSerie;DocumentNumber;DocumentDate;DocumentIssuer;RegAddress;FactAddress;GUID;ParentGUID;CertificateNumber;CertificateDate;CertificateIssuer;CertificateState;CertificateStateName;DateEnd;CertificateCancelReasonId;CatoTtg;AddressChange;FactAddressAtu;FactAddressStreetId;FactAddressStreetName;FactAddressHouseNum;FactAddressBuildNum;FactAddressFlatNum;';
    BEGIN
        --Отримуємо дату з якої починається формування дельти
        l_Start_Dt :=
            Ikis_Rbm.Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id),
                p_Rnc_Pt   => c_Pt_Start_Dt);

        --Отримуємо довідки ВПО
        l_Vpo_Certs := Get_Vpo_Certs (l_Start_Dt);

        --Отримуємо ідентифікатор файлу
        l_Uf_Id := Ikis_Rbm.Api$uxp_Files.Get_Ur_Uf (p_Ur_Id);

        --Формуємо файл
        Ikis_Rbm.Api$uxp_Files.Build_And_Zip_Csv (
            p_Uf_Id        => l_Uf_Id,
            p_Csv_Header   => c_Csv_Header,
            p_Csv_Data     => l_Vpo_Certs);
    END;

    -----------------------------------------------------------------------------
    --  Формування відповідей на запити дельти ВПО(для ПФУ)
    -----------------------------------------------------------------------------
    PROCEDURE Process_Delta_Request (p_Ur_Id IN NUMBER, p_Request IN CLOB --Ignore
                                                                         )
    IS
    BEGIN
        Build_Delta_Response (p_Ur_Id => p_Ur_Id);
    END;

    /*
    info:    Обробка запиту на дельту змін по ВПО
    author:  sho
    request: #106583
    */
    FUNCTION Handle_Delta_Ext_Request (p_Request_Id     IN NUMBER,
                                       p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Start_Dt      DATE;
        l_Min_Dt        DATE := TO_DATE ('16.02.2024', 'dd.mm.yyyy'); --Останне успішне завантаження довідок, раніше - можливий мусор
        l_Response      XMLTYPE;
        l_Answer_Code   NUMBER;
        l_Answer_Text   VARCHAR2 (32000);
    BEGIN
        BEGIN
                 SELECT TO_DATE (Start_Dt, 'yyyy-mm-dd"T"hh24:mi:ss')
                   INTO l_Start_Dt
                   FROM XMLTABLE (
                            '/*'
                            PASSING Xmltype (p_Request_Body)
                            COLUMNS Start_Dt    VARCHAR2 (20) PATH 'StartDt');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        IF l_Start_Dt IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Незаповнено поле "Дата початку зміни даних"';
            GOTO Resp;
        END IF;

        l_Start_Dt := NVL (l_Start_Dt, l_Min_Dt);

        IF l_Start_Dt < l_Min_Dt
        THEN
            l_Start_Dt := l_Min_Dt;
        END IF;

        Ikis_Rbm.Api$request.Save_Rn_Common_Info (
            p_Rnc_Rn       => Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Request_Id),
            p_Rnc_Pt       => c_Pt_Start_Dt,
            p_Rnc_Val_Dt   => l_Start_Dt);

        Ikis_Rbm.Api$background.Register_Background (
            p_Ur_Id         => p_Request_Id,
            p_Ubq_Content   => NULL);

        l_Answer_Code := 1;
        l_Answer_Text := 'Запит збережено';

       <<resp>>
        SELECT XMLELEMENT (
                   "DeltaAskResponse",
                   XMLELEMENT ("UrId", p_Request_Id),
                   Ikis_Rbm.Api$uxp_Univ.Answer_Xml (
                       p_Code   => l_Answer_Code,
                       p_Text   => l_Answer_Text))
          INTO l_Response
          FROM DUAL;

        RETURN l_Response.Getclobval;
    END;

    /*
    info:    Формування відповідей на запити дельти ВПО(для інших організацій)
    author:  sho
    request: #106583
    note:
    */
    PROCEDURE Process_Delta_Ext_Request (p_Ur_Id     IN NUMBER,
                                         p_Request   IN CLOB          --Ignore
                                                            )
    IS
        l_Start_Dt                DATE;
        l_Array                   CLOB;
        c_File_Row_Cnt   CONSTANT NUMBER := 10000; --todo: можливо винести в параметри
    BEGIN
        --Отримуємо дату з якої починається формування дельти
        l_Start_Dt :=
            Ikis_Rbm.Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id),
                p_Rnc_Pt   => c_Pt_Start_Dt);

        FOR Rec
            IN (WITH
                    Src
                    AS
                        (  SELECT MAX (e.Scde_Dt)     AS Modify_Dt,
                                  d.Scd_Id,
                                  d.Scd_Sc,
                                  d.Scd_St,
                                  d.Scd_Dh
                             FROM Uss_Person.Sc_Document d
                                  JOIN Uss_Person.Scd_Event e
                                      ON     e.Scde_Scd = d.Scd_Id
                                         AND e.Scde_Dt >= l_Start_Dt
                                         AND e.Scde_Event IN ('CR', 'CL', 'UP')
                            WHERE d.Scd_Ndt = 10052 AND d.Scd_Sc IS NOT NULL
                         GROUP BY d.Scd_Id,
                                  d.Scd_Sc,
                                  d.Scd_St,
                                  d.Scd_Dh),
                    Src_Attr
                    AS
                        (SELECT Scd_Id,
                                Scd_Sc,
                                Scd_St,
                                Scd_Dh,
                                Modify_Dt,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 2440,
                                    p_Dh_Id    => d.Scd_Dh)
                                    AS x_Guid,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 1756,
                                    p_Dh_Id    => d.Scd_Dh)
                                    AS x_Number,
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 1757,
                                    p_Dh_Id    => d.Scd_Dh)
                                    AS x_Issued,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 1759,
                                    p_Dh_Id    => d.Scd_Dh)
                                    AS x_Issuer,
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 1760,
                                    p_Dh_Id    => d.Scd_Dh)
                                    AS x_Date_End,
                                Uss_Doc.Api$documents.Get_Attr_Val_Id (
                                    p_Nda_Id   => 4492,
                                    p_Dh_Id    => d.Scd_Dh)
                                    AS x_Kaot_Id,
                                Build_Street_Tp (
                                    p_Street_Id   =>
                                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                            p_Nda_Id   => 5551,
                                            p_Dh_Id    => d.Scd_Dh),
                                    p_Street_Type   =>
                                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                            p_Nda_Id   => 4484,
                                            p_Dh_Id    => d.Scd_Dh))
                                    AS x_Street_Tp,
                                Build_Street_Name (
                                    p_Street_Id   =>
                                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                            p_Nda_Id   => 5551,
                                            p_Dh_Id    => d.Scd_Dh),
                                    p_Street_Name   =>
                                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                            p_Nda_Id   => 4485,
                                            p_Dh_Id    => d.Scd_Dh))
                                    AS x_Street,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 4487,
                                    p_Dh_Id    => d.Scd_Dh)
                                    AS x_House_Num,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 4488,
                                    p_Dh_Id    => d.Scd_Dh)
                                    AS x_Build_Num,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 4489,
                                    p_Dh_Id    => d.Scd_Dh)
                                    AS x_Flat
                           FROM Src d),
                    Data
                    AS
                        (  SELECT MAX (Modify_Dt)        AS Modify_Dt,
                                  Scd_Sc,
                                  LISTAGG (Scd_Dh, ','),
                                  Json_Arrayagg (
                                      Json_Object (
                                          'TemporarilyDisplacedPerson' VALUE
                                              Json_Object (
                                                  'GUID' VALUE x_Guid,
                                                  'Number' VALUE x_Number,
                                                  'Issued' VALUE
                                                      TO_CHAR (x_Issued,
                                                               'yyyy-mm-dd'),
                                                  'Issuer' VALUE x_Issuer,
                                                  'Status' VALUE
                                                      Get_Cert_Status_Json (
                                                          p_Scd_St   => s.Scd_St,
                                                          p_Scd_Dh   => s.Scd_Dh)
                                                      FORMAT JSON,
                                                  'DateEnd' VALUE
                                                      TO_CHAR (x_Date_End,
                                                               'yyyy-mm-dd'),
                                                  'ActualDomicile' VALUE
                                                      Json_Object (
                                                          'AddressId' VALUE
                                                              NULL,
                                                          'FullAddress' VALUE
                                                              (SELECT k.Kaot_Code
                                                                 FROM Uss_Ndi.v_Ndi_Katottg
                                                                      k
                                                                WHERE k.Kaot_Id =
                                                                      x_Kaot_Id),
                                                          'AdminUnitL1' VALUE
                                                              'UA',
                                                          'AdminUnitL2' VALUE
                                                              (SELECT MAX (
                                                                          k.L1_Kaot_Full_Name)
                                                                 FROM Uss_Ndi.Mv_Ndi_Katottg
                                                                      k
                                                                WHERE k.Kaot_Id =
                                                                      x_Kaot_Id),
                                                          'AdminUnitL5' VALUE
                                                              (SELECT MAX (
                                                                             'UA.ATU.M'
                                                                          || SUBSTR (
                                                                                 k.Kaot_Code,
                                                                                 -5))
                                                                 FROM Uss_Ndi.v_Ndi_Katottg
                                                                      k
                                                                WHERE k.Kaot_Id =
                                                                      x_Kaot_Id),
                                                          'ThoroughfareTp' VALUE
                                                              x_Street_Tp,
                                                          'Thoroughfare' VALUE
                                                              x_Street,
                                                          'LocatorDesignator' VALUE
                                                              x_House_Num,
                                                          'Building' VALUE
                                                              x_Build_Num,
                                                          'Flat' VALUE x_Flat)))
                                      ORDER BY s.Scd_Id
                                      RETURNING CLOB)    AS Temporarily_Displace_Json
                             FROM Src_Attr s
                         GROUP BY Scd_Sc)
                SELECT d.*, ROWNUM AS Rn
                  FROM Data d)
        LOOP
            DECLARE
                l_Obj   CLOB;
            BEGIN
                Ikis_Rbm.Api$uxp_Univ.Add_Jval (
                    l_Obj,
                    'ModifyDate',
                    TO_CHAR (Rec.Modify_Dt, 'yyyy-mm-dd"T"hh24:mi:ss'));
                Ikis_Rbm.Api$uxp_Univ.Add_Jval (
                    l_Obj,
                    'Person',
                    Unload$socialcard.Sc_Person_Json (p_Sc_Id         => Rec.Scd_Sc,
                                                      p_Need_Ident    => 'T',
                                                      p_Need_Issuer   => 'T'),
                    p_Format_Json   => TRUE);
                Ikis_Rbm.Api$uxp_Univ.Add_Jval (
                    l_Obj,
                    'Domicile',
                    Unload$vpo.Get_Domicile_Json (p_Sc_Id => Rec.Scd_Sc),
                    p_Format_Json   => TRUE);
                Ikis_Rbm.Api$uxp_Univ.Add_Jval (
                    l_Obj,
                    'TemporarilyDisplace',
                    Rec.Temporarily_Displace_Json,
                    p_Format_Json   => TRUE);

                Ikis_Rbm.Api$uxp_Univ.Add_Jobj (l_Array, p_Json_Obj => l_Obj);

                IF MOD (Rec.Rn, c_File_Row_Cnt) = 0
                THEN
                    Ikis_Rbm.Api$uxp_Files.Save_Json_Array (
                        p_Ur_Id             => p_Ur_Id,
                        p_Json_Array        => l_Array,
                        p_Compression_Lvl   => 8);
                    l_Array := NULL;
                END IF;
            END;
        END LOOP;

        IF l_Array IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Files.Save_Json_Array (p_Ur_Id             => p_Ur_Id,
                                                    p_Json_Array        => l_Array,
                                                    p_Compression_Lvl   => 8);
        END IF;
    END;

    /*
    info:    Отримання інформації про внутрішньо переміщену особу
    author:  sho
    request: #106583, 111335
    */
    FUNCTION Handle_Displaced_Person_Request (p_Request_Id     IN NUMBER,
                                              p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Response                  XMLTYPE;
        l_Person_Xml                XMLTYPE;
        l_Person                    Ikis_Rbm.Api$uxp_Univ.r_Person;
        l_Sc_Id                     NUMBER;
        l_Answer_Code               NUMBER;
        l_Answer_Text               VARCHAR2 (32000);
        l_Temporarilydisplace_Xml   XMLTYPE;
    BEGIN
        BEGIN
               SELECT Person
                 INTO l_Person_Xml
                 FROM XMLTABLE ('/*'
                                PASSING Xmltype (p_Request_Body)
                                COLUMNS Person    XMLTYPE PATH 'Person');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        IF l_Person_Xml IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Відсутній блок Дані особи (Person)';
            GOTO Resp;
        END IF;

        l_Person := Ikis_Rbm.Api$uxp_Univ.Parse_Person (l_Person_Xml);
        l_Person.Family_Name := Clear_Name (l_Person.Family_Name);
        l_Person.Name_ := Clear_Name (l_Person.Name_);
        l_Person.Patronymic_Name := Clear_Name (l_Person.Patronymic_Name);

        IF TRIM (l_Person.Family_Name) IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Незаповнено поле "Прізвище"';
            GOTO Resp;
        ELSIF TRIM (l_Person.Name_) IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Незаповнено поле "Ім’я"';
            GOTO Resp;
        ELSIF TRIM (l_Person.Birth_Date) IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Незаповнено поле "Дата народження"';
            GOTO Resp;
        ELSIF l_Person.Identifiers IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Незаповнено блок "Перелік ідентифікаторів"';
            GOTO Resp;
        END IF;

        FOR i IN 1 .. l_Person.Identifiers.COUNT
        LOOP
            IF TRIM (l_Person.Identifiers (i).Scheme_Code) IS NULL
            THEN
                l_Answer_Code := 10;
                l_Answer_Text :=
                       'Незаповнено поле "Назва унікального ідентифікатора"['
                    || i
                    || ']';
                GOTO Resp;
            ELSIF TRIM (l_Person.Identifiers (i).Notation) IS NULL
            THEN
                l_Answer_Code := 10;
                l_Answer_Text :=
                       'Незаповнено поле "Унікальний ідентифікатор"['
                    || i
                    || ']';
                GOTO Resp;
            END IF;
        END LOOP;

        l_Sc_Id := Unload$socialcard.Search_Sc (p_Person => l_Person);

        IF l_Sc_Id = Unload$socialcard.c_Search_Error_Found
        THEN
            l_Answer_Code := 0;
            l_Answer_Text := 'Особу не знайдено';
            GOTO Resp;
        ELSIF l_Sc_Id = Unload$socialcard.c_Search_Error_Support
        THEN
            l_Answer_Code := 2;
            l_Answer_Text :=
                'Унікальний ідентифікатор для пошуку особи не підтримується';
            GOTO Resp;
        ELSIF l_Sc_Id = Unload$socialcard.c_Search_Error_Many
        THEN
            l_Answer_Code := 3;
            l_Answer_Text := 'Не вдалося однозначно ідентифікувати особу';
            GOTO Resp;
        END IF;

        IF l_Answer_Code IS NULL
        THEN
            WITH
                Src
                AS
                    (SELECT Scd_Id,
                            Scd_St,
                            Scd_Dh,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 2440,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Guid,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 1756,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Number,
                            Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                p_Nda_Id   => 1757,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Issued,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 1759,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Issuer,
                            Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                p_Nda_Id   => 1760,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Date_End,
                            Uss_Doc.Api$documents.Get_Attr_Val_Id (
                                p_Nda_Id   => 4492,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Kaot_Id,
                            Build_Street_Tp (
                                p_Street_Id   =>
                                    Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                        p_Nda_Id   => 5551,
                                        p_Dh_Id    => d.Scd_Dh),
                                p_Street_Type   =>
                                    Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                        p_Nda_Id   => 4484,
                                        p_Dh_Id    => d.Scd_Dh))
                                AS x_Street_Tp,
                            Build_Street_Name (
                                p_Street_Id   =>
                                    Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                        p_Nda_Id   => 5551,
                                        p_Dh_Id    => d.Scd_Dh),
                                p_Street_Name   =>
                                    Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                        p_Nda_Id   => 4485,
                                        p_Dh_Id    => d.Scd_Dh))
                                AS x_Street,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 4487,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_House_Num,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 4488,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Build_Num,
                            Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                p_Nda_Id   => 4489,
                                p_Dh_Id    => d.Scd_Dh)
                                AS x_Flat
                       FROM Uss_Person.Sc_Document d
                      WHERE d.Scd_Ndt = 10052 AND d.Scd_Sc = l_Sc_Id),
                Data
                AS
                    (SELECT Scd_Id,
                            XMLELEMENT (
                                "TemporarilyDisplacedPerson",
                                XMLELEMENT ("GUID", x_Guid),
                                XMLELEMENT ("Number", x_Number),
                                XMLELEMENT ("Issued",
                                            TO_CHAR (x_Issued, 'yyyy-mm-dd')),
                                XMLELEMENT ("Issuer", x_Issuer),
                                Unload$vpo.Get_Cert_Status_Xml (
                                    p_Scd_St   => Scd_St,
                                    p_Scd_Dh   => Scd_Dh),
                                CASE
                                    WHEN x_Date_End IS NOT NULL
                                    THEN
                                        XMLELEMENT (
                                            "DateEnd",
                                            TO_CHAR (x_Date_End,
                                                     'yyyy-mm-dd'))
                                END,
                                XMLELEMENT (
                                    "ActualDomicile",
                                    XMLELEMENT ("AddressId", NULL),
                                    XMLELEMENT (
                                        "FullAddress",
                                        (SELECT k.Kaot_Code
                                           FROM Uss_Ndi.v_Ndi_Katottg k
                                          WHERE k.Kaot_Id = x_Kaot_Id)),
                                    XMLELEMENT ("AdminUnitL1", 'UA'),
                                    XMLELEMENT (
                                        "AdminUnitL2",
                                        (SELECT MAX (k.L1_Kaot_Full_Name)
                                           FROM Uss_Ndi.Mv_Ndi_Katottg k
                                          WHERE k.Kaot_Id = x_Kaot_Id)),
                                    XMLELEMENT (
                                        "AdminUnitL5",
                                        (SELECT MAX (
                                                       'UA.ATU.M'
                                                    || SUBSTR (k.Kaot_Code,
                                                               -5))
                                           FROM Uss_Ndi.v_Ndi_Katottg k
                                          WHERE k.Kaot_Id = x_Kaot_Id)),
                                    XMLELEMENT ("ThoroughfareTp",
                                                x_Street_Tp),
                                    XMLELEMENT ("Thoroughfare", x_Street),
                                    XMLELEMENT ("LocatorDesignator",
                                                x_House_Num),
                                    XMLELEMENT ("Building", x_Build_Num),
                                    XMLELEMENT ("Flat", x_Flat)))    Row_Xml
                       FROM Src)
            SELECT XMLELEMENT ("TemporarilyDisplace",
                               XMLAGG (Row_Xml ORDER BY Scd_Id DESC))
              INTO l_Temporarilydisplace_Xml
              FROM Data;

            l_Answer_Code := 1;
            l_Answer_Text := 'Особу знайдено';
        END IF;

       <<resp>>
        SELECT XMLELEMENT (
                   "DisplacedPersonResponse",
                   Ikis_Rbm.Api$uxp_Univ.Answer_Xml (
                       p_Code   => l_Answer_Code,
                       p_Text   => l_Answer_Text),
                   CASE
                       WHEN l_Answer_Code = 1
                       THEN
                           Unload$socialcard.Sc_Person_Xml (
                               p_Sc_Id        => l_Sc_Id,
                               p_Need_Ident   => 'T')
                   END,
                   CASE
                       WHEN l_Answer_Code = 1
                       THEN
                           Unload$vpo.Get_Domicile_Xml (p_Sc_Id => l_Sc_Id)
                   END,
                   l_Temporarilydisplace_Xml)
          INTO l_Response
          FROM DUAL;

        RETURN l_Response.Getclobval;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20030,
                   'Помилка Обробки запита: '
                || SQLCODE
                || ' '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    /*
    info:    Створення рядка вулиці на основі даних із атрибутів
    author:  kelatev
    request: #111333
    */
    FUNCTION Build_Street_Tp (p_Street_Id     IN VARCHAR2,
                              p_Street_Type   IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (32767);
    BEGIN
        SELECT CASE
                   WHEN p_Street_Id IS NOT NULL
                   THEN
                       (SELECT MAX (Nsrt.Nsrt_Name)
                          FROM Uss_Ndi.v_Ndi_Street       s,
                               Uss_Ndi.v_Ndi_Street_Type  Nsrt
                         WHERE     s.Ns_Id = p_Street_Id
                               AND s.History_Status = 'A'
                               AND Nsrt_Id = Ns_Nsrt)
                   WHEN p_Street_Type IS NOT NULL
                   THEN
                       (SELECT MAX (Nsrt.Nsrt_Name)
                          FROM Uss_Ndi.v_Ndi_Street_Type Nsrt
                         WHERE Nsrt_Id = p_Street_Type)
                   ELSE
                       NULL
               END
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;

    /*
    info:    Створення рядка вулиці на основі даних із атрибутів
    author:  kelatev
    request: #111333
    */
    FUNCTION Build_Street_Name (p_Street_Id     IN VARCHAR2,
                                p_Street_Name   IN VARCHAR2,
                                p_Street_Type   IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (32767);
    BEGIN
        SELECT CASE
                   WHEN p_Street_Id IS NOT NULL
                   THEN
                       (SELECT MAX (s.Ns_Name)
                          FROM Uss_Ndi.v_Ndi_Street s
                         WHERE     s.Ns_Id = p_Street_Id
                               AND s.History_Status = 'A')
                   ELSE
                       /*CASE
                         WHEN p_Street_Type IS NOT NULL THEN
                          (SELECT Nsrt.Nsrt_Name || ' '
                             FROM Uss_Ndi.v_Ndi_Street_Type Nsrt
                            WHERE Nsrt_Id = p_Street_Type)
                       END || */
                       p_Street_Name
               END
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;

    /*
    info:    Отримання адреси зареєстрованого місця проживання
    author:  kelatev
    request: #111333
    */
    FUNCTION Get_Domicile_Xml (p_Sc_Id IN NUMBER)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT Ikis_Rbm.Api$uxp_Univ.Domicile_Xml (
                   p_Address_Id   => NULL,
                   p_Full_Address   =>
                       (SELECT k.Kaot_Code
                          FROM Uss_Ndi.v_Ndi_Katottg k
                         WHERE k.Kaot_Id =
                               Uss_Doc.Api$documents.Get_Attr_Val_Id (
                                   p_Nda_Id   => 2292,
                                   p_Dh_Id    => Scd_Dh)))
          INTO l_Result
          FROM (SELECT MAX (d.Scd_Dh)     AS Scd_Dh
                  FROM Uss_Person.Sc_Document d
                 WHERE     d.Scd_Sc = p_Sc_Id
                       AND d.Scd_Ndt = 10052
                       AND d.Scd_St = '1'
                 FETCH FIRST 1 ROW ONLY);

        RETURN l_Result;
    END;

    /*
    info:    Отримання адреси зареєстрованого місця проживання
    author:  kelatev
    request: #111333
    */
    FUNCTION Get_Domicile_Json (p_Sc_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (32767);
    BEGIN
        SELECT Ikis_Rbm.Api$uxp_Univ.Domicile_Json (
                   p_Address_Id   => NULL,
                   p_Full_Address   =>
                       (SELECT k.Kaot_Code
                          FROM Uss_Ndi.v_Ndi_Katottg k
                         WHERE k.Kaot_Id =
                               Uss_Doc.Api$documents.Get_Attr_Val_Id (
                                   p_Nda_Id   => 2292,
                                   p_Dh_Id    => Scd_Dh)))
          INTO l_Result
          FROM (SELECT MAX (d.Scd_Dh)     AS Scd_Dh
                  FROM Uss_Person.Sc_Document d
                 WHERE     d.Scd_Sc = p_Sc_Id
                       AND d.Scd_Ndt = 10052
                       AND d.Scd_St = '1'
                 FETCH FIRST 1 ROW ONLY);

        RETURN l_Result;
    END;

    /*
    info:    Отримання статусу довідки ВПО
    author:  kelatev
    request: #111333
    */
    FUNCTION Get_Cert_Status_Xml (p_Scd_St IN VARCHAR2, p_Scd_Dh IN NUMBER)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
        l_Code     VARCHAR2 (10);
        l_Text     VARCHAR2 (32767);
    BEGIN
        IF p_Scd_St = 1
        THEN
            l_Code := 0;
            l_Text := 'Діюча';
        ELSE
            l_Code :=
                Uss_Doc.Api$documents.Get_Attr_Val_Id (p_Nda_Id   => 4480,
                                                       p_Dh_Id    => p_Scd_Dh);

            IF l_Code IS NOT NULL
            THEN
                SELECT MAX (Dic_Name)
                  INTO l_Text
                  FROM Uss_Ndi.v_Ddn_Vpo_End_Rsn
                 WHERE Dic_Value = l_Code AND Dic_St = 'A';
            END IF;

            IF l_Code IS NULL
            THEN
                l_Code := 8;
                l_Text := 'ЗАКІНЧЕННЯ ТЕРМІНУ ДІЇ ДОВІДКИ';
            END IF;
        END IF;

        SELECT XMLELEMENT ("Status",
                           XMLELEMENT ("Code", l_Code),
                           XMLELEMENT ("Text", l_Text))
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;

    FUNCTION Get_Cert_Status_Json (p_Scd_St IN VARCHAR2, p_Scd_Dh IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (32767);
        l_Code     VARCHAR2 (10);
        l_Text     VARCHAR2 (32767);
    BEGIN
        IF p_Scd_St = 1
        THEN
            l_Code := 0;
            l_Text := 'Діюча';
        ELSE
            l_Code :=
                Uss_Doc.Api$documents.Get_Attr_Val_Id (p_Nda_Id   => 4480,
                                                       p_Dh_Id    => p_Scd_Dh);

            IF l_Code IS NOT NULL
            THEN
                SELECT MAX (Dic_Name)
                  INTO l_Text
                  FROM Uss_Ndi.v_Ddn_Vpo_End_Rsn
                 WHERE Dic_Value = l_Code AND Dic_St = 'A';
            END IF;

            IF l_Code IS NULL
            THEN
                l_Code := 8;
                l_Text := 'ЗАКІНЧЕННЯ ТЕРМІНУ ДІЇ ДОВІДКИ';
            END IF;
        END IF;

        SELECT Json_Object ('Code' VALUE l_Code, 'Text' VALUE l_Text)
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;
END Unload$vpo;
/