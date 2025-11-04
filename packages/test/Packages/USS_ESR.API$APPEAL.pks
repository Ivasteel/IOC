/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$APPEAL
IS
    -- Author  : VANO
    -- Created : 08.12.2021 10:55:46
    -- Purpose : Функції роботи зі зверненнями в ЄСР

    --Отримання текстового параметру документу по учаснику
    FUNCTION Get_Doc_String (p_App       Ap_Document.Apd_App%TYPE,
                             p_Ndt       Ap_Document.Apd_Ndt%TYPE,
                             p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                             p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --Отримання параметру Дата з документу по учаснику
    FUNCTION Get_Doc_Dt (p_App   Ap_Document.Apd_App%TYPE,
                         p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                         p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE;

    --Отримання параметру Дата ( мінімальна ) з документу по зверненню
    FUNCTION get_doc_dt_min (p_Ap    Ap_Document.Apd_Ap%TYPE,
                             p_App   Ap_Document.Apd_App%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN DATE;

    --Отримання параметру Дата ( мінімальна ) з документу по зверненню
    FUNCTION get_doc_dt_max (p_Ap    Ap_Document.Apd_Ap%TYPE,
                             p_App   Ap_Document.Apd_App%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN DATE;

    FUNCTION Get_Doc_Sum (p_App   Ap_Document.Apd_App%TYPE,
                          p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                          p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN Ap_Document_Attr.Apda_Val_Sum%TYPE;

    --Отримання параметру Ціле з документу по учаснику
    FUNCTION Get_Doc_Int (p_App   Ap_Document.Apd_App%TYPE,
                          p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                          p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN Ap_Document_Attr.Apda_Val_Int%TYPE;

    --Отримання параметру Ід з документу по учаснику
    FUNCTION Get_Doc_Id (p_App   Ap_Document.Apd_App%TYPE,
                         p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                         p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN Ap_Document_Attr.Apda_Val_Id%TYPE;

    --Отримання кількості документів по переліку через кому
    FUNCTION Get_Doc_List_Cnt (p_App        Ap_Person.App_Id%TYPE,
                               p_List_Ndt   VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_Ap_Doc_Str (p_Ap_Id     IN NUMBER,
                             p_App_Tp    IN VARCHAR2,
                             p_Nda_Id    IN NUMBER,
                             p_Default      VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Doc_dt (p_Ap_Id     IN NUMBER,
                            p_App_Tp    IN VARCHAR2,
                            p_Nda_Id    IN NUMBER,
                            p_Default      DATE DEFAULT NULL)
        RETURN DATE;

    FUNCTION Get_App_Doc_dt (p_Ap_Id       IN NUMBER,
                             p_App_Id      IN NUMBER,
                             p_Nda_CLASS   IN VARCHAR2,
                             p_Default        DATE DEFAULT NULL)
        RETURN DATE;

    FUNCTION Get_Ap_Doc_Str (p_Ap_Id IN NUMBER, p_Nda_Class IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Attr_Str (p_Ap_Id     IN NUMBER,
                              p_Nda_Id    IN NUMBER,
                              p_Default      VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Attr_Id (p_Ap_Id     IN NUMBER,
                             p_Nda_Id    IN NUMBER,
                             p_Default      NUMBER DEFAULT NULL)
        RETURN NUMBER;

    FUNCTION Get_Ap_Doc_Id (p_Ap_Id    IN NUMBER,
                            p_App_Tp   IN VARCHAR2,
                            p_Nda_Id   IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Doc_Id (p_Ap_Id IN NUMBER, p_Nda_Class IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_All_Ap_Doc_Id (p_Ap_Id    IN NUMBER,
                                p_Ndt_Id   IN NUMBER,
                                p_Nda_Id   IN NUMBER)
        RETURN VARCHAR2;

    --Отримання кількості документів по переліку через кому
    FUNCTION Get_Ap_Doc_List_Cnt (p_Ap_Id      Ap_Person.App_Id%TYPE,
                                  p_List_Ndt   VARCHAR2)
        RETURN NUMBER;

    --Отримання текстового параметру документу по Заявнику
    FUNCTION Get_Ap_z_Doc_String (p_Ap    Ap_Document.Apd_Ap%TYPE,
                                  p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                                  p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_z_Doc_Id (p_Ap    Ap_Document.Apd_Ap%TYPE,
                              p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                              p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER;

    --Отримання текстового параметру документу по Отримувачу допомоги
    FUNCTION Get_Ap_o_Doc_String (p_Ap    Ap_Document.Apd_Ap%TYPE,
                                  p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                                  p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2;

    --Отримання параметру суми з документу по Отримувачу допомоги
    FUNCTION Get_Ap_o_Doc_Sum (p_Ap    Ap_Document.Apd_Ap%TYPE,
                               p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                               p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN Ap_Document_Attr.Apda_Val_Sum%TYPE;

    --Отримання параметру дати з документу по Отримувачу допомоги
    FUNCTION Get_Ap_o_Doc_Dt (p_Ap    Ap_Document.Apd_Ap%TYPE,
                              p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                              p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE;

    --Отримання параметру ID-у з документу по Отримувачу допомоги
    FUNCTION Get_Ap_o_Doc_Id (p_Ap    Ap_Document.Apd_Ap%TYPE,
                              p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                              p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DECIMAL;

    FUNCTION Get_Attr_Val_String (p_Apd_Id      IN Ap_Document.Apd_Id%TYPE,
                                  p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Attr_801_ChkQty (p_Ap_Id       IN APPEAL.AP_ID%TYPE,
                                  p_Ap_Src      IN APPEAL.AP_SRC%TYPE,
                                  p_Ap_ServTo   IN VARCHAR2,
                                  p_Rel_Tp      IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_Attr_801_ChkQty (p_Ap_Id       IN APPEAL.AP_ID%TYPE,
                                  p_Ap_ServTo   IN VARCHAR2,
                                  p_Rel_Tp      IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Is_Apd_Exists (p_Apd_Ap IN NUMBER, p_Apd_Ndt_List IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_Init_Apd (p_Apd_Ap IN NUMBER, p_Apd_Ndt_List IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Is_Aps_Exists (p_Aps_Ap IN NUMBER, p_Aps_Nst_List IN VARCHAR2)
        RETURN NUMBER;

    --
    --Перевірка корректності створення звернення:
    --1 - якщо не має жодного F у вказанних атрибутах
    --
    FUNCTION Is_Appeal_Maked_Correct (p_Ap_Id IN NUMBER)
        RETURN NUMBER;


    FUNCTION Is_Person_Address_Equal (
        p_App_One_Id   IN AP_PERSON.APP_ID%TYPE,
        p_App_Two_Id   IN AP_PERSON.APP_ID%TYPE)
        RETURN NUMBER;

    --Повернення Звернення на довведення
    PROCEDURE Return_Appeal_To_Editing (
        p_Ap_Id    Appeal.Ap_Id%TYPE,
        p_Reason   Ap_Log.Apl_Message%TYPE:= NULL);

    PROCEDURE Move_Appeal_To_Status (p_Ap_Id   Appeal.Ap_Id%TYPE,
                                     p_Ap_St   Appeal.Ap_St%TYPE);

    --Переводимо звернення в стан 'WD' = Опрацювання рішення, якщо хоча б одне рішення створене
    PROCEDURE Mark_Appeal_Working (p_Mode                 INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                   p_Check_Doc_Mode       INTEGER, --1=чи є рішення по зверненню, 2=чи є відрахування по зверненню
                                   p_Ap_Id                Appeal.Ap_Id%TYPE,
                                   p_Updated_Cnt      OUT INTEGER);

    FUNCTION GET_ISNEED_INCOME (P_AP_ID NUMBER)
        RETURN NUMBER;

    PROCEDURE Delete_Acts_By_Ap (p_Ap_Id IN NUMBER);

    --=============================================================
    --  Копіювання документів з ЄСР в СРКО
    --=============================================================
    PROCEDURE Copy_Document2Socialcard (p_ap            appeal.ap_id%TYPE,
                                        p_vf_not_null   NUMBER DEFAULT 1);
END Api$appeal;
/


/* Formatted on 8/12/2025 5:48:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$APPEAL
IS
    --Отримання текстового параметру документу по учаснику
    FUNCTION Get_Doc_String (p_App       Ap_Document.Apd_App%TYPE,
                             p_Ndt       Ap_Document.Apd_Ndt%TYPE,
                             p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                             p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (Apda_Val_String)
          INTO l_Rez
          FROM Ap_Document, Ap_Document_Attr
         WHERE     Apda_Apd = Apd_Id
               AND Ap_Document.History_Status = 'A'
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apd_App = p_App
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Rez, p_Default);
        END IF;

        RETURN l_Rez;
    END;

    --Отримання параметру Дата з документу по учаснику
    FUNCTION Get_Doc_Dt (p_App   Ap_Document.Apd_App%TYPE,
                         p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                         p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE
    IS
        l_Rez   DATE;
    BEGIN
        SELECT MAX (Apda_Val_Dt)
          INTO l_Rez
          FROM Ap_Document, Ap_Document_Attr
         WHERE     Apda_Apd = Apd_Id
               AND Ap_Document.History_Status = 'A'
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apd_App = p_App
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    --Отримання параметру Дата ( мінімальна ) з документу по зверненню
    FUNCTION get_doc_dt_min (p_Ap    Ap_Document.Apd_Ap%TYPE,
                             p_App   Ap_Document.Apd_App%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        IF p_App IS NOT NULL
        THEN
            SELECT MIN (Apda_Val_Dt)
              INTO l_Rez
              FROM Ap_Document
                   JOIN Ap_Document_Attr
                       ON     Apda_Apd = Apd_Id
                          AND Ap_Document_Attr.History_Status = 'A'
             WHERE     Ap_Document.History_Status = 'A'
                   AND Apd_Ap = p_Ap
                   AND Apd_App = p_App
                   AND Apd_Ndt = p_Ndt
                   AND Apda_Nda = p_Nda;
        ELSE
            SELECT MIN (Apda_Val_Dt)
              INTO l_Rez
              FROM Ap_Document
                   JOIN Ap_Document_Attr
                       ON     Apda_Apd = Apd_Id
                          AND Ap_Document_Attr.History_Status = 'A'
             WHERE     Ap_Document.History_Status = 'A'
                   AND Apd_Ap = p_Ap
                   AND Apd_Ndt = p_Ndt
                   AND Apda_Nda = p_Nda;
        END IF;

        RETURN l_rez;
    END;

    --Отримання параметру Дата ( мінімальна ) з документу по зверненню
    FUNCTION get_doc_dt_max (p_Ap    Ap_Document.Apd_Ap%TYPE,
                             p_App   Ap_Document.Apd_App%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        IF p_App IS NOT NULL
        THEN
            SELECT MAX (Apda_Val_Dt)
              INTO l_Rez
              FROM Ap_Document
                   JOIN Ap_Document_Attr
                       ON     Apda_Apd = Apd_Id
                          AND Ap_Document_Attr.History_Status = 'A'
             WHERE     Ap_Document.History_Status = 'A'
                   AND Apd_Ap = p_Ap
                   AND Apd_App = p_App
                   AND Apd_Ndt = p_Ndt
                   AND Apda_Nda = p_Nda;
        ELSE
            SELECT MAX (Apda_Val_Dt)
              INTO l_Rez
              FROM Ap_Document
                   JOIN Ap_Document_Attr
                       ON     Apda_Apd = Apd_Id
                          AND Ap_Document_Attr.History_Status = 'A'
             WHERE     Ap_Document.History_Status = 'A'
                   AND Apd_Ap = p_Ap
                   AND Apd_Ndt = p_Ndt
                   AND Apda_Nda = p_Nda;
        END IF;

        RETURN l_rez;
    END;

    --Отримання параметру Дата з документу по учаснику
    FUNCTION Get_Doc_Sum (p_App   Ap_Document.Apd_App%TYPE,
                          p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                          p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN Ap_Document_Attr.Apda_Val_Sum%TYPE
    IS
        l_Rez   Ap_Document_Attr.Apda_Val_Sum%TYPE;
    BEGIN
        SELECT MAX (Apda_Val_Sum)
          INTO l_Rez
          FROM Ap_Document, Ap_Document_Attr
         WHERE     Apda_Apd = Apd_Id
               AND Ap_Document.History_Status = 'A'
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apd_App = p_App
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    --Отримання параметру Ціле з документу по учаснику
    FUNCTION Get_Doc_Int (p_App   Ap_Document.Apd_App%TYPE,
                          p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                          p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN Ap_Document_Attr.Apda_Val_Int%TYPE
    IS
        l_Rez   Ap_Document_Attr.Apda_Val_Int%TYPE;
    BEGIN
        SELECT MAX (Apda_Val_Int)
          INTO l_Rez
          FROM Ap_Document, Ap_Document_Attr
         WHERE     Apda_Apd = Apd_Id
               AND Ap_Document.History_Status = 'A'
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apd_App = p_App
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    --Отримання параметру Ід з документу по учаснику
    FUNCTION Get_Doc_Id (p_App   Ap_Document.Apd_App%TYPE,
                         p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                         p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN Ap_Document_Attr.Apda_Val_Id%TYPE
    IS
        l_Rez   Ap_Document_Attr.Apda_Val_Id%TYPE;
    BEGIN
        SELECT MAX (Apda_Val_Id)
          INTO l_Rez
          FROM Ap_Document, Ap_Document_Attr
         WHERE     Apda_Apd = Apd_Id
               AND Ap_Document.History_Status = 'A'
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apd_App = p_App
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    --Отримання кількості документів по переліку через кому
    FUNCTION Get_Doc_List_Cnt (p_App        Ap_Person.App_Id%TYPE,
                               p_List_Ndt   VARCHAR2)
        RETURN NUMBER
    IS
        l_Rez   NUMBER (10);
    BEGIN
        WITH
            Ndt_List
            AS
                (    SELECT REGEXP_SUBSTR (p_List_Ndt,
                                           '[^,]+',
                                           1,
                                           LEVEL)    AS i_Ndt
                       FROM DUAL
                 CONNECT BY LEVEL <=
                            LENGTH (REGEXP_REPLACE (p_List_Ndt, '[^,]*')) + 1)
        SELECT COUNT (1)
          INTO l_Rez
          FROM Ap_Document JOIN Ndt_List ON Apd_Ndt = i_Ndt
         WHERE Apd_App = p_App AND Ap_Document.History_Status = 'A';

        RETURN l_Rez;
    END;

    FUNCTION Is_Apd_Exists (p_Apd_Ap IN NUMBER, p_Apd_Ndt_List IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Apd_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Apd_Exists
          FROM Ap_Document d
         WHERE     d.Apd_Ap = p_Apd_Ap
               AND d.Apd_Ndt IN
                       (SELECT TO_NUMBER (COLUMN_VALUE)
                          FROM XMLTABLE (p_Apd_Ndt_List))
               AND d.History_Status = 'A';

        RETURN l_Apd_Exists;
    END;

    FUNCTION Get_Init_Apd (p_Apd_Ap IN NUMBER, p_Apd_Ndt_List IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Apd_Ndt   NUMBER;
    BEGIN
        SELECT d.Apd_Ndt
          INTO l_Apd_Ndt
          FROM Ap_Document d
         WHERE     d.Apd_Ap = p_Apd_Ap
               AND d.Apd_Ndt IN
                       (SELECT TO_NUMBER (COLUMN_VALUE)
                          FROM XMLTABLE (p_Apd_Ndt_List))
               AND d.History_Status = 'A';

        RETURN l_Apd_Ndt;
    END;

    FUNCTION Is_Aps_Exists (p_Aps_Ap IN NUMBER, p_Aps_Nst_List IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Aps_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Aps_Exists
          FROM Ap_Service d
         WHERE     d.Aps_Ap = p_Aps_Ap
               AND d.Aps_Nst IN
                       (SELECT TO_NUMBER (COLUMN_VALUE)
                          FROM XMLTABLE (p_Aps_Nst_List))
               AND d.History_Status = 'A';

        RETURN l_Aps_Exists;
    END;

    FUNCTION Get_Ap_Doc_Str (p_Ap_Id     IN NUMBER,
                             p_App_Tp    IN VARCHAR2,
                             p_Nda_Id    IN NUMBER,
                             p_Default      VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Document_Attr.Apda_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON a.Apda_Apd = d.Apd_Id AND d.History_Status = 'A'
               JOIN Ap_Person p
                   ON     d.Apd_App = p.App_Id
                      AND p.History_Status = 'A'
                      AND p.App_Tp = p_App_Tp
         WHERE     a.Apda_Ap = p_Ap_Id
               AND a.Apda_Nda = p_Nda_Id
               AND a.History_Status = 'A';

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Result, p_Default);
        END IF;

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Doc_dt (p_Ap_Id     IN NUMBER,
                            p_App_Tp    IN VARCHAR2,
                            p_Nda_Id    IN NUMBER,
                            p_Default      DATE DEFAULT NULL)
        RETURN DATE
    IS
        l_Result   Ap_Document_Attr.Apda_Val_Dt%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_dt)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON a.Apda_Apd = d.Apd_Id AND d.History_Status = 'A'
               JOIN Ap_Person p
                   ON     d.Apd_App = p.App_Id
                      AND p.History_Status = 'A'
                      AND p.App_Tp = p_App_Tp
         WHERE     a.Apda_Ap = p_Ap_Id
               AND a.Apda_Nda = p_Nda_Id
               AND a.History_Status = 'A';

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Result, p_Default);
        END IF;

        RETURN l_Result;
    END;

    FUNCTION Get_App_Doc_dt (p_Ap_Id       IN NUMBER,
                             p_App_Id      IN NUMBER,
                             p_Nda_CLASS   IN VARCHAR2,
                             p_Default        DATE DEFAULT NULL)
        RETURN DATE
    IS
        l_Result   Ap_Document_Attr.Apda_Val_Dt%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_dt)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON a.Apda_Apd = d.Apd_Id AND d.History_Status = 'A'
               JOIN Ap_Person p
                   ON     d.Apd_App = p.App_Id
                      AND p.History_Status = 'A'
                      AND p.App_Id = p_App_Id
               JOIN uss_ndi.v_ndi_document_attr da ON a.apda_nda = da.nda_id
         WHERE     a.Apda_Ap = p_Ap_Id
               AND da.nda_class = 'BDT'
               AND a.History_Status = 'A';

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Result, p_Default);
        END IF;

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Doc_Str (p_Ap_Id IN NUMBER, p_Nda_Class IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Document_Attr.Apda_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON a.Apda_Apd = d.Apd_Id AND d.History_Status = 'A'
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE a.Apda_Ap = p_Ap_Id AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Attr_Str (p_Ap_Id     IN NUMBER,
                              p_Nda_Id    IN NUMBER,
                              p_Default      VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Document_Attr.Apda_Val_String%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document_Attr a
         WHERE     a.Apda_Ap = p_Ap_Id
               AND a.Apda_Nda = p_Nda_Id
               AND a.History_Status = 'A';

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Result, p_Default);
        END IF;

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Attr_Id (p_Ap_Id     IN NUMBER,
                             p_Nda_Id    IN NUMBER,
                             p_Default      NUMBER DEFAULT NULL)
        RETURN NUMBER
    IS
        l_Result   Ap_Document_Attr.Apda_Val_Id%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_Id)
          INTO l_Result
          FROM Ap_Document_Attr a
         WHERE     a.Apda_Ap = p_Ap_Id
               AND a.Apda_Nda = p_Nda_Id
               AND a.History_Status = 'A';

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Result, p_Default);
        END IF;

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Doc_Id (p_Ap_Id    IN NUMBER,
                            p_App_Tp   IN VARCHAR2,
                            p_Nda_Id   IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Document_Attr.Apda_Val_Id%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_Id)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON a.Apda_Apd = d.Apd_Id AND d.History_Status = 'A'
               JOIN Ap_Person p
                   ON     d.Apd_App = p.App_Id
                      AND p.History_Status = 'A'
                      AND p.App_Tp = p_App_Tp
         WHERE     a.Apda_Ap = p_Ap_Id
               AND a.Apda_Nda = p_Nda_Id
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_Ap_Doc_Id (p_Ap_Id IN NUMBER, p_Nda_Class IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Document_Attr.Apda_Val_Id%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_Id)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON a.Apda_Apd = d.Apd_Id AND d.History_Status = 'A'
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE a.Apda_Ap = p_Ap_Id AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    FUNCTION Get_All_Ap_Doc_Id (p_Ap_Id    IN NUMBER,
                                p_Ndt_Id   IN NUMBER,
                                p_Nda_Id   IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Ap_Document_Attr.Apda_Val_Id%TYPE;
    BEGIN
        SELECT MAX (a.Apda_Val_Id)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d
                   ON a.Apda_Apd = d.Apd_Id AND d.History_Status = 'A'
         WHERE     a.Apda_Ap = p_Ap_Id
               AND a.Apda_Nda = p_Nda_Id
               AND d.apd_ndt = p_Ndt_Id
               AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    --Отримання кількості документів по переліку через кому
    FUNCTION Get_Ap_Doc_List_Cnt (p_Ap_Id      Ap_Person.App_Id%TYPE,
                                  p_List_Ndt   VARCHAR2)
        RETURN NUMBER
    IS
        l_Rez   NUMBER (10);
    BEGIN
        WITH
            Ndt_List
            AS
                (    SELECT REGEXP_SUBSTR (p_List_Ndt,
                                           '[^,]+',
                                           1,
                                           LEVEL)    AS i_Ndt
                       FROM DUAL
                 CONNECT BY LEVEL <=
                            LENGTH (REGEXP_REPLACE (p_List_Ndt, '[^,]*')) + 1)
        SELECT COUNT (1)
          INTO l_Rez
          FROM Ap_Document JOIN Ndt_List ON Apd_Ndt = i_Ndt
         WHERE Apd_Ap = p_Ap_Id AND Ap_Document.History_Status = 'A';

        RETURN l_Rez;
    END;

    --Отримання текстового параметру документу по Заявнику
    FUNCTION Get_Ap_z_Doc_String (p_Ap    Ap_Document.Apd_Ap%TYPE,
                                  p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                                  p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (Apda_Val_String)
          INTO l_Rez
          FROM Ap_Person, Ap_Document, Ap_Document_Attr
         WHERE     Ap_Person.History_Status = 'A'
               AND Ap_Document.History_Status = 'A'
               AND Apd_App = App_Id
               AND Apda_Apd = Apd_Id
               AND App_Tp = 'Z'
               AND App_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    FUNCTION Get_Ap_z_Doc_Id (p_Ap    Ap_Document.Apd_Ap%TYPE,
                              p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                              p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER
    IS
        l_Rez   NUMBER;
    BEGIN
        SELECT MAX (Apda_Val_Id)
          INTO l_Rez
          FROM Ap_Person, Ap_Document, Ap_Document_Attr
         WHERE     Ap_Person.History_Status = 'A'
               AND Ap_Document.History_Status = 'A'
               AND Apd_App = App_Id
               AND Apda_Apd = Apd_Id
               AND App_Tp = 'Z'
               AND App_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    --Отримання текстового параметру документу по Отримувачу допомоги
    FUNCTION Get_Ap_o_Doc_String (p_Ap    Ap_Document.Apd_Ap%TYPE,
                                  p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                                  p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (Apda_Val_String)
          INTO l_Rez
          FROM Ap_Person, Ap_Document, Ap_Document_Attr
         WHERE     Ap_Person.History_Status = 'A'
               AND Ap_Document.History_Status = 'A'
               AND Apd_App = App_Id
               AND Apda_Apd = Apd_Id
               AND App_Tp = 'O'
               AND App_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    --Отримання параметру суми з документу по Отримувачу допомоги
    FUNCTION Get_Ap_o_Doc_Sum (p_Ap    Ap_Document.Apd_Ap%TYPE,
                               p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                               p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN Ap_Document_Attr.Apda_Val_Sum%TYPE
    IS
        l_Rez   Ap_Document_Attr.Apda_Val_Sum%TYPE;
    BEGIN
        SELECT MAX (Apda_Val_Sum)
          INTO l_Rez
          FROM Ap_Person, Ap_Document, Ap_Document_Attr
         WHERE     Ap_Person.History_Status = 'A'
               AND Ap_Document.History_Status = 'A'
               AND Apd_App = App_Id
               AND Apda_Apd = Apd_Id
               AND App_Tp = 'O'
               AND App_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;


    --Отримання параметру ID-у з документу по Отримувачу допомоги
    FUNCTION Get_Ap_o_Doc_Id (p_Ap    Ap_Document.Apd_Ap%TYPE,
                              p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                              p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DECIMAL
    IS
        l_Rez   DECIMAL;
    BEGIN
        SELECT MAX (Apda_Val_Id)
          INTO l_Rez
          FROM Ap_Person, Ap_Document, Ap_Document_Attr
         WHERE     Ap_Person.History_Status = 'A'
               AND Ap_Document.History_Status = 'A'
               AND Apd_App = App_Id
               AND Apda_Apd = Apd_Id
               AND App_Tp = 'O'
               AND App_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    --Отримання параметру суми з документу по Отримувачу допомоги
    FUNCTION Get_Ap_o_Doc_Dt (p_Ap    Ap_Document.Apd_Ap%TYPE,
                              p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                              p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE
    IS
        l_Rez   DATE;
    BEGIN
        SELECT MAX (Apda_Val_Dt)
          INTO l_Rez
          FROM Ap_Person, Ap_Document, Ap_Document_Attr
         WHERE     Ap_Person.History_Status = 'A'
               AND Ap_Document.History_Status = 'A'
               AND Apd_App = App_Id
               AND Apda_Apd = Apd_Id
               AND App_Tp = 'O'
               AND App_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    --Отримання текстового атрибуту документа
    FUNCTION Get_Attr_Val_String (p_Apd_Id      IN Ap_Document.Apd_Id%TYPE,
                                  p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (500);
    BEGIN
        SELECT MAX (a.Apda_Val_String)
          INTO l_Result
          FROM Ap_Document_Attr  a
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = p_Nda_Class
         WHERE a.Apda_Apd = p_Apd_Id AND a.History_Status = 'A';

        RETURN l_Result;
    END;

    --
    --Перевірка корректності створення звернення:
    --1 - якщо не має жодного F у вказанних атрибутах
    --
    FUNCTION Is_Appeal_Maked_Correct (p_Ap_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Res
          FROM appeal ap
         WHERE ap.ap_id = p_Ap_Id AND ap.ap_tp = 'SS';

        IF l_Res = 0
        THEN
            RETURN 1;
        END IF;

        SELECT SIGN (COUNT (1))
          INTO l_Res
          FROM Ap_Document  Apd
               JOIN Ap_Document_Attr Apda ON Apd.Apd_Id = Apda.Apda_Apd
         WHERE     Apda.Apda_Nda IN (8415,
                                     8416,
                                     8417,
                                     8418,
                                     8419)
               AND Apd.Apd_Ap = p_Ap_Id
               AND Apda.Apda_Val_String = 'F'
               AND apd.history_status = 'A'
               AND Apda.history_status = 'A';

        RETURN CASE WHEN l_Res = 0 THEN 1 ELSE 0 END;
    END;

    FUNCTION Get_Attr_801_ChkQty (p_Ap_Id       IN APPEAL.AP_ID%TYPE,
                                  p_Ap_Src      IN APPEAL.AP_SRC%TYPE,
                                  p_Ap_ServTo   IN VARCHAR2,
                                  p_Rel_Tp      IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT COUNT (1)     ChkQty
          INTO l_Res
          FROM Ap_Document  d
               JOIN Appeal ap ON Ap.Ap_Id = d.apd_ap AND AP.Ap_Src = p_Ap_Src
               JOIN Ap_Document_Attr atr
                   ON     atr.apda_apd = d.Apd_id
                      AND atr.apda_nda IN (1868)
                      AND atr.History_Status = 'A'
                      AND atr.apda_val_string = p_Ap_ServTo
               JOIN Ap_Document_Attr atr2
                   ON     atr2.apda_apd = d.Apd_id
                      AND atr2.apda_nda IN (1895)
                      AND atr2.History_Status = 'A'
                      AND atr2.apda_val_string = p_Rel_Tp
         WHERE 1 = 1 AND ap.ap_id = p_Ap_Id;

        RETURN l_Res;
    END;


    FUNCTION Get_Attr_801_ChkQty (p_Ap_Id       IN APPEAL.AP_ID%TYPE,
                                  p_Ap_ServTo   IN VARCHAR2,
                                  p_Rel_Tp      IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT COUNT (1)     ChkQty
          INTO l_Res
          FROM Ap_Document  d
               JOIN Appeal ap ON Ap.Ap_Id = d.apd_ap
               JOIN Ap_Document_Attr atr
                   ON     atr.apda_apd = d.Apd_id
                      AND atr.apda_nda IN (1868)
                      AND atr.History_Status = 'A'
                      AND atr.apda_val_string = p_Ap_ServTo
               JOIN Ap_Document_Attr atr2
                   ON     atr2.apda_apd = d.Apd_id
                      AND atr2.apda_nda IN (1895)
                      AND atr2.History_Status = 'A'
                      AND atr2.apda_val_string = p_Rel_Tp
         WHERE 1 = 1 AND ap.ap_id = p_Ap_Id;

        RETURN l_Res;
    END;

    FUNCTION Is_Person_Address_Equal (
        p_App_One_Id   IN AP_PERSON.APP_ID%TYPE,
        p_App_Two_Id   IN AP_PERSON.APP_ID%TYPE)
        RETURN NUMBER
    IS
        l_qty   NUMBER;
    BEGIN
        --#108335
        SELECT CASE WHEN COUNT (1) = 0 THEN 0 ELSE MIN (is_equal) END
          INTO l_qty
          FROM (SELECT CASE
                           WHEN a1.is_1632_exists = 1 AND a1.apda_nda = 1640
                           THEN
                               0
                           WHEN    (NVL (a1.apda_val_string, '1') =
                                    NVL (a2.apda_val_string, '2'))
                                OR (NVL (a1.apda_val_id, 1) =
                                    NVL (a2.apda_val_id, 2))
                           THEN
                               1
                           ELSE
                               0
                       END    is_equal
                  FROM uss_Ndi.v_Ndi_Document_Attr  a
                       LEFT JOIN
                       (SELECT apda_nda,
                               apda_val_id,
                               apda_val_string,
                               NVL (
                                   MAX (CASE WHEN apda_nda = 1632 THEN 1 END)
                                       OVER (),
                                   0)    is_1632_exists
                          FROM ap_document_attr  apda
                               JOIN ap_document apd
                                   ON apda.apda_apd = apd.apd_id
                         WHERE     apda_nda IN (1618,
                                                1625,
                                                1632,
                                                1640,
                                                1648,
                                                1654,
                                                1659)
                               AND apd.apd_app = p_App_One_Id
                               AND apda.history_status = 'A'
                               AND apd.history_status = 'A'
                               AND (   apda.apda_val_id IS NOT NULL
                                    OR apda.apda_val_string IS NOT NULL)) a1
                           ON a.nda_id = a1.apda_nda
                       LEFT JOIN
                       (SELECT apda_nda,
                               apda_val_id,
                               apda_val_string,
                               NVL (
                                   MAX (CASE WHEN apda_nda = 1632 THEN 1 END)
                                       OVER (),
                                   0)    is_1632_exists
                          FROM ap_document_attr  apda
                               JOIN ap_document apd
                                   ON apda.apda_apd = apd.apd_id
                         WHERE     apda_nda IN (1618,
                                                1625,
                                                1632,
                                                1640,
                                                1648,
                                                1654,
                                                1659)
                               AND apd.apd_app = p_App_Two_Id
                               AND apda.history_status = 'A'
                               AND apd.history_status = 'A'
                               AND (   apda.apda_val_id IS NOT NULL
                                    OR apda.apda_val_string IS NOT NULL)) a2
                           ON a.nda_id = a2.apda_nda
                 WHERE     nda_id IN (1618,
                                      1625,
                                      1632,
                                      1640,
                                      1648,
                                      1654,
                                      1659)
                       AND (   a1.apda_nda IS NOT NULL
                            OR a2.apda_nda IS NOT NULL));

        RETURN l_qty;
    END;

    --Повернення Звернення на довведення
    PROCEDURE Return_Appeal_To_Editing (
        p_Ap_Id    Appeal.Ap_Id%TYPE,
        p_Reason   Ap_Log.Apl_Message%TYPE:= NULL)
    IS
        l_St_Old      Appeal.Ap_St%TYPE;
        l_Old_State   Appeal%ROWTYPE;
        l_ps_cnt      INTEGER;
    BEGIN
        --  raise_application_error(-20000, p_ap_id);
        SELECT t.*
          INTO l_Old_State
          FROM Appeal t
         WHERE Ap_Id = p_Ap_Id;

        IF l_Old_State.Ap_Src = 'PORTAL'
        THEN
            --#100823
            UPDATE Appeal
               SET Ap_St = 'X'
             WHERE Ap_Id = p_Ap_Id;
        ELSE
            UPDATE Appeal
               SET Ap_St = 'P'
             WHERE Ap_Id = p_Ap_Id;
        END IF;

        SELECT COUNT (*)
          INTO l_ps_cnt
          FROM pc_state_alimony, appeal, ap_service
         WHERE     ps_ap = ap_id
               AND ap_tp = 'V'
               AND aps_ap = ap_id
               AND history_Status = 'A'
               AND aps_nst = 248
               AND ap_id = p_ap_id;

        IF l_Old_State.Ap_Tp = 'U' OR l_ps_cnt > 0
        THEN
            Api$pc_State_Alimony.Return_Ps (p_Ap_Id);
        END IF;

        Api$esr_Action.Preparecopy_Esr2visit (p_Ap_Id,
                                              l_Old_State.Ap_St,
                                              p_Reason);
    END;

    PROCEDURE Move_Appeal_To_Status (p_Ap_Id   Appeal.Ap_Id%TYPE,
                                     p_Ap_St   Appeal.Ap_St%TYPE)
    IS
        l_Ap    Appeal%ROWTYPE;
        l_msg   VARCHAR2 (500);
    BEGIN
        SELECT *
          INTO l_Ap
          FROM Appeal
         WHERE ap_id = p_ap_id;

        UPDATE Appeal
           SET Ap_St = p_Ap_St
         WHERE Ap_Id = p_Ap_Id;

        IF p_Ap_St = 'V'
        THEN
            l_msg := CHR (38) || '153#%';
        END IF;

        Api$esr_Action.Preparecopy_Esr2visit (p_Ap_Id, l_ap.Ap_St, l_msg);
    END;

    --Переводимо звернення в стан 'WD' = Опрацювання рішення, якщо хоча б одне рішення створене
    PROCEDURE Mark_Appeal_Working (p_Mode                 INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                   p_Check_Doc_Mode       INTEGER, --1=чи є рішення по зверненню, 2=чи є відрахування по зверненню, 3=чи є держутримання по зверненню, 4=чи є рішення про припинення допомог, 5=чи є рішення про припинення СП
                                   p_Ap_Id                Appeal.Ap_Id%TYPE,
                                   p_Updated_Cnt      OUT INTEGER)
    IS
        l_Cnt   INTEGER := 0;
    BEGIN
        IF p_Mode = 1 AND p_Ap_Id IS NOT NULL
        THEN
            DELETE FROM Tmp_Work_Ids
                  WHERE 1 = 1;

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT Ap_Id
                  FROM Appeal
                 WHERE Ap_Id = p_Ap_Id AND Ap_St IN ('O');

            l_Cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_Cnt
              FROM Tmp_Work_Ids, Appeal
             WHERE x_Id = Ap_Id AND Ap_St IN ('O');
        END IF;

        IF l_Cnt > 0
        THEN
            --Переводимо звернення в стан 'WD' = Опрацювання рішення, якщо хоча б одне рішення створене
            IF p_Check_Doc_Mode = 1
            THEN
                UPDATE Appeal
                   SET Ap_St = 'WD'
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM Tmp_Work_Ids
                                 WHERE x_Id = Ap_Id)
                       AND EXISTS
                               (SELECT 1
                                  FROM Pc_Decision
                                 WHERE     pd_st != 'W'
                                       AND (   Pd_Ap = Ap_Id
                                            OR Pd_Ap_Reason = Ap_Id)); --#78670 2022.07.20

                p_Updated_Cnt := SQL%ROWCOUNT;
            ELSIF p_Check_Doc_Mode = 2
            THEN
                UPDATE Appeal
                   SET Ap_St = 'WD'
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM Tmp_Work_Ids
                                 WHERE x_Id = Ap_Id)
                       AND EXISTS
                               (SELECT 1
                                  FROM Deduction
                                 WHERE Dn_Ap = Ap_Id);

                p_Updated_Cnt := SQL%ROWCOUNT;
            ELSIF p_Check_Doc_Mode = 3
            THEN
                UPDATE Appeal
                   SET Ap_St = 'WD'
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM Tmp_Work_Ids
                                 WHERE x_Id = Ap_Id)
                       --#74858 2022.01.21
                       AND (   EXISTS
                                   (SELECT 1
                                      FROM Pc_State_Alimony
                                     WHERE Ps_Ap = Ap_Id)
                            OR EXISTS
                                   (SELECT *
                                      FROM Pc_State_Alimony
                                           JOIN Ps_Changes
                                               ON     Psc_Ps = Ps_Id
                                                  AND Psc_Ap = Ap_Id
                                                  AND History_Status = 'A'));

                p_Updated_Cnt := SQL%ROWCOUNT;
            ELSIF p_Check_Doc_Mode = 4
            THEN
                UPDATE Appeal
                   SET Ap_St = 'WD'
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM Tmp_Work_Ids
                                 WHERE x_Id = Ap_Id)
                       AND EXISTS
                               (SELECT 1
                                  FROM Act
                                 WHERE At_Ap = Ap_Id AND At_Tp = 'RSTOPV');

                p_Updated_Cnt := SQL%ROWCOUNT;
            ELSIF p_Check_Doc_Mode = 5
            THEN
                UPDATE Appeal
                   SET Ap_St = 'WD'
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM Tmp_Work_Ids
                                 WHERE x_Id = Ap_Id)
                       AND EXISTS
                               (SELECT 1
                                  FROM Act
                                 WHERE At_Ap = Ap_Id AND At_Tp = 'RSTOPSS');

                p_Updated_Cnt := SQL%ROWCOUNT;
            ELSIF p_Check_Doc_Mode = 6
            THEN
                UPDATE Appeal ap
                   SET Ap_St = 'WD'
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM Tmp_Work_Ids
                                 WHERE x_Id = Ap_Id)
                       --# 89468 2024.01.19 Зміна статуса тільки якщо всі послуги із звернення є в рішеннях
                       AND (EXISTS
                                (SELECT 1
                                   FROM Act at
                                  WHERE     At_Ap = Ap_Id
                                        AND At_Tp IN ('PDSP',
                                                      'RSTOPSS',
                                                      'APOP',
                                                      'OKS',
                                                      'ANPOE')--AND (SELECT count(1)
                                                              --     FROM (SELECT aps_nst FROM ap_service aps WHERE aps.aps_ap = ap.ap_id AND aps.history_status = 'A'
                                                              --           MINUS
                                                              --           SELECT ats_nst FROM at_service ats WHERE ats.ats_at = at.at_id AND ats.history_status = 'A') ) = 0
                                                              --#97519 2024.01.25 - Для RSTOPSS не копіюються послуги
                                                              ));

                p_Updated_Cnt := SQL%ROWCOUNT;
            ELSE
                p_Updated_Cnt := 0;
            END IF;
        ELSE
            p_Updated_Cnt := 0;
        END IF;
    END;


    -- #82497 2022.12.28: Блокування кнопки «Розрахунок доходу» для рішень про СП
    FUNCTION GET_ISNEED_INCOME (P_AP_ID NUMBER)
        RETURN NUMBER
    IS
        L_AP_TP   VARCHAR2 (10);
        L_REZ     NUMBER (10);
    BEGIN
        SELECT AP_TP
          INTO L_AP_TP
          FROM APPEAL
         WHERE AP_ID = P_AP_ID;

        IF L_AP_TP != 'SS'
        THEN
            L_REZ := 1;
        ELSE
            SELECT COUNT (1)
              INTO L_REZ
              FROM AP_PERSON
                   JOIN AP_DOCUMENT
                       ON (    APD_APP = APP_ID
                           AND APD_NDT IN (801, 802, 803)
                           AND AP_DOCUMENT.HISTORY_STATUS = 'A')
                   JOIN AP_DOCUMENT_ATTR
                       ON (    APDA_APD = APD_ID
                           AND APDA_NDA IN (1871, 1948, 2528)
                           AND AP_DOCUMENT_ATTR.HISTORY_STATUS = 'A')
             WHERE     APP_AP = P_AP_ID
                   AND AP_PERSON.HISTORY_STATUS = 'A'
                   AND NVL (APDA_VAL_STRING, 'F') = 'T';
        END IF;

        RETURN SIGN (L_REZ);
    END;

    PROCEDURE Delete_Acts_By_Ap (p_Ap_Id IN NUMBER)
    IS
    BEGIN
        DELETE FROM at_other_spec atop
              WHERE atop.atop_at IN (SELECT at_id
                                       FROM act
                                      WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_income_src atis
              WHERE atis.ais_at IN (SELECT at_id
                                      FROM act
                                     WHERE at_ap IN (p_Ap_Id));

        DELETE FROM AT_INCOME_LOG
              WHERE ail_aid IN
                        (SELECT aid_id
                           FROM at_income_detail
                          WHERE aid_aic IN
                                    (SELECT aic_id
                                       FROM at_income_calc
                                      WHERE aic_at IN
                                                (SELECT at_id
                                                   FROM act
                                                  WHERE at_ap IN (p_Ap_Id))));

        DELETE FROM at_income_detail
              WHERE aid_aic IN (SELECT aic_id
                                  FROM at_income_calc
                                 WHERE aic_at IN (SELECT at_id
                                                    FROM act
                                                   WHERE at_ap IN (p_Ap_Id)));

        DELETE FROM at_income_calc atic
              WHERE atic.aic_at IN (SELECT at_id
                                      FROM act
                                     WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_section_feature atsf
              WHERE atsf.atef_at IN (SELECT at_id
                                       FROM act
                                      WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_section ats
              WHERE ats.ate_at IN (SELECT at_id
                                     FROM act
                                    WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_links lnk
              WHERE lnk.atk_at IN (SELECT at_id
                                     FROM act
                                    WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_links lnk
              WHERE lnk.atk_link_at IN (SELECT at_id
                                          FROM act
                                         WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_reject_info
              WHERE ari_at IN (SELECT at_id
                                 FROM act
                                WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_right_log
              WHERE arl_at IN (SELECT at_id
                                 FROM act
                                WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_service
              WHERE ats_at IN (SELECT at_id
                                 FROM act
                                WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_signers
              WHERE ati_at IN (SELECT at_id
                                 FROM act
                                WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_document_attr atr
              WHERE atda_at IN (SELECT at_id
                                  FROM act
                                 WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_document
              WHERE atd_at IN (SELECT at_id
                                 FROM act
                                WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_features
              WHERE atf_at IN (SELECT at_id
                                 FROM act
                                WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_person p
              WHERE atp_at IN (SELECT at_id
                                 FROM act
                                WHERE at_ap IN (p_Ap_Id));

        DELETE FROM at_log l
              WHERE atl_at IN (SELECT at_id
                                 FROM act
                                WHERE at_ap IN (p_Ap_Id));

        DELETE FROM EVA_LOG
              WHERE eval_eva IN
                        (SELECT eva_id
                           FROM ESR2VISIT_ACTIONS
                          WHERE eva_at IN (SELECT at_id
                                             FROM act
                                            WHERE at_ap IN (p_Ap_Id)));

        DELETE FROM ESR2VISIT_ACTIONS
              WHERE eva_at IN (SELECT at_id
                                 FROM act
                                WHERE at_ap IN (p_Ap_Id));

        UPDATE act a
           SET at_main_link = NULL, at_main_link_tp = NULL
         WHERE EXISTS
                   (SELECT 1
                      FROM act a1
                     WHERE     a.at_main_link = a1.at_id
                           AND a1.at_ap IN (p_Ap_Id));

        DELETE FROM act a
              WHERE at_ap IN (p_Ap_Id);
    END;


    --=============================================================
    --  Копіювання документів з ЄСР в СРКО
    --=============================================================
    PROCEDURE Copy_Document2Socialcard (p_ap            appeal.ap_id%TYPE,
                                        p_vf_not_null   NUMBER DEFAULT 1)
    IS
        l_Doc_Attrs   Uss_Person.Api$socialcard.t_Doc_Attrs;
        l_Scd_Id      NUMBER;

        ------------------------------
        CURSOR document IS
            SELECT *
              FROM (SELECT d.Apd_Id,
                           d.Apd_Doc,
                           d.Apd_Dh,
                           d.Apd_Ndt,
                           d.apd_vf,
                           p.App_Sc,
                           t.ndt_name_short,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY d.Apd_App,
                                                t.Ndt_Ndc,
                                                NVL (t.Ndt_Uniq_Group,
                                                     t.Ndt_Id)
                                   ORDER BY t.Ndt_Order)    AS Rn
                      FROM Uss_Esr.Ap_Document  d
                           JOIN Uss_Esr.Ap_Person p
                               ON     d.Apd_App = p.App_Id
                                  AND p.History_Status = 'A'
                           JOIN Uss_Ndi.v_Ndi_Document_Type t
                               ON     d.Apd_Ndt = t.Ndt_Id
                                  AND t.Ndt_Copy_Esr_Signed = 'T'
                     WHERE     d.Apd_Ap = p_Ap
                           AND EXISTS
                                   (SELECT 1
                                      FROM Uss_Esr.Ap_Document_Attr  apda
                                           JOIN
                                           Uss_Ndi.v_ndi_document_attr nda
                                               ON     nda.nda_id =
                                                      apda.apda_nda
                                                  AND nda.nda_class IN
                                                          ('DSN')
                                     WHERE     apda.apda_apd = d.apd_id
                                           AND apda.apda_val_string
                                                   IS NOT NULL
                                           AND apda.history_status = 'A')
                           AND d.History_Status = 'A')
             WHERE Rn = 1 AND (apd_vf IS NOT NULL OR p_vf_not_null = 0);
    ------------------------------
    BEGIN
        FOR Rec IN document
        LOOP
            SELECT a.Apda_Nda,
                   a.Apda_Val_String,
                   a.Apda_Val_Dt,
                   a.Apda_Val_Int,
                   a.Apda_Val_Id
              BULK COLLECT INTO l_Doc_Attrs
              FROM Uss_Esr.Ap_Document_Attr a
             WHERE a.Apda_Apd = rec.apd_id AND a.History_Status = 'A';

            Uss_Person.Api$socialcard.Save_Document (
                p_Sc_Id         => Rec.App_Sc,
                p_Ndt_Id        => Rec.Apd_Ndt,
                p_Doc_Attrs     => l_Doc_Attrs,
                p_Src_Id        => '37',
                p_Src_Code      => 'ESR',
                p_Scd_Note      =>
                    'Створено із звернення громадянина з системи ЄІССС: ЄСР',
                p_Scd_Id        => l_Scd_Id,
                p_Doc_Id        => Rec.Apd_Doc,
                p_Dh_Id         => Rec.Apd_Dh,
                p_Set_Feature   => TRUE                       --TODO: уточнить
                                       );

            Uss_Person.Api$socialcard.Init_Sc_Info (p_Sc_Id => Rec.App_Sc);
        END LOOP;
    END;
--=============================================================
END Api$appeal;
/