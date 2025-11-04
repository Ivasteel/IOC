/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$RNSP
IS
    -- Author  : LESHA
    -- Created : 07.11.2022 16:30:45
    -- Purpose :

    -- Пошук в ЄСП та РНСП попередніх звернень надавача по ЄДРПОУ/РНОКПП/реквізитам документу, що посвідчує особу
    PROCEDURE FIND (P_NUMIDENT         VARCHAR2,
                    P_RNOKPP           VARCHAR2,
                    P_RNOKPP_MIS       VARCHAR2,
                    P_PASS_NUM         VARCHAR2,
                    P_Appeal       OUT SYS_REFCURSOR,
                    P_RNSP         OUT SYS_REFCURSOR);


    PROCEDURE Register_Document_for_AP (p_ap_id NUMBER);

    -- виконувати повне копіювання обраного звернення в нове
    --за виключенням документу «Рішення про включення / повернення на доопрацювання надавачем поданих документів» ndt_id=730
    PROCEDURE copy_Appeal (p_ap_id           Appeal.Ap_Id%TYPE,
                           p_new_ap_id   OUT Appeal.Ap_Id%TYPE);

    -- копіювати з обраного звернення:
    -- всі наявні атрибути надавача
    -- перелік послуг у блок «Вид послуги».
    PROCEDURE copy_RNSP (p_RNSPM_ID        Appeal.Ap_Ext_Ident%TYPE,
                         p_new_ap_id   OUT Appeal.Ap_Id%TYPE);
END DNET$RNSP;
/


GRANT EXECUTE ON USS_VISIT.DNET$RNSP TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET$RNSP TO II01RC_USS_VISIT_WEB
/


