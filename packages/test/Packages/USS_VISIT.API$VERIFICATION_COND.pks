/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.Api$verification_Cond
IS
    -- Author  : LESHA
    -- Created : 01.06.2022 11:45:39
    -- Purpose :

    --==============================================================--
    --  Отримання текстового параметру документу по учаснику
    --==============================================================--
    FUNCTION Get_Doc_String (p_App       Ap_Document.Apd_App%TYPE,
                             p_Ndt       Ap_Document.Apd_Ndt%TYPE,
                             p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                             p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    -- Повернути AP_TP
    FUNCTION Get_Ap_Tp (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2;

    --==============================================================--
    --  Ознака «Категорія отримувача соціальних послуг»
    --==============================================================--
    FUNCTION Isrecip_Ss (p_App Ap_Document.Apd_App%TYPE)
        RETURN NUMBER;

    -- Чи потрібно запитувати
    FUNCTION Isneed_Decl_For_Ss (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN;

    -- Чи потрібно запитувати доходи з ПФУ для соцпослуг
    FUNCTION Isneed_Pfu_For_Ss (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Need_Dps_Incomes_For_Ss (p_Ap_Id    IN NUMBER,
                                         p_App_Id   IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Need_Incomes_For_Ss (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Need_Dps_Incomes_For_Vpo (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Ext_Process (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Vpo_Pkg (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Need_App_Vf (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Need_Nsp_Mju_Vf (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_All_App_Docs_Verified (p_App_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_All_App_Doc_Vf_Finished (p_App_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Need_Mfu_Vf (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Attach_Exists (p_Apd_Id IN NUMBER)
        RETURN BOOLEAN;


    FUNCTION Is_Verified_Or_Not_Exists (p_Ap_Id    IN NUMBER,
                                        p_Vf_Nvt   IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_Apd_Ap_Tp_Exists (p_Apd_Ap         IN NUMBER,
                                  p_Apd_Ndt_List   IN VARCHAR2,
                                  p_Ap_Tp          IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Is_Apd_Exists (p_Apd_Ap IN NUMBER, p_Apd_Ndt_List IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Is_Apd_In_List (p_Apd_Id IN NUMBER, p_Apd_Ndt_List IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Is_Apd_For_Person_Exists (p_App_Id         IN NUMBER,
                                       p_Apd_Ndt_List   IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Is_Exists_App_Doc_To_Dfs_Rnokpp_Verify (p_App_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Ap_Aps_Amount (p_Ap_Id          IN NUMBER,
                            p_Aps_Nst_List   IN VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;

    FUNCTION Is_Skip_801_Vf (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN;

    FUNCTION Is_App_Vf_Err_Type_Exists (p_ap_id         IN NUMBER,
                                        p_err_tp_list   IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Appeal_Main_Vf_Callback (p_Ap_Id   IN NUMBER,
                                       p_Vf_St   IN VARCHAR2);

    FUNCTION Is_Veteran (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN BOOLEAN;

    FUNCTION Get_Veteran_App_Id (p_Ap_Id IN Ap_Person.App_Ap%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Z_App_Id (p_Ap_Id IN Ap_Person.App_Ap%TYPE)
        RETURN NUMBER;

    FUNCTION Get_Person_Vf_St (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Veteran_Vf_St (p_Ap_Id IN Appeal.Ap_Id%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_App_Ap (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN NUMBER;
END Api$verification_Cond;
/


/* Formatted on 8/12/2025 5:59:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.Api$verification_Cond
IS
    /*
    Api$appeal.Declaration_Exists(:ap)
    --#72638
    OR (Api$appeal.Get_Person_Tp(:app) = 'FP' AND aps_exists(:ap, 268) AND
     Api$appeal.Get_Person_Relation_Tp(:app) = 'CHRG')
    --#73136
    OR aps_exist(:ap, '249,267')
    */

    /*
    (
      Api$verification_cond.Get_AP_TP(:ap) != 'SS' AND
      (  Api$appeal.Declaration_Exists(:ap)
         --#72638
         OR (Api$appeal.Get_Person_Tp(:app) = 'FP' AND aps_exists(:ap, 268) AND Api$appeal.Get_Person_Relation_Tp(:app) = 'CHRG')
         --#73136
        OR aps_exist(:ap, '249,267')
      )
    )
    or
    (
      Api$verification_cond.Get_AP_TP(:ap) = 'SS' AND
      Api$verification_cond.IsNeed_PFU_For_SS(:ap, :app)
    )
    */

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
    --  Ознака «Категорія отримувача соціальних послуг»
    --==============================================================--
    FUNCTION Isrecip_Ss (p_App Ap_Document.Apd_App%TYPE)
        RETURN NUMBER
    IS
        l_Rez   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO l_Rez
          FROM Ap_Document
               JOIN Ap_Document_Attr
                   ON     Apda_Apd = Apd_Id
                      AND Ap_Document_Attr.History_Status = 'A'
               JOIN Uss_Ndi.v_Ndi_Document_Attr ON Apda_Nda = Nda_Id
         WHERE     Ap_Document.History_Status = 'A'
               AND Apd_App = p_App
               AND Apd_Ndt = 605                                     -- Анкета
               AND Nda_Nng = 19    -- «Категорія отримувача соціальних послуг»
               AND NVL (Apda_Val_String, 'F') = 'T';

        RETURN SIGN (l_Rez);
    END;

    --==============================================================--
    --  Отримання текстового параметру документу по зверненю
    --==============================================================--
    FUNCTION Get_Ap_Doc_String (p_Ap        Ap_Document.Apd_Ap%TYPE,
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
               AND Apd_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        IF p_Default IS NOT NULL
        THEN
            RETURN NVL (l_Rez, p_Default);
        END IF;

        RETURN l_Rez;
    END;

    --==============================================================--
    --  Повернути AP_TP
    --==============================================================--
    FUNCTION Get_Ap_Tp (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Ap_Tp   VARCHAR2 (10);
    BEGIN
        SELECT MAX (Ap_Tp)
          INTO l_Ap_Tp
          FROM Appeal
         WHERE Ap_Id = p_Ap_Id;

        RETURN l_Ap_Tp;
    END;

    --==============================================================--
    --  Чи потрібно запитувати Декларацію для соцпослуг
    --==============================================================--
    FUNCTION Isneed_Decl_For_Ss (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        CURSOR App IS
            SELECT p.App_Id
              FROM Ap_Person p
             WHERE     App_Ap = p_Ap_Id
                   AND p.History_Status = 'A'
                   AND p.App_Tp = 'Z';
    BEGIN
        FOR Rec IN App
        LOOP
            IF Is_Need_Incomes_For_Ss (p_Ap_Id, Rec.App_Id)
            THEN
                RETURN TRUE;
            END IF;
        END LOOP;

        RETURN FALSE;
    END;

    --==============================================================--
    --  Чи потрібно запитувати доходи з ПФУ для соцпослуг
    --==============================================================--
    FUNCTION Isneed_Pfu_For_Ss (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Is_Need_Incomes_For_Ss (p_Ap_Id, p_App_Id);
    END;

    --==============================================================--
    --  Чи потрібно запитувати доходи в ДПС для соцпослуг
    --==============================================================--
    FUNCTION Is_Need_Dps_Incomes_For_Ss (p_Ap_Id    IN NUMBER,
                                         p_App_Id   IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        IF     Is_Apd_For_Person_Exists (p_App_Id, 37)
           AND NOT Is_Apd_For_Person_Exists (p_App_Id, 5)
           AND NOT (   Is_Apd_For_Person_Exists (p_App_Id, 6)
                    OR Is_Apd_For_Person_Exists (p_App_Id, 7))
        THEN
            RETURN FALSE;
        END IF;

        RETURN Is_Need_Incomes_For_Ss (p_Ap_Id, p_App_Id);
    END;

    --==============================================================--
    --  Чи потрібно запитувати доходи для соцпослуг
    --==============================================================--
    FUNCTION Is_Need_Incomes_For_Ss (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Cnt_Pay_Serv   NUMBER (10);
        l_Os_Recip_Ss    NUMBER (10);
        l_Fm_Recip_Ss    NUMBER (10);
        l_Emergency      VARCHAR2 (200);
        l_Ss_Needs801    VARCHAR2 (200);
        l_Ss_Needs802    VARCHAR2 (200);
        l_Ss_Method      VARCHAR2 (200);
        l_Provideserv    VARCHAR2 (200);
    BEGIN
        --#103476
        IF Is_Apd_Exists (p_Ap_Id, '802, 803, 1015')
        THEN
            RETURN FALSE;
        END IF;

        IF (   Get_Ap_Doc_String (p_Ap_Id,
                                  801,
                                  1871,
                                  'F') = 'T'
            OR Get_Ap_Doc_String (p_Ap_Id,
                                  802,
                                  1948,
                                  'F') = 'T'
            OR Get_Ap_Doc_String (p_Ap_Id,
                                  803,
                                  2528,
                                  'F') = 'T'
            OR Get_Ap_Doc_String (p_Ap_Id,
                                  835,
                                  3265,
                                  'F') = 'T'
            OR Get_Ap_Doc_String (p_Ap_Id,
                                  836,
                                  3446,
                                  'F') = 'T')
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;

        --В терии, остальной код не нужен.
        Dbms_Output_Put_Lines ('p_App_Id = ' || p_App_Id);

        /*
        Z   Заявник
        FM  Член сім’ї
        OS  Особа, що потребує СП
        OR  Законний представник особи, що потребує СП
        AG  Уповноважена особа органу опіки та піклування
        AP  Уповноважена особа надавача
        AF  Уповноважений представник сім’ї
        I   Інший суб’єкт повідомлення/інформації
        */

        --  802, 1944  Соціальних послуг потребує STRING  V_DDN_SS_NEEDS

        BEGIN
            SELECT CASE
                       WHEN Api$verification_Cond.Get_Doc_String (App_Id,
                                                                  801,
                                                                  1870,
                                                                  'F') = 'T'
                       THEN
                           'T'
                       WHEN Api$verification_Cond.Get_Doc_String (App_Id,
                                                                  802,
                                                                  1947,
                                                                  'F') = 'T'
                       THEN
                           'T'
                       WHEN Api$verification_Cond.Get_Doc_String (App_Id,
                                                                  803,
                                                                  2032,
                                                                  'F') = 'T'
                       THEN
                           'T'
                       ELSE
                           'F'
                   END       AS Emergency,
                   Api$verification_Cond.Get_Doc_String (App_Id,
                                                         801,
                                                         1868,
                                                         '-'),
                   Api$verification_Cond.Get_Doc_String (App_Id,
                                                         802,
                                                         1944,
                                                         '-'),
                   Api$verification_Cond.Get_Doc_String (App_Id,
                                                         801,
                                                         1869,
                                                         '-'),
                   Api$verification_Cond.Get_Doc_String (App_Id,
                                                         801,
                                                         1895,
                                                         '-'),
                   NVL (
                       (SELECT SUM (
                                   Api$verification_Cond.Isrecip_Ss (App_Id))
                          FROM Ap_Person p
                         WHERE     App_Ap = p_Ap_Id
                               AND p.App_Tp = 'OS'
                               AND p.History_Status = 'A'),
                       0)    AS Recip_Ss_Os,
                   NVL (
                       (SELECT SUM (
                                   Api$verification_Cond.Isrecip_Ss (App_Id))
                          FROM Ap_Person p
                         WHERE     App_Ap = p_Ap_Id
                               AND p.App_Tp = 'FM'
                               AND p.History_Status = 'A'),
                       0)    AS Recip_Ss_Fm
              INTO l_Emergency,
                   l_Ss_Needs801,
                   l_Ss_Needs802,
                   l_Ss_Method,
                   l_Provideserv,
                   l_Os_Recip_Ss,
                   l_Fm_Recip_Ss
              FROM Ap_Person p
             WHERE     App_Ap = p_Ap_Id
                   AND p.App_Tp = 'Z'
                   AND p.History_Status = 'A';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN FALSE;
        END;

        -- При збереженні/переведенні у статус "Зареєстровано" (?) картки звернення про надання СП додати контроль на необхідність заповнення вкладки «Декларація» і виконання шерінг-запитів до ПФУ та ДПС щодо доходів отримувача.
        --Заповнювати вкладку і виконувати запити не потрібно, якщо виконується хоча б одна з наступних умов:
        -- значення атрибуту «Екстрено (кризово)» = «Так» у документах:
        -- «Заява про надання соціальних послуг» ndt_id=801 / nda_id in (1870)
        -- «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 / nda_id in (1947)
        -- «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803 / nda_id in (2032)
        -- abo
        -- в документі «Заява про надання соціальних послуг» ndt_id=801 значення атрибуту «Спосіб надання соціальних послуг nda_id in (1869) = «платно»
        IF l_Emergency = 'T' OR l_Ss_Method = 'C'
        THEN
            RETURN FALSE;
        END IF;

        --- обрані у зверненні соціальні послуги мають значення ознаки «Послуга безоплатна для всіх категорій отримувачів» = «Так» ndi_service_type.nst_is_payed=F
        SELECT COUNT (1)
          INTO l_Cnt_Pay_Serv
          FROM Uss_Ndi.v_Ndi_Service_Type
               JOIN Ap_Service Aps
                   ON Aps.Aps_Nst = Nst_Id AND Aps.History_Status = 'A'
         WHERE Aps.Aps_Ap = p_Ap_Id AND Nst_Is_Payed != 'F';

        IF l_Cnt_Pay_Serv = 0
        THEN
            RETURN FALSE;
        END IF;

        -- у документі «Заява про надання соціальних послуг» ndt_id=801 вказано «Соціальних послуг потребує» nda_id in (1868)=«Особа» і:
        -- значення атрибуту «Послугу надати» nda_id in (1895)=«мені» (тобто заявнику) і в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так»
        -- значення атрибуту «Послугу надати» nda_id in (1895)=«моєму(їй) синові (доньці)»/«підопічному(ій)»,
        --    у зверненні є учасник з типом «Особа, що потребує соціальних послуг» і в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так»
        IF     l_Ss_Needs801 = 'Z'
           AND l_Provideserv = 'Z'
           AND Isrecip_Ss (p_App_Id) = 1
        THEN
            RETURN FALSE;
        ELSIF     l_Ss_Needs801 = 'Z'
              AND l_Provideserv = 'B'
              AND l_Os_Recip_Ss > 0
        THEN
            RETURN FALSE;
        END IF;

        -- у документі
        -- «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 вказано «Соціальних послуг потребує» nda_id in (1944)=«Особа»,
        --у зверненні є учасник з типом «Особа, що потребує соціальних послуг» і в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так»

        IF l_Ss_Needs802 = 'Z' AND l_Os_Recip_Ss > 0
        THEN
            RETURN FALSE;
        END IF;

        -- у документах
        -- «Заява про надання соціальних послуг» ndt_id=801 вказано «Соціальних послуг потребує» nda_id in (1868)=«Сім’я»
        -- «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 вказано «Соціальних послуг потребує» nda_id in (1944)=«Сім’я»
        --і у зверненні немає учасника з типом «Особа, що потребує соціальних послуг», але є учасник з типом «Член сім’ї» і в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так»

        IF     (l_Ss_Needs801 = 'FM' OR l_Ss_Needs802 = 'FM')
           AND l_Os_Recip_Ss = 0
           AND l_Fm_Recip_Ss > 0
        THEN
            RETURN FALSE;
        END IF;

        RETURN TRUE;
    END;

    --==============================================================--
    --  Чи потрібно запитувати доходи в ДПС для соцпослуг
    --==============================================================--
    FUNCTION Is_Need_Dps_Incomes_For_Vpo (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Api$appeal.Get_Ap_Reg_Dt (p_Ap_Id) >=
               TO_DATE ('01.03.2024', 'dd.mm.yyyy');
    END;

    --==============================================================--
    --  Чи буде звернення відпрацьовуватись лише у зовніщній системи
    --==============================================================--
    FUNCTION Is_Ext_Process (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Is_Ext_Process   VARCHAR2 (10);
    BEGIN
        SELECT NVL (
                   CASE
                       --Тимчасова заглушка для єДопомоги.
                       --прибрати піля виконання скрипта: update appeal set ap_is_ext_process='F' where ap_tp='IA';
                       WHEN a.Ap_Tp = 'IA' THEN 'F'
                       ELSE a.Ap_Is_Ext_Process
                   END,
                   'F')
          INTO l_Is_Ext_Process
          FROM Appeal a
         WHERE a.Ap_Id = p_Ap_Id;

        RETURN l_Is_Ext_Process = 'T';
    END;

    --==============================================================--
    --  Чи є заява пакетом заяв ВПО
    --==============================================================--
    FUNCTION Is_Vpo_Pkg (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN     Api$appeal.Document_Exists (p_Ap_Id, 10100)
               AND Api$appeal.Document_Exists (p_Ap_Id, 10101);
    END;

    --==============================================================--
    --  Чи потрібно виконувати верифікацію учасника звернення
    --==============================================================--
    FUNCTION Is_Need_App_Vf (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Ap_Tp   VARCHAR2 (10);
    BEGIN
        IF Aps_Exist (p_Ap_Id, '642')
        THEN
            RETURN FALSE;
        END IF;

        l_Ap_Tp := Api$appeal.Get_Ap_Tp (p_Ap_Id);

        IF l_Ap_Tp IN ('U', 'A', 'PP')
        THEN
            RETURN FALSE;
        END IF;

        --Якщо це пакетна заява ВПО
        IF    Api$appeal.Document_Exists (p_Ap_Id, 10100)
           OR Api$appeal.Document_Exists (p_Ap_Id, 10101)
        THEN
            --Верифікація учасника виконується лише за умови проходження "технологічного" контролю заяви
            RETURN Api$validation.Ap_Is_Valid;
        END IF;

        --Для звернень що обролюються зовнішніми системами
        IF Api$verification_Cond.Is_Ext_Process (p_Ap_Id)
        THEN
            --Виконуємо верифікацію заявника
            RETURN    Api$appeal.Get_Person_Tp (p_App_Id) = 'Z'
                   --Або іншиш учасників, для звернень на допомогу від Дії, що передаються до СГ
                   OR (    l_Ap_Tp = 'V'
                       AND Api$appeal.Get_Ap_Src (p_Ap_Id) = 'DIIA'
                       AND Api$appeal.Document_Exists (p_Ap_Id, 600)
                       AND Api$community.Is_Ext_Pass (p_Ap_Id));
        END IF;

        RETURN TRUE;
    END;

    FUNCTION Is_Skip_801_Vf (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_is_801_exists   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_is_801_exists
          FROM appeal ap JOIN ap_person app ON app.app_ap = ap.ap_id
         WHERE     ap_id = p_Ap_Id
               AND ap.ap_src = 'CMES'
               AND ap.ap_sub_tp = 'SZ'
               AND app.app_tp = 'AP'             --Уповноважена особа надавача
               AND app.app_id = p_App_Id
               AND EXISTS
                       (SELECT 1
                          FROM ap_document apd
                         WHERE apd_ap = ap.ap_id AND apd.apd_id = 801);

        RETURN l_is_801_exists > 0;
    END;

    --==============================================================--
    --  Чи всі верифікації документів учасника успішні
    --==============================================================--
    FUNCTION Is_All_App_Docs_Verified (p_App_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Not_Verified_Cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_Not_Verified_Cnt
          FROM Ap_Document  d
               JOIN Verification v ON d.Apd_Vf = Vf_Id
               JOIN Uss_Ndi.v_Ndi_Document_Type t ON d.Apd_Ndt = t.Ndt_Id
         WHERE     d.Apd_App = p_App_Id
               AND d.History_Status = 'A'
               AND v.Vf_St <> 'X'
               AND (t.Ndt_Ndc = 13 OR d.Apd_Ndt = 5);

        RETURN l_Not_Verified_Cnt = 0;
    END;

    --==============================================================--
    --  Чи завершено всі верифікації документів учасника
    --==============================================================--
    FUNCTION Is_All_App_Doc_Vf_Finished (p_App_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Unfinished_Cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_Unfinished_Cnt
          FROM Ap_Document d JOIN Verification v ON d.Apd_Vf = Vf_Id
         WHERE     d.Apd_App = p_App_Id
               AND d.History_Status = 'A'
               AND v.Vf_St = 'R';

        RETURN l_Unfinished_Cnt = 0;
    END;

    --==============================================================--
    --  Умова, що визначає необхідність превентивної верифікації МФУ
    --==============================================================--
    FUNCTION Is_Need_Mfu_Vf (p_Ap_Id IN NUMBER, p_App_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Pay_Id    VARCHAR2 (20);
        l_Need_Vf   NUMBER;
    BEGIN
        --Отримуємо код виплати для мінфіну
        FOR Rec IN (SELECT *
                      FROM Ap_Service s
                     WHERE s.Aps_Ap = p_Ap_Id AND s.History_Status = 'A')
        LOOP
            l_Pay_Id :=
                Uss_Ndi.Tools.Decode_Dict (p_Nddc_Tp         => 'NST_ID',
                                           p_Nddc_Src        => 'USS',
                                           p_Nddc_Dest       => 'MFU',
                                           p_Nddc_Code_Src   => Rec.Aps_Nst);

            IF l_Pay_Id IS NOT NULL
            THEN
                EXIT;
            END IF;
        END LOOP;

        IF l_Pay_Id IS NULL
        THEN
            RETURN FALSE;
        END IF;

        SELECT CASE
                   WHEN    (    p.App_Inn IS NOT NULL
                            AND p.App_Inn <> '0000000000')
                        OR (p.App_Ndt IN (6, 7) AND p.App_Doc_Num IS NOT NULL)
                   THEN
                       1
               END
          INTO l_Need_Vf
          FROM Ap_Person p
         WHERE p.App_Id = p_App_Id;

        RETURN NVL (l_Need_Vf, 0) = 1;
    END;

    --==============================================================--
    --  Умова, що визначає необхідність верифікації НСН у МЮУ
    --==============================================================--
    FUNCTION Is_Need_Nsp_Mju_Vf (p_Ap_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Qnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Qnt
          FROM Appeal ap
         WHERE ap.ap_id = p_Ap_Id AND ap.ap_sub_tp IN ('GA', 'GU', 'GD');

        RETURN l_Qnt > 0;
    END;


    FUNCTION Is_Attach_Exists (p_Apd_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Attach_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Attach_Exists
          FROM Ap_Document  d
               JOIN Uss_Doc.v_Doc_Attachments a ON d.Apd_Dh = a.Dat_Dh
         WHERE d.Apd_Id = p_Apd_Id AND a.Dat_File IS NOT NULL;

        RETURN l_Attach_Exists = 1;
    END;

    FUNCTION Is_Verified_Or_Not_Exists (p_Ap_Id    IN NUMBER,
                                        p_Vf_Nvt   IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Unverified_Cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_Unverified_Cnt
          FROM Ap_Document d JOIN Verification v ON d.Apd_Vf = v.Vf_Id
         WHERE     d.Apd_Ap = p_Ap_Id
               AND d.History_Status = 'A'
               AND v.Vf_Nvt = p_Vf_Nvt
               AND v.Vf_St <> ('X');

        /*IF p_Vf_Nvt = 34 THEN
          Raise_Application_Error(-20000, 'test ' || l_Unverified_Cnt);
        END IF;*/

        RETURN l_Unverified_Cnt = 0;
    END;

    FUNCTION Is_Apd_Ap_Tp_Exists (p_Apd_Ap         IN NUMBER,
                                  p_Apd_Ndt_List   IN VARCHAR2,
                                  p_Ap_Tp          IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Apd_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Apd_Exists
          FROM Ap_Document d JOIN Appeal a ON d.apd_ap = a.ap_id
         WHERE     d.Apd_Ap = p_Apd_Ap
               AND d.Apd_Ndt IN
                       (SELECT TO_NUMBER (COLUMN_VALUE)
                          FROM XMLTABLE (p_Apd_Ndt_List))
               AND a.ap_tp = p_Ap_Tp
               AND d.History_Status = 'A';

        RETURN l_Apd_Exists = 1;
    END;

    FUNCTION Is_Apd_Exists (p_Apd_Ap IN NUMBER, p_Apd_Ndt_List IN VARCHAR2)
        RETURN BOOLEAN
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

        RETURN l_Apd_Exists = 1;
    END;

    FUNCTION Is_Apd_In_List (p_Apd_Id IN NUMBER, p_Apd_Ndt_List IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Apd_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Apd_Exists
          FROM Ap_Document d
         WHERE     d.Apd_Id = p_Apd_Id
               AND d.Apd_Ndt IN
                       (SELECT TO_NUMBER (COLUMN_VALUE)
                          FROM XMLTABLE (p_Apd_Ndt_List))
               AND d.History_Status = 'A';

        RETURN l_Apd_Exists = 1;
    END;

    FUNCTION Is_Apd_For_Person_Exists (p_App_Id         IN NUMBER,
                                       p_Apd_Ndt_List   IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Apd_Exists   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Apd_Exists
          FROM Ap_Document d
         WHERE     d.apd_app = p_App_Id
               AND d.Apd_Ndt IN
                       (SELECT TO_NUMBER (COLUMN_VALUE)
                          FROM XMLTABLE (p_Apd_Ndt_List))
               AND d.History_Status = 'A';

        RETURN l_Apd_Exists = 1;
    END;

    FUNCTION Ap_Aps_Amount (p_Ap_Id          IN NUMBER,
                            p_Aps_Nst_List   IN VARCHAR2 DEFAULT NULL)
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_res
          FROM ap_service s
         WHERE     aps_ap = p_Ap_Id
               AND (   s.aps_nst IN
                           (SELECT TO_NUMBER (COLUMN_VALUE)
                              FROM XMLTABLE (p_Aps_Nst_List))
                    OR p_Aps_Nst_List IS NULL)
               AND NVL (history_status, 'A') = 'A';

        RETURN l_res;
    END;

    --==============================================================--
    --  Перевірка необхідності веріфікацій РНОКПП в ДПС
    --==============================================================--
    FUNCTION Is_Exists_App_Doc_To_Dfs_Rnokpp_Verify (p_App_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Docs_Cnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Docs_Cnt
          FROM Ap_Person Ap JOIN Ap_Document Apd ON Apd.Apd_App = Ap.App_Id
         WHERE Ap.App_Id = p_App_Id AND Apd.Apd_Ndt = 5;

        RETURN l_Docs_Cnt > 0;
    END;

    FUNCTION Is_App_Vf_Err_Type_Exists (p_ap_id         IN NUMBER,
                                        p_err_tp_list   IN VARCHAR2)
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (1))
          INTO l_res
          FROM (    SELECT v.*, fl.*
                      FROM Uss_Visit.Verification v
                           JOIN V_VF_LOG fl ON v.vf_id = fl.vfl_vf
                START WITH v.Vf_Id IN (SELECT a.Ap_Vf
                                         FROM Uss_Visit.Appeal a
                                        WHERE a.Ap_Id IN (p_ap_id))
                CONNECT BY PRIOR v.Vf_Id = v.Vf_Vf_Main)
         WHERE vfl_tp IN
                   (    SELECT REGEXP_SUBSTR (p_err_tp_list,
                                              '[^,]+',
                                              1,
                                              LEVEL)
                          FROM DUAL
                    CONNECT BY LEVEL <= REGEXP_COUNT (p_err_tp_list, '[^,]+'));

        RETURN l_res;
    END;

    PROCEDURE Appeal_Main_Vf_Callback (p_Ap_Id   IN NUMBER,
                                       p_Vf_St   IN VARCHAR2)
    IS
        l_Ap_Tp                  VARCHAR2 (10);
        l_Ap_Src                 VARCHAR2 (10);
        l_Ap_Ap_Main             NUMBER;
        l_Unlinked_Persons       VARCHAR2 (4000);
        l_Unlinked_Persons_Cnt   NUMBER;
        l_correct_status         VARCHAR2 (10);
        l_Ap_Vf_Res              VARCHAR2 (10);
    BEGIN
        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              =>
                UPPER (
                    'USS_VISIT.Api$verification_Cond.Appeal_Main_Vf_Callback'),
            p_obj_tp           => 'APPEAL',
            p_obj_id           => p_Ap_Id,
            p_regular_params   => 'Start. p_Vf_St=' || p_Vf_St);

        l_Ap_Src := Api$appeal.Get_Ap_Src (p_Ap_Id);
        l_Ap_Tp := Api$appeal.Get_Ap_Tp (p_Ap_Id);
        l_Ap_Ap_Main := Api$appeal.Get_Ap_Ap_Main (p_Ap_Id);

        --110653
        IF     l_Ap_Tp = 'SS'
           AND l_Ap_Src = 'CMES'
           AND (p_Vf_St = 'X' OR Api$appeal.Document_Exists (p_Ap_Id, 802))
        THEN
            l_correct_status :=
                CASE
                    WHEN Api$appeal.Document_Exists (p_Ap_Id, 802) THEN 'F'
                    WHEN p_Vf_St = 'X' THEN NULL
                    ELSE 'F'
                END;

            Api$Appeal.Save_Ap_Correct_Status (
                p_Ap_Id               => p_Ap_Id,
                p_ap_correct_status   => l_correct_status);

            --Звернення кейс-менеджера повинен підтвердити керівник надавача СП
            UPDATE Appeal
               SET Ap_St = 'WB'
             WHERE Ap_Id = p_Ap_Id;

            IKIS_SYS.Ikis_Procedure_Log.LOG (
                p_src              =>
                    UPPER (
                        'USS_VISIT.Api$verification_Cond.Appeal_Main_Vf_Callback'),
                p_obj_tp           => 'APPEAL',
                p_obj_id           => p_Ap_Id,
                p_regular_params   => 'Finish for CM HEAD approve');

            RETURN;
        END IF;

        --Успішна верифікація
        IF p_Vf_St = 'X'
        THEN
            IF     Api$verification_Cond.Is_Ext_Process (p_Ap_Id)
               AND NOT l_Ap_Tp = 'IA'
            THEN
                IKIS_SYS.Ikis_Procedure_Log.LOG (
                    p_src              =>
                        UPPER (
                            'USS_VISIT.Api$verification_Cond.Appeal_Main_Vf_Callback'),
                    p_obj_tp           => 'APPEAL',
                    p_obj_id           => p_Ap_Id,
                    p_regular_params   => 'Finish by existing process');
                RETURN;
            END IF;

            IF NOT Api$ap2sc.Is_All_App_Has_Sc (
                       p_Ap_Id,
                       p_Unlinked_Persons       => l_Unlinked_Persons,
                       p_Unlinked_Persons_Cnt   => l_Unlinked_Persons_Cnt)
            THEN
                IF l_Ap_Src IN ('EHLP')
                THEN
                    Api$appeal.Write_Log (
                        p_Apl_Ap   => p_Ap_Id,
                        p_Apl_Hs   => Tools.Gethistsession,
                        p_Apl_St   => 'VO',
                        p_Apl_Message   =>
                               CHR (38)
                            || CASE
                                   WHEN l_Unlinked_Persons_Cnt = 1 THEN '71'
                                   ELSE '70'
                               END
                            || '#'
                            || l_Unlinked_Persons);
                END IF;

                IF l_Ap_Tp NOT IN ('G')
                THEN
                    IKIS_SYS.Ikis_Procedure_Log.LOG (
                        p_src              =>
                            UPPER (
                                'USS_VISIT.Api$verification_Cond.Appeal_Main_Vf_Callback'),
                        p_obj_tp           => 'APPEAL',
                        p_obj_id           => p_Ap_Id,
                        p_regular_params   => 'Finish for unlinked persons');
                    RETURN;
                END IF;
            END IF;

            IF l_Ap_Tp IN ('U',
                           'V',
                           'VV',
                           'A',
                           'SS',
                           'IA',
                           'O',
                           'VPO',
                           'PP',
                           'R.OS',
                           'R.GS')
            THEN
                IF l_Ap_Tp IN ('SS')
                THEN
                    Api$Appeal.Save_Ap_Correct_Status (p_Ap_Id => p_Ap_Id);
                END IF;

                Api$visit_Action.Preparecopy_Visit2esr (p_Ap       => p_Ap_Id,
                                                        p_St_Old   => 'VW');
                API$Visit_Action.Save_Sc_Contact (p_Ap_Id);
            ELSIF l_Ap_Tp IN ('REG')
            THEN
                IF Aps_Exists (p_Ap_Id, 1141)
                THEN
                    -- #103626-57 ...окрему гілку проходження. Після проходження успішної верифікації буде статус "Виконано"
                    Api$ap2sc.Update_Benefits_Data (p_Ap_Id    => p_Ap_Id,
                                                    p_Vf_Res   => l_Ap_Vf_Res);

                    -- 19/02/2025 serhii for #116593
                    IF l_Ap_Vf_Res = 'ERR'
                    THEN
                        UPDATE Appeal
                           SET Ap_St = 'VE'
                         WHERE Ap_Id = p_Ap_Id;

                        Api$appeal.Write_Log (
                            p_Apl_Ap        => p_Ap_Id,
                            p_Apl_Hs        => Tools.Gethistsession (NULL),
                            p_Apl_St        => 'VE',
                            p_Apl_Message   =>
                                'Помилка оновлення даних по пільгам.',
                            p_Apl_St_Old    => 'VW',
                            p_Apl_Tp        => Api$appeal.c_Apl_Tp_Terror);
                    ELSE
                        -- Valentina, 18:56
                        -- Олексій а Ви можете зробити щоб зернення копіювалось в єср???
                        Api$visit_Action.Preparecopy_Visit2esr (
                            p_Ap       => p_Ap_Id,
                            p_St_Old   => 'VW');
                    END IF;
                ELSE
                    Api$visit_Action.Preparecopy_Visit2esr (
                        p_Ap       => p_Ap_Id,
                        p_St_Old   => 'VW');
                END IF;
            ELSIF l_Ap_Tp IN ('G')
            THEN
                Api$visit_Action.Preparecopy_Visit2rnsp (p_Ap       => p_Ap_Id,
                                                         p_St_Old   => 'VW');
            ELSIF l_Ap_Tp IN ('D') AND Aps_Exists (p_Ap_Id, 701)
            THEN
                Api$visit_Action.Preparecopy_Visit2rnsp (p_Ap       => p_Ap_Id,
                                                         p_St_Old   => 'F');
            ELSIF l_Ap_Tp = 'D' AND Aps_Exists (p_Ap_Id, 761)
            THEN
                Api$visit_Action.Preparecopy_Visit2esr (p_Ap       => p_Ap_Id,
                                                        p_St_Old   => 'F');
            ELSIF l_Ap_Tp = 'D' AND Aps_Exists (p_Ap_Id, 981)
            THEN
                Api$visit_Action.Preparecopy_Visit2esr (p_Ap       => p_Ap_Id,
                                                        p_St_Old   => 'F');
            ELSIF l_Ap_Tp = 'D' AND Aps_Exists (p_Ap_Id, 61)
            THEN
                Api$visit_Action.Preparecopy_Visit2esr (p_Ap       => p_Ap_Id,
                                                        p_St_Old   => 'F');
            ELSIF l_Ap_Tp = 'D'
            THEN
                Api$visit_Action.Preparecopy_Visit2esr (p_Ap       => p_Ap_Id,
                                                        p_St_Old   => 'VW');
            ELSIF l_Ap_Tp = 'DD'
            THEN
                Api$visit_Action.Preparecopy_Visit2esr (p_Ap       => p_Ap_Id,
                                                        p_St_Old   => 'VW');
            ELSIF l_Ap_Tp = 'CH_SRKO'
            THEN
                Api$visit_Action.Preparecopy_Visit2esr (p_Ap       => p_Ap_Id,
                                                        p_St_Old   => 'F');
                API$Visit_Action.Save_Sc_Contact (p_Ap_Id);
            END IF;

            Uss_Visit.Dnet$community.Reg_Appeal_Status_Send (
                p_Ap_Id   => p_Ap_Id,
                p_Ap_St   => 'S');
            Dnet$appeal_Ext.Reg_Diia_Status_Send_Req (
                p_Ap_Id     => p_Ap_Id,
                p_Ap_St     => 'S',
                p_Message   => CHR (38) || '52');
        ELSE
            --Неуспішна верифікація
            Uss_Visit.Dnet$community.Reg_Appeal_Status_Send (
                p_Ap_Id   => p_Ap_Id);
            Dnet$appeal_Ext.Reg_Diia_Status_Send_Req (p_Ap_Id   => p_Ap_Id,
                                                      p_Ap_St   => 'VE');
            Dnet$exch_Mju.Reg_Dracs_Application_Result_Req (
                p_Ap_Id   => p_Ap_Id,
                p_Ap_St   => 'VE');

            IF     l_Ap_Tp = 'D'
               AND Aps_Exists (p_Ap_Id, 981)
               AND l_Ap_Src = 'PFU'
            THEN
                uss_visit.dnet$exch_uss2ikis.Reg_Appeal_Bnf01_Send (
                    p_ap_id   => p_Ap_Id);
            END IF;

            IF     l_Ap_Tp IN ('SS')
               AND TOOLS.Get_Param_Val_def ('USE_LS', '1') = '1'
            THEN
                Api$Appeal.Save_Ap_Correct_Status (p_Ap_Id => p_Ap_Id);

                IF     NOT (    Is_Apd_Exists (p_Apd_Ap         => p_Ap_Id,
                                               p_Apd_Ndt_List   => '801')
                            AND l_Ap_Ap_Main IS NOT NULL)
                   --#108758
                   AND (   API$VERIFICATION_COND.Ap_Aps_Amount (p_Ap_Id) = 1
                        OR NOT Is_Apd_Exists (p_Apd_Ap         => p_Ap_Id,
                                              p_Apd_Ndt_List   => '801'))
                   --#105489
                   AND Is_App_Vf_Err_Type_Exists (p_Ap_Id, 'F') = 0
                THEN
                    Api$visit_Action.Preparecopy_Visit2esr (
                        p_Ap       => p_Ap_Id,
                        p_St_Old   => 'VW');
                    API$Visit_Action.Save_Sc_Contact (p_Ap_Id);
                END IF;
            END IF;
        END IF;

        IKIS_SYS.Ikis_Procedure_Log.LOG (
            p_src              =>
                UPPER (
                    'USS_VISIT.Api$verification_Cond.Appeal_Main_Vf_Callback'),
            p_obj_tp           => 'APPEAL',
            p_obj_id           => p_Ap_Id,
            p_regular_params   => 'Finish');
    EXCEPTION
        WHEN OTHERS
        THEN
            IKIS_SYS.Ikis_Procedure_Log.LOG (
                p_src              =>
                    UPPER (
                        'USS_VISIT.Api$verification_Cond.Appeal_Main_Vf_Callback'),
                p_obj_tp           => 'APPEAL',
                p_obj_id           => p_Ap_Id,
                p_regular_params   => 'Exception.',
                p_lob_param        =>
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace);
            Api$appeal.Write_Log (
                p_Apl_Ap        => p_Ap_Id,
                p_Apl_Hs        => Tools.Gethistsession (NULL),
                p_Apl_St        => 'VW',
                p_Apl_Message   =>
                       'Помилка обробки звернення після верифікації: '
                    || SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.Format_Error_Stack
                    || DBMS_UTILITY.Format_Error_Backtrace,
                p_Apl_Tp        => Api$appeal.c_Apl_Tp_Terror);
    END;

    --==============================================================--
    --  #103626  Чи має учасник в анкеті ознаку Ветеран?
    -- changed by #113654
    --==============================================================--
    FUNCTION Is_Veteran_OLD (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN BOOLEAN
    IS
    BEGIN
        IF Api$appeal.Get_Person_Attr_Val_Str (p_App_Id   => p_App_Id,
                                               p_Nda_Id   => 8420) =
           'T'
        THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    --==============================================================--
    --  #103626  Повертає App_Id учасника звернення, що в анкеті має Підтип заявника "Ветеран"
    --  якщо не знайдено або більше одного - повертає NULL
    -- changed by #113654
    --==============================================================--
    FUNCTION Get_Veteran_App_Id_OLD (p_Ap_Id IN Ap_Person.App_Ap%TYPE)
        RETURN NUMBER
    IS
        l_App_Id   Ap_Person.App_Id%TYPE;
    BEGIN
        SELECT App_Id
          INTO l_App_Id
          FROM Ap_Document_Attr  a
               JOIN Ap_Document d ON apda_apd = apd_id
               JOIN Ap_Person p ON p.app_id = d.apd_app
         WHERE     p.App_Ap = p_Ap_Id
               AND p.history_status = 'A'
               AND a.history_status = 'A'
               AND apda_nda = 8420
               AND apda_val_string = 'T'
               AND apd_ndt = 605
               AND d.history_status = 'A';

        RETURN l_App_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --==============================================================--
    --  #113654 Ветерана визначаємо за ознакою "Статус пільговика для ветерана війни"
    --==============================================================--
    FUNCTION Is_Veteran (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN BOOLEAN
    IS
    BEGIN
        IF Api$appeal.Get_Person_Attr_Val_Str (p_App_Id   => p_App_Id,
                                               p_Nda_Id   => 8333)
               IS NULL
        THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    END;

    --==============================================================--
    --  #113654 App_Id учасника звернення визначаємо за
    -- ознакою "Статус пільговика для ветерана війни"
    --==============================================================--
    FUNCTION Get_Veteran_App_Id (p_Ap_Id IN Ap_Person.App_Ap%TYPE)
        RETURN NUMBER
    IS
        l_App_Id   Ap_Person.App_Id%TYPE;
    BEGIN
        SELECT d.apd_app
          INTO l_App_Id
          FROM Ap_Document_Attr a JOIN Ap_Document d ON apda_apd = apd_id
         WHERE     d.apd_ap = p_Ap_Id
               AND a.history_status = 'A'
               AND apda_nda = 8333     -- Статус пільговика для ветерана війни
               AND a.apda_val_string IS NOT NULL -- 21/01/2025 serhii: changed by #114756-2 from: IN('WAR', 'INV', 'FGT')
               AND apd_ndt = 605                                     -- Анкета
               AND d.history_status = 'A';

        RETURN l_App_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --==============================================================--
    --  #103626  Повертає App_Id заявника звернення
    --  якщо не знайдено або більше одного - повертає NULL
    --==============================================================--
    FUNCTION Get_Z_App_Id (p_Ap_Id IN Ap_Person.App_Ap%TYPE)
        RETURN NUMBER
    IS
        l_App_Id   Ap_Person.App_Id%TYPE;
    BEGIN
        SELECT App_Id
          INTO l_App_Id
          FROM Ap_Person p
         WHERE     p.app_ap = p_Ap_Id
               AND p.history_status = 'A'
               AND p.app_tp = 'Z';

        RETURN l_App_Id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --==============================================================--
    --  #103626 Повертає стан верифікації учасника звернення по App_Id
    --==============================================================--
    FUNCTION Get_Person_Vf_St (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN VARCHAR2
    IS
        l_Vf_St   Verification.Vf_St%TYPE := Api$verification.c_Vf_St_Reg;
    BEGIN
        SELECT v.vf_st
          INTO l_Vf_St
          FROM Ap_Person p JOIN Verification v ON p.app_vf = v.vf_id
         WHERE p.app_id = p_App_Id AND v.vf_obj_tp = 'P';

        RETURN NVL (l_Vf_St, Api$verification.c_Vf_St_Reg);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN l_Vf_St;
    END;

    --==============================================================--
    --  #103626 Повертає стан верифікації учасника звернення, що в анкеті має Підтип заявника "Ветеран"
    --==============================================================--
    FUNCTION Get_Veteran_Vf_St (p_Ap_Id IN Appeal.Ap_Id%TYPE)
        RETURN VARCHAR2
    IS
        l_App_Id   Ap_Person.App_Id%TYPE;
        l_Vf_St    Verification.Vf_St%TYPE;
    BEGIN
        l_App_Id := Get_Veteran_App_Id (p_Ap_Id);
        l_Vf_St := Get_Person_Vf_St (l_App_Id);

        RETURN l_Vf_St;
    END;

    FUNCTION Get_App_Ap (p_App_Id IN Ap_Person.App_Id%TYPE)
        RETURN NUMBER
    IS
        l_App_Ap   Ap_Person.App_Ap%TYPE;
    BEGIN
        SELECT p.app_ap
          INTO l_App_Ap
          FROM Ap_Person p
         WHERE p.app_id = p_App_Id;

        RETURN l_App_Ap;
    END;
END Api$verification_Cond;
/