/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.UNLOAD$BENEFIT
IS
    -- Author  : KELATEV
    -- Created : 12.11.2024 13:00:52
    -- Purpose :

    FUNCTION Handle_Check_Benefit_Doc_Request (p_Request_Id     IN NUMBER,
                                               p_Request_Body   IN CLOB)
        RETURN CLOB;

    FUNCTION Handle_Benefit_Category_Request (p_Request_Id     IN NUMBER,
                                              p_Request_Body   IN CLOB)
        RETURN CLOB;

    FUNCTION Handle_Check_Benefit_Category_Request (p_Request_Id     IN NUMBER,
                                                    p_Request_Body   IN CLOB)
        RETURN CLOB;
END Unload$benefit;
/


GRANT EXECUTE ON USS_PERSON.UNLOAD$BENEFIT TO IKIS_RBM
/

GRANT EXECUTE ON USS_PERSON.UNLOAD$BENEFIT TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:57:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.UNLOAD$BENEFIT
IS
    /*
    info:    Обробка запиту на Перевірка документу особи що пілтверджує категорію пільговика
    author:  kelatev
    request: #111331
    */
    FUNCTION Handle_Check_Benefit_Doc_Request (p_Request_Id     IN NUMBER,
                                               p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Response          XMLTYPE;
        l_Person_Xml        XMLTYPE;
        l_Document_Number   VARCHAR2 (4000);
        l_Person            Ikis_Rbm.Api$uxp_Univ.r_Person;

        l_Answer_Code       NUMBER := 1;
        l_Answer_Text       VARCHAR2 (32000)
                                := 'Документ знайдено у даної особи';
        l_Document_Name     VARCHAR2 (32000);
        l_Document_Cnt      NUMBER;
        l_Person2_Cnt       NUMBER;
        l_Person2_Sc        NUMBER;
        l_Person2           Ikis_Rbm.Api$uxp_Univ.r_Person;
    BEGIN
        BEGIN
                        SELECT Person, Document_Number
                          INTO l_Person_Xml, l_Document_Number
                          FROM XMLTABLE (
                                   '/*'
                                   PASSING Xmltype (p_Request_Body)
                                   COLUMNS Person             XMLTYPE PATH 'Person',
                                           Document_Number    VARCHAR2 (4000) PATH 'DocumentNumber');
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

        IF TRIM (l_Document_Number) IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Незаповнено поле "Серія та номер документу"';
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
        END IF;

        SELECT MAX (x_Sc),
               MAX (x_Ndt_Name),
               COUNT (DISTINCT x_Sc),
               COUNT (*)
          INTO l_Person2_Sc,
               l_Document_Name,
               l_Person2_Cnt,
               l_Document_Cnt
          FROM (  SELECT Sbc.Scbc_Sc AS x_Sc, Ndt.Ndt_Name AS x_Ndt_Name
                    FROM Uss_Person.Sc_Benefit_Category Sbc,
                         Uss_Person.Sc_Benefit_Docs    Sbd,
                         Uss_Person.Sc_Document        d,
                         Uss_Ndi.v_Ndi_Document_Type   Ndt
                   WHERE     Sbc.Scbc_St IN ('A', 'VO')
                         AND (   Sbc.Scbc_Start_Dt IS NULL
                              OR Sbc.Scbc_Start_Dt < SYSDATE)
                         AND (   Sbc.Scbc_Stop_Dt IS NULL
                              OR Sbc.Scbc_Stop_Dt > SYSDATE)
                         AND Sbd.Scbd_Scbc = Sbc.Scbc_Id
                         AND (Sbd.Scbd_St IN ('A', 'VO') OR Scbd_St IS NULL)
                         AND Sbd.Scbd_Scd = d.Scd_Id
                         AND d.Scd_St = '1'
                         AND d.Scd_Number = l_Document_Number
                         AND Ndt.Ndt_Id = d.Scd_Ndt
                GROUP BY Sbc.Scbc_Sc, d.Scd_Ndt, Ndt.Ndt_Name);

        IF l_Person2_Sc IS NULL
        THEN
            l_Answer_Code := 0;
            l_Answer_Text := 'Документ не знайдено';
            GOTO Resp;
        END IF;

        IF l_Person2_Cnt = 1 AND l_Document_Cnt > 1
        THEN
            l_Answer_Code := 3;
            l_Answer_Text :=
                'У даної особи знайдено два документа з однаковим номером';
            GOTO Resp;
        ELSIF l_Person2_Cnt > 1
        THEN
            l_Answer_Code := 4;
            l_Answer_Text := 'Документ знайдено у декількох осіб';
            GOTO Resp;
        END IF;

        SELECT i.Sci_Ln,
               i.Sci_Fn,
               i.Sci_Mn,
               b.Scb_Dt
          INTO l_Person2.Family_Name,
               l_Person2.Name_,
               l_Person2.Patronymic_Name,
               l_Person2.Birth_Date
          FROM Uss_Person.v_Socialcard  t
               JOIN Uss_Person.v_Sc_Change Ch ON Ch.Scc_Id = t.Sc_Scc
               JOIN Uss_Person.v_Sc_Identity i ON i.Sci_Id = Ch.Scc_Sci
               JOIN Uss_Person.v_Sc_Birth b ON b.Scb_Id = Ch.Scc_Scb
         WHERE t.Sc_Id = l_Person2_Sc;

        IF    UTL_MATCH.Edit_Distance_Similarity (
                     l_Person.Family_Name
                  || ' '
                  || l_Person.Name_
                  || ' '
                  || l_Person.Patronymic_Name,
                     l_Person2.Family_Name
                  || ' '
                  || l_Person2.Name_
                  || ' '
                  || l_Person2.Patronymic_Name) <
              80
           OR l_Person.Birth_Date != l_Person2.Birth_Date
        THEN
            l_Answer_Code := 2;
            l_Answer_Text := 'Документ знайдено але особа не співпала';
            GOTO Resp;
        END IF;

        l_Answer_Code := 1;
        l_Answer_Text := 'Документ знайдено у даної особи';

       <<resp>>
        SELECT XMLELEMENT (
                   "BenefitCheckDocResponse",
                   Ikis_Rbm.Api$uxp_Univ.Answer_Xml (
                       p_Code   => l_Answer_Code,
                       p_Text   => l_Answer_Text),
                   CASE
                       WHEN l_Answer_Code IN (1, 2)
                       THEN
                           XMLELEMENT ("DocumentName", l_Document_Name)
                   END,
                   CASE
                       WHEN l_Answer_Code IN (1, 2)
                       THEN
                           Ikis_Rbm.Api$uxp_Univ.Person_Xml (
                               p_Family_Name   => l_Person2.Family_Name,
                               p_Name          => l_Person2.Name_,
                               p_Patronymic_Name   =>
                                   l_Person2.Patronymic_Name,
                               p_Birth_Dt      => l_Person2.Birth_Date,
                               p_Gender        => NULL,
                               p_Identifiers   =>
                                   Unload$socialcard.Sc_Identifiers_Xml (
                                       l_Person2_Sc))
                   END)
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
    info:    Обробка запиту на Отримання пільгових категорій по особі
    author:  kelatev
    request: #111332
    */
    FUNCTION Handle_Benefit_Category_Request (p_Request_Id     IN NUMBER,
                                              p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Response         XMLTYPE;
        l_Identifier_Xml   XMLTYPE;
        l_Identifier       Ikis_Rbm.Api$uxp_Univ.r_Identifier;

        l_Sc_Id            NUMBER;
        l_Answer_Code      NUMBER;
        l_Answer_Text      VARCHAR2 (32000);
        l_Categoris_Xml    XMLTYPE;
    BEGIN
        BEGIN
                   SELECT Identifier
                     INTO l_Identifier_Xml
                     FROM XMLTABLE ('/*'
                                    PASSING Xmltype (p_Request_Body)
                                    COLUMNS Identifier    XMLTYPE PATH 'Identifier');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        IF l_Identifier_Xml IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Відсутній блок Identifier';
            GOTO Resp;
        END IF;

        l_Identifier :=
            Ikis_Rbm.Api$uxp_Univ.Parse_Identifier (l_Identifier_Xml);

        IF TRIM (l_Identifier.Scheme_Code) IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text :=
                'Незаповнено поле "Назва унікального ідентифікатора"';
            GOTO Resp;
        ELSIF TRIM (l_Identifier.Notation) IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Незаповнено поле "Унікальний ідентифікатор"';
            GOTO Resp;
        END IF;

        l_Sc_Id := Unload$socialcard.Search_Sc (p_Identifier => l_Identifier);

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

        SELECT XMLAGG (XMLELEMENT ("Category",
                                   XMLELEMENT ("Code", Nbc_Code),
                                   XMLELEMENT ("Text", Nbc_Name))
                       ORDER BY Nbc_Code DESC)
          INTO l_Categoris_Xml
          FROM (  SELECT Bc.Nbc_Code, Bc.Nbc_Name
                    FROM Uss_Person.Sc_Benefit_Category Sbc,
                         Uss_Ndi.v_Ndi_Benefit_Category Bc
                   WHERE     Sbc.Scbc_St IN ('A', 'VO')
                         AND (   Sbc.Scbc_Start_Dt IS NULL
                              OR Sbc.Scbc_Start_Dt < SYSDATE)
                         AND (   Sbc.Scbc_Stop_Dt IS NULL
                              OR Sbc.Scbc_Stop_Dt > SYSDATE)
                         AND Sbc.Scbc_Sc = l_Sc_Id
                         AND Bc.Nbc_Id = Sbc.Scbc_Nbc
                         AND Bc.History_Status = 'A'
                GROUP BY Bc.Nbc_Code, Bc.Nbc_Name);

        IF l_Categoris_Xml IS NULL
        THEN
            l_Answer_Code := 4;
            l_Answer_Text :=
                'Особу знайдено, але пільгові категорії відсутні';
            GOTO Resp;
        END IF;

        l_Answer_Code := 1;
        l_Answer_Text := 'Особу та пільгові категорії знайдено';

       <<resp>>
        SELECT XMLELEMENT (
                   "BenefitCategoryListResponse",
                   Ikis_Rbm.Api$uxp_Univ.Answer_Xml (
                       p_Code   => l_Answer_Code,
                       p_Text   => l_Answer_Text),
                   CASE
                       WHEN l_Categoris_Xml IS NOT NULL
                       THEN
                           XMLELEMENT ("Categories", l_Categoris_Xml)
                   END)
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
    info:    Обробка запиту на Перевірка пільгової категорії по особі
    author:  kelatev
    request: #111332
    */
    FUNCTION Handle_Check_Benefit_Category_Request (p_Request_Id     IN NUMBER,
                                                    p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Response         XMLTYPE;
        l_Identifier_Xml   XMLTYPE;
        l_Category_Code    VARCHAR2 (4000);
        l_Identifier       Ikis_Rbm.Api$uxp_Univ.r_Identifier;

        l_Sc_Id            NUMBER;
        l_Answer_Code      NUMBER;
        l_Answer_Text      VARCHAR2 (32000);
        l_Category         VARCHAR2 (255);
    BEGIN
        BEGIN
                      SELECT Identifier, Category_Code
                        INTO l_Identifier_Xml, l_Category_Code
                        FROM XMLTABLE (
                                 '/*'
                                 PASSING Xmltype (p_Request_Body)
                                 COLUMNS Identifier       XMLTYPE PATH 'Identifier',
                                         Category_Code    VARCHAR2 (4000) PATH 'Category/Code');
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_Application_Error (
                    -20000,
                    'Помилка парсингу запиту: ' || SQLERRM);
        END;

        IF l_Identifier_Xml IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Відсутній блок Identifier';
            GOTO Resp;
        END IF;

        l_Identifier :=
            Ikis_Rbm.Api$uxp_Univ.Parse_Identifier (l_Identifier_Xml);

        IF TRIM (l_Identifier.Scheme_Code) IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text :=
                'Незаповнено поле "Назва унікального ідентифікатора"';
            GOTO Resp;
        ELSIF TRIM (l_Identifier.Notation) IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Незаповнено поле "Унікальний ідентифікатор"';
            GOTO Resp;
        ELSIF TRIM (l_Category_Code) IS NULL
        THEN
            l_Answer_Code := 10;
            l_Answer_Text := 'Незаповнено поле "Код пільгової категорії"';
            GOTO Resp;
        END IF;

        l_Sc_Id := Unload$socialcard.Search_Sc (p_Identifier => l_Identifier);

        IF l_Sc_Id = Unload$socialcard.c_Search_Error_Found
        THEN
            l_Answer_Code := 1;
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
            l_Answer_Code := 4;
            l_Answer_Text := 'Не вдалося однозначно ідентифікувати особу';
            GOTO Resp;
        END IF;

        SELECT MAX (Nbc_Code)
          INTO l_Category
          FROM Uss_Person.Sc_Benefit_Category  Sbc,
               Uss_Ndi.v_Ndi_Benefit_Category  Bc
         WHERE     Sbc.Scbc_St IN ('A', 'VO')
               AND (Sbc.Scbc_Start_Dt IS NULL OR Sbc.Scbc_Start_Dt < SYSDATE)
               AND (Sbc.Scbc_Stop_Dt IS NULL OR Sbc.Scbc_Stop_Dt > SYSDATE)
               AND Sbc.Scbc_Sc = l_Sc_Id
               AND Bc.Nbc_Id = Sbc.Scbc_Nbc
               AND Bc.History_Status = 'A'
               AND Bc.Nbc_Code = TRIM (l_Category_Code);

        IF l_Category IS NULL
        THEN
            l_Answer_Code := 3;
            l_Answer_Text :=
                'Запис з категорію та ідентифікатором не знайдено';
            GOTO Resp;
        END IF;

        l_Answer_Code := 0;
        l_Answer_Text := 'Запис з категорію та ідентифікатором знайдено';

       <<resp>>
        SELECT XMLELEMENT (
                   "BenefitCheckCategoryResponse",
                   Ikis_Rbm.Api$uxp_Univ.Answer_Xml (
                       p_Code   => l_Answer_Code,
                       p_Text   => l_Answer_Text))
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
END Unload$benefit;
/