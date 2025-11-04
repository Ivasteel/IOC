/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$UXP_UNIV
IS
    -- Author  : SHOSTAK
    -- Created : 16.08.2024 11:12:58
    -- Purpose : Універсальні контаркти та хелпери для стандартизованих обмінів

    Pkg   CONSTANT VARCHAR2 (50) := 'API$UXP_UNIV';

    --Жлкумент що посвідчує особу
    TYPE r_Identifier IS RECORD
    (
        Issued         DATE,                                     --Дата видачі
        Creator        VARCHAR2 (4000),                         --Орган видачі
        Scheme_Code    VARCHAR2 (200),                         --Тип документа
        Notation       VARCHAR2 (50)                --Серія та номер документа
    );

    TYPE t_Identifiers IS TABLE OF r_Identifier;

    TYPE r_Person IS RECORD
    (
        Family_Name        VARCHAR2 (200),
        Name_              VARCHAR2 (200),
        Patronymic_Name    VARCHAR2 (200),
        Birth_Date         DATE,
        Gender             VARCHAR2 (200),
        Identifiers        t_Identifiers
    );

    /*
    info:    Екранування JSON
    author:  sho
    */
    FUNCTION Jescp (p_Val IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE Add_Jval (p_Json_Obj      IN OUT NOCOPY CLOB,
                        p_Key           IN            VARCHAR2,
                        p_Val           IN            VARCHAR2,
                        p_Format_Json   IN            BOOLEAN DEFAULT FALSE);

    PROCEDURE Add_Jobj (p_Json_Array IN OUT NOCOPY CLOB, p_Json_Obj IN CLOB);

    /*
    info:    Парсинг реквізитів особи
    author:  sho
    request: #106637
    */
    FUNCTION Parse_Person (p_Person XMLTYPE)
        RETURN r_Person;

    /*
    info:    Формування XML з реквізитами особи
    author:  sho
    request: #106637
    */
    FUNCTION Person_Xml (p_Family_Name       IN VARCHAR2,
                         p_Name              IN VARCHAR2,
                         p_Patronymic_Name   IN VARCHAR2,
                         p_Birth_Dt          IN DATE,
                         p_Gender            IN VARCHAR2,
                         p_Identifiers       IN XMLTYPE)
        RETURN XMLTYPE;

    /*
    info:    Формування JSON з реквізитами особи
    author:  sho
    request: #106637
    */
    FUNCTION Person_Json (p_Family_Name       IN VARCHAR2,
                          p_Name              IN VARCHAR2,
                          p_Patronymic_Name   IN VARCHAR2,
                          p_Birth_Dt          IN DATE,
                          p_Gender            IN VARCHAR2,
                          p_Identifiers       IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Parse_Identifier (p_Identifier XMLTYPE)
        RETURN r_Identifier;

    FUNCTION Parse_Identifiers (p_Identifiers XMLTYPE)
        RETURN t_Identifiers;

    /*
    info:    Формування XML документа
    author:  sho
    request: #106637
    */
    FUNCTION Identifier_Xml (p_Issued        IN DATE,  --Дата видачі документа
                             p_Creator       IN VARCHAR2, --Орган видачі документа
                             p_Scheme_Code   IN VARCHAR2,      --Тип документа
                             p_Notation      IN VARCHAR2     --Номер документа
                                                        )
        RETURN XMLTYPE;

    /*
    info:    Формування JSON документа
    author:  sho
    request: #106637
    */
    FUNCTION Identifier_Json (p_Scheme_Code   IN VARCHAR2,     --Тип документа
                              p_Notation      IN VARCHAR2    --Номер документа
                                                         )
        RETURN VARCHAR2;

    /*
    info:    Формування JSON документа
    author:  sho
    request: #106637
    */
    FUNCTION Identifier_Ext_Json (p_Issued        IN DATE, --Дата видачі документа
                                  p_Creator       IN VARCHAR2, --Орган видачі документа
                                  p_Scheme_Code   IN VARCHAR2, --Тип документа
                                  p_Notation      IN VARCHAR2 --Номер документа
                                                             )
        RETURN VARCHAR2;

    /*
    info:    Формування відповіді
    author:  sho
    request: #106637
    */
    FUNCTION Answer_Xml (p_Code IN NUMBER, p_Text IN VARCHAR2)
        RETURN XMLTYPE;

    /*
    info:    Формування адреси XML
    author:  kelatev
    request: #111333
    */
    FUNCTION Domicile_Xml (p_Address_Id     IN VARCHAR2, --Глобальний ідентифікатор адреси за ЄДРА
                           p_Full_Address   IN VARCHAR2         --Повна адреса
                                                       )
        RETURN XMLTYPE;

    /*
    info:    Формування адреси XML
    author:  kelatev
    request: #111333
    */
    FUNCTION Domicile_Json (p_Address_Id     IN VARCHAR2, --Глобальний ідентифікатор адреси за ЄДРА
                            p_Full_Address   IN VARCHAR2        --Повна адреса
                                                        )
        RETURN VARCHAR2;
END Api$uxp_Univ;
/


GRANT EXECUTE ON IKIS_RBM.API$UXP_UNIV TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_UNIV TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_UNIV TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_UNIV TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$UXP_UNIV
IS
    /*
    info:    Екранування JSON
    author:  sho
    */
    FUNCTION Jescp (p_Val IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN REPLACE (
                   REPLACE (REPLACE (REPLACE (p_Val, '\', '\\'), '"', '\"'),
                            CHR (13),
                            '\r'),
                   CHR (10),
                   '\n');
    END;

    PROCEDURE Add_Jobj (p_Json_Array IN OUT NOCOPY CLOB, p_Json_Obj IN CLOB)
    IS
    BEGIN
        p_Json_Array :=
            p_Json_Array || ',' || '{' || LTRIM (p_Json_Obj, ',') || '}';
    END;

    PROCEDURE Add_Jval (p_Json_Obj      IN OUT NOCOPY CLOB,
                        p_Key           IN            VARCHAR2,
                        p_Val           IN            VARCHAR2,
                        p_Format_Json   IN            BOOLEAN DEFAULT FALSE)
    IS
    BEGIN
        IF p_Format_Json
        THEN
            p_Json_Obj := p_Json_Obj || ',"' || p_Key || '":' || p_Val || '';
        ELSE
            p_Json_Obj :=
                p_Json_Obj || ',"' || p_Key || '":"' || Jescp (p_Val) || '"';
        END IF;
    END;

    /*
    info:    Парсинг реквізитів особи
    author:  sho
    request: #106637
    */
    FUNCTION Parse_Person (p_Person XMLTYPE)
        RETURN r_Person
    IS
        l_Person       r_Person;
        l_Identifier   XMLTYPE;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (
                             Pkg,
                             'R_PERSON',
                             p_Date_Fmt   => 'YYYY-MM-DD"T"hh24:mi:ss',
                             p_Version    => '2025-02-18 11:04')
            USING IN p_Person.Getclobval, OUT l_Person;

        RETURN l_Person;
    END;

    /*
    info:    Формування XML з реквізитами особи
    author:  sho
    request: #106637
    */
    FUNCTION Person_Xml (p_Family_Name       IN VARCHAR2,
                         p_Name              IN VARCHAR2,
                         p_Patronymic_Name   IN VARCHAR2,
                         p_Birth_Dt          IN DATE,
                         p_Gender            IN VARCHAR2,
                         p_Identifiers       IN XMLTYPE)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLELEMENT (
                   "Person",
                   XMLELEMENT ("FamilyName", p_Family_Name),
                   XMLELEMENT ("Name", p_Name),
                   XMLELEMENT ("PatronymicName", p_Patronymic_Name),
                   CASE
                       WHEN p_Birth_Dt IS NOT NULL
                       THEN
                           XMLELEMENT ("BirthDate",
                                       TO_CHAR (p_Birth_Dt, 'YYYY-MM-DD'))
                   END,
                   CASE
                       WHEN p_Identifiers IS NOT NULL
                       THEN
                           XMLELEMENT ("Gender", p_Gender)
                   END,
                   CASE
                       WHEN p_Identifiers IS NOT NULL
                       THEN
                           XMLELEMENT ("Identifiers", p_Identifiers)
                   END)
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;

    /*
    info:    Формування JSON з реквізитами особи
    author:  sho
    request: #106637
    */
    FUNCTION Person_Json (p_Family_Name       IN VARCHAR2,
                          p_Name              IN VARCHAR2,
                          p_Patronymic_Name   IN VARCHAR2,
                          p_Birth_Dt          IN DATE,
                          p_Gender            IN VARCHAR2,
                          p_Identifiers       IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (32767);
    BEGIN
        SELECT Json_Object (
                   'FamilyName' VALUE p_Family_Name,
                   'Name' VALUE p_Name,
                   'PatronymicName' VALUE p_Patronymic_Name,
                   'BirthDate' VALUE TO_CHAR (p_Birth_Dt, 'YYYY-MM-DD'),
                   'Gender' VALUE p_Gender,
                   'Identifiers' VALUE NVL (p_Identifiers, '[]') FORMAT JSON)
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;

    /*
    info:    Парсинг реквізитів ідентифікатора
    author:  kelatev
    request: #111332
    */
    FUNCTION Parse_Identifier (p_Identifier XMLTYPE)
        RETURN r_Identifier
    IS
        l_Identifier   r_Identifier;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (
                             Pkg,
                             'R_IDENTIFIER',
                             p_Date_Fmt   => 'YYYY-MM-DD"T"hh24:mi:ss',
                             p_Version    => '2025-02-18 11:04')
            USING IN p_Identifier.Getclobval, OUT l_Identifier;

        RETURN l_Identifier;
    END;

    /*
    info:    Парсинг реквізитів ідентифікатора
    author:  kelatev
    request: #111332
    */
    FUNCTION Parse_Identifiers (p_Identifiers XMLTYPE)
        RETURN t_Identifiers
    IS
        l_Identifiers   t_Identifiers;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (
                             Pkg,
                             'T_IDENTIFIERS',
                             p_Date_Fmt   => 'YYYY-MM-DD"T"hh24:mi:ss',
                             p_Version    => '2025-02-18 11:04')
            USING IN p_Identifiers.Getclobval, OUT l_Identifiers;

        RETURN l_Identifiers;
    END;

    /*
    info:    Формування XML документа
    author:  sho
    request: #106637
    */
    FUNCTION Identifier_Xml (p_Issued        IN DATE,  --Дата видачі документа
                             p_Creator       IN VARCHAR2, --Орган видачі документа
                             p_Scheme_Code   IN VARCHAR2,      --Тип документа
                             p_Notation      IN VARCHAR2     --Номер документа
                                                        )
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLELEMENT (
                   "Identifier",
                   CASE
                       WHEN p_Issued IS NOT NULL
                       THEN
                           XMLELEMENT ("Issued",
                                       TO_CHAR (p_Issued, 'YYYY-MM-DD'))
                   END,
                   XMLELEMENT ("Creator", p_Creator),
                   XMLELEMENT ("SchemeCode", p_Scheme_Code),
                   XMLELEMENT ("Notation", p_Notation))
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;

    /*
    info:    Формування JSON документа
    author:  sho
    request: #106637
    */
    FUNCTION Identifier_Json (p_Scheme_Code   IN VARCHAR2,     --Тип документа
                              p_Notation      IN VARCHAR2    --Номер документа
                                                         )
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (32767);
    BEGIN
        SELECT Json_Object ('SchemeCode' VALUE p_Scheme_Code,
                            'Notation' VALUE p_Notation)
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;

    /*
    info:    Формування JSON документа
    author:  sho
    request: #106637
    */
    FUNCTION Identifier_Ext_Json (p_Issued        IN DATE, --Дата видачі документа
                                  p_Creator       IN VARCHAR2, --Орган видачі документа
                                  p_Scheme_Code   IN VARCHAR2, --Тип документа
                                  p_Notation      IN VARCHAR2 --Номер документа
                                                             )
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (32767);
    BEGIN
        SELECT Json_Object ('Issued' VALUE TO_CHAR (p_Issued, 'YYYY-MM-DD'),
                            'Creator' VALUE p_Creator,
                            'SchemeCode' VALUE p_Scheme_Code,
                            'Notation' VALUE p_Notation)
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;

    /*
    info:    Формування відповіді
    author:  sho
    request: #106637
    */
    FUNCTION Answer_Xml (p_Code IN NUMBER, p_Text IN VARCHAR2)
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLELEMENT ("Answer",
                           XMLELEMENT ("Code", p_Code),
                           XMLELEMENT ("Text", p_Text))
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;


    /*
    info:    Формування адреси XML
    author:  kelatev
    request: #111333
    */
    FUNCTION Domicile_Xml (p_Address_Id     IN VARCHAR2, --Глобальний ідентифікатор адреси за ЄДРА
                           p_Full_Address   IN VARCHAR2         --Повна адреса
                                                       )
        RETURN XMLTYPE
    IS
        l_Result   XMLTYPE;
    BEGIN
        SELECT XMLELEMENT (
                   "Domicile",
                   CASE
                       WHEN p_Address_Id IS NOT NULL
                       THEN
                           XMLELEMENT ("AddressId", p_Address_Id)
                   END,
                   XMLELEMENT ("FullAddress", p_Full_Address))
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;

    /*
    info:    Формування адреси XML
    author:  kelatev
    request: #111333
    */
    FUNCTION Domicile_Json (p_Address_Id     IN VARCHAR2, --Глобальний ідентифікатор адреси за ЄДРА
                            p_Full_Address   IN VARCHAR2        --Повна адреса
                                                        )
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (32767);
    BEGIN
        SELECT Json_Object ('AddressId' VALUE p_Address_Id,
                            'FullAddress' VALUE p_Full_Address)
          INTO l_Result
          FROM DUAL;

        RETURN l_Result;
    END;
END Api$uxp_Univ;
/