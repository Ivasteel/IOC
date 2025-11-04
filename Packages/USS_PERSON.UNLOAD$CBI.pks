/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.UNLOAD$CBI
IS
    -- Author  : SHOSTAK
    -- Created : 16.08.2024 16:18:59
    -- Purpose :

    c_Pt_Start_Dt          CONSTANT NUMBER := 80;
    c_Endless_Dt           CONSTANT DATE := TO_DATE ('2999-12-31', 'yyyy-mm-dd');
    c_Without_Disability   CONSTANT NUMBER := 0;

    /*
    info:    Обробка запиту на дельту змін по ЦБІ
    author:  sho
    request: #106583
    */
    FUNCTION Handle_Delta_Request (p_Request_Id     IN NUMBER,
                                   p_Request_Body   IN CLOB)
        RETURN CLOB;

    /*
    info:    Формування відповідей на запити дельти ЦБІ(для інших організацій)
    author:  sho
    request: #106637
    note:
    */
    PROCEDURE Process_Delta_Request (p_Ur_Id IN NUMBER, p_Request IN CLOB --Ignore
                                                                         );

    /*
    info:    Обробка запиту на Отримання інформації про особу з інвалідністю
    author:  kelatev
    request: #111334
    */
    FUNCTION Handle_Disabled_Person_Request (p_Request_Id     IN NUMBER,
                                             p_Request_Body   IN CLOB)
        RETURN CLOB;
END Unload$cbi;
/


GRANT EXECUTE ON USS_PERSON.UNLOAD$CBI TO IKIS_RBM
/