/* Formatted on 8/12/2025 6:00:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$RNSP
IS
    /*
    При натисканні кнопки «Шукати» з пов’язаної задачі виконувати:
    1) Пошук в ЄСП попередніх звернень надавача по ЄДРПОУ/РНОКПП/реквізитам документу, що посвідчує особу:
    - якщо введено ЄДРПОУ – пошук по атрибуту ndt_id=700 and nda_id=955
    - якщо введено РНОКПП – пошук по атрибуту ndt_id=700 and nda_id=961
    - якщо введено документ – пошук по атрибуту ndt_id=700 and nda_id=962

    Якщо звернення знайдені, то виводити модальне вікно з переліком знайдених звернень такого вигляду:
    - грід з колонками:
    -- чек-бокс для обрання звернення – обрати можна тільки одне звернення
    -- № звернення
    -- Дата реєстрації
    -- Статус звернення
    -- Заявник – ПІБ учасника звернення «Заявник»
    -- ЄДРПОУ/РНОКПП/Документ
    -- Повна назва/прізвище
    -- Тип особи
    -- Ознака головна/філіал

    - кнопки:
    -- Обрати
    -- Скасувати.
    При натисканні «Обрати»:
    - виконувати повне копіювання обраного звернення в нове за виключенням документу «Рішення про включення / повернення на доопрацювання надавачем поданих документів» ndt_id=730 (за наявності)

    Якщо звернення не було виділено, виводити повідомлення «Не обрано жодного звернення!»

    При збереженні створеного звернення всі скани зберігати заново.

    2) Якщо в ЄСП звернень надавача не знайдено, то виконувати пошук в РНСП. Якщо надавача знайдено (мігровані надавачі), то виводити модальне вікно з переліком знайдених надавачів
    (варіант наявності філіалів) такого вигляду:
    - грід з колонками:
    -- чек-бокс для обрання надавача – обрати можна тільки одного надавача
    -- ЄДРПОУ/РНОКПП/Документ
    -- Повна назва/прізвище
    -- Тип особи
    -- Ознака головна/філіал – атрибут з задачі #80964
    -- Статус

    - кнопки:
    -- Обрати
    -- Скасувати.
    При натисканні «Обрати» копіювати з обраного звернення:
    - всі наявні атрибути надавача
    - перелік послуг у блок «Вид послуги».

    Якщо надавача не було виділено, виводити повідомлення «Надавача не обрано!»

    3) Якщо надавача не знайдено ні в ЄСП, ні в РНСП, то вивести повідомлення – «За введеними даними надавача не знайдено. Створіть нове звернення».
    При закритті користувачем повідомлення створити документ «Заява надавача соціальних послуг» ndt_id=700, у відповідний атрибут якого підставити значення, по якому виконувався пошук:
    - ЄДРПОУ – підставляти в nda_id=955
    - РНОКПП – підставляти в nda_id=961
    - Ознака відмови особи від РНОКПП – встановлювати nda_id in (960)=T
    - Реквізити документу, що посвідчує особу – підставляти в nda_id=962.

    Все інше – атрибути, послуги, документи – реєстратор повинен буде внести вручну.
    */

    -- ЄДРПОУ
    -- РНОКПП
    -- Ознака відмови особи від РНОКПП - чек-бокс
    -- Реквізити документу, що посвідчує особу
    -- Function and procedure implementations
    PROCEDURE FIND (P_NUMIDENT         VARCHAR2,
                    P_RNOKPP           VARCHAR2,
                    P_RNOKPP_MIS       VARCHAR2,
                    P_PASS_NUM         VARCHAR2,
                    P_Appeal       OUT SYS_REFCURSOR,
                    P_RNSP         OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF P_NUMIDENT IS NOT NULL
        THEN
            OPEN P_Appeal FOR
                SELECT ap.ap_id,
                       ap.ap_num,                               -- № звернення
                       ap.ap_reg_dt,                        -- Дата реєстрації
                       (SELECT s.DIC_SNAME
                          FROM uss_ndi.v_ddn_ap_st s
                         WHERE s.DIC_VALUE = ap.ap_st)
                           AS st_name,                     -- Статус звернення
                       app.app_fn || ' ' || app.app_mn || ' ' || app.app_ln
                           AS PIB, -- Заявник – ПІБ учасника звернення «Заявник»
                       apda.apda_val_string
                           AS NUMIDENT, -- ЄДРПОУ/РНОКПП/Документ --955 Код ЄДРПОУ STRING
                       API$Appeal.Get_Attr_Val_String (
                           p_Apd_Id   => apd.apd_id,
                           p_Nda_Id   => 956)
                           AS ORG_NAME, -- Повна назва/прізвище --956 Повне найменування юридичної особи
                       (SELECT s.DIC_SNAME
                          FROM uss_ndi.v_ddn_rnsp_tp s
                         WHERE s.DIC_VALUE =
                               API$Appeal.Get_Attr_Val_String (
                                   p_Apd_Id   => apd.apd_id,
                                   p_Nda_Id   => 953))
                           AS RNSP_TP,                            -- Тип особи
                       (SELECT s.DIC_SNAME
                          FROM uss_ndi.V_DDN_RNSP_ORG_TP s
                         WHERE s.DIC_VALUE =
                               API$Appeal.Get_Attr_Val_String (
                                   p_Apd_Id   => apd.apd_id,
                                   p_Nda_Id   => 1131))
                           AS RNSP_ORG_TP             -- Ознака головна/філіал
                                         ,
                       ''
                           AS addr
                  FROM appeal  ap
                       JOIN ap_person app
                           ON     app.app_ap = ap.ap_id
                              AND app.app_tp = 'Z'
                              AND app.history_status = 'A'
                       JOIN ap_document apd
                           ON     apd.apd_ap = ap.ap_id
                              AND apd.apd_ndt = 700
                              AND apd.history_status = 'A'
                       JOIN ap_document_attr apda
                           ON     apda.apda_apd = apd.apd_id
                              AND apda.apda_nda = 955
                              AND apda.history_status = 'A'
                 WHERE apda.apda_val_string LIKE '%' || P_NUMIDENT || '%';
        ELSIF P_RNOKPP IS NOT NULL
        THEN
            OPEN P_Appeal FOR
                SELECT ap.ap_id,
                       ap.ap_num,                               -- № звернення
                       ap.ap_reg_dt,                        -- Дата реєстрації
                       (SELECT s.DIC_SNAME
                          FROM uss_ndi.v_ddn_ap_st s
                         WHERE s.DIC_VALUE = ap.ap_st)
                           AS st_name,                     -- Статус звернення
                       app.app_fn || ' ' || app.app_mn || ' ' || app.app_ln
                           AS PIB, -- Заявник – ПІБ учасника звернення «Заявник»
                       apda.apda_val_string
                           AS NUMIDENT, -- ЄДРПОУ/РНОКПП/Документ --961 РНОКПП STRING
                          API$Appeal.Get_Attr_Val_String (
                              p_Apd_Id   => apd.apd_id,
                              p_Nda_Id   => 963)
                       || ' '
                       || API$Appeal.Get_Attr_Val_String (
                              p_Apd_Id   => apd.apd_id,
                              p_Nda_Id   => 964)
                       || ' '
                       || API$Appeal.Get_Attr_Val_String (
                              p_Apd_Id   => apd.apd_id,
                              p_Nda_Id   => 965)
                           AS ORG_NAME,    -- Повна назва/прізвище 963+964+965
                       (SELECT s.DIC_SNAME
                          FROM uss_ndi.v_ddn_rnsp_tp s
                         WHERE s.DIC_VALUE =
                               API$Appeal.Get_Attr_Val_String (
                                   p_Apd_Id   => apd.apd_id,
                                   p_Nda_Id   => 953))
                           AS RNSP_TP,                            -- Тип особи
                       (SELECT s.DIC_SNAME
                          FROM uss_ndi.V_DDN_RNSP_ORG_TP s
                         WHERE s.DIC_VALUE =
                               API$Appeal.Get_Attr_Val_String (
                                   p_Apd_Id   => apd.apd_id,
                                   p_Nda_Id   => 1131))
                           AS RNSP_ORG_TP             -- Ознака головна/філіал
                                         ,
                       ''
                           AS addr
                  FROM appeal  ap
                       JOIN ap_person app
                           ON     app.app_ap = ap.ap_id
                              AND app.app_tp = 'Z'
                              AND app.history_status = 'A'
                       JOIN ap_document apd
                           ON     apd.apd_ap = ap.ap_id
                              AND apd.apd_ndt = 700
                              AND apd.history_status = 'A'
                       JOIN ap_document_attr apda
                           ON     apda_apd = apd.apd_id
                              AND apda.apda_nda = 961
                              AND apda.history_status = 'A'
                 WHERE     apda.apda_val_string LIKE '%' || P_RNOKPP || '%'
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM ap_document_attr apda1
                                 WHERE     apda1.apda_apd = apd.apd_id
                                       AND apda1.apda_nda = 960
                                       AND apda1.history_status = 'A'
                                       AND apda1.apda_val_string = 'T');
        ELSIF P_PASS_NUM IS NOT NULL
        THEN
            OPEN P_Appeal FOR
                SELECT ap.ap_id,
                       ap.ap_num,                               -- № звернення
                       ap.ap_reg_dt,                        -- Дата реєстрації
                       (SELECT s.DIC_SNAME
                          FROM uss_ndi.v_ddn_ap_st s
                         WHERE s.DIC_VALUE = ap.ap_st)
                           AS st_name,                     -- Статус звернення
                       app.app_fn || ' ' || app.app_mn || ' ' || app.app_ln
                           AS PIB, -- Заявник – ПІБ учасника звернення «Заявник»
                       apda.apda_val_string
                           AS NUMIDENT, -- ЄДРПОУ/РНОКПП/Документ --961 РНОКПП STRING
                          API$Appeal.Get_Attr_Val_String (
                              p_Apd_Id   => apd.apd_id,
                              p_Nda_Id   => 963)
                       || ' '
                       || API$Appeal.Get_Attr_Val_String (
                              p_Apd_Id   => apd.apd_id,
                              p_Nda_Id   => 964)
                       || ' '
                       || API$Appeal.Get_Attr_Val_String (
                              p_Apd_Id   => apd.apd_id,
                              p_Nda_Id   => 965)
                           AS ORG_NAME,    -- Повна назва/прізвище 963+964+965
                       (SELECT s.DIC_SNAME
                          FROM uss_ndi.v_ddn_rnsp_tp s
                         WHERE s.DIC_VALUE =
                               API$Appeal.Get_Attr_Val_String (
                                   p_Apd_Id   => apd.apd_id,
                                   p_Nda_Id   => 953))
                           AS RNSP_TP,                            -- Тип особи
                       (SELECT s.DIC_SNAME
                          FROM uss_ndi.V_DDN_RNSP_ORG_TP s
                         WHERE s.DIC_VALUE =
                               API$Appeal.Get_Attr_Val_String (
                                   p_Apd_Id   => apd.apd_id,
                                   p_Nda_Id   => 1131))
                           AS RNSP_ORG_TP             -- Ознака головна/філіал
                                         ,
                       ''
                           AS addr
                  FROM appeal  ap
                       JOIN ap_person app
                           ON     app.app_ap = ap.ap_id
                              AND app.app_tp = 'Z'
                              AND app.history_status = 'A'
                       JOIN ap_document apd
                           ON     apd.apd_ap = ap.ap_id
                              AND apd.apd_ndt = 700
                              AND apd.history_status = 'A'
                       JOIN ap_document_attr apda
                           ON     apda.apda_apd = apd.apd_id
                              AND apda.apda_nda = 961
                              AND apda.history_status = 'A'
                 WHERE     apda.apda_val_string LIKE '%' || P_PASS_NUM || '%'
                       AND EXISTS
                               (SELECT 1
                                  FROM ap_document_attr apda1
                                 WHERE     apda1.apda_apd = apd.apd_id
                                       AND apda1.apda_nda = 960
                                       AND apda1.history_status = 'A'
                                       AND apda1.apda_val_string = 'T');
        ELSE
            raise_application_error (-20000, 'Не задано фільтр');
        END IF;

        uss_rnsp.api$find.Query (P_NUMIDENT,
                                 P_RNOKPP,
                                 P_RNOKPP_MIS,
                                 P_PASS_NUM,
                                 P_RNSP);
    END;

    PROCEDURE Register_Document (p_Doc_Id OUT NUMBER, p_Dh_Id OUT NUMBER)
    IS
        l_Dh_Wu    NUMBER (14);
        l_Dh_Src   VARCHAR2 (10) := 'RNSP';
    BEGIN
        l_Dh_Wu := USS_VISIT_CONTEXT.GetContext (USS_VISIT_CONTEXT.gUID);

        uss_doc.Api$documents.Save_Document (
            p_Doc_Id          => NULL,
            p_Doc_Ndt         => NULL,
            p_Doc_Actuality   =>
                uss_doc.Api$documents.c_Doc_Actuality_Undefined,
            p_New_Id          => p_Doc_Id);

        uss_doc.Api$documents.Save_Doc_Hist (
            p_Dh_Id          => NULL,
            p_Dh_Doc         => p_Doc_Id,
            p_Dh_Sign_Alg    => NULL,
            p_Dh_Ndt         => NULL,
            p_Dh_Sign_File   => NULL,
            p_Dh_Actuality   =>
                uss_doc.Api$documents.c_Doc_Actuality_Undefined,
            p_Dh_Dt          => SYSDATE,
            p_Dh_Wu          => l_Dh_Wu,
            p_Dh_Src         => l_Dh_Src,
            p_New_Id         => p_Dh_Id);
    END;

    PROCEDURE Register_Document_for_AP (p_ap_id NUMBER)
    IS
        CURSOR Doc IS
            SELECT *
              FROM ap_document
             WHERE     apd_ap = p_ap_id
                   AND apd_aps IS NULL
                   AND (apd_doc IS NULL OR apd_dh IS NULL);

        l_Doc_Id   NUMBER;
        l_Dh_Id    NUMBER;
    BEGIN
        FOR d IN doc
        LOOP
            Register_Document (l_Doc_Id, l_Dh_Id);

            UPDATE ap_document
               SET apd_doc = l_Doc_Id, apd_dh = l_Dh_Id
             WHERE apd_id = d.apd_id;
        END LOOP;
    END;

    -- виконувати повне копіювання обраного звернення в нове
    --за виключенням документу «Рішення про включення / повернення на доопрацювання надавачем поданих документів» ndt_id=730
    PROCEDURE copy_Appeal (p_ap_id           Appeal.Ap_Id%TYPE,
                           p_new_ap_id   OUT Appeal.Ap_Id%TYPE)
    IS
    BEGIN
        api$appeal.Duplicate_Appeal (p_Ap_Id    => p_ap_id,
                                     p_New_Ap   => p_new_ap_id);

        Register_Document_for_AP (p_new_ap_id);
    --    COMMIT;
    --    raise_application_error(-20000, 'copy_Appeal('||p_ap_id||')>>'||p_new_ap_id);

    END;

    -- копіювати з обраного звернення:
    -- всі наявні атрибути надавача
    -- перелік послуг у блок «Вид послуги».
    PROCEDURE copy_RNSP (p_RNSPM_ID        Appeal.Ap_Ext_Ident%TYPE,
                         p_new_ap_id   OUT Appeal.Ap_Id%TYPE)
    IS
        l_CurrOrg   NUMBER (14) := tools.GetCurrOrg;
        l_CurrWu    NUMBER (14) := tools.GetCurrWu;
        l_Ap_St     VARCHAR2 (20) := 'J';
        l_App_Id    NUMBER (14);
        l_Apd_Id    NUMBER (14);
        l_rnsp      SYS_REFCURSOR;
        l_addr      SYS_REFCURSOR;
        l_addr1     SYS_REFCURSOR;
        l_srv       SYS_REFCURSOR;

        ------------------------------------------------------------
        PROCEDURE Save_Attr_dt (p_Nda NUMBER, p_Val_Dt DATE)
        IS
            l_Apda_Id   NUMBER (14);
        BEGIN
            api$appeal.Save_Document_Attr (p_Apda_Id           => NULL,
                                           p_Apda_Ap           => p_new_ap_id,
                                           p_Apda_Apd          => l_Apd_Id,
                                           p_Apda_Nda          => p_Nda,
                                           p_Apda_Val_Int      => NULL,
                                           p_Apda_Val_Dt       => p_Val_Dt,
                                           p_Apda_Val_String   => NULL,
                                           p_Apda_Val_Id       => NULL,
                                           p_Apda_Val_Sum      => NULL,
                                           p_New_Id            => l_Apda_Id);
        END;

        ------------------------------------------------------------
        PROCEDURE Save_Attr_String (p_Nda NUMBER, p_Val_String VARCHAR2)
        IS
            l_Apda_Id   NUMBER (14);
        BEGIN
            api$appeal.Save_Document_Attr (
                p_Apda_Id           => NULL,
                p_Apda_Ap           => p_new_ap_id,
                p_Apda_Apd          => l_Apd_Id,
                p_Apda_Nda          => p_Nda,
                p_Apda_Val_Int      => NULL,
                p_Apda_Val_Dt       => NULL,
                p_Apda_Val_String   => p_Val_String,
                p_Apda_Val_Id       => NULL,
                p_Apda_Val_Sum      => NULL,
                p_New_Id            => l_Apda_Id);
        END;

        ------------------------------------------------------------
        PROCEDURE Save_Attr_id (p_Nda          NUMBER,
                                p_Val_Id       NUMBER,
                                p_Val_String   VARCHAR2)
        IS
            l_Apda_Id   NUMBER (14);
        BEGIN
            api$appeal.Save_Document_Attr (
                p_Apda_Id           => NULL,
                p_Apda_Ap           => p_new_ap_id,
                p_Apda_Apd          => l_Apd_Id,
                p_Apda_Nda          => p_Nda,
                p_Apda_Val_Int      => NULL,
                p_Apda_Val_Dt       => NULL,
                p_Apda_Val_String   => p_Val_String,
                p_Apda_Val_Id       => p_Val_Id,
                p_Apda_Val_Sum      => NULL,
                p_New_Id            => l_Apda_Id);
        END;

        ------------------------------------------------------------
        PROCEDURE fetch_rnsp (p_rnsp SYS_REFCURSOR)
        IS
            RNSPM_ID                    NUMBER (14);
            RNSPM_TP                    VARCHAR2 (20);
            rnspm_org_tp                VARCHAR2 (20);
            rnspm_rnspm                 NUMBER (14);
            rnspm_rnspm_name            VARCHAR2 (2000);
            RNSPS_ID                    NUMBER (14);
            RNSPS_NUMIDENT              VARCHAR2 (20);
            RNSPS_IS_NUMIDENT_MISSING   VARCHAR2 (20);
            RNSPS_PASS_SERIA            VARCHAR2 (20);
            RNSPS_PASS_NUM              VARCHAR2 (20);
            RNSPS_LAST_NAME             VARCHAR2 (2000);
            RNSPS_FIRST_NAME            VARCHAR2 (2000);
            RNSPS_MIDDLE_NAME           VARCHAR2 (2000);
            RNSPS_GENDER                VARCHAR2 (20);
            RNSPO_ID                    NUMBER (14);
            RNSPO_PROP_FORM             VARCHAR2 (20);
            RNSPO_UNION_TP              VARCHAR2 (20);
            RNSPO_EMAIL                 VARCHAR2 (2000);
            RNSPO_PHONE                 VARCHAR2 (2000);
            RNSPO_WEB                   VARCHAR2 (2000);
            RNSPO_SERVICE_LOCATION      VARCHAR2 (200);
        BEGIN
            FETCH p_rnsp
                INTO RNSPM_ID,
                     RNSPM_TP,
                     rnspm_org_tp,
                     rnspm_rnspm,
                     rnspm_rnspm_name,
                     RNSPS_ID,
                     RNSPS_NUMIDENT,
                     RNSPS_IS_NUMIDENT_MISSING,
                     RNSPS_PASS_SERIA,
                     RNSPS_PASS_NUM,
                     RNSPS_LAST_NAME,
                     RNSPS_FIRST_NAME,
                     RNSPS_MIDDLE_NAME,
                     RNSPS_GENDER,
                     RNSPO_ID,
                     RNSPO_PROP_FORM,
                     RNSPO_UNION_TP,
                     RNSPO_EMAIL,
                     RNSPO_PHONE,
                     RNSPO_WEB,
                     RNSPO_SERVICE_LOCATION;

            CLOSE p_rnsp;

            Save_Attr_String (953, RNSPM_TP); --953 Тип надавача STRING V_DDN_RNSP_TP
            Save_Attr_String (1131, rnspm_org_tp); --1131 Головна організація/філіал STRING V_DDN_RNSP_ORG_TP
            Save_Attr_id (2451, rnspm_rnspm, rnspm_rnspm_name); --2451 Надавач соціальної послуги ID V_RNSP_ALL


            --O Юридична особа
            --F ФОП
            IF RNSPM_TP = 'O'
            THEN
                Save_Attr_String (955, RNSPS_NUMIDENT); --955 Код ЄДРПОУ STRING
                Save_Attr_String (956, RNSPS_LAST_NAME); --956 Повне найменування юридичної особи STRING
                Save_Attr_String (957, RNSPS_FIRST_NAME); --957 Скорочене найменування юридичної особи STRING
                Save_Attr_String (958, RNSPO_PROP_FORM); --958 Організаційно-правова форма STRING V_DDN_FORMS_MNGM
                Save_Attr_String (959, RNSPO_UNION_TP); --959 Вид громадського об’єднання, благодійної чи релігійної організації
            ELSIF RNSPM_TP = 'F'
            THEN
                Save_Attr_String (960, RNSPS_IS_NUMIDENT_MISSING); --960 Ознакa відмови особи від РНОКПП STRING
                Save_Attr_String (961, RNSPS_NUMIDENT);    --961 РНОКПП STRING
                Save_Attr_String (962, RNSPS_PASS_SERIA || RNSPS_PASS_NUM); --962 Реквізити документу, що посвідчує особу STRING
                Save_Attr_String (963, RNSPS_LAST_NAME); --963 Прізвище STRING
                Save_Attr_String (964, RNSPS_FIRST_NAME);    --964 Ім’я STRING
                Save_Attr_String (965, RNSPS_MIDDLE_NAME); --965 По батькові STRING
                Save_Attr_String (966, RNSPO_PROP_FORM); --966 Організаційно-правова форма STRING V_DDN_FORMS_MNGM
                Save_Attr_String (967, RNSPO_UNION_TP); --967 Вид громадського об’єднання, благодійної чи релігійної організації  STRING
            END IF;

            --Контактні дані
            Save_Attr_String (968, RNSPO_PHONE); --968 контактні телефони STRING
            Save_Attr_String (969, RNSPO_EMAIL); --969 електронна адреса STRING
            Save_Attr_String (970, RNSPO_WEB); --970 адреса веб-сайту/іншого інформаційного ресурсу STRING
        --      Save_Attr_String (, );    --
        /*


        Фізична особа – підприємець (ФОП)
        */

        END;

        ------------------------------------------------------------
        PROCEDURE fetch_addr (p_addr SYS_REFCURSOR, p_rnspa_tp VARCHAR2)
        IS
            RNSPA_ID            NUMBER (14);
            RNSPA_KAOT          NUMBER (14);
            RNSPA_INDEX         VARCHAR2 (200);
            RNSPA_STREET        VARCHAR2 (200);
            RNSPA_BUILDING      VARCHAR2 (200);
            RNSPA_KORP          VARCHAR2 (200);
            RNSPA_APPARTEMENT   VARCHAR2 (200);
            CITY_NAME           VARCHAR2 (200);
            REGION_NAME         VARCHAR2 (200);
            AREA_NAME           VARCHAR2 (200);
        BEGIN
            FETCH p_addr
                INTO RNSPA_ID,
                     RNSPA_KAOT,
                     RNSPA_INDEX,
                     RNSPA_STREET,
                     RNSPA_BUILDING,
                     RNSPA_KORP,
                     RNSPA_APPARTEMENT,
                     CITY_NAME,
                     REGION_NAME,
                     AREA_NAME;

            CLOSE p_addr;

            IF p_rnspa_tp = 'U'
            THEN
                Save_Attr_id (971, RNSPA_KAOT, CITY_NAME); --971 КАТОТТГ ID V_MF_KOATUU_TEST
                Save_Attr_String (972, RNSPA_INDEX); --972 індекс ID v_mf_index
                Save_Attr_String (973, REGION_NAME);      --973 область STRING
                Save_Attr_String (974, CITY_NAME); --974 населений пункт STRING
                --975 вулиця (вибір з довідника) ID V_NDI_STREET
                Save_Attr_String (976, RNSPA_BUILDING);   --976 будинок STRING
                Save_Attr_String (977, RNSPA_KORP);        --977 корпус STRING
                Save_Attr_String (978, RNSPA_APPARTEMENT); --978 офіс/квартира STRING
                --1093 Ознака співпадіння місця надання соціальних послуг з місцезнаходженням надавача STRING
                Save_Attr_String (2102, AREA_NAME);        --2102 район STRING
                Save_Attr_String (2159, RNSPA_STREET); --2159 вулиця (ручне введення у випадку відсутності в довіднику) STRING V_NDI_STREET
            ELSIF p_rnspa_tp = 'S'
            THEN
                Save_Attr_id (979, RNSPA_KAOT, CITY_NAME); --979 КАТОТТГ ID V_MF_KOATUU_TEST
                Save_Attr_String (980, RNSPA_INDEX); --980 індекс ID v_mf_index
                Save_Attr_String (981, REGION_NAME);      --981 область STRING
                Save_Attr_String (982, CITY_NAME); --982 населений пункт STRING
                --983 вулиця (вибір з довідника) ID V_NDI_STREET
                Save_Attr_String (984, RNSPA_BUILDING);   --984 будинок STRING
                Save_Attr_String (985, RNSPA_KORP);        --985 корпус STRING
                Save_Attr_String (986, RNSPA_APPARTEMENT); --986 офіс/квартира STRING
                Save_Attr_String (2103, AREA_NAME);        --2103 район STRING
                Save_Attr_String (2160, RNSPA_STREET); --2160 вулиця (ручне введення у випадку відсутності в довіднику) STRING V_NDI_STREET
            END IF;
        END;

        ------------------------------------------------------------
        PROCEDURE fetch_srv (p_srv SYS_REFCURSOR)
        IS
            rnspds_nst   NUMBER (14);
            l_ndt_id     NUMBER (14);
            l_aps_Id     NUMBER (14);
            l_apd_id     NUMBER (14);
        BEGIN
            LOOP
                FETCH p_srv INTO rnspds_nst;

                EXIT WHEN p_srv%NOTFOUND;

                --
                SELECT MAX (ndt.ndt_id)
                  INTO l_ndt_id
                  FROM uss_ndi.v_ndi_document_type  ndt
                       JOIN uss_ndi.v_ndi_nst_doc_config nndc
                           ON nndc.nndc_ndt = ndt.ndt_id AND nndc_ap_tp = 'G'
                 WHERE ndt.ndt_ndc = 14 AND nndc.nndc_nst = rnspds_nst;


                api$appeal.Save_Service (p_Aps_Id    => NULL,
                                         p_Aps_Nst   => rnspds_nst,
                                         p_Aps_Ap    => p_new_ap_id,
                                         p_Aps_St    => 'R',
                                         p_New_Id    => l_aps_Id);


                api$appeal.Save_Document (p_Apd_Id    => NULL,
                                          p_Apd_Ap    => p_new_ap_id,
                                          p_Apd_Ndt   => l_ndt_id,
                                          p_Apd_Doc   => NULL,
                                          p_Apd_Vf    => NULL,
                                          p_Apd_App   => l_app_id,
                                          p_New_Id    => l_apd_id,
                                          p_Com_Wu    => l_CurrWu,
                                          p_Apd_Dh    => NULL,
                                          p_Apd_Aps   => l_aps_Id);

                INSERT INTO ap_document_attr (apda_id,
                                              apda_ap,
                                              apda_apd,
                                              apda_nda,
                                              apda_val_int,
                                              apda_val_dt,
                                              apda_val_string,
                                              apda_val_id,
                                              apda_val_sum,
                                              history_status)
                    SELECT NULL,
                           p_new_ap_id,
                           l_apd_id,
                           nda_id,
                           NULL,
                           NULL,
                           (CASE
                                WHEN pt_data_type = 'STRING'
                                THEN
                                    nda_def_value
                            END),
                           NULL,
                           NULL,
                           'A'
                      FROM uss_ndi.v_ndi_document_attr  nda
                           JOIN uss_ndi.v_ndi_param_type ON pt_id = nda_pt
                     WHERE nda_ndt = l_ndt_id AND nda.history_status = 'A';
            END LOOP;

            CLOSE p_srv;
        END;
    ------------------------------------------------------------
    BEGIN
        api$appeal.Save_Appeal (p_Ap_Id          => NULL,
                                p_Ap_Num         => NULL,
                                p_Ap_Reg_Dt      => SYSDATE,
                                p_Ap_Create_Dt   => SYSDATE,
                                p_Ap_Src         => 'USS',
                                p_Ap_St          => l_Ap_St,
                                p_Com_Org        => l_CurrOrg,
                                p_Ap_Is_Second   => 'F',
                                p_Ap_Vf          => NULL,
                                p_Com_Wu         => l_CurrWu,
                                p_Ap_Tp          => 'G',
                                p_New_Id         => p_new_ap_id,
                                p_Ap_Ext_Ident   => p_rnspm_id);

        api$appeal.Save_Person (p_App_Id        => NULL,
                                p_App_Ap        => p_new_ap_id,
                                p_App_Tp        => 'Z',
                                p_App_Inn       => NULL,
                                p_App_Ndt       => NULL,
                                p_App_Doc_Num   => NULL,
                                p_App_Fn        => NULL,
                                p_App_Mn        => NULL,
                                p_App_Ln        => NULL,
                                p_App_Esr_Num   => NULL,
                                p_App_Gender    => NULL,
                                p_App_Vf        => NULL,
                                p_App_Sc        => NULL,
                                p_App_Num       => NULL,
                                p_New_Id        => l_App_Id);

        api$appeal.Save_Document (p_Apd_Id    => NULL,
                                  p_Apd_Ap    => p_new_ap_id,
                                  p_Apd_Ndt   => 700,
                                  p_Apd_Doc   => NULL,
                                  p_Apd_Vf    => NULL,
                                  p_Apd_App   => l_app_id,
                                  p_New_Id    => l_apd_id,
                                  p_Com_Wu    => l_CurrWu,
                                  p_Apd_Dh    => NULL,
                                  p_Apd_Aps   => NULL);


        uss_rnsp.api$find.GetRNSP_all (p_rnspm_id,
                                       l_rnsp,
                                       l_addr,
                                       l_addr1,
                                       l_srv);

        fetch_rnsp (l_rnsp);
        fetch_addr (l_addr, 'U');
        fetch_addr (l_addr1, 'S');
        fetch_srv (l_srv);

        Register_Document_for_AP (p_new_ap_id);
    END;
END DNET$RNSP;
/