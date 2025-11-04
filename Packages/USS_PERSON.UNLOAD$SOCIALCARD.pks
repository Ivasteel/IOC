/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.UNLOAD$SOCIALCARD
IS
    -- Author  : SHOSTAK
    -- Created : 16.08.2024 12:06:20
    -- Purpose : Універсальні функції для вивантаження даних(обмінів)

    c_Search_Error_Found     CONSTANT NUMBER := 0;         --Особу не знайдено
    c_Search_Error_Support   CONSTANT NUMBER := -1; --Унікальний ідентифікатор для пошуку особи не підтримується
    c_Search_Error_Many      CONSTANT NUMBER := -2; --Не вдалося однозначно ідентифікувати особу

    /*
    info:    Отримання масиву документів що посвідчують особу
    author:  sho
    request: #106637
    */
    FUNCTION Sc_Identifiers_Json (p_Sc_Id         IN NUMBER,
                                  p_Need_Issuer   IN VARCHAR2 DEFAULT 'F')
        RETURN CLOB;

    /*
    info:    Отримання масиву документів що посвідчують особу
    author:  sho
    request: #106637
    */
    FUNCTION Sc_Identifiers_Xml (p_Sc_Id IN NUMBER)
        RETURN XMLTYPE;

    /*
    info:    Отримання реквізитів особи
    author:  sho
    request: #106637
    */
    FUNCTION Sc_Person_Json (p_Sc_Id         IN NUMBER,
                             p_Need_Ident    IN VARCHAR2 DEFAULT 'F', --Чи потрібно отримувати документи
                             p_Need_Issuer   IN VARCHAR2 DEFAULT 'F' --Чи потрібно виводити видавця
                                                                    )
        RETURN CLOB;

    /*
    info:    Отримання реквізитів особи
    author:  sho
    request: #106637
    */
    FUNCTION Sc_Person_Xml (p_Sc_Id        IN NUMBER,
                            p_Need_Ident   IN VARCHAR2 DEFAULT 'F' --Чи потрібно отримувати документи
                                                                  )
        RETURN XMLTYPE;

    FUNCTION Search_Sc (p_Identifier IN Ikis_Rbm.Api$uxp_Univ.r_Identifier)
        RETURN NUMBER;

    FUNCTION Search_Sc (p_Identifiers IN Ikis_Rbm.Api$uxp_Univ.t_Identifiers)
        RETURN NUMBER;

    FUNCTION Search_Sc (p_Person IN Ikis_Rbm.Api$uxp_Univ.r_Person)
        RETURN NUMBER;
END Unload$socialcard;
/


