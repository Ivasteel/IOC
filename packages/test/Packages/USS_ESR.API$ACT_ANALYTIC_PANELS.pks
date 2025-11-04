/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACT_ANALYTIC_PANELS
IS
    /*
    FUNCTION Get_Rnsp_Analytic_View(p_Region_name  IN VARCHAR2 DEFAULT NULL,
                                    p_Kaot_tp      IN VARCHAR2 DEFAULT NULL,
                                    p_Settle_name  IN VARCHAR2 DEFAULT NULL,
                                    p_Ownership    IN VARCHAR2 DEFAULT NULL,
                                    p_Numident     IN VARCHAR2 DEFAULT NULL,
                                    p_Name         IN VARCHAR2 DEFAULT NULL,
                                    p_Nst_Id       IN NUMBER DEFAULT NULL
                                    ) return t_Rnsp_Analytic_View pipelined;
                                    */

    FUNCTION Get_Act_Sc_Koat_Id (p_Ap_Id IN NUMBER, p_Ap_Sc IN NUMBER)
        RETURN NUMBER;

    PROCEDURE Get_Rnsp_Analytic_View (
        p_Res            OUT SYS_REFCURSOR,
        p_Koat_L1     IN     NUMBER DEFAULT NULL,
        p_Koat_L2     IN     NUMBER DEFAULT NULL,
        p_Koat_L3     IN     NUMBER DEFAULT NULL,
        p_Koat_L4     IN     NUMBER DEFAULT NULL,
        p_Koat_L5     IN     NUMBER DEFAULT NULL,
        p_Ownership   IN     VARCHAR2 DEFAULT NULL,
        p_Numident    IN     VARCHAR2 DEFAULT NULL,
        p_Name        IN     VARCHAR2 DEFAULT NULL,
        p_Nst_Id      IN     VARCHAR2 DEFAULT NULL,
        p_Rnspm_Tp    IN     VARCHAR2 DEFAULT NULL,
        p_Start_Row   IN     NUMBER DEFAULT NULL,
        p_Take_Rows   IN     NUMBER DEFAULT NULL);

    PROCEDURE Get_Rnsp_Details_Analytic_View (
        p_Rnspm_Id   IN     uss_rnsp.v_rnsp.RNSPM_ID%TYPE,
        p_Rnsps_Id   IN     uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_AddressU      OUT SYS_REFCURSOR,
        p_AddressS      OUT SYS_REFCURSOR,
        p_Services      OUT SYS_REFCURSOR);

    PROCEDURE Get_Rnsp_Address_Analytic_View (
        p_Rnsps_Id       IN     uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_address_type   IN     uss_rnsp.v_rnsp_address.RNSPA_TP%TYPE,
        p_Res               OUT SYS_REFCURSOR);

    FUNCTION Get_Rnsp_Address_Analytic_Json (
        p_Rnsps_Id       IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_address_type   IN uss_rnsp.v_rnsp_address.RNSPA_TP%TYPE)
        RETURN CLOB;

    FUNCTION Get_Rnsp_Address_Analytic_List (
        p_Rnsps_Id       IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_address_type   IN uss_rnsp.v_rnsp_address.RNSPA_TP%TYPE)
        RETURN VARCHAR2;

    PROCEDURE Get_Rnsp_Service_Analytic_View (
        p_Rnspm_Id   IN     uss_rnsp.v_rnsp.RNSPM_ID%TYPE,
        p_Rnsps_Id   IN     uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_Res           OUT SYS_REFCURSOR);

    FUNCTION Get_Rnsp_Service_Analytic_Json (
        p_Rnspm_Id   IN uss_rnsp.v_rnsp.RNSPM_ID%TYPE,
        p_Rnsps_Id   IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE)
        RETURN CLOB;

    FUNCTION Get_Rnsp_Service_Analytic_List_Name (
        p_Rnsps_Id   IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Rnsp_Service_Analytic_List_Sum (
        p_Rnsps_Id   IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE)
        RETURN VARCHAR2;

    FUNCTION Get_Rnsp_Service_Analytic_List_Content (
        p_Rnsps_Id   IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE)
        RETURN CLOB;

    PROCEDURE Get_TCTR_Analytic_View (
        p_Res                 OUT SYS_REFCURSOR,
        p_Settl_type_Res      OUT SYS_REFCURSOR,
        P_Services_Res        OUT SYS_REFCURSOR,
        P_Rnsp_Res            OUT SYS_REFCURSOR,
        P_Sex_Res             OUT SYS_REFCURSOR,
        P_Age_Res             OUT SYS_REFCURSOR,
        p_Koat_L1          IN     NUMBER DEFAULT NULL,
        p_Koat_L2          IN     NUMBER DEFAULT NULL,
        p_Koat_L3          IN     NUMBER DEFAULT NULL,
        p_Koat_L4          IN     NUMBER DEFAULT NULL,
        p_Koat_L5          IN     NUMBER DEFAULT NULL,
        p_Numident         IN     VARCHAR2 DEFAULT NULL,
        p_Name             IN     VARCHAR2 DEFAULT NULL,
        p_Nst_Id           IN     VARCHAR2 DEFAULT NULL,
        p_Is_Disabled      IN     VARCHAR2 DEFAULT NULL);


    PROCEDURE Get_Rnsp_Analytic_Total_View (
        p_Res            OUT SYS_REFCURSOR,
        p_Koat_L1     IN     NUMBER DEFAULT NULL,
        p_Koat_L2     IN     NUMBER DEFAULT NULL,
        p_Koat_L3     IN     NUMBER DEFAULT NULL,
        p_Koat_L4     IN     NUMBER DEFAULT NULL,
        p_Koat_L5     IN     NUMBER DEFAULT NULL,
        p_Ownership   IN     VARCHAR2 DEFAULT NULL,
        p_Numident    IN     VARCHAR2 DEFAULT NULL,
        p_Name        IN     VARCHAR2 DEFAULT NULL,
        p_Nst_Id      IN     VARCHAR2 DEFAULT NULL,
        p_Rnspm_Tp    IN     VARCHAR2 DEFAULT NULL);

    ---Опис тіблиці результату
    -- l1_kaot_full_name Назва КОАТУУ 1-го рівня, або слово "Всього" для загального групування
    -- l2_kaot_full_name Назва КОАТУУ 2-го рівня, або слово "Всього" для загального групування
    -- l3_kaot_full_name Назва КОАТУУ 3-го рівня, або слово "Всього" для загального групування
    -- l4_kaot_full_name Назва КОАТУУ 4-го рівня, або слово "Всього" для загального групування
    -- l5_kaot_full_name Назва КОАТУУ 5-го рівня, або слово "Всього" для загального групування
    -- koat_tp_name Тип населеного пункту, або слово "Всього" для загального групування
    -- nst_name Назва послуги, або слово "Всього" для загального групування
    -- rnsp_qty Кількість надавачів соц. послуг
    -- at_qty Кількість актів
    -- m_less_18 кількість отримувачів чоловіків віком до 18 років
    -- m_between_18_60 кількість отримувачів чоловіків  віком від 18 до 60 років
    -- m_great_60 кількість отримувачів чоловіків  віком більше 60
    -- m_unaged кількість отримувачів чоловіків без вказаного віку
    -- m_is_disabled кількість отримувачів чоловіків з інвалідністю
    -- f_less_18 кількість отримувачів жінок віков до 18
    -- f_between_18_60 кількість отримувачів жінок  віком від 18 до 60 років
    -- f_great_60 кількість отримувачів жінок  віком більше 60
    -- f_unaged кількість отримувачів жінок без вказаного віку
    -- f_is_disabled кількістьь отримувачів жінок з інвалідністю
    -- u_less_18 кількість отримувачів без вказаної статі віком до 18 років
    -- u_between_18_60 кількість отримувачів без вказаної статі  віком від 18 до 60 років
    -- u_great_60 кількість отримувачів без вказаної статі   віком більше 60
    -- u_unaged кількість отримувачів без вказаної статі та віку
    -- u_is_disabled кількість отримувачів з інвалідністю без вказаної статі
    -- all_is_disabled усього з інвалідністю
    -- all_sc всього
    -- g_total закальний підсумок
    -- g_l1_kaot_full_name Ознака чи є рядок групування 1 або ні 0 (тобто в рідку у відповідній колонці буде слово "Всього")
    -- g_l2_kaot_full_name Ознака чи є рядок групування 1 або ні 0 (тобто в рідку у відповідній колонці буде слово "Всього")
    -- g_l3_kaot_full_name Ознака чи є рядок групування 1 або ні 0 (тобто в рідку у відповідній колонці буде слово "Всього")
    -- g_l4_kaot_full_name Ознака чи є рядок групування 1 або ні 0 (тобто в рідку у відповідній колонці буде слово "Всього")
    -- g_l5_kaot_full_name Ознака чи є рядок групування 1 або ні 0 (тобто в рідку у відповідній колонці буде слово "Всього")
    -- g_koat_tp_name Ознака чи є рядок групування 1 або ні 0 (тобто в рідку у відповідній колонці буде слово "Всього")
    -- g_nst_name Ознака чи є рядок групування 1 або ні 0 (тобто в рідку у відповідній колонці буде слово "Всього")

    PROCEDURE Get_TCTR_Wide_Analytic_View (
        p_Res                  OUT SYS_REFCURSOR,      -- Таблия з результатов
                                                              -- Фільтри даних
        p_Koat_L1           IN     NUMBER DEFAULT NULL,   -- КОАТУУ 1-го рівня
        p_Koat_L2           IN     NUMBER DEFAULT NULL,   -- КОАТУУ 2-го рівня
        p_Koat_L3           IN     NUMBER DEFAULT NULL,   -- КОАТУУ 3-го рівня
        p_Koat_L4           IN     NUMBER DEFAULT NULL,   -- КОАТУУ 4-го рівня
        p_Koat_L5           IN     NUMBER DEFAULT NULL,   -- КОАТУУ 5-го рівня
        p_Nst_Id            IN     VARCHAR2 DEFAULT NULL, -- ІД послуги uss_ndi.v_ndi_service_type. ІД можут передаватися переліком через кому
        p_Scy_Group         IN     VARCHAR2 DEFAULT NULL, -- Група інвалідності. Перелік може передаватися через кому
        p_Child_Qty_From    IN     NUMBER DEFAULT NULL, -- Кількість дітей від...
        p_Child_Qty_To      IN     NUMBER DEFAULT NULL, -- Кількість дітей до...
        p_Child_Age_From    IN     NUMBER DEFAULT NULL, --Кількість дітей віком від...
        p_Child_Age_To      IN     NUMBER DEFAULT NULL, -- Кількість дітей віком до...
        p_Nff_Id            IN     VARCHAR2 DEFAULT NULL, --ІД особливих умов uss_ndi.v_ndi_family_features. ІД можут передаватися переліком через кому
        p_Rnspm_Tp          IN     VARCHAR2 DEFAULT NULL, --ІД надавача послуг. ІД можут передаватися переліком через кому
        p_Gender            IN     VARCHAR2 DEFAULT NULL,              --Стать
        p_Age_From          IN     NUMBER DEFAULT NULL,          -- Вік від...
        p_Age_To            IN     NUMBER DEFAULT NULL,           -- Вік до...
        p_Is_Disabled       IN     VARCHAR2 DEFAULT NULL, -- Означа інваліності
        p_Serv_month_From   IN     NUMBER DEFAULT NULL, -- кількість місяців дії послуги від...
        p_Serv_month_To     IN     NUMBER DEFAULT NULL -- кількість місяців дії послуги до...
                                                      );
END API$ACT_ANALYTIC_PANELS;
/


GRANT EXECUTE ON USS_ESR.API$ACT_ANALYTIC_PANELS TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.API$ACT_ANALYTIC_PANELS TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$ACT_ANALYTIC_PANELS TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.API$ACT_ANALYTIC_PANELS TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.API$ACT_ANALYTIC_PANELS TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$ACT_ANALYTIC_PANELS TO PORTAL_PROXY
/

GRANT EXECUTE ON USS_ESR.API$ACT_ANALYTIC_PANELS TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$ACT_ANALYTIC_PANELS TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$ACT_ANALYTIC_PANELS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:48:38 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACT_ANALYTIC_PANELS
IS
    FUNCTION Get_Act_Sc_Koat_Id (p_Ap_Id IN NUMBER, p_Ap_Sc IN NUMBER)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT kaot_id
          INTO l_Res
          FROM (  SELECT kk.kaot_id,
                         kk.kaot_name,
                         kk.kaot_tp,
                         ktp.DIC_NAME,
                         ktp.DIC_SRTORDR
                    FROM ap_person app
                         JOIN ap_document apd ON apd.apd_app = app.app_id
                         JOIN ap_document_attr apda
                             ON     apda.apda_apd = apd.apd_id
                                AND apda.apda_nda IN (1618)
                         JOIN uss_ndi.v_ndi_katottg kk
                             ON apda.apda_val_id = kk.kaot_id
                         JOIN uss_ndi.v_ddn_kaot_tp ktp
                             ON kk.kaot_tp = ktp.DIC_CODE
                   WHERE p_Ap_Id = app.app_ap AND p_Ap_Sc = app.app_sc
                ORDER BY ktp.DIC_SRTORDR)
         WHERE ROWNUM = 1;

        RETURN l_Res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    FUNCTION Get_Rnst_Analityc_View_Filter (
        p_Koat_L1     IN NUMBER DEFAULT NULL,
        p_Koat_L2     IN NUMBER DEFAULT NULL,
        p_Koat_L3     IN NUMBER DEFAULT NULL,
        p_Koat_L4     IN NUMBER DEFAULT NULL,
        p_Koat_L5     IN NUMBER DEFAULT NULL,
        p_Ownership   IN VARCHAR2 DEFAULT NULL,
        p_Numident    IN VARCHAR2 DEFAULT NULL,
        p_Name        IN VARCHAR2 DEFAULT NULL,
        p_Nst_Id      IN VARCHAR2 DEFAULT NULL,
        p_Rnspm_Tp    IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Filter   VARCHAR2 (32000);
        l_str      VARCHAR2 (32000);
    BEGIN
        IF (p_Numident IS NOT NULL)
        THEN
            l_str := '''' || REPLACE (p_Numident, ',', ''',''') || '''';
            l_Filter := l_Filter || '
      AND r.RAP_NUMIDENT IN (' || l_str || ')';
        END IF;


        IF (p_Ownership IS NOT NULL)
        THEN
            l_Filter := l_Filter || '
      AND r.RAP_OWNERSHIP = :p_Ownership';
        ELSE
            l_Filter := l_Filter || '
      AND :p_Ownership IS NULL';
        END IF;

        IF (p_Name IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND LOWER(REPLACE(r.RAP_LAST_NAME,'' '','''')) LIKE ''%''||LOWER(REPLACE(:p_Name,'' '',''''))||''%''';
        ELSE
            l_Filter := l_Filter || '
      AND :p_Name IS NULL';
        END IF;

        IF (p_Nst_Id IS NOT NULL)
        THEN
            l_str := p_Nst_Id;
            l_Filter :=
                   l_Filter
                || '
      AND r.RAP_RNSPS in (SELECT r2s.rnsp2s_rnsps
                                                                  FROM uss_rnsp.v_rnsp_dict_service ds
                                                                  JOIN uss_rnsp.v_rnsp2service r2s
                                                                    ON ds.rnspds_id = r2s.rnsp2s_rnspds
                                                                  where rnspds_nst in ('
                || l_str
                || '))';
        END IF;

        IF (p_Rnspm_Tp IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Rnspm_Tp, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND EXISTS(SELECT 1
          FROM uss_rnsp.v_rnsp_main m
          WHERE m.RNSPM_ID = r.RAP_RNSPM
            AND m.RNSPM_TP in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                               FROM DUAL
                               CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL))';
        END IF;

        IF (p_Koat_L5 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RAP_RNSPS IN (SELECT r2a.RNSP2A_RNSPS
                         FROM uss_rnsp.v_rnsp_address ra
                         JOIN uss_rnsp.v_rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l5 = '
                || p_Koat_L5
                || '
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l5))';
        END IF;

        IF (p_Koat_L4 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RAP_RNSPS IN (SELECT r2a.RNSP2A_RNSPS
                         FROM uss_rnsp.v_rnsp_address ra
                         JOIN uss_rnsp.v_rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l4 = '
                || p_Koat_L4
                || ' and k.kaot_kaot_l5 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l4))';
        END IF;

        IF (p_Koat_L3 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RAP_RNSPS IN (SELECT r2a.RNSP2A_RNSPS
                         FROM uss_rnsp.v_rnsp_address ra
                         JOIN uss_rnsp.v_rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l3 = '
                || p_Koat_L3
                || ' and k.kaot_kaot_l4 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l3))';
        END IF;

        IF (p_Koat_L2 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RAP_RNSPS IN (SELECT r2a.RNSP2A_RNSPS
                         FROM uss_rnsp.v_rnsp_address ra
                         JOIN uss_rnsp.v_rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l2 = '
                || p_Koat_L2
                || ' and k.kaot_kaot_l3 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l2))';
        END IF;

        IF (p_Koat_L1 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND r.RAP_RNSPS IN (SELECT r2a.RNSP2A_RNSPS
                         FROM uss_rnsp.v_rnsp_address ra
                         JOIN uss_rnsp.v_rnsp2address r2a
                           ON ra.rnspa_id = r2a.RNSP2A_RNSPA
                         WHERE ra.rnspa_kaot IN (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l1 = '
                || p_Koat_L1
                || ' and k.kaot_kaot_l2 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l1))';
        END IF;

        RETURN l_Filter;
    END;

    PROCEDURE Get_Rnsp_Analytic_View (
        p_Res            OUT SYS_REFCURSOR,
        p_Koat_L1     IN     NUMBER DEFAULT NULL,
        p_Koat_L2     IN     NUMBER DEFAULT NULL,
        p_Koat_L3     IN     NUMBER DEFAULT NULL,
        p_Koat_L4     IN     NUMBER DEFAULT NULL,
        p_Koat_L5     IN     NUMBER DEFAULT NULL,
        p_Ownership   IN     VARCHAR2 DEFAULT NULL,
        p_Numident    IN     VARCHAR2 DEFAULT NULL,
        p_Name        IN     VARCHAR2 DEFAULT NULL,
        p_Nst_Id      IN     VARCHAR2 DEFAULT NULL,
        p_Rnspm_Tp    IN     VARCHAR2 DEFAULT NULL,
        p_Start_Row   IN     NUMBER DEFAULT NULL,
        p_Take_Rows   IN     NUMBER DEFAULT NULL)
    IS
        l_Query        VARCHAR2 (32000);
        l_Filter       VARCHAR2 (32000)
                           := Get_Rnst_Analityc_View_Filter (p_Koat_L1,
                                                             p_Koat_L2,
                                                             p_Koat_L3,
                                                             p_Koat_L4,
                                                             p_Koat_L5,
                                                             p_Ownership,
                                                             p_Numident,
                                                             p_Name,
                                                             p_Nst_Id,
                                                             p_Rnspm_Tp);
        l_Pagination   VARCHAR2 (500)
            :=    'ORDER BY r.RAP_RNSPM OFFSET '
               || p_Start_Row
               || ' ROWS FETCH NEXT '
               || p_Take_Rows
               || ' ROWS ONLY';
    BEGIN
        l_Query := 'SELECT   r.RAP_RNSPM RNSPM_ID,
                          r.RAP_RNSPS RNSPS_ID,
                          r.RAP_NUMIDENT RNSPS_NUMIDENT,
                          r.RAP_LAST_NAME RNSPS_LAST_NAME,
                          r.RAP_PHONE RNSPS_PHONE,
                          r.RAP_EMAIL RNSPS_EMAIL,
                          r.RAP_WEB RNSPS_WEB,
                          r.RAP_OWNERSHIP rnsps_ownership,
                          r.RAP_OWNERSHIP_NAME rnsps_ownership_name,
                          r.RAP_ORG_TP rnspm_org_tp,
                          r.RAP_ORG_TP_NAME rnspm_org_tp_name,
                          r.RAP_HEAD_FIO Rsnsp_Head_Fio,
                          r.RAP_ADDR_S_QTY RNSP_ADDR_S_QTY,
                          r.RAP_SERVICE_QTY RNSP_SERVICE_QTY,
                          r.RAP_RECEIVER_QTY RNSP_RECEIVER_QTY
                          ,r.RAP_ADDRESS_U_STR Rnsps_Address_U
                          ,r.RAP_ADDRESS_S_STR Rnsps_Address_S
                          ,r.RAP_SERVICES_NAMES Rnsps_Serv_Name
                          ,r.RAP_SERVICES_CONTENTS Rnsps_Serv_Context
                          ,r.RAP_SERVICES_CONTENTS2 Rnsps_Serv_Context2
                          ,r.RAP_SERVICES_SUMS Rnsps_Serv_Sum
                   FROM USS_RPT.V_RNSP_ANALYTIC_PANEL R
                   WHERE 1=1
                   #<FILTER>#
                   #<PAGINATION>#
                   ';

        l_Query := REPLACE (l_QUERY, '#<FILTER>#', l_Filter);

        IF p_Start_Row IS NOT NULL AND p_Take_Rows IS NOT NULL
        THEN
            l_Query := REPLACE (l_QUERY, '#<PAGINATION>#', l_Pagination);
        ELSE
            l_Query := REPLACE (l_QUERY, '#<PAGINATION>#', '');
        END IF;

        DBMS_OUTPUT.put_line (l_Query);

        OPEN p_Res FOR l_Query USING p_Ownership, p_Name;
    END;

    PROCEDURE Get_Rnsp_Details_Analytic_View (
        p_Rnspm_Id   IN     uss_rnsp.v_rnsp.RNSPM_ID%TYPE,
        p_Rnsps_Id   IN     uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_AddressU      OUT SYS_REFCURSOR,
        p_AddressS      OUT SYS_REFCURSOR,
        p_Services      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Get_Rnsp_Address_Analytic_View (p_Rnsps_Id, 'U', p_AddressU);
        Get_Rnsp_Address_Analytic_View (p_Rnsps_Id, 'S', p_AddressS);
        Get_Rnsp_Service_Analytic_View (p_Rnspm_Id, p_Rnsps_Id, p_Services);
    END;

    PROCEDURE Get_Rnsp_Address_Analytic_View (
        p_Rnsps_Id       IN     uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_address_type   IN     uss_rnsp.v_rnsp_address.RNSPA_TP%TYPE,
        p_Res               OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT ra.RNSPA_ID,
                   ra.RNSPA_TP,
                   uss_rnsp.cmes$rnsp.Get_Addr_Text (ra.RNSPA_ID)    rnspa_addr_text
              FROM uss_rnsp.v_rnsp_address  ra
                   JOIN uss_rnsp.v_rnsp2address r2a
                       ON r2a.RNSP2A_RNSPA = ra.RNSPA_ID
             WHERE     r2a.RNSP2A_RNSPS = p_Rnsps_Id
                   AND ra.RNSPA_TP = p_address_type;
    END;

    FUNCTION Get_Rnsp_Address_Analytic_Json (
        p_Rnsps_Id       IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_address_type   IN uss_rnsp.v_rnsp_address.RNSPA_TP%TYPE)
        RETURN CLOB
    IS
        l_Res   CLOB;
    BEGIN
        FOR c_Addr
            IN (SELECT json_object (
                           'RNSPA_ID' VALUE RNSPA_ID,
                           'RNSPA_ADDR_TEXT' VALUE
                               uss_rnsp.cmes$rnsp.Get_Addr_Text (RNSPA_ID))    rnspa_addr_text
                  FROM (SELECT DISTINCT ra.RNSPA_ID
                          FROM uss_rnsp.v_rnsp_address  ra
                               JOIN uss_rnsp.v_rnsp2address r2a
                                   ON r2a.RNSP2A_RNSPA = ra.RNSPA_ID
                         WHERE     r2a.RNSP2A_RNSPS = p_Rnsps_Id
                               AND ra.RNSPA_TP = p_address_type))
        LOOP
            IF l_Res IS NULL
            THEN
                l_Res := '[' || c_Addr.rnspa_addr_text;
            ELSE
                l_Res := l_Res || ', ' || c_Addr.rnspa_addr_text;
            END IF;
        END LOOP;

        IF l_Res IS NOT NULL
        THEN
            l_Res := l_Res || ']';
        END IF;

        RETURN l_Res;
    END;


    FUNCTION Get_Rnsp_Address_Analytic_List (
        p_Rnsps_Id       IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_address_type   IN uss_rnsp.v_rnsp_address.RNSPA_TP%TYPE)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (4000);
    BEGIN
        FOR c_Addr
            IN (SELECT uss_rnsp.cmes$rnsp.Get_Addr_Text (RNSPA_ID)    rnspa_addr_text
                  FROM (SELECT DISTINCT ra.RNSPA_ID
                          FROM uss_rnsp.v_rnsp_address  ra
                               JOIN uss_rnsp.v_rnsp2address r2a
                                   ON r2a.RNSP2A_RNSPA = ra.RNSPA_ID
                         WHERE     r2a.RNSP2A_RNSPS = p_Rnsps_Id
                               AND ra.RNSPA_TP = p_address_type))
        LOOP
            IF l_Res IS NULL
            THEN
                l_Res := c_Addr.rnspa_addr_text;
            ELSE
                l_Res := l_Res || '#' || c_Addr.rnspa_addr_text;
            END IF;
        END LOOP;

        RETURN l_Res;
    END;


    PROCEDURE Get_Rnsp_Service_Analytic_View (
        p_Rnspm_Id   IN     uss_rnsp.v_rnsp.RNSPM_ID%TYPE,
        p_Rnsps_Id   IN     uss_rnsp.v_rnsp.RNSPS_ID%TYPE,
        p_Res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT                                  --Назва соціальної послуги
                   st.nst_id
                       Rnspds_nst,
                   St.Nst_Name
                       Rnspds_nst_name,
                   --Короткий зміст та обсяг соціальної послуги
                   Ds.Rnspds_Content,
                   --Діючий тариф для особи
                    (SELECT t.Rnspt_Sum
                       FROM uss_rnsp.v_Rnsp_Tariff t
                      WHERE     t.Rnspt_Rnspm = p_Rnspm_Id
                            AND t.History_Status = 'A'
                            AND t.Rnspt_Nst = Ds.Rnspds_Nst
                            AND SYSDATE BETWEEN t.Rnspt_Start_Dt
                                            AND NVL (
                                                    t.Rnspt_Stop_Dt,
                                                    SYSDATE))
                       AS Rnspds_Sum,
                   --Діючий тариф для сім'ї
                    (SELECT t.Rnspt_Sum_Fm
                       FROM uss_rnsp.v_Rnsp_Tariff t
                      WHERE     t.Rnspt_Rnspm = p_Rnspm_Id
                            AND t.History_Status = 'A'
                            AND t.Rnspt_Nst = Ds.Rnspds_Nst
                            AND SYSDATE BETWEEN t.Rnspt_Start_Dt
                                            AND NVL (t.Rnspt_Stop_Dt,
                                                     SYSDATE))
                       AS Rnspds_Sum_Fm
              FROM uss_rnsp.v_Rnsp2service  Ns
                   JOIN uss_rnsp.v_Rnsp_Dict_Service Ds
                       ON Ns.Rnsp2s_Rnspds = Ds.Rnspds_Id
                   JOIN Uss_Ndi.v_Ndi_Service_Type St
                       ON Ds.Rnspds_Nst = St.Nst_Id
             WHERE Ns.Rnsp2s_Rnsps = p_Rnsps_Id;
    END;

    FUNCTION Get_Rnsp_Service_Analytic_Json (
        p_Rnspm_Id   IN uss_rnsp.v_rnsp.RNSPM_ID%TYPE,
        p_Rnsps_Id   IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE)
        RETURN CLOB
    IS
        l_Res   CLOB;
    BEGIN
        FOR c_NSt
            IN (SELECT json_object (
                           --Назва соціальної послуги
                           'RNSPDS_NST' VALUE st.nst_id,
                           'RNSPDS_NST_NAME' VALUE St.Nst_Name,
                           --Короткий зміст та обсяг соціальної послуги
                           'RNSPDS_CONTENT' VALUE Ds.Rnspds_Content,
                           --Діючий тариф для особи
                           'RNSPDS_SUM' VALUE
                               (SELECT t.Rnspt_Sum
                                  FROM uss_rnsp.v_Rnsp_Tariff t
                                 WHERE     t.Rnspt_Rnspm = p_Rnspm_Id
                                       AND t.History_Status = 'A'
                                       AND t.Rnspt_Nst = Ds.Rnspds_Nst
                                       AND SYSDATE BETWEEN t.Rnspt_Start_Dt
                                                       AND NVL (
                                                               t.Rnspt_Stop_Dt,
                                                               SYSDATE)),
                           --Діючий тариф для сім'ї
                           'RNSPDS_SUM_FM' VALUE
                               (SELECT t.Rnspt_Sum_Fm
                                  FROM uss_rnsp.v_Rnsp_Tariff t
                                 WHERE     t.Rnspt_Rnspm = p_Rnspm_Id
                                       AND t.History_Status = 'A'
                                       AND t.Rnspt_Nst = Ds.Rnspds_Nst
                                       AND SYSDATE BETWEEN t.Rnspt_Start_Dt
                                                       AND NVL (
                                                               t.Rnspt_Stop_Dt,
                                                               SYSDATE)))    nst_text
                  FROM uss_rnsp.v_Rnsp2service  Ns
                       JOIN uss_rnsp.v_Rnsp_Dict_Service Ds
                           ON Ns.Rnsp2s_Rnspds = Ds.Rnspds_Id
                       JOIN Uss_Ndi.v_Ndi_Service_Type St
                           ON Ds.Rnspds_Nst = St.Nst_Id
                 WHERE Ns.Rnsp2s_Rnsps = p_Rnsps_Id)
        LOOP
            IF l_Res IS NULL
            THEN
                l_Res := '[' || c_NSt.nst_text;
            ELSE
                l_Res := l_Res || ', ' || c_NSt.nst_text;
            END IF;
        END LOOP;

        IF l_Res IS NOT NULL
        THEN
            l_Res := l_Res || ']';
        END IF;

        RETURN l_Res;
    END;


    FUNCTION Get_Rnsp_Service_Analytic_List_Name (
        p_Rnsps_Id   IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE)
        RETURN VARCHAR2
    IS
        l_Res          VARCHAR2 (4000);
        l_IsFirstRow   BOOLEAN := TRUE;
    BEGIN
        FOR c_NSt
            IN (  SELECT St.Nst_Name     nst_text
                    FROM uss_rnsp.v_Rnsp2service Ns
                         JOIN uss_rnsp.v_Rnsp_Dict_Service Ds
                             ON Ns.Rnsp2s_Rnspds = Ds.Rnspds_Id
                         JOIN Uss_Ndi.v_Ndi_Service_Type St
                             ON Ds.Rnspds_Nst = St.Nst_Id
                   WHERE Ns.Rnsp2s_Rnsps = p_Rnsps_Id
                ORDER BY ds.RNSPDS_ID)
        LOOP
            IF l_IsFirstRow
            THEN
                l_Res := c_NSt.nst_text;
                l_IsFirstRow := FALSE;
            ELSIF c_NSt.nst_text IS NULL
            THEN
                l_Res := l_Res || '#';
            ELSE
                l_Res := l_Res || '#' || c_NSt.nst_text;
            END IF;
        END LOOP;

        RETURN l_Res;
    END;

    FUNCTION Get_Rnsp_Service_Analytic_List_Sum (
        p_Rnsps_Id   IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE)
        RETURN VARCHAR2
    IS
        l_Res          VARCHAR2 (4000);
        l_IsFirstRow   BOOLEAN := TRUE;
    BEGIN
        FOR c_NSt
            IN (  SELECT    CAST (ds.rnspds_sum AS VARCHAR2 (50))
                         || '|'
                         || CAST (ds.rnspds_sum_fm AS VARCHAR2 (50))    nst_text
                    FROM uss_rnsp.v_Rnsp2service Ns
                         JOIN uss_rnsp.v_Rnsp_Dict_Service Ds
                             ON Ns.Rnsp2s_Rnspds = Ds.Rnspds_Id
                         JOIN Uss_Ndi.v_Ndi_Service_Type St
                             ON Ds.Rnspds_Nst = St.Nst_Id
                   WHERE Ns.Rnsp2s_Rnsps = p_Rnsps_Id
                ORDER BY ds.RNSPDS_ID)
        LOOP
            IF l_IsFirstRow
            THEN
                l_Res := c_NSt.nst_text;
                l_IsFirstRow := FALSE;
            ELSIF c_NSt.nst_text IS NULL
            THEN
                l_Res := l_Res || '#';
            ELSE
                l_Res := l_Res || '#' || c_NSt.nst_text;
            END IF;
        END LOOP;

        RETURN l_Res;
    END;


    FUNCTION Get_Rnsp_Service_Analytic_List_Content (
        p_Rnsps_Id   IN uss_rnsp.v_rnsp.RNSPS_ID%TYPE)
        RETURN CLOB
    IS
        l_Res          CLOB;
        l_IsFirstRow   BOOLEAN := TRUE;
    BEGIN
        FOR c_NSt
            IN (  SELECT ds.Rnspds_Content     nst_text
                    FROM uss_rnsp.v_Rnsp2service Ns
                         JOIN uss_rnsp.v_Rnsp_Dict_Service Ds
                             ON Ns.Rnsp2s_Rnspds = Ds.Rnspds_Id
                         JOIN Uss_Ndi.v_Ndi_Service_Type St
                             ON Ds.Rnspds_Nst = St.Nst_Id
                   WHERE Ns.Rnsp2s_Rnsps = p_Rnsps_Id
                ORDER BY ds.RNSPDS_ID)
        LOOP
            IF l_IsFirstRow
            THEN
                l_Res := c_NSt.nst_text;
                l_IsFirstRow := FALSE;
            ELSIF c_NSt.nst_text IS NULL
            THEN
                l_Res := l_Res || '#';
            ELSE
                l_Res := l_Res || '#' || c_NSt.nst_text;
            END IF;
        END LOOP;

        RETURN l_Res;
    END;


    PROCEDURE Get_TCTR_Analytic_View (
        p_Res                 OUT SYS_REFCURSOR,
        p_Settl_type_Res      OUT SYS_REFCURSOR,
        P_Services_Res        OUT SYS_REFCURSOR,
        P_Rnsp_Res            OUT SYS_REFCURSOR,
        P_Sex_Res             OUT SYS_REFCURSOR,
        P_Age_Res             OUT SYS_REFCURSOR,
        p_Koat_L1          IN     NUMBER DEFAULT NULL,
        p_Koat_L2          IN     NUMBER DEFAULT NULL,
        p_Koat_L3          IN     NUMBER DEFAULT NULL,
        p_Koat_L4          IN     NUMBER DEFAULT NULL,
        p_Koat_L5          IN     NUMBER DEFAULT NULL,
        p_Numident         IN     VARCHAR2 DEFAULT NULL,
        p_Name             IN     VARCHAR2 DEFAULT NULL,
        p_Nst_Id           IN     VARCHAR2 DEFAULT NULL,
        p_Is_Disabled      IN     VARCHAR2 DEFAULT NULL)
    IS
        l_Query    VARCHAR2 (32000);
        l_Filter   VARCHAR2 (32000);
        l_str      VARCHAR2 (32000);
    BEGIN
        l_Query :=
            'INSERT INTO tmp_tctr_analitic(tctra_at_id, tctra_at_sc, tctra_at_ap, tctra_atp_id, tctra_at_rnspm, tctra_at_koat, tctra_atp_is_disabled, tctra_atp_sex, tctra_atp_age)
                 SELECT a.at_id, a.at_sc, a.at_ap, ap.atp_id, a.at_rnspm, API$ACT_ANALYTIC_PANELS.Get_Act_Sc_Koat_Id(a.at_ap, a.at_sc), ap.atp_is_disabled, ap.atp_sex, TRUNC(MONTHS_BETWEEN(SYSDATE, ap.atp_birth_dt)/12)
                 FROM at_person ap
                 JOIN act a
                   ON ap.atp_at = a.at_id
                  AND ap.atp_sc = a.at_sc
                 WHERE a.at_tp=''TCTR''
                   AND a.at_st in (''DT'', ''DPU'')
                 #<FILTER>#
     ';

        IF (p_Is_Disabled IS NOT NULL)
        THEN
            l_Filter := l_Filter || '
      AND ap.atp_is_disabled = :p_Is_Disabled';
        ELSE
            l_Filter := l_Filter || '
      AND :p_Is_Disabled IS NULL';
        END IF;


        IF (p_Nst_Id IS NOT NULL)
        THEN
            l_Filter := l_Filter || '
      AND EXISTS(SELECT 1
                 FROM at_service ats
                 WHERE ats.ats_nst = :p_Nst_Id
                   AND ats_at = a.at_id)';
        ELSE
            l_Filter := l_Filter || '
      AND :p_Nst_Id IS NULL';
        END IF;

        IF (p_Numident IS NOT NULL)
        THEN
            l_str := '''' || REPLACE (p_Numident, ',', ''',''') || '''';
            l_Filter := l_Filter || '
      AND EXISTS(SELECT 1
                 FROM uss_rnsp.v_rnsp r
                 WHERE a.at_rnspm = r.rnspm_id
                   AND r.RNSPS_NUMIDENT IN (' || l_str || '))';
        END IF;

        IF (p_Name IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND EXISTS(SELECT 1
                 FROM uss_rnsp.v_rnsp r
                 WHERE a.at_rnspm = r.rnspm_id
                   AND LOWER(REPLACE(r.RNSPS_LAST_NAME,'' '','''')) LIKE ''%''||LOWER(REPLACE(:p_Name,'' '',''''))||''%'')';
        ELSE
            l_Filter := l_Filter || '
      AND :p_Name IS NULL';
        END IF;

        IF (p_Koat_L5 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND API$ACT_ANALYTIC_PANELS.Get_Act_Sc_Koat_Id(a.at_ap, a.at_sc) IN
                                                (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l5 = '
                || p_Koat_L5
                || '
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l5)';
        ELSIF (p_Koat_L4 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND API$ACT_ANALYTIC_PANELS.Get_Act_Sc_Koat_Id(a.at_ap, a.at_sc) IN
                                                (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l4 = '
                || p_Koat_L4
                || ' and k.kaot_kaot_l5 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l4)';
        ELSIF (p_Koat_L3 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND API$ACT_ANALYTIC_PANELS.Get_Act_Sc_Koat_Id(a.at_ap, a.at_sc) IN
                                                (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l3 = '
                || p_Koat_L3
                || ' and k.kaot_kaot_l4 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l3)';
        ELSIF (p_Koat_L2 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND API$ACT_ANALYTIC_PANELS.Get_Act_Sc_Koat_Id(a.at_ap, a.at_sc) IN
                                                (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l2 = '
                || p_Koat_L2
                || ' and k.kaot_kaot_l3 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l2)';
        ELSIF (p_Koat_L1 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND API$ACT_ANALYTIC_PANELS.Get_Act_Sc_Koat_Id(a.at_ap, a.at_sc) IN
                                                (SELECT k.kaot_id
                                                 FROM uss_ndi.v_ndi_katottg k
                                                 START WITH k.kaot_kaot_l1 = '
                || p_Koat_L1
                || ' and k.kaot_kaot_l2 is null
                                                 CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l1)';
        END IF;


        l_Query := REPLACE (l_QUERY, '#<FILTER>#', l_Filter);

        --dbms_output.put_line(l_Query);

        EXECUTE IMMEDIATE l_Query
            USING p_Is_Disabled, p_Nst_Id, p_Name;


        l_Filter := '';

        FOR vServices
            IN (SELECT DISTINCT st.nst_name
                  FROM uss_ndi.v_Ndi_Service_Type  st
                       JOIN uss_rnsp.v_rnsp_dict_service ds
                           ON st.nst_id = ds.RNSPDS_NST
                       JOIN uss_rnsp.v_rnsp2service r2s
                           ON ds.RNSPDS_ID = r2s.rnsp2s_rnspds
                       JOIN uss_rnsp.v_rnsp_state rs
                           ON r2s.rnsp2s_rnsps = rs.RNSPS_ID
                       JOIN tmp_tctr_analitic ta
                           ON rs.RNSPS_RNSPM = ta.tctra_at_rnspm
                       JOIN appeal ap ON ta.tctra_at_ap = ap.ap_id
                       JOIN ap_service aps
                           ON     aps.aps_ap = ap.ap_id
                              AND aps.history_status = 'A'
                              AND aps.aps_nst = st.nst_id)
        LOOP
            IF (NVL (LENGTH (l_Filter), 0) + LENGTH (vServices.Nst_Name)) <
               4000
            THEN
                IF NVL (LENGTH (l_Filter), 0) > 0
                THEN
                    l_Filter := l_Filter || ', ';
                END IF;

                l_Filter := l_Filter || vServices.Nst_Name;
            ELSE
                IF NVL (LENGTH (l_Filter), 0) > 0
                THEN
                    l_Filter := l_Filter || '...';
                END IF;

                EXIT;
            END IF;
        END LOOP;


        OPEN p_Res FOR
            SELECT COUNT (DISTINCT t.tctra_at_id)       tctr_act_qty,
                   COUNT (DISTINCT t.tctra_at_sc)       tctr_sc_qty,
                   COUNT (
                       DISTINCT
                           CASE
                               WHEN t.tctra_atp_is_disabled = 'T'
                               THEN
                                   t.tctra_at_sc
                           END)                         tctr_disabled_sc_qty,
                   COUNT (DISTINCT t.tctra_at_rnspm)    tctr_rnspm_qty,
                   l_Filter                             AS tctr_services_list
              FROM tmp_tctr_analitic t;

        OPEN p_Settl_type_Res FOR
              SELECT ktp.DIC_CODE                       tctr_settl_code,
                     ktp.DIC_NAME                       tctr_settl_name,
                     COUNT (DISTINCT t.tctra_at_sc)     tctr_sc_qty
                FROM tmp_tctr_analitic t
                     JOIN uss_ndi.v_ndi_katottg kaot
                         ON t.tctra_at_koat = kaot.kaot_id
                     JOIN uss_ndi.v_ddn_kaot_tp ktp
                         ON kaot.kaot_tp = ktp.DIC_VALUE
            GROUP BY ktp.DIC_CODE, ktp.DIC_NAME, ktp.DIC_SRTORDR
            ORDER BY ktp.DIC_SRTORDR;

        OPEN P_Services_Res FOR
              SELECT st.nst_code                  tctr_nst_code,
                     st.nst_name                  tctr_nst_name,
                     COUNT (DISTINCT a.at_sc)     tctr_sc_qty
                FROM tmp_tctr_analitic t
                     JOIN act a ON a.at_id = t.tctra_at_id
                     JOIN appeal ap ON a.at_ap = ap.ap_id
                     JOIN ap_service aps
                         ON aps.aps_ap = ap.ap_id AND aps.history_status = 'A'
                     JOIN uss_ndi.v_Ndi_Service_Type st
                         ON aps.aps_nst = st.nst_id
            GROUP BY st.nst_code, st.nst_name;

        OPEN P_Rnsp_Res FOR
              SELECT r.RNSPM_ID                         tctr_rnspm_id,
                     r.RNSPS_NUMIDENT                   tctr_rnsps_numident,
                     r.RNSPS_LAST_NAME                  tctr_rnsps_name,
                     COUNT (DISTINCT t.tctra_at_sc)     tctr_sc_qty
                FROM tmp_tctr_analitic t
                     JOIN uss_rnsp.v_rnsp r ON t.tctra_at_rnspm = r.RNSPM_ID
            GROUP BY r.RNSPM_ID, r.RNSPS_NUMIDENT, r.RNSPS_LAST_NAME;


        OPEN p_Sex_Res FOR
              SELECT NVL (t.tctra_atp_sex, 'Не вказано')     tctr_atp_sex,
                     NVL (s.DIC_NAME, 'Не вказано')          tctr_atp_sex_name,
                     COUNT (DISTINCT t.tctra_at_sc)          tctr_sc_qty
                FROM tmp_tctr_analitic t
                     LEFT JOIN uss_ndi.v_ddn_gender s
                         ON t.tctra_atp_sex = s.DIC_VALUE
            GROUP BY NVL (t.tctra_atp_sex, 'Не вказано'),
                     NVL (s.DIC_NAME, 'Не вказано');

        OPEN p_Age_Res FOR
              SELECT CASE
                         WHEN t.tctra_atp_age < 18 THEN 1
                         WHEN t.tctra_atp_age > 60 THEN 3
                         ELSE 2
                     END                               tctr_age_srtordr,
                     CASE
                         WHEN t.tctra_atp_age < 18 THEN '<18'
                         WHEN t.tctra_atp_age > 60 THEN '>60'
                         ELSE '18-60'
                     END                               tctr_age_name,
                     COUNT (DISTINCT t.tctra_at_sc)    tctr_sc_qty
                FROM tmp_tctr_analitic t
            GROUP BY CASE
                         WHEN t.tctra_atp_age < 18 THEN '<18'
                         WHEN t.tctra_atp_age > 60 THEN '>60'
                         ELSE '18-60'
                     END,
                     CASE
                         WHEN t.tctra_atp_age < 18 THEN 1
                         WHEN t.tctra_atp_age > 60 THEN 3
                         ELSE 2
                     END
            ORDER BY CASE
                         WHEN t.tctra_atp_age < 18 THEN 1
                         WHEN t.tctra_atp_age > 60 THEN 3
                         ELSE 2
                     END;
    END;


    PROCEDURE Get_Rnsp_Analytic_Total_View (
        p_Res            OUT SYS_REFCURSOR,
        p_Koat_L1     IN     NUMBER DEFAULT NULL,
        p_Koat_L2     IN     NUMBER DEFAULT NULL,
        p_Koat_L3     IN     NUMBER DEFAULT NULL,
        p_Koat_L4     IN     NUMBER DEFAULT NULL,
        p_Koat_L5     IN     NUMBER DEFAULT NULL,
        p_Ownership   IN     VARCHAR2 DEFAULT NULL,
        p_Numident    IN     VARCHAR2 DEFAULT NULL,
        p_Name        IN     VARCHAR2 DEFAULT NULL,
        p_Nst_Id      IN     VARCHAR2 DEFAULT NULL,
        p_Rnspm_Tp    IN     VARCHAR2 DEFAULT NULL)
    IS
        l_Query    VARCHAR2 (32000);
        l_Filter   VARCHAR2 (32000)
                       := Get_Rnst_Analityc_View_Filter (p_Koat_L1,
                                                         p_Koat_L2,
                                                         p_Koat_L3,
                                                         p_Koat_L4,
                                                         p_Koat_L5,
                                                         p_Ownership,
                                                         p_Numident,
                                                         p_Name,
                                                         p_Nst_Id,
                                                         p_Rnspm_Tp);
    BEGIN
        l_Query := 'SELECT count(distinct r.RAP_RNSPM) RNSP_QTY,
                        count(distinct adr.rnspa_id) RNSP_ADDR_S_QTY,
                        count(distinct sc.at_sc) RNSP_RECEIVERS_QTY,
                        count(distinct r.RAP_RNSPM) TotalRows
                 FROM USS_RPT.V_RNSP_ANALYTIC_PANEL r
                 LEFT JOIN (SELECT ra.RNSPA_ID, r2a.RNSP2A_RNSPS
                            FROM uss_rnsp.v_rnsp_address ra
                            JOIN uss_rnsp.v_rnsp2address r2a
                              ON r2a.RNSP2A_RNSPA = ra.RNSPA_ID
                           WHERE ra.RNSPA_TP = ''S'') adr
                  ON adr.rnsp2a_rnsps = r.RAP_RNSPS
                 LEFT JOIN (SELECT a.at_sc, a.at_rnspm
                            FROM act a
                            WHERE a.at_tp=''TCTR''
                              AND a.at_st in (''DT'', ''DPU'')) sc
                  ON r.RAP_RNSPM = sc.at_rnspm
                 WHERE 1=1
                  #<FILTER>#
                   ';


        l_Query := REPLACE (l_QUERY, '#<FILTER>#', l_Filter);
        DBMS_OUTPUT.put_line (l_Query);

        OPEN p_Res FOR l_Query USING p_Ownership, p_Name;
    END;

    PROCEDURE Get_TCTR_Wide_Analytic_View_old (
        p_Res                  OUT SYS_REFCURSOR,
        p_Koat_L1           IN     NUMBER DEFAULT NULL,
        p_Koat_L2           IN     NUMBER DEFAULT NULL,
        p_Koat_L3           IN     NUMBER DEFAULT NULL,
        p_Koat_L4           IN     NUMBER DEFAULT NULL,
        p_Koat_L5           IN     NUMBER DEFAULT NULL,
        p_Nst_Id            IN     VARCHAR2 DEFAULT NULL,
        p_Scy_Group         IN     VARCHAR2 DEFAULT NULL,
        p_Child_Qty_From    IN     NUMBER DEFAULT NULL,
        p_Child_Qty_To      IN     NUMBER DEFAULT NULL,
        p_Child_Age_From    IN     NUMBER DEFAULT NULL,
        p_Child_Age_To      IN     NUMBER DEFAULT NULL,
        p_Nff_Id            IN     VARCHAR2 DEFAULT NULL,
        p_Rnspm_Tp          IN     VARCHAR2 DEFAULT NULL,
        p_Gender            IN     VARCHAR2 DEFAULT NULL,
        p_Age_From          IN     NUMBER DEFAULT NULL,
        p_Age_To            IN     NUMBER DEFAULT NULL,
        p_Is_Disabled       IN     VARCHAR2 DEFAULT NULL,
        p_Serv_month_From   IN     NUMBER DEFAULT NULL,
        p_Serv_month_To     IN     NUMBER DEFAULT NULL)
    IS
        l_Query    VARCHAR2 (32000);
        l_Filter   VARCHAR2 (32000);
        l_str      VARCHAR2 (4000);
    BEGIN
        /*
          insert into err_log(el_code, el_message)
          values('p_Koat_L1',p_Koat_L1);
          insert into err_log(el_code, el_message)
          values('p_Koat_L2',p_Koat_L2);
          insert into err_log(el_code, el_message)
          values('p_Koat_L3',p_Koat_L3);
          insert into err_log(el_code, el_message)
          values('p_Koat_L4',p_Koat_L4);
          insert into err_log(el_code, el_message)
          values('p_Koat_L5',p_Koat_L5);
          commit;
        */

        l_Query :=
            '
      SELECT l1_kaot_full_name,
             nvl(l2_kaot_full_name,l1_kaot_full_name) l2_kaot_full_name,
             nvl(l3_kaot_full_name,nvl(l2_kaot_full_name,l1_kaot_full_name)) l3_kaot_full_name,
             nvl(l4_kaot_full_name,nvl(l3_kaot_full_name,nvl(l2_kaot_full_name,l1_kaot_full_name))) l4_kaot_full_name,
             nvl(l5_kaot_full_name,nvl(l4_kaot_full_name,nvl(l3_kaot_full_name,nvl(l2_kaot_full_name,l1_kaot_full_name)))) l5_kaot_full_name,
             koat_tp_name,
             n.nst_name,
             count(distinct os.toas_rnspm) rnsp_qty,
             count(distinct os.toas_at)  at_qty,
             count(distinct case when oa.toa_gender=''M'' and oa.toa_full_year<18 then oa.toa_sc end) m_less_18,
             count(distinct case when oa.toa_gender=''M'' and oa.toa_full_year between 18 and 60 then oa.toa_sc end) m_between_18_60,
             count(distinct case when oa.toa_gender=''M'' and oa.toa_full_year>60 then oa.toa_sc end) m_great_60,
             count(distinct case when oa.toa_gender=''M'' and nvl(oa.toa_full_year,0)<=0 then oa.toa_sc end) m_unaged,
             count(distinct case when oa.toa_gender=''M'' and oa.toa_is_disabled=''T'' then oa.toa_sc end) m_is_disabled,
             count(distinct case when oa.toa_gender=''F'' and oa.toa_full_year<18 then oa.toa_sc end) f_less_18,
             count(distinct case when oa.toa_gender=''F'' and oa.toa_full_year between 18 and 60 then oa.toa_sc end) f_between_18_60,
             count(distinct case when oa.toa_gender=''F'' and oa.toa_full_year>60 then oa.toa_sc end) f_great_60,
             count(distinct case when oa.toa_gender=''F'' and nvl(oa.toa_full_year,0)<=0 then oa.toa_sc end) f_unaged,
             count(distinct case when oa.toa_gender=''F'' and oa.toa_is_disabled=''T'' then oa.toa_sc end) f_is_disabled,
             count(distinct case when nvl(oa.toa_gender,''E'') not in (''F'',''M'') and oa.toa_full_year<18 then oa.toa_sc end) u_less_18,
             count(distinct case when nvl(oa.toa_gender,''E'') not in (''F'',''M'') and oa.toa_full_year between 18 and 60 then oa.toa_sc end) u_between_18_60,
             count(distinct case when nvl(oa.toa_gender,''E'') not in (''F'',''M'') and oa.toa_full_year>60 then oa.toa_sc end) u_great_60,
             count(distinct case when nvl(oa.toa_gender,''E'') not in (''F'',''M'') and nvl(oa.toa_full_year,0)<=0 then oa.toa_sc end) u_unaged,
             count(distinct case when nvl(oa.toa_gender,''E'') not in (''F'',''M'') and oa.toa_is_disabled=''T'' then oa.toa_sc end) u_is_disabled
      FROM uss_Ndi.MV_NDI_KATOTTG k
      JOIN uss_rpt.V_TCTR_OSP_SERVICES os
        ON k.kaot_id = os.toas_kaot
      JOIN uss_ndi.v_ndi_service_type n
        ON os.toas_nst = n.nst_id
      JOIN uss_rpt.V_TCTR_OSP_ANALITYC oa
        ON os.toas_toa_sc = oa.toa_sc
      WHERE 1=1
      #<FILTER>#
      group by l1_kaot_full_name,
             nvl(l2_kaot_full_name,l1_kaot_full_name),
             nvl(l3_kaot_full_name,nvl(l2_kaot_full_name,l1_kaot_full_name)),
             nvl(l4_kaot_full_name,nvl(l3_kaot_full_name,nvl(l2_kaot_full_name,l1_kaot_full_name))),
             nvl(l5_kaot_full_name,nvl(l4_kaot_full_name,nvl(l3_kaot_full_name,nvl(l2_kaot_full_name,l1_kaot_full_name)))),
             koat_tp_name,
             n.nst_name
        ';


        IF (p_Koat_L5 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l5 = '
                || p_Koat_L5
                || '
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l5)';
        END IF;

        IF (p_Koat_L4 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l4 = '
                || p_Koat_L4
                || ' and k.kaot_kaot_l5 is null
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l4)';
        END IF;

        IF (p_Koat_L3 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l3 = '
                || p_Koat_L3
                || ' and k.kaot_kaot_l4 is null
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l3)';
        END IF;

        IF (p_Koat_L2 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l2 = '
                || p_Koat_L2
                || ' and k.kaot_kaot_l3 is null
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l2)';
        END IF;

        IF (p_Koat_L1 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l1 = '
                || p_Koat_L1
                || ' and k.kaot_kaot_l2 is null
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l1)';
        END IF;


        IF (p_Nst_Id IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Nst_Id, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND os.toas_nst is not null
      AND os.toas_nst in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                          FROM DUAL
                          CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF (p_Scy_Group IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Scy_Group, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND oa.toa_scy_group is not null
      AND oa.toa_scy_group in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                               FROM DUAL
                               CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF (p_Rnspm_Tp IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Rnspm_Tp, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND os.toas_rnspm_tp in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                               FROM DUAL
                               CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF    p_Child_Qty_From IS NOT NULL
           OR p_Child_Qty_To IS NOT NULL
           OR p_Child_Age_From IS NOT NULL
           OR p_Child_Age_To IS NOT NULL
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND (SELECT count(1)
           FROM uss_rpt.V_TCTR_OSP_RELATIVES osr
           WHERE oa.toa_sc = osr.toar_sc
             AND osr.toar_relation_tp=''B''
             AND osr.toar_full_year between '
                || NVL (p_Child_Age_From, 0)
                || ' and '
                || NVL (p_Child_Age_To, 999)
                || ' ) between '
                || NVL (p_Child_Qty_From, 0)
                || ' and '
                || NVL (p_Child_Qty_To, 99999)
                || ' ';
        END IF;

        IF p_Age_From IS NOT NULL OR p_Age_To IS NOT NULL
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND oa.toa_full_year between '
                || NVL (p_Age_From, 0)
                || ' and '
                || NVL (p_Age_To, 999)
                || ' ';
        END IF;

        IF p_Nff_id IS NOT NULL
        THEN
            l_str := REPLACE (REPLACE (p_Nff_id, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
            AND EXISTS(SELECT 1
                       FROM uss_rpt.V_TCTR_OSP_FAMILY_FEATURES off
                       WHERE oa.toa_sc = off.toff_toa_sc
                         AND off.toff_nff in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                                              FROM DUAL
                                              CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL))';
        END IF;

        IF (p_Gender IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Gender, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND oa.toa_gender is not null
      AND oa.toa_gender in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                            FROM DUAL
                            CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF (p_Is_Disabled IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Is_Disabled, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND oa.toa_is_disabled is not null
      AND oa.toa_is_disabled in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                                 FROM DUAL
                                 CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF p_Serv_month_From IS NOT NULL OR p_Serv_month_To IS NOT NULL
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND EXISTS(SELECT 1
                 FROM uss_rpt.V_TCTR_OSP_SERVICES oss
                 WHERE oa.toa_sc = oss.toas_toa_sc
                 AND nvl(oss.toad_months_amount,0) between '
                || NVL (p_Serv_month_From, 0)
                || ' and '
                || NVL (p_Serv_month_To, 9999)
                || ' ) ';
        END IF;

        l_Query := REPLACE (l_QUERY, '#<FILTER>#', l_Filter);

        --dbms_output.put_line(l_Query);

        OPEN p_Res FOR l_Query;
    END;

    PROCEDURE Get_TCTR_Wide_Analytic_View (
        p_Res                  OUT SYS_REFCURSOR,
        p_Koat_L1           IN     NUMBER DEFAULT NULL,
        p_Koat_L2           IN     NUMBER DEFAULT NULL,
        p_Koat_L3           IN     NUMBER DEFAULT NULL,
        p_Koat_L4           IN     NUMBER DEFAULT NULL,
        p_Koat_L5           IN     NUMBER DEFAULT NULL,
        p_Nst_Id            IN     VARCHAR2 DEFAULT NULL,
        p_Scy_Group         IN     VARCHAR2 DEFAULT NULL,
        p_Child_Qty_From    IN     NUMBER DEFAULT NULL,
        p_Child_Qty_To      IN     NUMBER DEFAULT NULL,
        p_Child_Age_From    IN     NUMBER DEFAULT NULL,
        p_Child_Age_To      IN     NUMBER DEFAULT NULL,
        p_Nff_Id            IN     VARCHAR2 DEFAULT NULL,
        p_Rnspm_Tp          IN     VARCHAR2 DEFAULT NULL,
        p_Gender            IN     VARCHAR2 DEFAULT NULL,
        p_Age_From          IN     NUMBER DEFAULT NULL,
        p_Age_To            IN     NUMBER DEFAULT NULL,
        p_Is_Disabled       IN     VARCHAR2 DEFAULT NULL,
        p_Serv_month_From   IN     NUMBER DEFAULT NULL,
        p_Serv_month_To     IN     NUMBER DEFAULT NULL)
    IS
        l_Query    CLOB;
        l_Filter   CLOB;
        l_str      VARCHAR2 (32000);
    BEGIN
        /*
          insert into err_log(el_code, el_message)
          values('p_Koat_L1',p_Koat_L1);
          insert into err_log(el_code, el_message)
          values('p_Koat_L2',p_Koat_L2);
          insert into err_log(el_code, el_message)
          values('p_Koat_L3',p_Koat_L3);
          insert into err_log(el_code, el_message)
          values('p_Koat_L4',p_Koat_L4);
          insert into err_log(el_code, el_message)
          values('p_Koat_L5',p_Koat_L5);
          commit;
        */

        l_Query :=
            '
     with x_analytic_katottg  as (select kaot_id,
                                         l1_kaot_full_name l1_kfn,
                                         nvl(l2_kaot_full_name,l1_kaot_full_name) l2_kfn,
                                         nvl(l3_kaot_full_name,nvl(l2_kaot_full_name,l1_kaot_full_name)) l3_kfn,
                                         nvl(l4_kaot_full_name,nvl(l3_kaot_full_name,nvl(l2_kaot_full_name,l1_kaot_full_name))) l4_kfn,
                                         nvl(l5_kaot_full_name,nvl(l4_kaot_full_name,nvl(l3_kaot_full_name,nvl(l2_kaot_full_name,l1_kaot_full_name)))) l5_kfn,
                                         koat_tp_name
                                  from uss_Ndi.MV_NDI_KATOTTG)
     SELECT  case when g_total = 1 then ''Всього''
                  when g_l2_kaot_full_name = 1 then ''Всього''
                  else l1_kfn end l1_kaot_full_name,
             case when g_total = 1 then ''''
                  when g_l2_kaot_full_name = 1 then ''''
                  when g_l3_kaot_full_name = 1 then ''Всього''
                  else l2_kfn end l2_kaot_full_name,
             case when g_total = 1 then ''''
                  when g_l2_kaot_full_name = 1 then ''''
                  when g_l3_kaot_full_name = 1 then ''''
                  when g_l4_kaot_full_name = 1 then ''Всього''
                  else l3_kfn end l3_kaot_full_name,
             case when g_total = 1 then ''''
                  when g_l2_kaot_full_name = 1 then ''''
                  when g_l3_kaot_full_name = 1 then ''''
                  when g_l4_kaot_full_name = 1 then ''''
                  when g_l5_kaot_full_name = 1 then ''Всього''
                  else l4_kfn end l4_kaot_full_name,
             case when g_total = 1 then ''''
                  when g_l2_kaot_full_name = 1 then ''''
                  when g_l3_kaot_full_name = 1 then ''''
                  when g_l4_kaot_full_name = 1 then ''''
                  when g_l5_kaot_full_name = 1 then ''''
                  when g_koat_tp_name = 1 then ''Всього''
                  else l5_kfn end l5_kaot_full_name,
             case when g_total = 1 then ''''
                  when g_l2_kaot_full_name = 1 then ''''
                  when g_l3_kaot_full_name = 1 then ''''
                  when g_l4_kaot_full_name = 1 then ''''
                  when g_l5_kaot_full_name = 1 then ''''
                  when g_koat_tp_name = 1 then ''''
                  when g_nst_name = 1 then ''Всього''
                  else koat_tp_name end koat_tp_name,
             case when g_l1_kaot_full_name = 1 then to_char(nst_name_all)
                  when g_l2_kaot_full_name = 1 then to_char(nst_name_l1)
                  when g_l3_kaot_full_name = 1 then to_char(nst_name_l2)
                  when g_l4_kaot_full_name = 1 then to_char(nst_name_l3)
                  when g_l5_kaot_full_name = 1 then to_char(nst_name_l4)
                  when g_koat_tp_name = 1 then to_char(nst_name_l5)
                  when g_nst_name = 1 then to_char(nst_name_koat_tp)
                  else nst_name end nst_name,
             rnsp_qty,
             at_qty,
             m_less_18,
             m_between_18_60,
             m_great_60,
             m_unaged,
             m_is_disabled,
             f_less_18,
             f_between_18_60,
             f_great_60,
             f_unaged,
             f_is_disabled,
             u_less_18,
             u_between_18_60,
             u_great_60,
             u_unaged,
             u_is_disabled,
             all_is_disabled,
             all_sc,
             g_total,
             g_l1_kaot_full_name,
             g_l2_kaot_full_name,
             g_l3_kaot_full_name,
             g_l4_kaot_full_name,
             g_l5_kaot_full_name,
             g_koat_tp_name,
             g_nst_name
    FROM (
    SELECT   rownum as rn,
             l1_kfn,
             l2_kfn,
             l3_kfn,
             l4_kfn,
             l5_kfn,
             koat_tp_name,
             nst_name,
             nst_name_koat_tp,
             nst_name_l5,
             nst_name_l4,
             nst_name_l3,
             nst_name_l2,
             nst_name_l1,
             nst_name_all,
             rnsp_qty,
             at_qty,
             m_less_18,
             m_between_18_60,
             m_great_60,
             m_unaged,
             m_is_disabled,
             f_less_18,
             f_between_18_60,
             f_great_60,
             f_unaged,
             f_is_disabled,
             u_less_18,
             u_between_18_60,
             u_great_60,
             u_unaged,
             u_is_disabled,
             all_is_disabled,
             all_sc,
             g_total,
             g_l1_kaot_full_name,
             g_l2_kaot_full_name,
             g_l3_kaot_full_name,
             g_l4_kaot_full_name,
             g_l5_kaot_full_name,
             g_koat_tp_name,
             g_nst_name
    FROM(
      SELECT l1_kfn,
             l2_kfn,
             l3_kfn,
             l4_kfn,
             l5_kfn,
             koat_tp_name,
             n.nst_name,
             count(distinct nst_name) over (partition by l1_kfn, l2_kfn, l3_kfn, l4_kfn, l5_kfn, koat_tp_name) nst_name_koat_tp,
             count(distinct nst_name) over (partition by l1_kfn, l2_kfn, l3_kfn, l4_kfn, l5_kfn) nst_name_l5,
             count(distinct nst_name) over (partition by l1_kfn, l2_kfn, l3_kfn, l4_kfn) nst_name_l4,
             count(distinct nst_name) over (partition by l1_kfn, l2_kfn, l3_kfn) nst_name_l3,
             count(distinct nst_name) over (partition by l1_kfn, l2_kfn) nst_name_l2,
             count(distinct nst_name) over (partition by l1_kfn) nst_name_l1,
             count(distinct nst_name) over () nst_name_all,
             count(distinct os.toas_rnspm) rnsp_qty,
             count(distinct os.toas_at)  at_qty,
             count(distinct case when os.toas_gender=''M'' and os.toas_full_year<18 then os.toas_sc end) m_less_18,
             count(distinct case when os.toas_gender=''M'' and os.toas_full_year between 18 and 60 then os.toas_sc end) m_between_18_60,
             count(distinct case when os.toas_gender=''M'' and os.toas_full_year>60 then os.toas_sc end) m_great_60,
             count(distinct case when os.toas_gender=''M'' and nvl(os.toas_full_year,0)<=0 then os.toas_sc end) m_unaged,
             count(distinct case when os.toas_gender=''M'' and os.toas_is_disabled=''T'' then os.toas_sc end) m_is_disabled,
             count(distinct case when os.toas_gender=''F'' and os.toas_full_year<18 then os.toas_sc end) f_less_18,
             count(distinct case when os.toas_gender=''F'' and os.toas_full_year between 18 and 60 then os.toas_sc end) f_between_18_60,
             count(distinct case when os.toas_gender=''F'' and os.toas_full_year>60 then os.toas_sc end) f_great_60,
             count(distinct case when os.toas_gender=''F'' and nvl(os.toas_full_year,0)<=0 then os.toas_sc end) f_unaged,
             count(distinct case when os.toas_gender=''F'' and os.toas_is_disabled=''T'' then os.toas_sc end) f_is_disabled,
             count(distinct case when nvl(os.toas_gender,''E'') not in (''F'',''M'') and os.toas_full_year<18 then os.toas_sc end) u_less_18,
             count(distinct case when nvl(os.toas_gender,''E'') not in (''F'',''M'') and os.toas_full_year between 18 and 60 then os.toas_sc end) u_between_18_60,
             count(distinct case when nvl(os.toas_gender,''E'') not in (''F'',''M'') and os.toas_full_year>60 then os.toas_sc end) u_great_60,
             count(distinct case when nvl(os.toas_gender,''E'') not in (''F'',''M'') and nvl(os.toas_full_year,0)<=0 then os.toas_sc end) u_unaged,
             count(distinct case when nvl(os.toas_gender,''E'') not in (''F'',''M'') and os.toas_is_disabled=''T'' then os.toas_sc end) u_is_disabled,
             count(distinct case when os.toas_is_disabled=''T'' then os.toas_sc end) all_is_disabled,
             count(distinct os.toas_sc) all_sc,
             GROUPING(l1_kfn) g_total,
             GROUPING(l1_kfn) g_l1_kaot_full_name,
             GROUPING(l2_kfn) g_l2_kaot_full_name,
             GROUPING(l3_kfn) g_l3_kaot_full_name,
             GROUPING(l4_kfn) g_l4_kaot_full_name,
             GROUPING(l5_kfn) g_l5_kaot_full_name,
             GROUPING(koat_tp_name) g_koat_tp_name,
             GROUPING(nst_name) g_nst_name
      FROM x_analytic_KATOTTG  k
      JOIN uss_rpt.V_TCTR_OSP_SERVICES os
        ON k.kaot_id = os.toas_kaot
      JOIN uss_ndi.v_ndi_service_type n
        ON os.toas_nst = n.nst_id
      WHERE 1=1
      #<FILTER>#
      group by rollup(
               l1_kfn,
               l2_kfn,
               l3_kfn,
               l4_kfn,
               l5_kfn,
               koat_tp_name,
               n.nst_name)
      ORDER BY l1_kfn nulls last,
               l2_kfn nulls last,
               l3_kfn nulls last,
               l4_kfn nulls last,
               l5_kfn nulls last,
               koat_tp_name nulls last,
               n.nst_name nulls last
       ))
       order by rn
        ';


        IF (p_Koat_L5 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l5 = '
                || p_Koat_L5
                || '
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l5)';
        END IF;

        IF (p_Koat_L4 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l4 = '
                || p_Koat_L4
                || ' and k.kaot_kaot_l5 is null
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l4)';
        END IF;

        IF (p_Koat_L3 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l3 = '
                || p_Koat_L3
                || ' and k.kaot_kaot_l4 is null
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l3)';
        END IF;

        IF (p_Koat_L2 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l2 = '
                || p_Koat_L2
                || ' and k.kaot_kaot_l3 is null
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l2)';
        END IF;

        IF (p_Koat_L1 IS NOT NULL)
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND k.kaot_id IN (SELECT k.kaot_id
                           FROM uss_ndi.v_ndi_katottg k
                           START WITH k.kaot_kaot_l1 = '
                || p_Koat_L1
                || ' and k.kaot_kaot_l2 is null
                           CONNECT BY NOCYCLE PRIOR k.kaot_id = k.kaot_kaot_l1)';
        END IF;


        IF (p_Nst_Id IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Nst_Id, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND os.toas_nst is not null
      AND os.toas_nst in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                          FROM DUAL
                          CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF (p_Scy_Group IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Scy_Group, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND os.toas_scy_group is not null
      AND os.toas_scy_group in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                               FROM DUAL
                               CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF (p_Rnspm_Tp IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Rnspm_Tp, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND os.toas_rnspm_tp in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                               FROM DUAL
                               CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF    p_Child_Qty_From IS NOT NULL
           OR p_Child_Qty_To IS NOT NULL
           OR p_Child_Age_From IS NOT NULL
           OR p_Child_Age_To IS NOT NULL
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND (SELECT COUNT(1)
           FROM (SELECT 1
                 FROM uss_rpt.V_TCTR_OSP_RELATIVES osr
                 WHERE os.toas_sc = osr.toar_sc_from
                   AND osr.toar_relation_tp=''B''
                   AND osr.toar_full_year between '
                || NVL (p_Child_Age_From, 0)
                || ' and '
                || NVL (p_Child_Age_To, 999)
                || '
                 UNION ALL
                 SELECT 1
                 FROM uss_rpt.V_TCTR_OSP_RELATIVES osr
                 WHERE os.toas_sc = osr.toar_sc_to
                   AND osr.toar_relation_tp=''B''
                   AND osr.toar_full_year between '
                || NVL (p_Child_Age_From, 0)
                || ' and '
                || NVL (p_Child_Age_To, 999)
                || ' )
             ) between '
                || NVL (p_Child_Qty_From, 0)
                || ' and '
                || NVL (p_Child_Qty_To, 99999)
                || ' ';
        END IF;

        IF p_Age_From IS NOT NULL OR p_Age_To IS NOT NULL
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND os.toas_full_year between '
                || NVL (p_Age_From, 0)
                || ' and '
                || NVL (p_Age_To, 999)
                || ' ';
        END IF;

        IF p_Nff_id IS NOT NULL
        THEN
            l_str := REPLACE (REPLACE (p_Nff_id, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
            AND EXISTS(SELECT 1
                       FROM uss_rpt.V_TCTR_OSP_FAMILY_FEATURES off
                       WHERE os.toas_sc = off.toff_sc
                         AND off.toff_nff in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                                              FROM DUAL
                                              CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL))';
        END IF;

        IF (p_Gender IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Gender, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND os.toas_gender is not null
      AND os.toas_gender in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                            FROM DUAL
                            CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF (p_Is_Disabled IS NOT NULL)
        THEN
            l_str := REPLACE (REPLACE (p_Is_Disabled, '''', ''), '"', '');
            l_Filter :=
                   l_Filter
                || '
      AND os.toas_is_disabled is not null
      AND os.toas_is_disabled in (SELECT     REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) pivot_char
                                 FROM DUAL
                                 CONNECT BY REGEXP_SUBSTR ('''
                || l_str
                || ''', ''[^,]+'', 1, LEVEL) IS NOT NULL)';
        END IF;

        IF p_Serv_month_From IS NOT NULL OR p_Serv_month_To IS NOT NULL
        THEN
            l_Filter :=
                   l_Filter
                || '
      AND EXISTS(SELECT 1
                 FROM uss_rpt.V_TCTR_OSP_SERVICES oss
                 WHERE os.toas_sc = oss.toas_sc
                 AND nvl(oss.toad_months_amount,0) between '
                || NVL (p_Serv_month_From, 0)
                || ' and '
                || NVL (p_Serv_month_To, 9999)
                || ' ) ';
        END IF;

        l_Query := REPLACE (l_QUERY, '#<FILTER>#', l_Filter);

        --dbms_output.put_line(l_Query);

        OPEN p_Res FOR l_Query;
    END;
END API$ACT_ANALYTIC_PANELS;
/