GRANT EXECUTE ON USS_PERSON.UNLOAD$CBI TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:57:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.UNLOAD$CBI
IS
    /*
    info:    Обробка запиту на дельту змін по ЦБІ
    author:  sho
    request: #106583
    */
    FUNCTION Handle_Delta_Request (p_Request_Id     IN NUMBER,
                                   p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Start_Dt      DATE;
        l_Min_Dt        DATE := TO_DATE ('01.01.2024', 'dd.mm.yyyy');
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
    info:    Функція перевіряє розширений доступ до інформації
    author:  kelatev
    request: #111334
    note:    LossProfessionalCapacityInfo
    */
    FUNCTION Is_Extend_View (p_Ur_Id IN NUMBER)
        RETURN NUMBER
    IS
        --l_Ur_Src VARCHAR2(10);
        l_Request_Body     CLOB;
        l_Nrt_Id           NUMBER;
        l_Member_Class     VARCHAR2 (250);
        l_Member_Code      VARCHAR2 (250);
        l_Subsystem_Code   VARCHAR2 (200);
        l_Result           NUMBER;
    BEGIN
        --На сьогодні це найпростіший варіант перевірки відправника, якщо він буде не влаштовувати - використовувати, варіант 2
        --l_Ur_Src := Ikis_Rbm.Api$uxp_Request.Get_Ur_Src(p_Ur_Id => p_Ur_Id);
        --RETURN CASE WHEN l_Ur_Src IN('MO_OGD', 'DRAC') THEN 1 ELSE 0 END;

        --Щоб подивитися на заголовки, отримуємо весь запит, а не тільки тіло
        l_Request_Body :=
            Ikis_Rbm.Api$uxp_Request.Get_Vrequest (p_Ur_Id => p_Ur_Id).Ur_Soap_Req;
        l_Nrt_Id := Ikis_Rbm.Api$uxp_Request.Get_Ur_Nrt (p_Ur_Id => p_Ur_Id); --107, 122

                   --Отримуємо інформацію про відправника запиту
                   SELECT Member_Class, Member_Code, Subsystem_Code
                     INTO l_Member_Class, l_Member_Code, l_Subsystem_Code
                     FROM XMLTABLE (
                              '//*:Envelope/*:Header/*:client'
                              PASSING Xmltype.Createxml (l_Request_Body)
                              COLUMNS Member_Class      VARCHAR2 (250) PATH '*:memberClass',
                                      Member_Code       VARCHAR2 (250) PATH '*:memberCode',
                                      Subsystem_Code    VARCHAR2 (250) PATH '*:subsystemCode');

        SELECT SIGN (COUNT (*))
          INTO l_Result
          FROM Paramsperson p
         WHERE     REGEXP_LIKE (p.Prm_Code,
                                'EXTEND_NRT_' || l_Nrt_Id || '_[0-9]+')
               AND p.Prm_Value =
                      l_Member_Class
                   || '/'
                   || l_Member_Code
                   || '/'
                   || l_Subsystem_Code;

        RETURN l_Result;
    END;

    /*
    info:    Формування відповідей на запити дельти ЦБІ(для інших організацій)
    author:  sho
    request: #106637
    note:
    */
    PROCEDURE Process_Delta_Request (p_Ur_Id IN NUMBER, p_Request IN CLOB --Ignore
                                                                         )
    IS
        l_Start_Dt                DATE;
        l_Array                   CLOB;
        c_File_Row_Cnt   CONSTANT NUMBER := 10000; --todo: можливо винести в параметри
        l_Is_Extend_View          NUMBER := 0; --Відображення блоку LossProfessionalCapacityInfo
    BEGIN
        l_Is_Extend_View := Unload$cbi.Is_Extend_View (p_Ur_Id => p_Ur_Id);
        --Отримуємо дату з якої починається формування дельти
        l_Start_Dt :=
            Ikis_Rbm.Api$request.Get_Rn_Common_Info_Dt (
                p_Rnc_Rn   => Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id),
                p_Rnc_Pt   => c_Pt_Start_Dt);

        FOR Rec
            IN (WITH
                    Docs
                    AS
                        (  SELECT MAX (e.Scde_Dt)     AS Modify_Dt,
                                  d.Scd_Id,
                                  d.Scd_Sc,
                                  d.Scd_St,
                                  d.Scd_Dh
                             FROM Uss_Person.Sc_Document d
                                  JOIN Scd_Event e
                                      ON     e.Scde_Scd = d.Scd_Id
                                         AND e.Scde_Dt >= l_Start_Dt
                                         AND e.Scde_Event IN ('CR', 'CL', 'UP')
                            WHERE d.Scd_Ndt = 201 AND d.Scd_Sc IS NOT NULL
                         GROUP BY d.Scd_Id,
                                  d.Scd_Sc,
                                  d.Scd_St,
                                  d.Scd_Dh),
                    Src
                    AS
                        (SELECT Modify_Dt,
                                Scd_Id,
                                d.Scd_St,
                                Scd_Sc,
                                Scd_Dh,
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 350,
                                    p_Dh_Id    => d.Scd_Dh)       AS x_Issued_Dt,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 346,
                                    p_Dh_Id    => d.Scd_Dh)       AS x_Number,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 349,
                                    p_Dh_Id    => d.Scd_Dh)       AS x_Group,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 791,
                                    p_Dh_Id    => d.Scd_Dh)       AS x_Sub_Group,
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 352,
                                    p_Dh_Id    => d.Scd_Dh)       AS x_Begin_Dt,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 2925,
                                    p_Dh_Id    => d.Scd_Dh)       AS x_Endless,
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 1910,
                                    p_Dh_Id    => d.Scd_Dh)       AS x_Review_Dt,
                                Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                                    p_Nda_Id   => 347,
                                    p_Dh_Id    => d.Scd_Dh)       AS x_End_Dt,
                                Uss_Doc.Api$documents.Get_Attr_Val_Str (
                                    p_Nda_Id   => 353,
                                    p_Dh_Id    => d.Scd_Dh)       AS x_Reason,
                                (SELECT MAX (Pd.Scpo_Scdi)
                                   FROM Uss_Person.Sc_Pfu_Document Pd
                                  WHERE     Pd.Scpo_Scd = d.Scd_Id
                                        AND Pd.Scpo_St = 'VO')    AS x_Scdi_Id
                           FROM Docs d),
                    Json
                    AS
                        (  SELECT MAX (Modify_Dt)        AS Modify_Dt,
                                  Scd_Sc,
                                  LISTAGG (Scd_Dh, ','),
                                  Json_Arrayagg (
                                      Json_Object (
                                          'DisabilityGroup' VALUE
                                              Json_Object (
                                                  'Actual' VALUE
                                                      DECODE (s.Scd_St,
                                                              1, 'true',
                                                              'false')
                                                      FORMAT JSON,
                                                  'Act' VALUE
                                                      Json_Object (
                                                          'Issued' VALUE
                                                              TO_CHAR (
                                                                  x_Issued_Dt,
                                                                  'yyyy-mm-dd'),
                                                          'Number' VALUE
                                                              x_Number,
                                                          'OrgId' VALUE
                                                              (SELECT z.Scmz_Org_Id
                                                                 FROM Uss_Person.Sc_Moz_Zoz
                                                                      z
                                                                WHERE     z.Scmz_Scdi =
                                                                          x_Scdi_Id
                                                                      AND z.Scmz_St =
                                                                          'VO'))
                                                      FORMAT JSON,
                                                  'Group' VALUE
                                                      NVL (
                                                          Uss_Ndi.Tools.Decode_Dict (
                                                              p_Nddc_Tp   =>
                                                                  'SCY_GROUP',
                                                              p_Nddc_Src   =>
                                                                  'USS',
                                                              p_Nddc_Dest   =>
                                                                  'UXP',
                                                              p_Nddc_Code_Src   =>
                                                                  x_Group),
                                                          c_Without_Disability),
                                                  'SubGroup' VALUE x_Sub_Group,
                                                  'DisabilityDateFrom' VALUE
                                                      TO_CHAR (x_Begin_Dt,
                                                               'yyyy-mm-dd'),
                                                  'IsDisabilityPerpetual' VALUE
                                                      CASE
                                                          WHEN x_Endless = 'T'
                                                          THEN
                                                              TO_CHAR (
                                                                  c_Endless_Dt,
                                                                  'yyyy-mm-dd')
                                                          ELSE
                                                              TO_CHAR (
                                                                  NVL (
                                                                      x_Review_Dt,
                                                                      x_End_Dt),
                                                                  'yyyy-mm-dd')
                                                      END,
                                                  'DisabilityReason' VALUE
                                                      x_Reason,
                                                  'LossProfessionalCapacityInfo' VALUE
                                                      CASE
                                                          WHEN l_Is_Extend_View =
                                                               1
                                                          THEN
                                                              (SELECT Json_Arrayagg (Json_Object (
                                                                                         'LossProfessionalCapacity' VALUE
                                                                                             Json_Object (
                                                                                                 'Date' VALUE
                                                                                                     TO_CHAR (
                                                                                                         l.Scml_Loss_Prof_Ability_Dt,
                                                                                                         'yyyy-mm-dd'),
                                                                                                 'Percentage' VALUE
                                                                                                     l.Scml_Loss_Prof_Ability_Perc,
                                                                                                 'Reason' VALUE
                                                                                                     l.Scml_Loss_Prof_Ability_Cause))
                                                                                     ORDER BY
                                                                      Scml_Id DESC )
                                                                 FROM Uss_Person.Sc_Moz_Loss_Prof_Ability
                                                                      l
                                                                WHERE     l.Scml_Scdi =
                                                                          x_Scdi_Id
                                                                      AND l.Scml_St =
                                                                          'VO')
                                                      END))
                                      ORDER BY s.Scd_Id
                                      RETURNING CLOB)    AS Disability_Group_Json
                             FROM Src s
                         GROUP BY Scd_Sc)
                SELECT d.*, ROWNUM AS Rn
                  FROM Json d)
        LOOP
            DECLARE
                l_Obj   CLOB;
            BEGIN
                Ikis_Rbm.Api$uxp_Univ.Add_Jval (
                    l_Obj,
                    'ModifyDate',
                    TO_CHAR (Rec.Modify_Dt, 'yyyy-mm-dd hh24:mi:ss'));
                Ikis_Rbm.Api$uxp_Univ.Add_Jval (
                    l_Obj,
                    'Person',
                    Unload$socialcard.Sc_Person_Json (p_Sc_Id         => Rec.Scd_Sc,
                                                      p_Need_Ident    => 'T',
                                                      p_Need_Issuer   => 'F'),
                    p_Format_Json   => TRUE);
                Ikis_Rbm.Api$uxp_Univ.Add_Jval (l_Obj,
                                                'DisabilityData',
                                                Rec.Disability_Group_Json,
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
    info:    Обробка запиту на Отримання інформації про особу з інвалідністю
    author:  kelatev
    request: #111334
    */
    FUNCTION Handle_Disabled_Person_Request (p_Request_Id     IN NUMBER,
                                             p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Response             XMLTYPE;
        l_Identifiers_Xml      XMLTYPE;
        l_Identifiers          Ikis_Rbm.Api$uxp_Univ.t_Identifiers;
        l_Begindate            DATE;
        l_Enddate              DATE;
        l_Get_Actual           VARCHAR2 (10);

        l_Min_Dt               DATE := TO_DATE ('01.01.2024', 'dd.mm.yyyy');
        l_Sc_Id                NUMBER;
        l_Answer_Code          NUMBER;
        l_Answer_Text          VARCHAR2 (32000);
        l_Disabilitydata_Xml   XMLTYPE;
        l_Is_Extend_View       NUMBER := 0; --Відображення блоку LossProfessionalCapacityInfo
    BEGIN
        l_Is_Extend_View :=
            Unload$cbi.Is_Extend_View (p_Ur_Id => p_Request_Id);

        BEGIN
                    SELECT Identifiers,
                           Tools.Try_Parse_Dt (Begindate, 'yyyy-mm-dd"T"hh24:mi:ss'),
                           Tools.Try_Parse_Dt (Enddate, 'yyyy-mm-dd"T"hh24:mi:ss'),
                           UPPER (Getactual)
                      INTO l_Identifiers_Xml,
                           l_Begindate,
                           l_Enddate,
                           l_Get_Actual
                      FROM XMLTABLE (
                               '/*'
                               PASSING Xmltype (p_Request_Body)
                               COLUMNS Identifiers    XMLTYPE PATH 'Identifiers',
                                       Begindate      VARCHAR2 (30) PATH 'BeginDate',
                                       Enddate        VARCHAR2 (30) PATH 'EndDate',
                                       Getactual      VARCHAR2 (10) PATH 'GetActual');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        IF l_Identifiers_Xml IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Відсутній блок Identifiers';
            GOTO Resp;
        END IF;

        l_Identifiers :=
            Ikis_Rbm.Api$uxp_Univ.Parse_Identifiers (l_Identifiers_Xml);

        FOR i IN 1 .. l_Identifiers.COUNT
        LOOP
            IF TRIM (l_Identifiers (i).Scheme_Code) IS NULL
            THEN
                l_Answer_Code := 10;
                l_Answer_Text :=
                       'Незаповнено поле "Назва унікального ідентифікатора"['
                    || i
                    || ']';
                GOTO Resp;
            ELSIF TRIM (l_Identifiers (i).Notation) IS NULL
            THEN
                l_Answer_Code := 10;
                l_Answer_Text :=
                       'Незаповнено поле "Унікальний ідентифікатор"['
                    || i
                    || ']';
                GOTO Resp;
            END IF;
        END LOOP;

        l_Sc_Id :=
            Unload$socialcard.Search_Sc (p_Identifiers => l_Identifiers);

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

        WITH
            Docs_201
            AS
                (  SELECT MAX (e.Scde_Dt)     AS Modify_Dt,
                          d.Scd_Id,
                          d.Scd_Dh,
                          d.Scd_St
                     FROM Uss_Person.Scd_Event e
                          JOIN Uss_Person.Sc_Document d
                              ON     e.Scde_Scd = d.Scd_Id
                                 AND d.Scd_Ndt = 201
                                 AND d.Scd_Sc = l_Sc_Id
                    WHERE     e.Scde_Dt >= l_Min_Dt
                          AND e.Scde_Event IN ('CR', 'CL', 'UP')
                          --Якщо Get_Actual = TRUE, то виводимо лише актуальні записи
                          --Якщо не вказано, то BeginDate/EndDate фільтрує записи дати реєстрації документа
                          AND (   (l_Get_Actual = 'TRUE' AND d.Scd_St = '1')
                               OR (    NVL (l_Get_Actual, 'FALSE') != 'TRUE'
                                   AND (   l_Begindate IS NULL
                                        OR (    e.Scde_Dt >= l_Begindate
                                            AND e.Scde_Event IN ('CR')))
                                   AND (   l_Enddate IS NULL
                                        OR (    e.Scde_Dt <= l_Enddate
                                            AND e.Scde_Event IN ('CR')))))
                 GROUP BY d.Scd_Id,
                          d.Scd_Issued_Dt,
                          d.Scd_Issued_Who,
                          d.Scd_Dh,
                          d.Scd_Sc,
                          d.Scd_St),
            Src_201
            AS
                (SELECT Scd_Id,
                        d.Scd_St,
                        Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                            p_Nda_Id   => 350,
                            p_Dh_Id    => d.Scd_Dh)                              AS x_Issued_Dt,
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            p_Nda_Id   => 346,
                            p_Dh_Id    => d.Scd_Dh)                              AS x_Number,
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            p_Nda_Id   => 349,
                            p_Dh_Id    => d.Scd_Dh)                              AS x_Group,
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            p_Nda_Id   => 791,
                            p_Dh_Id    => d.Scd_Dh)                              AS x_Sub_Group,
                        Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                            p_Nda_Id   => 352,
                            p_Dh_Id    => d.Scd_Dh)                              AS x_Begin_Dt,
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            p_Nda_Id   => 2925,
                            p_Dh_Id    => d.Scd_Dh)                              AS x_Endless,
                        Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                            p_Nda_Id   => 1910,
                            p_Dh_Id    => d.Scd_Dh)                              AS x_Review_Dt,
                        Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                            p_Nda_Id   => 347,
                            p_Dh_Id    => d.Scd_Dh)                              AS x_End_Dt,
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            p_Nda_Id   => 353,
                            p_Dh_Id    => d.Scd_Dh)                              AS x_Reason,
                        (SELECT MAX (Pd.Scpo_Scdi)
                           FROM Uss_Person.Sc_Pfu_Document Pd
                          WHERE Pd.Scpo_Scd = d.Scd_Id AND Pd.Scpo_St = 'VO')    AS x_Scdi_Id
                   FROM Docs_201 d),
            Xml_201
            AS
                (SELECT Scd_Id,
                        XMLELEMENT (
                            "DisabilityGroup",
                            XMLELEMENT ("Actual",
                                        DECODE (Scd_St, 1, 'true', 'false')),
                            XMLELEMENT (
                                "Act",
                                XMLELEMENT (
                                    "Issued",
                                    TO_CHAR (x_Issued_Dt, 'yyyy-mm-dd')),
                                XMLELEMENT ("Number", x_Number),
                                XMLELEMENT (
                                    "OrgId",
                                    (SELECT z.Scmz_Org_Id
                                       FROM Uss_Person.Sc_Moz_Zoz z
                                      WHERE     z.Scmz_Scdi = x_Scdi_Id
                                            AND z.Scmz_St = 'VO'))),
                            XMLELEMENT (
                                "Group",
                                NVL (Uss_Ndi.Tools.Decode_Dict (
                                         p_Nddc_Tp         => 'SCY_GROUP',
                                         p_Nddc_Src        => 'USS',
                                         p_Nddc_Dest       => 'UXP',
                                         p_Nddc_Code_Src   => x_Group),
                                     c_Without_Disability)),
                            XMLELEMENT ("SubGroup", x_Sub_Group),
                            CASE
                                WHEN x_Begin_Dt IS NOT NULL
                                THEN
                                    XMLELEMENT (
                                        "DisabilityDateFrom",
                                        TO_CHAR (x_Begin_Dt, 'yyyy-mm-dd'))
                            END,
                            XMLELEMENT (
                                "IsDisabilityPerpetual",
                                CASE
                                    WHEN x_Endless = 'T'
                                    THEN
                                        TO_CHAR (c_Endless_Dt, 'yyyy-mm-dd')
                                    ELSE
                                        TO_CHAR (NVL (x_Review_Dt, x_End_Dt),
                                                 'yyyy-mm-dd')
                                END),
                            XMLELEMENT ("DisabilityReason", x_Reason),
                            CASE
                                WHEN l_Is_Extend_View = 1
                                THEN
                                    XMLELEMENT (
                                        "LossProfessionalCapacityInfo",
                                        (SELECT XMLAGG (XMLELEMENT (
                                                            "LossProfessionalCapacity",
                                                            XMLELEMENT (
                                                                "Date",
                                                                TO_CHAR (
                                                                    l.Scml_Loss_Prof_Ability_Dt,
                                                                    'yyyy-mm-dd')),
                                                            XMLELEMENT (
                                                                "Percentage",
                                                                TRIM (
                                                                    TO_CHAR (
                                                                        l.Scml_Loss_Prof_Ability_Perc,
                                                                        '9999999999990D99999',
                                                                        'NLS_NUMERIC_CHARACTERS=''. '''))),
                                                            XMLELEMENT (
                                                                "Reason",
                                                                l.Scml_Loss_Prof_Ability_Cause))
                                                        ORDER BY Scml_Id DESC)
                                           FROM Uss_Person.Sc_Moz_Loss_Prof_Ability
                                                l
                                          WHERE     l.Scml_Scdi = x_Scdi_Id
                                                AND l.Scml_St = 'VO'))
                            END)    AS Row_Xml
                   FROM Src_201),
            Docs_200
            AS
                (  SELECT MAX (e.Scde_Dt)     AS Modify_Dt,
                          d.Scd_Id,
                          d.Scd_Dh,
                          d.Scd_St
                     FROM Uss_Person.Scd_Event e
                          JOIN Uss_Person.Sc_Document d
                              ON     e.Scde_Scd = d.Scd_Id
                                 AND d.Scd_Ndt = 200
                                 AND d.Scd_Sc = l_Sc_Id
                    WHERE     e.Scde_Dt >= l_Min_Dt
                          AND e.Scde_Event IN ('CR', 'CL', 'UP')
                          --Якщо Get_Actual = TRUE, то виводимо лише актуальні записи
                          --Якщо не вказано, то BeginDate/EndDate фільтрує записи дати реєстрації документа
                          AND (   (l_Get_Actual = 'TRUE' AND d.Scd_St = '1')
                               OR (    NVL (l_Get_Actual, 'FALSE') != 'TRUE'
                                   AND (   l_Begindate IS NULL
                                        OR (    e.Scde_Dt >= l_Begindate
                                            AND e.Scde_Event IN ('CR')))
                                   AND (   l_Enddate IS NULL
                                        OR (    e.Scde_Dt <= l_Enddate
                                            AND e.Scde_Event IN ('CR')))))
                 GROUP BY d.Scd_Id,
                          d.Scd_Issued_Dt,
                          d.Scd_Issued_Who,
                          d.Scd_Dh,
                          d.Scd_Sc,
                          d.Scd_St),
            Src_200
            AS
                (SELECT Scd_Id,
                        Scd_St,
                        Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                            p_Nda_Id   => 345,
                            p_Dh_Id    => d.Scd_Dh)   AS x_Issued,
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            p_Nda_Id   => 343,
                            p_Dh_Id    => d.Scd_Dh)   AS x_Number,
                        0                             x_Group,
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            p_Nda_Id   => 797,
                            p_Dh_Id    => d.Scd_Dh)   AS x_Sub_Group,
                        Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                            p_Nda_Id   => 792,
                            p_Dh_Id    => d.Scd_Dh)   AS x_Begin_Dt,
                        Uss_Doc.Api$documents.Get_Attr_Val_Dt (
                            p_Nda_Id   => 793,
                            p_Dh_Id    => d.Scd_Dh)   AS x_End_Dt,
                        Uss_Doc.Api$documents.Get_Attr_Val_Str (
                            p_Nda_Id   => 804,
                            p_Dh_Id    => d.Scd_Dh)   AS x_Reason
                   FROM Docs_200 d),
            Xml_200
            AS
                (SELECT Scd_Id,
                        XMLELEMENT (
                            "DisabilityGroup",
                            XMLELEMENT ("Actual",
                                        DECODE (Scd_St, 1, 'true', 'false')),
                            XMLELEMENT (
                                "Act",
                                XMLELEMENT ("Issued",
                                            TO_CHAR (x_Issued, 'yyyy-mm-dd')),
                                XMLELEMENT ("Number", x_Number),
                                XMLELEMENT ("OrgId", NULL)),
                            XMLELEMENT ("Group", x_Group),
                            XMLELEMENT (
                                "SubGroup",
                                CASE WHEN x_Sub_Group = 'DIA' THEN 'A' END),
                            CASE
                                WHEN x_Begin_Dt IS NOT NULL
                                THEN
                                    XMLELEMENT (
                                        "DisabilityDateFrom",
                                        TO_CHAR (x_Begin_Dt, 'yyyy-mm-dd'))
                            END,
                            CASE
                                WHEN x_End_Dt IS NOT NULL
                                THEN
                                    XMLELEMENT (
                                        "IsDisabilityPerpetual",
                                        TO_CHAR (x_End_Dt, 'yyyy-mm-dd'))
                            END,
                            XMLELEMENT ("DiasabilityReason", x_Reason))    AS Row_Xml
                   FROM Src_200)
        SELECT CASE
                   WHEN EXISTS (SELECT 1 FROM Src_201)
                   THEN
                       (SELECT XMLELEMENT (
                                   "DisabilityData",
                                   XMLAGG (Row_Xml ORDER BY Scd_Id DESC))
                          FROM Xml_201)
                   ELSE
                       (SELECT XMLELEMENT (
                                   "DisabilityData",
                                   XMLAGG (Row_Xml ORDER BY Scd_Id DESC))
                          FROM Xml_200)
               END
          INTO l_Disabilitydata_Xml
          FROM DUAL;

        l_Answer_Code := 1;
        l_Answer_Text := 'Особу знайдено';

       <<resp>>
        SELECT XMLELEMENT (
                   "DisabledPersonResponse",
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
                   l_Disabilitydata_Xml)
          INTO l_Response
          FROM DUAL;

        RETURN l_Response.Getclobval;
    END;
END Unload$cbi;
/