/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$VALIDATION
IS
    -- Author  : SHOSTAK
    -- Created : 01.06.2022 1:37:33 PM
    -- Purpose :

    TYPE t_Aps_List IS TABLE OF BOOLEAN
        INDEX BY PLS_INTEGER;

    Package_Name   CONSTANT VARCHAR2 (100) := 'API$VALIDATION';

    TYPE r_Message IS RECORD
    (
        Msg_Tp         VARCHAR2 (10),
        Msg_Tp_Name    VARCHAR2 (20),
        Msg_Text       VARCHAR2 (4000)
    );

    TYPE t_Messages IS TABLE OF r_Message;

    g_Messages              t_Messages;

    g_Is_Output             BOOLEAN := FALSE;


    TYPE t_Arr IS TABLE OF NUMBER;

    TYPE Type_Rec_Information IS RECORD
    (
        App_Id                 NUMBER (14),
        App_Ap                 NUMBER (14),
        App_Sc                 NUMBER (14),
        App_Tp                 VARCHAR2 (20),
        Disabilitychild        VARCHAR2 (20),          --Дитина з інвалідністю
        Disabilityfromchild    VARCHAR2 (20), --Особа з інвалідністю з дитинства
        Guardian               VARCHAR2 (20),                         --опікун
        Trustee                VARCHAR2 (20),                   --піклувальник
        Adopter                VARCHAR2 (20),                    --Усиновлювач
        Parents                VARCHAR2 (20),                    --Мати/батько
        Representativeinst     VARCHAR2 (20), --Представник закладу, де особа з інвалідністю перебуває на держутриманні
        Parentseducator        VARCHAR2 (20),     --Один з батьків-вихователів
        Cnt_o                  NUMBER (14),
        Cnt_Du                 NUMBER (14)
    );

    TYPE Table_Information IS TABLE OF Type_Rec_Information;

    g_Information           Table_Information := Table_Information ();

    FUNCTION F_AP_ID
        RETURN NUMBER;

    FUNCTION F_AP_TP
        RETURN VARCHAR2;

    FUNCTION F_AP_SRC
        RETURN VARCHAR2;

    PROCEDURE Init (p_Ap_Id IN Appeal.Ap_Id%TYPE);

    PROCEDURE Init (p_Ap_Id                IN Appeal.Ap_Id%TYPE,
                    p_Warnings             IN BOOLEAN,
                    p_Raise_Fatal_Err      IN BOOLEAN,
                    p_Err_On_Missing_Doc   IN BOOLEAN DEFAULT TRUE,
                    p_Error_To_Warning     IN BOOLEAN DEFAULT FALSE);

    PROCEDURE Add_Message (p_Msg_Text      IN VARCHAR2,
                           p_Msg_Tp        IN VARCHAR2,
                           p_Msg_Tp_Name   IN VARCHAR2);

    PROCEDURE Add_Warning (p_Msg_Text IN VARCHAR2);

    PROCEDURE Add_Error (p_Msg_Text IN VARCHAR2);

    PROCEDURE Add_Fatal (p_Msg_Text IN VARCHAR2);

    FUNCTION Aps_Exists (p_Aps_Nst IN NUMBER)
        RETURN NUMBER;

    FUNCTION Only_One_Aps_Exists (p_Aps_Nst IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Only_One_Aps_Exists_n (p_Aps_Nst IN NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Doc_String (p_App       Ap_Document.Apd_App%TYPE,
                             p_Ndt       Ap_Document.Apd_Ndt%TYPE,
                             p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                             p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Doc_Dt (p_Ap    Ap_Document.Apd_Ap%TYPE,
                            p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                            p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE;

    FUNCTION Get_Ap_Doc_String (p_Ap    Ap_Document.Apd_Ap%TYPE,
                                p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                                p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Doc_String (p_Ap    Ap_Document.Apd_Ap%TYPE,
                                p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Doc_Scan (p_Ap    Ap_Document.Apd_Ap%TYPE,
                              p_Ndt   Ap_Document.Apd_Ndt%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Apd_Doc_Scan (p_Apd Ap_Document.Apd_id%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Doc_Id (p_App   Ap_Document.Apd_App%TYPE,
                         p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                         p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Doc_Dt (p_App   Ap_Document.Apd_App%TYPE,
                         p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                         p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE;

    --==============================================================--
    --  Отримання текстового параметру документу по id документа
    --==============================================================--
    FUNCTION Get_Val_String (p_Apd       Ap_Document.Apd_Id%TYPE,
                             p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                             p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION Get_Val_Dt (p_Apd   Ap_Document.Apd_Id%TYPE,
                         p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE;

    FUNCTION Get_Val_Id (p_Apd       Ap_Document.Apd_Id%TYPE,
                         p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                         p_Default   NUMBER DEFAULT NULL)
        RETURN NUMBER;

    FUNCTION Get_Val_Int (p_Apd       Ap_Document.Apd_Id%TYPE,
                          p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                          p_Default   NUMBER DEFAULT NULL)
        RETURN NUMBER;

    FUNCTION Get_Val_Sum (p_Apd       Ap_Document.Apd_Id%TYPE,
                          p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                          p_Default   NUMBER DEFAULT NULL)
        RETURN NUMBER;

    --==============================================================--
    FUNCTION Get_Doc_Count (p_App   Ap_Document.Apd_App%TYPE,
                            p_Ndt   Ap_Document.Apd_Ndt%TYPE)
        RETURN NUMBER;

    --кількість документів классу 13. Ідентифікація особи
    FUNCTION Get_Doc_Ndc13_Count (p_App Ap_Document.Apd_App%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Ap_Doc_Count (p_Ap    Ap_Document.Apd_Ap%TYPE,
                               p_Ndt   Ap_Document.Apd_Ndt%TYPE)
        RETURN NUMBER;

    FUNCTION get_ap_doc_list_cnt (p_ap_id      appeal.ap_id%TYPE,
                                  p_list_ndt   VARCHAR2)
        RETURN NUMBER;

    --кількість документів классу 13. Ідентифікація особи
    FUNCTION Get_Ap_Doc_Ndc13_Count (p_Ap Ap_Document.Apd_Ap%TYPE)
        RETURN NUMBER;

    FUNCTION Check_Documents_Exists (p_App   Ap_Document.Apd_App%TYPE,
                                     p_Ndt   Ap_Document.Apd_Ndt%TYPE)
        RETURN VARCHAR2;

    ---------------------------------------------------------------------
    --             Отримання віку учасника звернення
    ---------------------------------------------------------------------
    FUNCTION Get_App_Age (p_App_Id IN NUMBER)
        RETURN NUMBER;

    --==============================================================--
    --  Перевірка документів по персоні по переліку через кому
    --==============================================================--
    FUNCTION Check_Doc_Exists (p_App_Id NUMBER, p_Ndt_List VARCHAR2)
        RETURN VARCHAR2;

    --Перевірка заповненості атрибутів документів - повертає кількість незаповнених атрибутів
    FUNCTION Check_Documents_Filled (p_App        Ap_Document.Apd_App%TYPE,
                                     p_Ndt        Ap_Document.Apd_Ndt%TYPE,
                                     p_Nda_List   VARCHAR2,
                                     p_Is_Need    NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    --  Перевірка заповненості атрибутів документів - повертає кількість незаповнених атрибутів
    FUNCTION Check_Documents_Filled (p_Apd_Id Ap_Document.Apd_Id%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Information
        RETURN Table_Information
        PIPELINED;

    PROCEDURE Check20 (Err_List OUT VARCHAR2);

    PROCEDURE Check21 (Err_List OUT VARCHAR2);                       --#103390

    PROCEDURE Check22 (Err_List OUT VARCHAR2);

    PROCEDURE Check248 (Err_List OUT VARCHAR2);

    PROCEDURE Check249 (Err_List OUT VARCHAR2);

    PROCEDURE Check267 (Err_List OUT VARCHAR2);

    PROCEDURE Check269 (Err_List OUT VARCHAR2);

    PROCEDURE Check4xx (Err_List OUT VARCHAR2);             --#77504  20220603

    PROCEDURE Check60x (Err_List OUT VARCHAR2);           --#73770  2021.12.03

    PROCEDURE Check620 (Err_List OUT VARCHAR2);                       --#98703

    PROCEDURE Check62x (Err_List OUT VARCHAR2);           --#74104  2021.12.16

    PROCEDURE Check641 (Err_List OUT VARCHAR2);

    PROCEDURE Check642 (Err_List OUT VARCHAR2);           --#78395  2022.07.06

    PROCEDURE Check643 (Err_List OUT VARCHAR2);           --#79278  2022.08.11

    PROCEDURE Check645 (Err_List OUT VARCHAR2);

    PROCEDURE Check664 (Err_List OUT VARCHAR2);

    PROCEDURE Check664 (Wrn_List OUT VARCHAR2);

    PROCEDURE Check701 (Err_List OUT VARCHAR2);           --#76656  2022.04.22

    PROCEDURE Check761 (Err_List OUT VARCHAR2);

    PROCEDURE Check801 (Err_List OUT VARCHAR2);           --#79278  2022.08.11

    PROCEDURE Check1141 (Err_List OUT VARCHAR2);         --#115740  2025.02.05

    PROCEDURE CheckDoc801;

    PROCEDURE CheckDoc802;

    PROCEDURE CheckDoc10033;

    PROCEDURE CheckDoc10034;

    PROCEDURE CheckDoc10035;


    PROCEDURE Check_Attr_Date;

    PROCEDURE Check_Attr_1;

    PROCEDURE Check_Attr_3;

    PROCEDURE Check_Attr_9;

    PROCEDURE Check_Attr_90;

    PROCEDURE Check_Attr_91;

    PROCEDURE Check_Attr_347_1806;

    PROCEDURE Check_Attr_349_791;                                     --#87947

    PROCEDURE Check_Attr_605;                                        -- #94969

    PROCEDURE Check_Attr_606;                                            --607

    PROCEDURE Check_Attr_649;

    PROCEDURE Check_Attr_699;                                        --#102162

    PROCEDURE Check_Attr_902;

    PROCEDURE Check_Attr_907;                                        --#111408

    PROCEDURE Check_Attr_923;                                        --#111408

    PROCEDURE Check_Attr_2531;                                        --#97529

    PROCEDURE Check_Attr_4300;                                       -- #92758

    PROCEDURE Check_Attr_8427;                                      -- #103028

    FUNCTION Get_Attr_801_ChkQty (p_Ap_Id       IN APPEAL.AP_ID%TYPE,
                                  p_Ap_ServTo   IN VARCHAR2,
                                  p_Rel_Tp      IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_Attr_801_ChkQty (p_Ap_Id       IN APPEAL.AP_ID%TYPE,
                                  p_Ap_Src      IN APPEAL.AP_SRC%TYPE,
                                  p_Ap_ServTo   IN VARCHAR2,
                                  p_Rel_Tp      IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Validate_Vpo_Pkg;

    PROCEDURE Validate_Ankt;

    PROCEDURE Validate_Zayav;

    PROCEDURE Validate_Documents;

    PROCEDURE Validate_Appeal (
        p_Ap_Id                IN Appeal.Ap_Id%TYPE,
        p_Warnings             IN BOOLEAN,
        p_Raise_Fatal_Err      IN BOOLEAN,
        p_Err_On_Missing_Doc   IN BOOLEAN DEFAULT TRUE,
        p_Check_Doc_Num_Attr   IN BOOLEAN DEFAULT TRUE,
        p_Error_To_Warning     IN BOOLEAN DEFAULT FALSE);

    FUNCTION Validate_Appeal (
        p_Ap_Id                IN Appeal.Ap_Id%TYPE,
        p_Warnings             IN BOOLEAN,
        p_Raise_Fatal_Err      IN BOOLEAN,
        p_Err_On_Missing_Doc   IN BOOLEAN DEFAULT TRUE,
        p_Check_Doc_Num_Attr   IN BOOLEAN DEFAULT TRUE,
        p_Error_To_Warning     IN BOOLEAN DEFAULT FALSE)
        RETURN t_Messages;

    PROCEDURE Validate_Appeal_Test (
        p_Ap_Id              IN Appeal.Ap_Id%TYPE,
        p_Error_To_Warning   IN BOOLEAN DEFAULT FALSE);

    FUNCTION Ap_Is_Valid
        RETURN BOOLEAN;

    PROCEDURE Dbms_Output_Appeal_Info (p_Id NUMBER);

    FUNCTION Com_Fn (p_Dt1 DATE, p_Dt2 DATE, p_Op NUMBER)
        RETURN NUMBER;

    FUNCTION Is_Mssing_Doc_Exception_query (p_App_Id   IN NUMBER,
                                            p_Ndt_Id   IN NUMBER)
        RETURN NUMBER;
END Api$validation;
/


GRANT EXECUTE ON USS_VISIT.API$VALIDATION TO IKIS_RBM
/

GRANT EXECUTE ON USS_VISIT.API$VALIDATION TO USS_ESR
/

GRANT EXECUTE ON USS_VISIT.API$VALIDATION TO USS_PERSON
/

GRANT EXECUTE ON USS_VISIT.API$VALIDATION TO USS_RNSP
/


/* Formatted on 8/12/2025 5:59:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$VALIDATION
IS
    g_Ap_Id                NUMBER;
    g_Ap                   APPEAL%ROWTYPE;
    g_Ap_Tp                VARCHAR2 (10);
    g_Ap_Reg_Dt            DATE;
    g_Ap_Create_Dt         DATE;
    g_Ap_Src               VARCHAR2 (10);
    g_Ap_Ap_Main           NUMBER;
    g_Ap_st                VARCHAR2 (10);
    g_Ap_Is_Second         VARCHAR2 (10);
    g_com_wu               NUMBER;
    g_Aps                  t_Aps_List;
    g_Apd_Id               NUMBER;
    g_org_to               NUMBER;
    g_Warnings             BOOLEAN;
    g_Raise_Fatal_Err      BOOLEAN;
    g_Err_On_Missing_Doc   BOOLEAN;
    g_Error_To_Warning     BOOLEAN;


    PROCEDURE put_line (p_str VARCHAR2)
    IS
    BEGIN
        IF g_is_output
        THEN
            DBMS_OUTPUT.put_line (p_str);
        END IF;
    END;

    FUNCTION F_AP_ID
        RETURN NUMBER
    IS
    BEGIN
        RETURN g_Ap_Id;
    END;

    FUNCTION F_AP_TP
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN g_Ap_Tp;
    END;

    FUNCTION F_AP_SRC
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN g_Ap_Src;
    END;

    PROCEDURE Add_Message (p_Msg_Text      IN VARCHAR2,
                           p_Msg_Tp        IN VARCHAR2,
                           p_Msg_Tp_Name   IN VARCHAR2)
    IS
        l_Msg   r_Message;
    BEGIN
        l_Msg.Msg_Text := p_Msg_Text;
        --Ряюченко: FATAL_ERROR (p_Msg_Tp = F) сделаны специально, чтобы их нельзя было конвертировать в предупреждения. Ошибки такого типа должны останавливать процесс
        l_Msg.Msg_Tp :=
            CASE
                WHEN g_Error_To_Warning AND p_Msg_Tp IN ('E') THEN 'W'
                ELSE p_Msg_Tp
            END;
        l_Msg.Msg_Tp_Name :=
            CASE
                WHEN g_Error_To_Warning AND p_Msg_Tp IN ('E')
                THEN
                    'Попередження'
                ELSE
                    p_Msg_Tp_Name
            END;
        g_Messages.EXTEND ();
        g_Messages (g_Messages.COUNT) := l_Msg;
    END;

    PROCEDURE Add_Warning (p_Msg_Text IN VARCHAR2)
    IS
    BEGIN
        Add_Message (p_Msg_Text, 'W', 'Попередження');
    END;

    PROCEDURE Add_Error (p_Msg_Text IN VARCHAR2)
    IS
    BEGIN
        IF INSTR (p_Msg_Text, '#FATAL_ERROR#') > 0
        THEN
            Add_Message (REPLACE (p_Msg_Text, '#FATAL_ERROR#', ''),
                         'F',
                         'Помилка');
        ELSE
            Add_Message (p_Msg_Text, 'E', 'Помилка');
        END IF;
    END;

    PROCEDURE Add_Fatal (p_Msg_Text IN VARCHAR2)
    IS
    BEGIN
        IF g_Raise_Fatal_Err AND NOT g_Error_To_Warning
        THEN
            Raise_Application_Error (-20000, p_Msg_Text);
        END IF;

        Add_Message (p_Msg_Text, 'F', 'Помилка');
    END;

    FUNCTION Get_App_Tp_Name (p_Dic_Value VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (250);
    BEGIN
        SELECT t.Dic_Sname
          INTO l_Result
          FROM Uss_Ndi.v_Ddn_App_Tp t
         WHERE t.Dic_Value = p_Dic_Value;

        RETURN l_Result;
    END;

    FUNCTION Get_Dic_Name (p_Ndc_Id IN NUMBER, p_Id IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Sql   VARCHAR2 (32000);
        l_Cur   SYS_REFCURSOR;
        l_Id    VARCHAR2 (10);
        l_Val   VARCHAR2 (500);
    BEGIN
        SELECT c.Ndc_Sql
          INTO l_Sql
          FROM Uss_Ndi.v_Ndi_Dict_Config c
         WHERE c.Ndc_Id = p_Ndc_Id;

        OPEN l_Cur FOR l_Sql;

        LOOP
            FETCH l_Cur INTO l_Id, l_Val;

            EXIT WHEN l_Cur%NOTFOUND;

            IF l_Id = p_Id
            THEN
                RETURN l_Val;
            END IF;
        END LOOP;
    END;

    FUNCTION Aps_Exists (p_Aps_Nst IN NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        IF g_Aps.EXISTS (p_Aps_Nst)
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END;

    FUNCTION Only_One_Aps_Exists (p_Aps_Nst IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN g_Aps.EXISTS (p_Aps_Nst) AND g_Aps.COUNT = 1;
    END;

    FUNCTION Only_One_Aps_Exists_n (p_Aps_Nst IN NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        IF g_Aps.EXISTS (p_Aps_Nst) AND g_Aps.COUNT = 1
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END;

    PROCEDURE Init (p_Ap_Id IN Appeal.Ap_Id%TYPE)
    IS
    BEGIN
        Init (p_Ap_Id, TRUE, TRUE);
    END;

    PROCEDURE Init (p_Ap_Id                IN Appeal.Ap_Id%TYPE,
                    p_Warnings             IN BOOLEAN,
                    p_Raise_Fatal_Err      IN BOOLEAN,
                    p_Err_On_Missing_Doc   IN BOOLEAN DEFAULT TRUE,
                    p_Error_To_Warning     IN BOOLEAN DEFAULT FALSE)
    IS
    BEGIN
        g_Ap_Id := p_Ap_Id;

        SELECT *
          INTO g_Ap
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        g_Ap_Tp := g_ap.Ap_Tp;
        g_Ap_Reg_Dt := g_ap.Ap_Reg_Dt;
        g_Ap_Create_Dt := g_ap.Ap_Create_Dt;
        g_Ap_Src := g_ap.Ap_Src;
        g_Ap_st := g_ap.Ap_st;
        g_com_wu := g_ap.com_wu;
        g_Ap_Is_Second := g_ap.Ap_Is_Second;
        g_Ap_Ap_Main := g_ap.Ap_Ap_Main;
        g_Warnings := p_Warnings;
        g_Raise_Fatal_Err := p_Raise_Fatal_Err;
        g_Err_On_Missing_Doc := p_Err_On_Missing_Doc;
        g_Error_To_Warning := p_Error_To_Warning;
        g_Messages := t_Messages ();

        SELECT MAX (t.org_to)
          INTO g_org_to
          FROM v_opfu t
         WHERE t.org_id = g_ap.com_org;

        g_Aps.Delete;

        FOR Rec
            IN (SELECT Aps_Nst
                  FROM Ap_Service
                 WHERE     Aps_Ap = g_Ap_Id
                       AND History_Status = 'A'
                       AND Aps_Nst IS NOT NULL)
        LOOP
            g_Aps (Rec.Aps_Nst) := TRUE;
        END LOOP;
    END;

    --==============================================================--
    --Отримання кількості документів по переліку через кому
    FUNCTION get_ap_doc_list_cnt (p_ap_id      appeal.ap_id%TYPE,
                                  p_list_ndt   VARCHAR2)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10);
    BEGIN
        WITH
            ndt_list
            AS
                (    SELECT REGEXP_SUBSTR (p_list_ndt,
                                           '[^,]+',
                                           1,
                                           LEVEL)    AS i_ndt
                       FROM DUAL
                 CONNECT BY LEVEL <=
                            LENGTH (REGEXP_REPLACE (p_list_ndt, '[^,]*')) + 1)
        SELECT COUNT (1)
          INTO l_rez
          FROM ap_document JOIN ndt_list ON apd_ndt = i_ndt
         WHERE apd_ap = p_ap_id AND ap_document.history_status = 'A';

        RETURN l_rez;
    END;

    ---------------------------------------------------------------------
    --                 ПЕРЕВІРКА ЗАГАЛЬНОЇ ІНФОРМАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Appeal
    IS
        l_cnt_ap     NUMBER;
        l_cnt_err    NUMBER;
        l_atp_num    NUMBER;
        l_Act_Data   USS_ESR.API$FIND.cAct;
    BEGIN
        IF g_Ap_Reg_Dt IS NULL
        THEN
            Add_Fatal (
                'Поле "Дата подання заяви" -обов''язкове для заповнення');
        ELSIF g_Ap_Reg_Dt > SYSDATE + INTERVAL '10' MINUTE
        THEN
            Add_Fatal (
                'Перевірте правильність введення дати. Введена дата є більш пізньою ніж поточна дата');
        -- #78732
        /*ELSIF g_Ap_Reg_Dt < (SYSDATE - 30)
              AND g_Ap_Src = Api$appeal.c_Src_Uss THEN
          Add_Fatal('Введена дата подання заяви перевищує термін 30 днів');
        END IF;*/
        /*ELSIF g_Ap_Reg_Dt NOT BETWEEN (g_Ap_Create_Dt - 30) AND (g_Ap_Create_Dt + 30)
            AND g_Ap_Src = Api$appeal.c_Src_Uss THEN
        Add_Fatal('Введена дата подання заяви перевищує термін 30 днів до дати реєстрації звернення');*/
        --#82959
        ELSIF (TRUNC (g_Ap_Reg_Dt) > TRUNC (g_Ap_Create_Dt))
        THEN                                                        --  #81509
            Add_Fatal (
                'Дата подання заяви" не може бути більш пізньою ніж "Дата реєстрації звернення". Приведіть у відповідність "Дату подання заяви"');
        ELSIF (g_Ap_Reg_Dt < TO_DATE ('01.05.2022', 'DD.MM.YYYY'))
        THEN                                                        --  #81509
            Add_Fatal (
                'Введення звернення з "Дата подання заяви" до 01.05.2022 заборонено!');
        END IF;


        SELECT COUNT (1)
          INTO l_cnt_err
          FROM ap_payment
         WHERE     apm_ap = g_ap_id
               AND apm_app IS NOT NULL
               AND NOT EXISTS
                       (SELECT 1
                          FROM ap_person app
                         WHERE app.app_ap = g_ap_id AND app.app_id = apm_app);

        IF l_cnt_err > 0
        THEN
            Add_Error ('Персона для "Спосіб виплати" відсутня в зверненні!');
        END IF;


        SELECT COUNT (aps_nst)
          INTO l_cnt_err
          FROM (  SELECT s.aps_nst, COUNT (1) AS x_cnt
                    FROM ap_service s
                   WHERE s.aps_ap = g_ap_id AND s.history_status = 'A'
                GROUP BY s.aps_nst
                  HAVING COUNT (1) > 1);

        IF l_cnt_err > 0
        THEN
            Add_Error (
                'Заборонено кілька разів обирати одну і ту саму послугу. Приведіть у відповідність блок "Послуга" у даному зверненні!');
        END IF;


        SELECT COUNT (1)
          INTO l_cnt_ap
          FROM appeal ap
         WHERE     ap.ap_id != g_Ap_id
               AND ap.ap_st = 'J'
               AND g_ap_st = 'J'
               AND ap.ap_tp = g_Ap_tp
               AND ap.com_wu = g_com_wu
               AND TRUNC (ap.ap_create_dt) = TRUNC (g_Ap_Create_Dt)
               AND EXISTS
                       (SELECT 1
                          FROM ap_service s1, ap_service s2
                         WHERE     s1.aps_nst = s2.aps_nst
                               AND s1.aps_ap = ap.ap_id
                               AND s2.aps_ap = g_ap_id
                               AND s1.history_status = 'A'
                               AND s2.history_status = 'A')
               AND EXISTS
                       (SELECT 1
                          FROM ap_person p1, ap_person p2
                         WHERE     p1.app_sc = p2.app_sc
                               AND p1.app_ap = ap.ap_id
                               AND p2.app_ap = g_ap_id
                               AND p1.app_tp = 'Z'
                               AND p2.app_tp = 'Z'
                               AND p1.history_status = 'A'
                               AND p2.history_status = 'A');

        IF l_cnt_ap > 0
        THEN
            Add_Fatal (
                'Сьогодні вже введено звернення з співпадаючими "заявник" та "послуга" від поточного користувача!');
        END IF;

        IF g_Ap_Tp IN ('SS')
        THEN
            IF                                      --g_Ap_Src IN ('CMES') AND
               g_Ap_Ap_Main IS NOT NULL
            THEN
                --#113726
                FOR vPerson
                    IN (SELECT *
                          FROM Ap_Person
                         WHERE app_ap = g_Ap_id AND History_Status = 'A')
                LOOP
                    l_atp_num :=
                        USS_ESR.API$FIND.Get_At_Atp_Num_By_FIO (
                            p_Ap_Id   => g_Ap_Ap_Main,
                            p_At_Tp   => 'APOP',
                            p_Ln      => vPerson.App_Ln,
                            p_Mn      => vPerson.App_Mn,
                            p_Fn      => vPerson.App_Fn);

                    IF l_atp_num IS NOT NULL AND l_atp_num <> vPerson.App_Num
                    THEN
                        Add_Fatal (
                               'Інформація для розробників: Порядковий номер учасника звернення '
                            || vPerson.App_Ln
                            || ' '
                            || vPerson.App_Fn
                            || ' '
                            || vPerson.App_Mn
                            || ' ['
                            || vPerson.App_Num
                            || '] не відповідає номеру, вказаному в Акті оцінки потреб ['
                            || l_atp_num
                            || ']');
                    END IF;
                END LOOP;

                SELECT COUNT (1)
                  INTO l_cnt_err
                  FROM ap_document
                 WHERE apd_ap = g_ap_id AND apd_ndt = 801;

                IF l_cnt_err > 0
                THEN
                    USS_ESR.API$FIND.Get_Act_By_Ap (
                        p_Ap_Id        => g_Ap_Ap_Main,
                        p_At_Tp_List   => 'APOP,OKS,ANPOE',
                        p_Act_Cur      => l_Act_Data);

                    SELECT COUNT (1)
                      INTO l_cnt_err
                      FROM TABLE (l_Act_Data)
                     WHERE    (At_Tp = 'APOP' AND At_St IN ('AS'))
                           OR (At_Tp = 'OKS' AND At_St IN ('TS'))
                           OR (At_Tp = 'ANPOE' AND At_St IN ('XP'));

                    IF l_cnt_err = 0
                    THEN
                        Add_Fatal (
                            'Звернення з ініціативним документом "Заява про надання соціальних послуг" можна створити тільки на основі попереднього звернення з підписаним актом – або "Акт первинної оцінки потреб", або "Оцінка кризової ситуації"');
                    END IF;
                END IF;
            END IF;

            IF g_Ap_Src IN ('CMES', 'VISIT')
            THEN
                SELECT COUNT (1)
                  INTO l_cnt_err
                  FROM ap_document
                 WHERE apd_ap = g_ap_id AND apd_ndt = 835;

                IF l_cnt_err > 0
                THEN
                    Add_Fatal (
                        'Не можуть бути звернення з ініціативними документи "Звернення з кабінету отримувача соціальних послуг"');
                END IF;

                SELECT COUNT (1)
                  INTO l_cnt_err
                  FROM ap_document
                 WHERE apd_ap = g_ap_id AND apd_ndt = 1015;

                IF l_cnt_err > 0
                THEN
                    Add_Fatal (
                        'Не можуть бути звернення з ініціативними документи "Звернення з Соціального веб-порталу Мінсоцполітики"');
                END IF;
            END IF;
        END IF;
    END;

    ---------------------------------------------------------------------
    --                    ПЕРЕВІРКА ПОСЛУГ
    ---------------------------------------------------------------------

    PROCEDURE check_attachment (p_is_error IN VARCHAR2 DEFAULT 'T')
    IS
    BEGIN
        FOR xx
            IN (SELECT dt.ndt_id,
                       dt.ndt_name,
                       d.apd_id,
                       (SELECT COUNT (*)
                          FROM uss_doc.v_doc_attachments z
                         WHERE z.dat_dh = d.apd_dh)    AS cnt
                  FROM tmp_work_ids1  t
                       JOIN uss_ndi.v_ndi_document_type dt
                           ON (dt.ndt_id = t.x_id)
                       JOIN ap_document d ON (d.apd_ndt = t.x_id)
                 WHERE d.apd_ap = g_Ap_Id AND d.history_status = 'A')
        LOOP
            IF (xx.cnt IS NULL OR xx.cnt = 0 AND p_is_error = 'T')
            THEN
                Add_Error (
                       'Для документу "'
                    || xx.ndt_name
                    || '" не вкладено скан-копію');
            ELSIF (   xx.cnt IS NULL
                   OR xx.cnt = 0 AND (p_is_error = 'F' OR p_is_error IS NULL))
            THEN
                Add_Warning (
                       'Для документу "'
                    || xx.ndt_name
                    || '" не вкладено скан-копію');
            END IF;
        END LOOP;
    END;

    -- #87814
    -- У разі спроби отримання Витягу за пільгою із забороненого переліку, надавати повідомлення "Витяг за категорією _ не надається"
    PROCEDURE check_961_service
    IS
        l_cnt           NUMBER;
        l_msg           VARCHAR2 (4000);
        l_raj           NUMBER;
        l_org           NUMBER;
        l_cur_org       NUMBER := tools.getcurrorg;
        l_wut           NUMBER := tools.Getcurrwut;
        l_flag          NUMBER := CASE WHEN l_wut IN (31, 41) THEN 0 ELSE 1 END;
        l_is_permited   NUMBER;
        --l_is_pilgovik NUMBER;
        l_sc            NUMBER;
    BEGIN
        IF g_ap_tp != 'D'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 961
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        SELECT COUNT (*), MAX (c.nbc_name), MAX (p.app_sc)
          INTO l_cnt, l_msg, l_sc
          FROM ap_person  p
               JOIN uss_person.v_sc_benefit_category t
                   ON (p.app_sc = t.scbc_sc)
               JOIN uss_ndi.v_ndi_benefit_category c ON nbc_id = scbc_nbc
               JOIN uss_person.v_sc_benefit_type ON scbt_sc = p.app_sc
               JOIN uss_ndi.v_ndi_benefit_type ON nbt_id = scbt_nbt
               JOIN uss_ndi.v_ndi_nbc_setup
                   ON nbcs_nbt = scbt_nbt AND nbcs_nbc = scbc_nbc
         WHERE     scbc_st = 'A'
               AND p.app_ap = g_ap_id
               AND p.app_tp = 'Z'
               AND c.nbc_id IN (1,
                                2,
                                3,
                                4,
                                11,
                                12,
                                13,
                                22,
                                23,
                                58,
                                80,
                                85,
                                86,
                                87,
                                88,
                                136,
                                137,
                                138,
                                139);

        IF (l_cnt > 0)
        THEN
            Add_Fatal ('Витяг за категорією ' || l_msg || ' не надається');
        END IF;

        EXECUTE IMMEDIATE 'SELECT MAX(tr.raj)
      FROM ap_person p
      JOIN uss_person.v_sc_benefit_category t ON (p.app_sc = t.scbc_sc)
      JOIN uss_person.v_x_trg tr ON (t.scbc_id = tr.trg_id and tr.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY'')
     WHERE scbc_st = ''A''
       AND p.app_ap = :1
       AND p.app_tp = ''Z'''
            INTO l_raj
            USING g_ap_id;



        -- Надавати можливість отримання витягу по тим пільговикам, у яких B_REESTRLG.RAJ (в приведенні до коду району ЄІССС*):
        --для користувачів типу 33 (область) - код (в приведенні до коду району ЄІССС*) є підлеглим для коду користувача (район підпорядковується області)
        --для користувачів типу 35 співпадає с кодом району користувача (в приведенні до коду району ЄІССС*)
        --Приведення кодів ЄДАРП до коду району ЄІССС*:
        --додати 50000
        IF (l_raj IS NOT NULL)
        THEN
            l_raj := l_raj + 50000;

            SELECT MAX (o.nddc_code_dest)
              INTO l_org
              FROM uss_ndi.v_ndi_decoding_config o
             WHERE     1 = 1
                   AND o.nddc_tp = 'ORG_MIGR'
                   AND o.nddc_code_src = l_raj;

            l_org := NVL (l_org, l_raj);

            SELECT COUNT (*)
              INTO l_cnt
              FROM v_opfu t
             WHERE     t.org_st = 'A'
                   AND (   (    l_wut = 33
                            AND t.org_id = l_org
                            AND t.org_org = l_cur_org)
                        OR (    l_wut = 35
                            AND t.org_id = l_org
                            AND t.org_id = l_cur_org)
                        OR (    l_wut = 39
                            AND t.org_org = l_org
                            AND t.org_id = l_cur_org)
                        OR 1 = 2);

            IF (l_cnt = 0)
            THEN
                Add_Fatal (
                    'По данному району/області не знайдено осіб з вказаними ознаками!');
            END IF;
        ELSE
            Add_Fatal ('Не знайдено район!');
        END IF;


        WITH
            dat
            AS
                (SELECT t.RAJ, t.R_NCARDP
                   FROM uss_person.v_x_trg  t
                        JOIN uss_person.v_sc_benefit_category c
                            ON     c.scbc_id = t.trg_id
                               AND t.trg_code =
                                   'USS_PERSON.SC_BENEFIT_CATEGORY'
                  WHERE c.scbc_sc = l_sc
                  FETCH FIRST ROW ONLY)
        SELECT COUNT (*)
          INTO l_is_permited
          FROM dat  t
               JOIN uss_person.v_b_katpp z
                   ON (t.raj = z.raj AND t.r_ncardp = z.r_ncardp)
         WHERE     1 = 1
               AND (   l_flag = 0
                    OR z.katp_cd NOT IN (1,
                                         2,
                                         3,
                                         4,
                                         11,
                                         12,
                                         13,
                                         22,
                                         23,
                                         58,
                                         80,
                                         85,
                                         86,
                                         87,
                                         88,
                                         136,
                                         137,
                                         138,
                                         139));

        IF (l_flag = 1 AND l_is_permited = 0)
        THEN
            Add_Fatal ('Доступ до даних обмежено!');
        END IF;
    END;

    -- #88840
    -- Реєструвати звернення по послузі з ІД=20 можуть лише органи, у яких org_org=56500 or org_org=54800.
    PROCEDURE check_20_service
    IS
        l_cnt       NUMBER;
        l_cur_org   NUMBER := tools.getcurrorg;
    BEGIN
        IF g_ap_tp != 'V'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 20
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        --Для тесування.
        IF g_is_output
        THEN
            RETURN;
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM (    SELECT org_id
                      FROM v_opfu t
                     WHERE t.org_st = 'A'
                CONNECT BY PRIOR t.org_org = t.org_id
                START WITH t.org_id = l_cur_org)
         WHERE org_id IN (56500, 54800);

        IF (l_cnt = 0)
        THEN
            Add_Fatal (
                'Заява про надання грошової допомоги постраждалому населенню внаслідок підриву рф Каховської ГЕС можливо реєструвати лише в управліннях Миколаївської чи Херсонської області!');
        END IF;

        -- #91517
        IF (    TRUNC (g_Ap_Reg_Dt) > TO_DATE ('31.10.2023', 'DD.MM.YYYY')
            AND TRUNC (g_Ap_Create_Dt) > TO_DATE ('31.10.2023', 'DD.MM.YYYY'))
        THEN                                                        --  #90848
            Add_Fatal (
                'Заборонено реєструвати звернення щодо матеріальної грошової допомоги після 31.10.2023"');
        END IF;
    END;

    -- #106127
    PROCEDURE check_643_service
    IS
        l_cnt         NUMBER;
        l_cur_org     NUMBER := tools.getcurrorg;
        l_flag1       NUMBER;
        l_flag2       NUMBER;
        l_change_tp   VARCHAR2 (10);
    BEGIN
        IF g_ap_tp != 'O'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 643
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        --Для тесування.
        IF g_is_output
        THEN
            RETURN;
        END IF;

        FOR xx
            IN (SELECT t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn    AS pib
                  FROM ap_person  t
                       JOIN ap_document d ON (d.apd_app = t.app_id)
                       JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                 WHERE     t.app_ap = g_Ap_Id
                       AND t.app_tp IN ('FP', 'FM')
                       AND a.apda_nda = 2452
                       AND t.history_status = 'A'
                       AND d.history_status = 'A'
                       AND a.history_status = 'A'
                       AND a.apda_val_string IS NULL)
        LOOP
            Add_Error (
                   'В Анкеті учасника звернення "'
                || xx.pib
                || '" не визначена причина зміни в складі сім`ї');
        END LOOP;

        SELECT SIGN (COUNT (a.apda_id))
          INTO l_flag1
          FROM ap_person  t
               JOIN ap_document d ON (d.apd_app = t.app_id)
               JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
         WHERE     t.app_ap = g_Ap_Id
               AND t.app_tp IN ('O')
               AND a.apda_nda = 2262
               AND d.apd_ndt = 10098
               AND a.apda_val_string = 901
               AND t.history_status = 'A'
               AND d.history_status = 'A'
               AND a.history_status = 'A';

        -- тип зміни складу сім'ї
        SELECT MAX (a.apda_val_string)
          INTO l_change_tp
          FROM ap_person  t
               JOIN ap_document d ON (d.apd_app = t.app_id)
               JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
         WHERE     t.app_ap = g_Ap_Id
               AND t.app_tp IN ('FP')
               AND a.apda_nda = 2452
               AND d.apd_ndt = 605
               AND t.history_status = 'A'
               AND d.history_status = 'A'
               AND a.history_status = 'A';

        IF (l_flag1 = 1)
        THEN
            FOR xx
                IN (SELECT t.*,
                           p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn    AS pib
                      FROM uss_ndi.v_ndi_document_type  t
                           JOIN ap_person p
                               ON (p.app_ap = g_Ap_Id AND p.app_tp = 'FP')
                     WHERE     (       l_change_tp = 'INS'
                                   AND t.ndt_id IN (10204, 10205, 10206)
                                OR     l_change_tp = 'DEL'
                                   AND t.ndt_id IN (10325)
                                OR     l_change_tp NOT IN ('INS', 'DEL')
                                   AND 1 = 2)
                           AND NOT EXISTS
                                   (SELECT *
                                      FROM ap_document z
                                     WHERE     z.apd_ap = g_Ap_Id
                                           AND z.apd_ndt = t.ndt_id
                                           AND z.history_status = 'A'))
            LOOP
                Add_Error (
                       'MissingDocs: Для учасника "'
                    || xx.pib
                    || '" відсутній обов`язковий документ "'
                    || xx.ndt_name
                    || '"');
            END LOOP;
        END IF;

        -- #109692
        FOR xx
            IN (SELECT p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn    AS pib
                  FROM ap_person  p
                       JOIN ap_document d ON (d.apd_app = p.app_id)
                       JOIN ap_document_attr a1
                           ON (    a1.apda_apd = d.apd_id
                               AND a1.apda_nda = 2660
                               AND a1.history_status = 'A')
                       JOIN ap_document_attr a2
                           ON (    a2.apda_apd = d.apd_id
                               AND a2.apda_nda = 2452
                               AND a2.history_status = 'A')
                 WHERE     p.app_ap = g_Ap_Id
                       AND p.app_tp = 'FP'
                       AND d.apd_ndt = 605
                       AND d.history_status = 'A'
                       AND a1.apda_val_string = 'T'
                       AND a2.apda_val_string = 'DEL'
                       AND NOT EXISTS
                               (SELECT *
                                  FROM ap_document z
                                 WHERE     z.apd_ap = g_Ap_Id
                                       AND z.apd_ndt = 10329
                                       AND z.apd_app = p.app_id
                                       AND z.history_status = 'A'))
        LOOP
            Add_Error (
                   'MissingDocs: Для учасника "'
                || xx.pib
                || '" відсутній обов`язковий документ «Копія рішення про вилучення дитини з прийомної сім`ї»');
        END LOOP;

        -- #109692
        FOR xx
            IN (SELECT p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn    AS pib
                  FROM ap_person  p
                       JOIN ap_document d ON (d.apd_app = p.app_id)
                       JOIN ap_document_attr a1
                           ON (    a1.apda_apd = d.apd_id
                               AND a1.apda_nda = 2659
                               AND a1.history_status = 'A')
                       JOIN ap_document_attr a2
                           ON (    a2.apda_apd = d.apd_id
                               AND a2.apda_nda = 2452
                               AND a2.history_status = 'A')
                 WHERE     p.app_ap = g_Ap_Id
                       AND p.app_tp = 'FP'
                       AND d.apd_ndt = 605
                       AND d.history_status = 'A'
                       AND a1.apda_val_string = 'T'
                       AND a2.apda_val_string = 'DEL'
                       AND NOT EXISTS
                               (SELECT *
                                  FROM ap_document z
                                 WHERE     z.apd_ap = g_Ap_Id
                                       AND z.apd_ndt = 10328
                                       AND z.apd_app = p.app_id
                                       AND z.history_status = 'A'))
        LOOP
            Add_Error (
                   'MissingDocs: Для учасника "'
                || xx.pib
                || '" відсутній обов`язковий документ «Копія рішення про вилучення дитини з дитячого будинку сімейного типу»');
        END LOOP;

        -- #109835
        FOR xx
            IN (SELECT p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn    AS pib
                  FROM ap_person  p
                       JOIN ap_document d ON (d.apd_app = p.app_id)
                       JOIN ap_document_attr a1
                           ON (    a1.apda_apd = d.apd_id
                               AND a1.apda_nda = 2660
                               AND a1.history_status = 'A')
                       JOIN ap_document_attr a2
                           ON (    a2.apda_apd = d.apd_id
                               AND a2.apda_nda = 2452
                               AND a2.history_status = 'A')
                 WHERE     p.app_ap = g_Ap_Id
                       AND p.app_tp = 'FP'
                       AND d.apd_ndt = 605
                       AND d.history_status = 'A'
                       AND a1.apda_val_string = 'T'
                       AND a2.apda_val_string = 'INS'
                       AND NOT EXISTS
                               (SELECT *
                                  FROM ap_document z
                                 WHERE     z.apd_ap = g_Ap_Id
                                       AND z.apd_ndt = 662
                                       AND z.apd_app = p.app_id
                                       AND z.history_status = 'A'))
        LOOP
            Add_Error (
                   'MissingDocs: Для учасника "'
                || xx.pib
                || '" відсутній обов`язковий документ «Рішення органу опіки чи піклування про влаштування дитини до прийомної сім`ї»');
        END LOOP;

        -- #109835
        FOR xx
            IN (SELECT p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn    AS pib
                  FROM ap_person  p
                       JOIN ap_document d ON (d.apd_app = p.app_id)
                       JOIN ap_document_attr a1
                           ON (    a1.apda_apd = d.apd_id
                               AND a1.apda_nda = 2659
                               AND a1.history_status = 'A')
                       JOIN ap_document_attr a2
                           ON (    a2.apda_apd = d.apd_id
                               AND a2.apda_nda = 2452
                               AND a2.history_status = 'A')
                 WHERE     p.app_ap = g_Ap_Id
                       AND p.app_tp = 'FP'
                       AND d.apd_ndt = 605
                       AND d.history_status = 'A'
                       AND a1.apda_val_string = 'T'
                       AND a2.apda_val_string = 'INS'
                       AND NOT EXISTS
                               (SELECT *
                                  FROM ap_document z
                                 WHERE     z.apd_ap = g_Ap_Id
                                       AND z.apd_ndt = 661
                                       AND z.apd_app = p.app_id
                                       AND z.history_status = 'A'))
        LOOP
            Add_Error (
                   'MissingDocs: Для учасника "'
                || xx.pib
                || '" відсутній обов`язковий документ «Рішення органу опіки чи піклування про влаштування дитини до дитячого будинку сімейного типу»');
        END LOOP;
    END;

    PROCEDURE check_664_service
    IS
        l_val   NUMBER;
    BEGIN
        FOR xx IN (SELECT *
                     FROM ap_service t
                    WHERE t.aps_ap = g_Ap_Id AND t.history_status = 'A')
        LOOP
            /*if (xx.aps_nst = 664 AND g_Ap_Reg_Dt < to_date('01.08.2023', 'DD.MM.YYYY') AND g_Ap_Create_Dt >= to_date('01.08.2023', 'DD.MM.YYYY')) then --  #81509
               Add_Fatal('Заборонено реєструвати звернення по допомозі ВПО за періоди до 31.07.2023 включно після 01.08.2023.');   */
            IF (    xx.aps_nst = 664
                AND g_Ap_Reg_Dt < TO_DATE ('01.05.2022', 'DD.MM.YYYY')
                AND g_Ap_Create_Dt >= TO_DATE ('01.05.2022', 'DD.MM.YYYY'))
            THEN                                                    --  #90848
                Add_Fatal (
                    'Заборонено реєструвати звернення по допомозі ВПО за періоди до 01.05.2022!');
            ELSIF (xx.aps_nst = 643)
            THEN
                SELECT MAX (at.apda_val_id)
                  INTO l_val
                  FROM ap_document  t
                       JOIN ap_document_attr at ON (at.apda_apd = t.apd_id)
                 WHERE     t.history_status = 'A'
                       AND at.history_status = 'A'
                       AND t.apd_ndt = 10098
                       AND at.apda_nda = 2262;

                --if (l_val = 664 AND g_Ap_Reg_Dt < to_date('01.08.2023', 'DD.MM.YYYY') AND g_Ap_Create_Dt >= to_date('01.08.2023', 'DD.MM.YYYY')) then --  #81509
                IF (    l_val = 664
                    AND g_Ap_Reg_Dt < TO_DATE ('01.05.2022', 'DD.MM.YYYY')
                    AND g_Ap_Create_Dt >=
                        TO_DATE ('01.05.2022', 'DD.MM.YYYY'))
                THEN                                                --  #90848
                    --Add_Fatal('Заборонено реєструвати звернення по допомозі ВПО за періоди до 31.07.2023 включно після 01.08.2023.');
                    Add_Fatal (
                        'Заборонено реєструвати звернення по допомозі ВПО за періоди до 01.05.2022!');
                END IF;
            ELSIF (xx.aps_nst = 801)
            THEN
                SELECT MAX (at.apda_val_id)
                  INTO l_val
                  FROM ap_document  t
                       JOIN ap_document_attr at ON (at.apda_apd = t.apd_id)
                 WHERE     t.history_status = 'A'
                       AND at.history_status = 'A'
                       AND t.apd_ndt = 10099
                       AND at.apda_nda = 2260;

                --if (l_val = 664 AND g_Ap_Reg_Dt < to_date('01.08.2023', 'DD.MM.YYYY') AND g_Ap_Create_Dt >= to_date('01.08.2023', 'DD.MM.YYYY')) then --  #81509
                IF (    l_val = 664
                    AND g_Ap_Reg_Dt < TO_DATE ('01.05.2022', 'DD.MM.YYYY')
                    AND g_Ap_Create_Dt >=
                        TO_DATE ('01.05.2022', 'DD.MM.YYYY'))
                THEN                                                --  #90848
                    Add_Fatal (
                        'Заборонено реєструвати звернення по допомозі ВПО за періоди до 01.05.2022!');
                END IF;
            END IF;
        END LOOP;
    END;

    PROCEDURE check_250_service
    IS
        l_cnt            NUMBER;
        l_child_cnt      NUMBER;
        l_is_chornobyl   VARCHAR2 (10);
        l_is_opikun      VARCHAR2 (10);
        l_close_dt       DATE;
        l_birth_dt       DATE;
        l_pib            VARCHAR2 (500);
        l_cur_org        NUMBER := tools.getcurrorg;
    BEGIN
        IF g_ap_tp != 'V'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 250
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM ap_person t
         WHERE     t.app_ap = g_Ap_Id
               AND t.history_status = 'A'
               AND t.app_tp = 'FP';

        IF (l_cnt = 0)
        THEN
            Add_Error (
                'У розділі "Учасники звернення" потрібно додати учасника з типом "Утриманець"');
        END IF;

        -- #99043
        FOR xx
            IN (  SELECT MAX (CASE WHEN apda_nda = 91 THEN a.apda_val_dt END)
                             AS dt1,
                         MAX (CASE WHEN apda_nda = 762 THEN a.apda_val_dt END)
                             AS dt2,
                         MAX (t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn)
                             AS pib,
                         t.app_id
                    FROM ap_person t
                         JOIN ap_document d ON (d.apd_app = t.app_id)
                         JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                   WHERE     t.app_ap = g_Ap_Id
                         AND t.app_tp = 'FP'
                         AND t.history_status = 'A'
                         AND d.history_status = 'A'
                         AND a.history_status = 'A'
                         AND (   a.apda_nda IN (91) AND d.apd_ndt IN (37)
                              OR a.apda_nda IN (762) AND d.apd_ndt IN (673))
                GROUP BY app_id)
        LOOP
            IF (   NVL (xx.dt1, xx.dt2) IS NULL
                OR ABS (MONTHS_BETWEEN (g_Ap_Reg_Dt, NVL (xx.dt1, xx.dt2))) >
                   12)
            THEN
                Add_Error (
                    'Помилка! Допомога при народженні дитини призначається якщо звернення надійшло не пізніше ніж за 12 календарних місяців після народження дитини.');
            END IF;
        END LOOP;

        -- #108386
        FOR xx
            IN (SELECT t.*
                  FROM (  SELECT MAX (
                                     CASE
                                         WHEN apda_nda = 8541
                                         THEN
                                             a.apda_val_string
                                     END)
                                     AS c1,
                                 MAX (
                                     CASE
                                         WHEN apda_nda = 8542
                                         THEN
                                             a.apda_val_string
                                     END)
                                     AS c2,
                                 MAX (
                                        t.app_ln
                                     || ' '
                                     || t.app_fn
                                     || ' '
                                     || t.app_mn)
                                     AS pib,
                                 (SELECT MAX (
                                                zp.app_ln
                                             || ' '
                                             || zp.app_fn
                                             || ' '
                                             || zp.app_mn)
                                    FROM ap_person zp
                                   WHERE     zp.app_ap = g_Ap_Id
                                         AND zp.app_tp = 'FP'
                                         AND zp.history_status = 'A')
                                     AS fp_pib,
                                 t.app_id
                            FROM ap_person t
                                 JOIN ap_document d ON (d.apd_app = t.app_id)
                                 JOIN ap_document_attr a
                                     ON (a.apda_apd = d.apd_id)
                           WHERE     t.app_ap = g_Ap_Id
                                 AND t.app_tp = 'Z'
                                 AND t.history_status = 'A'
                                 AND d.history_status = 'A'
                                 AND a.history_status = 'A'
                                 AND (    a.apda_nda IN (8541, 8542, 8543)
                                      AND d.apd_ndt IN (605))
                        GROUP BY app_id) t
                 WHERE t.c1 = 'T' OR t.c2 = 'T')
        LOOP
            SELECT COUNT (*)
              INTO l_cnt
              FROM ap_payment t JOIN ap_person p ON (p.app_id = t.apm_app)
             WHERE     t.apm_ap = g_Ap_Id
                   AND p.app_tp = 'FP'
                   AND t.apm_tp = 'BANK';

            IF (l_cnt IS NULL OR l_cnt = 0 AND xx.c1 = 'T')
            THEN
                Add_Error (
                       'Помилка! Для «'
                    || xx.pib
                    || '» встановлена ознака «Дитина влаштована до дитячого закладу на повне державне утримання», в закладці "Спосіб виплати" в колонці "Учасник" повинен бути – «'
                    || xx.fp_pib
                    || '», а в колонці "Тип способу виплати" - «Банком».');
            ELSIF (l_cnt IS NULL OR l_cnt = 0 AND xx.c2 = 'T')
            THEN
                Add_Error (
                       'Помилка! Для «'
                    || xx.pib
                    || '» встановлена ознака «Дитина перебуває разом з матір’ю в слідчому ізоляторі або установі виконання покарань», в закладці "Спосіб виплати" в колонці "Учасник" повинен бути – «'
                    || xx.fp_pib
                    || '», а в колонці "Тип способу виплати" - «Банком».');
            END IF;

            IF (xx.c1 = 'T' AND xx.c2 = 'T')
            THEN
                Add_Error (
                       'Помилка, в анкеті «'
                    || xx.pib
                    || '» потрібно обрати тільки одну ознаку або "Дитина влаштована до дитячого закладу на повне державне утримання" або "Дитина перебуває разом з матір’ю в слідчому ізоляторі або установі виконання покарань"');
            END IF;
        END LOOP;
    END;

    PROCEDURE check_251_service
    IS
        l_cnt              NUMBER;
        l_child_cnt        NUMBER;
        l_is_chornobyl     VARCHAR2 (10);
        l_is_opikun        VARCHAR2 (10);
        l_is_view_pology   VARCHAR2 (10);
        l_is_dead_child    VARCHAR2 (10);
        l_close_dt         DATE;
        l_birth_dt         DATE;
        l_pib              VARCHAR2 (500);
        l_cur_org          NUMBER := tools.getcurrorg;
    BEGIN
        IF g_ap_tp != 'V'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 251
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        SELECT COUNT (*),
               MAX (t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn)
          INTO l_cnt, l_pib
          FROM ap_person  t
               JOIN ap_document d ON (d.apd_app = t.app_id)
               JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
         WHERE     t.app_ap = g_Ap_Id
               AND t.history_status = 'A'
               AND d.history_status = 'A'
               AND a.history_status = 'A'
               AND a.apda_nda IN (651,
                                  2636,
                                  663,
                                  662,
                                  652)
               AND a.apda_val_string = 'T';

        IF (l_cnt = 0)
        THEN
            Add_Fatal (
                'Для послуги "Допомога у зв''язку з вагітністю та пологами" повинна бути вказана ознака роботи в анкеті в блоці "Ознака роботи (зайнятості)"');
        ELSIF (l_cnt > 1)
        THEN
            Add_Error (
                   'ПОМИЛКА! В анкеті "'
                || l_pib
                || '", у розділі "Ознака роботи (зайнятості)" необхідно зазначити ТІЛЬКИ ОДНУ ознаку');
        END IF;

        SELECT MAX (CASE WHEN apda_nda IN (91, 762) THEN a.apda_val_dt END),
               COUNT (
                   CASE
                       WHEN apda_nda IN (91, 762) AND a.apda_val_dt < SYSDATE
                       THEN
                           1
                   END)
          INTO l_birth_dt, l_child_cnt
          FROM ap_person  t
               JOIN ap_document d ON (d.apd_app = t.app_id)
               JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
         WHERE     t.app_ap = g_Ap_Id
               AND t.history_status = 'A'
               AND d.history_status = 'A'
               AND a.history_status = 'A'
               AND (   a.apda_nda IN (91) AND d.apd_ndt IN (37)
                    OR a.apda_nda IN (762) AND d.apd_ndt IN (673));

        IF (g_Ap_Is_Second = 'T')
        THEN
            RETURN;
        END IF;

        SELECT MAX (CASE WHEN apda_nda = 2633 THEN a.apda_val_string END),
               MAX (
                   CASE
                       WHEN apda_nda IN (642, 644) THEN a.apda_val_string
                   END),
               MAX (CASE WHEN apda_nda IN (8377) THEN a.apda_val_string END),
               NVL (
                   MAX (
                       CASE
                           WHEN apda_nda IN (8483) THEN a.apda_val_string
                       END),
                   'F'),
                 MAX (CASE WHEN apda_nda = 2580 THEN a.apda_val_dt END)
               - MAX (CASE WHEN apda_nda = 2579 THEN a.apda_val_dt END)
               + 1,
               MAX (CASE WHEN apda_nda = 2580 THEN a.apda_val_dt END)
          INTO l_is_chornobyl,
               l_is_opikun,
               l_is_view_pology,
               l_is_dead_child,
               l_cnt,
               l_close_dt
          FROM ap_person  t
               JOIN ap_document d ON (d.apd_app = t.app_id)
               JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
         WHERE     t.app_ap = g_Ap_Id
               AND t.app_tp = 'Z'
               AND t.history_status = 'A'
               AND d.history_status = 'A'
               AND a.history_status = 'A'
               AND (       a.apda_nda IN (2633,
                                          642,
                                          644,
                                          8377)
                       AND d.apd_ndt IN (605)
                    OR     a.apda_nda IN (2580,
                                          2579,
                                          2580,
                                          8483)
                       AND d.apd_ndt IN (10196));

        -- #93223
        IF (       ABS (MONTHS_BETWEEN (g_Ap_Reg_Dt, l_close_dt)) > 6
               AND g_Ap_Reg_Dt > l_close_dt
            OR     ABS (MONTHS_BETWEEN (g_Ap_Reg_Dt, l_birth_dt)) > 2
               AND g_Ap_Reg_Dt > l_birth_dt)
        THEN
            raise_application_error (-20000,
                                     'Порушено термін подання звернення');
        END IF;

        -- #104383
        IF (l_is_dead_child = 'T' AND l_cnt != 70)
        THEN
            raise_application_error (
                -20000,
                'Кількість днів у лікарняному не є вірним!');
        -- #101384
        ELSIF (l_is_dead_child != 'T' AND l_is_view_pology = 'T')
        THEN
            IF (   l_is_chornobyl = 'T' AND l_cnt != 90
                OR     (l_is_chornobyl IS NULL OR l_is_chornobyl = 'F')
                   AND l_cnt != 56
                OR l_cnt IS NULL)
            THEN
                raise_application_error (
                    -20000,
                    'Кількість днів у лікарняному не є вірним!');
            END IF;
        -- #98275
        ELSIF (    l_is_dead_child != 'T'
               AND l_is_opikun = 'T'
               AND l_child_cnt > 1)
        THEN
            IF (   l_is_chornobyl = 'T' AND l_cnt != 90
                OR     (l_is_chornobyl IS NULL OR l_is_chornobyl = 'F')
                   AND l_cnt != 70
                OR l_cnt IS NULL)
            THEN
                raise_application_error (
                    -20000,
                    'Кількість днів у лікарняному не є вірним!');
            END IF;
        ELSIF (l_is_dead_child != 'T' AND l_is_opikun = 'T')
        THEN
            IF (   l_is_chornobyl = 'T' AND l_cnt != 90
                OR     (l_is_chornobyl IS NULL OR l_is_chornobyl = 'F')
                   AND l_cnt != 56
                OR l_cnt IS NULL)
            THEN
                raise_application_error (
                    -20000,
                    'Кількість днів у лікарняному не є вірним!');
            END IF;
        ELSIF (    l_is_dead_child != 'T'
               AND (   l_is_chornobyl = 'T' AND l_cnt != 180
                    OR     (l_is_chornobyl IS NULL OR l_is_chornobyl = 'F')
                       AND l_cnt != 126
                    OR l_cnt IS NULL))
        THEN
            raise_application_error (
                -20000,
                'Кількість днів у лікарняному не є вірним!');
        END IF;

        -- #95061 , #95055
        SELECT MAX (CASE WHEN apda_nda = 690 THEN a.apda_val_string END),
               MAX (CASE WHEN apda_nda = 2581 THEN a.apda_val_string END)
          INTO l_is_chornobyl, l_is_opikun
          FROM ap_person  t
               JOIN ap_document d ON (d.apd_app = t.app_id)
               JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
         WHERE     t.app_ap = g_Ap_Id
               AND t.app_tp = 'Z'
               AND t.history_status = 'A'
               AND d.history_status = 'A'
               AND a.history_status = 'A'
               AND (   a.apda_nda IN (690) AND d.apd_ndt IN (98)
                    OR a.apda_nda IN (2581) AND d.apd_ndt IN (10196));

        -- #95061
        IF (l_is_chornobyl NOT IN ('D', 'U'))
        THEN
            Add_Error (
                'Форма навчання (денна, дуальна, заочна)" обрано заочну форму навчання. Право на отримання допомоги мають вагітні жінки, що навчаються за денною або дуальною формою навчання!');
        END IF;

        -- #95055
        SELECT MAX (z.dic_name)
          INTO l_pib
          FROM uss_ndi.v_DDN_MTR_LEAVE_ST z
         WHERE z.dic_value = l_is_opikun;

        IF (l_is_opikun NOT IN ('RD'))
        THEN
            Add_Error (
                   '"Помилка! В документі "Лікарняний у зв`язку з вагітністю та пологами", в позиції "Статус лікарняного" обрано статус лікарняного "'
                || l_pib
                || '", що не підлягає виплаті.');
        END IF;

        -- #98208
        SELECT CASE
                   WHEN is_opikun = 'T' AND dt1 > sick_dt THEN 1
                   WHEN is_ysunovlyvach = 'T' AND dt2 > sick_dt THEN 2
                   ELSE 0
               END
          INTO l_cnt
          FROM (SELECT MAX (
                           CASE
                               WHEN apda_nda = 642 THEN a.apda_val_string
                           END)
                           AS is_opikun,
                       MAX (
                           CASE
                               WHEN apda_nda = 644 THEN a.apda_val_string
                           END)
                           AS is_ysunovlyvach,
                       MAX (CASE WHEN apda_nda = 2579 THEN a.apda_val_dt END)
                           AS sick_dt,
                       MAX (CASE WHEN apda_nda = 715 THEN a.apda_val_dt END)
                           AS dt1,
                       MAX (CASE WHEN apda_nda = 708 THEN a.apda_val_dt END)
                           AS dt2
                  FROM ap_person  t
                       JOIN ap_document d ON (d.apd_app = t.app_id)
                       JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                 WHERE     t.app_ap = g_Ap_Id
                       AND t.app_tp = 'Z'
                       AND t.history_status = 'A'
                       AND d.history_status = 'A'
                       AND a.history_status = 'A'
                       AND (       a.apda_nda IN (642, 644)
                               AND d.apd_ndt IN (605)
                            OR a.apda_nda IN (2579) AND d.apd_ndt IN (10196)
                            OR a.apda_nda IN (715) AND d.apd_ndt IN (660)
                            OR a.apda_nda IN (708) AND d.apd_ndt IN (114)));

        IF (l_cnt = 1)
        THEN
            Add_Error (
                'В документі "Рішення суду про встановлення опіки чи піклування над дитиною-сиротою або дитиною, позбавленою батьківського піклування" дата початку дії не відповідає даті відкриття в документі "Лікарняний у зв`язку з вагітністю та пологами');
        ELSIF (l_cnt = 2)
        THEN
            Add_Error (
                'В документі "Рішення суду про усиновлення дитини" дата початку дії не відповідає даті відкриття в документі "Лікарняний у зв`язку з вагітністю та пологами');
        END IF;
    END;


    PROCEDURE check_901_service
    IS
        l_cnt        NUMBER;
        l_flag       VARCHAR2 (10);
        l_pib        VARCHAR2 (500);
        l_dt1        DATE;
        l_birth_dt   DATE;
        l_cur_org    NUMBER := tools.getcurrorg;
    BEGIN
        IF g_ap_tp != 'V'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 901
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        -- #93246
        /*SELECT MAX(CASE WHEN apda_nda = 2663 THEN a.apda_val_string END),
               MAX(CASE WHEN apda_nda = 91 THEN a.apda_val_dt END)
          INTO l_flag, l_birth_dt
          FROM ap_person t
          JOIN ap_document d ON (d.apd_app = t.app_id)
          JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
         WHERE t.app_ap = g_Ap_Id
           AND t.app_tp = 'FP'
           AND t.history_status = 'A'
           AND d.history_status = 'A'
           AND a.history_status = 'A'
           AND (a.apda_nda IN (2663) AND d.apd_ndt IN (650)
               OR a.apda_nda IN (91) AND d.apd_ndt IN (37));

        IF (l_flag = 'T' AND abs(months_between(g_Ap_Reg_Dt, l_birth_dt)) <= 12) THEN
          Add_Fatal('В анкеті ознака "Дитина віком до одного року" не відповідає даті народження утриманця!');
        END IF;*/

        -- #95109
        -- #113194 закоментував
        /*FOR xx in (SELECT MAX(CASE WHEN apda_nda = 2688 THEN a.apda_val_dt END) AS dt1,
                          MAX(CASE WHEN apda_nda = 2689 THEN a.apda_val_dt END) AS dt2,
                          MAX(t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn) AS pib,
                          t.app_id
                     FROM ap_person t
                     JOIN ap_document d ON (d.apd_app = t.app_id)
                     JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                    WHERE t.app_ap = g_Ap_Id
                      AND t.app_tp = 'FP'
                      AND t.history_status = 'A'
                      AND d.history_status = 'A'
                      AND a.history_status = 'A'
                      AND a.apda_nda IN (2688, 2689) AND d.apd_ndt IN (10205)
                    GROUP BY app_id)
        LOOP
          IF (abs(months_between(xx.dt1, xx.dt2)) > 3) THEN
            Add_Error('Помилка! В документі "Копія наказу служби у справах дітей про передачу дитини до сім’ї патронатного вихователя" для учасника звернення "' || xx.pib || '", термін перебування в сім`ї патронатного вихователя вказано не вірно');
          END IF;
        END LOOP;*/

        -- #95993
        FOR xx
            IN (  SELECT MAX (
                             CASE
                                 WHEN apda_nda = 802 THEN a.apda_val_string
                             END)
                             AS flag,
                         MAX (t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn)
                             AS pib,
                         t.app_id
                    FROM ap_person t
                         JOIN ap_document d ON (d.apd_app = t.app_id)
                         JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                   WHERE     t.app_ap = g_Ap_Id
                         AND t.app_tp = 'FP'
                         AND t.history_status = 'A'
                         AND d.history_status = 'A'
                         AND a.history_status = 'A'
                         AND a.apda_nda IN (802)
                         AND d.apd_ndt IN (507)
                GROUP BY app_id)
        LOOP
            IF (xx.flag IS NOT NULL AND xx.flag NOT IN ('28', '4'))
            THEN
                Add_Warning (
                       'Для "'
                    || xx.pib
                    || '" в документі "Довідка про доходи", в полі "вид доходу" є можливість обрати пункт "Соціальна стипендія" або "Стипендія"');
            END IF;
        END LOOP;

        -- #96041
        FOR xx
            IN (  SELECT MAX (t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn)
                             AS pib,
                         dt.ndt_name
                             AS doc,
                         t.app_id,
                         d.apd_id
                    FROM ap_person t
                         JOIN ap_document d ON (d.apd_app = t.app_id)
                         JOIN uss_ndi.v_ndi_document_type dt
                             ON (dt.ndt_id = d.apd_ndt)
                         JOIN uss_ndi.v_ndi_document_attr at
                             ON (at.nda_ndt = d.apd_ndt)
                         JOIN uss_ndi.v_ndi_param_type pt
                             ON (pt.pt_id = at.nda_pt)
                         LEFT JOIN ap_document_attr a
                             ON (    a.apda_apd = d.apd_id
                                 AND a.apda_nda = AT.nda_id
                                 AND a.history_status = 'A')
                   WHERE     t.app_ap = g_Ap_Id
                         --AND t.app_tp = 'FP'
                         AND t.history_status = 'A'
                         AND d.history_status = 'A'
                         AND d.apd_ndt IN (10204, 10205, 10206)
                         AND a.apda_val_int IS NULL
                         AND a.apda_val_dt IS NULL
                         AND (    a.apda_val_string IS NULL
                              AND pt.pt_edit_type != 'CHECK')
                         AND a.apda_val_id IS NULL
                         AND a.apda_val_sum IS NULL
                GROUP BY app_id, d.apd_id, dt.ndt_name)
        LOOP
            Add_Warning (
                   'Помилка. Для "'
                || xx.pib
                || '" в документі "'
                || xx.doc
                || '" необхідно заповнити всі атрибути');
        END LOOP;

        -- #113394
        SELECT COUNT (*)
          INTO l_cnt
          FROM ap_person t
         WHERE     t.app_ap = g_Ap_Id
               AND t.app_tp = 'FP'
               AND t.history_status = 'A';

        IF (l_cnt = 0)
        THEN
            Add_Error (
                'Учасниками звернення є не тільки "Заявник", а також потрібно вказати всіх утриманців, які будуть влаштовані в сім`ю патронатного вихователя');
        END IF;

        -- #114503
        SELECT COUNT (*)
          INTO l_cnt
          FROM ap_person t
         WHERE     t.app_ap = g_Ap_Id
               AND t.app_tp NOT IN ('Z', 'FP')
               AND t.history_status = 'A';

        IF (l_cnt > 0)
        THEN
            Add_Error (
                'учасниками звернення мають бути тільки заявник (патронатний вихователь) та утриманці (діти, що влаштовані в сім`ю патронатного вихователя)');
        END IF;

        -- #114244
        DELETE FROM tmp_work_ids1;

        INSERT INTO tmp_work_ids1 (x_id)
            SELECT 10205 FROM DUAL
            UNION
            SELECT 10204 FROM DUAL
            UNION
            SELECT 10206 FROM DUAL
            UNION
            SELECT 10321 FROM DUAL
            UNION
            SELECT 154 FROM DUAL;

        check_attachment ();
    END;

    -- це послуга 250....
    /*PROCEDURE check_1081_service
    IS
      l_cnt NUMBER;
      l_flag VARCHAR2(10);
      l_pib VARCHAR2(500);
      l_dt1 DATE;
      l_dt2 DATE;
    BEGIN
      IF g_ap_tp != 'V' THEN
        RETURN;
      END IF;

      SELECT COUNT(1)
        INTO l_cnt
        FROM Ap_Service s
       WHERE s.Aps_Ap = g_Ap_Id
         AND s.aps_nst = 1081;

      IF l_cnt = 0 THEN
        RETURN;
      END IF;

      -- #99043
      FOR xx in (SELECT MAX(CASE WHEN apda_nda = 91 THEN a.apda_val_dt END) AS dt1,
                        MAX(CASE WHEN apda_nda = 762 THEN a.apda_val_dt END) AS dt2,
                        MAX(t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn) AS pib,
                        t.app_id
                   FROM ap_person t
                   JOIN ap_document d ON (d.apd_app = t.app_id)
                   JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                  WHERE t.app_ap = g_Ap_Id
                    AND t.app_tp = 'FP'
                    AND t.history_status = 'A'
                    AND d.history_status = 'A'
                    AND a.history_status = 'A'
                    AND (a.apda_nda IN (91) AND d.apd_ndt IN (37) OR a.apda_nda IN (762) AND d.apd_ndt IN (673))
                  GROUP BY app_id)
      LOOP
        IF (nvl(xx.dt1, xx.dt2) is NULL OR Abs(Months_Between(g_Ap_Reg_Dt, nvl(xx.dt1, xx.dt2))) > 12) THEN
          Add_Error('Помилка! Допомога при народженні дитини призначається якщо звернення надійшло не пізніше ніж за 12 календарних місяців після народження дитини.');
        END IF;
      END LOOP;

    END;*/

    -- #93246
    PROCEDURE check_275_service
    IS
        l_cnt     NUMBER;
        l_flag1   VARCHAR2 (10);
        l_flag2   VARCHAR2 (10);
        l_pib     VARCHAR (500);
    BEGIN
        IF g_ap_tp != 'V'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 275
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        SELECT MAX (CASE WHEN apda_nda = 1858 THEN a.apda_val_string END),
               MAX (CASE WHEN apda_nda = 2654 THEN a.apda_val_string END),
               COUNT (app_id)
          INTO l_flag1, l_flag2, l_cnt
          FROM ap_person  t
               JOIN ap_document d ON (d.apd_app = t.app_id)
               JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
         WHERE     t.app_ap = g_Ap_Id
               AND t.app_tp = 'ANF'
               AND t.history_status = 'A'
               AND d.history_status = 'A'
               AND a.history_status = 'A'
               AND a.apda_nda IN (1858, 2654)
               AND d.apd_ndt IN (605);

        IF (l_cnt > 0 AND (l_flag1 IS NULL OR l_flag1 = 'F' OR l_flag2 = 'T'))
        THEN
            Add_Fatal (
                'Для учасника звернення "Інший батько/вихователь" невірно обраний підтип учасника звернення');
        END IF;


        -- #94462
        SELECT CASE WHEN a_1 = 'T' AND (a_2 = 'T' OR a_3 = 'T') THEN 1 END
          INTO l_cnt
          FROM (SELECT MAX (
                           CASE
                               WHEN apda_nda = 1858 THEN a.apda_val_string
                           END)    AS a_1,
                       MAX (
                           CASE
                               WHEN apda_nda = 2654 THEN a.apda_val_string
                           END)    AS a_2,
                       MAX (
                           CASE
                               WHEN apda_nda = 2660 THEN a.apda_val_string
                           END)    AS a_3,
                       COUNT (app_id)
                  --INTO l_flag1, l_flag2, l_cnt
                  FROM ap_person  t
                       JOIN ap_document d ON (d.apd_app = t.app_id)
                       JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                 WHERE     t.app_ap = g_Ap_Id
                       AND t.app_tp = 'Z'
                       AND t.history_status = 'A'
                       AND d.history_status = 'A'
                       AND a.history_status = 'A'
                       AND a.apda_nda IN (1858, 2654, 2660)
                       AND d.apd_ndt IN (605));

        IF (l_cnt = 1)
        THEN
            Add_Fatal (
                'Для типу учасника звернення "заявник" при виборі в анкеті атрибуту "Батько/мати-вихователь дитячого будинку сімейного типу" не можна вибирати атрибути "Прийомні батьки (батько/мати)" та "Дитина, яка влаштована до прийомної сім`ї"');
        END IF;

        SELECT CASE WHEN a_1 = 'T' AND (a_2 = 'T' OR a_3 = 'T') THEN 1 END
          INTO l_cnt
          FROM (SELECT MAX (
                           CASE
                               WHEN apda_nda = 2654 THEN a.apda_val_string
                           END)    AS a_1,
                       MAX (
                           CASE
                               WHEN apda_nda = 1858 THEN a.apda_val_string
                           END)    AS a_2,
                       MAX (
                           CASE
                               WHEN apda_nda = 2659 THEN a.apda_val_string
                           END)    AS a_3,
                       COUNT (app_id)
                  --INTO l_flag1, l_flag2, l_cnt
                  FROM ap_person  t
                       JOIN ap_document d ON (d.apd_app = t.app_id)
                       JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                 WHERE     t.app_ap = g_Ap_Id
                       AND t.app_tp = 'Z'
                       AND t.history_status = 'A'
                       AND d.history_status = 'A'
                       AND a.history_status = 'A'
                       AND a.apda_nda IN (2654, 1858, 2659)
                       AND d.apd_ndt IN (605));

        IF (l_cnt = 1)
        THEN
            Add_Fatal (
                'Для типу учасника звернення "заявник" при виборі в анкеті атрибуту "Прийомні батьки (батько/мати)" не можна вибирати атрибути "Батько/мати-вихователь дитячого будинку сімейного типу" та "Дитина, яка влаштована до дитячого будинку сімейного типу"');
        END IF;


        -- #94947
        SELECT CASE WHEN a_1 = 'T' AND a_2 = 'T' THEN 1 END, pib
          INTO l_cnt, l_pib
          FROM (SELECT MAX (
                           CASE
                               WHEN apda_nda = 2659 THEN a.apda_val_string
                           END)
                           AS a_1,
                       MAX (
                           CASE
                               WHEN apda_nda = 2660 THEN a.apda_val_string
                           END)
                           AS a_2,
                       MAX (t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn)
                           AS pib,
                       COUNT (app_id)
                  --INTO l_flag1, l_flag2, l_cnt
                  FROM ap_person  t
                       JOIN ap_document d ON (d.apd_app = t.app_id)
                       JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                 WHERE     t.app_ap = g_Ap_Id
                       AND t.app_tp = 'FP'
                       AND t.history_status = 'A'
                       AND d.history_status = 'A'
                       AND a.history_status = 'A'
                       AND a.apda_nda IN (2659, 2660)
                       AND d.apd_ndt IN (605));

        IF (l_cnt = 1)
        THEN
            Add_Error (
                   'ПОМИЛКА! Для утриманця "'
                || l_pib
                || '" в анкеті одночасно НЕМОЖЛИВО встановити ознаку "Дитина, яка влаштована до дитячого будинку сімейного типу" та "Дитина, яка влаштована до прийомної сім`ї"');
        END IF;

        -- #103089
        SELECT MAX (flag), MAX (pib)
          INTO l_cnt, l_pib
          FROM (SELECT 1                                                 AS flag,
                       t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn    AS pib
                  FROM ap_person  t
                       JOIN ap_document d ON (d.apd_app = t.app_id)
                       JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                 WHERE     t.app_ap = g_Ap_Id
                       AND t.app_tp = 'FP'
                       AND t.history_status = 'A'
                       AND d.history_status = 'A'
                       AND a.history_status = 'A'
                       AND a.apda_nda IN (856)
                       AND d.apd_ndt IN (98)
                       AND a.apda_val_string = 'T'
                 FETCH FIRST ROW ONLY);

        IF (l_cnt = 1)
        THEN
            Add_Warning (
                   'Для «'
                || l_pib
                || '» в документі «Довідка про навчання» встановлена ознака «На повному державному утриманні». Державна соціальна допомога може бути призначена ТІЛЬКИ за умови, що особа НЕ ПЕРЕБУВАЄ на повному державному утриманні. Перевірте правильність внесення інформації.');
        END IF;
    END;

    -- #99406
    PROCEDURE check_241_service
    IS
        l_cnt   NUMBER;
        l_dt1   DATE;
        l_dt2   DATE;
    BEGIN
        IF g_ap_tp != 'V'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 241
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM ap_person t
         WHERE     t.app_ap = g_Ap_Id
               AND t.app_tp IN ('Z', 'DP')
               AND t.history_status = 'A';

        IF (l_cnt < 2)
        THEN
            Add_Error (
                'У розділі "Учасники звернення" потрібно додати учасника з типом "Померла особа"');
        END IF;

        -- #99999
        SELECT MAX (CASE WHEN apda_nda IN (222) THEN a.apda_val_dt END),
               MAX (CASE WHEN apda_nda IN (7260) THEN a.apda_val_dt END)
          INTO l_dt1, l_dt2
          FROM ap_person  t
               JOIN ap_document d ON (d.apd_app = t.app_id)
               JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
         WHERE     t.app_ap = g_Ap_Id
               AND t.history_status = 'A'
               AND d.history_status = 'A'
               AND a.history_status = 'A'
               AND (   a.apda_nda IN (222) AND d.apd_ndt IN (89)
                    OR a.apda_nda IN (7260) AND d.apd_ndt IN (10295));

        IF (l_dt1 != l_dt2)
        THEN
            Add_Error (
                'В документах "Свідоцтво РАГС про смерть" та "Витяг з ДРАЦC про смерть для отримання допомоги на поховання" зазначені різні дати смерті померлої особи.');
        END IF;

        IF (l_dt1 >= g_Ap_Reg_Dt)
        THEN
            Add_Error (
                'Перевірте внесену дату смерті померлої особи в документі "Свідоцтво РАГС про смерть"');
        END IF;

        IF (l_dt2 >= g_Ap_Reg_Dt)
        THEN
            Add_Error (
                'Перевірте внесену дату смерті померлої особи в документі "Витяг з ДРАЦC про смерть для отримання допомоги на поховання"');
        END IF;
    END;

    -- #102172
    PROCEDURE check_1141_service
    IS
        l_cnt   NUMBER;
    BEGIN
        IF g_ap_tp != 'REG'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 1141
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        /* FOR xx IN (SELECT cnt, pib
                      FROM (SELECT COUNT(a.apda_id) AS cnt, p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn AS pib
                              FROM ap_document t
                              JOIN ap_person p ON (p.app_id = t.apd_app)
                              JOIN ap_document_attr a ON (a.apda_apd = t.apd_id)
                             WHERE t.apd_ap = g_Ap_Id
                               AND t.history_status = 'A'
                               AND p.history_status = 'A'
                               AND a.history_status = 'A'
                               AND a.apda_nda IN (8420, 8421)
                               AND a.apda_val_string = 'T'
                             GROUP BY p.app_id, p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn
                           )
                     WHERE cnt > 1)
         LOOP
           Add_Fatal('Для учасника "' || xx.pib || '" встановлено одразу підтип заявника "Ветеран" і "Член сім`ї", але можна вибрати лише щось одне!');
         END LOOP;*/

        /*FOR xx IN ( SELECT p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn AS pib
                      FROM ap_document t
                      JOIN ap_person p ON (p.app_id = t.apd_app)
                      JOIN ap_document_attr a1 ON (a1.apda_apd = t.apd_id AND a1.apda_nda = 8420 AND a1.apda_val_string = 'T')
                      JOIN ap_document_attr a2 ON (a2.apda_apd = t.apd_id AND a2.apda_nda = 649 AND a2.apda_val_string = 'HW')
                      JOIN ap_document_attr a3 ON (a3.apda_apd = t.apd_id AND a3.apda_nda = 8422 AND (a3.apda_val_string IS NULL OR a3.apda_val_string = 'F'))
                     WHERE t.apd_ap = g_Ap_Id
                       AND t.history_status = 'A'
                       AND p.history_status = 'A'
                       AND a1.history_status = 'A'
                       AND a2.history_status = 'A'
                       AND a3.history_status = 'A'
                       and not exists
                         (SELECT *
                            FROM ap_document tz
                            JOIN ap_document_attr az1 ON (az1.apda_apd = tz.apd_id AND az1.apda_nda = 8421 AND az1.apda_val_string = 'T')
                            JOIN ap_document_attr az2 ON (az2.apda_apd = tz.apd_id AND az2.apda_nda = 649 AND az2.apda_val_string = 'Z')
                            JOIN ap_document_attr az3 ON (az3.apda_apd = tz.apd_id AND az3.apda_nda = 8422 AND az3.apda_val_string = 'T')
                           WHERE tz.apd_ap = g_Ap_Id
                             AND tz.history_status = 'A'
                             AND az1.history_status = 'A'
                             AND az2.history_status = 'A'
                             AND az3.history_status = 'A')
                  )
        LOOP
          Add_Error('Для учасника "' || xx.pib || '" потрібно встановити категорію "Чоловік/дружина ветерана"');
        END LOOP;*/

        -- #112540
        FOR xx
            IN (WITH
                    dat
                    AS
                        (SELECT 70 ndt_id, 149 nda_id FROM DUAL
                         UNION
                         SELECT 70 ndt_id, 150 nda_id FROM DUAL
                         UNION
                         SELECT 70 ndt_id, 151 nda_id FROM DUAL
                         UNION
                         SELECT 71 ndt_id, 152 nda_id FROM DUAL
                         UNION
                         SELECT 71 ndt_id, 153 nda_id FROM DUAL
                         UNION
                         SELECT 71 ndt_id, 154 nda_id FROM DUAL
                         UNION
                         SELECT 115 ndt_id, 276 nda_id FROM DUAL
                         UNION
                         SELECT 115 ndt_id, 278 nda_id FROM DUAL
                         UNION
                         SELECT 115 ndt_id, 277 nda_id FROM DUAL
                         UNION
                         SELECT 115 ndt_id, 2565 nda_id FROM DUAL
                         UNION
                         SELECT 115 ndt_id, 2564 nda_id FROM DUAL)
                SELECT p.app_ln || ' ' || p.app_ln || ' ' || p.app_ln
                           AS pib,
                       dt.ndt_name,
                       da.nda_name
                  FROM ap_person  p
                       JOIN ap_document t ON (t.apd_app = p.app_id)
                       JOIN ap_document_attr a ON (a.apda_apd = t.apd_id)
                       JOIN dat d
                           ON (d.ndt_id = t.apd_ndt AND d.nda_id = a.apda_nda)
                       JOIN uss_ndi.v_ndi_document_type dt
                           ON (dt.ndt_id = t.apd_ndt)
                       JOIN uss_ndi.v_ndi_document_attr da
                           ON (da.nda_id = a.apda_nda)
                 WHERE     t.apd_ap = g_ap_id
                       AND p.history_status = 'A'
                       AND t.history_status = 'A'
                       AND a.history_status = 'A'
                       AND a.apda_val_string IS NULL
                       AND a.apda_val_dt IS NULL
                       AND a.apda_val_id IS NULL)
        LOOP
            Add_Error (
                   'В документі "'
                || xx.ndt_name
                || '" учасника "'
                || xx.pib
                || '" не заповнено "'
                || xx.nda_name
                || '"');
        END LOOP;

        -- #114549
        SELECT COUNT (t.apda_id)
          INTO l_cnt
          FROM ap_document_attr  t
               JOIN ap_document d ON (t.apda_apd = d.apd_id)
               JOIN ap_person p ON (p.app_id = d.apd_app)
         WHERE     t.apda_ap = g_Ap_Id
               AND t.apda_nda = 8333
               AND p.history_status = 'A'
               AND p.app_tp IN ('Z')
               AND t.history_status = 'A'
               AND t.apda_val_string IS NOT NULL;

        IF (l_cnt = 0 OR l_cnt IS NULL)
        THEN
            Add_Error ('Повинен бути вибраний статус пільговика!');
        END IF;

        -- #114549
        SELECT COUNT (t.apda_id)
          INTO l_cnt
          FROM ap_document_attr  t
               JOIN ap_document d ON (t.apda_apd = d.apd_id)
               JOIN ap_person p ON (p.app_id = d.apd_app)
         WHERE     t.apda_ap = g_Ap_Id
               AND t.apda_nda = 8333
               AND p.history_status = 'A'
               AND p.app_tp NOT IN ('Z')
               AND t.history_status = 'A'
               AND t.apda_val_string IS NOT NULL;

        IF (l_cnt > 0)
        THEN
            Add_Error ('Cтатус пільговика доступний лише для заявника!');
        END IF;

        -- #115742
        SELECT COUNT (t.apda_id)
          INTO l_cnt
          FROM ap_document_attr  t
               JOIN ap_document d ON (t.apda_apd = d.apd_id)
               JOIN ap_person p ON (p.app_id = d.apd_app)
         WHERE     t.apda_ap = g_Ap_Id
               AND t.apda_nda IN (8335, 8336)
               AND p.history_status = 'A'
               AND d.apd_ndt = 10305
               AND t.history_status = 'A'
               AND t.apda_val_string IS NOT NULL;

        IF (l_cnt = 0)
        THEN
            Add_Error (
                'В документі "Заява про внесення відомостей до Реєстру осіб, які мають право на пільги" повинен бути заповнений або "Номер телефону" або "Адреса електронної пошти"');
        END IF;
    /*SELECT count(ad.apd_id) as cnt
      into l_cnt
      FROM ap_document ad
     WHERE ad.apd_ap = g_ap_id
       AND ad.history_status = 'A'
       and ad.apd_ndt in (70, 71, 115);
    if (l_cnt = 0 or l_cnt is null) then
      Add_Error('В Анкеті пільговика не визначено статус ветерана війни');
    elsif (l_cnt > 1) then
      Add_Error('Право на визначення статусу ветерана війни має лише один із учасників звернення!');
    end if;*/

    /*FOR xx IN (
     with dat as (SELECT 70 ndt_id FROM dual
                  union
                  SELECT 71 ndt_id FROM dual
                  union
                  SELECT 115 ndt_id FROM dual
     )
    SELECT max(cnt)  as cnt
      FROM (
    SELECT dt.ndt_id,
           count(ad.apd_id) as cnt
      FROM dat d
      join uss_ndi.v_ndi_document_type dt on (dt.ndt_id = d.ndt_id)
      join ap_document ad on (ad.apd_ndt = dt.ndt_id)
     WHERE ad.apd_ap = g_ap_id
       AND ad.history_status = 'A'
     group by dt.ndt_id, dt.ndt_name
     )
     )
    LOOP
      if (xx.cnt > 1) then
         Add_Error('Право на визначення статусу ветерана війни має лише один із учасників звернення!');
      end if;
    END LOOP;*/
    END;

    -- #102172
    PROCEDURE check_1221_service
    IS
        l_cnt        NUMBER;
        l_Err_List   VARCHAR2 (32000);
    BEGIN
        IF g_ap_tp != 'V'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 1221
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        SELECT NVL (MAX (t.apd_id), -1)
          INTO l_cnt
          FROM ap_document t
         WHERE     t.apd_ap = g_Ap_Id
               AND t.apd_ndt = 10323
               AND t.history_status = 'A';

        l_Err_List := Api$validation.Check_Documents_Filled (l_cnt);

        IF (l_Err_List IS NOT NULL)
        THEN
            Add_Error (l_Err_List);
        END IF;

        -- #114244
        DELETE FROM tmp_work_ids1;

        INSERT INTO tmp_work_ids1 (x_id)
            SELECT 10204 FROM DUAL
            UNION
            SELECT 10321 FROM DUAL
            UNION
            SELECT 154 FROM DUAL;

        check_attachment ();
    END;

    -- #111590
    PROCEDURE check_1201_service
    IS
        l_cnt        NUMBER;
        l_Err_List   VARCHAR2 (32000);
    BEGIN
        IF g_ap_tp != 'V'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 1201
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        FOR xx
            IN (SELECT cnt, pib
                  FROM (  SELECT COUNT (a.apda_id)                                 AS cnt,
                                 p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn    AS pib
                            FROM ap_document t
                                 JOIN ap_person p ON (p.app_id = t.apd_app)
                                 JOIN ap_document_attr a
                                     ON (a.apda_apd = t.apd_id)
                           WHERE     t.apd_ap = g_Ap_Id
                                 AND t.history_status = 'A'
                                 AND p.history_status = 'A'
                                 AND a.history_status = 'A'
                                 AND a.apda_nda IN (2668, 8462)
                                 AND a.apda_val_string = 'T'
                        GROUP BY p.app_id,
                                    p.app_ln
                                 || ' '
                                 || p.app_fn
                                 || ' '
                                 || p.app_mn)
                 WHERE cnt > 1)
        LOOP
            Add_Fatal (
                   'Помилка! В анкеті учасника звернення "'
                || xx.pib
                || '" потрібно вибрати тільки один підтип заявника або "Патронатний вихователь", або "Помічник патронатного вихователя"');
        END LOOP;

        SELECT COUNT (*)
          INTO l_cnt
          FROM ap_person t
         WHERE     t.app_ap = g_Ap_Id
               AND t.history_status = 'A'
               AND t.app_tp != 'Z';

        IF (l_cnt > 0)
        THEN
            Add_Fatal (
                'Для цього типу послуги має бути тільки один учасник звернення - "Заявник".');
        END IF;

        -- #112599
        FOR xx
            IN (SELECT pib
                  FROM (SELECT p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn    AS pib
                          FROM ap_document  t
                               JOIN ap_person p ON (p.app_id = t.apd_app)
                               JOIN ap_document_attr a
                                   ON (a.apda_apd = t.apd_id)
                         WHERE     t.apd_ap = g_Ap_Id
                               AND t.history_status = 'A'
                               AND p.history_status = 'A'
                               AND a.history_status = 'A'
                               AND a.apda_nda IN (8498)
                               AND NOT (a.apda_val_dt <= (g_Ap_Reg_Dt + 30))))
        LOOP
            Add_Fatal (
                   'Помилка! В документі "Копія договору про патронат над дитиною" учасника звернення "'
                || xx.pib
                || '" дата початку діяльності повинна бути не більшою за дату подання заяви + 30 днів!');
        END LOOP;

        -- #117278
        DELETE FROM tmp_work_ids1;

        INSERT INTO tmp_work_ids1 (x_id)
            SELECT 10320 FROM DUAL;

        check_attachment ();
    END;

    -- #103441
    PROCEDURE check_21_service
    IS
        l_cnt   NUMBER;
    BEGIN
        IF g_ap_tp != 'V'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 21
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        IF (g_Ap_Reg_Dt <= TO_DATE ('27.03.2024', 'DD.MM.YYYY'))
        THEN
            Add_Fatal (
                'Постанова Кабінету Міністрів України від 22 березня 2024 р. № 331 набрала чинніть з 28.03.2024, відповідно дата звернення за допомогою "Дитина не одна" не може бути до 27.03.2024 ');
        END IF;

        -- #104451
        FOR xx
            IN (SELECT p.app_ln || ' ' || p.app_ln || ' ' || p.app_ln    AS pib
                  FROM ap_person  p
                       JOIN ap_document t ON (t.apd_app = p.app_id)
                       JOIN ap_document_attr a ON (a.apda_apd = t.apd_id)
                 WHERE     t.apd_ap = g_ap_id
                       AND t.apd_ndt = 605
                       AND a.apda_nda = 649
                       AND p.history_status = 'A'
                       AND t.history_status = 'A'
                       AND a.history_status = 'A'
                       AND a.apda_val_string IS NULL)
        LOOP
            Add_Error (
                   'В Анкеті учасника '
                || xx.pib
                || ' не заповнено "Ступінь родинного зв`язку"');
        END LOOP;
    END;

    -- #112996
    PROCEDURE check_23_service
    IS
        l_cnt   NUMBER;
    BEGIN
        IF g_ap_tp != 'VV'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 23
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM ap_person t
         WHERE t.app_ap = g_Ap_Id AND t.history_status = 'A';

        IF (l_cnt > 1)
        THEN
            Add_Error (
                'Право на використання накопичених днів має лише заявник');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM ap_person t
         WHERE     t.app_ap = g_Ap_Id
               AND t.history_status = 'A'
               AND t.app_tp = 'Z';

        IF (l_cnt = 0)
        THEN
            Add_Error (
                'Право на використання накопичених днів має лише заявник');
        END IF;

        FOR xx
            IN (SELECT cnt, pib
                  FROM (  SELECT COUNT (a.apda_id)                                 AS cnt,
                                 p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn    AS pib
                            FROM ap_document t
                                 JOIN ap_person p ON (p.app_id = t.apd_app)
                                 JOIN ap_document_attr a
                                     ON (a.apda_apd = t.apd_id)
                           WHERE     t.apd_ap = g_Ap_Id
                                 AND t.history_status = 'A'
                                 AND p.history_status = 'A'
                                 AND a.history_status = 'A'
                                 AND a.apda_nda IN (2668, 8462)
                                 AND a.apda_val_string = 'T'
                        GROUP BY p.app_id,
                                    p.app_ln
                                 || ' '
                                 || p.app_fn
                                 || ' '
                                 || p.app_mn)
                 WHERE cnt > 1)
        LOOP
            Add_Fatal (
                   'Помилка! В анкеті учасника звернення "'
                || xx.pib
                || '" потрібно вибрати тільки один підтип заявника або "Патронатний вихователь", або "Помічник патронатного вихователя"');
        END LOOP;

        SELECT COUNT (a.apda_id)
          INTO l_cnt
          FROM ap_document  t
               JOIN ap_person p ON (p.app_id = t.apd_app)
               JOIN ap_document_attr a ON (a.apda_apd = t.apd_id)
         WHERE     t.apd_ap = g_Ap_Id
               AND t.history_status = 'A'
               AND p.history_status = 'A'
               AND a.history_status = 'A'
               AND a.apda_nda IN (2668, 8462)
               AND a.apda_val_string = 'T';

        IF (l_cnt = 0)
        THEN
            Add_Error (
                'В анкеті має бути визначений підтип заявника - або "Помічник патронатного вихователя" або "Патронатний вихователь"');
        END IF;

        FOR xx
            IN (  SELECT MAX (CASE WHEN apda_nda = 8626 THEN a.apda_val_dt END)
                             AS dt1,
                         MAX (CASE WHEN apda_nda = 8625 THEN a.apda_val_dt END)
                             AS dt2,
                         MAX (CASE WHEN apda_nda = 8624 THEN a.apda_val_dt END)
                             AS dt3,
                         MAX (
                             CASE WHEN apda_nda = 8627 THEN a.apda_val_int END)
                             AS cnt,
                         MAX (t.app_ln || ' ' || t.app_fn || ' ' || t.app_mn)
                             AS pib,
                         t.app_id
                    FROM ap_person t
                         JOIN ap_document d ON (d.apd_app = t.app_id)
                         JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                   WHERE     t.app_ap = g_Ap_Id
                         AND t.app_tp = 'Z'
                         AND t.history_status = 'A'
                         AND d.history_status = 'A'
                         AND a.history_status = 'A'
                         AND (       a.apda_nda IN (8626, 8625, 8627)
                                 AND d.apd_ndt IN (10342)
                              OR a.apda_nda IN (8624) AND d.apd_ndt IN (10341))
                GROUP BY app_id)
        LOOP
            IF (xx.cnt IS NULL OR (xx.dt1 - xx.dt2 + 1) != xx.cnt)
            THEN
                Add_Error (
                    'Кількість днів відпустки визначена не вірно, потрібно перевірити вказані дати початку та завершення відпустки');
            END IF;

            -- #113187
            IF (xx.dt3 >= xx.dt2)
            THEN
                Add_Error (
                    'Дата початку надання відпустки має бути після дати вибуття всіх дітей');
            END IF;

            -- #113675
            IF (xx.cnt > 24 OR xx.cnt IS NULL)
            THEN
                Add_Error (
                    'В документі "Заява про використання накопичених днів", тривалість відпустки не повинна бути більша ніж 24 календарних дні.');
            END IF;
        END LOOP;
    END;


    -- #113400
    PROCEDURE check_22_service
    IS
        l_cnt      NUMBER;
        l_str      VARCHAR2 (10);
        l_sc_id    NUMBER;
        l_scd_id   NUMBER;
        l_apd_id   NUMBER;
    BEGIN
        IF g_ap_tp != 'DD'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Service s
         WHERE     s.Aps_Ap = g_Ap_Id
               AND s.aps_nst = 22
               AND s.history_status = 'A';

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        IF (g_Ap_Reg_Dt < TO_DATE ('01.01.2025', 'DD.MM.YYYY'))
        THEN
            Add_Fatal (
                'Заяви про забезпечення засобами реабілітації (ДЗР) дозволено  реєструвати в ЄІССС починаючи з 01.01.2025');
        END IF;

        -- #116774
        SELECT MAX (t.apda_val_string), MAX (t.apda_apd)
          INTO l_str, l_apd_id
          FROM ap_document_attr t
         WHERE     t.apda_ap = g_Ap_Id
               AND t.apda_nda = 9016
               AND t.history_status = 'A';

        IF (l_str = 'T')
        THEN
            SELECT MAX (t.app_sc)
              INTO l_sc_id
              FROM ap_person t
             WHERE t.app_ap = g_Ap_Id AND t.app_tp = 'Z';

            l_scd_id := uss_person.api$sc_tools.get_sc_doc (l_sc_id, 10052);

            IF (l_scd_id IS NOT NULL)
            THEN
                /*атрибут з Ід=8634 "Населений пункт (місце проживання)" документу Ід=10344 - атрибутом з Ід=4492 "КАТОТТГ" документу Ід=10052
                атрибут з Ід=8635 "Вулиця (місця проживання)" документу Ід=10344 - атрибутом з Ід=4485 "Вулиця" документу Ід=10052
                атрибут з Ід=8636 "Будинок (місця проживання)" документу Ід=10344 - атрибутом з Ід=4487 "Будинок" документу Ід=10052
                атрибут з Ід=8637 "Корпус (місця проживання) " документу Ід=10344 - атрибутом з Ід=4488 "Корпус" документу Ід=10052
                атрибут з Ід=8638 "Квартира (місця проживання)" документу Ід=10344 - атрибутом з Ід=4489 "Квартира" документу Ід=10052*/
                api$appeal.Save_Not_Empty_Document_Attr_Id_Str (
                    p_Apda_Ap           => g_Ap_Id,
                    p_Apda_Apd          => l_apd_id,
                    p_Apda_Nda          => 8634,
                    p_Apda_Val_Id       =>
                        uss_person.api$sc_tools.get_sc_doc_val_id (
                            p_scd_id   => l_scd_id,
                            p_nda_Id   => 4492),
                    p_Apda_Val_String   =>
                        uss_person.api$sc_tools.get_sc_doc_val_str (
                            p_scd_id   => l_scd_id,
                            p_nda_Id   => 4492),
                    p_New_Id            => l_sc_id);

                api$appeal.Save_Not_Empty_Document_Attr_Str (
                    p_Apda_Ap           => g_Ap_Id,
                    p_Apda_Apd          => l_apd_id,
                    p_Apda_Nda          => 8635,
                    p_Apda_Val_String   =>
                        uss_person.api$sc_tools.get_sc_doc_val_str (
                            p_scd_id   => l_scd_id,
                            p_nda_Id   => 4485),
                    p_New_Id            => l_sc_id);

                api$appeal.Save_Not_Empty_Document_Attr_Str (
                    p_Apda_Ap           => g_Ap_Id,
                    p_Apda_Apd          => l_apd_id,
                    p_Apda_Nda          => 8636,
                    p_Apda_Val_String   =>
                        uss_person.api$sc_tools.get_sc_doc_val_str (
                            p_scd_id   => l_scd_id,
                            p_nda_Id   => 4487),
                    p_New_Id            => l_sc_id);

                api$appeal.Save_Not_Empty_Document_Attr_Str (
                    p_Apda_Ap           => g_Ap_Id,
                    p_Apda_Apd          => l_apd_id,
                    p_Apda_Nda          => 8637,
                    p_Apda_Val_String   =>
                        uss_person.api$sc_tools.get_sc_doc_val_str (
                            p_scd_id   => l_scd_id,
                            p_nda_Id   => 4488),
                    p_New_Id            => l_sc_id);

                api$appeal.Save_Not_Empty_Document_Attr_Str (
                    p_Apda_Ap           => g_Ap_Id,
                    p_Apda_Apd          => l_apd_id,
                    p_Apda_Nda          => 8638,
                    p_Apda_Val_String   =>
                        uss_person.api$sc_tools.get_sc_doc_val_str (
                            p_scd_id   => l_scd_id,
                            p_nda_Id   => 4489),
                    p_New_Id            => l_sc_id);
            ELSE
                Add_Error (
                    'В "Заяві про забезпечення засобом реабілітації (ДЗР)" встановлено "так" в атрибуті "Адреса за даними довідки ВПО", проте за даними з ЄІБД ВПО, завантаженими в ЄІССС, відсутня інформація щодо наявності актуальної довідки ВПО у Заявника');
            END IF;
        END IF;
    END;

    PROCEDURE Validate_Services
    IS
        l_cnt_srv   NUMBER (10);
    BEGIN
        --#77095 20220510
        FOR Rec
            IN (SELECT t.Nst_Name
                  FROM Ap_Service  s
                       JOIN Uss_Ndi.v_Ndi_Service_Type t
                           ON s.Aps_Nst = t.Nst_Id
                 WHERE     s.Aps_Ap = g_Ap_Id
                       AND s.History_Status = 'A'
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM Uss_Ndi.v_Ndi_Ap_Nst_Config Nanc
                                 WHERE     Nanc.Nanc_Nst = t.Nst_Id
                                       AND Nanc_Ap_Tp = g_Ap_Tp
                                       AND Nanc.History_Status = 'A'))
        LOOP
            Add_Warning (
                   'Тип послуги '
                || Rec.Nst_Name
                || ' не дозволено для поточного типу звернення');
        END LOOP;

        --#89920 20230720
        IF g_ap_tp IN ('V',
                       'G',
                       'SS',
                       'R.OS',
                       'R.GS')
        THEN
            FOR Rec
                IN (  SELECT s.Aps_Ap, t.Nst_Name, COUNT (s.Aps_id) AS cnt
                        FROM Ap_Service s
                             JOIN appeal a ON s.aps_ap = ap_id
                             JOIN Uss_Ndi.v_Ndi_Service_Type t
                                 ON s.Aps_Nst = t.Nst_Id
                       WHERE     s.History_Status = 'A'
                             AND NOT (s.aps_nst = 781 AND ap_src = 'DIIA') -- 92874
                             AND s.Aps_Ap = g_Ap_Id
                    GROUP BY s.Aps_Ap, t.Nst_Name
                      HAVING COUNT (s.Aps_id) > 1)
            LOOP
                Add_Error (
                       'Тип послуги '
                    || Rec.Nst_Name
                    || ' В одне звернення заборонено додавати послугу більше одного разу!');
            END LOOP;
        END IF;

        --#80949 20221024
        -- Додати контроль при збереженні звернення (якщо можна раніше, то і раніше) о неможливості створення звернення з такою послугою вручну.
        -- У нас додана ця послуга для звернень. отриманих від дії
        IF g_Ap_Src = 'DIIA'
        THEN
            RETURN;
        END IF;

        FOR Rec
            IN (SELECT t.Nst_Name
                  FROM Ap_Service  s
                       JOIN Uss_Ndi.v_Ndi_Service_Type t
                           ON s.Aps_Nst = t.Nst_Id
                 WHERE     s.Aps_Ap = g_Ap_Id
                       AND s.History_Status = 'A'
                       AND s.aps_nst = 781)
        LOOP
            Add_Fatal (
                   'Тип послуги '
                || Rec.Nst_Name
                || ' не дозволено для поточного типу звернення');
        END LOOP;

        --87730  20230530
        --Додати контроль щодо заборони у зверненнях з типом "Заява щодо змін обставин" введення двох послуг
        IF g_ap_tp = 'O'
        THEN
            SELECT COUNT (1)
              INTO l_cnt_srv
              FROM Ap_Service s
             WHERE s.Aps_Ap = g_Ap_Id AND s.history_status = 'A';

            IF l_cnt_srv > 1
            THEN
                Add_Fatal (
                    'Під час реєстрації зверненнь щодо "Зяав щодо змін обставин" не можна реєструвати кілька різних послуг, тому що різні послуги обробляються в різних чергах.');
            END IF;
        END IF;

        IF     g_ap_tp = 'G'
           AND Get_Ap_Doc_String (g_Ap_Id, 700, 954) IN ('A', 'U')
        THEN
            SELECT COUNT (1)
              INTO l_cnt_srv
              FROM Ap_Service s
             WHERE     s.Aps_Ap = g_Ap_Id
                   AND s.history_status = 'A'
                   AND s.aps_nst IS NOT NULL;

            IF l_cnt_srv = 0
            THEN
                Add_Error ('Не вказано послуги!');
            END IF;
        END IF;

        -- #87814
        -- У разі спроби отримання Витягу за пільгою із забороненого переліку, надавати повідомлення "Витяг за категорією _ не надається"

        -- #89423 20230706 (закоментовано)
        --check_961_service;

        -- #88840
        -- Реєструвати звернення по послузі з ІД=20 можуть лише органи, у яких org_org=56500 or org_org=54800.
        check_20_service;

        -- #90361
        -- Блокування введення звернень по послузі з ІД=664 в ЄСП з 01.08.2023
        check_664_service;

        -- #92104
        -- встановити контроль щодо обов'язкового вибору в анкеті одного із атрибутів у розділі "Ознака роботи (зайнятості)"
        check_251_service;

        -- #95109
        check_901_service;

        -- #94654
        check_275_service;

        -- #99043
        --check_1081_service;

        -- #99406
        check_241_service;

        -- #99988
        check_250_service;

        -- #102172
        check_1141_service;

        -- #103441
        check_21_service;

        -- #106127
        check_643_service;

        -- #108839
        check_1221_service;

        -- #111590
        check_1201_service;

        -- #112996
        check_23_service;

        -- #113400
        check_22_service;
    END;

    ---------------------------------------------------------------------
    --                    ПЕРЕВІРКА СПОСОБІВ ВИПЛАТ
    ---------------------------------------------------------------------

    -- #78680: перевірка рахунку IBAN через контрольні суми
    PROCEDURE Checkibancontrolsum (p_Num IN VARCHAR2)
    IS
        l_Sum      NUMBER := 0;
        l_Chars    VARCHAR2 (9);
        l_Number   VARCHAR2 (34)
                       := SUBSTR (p_Num, 5) || '3010' || SUBSTR (p_Num, 3, 2);
    BEGIN
        IF (   p_Num IS NULL
            OR SUBSTR (p_Num, 1, 2) != 'UA'
            OR REGEXP_INSTR (l_Number, '\D') > 0)
        THEN
            RETURN;
        END IF;

        l_Chars := SUBSTR (l_Number, 1, 9);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);

        l_Chars := l_Sum || SUBSTR (l_Number, 10, 7);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);

        l_Chars := l_Sum || SUBSTR (l_Number, 17, 7);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);

        l_Chars := l_Sum || SUBSTR (l_Number, 24, 7);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);

        l_Chars := l_Sum || SUBSTR (l_Number, LENGTH (l_Number), 1);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);

        IF (l_Sum != 1)
        THEN
            Add_Warning (
                   'Значення '
                || p_Num
                || ' в полі "розрахунковий рахунок" не є дійсним рахунком IBAN');
        END IF;
    END;

    PROCEDURE Validate_Payments
    IS
        l_Exists              BOOLEAN := FALSE;
        l_err                 VARCHAR2 (2000);

        l_Ap_Tp_Help_to_pay   BOOLEAN;
    BEGIN
        --#97566
        l_Ap_Tp_Help_to_pay :=
               g_Aps.EXISTS (248)
            OR g_Aps.EXISTS (249)
            OR g_Aps.EXISTS (251)
            OR g_Aps.EXISTS (265)
            OR g_Aps.EXISTS (267)
            OR g_Aps.EXISTS (268)
            OR g_Aps.EXISTS (269)
            OR g_Aps.EXISTS (275)
            OR g_Aps.EXISTS (862)
            OR g_Aps.EXISTS (901)
            OR g_Aps.EXISTS (241)
            OR g_Aps.EXISTS (250)
            OR g_Aps.EXISTS (21);

        FOR Rec
            IN (SELECT p.Apm_Tp,
                       t.Dic_Sname
                           Apm_Tp_Name,
                       NVL (p.Apm_Nb, pa.dppa_nb)
                           AS Apm_Nb,
                       NVL (p.Apm_Account, pa.dppa_account)
                           AS Apm_Account,
                       REGEXP_SUBSTR (p.Apm_Account, '[0-9]{6}', 5)
                           Apm_Mfo,
                       --#78157 20220622
                        (SELECT MAX (b.Nb_Id)
                           FROM Uss_Ndi.v_Ndi_Bank b
                          WHERE     b.Nb_Mfo =
                                    REGEXP_SUBSTR (p.Apm_Account,
                                                   '[0-9]{6}',
                                                   5)
                                AND b.History_Status = 'A')
                           Find_Nb_Id,
                       b.Nb_Mfo,
                       b.Nb_Name,
                       p.Apm_Index,
                       p.Apm_Kaot,
                       p.Apm_Street,
                       p.Apm_Ns,
                       p.Apm_Building,
                       p.Apm_App,
                       pa.dppa_nb,
                       pa.dppa_account
                  FROM Ap_Payment  p
                       JOIN Uss_Ndi.v_Ddn_Apm_Tp t ON p.Apm_Tp = t.Dic_Code
                       LEFT JOIN Uss_Ndi.v_Ndi_Bank b
                           ON p.Apm_Nb = b.Nb_Id AND b.History_Status = 'A'
                       LEFT JOIN Uss_Ndi.v_Ndi_Pay_Person_Acc Pa
                           ON (Pa.Dppa_Id = p.Apm_Dppa)
                 WHERE p.Apm_Ap = g_Ap_Id AND p.History_Status = 'A')
        LOOP
            IF Rec.Apm_Tp = 'BANK'
            THEN
                IF l_Ap_Tp_Help_to_pay AND Rec.Apm_App IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано учасника');
                END IF;

                IF Rec.Apm_Nb IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано банківську установу');
                END IF;

                IF Rec.Apm_Account IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано банківський рахунок');
                ELSE
                    IF NOT REGEXP_LIKE (Rec.Apm_Account,
                                        '^[U]{1}[A]{1}[0-9]{27}$')   -- #74462
                    THEN
                        Add_Warning (
                               'Значення '
                            || Rec.Apm_Account
                            || ' в полі "розрахунковий рахунок" не відповідає формату IBAN');
                    END IF;

                    -- #78680
                    Checkibancontrolsum (Rec.Apm_Account);

                    IF Rec.Apm_Account IS NOT NULL AND Rec.Find_Nb_Id IS NULL
                    THEN
                        Add_Error (
                               'Відсутня банківська установа з МФО зазначеними в ІBAN з 3 по 8 позиції у довіднику Банків, '
                            || 'перевірте правильність введеного ІBAN або перевірте наявність відповідного Банку в довіднику');
                    ELSIF Rec.Apm_Mfo IS NULL OR Rec.Apm_Mfo != Rec.Nb_Mfo
                    THEN
                        Add_Error (
                               'У введеному рахунку IBAN код банку (МФО, зазначається з 3-тої по 8-му позицію в цифровій частині IBAN) '
                            || Rec.Apm_Mfo
                            || ' не відповідає коду банку (МФО) '
                            || Rec.Nb_Mfo
                            || ' для банківської установи '
                            || Rec.Nb_Name
                            || '.');
                    END IF;

                    IF     g_Aps.EXISTS (923)
                       AND Get_Doc_String (Rec.Apm_App,
                                           605,
                                           3119,
                                           'F') = 'T'
                    THEN
                        SELECT LISTAGG (
                                      'В "Способі виплати" отримувачем коштів визначено померлу особу '
                                   || Pib (App_Ln, App_Fn, App_Mn))
                               WITHIN GROUP (ORDER BY 1)
                          INTO l_err
                          FROM ap_person
                         WHERE app_id = Rec.Apm_App;

                        Add_Error (l_err);
                    END IF;
                END IF;
            ELSIF     Rec.Apm_Tp = 'POST'
                  AND Rec.Apm_Index IS NOT NULL
                  AND REGEXP_INSTR (Rec.Apm_Index, '^\d{5}$') = 0
            THEN
                Add_Error (
                    'Поле "Індекс" у вкладці "Спосіб виплати" має містити 5 цифр.');
            ELSIF     Rec.Apm_Tp = 'POST'
                  AND (   g_Aps.EXISTS (20)
                       OR g_Aps.EXISTS (664)
                       OR l_Ap_Tp_Help_to_pay)
            THEN
                IF l_Ap_Tp_Help_to_pay AND Rec.Apm_App IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано учасника');
                END IF;

                IF Rec.Apm_Index IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано "Індекс"');
                END IF;

                IF Rec.Apm_Kaot IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано "КАТОТТГ"');
                END IF;

                IF Rec.Apm_Street IS NULL AND Rec.Apm_Ns IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано вулицю');
                END IF;

                IF Rec.Apm_Building IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано будинок');
                END IF;
            ELSIF     (   g_Aps.EXISTS (923)
                       OR l_Ap_Tp_Help_to_pay
                       OR g_Aps.EXISTS (1221)
                       OR g_Aps.EXISTS (23))
                  AND (Rec.Apm_Tp IS NULL OR Rec.Apm_App IS NULL)
            THEN
                Add_Error (
                    'В закладці "Спосіб виплати" не заповнено учасника або спосіб виплати');
            ELSIF     g_Aps.EXISTS (923)
                  AND Get_Doc_String (Rec.Apm_App,
                                      605,
                                      3119,
                                      'F') = 'T'
            THEN
                SELECT LISTAGG (
                              'В "Способі виплати" отримувачем коштів визначено померлу особу '
                           || Pib (App_Ln, App_Fn, App_Mn))
                       WITHIN GROUP (ORDER BY 1)
                  INTO l_err
                  FROM ap_person
                 WHERE app_id = Rec.Apm_App;

                Add_Error (l_err);
            ELSIF    g_Aps.EXISTS (600)
                  OR g_Aps.EXISTS (601)
                  OR g_Aps.EXISTS (602)
                  OR g_Aps.EXISTS (603)
                  OR l_Ap_Tp_Help_to_pay
            THEN
                IF Rec.Apm_Nb IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано банківську установу');
                END IF;

                IF Rec.Apm_Account IS NULL
                THEN
                    Add_Error (
                           'Тип виплати '
                        || Rec.Apm_Tp_Name
                        || ', не вказано банківський рахунок');
                ELSE
                    IF NOT REGEXP_LIKE (Rec.Apm_Account,
                                        '^[U]{1}[A]{1}[0-9]{27}$')
                    THEN                                             -- #74462
                        Add_Warning (
                               'Значення '
                            || Rec.Apm_Account
                            || ' в полі "розрахунковий рахунок" не відповідає формату IBAN');
                    END IF;

                    -- #78680
                    Checkibancontrolsum (Rec.Apm_Account);
                END IF;
            END IF;

            l_Exists := TRUE;
        END LOOP;

        IF     NOT l_Exists
           AND (   g_Aps.EXISTS (20)
                OR g_Aps.EXISTS (664)
                OR g_Aps.EXISTS (923)
                OR g_Aps.EXISTS (600)
                OR g_Aps.EXISTS (601)
                OR g_Aps.EXISTS (602)
                OR g_Aps.EXISTS (603)
                OR g_Aps.EXISTS (1221)
                OR l_Ap_Tp_Help_to_pay
                OR g_Aps.EXISTS (23))
        THEN
            Add_Error ('Не заповнено спосіб виплати');
        END IF;

        IF g_Ap_Tp = Api$appeal.c_Ap_Tp_Ehelp
        THEN
            DECLARE
                l_Duplicates_Cnt   NUMBER;
            BEGIN
                SELECT COUNT (DISTINCT pp.apm_ap)
                  INTO l_duplicates_cnt
                  FROM ap_payment  p
                       JOIN ap_payment pp
                           ON     p.apm_account = pp.apm_account
                              AND pp.apm_ap <> g_ap_id
                              AND pp.history_status = 'A'
                       JOIN appeal a
                           ON     a.ap_id = pp.apm_ap
                              AND a.ap_tp = Api$appeal.c_Ap_Tp_Ehelp
                              AND a.ap_st NOT IN ('X') --#88713 виключення відхилених звернень
                 WHERE p.apm_ap = g_ap_id AND p.history_status = 'A';

                IF l_Duplicates_Cnt > 5
                THEN
                    Add_Error (
                           'Заявка відхилена у зв’язку із наявністю помилки в IBAN.'
                        || CHR (13)
                        || CHR (10)
                        || 'Просимо повторно заповнити і подати заявку.');
                END IF;
            END;
        END IF;
    END;

    ---------------------------------------------------------------------
    --               ПЕРЕВІРКА УЧАСНИКІВ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------

    -- #78710 - перевірка контрольної суми РНОКПП
    PROCEDURE Checkinncontrolsum (p_Inn IN VARCHAR2)
    IS
        l_Sum    NUMBER := 0;
        l_Char   VARCHAR2 (1);
        l_Arr    t_Arr
                     := t_Arr (-1,
                               5,
                               7,
                               9,
                               4,
                               6,
                               10,
                               5,
                               7);
    BEGIN
        IF (p_Inn IS NULL OR LENGTH (p_Inn) < 10)
        THEN
            RETURN;
        END IF;

        IF (REGEXP_INSTR (p_Inn, '\D') > 0)
        THEN
            RETURN;
        END IF;

        FOR Idx IN 1 .. 9
        LOOP
            l_Char := SUBSTR (p_Inn, Idx, 1);
            l_Sum := l_Sum + TO_NUMBER (l_Char) * l_Arr (Idx);
        END LOOP;

        l_Char := SUBSTR (p_Inn, 10, 1);

        l_Sum := MOD (l_Sum, 11);

        IF (l_Sum = 10)
        THEN
            l_Sum := 0;
        END IF;

        IF (TO_NUMBER (l_Char) != l_Sum)
        THEN
            Add_Warning (
                   'Для учасника (РНОКПП='
                || p_Inn
                || ') контрольна сума РНОКПП невірна');
        END IF;
    END;

    PROCEDURE Validate_Persons (p_Check_Doc_Num_Attr IN BOOLEAN DEFAULT TRUE)
    IS
        l_Cnt_z     NUMBER := 0;
        l_Cnt_anf   NUMBER := 0;
        l_Cnt_ap    NUMBER := 0;
        l_Cnt_os    NUMBER := 0;
        l_Cnt_pv    NUMBER := 0;
        l_cnt       NUMBER;
        l_err       VARCHAR2 (2000);
    BEGIN
        IF g_Ap_Src IN ('PORTAL') AND g_Ap_tp = 'G'
        THEN
            RETURN;
        END IF;

        FOR Rec IN (SELECT App_Id,
                           NULLIF (App_Inn, '0000000000')     AS App_Inn,
                           App_Inn                            AS rnokpp,
                           App_Tp,
                           App_Sc,
                           App_Ln,
                           App_Fn,
                           App_Mn,
                           App_Ndt,
                           App_Doc_Num,
                           app_gender
                      FROM Ap_Person p
                     WHERE p.App_Ap = g_Ap_Id AND p.History_Status = 'A')
        LOOP
            DECLARE
                FUNCTION App_Ident
                    RETURN VARCHAR2
                IS
                BEGIN
                    IF Rec.App_Inn IS NOT NULL
                    THEN
                        RETURN 'РНОКПП=' || Rec.App_Inn;
                    ELSIF Rec.App_Doc_Num IS NOT NULL
                    THEN
                        RETURN 'документ=' || Rec.App_Doc_Num;
                    ELSE
                        RETURN    'ПІБ='
                               || Pib (Rec.App_Ln, Rec.App_Fn, Rec.App_Mn);
                    END IF;
                END;
            BEGIN
                --Add_Warning('Для учасника (' || Rec.App_Ln||' '||Rec.App_Fn||' '||Rec.App_Mn || ') App_Ndt = '||Rec.App_Ndt);

                --НЕ ОБРАНО ТИП УЧАСНИКА
                IF Rec.App_Tp IS NULL
                THEN
                    Add_Error (
                        'Для учасника (' || App_Ident || ') не обрано тип');
                END IF;

                --#75573 20220211
                IF     Rec.App_Inn IS NOT NULL
                   AND REGEXP_INSTR (Rec.App_Inn, '^\d{10}$') = 0
                   AND NOT (g_Ap_Src IN ('PORTAL', 'USS') AND g_Ap_tp = 'G')
                THEN
                    --#116395
                    Add_Fatal (
                        'РНОКПП наявний, але не відповідає шаблону (10 цифр).');
                --#84495 20230224
                ELSIF     Rec.App_Inn IS NOT NULL
                      AND p_Check_Doc_Num_Attr
                      AND Rec.App_Inn != Get_Doc_String (Rec.App_Id,
                                                         5,
                                                         1,
                                                         '_')
                      AND Get_Doc_String (Rec.App_Id,
                                          605,
                                          3119,
                                          '_') != 'T'
                      AND NOT (    g_Ap_Src IN ('PORTAL', 'USS')
                               AND (   g_Ap_tp IN ('G')               --#99009
                                    OR (    g_Ap_tp IN ('R.OS', 'SS')
                                        AND Rec.App_Tp = 'Z')))
                THEN
                    --#116395
                    Add_Fatal (
                           'Не додано документ "Довідка про присвоєння РНОКПП" або РНОКПП не відповідає в блоці "Учасники звернення" та в блоці "Документи" для особи '
                        || App_Ident);
                END IF;

                SELECT COUNT (*)
                  INTO l_cnt
                  FROM ap_document  t
                       JOIN ap_document_attr a ON (a.apda_apd = t.apd_id)
                 WHERE     t.history_status = 'A'
                       AND t.apd_ap = g_Ap_Id
                       AND t.apd_app = rec.app_id
                       AND a.history_status = 'A'
                       AND a.apda_val_string = 'T'
                       AND a.apda_nda IN (812, 640);

                IF     (l_cnt > 0 AND rec.rnokpp IS NOT NULL)
                   AND NOT (    g_Ap_Src IN ('PORTAL', 'USS')
                            AND (   g_Ap_tp IN ('G')                  --#99009
                                 OR (    g_Ap_tp IN ('R.OS', 'SS')
                                     AND Rec.App_Tp = 'Z')))
                THEN
                    Add_Fatal (
                        'Виправте помилку, в зверненні доданий документ «Довідка про присвоєння РНОКПП», при цьому в анкеті учасника звернення обрано атрибут «Відмова від використання РНОКПП»');
                END IF;

                --НЕМАЄ ЗВЯ’ЯЗКУ З СОЦ.КАРТКОЮ
                IF Rec.App_Sc IS NULL AND g_Ap_Src = Api$appeal.c_Src_Uss
                THEN
                    IF Rec.App_Tp = 'FA'
                    THEN
                        NULL;                                         --#84352
                    --Add_Warning('Для учасника (' || App_Ident || ') не визначено зв’язок з соціальною карткою');
                    ELSIF g_Ap_Tp = 'G'
                    THEN
                        NULL;                              --#86112 2023.04.07
                    --Add_Warning('Для учасника (' || App_Ident || ') не визначено зв’язок з соціальною карткою');
                    ELSIF g_Ap_Tp = 'V' AND g_org_to IN (33, 35)
                    THEN
                        NULL;                                        --#117434
                    ELSE
                        Add_Error (
                               'Для учасника ('
                            || App_Ident
                            || ') не визначено зв’язок з соціальною карткою');
                    END IF;
                END IF;

                IF Rec.App_Tp IN ('Z',
                                  'O',
                                  'AF',
                                  'AG',
                                  'OR')
                THEN
                    l_Cnt_z := l_Cnt_z + 1;
                ELSIF Rec.App_Tp IN ('AP')
                THEN
                    l_Cnt_ap := l_Cnt_ap + 1;
                ELSIF Rec.App_Tp IN ('PV')
                THEN
                    l_Cnt_pv := l_Cnt_pv + 1;
                ELSIF Rec.App_Tp IN ('ANF')
                THEN
                    l_Cnt_anf := l_Cnt_anf + 1;
                ELSIF Rec.App_Tp = 'OS' AND g_Ap_Tp = 'SS'
                THEN
                    l_Cnt_os := l_Cnt_os + 1;
                END IF;

                IF Rec.App_Ln IS NULL
                THEN
                    Add_Error (
                           'Для учасника ('
                        || App_Ident
                        || ') не вказано прізвище');
                END IF;

                IF     Rec.App_Gender IS NULL
                   AND Only_One_Aps_Exists_n (1141) = 1
                THEN
                    Add_Error (
                        'Для учасника (' || App_Ident || ') не вказано стать');
                END IF;

                IF Rec.App_Fn IS NULL
                THEN
                    Add_Error (
                        'Для учасника (' || App_Ident || ') не вказано ім’я');
                END IF;

                IF     Rec.App_Mn IS NULL
                   AND g_Ap_Tp NOT IN ('SS', 'R.OS', 'R.GS')
                THEN
                    Add_Warning (
                           'Для учасника ('
                        || App_Ident
                        || ') не вказано по батькові');
                END IF;

                IF     Rec.App_Inn IS NULL
                   AND (Rec.App_Ndt IS NULL OR Rec.App_Doc_Num IS NULL)
                   AND Rec.App_Tp != 'FA'
                   AND NOT (g_Ap_Tp IN ('D', 'R.OS') AND g_Ap_Src = 'PORTAL')
                THEN
                    --#84352
                    Add_Error (
                           'Для учасника ('
                        || App_Ident
                        || ') не вказано РНОКПП або документ !!');
                END IF;

                IF     Rec.App_Inn IS NULL
                   AND (Rec.App_Ndt IS NULL OR Rec.App_Doc_Num IS NULL)
                   AND Rec.App_Tp != 'Z'
                   AND                                                 /*NOT*/
                       g_Ap_Src = 'PORTAL'                  -- bogdan 20241010
                THEN
                    --#98757
                    Add_Error (
                           'Для учасника ('
                        || App_Ident
                        || ') не вказано РНОКПП або документ !!');
                END IF;

                --dbms_output_put_lines('Get_Doc_String(Rec.App_Id, 605, 3119)='||Get_Doc_String(Rec.App_Id, 605, 3119, '_'));

                IF Rec.App_Ndt = 6
                THEN
                    IF NOT REGEXP_LIKE (
                               Rec.App_Doc_Num,
                               '^[А-ЯҐІЇЄABCIETOPHKXM]{2}[-]{0,1}[0-9]{6}$')
                    THEN
                        Add_Error (
                               'Паспорт учасника ('
                            || App_Ident
                            || ') має некоректний формат');
                    END IF;

                    IF     p_Check_Doc_Num_Attr
                       AND Rec.App_Doc_Num != Get_Doc_String (Rec.App_Id,
                                                              6,
                                                              3,
                                                              '_')
                       AND Get_Doc_String (Rec.App_Id,
                                           605,
                                           3119,
                                           '_') != 'T'
                    THEN
                        Add_Error (
                               'Для '
                            || Rec.App_Ln
                            || ' '
                            || rec.app_fn
                            || ' '
                            || rec.app_mn
                            || ' серія та/або номер "Паспорта" НЕ ЗБІГАЄТЬСЯ в розділах "Учасники звернення" та "Документи"'
                            || App_Ident);
                    END IF;
                END IF;

                IF Rec.App_Ndt = 7
                THEN
                    IF NOT REGEXP_LIKE (Rec.App_Doc_Num, '^[0-9]{9}$')
                    THEN
                        Add_Error (
                               'ІД картка учасника ('
                            || App_Ident
                            || ') має некоректний формат');
                    END IF;

                    IF     p_Check_Doc_Num_Attr
                       AND Rec.App_Doc_Num != Get_Doc_String (Rec.App_Id,
                                                              7,
                                                              9,
                                                              '_')
                       AND Get_Doc_String (Rec.App_Id,
                                           605,
                                           3119,
                                           '_') != 'T'
                    THEN
                        Add_Error (
                               'Для '
                            || Rec.App_Ln
                            || ' '
                            || rec.app_fn
                            || ' '
                            || rec.app_mn
                            || ' серія та/або номер "ІД картка" НЕ ЗБІГАЄТЬСЯ в розділах "Учасники звернення" та "Документи"'
                            || App_Ident);
                    END IF;
                END IF;

                IF     Rec.App_Ndt = 37
                   AND NOT REGEXP_LIKE (
                               SUBSTR (Rec.App_Doc_Num,
                                       LENGTH (Rec.App_Doc_Num) - 5,
                                       6),
                               '^[0-9]{6}$')
                THEN
                    Add_Error (
                           'Свідоцтво про народження учасника ('
                        || App_Ident
                        || ') має некоректний формат');
                ELSIF Rec.App_Ndt = 37
                THEN
                    IF     p_Check_Doc_Num_Attr
                       AND Rec.App_Doc_Num != Get_Doc_String (Rec.App_Id,
                                                              37,
                                                              90,
                                                              '_')
                       AND Get_Doc_String (Rec.App_Id,
                                           605,
                                           3119,
                                           '_') != 'T'
                    THEN
                        Add_Error (
                               'Для '
                            || Rec.App_Ln
                            || ' '
                            || rec.app_fn
                            || ' '
                            || rec.app_mn
                            || ' серія та/або номер "Свідоцтво про народження" НЕ ЗБІГАЄТЬСЯ в розділах "Учасники звернення" та "Документи"'
                            || App_Ident);
                    END IF;
                END IF;

                --#90120
                IF g_Ap_Tp IN ('G',
                               'SS',
                               'R.OS',
                               'R.GS')
                THEN
                    --#106295
                    IF     g_Ap_Tp IN ('G')
                       AND Rec.App_Tp = 'Z'
                       AND Rec.App_Ndt NOT IN (6, 7, 8)
                    THEN
                        Add_Error (
                            'ValidatePerson: Для учасника звернення з типом «Заявник» не вказано "Паспорт громадянина України" або "ID картка" або "Посвідка на постійне проживання"');
                    --#106579
                    ELSIF     g_Ap_Tp IN ('SS')
                          AND Rec.App_Tp = 'Z'
                          AND Rec.App_Ndt NOT IN (6,
                                                  7,
                                                  8,
                                                  9)
                    THEN
                        Add_Error (
                            'ValidatePerson: Для учасника звернення з типом «Заявник» не вказано "Паспорт громадянина України" або "ID картка" або "Посвідка на постійне проживання" або «Посвідка на тимчасове проживання»');
                    ELSIF     g_Ap_Tp IN ('R.OS', 'R.GS')
                          AND Rec.App_Tp = 'Z'
                          AND Rec.App_Ndt NOT IN (6, 7)
                    THEN
                        Add_Error (
                            'ValidatePerson: Для учасника звернення з типом «Заявник» не вказано "Паспорт громадянина України" або "ID картка"');
                    ELSIF     Rec.App_Tp = 'Z'
                          AND Rec.App_Ndt IN (6, 7)
                          AND COALESCE (
                                  Api$validation.Get_Doc_Dt (rec.app_id,
                                                             6,
                                                             606),
                                  Api$validation.Get_Doc_Dt (rec.app_id,
                                                             7,
                                                             607))
                                  IS NULL
                    THEN
                        Add_Error (
                            'ValidatePerson: Для учасника звернення з типом «Заявник» не зазначено дату народження в "Паспорт громадянина України" або "ID картка"');
                    ELSIF     Rec.App_Tp = 'Z'
                          AND Rec.App_Ndt IN (6, 7)
                          AND   MONTHS_BETWEEN (
                                    g_Ap_Reg_Dt,
                                    COALESCE (
                                        Api$validation.Get_Doc_Dt (
                                            rec.app_id,
                                            6,
                                            606),
                                        Api$validation.Get_Doc_Dt (
                                            rec.app_id,
                                            7,
                                            607)))
                              / 12 <
                              18
                    THEN
                        Add_Error (
                            'ValidatePerson: Учасником звернення з типом «Заявник» вказано дитину');
                    END IF;
                END IF;

                -- #78710
                Checkinncontrolsum (Rec.App_Inn);

                IF   Get_Doc_Count (Rec.App_Id, 6)
                   + Get_Doc_Count (Rec.App_Id, 7) >
                   1
                THEN
                    Add_Fatal (
                           'Щодо особи ('
                        || App_Ident
                        || ') в блоці документи зазначено одночасно два документи" "Паспорт громадянина України" та "ID картка"');
                END IF;
            END;
        END LOOP;


        SELECT LISTAGG (
                      'В одному зверненні заборонено реєструвати одного учасника кілька разів. Учасник звернення з ЄСР ІД - '
                   || app_sc
                   || ' зареєстровано кілька разів. Виправте помилку')
               WITHIN GROUP (ORDER BY 1)
          INTO l_err
          FROM (SELECT app.app_sc,
                       COUNT (1) OVER (PARTITION BY app_ap, app_sc)    AS cnt
                  FROM ap_person app
                 WHERE     app.history_status = 'A'
                       AND app.app_sc IS NOT NULL
                       AND app.app_ap = g_Ap_Id)
         WHERE cnt > 1;

        IF l_err IS NOT NULL
        THEN
            Add_Fatal (l_err);
        END IF;

        IF l_Cnt_z > 1
        THEN
            Add_Fatal (
                   'У зверненні помилково зареєстровано '
                || l_Cnt_z
                || ' учасника з типом "Заявник". Для збереження звернення необхідно виправити помилку');
        END IF;

        IF l_Cnt_PV > 1 AND NOT Only_One_Aps_Exists (1221)
        THEN
            Add_Error (
                'Тип учасника "Патронатний вихователь" доступний лише для послуги "Надання послуги помічника патронатного вихователя"');
        ELSIF Only_One_Aps_Exists (1221) AND l_cnt_PV = 0
        THEN
            Add_Error (
                'Тип учасника "Патронатний вихователь" обов`язковий для послуги "Надання послуги помічника патронатного вихователя"');
        END IF;

        IF l_Cnt_os > 1
        THEN
            Add_Fatal (
                   'У зверненні помилково зареєстровано '
                || l_Cnt_os
                || ' учасника з типом "Особа, що потребує СП". Для збереження звернення необхідно виправити помилку');
        END IF;

        IF l_Cnt_anf > 1
        THEN
            Add_Fatal (
                   'У зверненні помилково зареєстровано '
                || l_Cnt_anf
                || ' учасника з типом "Інший батько/вихователь". Для збереження звернення необхідно виправити помилку');
        END IF;

        IF l_Cnt_z = 0 AND l_Cnt_anf = 0 AND l_Cnt_ap = 0
        THEN
            Add_Error ('У зверненні відсутній учасник з типом "Заявник"');
        END IF;
    END;

    ---------------------------------------------------------------------
    --                ПЕРЕВІРКА АНКЕТИ УЧАСНИКА ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Ankt
    IS
        l_Cnt                     NUMBER;
        l_App_Tp_Name             VARCHAR2 (250);
        l_Relation_Is_Applicant   BOOLEAN;
        l_Relation_Tp             VARCHAR2 (10);
        l_Ankt_kaot_id            NUMBER;
        l_Doc_kaot_id             NUMBER;
        l_Ankt_kaot_cod           VARCHAR2 (250);
        l_Doc_kaot_cod            VARCHAR2 (250);
        l_s275                    NUMBER;
    BEGIN
        FOR Ankt
            IN (  SELECT MAX (d.Apd_Id)                                    AS Apd_Id,
                         COUNT (*)                                         AS Ankt_Cnt,
                         p.App_Id,
                         p.App_Tp,
                         p.App_Inn,
                         p.App_Sc,
                         p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn    AS Pib
                    FROM Ap_Document d
                         JOIN Ap_Person p
                             ON d.Apd_App = p.App_Id AND p.History_Status = 'A'
                   WHERE     d.Apd_Ap = g_Ap_Id
                         AND d.History_Status = 'A'
                         AND d.Apd_Ndt = Api$appeal.c_Apd_Ndt_Ankt
                GROUP BY p.App_Id,
                         p.App_Tp,
                         p.App_Inn,
                         p.App_Sc,
                         p.App_Ln,
                         p.App_Fn,
                         p.App_Mn)
        LOOP
            IF Ankt.Ankt_Cnt > 1
            THEN
                Add_Fatal (
                       'Для учасника (РНОКПП='
                    || Ankt.App_Inn
                    || ') створено більше однієї анкети');
            END IF;

            IF g_Warnings
            THEN
                l_Relation_Tp :=
                    Api$appeal.Get_Attr_Val_String (
                        Ankt.Apd_Id,
                        p_Nda_Id   => Api$appeal.c_Apda_Nda_Relation);
                l_Relation_Is_Applicant :=
                    l_Relation_Tp = Api$appeal.c_Rel_Tp_Applicant;

                --Перевірка анкети заявника
                IF     Ankt.App_Tp = Api$appeal.c_App_Tp_Applicant
                   AND NOT g_Ap_Tp IN ('SS', 'R.OS', 'R.GS')
                   AND NOT Only_One_Aps_Exists (664)
                   AND NOT Only_One_Aps_Exists (1061)
                   AND NOT Only_One_Aps_Exists (20)
                   --AND NOT Only_One_Aps_Exists(21)
                   AND NOT Only_One_Aps_Exists (241)
                   AND NOT Only_One_Aps_Exists (250)
                   AND NOT Only_One_Aps_Exists (1221)
                THEN
                    SELECT COUNT (*)
                      INTO l_Cnt
                      FROM Ap_Document_Attr  a
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON     a.Apda_Nda = n.Nda_Id
                                  AND n.Nda_Class = 'APPSTP'
                                  AND a.Apda_Val_String = 'T'
                     WHERE     a.Apda_Apd = Ankt.Apd_Id
                           AND a.History_Status = 'A';

                    IF l_Cnt = 0
                    THEN
                        Add_Warning (
                            'Для анкети заявника не обрано підтип заявника');
                    END IF;

                    -- #93230
                    SELECT COUNT (*)
                      INTO l_s275
                      FROM ap_service t
                     WHERE     t.aps_ap = g_Ap_Id
                           AND t.aps_nst = 275
                           AND t.history_status = 'A';

                    IF l_Cnt > 1 AND l_s275 > 0
                    THEN
                        Add_Warning (
                            'Необхідно обрати/певевірити підтип заявника');
                    END IF;

                    IF NOT l_Relation_Is_Applicant
                    THEN
                        Add_Warning (
                            'Для учасника з типом "Заявник" не обрано ступінь родинного звязку "Заявник"');
                    END IF;
                --Інщі учасники
                ELSE
                    IF     Ankt.App_Tp IN
                               (Api$appeal.c_App_Tp_Charge,
                                Api$appeal.c_App_Tp_Familly)
                       AND l_Relation_Is_Applicant
                    THEN
                        l_App_Tp_Name := Get_App_Tp_Name (Ankt.App_Tp);
                        Add_Warning (
                               'Для учасника з типом "'
                            || l_App_Tp_Name
                            || '" обрано ступінь родинного звязку "Заявник"');
                    END IF;
                END IF;
            END IF;

            IF     g_Ap_Tp = 'SS'
               AND NVL (
                       Api$appeal.Get_Attr_Val_String (
                           p_Apd_Id   => Ankt.Apd_Id,
                           p_Nda_Id   => 1789),
                       '-') =
                   'DI'
               AND NVL (
                       Api$appeal.Get_Attr_Val_String (
                           p_Apd_Id   => Ankt.Apd_Id,
                           p_Nda_Id   => 1790),
                       '-') IN
                       ('1', '2', '3')
            THEN
                Add_Error (
                       'Дитина з інвалідністю не може мати групи інвалідності. В анкеті учасника звернення '
                    || Ankt.Pib
                    || ' блоці «Інформація про інвалідність» необхідно встановити в полі «Група інвалідності» значення «Дитина з інвалідністю» або залишити поле пустим');
            END IF;

            IF     Api$appeal.Get_Attr_Val_String (p_Apd_Id   => Ankt.Apd_Id,
                                                   p_Nda_Id   => 1792)
                       IS NOT NULL
               AND Api$appeal.Get_Attr_Val_String (p_Apd_Id   => Ankt.Apd_Id,
                                                   p_Nda_Id   => 1790) !=
                   '1'
            THEN
                --#112449
                Add_Error (
                       'В Анкеті «Підгрупа інвалідності» вказується тільки тоді, коли «Група інвалідності» перша, для '
                    || Ankt.Pib);
            END IF;

            IF     (   g_Aps.EXISTS (249)
                    OR g_Aps.EXISTS (267)
                    OR g_Aps.EXISTS (1141))
               AND Api$appeal.Get_Attr_Val_String (p_Apd_Id   => Ankt.Apd_Id,
                                                   p_Nda_Id   => 649)
                       IS NULL
            THEN
                IF Ankt.App_Sc IS NULL
                THEN
                    Add_Error (
                           'В Анкеті не зазначено "Ступінь родинного зв''язку" для '
                        || Ankt.Pib);
                ELSE
                    Add_Error (
                           'В Анкеті не зазначено "Ступінь родинного зв''язку" для '
                        || Uss_Person.Api$sc_Tools.Get_Pib (Ankt.App_Sc));
                END IF;
            END IF;

            IF g_Aps.EXISTS (664)
            THEN
                l_Ankt_kaot_id := get_val_id (ankt.Apd_Id, 1775);
                l_Doc_kaot_id := get_doc_id (ankt.App_Id, 10052, 2292);

                IF     l_Ankt_kaot_id IS NOT NULL
                   AND l_Doc_kaot_id IS NOT NULL
                   AND l_Ankt_kaot_id != l_Doc_kaot_id
                THEN
                    SELECT MAX (m.kaot_code)
                      INTO l_Ankt_kaot_cod
                      FROM uss_ndi.v_Ndi_Katottg m
                     WHERE m.kaot_id = l_Ankt_kaot_id;

                    SELECT MAX (m.kaot_code)
                      INTO l_Doc_kaot_cod
                      FROM uss_ndi.v_Ndi_Katottg m
                     WHERE m.kaot_id = l_Doc_kaot_id;

                    IF Ankt.App_Sc IS NULL
                    THEN
                        Add_Warning (
                               'В довідці ВПО та анкеті для особи '
                            || Ankt.Pib
                            || ' зазначено різні значення, '
                            || 'а саме, в полі КАТТОТГ у довідці ВПО зазначено '
                            || l_Doc_kaot_cod
                            || ', а в Анкеті зазначено '
                            || l_Ankt_kaot_cod);
                    ELSE
                        Add_Warning (
                               'В довідці ВПО та анкеті для особи '
                            || Uss_Person.Api$sc_Tools.Get_Pib (Ankt.App_Sc)
                            || ' зазначено різні значення, '
                            || 'а саме, в полі КАТТОТГ у довідці ВПО зазначено '
                            || l_Doc_kaot_cod
                            || ', а в Анкеті зазначено '
                            || l_Ankt_kaot_cod);
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                   ПЕРЕВІРКА ЗАЯВИ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Zayav
    IS
        l_Apd_Id           NUMBER;
        l_App_Id           NUMBER;
        l_Cnt              NUMBER;
        l_Birth_Dt_Zayav   DATE;
        l_Birth_Dt_Pasp    DATE;
        l_Is_Alone         BOOLEAN;
        l_Err_List         VARCHAR2 (4000);
        l_Wrn_List         VARCHAR2 (4000);
    BEGIN
        BEGIN
            SELECT d.Apd_Id, p.App_Id, COUNT (*) OVER (PARTITION BY p.App_Ap)
              INTO l_Apd_Id, l_App_Id, l_Cnt
              FROM Ap_Person  p
                   JOIN Ap_Document d
                       ON     p.App_Ap = d.Apd_Ap
                          AND d.Apd_Ndt = Api$appeal.c_Apd_Ndt_Zayv
                          AND d.History_Status = 'A'
             WHERE     p.App_Ap = g_Ap_Id
                   AND p.App_Tp = 'Z'
                   AND p.History_Status = 'A'
             FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;
        END;

        IF l_Cnt > 1
        THEN
            Add_Error ('Створено більше однієї заяви');
        END IF;

        IF g_Warnings
        THEN
            l_Birth_Dt_Zayav := Api$appeal.Get_Attr_Val_Dt (l_Apd_Id, 'BDT');
            l_Birth_Dt_Pasp :=
                COALESCE (
                    Api$appeal.Get_Person_Attr_Val_Dt (p_App_Id   => l_App_Id,
                                                       p_Nda_Id   => 606),
                    Api$appeal.Get_Person_Attr_Val_Dt (p_App_Id   => l_App_Id,
                                                       p_Nda_Id   => 607),
                    Api$appeal.Get_Person_Attr_Val_Dt (p_App_Id   => l_App_Id,
                                                       p_Nda_Id   => 2014),
                    Api$appeal.Get_Person_Attr_Val_Dt (p_App_Id   => l_App_Id,
                                                       p_Nda_Id   => 2015));

            IF NVL (l_Birth_Dt_Zayav, TO_DATE ('01.01.1800', 'dd.mm.yyyy')) <>
               NVL (l_Birth_Dt_Pasp, TO_DATE ('01.01.1800', 'dd.mm.yyyy'))
            THEN
                Add_Warning (
                    'Дата народження в заяві відрізняється від дати народження в паспорті');
            END IF;
        END IF;

        l_Is_Alone :=
            Api$appeal.Get_Person_Attr_Val_Str (
                p_App_Id   => l_App_Id,
                p_Nda_Id   => Api$appeal.c_Apda_Nda_Is_Alone) =
            'T';

        IF l_Is_Alone
        THEN
            SELECT COUNT (*)
              INTO l_Cnt
              FROM Ap_Document_Attr a
             WHERE     a.Apda_Apd = l_Apd_Id
                   AND a.History_Status = 'A'
                   AND a.Apda_Nda IN
                           (Api$appeal.c_Apda_Nda_Divorsed,
                            Api$appeal.c_Apda_Nda_Unmarried,
                            Api$appeal.c_Apda_Nda_Married)
                   AND a.Apda_Val_String = 'T';

            IF l_Cnt = 0 AND Aps_Exists (248) = 0
            THEN
                Add_Error (
                    'Для заявника з підтипом "одинокий/одинока" необхідно обрати хоча б одну з ознак про шлюб(«перебувала», «не перебувала», "перебуваю")');
            END IF;
        END IF;

        SELECT LISTAGG (
                   CASE a.Apda_Nda
                       WHEN Api$appeal.c_Apda_Nda_Addr_Residence_Ind
                       THEN
                              'Поле "Індекс" адреси проживання у картці документу '
                           || '"Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" має містити 5 цифр.'
                       WHEN Api$appeal.c_Apda_Nda_Addr_Registration_Ind
                       THEN
                              'Поле "Індекс" адреси регістрації у картці документу '
                           || '"Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" має містити 5 цифр.'
                   END,
                   ',')
               WITHIN GROUP (ORDER BY 1)
          INTO l_Err_List
          FROM Ap_Document_Attr a
         WHERE     a.Apda_Apd = l_Apd_Id
               AND a.History_Status = 'A'
               AND a.Apda_Nda IN
                       (Api$appeal.c_Apda_Nda_Addr_Residence_Ind,
                        Api$appeal.c_Apda_Nda_Addr_Registration_Ind)
               AND a.Apda_Val_String IS NOT NULL
               AND REGEXP_INSTR (a.Apda_Val_String, '^\d{5}$') = 0;

        IF l_Err_List IS NOT NULL
        THEN
            Add_Error (l_Err_List);
        END IF;

        --#76374 20220410
        WITH
            Adr
            AS
                (SELECT Apda_Ap,
                        Apda_Apd,
                        "KATTOTG_NAME",
                        "KATTOTG_ID",
                        (SELECT MAX (Npo.Npo_Index)
                           FROM Uss_Ndi.v_Ndi_Post_Office Npo
                          WHERE     Npo.Npo_Kaot = "KATTOTG_ID"
                                AND Npo.Npo_Index = "INDEX_NAME")
                            AS Kattotg_Index,
                        "INDEX_NAME"
                            AS Index_,
                        "STREET_STR_NAME",
                        "STREET_NAME",
                        "STREET_ID",
                        (SELECT MAX (Ns_Kaot)
                           FROM Uss_Ndi.v_Ndi_Street Ns
                          WHERE Ns.Ns_Id = "STREET_ID")
                            AS Street_Kaot,
                        (SELECT MAX (Npo.Npo_Index)
                           FROM Uss_Ndi.v_Ndi_Street  Ns
                                JOIN Uss_Ndi.v_Ndi_Post_Office Npo
                                    ON     Ns.Ns_Kaot = Npo.Npo_Kaot
                                       AND Npo.History_Status = 'A'
                          WHERE     Ns.Ns_Id = "STREET_ID"
                                AND Npo.Npo_Index = "INDEX_NAME")
                            AS Street_Index,
                        (SELECT MAX (Npo.Npo_Index)
                           FROM Uss_Ndi.v_Ndi_Street  Ns
                                JOIN uss_ndi.v_ndi_katottg k
                                    ON (k.kaot_kaot_l4 = ns.ns_kaot)
                                JOIN Uss_Ndi.v_Ndi_Post_Office Npo
                                    ON     k.kaot_id = Npo.Npo_Kaot
                                       AND Npo.History_Status = 'A'
                          WHERE     Ns.Ns_Id = "STREET_ID"
                                AND Npo.Npo_Index = "INDEX_NAME")
                            AS Street_Index_4          /*,
(SELECT MAX(Npo.Npo_Index)
   FROM Uss_Ndi.v_Ndi_Street Ns
   join uss_ndi.v_ndi_npo_config c on (c.nnc_ns = ns.ns_id)
   JOIN Uss_Ndi.v_Ndi_Post_Office Npo
     ON Npo.Npo_id = c.nnc_npo
        AND Npo.History_Status = 'A'
  WHERE Ns.Ns_Id = "STREET_ID"
    and Npo.Npo_Index = "INDEX_NAME") AS Street_Index_Cfg*/
                   FROM (  SELECT Apda.Apda_Ap,
                                  Apda.Apda_Apd,
                                  Apda.Apda_Nda,
                                  Apda.Apda_Val_String,
                                  Apda.Apda_Val_Id
                             FROM Ap_Document Apd
                                  JOIN Ap_Document_Attr Apda
                                      ON     Apda.Apda_Apd = Apd.Apd_Id
                                         AND Apda.History_Status = 'A'
                            WHERE Apd.Apd_Id = l_Apd_Id
                         ORDER BY Apda.Apda_Apd, Apda.Apda_Id)
                            PIVOT (
                                  MAX (Apda_Val_String) NAME,
                                  MAX (Apda_Val_Id) Id
                                  --FOR Apda_Nda IN(604 "KATTOTG", 599 "INDEX", 788 "STREET_STR", 597 "STREET"))),
                                  --#112135
                                  FOR Apda_Nda
                                  IN (580 "KATTOTG",
                                     587 "INDEX",
                                     787 "STREET_STR",
                                     585 "STREET"))),
            r_Adr
            AS
                (SELECT "KATTOTG_NAME",
                        "KATTOTG_ID",
                        (SELECT MAX (Npo.Npo_Index)
                           FROM Uss_Ndi.v_Ndi_Post_Office Npo
                          WHERE     Npo.Npo_Kaot = "KATTOTG_ID"
                                AND Npo.Npo_Index = "INDEX_NAME")
                            AS Kattotg_Index,
                        "INDEX_NAME"
                            AS Index_,
                        "STREET_STR_NAME",
                        "STREET_NAME",
                        "STREET_ID",
                        (SELECT MAX (Ns_Kaot)
                           FROM Uss_Ndi.v_Ndi_Street Ns
                          WHERE Ns.Ns_Id = "STREET_ID")
                            AS Street_Kaot,
                        (SELECT MAX (Npo.Npo_Index)
                           FROM Uss_Ndi.v_Ndi_Street  Ns
                                JOIN Uss_Ndi.v_Ndi_Post_Office Npo
                                    ON     Ns.Ns_Kaot = Npo.Npo_Kaot
                                       AND Npo.History_Status = 'A'
                          WHERE     Ns.Ns_Id = "STREET_ID"
                                AND Npo.Npo_Index = "INDEX_NAME")
                            AS Street_Index,
                        (SELECT MAX (Npo.Npo_Index)
                           FROM Uss_Ndi.v_Ndi_Street  Ns
                                JOIN uss_ndi.v_ndi_katottg k
                                    ON (k.kaot_kaot_l4 = ns.ns_kaot)
                                JOIN Uss_Ndi.v_Ndi_Post_Office Npo
                                    ON     k.kaot_id = Npo.Npo_Kaot
                                       AND Npo.History_Status = 'A'
                          WHERE     Ns.Ns_Id = "STREET_ID"
                                AND Npo.Npo_Index = "INDEX_NAME")
                            AS Street_Index_4          /*,
(SELECT MAX(Npo.Npo_Index)
   FROM Uss_Ndi.v_Ndi_Street Ns
   join uss_ndi.v_ndi_npo_config c on (c.nnc_ns = ns.ns_id)
   JOIN Uss_Ndi.v_Ndi_Post_Office Npo
     ON Npo.Npo_id = c.nnc_npo
        AND Npo.History_Status = 'A'
  WHERE Ns.Ns_Id = "STREET_ID"
    and Npo.Npo_Index = "INDEX_NAME") AS Street_Index_Cfg*/
                   FROM (  SELECT Apda.Apda_Ap,
                                  Apda.Apda_Apd,
                                  Apda.Apda_Nda,
                                  Apda.Apda_Val_String,
                                  Apda.Apda_Val_Id
                             FROM Ap_Document Apd
                                  JOIN Ap_Document_Attr Apda
                                      ON     Apda.Apda_Apd = Apd.Apd_Id
                                         AND Apda.History_Status = 'A'
                            WHERE Apd.Apd_Id = l_Apd_Id
                         ORDER BY Apda.Apda_Apd, Apda.Apda_Id)
                            PIVOT (
                                  MAX (Apda_Val_String) NAME,
                                  MAX (Apda_Val_Id) Id
                                  FOR Apda_Nda
                                  IN (592 "IsCoincidence",
                                     604 "KATTOTG",
                                     599 "INDEX",
                                     788 "STREET_STR",
                                     597 "STREET"))
                  WHERE NVL ("IsCoincidence_NAME", 'F') = 'F')
        SELECT LISTAGG (l_Err, ',') WITHIN GROUP (ORDER BY 1),
               LISTAGG (l_Wrn, ',') WITHIN GROUP (ORDER BY 1)
          INTO l_Err_List, l_Wrn_List
          FROM (SELECT CASE
                           WHEN Index_ IS NULL
                           THEN
                               'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" не заповнено атрибут "Індекс" в адресі реєстрації'
                           WHEN Street_Str_Name IS NULL AND Street_Id IS NULL
                           THEN
                               'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" не заповнено жодного атрибуту "Вулиця" в адресі реєстрації'
                           WHEN NVL (Kattotg_Index, '-1') !=
                                NVL (Index_, '-2')
                           THEN
                                  'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано індекс, який не відповідає КАТТОТГ із назвою '
                               || Kattotg_Name
                           /*WHEN Street_Id IS not NULL and street_kaot is null and Nvl(Kattotg_Index, '-1') != nvl(Street_Index_Cfg, '-2') THEN
                             'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано вулицю, який не відповідає КАТТОТГ із назвою ' ||
                            Kattotg_Name
                           */
                           WHEN     Street_Id IS NOT NULL /* and street_kaot is not null*/
                                AND NVL (Kattotg_Index, '-1') !=
                                    NVL (NVL (Street_Index, Street_Index_4),
                                         '-2')
                           THEN
                                  'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано вулицю, який не відповідає КАТТОТГ із назвою '
                               || Kattotg_Name
                           ELSE
                               ''
                       END    AS l_Err,
                       CASE
                           WHEN Street_Id IS NOT NULL AND street_kaot IS NULL
                           THEN
                               'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано вулицю, для якої не зазначено КАТОТТГ в довіднику вулиць'
                       END    AS l_Wrn
                  FROM Adr
                UNION ALL
                SELECT CASE
                           WHEN Index_ IS NULL
                           THEN
                               'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" не заповнено атрибут "Індекс" в адресі проживання'
                           WHEN Street_Str_Name IS NULL AND Street_Id IS NULL
                           THEN
                               'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" не заповнено жодного атрибуту "Вулиця" в адресі проживання'
                           WHEN NVL (Kattotg_Index, '-1') !=
                                NVL (Index_, '-2')
                           THEN
                                  'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано індекс, який не відповідає КАТТОТГ із назвою '
                               || Kattotg_Name
                           /* WHEN Street_Id IS not NULL and street_kaot is null and Nvl(Kattotg_Index, '-1') != nvl(Street_Index_Cfg, '-2') THEN
                              'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано вулицю, який не відповідає КАТТОТГ із назвою ' ||
                             Kattotg_Name
                            */
                           WHEN     Street_Id IS NOT NULL /* and street_kaot is not null*/
                                AND NVL (Kattotg_Index, '-1') !=
                                    NVL (NVL (Street_Index, Street_Index_4),
                                         '-2')
                           THEN
                                  'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано вулицю, який не відповідає КАТТОТГ із назвою '
                               || Kattotg_Name
                           ELSE
                               ''
                       END    AS l_Err,
                       CASE
                           WHEN Street_Id IS NOT NULL AND street_kaot IS NULL
                           THEN
                               'В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано вулицю, для якої не зазначено КАТОТТГ в довіднику вулиць'
                       END    AS l_Wrn
                  FROM r_Adr);

        /*
        1.Необхідно додати контроль щодо відповідності Індексу, Вулиці до обраного користувачем КАТТОТГ.
          Значення полів, які зазначено на скріншоті користувач обирає із довідників, у яких є прив'язка до ndi_kattotg.
        Відповідно, у випадку, якщо користувач обрав індекс, вулицю, які прив'язано до іншого КАТТОТГ, то видавати повідомлення з типом помилка:
        "В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано індекс,
        який не відповідає КАТТОТГ із назвою <Назва КАТТОТГ>" або "В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" обрано вулицю, який не відповідає КАТТОТГ із назвою <Назва КАТТОТГ>".
        2.Також необхідно врахувати, що поле "Вулиця" може бути пустим, у випадку якщо інше поле "Вулиця" заповненне:
        Якщо обидва поля "Вулиця" не заповнено, то видавати повідомлення з типом "Помилка"
        "В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" не заповнено жодного атрибуту "Вулиця" в адресі <проживання/реєстрації, необхідно вказувати в якій із двох адрес не вказано вулиці>"
        3. Поле "Індекс" має бути заповненим завжди, Якщо поле не заповнено, то видавати повідомлення з типом
        "Помилка": "В документі "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" не заповнено атрибут "Індекс" в адресі <проживання/реєстрації, необхідно вказувати в якій із двох адрес не вказано індекс>"
        */

        IF l_Err_List IS NOT NULL
        THEN
            Add_Error (l_Err_List);
        END IF;

        IF l_Wrn_List IS NOT NULL
        THEN
            Add_Warning (l_Wrn_List);
        END IF;
    END;

    PROCEDURE Validate_Zayav_Veteran
    IS
        l_Apd_Id           NUMBER;
        l_App_Id           NUMBER;
        l_Cnt              NUMBER;
        l_Birth_Dt_Zayav   DATE;
        l_Birth_Dt_Pasp    DATE;
        l_Is_Alone         BOOLEAN;
        l_Err_List         VARCHAR2 (4000);
    BEGIN
        BEGIN
            SELECT d.Apd_Id, p.App_Id, COUNT (*) OVER (PARTITION BY p.App_Ap)
              INTO l_Apd_Id, l_App_Id, l_Cnt
              FROM Ap_Person  p
                   JOIN Ap_Document d
                       ON     p.App_Ap = d.Apd_Ap
                          AND d.Apd_Ndt = Api$appeal.c_Apd_Ndt_Veteran
                          AND d.History_Status = 'A'
             WHERE     p.App_Ap = g_Ap_Id
                   AND p.App_Tp = 'Z'
                   AND p.History_Status = 'A'
             FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;
        END;

        IF l_Cnt > 1
        THEN
            Add_Error ('Створено більше однієї заяви');
        END IF;

        WITH
            Adr
            AS
                (SELECT "STREET_STR_NAME", "STREET_NAME", "STREET_ID"
                   FROM (  SELECT Apda.Apda_Ap,
                                  Apda.Apda_Apd,
                                  Apda.Apda_Nda,
                                  Apda.Apda_Val_String,
                                  Apda.Apda_Val_Id
                             FROM Ap_Document Apd
                                  JOIN Ap_Document_Attr Apda
                                      ON     Apda.Apda_Apd = Apd.Apd_Id
                                         AND Apda.History_Status = 'A'
                            WHERE Apd.Apd_Id = l_Apd_Id
                         ORDER BY Apda.Apda_Apd, Apda.Apda_Id)
                            PIVOT (
                                  MAX (Apda_Val_String) NAME,
                                  MAX (Apda_Val_Id) Id
                                  FOR Apda_Nda
                                  IN (8411 "STREET_STR", 8403 "STREET"))),
            r_Adr
            AS
                (SELECT "STREET_STR_NAME", "STREET_NAME", "STREET_ID"
                   FROM (  SELECT Apda.Apda_Ap,
                                  Apda.Apda_Apd,
                                  Apda.Apda_Nda,
                                  Apda.Apda_Val_String,
                                  Apda.Apda_Val_Id
                             FROM Ap_Document Apd
                                  JOIN Ap_Document_Attr Apda
                                      ON     Apda.Apda_Apd = Apd.Apd_Id
                                         AND Apda.History_Status = 'A'
                            WHERE Apd.Apd_Id = l_Apd_Id
                         ORDER BY Apda.Apda_Apd, Apda.Apda_Id)
                            PIVOT (
                                  MAX (Apda_Val_String) NAME,
                                  MAX (Apda_Val_Id) Id
                                  FOR Apda_Nda
                                  IN (8410 "STREET_STR", 8393 "STREET")))
        SELECT LISTAGG (l_Err, ',') WITHIN GROUP (ORDER BY 1)
          INTO l_Err_List
          FROM (SELECT CASE
                           WHEN Street_Str_Name IS NULL AND Street_Id IS NULL
                           THEN
                               'В документі "Заява про взяття на облік ветерана війни" не заповнено жодного атрибуту "Вулиця" в адресі реєстрації'
                           ELSE
                               ''
                       END    AS l_Err
                  FROM r_Adr
                UNION ALL
                SELECT CASE
                           WHEN Street_Str_Name IS NULL AND Street_Id IS NULL
                           THEN
                               'В документі "Заява про взяття на облік ветерана війни" не заповнено жодного атрибуту "Вулиця" в адресі проживання'
                           ELSE
                               ''
                       END    AS l_Err
                  FROM Adr);

        IF l_Err_List IS NOT NULL
        THEN
            Add_Error (l_Err_List);
        END IF;

        l_Err_List := Api$validation.Check_Documents_Filled (l_Apd_Id);

        IF l_Err_List IS NOT NULL
        THEN
            Add_Error (l_Err_List);
        END IF;
    END;

    ---------------------------------------------------------------------
    --           ПЕРЕВІРКА АНКЕТИ УЧАСНИКА ЗВЕРНЕННЯ РНСП
    ---------------------------------------------------------------------
    PROCEDURE Validate_Zayav_g
    IS
        l_Err_List   VARCHAR2 (4000);
        l_Num        VARCHAR2 (200);
        l_Numident   VARCHAR2 (200);
        l_Rnspm_Id   NUMBER (14);
        l_Rnspm_St   VARCHAR2 (20);
        l_Rnspm_Tp   VARCHAR2 (20);
        l_cnt        NUMBER (14);
    BEGIN
        SELECT MAX (Ap_Num)
          INTO l_Num
          FROM Appeal
         WHERE Ap_Id = g_Ap_Id;

        SELECT COUNT (1)
          INTO l_cnt
          FROM Ap_Document Apd
         WHERE     Apd.Apd_Ap = g_Ap_Id
               AND Apd.Apd_Ndt = 700
               AND Apd.History_Status = 'A';

        IF l_cnt = 0
        THEN
            Add_Error (
                'Відсутня заява надавача! Потрібно її заповнити і зберегти!');
            RETURN;
        ELSIF l_cnt > 1
        THEN
            Add_Error ('Заява надавача повинна бути одна!');
            RETURN;
        END IF;

        FOR Ank
            IN (SELECT Apd_Ap,
                       Apd_Id,
                       api$validation.Get_Val_String (Apd.Apd_Id, 954)
                           AS "RNSP_ST",
                       api$validation.Get_Val_String (Apd.Apd_Id, 953)
                           AS "RNSP_TP",
                       api$validation.Get_Val_String (Apd.Apd_Id, 1131, 'PR')
                           AS "RNSP_ORG_TP", --Ознака "головна організація/філіал" STRING V_DDN_RNSP_ORG_TP
                       api$validation.Get_Val_Id (Apd.Apd_Id, 2450)
                           AS "RNSPM_ID", --Найменування організації, щодо якої створюється звернення ID V_RNSP_ALL
                       api$validation.Get_Val_Id (Apd.Apd_Id, 2451)
                           AS "RNSPM_RNSPM", --Головна організація/установа (вказати, якщо обрано ознаку "філіал")
                       api$validation.Get_Val_String (Apd.Apd_Id, 955)
                           AS "EDRPOU",
                       api$validation.Get_Val_String (Apd.Apd_Id, 960)
                           AS Isnotiin,
                       api$validation.Get_Val_String (Apd.Apd_Id, 961)
                           AS "IIN",
                       api$validation.Get_Val_String (Apd.Apd_Id, 962)
                           AS "PASPORT",
                       api$validation.Get_Val_String (apd.apd_id, 956)
                           AS Full_NAME,
                       api$validation.Get_Val_String (apd.apd_id, 957)
                           AS Short_NAME,
                       api$validation.Get_Val_String (apd.apd_id, 963)
                           AS LAST_NAME,
                       api$validation.Get_Val_String (apd.apd_id, 964)
                           AS FIRST_NAME,
                       api$validation.Get_Val_String (apd.apd_id, 965)
                           AS MIDDLE_NAME,
                       api$validation.Get_Val_String (Apd.Apd_Id, 5575)
                           AS "BOSS_IIN",
                       (SELECT MAX (Dic_Name)
                          FROM Uss_Ndi.v_Ddn_Rnsp_Tp
                         WHERE Dic_Value =
                               api$validation.Get_Val_String (Apd.Apd_Id,
                                                              953))
                           AS "RNSP_TP_NAME",
                       (SELECT MAX (Dic_Name)
                          FROM Uss_Ndi.v_Ddn_Rnsp_St
                         WHERE Dic_Value =
                               api$validation.Get_Val_String (Apd.Apd_Id,
                                                              954))
                           AS "RNSP_ST_NAME"
                  FROM Ap_Document Apd
                 WHERE     Apd.Apd_Ap = g_Ap_Id
                       AND Apd.Apd_Ndt = 700
                       AND Apd.History_Status = 'A')
        LOOP
            CASE
                WHEN Ank.Rnsp_Tp IS NULL
                THEN
                    Add_Error (
                        'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Тип надавача"');
                WHEN Ank.Rnsp_Tp = 'O' AND Ank.Edrpou IS NULL
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_Tp_Name
                        || ' не заповнено атрибут "Код ЄДРПОУ"');
                WHEN     Ank.Rnsp_Tp = 'F'
                     AND NVL (Ank.Isnotiin, 'F') = 'F'
                     AND Ank.Iin IS NULL
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_Tp_Name
                        || ' не заповнено атрибут "РНОКПП"');
                WHEN     Ank.Rnsp_Tp = 'F'
                     AND NVL (Ank.Isnotiin, 'F') = 'T'
                     AND Ank.Pasport IS NULL
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_Tp_Name
                        || ' не заповнено атрибут "Реквізити документу, що посвідчує особу"');
                WHEN Ank.Rnsp_Tp = 'O'
                THEN
                    l_Numident := Ank.Edrpou;
                WHEN Ank.Rnsp_Tp = 'F' AND NVL (Ank.Isnotiin, 'F') = 'F'
                THEN
                    l_Numident := Ank.Iin;
                WHEN Ank.Rnsp_Tp = 'F' AND NVL (Ank.Isnotiin, 'F') = 'T'
                THEN
                    l_Numident := Ank.Pasport;
                ELSE
                    NULL;
            END CASE;

            IF ank.RNSP_TP = 'O'
            THEN
                IF ank.Full_NAME IS NULL
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_Tp_Name
                        || ' не заповнено атрибут "Повне найменування юридичної особи (згідно ЄДР)"');
                END IF;

                IF ank.Short_NAME IS NULL
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_Tp_Name
                        || ' не заповнено атрибут "Скорочене найменування юридичної особи (згідно ЄДР)"');
                END IF;
            ELSIF ank.RNSP_TP = 'F'
            THEN
                IF ank.LAST_NAME IS NULL
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_Tp_Name
                        || ' не заповнено атрибут "Прізвище"');
                END IF;

                IF ank.FIRST_NAME IS NULL
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_Tp_Name
                        || ' не заповнено атрибут "Ім’я"');
                END IF;
            END IF;

            IF l_Numident IS NOT NULL
            THEN
                Uss_Rnsp.Api$find.GetRNSPM (
                    p_numident           => l_Numident,
                    p_numident_missing   => Ank.Isnotiin,
                    p_num                => l_Num,
                    p_rnspm_org_tp       => Ank.Rnsp_Org_Tp,
                    p_rnspm_id           => l_Rnspm_id,
                    p_rnspm_st           => l_Rnspm_St,
                    p_rnspm_tp           => l_Rnspm_Tp);

                --shost 29.03.2023: за постановкою В.Шимановича
                IF     Ank.Rnsp_St IN ('U', 'D')
                   AND Ank.Rnspm_Id IS NOT NULL
                   AND l_Numident <>
                       NVL (
                           Uss_Rnsp.Api$find.Get_Nsp_Numident (Ank.Rnspm_Id),
                           Uss_Rnsp.Api$find.Get_Nsp_Pasp (Ank.Rnspm_Id))
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_St_Name
                        || ' вказано діючу картку, в якій '
                        || CASE
                               WHEN Ank.Rnsp_Tp = 'O'
                               THEN
                                   'ЕДРПОУ'
                               WHEN     Ank.Rnsp_Tp = 'F'
                                    AND NVL (Ank.Isnotiin, 'F') = 'F'
                               THEN
                                   'РНОКПП'
                               WHEN     Ank.Rnsp_Tp = 'F'
                                    AND NVL (Ank.Isnotiin, 'F') = 'T'
                               THEN
                                   'паспорт'
                           END
                        || ' відрізняється від того, що зазначено в заяві');
                END IF;
            END IF;

            /*
            O  Юридична особа
            F  ФОП

            U  Зміна відомостей в РНСП
            A  Включено до РНСП
            D  Виключено з РНСП
            */

            CASE
                WHEN Ank.Rnsp_St IS NULL
                THEN
                    Add_Error (
                        'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Тип звернення"');
                WHEN     Ank.Rnsp_St = 'A'
                     AND (   Ank.Rnspm_Id IS NOT NULL
                          OR (l_Rnspm_id IS NOT NULL AND l_rnspm_st != 'N'))
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_St_Name
                        || ' вказано діючу картку');
                WHEN     Ank.Rnsp_St = 'A'
                     AND l_Rnspm_id IS NOT NULL
                     AND l_rnspm_st = 'N'
                THEN
                    UPDATE appeal app
                       SET app.ap_ext_ident = l_Rnspm_id
                     WHERE Ap_id = g_Ap_Id;
                WHEN Ank.Rnsp_St IN ('U', 'D') AND Ank.Rnspm_Id IS NULL
                THEN
                    Add_Error (
                           'В документі "Заява надавача соціальних послуг" для '
                        || Ank.Rnsp_St_Name
                        || ' не вказано діючу картку');
                ELSE
                    UPDATE appeal app
                       SET app.ap_ext_ident = Ank.Rnspm_Id
                     WHERE Ap_id = g_Ap_Id;
            END CASE;

            CASE
                WHEN Ank.RNSP_ORG_TP = 'SL' AND Ank.Rnspm_rnspm IS NULL
                THEN
                    Add_Error (
                        'В документі "Заява надавача соціальних послуг" для філії не вказано діючу картку головного підприємства');
                WHEN Ank.RNSP_ORG_TP = 'PR' AND Ank.Rnspm_rnspm IS NOT NULL
                THEN
                    Add_Error (
                        'В документі "Заява надавача соціальних послуг" вказано головне підприємство та заповнено картку головного підприємства');
                ELSE
                    NULL;
            END CASE;



            /*
                --№86321
                --Відміна контролю на наявність неопрацьованого звернення надавача
                  SELECT Listagg(l_Err, ',' ON OVERFLOW TRUNCATE '...') Within GROUP(ORDER BY 1)
                    INTO l_Err_List
                  FROM (  select 'Звернення створити неможливо, оскільки вже існує звернення '||ap.ap_num||
                                 ' від надавача з ЄДРПОУ '||api$validation.Get_Val_String(Apd.Apd_Id,  955)||
                                 ' у статусі, що відрізняється від «Виконано» або «Відхилено»' as l_Err
                          from appeal ap
                                     join Ap_Document Apd on Apd.Apd_Ap=ap.ap_id AND Apd.Apd_Ndt = 700 AND Apd.History_Status = 'A'
                          where ap.ap_id != g_Ap_Id
                                and ap.ap_st not in ('V', 'X')
                                and ap.ap_ext_ident in ( select t.ap_ext_ident from appeal t where t.ap_id = g_Ap_Id)
                       );
                  IF l_Err_List IS NOT NULL THEN
                    Add_Error(l_Err_List);
                  END IF;
            */

            IF     ank.edrpou IS NOT NULL
               AND NOT REGEXP_LIKE (ank.edrpou, '^[0-9]{8}$')
            THEN
                Add_Error (
                    'У «Код ЄДРПОУ» введено значення не в форматі 8 цифр');
            END IF;

            IF     ank.boss_iin IS NOT NULL
               AND NOT REGEXP_LIKE (ank.boss_iin, '^[0-9]{10}$')
            THEN
                Add_Error (
                    'У «РНОКПП керівника юридичної особи» введено значення не в форматі 10 цифр');
            END IF;

            IF     ank.iin IS NOT NULL
               AND NOT REGEXP_LIKE (ank.iin, '^[0-9]{10}$')
            THEN
                Add_Error (
                    'У «РНОКПП» введено значення не в форматі 10 цифр');
            ELSIF ank.iin IS NOT NULL AND ank.isnotiin = 'T'
            THEN
                Add_Error (
                    'Введено «РНОКПП» і одночасно встановлено «Ознакa відмови особи від РНОКПП»');
            END IF;

            IF     ank.pasport IS NOT NULL
               AND NOT (   REGEXP_LIKE (
                               ank.pasport,
                               '^[АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ]{2}\d{6}$')
                        OR REGEXP_LIKE (ank.pasport, '^[0-9]{9}$'))
            THEN
                Add_Error (
                    'У «серія та номер паспорта / номер ID картки» введено значення не в форматі дві великі літери + 6 цифр або 9 цифр');
            END IF;
        /*
        При збереженні документа ndt_id=700 додати контроль з типом «Помилка»:
        - якщо у «Код ЄДРПОУ» nda_id=955 введено значення != 8 цифр
        - якщо у «РНОКПП» nda_id=961 введено значення != 10 цифр
        - якщо у «серія та номер паспорта / номер ID картки» nda_id=962 введено значення, що не відповідає:
        -- або дві великі літери + 6 цифр без пробілів (АА123456)
        -- або 9 цифр (123456789)
        - якщо введено «РНОКПП» nda_id=961 і одночасно встановлено «Ознакa відмови особи від РНОКПП» nda_id in (960)=Т
        - якщо атрибут nda_id in (1131) = "головна організація/установа" і при цьому атрибут nda_id in (2451) заповнено
        */


        END LOOP;

        WITH
            Adr
            AS
                (SELECT Apd_Ap,
                        Apd_Id,
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 971
                                AND Apda.History_Status = 'A')
                            AS "KATTOTG_ID",
                        (SELECT Apda_Val_String                  --Apda_Val_Id
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 972
                                AND Apda.History_Status = 'A')
                            AS "INDX",
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 975
                                AND Apda.History_Status = 'A')
                            AS "STREET_ID",
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 2159
                                AND Apda.History_Status = 'A')
                            AS "STREET_NAME",
                        (SELECT Apda.Apda_Val_String
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 976
                                AND Apda.History_Status = 'A')
                            AS "BUILDING"
                   FROM Ap_Document Apd
                  WHERE     Apd.Apd_Ap = g_Ap_Id
                        AND Apd.Apd_Ndt = 700
                        AND Apd.History_Status = 'A'),
            r_Adr
            AS
                (SELECT Apd_Ap,
                        Apd_Id,
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 979
                                AND Apda.History_Status = 'A')
                            AS "KATTOTG_ID",
                        (SELECT Apda_Val_String                  --Apda_Val_Id
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 980
                                AND Apda.History_Status = 'A')
                            AS "INDX",
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 983
                                AND Apda.History_Status = 'A')
                            AS "STREET_ID",
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 2160
                                AND Apda.History_Status = 'A')
                            AS "STREET_NAME",
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 984
                                AND Apda.History_Status = 'A')
                            AS "BUILDING",
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 1093
                                AND Apda.History_Status = 'A')
                            AS "ISCOINCIDENCE"
                   FROM Ap_Document Apd
                  WHERE     Apd.Apd_Ap = g_Ap_Id
                        AND Apd.Apd_Ndt = 700
                        AND Apd.History_Status = 'A'/*AND EXISTS (SELECT 1
                                                       FROM Ap_Document_Attr Apda
                                                      WHERE Apda.Apda_Apd = Apd.Apd_Id
                                                            AND Apda_Nda = 1093
                                                            AND Nvl(Apda_Val_String, 'F') = 'F'
                                                            AND Apda.History_Status = 'A')*/
                                                    )
        SELECT LISTAGG (l_Err, ',') WITHIN GROUP (ORDER BY 1)
          INTO l_Err_List
          FROM (SELECT CASE
                           WHEN Kattotg_Id IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "КАТТОТГ" в адресі реєстрації'
                           WHEN INDX IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Індекс" в адресі реєстрації'
                           WHEN REGEXP_INSTR (INDX, '^\d{5}$') = 0
                           THEN
                               'В документі "Заява надавача соціальних послуг" атрибут "Індекс" має містити 5 цифр в адресі реєстрації'
                           WHEN Street_Id IS NULL AND Street_Name IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Вулиця" в адресі реєстрації'
                           WHEN Building IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Будинок" в адресі реєстрації'
                           ELSE
                               ''
                       END    AS l_Err
                  FROM Adr
                UNION ALL
                SELECT CASE
                           WHEN Kattotg_Id IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "КАТТОТГ" в адресі фактичного надання послуг'
                           WHEN INDX IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Індекс" в адресі фактичного надання послуг'
                           WHEN REGEXP_INSTR (INDX, '^\d{5}$') = 0
                           THEN
                               'В документі "Заява надавача соціальних послуг" атрибут "Індекс" має містити 5 цифр в адресі фактичного надання послуг'
                           WHEN Street_Id IS NULL AND Street_Name IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Вулиця" в адресі фактичного надання послуг'
                           WHEN Building IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Будинок" в адресі фактичного надання послуг'
                           ELSE
                               ''
                       END    AS l_Err
                  FROM r_Adr
                UNION ALL
                SELECT CASE
                           WHEN     Adr.Kattotg_Id IS NOT NULL
                                AND r_Adr.Kattotg_Id IS NOT NULL
                                AND adr.Kattotg_Id != r_Adr.Kattotg_Id
                           THEN
                                  'В документі "Заява надавача соціальних послуг" не співпвдвють отрибути "КАТТОТГ" '
                               || 'в адресах реєстрації та фактичного надання послуг'
                           WHEN     Adr.INDX IS NOT NULL
                                AND r_Adr.INDX IS NOT NULL
                                AND adr.INDX != r_Adr.INDX
                           THEN
                                  'В документі "Заява надавача соціальних послуг" не співпвдвють отрибути "Індекс" '
                               || 'в адресах реєстрації та фактичного надання послуг'
                           WHEN     Adr.Street_Id IS NOT NULL
                                AND r_Adr.Street_Id IS NOT NULL
                                AND adr.Street_Id != r_Adr.Street_Id
                           THEN
                                  'В документі "Заява надавача соціальних послуг" не співпвдвють отрибути "Вулиця" '
                               || 'в адресах реєстрації та фактичного надання послуг'
                           WHEN     Adr.Building IS NOT NULL
                                AND r_Adr.Building IS NOT NULL
                                AND adr.Building != r_Adr.Building
                           THEN
                                  'В документі "Заява надавача соціальних послуг" не співпвдвють отрибути "Будинок" '
                               || 'в адресах реєстрації та фактичного надання послуг'
                           ELSE
                               ''
                       END    AS l_Err
                  FROM Adr, r_Adr
                 WHERE ISCOINCIDENCE = 'T');

        IF l_Err_List IS NOT NULL
        THEN
            Add_Error (l_Err_List);
        END IF;

        WITH
            Adr_dop
            AS
                (SELECT Apd_Ap,
                        Apd_Id,
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 1098
                                AND Apda.History_Status = 'A')
                            AS "KATTOTG_ID",
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 1133
                                AND Apda.History_Status = 'A')
                            AS "INDX",
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 2535
                                AND Apda.History_Status = 'A')
                            AS "STREET_ID",
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 2536
                                AND Apda.History_Status = 'A')
                            AS "STREET_NAME",
                        (SELECT Apda.Apda_Val_String
                           FROM Ap_Document_Attr Apda
                          WHERE     Apda.Apda_Apd = Apd.Apd_Id
                                AND Apda_Nda = 2537
                                AND Apda.History_Status = 'A')
                            AS "BUILDING"
                   FROM Ap_Document Apd
                  WHERE     Apd.Apd_Ap = g_Ap_Id
                        AND Apd.Apd_Ndt = 750
                        AND Apd.History_Status = 'A')
        SELECT LISTAGG (l_Err, ',') WITHIN GROUP (ORDER BY 1)
          INTO l_Err_List
          FROM (SELECT CASE
                           WHEN Kattotg_Id IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "КАТТОТГ" в додатковій адресі фактичного надання послуг'
                           WHEN INDX IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Індекс" в додатковій адресі фактичного надання послуг'
                           WHEN REGEXP_INSTR (INDX, '^\d{5}$') = 0
                           THEN
                               'В документі "Заява надавача соціальних послуг" атрибут "Індекс" має містити 5 цифр в адресі фактичного надання послуг'
                           WHEN Street_Id IS NULL AND Street_Name IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Вулиця" в додатковій адресі фактичного надання послуг'
                           WHEN Building IS NULL
                           THEN
                               'В документі "Заява надавача соціальних послуг" не заповнено атрибут "Будинок" в додатковій адресі фактичного надання послуг'
                           ELSE
                               ''
                       END    AS l_Err
                  FROM Adr_dop);

        IF l_Err_List IS NOT NULL
        THEN
            Add_Error (l_Err_List);
        END IF;
    END;

    ---------------------------------------------------------------------
    --                   ПЕРЕВІРКА ДЕКЛАРАЦІЇ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Declaration
    IS
        l_Decl_Exists       NUMBER;
        l_Ss_Exists         NUMBER;
        l_Ap_Month          VARCHAR2 (2)
                                := TO_CHAR (NVL (g_Ap_Reg_Dt, SYSDATE), 'mm');
        l_Cur_Year          VARCHAR2 (4)
                                := TO_CHAR (NVL (g_Ap_Reg_Dt, SYSDATE), 'yyyy');
        l_Prev_Year         VARCHAR2 (4)
            := TO_CHAR (ADD_MONTHS (NVL (g_Ap_Reg_Dt, SYSDATE), -12), 'yyyy');
        l_Apr_Start_Dt      DATE;
        l_Apr_Stop_Dt       DATE;
        l_Proper_Start_Dt   VARCHAR2 (10);
        l_Proper_Stop_Dt    VARCHAR2 (10);
    BEGIN
        SELECT SIGN (COUNT (*)),
               MAX (TRUNC (d.Apr_Start_Dt)),
               MAX (TRUNC (d.Apr_Stop_Dt))
          INTO l_Decl_Exists, l_Apr_Start_Dt, l_Apr_Stop_Dt
          FROM Ap_Declaration d
         WHERE d.Apr_Ap = g_Ap_Id;

        IF g_Ap_Tp = 'SS'
        THEN
            SELECT SIGN (COUNT (1))
              INTO l_Ss_Exists
              FROM Ap_Service s
             WHERE     s.Aps_Ap = g_Ap_Id
                   AND s.History_Status = 'A'
                   AND s.Aps_Nst BETWEEN 400 AND 500;
        END IF;

        IF l_Decl_Exists = 0
        THEN
            IF g_Aps.EXISTS (Api$appeal.c_Aps_Nst_Help_Alone_Mother)
            THEN
                Add_Error (
                    'Обрано вид послуги «допомога на дітей одиноким матерям», а Декларацію не заповнено');
            END IF;

            -- #113272
            IF Only_One_Aps_Exists (249) OR Only_One_Aps_Exists (267)
            THEN
                Add_Error (
                    'Для послуги обов`язково має бути заповнена декларація.');
            END IF;

            IF     l_Ss_Exists = 1
               AND (   NVL (get_ap_doc_string (g_ap_id, 801, 1871), 'F') =
                       'T'
                    OR NVL (get_ap_doc_string (g_ap_id, 802, 1948), 'F') =
                       'T'
                    OR NVL (get_ap_doc_string (g_ap_id, 803, 2528), 'F') =
                       'T'
                    OR NVL (get_ap_doc_string (g_ap_id, 836, 3446), 'F') =
                       'T')
            THEN
                --         AND Api$verification_Cond.Isneed_Decl_For_Ss(g_Ap_Id) THEN
                Add_Error (
                    'Обрано надання платних соціальніх послуг, а Декларацію не заповнено');
            END IF;

            --Если декларация не заполнена, то нет смысла выполнять остальные контроли
            RETURN;
        END IF;

        IF l_Ss_Exists = 1
        THEN
            WITH
                Prev
                AS
                    (SELECT TRUNC (ADD_MONTHS (g_Ap_Reg_Dt, -1), 'MM')    AS Dt
                       FROM DUAL)
            SELECT TO_CHAR (TRUNC (ADD_MONTHS (Dt, -3), 'Q'), 'dd.mm.yyyy'),
                   TO_CHAR (
                         TRUNC (
                             ADD_MONTHS (TRUNC (ADD_MONTHS (Dt, -3), 'Q'), 3),
                             'Q')
                       - 1,
                       'dd.mm.yyyy')
              INTO l_Proper_Start_Dt, l_Proper_Stop_Dt
              FROM Prev;
        ELSE
            --Перевірка періоду за який подається декларація
            IF l_Ap_Month IN ('08', '09', '10')
            THEN
                l_Proper_Start_Dt := '01.01.' || l_Cur_Year;
                l_Proper_Stop_Dt := '30.06.' || l_Cur_Year;
            ELSIF l_Ap_Month IN ('11', '12', '01')
            THEN
                l_Proper_Start_Dt :=
                       '01.04.'
                    || CASE
                           WHEN l_Ap_Month IN ('11', '12') THEN l_Cur_Year
                           ELSE l_Prev_Year
                       END;
                l_Proper_Stop_Dt :=
                       '30.09.'
                    || CASE
                           WHEN l_Ap_Month IN ('11', '12') THEN l_Cur_Year
                           ELSE l_Prev_Year
                       END;
            ELSIF l_Ap_Month IN ('02', '03', '04')
            THEN
                l_Proper_Start_Dt := '01.07.' || l_Prev_Year;
                l_Proper_Stop_Dt := '31.12.' || l_Prev_Year;
            ELSIF l_Ap_Month IN ('05', '06', '07')
            THEN
                l_Proper_Start_Dt := '01.10.' || l_Prev_Year;
                l_Proper_Stop_Dt := '31.03.' || l_Cur_Year;
            END IF;
        END IF;

        IF (   l_Apr_Start_Dt <> TO_DATE (l_Proper_Start_Dt, 'dd.mm.yyyy')
            OR l_Apr_Stop_Dt <> TO_DATE (l_Proper_Stop_Dt, 'dd.mm.yyyy'))
        THEN
            Add_Error (
                   'Неправильно заповнено період, за який подається декларація. Поле "Період з" має містити дату '
                || l_Proper_Start_Dt
                || ', "Період по" має містити дату '
                || l_Proper_Stop_Dt);
        END IF;

        FOR xx
            IN (SELECT *
                  FROM ap_declaration  d
                       JOIN apr_person p ON (d.apr_id = p.aprp_apr)
                       LEFT JOIN ap_person ap
                           ON (    ap.app_id = p.aprp_app
                               AND ap.history_status = 'A')
                 WHERE     p.history_status = 'A'
                       AND d.apr_ap = g_Ap_Id
                       AND ap.app_id IS NULL
                 FETCH FIRST ROW ONLY)
        LOOP
            Add_Error (
                'Для особи в декларації не вказано актуального учасника звернення!');
        END LOOP;

        IF NOT g_Warnings
        THEN
            RETURN;
        END IF;

        FOR Rec
            IN (SELECT DISTINCT
                       Pp.App_Ln || ' ' || Pp.App_Fn || ' ' || Pp.App_Mn    AS Pib
                  FROM Ap_Document  d
                       JOIN Ap_Document_Attr a
                           ON     d.Apd_Id = a.Apda_Apd
                              AND a.Apda_Nda = Api$appeal.c_Apda_Nda_Fop
                              AND a.Apda_Val_String = 'T'
                       JOIN Apr_Person p
                           ON     d.Apd_App = p.Aprp_App
                              AND p.History_Status = 'A'
                       JOIN Ap_Person Pp ON p.Aprp_App = Pp.App_Id
                       LEFT JOIN Apr_Income i
                           ON     p.Aprp_Id = i.Apri_Aprp
                              AND i.History_Status = 'A'
                              AND i.Apri_Tp IN ('15', '16', '17')
                 WHERE     d.Apd_Ap = g_Ap_Id
                       AND d.Apd_Ndt = Api$appeal.c_Apd_Ndt_Ankt
                       AND d.History_Status = 'A'
                       AND i.Apri_Id IS NULL)
        LOOP
            Add_Warning (
                'Для особи ' || Rec.Pib || ' не заповнено дохід як ФОП');
        END LOOP;

        FOR Rec
            IN (SELECT DISTINCT
                       Pp.App_Ln || ' ' || Pp.App_Fn || ' ' || Pp.App_Mn    AS Pib
                  FROM Ap_Document  d
                       JOIN Ap_Document_Attr a
                           ON     d.Apd_Id = a.Apda_Apd
                              AND a.Apda_Nda IN
                                      (Api$appeal.c_Apda_Nda_Care_Child3,
                                       Api$appeal.c_Apda_Nda_Care_Old,
                                       Api$appeal.c_Apda_Nda_Care_Child_Dis,
                                       Api$appeal.c_Apda_Nda_Care_Per_Dis1,
                                       Api$appeal.c_Apda_Nda_Care_Per_Dis2,
                                       Api$appeal.c_Apda_Nda_Care_Child18)
                              AND a.Apda_Val_String = 'T'
                       JOIN Apr_Person p
                           ON     d.Apd_App = p.Aprp_App
                              AND p.History_Status = 'A'
                       JOIN Ap_Person Pp ON p.Aprp_App = Pp.App_Id
                       LEFT JOIN Apr_Income i
                           ON     p.Aprp_Id = i.Apri_Aprp
                              AND i.History_Status = 'A'
                              AND i.Apri_Tp IN ('6')
                 WHERE     d.Apd_Ap = g_Ap_Id
                       AND d.Apd_Ndt = Api$appeal.c_Apd_Ndt_Ankt
                       AND d.History_Status = 'A'
                       AND i.Apri_Id IS NULL)
        LOOP
            Add_Warning (
                   'Для особи '
                || Rec.Pib
                || ' не заповнено дохід з видом "Допомога"');
        END LOOP;
    END;

    --==============================================================--
    --  Отримання текстового параметру документу по учаснику
    --==============================================================--
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

    --==============================================================--
    --  Отримання параметру Дата з документу по учаснику
    --==============================================================--
    FUNCTION Get_Ap_Doc_Dt (p_Ap    Ap_Document.Apd_Ap%TYPE,
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
               AND Apd_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    FUNCTION Get_Ap_Doc_String (p_Ap    Ap_Document.Apd_Ap%TYPE,
                                p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                                p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (200);
    BEGIN
        SELECT MAX (Apda_Val_string)
          INTO l_Rez
          FROM Ap_Document, Ap_Document_Attr
         WHERE     Apda_Apd = Apd_Id
               AND Ap_Document.History_Status = 'A'
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apd_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    FUNCTION Get_Ap_Doc_String (p_Ap    Ap_Document.Apd_Ap%TYPE,
                                p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (200);
    BEGIN
        SELECT MAX (Apda_Val_string)
          INTO l_Rez
          FROM Ap_Document, Ap_Document_Attr
         WHERE     Apda_Apd = Apd_Id
               AND Ap_Document.History_Status = 'A'
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apd_Ap = p_Ap
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    FUNCTION Get_Ap_Doc_Scan (p_Ap    Ap_Document.Apd_Ap%TYPE,
                              p_Ndt   Ap_Document.Apd_Ndt%TYPE)
        RETURN NUMBER
    IS
        L_RES          SYS_REFCURSOR;
        l_Doc_Id       NUMBER;
        l_File_Code    VARCHAR2 (200);
        l_File_Name    VARCHAR2 (200);
        l_File_MT      VARCHAR2 (200);
        l_File_Size    NUMBER;
        l_File_Hash    VARCHAR2 (200);
        l_File_Cr_Dt   DATE;
        l_File_Dscr    VARCHAR2 (2000);
        l_File_SC      VARCHAR2 (2000);
        l_File_SH      VARCHAR2 (2000);
        l_Added_S      VARCHAR2 (2000);
        l_Dat_Num      VARCHAR2 (2000);
        l_Dh_Id        NUMBER;
        l_Apd_Dh       NUMBER;
    BEGIN
        USS_DOC.API$DOCUMENTS.CLEAR_TMP_WORK_IDS;

        SELECT MAX (apd.Apd_Dh)
          INTO l_Apd_Dh
          FROM Ap_Document apd
         WHERE History_Status = 'A' AND Apd_Ap = p_Ap AND Apd_Ndt = p_Ndt;

        INSERT INTO USS_DOC.TMP_WORK_IDS (X_ID)
             VALUES (l_Apd_Dh);

        USS_DOC.API$DOCUMENTS.GET_SIGNED_ATTACHMENTS (P_RES => L_RES);

        LOOP
            FETCH L_RES
                INTO l_Doc_Id,
                     l_File_Code,
                     l_File_Name,
                     l_File_MT,
                     l_File_Size,
                     l_File_Hash,
                     l_File_Cr_Dt,
                     l_File_Dscr,
                     l_File_SC,
                     l_File_SH,
                     l_Added_S,
                     l_Dat_Num,
                     l_Dh_Id;

            EXIT WHEN L_RES%NOTFOUND;

            IF     l_Dh_Id = l_Apd_Dh
               AND UPPER (l_File_MT) IN
                       ('IMAGE/PNG', 'IMAGE/JPEG', 'APPLICATION/PDF')
            THEN
                CLOSE L_RES;

                RETURN 1;
            --DBMS_OUTPUT.PUT_LINE ( l_Doc_Id||'   '||l_File_Code||'   '||l_File_Name||'   '||l_File_MT||'    ' ||l_Dh_Id);
            END IF;
        END LOOP;

        CLOSE L_RES;

        /*
             x_Id1 AS Doc_Id,
               f.File_Code,
               f.File_Name,
               f.File_Mime_Type,
               f.File_Size,
               f.File_Hash,
               f.File_Create_Dt,
               f.File_Description,
               s.File_Code AS File_Sign_Code,
               s.File_Hash AS File_Sign_Hash,
               (SELECT Listagg(Fs.File_Code, ',') Within GROUP(ORDER BY Ss.Dats_Id)
                  FROM Doc_Attach_Signs Ss
                  JOIN Files Fs
                    ON Ss.Dats_Sign_File = Fs.File_Id
                 WHERE Ss.Dats_Dat = a.Dat_Id) AS Added_Signs,
               a.Dat_Num,
               Dat_Dh AS Dh_Id
                FROM Doc_Attachments a,
                     Files           f,
                     Files           s,
                     Tmp_Work_Set1   t
               WHERE a.Dat_Dh = x_Id2
                     AND a.Dat_File = f.File_Id
                     AND a.Dat_Sign_File = s.File_Id(+)
               ORDER BY a.Dat_Num;
        */

        RETURN 0;
    END;

    FUNCTION Get_Apd_Doc_Scan (p_Apd Ap_Document.Apd_id%TYPE)
        RETURN NUMBER
    IS
        L_RES          SYS_REFCURSOR;
        l_Doc_Id       NUMBER;
        l_File_Code    VARCHAR2 (200);
        l_File_Name    VARCHAR2 (200);
        l_File_MT      VARCHAR2 (200);
        l_File_Size    NUMBER;
        l_File_Hash    VARCHAR2 (200);
        l_File_Cr_Dt   DATE;
        l_File_Dscr    VARCHAR2 (2000);
        l_File_SC      VARCHAR2 (2000);
        l_File_SH      VARCHAR2 (2000);
        l_Added_S      VARCHAR2 (2000);
        l_Dat_Num      VARCHAR2 (2000);
        l_Dh_Id        NUMBER;
        l_Apd_Dh       NUMBER;
    BEGIN
        USS_DOC.API$DOCUMENTS.CLEAR_TMP_WORK_IDS;

        SELECT MAX (apd.Apd_Dh)
          INTO l_Apd_Dh
          FROM Ap_Document apd
         WHERE History_Status = 'A' AND apd_id = p_Apd;

        INSERT INTO USS_DOC.TMP_WORK_IDS (X_ID)
             VALUES (l_Apd_Dh);

        --USS_DOC.API$DOCUMENTS.Get_Attachments
        USS_DOC.API$DOCUMENTS.Get_SIGNED_ATTACHMENTS (P_RES => L_RES);

        LOOP
            FETCH L_RES
                INTO l_Doc_Id,
                     l_File_Code,
                     l_File_Name,
                     l_File_MT,
                     l_File_Size,
                     l_File_Hash,
                     l_File_Cr_Dt,
                     l_File_Dscr,
                     l_File_SC,
                     l_File_SH,
                     l_Added_S,
                     l_Dat_Num,
                     l_Dh_Id;

            EXIT WHEN L_RES%NOTFOUND;

            IF     l_Dh_Id = l_Apd_Dh
               AND UPPER (l_File_MT) IN
                       ('IMAGE/PNG', 'IMAGE/JPEG', 'APPLICATION/PDF')
            THEN
                CLOSE L_RES;

                RETURN 1;
            --DBMS_OUTPUT.PUT_LINE ( l_Doc_Id||'   '||l_File_Code||'   '||l_File_Name||'   '||l_File_MT||'    ' ||l_Dh_Id);
            END IF;
        END LOOP;

        CLOSE L_RES;

        RETURN 0;
    END;

    FUNCTION Get_Doc_id (p_App   Ap_Document.Apd_App%TYPE,
                         p_Ndt   Ap_Document.Apd_Ndt%TYPE,
                         p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN NUMBER
    IS
        l_Rez   NUMBER;
    BEGIN
        SELECT MAX (Apda_Val_id)
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

    --==============================================================--
    --  Отримання текстового параметру документу по id документа
    --==============================================================--
    FUNCTION Get_Val_String (p_Apd       Ap_Document.Apd_Id%TYPE,
                             p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                             p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (Apda_Val_String)
          INTO l_Rez
          FROM Ap_Document_Attr
         WHERE     Apda_Apd = p_Apd
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apda_Nda = p_Nda;

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Rez, p_Default);
        END IF;

        RETURN l_Rez;
    END;

    --==============================================================--
    FUNCTION Get_Val_dt (p_Apd   Ap_Document.Apd_Id%TYPE,
                         p_Nda   Ap_Document_Attr.Apda_Nda%TYPE)
        RETURN DATE
    IS
        l_Rez   DATE;
    BEGIN
        SELECT MAX (Apda_Val_dt)
          INTO l_Rez
          FROM Ap_Document_Attr
         WHERE     Apda_Apd = p_Apd
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apda_Nda = p_Nda;

        RETURN l_Rez;
    END;

    --==============================================================--
    FUNCTION Get_Val_Id (p_Apd       Ap_Document.Apd_Id%TYPE,
                         p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                         p_Default   NUMBER DEFAULT NULL)
        RETURN NUMBER
    IS
        l_Rez   NUMBER;
    BEGIN
        SELECT MAX (Apda_Val_Id)
          INTO l_Rez
          FROM Ap_Document_Attr
         WHERE     Apda_Apd = p_Apd
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apda_Nda = p_Nda;

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Rez, p_Default);
        END IF;

        RETURN l_Rez;
    END;

    --==============================================================--
    FUNCTION Get_Val_Int (p_Apd       Ap_Document.Apd_Id%TYPE,
                          p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                          p_Default   NUMBER DEFAULT NULL)
        RETURN NUMBER
    IS
        l_Rez   NUMBER;
    BEGIN
        SELECT MAX (Apda_Val_Int)
          INTO l_Rez
          FROM Ap_Document_Attr
         WHERE     Apda_Apd = p_Apd
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apda_Nda = p_Nda;

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Rez, p_Default);
        END IF;

        RETURN l_Rez;
    END;

    --==============================================================--
    FUNCTION Get_Val_Sum (p_Apd       Ap_Document.Apd_Id%TYPE,
                          p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                          p_Default   NUMBER DEFAULT NULL)
        RETURN NUMBER
    IS
        l_Rez   NUMBER;
    BEGIN
        SELECT MAX (Apda_Val_Sum)
          INTO l_Rez
          FROM Ap_Document_Attr
         WHERE     Apda_Apd = p_Apd
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apda_Nda = p_Nda;

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Rez, p_Default);
        END IF;

        RETURN l_Rez;
    END;

    --==============================================================--
    --  Отримання наявності документу
    --==============================================================--
    FUNCTION Get_Doc_Count (p_App   Ap_Document.Apd_App%TYPE,
                            p_Ndt   Ap_Document.Apd_Ndt%TYPE)
        RETURN NUMBER
    IS
        l_Rez   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO l_Rez
          FROM Ap_Document
         WHERE     Ap_Document.History_Status = 'A'
               AND Apd_App = p_App
               AND Apd_Ndt = p_Ndt;

        RETURN l_Rez;
    END;

    --кількість документів классу 13. Ідентифікація особи
    FUNCTION Get_Doc_ndc13_Count (p_App Ap_Document.Apd_App%TYPE)
        RETURN NUMBER
    IS
        l_Rez   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO l_Rez
          FROM Ap_Document
               JOIN Uss_Ndi.v_Ndi_Document_Type
                   ON ndt_id = apd_ndt AND ndt_ndc = 13
         WHERE Ap_Document.History_Status = 'A' AND Apd_App = p_App;

        RETURN l_Rez;
    END;

    --==============================================================--
    FUNCTION Get_AP_Doc_Count (p_Ap    Ap_Document.Apd_Ap%TYPE,
                               p_Ndt   Ap_Document.Apd_Ndt%TYPE)
        RETURN NUMBER
    IS
        l_Rez   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO l_Rez
          FROM Ap_Document
         WHERE     Ap_Document.History_Status = 'A'
               AND Apd_Ap = p_Ap
               AND Apd_Ndt = p_Ndt;

        RETURN l_Rez;
    END;

    --==============================================================--
    --кількість документів классу 13. Ідентифікація особи
    FUNCTION Get_AP_Doc_ndc13_Count (p_Ap Ap_Document.Apd_Ap%TYPE)
        RETURN NUMBER
    IS
        l_Rez   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO l_Rez
          FROM Ap_Document
               JOIN Uss_Ndi.v_Ndi_Document_Type
                   ON ndt_id = apd_ndt AND ndt_ndc = 13
         WHERE Ap_Document.History_Status = 'A' AND Apd_Ap = p_Ap;

        RETURN l_Rez;
    END;

    --==============================================================--
    --  Перевірка документів по персоні по переліку через кому
    --==============================================================--
    FUNCTION check_doc_exists (p_app_id NUMBER, p_ndt_list VARCHAR2)
        RETURN VARCHAR2
    IS
        l_cnt        INTEGER;
        l_all_cnt    INTEGER;
        l_err_list   VARCHAR2 (4000);
    BEGIN
        WITH
            ndt_list
            AS
                (    SELECT REGEXP_SUBSTR (p_ndt_list,
                                           '[^,]+',
                                           1,
                                           LEVEL)    AS x_ndt
                       FROM DUAL
                 CONNECT BY LEVEL <=
                            LENGTH (REGEXP_REPLACE (p_ndt_list, '[^,]*')) + 1)
        SELECT LISTAGG ('"' || dt.ndt_name_short || '"', ', ')
                   WITHIN GROUP (ORDER BY dt.ndt_id)
                   x_Doc_list,
               SUM (CASE WHEN apd_id IS NOT NULL THEN 1 ELSE 0 END)
                   AS x_exists_cnt,
               SUM (1)
                   AS x_all_cnt
          INTO l_err_list, l_cnt, l_all_cnt
          FROM ndt_list
               JOIN uss_ndi.v_ndi_document_type dt ON dt.ndt_id = x_ndt
               LEFT JOIN ap_document apd
                   ON     apd_ndt = x_ndt
                      AND apd.history_status = 'A'
                      AND apd.apd_app = p_app_id;

        IF l_cnt > 0
        THEN
            RETURN '';
        END IF;

        SELECT    'Для учасника ('
               || NVL (App_Inn, App_Doc_Num)
               || ') з типом "'
               || tp.DIC_SNAME
               || '"  не додано '
               || CASE
                      WHEN l_all_cnt = 1 THEN 'документ ' || l_err_list
                      ELSE 'один з цих документів: ' || l_err_list
                  END
          INTO l_err_list
          FROM ap_person
               LEFT JOIN Uss_Ndi.v_Ddn_App_Tp tp ON tp.Dic_Value = app_tp
         WHERE app_id = p_app_id;

        RETURN l_err_list;
    END;

    --==============================================================--
    --  Перевірка заповненості атрибутів документів - повертає кількість незаповнених атрибутів
    --==============================================================--
    FUNCTION Check_Documents_Filled (p_Apd_Id Ap_Document.Apd_Id%TYPE)
        RETURN VARCHAR2
    IS
        CURSOR Documentcheck IS
              SELECT    'Для '
                     || App.App_Ln
                     || ' '
                     || App.App_Fn
                     || ' '
                     || App.App_Mn
                     || ' в документі '
                     || Ndt.Ndt_Name_Short
                     || ' не заповнено атрибут(и):'
                     || LISTAGG (Apda.Nda_Name, ', ') WITHIN GROUP (ORDER BY 1)    Err_Str
                FROM v_Ap_Document_Attr_Check Apda
                     INNER JOIN Uss_Ndi.v_Ndi_Document_Type Ndt
                         ON Ndt.Ndt_Id = Apda.Apd_Ndt
                     LEFT JOIN Ap_Person App ON App.App_Id = Apda.Apd_App
               WHERE Apda.Is_Req_Error = 1 AND Apda.Apd_Id = p_Apd_Id
            GROUP BY App.App_Ln,
                     App.App_Fn,
                     App.App_Mn,
                     Ndt.Ndt_Name_Short;

        l_Err_List   VARCHAR2 (4000);
    BEGIN
        /*
        Під час збереження будь-якого звернення щодо призначення допомог. Необхідно перевіряти заповнення усіх атрибутів документів.
        У разі, якщо якийсь із атрибутів документа не заповнено, у вікні "Перегляд повідомлень" видавати повідомлення з таким текстом:
        Для <ПІБ учасника звернення> у документі <Коротка назва документу> не заповнено атрибут(и) <назва атрибуту 1>, <назва атрибуту 2>, <назва атрибуту 3>....
        Тип повідомлення "Попередження"
        */
        FOR d IN Documentcheck
        LOOP
            l_Err_List := d.Err_Str;
        END LOOP;

        RETURN l_Err_List;
    END;

    --Перевірка заповненості атрибутів документів - повертає кількість незаповнених атрибутів
    FUNCTION Check_Documents_Filled (p_App        Ap_Document.Apd_App%TYPE,
                                     p_Ndt        Ap_Document.Apd_Ndt%TYPE,
                                     p_Nda_List   VARCHAR2,
                                     p_Is_Need    NUMBER DEFAULT 1)
        RETURN VARCHAR2
    IS
        l_Cnt        INTEGER;
        l_Rez        INTEGER := 1;
        l_Sc         Ap_Person.App_Sc%TYPE;
        l_Tmp        VARCHAR2 (4000);
        l_Err_List   VARCHAR2 (4000);
    BEGIN
        SELECT COUNT (*)
          INTO l_Cnt
          FROM Ap_Document
         WHERE Apd_App = p_App AND Apd_Ndt = p_Ndt AND History_Status = 'A';

        IF l_Cnt > 0
        THEN
            --Рахуємо кількість незаповнених атрибутів
            WITH
                Nda_List
                AS
                    (    SELECT REGEXP_SUBSTR (p_Nda_List,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS i_Nda
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (p_Nda_List, '[^,]*'))
                                + 1)
            SELECT SUM (
                       CASE
                           WHEN    Apda_Id IS NULL
                                OR (    Pt_Data_Type = 'STRING'
                                    AND Apda_Val_String IS NULL)
                                OR (    Pt_Data_Type = 'INTEGER'
                                    AND Apda_Val_Int IS NULL)
                                OR (    Pt_Data_Type = 'SUM'
                                    AND Apda_Val_Sum IS NULL)
                                OR (    Pt_Data_Type = 'ID'
                                    AND Apda_Val_Id IS NULL)
                                OR (    Pt_Data_Type = 'DATE'
                                    AND Apda_Val_Dt IS NULL)
                           THEN
                               1
                           ELSE
                               0
                       END)                          AS x_Err_Cnt,
                   LISTAGG (
                       CASE
                           WHEN    Apda_Id IS NULL
                                OR (    Pt_Data_Type = 'STRING'
                                    AND Apda_Val_String IS NULL)
                                OR (    Pt_Data_Type = 'INTEGER'
                                    AND Apda_Val_Int IS NULL)
                                OR (    Pt_Data_Type = 'SUM'
                                    AND Apda_Val_Sum IS NULL)
                                OR (    Pt_Data_Type = 'ID'
                                    AND Apda_Val_Id IS NULL)
                                OR (    Pt_Data_Type = 'DATE'
                                    AND Apda_Val_Dt IS NULL)
                           THEN
                               NVL (Nda_Name, Pt_Name)
                           ELSE
                               ''
                       END,
                       ', ')
                   WITHIN GROUP (ORDER BY Nda_Id)    AS x_Err_Fields_List
              INTO l_Rez, l_Tmp
              FROM Ap_Document       Apd,
                   Uss_Ndi.v_Ndi_Document_Attr,
                   Uss_Ndi.v_Ndi_Param_Type,
                   Ap_Document_Attr  Apda,
                   Nda_List
             WHERE     Apd_App = p_App
                   AND Apd_Ndt = p_Ndt
                   AND Apd_Ndt = Nda_Ndt
                   AND Apda_Apd(+) = Apd_Id
                   AND Apda_Nda(+) = Nda_Id
                   AND Nda_Pt = Pt_Id
                   AND Nda_Id = i_Nda
                   AND Apd.History_Status = 'A'
                   AND Apda.History_Status(+) = 'A';

            IF l_Rez > 0
            THEN
                SELECT App_Sc
                  INTO l_Sc
                  FROM Ap_Person
                 WHERE App_Id = p_App;

                SELECT    'Для '
                       || Uss_Person.Api$sc_Tools.Get_Pib (l_Sc)
                       || ' в документі з типом '
                       || Ndt_Name_Short
                       || ' не заповнені атрибути: '
                       || l_Tmp
                  INTO l_Err_List
                  FROM Uss_Ndi.v_Ndi_Document_Type
                 WHERE Ndt_Id = p_Ndt;
            END IF;
        ELSIF p_Is_Need = 1
        THEN
            SELECT App_Sc
              INTO l_Sc
              FROM Ap_Person
             WHERE App_Id = p_App;

            SELECT    'Для '
                   || Uss_Person.Api$sc_Tools.Get_Pib (l_Sc)
                   || ' не знайдено документа з типом '
                   || Ndt_Name
              INTO l_Err_List
              FROM Uss_Ndi.v_Ndi_Document_Type
             WHERE Ndt_Id = p_Ndt;
        END IF;

        IF l_Rez > 0
        THEN
            RETURN l_Err_List;
        ELSE
            RETURN '';
        END IF;
    END;

    --==============================================================--
    --  Перевірка наявності документа
    --==============================================================--
    FUNCTION Check_Documents_Exists (p_App   Ap_Document.Apd_App%TYPE,
                                     p_Ndt   Ap_Document.Apd_Ndt%TYPE)
        RETURN VARCHAR2
    IS
        l_Err_List   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (Ndt.Ndt_Name_Short, ', ') WITHIN GROUP (ORDER BY 1)
          INTO l_Err_List
          FROM Uss_Ndi.v_Ndi_Document_Type  Ndt
               LEFT JOIN Ap_Document Apd
                   ON     Apd.Apd_Ndt = Ndt.Ndt_Id
                      AND Apd.Apd_App = p_App
                      AND Apd.History_Status = 'A'
         WHERE Ndt.Ndt_Id = p_Ndt AND Apd.Apd_Id IS NULL;

        RETURN l_Err_List;
    END;

    --==============================================================--
    --  Завантаження опису персон для держутримання
    --==============================================================--
    PROCEDURE Set_Information
    IS
    BEGIN
        SELECT App_Id,
               App_Ap,
               App_Sc,
               App_Tp,
               NVL ("DisabilityChild", 'F')        Disabilitychild, -- Дитина з інвалідністю
               NVL ("DisabilityFromChild", 'F')    Disabilityfromchild, -- Особа з інвалідністю з дитинства
               NVL ("Guardian", 'F')               Guardian,         -- Опікун
               NVL ("Trustee", 'F')                Trustee,    -- Піклувальник
               NVL ("Adopter", 'F')                Adopter,     -- Усиновлювач
               NVL ("Parents", 'F')                Parents,     -- Мати/батько
               NVL ("RepresentativeInst", 'F')     Representativeinst, -- Представник закладу, де особа з інвалідністю перебуває на держутриманні
               NVL ("ParentsEducator", 'F')        Parentseducator -- Один з батьків-вихователів
                                                                  ,
               SUM (CASE App_Tp WHEN 'O' THEN 1 ELSE 0 END)
                   OVER (PARTITION BY App_Ap)      Cnt_o,
               SUM (CASE App_Tp WHEN 'DU' THEN 1 ELSE 0 END)
                   OVER (PARTITION BY App_Ap)      Cnt_Du
          BULK COLLECT INTO g_Information
          FROM (SELECT App.App_Id,
                       App.App_Ap,
                       App.App_Sc,
                       App.App_Tp,
                       Apda.Apda_Nda,
                       Apda.Apda_Val_String
                  FROM Ap_Person  App
                       JOIN Ap_Document Apd
                           ON     Apd.Apd_App = App.App_Id
                              AND Apd.Apd_Ndt = 10037
                              AND Apd.History_Status = 'A'
                       LEFT JOIN Ap_Document_Attr Apda
                           ON     Apda.Apda_Apd = Apd.Apd_Id
                              AND Apda.History_Status = 'A'
                 WHERE App.App_Ap = g_Ap_Id AND App.History_Status = 'A')
                   PIVOT (
                         MAX (Apda_Val_String)
                         FOR Apda_Nda
                         IN (929 "DisabilityChild",   -- Дитина з інвалідністю
                            930 "DisabilityFromChild", -- Особа з інвалідністю з дитинства
                            914 "Guardian",                          -- Опікун
                            915 "Trustee",                     -- Піклувальник
                            916 "Adopter",                      -- Усиновлювач
                            917 "Parents",                      -- Мати/батько
                            918 "RepresentativeInst", -- Представник закладу, де особа з інвалідністю перебуває на держутриманні
                            919 "ParentsEducator" -- Один з батьків-вихователів
                                                 ));
    END;

    --==============================================================--
    --  Віддати опис персон для держутримання
    --==============================================================--
    FUNCTION Get_Information
        RETURN Table_Information
        PIPELINED
    IS
    BEGIN
        IF g_Information.COUNT > 0
        THEN
            FOR i IN g_Information.FIRST .. g_Information.LAST
            LOOP
                PIPE ROW (g_Information (i));
            END LOOP;
        END IF;

        RETURN;
    END;

    --==============================================================--
    --  Перевірка для РНСП
    --==============================================================--
    PROCEDURE Check_g (Err_List OUT VARCHAR2)
    IS
    BEGIN
        --      Raise_Application_Error(-20000, 'Check_g');

        SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (SELECT 'CheckG[1]: У заявника повинен бути присутнім один з документів – або "Паспорт громадянина України", або "ID картка" або "Паспортний документ іноземця"'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND (  Api$validation.Get_Doc_Count (App_Id, 6)
                            + Api$validation.Get_Doc_Count (App_Id, 7)
                            + Api$validation.Get_Doc_Count (App_Id, 8)) =
                           0
                       AND g_Ap_Src != 'PORTAL'
                UNION ALL
                /*
                            SELECT CASE
                                     WHEN Get_Doc_Count(App_Id, 750) > 3
                                       THEN 'Допускається створення не більше трьох документів про додаткові адреси надання послуг надавачем'
                                     ELSE ''
                                   END AS x_Errors_List
                              FROM Ap_Person App
                             WHERE App.App_Ap = g_Ap_Id
                                   AND App.App_Tp = 'Z'
                                   AND App.History_Status = 'A'
                            UNION ALL
                */
                SELECT CASE
                           WHEN Get_Doc_Count (App_Id, 700) < 1
                           THEN
                               'CheckG[2]: У заявника повинен бути присутнім документ «Заява надавача соціальних послуг»'
                           ELSE
                               ''
                       END    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND g_Ap_Src != 'PORTAL'
                UNION ALL
                SELECT CASE
                           WHEN Get_Doc_Count (App_Id, 701) < 1
                           THEN
                               'CheckG[3]: У заявника повинен бути присутнім документ «Перелік соціальних послуг, які має право надавати надавач соціальних послуг, їх зміст та обсяг, умови і порядок отримання»'
                           ELSE
                               ''
                       END    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                /*
                            UNION ALL
                            SELECT CASE
                                     WHEN Get_Doc_Count(App_Id, 711) < 1
                                       THEN 'У заявника повинен бути присутнім документ «Копії установчих та інших документів, якими визначено перелік соціальних послуг та категорії осіб, яким надаються такі послуги»'
                                     ELSE ''
                                   END AS x_Errors_List
                              FROM Ap_Person App
                             WHERE App.App_Ap = g_Ap_Id
                                   AND App.App_Tp = 'Z'
                                   AND App.History_Status = 'A'
                            UNION ALL
                            SELECT CASE
                                     WHEN Get_Doc_Count(App_Id, 705) < 1
                                       THEN 'У заявника повинен бути присутнім документ «Копії документів про освіту, свідоцтва про підвищення кваліфікації, атестацію, неформальне професійне навчання, фаховий рівень працівників»'
                                     ELSE ''
                                   END AS x_Errors_List
                              FROM Ap_Person App
                             WHERE App.App_Ap = g_Ap_Id
                                   AND App.App_Tp = 'Z'
                                   AND App.History_Status = 'A'
                */
                UNION ALL
                SELECT 'CheckG[4]: Формат номера "Паспорт громадянина України": дві великі летери та шість цифр'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND Api$validation.Get_Doc_Count (App_Id, 6) = 1
                       AND NVL (
                               REGEXP_INSTR (
                                   Api$validation.Get_Doc_String (App_Id,
                                                                  6,
                                                                  3),
                                   '^[А-Я]{2}[0-9]{6}$',
                                   1),
                               0) =
                           0
                       AND g_Ap_Src != 'PORTAL'
                UNION ALL
                SELECT 'CheckG[5]: Формат номера "ID картка": дев''ять цифр'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND Api$validation.Get_Doc_Count (App_Id, 7) = 1
                       AND NVL (
                               REGEXP_INSTR (
                                   Api$validation.Get_Doc_String (App_Id,
                                                                  7,
                                                                  9),
                                   '^[0-9]{9}$',
                                   1),
                               0) =
                           0
                       AND g_Ap_Src != 'PORTAL'
                UNION ALL
                SELECT    'CheckG[6]: Додану послугу "'
                       || St.Nst_Name
                       || '" необхідно зберегти у вікні «Картка документу», яке відкривається кнопкою «Відкрити опис» в рядку послуги»'
                  FROM Ap_Service  s
                       JOIN Uss_Ndi.v_Ndi_Nst_Doc_Config c
                           ON     c.Nndc_Nst = s.Aps_Nst
                              AND c.Nndc_Ndt BETWEEN 751 AND 793
                              AND c.Nndc_Ap_Tp = 'G'
                       JOIN Uss_Ndi.v_Ndi_Service_Type St
                           ON St.Nst_Id = s.Aps_Nst
                       LEFT JOIN Ap_Document d
                           ON     d.Apd_Ap = s.Aps_Ap
                              AND d.Apd_Ndt = c.Nndc_Ndt
                              AND d.History_Status = 'A'
                 WHERE     s.History_Status = 'A'
                       AND s.Aps_Ap = g_Ap_Id
                       AND d.Apd_Id IS NULL)
         WHERE x_Errors_List IS NOT NULL;
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    /*
    У випадку, якщо у зверненні з ІД=20 буде зареєстровано учасника звернення з типом "Член сім'ї", то це помилка і необхідно видавати повідомлення:
    "Під час реєстрації звернень не можна застосовувати учасника звернення з типом "Член сім''ї",
    в зверненні можуть фігурувати "Представник заявника" і "Заявник" якщо заявник недієздатний або "Заявник" та/або "Утриманці",
    якщо звернення надійшло від одного з батьків"
    */
    /*
    Якщо в атрибуті nda_id=3477 в документі nda_ndt = 10221 користувач обрав КАТТОТГ (місця проживання),
    у якому перший рівень не Херсонська область (КАТТОТГ UA65000000000030969) або не Миколаївська область (КАТТОТГ UA48000000000039575), то це помилка. В повідомленні про помилку необхідно зазначати:
    "В "Заяві про надання грошової допомоги постраждалому населенню внаслідок підриву рф Каховської ГЕС" зазначено населений пункт, який не належить до Херсонської або до Миколаївської областей"
    */
    PROCEDURE Check20 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        WITH
            Check_app
            AS
                (SELECT COUNT (1)     AS cnt_fm
                   FROM ap_person app
                  WHERE     App_Ap = g_Ap_Id
                        AND App.App_Tp = 'FM'
                        AND App.History_Status = 'A'),
            Check_katottg
            AS
                (SELECT COUNT (1)     AS cnt_not
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 10221
                               AND Apd.History_Status = 'A'
                        JOIN Ap_Document_Attr Apda
                            ON     Apda.Apda_Apd = Apd.Apd_Id
                               AND Apda.History_Status = 'A'
                               AND Apda.Apda_Nda = 3477
                        LEFT JOIN uss_ndi.v_ndi_katottg k
                            ON k.kaot_id = apda.apda_val_id
                        LEFT JOIN uss_ndi.v_ndi_katottg kh
                            ON kh.kaot_id = k.kaot_kaot_l1
                  WHERE     App.App_Ap = g_Ap_Id
                        AND App.History_Status = 'A'
                        AND NVL (kh.kaot_code, '-') NOT IN
                                ('UA65000000000030969', 'UA48000000000039575')),
            Check_adr
            AS
                (SELECT api$validation.Get_Val_id (Apd.Apd_Id, 3480)
                            AS street_id,
                        api$validation.Get_Val_String (Apd.Apd_Id, 3481)
                            AS street_str,
                        api$validation.Get_Val_String (Apd.Apd_Id, 3483)
                            AS bild_str
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 10221
                               AND Apd.History_Status = 'A'
                  WHERE App.App_Ap = g_Ap_Id AND App.History_Status = 'A'),
            Check_Doc
            AS
                (SELECT CASE
                            WHEN cnt_fm > 0
                            THEN
                                   'Під час реєстрації звернень не можна застосовувати учасника звернення з типом "Член сім''ї", '
                                || 'в зверненні можуть фігурувати "Представник заявника" і "Заявник" якщо заявник недієздатний або "Заявник" та/або "Утриманці", '
                                || 'якщо звернення надійшло від одного з батьків'
                            ELSE
                                ''
                        END    AS Err_Doc
                   FROM Check_app
                 UNION ALL
                 SELECT CASE
                            WHEN cnt_not > 0
                            THEN
                                   'В "Заяві про надання грошової допомоги постраждалому населенню внаслідок підриву рф Каховської ГЕС" зазначено населений пункт, '
                                || 'який не належить до Херсонської або до Миколаївської областей'
                            ELSE
                                ''
                        END    AS Err_Doc
                   FROM Check_katottg
                 UNION ALL
                 SELECT CASE
                            WHEN street_id IS NULL AND street_str IS NULL
                            THEN
                                'У заяві "Заяві про надання грошової допомоги постраждалому населенню внаслідок підриву рф Каховської ГЕС" не заповнено жодне з полів щодо вулиці'
                            WHEN bild_str IS NULL
                            THEN
                                'У заяві "Заяві про надання грошової допомоги постраждалому населенню внаслідок підриву рф Каховської ГЕС" не заповнено поле щодо будинку'
                            ELSE
                                ''
                        END    AS Err_Doc
                   FROM Check_adr)
        SELECT LISTAGG (Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    --Додати контроль щодо обов'язковості заповнення одного двох атрибутів nda_ndt = 10221 3481 або 3482 щодо вулиці згідно документу nda_ndt = 10221,
    --Якщо не заповнено хоча б один з них, то помилка. Текст помилки:
    --"У заяві "Заяві про надання грошової допомоги постраждалому населенню внаслідок підриву рф Каховської ГЕС" не заповнено жодне з полів щодо вулиці"

    --Додати контроль щодо щодо обов'язковості заповнення атрибуту nda_ndt = 3483, Якщо не заповнено, то помилка. Текст помилки:
    --"У заяві "Заяві про надання грошової допомоги постраждалому населенню внаслідок підриву рф Каховської ГЕС" не заповнено жодне з поле щодо будинку"

    END;

    --==============================================================--
    --#103390
    PROCEDURE Check21 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        --Контроль для послуги з Ід=21:
        --Якщо для учасника звернення
        --з типом «Заявник» в анкеті в атрибуті з Ід=8436 (Тимчасово влаштована дитина) зазначено "Так" і вік заявника не в межах від 14 до 18 років, то це помилка.
        --Текст помилки "Самостійно звертатися за допомогою "Дитина не одна" можуть діти віком від 14 до 18 років, вік особи з <ПІБ> не в межах від 14 до 18 років"
        WITH
            Check_ank
            AS
                (SELECT App.App_Sc,
                        api$validation.Get_Val_String (Apd.Apd_Id, 8436)
                            AS x_TAB,
                        Api$appeal.Get_Person_Attr_Val_Dt (app_id, 'BDT')
                            AS x_BDT
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 605
                               AND Apd.History_Status = 'A'
                  WHERE App.App_Ap = g_Ap_Id AND App.History_Status = 'A'),
            Check_Doc
            AS
                (SELECT CASE
                            WHEN     x_TAB = 'T'
                                 AND g_Ap_Reg_Dt NOT BETWEEN ADD_MONTHS (
                                                                 x_BDT,
                                                                 12 * 14)
                                                         AND ADD_MONTHS (
                                                                 x_BDT,
                                                                 12 * 18)
                            THEN
                                   'Самостійно звертатися за допомогою "Дитина не одна" можуть діти віком від 14 до 18 років, '
                                || 'вік особи з '
                                || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                                || ' не в межах від 14 до 18 років'
                            ELSE
                                ''
                        END    AS Err_Doc
                   FROM Check_ank
                 UNION ALL
                 SELECT --Check_Documents_Filled( p_apd_id => apd_id) AS Err_Doc
                        Api$validation.Check_Documents_Filled (apd.Apd_Id)    AS Err_Doc
                   FROM Ap_Person  App
                        JOIN Ap_Document apd
                            ON     app.app_id = apd.apd_app
                               AND apd.History_Status = 'A'
                  WHERE     App.History_Status = 'A'
                        AND App.App_Ap = g_Ap_Id
                        AND apd.apd_ndt IN (200))
        SELECT LISTAGG (Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    END;

    --==============================================================--
    --#
    PROCEDURE Check22 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        --Звернення-кролик 20000000000240000048917

        --  Документ з Ід=10351 "Документ, що підтверджує потребу в забезпеченні засобами реабілітації,
        --  які видано МСЕК, ВЛК чи ЛКК" з датою видачі в атрибутіз Ід=8674 може кріпитися до звернення тільки для осіб з типом "Заявник".

        --1. Якщо в атрибуті з Ід=8675 "Тип документу (довідка чи індивідуальна програма)" зазначено "Індивідуальна програма реабілітації" або "Довідка",
        --   то в атрибуті з Ід=8674 "Дата видачі" документу з Ід=10351 може бути дата до 14.12.2023 включно, якщо дата після 14.12.2023,
        --   то видавати повідомлення з типом помилка
        --   "Документи "Індивідуальна програма реабілітації" або "Довідка" для підтвердження медичних показань щодо ДЗР видавались до 14.12.2023. Перевірте правильність внесення атрибутів щодо типа документу або дати видачі документу"

        --2. Якщо в атрибуті з Ід=8675 "Тип документу (довідка чи індивідуальна програма)" зазначено "Висновок",
        --   то в атрибуті з Ід=8674 "Дата видачі" документу з Ід=10351 може бути дата в межах періоду з 15.12.2023 по дату подання заяви включно,
        --   якщо дата до 14.12.2023, то видавати повідомлення з типом помилка
        --   "Документ "Висновок" для підтвердження медичних показань щодо ДЗР видавались після 15.12.2023. Перевірте правильність внесення атрибутів щодо типа документу або дати видачі документу"

        /*
          Якщо в зверненні наявний документ з Ід=10339 "Висновок про забезпечення ДЗР" (на етапі реєстрації звернення атрибути будуть пусті),
          то перевіряти чи ДЗРи, які зазначені в атрибуті з Ід=8642 документа з Ід=10344 "Заява про забезпечення засобом реабілітації (ДЗР)"
          визначені в даних від МОЗ - таблиця SC_DZR_RECOMM.
          Відповідно на етапі переведення звернення в статус "Зареєстровано",
          необхідно перевірити чи в таблиці SC_DZR_RECOMM по особі (в полі scdr_sc зазначається SocialCard особи, якій рекомендовано ДЗР) наявні ДЗР,
          які зазначені в атрибуті з Ід=8642 документа з Ід=10344.
        */

        /*  #115872
        1. Якщо в документі з ІД=10344 в атрибуті з Ід=8731 "пусто" або "ні",
           то обов'язково має бути додано документ з Ід=10404 "Витяг з реєстру територіальної громади". інакше це помилка.
        Текст помилки: "В документі "Заява про забезпечення засобом реабілітації (ДЗР)" не зазначено, що адреса реєстрації збігається з адресом проживання. Якщо адреса реєстрації НЕ збігається з адресом проживання, то необхідно до звернення долучити сканкопію документа "Витяг з реєстру територіальної громади""

        2. Якщо в документі з Ід=605 в атрибуті з ІД=9010 зазначено "Так", то обов'язково має бути додано документ з Ід=10404 "Витяг з реєстру територіальної громади". інакше це помилка.
        Текст помилки: "В анкеті учасника звернення в атрибуті "Адреса реєстрації відрізняється від адреси проживання" зазначено "ТАК", а документ "Витяг з реєстру територіальної громади" не додано.
        */

        /* -- #116784
        1. Якщо щодо Заявника в атрибуті з Ід=8786 "Внутрішньо переміщена особа (Перебування на обліку)" анкети документ з Ід=605 зазначено "так",
           то в атрибуті Ід=9016 "Адреса за даними довідки ВПО" в документі з Ід=10344 "Заява про забезпечення засобом реабілітації (ДЗР)" * теж*
           має бути зазначено зазначено "так", інакше помилка.
        текст помилки:
        "Якщо в анкеті учасника звернення щодо <ПІБ> атрибуті "Внутрішньо переміщена особа (Перебування на обліку)" зазначено "так", та в атрибуті І "Адреса за даними довідки ВПО" в документі з "Заява про забезпечення засобом реабілітації (ДЗР)" теж необхідно зазначити "так""

        2. Перевіряти чи стосовно особи Заявника в СРКО наявна актуальна довідка ВПО, якщо наявна,
           то перевіряти чи встановлено "так" в в атрибуті з Ід=8786 "Внутрішньо переміщена особа (Перебування на обліку)"
           та в атрибуті Ід=9016 "Адреса за даними довідки ВПО" в документі з Ід=10344 "Заява про забезпечення засобом реабілітації (ДЗР)",
           якщо не встановлено "так", то це помилка
        текст помилки:
          'За даними з ЄІБД ВПО, які завантажено в ЄІССС, щодо особи '||||' наявна актуальна довідка ВПО, '||
          'приведіть у відповідність інформацію в анкеті учасника звернення та в "Заяві про забезпечення засобом реабілітації (ДЗР)'

        3. Якщо в СРКО щодо особи Завяника наявна актуальна довідка ВПО (документ з Ід=10052),
          значення в атрибут з Ід=8634 "Населений пункт (місце проживання)" документу Ід=10344 та атрибуті з Ід=4492 "КАТОТТГ" документу Ід=10052 мають бути одинакові, інакше це помилка:

        текст помилки:
          'За даними з ЄІБД ВПО, які завантажено в ЄІССС, щодо особи '||||' наявна актуальна довідка ВПО, '||
          'приведіть у відповідність адресу особи заявника за даними довідки ВПО, вказавши "так" в атрибуті '||
          '"Адреса за даними довідки ВПО" в документі "Заява про забезпечення засобом реабілітації (ДЗР)'

              l_scd_id  := uss_person.api$sc_tools.get_sc_doc(l_sc_id, 10052);
              x_Val_Str => uss_person.api$sc_tools.get_sc_doc_val_str(p_scd_id => l_scd_id, p_nda_Id => 4492);

        */

        WITH
            Check_ank
            AS
                (SELECT App.App_Sc,
                        App.App_id,
                        api$validation.Get_Val_String (Apd.Apd_Id, 8436)
                            AS x_TAB,
                        Api$appeal.Get_Person_Attr_Val_Dt (app_id, 'BDT')
                            AS x_BDT,
                        api$validation.Get_Val_String (Apd.Apd_Id, 9010, 'F')
                            AS x_val_9010,
                        api$validation.Get_Val_String (Apd.Apd_Id, 8786, 'F')
                            AS x_val_8786
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 605
                               AND Apd.History_Status = 'A'
                  WHERE App.App_Ap = g_Ap_Id AND App.History_Status = 'A'),
            Check_10344
            AS
                (SELECT App.App_Sc,
                        App.App_id,
                        api$validation.Get_Val_String (Apd.Apd_Id, 8731, 'F')
                            AS x_val_8731,
                        api$validation.Get_Val_String (Apd.Apd_Id, 9016, 'F')
                            AS x_val_9016,
                        api$validation.Get_Val_id (Apd.Apd_Id, 8634)
                            AS x_id_8634
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 10344
                               AND Apd.History_Status = 'A'
                  WHERE App.App_Ap = g_Ap_Id AND App.History_Status = 'A'),
            Check_10351
            AS
                (SELECT App.App_Sc,
                        api$validation.Get_Val_String (Apd.Apd_Id, 8675)
                            AS x_tp,
                        api$validation.Get_Val_Dt (Apd.Apd_Id, 8674)
                            AS x_doc_dt
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 10351
                               AND Apd.History_Status = 'A'
                  WHERE App.App_Ap = g_Ap_Id AND App.History_Status = 'A'),
            attr_8642
            AS
                (SELECT app.app_id,
                        app.app_sc,
                        REPLACE (apda1.apda_val_string, ';', ',')
                            AS val_8642,
                        api$appeal.Get_Person_Attr_Val_Str (app_id, 8676)
                            AS val_8676
                   FROM ap_person  app
                        JOIN ap_document apd
                            ON apd_app = app_id AND apd.history_status = 'A'
                        JOIN ap_document_attr apda1
                            ON     apda1.apda_apd = apd_id
                               AND apda1.apda_nda = 8642
                               AND apda1.history_status = 'A'
                  WHERE app_ap = g_Ap_Id AND app.history_status = 'A'),
            /*
                   attr_8642_sc AS
                   (SELECT app.app_id, replace(apda1.apda_val_string,';',',') AS val_8642,  app.app_sc
                     FROM ap_person app
                       JOIN ap_document apd ON apd_app = app_id AND apd.history_status = 'A'
                       JOIN ap_document_attr apda1 ON apda1.apda_apd = apd_id AND apda1.apda_nda = 8642 AND apda1.history_status = 'A'
                     WHERE app_ap = g_Ap_Id
                       AND app.history_status = 'A'
                       AND EXISTS ( SELECT 1
                                    FROM ap_document d_sl
                                    WHERE d_sl.apd_app = app_id
                                      AND d_sl.history_status = 'A'
                                      AND d_sl.apd_ndt = 10339
                                  )
                    ),*/
            /*
                   attr_8735_sc AS
                   (SELECT app.app_id, replace(apda1.apda_val_string,';',',') AS val_8735,  app.app_sc
                     FROM ap_person app
                       JOIN ap_document apd ON apd_app = app_id AND apd.history_status = 'A'
                       JOIN ap_document_attr apda1 ON apda1.apda_apd = apd_id AND apda1.apda_nda = 8735 AND apda1.history_status = 'A'
                     WHERE app_ap = g_Ap_Id
                       AND app.history_status = 'A'
                       AND EXISTS ( SELECT 1
                                    FROM ap_document d_sl
                                    WHERE d_sl.apd_app = app_id
                                      AND d_sl.history_status = 'A'
                                      AND d_sl.apd_ndt = 10339
                                  )
                    ),
            */
            attr_8735
            AS
                (SELECT app.app_id,
                        app.app_sc,
                        REPLACE (apda1.apda_val_string, ';', ',')    AS val_8735
                   FROM ap_person  app
                        JOIN ap_document apd
                            ON apd_app = app_id AND apd.history_status = 'A'
                        JOIN ap_document_attr apda1
                            ON     apda1.apda_apd = apd_id
                               AND apda1.apda_nda = 8735
                               AND apda1.history_status = 'A'
                  WHERE app_ap = g_Ap_Id AND app.history_status = 'A'),
            attr_8735_cnt
            AS
                (SELECT app_sc,
                        x_scdr,
                        x_wrn,
                        x_WANT_DZR,
                        uss_esr.api$find.Get_wrn_count (app_sc, x_wrn)    AS x_USED_DZR
                   FROM (  SELECT attr_8735.app_sc,
                                  ids.COLUMN_VALUE     AS x_scdr,
                                  scdr_wrn             AS x_wrn,
                                  COUNT (1)            AS x_WANT_DZR
                             FROM attr_8735,
                                  TABLE (
                                      TOOLS.split_str (attr_8735.val_8735, ','))
                                  ids,
                                  uss_person.v_sc_dzr_recomm dzr
                            WHERE dzr.scdr_id = ids.COLUMN_VALUE
                         GROUP BY attr_8735.app_sc,
                                  ids.COLUMN_VALUE,
                                  scdr_wrn)),
            attr_8642_cnt
            AS
                (SELECT app_sc,
                        x_wrn,
                        x_WANT_DZR,
                        uss_esr.api$find.Get_wrn_count (app_sc, x_wrn)    AS x_USED_DZR
                   FROM (  SELECT attr_8642.app_sc,
                                  ids.COLUMN_VALUE     /*AS x_scdr, scdr_wrn*/
                                                       AS x_wrn,
                                  COUNT (1)            AS x_WANT_DZR
                             FROM attr_8642,
                                  TABLE (
                                      TOOLS.split_str (attr_8642.val_8642, ','))
                                  ids
                         GROUP BY attr_8642.app_sc, ids.COLUMN_VALUE)),
            Check_Doc
            AS
                (SELECT    '"Документ, що підтверджує потребу в забезпеченні засобами реабілітації, '
                        || 'які видано МСЕК, ВЛК чи ЛКК" може кріпитися до звернення тільки для осіб з типом "Заявник"'    AS Err_Doc
                   FROM Ap_Person  App
                        JOIN Ap_Document apd
                            ON     app.app_id = apd.apd_app
                               AND apd.History_Status = 'A'
                        JOIN uss_ndi.v_ndi_document_type t
                            ON t.ndt_id = apd.apd_ndt
                  WHERE     App.History_Status = 'A'
                        AND App.App_Ap = g_Ap_Id
                        AND app.app_tp != 'Z'
                        AND apd.apd_ndt = 10351
                 UNION ALL                                           --#114154
                 SELECT CASE
                            WHEN api$validation.Get_Doc_Count (App.App_Id,
                                                               10344) >
                                 1
                            THEN
                                'Заборонено додавати кілька документів "Заява про забезпечення засобом реабілітації (ДЗР)" до звернення'
                            ELSE
                                ''
                        END    AS Err_Doc
                   FROM Ap_Person App
                  WHERE App.History_Status = 'A' AND App.App_Ap = g_Ap_Id
                 UNION ALL                                           --#114068
                 SELECT CASE
                            WHEN     api$validation.Get_Val_String (
                                         Apd.Apd_Id,
                                         8733) =
                                     'T'
                                 AND api$validation.Get_Val_String (
                                         Apd.Apd_Id,
                                         8734) =
                                     'T'
                            THEN
                                   'Заборонено одночасно встановлювати "так" в атрибутах анкети "Електронний висновок про забезпечення ДЗР (видається з 01.01.2025)" '
                                || 'та "Паперовий документ про потребу забезпечення ДЗР"'
                            ELSE
                                ''
                        END    AS Err_Doc
                   FROM Ap_Person  App
                        JOIN Ap_Document apd
                            ON     app.app_id = apd.apd_app
                               AND apd.History_Status = 'A'
                  WHERE     App.History_Status = 'A'
                        AND App.App_Ap = g_Ap_Id
                        AND apd.apd_ndt = 605
                 UNION ALL                                           --#114068
                 SELECT CASE
                            WHEN     api$validation.Get_Val_String (
                                         Apd.Apd_Id,
                                         8735)
                                         IS NULL
                                 AND api$validation.Get_Val_String (
                                         Apd.Apd_Id,
                                         8642)
                                         IS NULL
                            THEN
                                'В "Заяві про забезпечення засобом реабілітації (ДЗР)" не заповнено перелік ДЗР, за якими звернулася особа'
                            ELSE
                                api$validation.Check_Documents_Filled (
                                    app_id,
                                    apd_ndt,
                                    '8634,8635,8636,8725,8726,8727,8728,8682',
                                    0)
                        END    AS Err_Doc
                   FROM Ap_Person  App
                        JOIN Ap_Document apd
                            ON     app.app_id = apd.apd_app
                               AND apd.History_Status = 'A'
                  WHERE     App.History_Status = 'A'
                        AND App.App_Ap = g_Ap_Id
                        AND apd.apd_ndt = 10344
                 UNION ALL                                           --#114068
                 SELECT CASE
                            WHEN     api$validation.Get_Doc_Count (app_id,
                                                                   10339) >
                                     0
                                 AND api$validation.Get_Doc_Count (app_id,
                                                                   10351) >
                                     0
                            THEN
                                   'В зверненні одночасно не можуть знаходитись документи "Висновок про забезпечення ДЗР" та '
                                || '"Документ, що підтверджує потребу в забезпеченні засобами реабілітації, які видано МСЕК, ВЛК чи ЛКК"'
                            WHEN     api$validation.Get_Doc_Count (app_id,
                                                                   10339) =
                                     0
                                 AND api$validation.Get_Doc_Count (app_id,
                                                                   10351) =
                                     0
                            THEN
                                'Не додано у звернення жодного документу, що підтверджує потребу особи щодо забезпечення ДЗР.'
                            ELSE
                                ''
                        END    AS Err_Doc
                   FROM Ap_Person App
                  WHERE     App.History_Status = 'A'
                        AND App.App_Tp = 'Z'
                        AND App.App_Ap = g_Ap_Id
                 UNION ALL                                           --#114068
                 SELECT CASE
                            WHEN api$validation.Get_Doc_String (app_id,
                                                                10344,
                                                                8735)
                                     IS NULL
                            THEN
                                   'В звернення додано документ "Висновок про забезпечення ДЗР", '
                                || 'а в документі "Заява про забезпечення засобом реабілітації (ДЗР)" не заповнено атрибут "Перелік ДЗР з електронного висновку"'
                            ELSE
                                ''
                        END    AS Err_Doc
                   FROM Ap_Person  App
                        JOIN Ap_Document apd
                            ON     app.app_id = apd.apd_app
                               AND apd.History_Status = 'A'
                  WHERE     App.History_Status = 'A'
                        AND apd.apd_ndt = 10339
                        AND App.App_Ap = g_Ap_Id
                 UNION ALL                                           --#114068
                 SELECT CASE
                            WHEN api$validation.Get_Doc_String (app_id,
                                                                10344,
                                                                8642)
                                     IS NULL
                            THEN
                                   'В звернення додано документ "Документ, що підтверджує потребу в забезпеченні засобами реабілітації, які видано МСЕК, ВЛК чи ЛКК ", '
                                || 'а в документі "Заява про забезпечення засобом реабілітації (ДЗР)" не заповнено атрибут "Перелік ДЗР"'
                            ELSE
                                ''
                        END    AS Err_Doc
                   FROM Ap_Person  App
                        JOIN Ap_Document apd
                            ON     app.app_id = apd.apd_app
                               AND apd.History_Status = 'A'
                  WHERE     App.History_Status = 'A'
                        AND apd.apd_ndt = 10351
                        AND App.App_Ap = g_Ap_Id
                 UNION ALL
                 SELECT    'В "Заяві про забезпечення засобом реабілітації (ДЗР)" зазначені ДЗРи '
                        || list_err
                        || ', '
                        || 'які відсутні в переліку документа "Документ, що підтверджує потребу в забезпеченні засобами реабілітації, які видано МСЕК, ВЛК чи ЛКК'
                   FROM (SELECT LISTAGG (w.wrn_name, ', ')     AS list_err
                           FROM attr_8642,
                                TABLE (
                                    TOOLS.split_str (attr_8642.val_8642, ','))
                                ids,
                                uss_ndi.v_NDI_CBI_WARES  w
                          WHERE     NOT EXISTS
                                        (SELECT 1
                                           FROM TABLE (
                                                    TOOLS.split_str (
                                                        attr_8642.val_8676,
                                                        ',')) ids_sl
                                          WHERE ids_sl.COLUMN_VALUE =
                                                ids.COLUMN_VALUE)
                                AND w.wrn_id = ids.COLUMN_VALUE)
                  WHERE list_err IS NOT NULL
                 /*      UNION ALL
                       SELECT 'Згідно даних, які надійшли від МОЗ особі '||Uss_Person.Api$sc_Tools.Get_Pib(App_Sc)||' не рекомендовано ДЗР ' || list_err
                       FROM (  SELECT listagg(w.wrn_name, ', ') AS list_err,
                                      App_Sc
                               FROM attr_8735_sc,
                                    TABLE(TOOLS.split_str(attr_8735_sc.val_8735, ',')) ids,
                                    uss_ndi.v_NDI_CBI_WARES w
                               WHERE NOT EXISTS ( SELECT 1
                                                  FROM uss_person.V_SC_DZR_RECOMM v
                                                  WHERE v.scdr_wrn = ids.column_value
                                                    AND v.scdr_sc = attr_8735_sc.app_sc
                                                )
                                 AND w.wrn_id = ids.column_value
                               GROUP BY App_Sc
                            )
                       WHERE list_err IS NOT NULL*/
                 UNION ALL
                 /*  #115872
                 1. Якщо в документі з ІД=10344 в атрибуті з Ід=8731 "пусто" або "ні", то обов'язково має бути додано документ з
                 або Ід= 10404 "Витяг з реєстру територіальної громади",
                 або Ід= 10405 Свідоцтво про право власності
                 або Ід= 10407 Договір оренди (найму, піднайму)
                 або Ід= 805 Посвідчення про взяття на облік бездомної особи
                 або Ід= 10408 Договір найму житла у гуртожитку (для студентів)
                 або Ід= 10406 Ордер
                 або Ід= 10409 Рішення суду, яке набрало законної сили, про надання особі права на вселення до житлового приміщення, визнання за особою права користування житловим приміщенням або права власності на нього, права на реєстрацію місця проживання
                 або Ід= 10410 Довідка про прийняття на обслуговування в спеціалізованій соціальній установі, іншого надавача соціальних послуг з проживанням
                 або Ід= 10411 Згода членів сім’ї на реєстрацію місця проживання. інакше це помилка.
                 Текст помилки:
                 "В документі "Заява про забезпечення засобом реабілітації (ДЗР)" не зазначено, що адреса реєстрації збігається з адресом проживання.
                 Якщо адреса реєстрації НЕ збігається з адресом проживання, то необхідно до звернення долучити сканкопію документа одного із документів:
                 Витяг з реєстру територіальної громади, Свідоцтво про право власності, Договір оренди (найму, піднайму),
                 Посвідчення про взяття на облік бездомної особи, Договір найму житла у гуртожитку (для студентів), Ордер, Рішення суду, яке набрало законної сили,
                 Довідка про прийняття на обслуговування в спеціалізованій соціальній установі, іншого надавача соціальних послуг з проживанням,
                 Згода членів сім’ї на реєстрацію місця проживання"

                 2. Якщо в документі з Ід=605 в атрибуті з ІД=9010 зазначено "Так", то обов'язково має бути додано документ з Ід=10404 "Витяг з реєстру територіальної громади". інакше це помилка.
                 Текст помилки: "В анкеті учасника звернення в атрибуті "Адреса реєстрації відрізняється від адреси проживання" зазначено "ТАК", а документ "Витяг з реєстру територіальної громади" не додано.
                 */
                 SELECT CASE
                            WHEN     x_val_8731 = 'F'
                                 AND uss_person.api$sc_tools.get_sc_doc (
                                         app_sc,
                                         10052)
                                         IS NULL
                            THEN
                                   'В документі "Заява про забезпечення засобом реабілітації (ДЗР)" не зазначено, що адреса реєстрації збігається з адресом проживання. '
                                || 'Якщо адреса реєстрації НЕ збігається з адресом проживання, то необхідно до звернення долучити сканкопію документа одного із документів: '
                                || 'Витяг з реєстру територіальної громади, Свідоцтво про право власності, Договір оренди (найму, піднайму), '
                                || 'Посвідчення про взяття на облік бездомної особи, Договір найму житла у гуртожитку (для студентів), Ордер, Рішення суду, яке набрало законної сили, '
                                || 'Довідка про прийняття на обслуговування в спеціалізованій соціальній установі, іншого надавача соціальних послуг з проживанням, '
                                || 'Згода членів сім’ї на реєстрацію місця проживання'
                        END    AS Err_Doc
                   FROM Check_10344
                  WHERE NOT EXISTS
                            (SELECT 1
                               FROM Ap_Document Apd
                              WHERE     apd.apd_App = App_Id
                                    AND Apd.History_Status = 'A'
                                    AND Apd.Apd_Ndt IN (10404,
                                                        10405,
                                                        10407,
                                                        805,
                                                        10408,
                                                        10406,
                                                        10409,
                                                        10410,
                                                        10411))
                 UNION ALL
                 SELECT CASE
                            WHEN     x_val_9010 = 'T'
                                 AND uss_person.api$sc_tools.get_sc_doc (
                                         app_sc,
                                         10052)
                                         IS NULL
                            THEN
                                   'В анкеті учасника звернення в атрибуті "Адреса реєстрації відрізняється від адреси проживання" зазначено "ТАК", '
                                || 'але до звернення не долучено одного із документів: "Витяг з реєстру територіальної громади", Свідоцтво про право власності, '
                                || 'Договір оренди (найму, піднайму), Посвідчення про взяття на облік бездомної особи, Договір найму житла у гуртожитку (для студентів), '
                                || 'Ордер, Рішення суду, яке набрало законної сили, '
                                || 'Довідка про прийняття на обслуговування в спеціалізованій соціальній установі, іншого надавача соціальних послуг з проживанням, '
                                || 'Згода членів сім’ї на реєстрацію місця проживання'
                        END    AS Err_Doc
                   FROM Check_ank
                  WHERE NOT EXISTS
                            (SELECT 1
                               FROM Ap_Document Apd
                              WHERE     apd.apd_App = App_Id
                                    AND Apd.History_Status = 'A'
                                    AND Apd.Apd_Ndt IN (10404,
                                                        10405,
                                                        10407,
                                                        805,
                                                        10408,
                                                        10406,
                                                        10409,
                                                        10410,
                                                        10411))
                 /*
                         UNION ALL
                         --#114399
                         SELECT 'Сканкопія документа "Заява про забезпечення засобом реабілітації (ДЗР)" не підписана ЕЦП. '||
                                'Скористайтесь функцією "Сканування з ЕЦП"'  AS Err_Doc
                               --d.apd_id, d.Apd_Ndt, a.Dat_Sign_File
                         FROM Ap_Document d
                           --JOIN Uss_Doc.v_Doc_Attachments a   ON d.Apd_Dh = a.Dat_Dh
                         WHERE d.Apd_Ap  = g_Ap_Id
                           AND d.History_Status = 'A'
                           AND d.Apd_Ndt = 10344
                           AND NOT EXISTS ( SELECT 1
                                            FROM Uss_Doc.v_Doc_Attachments a
                                            WHERE d.Apd_Dh = a.Dat_Dh
                                              AND a.Dat_Sign_File IS NOT NULL
                                          )
                 */
                 UNION ALL                                          -- #116784
                 SELECT CASE
                            WHEN     ank.x_val_8786 = 'T'
                                 AND doc.x_val_9016 != 'T'
                            THEN
                                   'Якщо в анкеті учасника звернення щодо '
                                || Uss_Person.Api$sc_Tools.Get_Pib (
                                       ank.App_Sc)
                                || ' в атрибуті "Внутрішньо переміщена особа (Перебування на обліку)" зазначено "так", '
                                || 'та в атрибуті "Адреса за даними довідки ВПО" в документі "Заява про забезпечення засобом реабілітації (ДЗР)" теж необхідно зазначити "так"'
                        END    AS Err_Doc
                   FROM Check_ank  ank
                        JOIN Check_10344 doc ON doc.App_id = ank.App_id
                 UNION ALL                                          -- #116784
                 SELECT CASE
                            WHEN     uss_person.api$sc_tools.get_sc_doc_val_str (
                                         x_scd_id,
                                         8786) =
                                     'T'
                                 AND doc.x_val_9016 != 'T'
                            THEN
                                   'За даними з ЄІБД ВПО, які завантажено в ЄІССС, щодо особи '
                                || Uss_Person.Api$sc_Tools.Get_Pib (
                                       doc.App_Sc)
                                || ' наявна актуальна довідка ВПО, '
                                || 'приведіть у відповідність інформацію в анкеті учасника звернення та в "Заяві про забезпечення засобом реабілітації (ДЗР)'
                        END    AS Err_Doc
                   FROM (SELECT App_id,
                                App_Sc,
                                x_val_9016,
                                uss_person.api$sc_tools.get_sc_doc (app_sc,
                                                                    10052)    AS x_scd_id
                           FROM Check_10344) doc
                  WHERE x_scd_id IS NOT NULL
                 UNION ALL                                          -- #116784
                 SELECT CASE
                            WHEN x_id_8634 !=
                                 uss_person.api$sc_tools.get_sc_doc_val_id (
                                     x_scd_id,
                                     4492)
                            THEN
                                   'За даними з ЄІБД ВПО, які завантажено в ЄІССС, щодо особи '
                                || Uss_Person.Api$sc_Tools.Get_Pib (
                                       doc.App_Sc)
                                || ' наявна актуальна довідка ВПО, '
                                || 'приведіть у відповідність адресу особи заявника за даними довідки ВПО, вказавши "так" в атрибуті '
                                || '"Адреса за даними довідки ВПО" в документі "Заява про забезпечення засобом реабілітації (ДЗР)'
                        END    AS Err_Doc
                   FROM (SELECT App_Sc,
                                x_id_8634,
                                uss_person.api$sc_tools.get_sc_doc (app_sc,
                                                                    10052)    AS x_scd_id
                           FROM Check_10344) doc
                  WHERE x_scd_id IS NOT NULL
                 UNION ALL                                           --#116840
                 SELECT                         --v.app_sc, v.x_scdr, v.x_wrn,
                --v.x_WANT_DZR, v.x_USED_DZR, w.wrn_issue_max, w.wrn_mult_qnt,
                      CASE
                          WHEN     (wrn_issue_max - x_USED_DZR) < x_WANT_DZR
                               AND NVL (wrn_issue_max, 0) > 0
                          THEN
                                 'Перевищено максимально дозволену кількість ДЗР '
                              || wrn_shifr
                              || ' "'
                              || wrn_name
                              || '"'
                          WHEN     MOD (x_WANT_DZR, w.wrn_mult_qnt) > 0
                               AND NVL (wrn_mult_qnt, 0) > 0
                          THEN
                                 'Для ДЗР '
                              || wrn_shifr
                              || ' "'
                              || wrn_name
                              || '" дозволено обирати кількість, яка кратна '
                              || wrn_mult_qnt
                      END    AS err_str
                 FROM attr_8735_cnt  v
                      JOIN uss_ndi.v_NDI_CBI_WARES w ON w.wrn_id = v.x_wrn
                 UNION ALL                                           --#117401
                 SELECT                         --v.app_sc, v.x_scdr, v.x_wrn,
                --v.x_WANT_DZR, v.x_USED_DZR, w.wrn_issue_max, w.wrn_mult_qnt,
                      CASE
                          WHEN     (wrn_issue_max - x_USED_DZR) < x_WANT_DZR
                               AND NVL (wrn_issue_max, 0) > 0
                          THEN
                                 'Перевищено максимально дозволену кількість ДЗР '
                              || wrn_shifr
                              || ' "'
                              || wrn_name
                              || '"'
                          WHEN     MOD (x_WANT_DZR, w.wrn_mult_qnt) > 0
                               AND NVL (wrn_mult_qnt, 0) > 0
                          THEN
                                 'Для ДЗР '
                              || wrn_shifr
                              || ' "'
                              || wrn_name
                              || '" дозволено обирати кількість, яка кратна '
                              || wrn_mult_qnt
                      END    AS err_str
                 FROM attr_8642_cnt  v
                      JOIN uss_ndi.v_NDI_CBI_WARES w ON w.wrn_id = v.x_wrn)
        SELECT LISTAGG (Err_Doc, CHR (13) || CHR (10))
                   WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;

        --  Якщо в зверненні по послузі з Ід=22 з джерелом "ЄІССС" в блоці "Документи"
        --наявний будь-який документ крім документу з Ід=10339 "Висновок про забезпечення ДЗР",
        --то обов'язково має бути прикріплена скан-копія документа, інакше видавати текст помилки:
        --"Для документа <назва документа> не додано скан-копію".


        FOR rec
            IN (SELECT    'Для документа "'
                       || t.ndt_name_short
                       || '" не додано скан-копію'    AS Err_Doc,
                       apd.apd_id
                  FROM Ap_Person  App
                       JOIN Ap_Document apd
                           ON     app.app_id = apd.apd_app
                              AND apd.History_Status = 'A'
                       JOIN uss_ndi.v_ndi_document_type t
                           ON t.ndt_id = apd.apd_ndt
                 WHERE     App.History_Status = 'A'
                       AND App.App_Ap = g_Ap_Id
                       AND g_Ap_Src = 'USS'
                       AND apd.apd_ndt NOT IN (605, 10052, 10339))
        LOOP
            IF Get_Apd_Doc_Scan (rec.apd_id) = 0
            THEN
                IF Err_List IS NULL
                THEN
                    Err_List := rec.Err_Doc;
                ELSE
                    Err_List :=
                        Err_List || CHR (13) || CHR (10) || rec.Err_Doc;
                END IF;
            END IF;
        END LOOP;
    END;


    --==============================================================--
    /*
    для допомоги з ІД=267 та з ІД=249 для учасника звернення, який є членом сім'ї, ступінь родинного зв'язку = "Дружина/Чоловік" серед документів має бути поданий обов'язковий документ "Паспорт громадянина України", альтернативний документ - ID-картка
    */
    PROCEDURE Check248 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        WITH
            Anketa_Prev
            AS
                (SELECT App.App_Id,
                        App.App_Sc,
                        App.App_Tp,
                        Apda.Apda_Nda,
                        Apda.Apda_Val_String
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 605
                               AND Apd.History_Status = 'A'
                        LEFT JOIN Ap_Document_Attr Apda
                            ON     Apda.Apda_Apd = Apd.Apd_Id
                               AND Apda.History_Status = 'A'
                               AND Apda.Apda_Nda IN (641,
                                                     660,
                                                     796,
                                                     795)
                  WHERE App.App_Ap = g_Ap_Id AND App.History_Status = 'A'),
            Anketa
            AS
                (SELECT App_Id,
                        App_Sc,
                        App_Tp,
                        NVL ("Alone", 'F')                Alone, --Одинокий/Одинока
                        NVL ("Disability", 'F')           Disability, --Особа з інвалідністю з дитинства
                        NVL ("DisabilityState", '-')      Disabilitystate, --Статус інвалідності
                        NVL ("DisabilityReason", '-')     Disabilityreason --причина інвалідності
                   FROM Anketa_Prev
                            PIVOT (
                                  MAX (Apda_Val_String)
                                  FOR Apda_Nda
                                  IN (641 "Alone",          --Одинокий/Одинока
                                     660 "Disability",  --Особа з інвалідністю
                                     796 "DisabilityState", --Статус інвалідності
                                     795 "DisabilityReason") --причина інвалідності
                                                            )),
            Check_Doc
            AS
                (SELECT    'Для послуги "Державна соціальна допомога інвалідам з дитинства та дітям-інвалідам" для учасника звернення '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                        || ' не прикріплено документ: '
                        || CASE
                               WHEN (   (    Disabilitystate = 'I'
                                         AND Disabilityreason = 'ID')
                                     OR Disabilitystate = 'IZ')
                               THEN
                                   Api$validation.Check_Documents_Exists (
                                       App_Id,
                                       201)
                               WHEN Disabilitystate = 'DI'
                               THEN
                                   Api$validation.Check_Documents_Exists (
                                       App_Id,
                                       200)
                           END    AS Err_Doc
                   FROM Anketa
                  WHERE     (   (    Disabilitystate = 'I'
                                 AND Disabilityreason = 'ID')
                             OR Disabilitystate = 'IZ'
                             OR Disabilitystate = 'DI')
                        AND   Api$validation.Get_Doc_Count (App_Id, 201)
                            + Api$validation.Get_Doc_Count (App_Id, 200) <
                            1
                 UNION ALL
                 SELECT    'Для послуги "Державна соціальна допомога інвалідам з дитинства та дітям-інвалідам" для учасника звернення '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App.App_Sc)
                        || ', не прикріплено документ: "Витяг з Державного реєстру актів цивільного стану про народження дитини"'
                        || ' або для учасника звернення '
                        || Uss_Person.Api$sc_Tools.Get_Pib (Anketa.App_Sc)
                        || ', не прикріплено жоден з документів: "Свідоцтво РАГС про смерть", "Рішення суду про позбавлення батьківських прав"'    AS Err_Doc
                   FROM Anketa
                        LEFT JOIN Ap_Person App
                            ON     App.App_Ap = g_Ap_Id
                               AND App.App_Tp = 'FP'
                               AND App.History_Status = 'A'
                  WHERE     Anketa.App_Tp = 'Z'
                        AND Anketa.Alone = 'T'
                        AND Anketa.Disability <> 'T'
                        AND (  Api$validation.Get_Doc_Count (App.App_Id, 663)
                             + Api$validation.Get_Doc_Count (Anketa.App_Id,
                                                             10039)
                             + Api$validation.Get_Doc_Count (Anketa.App_Id,
                                                             89)) =
                            0
                        AND NVL (
                                TRUNC (
                                      MONTHS_BETWEEN (
                                          SYSDATE,
                                          COALESCE (
                                              Api$validation.Get_Doc_Dt (
                                                  App.App_Id,
                                                  6,
                                                  606),              --Паспорт
                                              Api$validation.Get_Doc_Dt (
                                                  App.App_Id,
                                                  7,
                                                  607),            --ID картка
                                              Api$validation.Get_Doc_Dt (
                                                  App.App_Id,
                                                  37,
                                                  91)) --свідоцтво про народження дитини
                                                      )
                                    / 12,
                                    0),
                                -1) BETWEEN 0
                                        AND 18
                 UNION ALL
                 --#97450
                 SELECT    'Для '
                        || Pib (App_Ln, App_Fn, App_Mn)
                        || ' в документі "Виписка з акту огляду МСЕК" не заповнено підгрупа інвалідності'    AS Err_Doc
                   FROM Ap_Document  Apd
                        LEFT JOIN Ap_Person App
                            ON     App.App_Id = Apd.Apd_App
                               AND App.App_Ap = g_Ap_Id
                               AND App.History_Status = 'A'
                  WHERE     Apd.History_Status = 'A'
                        AND Apd.Apd_Ap = g_Ap_Id
                        AND Apd.Apd_Ndt = 201   /*Виписка з акту огляду МСЕК*/
                        AND Api$validation.Get_Val_String (
                                p_Apd   => Apd.Apd_Id,
                                p_Nda   => 349          /*Група інвалідності*/
                                              ) =
                            '1'                                                     /*1 група*/
                        AND Api$validation.Get_Val_String (
                                p_Apd   => Apd.Apd_Id,
                                p_Nda   => 791       /*Підгрупа інвалідності*/
                                              )
                                IS NULL
                 UNION ALL
                 SELECT --Check_Documents_Filled( p_apd_id => apd_id) AS Err_Doc
                        Api$validation.Check_Documents_Filled (apd.Apd_Id)    AS Err_Doc
                   FROM Ap_Person  App
                        JOIN Ap_Document apd
                            ON     app.app_id = apd.apd_app
                               AND apd.History_Status = 'A'
                  WHERE     App.History_Status = 'A'
                        AND App.App_Ap = g_Ap_Id
                        AND apd.apd_ndt IN (200, 201)
                 UNION ALL
                 SELECT CASE
                            WHEN    Api$validation.Get_Val_String (
                                        p_Apd       => Apd.Apd_Id,
                                        p_Nda       => 8427,
                                        p_Default   => 'F')
                                 || Api$validation.Get_Val_String (
                                        p_Apd       => Apd.Apd_Id,
                                        p_Nda       => 8428,
                                        p_Default   => 'F')
                                 || Api$validation.Get_Val_String (
                                        p_Apd       => Apd.Apd_Id,
                                        p_Nda       => 8429,
                                        p_Default   => 'F') NOT IN
                                     ('TFF',
                                      'FTF',
                                      'FFT',
                                      'FFF')
                            THEN
                                   'Для особи '
                                || Pib (App_Ln, App_Fn, App_Mn)
                                || ' зазначено одночасно "так" у двох і більше атрибутах в анкеті '
                                || 'в групі атрибутів "Особам з інвалідністю з дитинства, які одночасно мають право на отримання надбавки, '
                                || 'за їх вибором'
                        END    AS Err_Doc
                   FROM Ap_Person  App
                        JOIN Ap_Document apd
                            ON     app.app_id = apd.apd_app
                               AND apd.History_Status = 'A'
                  WHERE     App.History_Status = 'A'
                        AND App.App_Ap = g_Ap_Id
                        AND apd.apd_ndt IN (605))
        SELECT LISTAGG (Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    /*
    Якщо для допомоги з Ід=248 в анкеті зазначено "Одинокий/одинока"="так" і "Особа з інвалідністю"<>"Так",
    то обов'язково має бути наданий документ ndt_id=663, прикріплений до учасника звернення "утриманець" або
    альтернативний документ ndt_id=10039, прикріплений до заявника,
    або альтернативний документ ndt_id=89, прикріплений до заявника.*/

    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check249 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        WITH
            Anketa_Prev
            AS
                (SELECT App.App_Id,
                        App.App_ap,
                        App.App_Sc,
                        App.App_Tp,
                        Apda.Apda_Nda,
                        Apda.Apda_Val_String
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 605
                               AND Apd.History_Status = 'A'
                        LEFT JOIN Ap_Document_Attr Apda
                            ON     Apda.Apda_Apd = Apd.Apd_Id
                               AND Apda.History_Status = 'A'
                               AND Apda.Apda_Nda IN (641,
                                                     660,
                                                     796,
                                                     795,
                                                     871)
                  WHERE App.App_Ap = g_Ap_Id AND App.History_Status = 'A'),
            Anketa
            AS
                (SELECT App_Id,
                        App_Ap,
                        App_Sc,
                        App_Tp,
                        NVL ("Alone", 'F')                Alone, --Одинокий/Одинока
                        NVL ("Disability", 'F')           Disability, --Особа з інвалідністю з дитинства
                        NVL ("DisabilityState", '-')      Disabilitystate, --Статус інвалідності
                        NVL ("DisabilityReason", '-')     Disabilityreason, --причина інвалідності
                        NVL ("ChildOutsideUA", 'F')       ChildOutsideUA --причина інвалідності
                   FROM Anketa_Prev
                            PIVOT (
                                  MAX (Apda_Val_String)
                                  FOR Apda_Nda
                                  IN (641 "Alone",          --Одинокий/Одинока
                                     660 "Disability",  --Особа з інвалідністю
                                     796 "DisabilityState", --Статус інвалідності
                                     795 "DisabilityReason", --причина інвалідності
                                     871 "ChildOutsideUA" --Дитина народжена поза межами України
                                                         ))),
            Check_Doc
            AS
                (SELECT    'Для послуги "Державна соціальна допомога малозабезпеченим сім’ям" для учасника звернення '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                        || ' не прикріплено документ: '
                        || CASE
                               WHEN (   (    Disabilitystate = 'I'
                                         AND Disabilityreason = 'ID')
                                     OR Disabilitystate = 'IZ')
                               THEN
                                   Api$validation.Check_Documents_Exists (
                                       App_Id,
                                       201)
                               WHEN Disabilitystate = 'DI'
                               THEN
                                   Api$validation.Check_Documents_Exists (
                                       App_Id,
                                       200)
                           END    AS Err_Doc
                   FROM Anketa
                  WHERE     (   (    Disabilitystate = 'I'
                                 AND Disabilityreason = 'ID')
                             OR Disabilitystate = 'IZ'
                             OR Disabilitystate = 'DI')
                        AND   Api$validation.Get_Doc_Count (App_Id, 201)
                            + Api$validation.Get_Doc_Count (App_Id, 200) <
                            1
                 UNION ALL
                 SELECT    'Для '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                        || ' в анкеті вказано "Так" в атрибуті "Дитина народжена поза межами України", '
                        || 'а документ "Свідоцтво про народження дитини (видане за межами України)" не додано"'    AS Err_Doc
                   FROM Anketa
                  WHERE     App_Tp = 'FP'
                        AND ChildOutsideUA = 'T'
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM Ap_Document Apd
                                  WHERE     Apd.Apd_App = App_Id
                                        AND Apd.History_Status = 'A'
                                        AND Apd.Apd_Ndt IN (673))
                 UNION ALL
                 SELECT    'Для послуги "Державна соціальна допомога малозабезпеченим сім’ям" для учасника звернення '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App.App_Sc)
                        || ', не прикріплено документ: "Витяг з Державного реєстру актів цивільного стану про народження дитини"'
                        || ' або для учасника звернення '
                        || Uss_Person.Api$sc_Tools.Get_Pib (Anketa.App_Sc)
                        || ', не прикріплено жоден з документів: "Свідоцтво РАГС про смерть", "Рішення суду про позбавлення батьківських прав"'    AS Err_Doc
                   FROM Anketa
                        LEFT JOIN Ap_Person App
                            ON     App.App_Ap = g_Ap_Id
                               AND App.App_Tp = 'FP'
                               AND App.History_Status = 'A'
                  WHERE     Anketa.App_Tp = 'Z'
                        AND Anketa.Alone = 'T'
                        AND Anketa.Disability <> 'T'
                        AND (  Api$validation.Get_Doc_Count (App.App_Id, 663)
                             + Api$validation.Get_Doc_Count (Anketa.App_Id,
                                                             10039)
                             + Api$validation.Get_Doc_Count (Anketa.App_Id,
                                                             89)) =
                            0
                        AND NVL (
                                TRUNC (
                                      MONTHS_BETWEEN (
                                          SYSDATE,
                                          COALESCE (
                                              Api$validation.Get_Doc_Dt (
                                                  App.App_Id,
                                                  6,
                                                  606),              --Паспорт
                                              Api$validation.Get_Doc_Dt (
                                                  App.App_Id,
                                                  7,
                                                  607),            --ID картка
                                              Api$validation.Get_Doc_Dt (
                                                  App.App_Id,
                                                  37,
                                                  91)) --свідоцтво про народження дитини
                                                      )
                                    / 12,
                                    0),
                                -1) BETWEEN 0
                                        AND 18)
        SELECT LISTAGG (Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check267 (Err_List OUT VARCHAR2)
    IS
        l_Iswidow   VARCHAR2 (20) := 'F';
    BEGIN
        SELECT NVL (MAX (Api$validation.Get_Doc_String (App.App_Id,
                                                        605,
                                                        674,
                                                        'F')),
                    'F')
          INTO l_Iswidow
          FROM Ap_Person App
         WHERE     App.App_Ap = g_Ap_Id
               AND App.App_Tp = 'Z'
               AND App.History_Status = 'A';

        SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (WITH
                    Anketa_Prev
                    AS
                        (SELECT App.App_Id,
                                App.App_ap,
                                App.App_Sc,
                                App.App_Tp,
                                Apda.Apda_Nda,
                                Apda.Apda_Val_String
                           FROM Ap_Person  App
                                JOIN Ap_Document Apd
                                    ON     Apd.Apd_App = App.App_Id
                                       AND Apd.Apd_Ndt = 605
                                       AND Apd.History_Status = 'A'
                                LEFT JOIN Ap_Document_Attr Apda
                                    ON     Apda.Apda_Apd = Apd.Apd_Id
                                       AND Apda.History_Status = 'A'
                                       AND Apda.Apda_Nda IN (871)
                          WHERE     App.App_Ap = g_Ap_Id
                                AND App.History_Status = 'A'),
                    Anketa
                    AS
                        (SELECT App_Id,
                                App_Ap,
                                App_Sc,
                                App_Tp,
                                NVL ("ChildOutsideUA", 'F')    ChildOutsideUA --причина інвалідності
                           FROM Anketa_Prev
                                    PIVOT (MAX (Apda_Val_String)
                                          FOR Apda_Nda
                                          IN (871 "ChildOutsideUA" --Дитина народжена поза межами України
                                                                  )))
                    SELECT    'Для послуги "Допомога на дітей одиноким матерям", учасника '
                           || Uss_Person.Api$sc_Tools.Get_Pib (App.App_Sc)
                           || ' не прикріплено жодного із документів: '
                           || (SELECT LISTAGG (
                                          '"' || Ndt.Ndt_Name_Short || '"',
                                          ' або ')
                                      WITHIN GROUP (ORDER BY 1)
                                 FROM Uss_Ndi.v_Ndi_Document_Type Ndt
                                WHERE     Ndt.History_Status = 'A'
                                      AND Ndt.Ndt_Id IN (663, 672, 673))    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Tp = 'FP'
                           AND App.History_Status = 'A'
                           AND l_Iswidow != 'T'
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM Ap_Document Apd
                                     WHERE     App.App_Id = Apd.Apd_App
                                           AND Apd.History_Status = 'A'
                                           AND Apd.Apd_Ndt IN (663, 672, 673))
                    UNION ALL
                      SELECT    'Для послуги "Допомога на дітей одиноким матерям", учасника '
                             || Uss_Person.Api$sc_Tools.Get_Pib (App.App_Sc)
                             || ' наявні '
                             || COUNT (Ndt.Ndt_Id)
                             || ' документа: '
                             || LISTAGG ('"' || Ndt.Ndt_Name_Short || '"',
                                         ' і ')
                                WITHIN GROUP (ORDER BY 1)
                             || ', видаліть зайвий документ'    AS x_Errors_List
                        FROM Ap_Person App
                             INNER JOIN Ap_Document Apd
                                 ON     App.App_Id = Apd.Apd_App
                                    AND Apd.History_Status = 'A'
                                    AND Apd.Apd_Ndt IN (663, 672, 673)
                             INNER JOIN Uss_Ndi.v_Ndi_Document_Type Ndt
                                 ON Ndt.Ndt_Id = Apd.Apd_Ndt
                       WHERE     App.App_Ap = g_Ap_Id
                             AND App.App_Tp = 'FP'
                             AND App.History_Status = 'A'
                             AND l_Iswidow != 'T'
                    GROUP BY App.App_Sc, COALESCE (App.App_Sc, App.App_Id)
                      HAVING COUNT (Ndt.Ndt_Id) > 1
                    UNION ALL
                    SELECT    'Для '
                           || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                           || ' в анкеті вказано "Так" в атрибуті "Дитина народжена поза межами України", '
                           || 'а документ "Свідоцтво про народження дитини (видане за межами України)" не додано"'    AS Err_Doc
                      FROM Anketa
                     WHERE     App_Tp = 'FP'
                           AND ChildOutsideUA = 'T'
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM Ap_Document Apd
                                     WHERE     Apd.Apd_App = App_Id
                                           AND Apd.History_Status = 'A'
                                           AND Apd.Apd_Ndt IN (673))
                    -- #112888
                    UNION ALL
                    SELECT 'Для цієї послуги обов`язковими типами учасників звернення мають бути "Заявник" та "Утриманець"!'    AS Err_Doc
                      FROM ap_person t
                     WHERE t.app_ap = g_Ap_Id AND t.app_tp IN ('Z', 'FP')
                    HAVING COUNT (*) < 2)
         WHERE x_Errors_List IS NOT NULL;
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check269 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        WITH
            Person
            AS
                (SELECT App.App_Ap,
                        App.App_Id,
                        App.App_Sc,
                        App.App_Tp,
                        Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)    AS App_Name
                   FROM Ap_Person App
                  WHERE     App.App_Ap = g_Ap_Id
                        AND App.App_Tp IN ('Z', 'FP')
                        AND App.History_Status = 'A'),
            Check_Doc
            AS
                (SELECT Api$validation.Check_Documents_Filled (App_Id,
                                                               37,
                                                               '90',
                                                               0)    AS Err_Doc
                   FROM Person)
        SELECT LISTAGG (Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    END;

    --==============================================================--
    PROCEDURE Set_ss_need_income
    IS
        l_is_801    NUMBER (10);
        l_is_802    NUMBER (10);
        l_is_803    NUMBER (10);
        l_is_835    NUMBER (10);
        l_is_836    NUMBER (10);
        l_pay_cnt   NUMBER (10);

        --------------------------
        PROCEDURE SET_VAL_STRING (p_ndt NUMBER, p_nda NUMBER, p_val VARCHAR2)
        IS
        BEGIN
            MERGE INTO ap_document_attr
                 USING (SELECT apda.apda_id     AS x_apda_id,
                               g_ap_id          AS x_apda_ap,
                               apd_id           AS x_apd_id,
                               p_nda            AS x_apda_nda,
                               p_val            AS x_apda_val_string
                          FROM ap_document  apd
                               LEFT JOIN ap_document_attr apda
                                   ON     apd_id = apda_apd
                                      AND apda_nda = p_nda
                                      AND apda.history_status = 'A'
                         WHERE     apd_ndt = p_ndt
                               AND apd_ap = g_ap_id
                               AND apd.history_status = 'A')
                    ON (apda_id = x_apda_id)
            WHEN MATCHED
            THEN
                UPDATE SET apda_val_string = x_apda_val_string
            WHEN NOT MATCHED
            THEN
                INSERT     (apda_id,
                            apda_ap,
                            apda_apd,
                            apda_nda,
                            apda_val_string,
                            history_status)
                    VALUES (x_apda_id,
                            x_apda_ap,
                            x_apd_id,
                            x_apda_nda,
                            x_apda_val_string,
                            'A');
        END;

        --------------------------
        FUNCTION Get_IsRecip_SS (p_app_tp VARCHAR2)
            RETURN NUMBER
        IS
            l_rez   NUMBER (10);
        BEGIN
            SELECT COUNT (1)
              INTO l_rez
              FROM ap_person
                   JOIN ap_document
                       ON     apd_app = app_id
                          AND apd_ndt = 605
                          AND ap_document.history_status = 'A'
                   JOIN ap_document_attr
                       ON     apda_apd = apd_id
                          AND ap_document_attr.history_status = 'A'
                   JOIN uss_ndi.v_ndi_document_attr
                       ON apda_nda = nda_id AND nda_nng = 19 -- «Категорія отримувача соціальних послуг»
             WHERE     app_ap = g_ap_id
                   AND app_tp = p_app_tp
                   AND ap_person.history_status = 'A'
                   AND NVL (apda_val_string, 'F') != 'F';

            RETURN SIGN (l_rez);
        END;

        --------------------------
        FUNCTION Get_IsRecip_Z_FM
            RETURN NUMBER
        IS
            l_rez   NUMBER (10);
        BEGIN
            WITH
                SS19
                AS
                    (SELECT app_id,
                            (SELECT COUNT (1)
                               FROM ap_document_attr
                                    JOIN uss_ndi.v_ndi_document_attr
                                        ON apda_nda = nda_id AND nda_nng = 19 -- «Категорія отримувача соціальних послуг»
                              WHERE     apda_apd = apd_id
                                    AND ap_document_attr.history_status = 'A'
                                    AND NVL (apda_val_string, 'F') != 'F')    AS cnt
                       FROM ap_person
                            JOIN ap_document
                                ON     apd_app = app_id
                                   AND apd_ndt = 605
                                   AND ap_document.history_status = 'A'
                      WHERE     app_ap = g_ap_id
                            AND app_tp IN ('Z', 'FM')
                            AND ap_person.history_status = 'A')
            SELECT COUNT (1)
              INTO l_rez
              FROM SS19
             WHERE cnt = 0;      -- рахуємо тих, хто немає права на соцпосдуги

            IF l_rez = 0
            THEN  --Немає членів сімї, хто немає права на безкоштовну допомогу
                RETURN 1;
            END IF;

            RETURN 0;
        END;
    --------------------------
    BEGIN
        l_is_801 := get_ap_doc_count (g_Ap_id, '801');
        l_is_802 := get_ap_doc_count (g_Ap_id, '802');
        l_is_803 := get_ap_doc_count (g_Ap_id, '803');
        l_is_835 := get_ap_doc_count (g_Ap_id, '835');
        l_is_836 := get_ap_doc_count (g_Ap_id, '836');

        SELECT COUNT (st.nst_is_payed)
          INTO l_pay_cnt
          FROM ap_service  s
               JOIN uss_ndi.v_ndi_service_type st ON st.nst_id = s.aps_nst
         WHERE     s.aps_ap = g_ap_id
               AND s.history_status = 'A'
               AND st.nst_is_payed = 'T';

        CASE
            WHEN l_is_802 > 0
            THEN
                put_line ('802');
                SET_VAL_STRING (802, 1948, 'F');
            WHEN l_is_803 > 0
            THEN
                put_line ('803');
                SET_VAL_STRING (803, 2528, 'F');
            WHEN     l_is_801 > 0
                 AND NVL (get_ap_doc_string (g_ap_id, 801, 1870), 'F') = 'T'
            THEN
                put_line ('801 get_ap_doc_string(g_ap_id, 801, 1870) = T');
                SET_VAL_STRING (801, 1871, 'F');
            WHEN l_is_801 > 0 AND l_pay_cnt = 0
            THEN
                put_line ('801 l_pay_cnt = 0');
                SET_VAL_STRING (801, 1871, 'F');
            WHEN     l_is_801 > 0
                 AND NVL (get_ap_doc_string (g_ap_id, 801, 1895), '-') = 'Z'
            THEN
                put_line (
                       '801 get_ap_doc_string(g_ap_id, 801, 1895) = Z  Get_IsRecip_SS(''Z'')='
                    || Get_IsRecip_SS ('Z'));

                IF Get_IsRecip_SS ('Z') > 0
                THEN
                    SET_VAL_STRING (801, 1871, 'F');
                ELSE
                    SET_VAL_STRING (801, 1871, 'T');
                END IF;
            WHEN     l_is_801 > 0
                 AND NVL (get_ap_doc_string (g_ap_id, 801, 1895), '-') = 'FM'
            THEN
                put_line (
                       '801 get_ap_doc_string(g_ap_id, 801, 1895) = FM  Get_IsRecip_Z_FM='
                    || Get_IsRecip_Z_FM);

                IF Get_IsRecip_Z_FM > 0
                THEN
                    SET_VAL_STRING (801, 1871, 'F');
                ELSE
                    SET_VAL_STRING (801, 1871, 'T');
                END IF;
            WHEN l_is_835 > 0
            THEN
                put_line ('835');
                SET_VAL_STRING (835, 3265, 'F');
            --    WHEN l_is_836 > 0 AND nvl(get_ap_doc_string(g_ap_id, 836, 1870), 'F') = 'T' THEN
            --        put_line('836 get_ap_doc_string(g_ap_id, 836, 1870) = T');
            --        SET_VAL_STRING(836, 3446, 'F');
            WHEN l_is_836 > 0 AND l_pay_cnt = 0
            THEN
                put_line ('836 l_pay_cnt = 0');
                SET_VAL_STRING (836, 3446, 'F');
            WHEN     l_is_836 > 0
                 AND NVL (get_ap_doc_string (g_ap_id, 836, 3443), '-') = 'Z'
            THEN
                put_line (
                       '836 get_ap_doc_string(g_ap_id, 836, 3443) = Z  Get_IsRecip_SS(''Z'')='
                    || Get_IsRecip_SS ('Z'));

                IF Get_IsRecip_SS ('Z') > 0
                THEN
                    SET_VAL_STRING (836, 3446, 'F');
                ELSE
                    SET_VAL_STRING (836, 3446, 'T');
                END IF;
            WHEN     l_is_836 > 0
                 AND NVL (get_ap_doc_string (g_ap_id, 836, 3443), '-') = 'FM'
            THEN
                put_line (
                       '836 get_ap_doc_string(g_ap_id, 836, 3443) = FM  Get_IsRecip_Z_FM='
                    || Get_IsRecip_Z_FM);

                IF Get_IsRecip_Z_FM > 0
                THEN
                    SET_VAL_STRING (836, 3446, 'F');
                ELSE
                    SET_VAL_STRING (836, 3446, 'T');
                END IF;
            WHEN Get_IsRecip_SS ('OS') > 0
            THEN
                put_line (
                    'Get_IsRecip_SS(''OS'') = ' || Get_IsRecip_SS ('OS'));
                SET_VAL_STRING (801, 1871, 'F');
            ELSE
                put_line ('ELSE');
                SET_VAL_STRING (801, 1871, 'T');
        END CASE;
    /*
    Результат визначення зберігати в атрибутах:
    - nda_id=1871 - для «Заява про надання соціальних послуг» ndt_id=801
    - nda_id=1948 - для «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» для ndt_id=802
    - nda_id=2528 - для «Акт про надання повнолітній особі соціальних послуг екстрено (кризово)» ndt_id=803
    */

    /*
    WHEN l_is_801 > 0 AND nvl(get_ap_doc_string(g_ap_id, 801, 1895), '-') NOT IN ('Z', 'FM') THEN
        IF Get_IsRecip_SS('OS') > 0 THEN
          SET_VAL_STRING(801, 1871, 'F');
        ELSE
          SET_VAL_STRING(801, 1871, 'T');
        END IF;
    WHEN l_is_801 > 0 AND nvl(get_ap_doc_string(g_ap_id, 801, 1895), '-') IN ('Z', 'FM') THEN
        IF Get_IsRecip_SS('Z') > 0 THEN
          SET_VAL_STRING(801, 1871, 'F');
        ELSE
          SET_VAL_STRING(801, 1871, 'T');
        END IF;
    WHEN l_is_801 > 0 THEN
          SET_VAL_STRING(801, 1871, 'F');
    ELSE
      NULL;
    END CASE;
*/
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check4xx_OS (Err_List OUT VARCHAR2)
    IS
        l_at_cur               SYS_REFCURSOR;
        l_provide_assistance   VARCHAR2 (20);
        l_provide_dogovor      VARCHAR2 (200);
        l_at_id                VARCHAR2 (20);
        l_Cu_Sc                NUMBER;
    BEGIN
        IF g_Ap_Src = 'PORTAL'
        THEN
            SELECT MAX (Ikis_Rbm.Tools.Getcusc (a.ap_cu))
              INTO l_Cu_Sc
              FROM appeal a
             WHERE ap_id = g_Ap_Id AND a.ap_cu IS NOT NULL;
        END IF;

        --    l_Cu_Sc := Ikis_Rbm.Tools.Getcusc(Ikis_Rbm.Tools.Getcurrentcu);

        l_provide_assistance :=
            NVL (get_ap_doc_string (g_ap_id, 800, 3061), '-');
        l_provide_dogovor :=
            NVL (get_ap_doc_string (g_ap_id, 800, 3062), '-');

        --    dbms_output_put_lines('l_provide_assistance ='||l_provide_assistance );

        CASE
            WHEN l_provide_assistance IN ('-')
            THEN
                Err_List :=
                    'Діючих рішень про надання соціальних послуг, зазначених у заяві про відмову, не знайдено. Перевірте коректність внесених даних щодо учасника звернення або доданих послуг';
            WHEN l_provide_dogovor IN ('-')
            THEN
                Err_List :=
                    'Не вказано договір про надання соціальних послуг';
            WHEN l_provide_assistance IN ('Z', 'FM')
            THEN
                FOR rec
                    IN (SELECT NVL (app.app_sc, l_Cu_Sc)     AS app_sc,
                               aps.aps_nst
                          FROM ap_person  app
                               JOIN ap_service aps ON app_ap = aps_ap
                         WHERE     App_Ap = g_Ap_Id
                               AND App_Tp = 'Z'
                               AND App.History_Status = 'A'
                               AND Aps.History_Status = 'A')
                LOOP
                    --dbms_output_put_lines('Get_Act_PDSP rec.app_sc='||rec.app_sc||', '||rec.aps_nst);
                    -- бо так шукають при створенні акту на припинення #94257
                    uss_esr.api$find.                         /*Get_Act_PDSP*/
                                     Get_Act_Terminate (
                        p_sc_id     => rec.app_sc,
                        p_nst_id    => rec.aps_nst,
                        p_act_cur   => l_at_cur);

                    FETCH l_at_cur INTO l_at_id;

                    CLOSE l_at_cur;

                    IF l_at_id IS NULL
                    THEN
                        Err_List :=
                            'Діючих рішень про надання соціальних послуг, зазначених у заяві про відмову, не знайдено. Перевірте коректність внесених даних щодо учасника звернення або доданих послуг';
                    END IF;
                END LOOP;
            ELSE
                FOR rec
                    IN (SELECT NVL (app.app_sc, l_Cu_Sc)     AS app_sc,
                               aps.aps_nst
                          FROM ap_person  app
                               JOIN ap_service aps ON app_ap = aps_ap
                         WHERE     App_Ap = g_Ap_Id
                               AND App_Tp = 'OS'
                               AND App.History_Status = 'A'
                               AND Aps.History_Status = 'A')
                LOOP
                    dbms_output_put_lines (
                        'rec.app_sc=' || rec.app_sc || ', ' || rec.aps_nst);

                    -- бо так шукають при створенні акту на припинення #94257
                    uss_esr.api$find.                         /*Get_Act_PDSP*/
                                     Get_Act_Terminate (
                        p_sc_id     => rec.app_sc,
                        p_nst_id    => rec.aps_nst,
                        p_act_cur   => l_at_cur);

                    FETCH l_at_cur INTO l_at_id;

                    CLOSE l_at_cur;

                    IF l_at_id IS NULL
                    THEN
                        Err_List :=
                            'Діючих рішень про надання соціальних послуг, зазначених у заяві про відмову, не знайдено. Перевірте коректність внесених даних щодо учасника звернення або доданих послуг';
                    END IF;
                END LOOP;
        END CASE;

        SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (SELECT CASE
                           WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                  800) >
                                    0
                                AND Api$validation.Get_doc_String (app_id,
                                                                   800,
                                                                   3061,
                                                                   '-') IN
                                        ('B', 'CHRG')
                           THEN
                               'Список учасників звернення не відповідає встановленому значенню атрибута заяви «послуга надається»'
                           ELSE
                               NULL
                       END    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM Ap_Person App_OS
                                 WHERE     App_OS.App_Ap = App.App_Ap
                                       AND App_OS.App_Tp = 'OS'
                                       AND App_OS.History_Status = 'A')
                UNION ALL
                SELECT Err_List     AS x_Errors_List
                  FROM DUAL
                 WHERE Err_List IS NOT NULL)
         WHERE x_Errors_List IS NOT NULL;
    /*
    Додати контроль з типом «Помилка»:
    - для R.OS-звернень – якщо в ndt_id=800 «Заява щодо відмови від отримання соціальних послуг»
    вказано «послуга надається» nda_id=3061 in (‘моєму(їй) синові (доньці)’, ‘підопічному(ій)’) і
    відсутній учасник звернення «Особа, що потребує СП» (OS)
    При наявності помилки видавати повідомлення –
    «Список учасників звернення не відповідає встановленому значенню атрибута заяви «послуга надається»
    Приклад – звернення 42073
    */
    END;

    PROCEDURE Check4xx_GS (Err_List OUT VARCHAR2)
    IS
        l_at_cur   SYS_REFCURSOR;
        l_at_id    VARCHAR2 (20);
    BEGIN
        FOR rec
            IN (SELECT app.app_sc, aps.aps_nst
                  FROM ap_person app JOIN ap_service aps ON app_ap = aps_ap
                 WHERE     App_Ap = g_Ap_Id
                       AND App_Tp = 'OS'
                       AND App.History_Status = 'A'
                       AND Aps.History_Status = 'A')
        LOOP
            --dbms_output_put_lines('rec.app_sc='||rec.app_sc||', '||rec.aps_nst);

            uss_esr.api$find.Get_Act_PDSP (p_sc_id     => rec.app_sc,
                                           p_nst_id    => rec.aps_nst,
                                           p_act_cur   => l_at_cur);


            FETCH l_at_cur INTO l_at_id;

            CLOSE l_at_cur;

            IF l_at_id IS NULL
            THEN
                Err_List :=
                    'Діючих рішень про надання соціальних послуг, зазначених у заяві про відмову, не знайдено. Перевірте коректність внесених даних щодо учасника звернення або доданих послуг';
            END IF;
        END LOOP;

        SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (SELECT CASE
                           WHEN Api$validation.Get_Doc_Count (App_Id, 861) >
                                0
                           THEN
                               'У списку учасників звернення обов’язково повинен бути наявним учасник з типом «Особа, що потребує СП»'
                           ELSE
                               NULL
                       END    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM Ap_Person App_OS
                                 WHERE     App_OS.App_Ap = App.App_Ap
                                       AND App_OS.App_Tp = 'OS'
                                       AND App_OS.History_Status = 'A')
                UNION ALL
                SELECT Err_List     AS x_Errors_List
                  FROM DUAL
                 WHERE Err_List IS NOT NULL)
         WHERE x_Errors_List IS NOT NULL;
    /*
    - для R.GS-звернень – якщо в ndt_id=861 «Інформація про припинення надання соціальних послуг»
    відсутній учасник звернення «Особа, що потребує СП» (OS)
    При наявності помилки видавати повідомлення –
    «У списку учасників звернення обов’язково повинен бути наявним учасник з типом «Особа, що потребує СП»
    Приклад – звернення 41599*/

    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check4xx (Err_List OUT VARCHAR2)
    IS
    BEGIN
        IF g_Ap_Tp = 'G'
        THEN
            Check_g (Err_List);
        ELSIF g_Ap_Tp = 'R.OS'
        THEN
            Check4xx_OS (Err_List);
        ELSIF g_Ap_Tp = 'R.GS'
        THEN
            Check4xx_GS (Err_List);
        ELSE
            /*
            Додати контролі з типом «Помилка»:
            - якщо в анкеті ndt_id=605 значення атрибута nda_id in (660) = Так, то мають бути заповненими атрибути nda_id in (1789, 1790, 1793)
            За наявності помилки виводити повідомлення:
            «В анкеті учасника звернення » + ПІБ + « у блоці «Категорія особи» встановлено ознаку «Особа з інвалідністю», але не внесено дані в блоці «Інформація про інвалідність»

            - якщо в анкеті ndt_id=605 заповнено атрибути nda_id in (1789, 1790, 1793), то повинно бути значення атрибута nda_id in (660) = Так
            За наявності помилки виводити повідомлення:
            «В анкеті учасника звернення » + ПІБ + « внесено дані в блоці «Інформація про інвалідність», але у блоці «Категорія особи» не встановлено ознаку «Особа з інвалідністю»
            */

            --    ELSIF g_Ap_Tp = 'SS' AND g_Ap_Src = api$appeal.c_Src_Portal THEN

            /*
            - контроль коректності внесених атрибутів:
            -- якщо встановлено «Отримувач звернення» nda_id in (3261) = «структурному підрозділу з питань соціального захисту населення» - має бути заповнений nda_id in (3262)
            -- якщо встановлено «Отримувач звернення» nda_id in (3261) = «надавачу соціальних послуг» - має бути заповнений nda_id in (3263)

            Після вдалого проходження контролів відправляти звернення на опрацювання в ЄСР.

            Отримувати запити по доходам і виконувати потім розрахунок в ЄСРі не потрібно.
            Для визначення цього атрибуту nda_id=3265 за замовченням встановлено значення nda_def_value = 'F'
            */

            --Raise_Application_Error(-20000, 'Check4xx');
            WITH
                Adr
                AS
                    (SELECT app_sc,
                            Apda_Ap,
                            Apda_Apd,
                            "KATTOTG_NAME",
                            "KATTOTG_ID",
                            (SELECT MAX (Npo.Npo_Index)
                               FROM Uss_Ndi.v_Ndi_Post_Office Npo
                              WHERE Npo.Npo_Kaot = "KATTOTG_ID")
                                AS Kattotg_Index,
                            "INDEX_NAME"
                                AS Index_
                       FROM (  SELECT App.App_Sc,
                                      Apda.Apda_Ap,
                                      Apda.Apda_Apd,
                                      Apda.Apda_Nda,
                                      Apda.Apda_Val_String,
                                      Apda.Apda_Val_Id
                                 FROM Ap_Person App
                                      JOIN Ap_Document Apd
                                          ON     Apd.Apd_App = App.App_Id
                                             AND Apd.Apd_Ndt = 605
                                             AND Apd.History_Status = 'A'
                                      JOIN Ap_Document_Attr Apda
                                          ON     Apda.Apda_Apd = Apd.Apd_Id
                                             AND Apda.History_Status = 'A'
                                             AND Apda.Apda_Nda IN (1488,
                                                                   1489,
                                                                   1618,
                                                                   1625)
                                WHERE Apd.Apd_Ap = g_Ap_Id
                             ORDER BY Apda.Apda_Apd, Apda.Apda_Id)
                                PIVOT (
                                      MAX (Apda_Val_String) NAME,
                                      MAX (Apda_Val_Id) Id
                                      FOR Apda_Nda
                                      IN (1488 "KATTOTG", 1489 "INDEX"))),
                r_Adr
                AS
                    (SELECT app_sc,
                            Apda_Ap,
                            Apda_Apd,
                            "KATTOTG_NAME",
                            "KATTOTG_ID",
                            (SELECT MAX (Npo.Npo_Index)
                               FROM Uss_Ndi.v_Ndi_Post_Office Npo
                              WHERE Npo.Npo_Kaot = "KATTOTG_ID")
                                AS Kattotg_Index,
                            "INDEX_NAME"
                                AS Index_
                       FROM (  SELECT App.App_Sc,
                                      Apda.Apda_Ap,
                                      Apda.Apda_Apd,
                                      Apda.Apda_Nda,
                                      Apda.Apda_Val_String,
                                      Apda.Apda_Val_Id
                                 FROM Ap_Person App
                                      JOIN Ap_Document Apd
                                          ON     Apd.Apd_App = App.App_Id
                                             AND Apd.Apd_Ndt = 605
                                             AND Apd.History_Status = 'A'
                                      JOIN Ap_Document_Attr Apda
                                          ON     Apda.Apda_Apd = Apd.Apd_Id
                                             AND Apda.History_Status = 'A'
                                             AND Apda.Apda_Nda IN (1488,
                                                                   1489,
                                                                   1618,
                                                                   1625)
                                WHERE Apd.Apd_Ap = g_Ap_Id
                             ORDER BY Apda.Apda_Apd, Apda.Apda_Id)
                                PIVOT (
                                      MAX (Apda_Val_String) NAME,
                                      MAX (Apda_Val_Id) Id
                                      FOR Apda_Nda
                                      IN (1618 "KATTOTG", 1625 "INDEX"))),
                ap801
                AS
                    (SELECT a.ap_id,
                            api$validation.Get_Ap_Doc_String (a.ap_id,
                                                              801,
                                                              1868)
                                ss_need,
                            api$validation.Get_Ap_Doc_String (a.ap_id,
                                                              801,
                                                              1895)
                                ss_app,
                            (SELECT COUNT (1)
                               FROM ap_person app
                              WHERE     app_ap = a.ap_id
                                    AND app.history_status = 'A'
                                    AND app.app_tp = 'Z')
                                AS cnt_Z,
                            (SELECT COUNT (1)
                               FROM ap_person app
                              WHERE     app_ap = a.ap_id
                                    AND app.history_status = 'A'
                                    AND app.app_tp = 'FM')
                                AS cnt_FM,
                            (SELECT COUNT (1)
                               FROM ap_person app
                              WHERE     app_ap = a.ap_id
                                    AND app.history_status = 'A'
                                    AND app.app_tp = 'OS')
                                AS cnt_OS,
                            (SELECT COUNT (1)
                               FROM ap_person app
                              WHERE     app_ap = a.ap_id
                                    AND app.history_status = 'A'
                                    AND app.app_tp = 'FMS')
                                AS cnt_FMS,
                            (SELECT COUNT (1)
                               FROM ap_person app
                              WHERE     app_ap = a.ap_id
                                    AND app.history_status = 'A'
                                    AND app.app_tp = 'AF')
                                AS cnt_AF,
                            (SELECT COUNT (1)
                               FROM ap_person app
                              WHERE     app_ap = a.ap_id
                                    AND app.history_status = 'A'
                                    AND app.app_tp = 'OR')
                                AS cnt_OR,
                            (SELECT COUNT (1)
                               FROM ap_person app
                              WHERE     app_ap = a.ap_id
                                    AND app.history_status = 'A'
                                    AND app.app_tp = 'AG')
                                AS cnt_AG,
                            (SELECT COUNT (1)
                               FROM ap_person app
                              WHERE     app_ap = a.ap_id
                                    AND app.history_status = 'A'
                                    AND app.app_tp = 'AP')
                                AS cnt_AP,
                            a.ap_src
                       FROM appeal a
                      WHERE     a.ap_id = g_Ap_Id
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_document apd
                                      WHERE     apd_ap = a.ap_id
                                            AND apd.history_status = 'A'
                                            AND apd.apd_ndt = 801))
            SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
              INTO Err_List
              FROM (SELECT CASE
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      801) >
                                        0
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            801,
                                            1895)
                                            IS NULL
                               THEN
                                   'В документі "Заява про надання соціальних послуг" не заповнено атрибут "Послугу надати"'
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      802) >
                                        0
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            802,
                                            1944)
                                            IS NULL
                               THEN
                                   'В документі "Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО" не заповнено атрибут "Соціальних послуг потребує"'
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      802) >
                                        0
                                    AND NVL (
                                            REGEXP_INSTR (
                                                Api$validation.Get_doc_String (
                                                    app_id,
                                                    802,
                                                    2914),
                                                '^\d{8}$'),
                                            0) =
                                        0
                                    AND NVL (
                                            REGEXP_INSTR (
                                                Api$validation.Get_doc_String (
                                                    app_id,
                                                    802,
                                                    2914),
                                                '^\d{10}$'),
                                            0) =
                                        0
                               THEN
                                   'В атрибут «ЄДРПОУ / РНОКПП» можна ввести або 8, або 10 цифр'
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      803) >
                                        0
                                    AND NVL (
                                            REGEXP_INSTR (
                                                Api$validation.Get_doc_String (
                                                    app_id,
                                                    803,
                                                    2915),
                                                '^\d{8}$'),
                                            0) =
                                        0
                                    AND NVL (
                                            REGEXP_INSTR (
                                                Api$validation.Get_doc_String (
                                                    app_id,
                                                    803,
                                                    2915),
                                                '^\d{10}$'),
                                            0) =
                                        0
                               THEN
                                   'В атрибут «ЄДРПОУ / РНОКПП» можна ввести або 8, або 10 цифр'
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      835) >
                                        0
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            835,
                                            3261)
                                            IS NULL
                               THEN
                                   'В документі "Звернення з кабінету отримувача соціальних послуг" не заповнено атрибут "Отримувач звернення"'
                               --#88642 2023.06.27
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      835) >
                                        0
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            835,
                                            3261) =
                                        'SB'
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            835,
                                            3262)
                                            IS NULL
                               THEN
                                   'В документі "Звернення з кабінету отримувача соціальних послуг" не заповнено атрибут "Назва СПСЗН"'
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      835) >
                                        0
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            835,
                                            3261) =
                                        'G'
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            835,
                                            3263)
                                            IS NULL
                               THEN
                                   'В документі "Звернення з кабінету отримувача соціальних послуг" не заповнено атрибут "Найменування надавача соціальних послуг"'
                               ELSE
                                   NULL
                           END    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Tp IN ('Z',
                                              'AF',
                                              'OR',
                                              'AG')
                           AND App.History_Status = 'A'
                    UNION ALL
                    SELECT CASE
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      836) >
                                        0
                                    AND api$validation.Get_doc_String (
                                            app_id,
                                            836,
                                            3443)
                                            IS NULL
                               THEN
                                   'В документі "Заява про надання соціальної послуги медіації" не заповнено атрибут "Послугу надати"'
                           END    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Tp IN ('Z',
                                              'AF',
                                              'OR',
                                              'AG')
                           AND App.History_Status = 'A'
                    UNION ALL
                    SELECT CASE
                               WHEN Api$validation.Get_Doc_Count (App_Id,
                                                                  605) =
                                    0
                               THEN
                                      'Відсутній документ "Анкета учасника звернення" для '
                                   || App_Ln
                                   || ' '
                                   || App_Fn
                                   || ' '
                                   || App_Mn
                           END    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE App.App_Ap = g_Ap_Id AND App.History_Status = 'A'
                    UNION ALL
                    SELECT CASE
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      836) >
                                        0
                                    AND Api$validation.Aps_Exists (404) = 0
                               THEN
                                   'Для доданого виду заяви необхідно вказати послугу – «Посередництво»'
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      836) >
                                        0
                                    AND Api$validation.Only_One_Aps_Exists_n (
                                            404) =
                                        0
                               THEN
                                   'Для доданого виду заяви необхідно вказати тільки одну послугу – «Посередництво»'
                           END    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Tp IN ('Z',
                                              'AF',
                                              'OR',
                                              'AG')
                           AND App.History_Status = 'A'
                    UNION ALL
                    SELECT CASE
                               WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                      835) >
                                        0
                                    AND g_Ap_Src != 'PORTAL'
                               THEN
                                   'Документ «Звернення з кабінету ОСП» можна додавати тільки в кабінеті отримувача соціальних послуг'
                               ELSE
                                   NULL
                           END    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Tp IN ('Z',
                                              'AF',
                                              'OR',
                                              'AG')
                           AND App.History_Status = 'A'
                    --              UNION ALL
                    --              SELECT Api$validation.Get_Doc_Count(App_Id, 836) > 0
                    --              FROM Ap_Person App
                    --              WHERE App.App_Ap = g_Ap_Id
                    --                AND App.App_Tp = 'Z'
                    --                AND App.History_Status = 'A'
                    UNION ALL
                    SELECT CASE
                               WHEN     Api$validation.Get_Val_String (
                                            Apd_id,
                                            2082)
                                            IS NOT NULL
                                    AND Api$validation.Get_Val_String (
                                            Apd_id,
                                            2084)
                                            IS NULL
                               THEN
                                   'Якщо є потреба у подальшому наданні СП, то яких саме має бути заповненим'
                               ELSE
                                   ''
                           END    AS x_Errors_List
                      FROM Ap_Person  App
                           JOIN Ap_Document apd
                               ON     apd_app = app_id
                                  AND apd_ndt = 803
                                  AND apd.history_status = 'A'
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Tp IN ('Z',
                                              'AF',
                                              'OR',
                                              'AG')
                           AND App.History_Status = 'A'
                    UNION ALL
                    SELECT 'Формат номера "Паспорт громадянина України": дві великі літери та шість цифр'    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.History_Status = 'A'
                           AND Api$validation.Get_Doc_Count (App_Id, 6) > 0
                           AND NVL (
                                   REGEXP_INSTR (
                                       Api$validation.Get_Doc_String (App_Id,
                                                                      6,
                                                                      3),
                                       '^[А-Я]{2}[0-9]{6}$',
                                       1),
                                   0) =
                               0
                    UNION ALL
                    SELECT 'Формат номера "ID картка": дев''ять цифр'    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.History_Status = 'A'
                           AND Api$validation.Get_Doc_Count (App_Id, 7) > 0
                           AND NVL (
                                   REGEXP_INSTR (
                                       Api$validation.Get_Doc_String (App_Id,
                                                                      7,
                                                                      9),
                                       '^[0-9]{9}$',
                                       1),
                                   0) =
                               0
                    UNION ALL
                    SELECT CASE
                               WHEN Ap.Ap_Tp IN ('SS')
                               THEN
                                   NULL
                               WHEN     Api$validation.Get_doc_String (
                                            app_id,
                                            605,
                                            660,
                                            'F') = 'T'
                                    AND (   Api$validation.Get_doc_String (
                                                app_id,
                                                605,
                                                1789,
                                                'N') = 'N'
                                         OR Api$validation.Get_doc_String (
                                                app_id,
                                                605,
                                                1790)
                                                IS NULL
                                         OR Api$validation.Get_Doc_Dt (
                                                app_id,
                                                605,
                                                1793)
                                                IS NULL)
                               THEN
                                      'В анкеті учасника звернення '
                                   || App_Ln
                                   || ' '
                                   || App_Fn
                                   || ' '
                                   || App_Mn
                                   || ' у блоці «Категорія особи» встановлено ознаку «Особа з інвалідністю», але не внесено дані в блоці «Інформація про інвалідність»'
                               WHEN     Api$validation.Get_doc_String (
                                            app_id,
                                            605,
                                            660,
                                            'F') != 'T'
                                    AND (   Api$validation.Get_doc_String (
                                                app_id,
                                                605,
                                                1789,
                                                'N') != 'N'
                                         OR Api$validation.Get_doc_String (
                                                app_id,
                                                605,
                                                1790)
                                                IS NOT NULL
                                         OR Api$validation.Get_Doc_Dt (
                                                app_id,
                                                605,
                                                1793)
                                                IS NOT NULL)
                               THEN
                                      'В анкеті учасника звернення '
                                   || App_Ln
                                   || ' '
                                   || App_Fn
                                   || ' '
                                   || App_Mn
                                   || ' внесено дані в блоці «Інформація про інвалідність», але у блоці «Категорія особи» не встановлено ознаку «Особа з інвалідністю»'
                               ELSE
                                   NULL
                           END    AS x_Errors_List
                      FROM Ap_Person App, Appeal Ap
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Ap = Ap.Ap_Id
                           AND App.History_Status = 'A'
                    UNION ALL
                    SELECT CASE
                               WHEN KATTOTG_ID IS NULL AND Index_ IS NULL
                               THEN
                                   'В документі "Анкета учасника звернення" не заповнено атрибути "КАТТОТГ" та "Індекс" в адресі реєстрації'
                               WHEN KATTOTG_ID IS NULL
                               THEN
                                   'В документі "Анкета учасника звернення" не заповнено атрибут "КАТТОТГ" в адресі реєстрації'
                               WHEN Index_ IS NULL
                               THEN
                                   'В документі "Анкета учасника звернення" не заповнено атрибут "Індекс" в адресі реєстрації'
                               --WHEN Nvl(Kattotg_Index, '-1') != Nvl(Index_, '-2') THEN
                               -- 'В документі "Анкета учасника звернення" обрано індекс, який не відповідає КАТТОТГ із назвою ' ||
                               -- Kattotg_Name
                               ELSE
                                   ''
                           END    AS l_Err
                      FROM Adr
                    UNION ALL
                    SELECT CASE
                               WHEN KATTOTG_ID IS NULL AND Index_ IS NULL
                               THEN
                                   'В документі "Анкета учасника звернення" не заповнено атрибути "КАТТОТГ" та "Індекс" в адресі проживання'
                               WHEN KATTOTG_ID IS NULL
                               THEN
                                   'В документі "Анкета учасника звернення" не заповнено атрибут "КАТТОТГ" в адресі проживання'
                               WHEN Index_ IS NULL
                               THEN
                                   'В документі "Анкета учасника звернення" не заповнено атрибут "Індекс" в адресі проживання'
                               --WHEN Nvl(Kattotg_Index, '-1') != Nvl(Index_, '-2') THEN
                               -- 'В документі "Анкета учасника звернення" обрано індекс, який не відповідає КАТТОТГ із назвою ' ||
                               -- Kattotg_Name
                               ELSE
                                   ''
                           END    AS l_Err
                      FROM r_Adr
                    UNION ALL
                    SELECT CASE
                               WHEN     Api$validation.Get_doc_String (
                                            app_id,
                                            801,
                                            3688,
                                            '-') = 'G'
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            801,
                                            1872)
                                            IS NULL
                               THEN
                                   'У заяві встановлено необхідність розгляду звернення надавачем, але надавача не вказано#FATAL_ERROR#'
                               WHEN     Api$validation.Get_doc_String (
                                            app_id,
                                            802,
                                            3687,
                                            '-') = 'G'
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            802,
                                            3689)
                                            IS NULL
                               THEN
                                   'У заяві встановлено необхідність розгляду звернення надавачем, але надавача не вказано#FATAL_ERROR#'
                               WHEN     Api$validation.Get_doc_String (
                                            app_id,
                                            835,
                                            3261,
                                            '-') = 'G'
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            835,
                                            3263)
                                            IS NULL
                               THEN
                                   'У заяві встановлено необхідність розгляду звернення надавачем, але надавача не вказано#FATAL_ERROR#'
                               WHEN     Api$validation.Get_doc_String (
                                            app_id,
                                            836,
                                            3686,
                                            '-') = 'G'
                                    AND Api$validation.Get_doc_String (
                                            app_id,
                                            836,
                                            3690)
                                            IS NULL
                               THEN
                                   'У заяві встановлено необхідність розгляду звернення надавачем, але надавача не вказано#FATAL_ERROR#'
                               ELSE
                                   NULL
                           END    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_tp IN ('Z',
                                              'AF',
                                              'OR',
                                              'AG')
                           AND App.History_Status = 'A'
                    UNION ALL
                    --#96311
                    SELECT                           --ap_id, ss_need, ss_app,
                           --'ss_need='||ss_need||'    ss_app='||ss_app||'  cnt_Z='||cnt_Z||'  cnt_AP='||cnt_AP||'  '||
                           CASE
                               WHEN (  cnt_Z
                                     + cnt_AF
                                     + cnt_OR
                                     + cnt_AG
                                     + cnt_AP) !=
                                    1
                               THEN
                                   '"Заявник" або «Уповноважений представник сім’ї» або «Уповноважена особа органу опіки та піклування» або «Законний представник особи, що потребує СП» повинен бути тільки один'
                               WHEN ss_need = 'Z' AND cnt_AP > 0
                               THEN
                                   CASE
                                       WHEN cnt_OS = 0
                                       THEN
                                           'Необхідно вказати «Особа, що потребує СП»'
                                   END
                               WHEN ss_need = 'Z' AND ss_app = 'Z'
                               THEN
                                   CASE
                                       WHEN cnt_Z = 0
                                       THEN
                                           'Необхідно вказати «Заявник»'
                                   END
                               WHEN ss_need = 'Z' AND ss_app = 'B'
                               THEN
                                   CASE
                                       WHEN cnt_Z = 0
                                       THEN
                                           'Необхідно вказати «Заявник»'
                                       WHEN cnt_OS = 0 AND ap_src = 'USS'
                                       THEN
                                           --#109220
                                           'Тип учасника звернення не відповідає встановленим у заяві значенням. Необхідно вказати «Особа, яка потребує соціальних послуг»#FATAL_ERROR#'
                                       WHEN cnt_OS = 0
                                       THEN
                                           'Необхідно вказати «Особа, що потребує СП»'
                                   END
                               WHEN ss_need = 'Z' AND ss_app = 'CHRG'
                               THEN
                                   CASE
                                       WHEN cnt_OR + cnt_AG = 0
                                       THEN
                                           'Необхідно вказати або «Уповноважена особа органу опіки та піклування» або «Законний представник особи, що потребує СП»'
                                       WHEN cnt_OS = 0
                                       THEN
                                           'Необхідно вказати «Особа, що потребує СП»'
                                   END
                               WHEN ss_need = 'FM' AND cnt_AP > 0
                               THEN
                                   CASE
                                       WHEN cnt_FMS = 0
                                       THEN
                                           'Необхідно вказати «Член сім’ї, на якого буде оформлено договір»'
                                       WHEN cnt_FM = 0
                                       THEN
                                           'Необхідно вказати «Член сім’ї»'
                                   END
                               WHEN ss_need = 'FM' AND ss_app = 'FM'
                               THEN
                                   CASE
                                       WHEN cnt_Z + cnt_AF = 0
                                       THEN
                                           'Необхідно вказати або «Заявник» або «Уповноважений представник сім’ї»'
                                       WHEN cnt_Z = 1 AND cnt_FM = 0
                                       THEN
                                           'Необхідно вказати «Член сім’ї»'
                                       --#109465
                                       --WHEN cnt_AF = 1 AND cnt_FMS = 0 THEN
                                       --  'Необхідно вказати «Член сім’ї, на якого буде оформлено договір»'
                                       WHEN cnt_AF = 1 AND cnt_FM = 0
                                       THEN
                                           'Необхідно вказати «Член сім’ї»'
                                   END
                               ELSE
                                   'Не допустима комбінація "Соціальних послуг потребує" + "Послугу надати"'
                           END    AS x_Errors_List
                      FROM ap801
                    UNION ALL
                    --#96312
                    SELECT CASE
                               WHEN apda_nda = 646
                               THEN
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '37, 6')
                               WHEN     apda_nda = 642
                                    AND api$validation.Get_App_Age (
                                            fm.app_id) <
                                        18
                               THEN
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '660,812')
                               WHEN apda_nda = 642
                               THEN
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '816,674')
                               WHEN     apda_nda = 643
                                    AND api$validation.Get_App_Age (
                                            fm.app_id) <
                                        18
                               THEN
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '660,812')
                               WHEN apda_nda = 643
                               THEN
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '816,674')
                               WHEN apda_nda = 644
                               THEN
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '114')
                               WHEN apda_nda = 2668
                               THEN
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '811')
                               WHEN apda_nda = 648
                               THEN
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '661')
                               WHEN apda_nda = 2654
                               THEN
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '662')
                           END    AS x_Errors_List
                      FROM ap_person  z
                           JOIN ap_document
                               ON     apd_app = z.app_id
                                  AND ap_document.history_status = 'A'
                           JOIN ap_document_attr
                               ON     apda_apd = apd_id
                                  AND ap_document_attr.history_status = 'A'
                           JOIN ap_person fm
                               ON     fm.app_ap = z.app_ap
                                  AND fm.app_tp IN ('OS')
                                  AND fm.history_status = 'A'
                     WHERE     z.app_ap = g_Ap_Id
                           AND z.app_tp = 'OR'
                           AND apd_app = z.app_id
                           AND apd_ndt = 605                         -- Анкета
                           AND NVL (apda_val_string, 'F') != 'F'
                           AND apda_nda IN (646,
                                            642,
                                            643,
                                            644,
                                            2668,
                                            648,
                                            2654)
                    UNION ALL
                    SELECT CASE
                               WHEN api$validation.Get_App_Age (fm.app_id) <
                                    18
                               THEN
                                   '' --api$validation.check_doc_exists(fm.app_id, '660,812')
                               ELSE
                                   api$validation.check_doc_exists (
                                       fm.app_id,
                                       '674,815')
                           END    AS x_Errors_List
                      FROM ap_person  z
                           JOIN ap_person fm
                               ON     fm.app_ap = z.app_ap
                                  AND fm.app_tp IN ('OS')
                                  AND fm.history_status = 'A'
                     WHERE z.app_ap = g_Ap_Id AND z.app_tp = 'AG')
             WHERE x_Errors_List IS NOT NULL;
        END IF;

        /*
        При збереженні картки і спробі зміни її статусу на «Зареєстровано» додати контролі з типом контролю «Помилка»:
        1) на обов’язкову наявність у зверненні одного з документів:
        - «Заява про надання соціальних послуг» ndt_id=801
        - «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802
        - «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803

        2) на наявність у зверненні з якихось причин кількох з вказаних документів або кількох копій (варіантів) одного й того ж документа. Документ з вказаних має бути один і тільки один!

        При наявності помилки виводити текст:
        «У зверненні повинен бути присутнім один з трьох документів – або Заява, або Повідомлення/інформація, або Акт про надання СП екстрено»
        */
        Set_ss_need_income;
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check60x (Err_List OUT VARCHAR2)
    IS
    BEGIN
        WITH
            Doc10031
            AS
                (SELECT App_Id,
                        App_Sc,
                        app_ln || ' ' || app_fn || ' ' || app_mn
                            AS pib,
                        Get_Val_sum (Apd_Id, 890, 0)
                            AS Size_Denominator,
                        Get_Val_String (Apd_Id, 886, '-')
                            AS Deduction_Unit,
                        Get_Val_dt (Apd_Id, 943)
                            AS x_stop_dt
                   FROM Ap_Person
                        JOIN Ap_Document
                            ON     Apd_App = App_Id
                               AND Apd_Ndt = 10031
                               AND Ap_Document.History_Status = 'A'
                  WHERE App_Ap = g_Ap_Id AND Ap_Person.History_Status = 'A'),
            Doc10238
            AS
                (SELECT App_Id,
                        App_Sc,
                        app_ln || ' ' || app_fn || ' ' || app_mn    AS pib,
                        Get_Val_dt (Apd_Id, 4284)                   AS x_stop_dt
                   FROM Ap_Person
                        JOIN Ap_Document
                            ON     Apd_App = App_Id
                               AND Apd_Ndt = 10238
                               AND Ap_Document.History_Status = 'A'
                  WHERE App_Ap = g_Ap_Id AND Ap_Person.History_Status = 'A'),
            Check_Doc
            AS
                (SELECT App_Sc,
                        pib,
                        CASE
                            WHEN     Deduction_Unit = 'SD'
                                 AND Size_Denominator = 0
                            THEN
                                   ' якщо в документі "Постанова про звернення стягнення" в атрибуті одиниця вимірювання зазначено «частина доходу», '
                                || 'то в атрибуті «Розмір (знаменник: значення частини)» має бути обов’язково заповнено значення число, '
                                || 'яке відмінно від нуля'
                            WHEN x_stop_dt IS NULL
                            THEN
                                   ' в документі "Постанова про звернення стягнення аліментів на заробітну плату, пенсію, стипендію та інші доходи боржника" '
                                || 'не внесена кінцева дата відрахування аліментів.'
                        END    AS Err_Doc
                   FROM Doc10031
                 UNION ALL
                 SELECT App_Sc,
                        pib,
                        CASE
                            WHEN x_stop_dt IS NULL
                            THEN
                                ' в документі "Умови стягнення по дитині" не внесена кінцева дата відрахування аліментів.'
                        END    AS Err_Doc
                   FROM Doc10238)
        SELECT LISTAGG (
                      'Для '
                   || NVL (Uss_Person.Api$sc_Tools.Get_Pib (App_Sc), pib)
                   || Err_Doc,
                   CHR (13) || CHR (10))
               WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    /*
    в док-те ід=10031 " Постанова про звернення стягнення аліментів на заробітну плату, пенсію, стипендію та інші доходи боржника"
      додати контроль заповнення атрибута ід=943 "Кінцева дата відрахування аліментів".
    При збереженні звернення, за умови незаповненного атрибуту ід=943, - система має надати повідомлення про помилку :
    "Для "ПІБ" в документі "Постанова про звернення стягнення аліментів на заробітну плату, пенсію, стипендію та інші доходи боржника" не внесена кінцева дата відрахування аліментів."

    в док-те ід=10238" Умови стягнення по дитині"
      додати контроль заповнення атрибуту ід=4284 "Кінцева дата відрахування аліментів".
      При збереженні звернення, за умови незаповненного атрибуту ід=4284, - система має надати повідомлення про помилку :
    "Для "ПІБ" в документі " Умови стягнення по дитині" не внесена кінцева дата відрахування аліментів."

    */

    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check620 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        --#98703
        /*Якщо в зверненні по послузі з Ід=248 і Ід=248 додано два документи з
          Ід=10033 "Заява про перерахування коштів на банківський рахунок закладу держутримання" і
          Ід=10034 "Довідка про зарахування особи на повне державне утримання",
          то треба перевіряти щоб в Ід=924 в документі з Ід=10034 "Довідка про зарахування особи на повне державне утримання" був ЄДРПОУ
          який відповідає рахунку із атрибуту з Ід=5362 документу Ід=10033 "Заява про перерахування коштів на банківський рахунок закладу держутримання"

          Якщо ЄДРПОУ не відповідає, то це помилка, видавати повідомлення:
          Рахунок в документі "Заява про перерахування коштів на банківський рахунок закладу держутримання"
          не відповідає закладу держутримання в документі "Довідка про зарахування особи на повне державне утримання".

        Зауваження: в довіднику контрагентів може бути кілька рахунків для одного коду ЄДРПОУ.
        */

        SELECT LISTAGG (Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (SELECT CASE
                           WHEN NOT EXISTS
                                    (SELECT t.dpp_tax_code
                                       FROM uss_ndi.v_ndi_pay_person t
                                      WHERE     t.dpp_id =
                                                Get_Val_Id (Apd4.Apd_id, 924)
                                            AND EXISTS
                                                    (SELECT dpp.dpp_tax_code
                                                       FROM uss_ndi.v_Ndi_Pay_Person_Acc
                                                            dppa
                                                            JOIN
                                                            uss_ndi.v_NDI_PAY_PERSON
                                                            dpp
                                                                ON dpp.dpp_id =
                                                                   dppa.dppa_dpp
                                                      WHERE     dppa.dppa_id =
                                                                Get_Val_Id (
                                                                    Apd3.Apd_id,
                                                                    5362)
                                                            AND dpp.dpp_tax_code =
                                                                t.dpp_tax_code))
                           THEN
                                  'Рахунок в документі "Заява про перерахування коштів на банківський рахунок закладу держутримання"'
                               || ' не відповідає закладу держутримання в документі "Довідка про зарахування особи на повне державне утримання".'
                       END    AS Err_Doc
                  FROM Appeal
                       JOIN Ap_Document Apd3
                           ON     Apd3.Apd_Ap = ap_id
                              AND Apd3.Apd_Ndt = 10033
                              AND Apd3.History_Status = 'A'
                       JOIN Ap_Document Apd4
                           ON     Apd4.Apd_Ap = ap_id
                              AND Apd4.Apd_Ndt = 10034
                              AND Apd4.History_Status = 'A'
                 WHERE Ap_id = g_Ap_Id
                UNION ALL
                SELECT    'У звернення з типом послуги "Взяття особи на повне державне утримання" '
                       || 'документ "Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань" не потрібно додавати'    AS Err_Doc
                  FROM Ap_Document Apd
                 WHERE     Apd.Apd_Ap = g_Ap_Id
                       AND Apd.Apd_Ndt = 10035
                       AND Apd.History_Status = 'A')
         WHERE Err_Doc IS NOT NULL;
    END;

    --Якщо в зверненні з Ід=621 додано документ з Ід=10034, то це помилка, текст помилки
    --  "У звернення з типом послуги "Припинення відрахувань (тимчасове/постійне) на повне державне утриманняВзяття особи на повне державне утримання" документ "Довідка про зарахування особи на повне державне утримання" не потрібно додавати"

    --Якщо в зверненні з Ід=620 додано документ з Ід=10035, то це помилка. Текст помилки
    --  "У звернення з типом послуги "Взяття особи на повне державне утримання" документ "Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань" не потрібно додавати"
    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check62x (Err_List OUT VARCHAR2)
    IS
    BEGIN
        Set_Information;

        WITH
            Check_10035
            AS
                (SELECT Apd_Id,
                        Apd_App,
                        NVL ("Basis_Val", '-')         Basis,
                        "EDRPOU_Val"                   AS EDRPOU,
                        CASE   NVL ("DepOrder_IsNull", 0)
                             + NVL ("DepOrderD_IsNull", 0)
                             + NVL ("DepDate_IsNull", 0)
                            WHEN 0
                            THEN
                                1
                            ELSE
                                0
                        END                            AS Dep_Notnull,
                          NVL ("DepOrder_IsNull", 0)
                        + NVL ("DepOrderD_IsNull", 0)
                        + NVL ("DepDate_IsNull", 0)    AS Dep_Null_Cnt,
                        CASE   NVL ("ArrOrder_IsNull", 0)
                             + NVL ("ArrOrderD_IsNull", 0)
                             + NVL ("ArrDate_IsNull", 0)
                            WHEN 0
                            THEN
                                1
                            ELSE
                                0
                        END                            AS Arr_Notnull,
                          NVL ("ArrOrder_IsNull", 0)
                        + NVL ("ArrOrderD_IsNull", 0)
                        + NVL ("ArrDate_IsNull", 0)    AS Arr_Null_Cnt,
                        RTRIM (
                               CASE NVL ("DepOrder_IsNull", 0)
                                   WHEN 0 THEN "DepOrder_Name" || ', '
                                   ELSE ''
                               END
                            || CASE NVL ("DepOrderD_IsNull", 0)
                                   WHEN 0 THEN "DepOrderD_Name" || ', '
                                   ELSE ''
                               END
                            || CASE NVL ("DepDate_IsNull", 0)
                                   WHEN 0 THEN "DepDate_Name" || ', '
                                   ELSE ''
                               END,
                            ', ')                      AS Dep_Name_Notnull,
                        RTRIM (
                               CASE NVL ("DepOrder_IsNull", 0)
                                   WHEN 1 THEN "DepOrder_Name" || ', '
                                   ELSE ''
                               END
                            || CASE NVL ("DepOrderD_IsNull", 0)
                                   WHEN 1 THEN "DepOrderD_Name" || ', '
                                   ELSE ''
                               END
                            || CASE NVL ("DepDate_IsNull", 0)
                                   WHEN 1 THEN "DepDate_Name" || ', '
                                   ELSE ''
                               END,
                            ', ')                      AS Dep_Name_Isnull,
                        RTRIM (
                               CASE NVL ("ArrOrder_IsNull", 0)
                                   WHEN 0 THEN "ArrOrder_Name" || ', '
                                   ELSE ''
                               END
                            || CASE NVL ("ArrOrderD_IsNull", 0)
                                   WHEN 0 THEN "ArrOrderD_Name" || ', '
                                   ELSE ''
                               END
                            || CASE NVL ("ArrDate_IsNull", 0)
                                   WHEN 0 THEN "ArrDate_Name" || ', '
                                   ELSE ''
                               END,
                            ', ')                      AS Arr_Name_Notnull,
                        RTRIM (
                               CASE NVL ("ArrOrder_IsNull", 0)
                                   WHEN 1 THEN "ArrOrder_Name" || ', '
                                   ELSE ''
                               END
                            || CASE NVL ("ArrOrderD_IsNull", 0)
                                   WHEN 1 THEN "ArrOrderD_Name" || ', '
                                   ELSE ''
                               END
                            || CASE NVL ("ArrDate_IsNull", 0)
                                   WHEN 1 THEN "ArrDate_Name" || ', '
                                   ELSE ''
                               END,
                            ', ')                      AS Arr_Name_Isnull
                   FROM (SELECT Apda.Apd_Id,
                                Apda.Apd_App,
                                Apda.Nda_Id,
                                Apda.Nda_Name,
                                Apda.Apda_Is_Null,
                                Apda.Apda_Val_String
                           FROM v_Ap_Document_Attr_Check Apda
                          WHERE     Apda.Apd_Ndt = 10035
                                AND Apda.Apd_Ap = g_Ap_Id)
                            PIVOT (
                                  MAX (Apda_Is_Null) "IsNull",
                                  MAX (Nda_Name) "Name",
                                  MAX (Apda_Val_String) "Val"
                                  FOR Nda_Id
                                  IN (903 "ExtractD",
                                     906 "EDRPOU",
                                     909 "Basis",
                                     905 "DepOrder",
                                     904 "DepOrderD",
                                     907 "DepDate",
                                     911 "ArrOrder",
                                     910 "ArrOrderD",
                                     908 "ArrDate"))),
            Check_Doc
            AS
                (SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                        || ' '                                 Err_Pib,
                           'в документі "Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань" '
                        || 'не заповнено атрибут: Підстава'    AS Err_Doc
                   FROM Check_10035 JOIN Ap_Person App ON Apd_App = App_Id
                  WHERE Basis = '-'
                 UNION ALL
                 SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                        || ' '    Err_Pib,
                        (CASE
                             WHEN Arr_Null_Cnt < 3
                             THEN
                                    'в документі "Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань" '
                                 || 'зазначено інформацію про вибуття особи із закладу держутримання (заповнено причину вибуття"Самовільне вибуття", або "Смерть", або "Вибув", або "Переведення") '
                                 || 'при цьому заповнено атрибут щодо прибуття '
                                 || Arr_Name_Notnull
                         END)     AS Err_Doc
                   FROM Check_10035 JOIN Ap_Person App ON Apd_App = App_Id
                  WHERE Basis IN ('TR',
                                  'UN',
                                  'DE',
                                  'HL')
                 UNION ALL
                 SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                        || ' '    Err_Pib,
                        (CASE Dep_Notnull
                             WHEN 0
                             THEN
                                    'в документі "Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань" '
                                 || 'зазначено інформацію про вибуття особи із закладу держутримання (заповнено причину вибуття"Самовільне вибуття", або "Смерть", або "Вибув", або "Переведення") '
                                 || 'при цьому не заповнено атрибут щодо вибуття '
                                 || Dep_Name_Isnull
                         END)     AS Err_Doc
                   FROM Check_10035 JOIN Ap_Person App ON Apd_App = App_Id
                  WHERE Basis IN ('TR',
                                  'UN',
                                  'DE',
                                  'HL')
                 UNION ALL
                 SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                        || ' '    Err_Pib,
                        (CASE
                             WHEN    (    Dep_Null_Cnt IN (1, 2)
                                      AND Arr_Null_Cnt IN (1, 2))
                                  OR (Dep_Null_Cnt = 3 AND Arr_Null_Cnt = 3)
                             THEN
                                    'В документі "Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань" '
                                 || 'зазначено інформацію про Канікули/Лікування особи, яка  зареєстрована в закладі держутримання (заповнено причину "Канікули") '
                                 || 'при цьому не заповнено атрибути щодо вибуття/прибуття '
                                 || Dep_Name_Isnull
                                 || ', '
                                 || Arr_Name_Isnull
                             WHEN Arr_Null_Cnt IN (1, 2)
                             THEN
                                    'В документі "Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань" '
                                 || 'зазначено інформацію про Канікули/Лікування особи, яка  зареєстрована в закладі держутримання (заповнено причину "Канікули") '
                                 || 'при цьому не заповнено атрибути щодо вибуття/прибуття '
                                 || Arr_Name_Isnull
                             WHEN Dep_Null_Cnt IN (1, 2)
                             THEN
                                    'В документі "Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань" '
                                 || 'зазначено інформацію про Канікули/Лікування особи, яка  зареєстрована в закладі держутримання (заповнено причину "Канікули") '
                                 || 'при цьому не заповнено атрибути щодо вибуття/прибуття '
                                 || Dep_Name_Isnull
                         END)     AS Err_Doc
                   FROM Check_10035 JOIN Ap_Person App ON Apd_App = App_Id
                  WHERE Basis IN ('V')
                 --
                 UNION ALL
                 SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                        || ' '                                   Err_Pib,
                           'В документі Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань не заповнено атрибут(и):'
                        || 'Код ЄДРПОУ закладу держутримання'    AS Err_Doc
                   FROM Check_10035 JOIN Ap_Person App ON Apd_App = App_Id
                  WHERE EDRPOU IS NULL
                 --
                 UNION ALL
                 SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                        || ' відсутній документ '    Err_Pib,
                        (CASE s.Aps_Nst
                             WHEN 620
                             THEN
                                 Api$validation.Check_Documents_Exists (
                                     Ap_o.App_Id,
                                     10034)
                             WHEN 621
                             THEN
                                 Api$validation.Check_Documents_Exists (
                                     Ap_o.App_Id,
                                     10035)
                         END)                        AS Err_Doc
                   FROM Ap_Person  Ap_o
                        JOIN Ap_Service s ON s.Aps_Ap = Ap_o.App_Ap
                  WHERE     Ap_o.App_Ap = g_Ap_Id
                        AND Ap_o.History_Status = 'A'
                        AND Ap_o.App_Tp = 'O'
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM Ap_Person Ap_Du
                                  WHERE     Ap_Du.App_Ap = Ap_o.App_Ap
                                        AND Ap_Du.App_Tp = 'DU')
                 --1
                 UNION ALL
                 SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                            Err_Pib,
                        ' не зазначено інформацію про категорію інвалідності особи в документі Відомості про осіб із звернення «Держутримання»'
                            AS Err_Doc
                   FROM TABLE (Api$validation.Get_Information)
                  WHERE     App_Tp = 'O'
                        AND Cnt_Du = 0
                        AND NOT (   Disabilitychild = 'T'
                                 OR Disabilityfromchild = 'T')
                 UNION ALL
                 SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                            Err_Pib,
                        ' зазначено підтип заявника в документі Відомості про осіб із звернення «Держутримання»'
                            AS Err_Doc
                   FROM TABLE (Api$validation.Get_Information)
                  WHERE     App_Tp = 'O'
                        AND Cnt_Du = 0
                        AND (   Guardian = 'T'
                             OR Trustee = 'T'
                             OR Adopter = 'T'
                             OR Parents = 'T'
                             OR Representativeinst = 'T'
                             OR Parentseducator = 'T')
                 UNION ALL
                 --3
                 SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                            Err_Pib,
                        ' зазначено інформацію про категорію інвалідності особи в документі Відомості про осіб із звернення «Держутримання» для особи, яка не знаходиться на держутриманні'
                            AS Err_Doc
                   FROM TABLE (Api$validation.Get_Information)
                  WHERE     App_Tp = 'O'
                        AND Cnt_Du > 0
                        AND (   Disabilitychild = 'T'
                             OR Disabilityfromchild = 'T')
                 UNION ALL
                 SELECT    'Для отримувач допомоги '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                            Err_Pib,
                        ' не зазначено підтип заявника для особи, яка є отримувачем допомоги'
                            AS Err_Doc
                   FROM TABLE (Api$validation.Get_Information)
                  WHERE     App_Tp = 'O'
                        AND Cnt_Du > 0
                        AND NOT (   Guardian = 'T'
                                 OR Trustee = 'T'
                                 OR Adopter = 'T'
                                 OR Parents = 'T'
                                 OR Representativeinst = 'T'
                                 OR Parentseducator = 'T')
                 UNION ALL
                 --2
                 SELECT    'Для особи на держутриманні '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                            Err_Pib,
                        ' не зазначено інформацію про категорію інвалідності особи в документі Відомості про осіб із звернення «Держутримання»'
                            AS Err_Doc
                   FROM TABLE (Api$validation.Get_Information)
                  WHERE     App_Tp = 'DU'
                        AND NOT (   Disabilitychild = 'T'
                                 OR Disabilityfromchild = 'T')
                 UNION ALL
                 SELECT    'Для особи на держутриманні '
                        || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                            Err_Pib,
                        ' зазначено підтип заявника для особи, яка не є отримувачем допомоги в документі Відомості про осіб із звернення «Держутримання»'
                            AS Err_Doc
                   FROM TABLE (Api$validation.Get_Information)
                  WHERE     App_Tp = 'DU'
                        AND (   Guardian = 'T'
                             OR Trustee = 'T'
                             OR Adopter = 'T'
                             OR Parents = 'T'
                             OR Representativeinst = 'T'
                             OR Parentseducator = 'T')
                 UNION ALL
                 SELECT NULL,
                           'У звернення з типом послуги "Припинення відрахувань (тимчасове/постійне) на повне державне утримання" '
                        || 'документ "Довідка про зарахування особи на повне державне утримання" не потрібно додавати'    AS Err_Doc
                   FROM Ap_Document Apd
                  WHERE     Apd.Apd_Ap = g_Ap_Id
                        AND Apd.Apd_Ndt = 10034
                        AND Apd.History_Status = 'A'
                        AND EXISTS
                                (SELECT 1
                                   FROM ap_service s
                                  WHERE     s.aps_ap = g_Ap_Id
                                        AND s.aps_nst = 621
                                        AND s.History_Status = 'A'))
        SELECT LISTAGG (Err_Pib || Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    /*
      3. Якщо у зверненні з типом держутримання наявно два учасника звернення "Отримувач допомоги" та "Особа на держутриманні",
         то у документі з Ід=10037 має бути заповнено "Так" для хоча б одиного атрибуту в групі "Підтип заявника" для учасника звернення "Отримувач допомоги",
         а атрибути в групі "Основні параметри" не заповнені або = "НІ", інакше видавати повідомлення
         "Для зазначено інформацію про категорію інвалідності особи в документі Відомості про осіб із звернення «Держутримання» для особи, яка не знаходиться на держутриманні" або
         "Для не зазначено підтип заявника для особи, яка не є отримувачем допомоги"
      */

    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check641 (Err_List OUT VARCHAR2)
    IS
    --1. Обов'язково у зверненні повинен бути документ із ІД= 10115, якщо документу нема, то це - помилка,
    --   текст повідомлення про помилку: "У блоці документи відсутній документ "Зміна персональних даних" щодо одержувача допомоги".
    --2. Обов'язково у зверненнях такого типу в блоці "Документи" має бути зазначений хоча б один документ з категорією 13,
    --   якщо такого документу нема, то це помилка: "У блоці документи відсутній документ, який ідентифікує особу"
    BEGIN
        SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (SELECT CASE
                           WHEN Get_AP_Doc_Count (g_Ap_Id, 10115) < 1
                           THEN
                               'У блоці документи відсутній документ "Зміна персональних даних" щодо одержувача допомоги'
                           ELSE
                               NULL
                       END    AS x_Errors_List
                  FROM DUAL
                UNION ALL
                SELECT CASE
                           WHEN Get_AP_Doc_ndc13_Count (g_Ap_Id) < 1
                           THEN
                               'У блоці документи відсутній документ, який ідентифікує особу'
                           ELSE
                               NULL
                       END    AS x_Errors_List
                  FROM DUAL)
         WHERE x_Errors_List IS NOT NULL;
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check642 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (SELECT 'Для "Отримувач допомоги" повинен бути присутнім документ "Зміна виплатних реквізитів"'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'O'
                       AND App.History_Status = 'A'
                       AND (Api$validation.Get_Doc_Count (App_Id, 10091) < 1)
                UNION ALL
                SELECT 'Не відповідність дати подання заяви у картці звернення та в документі "Зміна виплатних документів"'    AS x_Errors_List
                  FROM Appeal Ap
                 WHERE     Ap.Ap_Id = g_Ap_Id
                       AND TRUNC (
                               NVL (
                                   Api$validation.Get_Ap_Doc_Dt (Ap.Ap_Id,
                                                                 10091,
                                                                 2105),
                                   TO_DATE ('3000', 'yyyy'))) !=
                           TRUNC (Ap.Ap_Reg_Dt)
                UNION ALL
                SELECT '"Спосіб виплати" введений у закладці звернення не відповідає "Способу виплати" в документі "Зміна виплатних документів"'    AS x_Errors_List
                  FROM Ap_Person  App
                       JOIN Ap_Payment Apm ON App.App_Ap = Apm.Apm_Ap
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'O'
                       AND App.History_Status = 'A'
                       AND Api$validation.Get_Doc_String (App.App_Id,
                                                          10091,
                                                          2192,
                                                          '-1') !=
                           NVL (Apm.Apm_Tp, '-1')
                UNION ALL
                SELECT CASE
                           WHEN p.Apm_Tp IS NULL
                           THEN
                               'Не обрано спосіб (тип) виплати допомоги в закладці "Параметри виплати"'
                           WHEN p.Apm_Tp = 'BANK'
                           THEN
                               ''
                           WHEN     p.Apm_Tp = 'POST'
                                AND Api$validation.Get_Doc_String (
                                        App.App_Id,
                                        10091,
                                        2191,
                                        '-') = '664'
                           THEN
                               'Для послуги "Допомога на проживання внутрішньо переміщеним особам" обрано спосіб виплати "Поштою" в закладці "Спосіб виплати"'
                           WHEN     Api$validation.Get_Doc_String (
                                        App.App_Id,
                                        10091,
                                        2192,
                                        '-') = 'POST'
                                AND Api$validation.Get_Doc_String (
                                        App.App_Id,
                                        10091,
                                        2191,
                                        '-') = '664'
                           THEN
                               'Для послуги "Допомога на проживання внутрішньо переміщеним особам" обрано спосіб виплати "Поштою" в документі "Зміна виплатних документів"'
                           WHEN     p.Apm_Tp = 'POST'
                                AND (   p.Apm_Kaot IS NULL
                                     OR p.Apm_Index IS NULL
                                     OR (    p.Apm_Street IS NULL
                                         AND p.Apm_Ns IS NULL)
                                     OR p.Apm_Building IS NULL)
                           THEN
                                  'Для способу виплати "Поштою" не заповнено реквізити:'
                               || LTRIM (
                                         CASE
                                             WHEN p.Apm_Index IS NULL
                                             THEN
                                                 ', Індекс'
                                         END
                                      || CASE
                                             WHEN p.Apm_Kaot IS NULL
                                             THEN
                                                 ', КАТОТГГ'
                                         END
                                      || CASE
                                             WHEN     p.Apm_Street IS NULL
                                                  AND p.Apm_Ns IS NULL
                                             THEN
                                                 ', Вулиця'
                                         END
                                      || CASE
                                             WHEN p.Apm_Building IS NULL
                                             THEN
                                                 ', Будинок'
                                         END,
                                      ',')
                       END    AS x_Errors_List
                  FROM Ap_Person  App
                       LEFT JOIN Ap_Payment p ON App.App_Ap = p.Apm_Ap
                       LEFT JOIN Uss_Ndi.v_Ddn_Apm_Tp t
                           ON p.Apm_Tp = t.Dic_Code
                       LEFT JOIN Uss_Ndi.v_Ndi_Bank b ON p.Apm_Nb = b.Nb_Id
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'O'
                       AND App.History_Status = 'A'
                       AND Api$validation.Get_Doc_String (App.App_Id,
                                                          10091,
                                                          2191,
                                                          '-') !=
                           NVL (p.Apm_Tp, '-1'))
         WHERE x_Errors_List IS NOT NULL;
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check643 (Err_List OUT VARCHAR2)
    IS
    --Додати верифікацію довідки ВПО для Заявника і Утриманців, та Свідоцтва про народження, якщо в Утриманця наявне свідоцтво про народження.
    BEGIN
        WITH
            Person
            AS
                (SELECT App.App_Ap,
                        App.App_Id,
                        App.App_Sc,
                        App.App_Tp,
                        Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)    AS App_Name
                   FROM Ap_Person App
                  WHERE     App.App_Ap = g_Ap_Id
                        AND App.App_Tp IN ('O', 'FP')
                        AND App.History_Status = 'A'),
            Check_Doc
            AS
                (SELECT 'Для "Отримувач допомоги" повинен бути присутнім документ "Заява про зміни складу сім''ї"'    AS Err_Doc
                   FROM Person
                  WHERE     App_Tp = 'O'
                        AND Api$validation.Get_Doc_Count (App_Id, 10098) = 0
                 UNION ALL
                 SELECT    'Для  '
                        || App_Name
                        || ' не додано документи ID картка, Посвідка на постійне проживання, Посвідка на тимчасове проживання, Тимчасове посвідчення громадянина України, Закордонний паспорт громадянина України, Свідоцтво про народження дитини видане в Україні або за межами України'    AS Err_Doc
                   FROM Person
                  WHERE     App_Tp = 'FP'
                        AND Api$validation.Get_Doc_ndc13_Count (App_Id) = 0
                 UNION ALL
                 SELECT    'В документі "ID картка" не заповнено дату народження особи '
                        || App_Name    AS Err_Doc
                   FROM Person
                  WHERE     Api$validation.Get_Doc_Count (App_Id, 7) > 0
                        AND Api$validation.Get_Doc_Dt (App_Id, 7, 607)
                                IS NULL
                 UNION ALL
                 SELECT    'В документі "Свідоцтво про народження" не заповнено дату народження особи '
                        || App_Name    AS Err_Doc
                   FROM Person
                  WHERE     Api$validation.Get_Doc_Count (App_Id, 37) > 0
                        AND Api$validation.Get_Doc_Dt (App_Id, 37, 91)
                                IS NULL
                 UNION ALL
                 -- #81892  20221201
                 SELECT CASE
                            WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                   10052) =
                                     0
                                 AND Api$validation.Get_Doc_String (App_Id,
                                                                    10098,
                                                                    2262,
                                                                    '-') =
                                     '664'
                                 AND Api$validation.Get_Doc_String (App_Id,
                                                                    605,
                                                                    813,
                                                                    '-') IN
                                         ('Z', 'B')
                            THEN
                                   'До звернення для учасника звернення з типом "Одержувач допомоги" '
                                || App_Name
                                || ' необхідно долучити документ "Довідка про взяття на облік внутрішньо переміщеної особи"'
                            ELSE
                                NULL
                        END    AS Err_Doc
                   FROM Person
                 UNION ALL
                 -- #104926  2024/07/02
                 SELECT    'У зверненні дата подання заяви '
                        || TO_CHAR (g_Ap_Reg_Dt, 'dd.mm.yyyy')
                        || ' не дорівнює '
                        || TO_CHAR (
                               Api$validation.Get_Doc_Dt (App_Id,
                                                          10098,
                                                          2254),
                               'dd.mm.yyyy')
                        || ' "Заява про зміни складу сім''ї"'    AS Err_Doc
                   FROM Person
                  WHERE     App_Tp = 'O'
                        AND Api$validation.Get_Doc_Dt (App_Id, 10098, 2254) !=
                            TRUNC (g_Ap_Reg_Dt, 'DD'))
        SELECT LISTAGG (Err_Doc, CHR (13) || CHR (10)               /*||', '*/
                                                     )
                   WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    /*
      Якщо в зверненні з Ід=643 "Зміна складу сім'ї " дата подання заяви не дорівнює даті в атрибуті з
       Ід=2254 ("Дата подання заяви") документу з Ід=10098 ("Заява про зміни складу сім'ї "),
       то це помилка текст помилки:
       "У зверненні дата подання заяви <Дата подання заяви> не дорівнює <Дата подання заяви із документу з ІД=10098> "Заява про зміни складу сім'ї "
    */
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check645 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        /*
        2239 Дата подання заяви DATE
        2240 Вид допомоги STRING v_ndi_service_type_cpd
        2241 Причина припинення виплати STRING
         */
        SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (SELECT 'Не відповідність дати подання заяви у картці звернення та в документі "Заява отримувача допомоги про припинення виплати допомоги"'    AS x_Errors_List
                  FROM Appeal Ap
                 WHERE     Ap.Ap_Id = g_Ap_Id
                       AND TRUNC (
                               NVL (
                                   Api$validation.Get_Ap_Doc_Dt (Ap.Ap_Id,
                                                                 10093,
                                                                 2239),
                                   TO_DATE ('3000', 'yyyy'))) !=
                           TRUNC (Ap.Ap_Reg_Dt)
                UNION ALL
                SELECT 'В документі "Заява отримувача допомоги про припинення виплати допомог" не заповнено вид допомоги'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'O'
                       AND App.History_Status = 'A'
                       AND Api$validation.Get_Doc_String (App.App_Id,
                                                          10093,
                                                          2240,
                                                          '-') = '-'
                UNION ALL
                SELECT 'В документі "Заява отримувача допомоги про припинення виплати допомог" не заповнено причину припинення виплати допомоги'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'O'
                       AND App.History_Status = 'A'
                       AND LENGTH (
                               Api$validation.Get_Doc_String (App.App_Id,
                                                              10093,
                                                              2241)) <
                           6)
         WHERE x_Errors_List IS NOT NULL;
    END;

    --==============================================================--
    --
    --==============================================================--
    PROCEDURE Check664 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        WITH
            Person
            AS
                (SELECT App.App_Ap,
                        App.App_Id,
                        App.App_Sc,
                        App.App_Tp,
                        Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)    AS App_Name
                   FROM Ap_Person App
                  WHERE     App.App_Ap = g_Ap_Id
                        AND App.App_Tp IN ('Z', 'FP')
                        AND App.History_Status = 'A'),
            Anketa
            AS
                (SELECT App.App_Ap,
                        App.App_Id,
                        App.App_Sc,
                        App.App_Tp,
                        Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                            AS App_Name,
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1775)
                            AS Rsd_Katog,
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1781)
                            AS Chn_Katog
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 605
                               AND Apd.History_Status = 'A'
                  WHERE     App.App_Ap = g_Ap_Id
                        AND App.App_Tp IN ('Z', 'FP')
                        AND App.History_Status = 'A'),
            Check_Doc
            AS
                (SELECT    'В "Анкеті учасника звернення"  атрибут КАТОТТГ  не заповнено для '
                        || App_Name
                        || ' в Адресі  місця проживання, звідки перемістилася особа'    AS Err_Doc
                   FROM Anketa
                  WHERE Rsd_Katog IS NULL
                 UNION ALL
                 SELECT    'В "Анкеті учасника звернення"  атрибут КАТОТТГ  не заповнено для '
                        || App_Name
                        || ' в Адресі  місця проживання, куди перемістилася особа'    AS Err_Doc
                   FROM Anketa
                  WHERE Chn_Katog IS NULL
                 UNION ALL
                 SELECT CASE
                            WHEN     g_Ap_Reg_Dt BETWEEN TO_DATE (
                                                             '01.05.2022',
                                                             'dd.mm.yyyy')
                                                     AND TO_DATE (
                                                             '31.07.2023',
                                                             'dd.mm.yyyy')
                                 AND Api$validation.Get_ap_Doc_Count (
                                         g_Ap_Id,
                                         10250) =
                                     0
                            THEN
                                'До звернення щодо допомоги ВПО за період до 01.08.2023 не долучено документ "Підстава щодо призначення допомоги за попередній період"'
                            WHEN     g_Ap_Reg_Dt BETWEEN TO_DATE (
                                                             '01.05.2022',
                                                             'dd.mm.yyyy')
                                                     AND TO_DATE (
                                                             '31.07.2023',
                                                             'dd.mm.yyyy')
                                 AND Api$validation.Get_Ap_Doc_String (
                                         g_Ap_Id,
                                         10250,
                                         4360)
                                         IS NULL
                            THEN
                                'У зверненні за період до 01.08.2023 не зазначено піставу в атрибуті "Підстава"'
                        END    AS Err_Doc
                   FROM DUAL
                 /*
                       UNION ALL
                       SELECT CASE
                              WHEN g_Ap_Reg_Dt BETWEEN to_date('01.05.2023', 'dd.mm.yyyy') AND to_date('31.07.2023', 'dd.mm.yyyy')
                                AND Api$validation.Get_Ap_Doc_Scan(g_Ap_Id , 10250) = 0 THEN
                                   'До звернення за період до 01.08.2023 не долучено скан документу підстави щодо призначення допомоги за попередній період'
                              END  AS Err_Doc
                        FROM dual*/
                 /*           when
                 Необхідно додати нові контролі для звернень щодо послуги з ІД=664, які подаються за періоди до 31.07.2023 включно, а саме:
                 • Якщо «Дата подання заяви» за періоди між 01.05.2023 і 31.07.2023, то до звернення необхідно обов’язково долучати документ «Підстава щодо призначення допомоги за попередній період»,
                   інакше помилка з текстом «До звернення щодо допомоги ВПО за період до 01.08.2023 не долучено документ "Підстава щодо призначення допомоги за попередній період»
                 • У документ «Підстава щодо призначення допомоги за попередній період» обов’язково має бути прикріплений «скан», інакше помилка з текстом
                   «До звернення за період до 01.08.2023 не долучено скан документу підстави щодо призначення допомоги за попередній період»
                 • В документі «Підстава щодо призначення допомоги за попередній період» обов’язково має бути обраний пункт в атрибуті «Підстава...» ІД=4360,
                   інакше помилка з текстом «У зверненні за період до 01.08.2023 не зазначено піставу в атрибуті «Підстава»»*/

                 UNION ALL
                 ----Помилка Не заповнено дату народження в документі з ІД=8, 9, 13, 673 В документі <Назва документа> не заповнено дату народження особи <ПІБ>
                 SELECT    'В документі "'
                        || Ndt_Name_Short
                        || '" не заповнено дату народження особи '
                        || App_Name    AS Err_Doc
                   FROM Person
                        JOIN Ap_Document
                            ON     Apd_App = App_Id
                               AND Ap_Document.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        LEFT JOIN Ap_Document_Attr
                            ON     Apda_Apd = Apd_Id
                               AND Ap_Document_Attr.History_Status = 'A'
                  WHERE     (   (Apd_Ndt = 6 AND Apda_Nda = 606)
                             OR (Apd_Ndt = 7 AND Apda_Nda = 607)
                             OR (Apd_Ndt = 8 AND Apda_Nda = 2014)
                             OR (Apd_Ndt = 9 AND Apda_Nda = 2015)
                             OR (Apd_Ndt = 11 AND Apda_Nda = 2329)
                             OR (Apd_Ndt = 13 AND Apda_Nda = 2016)
                             OR (Apd_Ndt = 37 AND Apda_Nda = 91)
                             OR (Apd_Ndt = 673 AND Apda_Nda = 762))
                        AND Apda_Val_Dt IS NULL
                 UNION ALL
                 SELECT CASE
                            WHEN Api$validation.Get_val_Dt (Apd_Id, 352)
                                     IS NULL
                            THEN
                                'В документі "Виписка з акту огляду МСЕК" (ІД=201)не заповнено дату встановлення інвалідності'
                        END    AS Err_Doc
                   FROM Person
                        JOIN ap_document apd
                            ON     Apd_App = App_id
                               AND apd_ndt = 201
                               AND APD.History_Status = 'A'
                 UNION ALL
                 SELECT 'В документі "Виписка з акту огляду МСЕК" (ІД=201)не заповнено поле "встановлено на період по"'    AS Err_Doc
                   FROM Person
                  WHERE     Api$validation.Get_Doc_Count (App_Id, 201) > 0
                        AND Api$validation.Get_Doc_Dt (App_Id, 201, 347)
                                IS NULL
                 UNION ALL
                 SELECT 'Відсутній документі "Документ - підтвердження факту пошкодження/знищення нерухомого майна військовою агресією Російської Федерації"'    AS Err_Doc
                   FROM Person
                  WHERE     App_Tp = 'Z'
                        AND Api$validation.Get_Doc_String (App_Id,
                                                           605,
                                                           2101,
                                                           'F') = 'T'
                        AND Api$validation.Get_Doc_Count (App_Id, 10090) = 0
                 UNION ALL
                 SELECT Api$validation.Check_Documents_Filled (
                            App_Id,
                            10090,
                            '2089,2092,2097,2100',
                            0)    AS Err_Doc
                   FROM Person
                  WHERE App_Tp = 'Z'
                 UNION ALL
                 -- #81892  20221201
                 SELECT CASE Api$validation.Get_Doc_Count (App_Id, 10052)
                            WHEN 0
                            THEN
                                   'До звернення для учасника звернення з типом "Одержувач допомоги" '
                                || App_Name
                                || ' необхідно долучити документ "Довідка про взяття на облік внутрішньо переміщеної особи"'
                            ELSE
                                NULL
                        END    AS Err_Doc
                   FROM Person
                  WHERE app_tp IN ('Z', 'FP')
                 UNION ALL
                 SELECT CASE
                            WHEN     Api$validation.Get_Val_String (Apd_Id,
                                                                    7412,
                                                                    'F') =
                                     'T'
                                 AND g_Ap_Reg_Dt <
                                     TO_DATE ('01.02.2024', 'dd.mm.yyyy')
                            THEN
                                   '"Встановлювати "Так" в атрибуті "Звернення надано для подовження допомоги ВПО з 01.03.2024" '
                                || 'дозволено тільки для звернень за допомогою ВПО починаючи з 1 лютого 2024 року"'
                            WHEN     Api$validation.Get_Val_String (Apd_Id,
                                                                    7412,
                                                                    'F') =
                                     'T'
                                 AND SYSDATE <
                                     TO_DATE ('01.03.2024', 'dd.mm.yyyy')
                            THEN
                                'Звернення, які подаються згідно абз.3 п.1 Постанови КМУ від 26.01.2024 № 94, можна опрацьовувати починаючи з березня 2024 року'
                        END    AS Err_Doc
                   FROM Person
                        JOIN ap_document apd
                            ON     Apd_App = App_id
                               AND apd_ndt = 10045
                               AND APD.History_Status = 'A'/*
                                                                 UNION ALL
                                                                 SELECT Api$validation.Check_Documents_Filled(App_Id, 10052, '', 1) AS Err_Doc
                                                                   FROM Person
                                                                  WHERE (App_Tp = 'Z' AND Api$validation.Get_Doc_String(App_Id, 605, 649) = 'Z')
                                                                        OR (App_Tp = 'FP' AND Api$validation.Get_Doc_String(App_Id, 605, 649) = 'B')*/
                                                           )
        SELECT LISTAGG (Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;

        IF     g_Ap_Reg_Dt BETWEEN TO_DATE ('01.05.2022', 'dd.mm.yyyy')
                               AND TO_DATE ('31.07.2023', 'dd.mm.yyyy')
           AND Api$validation.Get_Ap_Doc_Scan (g_Ap_Id, 10250) = 0
        THEN
            IF Err_List IS NULL
            THEN
                Err_List :=
                    'До звернення за період до 01.08.2023 не долучено скан документу підстави щодо призначення допомоги за попередній період';
            ELSE
                Err_List :=
                       Err_List
                    || ', До звернення за період до 01.08.2023 не долучено скан документу підстави щодо призначення допомоги за попередній період';
            END IF;
        END IF;
    END;

    PROCEDURE Check664 (Wrn_List OUT VARCHAR2)
    IS
    BEGIN
        WITH
            Anketa
            AS
                (SELECT App.App_Ap,
                        App.App_Id,
                        App.App_Sc,
                        App.App_Tp,
                        Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                            AS App_Name,
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1777)
                            AS Rsd_Strit_Id,
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1785)
                            AS Rsd_Strit,
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1778)
                            AS Rsd_House,
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1776)
                            AS Rsd_Index,
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1783)
                            AS Chn_Strit_Id,
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1786)
                            AS Chn_Strit,
                        (SELECT Apda_Val_String
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1784)
                            AS Chn_House,
                        (SELECT Apda_Val_Id
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd.Apd_Id
                                AND a.History_Status = 'A'
                                AND Apda_Nda = 1782)
                            AS Chn_Index
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 605
                               AND Apd.History_Status = 'A'
                  WHERE     App.App_Ap = g_Ap_Id
                        AND App.App_Tp IN ('Z', 'FP')
                        AND App.History_Status = 'A'),
            Person
            AS
                (SELECT App.App_Ap,
                        App.App_Id,
                        App.App_Sc,
                        App.App_Tp,
                        Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)    AS App_Name
                   FROM Ap_Person App
                  WHERE     App.App_Ap = g_Ap_Id
                        AND App.App_Tp IN ('Z', 'FP')
                        AND App.History_Status = 'A'),
            Check_Doc
            AS
                (SELECT    'В "Анкеті учасника звернення"  атрибут "Вулиця" не заповнено для '
                        || App_Name
                        || ' в Адресі місця проживання, звідки перемістилася особа'    AS Err_Doc
                   FROM Anketa
                  WHERE Rsd_Strit_Id IS NULL AND Rsd_Strit IS NULL
                 UNION ALL
                 SELECT    'В "Анкеті учасника звернення"  атрибут "Будинок" не заповнено для '
                        || App_Name
                        || ' в Адресі місця проживання, звідки перемістилася особа'    AS Err_Doc
                   FROM Anketa
                  WHERE Rsd_House IS NULL
                 UNION ALL
                 SELECT    'В "Анкеті учасника звернення"  атрибут "Індекс"  не заповнено для '
                        || App_Name
                        || ' в Адресі  місця проживання, звідки перемістилася особа'    AS Err_Doc
                   FROM Anketa
                  WHERE Rsd_Index IS NULL
                 UNION ALL
                 SELECT    'В "Анкеті учасника звернення"  атрибут "Вулиця" не заповнено для '
                        || App_Name
                        || ' в Адресі місця проживання, куди перемістилася особа'    AS Err_Doc
                   FROM Anketa
                  WHERE Chn_Strit_Id IS NULL AND Chn_Strit IS NULL
                 UNION ALL
                 SELECT    'В "Анкеті учасника звернення"  атрибут "Будинок" не заповнено для '
                        || App_Name
                        || ' в Адресі місця проживання, куди перемістилася особа'    AS Err_Doc
                   FROM Anketa
                  WHERE Chn_House IS NULL
                 UNION ALL
                 SELECT    'В "Анкеті учасника звернення"  атрибут "Індекс"  не заповнено для '
                        || App_Name
                        || ' в Адресі  місця проживання, куди перемістилася особа'    AS Err_Doc
                   FROM Anketa
                  WHERE Chn_Index IS NULL
                 UNION ALL
                 SELECT DISTINCT
                           'В документі "'
                        || Ndt_Name_Short
                        || '" для особи '
                        || App_Name
                        || ' не заповнено атрибути: Група інвалідності, Причина інвалідності'    AS Err_Doc
                   FROM Person
                        JOIN Ap_Document
                            ON     Apd_App = App_Id
                               AND Ap_Document.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        LEFT JOIN Ap_Document_Attr
                            ON     Apda_Apd = Apd_Id
                               AND Ap_Document_Attr.History_Status = 'A'
                  WHERE     Apd_Ndt = 601
                        AND Apda_Nda IN (1125, 1126)
                        AND Apda_Val_String IS NULL)
        SELECT LISTAGG (Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Wrn_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    END;

    --==============================================================--
    --
    --==============================================================--
    PROCEDURE Check701 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        WITH
            Doc
            AS
                (SELECT Apd_Ap,
                        (SELECT SUM (
                                    CASE NVL (Apda_Val_String, 'F')
                                        WHEN 'T' THEN 1
                                        ELSE 0
                                    END)
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd_Id
                                AND Apda_Nda IN (1714, 1715)
                                AND a.History_Status = 'A')    Cnt1,
                        (SELECT SUM (
                                    CASE NVL (Apda_Val_String, 'F')
                                        WHEN 'T' THEN 1
                                        ELSE 0
                                    END)
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd_Id
                                AND Apda_Nda IN (1718, 1719, 1720)
                                AND a.History_Status = 'A')    Cnt2,
                        (SELECT SUM (
                                    CASE NVL (Apda_Val_String, 'F')
                                        WHEN 'T' THEN 1
                                        ELSE 0
                                    END)
                           FROM Ap_Document_Attr a
                          WHERE     Apda_Apd = Apd_Id
                                AND Apda_Nda IN (1729, 1730, 1731)
                                AND a.History_Status = 'A')    Cnt3
                   FROM Ap_Document
                  WHERE     Apd_Ndt = 740
                        AND Apd_Ap = g_Ap_Id --IN (SELECT aps_ap FROM ap_service WHERE aps_nst = 701)
                        AND Ap_Document.History_Status = 'A'),
            Address
            AS
                (SELECT App.App_Id,
                        App.App_Sc,
                        App.App_Tp,
                        Api$validation.Get_Val_String (Apd_Id, 1733)
                            AS Oblast,
                        Api$validation.Get_Val_String (Apd_Id, 1734)
                            AS Oblast_District,
                        Api$validation.Get_Val_String (Apd_Id, 1735)
                            AS City,
                        Api$validation.Get_Val_String (Apd_Id, 1736)
                            AS City_District,
                        Api$validation.Get_Val_String (Apd_Id, 1737)
                            AS Village_Urban,
                        Api$validation.Get_Val_String (Apd_Id, 1738)
                            AS Village1,
                        Api$validation.Get_Val_String (Apd_Id, 1739)
                            AS Village2,
                        Api$validation.Get_Val_String (Apd_Id, 1740)
                            AS Street_Manual,
                        Api$validation.Get_Val_Id (Apd_Id, 2161)
                            AS Street,
                        Api$validation.Get_Val_String (Apd_Id, 1741)
                            AS House,
                        Api$validation.Get_Val_String (Apd_Id, 1742)
                            AS Corps,
                        Api$validation.Get_Val_String (Apd_Id, 1743)
                            AS Premises_Type,
                        Api$validation.Get_Val_Int (Apd_Id, 1744)
                            AS Premises_Number,
                        Api$validation.Get_Val_Id (Apd_Id, 1745)
                            AS Postal_Code
                   FROM Ap_Person  App
                        JOIN Ap_Document Apd
                            ON     Apd.Apd_App = App.App_Id
                               AND Apd.Apd_Ndt = 740
                               AND Apd.History_Status = 'A'
                  WHERE     App.App_Ap = g_Ap_Id
                        AND App.History_Status = 'A'
                        AND Api$validation.Get_Val_String (Apd_Id, 1731, 'F') =
                            'T')
        --Блок "Тип витягу":
        --1. Пошук станом на дату формування звіту – nda_id=1714
        --2. Пошук станом на визначені дату і час – nda_id=1715
        --Блок "Критерії пошуку відомостей":
        --5. Юридична особа – nda_id=1718
        --6. Фізична особа – nda_id=1719
        --7. Орган державної влади – nda_id=1720
        --Блок "Відомості про спосіб видачі витягу":
        --16. надати запитувачу (якщо запит подано в електронній формі) на електронну адресу – nda_id=1729
        --17. видати запитувачу (якщо запит подано у паперовій формі) – nda_id=1730
        --18. надіслати поштовим відправленням (якщо запит подано у паперовій формі) – nda_id=1731
        SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (--4.exists
                SELECT    'Check701[1]: Для документа "Витяг з Реєстру надавачів та отримувачів соціальних послуг (Додаток 7)" Блок "Тип витягу" '
                       || (CASE Doc.Cnt1
                               WHEN 0 THEN 'не обран жодний з варіантів.'
                               ELSE 'обрано більше одного варіанта'
                           END)    AS x_Errors_List
                  FROM Doc
                 WHERE Doc.Cnt1 != 1
                UNION ALL
                SELECT    'Check701[2]: Для документа "Витяг з Реєстру надавачів та отримувачів соціальних послуг (Додаток 7)" Блок "Критерії пошуку відомостей" '
                       || (CASE Doc.Cnt2
                               WHEN 0 THEN 'не обран жодний з варіантів.'
                               ELSE 'обрано більше одного варіанта'
                           END)    AS x_Errors_List
                  FROM Doc
                 WHERE Doc.Cnt2 != 1
                UNION ALL
                SELECT    'Check701[3]: Для документа "Витяг з Реєстру надавачів та отримувачів соціальних послуг (Додаток 7)" Блок "Відомості про спосіб видачі витягу" '
                       || (CASE Doc.Cnt2
                               WHEN 0 THEN 'не обран жодний з варіантів.'
                               ELSE 'обрано більше одного варіанта'
                           END)    AS x_Errors_List
                  FROM Doc
                 WHERE Doc.Cnt2 != 1
                UNION ALL
                SELECT 'Check701[4]: Для створення «Витягу (Додаток 7)» потрібно додати документ та вказати параметри для його формування'    AS x_Errors_List
                  FROM DUAL
                 WHERE NOT EXISTS (SELECT 1 FROM doc)
                UNION ALL
                SELECT 'Check701[5]: У заявника повинен бути присутнім один з документів – або "Паспорт громадянина України", або "ID картка"'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND (  Api$validation.Get_Doc_Count (App_Id, 6)
                            + Api$validation.Get_Doc_Count (App_Id, 7)
                            + Api$validation.Get_Doc_Count (App_Id, 8)) =
                           0
                       AND g_Ap_Src != 'PORTAL'
                UNION ALL
                SELECT 'Check701[6]: Формат номера "Паспорт громадянина України": дві великі літери та шість цифр'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       --AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND Api$validation.Get_Doc_Count (App_Id, 6) = 1
                       AND NVL (
                               REGEXP_INSTR (
                                   Api$validation.Get_Doc_String (App_Id,
                                                                  6,
                                                                  3),
                                   '^[А-Я]{2}[0-9]{6}$',
                                   1),
                               0) =
                           0
                UNION ALL
                SELECT 'Check701[7]: Формат номера "ID картка": дев''ять цифр'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       --AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND Api$validation.Get_Doc_Count (App_Id, 7) = 1
                       AND NVL (
                               REGEXP_INSTR (
                                   Api$validation.Get_Doc_String (App_Id,
                                                                  7,
                                                                  9),
                                   '^[0-9]{9}$',
                                   1),
                               0) =
                           0
                UNION ALL
                SELECT CASE
                           WHEN     Api$validation.Get_Doc_String (App_Id,
                                                                   740,
                                                                   1715,
                                                                   'F') = 'T'
                                AND Api$validation.Get_Doc_Dt (App_Id,
                                                               740,
                                                               1717)
                                        IS NULL
                           THEN
                               'Check701[7]: Обрано пошук станом на визначені дату і час, але їх не було встановлено'
                           ELSE
                               ''
                       END    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                UNION ALL
                SELECT 'Check701[8]: Встановлено вид відправки заявнику електронною поштою, але її адресу не вказано'    AS x_Errors_List
                  FROM Ap_Person App
                 WHERE     App.App_Ap = g_Ap_Id
                       AND App.App_Tp = 'Z'
                       AND App.History_Status = 'A'
                       AND Api$validation.Get_Doc_String (App_Id,
                                                          740,
                                                          1729,
                                                          'F') = 'T'
                       AND Api$validation.Get_Doc_String (App_Id, 740, 1732)
                               IS NULL
                UNION ALL
                SELECT 'Check701[9]: Встановлено вид відправки поштою, але поштову адресу не вказано'    AS x_Errors_List
                  FROM Address
                 WHERE    City || Village_Urban || Village1 || Village2
                              IS NULL
                       OR (    City IS NOT NULL
                           AND Village_Urban || Village1 || Village2
                                   IS NOT NULL)
                       OR (    Village_Urban IS NOT NULL
                           AND Village1 || Village2 IS NOT NULL)
                       OR (Village1 IS NOT NULL AND Village2 IS NOT NULL)
                       OR (Street_Manual IS NULL AND Street IS NULL)
                       OR (Street_Manual IS NOT NULL AND Street IS NOT NULL)
                       OR (    House IS NULL
                           AND Corps IS NULL
                           AND Premises_Number IS NULL))
         WHERE x_Errors_List IS NOT NULL;
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check761 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        SELECT LISTAGG (x_Errors_List, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM (WITH
                    Address
                    AS
                        (SELECT App.App_Id,
                                App.App_Sc,
                                App.App_Tp,
                                Api$validation.Get_Val_String (Apd_Id, 2176)
                                    AS Oblast,
                                Api$validation.Get_Val_String (Apd_Id, 2177)
                                    AS Oblast_District,
                                Api$validation.Get_Val_String (Apd_Id, 2178)
                                    AS City,
                                Api$validation.Get_Val_String (Apd_Id, 2179)
                                    AS City_District,
                                Api$validation.Get_Val_String (Apd_Id, 2180)
                                    AS Village_Urban,
                                Api$validation.Get_Val_String (Apd_Id, 2181)
                                    AS Village1,
                                Api$validation.Get_Val_String (Apd_Id, 2182)
                                    AS Village2,
                                Api$validation.Get_Val_String (Apd_Id, 2183)
                                    AS Street_Manual,
                                Api$validation.Get_Val_Id (Apd_Id, 2184)
                                    AS Street,
                                Api$validation.Get_Val_String (Apd_Id, 2185)
                                    AS House,
                                Api$validation.Get_Val_String (Apd_Id, 2186)
                                    AS Corps,
                                Api$validation.Get_Val_String (Apd_Id, 2187)
                                    AS Premises_Type,
                                Api$validation.Get_Val_Int (Apd_Id, 2188)
                                    AS Premises_Number,
                                Api$validation.Get_Val_Id (Apd_Id, 2189)
                                    AS Postal_Code
                           FROM Ap_Person  App
                                JOIN Ap_Document Apd
                                    ON     Apd.Apd_App = App.App_Id
                                       AND Apd.Apd_Ndt = 741
                                       AND Apd.History_Status = 'A'
                          WHERE     App.App_Ap = g_Ap_Id
                                AND App.History_Status = 'A'
                                AND Api$validation.Get_Val_String (Apd_Id,
                                                                   2174,
                                                                   'F') =
                                    'T')
                    SELECT 'Check761[1]: У заявника повинен бути присутнім один з документів – або "Паспорт громадянина України", або "ID картка"'    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Tp = 'Z'
                           AND App.History_Status = 'A'
                           AND (  Api$validation.Get_Doc_Count (App_Id, 6)
                                + Api$validation.Get_Doc_Count (App_Id, 7)
                                + Api$validation.Get_Doc_Count (App_Id, 8)) =
                               0
                           AND g_Ap_Src != 'PORTAL'
                    UNION ALL
                    SELECT 'Check761[2]: Формат номера "Паспорт громадянина України": дві великі літери та шість цифр'    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           --AND App.App_Tp = 'Z'
                           AND App.History_Status = 'A'
                           AND Api$validation.Get_Doc_Count (App_Id, 6) = 1
                           AND NVL (
                                   REGEXP_INSTR (
                                       Api$validation.Get_Doc_String (App_Id,
                                                                      6,
                                                                      3),
                                       '^[А-Я]{2}[0-9]{6}$',
                                       1),
                                   0) =
                               0
                    UNION ALL
                    SELECT 'Check761[3]: Формат номера "ID картка": дев''ять цифр'    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           --AND App.App_Tp = 'Z'
                           AND App.History_Status = 'A'
                           AND Api$validation.Get_Doc_Count (App_Id, 7) = 1
                           AND NVL (
                                   REGEXP_INSTR (
                                       Api$validation.Get_Doc_String (App_Id,
                                                                      7,
                                                                      9),
                                       '^[0-9]{9}$',
                                       1),
                                   0) =
                               0
                    UNION ALL
                    SELECT CASE
                               WHEN     Api$validation.Get_Doc_String (
                                            App_Id,
                                            741,
                                            2163,
                                            'F') = 'T'
                                    AND Api$validation.Get_Doc_Dt (App_Id,
                                                                   741,
                                                                   2164)
                                            IS NULL
                               THEN
                                   'Check761[4]: Обрано пошук станом на визначені дату і час, але їх не було встановлено'
                               ELSE
                                   ''
                           END    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Tp = 'Z'
                           AND App.History_Status = 'A'
                    UNION ALL
                    SELECT 'Check761[5]: Встановлено вид відправки заявнику електронною поштою, але її адресу не вказано'    AS x_Errors_List
                      FROM Ap_Person App
                     WHERE     App.App_Ap = g_Ap_Id
                           AND App.App_Tp = 'Z'
                           AND App.History_Status = 'A'
                           AND Api$validation.Get_Doc_String (App_Id,
                                                              741,
                                                              2172,
                                                              'F') = 'T'
                           AND Api$validation.Get_Doc_String (App_Id,
                                                              741,
                                                              2175)
                                   IS NULL
                    UNION ALL
                    SELECT 'Check761[6]: Встановлено вид відправки поштою, але поштову адресу не вказано'    AS x_Errors_List
                      FROM Address
                     WHERE    City || Village_Urban || Village1 || Village2
                                  IS NULL
                           OR (    City IS NOT NULL
                               AND Village_Urban || Village1 || Village2
                                       IS NOT NULL)
                           OR (    Village_Urban IS NOT NULL
                               AND Village1 || Village2 IS NOT NULL)
                           OR (Village1 IS NOT NULL AND Village2 IS NOT NULL)
                           OR (Street_Manual IS NULL AND Street IS NULL)
                           OR (    Street_Manual IS NOT NULL
                               AND Street IS NOT NULL)
                           OR (    House IS NULL
                               AND Corps IS NULL
                               AND Premises_Number IS NULL))
         WHERE x_Errors_List IS NOT NULL
        UNION ALL
        SELECT 'Check761[7]: Для створення «Витягу (Додаток 8)» потрібно додати документ та вказати параметри для його формування'    AS x_Errors_List
          FROM DUAL
         WHERE NOT EXISTS
                   (SELECT 1
                      FROM Ap_Document Apd
                     WHERE     Apd.Apd_Ap = g_Ap_Id
                           AND Apd.History_Status = 'A'
                           AND Apd.Apd_Ndt = 741);
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--

    /*
    Якщо в документі з Ід=10099 "Повідомлення про наявність інвалідності" в атрибуті Ід=2260 "Вид допомоги" користувач зазначив "Допомога ВПО" (послуга з Ід=664),
    то для особи з типом "Одержувач допомоги" вимагати "довідку ВПО" - документ з Ід= 10052 (Довідка про взяття на облік внутрішньо переміщеної особи),
    якщо документ з Ід= 10052 не додано, то видавати повідомлення "Необхідно додати документ "Довідка про взяття на облік внутрішньо переміщеної особи" для особи <ПІБ>, бо документі "Повідомлення про наявність інвалідності" зазначено, що інформація про інвалідність додається для перерахунку по Допомозі ВПО"*/
    PROCEDURE Check801 (Err_List OUT VARCHAR2)
    IS
    --Додати верифікацію довідки ВПО для Заявника і Утриманців, та Свідоцтва про народження, якщо в Утриманця наявне свідоцтво про народження.
    BEGIN
        WITH
            Person
            AS
                (SELECT App.App_Ap,
                        App.App_Id,
                        App.App_Sc,
                        App.App_Tp,
                        Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)    AS App_Name
                   FROM Ap_Person App
                  WHERE     App.App_Ap = g_Ap_Id
                        AND App.App_Tp IN ('O', 'FP')
                        AND App.History_Status = 'A'),
            Check_Doc
            AS
                (                                 -- #81892  20221201 + #88041
                 SELECT CASE
                            WHEN     Api$validation.Get_Doc_Count (App_Id,
                                                                   10052) =
                                     0
                                 AND Api$validation.Get_Doc_String (App_Id,
                                                                    10099,
                                                                    2260,
                                                                    '-') =
                                     '664'
                            THEN
                                   --'До звернення для учасника звернення з типом "Одержувач допомоги" '||App_Name||
                                   --' необхідно долучити документ "Довідка про взяття на облік внутрішньо переміщеної особи"'
                                   'Необхідно додати документ "Довідка про взяття на облік внутрішньо переміщеної особи" для особи '
                                || App_Name
                                || ', бо документі "Повідомлення про наявність інвалідності" зазначено, що інформація про інвалідність додається для перерахунку по Допомозі ВПО"'
                            ELSE
                                NULL
                        END    AS Err_Doc
                   FROM Person
                  WHERE app_tp = 'O')
        SELECT LISTAGG (Err_Doc, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    END;

    --==============================================================--
    --  Перевірка наявності документів
    --==============================================================--
    PROCEDURE Check1141 (Err_List OUT VARCHAR2)
    IS
    BEGIN
        WITH
            Check_Doc
            AS
                (SELECT    'Сканкопія документа "'
                        || ndt.ndt_name_short
                        || '" не підписана ЕЦП. '
                        || 'Скористайтесь функцією "Сканування з ЕЦП"'    AS Err_Doc
                   --d.apd_id, d.Apd_Ndt, a.Dat_Sign_File
                   FROM Ap_Document  d
                        JOIN Uss_ndi.v_Ndi_Document_Type ndt
                            ON ndt.ndt_id = d.apd_ndt
                  WHERE     d.Apd_Ap = g_Ap_Id
                        AND d.History_Status = 'A'
                        AND d.Apd_Ndt = 10305
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM Uss_Doc.v_Doc_Attachments a
                                  WHERE     d.Apd_Dh = a.Dat_Dh
                                        AND a.Dat_Sign_File IS NOT NULL))
        SELECT LISTAGG (Err_Doc, CHR (13) || CHR (10))
                   WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Check_Doc
         WHERE Err_Doc IS NOT NULL;
    END;

    --==============================================================--
    PROCEDURE Check_Attr_Date
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            DT
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                        Ndt_Name_Short           AS Ndt_Name,
                        nda_name                 AS nda_name,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)    Pib
                   FROM Ap_Document  d
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        JOIN Uss_Ndi.v_Ndi_Document_Attr ON Nda_ndt = Ndt_id
                        LEFT JOIN Ap_Document_Attr apda
                            ON     apda.apda_apd = d.apd_id
                               AND apda.apda_nda = Nda_Id
                               AND apda.history_status = 'A'
                  WHERE     d.Apd_ap = g_Ap_Id
                        AND d.history_status = 'A'
                        AND apda.apda_val_dt IS NOT NULL
                        AND apda.apda_val_dt > SYSDATE
                        AND (   (ndt_id = 6 AND nda_id IN (5))
                             OR (ndt_id = 7 AND nda_id IN (14))
                             OR (ndt_id = 201 AND nda_id IN (348, 352, 350))
                             OR (ndt_id = 700 AND nda_id IN (2562))
                             OR (ndt_id = 708 AND nda_id IN (1138))
                             OR (ndt_id = 710 AND nda_id IN (1142))
                             OR (ndt_id = 713 AND nda_id IN (1145))
                             OR (ndt_id = 714 AND nda_id IN (1148))
                             OR (ndt_id = 715 AND nda_id IN (1140))
                             OR (ndt_id = 717 AND nda_id IN (1151))
                             OR (ndt_id = 718 AND nda_id IN (1154))
                             OR (ndt_id = 719 AND nda_id IN (1156))
                             OR (ndt_id = 720 AND nda_id IN (1164))
                             OR (ndt_id = 721 AND nda_id IN (1158))
                             OR (ndt_id = 722 AND nda_id IN (1166))
                             OR (ndt_id = 723 AND nda_id IN (1160))
                             OR (ndt_id = 724 AND nda_id IN (1162))
                             OR (ndt_id = 725 AND nda_id IN (1184))
                             OR (ndt_id = 726 AND nda_id IN (2290))
                             OR (ndt_id = 740 AND nda_id IN (1717))
                             OR (ndt_id = 741 AND nda_id IN (2164))
                             OR (    ndt_id = 809
                                 AND nda_id IN (1939, 1805, 1808))
                             OR (ndt_id = 801 AND nda_id IN (1899))
                             OR (ndt_id = 802 AND nda_id IN (1980))
                             OR (ndt_id = 802 AND nda_id IN (1949))
                             OR (    ndt_id = 803
                                 AND nda_id IN (2081, 2078, 2079))
                             OR (    ndt_id = 804
                                 AND nda_id IN (1901, 1906, 1907))
                             OR (ndt_id = 805 AND nda_id IN (1841, 1843))
                             OR (ndt_id = 806 AND nda_id IN (1845, 1827))
                             OR (ndt_id = 807 AND nda_id IN (1849, 1828))
                             OR (ndt_id = 808 AND nda_id IN (1853, 1863))
                             OR (ndt_id = 810 AND nda_id IN (1818))
                             OR (ndt_id = 811 AND nda_id IN (1813, 1817))
                             OR (ndt_id = 812 AND nda_id IN (1821, 1822))
                             OR (ndt_id = 813 AND nda_id IN (1826))
                             OR (ndt_id = 815 AND nda_id IN (1834))
                             OR (ndt_id = 816 AND nda_id IN (1865))
                             OR (ndt_id = 817 AND nda_id IN (1831))
                             OR (ndt_id = 831 AND nda_id IN (2624))--OR (ndt_id = 836 and nda_id in (1899))
                                                                   )),
            Chk
            AS
                (SELECT    'Для особи '
                        || Pib
                        || ' в документі "'
                        || Ndt_Name
                        || '" в атрибуті "'
                        || nda_name
                        || '" встановлено дату, більшу за поточну.'    AS Err_Text
                   FROM DT)
        SELECT LISTAGG (Err_Text, ', ' ON OVERFLOW TRUNCATE '...')
                   WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk
         WHERE Err_Text IS NOT NULL;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    FUNCTION com_fn (p_dt1 DATE, p_dt2 DATE, p_op NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        IF (p_op = 0 AND p_dt1 < p_dt2)
        THEN
            RETURN 2;
        ELSIF (p_op = 1 AND p_dt1 <= p_dt2)
        THEN
            RETURN 2;
        ELSIF (p_op = 2 AND p_dt1 > p_dt2)
        THEN
            RETURN 0;
        ELSE
            RETURN 1;
        END IF;
    END;

    PROCEDURE Check_Attr_Dates
    IS
    BEGIN
        FOR xx
            IN (-- 0 - менше
                -- 1 - менше =
                -- 2 - більше
                WITH
                    data
                    AS
                        (SELECT 6       x_ndt,
                                5       x_nda1,
                                606     x_nda2,
                                2       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 7       x_ndt,
                                14      x_nda1,
                                607     x_nda2,
                                2       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10197     x_ndt,
                                2600      x_nda1,
                                -1        x_nda2,
                                1         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 92      x_ndt,
                                230     x_nda1,
                                -1      x_nda2,
                                1       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 7      x_ndt,
                                14     x_nda1,
                                -1     x_nda2,
                                1      x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 18     x_ndt,
                                59     x_nda1,
                                -1     x_nda2,
                                1      x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10198     x_ndt,
                                4362      x_nda1,
                                4363      x_nda2,
                                0         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10198     x_ndt,
                                2606      x_nda1,
                                -1        x_nda2,
                                1         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 98      x_ndt,
                                249     x_nda1,
                                -1      x_nda2,
                                1       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 98      x_ndt,
                                687     x_nda1,
                                688     x_nda2,
                                0       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 507     x_ndt,
                                799     x_nda1,
                                -1      x_nda2,
                                1       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10108     x_ndt,
                                2274      x_nda1,
                                -1        x_nda2,
                                1         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10108     x_ndt,
                                2275      x_nda1,
                                2274      x_nda2,
                                2         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10203     x_ndt,
                                2640      x_nda1,
                                -1        x_nda2,
                                1         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10203     x_ndt,
                                2641      x_nda1,
                                -1        x_nda2,
                                2         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10107     x_ndt,
                                2282      x_nda1,
                                -1        x_nda2,
                                1         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10107     x_ndt,
                                2282      x_nda1,
                                2283      x_nda2,
                                0         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10107     x_ndt,
                                2287      x_nda1,
                                2288      x_nda2,
                                0         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 37     x_ndt,
                                94     x_nda1,
                                -1     x_nda2,
                                1      x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 37     x_ndt,
                                91     x_nda1,
                                94     x_nda2,
                                1      x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 200     x_ndt,
                                345     x_nda1,
                                -1      x_nda2,
                                1       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 200     x_ndt,
                                792     x_nda1,
                                793     x_nda2,
                                1       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 201     x_ndt,
                                348     x_nda1,
                                -1      x_nda2,
                                1       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 201     x_ndt,
                                352     x_nda1,
                                347     x_nda2,
                                0       x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 201      x_ndt,
                                1910     x_nda1,
                                347      x_nda2,
                                1        x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10135     x_ndt,
                                2511      x_nda1,
                                -1        x_nda2,
                                1         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10205     x_ndt,
                                2675      x_nda1,
                                -1        x_nda2,
                                0         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10206     x_ndt,
                                2670      x_nda1,
                                -1        x_nda2,
                                0         x_mode
                           FROM DUAL
                         UNION ALL
                         SELECT 10244     x_ndt,
                                4301      x_nda1,
                                4305      x_nda2,
                                2         x_mode
                           FROM DUAL),
                    DT
                    AS
                        (SELECT *
                           FROM (SELECT Ndt_Name_Short
                                            AS Ndt_Name,
                                        a1.nda_name
                                            AS nda_name_1,
                                        NVL (a2.nda_name,
                                             'Дата подання заяви')
                                            AS nda_name_2,
                                        pa1.apda_val_dt
                                            AS val_1,
                                        NVL (pa2.apda_val_dt,
                                             (g_Ap_Reg_Dt + 30))
                                            AS val_2,
                                        q.x_mode
                                            AS op,
                                           INITCAP (p.App_Ln)
                                        || ' '
                                        || INITCAP (p.App_Fn)
                                        || ' '
                                        || INITCAP (p.App_Mn)
                                            Pib
                                   FROM Ap_Document  d
                                        JOIN data q ON (q.x_ndt = d.apd_ndt)
                                        JOIN Ap_Person p
                                            ON     p.App_Id = d.Apd_App
                                               AND p.History_Status = 'A'
                                        JOIN Uss_Ndi.v_Ndi_Document_Type
                                            ON Ndt_Id = Apd_Ndt
                                        JOIN Uss_Ndi.v_Ndi_Document_Attr a1
                                            ON a1.Nda_id = q.x_nda1
                                        LEFT JOIN
                                        Uss_Ndi.v_Ndi_Document_Attr a2
                                            ON a2.Nda_id = q.x_nda2
                                        LEFT JOIN Ap_Document_Attr pa1
                                            ON     pa1.apda_apd = d.apd_id
                                               AND pa1.apda_nda = a1.Nda_Id
                                               AND pa1.history_status = 'A'
                                        LEFT JOIN Ap_Document_Attr pa2
                                            ON     pa2.apda_apd = d.apd_id
                                               AND pa2.apda_nda = a2.Nda_Id
                                               AND pa2.history_status = 'A'
                                  WHERE     d.Apd_ap = g_Ap_Id
                                        AND d.history_status = 'A')
                          WHERE     1 = 1
                                AND val_1 IS NOT NULL
                                AND val_2 IS NOT NULL
                                AND 1 = com_fn (val_1, val_2, op)),
                    Chk
                    AS
                        (SELECT    'Для особи '
                                || Pib
                                || ' в документі "'
                                || Ndt_Name
                                || '"  "'
                                || nda_name_1
                                || '" не відповідає '
                                || ' "'
                                || nda_name_2
                                || '"'    AS Err_Text
                           FROM DT)
                SELECT err_text
                  FROM Chk
                 WHERE Err_Text IS NOT NULL)
        LOOP
            Add_Warning (xx.err_text);
        END LOOP;
    END;

    PROCEDURE Check_Attr_Dates_Error
    IS
    BEGIN
        FOR xx
            IN (-- 0 - менше
                -- 1 - менше =
                -- 2 - більше
                WITH
                    data
                    AS
                        (SELECT 10244     x_ndt,
                                4301      x_nda1,
                                4305      x_nda2,
                                2         x_mode
                           FROM DUAL),
                    DT
                    AS
                        (SELECT *
                           FROM (SELECT Ndt_Name_Short
                                            AS Ndt_Name,
                                        a1.nda_name
                                            AS nda_name_1,
                                        NVL (a2.nda_name,
                                             'Дата подання заяви')
                                            AS nda_name_2,
                                        pa1.apda_val_dt
                                            AS val_1,
                                        NVL (pa2.apda_val_dt,
                                             (g_Ap_Reg_Dt + 30))
                                            AS val_2,
                                        q.x_mode
                                            AS op,
                                           INITCAP (p.App_Ln)
                                        || ' '
                                        || INITCAP (p.App_Fn)
                                        || ' '
                                        || INITCAP (p.App_Mn)
                                            Pib,
                                        DECODE (q.x_mode,
                                                2, 'більш рання за',
                                                'не відповідає')
                                            AS msg
                                   FROM Ap_Document  d
                                        JOIN data q ON (q.x_ndt = d.apd_ndt)
                                        JOIN Ap_Person p
                                            ON     p.App_Id = d.Apd_App
                                               AND p.History_Status = 'A'
                                        JOIN Uss_Ndi.v_Ndi_Document_Type
                                            ON Ndt_Id = Apd_Ndt
                                        JOIN Uss_Ndi.v_Ndi_Document_Attr a1
                                            ON a1.Nda_id = q.x_nda1
                                        LEFT JOIN
                                        Uss_Ndi.v_Ndi_Document_Attr a2
                                            ON a2.Nda_id = q.x_nda2
                                        LEFT JOIN Ap_Document_Attr pa1
                                            ON     pa1.apda_apd = d.apd_id
                                               AND pa1.apda_nda = a1.Nda_Id
                                               AND pa1.history_status = 'A'
                                        LEFT JOIN Ap_Document_Attr pa2
                                            ON     pa2.apda_apd = d.apd_id
                                               AND pa2.apda_nda = a2.Nda_Id
                                               AND pa2.history_status = 'A'
                                  WHERE     d.Apd_ap = g_Ap_Id
                                        AND d.history_status = 'A')
                          WHERE     1 = 1
                                AND val_1 IS NOT NULL
                                AND val_2 IS NOT NULL
                                AND 1 = com_fn (val_1, val_2, op)),
                    Chk
                    AS
                        (SELECT    'Для особи '
                                || Pib
                                || ' в документі "'
                                || Ndt_Name
                                || '"  "'
                                || nda_name_1
                                || '" '
                                || msg
                                || ' '
                                || ' "'
                                || nda_name_2
                                || '"'    AS Err_Text
                           FROM DT)
                SELECT err_text
                  FROM Chk
                 WHERE Err_Text IS NOT NULL)
        LOOP
            Add_Error (xx.err_text);
        END LOOP;
    END;

    --==============================================================--
    --  Перевірка #81176
    --==============================================================--
    PROCEDURE Check_Attr_1
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        --    Dbms_Output.Put_Line('Check_attr_91');
        WITH
            D5
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                        Ndt_Name_Short           AS Ndt_Name,
                        apda.apda_val_string     AS numident,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)    Pib
                   FROM Ap_Document  d
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        JOIN Uss_Ndi.v_Ndi_Document_Attr
                            ON Nda_ndt = Ndt_id AND nda_id = 1
                        LEFT JOIN Ap_Document_Attr apda
                            ON     apda.apda_apd = d.apd_id
                               AND apda.apda_nda = Nda_Id
                               AND apda.history_status = 'A'
                  WHERE     d.Apd_id = g_Apd_Id
                        AND d.apd_ndt = 5
                        AND d.history_status = 'A'),
            Chk
            AS
                (SELECT CASE
                            WHEN numident IS NULL
                            THEN
                                   --'перевірте заповнення РНОКПП в документі "Довідка про присвоєння РНОКПП", після перевірки заповнення атрибутів документа натисніть кнопку "Зберегти"'
                                   'Для особи '
                                || Pib
                                || ' перевірте заповнення РНОКПП в документі "Довідка про присвоєння РНОКПП"'
                                || CASE
                                       WHEN g_Ap_Src NOT IN ('CMES')
                                       THEN
                                           ', після перевірки заповнення атрибутів документа натисніть кнопку "Зберегти"'
                                   END
                            WHEN    REGEXP_INSTR (numident, '^\d{10}$') = 0
                                 OR numident IN ('1111111111',
                                                 '2222222222',
                                                 '3333333333',
                                                 '4444444444',
                                                 '5555555555',
                                                 '6666666666',
                                                 '7777777777',
                                                 '8888888888',
                                                 '9999999999',
                                                 '0000000000')
                            THEN
                                   --'перевірте заповнення РНОКПП в документі "Довідка про присвоєння РНОКПП", після перевірки заповнення атрибутів документа натисніть кнопку "Зберегти"'
                                   'Для особи '
                                || Pib
                                || ' в документі "Довідка про присвоєння РНОКПП" невірний формат номеру РНОКПП'
                        END    AS Err_Text
                   FROM D5)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk
         WHERE Err_Text IS NOT NULL;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    PROCEDURE Check_Attr_3
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        --    Dbms_Output.Put_Line('Check_attr_3');
        WITH
            D5
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)    Pib,
                        ndt_name_short
                   FROM Ap_Document  d
                        JOIN Ap_Document_Attr apda
                            ON     apda.apda_apd = d.apd_id
                               AND apda.apda_nda = 3
                               AND apda.history_status = 'A'
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                  WHERE     d.Apd_Id = g_Apd_Id
                        AND d.history_status = 'A'
                        --AND Nvl(Regexp_Instr(apda.apda_val_string, '^[А-Я]{2}[0-9]{6}$', 1), 0) = 0
                        AND NVL (
                                REGEXP_INSTR (
                                    apda.apda_val_string,
                                    '^[АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ]{2}[0-9]{6}$',
                                    1),
                                0) =
                            0),
            Chk
            AS
                (SELECT    'Для особи '
                        || Pib
                        || ' номер в "'
                        || ndt_name_short
                        || '" має не коректний формат'    AS Err_Text
                   FROM D5)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk
         WHERE Err_Text IS NOT NULL;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    PROCEDURE Check_Attr_9
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        --    Dbms_Output.Put_Line('Check_attr_9');
        WITH
            D5
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)    Pib,
                        ndt_name_short
                   FROM Ap_Document  d
                        JOIN Ap_Document_Attr apda
                            ON     apda.apda_apd = d.apd_id
                               AND apda.apda_nda = 6
                               AND apda.history_status = 'A'
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                  WHERE     d.Apd_Id = g_Apd_Id
                        AND d.history_status = 'A'
                        AND NVL (
                                REGEXP_INSTR (apda.apda_val_string,
                                              '^[0-9]{9}$',
                                              1),
                                0) =
                            0),
            Chk
            AS
                (SELECT    'Для особи '
                        || Pib
                        || ' номер в "'
                        || ndt_name_short
                        || '" має не коректний формат'    AS Err_Text
                   FROM D5)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk
         WHERE Err_Text IS NOT NULL;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    --#78808
    PROCEDURE Check_Attr_90
    IS
        Err_List   VARCHAR2 (4000);
        Wrn_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D37
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                        Api$validation.Get_Doc_String (d.Apd_App,
                                                       d.Apd_Ndt,
                                                       90)
                            Reg_Num,
                        Api$validation.Get_Doc_Dt (d.Apd_App, d.Apd_Ndt, 94)
                            Dt,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)
                            Pib
                   FROM Ap_Document  d
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                  WHERE d.Apd_Id = g_Apd_Id),
            D37_Reg
            AS
                (SELECT Apd_Id,
                        Apd_Ap,
                        Reg_Num,
                        Dt,
                        Pib,
                        NVL (
                            REGEXP_SUBSTR (
                                Reg_Num,
                                '[A-Za-zА-Яа-яЇїІіЄєҐґ0-9\-]{7}[0-9]{6}',
                                1),
                            '-1')                                  AS Reg_Num_Old,
                        --#92481: з урахуванням того, що реєстр ДРАЦС містить помилки, і там дійсно наявні свідоцтва,
                        -- серія яких починається з 1, додаємо одиничку в маску для перевірки серії
                        NVL (
                            REGEXP_SUBSTR (
                                Reg_Num,
                                '[IІ1]{1}\-[А-Яа-яЇїІіЄєҐґ]{2}[0-9]{6}',
                                1),
                            '-1')                                  AS Reg_Num_New,
                        REGEXP_SUBSTR (Reg_Num, '[0-9]{6}$', 1)    AS Reg_Num_6
                   FROM D37),
            Chk
            AS
                (SELECT CASE
                            WHEN Reg_Num_6 IS NULL
                            THEN
                                   'Номер документу "Свідоцтво про народження дитини (місце народження в Україні)" не відповідає формату "шість цифр" '
                                || Pib
                        END    AS Err_Text,
                        CASE
                            WHEN     Dt <=
                                     TO_DATE ('20.11.2010', 'dd.mm.yyyy')
                                 AND Reg_Num != Reg_Num_Old
                            THEN
                                   'Перевірте правильність внесення серії документа "Свідоцтво про народження дитини" '
                                || Pib
                            WHEN     Dt >
                                     TO_DATE ('20.11.2010', 'dd.mm.yyyy')
                                 AND Reg_Num != Reg_Num_New
                            THEN
                                   'Перевірте правильність внесення серії документа "Свідоцтво про народження дитини" '
                                || Pib
                        END    AS Wrn_Text
                   --, apd_ap, reg_num, reg_num_old, reg_num_new
                   FROM D37_Reg
                  WHERE Reg_Num IS NOT NULL)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1),
               LISTAGG (Wrn_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List, Wrn_List
          FROM Chk;

        --WHERE Err_Doc IS NOT NULL;
        IF Wrn_List IS NOT NULL
        THEN
            Add_Warning (Wrn_List);
        END IF;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    PROCEDURE Check_Attr_91
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D37
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                        Ndt_Name_Short
                            AS Ndt_Name,
                        Api$validation.Get_Doc_Dt (d.Apd_App, d.Apd_Ndt, 91)
                            AS Dt,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)
                            Pib
                   FROM Ap_Document  d
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                  WHERE d.Apd_Id = g_Apd_Id),
            Chk
            AS
                (SELECT CASE
                            WHEN Dt > SYSDATE
                            THEN
                                   'Для особи '
                                || Pib
                                || ' в документі '
                                || Ndt_Name
                                || ' неправильно зазначено дату народження, перевірте правильність внесення'
                            WHEN Dt IS NULL
                            THEN
                                   'Для особи '
                                || Pib
                                || ' в документі '
                                || Ndt_Name
                                || ' не зазначено дату народження, перевірте правильність внесення'
                        END    AS Err_Text
                   FROM D37)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    --#82602
    --#82603
    PROCEDURE Check_Attr_347_1806
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D6
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                        Ndt_Name_Short           AS Ndt_Name,
                        Nda_Name,
                        atr_1.apda_val_dt        AS start_Dt,
                        atr.apda_val_dt          AS Dt,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)    Pib
                   FROM Ap_Document  d
                        JOIN Ap_Document_Attr atr
                            ON     atr.apda_apd = d.Apd_id
                               AND atr.apda_nda IN (347, 1806)
                               AND atr.History_Status = 'A'
                        LEFT JOIN Ap_Document_Attr atr_1
                            ON     atr_1.apda_apd = atr.apda_apd
                               AND atr_1.apda_nda IN (352, 1939)
                               AND atr_1.History_Status = 'A'
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        JOIN Uss_Ndi.v_Ndi_Document_Attr
                            ON Nda_Id = atr.Apda_nda
                  WHERE d.Apd_Id = g_Apd_Id),
            Chk
            AS
                (SELECT CASE
                            WHEN Dt > TO_DATE ('31.12.2099', 'dd.mm.yyyy')
                            THEN
                                   'Для особи '
                                || Pib
                                || 'в атрибуті '
                                || Nda_Name
                                || ' документа '
                                || Ndt_Name
                                || ' зазначено дату, що перевищує 31.12.2099. Якщо Інвалідність встановлено довічно, то необхідно зазначати дату 31.11.2099.'
                            WHEN start_Dt > Dt
                            THEN
                                   'Для особи '
                                || Pib
                                || ' дата "Встановлено на період до" не може бути раніше ніж "Дата встановлення інвалідності" в документі '
                                || Ndt_Name
                        END    AS Err_Text
                   FROM D6)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;

        --Якщо в атрибутах 347 або 1806 встановлено дату більшу ніж 31.11.2099, то видавати повідомлення:
        --"Для особи <ПІБ> в атрибуті "<назва>" документа "<назва>" зазначено дату, що перевищує 31.11.2099. Якщо Інвалідність встановлено довічно, то необхідно зазначати дату 31.11.2099."

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    --349 група інвалідності STRING V_DDN_SCY_GROUP
    --791 підгрупа інвалідності STRING V_DDN_SCY_SGROUP --#82602
    --#87947
    --Необхідно додати контроль щодо заповнення атрибуту nda_id=791 в документі з Ід=201 (Виписка з акту огляду МСЕК),
    --а саме, nda_id=791 в документі з Ід=201 (Виписка з акту огляду МСЕК) може заповнюватися лише для 1 групи інвалідності.
    --Якщо для 2 або 3 групи інвалідності заповнено атрибут nda_id=791 в документі з Ід=201 значенням "А" або "Б", то це помилка, необхідно видавати повідомлення:
    --"Для 2, 3 груп інвалідності не встановлюється підгрупа інвалідності. Виправте помилку в документі "Виписка з акту огляду МСЕК""
    PROCEDURE Check_Attr_349_791
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D6
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                        Ndt_Name_Short                      AS Ndt_Name,
                        Nda_Name,
                        NVL (atr.apda_val_string, '-')      AS Inv_group,
                        NVL (atr_1.apda_val_string, '-')    AS Inv_subgroup,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)               Pib
                   FROM Ap_Document  d
                        JOIN Ap_Document_Attr atr
                            ON     atr.apda_apd = d.Apd_id
                               AND atr.apda_nda IN (349)
                               AND atr.History_Status = 'A'
                        LEFT JOIN Ap_Document_Attr atr_1
                            ON     atr_1.apda_apd = atr.apda_apd
                               AND atr_1.apda_nda IN (791)
                               AND atr_1.History_Status = 'A'
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        JOIN Uss_Ndi.v_Ndi_Document_Attr
                            ON Nda_Id = atr.Apda_nda
                  WHERE d.Apd_Id = g_Apd_Id),
            Chk
            AS
                (SELECT Inv_group,
                        Inv_subgroup,
                        CASE
                            WHEN Inv_group != '1' AND Inv_subgroup != '-'
                            THEN
                                'Для 2, 3 груп інвалідності не встановлюється підгрупа інвалідності. Виправте помилку в документі "Виписка з акту огляду МСЕК"'
                            ELSE
                                NULL
                        END    AS Err_Text
                   FROM D6)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;


        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    -- #94969
    PROCEDURE Check_Attr_605
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D6
            AS
                (SELECT atr.apda_val_string     AS phone
                   FROM Ap_Document  d
                        JOIN Ap_Document_Attr atr
                            ON     atr.apda_apd = d.Apd_id
                               AND atr.apda_nda IN (605)
                               AND atr.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        JOIN Uss_Ndi.v_Ndi_Document_Attr
                            ON Nda_Id = atr.Apda_nda
                  WHERE d.Apd_Id = g_Apd_Id),
            Chk
            AS
                -- #93513
                (SELECT CASE
                            WHEN phone IS NULL
                            THEN
                                'В "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" відсутній контактний телефон (мобільний)'
                            ELSE
                                NULL
                        END    AS Err_Text
                   FROM D6)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;


        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    --#79233
    PROCEDURE Check_Attr_606
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D6
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                        Ndt_Name_Short           AS Ndt_Name,
                        CASE
                            WHEN Apd_Ndt = 6
                            THEN
                                Api$validation.Get_Doc_Dt (d.Apd_App,
                                                           d.Apd_Ndt,
                                                           606)
                            WHEN Apd_Ndt = 7
                            THEN
                                Api$validation.Get_Doc_Dt (d.Apd_App,
                                                           d.Apd_Ndt,
                                                           607)
                        END                      AS Dt,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)    Pib
                   FROM Ap_Document  d
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                  WHERE d.Apd_Id = g_Apd_Id),
            Chk
            AS
                (SELECT CASE
                            WHEN Dt > ADD_MONTHS (SYSDATE, -168)
                            THEN
                                   'Для особи '
                                || Pib
                                || ' в документі '
                                || Ndt_Name
                                || ' неправильно зазначено дату народження, перевірте правильність внесення'
                            WHEN Dt IS NULL
                            THEN
                                   'Для особи '
                                || Pib
                                || ' в документі '
                                || Ndt_Name
                                || ' не зазначено дату народження, перевірте правильність внесення'
                        END    AS Err_Text
                   FROM D6)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --================================================================
    --#97569
    --Запускається в Validate_Attrs
    --Знаходиться в Uss_Ndi.v_Ndi_Nda_Validation (nnv_nda = 649)
    PROCEDURE Check_Attr_649
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            Data
            AS
                (SELECT TRIM (
                            UPPER (
                                   p.App_Ln
                                || ' '
                                || p.App_Fn
                                || ' '
                                || p.App_Mn))    Pib
                   FROM Ap_Document  d
                        JOIN Ap_Document_Attr Apda
                            ON     Apda.Apda_Apd = d.Apd_Id
                               AND Apda.Apda_Nda = 649 /*Ступінь родинного зв'язку*/
                               AND Apda.Apda_Val_String IS NULL
                               AND Apda.History_Status = 'A'
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                               AND p.App_Tp = 'Z'                  /*Заявник*/
                        JOIN Ap_Service s
                            ON     d.Apd_Ap = s.Aps_Ap
                               AND s.History_Status = 'A'
                               AND s.Aps_Nst IN (901              /*патронат*/
                                                    ,
                                                 862           /*багатодітні*/
                                                    ,
                                                 267               /*одинока*/
                                                    ,
                                                 265                 /*хвора*/
                                                    ,
                                                 249       /*малозабезпечені*/
                                                    ,
                                                 269            /*усиновлені*/
                                                    ,
                                                 268   /*опіка та піклування*/
                                                    ,
                                                 248          /*інвалідність*/
                                                    )
                  WHERE d.Apd_Id = g_Apd_Id AND d.History_Status = 'A'),
            Chk
            AS
                (SELECT    'В Анкеті учасника звернення не заповнено "Ступінь родинного зв''язку" для Заявника '
                        || Pib
                        || '.'    AS Err_Text
                   FROM Data)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk
         WHERE Err_Text IS NOT NULL;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --================================================================
    --#102162
    PROCEDURE Check_Attr_699
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D6
            AS
                (SELECT atr.apda_val_string      AS x_val_string,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)    Pib,
                        ndt.ndt_name_short,
                        nda.nda_name
                   FROM Ap_Document  d
                        JOIN Ap_Person p ON p.App_Id = d.Apd_App
                        JOIN Ap_Document_Attr atr
                            ON     atr.apda_apd = d.Apd_id
                               AND atr.apda_nda = 699
                               AND atr.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ndt
                            ON Ndt_Id = Apd_Ndt
                        JOIN Uss_Ndi.v_Ndi_Document_Attr nda
                            ON Nda_Id = atr.Apda_nda
                  WHERE d.Apd_Id = g_Apd_Id),
            Chk
            AS
                (SELECT    'Для особи '
                        || Pib
                        || ' в документі '
                        || ndt_name_short
                        || ' розмір поля '
                        || nda_name
                        || ' не може бути більшим за 70 символів'    AS Err_Text
                   FROM D6
                  WHERE LENGTH (x_val_string) > 70)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --================================================================
    --#101523
    PROCEDURE Check_Attr_902
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D
            AS
                (SELECT d.Apd_Id, d.Apd_Ap
                   FROM Ap_Document  d
                        LEFT JOIN Ap_Document_Attr apda
                            ON     apda.apda_apd = d.apd_id
                               AND apda.apda_nda = 902
                               AND apda.history_status = 'A'
                  WHERE     d.Apd_Id = g_Apd_Id
                        AND d.history_status = 'A'
                        AND (   apda.apda_val_sum NOT IN (0,
                                                          50,
                                                          75,
                                                          100)
                             OR apda.apda_val_sum IS NULL)),
            Chk
            AS
                (SELECT    'В атрибуті "Відсоток відрахувань" в документі  '
                        || '"Заява про перерахування коштів на банківський рахунок закладу держутримання" зазначено не коректний відсоток (не 0, 50, 75 або 100)'    AS Err_Text
                   FROM D)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk
         WHERE Err_Text IS NOT NULL;

        --    Raise_Application_Error(-20000, 'g_Apd_Id='||g_Apd_Id);

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    --#111408
    PROCEDURE Check_Attr_907
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D6
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                        Ndt_Name_Short           AS Ndt_Name,
                        nda_name,
                        apda.apda_val_dt         AS val_dt,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)    Pib
                   FROM Ap_Document  d
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        JOIN Uss_Ndi.v_Ndi_Document_Attr ON Nda_ndt = Ndt_id
                        LEFT JOIN Ap_Document_Attr apda
                            ON     apda.apda_apd = d.apd_id
                               AND apda.apda_nda = Nda_Id
                               AND apda.history_status = 'A'
                  WHERE     d.Apd_id = g_Apd_Id
                        AND apd_ndt = 10035
                        AND nda_id = 907
                        AND d.history_status = 'A'),
            Chk
            AS
                (SELECT CASE
                            WHEN val_Dt > g_Ap_Reg_Dt
                            THEN
                                   'Для особи '
                                || Pib
                                || ' в документі '
                                || Ndt_Name
                                || ' '
                                || nda_name
                                || ' не може бути вказана дата більша за "дату подання заяви" '
                        END    AS Err_Text
                   FROM D6)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --==============================================================--
    --#111408
    PROCEDURE Check_Attr_923
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D6
            AS
                (SELECT d.Apd_Id,
                        d.Apd_Ap,
                        Ndt_Name_Short           AS Ndt_Name,
                        nda_name,
                        apda.apda_val_dt         AS val_dt,
                           INITCAP (p.App_Ln)
                        || ' '
                        || INITCAP (p.App_Fn)
                        || ' '
                        || INITCAP (p.App_Mn)    Pib
                   FROM Ap_Document  d
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        JOIN Uss_Ndi.v_Ndi_Document_Attr ON Nda_ndt = Ndt_id
                        LEFT JOIN Ap_Document_Attr apda
                            ON     apda.apda_apd = d.apd_id
                               AND apda.apda_nda = Nda_Id
                               AND apda.history_status = 'A'
                  WHERE     d.Apd_id = g_Apd_Id
                        AND apd_ndt = 10034
                        AND nda_id = 923
                        AND d.history_status = 'A'),
            Chk
            AS
                (SELECT CASE
                            WHEN val_Dt > g_Ap_Reg_Dt
                            THEN
                                   'Для особи '
                                || Pib
                                || ' в документі '
                                || Ndt_Name
                                || ' '
                                || nda_name
                                || ' не може бути вказана дата більша за "дату подання заяви" '
                        END    AS Err_Text
                   FROM D6)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --================================================================
    --#97529
    --Запускається в Validate_Attrs
    --Знаходиться в Uss_Ndi.v_Ndi_Nda_Validation (nnv_nda = 2531)
    PROCEDURE Check_Attr_2531
    IS
        Err_List               VARCHAR2 (4000);

        l_Nda_2531_Need_Fill   BOOLEAN;
        l_Is_Nda_2531_Empty    BOOLEAN;
    BEGIN
        l_Nda_2531_Need_Fill :=
            Api$validation.Get_Val_String (p_Apd => g_Apd_Id, p_Nda => 2529 /*Одиниця відрахування переплати*/
                                                                           ) NOT IN
                ('PD'                                      /*Відсотки доходу*/
                     , 'AS'                                               /*Абсолютна сума*/
                           );
        l_Is_Nda_2531_Empty :=
            Api$validation.Get_Val_Sum (p_Apd => g_Apd_Id, p_Nda => 2531 /*Розмір (знаменник: значення частини)*/
                                                                        )
                IS NULL;

        IF l_Nda_2531_Need_Fill AND l_Is_Nda_2531_Empty
        THEN
            WITH
                Chk
                AS
                    (SELECT TRIM (
                                UPPER (
                                       p.App_Ln
                                    || ' '
                                    || p.App_Fn
                                    || ' '
                                    || p.App_Mn))    Pib
                       FROM Ap_Document  d
                            JOIN Ap_Person p
                                ON     p.App_Id = d.Apd_App
                                   AND p.History_Status = 'A'
                      WHERE d.Apd_Id = g_Apd_Id)
            SELECT LISTAGG (
                          'Для '
                       || Pib
                       || ' в документі "Заява про добровільне повернення переплати" не заповнено атрибут: Розмір (знаменник: значення частини)',
                       ', ')
                   WITHIN GROUP (ORDER BY 1)
              INTO Err_List
              FROM Chk;
        ELSIF NOT l_Nda_2531_Need_Fill AND NOT l_Is_Nda_2531_Empty
        THEN
            WITH
                Chk
                AS
                    (SELECT TRIM (
                                UPPER (
                                       p.App_Ln
                                    || ' '
                                    || p.App_Fn
                                    || ' '
                                    || p.App_Mn))    Pib
                       FROM Ap_Document  d
                            JOIN Ap_Person p
                                ON     p.App_Id = d.Apd_App
                                   AND p.History_Status = 'A'
                      WHERE d.Apd_Id = g_Apd_Id)
            SELECT LISTAGG (
                          'Для '
                       || Pib
                       || ' в документі "Заява про добровільне повернення переплати" Якщо "Одиниця відрахування переплати" = "Відсотки доходу" або "Абсолютна сума", то атрибут "Розмір (знаменник: значення частини)" не заповнюється',
                       ', ')
                   WITHIN GROUP (ORDER BY 1)
              INTO Err_List
              FROM Chk;
        END IF;

        IF Err_List IS NOT NULL
        THEN
            Add_Warning (Err_List);
        END IF;
    END;

    --==============================================================--
    -- 4297 = PD
    -- 4300 is not null
    -- #92758
    PROCEDURE Check_Attr_4300
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D6
            AS
                (SELECT atr.apda_val_sum          AS znamennik,
                        atr_1.apda_val_string     AS sum_tp
                   FROM Ap_Document  d
                        JOIN Ap_Document_Attr atr
                            ON     atr.apda_apd = d.Apd_id
                               AND atr.apda_nda IN (4300)
                               AND atr.History_Status = 'A'
                        LEFT JOIN Ap_Document_Attr atr_1
                            ON     atr_1.apda_apd = atr.apda_apd
                               AND atr_1.apda_nda IN (4297)
                               AND atr_1.History_Status = 'A'
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                        JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Apd_Ndt
                        JOIN Uss_Ndi.v_Ndi_Document_Attr
                            ON Nda_Id = atr.Apda_nda
                  WHERE d.Apd_Id = g_Apd_Id),
            Chk
            AS
                -- #93513
                (SELECT CASE
                            WHEN sum_tp = 'SD' AND znamennik IS NULL
                            THEN
                                'Для значення одиниці відрахування "Частина доходу" необхідно заповнювати знаменник'
                            ELSE
                                NULL
                        END    AS Err_Text
                   FROM D6)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;


        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
    END;

    --Якщо в атрибуті з Ід=8427 (Підвищення дітям війни) в документі з Ід=605 зазначено так, то і дата народження особи, якої стосується анкета,
    --не відповідає умові: особі до 2 вересня 1945 року війни було менше ніж 18 років,
    --то це помилка, текст помилки
    --"Осрба <ПІБ> не є дитина війни, тому що дитина війни - особа, якій на час закінчення (2 вересня 1945 року) Другої світової війни було менше 18 років;"
    --==============================================================--
    -- #103028
    PROCEDURE Check_Attr_8427
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        WITH
            D6
            AS
                (SELECT Api$appeal.Get_Person_Attr_Val_Dt (p.app_id, 'BDT')
                            AS x_BDT,
                        TRIM (
                            UPPER (
                                   p.App_Ln
                                || ' '
                                || p.App_Fn
                                || ' '
                                || p.App_Mn))
                            AS x_Pib
                   FROM Ap_Document  d
                        JOIN Ap_Document_Attr atr
                            ON     atr.apda_apd = d.Apd_id
                               AND atr.apda_nda IN (8427)
                               AND atr.History_Status = 'A'
                        JOIN Ap_Person p
                            ON     p.App_Id = d.Apd_App
                               AND p.History_Status = 'A'
                  WHERE d.Apd_Id = g_Apd_Id AND atr.apda_val_string = 'T'),
            Chk
            AS
                (SELECT CASE
                            WHEN TO_DATE ('02.09.1945', 'dd.mm.yyyy') NOT BETWEEN x_BDT
                                                                              AND ADD_MONTHS (
                                                                                      x_BDT,
                                                                                        12
                                                                                      * 18)
                            THEN
                                   'Особа '
                                || x_Pib
                                || ' не є дитина війни, тому що дитина війни - особа, якій на час закінчення (2 вересня 1945 року) Другої світової війни було менше 18 років'
                        END    AS Err_Text
                   FROM D6)
        SELECT LISTAGG (Err_Text, ', ') WITHIN GROUP (ORDER BY 1)
          INTO Err_List
          FROM Chk;


        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
        END IF;
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

    --------------------------------------------------------------------
    -----#102136
    --------------------------------------------------------------------
    PROCEDURE CheckDoc801
    IS
        Err_List          VARCHAR2 (4000);
        l_ServiceNeeded   VARCHAR2 (100);
        l_ServiceTo       VARCHAR2 (100);
        l_Apop_nst        USS_ESR.API$FIND.cActServices;
        l_IsNstError      BOOLEAN;
        l_qty             NUMBER;
    BEGIN
        --IF g_Ap_Src IN ('PORTAL') THEN
        --  RETURN;
        --END IF;

        --#105489
        l_ServiceNeeded := API$APPEAL.Get_Ap_Attr_Val_Str (g_Ap_Id, 1868);
        l_ServiceTo := API$APPEAL.Get_Ap_Attr_Val_Str (g_Ap_Id, 1895);


        --Якщо джерело реєстрації звернення ap_src in (‘USS’), то варіанти можуть бути наступними :
        /*1)  Якщо в заяві вказано:
               - «Соціальних послуг потребує» nda_id in (1868) = «особа» (Z)
               - «Послугу надати» nda_id in (1895) = «мені» (Z),
               то типи учасників мають бути:
               - «Заявник» (Z) – обов’язково;
               - «Член сім’ї» (FM) – за наявності

               При цьому повинен бути наявним контроль щодо заповнення в анкеті 605 атрибуту nda_id = 649 «Ступінь родинного зв’язку», а саме:
               - для учасника «Заявник» (Z) – 649 = «Заявник» (Z)
               - для учасника «Член сім’ї» (FM) – 649 = будь-хто, за виключенням «Заявник» (Z)

               Не можуть бути наявними типи учасників:
               - «Особа, яка потребує соціальних послуг» (OS)
               - «Законний представник особи, яка потребує соціальних послуг» (OR)
               - «Уповноважений представник сім’ї» (AF)*/
        IF l_ServiceNeeded = 'Z' AND l_ServiceTo = 'Z'
        THEN
            FOR vErr
                IN (WITH
                        Chk
                        AS
                            (SELECT CASE
                                        WHEN COUNT (1) = 0
                                        THEN
                                            'CheckDoc801[1.1]: Для звернення необхідно вказати хоча б одного учасника з типом "Заявник"'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'Z'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) = 0
                                        THEN
                                            'CheckDoc801[1.2]: Для учасника з типом "Заявник" атрибут «Ступінь родинного зв’язку» повинен мати значення «Заявник»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'Z'
                                    AND API$APPEAL.Get_Person_Attr_Val_Str (
                                            app.app_id,
                                            649) =
                                        'Z'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) = 1
                                        THEN
                                            'CheckDoc801[1.3]: Для учасника з типом "Член сім’ї" атрибут «Ступінь родинного зв’язку» повинен бути заповнений і не може мати значення «Заявник»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'FM'
                                    AND NVL (
                                            API$APPEAL.Get_Person_Attr_Val_Str (
                                                app.app_id,
                                                649),
                                            'Z') =
                                        'Z'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) > 0
                                        THEN
                                            'CheckDoc801[1.4]: У зверненні не повинно бути учасників з типами «Особа, яка потребує соціальних послуг», «Законний представник особи, яка потребує соціальних послуг», «Уповноважений представник сім’ї»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp IN ('OS',
                                                       'OR',
                                                       'AF',
                                                       'AG')
                                    AND app.history_status = 'A')
                    SELECT Err_Text
                      FROM Chk
                     WHERE TRIM (Err_Text) IS NOT NULL)
            LOOP
                Add_Fatal (vErr.Err_Text);
            END LOOP;
        /*
        2)Якщо в заяві вказано:
            - «Соціальних послуг потребує» nda_id in (1868) = «особа» (Z)
            - «Послугу надати» nda_id in (1895) = «моєму(їй) синові (доньці)» (B)
            ТА виконується одна з умов:
            - АБО вік сина/доньки < 18 років
            - АБО вік сина/доньки >= 18 років ТА статус «Недієздатна особа» = T,
            то типи учасників мають бути:
            - «Заявник» (Z) – обов’язково
            - «Особа, яка потребує соціальних послуг» (OS) – обов’язково (це син/донька)
            - «Член сім’ї» (FM) – за наявності

            При цьому повинен бути наявним контроль щодо заповнення в анкеті 605 атрибуту nda_id = 649 «Ступінь родинного зв’язку», а саме:
            - для учасника «Заявник» (Z) – 649 = «Заявник» (Z)
            - для учасника «Особа, яка потребує соціальних послуг» (OS) – 649 = «Син/Донька» (B)
            - для учасника «Член сім’ї» (FM) – 649 = будь-хто, за виключенням «Заявник» (Z)

            Не можуть бути наявними типи учасників:
            - «Законний представник особи, яка потребує соціальних послуг» (OR)
            - «Уповноважений представник сім’ї» (AF)
        */
        ELSIF l_ServiceNeeded = 'Z' AND l_ServiceTo = 'B'
        THEN
            FOR vErr
                IN (WITH
                        Persons
                        AS
                            (SELECT app.*,
                                    Api$appeal.Get_Person_Attr_Val_Dt (
                                        app.app_id,
                                        p_Nda_Class   => 'BDT')   app_bdt,
                                    NVL (
                                        Api$appeal.Get_Person_Attr_Val_Str (
                                            app.app_id,
                                            p_Nda_id   => 2215),
                                        'F')                      app_disability
                               FROM Appeal  ap
                                    JOIN Ap_Person App
                                        ON ap.ap_id = app.app_ap
                              WHERE ap.ap_id = g_Ap_Id),
                        Chk
                        AS
                            (SELECT CASE
                                        WHEN COUNT (1) = 0
                                        THEN
                                            'CheckDoc801[2.1]: У зверненні не вказано заявника'
                                    END    Err_Text
                               FROM Persons app
                              WHERE app_tp = 'Z' AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) = 0
                                        THEN
                                            'CheckDoc801[2.2]: У зверненні не вказано учасника з типом «Особу, що потребує СП»'
                                    END
                               FROM Persons app
                              WHERE     app_tp = 'OS'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (
                                                 CASE
                                                     WHEN API$APPEAL.Get_Person_Attr_Val_Str (
                                                              app.app_id,
                                                              649) =
                                                          'B'
                                                     THEN
                                                         1
                                                 END) <>
                                             COUNT (1)
                                        THEN
                                            'CheckDoc801[2.3]: Учасник з типом «Особа, яка потребує соціальних послуг» повинен мати тип родинного зв`язку «Син/Донька»'
                                    END
                               FROM Persons app
                              WHERE     app_tp = 'OS'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) = 0
                                        THEN
                                            'CheckDoc801[2.4]: Учасник з типом «Особа, яка потребує соціальних послуг» повинен або бути недієздатним або бути молодшим 18 років'
                                    END
                               FROM Persons app
                              WHERE     app_tp = 'OS'
                                    AND app.history_status = 'A'
                                    AND API$APPEAL.Get_Person_Attr_Val_Str (
                                            app.app_id,
                                            649) =
                                        'B'
                                    AND (   MONTHS_BETWEEN (SYSDATE, app_bdt) <
                                            18 * 12
                                         OR (    MONTHS_BETWEEN (SYSDATE,
                                                                 app_bdt) >=
                                                 18 * 12
                                             AND app_disability = 'T'))
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) > 0
                                        THEN
                                            'CheckDoc801[2.5]: У зверненні не повинно бути учасників з типами «Законний представник особи, яка потребує соціальних послуг», «Уповноважений представник сім’ї»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.history_status = 'A'
                                    AND app.app_tp IN ('OR', 'AF', 'AG'))
                    SELECT Err_Text
                      FROM Chk
                     WHERE TRIM (Err_Text) IS NOT NULL)
            LOOP
                Add_Fatal (vErr.Err_Text);
            END LOOP;
        /*
        3)Якщо в заяві вказано:
           - «Соціальних послуг потребує» nda_id in (1868) = «особа» (Z)
           - «Послугу надати» nda_id in (1895) = «підопічному(ій)» (CHRG)
           то типи учасників мають бути:
           - «Законний представник особи, яка потребує соціальних послуг» (OR) – обов’язково
           - «Особа, яка потребує соціальних послуг» (OS) – обов’язково (це підопічний)
           - «Член сім’ї» (FM) – за наявності

           При цьому повинен бути наявним контроль щодо заповнення в анкеті 605 атрибуту nda_id = 649 «Ступінь родинного зв’язку», а саме:
           - для учасника «Законний представник особи, яка потребує соціальних послуг» (OR) – 649 = «Заявник» (Z)
           - для учасника «Особа, яка потребує соціальних послуг» (OS) – 649 = «Підопічний» (CHRG)
           - для учасника «Член сім’ї» (FM) – 649 = будь-хто, за виключенням «Заявник» (Z)

           Не можуть бути наявними типи учасників:
           - «Заявник» Z
        */
        ELSIF l_ServiceNeeded = 'Z' AND l_ServiceTo = 'CHRG'
        THEN
            FOR vErr
                IN (WITH
                        Chk
                        AS
                            (SELECT CASE
                                        WHEN COUNT (1) = 0
                                        THEN
                                            'CheckDoc801[3.1]: У зверненні повинно бути вказано участника з типом «Особа, яка потребує соціальних послуг»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     App_Ap = g_Ap_Id
                                    AND app_tp IN ('OS')
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) = 0
                                        THEN
                                            'CheckDoc801[3.1]: У зверненні повинно бути вказано участника з типом «Законний представник особи, що потребує соціальних послуг»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     App_Ap = g_Ap_Id
                                    AND app_tp IN ('OR', 'AG')
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (
                                                 CASE
                                                     WHEN API$APPEAL.Get_Person_Attr_Val_Str (
                                                              app.app_id,
                                                              649) =
                                                          'Z'
                                                     THEN
                                                         1
                                                 END) <>
                                             COUNT (1)
                                        THEN
                                            'CheckDoc801[3.2]: Для учасника з типом «Законний представник особи, яка потребує соціальних послуг» атрибут «Ступінь родинного зв’язку» повинен мати значення «Заявник»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'OR'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (
                                                 CASE
                                                     WHEN API$APPEAL.Get_Person_Attr_Val_Str (
                                                              app.app_id,
                                                              649) =
                                                          'Z'
                                                     THEN
                                                         1
                                                 END) <>
                                             COUNT (1)
                                        THEN
                                            'CheckDoc801[3.3]: Для учасника з типом «повноважена особа органу опіки та піклування» атрибут «Ступінь родинного зв’язку» повинен мати значення «Заявник»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'AG'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (
                                                 CASE
                                                     WHEN API$APPEAL.Get_Person_Attr_Val_Str (
                                                              app.app_id,
                                                              649) =
                                                          'CHRG'
                                                     THEN
                                                         1
                                                 END) <>
                                             COUNT (1)
                                        THEN
                                            'CheckDoc801[3.4]: Для учасника з типом «Особа, яка потребує соціальних послуг» атрибут «Ступінь родинного зв’язку» повинен мати значення «Підопічний»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'OS'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) > 0
                                        THEN
                                            'CheckDoc801[3.5]: Для учасника з типом «Член сім’ї» атрибут «Ступінь родинного зв’язку» повине бути заповнений і не може мати значення «Заявник»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'FM'
                                    AND app.history_status = 'A'
                                    AND NVL (
                                            API$APPEAL.Get_Person_Attr_Val_Str (
                                                app.app_id,
                                                649),
                                            'Z') =
                                        'Z'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) > 0
                                        THEN
                                            'CheckDoc801[3.6]: У зверненні не повинно бути учасників з типами «Учасник»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'Z'
                                    AND app.history_status = 'A')
                    SELECT Err_Text
                      FROM Chk
                     WHERE TRIM (Err_Text) IS NOT NULL)
            LOOP
                Add_Fatal (vErr.Err_Text);
            END LOOP;
        /*
        4) Якщо в заяві вказано «Соціальних послуг потребує» nda_id in (1868) = «сім’я» (FM) + «Послугу надати» nda_id in (1895) = «моїй сім’ї» (FM), то типи учасників мають бути:
          - один з двох:
          -- АБО «Заявник» (Z) – обов’язково (це член сім’ї)
          -- АБО «Уповноважений представник сім’ї» (AF) – обов’язково (і це теж член сім’ї (для чого? не зрозуміло))
          - «Член сім’ї» (FM) – хоча б один

          При цьому повинен бути наявним контроль щодо заповнення в анкеті 605 атрибуту nda_id = 649 «Ступінь родинного зв’язку», а саме:
          - для учасника «Заявник» (Z) – 649 = «Заявник» (Z)
          - для учасника «Уповноважений представник сім’ї» (AF) – 649 = «Заявник» (Z)
          - для учасника «Член сім’ї» (FM) – 649 = будь-хто, за виключенням «Заявник» (Z)

          Не можуть бути наявними типи учасників:
          - «Особа, яка потребує соціальних послуг» (OS)
          - «Законний представник особи, яка потребує соціальних послуг» (OR)
          - «Уповноважена особа органу опіки та піклування» (AG)
        */

        ELSIF l_ServiceNeeded = 'FM' AND l_ServiceTo = 'FM'
        THEN
            FOR vErr
                IN (WITH
                        Chk
                        AS
                            (SELECT CASE
                                        WHEN COUNT (1) <> 1
                                        THEN
                                            'CheckDoc801[4.1]: У зверненні повинно бути вказано АБО участника з типом «Заявник» АБО з типом «Уповноважений представник сім’ї»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     App_Ap = g_Ap_Id
                                    AND app_tp IN ('AF', 'Z')
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN API$APPEAL.Get_Person_Attr_Val_Str (
                                                 app.app_id,
                                                 649) <>
                                             'Z'
                                        THEN
                                            'CheckDoc801[4.2]: Для учасника з типом «Заявник» атрибут «Ступінь родинного зв’язку» повинен мати значення «Заявник»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'Z'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN API$APPEAL.Get_Person_Attr_Val_Str (
                                                 app.app_id,
                                                 649) <>
                                             'Z'
                                        THEN
                                            'CheckDoc801[4.3]: Для учасника з типом «Уповноважений представник сім’ї» атрибут «Ступінь родинного зв’язку» повинен мати значення «Заявник»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'AF'
                                    AND app.history_status = 'A'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) > 0
                                        THEN
                                            'CheckDoc801[4.4]: Для учасника з типом «Член сім’ї» атрибут «Ступінь родинного зв’язку» повине бути заповнений та не може мати значення «Заявник»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp = 'FM'
                                    AND app.history_status = 'A'
                                    AND NVL (
                                            API$APPEAL.Get_Person_Attr_Val_Str (
                                                app.app_id,
                                                649),
                                            'Z') =
                                        'Z'
                             UNION ALL
                             SELECT CASE
                                        WHEN COUNT (1) > 0
                                        THEN
                                            'CheckDoc801[4.5]: У зверненні не повинно бути учасників з типами «Особа, яка потребує соціальних послуг», «Законний представник особи, яка потребує соціальних послуг», «Уповноважена особа органу опіки та піклування»'
                                    END    Err_Text
                               FROM Ap_Person app
                              WHERE     app.app_ap = g_Ap_Id
                                    AND app.app_tp IN ('OS', 'OR', 'AG')
                                    AND app.history_status = 'A')
                    SELECT Err_Text
                      FROM Chk
                     WHERE TRIM (Err_Text) IS NOT NULL)
            LOOP
                Add_Fatal (vErr.Err_Text);
            END LOOP;
        END IF;

        /*
         Додатково: додати контроль на неможливість одночасної присутності у зверненні типів учасників «Заявник» (Z) та «Член сім’ї, на якого буде оформлено договір» (FMS)
         */
        WITH
            IsNeedChk
            AS
                (SELECT COUNT (1)     ChkQty
                   FROM Ap_Document  d
                        JOIN Appeal ap
                            ON     Ap.Ap_Id = d.apd_ap
                               AND AP.Ap_Src IN ('CMES', 'USS')
                        JOIN Ap_Document_Attr atr
                            ON     atr.apda_apd = d.Apd_id
                               AND atr.apda_nda IN (1868)
                               AND atr.History_Status = 'A'
                               AND atr.apda_val_string = 'Z'
                        JOIN Ap_Document_Attr atr2
                            ON     atr2.apda_apd = d.Apd_id
                               AND atr2.apda_nda IN (1895)
                               AND atr2.History_Status = 'A'
                               AND atr2.apda_val_string IN ('FM',
                                                            'CHRG',
                                                            'B',
                                                            'Z')
                  WHERE 1 = 1 AND ap.ap_id = g_Ap_Id),
            Chk
            AS
                (SELECT CASE
                            WHEN ((  SIGN (
                                         COUNT (
                                             CASE
                                                 WHEN App_Tp = 'Z' THEN 1
                                             END))
                                   + SIGN (
                                         COUNT (
                                             CASE
                                                 WHEN App_Tp = 'FMS' THEN 1
                                             END))) =
                                  2)
                            THEN
                                'CheckDoc801[8]: У зверненні не повинні бути одночасно вказані Заявник та Член сім"ї, на якого буде оформлено договір'
                        END    Err_Text
                   FROM Ap_Person
                  WHERE App_Ap = g_Ap_Id)
        SELECT LISTAGG (Err_Text, ', ')
          INTO Err_List
          FROM IsNeedChk, Chk
         WHERE ChkQty > 0;

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
            Err_List := NULL;
        END IF;


        --#109391
        IF g_AP.Ap_Ap_Main IS NOT NULL
        THEN
            USS_ESR.API$FIND.Get_Apop_Services_By_Ap (g_AP.Ap_Ap_Main,
                                                      l_Apop_nst);

            Err_List := NULL;

            SELECT COUNT (1) ChkQty INTO l_qty FROM TABLE (l_Apop_nst);

            IF l_qty > 0
            THEN
                WITH
                    Chk
                    AS
                        (SELECT COUNT (1)     ChkQty
                           FROM TABLE (l_Apop_nst)
                          WHERE NOT EXISTS
                                    (SELECT 1
                                       FROM Appeal
                                      WHERE     ap_ap_main = g_AP.Ap_Ap_Main
                                            AND ap_id <> g_Ap.Ap_Id
                                            AND ap_st <> 'X'
                                            AND EXISTS
                                                    (SELECT 1
                                                       FROM ap_service
                                                      WHERE     aps_ap =
                                                                ap_id
                                                            AND HISTORY_STATUS =
                                                                'A'
                                                            AND aps_nst =
                                                                Ats_nst)))
                SELECT CASE
                           WHEN ChkQty = 0
                           THEN
                               'Неможливо створити нове звернення, так як всі створені звернення у статусі != «Відхилено» вже охоплюють всі послуги з АРОРу'
                       END
                  INTO Err_List
                  FROM Chk;

                IF Err_List IS NOT NULL
                THEN
                    Add_Fatal (Err_List);
                    Err_List := NULL;
                END IF;
            END IF;

            WITH
                Chk
                AS
                    (SELECT COUNT (1)     ChkQty
                       FROM appeal  ap1
                            JOIN ap_service aps1 ON ap1.ap_id = aps1.aps_ap
                      WHERE     ap1.ap_id = g_Ap.Ap_Id
                            AND aps1.HISTORY_STATUS = 'A'
                            AND EXISTS
                                    (SELECT 1
                                       FROM appeal  ap2
                                            JOIN ap_service aps2
                                                ON ap2.ap_id = aps2.aps_ap
                                      WHERE     ap2.ap_ap_main =
                                                g_AP.Ap_Ap_Main
                                            AND ap_id <> g_Ap.Ap_Id
                                            AND ap_st <> 'X'
                                            AND aps1.aps_nst = aps2.aps_nst
                                            AND aps2.HISTORY_STATUS = 'A'))
            SELECT CASE
                       WHEN ChkQty > 0
                       THEN
                           'Неможливо створити нове звернення, так як послуги у зверненні вже є в іншому зверненні у статусі != «Відхилено»'
                   END
              INTO Err_List
              FROM Chk;

            IF Err_List IS NOT NULL
            THEN
                Add_Fatal (Err_List);
                Err_List := NULL;
            END IF;
        END IF;
    END;

    --#105581
    PROCEDURE CheckDoc802
    IS
        Err_List   VARCHAR2 (4000);
    BEGIN
        --#105581 - Прибрано джерело звернення
        --Якщо джерело реєстрації звернення ap_src in (‘USS’), то варіанти можуть бути наступними :
        /*1) Якщо вказано: в атрибуті nda_id = 1944 «Соціальних послуг потребує» = «особа» (Z)
               та значення атрибуту nda_id in (1946) «Вид надходження» = «самозвернення» (SA), то у зверненні має бути:
               - «Заявник» (Z) – обов’язково --- це ця ж особа, яка потребує СП
               - «Член сім’ї» (FM) – за наявності
               Прив’язка акту до «Заявник» (Z)*/
        WITH
            Chk
            AS
                (SELECT CASE
                            WHEN COUNT (1) = 0
                            THEN
                                'CheckDoc802[1]: Для звернення необхідно вказати особу з типом "Заявник"'
                        END    Err_Text
                   FROM Ap_Person app
                  WHERE app.app_ap = g_Ap_Id AND app.app_tp = 'Z')
        SELECT LISTAGG (Err_Text, ', ')
          INTO Err_List
          FROM Chk
         WHERE     API$Validation.Get_Ap_Doc_String (g_Ap_Id, 1944) = 'Z'
               AND API$Validation.Get_Ap_Doc_String (g_Ap_Id, 1946) = 'SA';

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
            Err_List := NULL;
        END IF;



        /*
      2) Якщо вказано: в атрибуті nda_id = 1944 «Соціальних послуг потребує» = «особа» (Z)
    та значення атрибуту nda_id in (1946) «Вид надходження» != «самозвернення» (SA), то у зверненні мають бути:
    - учасник одного з типів – обов’язково:
    -- «Заявник» (Z) --- це умовний сусід
    -- «Законний представник особи, що потребує соціальних послуг» (OR)
    -- «Уповноважена особа надавача» (AP)
    -- «Уповноважена особа органу опіки та піклування» (AG)
    - «Особа, що потребує соціальних послуг» (OS) – обов’язково --- це особа, яка потребує СП
    - «Член сім’ї» (FM) – за наявності
    Прив’язка акту до «Особа, що потребує соціальних послуг» (OS)
        */
        WITH
            Chk
            AS
                (SELECT CASE
                            WHEN COUNT (DISTINCT app.app_tp) = 0
                            THEN
                                'CheckDoc802[2]: Для звернення необхідно вказати учасників з одним з типів: "Заявник", "Уповноважена особа надавача»", "Уповноважена особа органу опіки та піклування", "Особа, що потребує соціальних послуг"'
                        END    Err_Text
                   FROM Ap_Person app
                  WHERE     app.app_ap = g_Ap_Id
                        AND app.app_tp IN ('Z',
                                           'AP',
                                           'AG',
                                           'OS'))
        SELECT LISTAGG (Err_Text, ', ')
          INTO Err_List
          FROM Chk
         WHERE     API$Validation.Get_Ap_Doc_String (g_Ap_Id, 1944) = 'Z'
               AND API$Validation.Get_Ap_Doc_String (g_Ap_Id, 1946) != 'SA';

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
            Err_List := NULL;
        END IF;


        /*
    3) Якщо вказано: в атрибуті nda_id = 1944 «Соціальних послуг потребує» = «сім’я» (FM)
  та значення атрибуту nda_id in (1946) «Вид надходження» = «самозвернення» (SA), то у зверненні мають бути:
  - учасник одного з типів – обов’язково:
  -- «Заявник» (Z) --- це член сім’ї, який звертається щодо своєї сім’ї
  -- «Уповноважений представник сім’ї» (AF) --- оскільки за зауваженням МСП це теж член сім’ї, який звертається щодо своєї сім’ї => не зрозуміло для чого мінсоцу потрібні 2 ідентичні за змістом учасники!
  - «Член сім’ї» (FM) – бажано ( це означає, що краще би одразу мати повний перелік членів сім’ї з можливістю їх ідентифікації. Але оскільки звернення з 802 є некоректним за замовченням, то не встановлюю додавання учасника «Член сім’ї» обов’язковим )
    Прив’язка акту АБО до «Заявник» (Z) АБО «Уповноважений представник сім’ї» (AF)
      */
        WITH
            Chk
            AS
                (SELECT CASE
                            WHEN COUNT (1) = 0
                            THEN
                                'CheckDoc802[3]: Для звернення необхідно вказати учасників з одним з типів: "Заявник", "Уповноважена представник сім’ї»"'
                        END    Err_Text
                   FROM Ap_Person app
                  WHERE app.app_ap = g_Ap_Id AND app.app_tp IN ('Z', 'AF'))
        SELECT LISTAGG (Err_Text, ', ')
          INTO Err_List
          FROM Chk
         WHERE     API$Validation.Get_Ap_Doc_String (g_Ap_Id, 1944) = 'FM'
               AND API$Validation.Get_Ap_Doc_String (g_Ap_Id, 1946) = 'SA';

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
            Err_List := NULL;
        END IF;

        /*
   4) Якщо вказано: в атрибуті nda_id = 1944 «Соціальних послуг потребує» = «сім’я» (FM)
  та значення атрибуту nda_id in (1946) «Вид надходження» != «самозвернення» (SA), то у зверненні мають бути:
  - учасник одного з типів – обов’язково:
  -- «Заявник» (Z) --- це умовний сусід
  -- «Уповноважена особа надавача» (AP)
  -- «Уповноважена особа органу опіки та піклування» (AG)
  - «Член сім’ї» (FM) – обов’язково хоча б один
  */
        WITH
            Chk
            AS
                (SELECT CASE
                            WHEN COUNT (DISTINCT app.app_tp) = 0
                            THEN
                                'CheckDoc802[4]: Для звернення необхідно вказати учасників з одним з типів: "Заявник", "Уповноважена особа надавача»", "Уповноважена особа органу опіки та піклування", "Член сім’ї"'
                        END    Err_Text
                   FROM Ap_Person app
                  WHERE     app.app_ap = g_Ap_Id
                        AND app.app_tp IN ('Z',
                                           'AP',
                                           'AG',
                                           'FM'))
        SELECT LISTAGG (Err_Text, ', ')
          INTO Err_List
          FROM Chk
         WHERE     API$Validation.Get_Ap_Doc_String (g_Ap_Id, 1944) = 'FM'
               AND API$Validation.Get_Ap_Doc_String (g_Ap_Id, 1946) != 'SA';

        IF Err_List IS NOT NULL
        THEN
            Add_Error (Err_List);
            Err_List := NULL;
        END IF;
    END;

    ---------------------------------------------------------------------
    FUNCTION GET_DOC_NAME (p_Apd_Id NUMBER)
        RETURN VARCHAR2
    IS
        ret   VARCHAR2 (2000);
    BEGIN
        SELECT MAX (t.ndt_name_short)
          INTO ret
          FROM ap_document  apd
               JOIN uss_ndi.v_ndi_document_type t ON t.ndt_id = apd.apd_ndt
         WHERE apd.apd_id = p_Apd_Id;

        RETURN ret;
    END;

    ---------------------------------------------------------------------
    PROCEDURE CheckDoc10033
    IS
        ret   NUMBER;
    BEGIN
        ret := Get_Apd_Doc_Scan (g_Apd_Id);

        IF ret = 0
        THEN
            Add_Error (
                   'Для документу "'
                || Get_doc_name (g_Apd_Id)
                || '" не долучено сканкопію паперового документу');
        END IF;
    END;

    ---------------------------------------------------------------------
    PROCEDURE CheckDoc10034
    IS
        ret   NUMBER;
    BEGIN
        ret := Get_Apd_Doc_Scan (g_Apd_Id);

        IF ret = 0
        THEN
            Add_Error (
                   'Для документу "'
                || Get_doc_name (g_Apd_Id)
                || '" не долучено сканкопію паперового документу');
        END IF;
    END;

    ---------------------------------------------------------------------
    PROCEDURE CheckDoc10035
    IS
        ret   NUMBER;
    BEGIN
        ret := Get_Apd_Doc_Scan (g_Apd_Id);

        IF ret = 0
        THEN
            Add_Error (
                   'Для документу "'
                || Get_doc_name (g_Apd_Id)
                || '" не долучено сканкопію паперового документу');
        END IF;
    END;

    ---------------------------------------------------------------------
    --             ПЕРЕВІРКА ПАКЕТУ ЗАЯВ ВПО
    ---------------------------------------------------------------------
    PROCEDURE Validate_Vpo_Pkg
    IS
        l_Cnt      NUMBER;
        l_App_Tp   VARCHAR2 (10);
    BEGIN
        Validate_Appeal;
        Validate_Persons (p_Check_Doc_Num_Attr => FALSE);

        --Перевіряємо що до кожного учасника звернення прив'язана одна заява про взяття на облік ВПО
        FOR Rec
            IN (  SELECT p.App_Id,
                         p.App_Inn,
                         p.App_Ndt,
                         p.App_Doc_Num,
                         p.App_Fn,
                         p.App_Mn,
                         p.App_Ln,
                         COUNT (d.Apd_App)     AS Cnt
                    FROM Ap_Person p
                         LEFT JOIN Ap_Document d
                             ON     p.App_Id = d.Apd_App
                                AND d.Apd_Ndt = 10100
                                AND d.History_Status = 'A'
                   WHERE App_Ap = g_Ap_Id AND p.History_Status = 'A'
                GROUP BY p.App_Id,
                         p.App_Inn,
                         p.App_Ndt,
                         p.App_Doc_Num,
                         p.App_Fn,
                         p.App_Mn,
                         p.App_Ln
                  HAVING COUNT (d.Apd_App) <> 1)
        LOOP
            DECLARE
                FUNCTION App_Ident
                    RETURN VARCHAR2
                IS
                BEGIN
                    IF Rec.App_Inn IS NOT NULL
                    THEN
                        RETURN 'РНОКПП=' || Rec.App_Inn;
                    ELSIF Rec.App_Doc_Num IS NOT NULL
                    THEN
                        RETURN 'документ=' || Rec.App_Doc_Num;
                    ELSE
                        RETURN    'ПІБ='
                               || Pib (Rec.App_Ln, Rec.App_Fn, Rec.App_Mn);
                    END IF;
                END;
            BEGIN
                IF Rec.Cnt = 0
                THEN
                    Add_Error (
                           'Для учасника ('
                        || App_Ident
                        || ') не заповнено заяву про взяття на облік ВПО');
                END IF;

                IF Rec.Cnt > 1
                THEN
                    Add_Error (
                           'Для учасника ('
                        || App_Ident
                        || ') прив’язано більше однієї заяви про взяття на облік ВПО');
                END IF;
            END;
        END LOOP;

        --Перевіряємо, що у зверненні лише одна заява на допомогу ВПО
        SELECT COUNT (*), MAX (p.App_Tp)
          INTO l_Cnt, l_App_Tp
          FROM Ap_Document d LEFT JOIN Ap_Person p ON d.Apd_App = p.App_Id
         WHERE     d.Apd_Ap = g_Ap_Id
               AND d.Apd_Ndt = 10101
               AND d.History_Status = 'A';

        IF l_Cnt = 0
        THEN
            Add_Error ('Не заповнено заяву на допомогу на проживання ВПО');
        END IF;

        IF l_Cnt > 1
        THEN
            Add_Error (
                'Заповнено більше однієї заяви на допомогу на проживання ВПО');
        END IF;

        IF l_App_Tp <> 'Z'
        THEN
            Add_Error ('Заяву на допомогу не прив’язано до заявника');
        END IF;
    END;

    ---------------------------------------------------------------------
    --             Отримання віку учасника звернення
    ---------------------------------------------------------------------
    FUNCTION Get_App_Age (p_App_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Birth_Dt   DATE;
    BEGIN
        SELECT MAX (a.Apda_Val_Dt)
          INTO l_Birth_Dt
          FROM Ap_Document  d
               JOIN Ap_Document_Attr a ON d.Apd_Id = a.Apda_Apd
               JOIN Uss_Ndi.v_Ndi_Document_Attr n
                   ON a.Apda_Nda = n.Nda_Id AND n.Nda_Class = 'BDT'
         WHERE d.Apd_App = p_App_Id AND d.History_Status = 'A';

        IF l_Birth_Dt IS NULL
        THEN
            RETURN NULL;
        END IF;

        RETURN FLOOR (
                     MONTHS_BETWEEN (NVL (g_Ap_Reg_Dt, SYSDATE), l_Birth_Dt)
                   / 12);
    END;

    ---------------------------------------------------------------------
    --            Виключення із правил для наявності обовязкових документів
    ---------------------------------------------------------------------
    FUNCTION Is_Mssing_Doc_Exception (p_App_Id IN NUMBER, p_Ndt_Id IN NUMBER)
        RETURN BOOLEAN
    IS
    --l_attr_val_Str varchar2(10);
    BEGIN
        --ІНН не обовязковий для дітей віком до 14 років
        IF p_Ndt_Id = 5 AND Get_App_Age (p_App_Id) < 14
        THEN
            RETURN TRUE;
        END IF;

        /*
        SELECT case when count(1)>0 then 'T' else 'F' end
        INTO l_attr_val_str
        FROM ap_document_Attr a
        JOIN ap_document d
          ON a.apda_apd = d.apd_id
        WHERE d.apd_app = p_App_Id
          AND a.apda_nda in (1796, 2560)
          AND apda_val_string = 'T';

        IF l_attr_val_str='T' THEN
          RETURN TRUE;
        END IF;
        */

        RETURN FALSE;
    END;

    FUNCTION Is_Mssing_Doc_Exception_query (p_App_Id   IN NUMBER,
                                            p_Ndt_Id   IN NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        IF Is_Mssing_Doc_Exception (p_App_Id, p_Ndt_Id)
        THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END;

    ---------------------------------------------------------------------
    --             ПЕРЕВІРКА НАЯВНОСТІ ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Missing_Docs
    IS
        FUNCTION Nndc_Has_Alternatives (p_Nndc_Id        IN     NUMBER,
                                        p_Alt_Ndt_List      OUT VARCHAR2)
            RETURN BOOLEAN
        IS
        BEGIN
            SELECT LISTAGG (t.Ndt_Name_Short, '" або "')
                       WITHIN GROUP (ORDER BY t.Ndt_Name_Short)
              INTO p_Alt_Ndt_List
              FROM Uss_Ndi.v_Ndi_Nndc_Setup  s
                   JOIN Uss_Ndi.v_Ndi_Document_Type t ON s.Nns_Ndt = t.Ndt_Id
             WHERE     s.Nns_Nndc = p_Nndc_Id
                   AND s.Nns_Tp = 'AD'
                   AND s.History_Status = 'A';

            RETURN p_Alt_Ndt_List IS NOT NULL;
        END;

        FUNCTION Get_Check_Val (p_App_Id IN NUMBER, p_Nda_Id IN NUMBER)
            RETURN VARCHAR2
        IS
        BEGIN
            RETURN CASE
                       WHEN Api$appeal.Get_Person_Attr_Val_Str (p_App_Id,
                                                                p_Nda_Id) =
                            'T'
                       THEN
                           'встановлено'
                       ELSE
                           'не встановлено'
                   END;
        END;
    BEGIN
        --Обов’язкові документи, яких не вистачає у зверненні
        FOR Rec
            IN (WITH
                    Missing_Docs
                    AS
                        (SELECT c.*,
                                p.App_Id,
                                p.App_Inn,
                                p.App_Doc_Num,
                                p.app_tp
                           FROM Uss_Ndi.v_Ndi_Nst_Doc_Config  c
                                JOIN Uss_Ndi.v_Ndi_Document_Type dct
                                    ON c.nndc_ndt = dct.Ndt_Id
                                --УЧАСНИКИ
                                LEFT JOIN Uss_Visit.v_Ap_Person p
                                    ON     p.App_Ap = Api$validation.g_Ap_Id
                                       AND p.History_Status = 'A'
                                --ДОКУМЕНТИ
                                LEFT JOIN Uss_Visit.v_Ap_Document d
                                    ON     d.Apd_Ap = Api$validation.g_Ap_Id
                                       AND d.History_Status = 'A'
                                       --ОБИРАЄМО ДОКУМЕНТИ УЧАСНИКІВ
                                       AND p.App_Id = d.Apd_App
                                       AND (   d.Apd_Ndt = c.Nndc_Ndt
                                            OR --d.Apd_Ndt = c.Nndc_Ndt_Alt1 OR --#77124 20220511
                                               d.Apd_Ndt IN
                                                   (SELECT Nns_Ndt
                                                      FROM Uss_Ndi.v_Ndi_Nndc_Setup
                                                           Nns
                                                     WHERE     Nns_Nndc =
                                                               c.Nndc_Id
                                                           AND Nns_Tp = 'AD'
                                                           AND Nns.History_Status =
                                                               'A')
                                            OR (    c.Nndc_Ndc IS NOT NULL
                                                AND EXISTS
                                                        (SELECT NULL
                                                           FROM Uss_Ndi.v_Ndi_Document_Type
                                                                Dt
                                                          WHERE     Dt.Ndt_Ndc =
                                                                    c.Nndc_Ndc
                                                                AND Dt.Ndt_Id =
                                                                    d.Apd_Ndt)))
                          --LEFT JOIN Uss_Ndi.v_Ndi_Document_Type ddt
                          --    ON d.apd_ndt = ddt.Ndt_Id
                          WHERE     c.Nndc_Is_Req = 'T'
                                AND c.Nndc_Ap_Tp = Api$validation.g_Ap_Tp --#77124 20220511
                                AND c.History_Status = 'A'
                                --AND NOT (g_Ap_Src IN ('PORTAL', 'USS') AND g_Ap_Tp in ('R.OS','SS') AND p.App_Tp = 'Z'  AND nvl(ddt.ndt_ndc,0) = 2 ) --#99009
                                --#104757
                                AND NOT (    Api$validation.g_Ap_Src IN
                                                 ('PORTAL')
                                         AND p.App_Tp = 'Z'
                                         AND NVL (dct.ndt_ndc, 0) = 2)
                                --ТИП УЧАСНИКА
                                AND (   c.Nndc_App_Tp IS NULL
                                     OR c.Nndc_App_Tp = p.App_Tp)
                                --ПОСЛУГИ
                                AND (   EXISTS
                                            (SELECT NULL
                                               FROM Uss_Visit.v_Ap_Service s
                                              WHERE     s.Aps_Ap =
                                                        Api$validation.g_Ap_Id
                                                    AND s.History_Status =
                                                        'A'
                                                    AND s.Aps_Nst =
                                                        c.Nndc_Nst)
                                     OR c.Nndc_Nst IS NULL)
                                --АТРИБУТИ В ДОКУМЕНТАХ УЧАСНИКА
                                AND (   c.Nndc_Nda IS NULL
                                     OR EXISTS
                                            (SELECT NULL
                                               FROM Uss_Visit.v_Ap_Document f
                                                    JOIN
                                                    Uss_Visit.v_Ap_Document_Attr
                                                    a
                                                        ON     f.Apd_Id =
                                                               a.Apda_Apd
                                                           AND a.Apda_Nda =
                                                               c.Nndc_Nda
                                                           AND NVL (
                                                                   a.Apda_Val_String,
                                                                   '-') =
                                                               NVL (
                                                                   c.Nndc_Val_String,
                                                                   '-')
                                                           AND a.History_Status =
                                                               'A'
                                              WHERE     f.Apd_App = p.App_Id
                                                    AND f.History_Status =
                                                        'A'))
                                AND (d.Apd_Id IS NULL))
                SELECT d.Nndc_Id,
                       d.App_Id,
                       d.app_tp,
                       d.App_Inn,
                       d.App_Doc_Num,
                       At.Dic_Name
                           AS App_Tp_Name,
                       St.Nst_Name,
                       Dt.Ndt_Name_Short,
                       --Alt1.Ndt_Name_Short AS Alt1_Ndt_Name,--#77124 20220511
                        (SELECT LISTAGG (Ndt_Name_Short, ', ')
                                    WITHIN GROUP (ORDER BY Ndt_Name_Short)
                           FROM Uss_Ndi.v_Ndi_Nndc_Setup  Nns
                                JOIN Uss_Ndi.v_Ndi_Document_Type c
                                    ON     Nns.Nns_Ndt = c.Ndt_Id
                                       AND c.History_Status = 'A'
                          WHERE     Nns_Nndc = d.Nndc_Id
                                AND Nns_Tp = 'AD'
                                AND Nns.History_Status = 'A')
                           AS Alt1_Ndt_Name,
                       Nda.Nda_Name,
                       t.Pt_Edit_Type,
                       t.Pt_Ndc,
                       d.Nndc_Nda,
                       d.Nndc_Val_String,
                       c.Ndc_Name,
                       d.Nndc_Ndt
                  FROM Missing_Docs  d
                       LEFT JOIN Uss_Ndi.v_Ndi_Service_Type St
                           ON d.Nndc_Nst = St.Nst_Id
                       LEFT JOIN Uss_Ndi.v_Ddn_App_Tp At
                           ON d.Nndc_App_Tp = At.Dic_Value
                       LEFT JOIN Uss_Ndi.v_Ndi_Document_Type Dt
                           ON d.Nndc_Ndt = Dt.Ndt_Id
                       LEFT JOIN Uss_Ndi.v_Ndi_Document_Attr Nda
                           ON Nndc_Nda = Nda.Nda_Id
                       LEFT JOIN Uss_Ndi.v_Ndi_Param_Type t
                           ON Nda.Nda_Pt = t.Pt_Id
                       LEFT JOIN Uss_Ndi.v_Ndi_Document_Class c
                           ON d.Nndc_Ndc = c.Ndc_Id)
        LOOP
            DECLARE
                l_Msg            VARCHAR2 (32000) := '';
                l_Alt_Ndt_List   VARCHAR2 (4000);
            BEGIN
                IF Is_Mssing_Doc_Exception (Rec.App_Id, Rec.Nndc_Ndt)
                THEN
                    CONTINUE;
                END IF;

                --#102152
                IF API$VERIFICATION_COND.Is_Skip_801_Vf (g_Ap_Id, Rec.App_Id)
                THEN
                    CONTINUE;
                END IF;


                IF    Rec.Nst_Name IS NOT NULL
                   OR NVL (Rec.App_Inn, Rec.App_Doc_Num) IS NOT NULL
                   OR Rec.Pt_Edit_Type IS NOT NULL
                THEN
                    l_Msg := 'MissingDocsValidate: Для ';
                END IF;

                IF Rec.Nst_Name IS NOT NULL
                THEN
                    l_Msg := l_Msg || ' послуги "' || Rec.Nst_Name || '",';
                END IF;

                IF NVL (Rec.App_Inn, Rec.App_Doc_Num) IS NOT NULL
                THEN
                    l_Msg :=
                           l_Msg
                        || ' учасника ('
                        || NVL (Rec.App_Inn, Rec.App_Doc_Num)
                        || ')'
                        || CASE
                               WHEN Rec.App_Tp_Name IS NOT NULL
                               THEN
                                   ' з типом "' || Rec.App_Tp_Name || '"'
                           END
                        || ',';
                END IF;

                IF Rec.Pt_Edit_Type = 'CHECK'
                THEN
                    l_Msg :=
                           l_Msg
                        || ' в якого '
                        || Get_Check_Val (Rec.App_Id, Rec.Nndc_Nda)
                        || ' ознаку "'
                        || Rec.Nda_Name
                        || '",';
                END IF;

                IF Rec.Pt_Edit_Type = 'DDLB'
                THEN
                    l_Msg :=
                           l_Msg
                        || ' в якого '
                        || Rec.Nda_Name
                        || '="'
                        || Get_Dic_Name (p_Ndc_Id   => Rec.Pt_Ndc,
                                         p_Id       => Rec.Nndc_Val_String)
                        || '",';
                END IF;

                l_Msg := RTRIM (l_Msg, ',') || ' не додано ';

                IF Rec.Ndt_Name_Short IS NOT NULL
                THEN
                    IF Nndc_Has_Alternatives (Rec.Nndc_Id, l_Alt_Ndt_List)
                    THEN
                        l_Msg :=
                               l_Msg
                            || 'один з цих документів: "'
                            || Rec.Ndt_Name_Short
                            || '" або "'
                            || l_Alt_Ndt_List
                            || '"';
                    ELSE
                        l_Msg :=
                               l_Msg
                            || 'документ "'
                            || Rec.Ndt_Name_Short
                            || '"';
                    END IF;
                END IF;

                IF Rec.Ndc_Name IS NOT NULL
                THEN
                    l_Msg :=
                           l_Msg
                        || 'жодного документа з категорії "'
                        || Rec.Ndc_Name
                        || '"';
                END IF;

                l_Msg := TRIM (l_Msg);

                IF g_Err_On_Missing_Doc
                THEN
                    Add_Error (l_Msg);
                ELSE
                    Add_Warning (l_Msg);
                END IF;
            END;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --          ПЕРЕВІРКА ЗАПОВНЕНОСТІ АТРИБУТІВ ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Attrs_Filled
    IS
        l_Err_List   VARCHAR2 (32000);
    BEGIN
        IF g_Warnings
        THEN
            FOR Rec
                IN (  SELECT Apd_Id
                        FROM Ap_Document d
                             JOIN Ap_Person p
                                 ON     d.Apd_App = p.App_Id
                                    AND p.History_Status = 'A'
                       WHERE     d.Apd_Ap = g_Ap_Id
                             AND d.History_Status = 'A'
                             AND d.Apd_Ndt NOT IN
                                     ( --Api$appeal.c_Apd_Ndt_Pasp, -- #100131
                                     --Api$appeal.c_Apd_Ndt_Idcard, -- #100127
                                     Api$appeal.c_Apd_Ndt_Ankt,
                                     Api$appeal.c_Apd_Ndt_Zayv,
                                     Api$appeal.c_Apd_Ndt_Veteran   -- #112414
                                                                 )
                             -- #103774
                             AND (       (   Only_One_Aps_Exists_n (248) = 1
                                          OR Only_One_Aps_Exists_n (21) = 1)
                                     AND d.apd_ndt NOT IN (200)
                                  OR     Only_One_Aps_Exists_n (1221) = 1
                                     AND d.apd_ndt NOT IN (10323)
                                  OR NOT (   Only_One_Aps_Exists_n (248) = 1
                                          OR Only_One_Aps_Exists_n (21) = 1
                                          OR Only_One_Aps_Exists_n (1221) = 1))
                    ORDER BY DECODE (p.App_Tp,  'Z', 1,  'FP', 2,  3))
            LOOP
                l_Err_List :=
                    Api$validation.Check_Documents_Filled (Rec.Apd_Id);

                IF l_Err_List IS NOT NULL
                THEN
                    Add_Warning (l_Err_List);
                END IF;
            END LOOP;
        END IF;
    END;

    PROCEDURE Validate_Attrs
    IS
        CURSOR Attrs IS
              SELECT Apd_Id, n.Nnv_Tp, n.Nnv_Condition
                FROM Ap_Document d
                     JOIN Ap_Person p
                         ON d.Apd_App = p.App_Id AND p.History_Status = 'A'
                     JOIN uss_ndi.v_Ndi_Document_Attr nda
                         ON     nda.nda_ndt = d.apd_ndt
                            AND nda.History_Status = 'A'
                     JOIN Uss_Ndi.v_Ndi_Nda_Validation n
                         ON n.Nnv_Nda = nda.nda_id AND n.History_Status = 'A'
               WHERE     d.Apd_Ap = g_Ap_Id
                     AND n.Nnv_Tp = 'V'
                     AND d.History_Status = 'A'
            ORDER BY DECODE (p.App_Tp,  'Z', 1,  'FP', 2,  3);

        /*
              SELECT Apd_Id,
                     n.Nnv_Tp,
                     n.Nnv_Condition
                FROM Ap_Document d
                JOIN Ap_Person p
                  ON d.Apd_App = p.App_Id
                     AND p.History_Status = 'A'
                JOIN Ap_Document_Attr Da
                  ON Da.Apda_Apd = d.Apd_Id
                     AND Da.History_Status = 'A'
                JOIN Uss_Ndi.v_Ndi_Nda_Validation n
                  ON n.Nnv_Nda = Da.Apda_Nda
                     AND n.History_Status = 'A'
               WHERE d.Apd_Ap = g_Ap_Id
                     AND n.Nnv_Tp = 'V'
                     AND d.History_Status = 'A'
               ORDER BY Decode(p.App_Tp, 'Z', 1, 'FP', 2, 3);
        */
        CURSOR Attrs_date IS
              SELECT Apd_Id,
                     Da.Apda_Val_Dt,
                        'В документі '
                     || ndt.ndt_name_short
                     || ' введено дату після 31.12.2099. '
                     || 'Для безстрокового чи для довічного терміну необхідно зазначати дату 31.12.2099'    AS err_str
                FROM Ap_Document d
                     JOIN Ap_Person p
                         ON d.Apd_App = p.App_Id AND p.History_Status = 'A'
                     JOIN Ap_Document_Attr Da
                         ON Da.Apda_Apd = d.Apd_Id AND Da.History_Status = 'A'
                     JOIN uss_ndi.v_ndi_document_attr nda
                         ON nda.nda_id = da.apda_nda
                     JOIN uss_ndi.v_ndi_document_type ndt
                         ON ndt.ndt_id = d.apd_ndt
                     JOIN uss_ndi.v_ndi_param_type pt
                         ON pt.pt_id = nda.nda_pt AND pt.pt_data_type = 'DATE'
               WHERE     d.Apd_Ap = g_Ap_Id
                     AND d.History_Status = 'A'
                     AND Da.Apda_Val_Dt > TO_DATE ('31.12.2099', 'dd.mm.yyyy')
            ORDER BY DECODE (p.App_Tp,  'Z', 1,  'FP', 2,  3);

        CURSOR Min_Attrs_Date IS
              SELECT Apd_Id,
                     Da.Apda_Val_Dt,
                        'В документі '
                     || ndt.ndt_name_short
                     || ' введено дату до 01.01.1900'    AS err_str
                FROM Ap_Document d
                     JOIN Ap_Person p
                         ON d.Apd_App = p.App_Id AND p.History_Status = 'A'
                     JOIN Ap_Document_Attr Da
                         ON Da.Apda_Apd = d.Apd_Id AND Da.History_Status = 'A'
                     JOIN uss_ndi.v_ndi_document_attr nda
                         ON nda.nda_id = da.apda_nda
                     JOIN uss_ndi.v_ndi_document_type ndt
                         ON ndt.ndt_id = d.apd_ndt
                     JOIN uss_ndi.v_ndi_param_type pt
                         ON pt.pt_id = nda.nda_pt AND pt.pt_data_type = 'DATE'
               WHERE     d.Apd_Ap = g_Ap_Id
                     AND d.History_Status = 'A'
                     AND Da.Apda_Val_Dt < TO_DATE ('01.01.1900', 'dd.mm.yyyy')
            ORDER BY DECODE (p.App_Tp,  'Z', 1,  'FP', 2,  3);
    BEGIN
        FOR Rec IN Attrs
        LOOP
            IF Rec.Nnv_Condition IS NOT NULL
            THEN
                g_Apd_Id := Rec.Apd_Id;

                EXECUTE IMMEDIATE ' ' || Rec.Nnv_Condition;
            --dbms_output.put_line(Rec.Nnv_Condition);
            END IF;
        END LOOP;

        --#88166
        FOR Rec IN Attrs_date
        LOOP
            Add_Error (rec.err_str);
        END LOOP;

        --#100515
        FOR Rec IN Min_Attrs_Date
        LOOP
            Add_Warning (rec.err_str);
        END LOOP;
    END;

    -- #115407 Валідація емейлів
    PROCEDURE validate_attr_email
    IS
    BEGIN
        FOR xx
            IN (SELECT *
                  FROM (SELECT dt.ndt_name,
                               da.nda_name,
                               p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn
                                   AS pib,
                               CASE
                                   WHEN REGEXP_LIKE (
                                            a.apda_val_string,
                                            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')
                                   THEN
                                       1
                                   ELSE
                                       0
                               END
                                   AS is_valid
                          FROM ap_document  d
                               JOIN ap_document_attr a
                                   ON (a.apda_apd = d.apd_id)
                               JOIN ap_person p ON (p.app_id = d.apd_app)
                               JOIN uss_ndi.v_ndi_document_attr da
                                   ON (da.nda_id = a.apda_nda)
                               JOIN uss_ndi.v_ndi_document_type dt
                                   ON (dt.ndt_id = d.apd_ndt)
                         WHERE     d.apd_ap = g_Ap_Id
                               AND da.nda_class = 'EMAIL'
                               AND d.history_status = 'A'
                               AND a.history_status = 'A'
                               AND a.apda_val_string IS NOT NULL) t
                 WHERE is_valid = 0)
        LOOP
            Add_Error (
                   'Для учасника "'
                || xx.pib
                || '" в документі "'
                || xx.ndt_name
                || '" Невірно вказана електронна адреса');
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --     ПЕРЕВІРКИ ДОКУМЕНТІВ СПЕЦИФІЧНІ ДЛЯ РІЗНИХ ТИПІВ ПОСЛУГ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Svc_Specific_Docs
    IS
        l_Err_List   VARCHAR2 (32000);
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT=BINARY';

        FOR Rec
            IN (SELECT CASE
                           WHEN s.Aps_Nst IN (600,
                                              601,
                                              602,
                                              603)
                           THEN
                               'Check60x'
                           WHEN s.Aps_Nst IN (621)
                           THEN
                               'Check62x'
                           WHEN s.Aps_Nst BETWEEN 400 AND 500
                           THEN
                               'Check4xx'
                       END
                           AS Check_Proc,
                       CASE WHEN s.Aps_Nst = 664 THEN 'T' END
                           AS Check_Wrn,
                       s.Aps_Nst
                  FROM Ap_Service s
                 WHERE     s.Aps_Ap = g_Ap_Id
                       AND s.History_Status = 'A'
                       AND (   s.Aps_Nst IN (20,
                                             21,
                                             22,
                                             248,
                                             249,
                                             267,
                                             269,
                                             600,
                                             601,
                                             602,
                                             603,
                                             620,
                                             621,
                                             641,
                                             642,
                                             643,
                                             645,
                                             664,
                                             701,
                                             761,
                                             801,
                                             1141)
                            OR s.Aps_Nst BETWEEN 400 AND 500))
        LOOP
            --dbms_output.put_line('Check ' || Rec.Aps_Nst);
            DECLARE
                l_Check_Proc   VARCHAR2 (200);
            BEGIN
                l_Check_Proc :=
                       Package_Name
                    || '.'
                    || NVL (Rec.Check_Proc, 'Check' || Rec.Aps_Nst);

                --Помилки
                EXECUTE IMMEDIATE   'BEGIN '
                                 || l_Check_Proc
                                 || '(Err_List => :p_Err_List); END;'
                    USING OUT l_Err_List;

                IF l_Err_List IS NOT NULL
                THEN
                    Add_Error (l_Err_List);
                END IF;

                --Попередження
                IF g_Warnings AND Rec.Check_Wrn = 'T'
                THEN
                    EXECUTE IMMEDIATE   'BEGIN '
                                     || l_Check_Proc
                                     || '(Wrn_List => :p_Wrn_List); END;'
                        USING OUT l_Err_List;

                    IF l_Err_List IS NOT NULL
                    THEN
                        Add_Warning (l_Err_List);
                    END IF;
                END IF;
            END;
        END LOOP;
    END;

    --     ПЕРЕВІРКИ ДОКУМЕНТІВ СПЕЦИФІЧНІ ДЛЯ РІЗНИХ ТИПІВ ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Doc_Specific_Docs
    IS
        l_Err_List     VARCHAR2 (32000);
        l_Check_Proc   VARCHAR2 (200);
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT=BINARY';

        FOR Rec IN (SELECT d.apd_id, d.apd_ndt, NULL Check_Proc
                      FROM Ap_Document d
                     WHERE     d.Apd_Ap = g_Ap_Id
                           AND d.History_Status = 'A'
                           AND d.apd_ndt IN (801,
                                             802,
                                             10033,
                                             10034,
                                             10035))
        LOOP
            g_Apd_Id := rec.apd_id;
            l_Check_Proc :=
                   Package_Name
                || '.'
                || NVL (Rec.Check_Proc, 'CheckDoc' || Rec.apd_ndt);

            --Помилки
            EXECUTE IMMEDIATE 'BEGIN ' || l_Check_Proc || '; END;';
        END LOOP;
    END;

    PROCEDURE Validate_Doc_Signs
    IS
    BEGIN
        --30.10.2023: за постановкою О.Зиновець відключено контроль
        RETURN;

        IF g_Ap_Src NOT IN ('DIIA')
        THEN
            RETURN;
        END IF;

        FOR Doc
            IN (SELECT t.Ndt_Name, f.File_Name, d.Apd_Ndt
                  FROM Ap_Document  d
                       JOIN Uss_Doc.v_Doc_Attachments a
                           ON d.Apd_Dh = a.Dat_Dh AND a.Dat_Sign_File IS NULL
                       JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
                       JOIN Uss_Ndi.v_Ndi_Document_Type t
                           ON d.Apd_Ndt = t.Ndt_Id
                       JOIN Ap_Document_Attr Aa
                           ON     d.Apd_Id = Aa.Apda_Apd
                              AND Aa.History_Status = 'A'
                       LEFT JOIN Uss_Ndi.v_Ndi_Document_Attr n
                           ON Aa.Apda_Nda = n.Nda_Id AND n.Nda_Class = 'SRC'
                 WHERE     d.Apd_Ap = g_Ap_Id
                       AND d.History_Status = 'A'
                       AND d.Apd_Ndt NOT IN (10076)
                       AND NVL (Aa.Apda_Val_String, '0') = '0')
        LOOP
            IF     Doc.Apd_Ndt IN (114, 660)
               AND g_Ap_Src = 'DIIA'
               AND g_Ap_Tp = 'V'
            THEN
                CONTINUE;
            END IF;

            Add_Error (
                   'Відсутній підпис для вкладення "'
                || Doc.File_Name
                || '" в документі "'
                || Doc.Ndt_Name
                || '"');
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --                   ПЕРЕВІРКА ДОКУМЕНТІВ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Documents
    IS
        l_cnt_err   NUMBER;
    BEGIN
        Validate_Ankt;
        Validate_Zayav;
        Validate_Zayav_Veteran;

        IF g_Ap_Tp = 'G'
        THEN
            Validate_Zayav_g;
        END IF;

        IF g_Ap_Tp IN ('G', 'SS')
        THEN
            Check_Attr_Date;
        END IF;

        -- #95369
        IF g_Ap_Tp IN ('V')
        THEN
            Check_Attr_Dates;
        END IF;

        --#98075
        IF g_Ap_Tp IN ('A')
        THEN
            Check_Attr_Dates_Error;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt_err
          FROM ap_document  apd
               JOIN uss_ndi.v_ndi_document_type ndt
                   ON apd.apd_ndt = ndt.ndt_id
         WHERE     apd_ap = g_ap_id
               AND ndt.ndt_ndc = 10
               AND apd.history_status = 'A';

        --#90120
        IF    (    g_Ap_Tp IN ('G',
                               'SS',
                               'R.OS',
                               'R.GS')
               AND get_ap_doc_list_cnt (g_Ap_Id, '800,801,802,836,835,1015') >
                   1)
           OR (g_Ap_Tp IN ('SS') AND l_cnt_err > 1)
        THEN
            Add_Fatal (
                'У звернення додано більше одного ініціативного документа!');
        -- #99637
        ELSIF    (    g_Ap_Tp IN ('G',
                                  'SS',
                                  'R.OS',
                                  'R.GS')
                  AND get_ap_doc_list_cnt (g_Ap_Id,
                                           '800,801,802,836,835,700,1015') <
                      1)
              OR (g_Ap_Tp IN ('SS') AND l_cnt_err < 1)
        THEN
            Add_Fatal (
                'У звернення не додано жодного ініціативного документа!');
        END IF;


        Validate_Missing_Docs;
        Validate_Attrs_Filled;
        Validate_Attrs;
        Validate_Svc_Specific_Docs;
        Validate_Doc_Specific_Docs;
        Validate_Doc_Signs;
        validate_attr_email;
    END;

    PROCEDURE Check_Duplicates_Ss
    IS
        l_Lock       Ikis_Sys.Ikis_Lock.t_Lockhandler;
        l_Aps_List   VARCHAR2 (4000);
        l_Cnt        NUMBER;
    BEGIN
        FOR Per
            IN (SELECT *
                  FROM Ap_Person p
                 WHERE     p.App_Ap = g_Ap_Id
                       AND p.History_Status = 'A'
                       AND p.App_Tp IN ('OS'))
        LOOP
            Ikis_Sys.Ikis_Lock.Request_Lock (
                p_Permanent_Name      => Tools.Ginstance_Lock_Name,
                p_Var_Name            =>
                    'AP_DUP_SS_' || NVL (Per.App_Inn, Per.App_Doc_Num),
                p_Errmessage          => NULL,
                p_Lockhandler         => l_Lock,
                p_Timeout             => 3600,
                p_Release_On_Commit   => TRUE);

            FOR Ap
                IN (SELECT a.Ap_Id
                      FROM Appeal  a
                           JOIN Ap_Person p
                               ON     a.Ap_Id = p.App_Ap
                                  AND p.History_Status = 'A'
                     WHERE     a.Ap_Tp = 'SS'
                           AND (   p.App_Inn = Per.App_Inn
                                OR (    p.App_Doc_Num = Per.App_Doc_Num
                                    AND p.App_Ndt = Per.App_Ndt))
                           AND p.App_Tp IN ('OS')
                           AND a.Ap_Id <> g_Ap_Id)
            LOOP
                SELECT LISTAGG (Nst_Name, '", "') WITHIN GROUP (ORDER BY 1),
                       COUNT (*)
                  INTO l_Aps_List, l_Cnt
                  FROM Ap_Service  s
                       JOIN Ap_Service Ss
                           ON     Ss.Aps_Ap = Ap.Ap_Id
                              AND s.Aps_Nst = Ss.Aps_Nst
                              AND Ss.History_Status = 'A'
                       JOIN Uss_Ndi.v_Ndi_Service_Type t
                           ON Ss.Aps_Nst = t.Nst_Id
                 WHERE     s.Aps_Ap = g_Ap_Id
                       AND s.History_Status = 'A'
                       AND s.Aps_Nst BETWEEN 400 AND 500;

                IF l_Cnt > 0
                THEN
                    Add_Fatal (
                           'Для '
                        || Per.App_Ln
                        || ' '
                        || Per.App_Fn
                        || ' '
                        || Per.App_Mn
                        || ' вже подано заяву на послуг'
                        || CASE WHEN l_Cnt = 1 THEN 'у' ELSE 'и' END
                        || ' "'
                        || l_Aps_List
                        || '"');
                END IF;
            END LOOP;
        END LOOP;
    END;

    ---------------------------------------------------------------------
    --        ПЕРЕВІРКА НА НАЯВНІСТЬ ДУБЛІКАТІВ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Check_Duplicates
    IS
    BEGIN
        IF NOT g_Ap_Tp IN ('SS')
        THEN
            RETURN;
        END IF;

        EXECUTE IMMEDIATE 'BEGIN CHECK_DUPLICATES_' || g_Ap_Tp || ' END;';
    END;

    ---------------------------------------------------------------------
    --              ПЕРЕВІРКА ВСІХ СКЛАДОВИХ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    PROCEDURE Validate_Appeal (
        p_Ap_Id                IN Appeal.Ap_Id%TYPE,
        p_Warnings             IN BOOLEAN,
        p_Raise_Fatal_Err      IN BOOLEAN,
        p_Err_On_Missing_Doc   IN BOOLEAN DEFAULT TRUE,
        p_Check_Doc_Num_Attr   IN BOOLEAN DEFAULT TRUE,
        p_Error_To_Warning     IN BOOLEAN DEFAULT FALSE)
    IS
    BEGIN
        Init (p_Ap_Id                => p_Ap_Id,
              p_Warnings             => p_Warnings,
              p_Raise_Fatal_Err      => p_Raise_Fatal_Err,
              p_Err_On_Missing_Doc   => p_Err_On_Missing_Doc,
              p_Error_To_Warning     => p_Error_To_Warning);
        Validate_Appeal;
        Validate_Services;
        Validate_Payments;
        Validate_Persons (p_Check_Doc_Num_Attr => p_Check_Doc_Num_Attr);
        Validate_Documents;
        Validate_Declaration;
    END;

    ---------------------------------------------------------------------
    --              ПЕРЕВІРКА ВСІХ СКЛАДОВИХ ЗВЕРНЕННЯ
    ---------------------------------------------------------------------
    FUNCTION Validate_Appeal (
        p_Ap_Id                IN Appeal.Ap_Id%TYPE,
        p_Warnings             IN BOOLEAN,
        p_Raise_Fatal_Err      IN BOOLEAN,
        p_Err_On_Missing_Doc   IN BOOLEAN DEFAULT TRUE,
        p_Check_Doc_Num_Attr   IN BOOLEAN DEFAULT TRUE,
        p_Error_To_Warning     IN BOOLEAN DEFAULT FALSE)
        RETURN t_Messages
    IS
    BEGIN
        Validate_Appeal (p_Ap_Id                => p_Ap_Id,
                         p_Warnings             => p_Warnings,
                         p_Raise_Fatal_Err      => p_Raise_Fatal_Err,
                         p_Err_On_Missing_Doc   => p_Err_On_Missing_Doc,
                         p_Check_Doc_Num_Attr   => p_Check_Doc_Num_Attr,
                         p_Error_To_Warning     => p_Error_To_Warning);
        RETURN g_Messages;
    END;

    PROCEDURE Validate_Appeal_Test (
        p_Ap_Id              IN Appeal.Ap_Id%TYPE,
        p_Error_To_Warning   IN BOOLEAN DEFAULT FALSE)
    IS
        l_Validation_Messages   Api$validation.t_Messages;
    BEGIN
        l_Validation_Messages :=
            Api$validation.Validate_Appeal (
                p_Ap_Id              => p_Ap_Id,
                p_Warnings           => TRUE,
                p_Raise_Fatal_Err    => FALSE,
                p_Error_To_Warning   => p_Error_To_Warning);

        FOR vI IN (  SELECT *
                       FROM TABLE (l_Validation_Messages) t
                   ORDER BY DECODE (t.Msg_Tp,  'F', 1,  'E', 2,  3))
        LOOP
            DBMS_OUTPUT.put_line (vI.Msg_Tp_Name || ': ' || vI.Msg_Text);
        END LOOP;
    END;

    PROCEDURE Test
    IS
    BEGIN
        DBMS_OUTPUT.Put_Line (
               ' >>>>>>  '
            || Utl_Call_Stack.Subprogram (2) (1)
            || '.'
            || Utl_Call_Stack.Subprogram (2) (2));
    END;

    FUNCTION Ap_Is_Valid
        RETURN BOOLEAN
    IS
        l_Cnt   NUMBER;
    BEGIN
        IF g_Messages IS NULL
        THEN
            RETURN TRUE;
        END IF;

        IF g_Messages.COUNT = 0
        THEN
            RETURN TRUE;
        END IF;

        IF g_Warnings
        THEN
            --З врахуванням попереджень
            SELECT COUNT (*) INTO l_Cnt FROM TABLE (g_Messages);
        ELSE
            --Без врахування попереджень
            SELECT COUNT (*)
              INTO l_Cnt
              FROM TABLE (g_Messages)
             WHERE Msg_Tp <> 'W';
        END IF;

        RETURN l_cnt = 0;
    END;

    ---------------------------------------------------------------------
    --            ДЛЯ ДЕБАГА
    ---------------------------------------------------------------------
    PROCEDURE Dbms_Output_Appeal_Info (p_Id NUMBER)
    IS
        CURSOR Ap IS
            SELECT *
              FROM Appeal
             WHERE Ap_Id = p_Id;

        CURSOR Apm (p_Ap_Id NUMBER)
        IS
            SELECT *
              FROM Ap_Payment p
             WHERE Apm_Ap = p_Ap_Id;

        CURSOR Sr (p_Ap_Id NUMBER)
        IS
            SELECT *
              FROM Ap_Service s
             WHERE Aps_Ap = p_Ap_Id;

        CURSOR z (p_Ap_Id NUMBER)
        IS
            SELECT *
              FROM Ap_Person
             WHERE App_Ap = p_Ap_Id AND App_Tp IN ('Z', 'O');

        CURSOR Fp (p_Ap_Id NUMBER)
        IS
            SELECT *
              FROM Ap_Person
             WHERE App_Ap = p_Ap_Id AND App_Tp IN ('FP', 'OD');

        CURSOR Fm (p_Ap_Id NUMBER)
        IS
            SELECT *
              FROM Ap_Person
             WHERE App_Ap = p_Ap_Id AND App_Tp = 'FM';

        CURSOR Th (p_Ap_Id NUMBER)
        IS
            SELECT *
              FROM Ap_Person
             WHERE     App_Ap = p_Ap_Id
                   AND App_Tp NOT IN ('Z',
                                      'O',
                                      'FP',
                                      'OD',
                                      'FM');

        CURSOR Doc (p_App_Id NUMBER)
        IS
            SELECT Apd.Apd_Id,
                   Apd.Apd_App,
                   Apd.Apd_Ndt,
                   Ndt.Ndt_Name_Short,
                      Apd.History_Status
                   || ' apd_ndt='
                   || RPAD (Apd.Apd_Ndt, 6, ' ')
                   || ' '
                   || Ndt.Ndt_Name_Short    Doc
              FROM Ap_Document  Apd
                   INNER JOIN Uss_Ndi.v_Ndi_Document_Type Ndt
                       ON Ndt.Ndt_Id = Apd.Apd_Ndt
             WHERE p_App_Id = Apd.Apd_App;

        CURSOR Atr (p_Apd_Id NUMBER)
        IS
            WITH
                Atr
                AS
                    (  SELECT Apda.Apda_Apd,
                              Apda.Apda_Id,
                              Apda.History_Status,
                              CASE Pt_Data_Type
                                  WHEN 'STRING'
                                  THEN
                                      Apda_Val_String
                                  WHEN 'INTEGER'
                                  THEN
                                      TO_CHAR (Apda_Val_Int)
                                  WHEN 'SUM'
                                  THEN
                                      TO_CHAR (Apda_Val_Sum)
                                  WHEN 'ID'
                                  THEN
                                      TO_CHAR (Apda_Val_Id)
                                  WHEN 'DATE'
                                  THEN
                                      TO_CHAR (Apda_Val_Dt, 'dd.mm.yyyy')
                                  ELSE
                                      '???'
                              END                                AS Apda_Val,
                              Nda.Nda_Id,
                              NVL (Nda.Nda_Name, Npt.Pt_Name)    Nda_Name,
                              --nda.nda_nng, (select nng.nng_name from uss_ndi.v_ndi_nda_group nng where nng.nng_id=nda.nda_nng) nng_name,
                              Npt.Pt_Data_Type
                         FROM Ap_Document_Attr Apda
                              INNER JOIN Uss_Ndi.v_Ndi_Document_Attr Nda
                                  ON Nda.Nda_Id = Apda.Apda_Nda
                              INNER JOIN Uss_Ndi.v_Ndi_Param_Type Npt
                                  ON Npt.Pt_Id = Nda.Nda_Pt
                     ORDER BY 1, 2)
              SELECT Apda_Apd,
                     LISTAGG (
                            LPAD (' ', 12, ' ')
                         || History_Status
                         || '  '
                         || Nda_Id
                         || '  '
                         || Nda_Name
                         || ' = '
                         || Apda_Val,
                         CHR (13) || CHR (10))
                     WITHIN GROUP (ORDER BY Apda_Apd)    Apda_List
                FROM Atr
               WHERE Apda_Val IS NOT NULL AND Atr.Apda_Apd = p_Apd_Id
            GROUP BY Apda_Apd;

        ------------------------------
        PROCEDURE Unload_Doc (p_Ap_Id NUMBER)
        IS
        BEGIN
            FOR Docum IN Doc (p_Ap_Id)
            LOOP
                DBMS_OUTPUT.Put_Line ('        ' || Docum.Doc);

                FOR a IN Atr (Docum.Apd_Id)
                LOOP
                    DBMS_OUTPUT.Put_Line (a.Apda_List);
                END LOOP;
            END LOOP;
        END;
    ------------------------------
    BEGIN
        Test;

        FOR d IN Ap
        LOOP
            DBMS_OUTPUT.Put_Line (
                '  Ap_Tp = ' || d.Ap_Tp || '  Ap_src = ' || d.Ap_src);

            FOR s IN Sr (d.Ap_Id)
            LOOP
                DBMS_OUTPUT.Put_Line ('    nst >> ' || s.Aps_Nst);
            END LOOP;

            DBMS_OUTPUT.Put_Line ('    ');

            FOR s IN Apm (d.Ap_Id)
            LOOP
                DBMS_OUTPUT.Put_Line (
                       '    apm >> Apm_aps='
                    || s.Apm_aps
                    || '  Apm_app='
                    || s.Apm_app);
            END LOOP;

            DBMS_OUTPUT.Put_Line ('    ');

            FOR p IN z (d.Ap_Id)
            LOOP
                DBMS_OUTPUT.Put_Line (
                       '    '
                    || p.App_Tp
                    || '  inn='
                    || p.app_inn
                    || '  ndt='
                    || p.app_ndt
                    || '  doc_num='
                    || p.app_doc_num
                    || '  '
                    || p.History_Status);

                IF p.App_Sc IS NULL
                THEN
                    DBMS_OUTPUT.Put_Line (
                        '    app_id=' || RPAD (p.App_Id, 8, ' '));
                ELSE
                    DBMS_OUTPUT.Put_Line (
                           '    app_id='
                        || RPAD (p.App_Id, 8, ' ')
                        || '  '
                        || Uss_Person.Api$sc_Tools.Get_Pib (p.App_Sc));
                END IF;

                Unload_Doc (p.App_Id);
            END LOOP;

            DBMS_OUTPUT.Put_Line ('    ');

            FOR p IN Fp (d.Ap_Id)
            LOOP
                DBMS_OUTPUT.Put_Line (
                       '    '
                    || p.App_Tp
                    || '  inn='
                    || p.app_inn
                    || '  ndt='
                    || p.app_ndt
                    || '  doc_num='
                    || p.app_doc_num
                    || '  '
                    || p.History_Status);

                IF p.App_Sc IS NULL
                THEN
                    DBMS_OUTPUT.Put_Line (
                        '    app_id=' || RPAD (p.App_Id, 8, ' '));
                ELSE
                    DBMS_OUTPUT.Put_Line (
                           '    app_id='
                        || RPAD (p.App_Id, 8, ' ')
                        || '  '
                        || Uss_Person.Api$sc_Tools.Get_Pib (p.App_Sc));
                END IF;

                Unload_Doc (p.App_Id);
            END LOOP;

            DBMS_OUTPUT.Put_Line ('    ');

            FOR p IN Fm (d.Ap_Id)
            LOOP
                DBMS_OUTPUT.Put_Line (
                       '    '
                    || p.App_Tp
                    || '  inn='
                    || p.app_inn
                    || '  ndt='
                    || p.app_ndt
                    || '  doc_num='
                    || p.app_doc_num
                    || '  '
                    || p.History_Status);

                IF p.App_Sc IS NULL
                THEN
                    DBMS_OUTPUT.Put_Line (
                        '    app_id=' || RPAD (p.App_Id, 8, ' '));
                ELSE
                    DBMS_OUTPUT.Put_Line (
                           '    app_id='
                        || RPAD (p.App_Id, 8, ' ')
                        || '  '
                        || Uss_Person.Api$sc_Tools.Get_Pib (p.App_Sc));
                END IF;

                Unload_Doc (p.App_Id);
            END LOOP;

            DBMS_OUTPUT.Put_Line ('    ');

            FOR p IN Th (d.Ap_Id)
            LOOP
                DBMS_OUTPUT.Put_Line (
                       '    '
                    || p.App_Tp
                    || '  inn='
                    || p.app_inn
                    || '  ndt='
                    || p.app_ndt
                    || '  doc_num='
                    || p.app_doc_num
                    || '  '
                    || p.History_Status);

                IF p.App_Sc IS NULL
                THEN
                    DBMS_OUTPUT.Put_Line (
                        '    app_id=' || RPAD (p.App_Id, 8, ' '));
                ELSE
                    DBMS_OUTPUT.Put_Line (
                           '    app_id='
                        || RPAD (p.App_Id, 8, ' ')
                        || '  '
                        || Uss_Person.Api$sc_Tools.Get_Pib (p.App_Sc));
                END IF;

                Unload_Doc (p.App_Id);
            END LOOP;
        END LOOP;
    END;
END Api$validation;
/