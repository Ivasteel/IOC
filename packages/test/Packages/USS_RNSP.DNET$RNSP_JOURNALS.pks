/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$RNSP_JOURNALS
IS
    -- Author  : VANO
    -- Created : 14.04.2022 15:37:26
    -- Purpose : Запити для роботи з журналами

    PROCEDURE Write_LogA (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                          p_Apl_Hs        IN Ap_Log.Apl_Hs%TYPE,
                          p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                          p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                          p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE := NULL,
                          p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE := NULL);

    PROCEDURE GET_QUEUE_LIST (P_PROVIDER_TP   IN     VARCHAR2, -- Тип надавача
                              P_AP_TP         IN     VARCHAR2, -- Тип звернення
                              P_AP_ST         IN     VARCHAR2, -- Статус звернення
                              P_AP_NUM        IN     VARCHAR2, -- Номер реєстраційної картки
                              P_AP_DT_START   IN     DATE, -- Дата реєстрації звернення з
                              P_AP_DT_STOP    IN     DATE, -- Дата реєстрації звернення по
                              P_EDRPOU        IN     VARCHAR2, -- Код за ЄДРПОУ/РНОКПП
                              P_IS_CODELESS   IN     VARCHAR2, -- Особа є відмовником від РНОКПП
                              P_PASS_DATA     IN     VARCHAR2, -- Серія Номер паспорту/номер ІД-картки
                              P_FULL_NAME     IN     VARCHAR2, -- Повна назва/прізвище
                              P_SHORT_NAME    IN     VARCHAR2, -- Скорочена назва/ім'я
                              P_ADDR          IN     VARCHAR2, -- Область місця знаходження/проживання TODO:
                              P_ADDR_SERV     IN     VARCHAR2, -- Міcце надання послуги TODO:
                              P_NST_ID        IN     NUMBER, -- Соціальна послуга
                              P_FLAG          IN     NUMBER, -- 0 - по дефолту, 1 - тільки NS
                              RES_CUR            OUT SYS_REFCURSOR);


    PROCEDURE GET_QUEUE_CHILD_LIST (P_PROVIDER_TP   IN     VARCHAR2, -- Тип надавача
                                    P_AP_TP         IN     VARCHAR2, -- Тип звернення
                                    P_AP_ST         IN     VARCHAR2, -- Статус звернення
                                    P_AP_NUM        IN     VARCHAR2, -- Номер реєстраційної картки
                                    P_AP_DT_START   IN     DATE, -- Дата реєстрації звернення з
                                    P_AP_DT_STOP    IN     DATE, -- Дата реєстрації звернення по
                                    P_EDRPOU        IN     VARCHAR2, -- Код за ЄДРПОУ/РНОКПП
                                    P_IS_CODELESS   IN     VARCHAR2, -- Особа є відмовником від РНОКПП
                                    P_PASS_DATA     IN     VARCHAR2, -- Серія Номер паспорту/номер ІД-картки
                                    P_FULL_NAME     IN     VARCHAR2, -- Повна назва/прізвище
                                    P_SHORT_NAME    IN     VARCHAR2, -- Скорочена назва/ім'я
                                    P_ADDR          IN     VARCHAR2, -- Область місця знаходження/проживання TODO:
                                    P_ADDR_SERV     IN     VARCHAR2, -- Міcце надання послуги TODO:
                                    P_NST_ID        IN     NUMBER, -- Соціальна послуга
                                    P_FLAG          IN     NUMBER, -- 0 - по дефолту, 1 - тільки NS
                                    RES_CUR            OUT SYS_REFCURSOR);

    PROCEDURE GET_WORK_LIST (P_PROVIDER_TP   IN     VARCHAR2,  -- Тип надавача
                             P_AP_TP         IN     VARCHAR2, -- Тип звернення
                             P_AP_NUM        IN     VARCHAR2, -- Номер реєстраційної картки
                             P_AP_DT_START   IN     DATE, -- Дата реєстрації звернення з
                             P_AP_DT_STOP    IN     DATE, -- Дата реєстрації звернення по
                             P_MODE          IN     NUMBER, -- 1 - «На контролі», 2 - "Опрацювання рішення", 3 - оба
                             RES_CUR            OUT SYS_REFCURSOR);

    PROCEDURE Approve_Appeal (p_ap_id       NUMBER,
                              p_ap_st    IN VARCHAR2,
                              p_doc_id      NUMBER,
                              p_hs_id       NUMBER /*,
                                   p_pdf_data OUT  SYS_REFCURSOR*/
                                                  );

    PROCEDURE Approve_Appeal (p_ap_id IN NUMBER, p_ap_st IN VARCHAR2);

    PROCEDURE get_decision_approve_blob (p_ap_id          NUMBER,
                                         p_pdf_data   OUT SYS_REFCURSOR);

    PROCEDURE Reject_Appeal (p_ap_id       NUMBER,
                             p_ap_st    IN VARCHAR2,
                             p_reason      ap_log.apl_message%TYPE := NULL);

    PROCEDURE Return_Appeal (p_ap_id    NUMBER,
                             p_reason   ap_log.apl_message%TYPE:= NULL);

    PROCEDURE Return_Appeal (p_ap_id    IN NUMBER,
                             p_ap_st    IN VARCHAR2,
                             p_doc_id      NUMBER,
                             p_hs_id       NUMBER,
                             --p_pdf_data OUT  SYS_REFCURSOR,
                             p_reason      ap_log.apl_message%TYPE := NULL);

    PROCEDURE get_Return_Appeal_blob (p_ap_id          NUMBER,
                                      p_pdf_data   OUT SYS_REFCURSOR);


    PROCEDURE GET_DOC_LIST (P_AP_ID     IN     NUMBER,
                            DOC_CUR        OUT SYS_REFCURSOR,
                            ATTR_CUR       OUT SYS_REFCURSOR,
                            FILES_CUR      OUT SYS_REFCURSOR);

    PROCEDURE Get_Nda_List (p_Ndt_Id NUMBER, p_Nda_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Nng_List (p_Nng_Cur OUT SYS_REFCURSOR);

    PROCEDURE get_appeal_list (p_rnsp_id   IN     NUMBER,
                               res_cur        OUT SYS_REFCURSOR);

    PROCEDURE Get_Documents_Files (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR);

    --=================================================================--
    /*
      A -> WD -> V
    */
    PROCEDURE Approve_RND (p_rnd_id IN NUMBER, p_rnd_st IN VARCHAR2);

    /*
      WD -> A
    */
    PROCEDURE Return_RND (p_rnd_id IN NUMBER, p_rnd_st IN VARCHAR2);

    /*
      WD -> X
    */
    PROCEDURE Reject_RND (p_rnd_id NUMBER, p_rnd_st IN VARCHAR2);
END DNET$RNSP_JOURNALS;
/


GRANT EXECUTE ON USS_RNSP.DNET$RNSP_JOURNALS TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.DNET$RNSP_JOURNALS TO II01RC_USS_RNSP_WEB
/


/* Formatted on 8/12/2025 5:58:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.DNET$RNSP_JOURNALS
IS
    PROCEDURE Write_Log (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                         p_Apl_Hs        IN Ap_Log.Apl_Hs%TYPE,
                         p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                         p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                         p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE := NULL,
                         p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE := NULL)
    IS
    BEGIN
        IF p_Apl_Hs IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'vano>>программист прикладной функции забыл сгенерировать сессию историческую! Клемить его позором');
        END IF;

        INSERT INTO Ap_Log (Apl_Ap,
                            Apl_Hs,
                            Apl_St,
                            Apl_Message,
                            Apl_St_Old,
                            Apl_Tp)
             VALUES (p_Apl_Ap,
                     p_Apl_Hs,
                     p_Apl_St,
                     p_Apl_Message,
                     p_Apl_St_Old,
                     NVL (p_Apl_Tp, 'SYS'));
    END;

    PROCEDURE Write_LogA (p_Apl_Ap        IN Ap_Log.Apl_Ap%TYPE,
                          p_Apl_Hs        IN Ap_Log.Apl_Hs%TYPE,
                          p_Apl_St        IN Ap_Log.Apl_St%TYPE,
                          p_Apl_Message   IN Ap_Log.Apl_Message%TYPE,
                          p_Apl_St_Old    IN Ap_Log.Apl_St_Old%TYPE := NULL,
                          p_Apl_Tp        IN Ap_Log.Apl_Tp%TYPE := NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        Write_Log (p_Apl_Ap,
                   p_Apl_Hs,
                   p_Apl_St,
                   p_Apl_Message,
                   p_Apl_St_Old,
                   p_Apl_Tp);
        COMMIT;
    END;


    -- перевірка на консистентність даних
    PROCEDURE check_consistensy (P_AP_ID IN NUMBER, P_AP_ST IN VARCHAR2)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT ap_st
          INTO l_st
          FROM appeal t
         WHERE t.ap_id = p_ap_id;

        IF (l_st != p_ap_st OR p_ap_st IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Дану операцію неможливо завершити. Дані застарілі. Оновіть сторінку і спробуйте знову.');
        END IF;
    END;

    -- перевірка на консистентність даних
    PROCEDURE check_consistensy_rnd (P_RND_ID   IN NUMBER,
                                     P_RND_ST   IN VARCHAR2)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT t.rnd_st
          INTO l_st
          FROM v_rn_document t
         WHERE t.rnd_id = P_RND_ID;

        IF (l_st != P_RND_ST OR P_RND_ST IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Дану операцію неможливо завершити. Дані застарілі. Оновіть сторінку і спробуйте знову.');
        END IF;
    END;

    /*
    50 J Реєстрація в роботі
    51 F Зареєстровано
    52 S Передано на призначення
    53 A На контролі
    54 NS  Потребує затвердження рішення
    55 WD  Опрацювання рішення
    56 WI  Очікує включення до реєстру
    57 V Виконано
    58 B Повернуто з органу призначення
    59 P Повернуто
    60 X Відхилено
    */
    FUNCTION Get_Tmpl_Code (p_val VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE p_val
                   WHEN 'J' THEN '50'                   -- Реєстрація в роботі
                   WHEN 'F' THEN '51'                         -- Зареєстровано
                   WHEN 'S' THEN '52'               -- Передано на призначення
                   WHEN 'A' THEN '53'                           -- На контролі
                   WHEN 'NS' THEN '54'       --  Потребує затвердження рішення
                   WHEN 'WD' THEN '55'                 --  Опрацювання рішення
                   WHEN 'WI' THEN '56'         --  Очікує включення до реєстру
                   WHEN 'V' THEN '57'                              -- Виконано
                   WHEN 'B' THEN '58'        -- Повернуто з органу призначення
                   WHEN 'P' THEN '59'                             -- Повернуто
                   WHEN 'X' THEN '60'                             -- Відхилено
               END;
    END;

    PROCEDURE GET_QUEUE_LIST (P_PROVIDER_TP   IN     VARCHAR2, -- Тип надавача
                              P_AP_TP         IN     VARCHAR2, -- Тип звернення
                              P_AP_ST         IN     VARCHAR2, -- Статус звернення
                              P_AP_NUM        IN     VARCHAR2, -- Номер реєстраційної картки
                              P_AP_DT_START   IN     DATE, -- Дата реєстрації звернення з
                              P_AP_DT_STOP    IN     DATE, -- Дата реєстрації звернення по
                              P_EDRPOU        IN     VARCHAR2, -- Код за ЄДРПОУ/РНОКПП
                              P_IS_CODELESS   IN     VARCHAR2, -- Особа є відмовником від РНОКПП
                              P_PASS_DATA     IN     VARCHAR2, -- Серія Номер паспорту/номер ІД-картки
                              P_FULL_NAME     IN     VARCHAR2, -- Повна назва/прізвище
                              P_SHORT_NAME    IN     VARCHAR2, -- Скорочена назва/ім'я
                              P_ADDR          IN     VARCHAR2, -- Область місця знаходження/проживання TODO:
                              P_ADDR_SERV     IN     VARCHAR2, -- Міcце надання послуги TODO:
                              P_NST_ID        IN     NUMBER, -- Соціальна послуга
                              P_FLAG          IN     NUMBER, -- 0 - по дефолту, 1 - тільки NS
                              RES_CUR            OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.GetCurrOrg;
    BEGIN
        tools.WriteMsg ('DNET$RNSP_JOURNALS.' || $$PLSQL_UNIT);

        OPEN RES_CUR FOR
            SELECT t.ap_id,
                   t.ap_ext_ident                                AS rnspm_id,
                   t.Ap_St,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = t.ap_st)                AS Ap_St_Name,
                   t.ap_num,                     -- Номер реєстраційної картки
                   t.ap_reg_dt,                   -- Дата реєстрації звернення
                   tpn.DIC_NAME                                  AS provider_name, -- Тип надавача
                   atp.DIC_NAME                                  AS appeal_tp_name, -- Тип звернення
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1087,
                                       'F', 963,
                                       956)
                           AND z.history_status = 'A')           AS full_name, -- Повна назва/прізвище
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1088,
                                       'F', 964,
                                       957)
                           AND z.history_status = 'A')           AS short_name, -- Скорочена назва/ім'я
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1089,
                                       'F', 965,
                                       -1)
                           AND z.history_status = 'A')           AS middle_name, -- Абревіатура/по батькові
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1085,
                                       'F', 961,
                                       955)
                           AND z.history_status = 'A')           AS edrpou, -- Код за ЄДРПОУ/РНОКПП
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1086,
                                       'F', 962,
                                       -1)
                           AND z.history_status = 'A')           AS pass_data, -- Серія та Номер паспорту/номер ІД-картки
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string, 'P', 1092, -1)
                           AND z.history_status = 'A')           AS nationality, -- Громадянство
                   (SELECT z.apda_val_dt
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string, 'P', 1091, -1)
                           AND z.history_status = 'A')           AS birth_dt, -- дата народження
                   NULL                                          AS obl_name, -- Область місцезнаходження
                   NULL                                          AS addr_living, -- Адреса місцезнаходження/проживання
                   NULL                                          AS addr_service, -- Місце надання послуги
                   (SELECT LISTAGG (z.apda_val_dt, ',')
                               WITHIN GROUP (ORDER BY z.apda_nda)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda IN (968, 969, 970))    AS contacts -- Контактні дані
              FROM v_appeal  t
                   JOIN v_ap_document d
                       ON (d.apd_ap = t.ap_id AND d.history_status = 'A')
                   JOIN v_ap_document_attr tp
                       ON (    tp.apda_apd = d.apd_id
                           AND tp.apda_nda = 953
                           AND tp.history_status = 'A')        -- Тип надавача
                   JOIN v_ap_document_attr apa
                       ON (    apa.apda_apd = d.apd_id
                           AND apa.apda_nda = 954
                           AND apa.history_status = 'A') -- Тип звернення РНСП
                   JOIN uss_ndi.V_DDN_RNSP_TP tpn
                       ON (tpn.DIC_VALUE = tp.apda_val_string)
                   JOIN uss_ndi.V_DDN_RNSP_ST atp
                       ON (atp.DIC_VALUE = apa.apda_val_string)
             WHERE     1 = 1
                   AND d.apd_ndt = 700
                   AND t.com_org = l_org
                   --AND (t.com_org = l_org OR t.ap_dest_org = l_org)
                   AND (       P_FLAG = 0
                           AND t.ap_st IN ('A',
                                           'S',
                                           'NS',
                                           'WI',
                                           'V',
                                           'X',
                                           'B')
                        OR P_FLAG = 1 AND t.ap_st IN ('NS')
                        OR 1 = 2)
                   AND (   (    p_ap_st IS NULL
                            AND t.ap_st IN ('A',
                                            'S',
                                            'NS',
                                            'WI'))
                        OR t.ap_st = p_ap_st)
                   AND (   P_PROVIDER_TP IS NULL
                        OR tp.apda_val_string = P_PROVIDER_TP)
                   AND (   P_AP_TP IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda = 954
                                       AND z.apda_val_string = P_AP_TP))
                   AND (   P_AP_NUM IS NULL
                        OR t.ap_num LIKE '%' || P_AP_NUM || '%')
                   AND (P_AP_DT_START IS NULL OR t.ap_reg_dt >= P_AP_DT_START)
                   AND (P_AP_DT_STOP IS NULL OR t.ap_reg_dt <= P_AP_DT_STOP)
                   AND (   P_EDRPOU IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1085,
                                                   'F', 961,
                                                   955)
                                       AND z.apda_val_string LIKE
                                               '%' || P_EDRPOU || '%'))
                   AND (   P_IS_CODELESS IS NULL
                        OR P_IS_CODELESS = 'F'
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1084,
                                                   960)
                                       AND z.apda_val_string = P_IS_CODELESS))
                   AND (   P_PASS_DATA IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1086,
                                                   962)
                                       AND UPPER (z.apda_val_string) LIKE
                                               UPPER (
                                                   '%' || P_PASS_DATA || '%')))
                   /* and (P_FULL_NAME is null
                            or tp.apda_val_string = 'O' and exists (SELECT * FROM v_ap_document_attr z
                                         where z.apda_apd = d.apd_id
                                          and z.apda_nda = 956 and z.apda_val_string like '%'||P_FULL_NAME||'%')
                            or tp.apda_val_string = 'F' and exists (select * from (SELECT listagg(z.apda_val_string, '%') within group (order by z.apda_nda) as nm FROM v_ap_document_attr z
                                         where z.apda_apd = d.apd_id
                                          and z.apda_nda in (963, 964, 965))
                                         where nm like '%'||P_FULL_NAME||'%')
                            or tp.apda_val_string = 'P' and exists (select * from (SELECT listagg(z.apda_val_string, '%') within group (order by z.apda_nda) as nm FROM v_ap_document_attr z
                                         where z.apda_apd = d.apd_id
                                          and z.apda_nda in (1087, 1088, 1089))
                                         where nm like '%'||P_FULL_NAME||'%')
                        )*/

                   AND (   P_FULL_NAME IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1087,
                                                   'F', 963,
                                                   956)
                                       AND UPPER (z.apda_val_string) LIKE
                                               UPPER (
                                                   '%' || P_FULL_NAME || '%')))
                   AND (   P_SHORT_NAME IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1088,
                                                   'F', 964,
                                                   957)
                                       AND UPPER (z.apda_val_string) LIKE
                                               UPPER (
                                                   '%' || P_SHORT_NAME || '%')))
                   AND (   P_ADDR IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda = 973
                                       AND z.apda_val_string LIKE
                                               '%' || P_ADDR || '%'))
                   AND (   P_NST_ID IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM ap_service z
                                 WHERE     z.aps_ap = t.ap_id
                                       AND z.aps_nst = P_NST_ID));
    END;

    PROCEDURE GET_QUEUE_CHILD_LIST (P_PROVIDER_TP   IN     VARCHAR2, -- Тип надавача
                                    P_AP_TP         IN     VARCHAR2, -- Тип звернення
                                    P_AP_ST         IN     VARCHAR2, -- Статус звернення
                                    P_AP_NUM        IN     VARCHAR2, -- Номер реєстраційної картки
                                    P_AP_DT_START   IN     DATE, -- Дата реєстрації звернення з
                                    P_AP_DT_STOP    IN     DATE, -- Дата реєстрації звернення по
                                    P_EDRPOU        IN     VARCHAR2, -- Код за ЄДРПОУ/РНОКПП
                                    P_IS_CODELESS   IN     VARCHAR2, -- Особа є відмовником від РНОКПП
                                    P_PASS_DATA     IN     VARCHAR2, -- Серія Номер паспорту/номер ІД-картки
                                    P_FULL_NAME     IN     VARCHAR2, -- Повна назва/прізвище
                                    P_SHORT_NAME    IN     VARCHAR2, -- Скорочена назва/ім'я
                                    P_ADDR          IN     VARCHAR2, -- Область місця знаходження/проживання TODO:
                                    P_ADDR_SERV     IN     VARCHAR2, -- Міcце надання послуги TODO:
                                    P_NST_ID        IN     NUMBER, -- Соціальна послуга
                                    P_FLAG          IN     NUMBER, -- 0 - по дефолту, 1 - тільки NS
                                    RES_CUR            OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.GetCurrOrg;
    BEGIN
        tools.WriteMsg ('DNET$RNSP_JOURNALS.' || $$PLSQL_UNIT);

        OPEN RES_CUR FOR
            SELECT t.ap_id,
                   t.ap_ext_ident                                AS rnspm_id,
                   t.Ap_St,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = t.ap_st)                AS Ap_St_Name,
                   t.ap_num,                     -- Номер реєстраційної картки
                   t.ap_reg_dt,                   -- Дата реєстрації звернення
                   tpn.DIC_NAME                                  AS provider_name, -- Тип надавача
                   atp.DIC_NAME                                  AS appeal_tp_name, -- Тип звернення
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1087,
                                       'F', 963,
                                       956)
                           AND z.history_status = 'A')           AS full_name, -- Повна назва/прізвище
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1088,
                                       'F', 964,
                                       957)
                           AND z.history_status = 'A')           AS short_name, -- Скорочена назва/ім'я
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1089,
                                       'F', 965,
                                       -1)
                           AND z.history_status = 'A')           AS middle_name, -- Абревіатура/по батькові
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1085,
                                       'F', 961,
                                       955)
                           AND z.history_status = 'A')           AS edrpou, -- Код за ЄДРПОУ/РНОКПП
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1086,
                                       'F', 962,
                                       -1)
                           AND z.history_status = 'A')           AS pass_data, -- Серія та Номер паспорту/номер ІД-картки
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string, 'P', 1092, -1)
                           AND z.history_status = 'A')           AS nationality, -- Громадянство
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string, 'P', 1091, -1)
                           AND z.history_status = 'A')           AS birth_dt, -- дата народження
                   NULL                                          AS obl_name, -- Область місцезнаходження
                   NULL                                          AS addr_living, -- Адреса місцезнаходження/проживання
                   NULL                                          AS addr_service, -- Місце надання послуги
                   (SELECT LISTAGG (z.apda_val_dt, ',')
                               WITHIN GROUP (ORDER BY z.apda_nda)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda IN (968, 969, 970))    AS contacts -- Контактні дані
              FROM appeal  t
                   JOIN v_opfu o ON (o.org_id = t.ap_dest_org)
                   JOIN v_ap_document d
                       ON (d.apd_ap = t.ap_id AND d.history_status = 'A')
                   JOIN v_ap_document_attr tp
                       ON (    tp.apda_apd = d.apd_id
                           AND tp.apda_nda = 953
                           AND tp.history_status = 'A')        -- Тип надавача
                   JOIN v_ap_document_attr apa
                       ON (    apa.apda_apd = d.apd_id
                           AND apa.apda_nda = 954
                           AND apa.history_status = 'A') -- Тип звернення РНСП
                   JOIN uss_ndi.V_DDN_RNSP_TP tpn
                       ON (tpn.DIC_VALUE = tp.apda_val_string)
                   JOIN uss_ndi.V_DDN_RNSP_ST atp
                       ON (atp.DIC_VALUE = apa.apda_val_string)
             WHERE     1 = 1
                   AND d.apd_ndt = 700
                   --AND t.com_org = l_org
                   AND o.org_id IN (    SELECT org_id
                                          FROM v_opfu z
                                    CONNECT BY PRIOR z.org_id = z.org_org
                                    START WITH z.org_id = l_org)
                   --AND (o.org_id = l_org OR o.org_org = l_org)
                   AND (       P_FLAG = 0
                           AND t.ap_st IN ('A',
                                           'S',
                                           'NS',
                                           'WI')
                        OR P_FLAG = 1 AND t.ap_st IN ('NS')
                        OR 1 = 2)
                   AND (p_ap_st IS NULL OR t.ap_st = p_ap_st)
                   AND (   P_PROVIDER_TP IS NULL
                        OR tp.apda_val_string = P_PROVIDER_TP)
                   AND (   P_AP_TP IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda = 954
                                       AND z.apda_val_string = P_AP_TP))
                   AND (   P_AP_NUM IS NULL
                        OR t.ap_num LIKE '%' || P_AP_NUM || '%')
                   AND (P_AP_DT_START IS NULL OR t.ap_reg_dt >= P_AP_DT_START)
                   AND (P_AP_DT_STOP IS NULL OR t.ap_reg_dt <= P_AP_DT_STOP)
                   AND (   P_EDRPOU IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1085,
                                                   'F', 961,
                                                   955)
                                       AND z.apda_val_string LIKE
                                               '%' || P_EDRPOU || '%'))
                   AND (   P_IS_CODELESS IS NULL
                        OR P_IS_CODELESS = 'F'
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1084,
                                                   960)
                                       AND z.apda_val_string = P_IS_CODELESS))
                   AND (   P_PASS_DATA IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1086,
                                                   962)
                                       AND UPPER (z.apda_val_string) LIKE
                                               UPPER (
                                                   '%' || P_PASS_DATA || '%')))
                   /* and (P_FULL_NAME is null
                            or tp.apda_val_string = 'O' and exists (SELECT * FROM v_ap_document_attr z
                                         where z.apda_apd = d.apd_id
                                          and z.apda_nda = 956 and z.apda_val_string like '%'||P_FULL_NAME||'%')
                            or tp.apda_val_string = 'F' and exists (select * from (SELECT listagg(z.apda_val_string, '%') within group (order by z.apda_nda) as nm FROM v_ap_document_attr z
                                         where z.apda_apd = d.apd_id
                                          and z.apda_nda in (963, 964, 965))
                                         where nm like '%'||P_FULL_NAME||'%')
                            or tp.apda_val_string = 'P' and exists (select * from (SELECT listagg(z.apda_val_string, '%') within group (order by z.apda_nda) as nm FROM v_ap_document_attr z
                                         where z.apda_apd = d.apd_id
                                          and z.apda_nda in (1087, 1088, 1089))
                                         where nm like '%'||P_FULL_NAME||'%')
                        )*/

                   AND (   P_FULL_NAME IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1087,
                                                   'F', 963,
                                                   956)
                                       AND UPPER (z.apda_val_string) LIKE
                                               UPPER (
                                                   '%' || P_FULL_NAME || '%')))
                   AND (   P_SHORT_NAME IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda =
                                           DECODE (tp.apda_val_string,
                                                   'P', 1088,
                                                   'F', 964,
                                                   957)
                                       AND UPPER (z.apda_val_string) LIKE
                                               UPPER (
                                                   '%' || P_SHORT_NAME || '%')))
                   AND (   P_ADDR IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda = 973
                                       AND z.apda_val_string LIKE
                                               '%' || P_ADDR || '%'))
                   AND (   P_NST_ID IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM ap_service z
                                 WHERE     z.aps_ap = t.ap_id
                                       AND z.aps_nst = P_NST_ID));
    END;

    PROCEDURE GET_WORK_LIST (P_PROVIDER_TP   IN     VARCHAR2,  -- Тип надавача
                             P_AP_TP         IN     VARCHAR2, -- Тип звернення
                             P_AP_NUM        IN     VARCHAR2, -- Номер реєстраційної картки
                             P_AP_DT_START   IN     DATE, -- Дата реєстрації звернення з
                             P_AP_DT_STOP    IN     DATE, -- Дата реєстрації звернення по
                             P_MODE          IN     NUMBER, -- 1 - «На контролі», 2 - "Опрацювання рішення", 3 - оба
                             RES_CUR            OUT SYS_REFCURSOR)
    IS
        l_user   NUMBER := tools.GetCurrWu;
    BEGIN
        tools.WriteMsg ('DNET$RNSP_JOURNALS.' || $$PLSQL_UNIT);

        OPEN RES_CUR FOR
            SELECT t.ap_id,
                   t.ap_ext_ident                          AS rnspm_id,
                   t.Ap_St,
                   t.com_wu,
                   t.ap_num,                     -- Номер реєстраційної картки
                   t.ap_reg_dt,                   -- Дата реєстрації звернення
                   tpn.DIC_NAME                            AS provider_name, -- Тип надавача
                   atp.DIC_NAME                            AS appeal_tp_name, -- Тип звернення
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1087,
                                       'F', 963,
                                       956)
                           AND z.history_status = 'A')     AS full_name, -- Повна назва/прізвище
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1088,
                                       'F', 964,
                                       957)
                           AND z.history_status = 'A')     AS short_name, -- Скорочена назва/ім'я
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1089,
                                       'F', 965,
                                       -1)
                           AND z.history_status = 'A')     AS middle_name, -- Абревіатура/по батькові
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1085,
                                       'F', 961,
                                       955)
                           AND z.history_status = 'A')     AS edrpou, -- Код за ЄДРПОУ/РНОКПП
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string,
                                       'P', 1086,
                                       'F', 962,
                                       -1)
                           AND z.history_status = 'A')     AS pass_data, -- Серія та Номер паспорту/номер ІД-картки
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string, 'P', 1092, -1)
                           AND z.history_status = 'A')     AS nationality, -- Громадянство
                   (SELECT MAX (z.apda_val_string)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda =
                               DECODE (tp.apda_val_string, 'P', 1091, -1)
                           AND z.history_status = 'A')     AS birth_dt, -- дата народження
                   NULL                                    AS obl_name, -- Область місцезнаходження
                   NULL                                    AS addr_living, -- Адреса місцезнаходження/проживання
                   NULL                                    AS addr_service, -- Місце надання послуги
                   (SELECT LISTAGG (z.apda_val_dt, ',')
                               WITHIN GROUP (ORDER BY z.apda_nda)
                      FROM v_ap_document_attr z
                     WHERE     z.apda_apd = d.apd_id
                           AND z.apda_nda IN (968, 969, 970)
                           AND z.history_status = 'A')     AS contacts, -- Контактні дані
                   (SELECT CASE WHEN COUNT (*) > 0 THEN 'T' ELSE 'F' END
                      FROM v_rn_document  zd
                           LEFT JOIN v_rn_document_attr r
                               ON (    r.rnda_rnd = zd.rnd_id
                                   AND r.rnda_nda = 1114
                                   AND r.history_status = 'A')      -- Рішення
                           LEFT JOIN v_rn_document_attr p
                               ON (    p.rnda_rnd = zd.rnd_id
                                   AND p.rnda_nda = 1115
                                   AND p.history_status = 'A') -- Підстави прийняття рішення про повернення на доопрацювання
                     WHERE     zd.rnd_ap = t.ap_id
                           AND zd.rnd_ndt = 730
                           AND r.rnda_val_string = 'P'
                           AND p.rnda_val_string IS NOT NULL
                           AND zd.history_status = 'A')    AS can_return_string
              FROM appeal  t
                   JOIN histsession hs ON (hs.hs_id = t.ap_hs_oper)
                   JOIN v_ap_document d
                       ON (d.apd_ap = t.ap_id AND d.history_status = 'A')
                   JOIN v_ap_document_attr tp
                       ON (tp.apda_apd = d.apd_id AND tp.apda_nda = 953) -- Тип надавача
                   JOIN v_ap_document_attr apa
                       ON (apa.apda_apd = d.apd_id AND apa.apda_nda = 954) -- Тип звернення РНСП
                   JOIN uss_ndi.V_DDN_RNSP_TP tpn
                       ON (tpn.DIC_VALUE = tp.apda_val_string)
                   JOIN uss_ndi.V_DDN_RNSP_ST atp
                       ON (atp.DIC_VALUE = apa.apda_val_string)
             WHERE     1 = 1
                   AND d.apd_ndt = 700
                   AND hs.hs_wu = l_user
                   AND (   p_mode = 3 AND t.ap_st IN ('A', 'WD')
                        OR p_mode = 1 AND t.ap_st IN ('A')
                        OR p_mode = 2 AND t.ap_st IN ('WD')
                        OR 1 = 2)
                   AND (   P_PROVIDER_TP IS NULL
                        OR tp.apda_val_string = P_PROVIDER_TP)
                   AND (   P_AP_TP IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_document_attr z
                                 WHERE     z.apda_apd = d.apd_id
                                       AND z.apda_nda = 954
                                       AND z.apda_val_string = P_AP_TP))
                   AND (   P_AP_NUM IS NULL
                        OR t.ap_num LIKE '%' || P_AP_NUM || '%')
                   AND (P_AP_DT_START IS NULL OR t.ap_reg_dt >= P_AP_DT_START)
                   AND (P_AP_DT_STOP IS NULL OR t.ap_reg_dt <= P_AP_DT_STOP);
    END;

    PROCEDURE Get_document_reg (p_ap_id         NUMBER,
                                p_num       OUT NUMBER,
                                p_regdate   OUT DATE)
    IS
    BEGIN
        SELECT MAX (
                   (SELECT MAX (rnda_val_int)
                      FROM rn_Document_Attr
                     WHERE     rnda_rnd = rnd_id
                           AND rnda_nda = 1112                             --№
                           AND rn_Document_Attr.History_Status = 'A')),
               MAX (
                   (SELECT MAX (rnda_val_dt)
                      FROM rn_Document_Attr
                     WHERE     rnda_rnd = rnd_id
                           AND rnda_nda = 1113                          --Дата
                           AND rn_Document_Attr.History_Status = 'A'))
          INTO p_num, p_regdate
          FROM rn_Document
         WHERE rnd_ap = p_ap_id AND rnd_ndt = 730 AND history_status = 'A';
    END;

    --Опрацювання статусів
    /*
                    A
                    ^
                    |
    S -> A -> NS -> WD -> WI -> V
                    |
               P <- B
    */
    PROCEDURE Approve_Appeal (p_ap_id       NUMBER,
                              p_ap_st    IN VARCHAR2,
                              p_doc_id      NUMBER,
                              p_hs_id       NUMBER /*,
                                   p_pdf_data OUT  SYS_REFCURSOR*/
                                                  )
    IS
        l_hs                 NUMBER := tools.GetHistSession;
        l_prev_ap_num        VARCHAR2 (2000);
        l_edrpou             VARCHAR2 (2000);
        l_st                 appeal.ap_st%TYPE;
        l_st_name            VARCHAR2 (250);
        l_st_new             appeal.ap_st%TYPE;
        l_rnd_id             rn_document.rnd_id%TYPE;
        l_rnsp_decision      VARCHAR2 (500);
        l_BarCode            VARCHAR2 (500);
        l_QrCode             VARCHAR2 (500);
        l_Card_Info          VARCHAR2 (500);
        l_new_ap_id          NUMBER (14);
        l_id                 NUMBER (14);
        L_Content            BLOB;
        L_IsSkipSignFile     NUMBER (10) := 1;
        l_Wu                 NUMBER := tools.GetCurrWu;

        l_decision_num       NUMBER;
        l_decision_regdate   DATE;
        l_rnspm_id           NUMBER;

        l_OPFU_cod           NUMBER (10);
        l_OPFU_name          VARCHAR2 (250);
        l_ext_ident          NUMBER (10);
    BEGIN
        tools.WriteMsg ('DNET$RNSP_JOURNALS.' || $$PLSQL_UNIT);
        check_consistensy (p_ap_id, p_ap_st);
        /*
          S -> A -> NS -> WD -> WI
        */
        api$document.Get_UserOPFU (l_OPFU_cod, l_OPFU_name);
        Get_document_reg (p_ap_id, l_decision_num, l_decision_regdate);

        SELECT MAX (rnd_id), MAX (rnda_val_string)
          INTO l_rnd_id, l_rnsp_decision
          FROM rn_document
               LEFT JOIN rn_document_attr
                   ON     rnda_rnd = rnd_id
                      AND rnda_nda = 1114                          /*Рішення*/
                      AND rn_document_attr.history_status = 'A'
         WHERE     rnd_ap = p_ap_id
               AND rnd_ndt = 730
               AND rn_document.history_status = 'A';

        SELECT ap.ap_st,
               st.DIC_SNAME,
               CASE ap.ap_st
                   WHEN 'S' THEN 'A'
                   WHEN 'A' THEN 'NS'
                   WHEN 'NS' THEN 'WD'
                   WHEN 'WD' THEN 'WI'
                   ELSE ''
               END
                   AS ap_st_new,
               l_OPFU_cod || TO_CHAR (l_decision_regdate, 'YYYY') || l_rnd_id
                   AS BarCode,
                  l_OPFU_name
               || ';'
               || l_decision_num
               || ' від '
               || TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
                   AS QrCode,
                  TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
               || ' '
               || l_decision_num
                   AS card_info,
               ap.ap_ext_ident,
               (SELECT MAX (z.apda_val_string)
                  FROM ap_document_attr z
                 WHERE     z.apda_apd = d.apd_id
                       AND z.apda_nda =
                           DECODE (tp.apda_val_string,
                                   'P', 1085,
                                   'F', 961,
                                   955)
                       AND z.history_status = 'A')
                   AS edrpou
          INTO l_st,
               l_st_name,
               l_st_new,
               l_BarCode,
               l_QrCode,
               l_Card_Info,
               l_ext_ident,
               l_edrpou
          FROM appeal  ap
               JOIN Uss_Ndi.v_Ddn_Ap_St St ON St.Dic_Value = ap.Ap_St
               JOIN ap_document d
                   ON d.apd_ap = ap.ap_id AND d.history_status = 'A'
               JOIN ap_document_attr tp
                   ON     tp.apda_apd = d.apd_id
                      AND tp.apda_nda = 953
                      AND tp.history_status = 'A'              -- Тип надавача
         WHERE ap.ap_id = p_ap_id;

        IF l_st_new = 'A'
        THEN
            --Для визначення чи можна звернення взяти в роботу, додати контролі при натисканні кнопки «Взяти в роботу»:
            -- якщо від надавача, звернення від якого намагаються взяти в роботу, в РНСП вже є звернення у статусах not in (S, V),
            --то статус звернення, яке намагаються взяти в роботу, не змінювати і виводити повідомлення
            --«Звернення взяти в роботу не можливо. Від надавача ЄДРПОУ » + ЄДРПОУ + « на опрацюванні вже є звернення №» + №звернення, яке опрацьовується
            --++++ #87137
            --Виправити наявний контроль - звернення від одного й того ж надавача не можна взяти в роботу, якщо вже є звернення у статусах not in (S, V, X)
            SELECT LISTAGG (a.ap_num, ', ') WITHIN GROUP (ORDER BY a.ap_id)
              INTO l_prev_ap_num
              FROM appeal a
             WHERE     a.ap_st NOT IN ('S', 'V', 'X')
                   AND ap_ext_ident = l_ext_ident
                   AND ap_id != p_ap_id;

            IF l_prev_ap_num IS NOT NULL
            THEN
                raise_application_error (
                    -20000,
                       'Звернення взяти в роботу не можливо. Від надавача ЄДРПОУ '
                    || l_edrpou
                    || ' на опрацюванні вже є звернення № '
                    || l_prev_ap_num);
            END IF;

            -- якщо від надавача, звернення від якого намагаються взяти в роботу, в РНСП немає звернень у статусах not in (S, V),
            --але є звернення у статусі = S з датою створення < ніж у того, яке намагаються взяти в роботу, то статус звернення, яке намагаються взяти в роботу, не змінювати
            --і виводити повідомлення «Звернення взяти в роботу не можливо. Від надавача ЄДРПОУ » + ЄДРПОУ + « в черзі на опрацювання є звернення №» + №звернення, яке опрацьовується + «, яке потрібно опрацювати першим»
            SELECT LISTAGG (a.ap_num, ', ') WITHIN GROUP (ORDER BY a.ap_id)
              INTO l_prev_ap_num
              FROM appeal a
             WHERE     a.ap_st IN ('S')
                   AND ap_ext_ident = l_ext_ident
                   AND ap_id < p_ap_id;

            IF l_prev_ap_num IS NOT NULL
            THEN
                raise_application_error (
                    -20000,
                       'Звернення взяти в роботу не можливо. Від надавача ЄДРПОУ '
                    || l_edrpou
                    || ' в черзі на опрацювання є звернення № '
                    || l_prev_ap_num
                    || ', яке потрібно опрацювати першим');
            END IF;
        --#87437 2023.05.22
        /*При спробі відправки рішення на затвердження (зміни статусу на ‘WD’) додати контроль з типом «Помилка»:
        якщо в документі «Рішення про включення / повернення на доопрацювання надавачем поданих документів» ndt_id=730
        в атрибуті "Рішення" nda_id=1114 встановлено значення «про повернення на доопрацювання надавачу…» (P)
        і при цьому атрибут «Підстави прийняття рішення про повернення на доопрацювання» nda_id=1115 is NULL*/
        ELSIF     l_st_new = 'NS'
              AND l_rnsp_decision = 'P'
              AND api$document.Get_Attr_Val_String (p_ap_id, 730, 1115)
                      IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не вказано  "Підстави прийняття рішення про повернення на доопрацювання"');
        END IF;

        IF l_st NOT IN ('S',
                        'A',
                        'NS',
                        'WD')
        THEN
            raise_application_error (
                -20000,
                   'Звернення не можливо підтвердити зі статуса '
                || l_st_name
                || '.');
        ELSIF l_st_new IN ('NS')
        THEN
            IF l_rnsp_decision IS NULL
            THEN
                raise_application_error (
                    -20000,
                    'Відправити на затвердження неможливо, не обрано варіант у полі "Рішення"');
            END IF;
        ELSIF l_st_new IN ('WI')
        THEN
            IF NVL (l_rnsp_decision, 'P') = 'P'
            THEN
                raise_application_error (
                    -20000,
                       'Звернення не можливо підтвердити, так як сформовано рішення '
                    || '"Про повернення на доопрацювання поданих документів надавачу соціальних послуг"');
            END IF;
        END IF;

        -- S/NS - взяття в роботу
        UPDATE appeal ap
           SET ap.ap_st = l_st_new,
               ap.ap_hs_oper = l_hs,
               ap.com_wu =
                   CASE
                       WHEN p_ap_st IN ('S', 'NS') THEN l_wu
                       ELSE ap.com_wu
                   END
         WHERE ap.ap_id = p_ap_id;

        IF l_st_new IN ('A')
        THEN
            Api$Document.Update_appeal_ap_ext_ident (p_ap_id, l_new_ap_id);
            API$Document.Create_document730 (p_ap_id, l_rnd_id);
            Api$check_Right.init_right_for_appeals (1, p_ap_id);

            UPDATE rnsp_main m
               SET m.rnspm_ap_edit = p_ap_id
             WHERE m.rnspm_id IN (SELECT ap_ext_ident
                                    FROM appeal
                                   WHERE ap_id = p_ap_id);
        ELSIF l_st_new IN ('WD')
        THEN
            API$Document.Update_document730_pib (p_ap_id);
        ELSIF l_st_new IN ('WI')
        THEN
            API$Document.MERGE_dict_service (p_ap_id);
            API$Document.Update_document730 (l_rnd_id, p_doc_id, p_hs_id);
            API$RNSP_ACTION.PrepareCopy_RNSP2Visit (p_ap        => p_ap_id,
                                                    p_ST_OLD    => l_st,
                                                    p_message   => NULL);

            IF l_ext_ident IS NOT NULL
            THEN
                PRIV$rnsp_status_register.save (
                    p_rnspsr_id       => NULL,
                    p_rnspsr_rnspm    => l_ext_ident,
                    p_rnspsr_date     => SYSDATE,
                    p_rnspsr_reason   => 'Данні оновлено',
                    p_rnspsr_hs       => l_hs,
                    p_rnspsr_st       => 'A',
                    p_new_id          => l_id);
            END IF;
        --      UPDATE rnsp_main m SET
        --        m.rnspm_ap_edit = NULL
        --      WHERE m.rnspm_id IN (SELECT ap_ext_ident FROM appeal WHERE ap_id = p_ap_id);

        END IF;


        Write_Log (p_Apl_Ap        => p_ap_id,
                   p_Apl_Hs        => l_hs,
                   p_Apl_St        => l_st_new,
                   p_Apl_Message   => CHR (38) || Get_Tmpl_Code (l_st_new),
                   p_Apl_St_Old    => l_st,
                   p_Apl_Tp        => 'G');

        /*
            IF l_st_new IN ('A') THEN
              L_IsSkipSignFile := 1;
            ELSE
               SELECT CASE NVL(rnda.rnda_val_string, '-') WHEN 'D' THEN 1 ELSE 0 END
                 INTO L_IsSkipSignFile
               FROM v_rn_document rnd
                      LEFT JOIN v_rn_document_attr rnda ON rnda.rnda_rnd = rnd.rnd_id AND rnda.history_status = 'A'
               WHERE rnd.rnd_ap = p_ap_id
                 AND rnd.rnd_ndt = 730
                 AND rnd.history_status = 'A'
                 AND rnda.rnda_nda = 1114;
            END IF;
            IF L_IsSkipSignFile = 0 THEN
              L_Content         := API$RTF.get_decision_approve_blob(p_ap_id);
            END IF;

            OPEN p_pdf_data FOR
              SELECT rnd.rnd_doc  AS doc_Id,
                     rnd.rnd_dh   AS dh_id,
                     l_BarCode AS BarCode,
                       l_QrCode AS QrCode,
                       l_OPFU_Name AS Org_Name,
                       l_Card_Info AS Card_Info,
                       '"сформований номер.pdf' AS FileName,
                       L_Content AS Content,
                       L_IsSkipSignFile AS IsSkipSignFile
                FROM rn_document rnd
                WHERE rnd_id = l_rnd_id AND l_st_new = 'WI';
        */
        IF l_st_new = 'WI'
        THEN
            API$Document.Save_appeal_2_rnsp (p_ap_id);

            UPDATE appeal ap
               SET ap.ap_st = 'V', ap.ap_hs_oper = l_hs
             WHERE ap.ap_id = p_ap_id;

            SELECT MAX (t.rnspm_id)
              INTO l_rnspm_id
              FROM rnsp_main t
             WHERE t.rnspm_ap_edit = p_ap_id;

            -- #107822 (п.1)
            IF (l_rnsp_decision = 'D')
            THEN
                UPDATE rnsp_main t
                   SET t.rnspm_st = 'D'
                 WHERE t.rnspm_id = l_rnspm_id;
            END IF;

            -- #113530
            UPDATE rnsp_main t
               SET t.rnspm_tp =
                       NVL (
                           api$document.Get_Apda_Val_String (
                               p_Ap_Id     => p_ap_id,
                               p_apd_ndt   => 700,
                               p_Nda_Id    => 953),
                           t.rnspm_tp)
             WHERE t.rnspm_id = l_rnspm_id;


            Write_Log (p_Apl_Ap        => p_ap_id,
                       p_Apl_Hs        => l_hs,
                       p_Apl_St        => 'V',
                       p_Apl_Message   => CHR (38) || Get_Tmpl_Code ('V'),
                       p_Apl_St_Old    => l_st_new,
                       p_Apl_Tp        => 'G');
        END IF;
    END;

    PROCEDURE get_decision_approve_blob (p_ap_id          NUMBER,
                                         p_pdf_data   OUT SYS_REFCURSOR)
    IS
        L_Content            BLOB;
        l_rnd_id             rn_document.rnd_id%TYPE;
        l_rnsp_decision      VARCHAR2 (500);
        l_BarCode            VARCHAR2 (500);
        l_QrCode             VARCHAR2 (500);
        l_Card_Info          VARCHAR2 (500);
        l_decision_num       NUMBER;
        l_decision_regdate   DATE;
        l_OPFU_cod           NUMBER (10);
        l_OPFU_name          VARCHAR2 (250);
        l_ext_ident          NUMBER (10);
    BEGIN
        api$document.Get_UserOPFU (l_OPFU_cod, l_OPFU_name);
        Get_document_reg (p_ap_id, l_decision_num, l_decision_regdate);

        SELECT MAX (rnd_id), MAX (rnda_val_string)
          INTO l_rnd_id, l_rnsp_decision
          FROM rn_document
               LEFT JOIN rn_document_attr
                   ON     rnda_rnd = rnd_id
                      AND rnda_nda = 1114                          /*Рішення*/
                      AND rn_document_attr.history_status = 'A'
         WHERE     rnd_ap = p_ap_id
               AND rnd_ndt = 730
               AND rn_document.history_status = 'A';

        SELECT                                       --ap.ap_st, st.DIC_SNAME,
               l_OPFU_cod || TO_CHAR (l_decision_regdate, 'YYYY') || l_rnd_id
                   AS BarCode,
                  l_OPFU_name
               || ';'
               || l_decision_num
               || ' від '
               || TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
                   AS QrCode,
                  TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
               || ' '
               || l_decision_num
                   AS card_info,
               ap.ap_ext_ident
          INTO                                              --l_st, l_st_name,
               l_BarCode,
               l_QrCode,
               l_Card_Info,
               l_ext_ident
          FROM appeal ap
         --JOIN Uss_Ndi.v_Ddn_Ap_St St ON St.Dic_Value = ap.Ap_St
         WHERE ap.ap_id = p_ap_id;

        L_Content := API$RTF.get_decision_approve_blob (p_ap_id);

        OPEN p_pdf_data FOR
            SELECT rnd.rnd_doc                  AS doc_Id,
                   rnd.rnd_dh                   AS dh_id,
                   l_BarCode                    AS BarCode,
                   l_QrCode                     AS QrCode,
                   l_OPFU_Name                  AS Org_Name,
                   l_Card_Info                  AS Card_Info,
                   '"сформований номер.pdf'     AS FileName,
                   L_Content                    AS Content,
                   0                            AS IsSkipSignFile
              FROM rn_document rnd
             WHERE rnd_id = l_rnd_id;
    END;


    PROCEDURE Approve_Appeal (p_ap_id IN NUMBER, p_ap_st VARCHAR2)
    IS
        l_pdf_data   SYS_REFCURSOR;
    BEGIN
        Approve_Appeal (p_ap_id,
                        p_ap_st,
                        NULL,
                        NULL                                  /*, l_pdf_data*/
                            );
    END;

    PROCEDURE Get_A_WU (p_ap_id NUMBER, p_hs_wu OUT histsession.hs_wu%TYPE)
    IS
    BEGIN
        FOR l
            IN (  SELECT L.APL_ID, L.APL_HS, h.hs_wu
                    FROM ap_log L JOIN histsession h ON l.apl_hs = h.hs_id
                   WHERE     L.APL_AP = p_ap_id
                         AND L.APL_ST = 'A'
                         AND L.APL_ST_OLD = 'S'
                ORDER BY 1)
        LOOP
            p_hs_wu := l.hs_wu;
        END LOOP;
    END;

    PROCEDURE Reject_Appeal (p_ap_id    NUMBER,
                             p_ap_st    VARCHAR2,
                             p_reason   ap_log.apl_message%TYPE:= NULL)
    IS
        l_hs          NUMBER := tools.GetHistSession;
        l_hs_wu       histsession.hs_wu%TYPE;
        l_st          appeal.ap_st%TYPE;
        l_st_name     VARCHAR2 (250);
        l_st_new      appeal.ap_st%TYPE;
        l_rnspm_id    NUMBER;
        l_Ap_Sub_Tp   VARCHAR2 (10);
        l_msg         VARCHAR2 (4000);
    BEGIN
        tools.WriteMsg ('DNET$RNSP_JOURNALS.' || $$PLSQL_UNIT);
        check_consistensy (p_ap_id, p_ap_st);

        /*
        WD -> A
        */
        SELECT ap.ap_st, st.DIC_SNAME, ap.ap_ext_ident
          INTO l_st, l_st_name, l_rnspm_id
          FROM appeal  ap
               JOIN Uss_Ndi.v_Ddn_Ap_St St ON St.Dic_Value = ap.Ap_St
         WHERE ap.ap_id = p_ap_id;

        IF l_st NOT IN ('WD')
        THEN
            raise_application_error (
                -20000,
                   'Звернення не можливо повернути на доопрацювання зі статуса '
                || l_st_name
                || '.');
        END IF;

        l_st_new := 'A';

        Write_Log (
            p_Apl_Ap        => p_ap_id,
            p_Apl_Hs        => l_hs,
            p_Apl_St        => l_st_new,
            p_Apl_Message   =>
                CHR (38) || Get_Tmpl_Code (l_st_new) || '#' || p_reason,
            p_Apl_St_Old    => l_st,
            p_Apl_Tp        => 'G');

        Get_A_WU (p_ap_id, l_hs_wu);

        INSERT INTO histsession (hs_id, hs_wu, hs_dt)
             VALUES (0, l_hs_wu, SYSDATE)
          RETURNING hs_id
               INTO l_hs;

        UPDATE appeal ap
           SET ap.ap_st = l_st_new,
               ap.ap_hs_oper = l_hs,
               ap.com_wu =
                   (SELECT DISTINCT
                           LAST_VALUE (s.hs_wu)
                               OVER (
                                   ORDER BY apl_id
                                   ROWS BETWEEN UNBOUNDED PRECEDING
                                        AND     UNBOUNDED FOLLOWING)
                      FROM ap_log l JOIN histsession s ON s.hs_id = l.apl_hs
                     WHERE     apl_st = 'A'
                           AND apl_st_old = 'S'
                           AND apl_ap = ap.ap_id)
         WHERE ap.ap_id = p_ap_id;

        --API$appeal.Create_document730 (p_ap_id, p_doc_id, p_hs_id, l_apd_id);

        SELECT Api$document.Get_Apda_Str (d.Apd_Id, 954)
          INTO l_Ap_Sub_Tp
          FROM Ap_Document d
         WHERE     d.Apd_Ap = p_Ap_Id
               AND d.Apd_Ndt = 700
               AND d.History_Status = 'A';

        l_msg :=
               'Заяву про '
            || CASE l_Ap_Sub_Tp
                   WHEN 'A'
                   THEN
                          'включення надавача "'
                       || Api$find.Get_Nsp_Name (l_Rnspm_Id)
                       || '" до реєстру надавачів соціальних послуг'
                   WHEN 'U'
                   THEN
                          'зміну даних надавача "'
                       || Api$find.Get_Nsp_Name (l_Rnspm_Id)
                       || '" в реєстрі надавачів соціальних послуг.'
               END
            || ' відхилено. Причина: '
            || p_reason;


        uss_person.api$nt_api.Sendrnspmail (
            p_Rnspm_Id   => l_rnspm_id,
            p_Source     => '42',
            p_Title      => 'ЄІССС: заяву відхилено',
            p_Text       => l_msg);
    END;

    PROCEDURE Get_NS_WU (p_ap_id NUMBER, p_hs_wu OUT histsession.hs_wu%TYPE)
    IS
    BEGIN
        FOR l
            IN (  SELECT L.APL_ID, L.APL_HS, h.hs_wu
                    FROM ap_log L JOIN histsession h ON l.apl_hs = h.hs_id
                   WHERE     L.APL_AP = p_ap_id
                         AND L.APL_ST = 'WD'
                         AND L.APL_ST_OLD = 'NS'
                ORDER BY 1)
        LOOP
            p_hs_wu := l.hs_wu;
        END LOOP;
    END;

    /*
         NS <- WD
         S <- A
    */

    PROCEDURE Return_Appeal (p_ap_id    NUMBER,
                             p_reason   ap_log.apl_message%TYPE:= NULL)
    IS
        l_hs        NUMBER := tools.GetHistSession;
        l_st        appeal.ap_st%TYPE;
        l_st_name   VARCHAR2 (250);
        l_st_new    appeal.ap_st%TYPE;
        l_hs_wu     histsession.hs_wu%TYPE;
    BEGIN
        tools.WriteMsg ('DNET$RNSP_JOURNALS.' || $$PLSQL_UNIT);

        SELECT ap.ap_st,
               st.DIC_SNAME,
               CASE ap.ap_st WHEN 'A' THEN 'S' WHEN 'WD' THEN 'NS' END
          INTO l_st, l_st_name, l_st_new
          FROM appeal  ap
               JOIN Uss_Ndi.v_Ddn_Ap_St St ON St.Dic_Value = ap.Ap_St
               LEFT JOIN v_Opfu Opfu ON ap.Com_Org = Opfu.Org_Id
         WHERE ap.ap_id = p_ap_id;

        IF l_st_new IS NULL
        THEN
            raise_application_error (
                -20000,
                   'Звернення не можливо повернути зі статуса '
                || l_st_name
                || '.');
        END IF;

        IF l_st_new = 'NS'
        THEN
            Get_NS_WU (p_ap_id, l_hs_wu);
        ELSIF l_st_new = 'S'
        THEN
            l_hs_wu := '';
        END IF;

        UPDATE appeal ap
           SET ap.ap_st = l_st_new, ap.ap_hs_oper = l_hs, ap.com_wu = l_hs_wu
         WHERE ap.ap_id = p_ap_id;

        Write_Log (
            p_Apl_Ap        => p_ap_id,
            p_Apl_Hs        => l_hs,
            p_Apl_St        => l_st_new,
            p_Apl_Message   =>
                CHR (38) || Get_Tmpl_Code (l_st_new) || '#' || p_reason,
            p_Apl_St_Old    => l_st,
            p_Apl_Tp        => 'G');
    /*
    API$RNSP_ACTION.PrepareCopy_RNSP2Visit(p_ap => p_ap_id,
                                           p_ST_OLD => l_st,
                                           p_message => p_reason);
    */
    END;

    PROCEDURE Return_Appeal (p_ap_id    IN NUMBER,
                             p_ap_st    IN VARCHAR2,
                             p_doc_id      NUMBER,
                             p_hs_id       NUMBER,
                             --p_pdf_data OUT  SYS_REFCURSOR,
                             p_reason      ap_log.apl_message%TYPE := NULL)
    IS
        l_hs                 NUMBER := tools.GetHistSession;
        l_st                 appeal.ap_st%TYPE;
        l_st_name            VARCHAR2 (250);
        l_st_new             appeal.ap_st%TYPE;
        l_rnd_id             ap_document.apd_id%TYPE;
        l_BarCode            VARCHAR2 (500);
        l_QrCode             VARCHAR2 (500);
        l_Card_Info          VARCHAR2 (500);
        l_OPFU_cod           VARCHAR2 (10);
        l_OPFU_name          VARCHAR2 (250);
        l_decision_num       NUMBER;
        l_decision_regdate   DATE;
        l_ap_tp              appeal.ap_tp%TYPE;
        l_ap_src             appeal.ap_src%TYPE;
    BEGIN
        check_consistensy (p_ap_id, p_ap_st);
        /*
        WD -> B(X)
        */
        api$document.Get_UserOPFU (l_OPFU_cod, l_OPFU_name);
        Get_document_reg (p_ap_id, l_decision_num, l_decision_regdate);

        --
        SELECT MAX (rnd_id)
          INTO l_rnd_id
          FROM rn_document
         WHERE rnd_ap = p_ap_id AND rnd_ndt = 730 AND history_status = 'A';

        SELECT ap.ap_st,
               st.DIC_SNAME,
               l_OPFU_cod || TO_CHAR (l_decision_regdate, 'YYYY') || l_rnd_id
                   AS BarCode,
                  l_OPFU_name
               || ';'
               || l_decision_num
               || ' від '
               || TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
                   AS QrCode,
                  TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
               || ' '
               || l_decision_num
                   AS card_info,
               ap.ap_tp,
               ap.ap_src
          INTO l_st,
               l_st_name,
               l_BarCode,
               l_QrCode,
               l_Card_Info,
               l_ap_tp,
               l_ap_src
          FROM appeal  ap
               JOIN Uss_Ndi.v_Ddn_Ap_St St ON St.Dic_Value = ap.Ap_St
         WHERE ap.ap_id = p_ap_id;


        IF l_ap_tp = 'G' AND l_ap_src = 'PORTAL'
        THEN
            --#97338 21.01.2024
            l_st_new := 'X';
        ELSE
            l_st_new := 'B';
        END IF;

        IF l_st NOT IN ('WD')
        THEN
            raise_application_error (
                -20000,
                   'Звернення не можливо повернути повернути на доопрацювання зі статуса '
                || l_st_name
                || '.');
        END IF;

        UPDATE appeal ap
           SET ap.ap_st = l_st_new, ap.ap_hs_oper = l_hs
         WHERE ap.ap_id = p_ap_id;

        IF l_rnd_id IS NULL
        THEN
            raise_application_error (-20000, ' rnd_id пустое ');
        ELSIF p_doc_id IS NULL OR p_hs_id IS NULL
        THEN
            raise_application_error (-20000,
                                     ' p_doc_id IS NULL OR p_hs_id IS NULL');
        END IF;

        API$Document.Update_document730 (l_rnd_id, p_doc_id, p_hs_id);

        API$RNSP_ACTION.PrepareCopy_RNSP2Visit (p_ap        => p_ap_id,
                                                p_ST_OLD    => l_st,
                                                p_message   => p_reason);

        Write_Log (
            p_Apl_Ap        => p_ap_id,
            p_Apl_Hs        => l_hs,
            p_Apl_St        => l_st_new,
            p_Apl_Message   =>
                CHR (38) || Get_Tmpl_Code (l_st_new) || '#' || p_reason,
            p_Apl_St_Old    => l_st,
            p_Apl_Tp        => 'G');
    /*
          OPEN p_pdf_data FOR
            SELECT rnd.rnd_doc  AS doc_Id,
                   rnd.rnd_dh   AS dh_id,
                   l_BarCode AS BarCode,
                   l_QrCode AS QrCode,
                   l_OPFU_Name AS Org_Name,
                   l_Card_Info AS Card_Info,
                   '' AS FileName,
                   API$RTF.get_decision_approve_blob(p_ap_id) AS Content
            FROM rn_document rnd
            WHERE rnd_id = l_rnd_id;
    */
    END;

    --==============================================================--
    PROCEDURE get_Return_Appeal_blob (p_ap_id          NUMBER,
                                      p_pdf_data   OUT SYS_REFCURSOR)
    IS
        l_st                 appeal.ap_st%TYPE;
        l_st_name            VARCHAR2 (250);
        l_st_new             appeal.ap_st%TYPE;

        l_rnd_id             ap_document.apd_id%TYPE;
        l_BarCode            VARCHAR2 (500);
        l_QrCode             VARCHAR2 (500);
        l_Card_Info          VARCHAR2 (500);
        l_OPFU_cod           VARCHAR2 (10);
        l_OPFU_name          VARCHAR2 (250);
        l_decision_num       NUMBER;
        l_decision_regdate   DATE;
    BEGIN
        api$document.Get_UserOPFU (l_OPFU_cod, l_OPFU_name);
        Get_document_reg (p_ap_id, l_decision_num, l_decision_regdate);

        --
        SELECT MAX (rnd_id)
          INTO l_rnd_id
          FROM rn_document
         WHERE rnd_ap = p_ap_id AND rnd_ndt = 730 AND history_status = 'A';


        SELECT ap.ap_st,
               st.DIC_SNAME,
               l_OPFU_cod || TO_CHAR (l_decision_regdate, 'YYYY') || l_rnd_id
                   AS BarCode,
                  l_OPFU_name
               || ';'
               || l_decision_num
               || ' від '
               || TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
                   AS QrCode,
                  TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
               || ' '
               || l_decision_num
                   AS card_info
          INTO l_st,
               l_st_name,
               l_BarCode,
               l_QrCode,
               l_Card_Info
          FROM appeal  ap
               JOIN Uss_Ndi.v_Ddn_Ap_St St ON St.Dic_Value = ap.Ap_St
         WHERE ap.ap_id = p_ap_id;

        IF l_rnd_id IS NULL
        THEN
            raise_application_error (-20000, ' rnd_id пустое ');
        END IF;

        OPEN p_pdf_data FOR
            SELECT rnd.rnd_doc                                     AS doc_Id,
                   rnd.rnd_dh                                      AS dh_id,
                   l_BarCode                                       AS BarCode,
                   l_QrCode                                        AS QrCode,
                   l_OPFU_Name                                     AS Org_Name,
                   l_Card_Info                                     AS Card_Info,
                   ''                                              AS FileName,
                   API$RTF.get_decision_approve_blob (p_ap_id)     AS Content
              FROM rn_document rnd
             WHERE rnd_id = l_rnd_id;
    END;

    --==============================================================--
    PROCEDURE Approve_RND (p_rnd_id IN NUMBER, p_rnd_st IN VARCHAR2)
    IS
        l_hs                 NUMBER := tools.GetHistSession;
        l_st                 appeal.ap_st%TYPE;
        l_st_name            VARCHAR2 (250);
        l_st_new             appeal.ap_st%TYPE;
        l_rnsp_decision      VARCHAR2 (500);
        l_BarCode            VARCHAR2 (500);
        l_QrCode             VARCHAR2 (500);
        l_Card_Info          VARCHAR2 (500);
        l_id                 NUMBER (14);
        l_rnspm_id           NUMBER (14);
        L_Content            BLOB;
        L_IsSkipSignFile     NUMBER (10) := 1;
        l_Wu                 NUMBER := tools.GetCurrWu;

        l_decision_num       NUMBER;
        l_decision_regdate   DATE;

        l_OPFU_cod           NUMBER (10);
        l_OPFU_name          VARCHAR2 (250);
    BEGIN
        check_consistensy_rnd (p_rnd_id, p_rnd_st);

        /*
          A -> WD -> V
        */
        api$document.Get_UserOPFU (l_OPFU_cod, l_OPFU_name);

        SELECT (SELECT MAX (rnda_val_int)
                  FROM rn_Document_Attr
                 WHERE     rnda_rnd = rnd_id
                       AND rnda_nda = 1112                                 --№
                       AND rn_Document_Attr.History_Status = 'A'),
               (SELECT MAX (rnda_val_dt)
                  FROM rn_Document_Attr
                 WHERE     rnda_rnd = rnd_id
                       AND rnda_nda = 1113                              --Дата
                       AND rn_Document_Attr.History_Status = 'A'),
               (SELECT MAX (rnda_val_string)
                  FROM rn_Document_Attr
                 WHERE     rnda_rnd = rnd_id
                       AND rnda_nda = 1112                                 --№
                       AND rn_Document_Attr.History_Status = 'A')
          INTO l_decision_num, l_decision_regdate, l_rnsp_decision
          FROM rn_Document
         WHERE rnd_id = p_rnd_id AND rnd_ndt = 730 AND history_status = 'A';

        SELECT rnd.rnd_st,
               st.DIC_SNAME,
               CASE rnd.rnd_st
                   WHEN 'A' THEN 'WD'
                   WHEN 'WD' THEN 'V'
                   ELSE ''
               END
                   AS rnd_st_new,
               l_OPFU_cod || TO_CHAR (l_decision_regdate, 'YYYY') || rnd_id
                   AS BarCode,
                  l_OPFU_name
               || ';'
               || l_decision_num
               || ' від '
               || TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
                   AS QrCode,
                  TO_CHAR (l_decision_regdate, 'dd.mm.yyyy')
               || ' '
               || l_decision_num
                   AS card_info,
               rnd.rnd_rnspm
          INTO l_st,
               l_st_name,
               l_st_new,
               l_BarCode,
               l_QrCode,
               l_Card_Info,
               l_rnspm_id
          FROM rn_Document  rnd
               JOIN Uss_Ndi.v_Ddn_rnsp_rnd_St St ON St.Dic_Value = rnd.rnd_St
         WHERE rnd_id = p_rnd_id;

        IF l_rnspm_id IS NULL
        THEN
            raise_application_error (-20000,
                                     'Не знайдено Картку для закриття!');
        END IF;

        IF l_st NOT IN ('A', 'WD')
        THEN
            raise_application_error (
                -20000,
                   'Рішення не можливо підтвердити зі статуса '
                || l_st_name
                || '.');
        END IF;

        UPDATE rn_document rn
           SET rn.rnd_st = l_st_new
         WHERE rnd_id = p_rnd_id;

        IF l_st_new = 'V'
        THEN
            API$Document.Update_userpib (p_rnd_id);

            UPDATE rnsp_main
               SET rnspm_st = 'D', rnspm_date_out = TRUNC (SYSDATE)
             WHERE rnspm_id = l_rnspm_id;

            PRIV$rnsp_status_register.save (p_rnspsr_id       => NULL,
                                            p_rnspsr_rnspm    => l_rnspm_id,
                                            p_rnspsr_date     => SYSDATE,
                                            p_rnspsr_reason   => 'Закрито',
                                            p_rnspsr_hs       => l_hs,
                                            p_rnspsr_st       => 'D',
                                            p_new_id          => l_id);
        END IF;

        NULL;
    END;

    --==============================================================--
    PROCEDURE Return_RND (p_rnd_id IN NUMBER, p_rnd_st IN VARCHAR2)
    IS
        l_hs         NUMBER := tools.GetHistSession;
        l_st         appeal.ap_st%TYPE;
        l_st_name    VARCHAR2 (250);
        l_st_new     appeal.ap_st%TYPE;
        l_rnspm_id   NUMBER (14);
    BEGIN
        check_consistensy_rnd (p_rnd_id, p_rnd_st);

        SELECT rnd.rnd_st,
               st.DIC_SNAME,
               CASE rnd.rnd_st WHEN 'WD' THEN 'A' ELSE '' END
                   AS rnd_st_new,
               rnd.rnd_rnspm
          INTO l_st,
               l_st_name,
               l_st_new,
               l_rnspm_id
          FROM rn_Document  rnd
               JOIN Uss_Ndi.v_Ddn_rnsp_rnd_St St ON St.Dic_Value = rnd.rnd_St
         WHERE rnd_id = p_rnd_id;

        IF l_st NOT IN ('WD')
        THEN
            raise_application_error (
                -20000,
                   'Рішення не можливо повернути на доопрацювання зі статуса '
                || l_st_name
                || '.');
        END IF;

        UPDATE rn_document rn
           SET rn.rnd_st = l_st_new
         WHERE rnd_id = p_rnd_id;
    END;

    --==============================================================--
    PROCEDURE Reject_RND (p_rnd_id NUMBER, p_rnd_st IN VARCHAR2)
    IS
        l_hs        NUMBER := tools.GetHistSession;
        l_hs_wu     histsession.hs_wu%TYPE;
        l_st        appeal.ap_st%TYPE;
        l_st_name   VARCHAR2 (250);
        l_st_new    appeal.ap_st%TYPE;
    BEGIN
        check_consistensy_rnd (p_rnd_id, p_rnd_st);

        SELECT rnd.rnd_st,
               st.DIC_SNAME,
               CASE rnd.rnd_st WHEN 'WD' THEN 'X' ELSE '' END    AS rnd_st_new
          INTO l_st, l_st_name, l_st_new
          FROM rn_Document  rnd
               JOIN Uss_Ndi.v_Ddn_rnsp_rnd_St St ON St.Dic_Value = rnd.rnd_St
         WHERE rnd_id = p_rnd_id;

        IF l_st NOT IN ('WD')
        THEN
            raise_application_error (
                -20000,
                'Рішення не можливо закрити зі статуса ' || l_st_name || '.');
        END IF;

        UPDATE rn_document rn
           SET rn.rnd_st = l_st_new
         WHERE rnd_id = p_rnd_id;
    END;

    --==============================================================--

    -- info:   Выбор информации об документах в обращении
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Documents (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT d.rnd_Id,
                   d.rnd_Ndt,
                   t.Ndt_Name_Short
                       AS rnd_Ndt_Name,
                   d.rnd_Doc,
                   d.rnd_App,
                   p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn
                       AS Rnd_App_Name,
                   --серія та номер документа
                    (SELECT a.rnda_Val_String
                       FROM rn_Document_Attr  a
                            JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                ON     a.rnda_Nda = n.Nda_Id
                                   AND n.Nda_Class = 'DSN'
                      WHERE a.rnda_rnd = d.rnd_Id AND a.History_Status = 'A')
                       AS rnd_Seria_Num,
                   d.rnd_Dh,
                   d.rnd_Dh
                       AS rnd_Dh_Old,
                   s.aps_nst,
                   (SELECT COUNT (*)
                      FROM rn_Document_Attr z
                     WHERE        z.rnda_rnd = d.rnd_id
                              AND z.history_status = 'A'
                              AND z.rnda_val_int IS NOT NULL
                           OR z.rnda_val_sum IS NOT NULL
                           OR z.rnda_val_id IS NOT NULL
                           OR z.rnda_val_dt IS NOT NULL
                           OR z.rnda_val_string IS NOT NULL)
                       AS Is_Attributed
              FROM rn_Document  d
                   LEFT JOIN Uss_Ndi.v_Ndi_Document_Type t
                       ON d.rnd_Ndt = t.Ndt_Id
                   LEFT JOIN Ap_Person p ON d.rnd_App = p.App_Id
                   LEFT JOIN ap_service s ON (s.aps_id = d.rnd_aps)
             WHERE d.rnd_Ap = p_Ap_Id AND d.History_Status = 'A';
    END;

    ----------------------------------------
    -- info:   Выбор информации об документах (атрибуты)
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Documents_Attr (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
              SELECT rnda.rnda_Id,
                     rnda.rnda_rnd,
                     rnda.rnda_Nda,
                     rnda.rnda_Val_Int,
                     rnda.rnda_Val_Dt,
                     rnda.rnda_Val_String,
                     rnda.rnda_Val_Id,
                     rnda.rnda_Val_Sum,
                     Nda.Nda_Id,
                     Nda.Nda_Name,
                     Nda.Nda_Is_Key,
                     Nda.Nda_Ndt,
                     Nda.Nda_Order,
                     Nda.Nda_Pt,
                     Nda.Nda_Is_Req,
                     Nda.Nda_Def_Value,
                     Nda.Nda_Can_Edit,
                     Nda.Nda_Need_Show,
                     Pt.Pt_Id,
                     Pt.Pt_Code,
                     Pt.Pt_Name,
                     Pt.Pt_Ndc,
                     Pt.Pt_Edit_Type,
                     Pt.Pt_Data_Type,
                     CASE
                         WHEN     rnda.rnda_apda IS NOT NULL
                              AND (   apda.apda_val_int IS NOT NULL
                                   OR apda.apda_val_sum IS NOT NULL
                                   OR apda.apda_val_id IS NOT NULL
                                   OR apda.apda_val_dt IS NOT NULL
                                   OR apda.apda_val_string IS NOT NULL)
                         THEN
                             'T'
                         ELSE
                             'F'
                     END    AS is_Disabled
                --CASE WHEN nda.nda_can_edit = 'T' THEN 'T' ELSE 'F' END AS is_Disabled
                FROM rn_Document rnd
                     JOIN rn_Document_Attr rnda
                         ON     rnda.rnda_rnd = rnd.rnd_Id
                            AND rnda.History_Status = 'A'
                     JOIN Uss_Ndi.v_Ndi_Document_Attr Nda
                         ON Nda.Nda_Id = rnda.rnda_Nda
                     JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
                     LEFT JOIN ap_Document_Attr apda
                         ON     apda.apda_id = rnda.rnda_apda
                            AND apda.History_Status = 'A'
               WHERE rnd.rnd_Ap = p_Ap_Id AND rnd.History_Status = 'A'
            ORDER BY Nda.Nda_Order;
    END;

    -- info:   Выбор информации об документах (файлы)
    -- params: p_ap_id - ідентифікатор обращения
    -- note:
    PROCEDURE Get_Documents_Files (p_Ap_Id NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT rnd_Dh
              FROM rn_Document
             WHERE rnd_Ap = p_Ap_Id AND History_Status = 'A';

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Attachments (p_Doc_Id        => NULL,
                                               p_Dh_Id         => NULL,
                                               p_Res           => p_Res,
                                               p_Params_Mode   => 3);
    END;

    PROCEDURE GET_DOC_LIST (P_AP_ID     IN     NUMBER,
                            DOC_CUR        OUT SYS_REFCURSOR,
                            ATTR_CUR       OUT SYS_REFCURSOR,
                            FILES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$RNSP_JOURNALS.' || $$PLSQL_UNIT);
        Get_Documents (p_Ap_Id => p_Ap_Id, p_Res => Doc_Cur);
        Get_Documents_Attr (p_Ap_Id => p_Ap_Id, p_Res => Attr_Cur);
        Get_Documents_Files (p_Ap_Id => p_Ap_Id, p_Res => Files_Cur);
    END;

    -- info:   Выбор информации об
    -- params:
    -- note:
    PROCEDURE Get_Nda_List (p_Ndt_Id NUMBER, p_Nda_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Nda_Cur FOR
            SELECT Nda.Nda_Id,
                   NVL (Nda.Nda_Name, Pt.Pt_Name)     AS Nda_Name,
                   Nda.Nda_Is_Key,
                   Nda.Nda_Ndt,
                   Nda.Nda_Order,
                   Nda.Nda_Pt,
                   Nda.Nda_Is_Req,
                   Nda.Nda_Def_Value,
                   Nda.Nda_Can_Edit,
                   Nda.Nda_Need_Show,
                   Pt.Pt_Id,
                   Pt.Pt_Code,
                   Pt.Pt_Name,
                   Pt.Pt_Ndc,
                   Pt.Pt_Edit_Type,
                   Pt.Pt_Data_Type,
                   Ndc.Ndc_Code,
                   NVL (Nda.Nda_Nng, -1)              AS Nda_Nng
              FROM Uss_Ndi.v_Ndi_Document_Attr  Nda
                   JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = Nda.Nda_Pt
                   LEFT JOIN Uss_Ndi.v_Ndi_Dict_Config Ndc
                       ON Ndc.Ndc_Id = Pt.Pt_Ndc
             WHERE Nda_Ndt = p_Ndt_Id;
    END;

    ---------------------------------------------------------------------
    --                   ДОВІДНИК ГРУП АТРИБУТІВ
    ---------------------------------------------------------------------
    PROCEDURE Get_Nng_List (p_Nng_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Nng_Cur FOR
            SELECT -1                      AS Nng_Id,
                   'Основні параметри'     AS Nng_Name,
                   'T'                     AS Nng_Open_By_Def,
                   0                       AS Nng_Order
              FROM DUAL
            UNION ALL
            SELECT g.Nng_Id,
                   g.Nng_Name,
                   g.Nng_Open_By_Def,
                   g.Nng_Order
              FROM Uss_Ndi.v_Ndi_Nda_Group g
            ORDER BY Nng_Order;
    END;

    ---- Slider
    PROCEDURE get_appeal_list (p_rnsp_id   IN     NUMBER,
                               res_cur        OUT SYS_REFCURSOR)
    IS
        l_wu   NUMBER := tools.GetCurrWu;
    BEGIN
        tools.WriteMsg ('DNET$RNSP_JOURNALS.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
            SELECT t.ap_id
                       AS id,
                   CASE WHEN hs.hs_wu = l_wu THEN t.ap_st ELSE '-1' END
                       AS code,
                   t.ap_num || ' від ' || TO_CHAR (t.ap_reg_dt, 'DD.MM.YYYY')
                       AS name
              FROM appeal t JOIN histsession hs ON (hs.hs_id = t.ap_hs_oper)
             WHERE t.ap_ext_ident = p_rnsp_id;
    END;
END DNET$RNSP_JOURNALS;
/