/* Formatted on 8/12/2025 5:57:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.UNLOAD$SOCIALCARD
IS
    /*
    info:    Отримання масиву документів що посвідчують особу
    author:  sho
    request: #106637
    */
    FUNCTION Sc_Identifiers_Json (p_Sc_Id         IN NUMBER,
                                  p_Need_Issuer   IN VARCHAR2 DEFAULT 'F' --Чи потрібно виводити видавця
                                                                         )
        RETURN CLOB
    IS
        l_Result   CLOB;
    BEGIN
        SELECT NVL (
                   Json_Arrayagg (
                       Json_Object (
                           'Identifier' VALUE
                               CASE
                                   WHEN p_Need_Issuer = 'T'
                                   THEN
                                       Ikis_Rbm.Api$uxp_Univ.Identifier_Ext_Json (
                                           p_Issued   =>
                                               x_Issued,
                                           p_Creator   =>
                                               x_Creator,
                                           p_Scheme_Code   =>
                                               x_Scheme_Code,
                                           p_Notation   =>
                                               x_Notation)
                                   ELSE
                                       Ikis_Rbm.Api$uxp_Univ.Identifier_Json (
                                           p_Scheme_Code   => x_Scheme_Code,
                                           p_Notation      => x_Notation)
                               END FORMAT JSON)),
                   '[]')
          INTO l_Result
          FROM (SELECT d.Scd_Issued_Dt
                           AS x_Issued,
                       d.Scd_Issued_Who
                           AS x_Creator,
                       Uss_Ndi.Tools.Decode_Dict (
                           p_Nddc_Tp         => 'SCHM',
                           p_Nddc_Src        => 'USS',
                           p_Nddc_Dest       => 'UXP',
                           p_Nddc_Code_Src   => d.Scd_Ndt)
                           AS x_Scheme_Code,
                       d.Scd_Seria || d.Scd_Number
                           AS x_Notation
                  FROM Sc_Document  d
                       JOIN Uss_Ndi.v_Ndi_Document_Type t
                           ON     d.Scd_Ndt = t.Ndt_Id
                              AND (   t.Ndt_Ndc = 13
                                   OR d.Scd_Ndt = 5
                                   OR d.Scd_Ndt = 807)
                 WHERE d.Scd_Sc = p_Sc_Id AND d.Scd_St = '1'
                UNION ALL
                -- Унікальний номер запису у реєстрі
                SELECT d.Scd_Issued_Dt      AS x_Issued,
                       d.Scd_Issued_Who     AS x_Creator,
                       '2'                  AS x_Scheme_Name,
                       a.Da_Val_String      AS x_Notation
                  FROM Sc_Document               d,
                       Uss_Doc.v_Doc_Attr2hist   Ah,
                       Uss_Doc.v_Doc_Attributes  a
                 WHERE     d.Scd_Sc = p_Sc_Id
                       AND d.Scd_St = '1'
                       AND d.Scd_Ndt = 7
                       AND Ah.Da2h_Dh = d.Scd_Dh
                       AND a.Da_Id = Ah.Da2h_Da
                       AND a.Da_Nda = 810
                       AND a.Da_Val_String IS NOT NULL);

        RETURN l_Result;
    END;

    /*
    info:    Отримання масиву документів що посвідчують особу
    author:  sho
    request: #106637
    */
    FUNCTION Sc_Identifiers_Xml (p_Sc_Id IN NUMBER)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLAGG (Ikis_Rbm.Api$uxp_Univ.Identifier_Xml (
                           p_Issued        => x_Issued,
                           p_Creator       => x_Creator,
                           p_Scheme_Code   => x_Scheme_Code,
                           p_Notation      => x_Notation))
          INTO l_Result
          FROM (SELECT d.Scd_Issued_Dt
                           AS x_Issued,
                       d.Scd_Issued_Who
                           AS x_Creator,
                       Uss_Ndi.Tools.Decode_Dict (
                           p_Nddc_Tp         => 'SCHM',
                           p_Nddc_Src        => 'USS',
                           p_Nddc_Dest       => 'UXP',
                           p_Nddc_Code_Src   => d.Scd_Ndt)
                           AS x_Scheme_Code,
                       d.Scd_Seria || d.Scd_Number
                           AS x_Notation
                  FROM Sc_Document  d
                       JOIN Uss_Ndi.v_Ndi_Document_Type t
                           ON     d.Scd_Ndt = t.Ndt_Id
                              AND (   t.Ndt_Ndc = 13
                                   OR d.Scd_Ndt = 5
                                   OR d.Scd_Ndt = 807)
                 WHERE d.Scd_Sc = p_Sc_Id AND d.Scd_St = '1'
                UNION ALL
                -- Унікальний номер запису у реєстрі
                SELECT d.Scd_Issued_Dt      AS x_Issued,
                       d.Scd_Issued_Who     AS x_Creator,
                       '2'                  AS x_Scheme_Code,
                       a.Da_Val_String      AS x_Notation
                  FROM Sc_Document               d,
                       Uss_Doc.v_Doc_Attr2hist   Ah,
                       Uss_Doc.v_Doc_Attributes  a
                 WHERE     d.Scd_Sc = p_Sc_Id
                       AND d.Scd_St = '1'
                       AND d.Scd_Ndt = 7
                       AND Ah.Da2h_Dh = d.Scd_Dh
                       AND a.Da_Id = Ah.Da2h_Da
                       AND a.Da_Nda = 810
                       AND a.Da_Val_String IS NOT NULL);

        RETURN l_Result;
    END;

    /*
    info:    Отримання реквізитів особи
    author:  sho
    request: #106637
    */
    FUNCTION Sc_Person_Json (p_Sc_Id         IN NUMBER,
                             p_Need_Ident    IN VARCHAR2 DEFAULT 'F', --Чи потрібно отримувати документи
                             p_Need_Issuer   IN VARCHAR2 DEFAULT 'F' --Чи потрібно виводити видавця
                                                                    )
        RETURN CLOB
    IS
        l_Result   CLOB;
    BEGIN
        SELECT Ikis_Rbm.Api$uxp_Univ.Person_Json (
                   p_Family_Name       => i.Sci_Ln,
                   p_Name              => i.Sci_Fn,
                   p_Patronymic_Name   => i.Sci_Mn,
                   p_Birth_Dt          => b.Scb_Dt,
                   p_Gender            => Uss_Ndi.Tools.Decode_Dict (
                                             p_Nddc_Tp         => 'GENDER',
                                             p_Nddc_Src        => 'USS',
                                             p_Nddc_Dest       => 'UXP',
                                             p_Nddc_Code_Src   => i.Sci_Gender),
                   p_Identifiers       =>
                       CASE
                           WHEN p_Need_Ident = 'T'
                           THEN
                               Sc_Identifiers_Json (c.Sc_Id, p_Need_Issuer)
                       END)    AS Person
          INTO l_Result
          FROM Socialcard  c
               JOIN Sc_Change g ON c.Sc_Scc = g.Scc_Id
               JOIN Sc_Identity i ON g.Scc_Sci = i.Sci_Id
               LEFT JOIN Sc_Birth b ON g.Scc_Scb = b.Scb_Id
         WHERE c.Sc_Id = p_Sc_Id;

        RETURN l_Result;
    END;

    /*
    info:    Отримання реквізитів особи
    author:  sho
    request: #106637
    */
    FUNCTION Sc_Person_Xml (p_Sc_Id        IN NUMBER,
                            p_Need_Ident   IN VARCHAR2 DEFAULT 'F' --Чи потрібно отримувати документи
                                                                  )
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT Ikis_Rbm.Api$uxp_Univ.Person_Xml (
                   p_Family_Name       => i.Sci_Ln,
                   p_Name              => i.Sci_Fn,
                   p_Patronymic_Name   => i.Sci_Mn,
                   p_Birth_Dt          => b.Scb_Dt,
                   p_Gender            => Uss_Ndi.Tools.Decode_Dict (
                                             p_Nddc_Tp         => 'GENDER',
                                             p_Nddc_Src        => 'USS',
                                             p_Nddc_Dest       => 'UXP',
                                             p_Nddc_Code_Src   => i.Sci_Gender),
                   p_Identifiers       =>
                       CASE
                           WHEN p_Need_Ident = 'T'
                           THEN
                               Sc_Identifiers_Xml (c.Sc_Id)
                       END)    AS Person
          INTO l_Result
          FROM Socialcard  c
               JOIN Sc_Change g ON c.Sc_Scc = g.Scc_Id
               JOIN Sc_Identity i ON g.Scc_Sci = i.Sci_Id
               LEFT JOIN Sc_Birth b ON g.Scc_Scb = b.Scb_Id
         WHERE c.Sc_Id = p_Sc_Id;

        RETURN l_Result;
    END;

    /*
    info:    Пошук особи за посвідчуючим документом
    author:  kelatev
    request: #111332
    */
    FUNCTION Search_By_Doc (
        p_Identifier   IN Ikis_Rbm.Api$uxp_Univ.r_Identifier)
        RETURN OWA_UTIL.Num_Arr
    IS
        l_Sc_Id      OWA_UTIL.Num_Arr;
        l_Ndt_List   OWA_UTIL.Ident_Arr;
    BEGIN
        CASE p_Identifier.Scheme_Code
            WHEN '2'
            THEN
                --Id--УНЗР знаходиться в атрибуті, а не окремим документом
                SELECT Scd_Sc
                  BULK COLLECT INTO l_Sc_Id
                  FROM Uss_Person.v_Sc_Document  d,
                       Uss_Doc.v_Doc_Attr2hist   Ah,
                       Uss_Doc.v_Doc_Attributes  a
                 WHERE     d.Scd_Ndt IN (7)
                       AND d.Scd_St = '1'
                       AND Ah.Da2h_Dh = d.Scd_Dh
                       AND a.Da_Id = Ah.Da2h_Da
                       AND a.Da_Nda IN (810)
                       AND a.Da_Val_String = p_Identifier.Notation;
            WHEN '20'
            THEN
                --BirthCertificate--Свідоцтво про народження необхідно перевіряти на помилкові символи у серії
                SELECT Scd_Sc
                  BULK COLLECT INTO l_Sc_Id
                  FROM Uss_Person.v_Sc_Document d
                 WHERE     d.Scd_St = '1'
                       AND d.Scd_Ndt IN (37, 673)
                       AND REPLACE (
                               REPLACE (
                                   TRANSLATE (
                                       UPPER (d.Scd_Seria || d.Scd_Number),
                                       '1І',
                                       'II'),
                                   '-',
                                   ''),
                               ' ',
                               '') =
                           REPLACE (
                               REPLACE (
                                   TRANSLATE (UPPER (p_Identifier.Notation),
                                              '1І',
                                              'II'),
                                   '-',
                                   ''),
                               ' ',
                               '');
            ELSE
                --Шукаємо перекодування
                SELECT t.Nddc_Code_Src
                  BULK COLLECT INTO l_Ndt_List
                  FROM Uss_Ndi.v_Ndi_Decoding_Config t
                 WHERE     Nddc_Tp = 'SCHM'
                       AND Nddc_Src = 'USS'
                       AND Nddc_Dest = 'UXP'
                       AND t.Nddc_Code_Dest = p_Identifier.Scheme_Code
                       AND t.Nddc_Code_Src != '-1';

                --Якщо такого не існує, передаємо помилку
                IF l_Ndt_List.COUNT = 0
                THEN
                    l_Sc_Id (1) := c_Search_Error_Support;
                END IF;
        END CASE;

        --Покуш СРКО на основі перекодування
        IF l_Ndt_List.COUNT > 0
        THEN
            SELECT Scd_Sc
              BULK COLLECT INTO l_Sc_Id
              FROM Uss_Person.v_Sc_Document d
             WHERE     d.Scd_St = '1'
                   AND d.Scd_Ndt IN (SELECT * FROM TABLE (l_Ndt_List))
                   AND UPPER (
                           REPLACE (
                               REPLACE (d.Scd_Seria || d.Scd_Number, '-', ''),
                               ' ',
                               '')) =
                       UPPER (
                           REPLACE (REPLACE (p_Identifier.Notation, '-', ''),
                                    ' ',
                                    ''));
        END IF;

        --Особливість цієї функції, неможна щоб масив що повертається був пустий
        IF l_Sc_Id.COUNT = 0
        THEN
            l_Sc_Id (1) := c_Search_Error_Found;
        END IF;

        RETURN l_Sc_Id;
    END;

    /*
    info:    Пошук особи за посвідчуючим документом
    author:  kelatev
    request: #111332
    */
    FUNCTION Search_Sc (p_Identifier IN Ikis_Rbm.Api$uxp_Univ.r_Identifier)
        RETURN NUMBER
    IS
        l_Sc_List   OWA_UTIL.Num_Arr;
    BEGIN
        l_Sc_List := Search_By_Doc (p_Identifier => p_Identifier);

        IF l_Sc_List.COUNT > 1
        THEN
            RETURN c_Search_Error_Many;
        END IF;

        RETURN l_Sc_List (1);
    END;

    /*
    info:    Пошук особи за посвідчуючим документом
    author:  kelatev
    request: #111332
    */
    FUNCTION Search_Sc (
        p_Identifiers   IN Ikis_Rbm.Api$uxp_Univ.t_Identifiers,
        p_Pib           IN VARCHAR2,
        p_Birth_Dt      IN DATE)
        RETURN NUMBER
    IS
        l_Sc_Result   OWA_UTIL.Num_Arr;
    BEGIN
        FOR c IN (  SELECT Scheme_Code, Notation
                      FROM TABLE (p_Identifiers)
                  ORDER BY Scheme_Code)
        LOOP
            DECLARE
                l_Sc_List   OWA_UTIL.Num_Arr;
            BEGIN
                l_Sc_List :=
                    Search_By_Doc (
                        p_Identifier   =>
                            Ikis_Rbm.Api$uxp_Univ.r_Identifier (
                                Scheme_Code   => c.Scheme_Code,
                                Notation      => c.Notation));

                IF l_Sc_List.COUNT = 1
                THEN
                    --Якщо СРКО лише один та це не помилка, то закінчуємо пошук
                    IF l_Sc_List (1) > 0
                    THEN
                        RETURN l_Sc_List (1);
                    ELSE
                        --Якщо СРКО по даному ідентифікатору не знайдено переходимо до наступного
                        CONTINUE;
                    END IF;
                END IF;

                IF p_Pib IS NOT NULL AND p_Birth_Dt IS NOT NULL
                THEN
                    SELECT COLUMN_VALUE
                      BULK COLLECT INTO l_Sc_Result
                      FROM TABLE (l_Sc_List)
                     WHERE     (   NOT EXISTS
                                       (SELECT 1 FROM TABLE (l_Sc_Result))
                                OR COLUMN_VALUE IN
                                       (SELECT COLUMN_VALUE
                                          FROM TABLE (l_Sc_Result)))
                           AND EXISTS
                                   (SELECT 1
                                      FROM Uss_Person.Socialcard  Sc
                                           JOIN Uss_Person.Sc_Change Scc
                                               ON Scc.Scc_Id = Sc.Sc_Scc
                                           JOIN Uss_Person.Sc_Identity i
                                               ON i.Sci_Id = Scc.Scc_Sci
                                           JOIN Uss_Person.Sc_Birth b
                                               ON b.Scb_Id = Scc.Scc_Scb
                                     WHERE     Sc.Sc_Id = COLUMN_VALUE
                                           AND Sc.Sc_St IN ('1', '4')
                                           AND UTL_MATCH.Edit_Distance_Similarity (
                                                      i.Sci_Ln
                                                   || ' '
                                                   || i.Sci_Fn
                                                   || ' '
                                                   || i.Sci_Mn,
                                                   p_Pib) >=
                                               80
                                           AND b.Scb_Dt = p_Birth_Dt);
                ELSE
                    SELECT COLUMN_VALUE
                      BULK COLLECT INTO l_Sc_Result
                      FROM TABLE (l_Sc_List)
                     WHERE    NOT EXISTS (SELECT 1 FROM TABLE (l_Sc_Result))
                           OR COLUMN_VALUE IN
                                  (SELECT COLUMN_VALUE
                                     FROM TABLE (l_Sc_Result));
                END IF;

                IF l_Sc_Result.COUNT = 1
                THEN
                    RETURN l_Sc_Result (1);
                END IF;
            END;
        END LOOP;

        IF     l_Sc_Result.COUNT = 0
           AND p_Pib IS NOT NULL
           AND p_Birth_Dt IS NOT NULL
        THEN
            SELECT Sc.Sc_Id
              BULK COLLECT INTO l_Sc_Result
              FROM Uss_Person.Socialcard  Sc
                   JOIN Uss_Person.Sc_Change Scc ON Scc.Scc_Id = Sc.Sc_Scc
                   JOIN Uss_Person.Sc_Identity i ON i.Sci_Id = Scc.Scc_Sci
                   JOIN Uss_Person.Sc_Birth b ON b.Scb_Id = Scc.Scc_Scb
             WHERE     Sc.Sc_St IN ('1', '4')
                   AND UTL_MATCH.Edit_Distance_Similarity (
                           i.Sci_Ln || ' ' || i.Sci_Fn || ' ' || i.Sci_Mn,
                           p_Pib) >=
                       80
                   AND b.Scb_Dt = p_Birth_Dt;
        END IF;

        IF l_Sc_Result.COUNT = 0
        THEN
            RETURN c_Search_Error_Found;
        ELSIF l_Sc_Result.COUNT > 1
        THEN
            RETURN c_Search_Error_Many;
        END IF;

        RETURN l_Sc_Result (1);
    END;

    /*
    info:    Пошук особи за посвідчуючим документом
    author:  kelatev
    request: #111332
    */
    FUNCTION Search_Sc (p_Identifiers IN Ikis_Rbm.Api$uxp_Univ.t_Identifiers)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Search_Sc (p_Identifiers   => p_Identifiers,
                          p_Pib           => NULL,
                          p_Birth_Dt      => NULL);
    END;

    /*
    info:    Пошук особи її реквізитами
    author:  kelatev
    request: #111333
    */
    FUNCTION Search_Sc (p_Person IN Ikis_Rbm.Api$uxp_Univ.r_Person)
        RETURN NUMBER
    IS
    BEGIN
        RETURN Search_Sc (
                   p_Identifiers   => p_Person.Identifiers,
                   p_Pib           =>
                          p_Person.Family_Name
                       || ' '
                       || p_Person.Name_
                       || ' '
                       || p_Person.Patronymic_Name,
                   p_Birth_Dt      => p_Person.Birth_Date);
    END;
END Unload$socialcard;
/