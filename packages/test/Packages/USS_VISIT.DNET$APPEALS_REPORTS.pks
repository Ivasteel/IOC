/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$APPEALS_REPORTS
IS
    -- Author  : LEVCHENKO
    -- Created : 18.06.2021 13:39:29
    -- Purpose : Звіти

    -- info:   Отримання інформації по КАТОТТГ
    -- params: p_kaot_id - ІД КАТОТТГ
    -- note:
    FUNCTION get_katottg_info (p_kaot_id NUMBER)
        RETURN VARCHAR2;

    -- info:   Отримання інформації по вулиці
    -- params: p_ns_id - ідентифікатор вулиці
    -- note:
    FUNCTION get_street_info (p_ns_id NUMBER)
        RETURN VARCHAR2;

    --Адреса проживання
    FUNCTION get_pers_fact_address (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN VARCHAR2;

    --Адреса регістрації
    FUNCTION get_pers_reg_address (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_ap_document_attr_str (p_ap_id    NUMBER,
                                       p_app_id   NUMBER,
                                       p_ndt      NUMBER,
                                       p_nda      NUMBER,
                                       p_apd_id   NUMBER:= NULL)
        RETURN VARCHAR2;

    FUNCTION get_ap_document_attr_str (p_ap_id       NUMBER,
                                       p_app_id      NUMBER,
                                       p_ndt         NUMBER,
                                       p_nda_class   VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_ap_document_attr_dt (p_ap_id       NUMBER,
                                      p_app_id      NUMBER,
                                      p_ndt         NUMBER,
                                      p_nda_class   VARCHAR2)
        RETURN DATE;

    FUNCTION get_ap_document_attr_dt (p_ap_id    NUMBER,
                                      p_app_id   NUMBER,
                                      p_ndt      NUMBER,
                                      p_nda      NUMBER)
        RETURN DATE;

    FUNCTION get_ap_document_attr_int (p_ap_id    NUMBER,
                                       p_app_id   NUMBER,
                                       p_ndt      NUMBER,
                                       p_nda      NUMBER)
        RETURN INTEGER;

    FUNCTION get_ap_document_attr_id (p_ap_id    NUMBER,
                                      p_app_id   NUMBER,
                                      p_ndt      NUMBER,
                                      p_nda      NUMBER,
                                      p_apd_id   NUMBER:= NULL)
        RETURN NUMBER;

    --повертає галочку
    FUNCTION check_mark
        RETURN VARCHAR2;

    -- info:   Ініціалізація процесу підготовки звіту "Розписка про отримання особою документів/довідок від працівника ПФУ;"
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #69659
    PROCEDURE reg_receip_info_get (p_ap_id    IN     appeal.ap_id%TYPE,
                                   p_jbr_id      OUT DECIMAL);

    FUNCTION get_doc_is_required (p_adp_ndt   IN NUMBER,
                                  p_apd_ap    IN NUMBER,
                                  p_apd_app   IN NUMBER,
                                  p_app_tp    IN VARCHAR2)
        RETURN VARCHAR2;

    -- info:   Ініціалізація процесу підготовки друкованої форми заяви
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #70457
    PROCEDURE reg_application_get (p_ap_id    IN     appeal.ap_id%TYPE,
                                   p_jbr_id      OUT DECIMAL);

    -- info:   Ініціалізація процесу підготовки друкованої форми заяви по ВПО (стара, форма до 01.08.23)
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #70457
    PROCEDURE reg_application_get_old (p_ap_id    IN     appeal.ap_id%TYPE,
                                       p_jbr_id      OUT DECIMAL);

    PROCEDURE reg_declaration_get (p_ap_id    IN     appeal.ap_id%TYPE,
                                   p_jbr_id      OUT NUMBER);

    -----------------------------------------------------------------
    --  Ініціалізація процесу підготовки звіту "Звіт щодо роботи в ЄСП"
    --  p_com_org код органу ПФУ
    --  p_d_start початок періоду
    --  p_d_end   кінець періоду
    -----------------------------------------------------------------
    PROCEDURE reg_report_work_esp_get (p_com_org       appeal.com_org%TYPE,
                                       p_d_start       DATE,
                                       p_d_end         DATE,
                                       p_jbr_id    OUT NUMBER);

    ---------------------------------------------------------------------------------------------------
    --Ініціалізація процесу підготовки звіту "Звіт щодо кількості зареєстрованих заяв надавачів"
    ---------------------------------------------------------------------------------------------------
    PROCEDURE reg_report_g_reg_appeals (p_com_org       appeal.com_org%TYPE,
                                        p_d_start       DATE,
                                        p_d_end         DATE,
                                        p_jbr_id    OUT NUMBER);

    -- info:   формування друкованих форм документів для надавачів соціальних послуг
    -- params: p_rt_id - ідентифікатор звіту,
    --         p_ap_id - ідентифікатор звернення
    -- note:
    PROCEDURE reg_nsp_doc_get (p_rt_id    IN     rpt_templates.rt_id%TYPE,
                               p_ap_id    IN     appeal.ap_id%TYPE,
                               p_jbr_id      OUT DECIMAL);

    -- info:   Отримання друкованої форми довідки
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #76148, в разі успішного підготовки файл необхідно зберегти/оновити документ звернення
    PROCEDURE get_dovidka_doc (p_ap_id     IN     appeal.ap_id%TYPE,
                               p_res_doc      OUT SYS_REFCURSOR);

    -- info:   Отримання blob-а з файлом пам'ятки
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #78649, кнопка "Друк пам'ятки"
    PROCEDURE get_note_rpt_blob (p_ap_id            IN     appeal.ap_id%TYPE,
                                 p_code             IN     VARCHAR2,
                                 p_file_name           OUT VARCHAR2,
                                 p_file_mime_type      OUT VARCHAR2,
                                 p_rpt_blob            OUT BLOB);


    -- #87794, #87814
    PROCEDURE get_ap_edarp_dovidka (p_ap_id     IN     NUMBER,
                                    p_res_doc      OUT SYS_REFCURSOR);

    --
    FUNCTION get_add_docs_term (p_ap_id appeal.ap_id%TYPE)
        RETURN INTEGER;
END;
/


GRANT EXECUTE ON USS_VISIT.DNET$APPEALS_REPORTS TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET$APPEALS_REPORTS TO II01RC_USS_VISIT_WEB
/


/* Formatted on 8/12/2025 5:59:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$APPEALS_REPORTS
IS
    -- Author  : LEVCHENKO
    -- Created : 18.06.2021 13:39:29
    -- Purpose : Звіти

    v_check_mark   VARCHAR2 (200)
        := '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}';

    -- info:   Отримання blob шаблону по коду
    -- params: p_rt_code - код шаблону
    -- note:
    FUNCTION get_template_by_code (p_rt_code IN VARCHAR2)
        RETURN BLOB
    IS
        v_blob   BLOB;
    BEGIN
        SELECT rt_text
          INTO v_blob
          FROM v_rpt_templates
         WHERE rt_code = p_rt_code;

        RETURN v_blob;
    END;

    -- info:   Отримання ідентифікатора шаблону по коду
    -- params: p_rt_code - код шаблону
    -- note:
    FUNCTION get_rt_by_code (p_rt_code IN rpt_templates.rt_code%TYPE)
        RETURN NUMBER
    IS
        v_rt_id   rpt_templates.rt_id%TYPE;
    BEGIN
        SELECT rt_id
          INTO v_rt_id
          FROM v_rpt_templates
         WHERE rt_code = p_rt_code;

        RETURN v_rt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання коду шаблону по ідентифікатору
    -- params: p_rt_id - ідентифікатор шаблону
    -- note:
    FUNCTION get_rt_code (p_rt_id IN rpt_templates.rt_id%TYPE)
        RETURN VARCHAR2
    IS
        v_rt_code   rpt_templates.rt_code%TYPE;
    BEGIN
        SELECT rt_code
          INTO v_rt_code
          FROM v_rpt_templates
         WHERE rt_id = p_rt_id;

        RETURN v_rt_code;
    END;

    -- info:   Отримання назви місяця по даті
    -- params: p_date - дата по якій необхідно отримати назву місяця
    -- note:
    FUNCTION get_month_name (p_date IN DATE)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE TO_NUMBER (TO_CHAR (p_date, 'MM'))
                   WHEN 1 THEN 'січня'
                   WHEN 2 THEN 'лютого'
                   WHEN 3 THEN 'березня'
                   WHEN 4 THEN 'квітня'
                   WHEN 5 THEN 'травня'
                   WHEN 6 THEN 'червня'
                   WHEN 7 THEN 'липня'
                   WHEN 8 THEN 'серпня'
                   WHEN 9 THEN 'вересня'
                   WHEN 10 THEN 'жовтня'
                   WHEN 11 THEN 'листопада'
                   WHEN 12 THEN 'грудня'
                   ELSE ''
               END;
    END;

    -- info:   Отримання інформації по КАТОТТГ
    -- params: p_kaot_id - ІД КАТОТТГ
    -- note:
    FUNCTION get_katottg_info (p_kaot_id NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (4000);
    BEGIN
        SELECT RTRIM (
                      (CASE
                           WHEN l1_name IS NOT NULL AND l1_name != kaot_name
                           THEN
                               l1_name || ', '
                       END)
                   || (CASE
                           WHEN l2_name IS NOT NULL AND l2_name != kaot_name
                           THEN
                               l2_name || ', '
                       END)
                   || (CASE
                           WHEN l3_name IS NOT NULL AND l3_name != kaot_name
                           THEN
                               l3_name || ', '
                       END)
                   || (CASE
                           WHEN l4_name IS NOT NULL AND l4_name != kaot_name
                           THEN
                               l4_name || ', '
                       END)
                   || (CASE
                           WHEN l5_name IS NOT NULL AND l5_name != kaot_name
                           THEN
                               l5_name || ', '
                       END)
                   || name_temp,
                   ',')
          INTO v_res
          FROM (SELECT m.*,
                       (CASE
                            WHEN kaot_kaot_l1 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l1
                                        AND kaot_tp = dic_value)
                        END)                              AS l1_name,
                       (CASE
                            WHEN kaot_kaot_l2 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l2
                                        AND kaot_tp = dic_value)
                        END)                              AS l2_name,
                       (CASE
                            WHEN kaot_kaot_l3 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l3
                                        AND kaot_tp = dic_value)
                        END)                              AS l3_name,
                       (CASE
                            WHEN kaot_kaot_l4 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l4
                                        AND kaot_tp = dic_value)
                        END)                              AS l4_name,
                       (CASE
                            WHEN kaot_kaot_l5 = kaot_id
                            THEN
                                NULL
                            ELSE
                                (SELECT dic_sname || ' ' || x1.kaot_name
                                   FROM uss_ndi.v_ndi_katottg  x1,
                                        uss_ndi.v_ddn_kaot_tp
                                  WHERE     x1.kaot_id = m.kaot_kaot_l5
                                        AND kaot_tp = dic_value)
                        END)                              AS l5_name,
                       t.dic_sname || ' ' || kaot_name    AS name_temp
                  FROM uss_ndi.v_ndi_katottg  m
                       JOIN uss_ndi.v_ddn_kaot_tp t ON t.dic_code = m.kaot_tp
                 WHERE m.kaot_id = p_kaot_id);

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання інформації по вулиці
    -- params: p_ns_id - ідентифікатор вулиці
    -- note:
    FUNCTION get_street_info (p_ns_id NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (4000);
    BEGIN
        SELECT    (SELECT nsrt_name || ' '
                     FROM uss_ndi.v_ndi_street_type
                    WHERE ns_nsrt = nsrt_id)
               || ns_name
          INTO v_res
          FROM uss_ndi.v_ndi_street
         WHERE ns_id = p_ns_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --Адреса проживання
    FUNCTION get_pers_fact_address (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN VARCHAR2
    IS
        l_address   VARCHAR2 (1000);
    BEGIN
        SELECT RTRIM (
                   (   MAX (
                           CASE
                               WHEN     da.apda_nda = 1625
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   TRIM (da.apda_val_string) || ', '
                           END)
                    || (LTRIM (
                               MAX (
                                   CASE da.apda_nda
                                       WHEN 1618
                                       THEN
                                           COALESCE (
                                               (CASE
                                                    WHEN da.apda_val_id
                                                             IS NOT NULL
                                                    THEN
                                                        uss_visit.dnet$appeals_reports.get_katottg_info (
                                                            da.apda_val_id)
                                                END),
                                               da.apda_val_string)
                                   END)
                            || ', ',
                            ', '))
                    || COALESCE (
                           LTRIM (
                                  MAX (
                                      CASE da.apda_nda
                                          WHEN 1632
                                          THEN
                                              COALESCE (
                                                  (CASE
                                                       WHEN da.apda_val_id
                                                                IS NOT NULL
                                                       THEN
                                                           uss_visit.dnet$appeals_reports.get_street_info (
                                                               da.apda_val_id)
                                                   END),
                                                  TRIM (da.apda_val_string))
                                      END)
                               || ', ',
                               ', '),
                           MAX (
                               CASE
                                   WHEN     da.apda_nda = 1640
                                        AND TRIM (da.apda_val_string)
                                                IS NOT NULL
                                   THEN
                                          'вул. '
                                       || TRIM (da.apda_val_string)
                                       || ', '
                               END))
                    || MAX (
                           CASE
                               WHEN     da.apda_nda = 1648
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'буд. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     da.apda_nda = 1654
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'корп. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     da.apda_nda = 1659
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   'кв. ' || TRIM (da.apda_val_string)
                           END)),
                   ', ')
          INTO l_address
          FROM v_ap_document  d
               JOIN v_ap_document_attr da
                   ON     da.apda_apd = d.apd_id
                      AND d.apd_app = p_app_id
                      AND da.apda_ap = d.apd_ap
                      AND da.apda_nda IN (1618,
                                          1625,
                                          1632,
                                          1640,
                                          1648,
                                          1654,
                                          1659)
                      AND da.history_status = 'A'
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = 605
               AND d.history_status = 'A';

        RETURN l_address;
    END;

    --Адреса регістрації
    FUNCTION get_pers_reg_address (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN VARCHAR2
    IS
        l_address   VARCHAR2 (1000);
    BEGIN
        SELECT RTRIM (
                   (   MAX (
                           CASE
                               WHEN     d.apd_ndt = 605
                                    AND da.apda_nda = 1489
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   TRIM (da.apda_val_string) || ', '
                           END)
                    || (LTRIM (
                               MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 605
                                            AND da.apda_nda = 1488
                                       THEN
                                           COALESCE (
                                               (CASE
                                                    WHEN da.apda_val_id
                                                             IS NOT NULL
                                                    THEN
                                                        get_katottg_info (
                                                            da.apda_val_id)
                                                END),
                                               da.apda_val_string)
                                   END)
                            || ', ',
                            ', '))
                    || COALESCE (
                           LTRIM (
                                  MAX (
                                      CASE
                                          WHEN     d.apd_ndt = 605
                                               AND da.apda_nda = 1490
                                          THEN
                                              COALESCE (
                                                  (CASE
                                                       WHEN da.apda_val_id
                                                                IS NOT NULL
                                                       THEN
                                                           get_street_info (
                                                               da.apda_val_id)
                                                   END),
                                                  TRIM (da.apda_val_string))
                                      END)
                               || ', ',
                               ', '),
                           MAX (
                               CASE
                                   WHEN     d.apd_ndt = 605
                                        AND da.apda_nda = 1591
                                        AND TRIM (da.apda_val_string)
                                                IS NOT NULL
                                   THEN
                                          'вул. '
                                       || TRIM (da.apda_val_string)
                                       || ', '
                               END))
                    || MAX (
                           CASE
                               WHEN     d.apd_ndt = 605
                                    AND da.apda_nda = 1599
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'буд. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     d.apd_ndt = 605
                                    AND da.apda_nda = 1605
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'корп. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     d.apd_ndt = 605
                                    AND da.apda_nda = 1611
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   'кв. ' || TRIM (da.apda_val_string)
                           END)),
                   ', ')    AS pers_reg_addr
          INTO l_address
          FROM v_ap_document  d
               JOIN v_ap_document_attr da
                   ON     da.apda_apd = d.apd_id
                      AND d.apd_app = p_app_id
                      AND da.apda_ap = d.apd_ap
                      AND da.apda_nda IN (1489,
                                          1488,
                                          1490,
                                          1591,
                                          1599,
                                          1605,
                                          1611)
                      AND da.history_status = 'A'
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = 605
               AND d.history_status = 'A';

        RETURN l_address;
    END;

    FUNCTION get_ap_document_attr_str (p_ap_id    NUMBER,
                                       p_app_id   NUMBER,
                                       p_ndt      NUMBER,
                                       p_nda      NUMBER,
                                       p_apd_id   NUMBER:= NULL)
        RETURN VARCHAR2
    IS
        l_result   ap_document_attr.apda_val_string%TYPE;
    BEGIN
        /*raise_application_error(-20000, 'p_ap_id='||p_ap_id
        ||';p_ap_id='||p_ap_id
        ||';p_app_id='||p_app_id
        ||';p_ndt='||p_ndt
        ||';p_nda='||p_nda
        ||';p_apd_id='||p_apd_id); */
        SELECT MAX (da.apda_val_string)
          INTO l_result
          FROM ap_document d, ap_document_attr da
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = NVL (p_ndt, d.apd_ndt)
               AND d.history_status = 'A'
               AND d.apd_app = NVL (p_app_id, d.apd_app)
               AND d.apd_id = da.apda_apd
               AND da.history_status = 'A'
               AND da.apda_nda = p_nda
               AND d.apd_id = NVL (p_apd_id, d.apd_id);

        RETURN l_result;
    END;

    FUNCTION get_ap_document_attr_str (p_ap_id       NUMBER,
                                       p_app_id      NUMBER,
                                       p_ndt         NUMBER,
                                       p_nda_class   VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result   ap_document_attr.apda_val_string%TYPE;
    BEGIN
        SELECT MAX (da.apda_val_string)
          INTO l_result
          FROM ap_document  d
               JOIN ap_document_attr da ON (da.apda_apd = d.apd_id)
               JOIN uss_ndi.v_ndi_document_attr a ON (a.nda_id = da.apda_nda)
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = NVL (p_ndt, d.apd_ndt)
               AND d.history_status = 'A'
               AND d.apd_app = NVL (p_app_id, d.apd_app)
               AND da.history_status = 'A'
               AND a.nda_class = p_nda_class;

        RETURN l_result;
    END;

    FUNCTION get_ap_document_attr_dt (p_ap_id    NUMBER,
                                      p_app_id   NUMBER,
                                      p_ndt      NUMBER,
                                      p_nda      NUMBER)
        RETURN DATE
    IS
        l_result   ap_document_attr.apda_val_dt%TYPE;
    BEGIN
        SELECT MAX (da.apda_val_dt)
          INTO l_result
          FROM ap_document d, ap_document_attr da
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = NVL (p_ndt, d.apd_ndt)
               AND d.history_status = 'A'
               AND d.apd_app = NVL (p_app_id, d.apd_app)
               AND d.apd_id = da.apda_apd
               AND da.history_status = 'A'
               AND da.apda_nda = p_nda;

        RETURN l_result;
    END;

    FUNCTION get_ap_document_attr_dt (p_ap_id       NUMBER,
                                      p_app_id      NUMBER,
                                      p_ndt         NUMBER,
                                      p_nda_class   VARCHAR2)
        RETURN DATE
    IS
        l_result   ap_document_attr.apda_val_dt%TYPE;
    BEGIN
        SELECT MAX (da.apda_val_dt)
          INTO l_result
          FROM ap_document  d
               JOIN ap_document_attr da ON (da.apda_apd = d.apd_id)
               JOIN uss_ndi.v_ndi_document_attr a ON (a.nda_id = da.apda_nda)
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = NVL (p_ndt, d.apd_ndt)
               AND d.history_status = 'A'
               AND d.apd_app = NVL (p_app_id, d.apd_app)
               AND da.history_status = 'A'
               AND a.nda_class = p_nda_class;

        RETURN l_result;
    END;

    FUNCTION get_ap_document_attr_int (p_ap_id    NUMBER,
                                       p_app_id   NUMBER,
                                       p_ndt      NUMBER,
                                       p_nda      NUMBER)
        RETURN INTEGER
    IS
        l_result   ap_document_attr.apda_val_int%TYPE;
    BEGIN
        SELECT MAX (da.apda_val_int)
          INTO l_result
          FROM ap_document d, ap_document_attr da
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = NVL (p_ndt, d.apd_ndt)
               AND d.history_status = 'A'
               AND d.apd_app = NVL (p_app_id, d.apd_app)
               AND d.apd_id = da.apda_apd
               AND da.history_status = 'A'
               AND da.apda_nda = p_nda;

        RETURN l_result;
    END;

    FUNCTION get_ap_document_attr_id (p_ap_id    NUMBER,
                                      p_app_id   NUMBER,
                                      p_ndt      NUMBER,
                                      p_nda      NUMBER,
                                      p_apd_id   NUMBER:= NULL)
        RETURN NUMBER
    IS
        l_result   ap_document_attr.apda_val_id%TYPE;
    BEGIN
        SELECT MAX (da.apda_val_id)
          INTO l_result
          FROM ap_document d, ap_document_attr da
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = NVL (p_ndt, d.apd_ndt)
               AND d.history_status = 'A'
               AND d.apd_app = NVL (p_app_id, d.apd_app)
               AND d.apd_id = da.apda_apd
               AND da.history_status = 'A'
               AND da.apda_nda = p_nda
               AND d.apd_id = NVL (p_apd_id, d.apd_id);

        RETURN l_result;
    END;

    --повертає підкреслене p_str  p_undrl = TRUE
    FUNCTION UnderLine (p_str VARCHAR2, p_undrl BOOLEAN)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_undrl
        THEN
            RETURN '\ul' || p_str || '\ul0';
        ELSE
            RETURN p_str;
        END IF;
    END;

    --повертає галочку
    FUNCTION check_mark
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN v_check_mark;
    END;

    -- info:   Ініціалізація процесу підготовки звіту "Розписка про отримання особою документів/довідок від працівника ПФУ;"
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #69659
    PROCEDURE reg_receip_info_get (p_ap_id    IN     appeal.ap_id%TYPE,
                                   p_jbr_id      OUT DECIMAL)
    IS
    BEGIN
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.REG_RECEIP_INFO_GET',
            action_name   => 'p_ap_id=' || TO_CHAR (p_ap_id));

        p_jbr_id :=
            rdm$rtfl.initreport (get_rt_by_code ('RECEIPT_INFO_GET_R1'));

        --ініціалізація параметрів звіту
        FOR data_cur
            IN (  SELECT tools.init_cap (
                                p.app_ln
                             || ' '
                             || p.app_fn
                             || ' '
                             || p.app_mn)                        AS app_pers_name,
                         p.app_inn,
                         (SELECT dt.ndt_name
                            FROM uss_ndi.v_ndi_document_type dt
                           WHERE dt.ndt_id = p.app_ndt)          AS app_ndt_name,
                         p.app_doc_num,
                         a.ap_reg_dt,
                         (SELECT o.org_name
                            FROM v_opfu o
                           WHERE o.org_id = tools.getcurrorg)    AS app_doc_org
                    FROM v_appeal a
                         LEFT JOIN v_ap_person p
                             ON     p.app_ap = a.ap_id
                                AND p.history_status = 'A'
                                AND p.app_tp IN ('P', 'Z') --"Представник заявника", "Заявник" - при наявності в звіт потрапляє представник
                   WHERE a.ap_id = p_ap_id
                ORDER BY p.app_tp)
        LOOP
            rdm$rtfl.addparam (p_jbr_id,
                               'app_pers_name',
                               data_cur.app_pers_name);                  --ПІБ
            rdm$rtfl.addparam (p_jbr_id, 'app_inn', data_cur.app_inn); --РНОКПП, який зазначено в полі РНОКПП в блоці «Учасники звернення»
            rdm$rtfl.addparam (p_jbr_id,
                               'app_ndt_name',
                               data_cur.app_ndt_name); --тип документу -  відповідає назві типу документу із блоку «Документи» (назва може дорівнювати однаму із значень назв «Довідка ОК-2», «Довідка ОК-5», «Довідка ОК-7»…)
            rdm$rtfl.addparam (p_jbr_id, 'app_doc_num', data_cur.app_doc_num); --серія номер – відповідає серії і номеру із блоку «Учасники звернення»
            rdm$rtfl.addparam (p_jbr_id,
                               'ap_reg_dt',
                               TO_CHAR (data_cur.ap_reg_dt, 'DD.MM.YYYY')); --дата звернення
            rdm$rtfl.addparam (p_jbr_id, 'app_doc_org', data_cur.app_doc_org); --орган/організація, у якому/якій видається довідка
            EXIT;
        END LOOP;

        rdm$rtfl.addparam (p_jbr_id,
                           'curr_dt',
                           TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')); --системна дата (поточна)

        rdm$rtfl.adddataset (
            p_jbr_id,
            'main_ds',
               q'[SELECT row_number() over(ORDER BY s.aps_nst, s.aps_id) AS rn, t.nst_name AS aps_name, 1 AS copies_cnt
	FROM uss_visit.v_ap_service s
	JOIN uss_ndi.v_ndi_service_type t ON s.aps_nst = t.nst_id
 WHERE s.aps_ap = ]'
            || TO_CHAR (p_ap_id)
            || q'[
	 AND s.history_status = 'A'
	 /*AND s.aps_st = 'G'*/]'); --!!! тимчасово в таблицю повинні потрапляти всі послуги в незалежності від статусу

        rdm$rtfl.putreporttoworkingqueue (p_jbr_id);
    END;

    FUNCTION get_doc_is_required (p_adp_ndt   IN NUMBER,
                                  p_apd_ap    IN NUMBER,
                                  p_apd_app   IN NUMBER,
                                  p_app_tp    IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_doc_is_required   VARCHAR2 (10);
    BEGIN
        SELECT NVL (MAX (b.dic_name), 'Ні')
          INTO l_doc_is_required
          FROM uss_ndi.v_ndi_nst_doc_config  c
               JOIN uss_ndi.v_ddn_boolean b ON c.nndc_is_req = b.dic_value
         WHERE     (   c.nndc_ndt = p_adp_ndt
                    OR c.nndc_ndc = (SELECT t.ndt_ndc
                                       FROM uss_ndi.v_ndi_document_type t
                                      WHERE t.ndt_id = p_adp_ndt))
               AND c.history_status = 'A'
               AND (c.nndc_app_tp = p_app_tp OR c.nndc_app_tp IS NULL)
               AND (   EXISTS
                           (SELECT NULL
                              FROM ap_service s
                             WHERE     s.aps_ap = p_apd_ap
                                   AND s.history_status = 'A'
                                   AND s.aps_nst = c.nndc_nst)
                    OR c.nndc_nst IS NULL)
               AND (   c.nndc_nda IS NULL
                    OR EXISTS
                           (SELECT NULL
                              FROM uss_visit.v_ap_document  f
                                   JOIN uss_visit.v_ap_document_attr a
                                       ON     f.apd_id = a.apda_apd
                                          AND a.apda_ap =
                                              COALESCE (p_apd_ap, a.apda_ap)
                                          AND a.apda_nda = c.nndc_nda
                                          AND a.apda_val_string =
                                              c.nndc_val_string
                                          AND a.history_status = 'A'
                             WHERE     f.apd_app = p_apd_app
                                   AND f.history_status = 'A'));

        RETURN l_doc_is_required;
    END;

    FUNCTION get_add_docs_term (p_ap_id appeal.ap_id%TYPE)
        RETURN INTEGER
    IS
        l_rezult   INTEGER;
        l_cnt      INTEGER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM ap_service
         WHERE history_status = 'A' AND aps_nst = 248 AND aps_ap = p_ap_id;

        IF l_cnt > 0
        THEN
            l_rezult := 3;
        ELSE
            l_rezult := 1;
        END IF;

        /*WITH PAR1 as (SELECT c.nndc_nst, d.apd_id
                         FROM uss_ndi.v_ndi_nst_doc_config c
                         LEFT JOIN uss_ndi.v_ndi_document_type t ON c.nndc_ndt = t.ndt_id
                         LEFT JOIN uss_visit.v_ap_person p ON (c.nndc_app_tp IS NOT NULL OR c.nndc_nda IS NOT NULL)
                                                          AND p.app_ap = p_ap_id
                                                          AND p.history_status = 'A'
                         LEFT JOIN uss_visit.v_ap_document d ON p.app_id = d.apd_app
                                                            AND d.history_status = 'A'
                                                            AND ((c.nndc_app_tp IS NULL AND c.nndc_nda IS NULL) OR p.app_id = d.apd_app)
                                                            AND (d.apd_ndt = c.nndc_ndt OR d.apd_ndt = c.nndc_ndt_alt1 OR
                                                                (c.nndc_ndc IS NOT NULL AND EXISTS
                                                                 (SELECT NULL
                                                                     FROM uss_ndi.v_ndi_document_type dt
                                                                    WHERE dt.ndt_ndc = c.nndc_ndc
                                                                      AND dt.ndt_id = d.apd_ndt)))
                        WHERE c.nndc_is_req = 'T'
                          AND c.history_status = 'A'
                          AND (c.nndc_ndt < 600 OR c.nndc_ndt > 600)
                          AND (c.nndc_app_tp IS NULL OR c.nndc_app_tp = p.app_tp)
                          AND (EXISTS (SELECT NULL
                                         FROM uss_visit.v_ap_service s
                                        WHERE s.aps_ap = p_ap_id
                                          AND s.history_status = 'A'
                                          AND s.aps_nst = c.nndc_nst) OR c.nndc_nst IS NULL)
                          AND (c.nndc_nda IS NULL OR EXISTS
                               (SELECT NULL
                                  FROM uss_visit.v_ap_document f
                                  JOIN uss_visit.v_ap_document_attr a ON f.apd_id = a.apda_apd
                                                                     AND a.apda_ap = f.apd_ap
                                                                     AND a.apda_nda = c.nndc_nda
                                                                     AND a.apda_val_string = c.nndc_val_string
                                                                     AND a.history_status = 'A'
                                 WHERE f.apd_app = p.app_id
                                   AND f.history_status = 'A'))
                          AND (d.apd_id IS NULL)),
              par2 as (SELECT c.nndc_nst, d.apd_id
                       FROM uss_visit.v_ap_document d
                       JOIN uss_ndi.v_ndi_document_type t ON d.apd_ndt = t.ndt_id
                                                         AND t.ndt_is_have_scan = 'T'
                       JOIN uss_visit.v_ap_person p ON d.apd_app = p.app_id
                                                   AND p.history_status = 'A'
                     --#73198 перевірка наявності вкладення по альтернативному документі
                       LEFT JOIN uss_ndi.v_ndi_nst_doc_config c ON c.nndc_ndt = d.apd_ndt
                                                               AND c.nndc_is_req = 'T'
                                                               AND c.history_status = 'A'
                                                               AND (c.nndc_app_tp IS NULL OR c.nndc_app_tp = p.app_tp)
                                                               AND (EXISTS (SELECT 1
                                                                              FROM uss_visit.v_ap_service s
                                                                             WHERE s.aps_ap = p_ap_id
                                                                               AND s.history_status = 'A'
                                                                               AND s.aps_nst = c.nndc_nst) OR c.nndc_nst IS NULL)
                                                               AND (c.nndc_nda IS NULL OR EXISTS
                                                                    (SELECT 1
                                                                       FROM uss_visit.v_ap_document_attr a
                                                                      WHERE a.apda_nda = c.nndc_nda
                                                                        AND a.apda_val_string = c.nndc_val_string
                                                                        AND a.history_status = 'A'))
                       LEFT JOIN uss_visit.v_ap_document ad ON ad.apd_ndt = c.nndc_ndt_alt1
                                                           AND ad.apd_ap = p_ap_id
                                                           AND ad.apd_app = p.app_id
                      -- LEFT JOIN uss_doc.v_doc_attachments ada ON ada.dat_dh = ad.apd_dh
                      WHERE d.apd_ap = p_ap_id
                        AND (d.apd_ndt < 600 OR d.apd_ndt > 600)
                        --AND d.apd_ndt NOT IN (600)
                        AND d.history_status = 'A'
                        AND NOT EXISTS (SELECT NULL FROM uss_doc.v_doc_attachments da WHERE da.dat_dh = d.apd_dh)
                        \*AND ada.dat_id IS NULL*\)
        SELECT (CASE WHEN MAX(CASE nndc_nst WHEN 248 THEN 1 ELSE 0 END) = 1
                        AND MAX(CASE WHEN nndc_nst != 248 THEN 1 ELSE 0 END) = 0 THEN 3
                     ELSE 1 END)
        INTO l_rezult
        FROM (SELECT nndc_nst, apd_id FROM PAR1
              UNION all
              --Документи без вкладень
              SELECT nndc_nst, apd_id
               FROM par2);*/

        RETURN l_rezult;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    FUNCTION is_service_reg (p_ap_id IN NUMBER, p_nst_id IN NUMBER)
        RETURN NUMBER
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM ap_service t
         WHERE     t.aps_ap = p_ap_id
               AND t.history_status = 'A'
               AND t.aps_nst IN (p_nst_id);

        RETURN l_cnt;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми заяви
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #70457
    PROCEDURE reg_application_get (p_ap_id    IN     appeal.ap_id%TYPE,
                                   p_jbr_id      OUT DECIMAL)
    IS
        v_appeal_exist   NUMBER;
        v_org_name       VARCHAR2 (1000);
        l_str            VARCHAR2 (4000);
        l_term           INTEGER;
    BEGIN
        ROLLBACK;

        tools.writemsg ('DNET$APPEALS_REPORTS.' || $$PLSQL_UNIT);
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.REG_APPLICATION_GET',
            action_name   => 'p_ap_id=' || TO_CHAR (p_ap_id));

        --#78873 Друкована форма "Заяви щодо змін обставин"
        FOR o_cur
            IN (  SELECT a.ap_num,
                         a.ap_reg_dt,
                         a.ap_create_dt,
                         o.org_name,
                         p.app_id,
                         tools.init_cap (
                                p.app_ln
                             || ' '
                             || p.app_fn
                             || ' '
                             || p.app_mn)    AS app_pib,
                         p.app_inn,
                         p.app_doc_num,
                         MAX (
                             CASE
                                 WHEN     d.apd_ndt IN (6, 7)
                                      AND da.apda_nda IN (3, 9)
                                 THEN
                                     da.apda_val_string
                             END)            AS pasp_sn,
                         MAX (
                             CASE
                                 WHEN     d.apd_ndt IN (6, 7)
                                      AND da.apda_nda IN (5, 14)
                                 THEN
                                     da.apda_val_dt
                             END)            AS pass_dt,
                         MAX (
                             CASE
                                 WHEN     d.apd_ndt IN (6, 7)
                                      AND da.apda_nda IN (7, 13)
                                 THEN
                                     da.apda_val_string
                             END)            AS pass_org,
                         s.aps_nst,
                         MAX (
                             CASE
                                 WHEN     s.aps_nst = 642
                                      AND d.apd_ndt = 10091
                                      AND da.apda_nda = 2191
                                      AND da.apda_val_string IS NOT NULL
                                 THEN
                                     (SELECT nst_name
                                        FROM uss_ndi.v_ndi_service_type
                                       WHERE nst_id =
                                             TO_NUMBER (
                                                 da.apda_val_string))
                             END)            AS pay_dtl_chng_serv,
                         MAX (
                             CASE
                                 WHEN     s.aps_nst = 642
                                      AND d.apd_ndt = 10091
                                      AND da.apda_nda = 2192
                                 THEN
                                     da.apda_val_string
                             END)            AS pay_dtl_chng_tp,
                            MAX (
                                CASE
                                    WHEN     s.aps_nst = 645
                                         AND d.apd_ndt = 10093
                                         AND da.apda_nda = 2240
                                         AND da.apda_val_string
                                                 IS NOT NULL
                                    THEN
                                        (SELECT nst_name || ' '
                                           FROM uss_ndi.v_ndi_service_type
                                          WHERE nst_id =
                                                TO_NUMBER (
                                                    da.apda_val_string))
                                END)
                         || MAX (
                                CASE
                                    WHEN     s.aps_nst = 645
                                         AND d.apd_ndt = 10093
                                         AND da.apda_nda = 2241
                                         AND da.apda_val_string
                                                 IS NOT NULL
                                    THEN
                                        'у зв’язку' || da.apda_val_string
                                END)         AS asstnc_chng,
                         MAX (CASE
                                  WHEN     s.aps_nst IN (642,
                                                         643,
                                                         645,
                                                         801)
                                       AND d.apd_ndt IN (10091,
                                                         10093,
                                                         10098,
                                                         10099)
                                       AND da.apda_nda IN (2105,
                                                           2239,
                                                           2254,
                                                           2259)
                                  THEN
                                      da.apda_val_dt
                              END)           AS appeal_dt,
                         MAX (
                             CASE
                                 WHEN     s.aps_nst IN (643, 801)
                                      AND d.apd_ndt IN (10098, 10099)
                                      AND da.apda_nda IN (2254, 2259)
                                      AND da.apda_val_string IS NOT NULL
                                 THEN
                                     (SELECT nst_name
                                        FROM uss_ndi.v_ndi_service_type
                                       WHERE nst_id =
                                             TO_NUMBER (
                                                 da.apda_val_string))
                             END)            AS asstnc_chng1,
                         MAX (
                             CASE
                                 WHEN     s.aps_nst = 643
                                      AND d.apd_ndt = 10098
                                      AND da.apda_nda = 2256
                                      AND da.apda_val_string IS NOT NULL
                                 THEN
                                     (SELECT dic_sname
                                        FROM uss_ndi.v_ddn_changes_fm
                                       WHERE dic_value =
                                             da.apda_val_string)
                                 WHEN     s.aps_nst = 801
                                      AND d.apd_ndt = 10099
                                      AND da.apda_nda = 2261
                                 THEN
                                     TRIM (da.apda_val_string)
                             END)            AS asstnc_chng_rsn
                    FROM v_appeal a
                         LEFT JOIN v_opfu o ON o.org_id = a.com_org
                         LEFT JOIN v_ap_person p
                             ON     p.app_ap = a.ap_id
                                AND p.app_tp IN ('O', 'ANF')
                                AND p.history_status = 'A'
                         LEFT JOIN v_ap_service s
                             ON     s.aps_ap = a.ap_id
                                AND s.aps_nst IN (641,
                                                  642,
                                                  643,
                                                  644,
                                                  645,
                                                  801)
                                AND s.history_status = 'A'
                         LEFT JOIN v_ap_document d
                         JOIN v_ap_document_attr da
                             ON     da.apda_apd = d.apd_id
                                AND da.apda_ap = p_ap_id
                                AND da.history_status = 'A'
                             ON     d.apd_ap = a.ap_id
                                AND d.apd_app = p.app_id
                                AND d.apd_ndt IN (6,
                                                  7,
                                                  10091,
                                                  10092,
                                                  10093,
                                                  10098,
                                                  10099)
                                AND d.history_status = 'A'
                   WHERE a.ap_id = p_ap_id AND a.ap_tp IN ('O')
                GROUP BY a.ap_num,
                         a.ap_reg_dt,
                         a.ap_create_dt,
                         o.org_name,
                         p.app_id,
                         tools.init_cap (
                             p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn),
                         p.app_inn,
                         p.app_doc_num,
                         s.aps_nst
                ORDER BY p.app_id
                   FETCH FIRST 1 ROW ONLY)
        LOOP
            --ініціалізація завдання на підготовку звіту
            p_jbr_id :=
                rdm$rtfl.initreport (
                    get_rt_by_code ('APPEAL_CHNG_CRCMSTNCS_R1'));

            rdm$rtfl.addparam (p_jbr_id, 'org_name', o_cur.org_name);
            rdm$rtfl.addparam (
                p_jbr_id,
                'app_pib',
                COALESCE (
                    o_cur.app_pib,
                       '____________________________________________________________________________\par'
                    || '________________________________________________________________________________\par'
                    || '________________________________________________________________________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'app_pass_serie',
                COALESCE (
                    REGEXP_REPLACE (
                        SUBSTR (COALESCE (o_cur.pasp_sn, o_cur.app_doc_num),
                                1,
                                2),
                        '\d'),
                    '______'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'app_pass_num',
                COALESCE (
                    (CASE
                         WHEN REGEXP_REPLACE (
                                  SUBSTR (
                                      COALESCE (o_cur.pasp_sn,
                                                o_cur.app_doc_num),
                                      1,
                                      2),
                                  '\d')
                                  IS NOT NULL
                         THEN
                             SUBSTR (
                                 COALESCE (o_cur.pasp_sn, o_cur.app_doc_num),
                                 3)
                         ELSE
                             COALESCE (o_cur.pasp_sn, o_cur.app_doc_num)
                     END),
                    '________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'app_pass_org',
                COALESCE (
                    LTRIM (
                        (   (CASE
                                 WHEN o_cur.pass_dt IS NOT NULL
                                 THEN
                                        TO_CHAR (o_cur.pass_dt, 'DD.MM.YYYY')
                                     || ', '
                             END)
                         || o_cur.pass_org),
                        ', '),
                    '__________________________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'app_inn',
                COALESCE (o_cur.app_inn, '_________________________'));
            rdm$rtfl.addparam (p_jbr_id,
                               'app_phone_num',
                               '_________________________');
            rdm$rtfl.addparam (p_jbr_id, 'app_eoc', '___________________');
            rdm$rtfl.addparam (
                p_jbr_id,
                'info_chng_chck_mrk',
                (CASE o_cur.aps_nst WHEN 641 THEN v_check_mark END));
            rdm$rtfl.addparam (
                p_jbr_id,
                'info_chng',
                   '_______________________________________________\par'
                || '________________________________________________________________________________');
            rdm$rtfl.addparam (
                p_jbr_id,
                'pay_dtl_chng_chck_mrk',
                (CASE o_cur.aps_nst WHEN 642 THEN v_check_mark END));
            rdm$rtfl.addparam (
                p_jbr_id,
                'pay_dtl_chng_serv',
                COALESCE (
                    o_cur.pay_dtl_chng_serv,
                       '_________________________\par'
                    || '________________________________________________________________________________'));

            IF     o_cur.aps_nst = 642
               AND o_cur.app_id IS NOT NULL
               AND o_cur.pay_dtl_chng_tp IN ('BANK', 'POST')
            THEN
                FOR pd_cur
                    IN (SELECT MAX (
                                   CASE p.apm_tp
                                       WHEN 'BANK'
                                       THEN
                                              (SELECT    b.nb_name
                                                      || ', '
                                                 FROM uss_ndi.v_ndi_bank
                                                      b
                                                WHERE b.nb_id =
                                                      p.apm_nb)
                                           || (CASE
                                                   WHEN p.apm_account LIKE
                                                            'UA%'
                                                   THEN
                                                       p.apm_account
                                                   WHEN p.apm_account
                                                            IS NOT NULL
                                                   THEN
                                                          'UA'
                                                       || p.apm_account
                                               END)
                                       WHEN 'POST'
                                       THEN
                                           RTRIM (
                                                  LTRIM (
                                                         p.apm_index
                                                      || ', ',
                                                      ', ')
                                               || LTRIM (
                                                         k.kaot_full_name
                                                      || ', ',
                                                      ', ')
                                               || COALESCE (
                                                      LTRIM (
                                                             (CASE
                                                                  WHEN nsrt_name
                                                                           IS NOT NULL
                                                                  THEN
                                                                         nsrt_name
                                                                      || ' '
                                                              END)
                                                          || ns.ns_name
                                                          || ', ',
                                                          ', '),
                                                      LTRIM (
                                                             p.apm_street
                                                          || ', ',
                                                          ', '))
                                               || (CASE
                                                       WHEN p.apm_building
                                                                IS NOT NULL
                                                       THEN
                                                              'буд. '
                                                           || p.apm_building
                                                           || ', '
                                                   END)
                                               || (CASE
                                                       WHEN p.apm_block
                                                                IS NOT NULL
                                                       THEN
                                                              'корп. '
                                                           || p.apm_block
                                                           || ', '
                                                   END)
                                               || (CASE
                                                       WHEN p.apm_apartment
                                                                IS NOT NULL
                                                       THEN
                                                              'кв. '
                                                           || p.apm_apartment
                                                   END),
                                               ', ')
                                   END)    AS pay_dtl_chng_info
                          FROM v_ap_payment  p
                               LEFT JOIN uss_ndi.v_ndi_katottg k
                                   ON k.kaot_id = p.apm_kaot
                               LEFT JOIN uss_ndi.v_ndi_street ns
                                   ON ns.ns_id = p.apm_ns
                               LEFT JOIN uss_ndi.v_ndi_street_type st
                                   ON st.nsrt_id = ns.ns_nsrt
                         WHERE     p.apm_ap = p_ap_id
                               AND p.apm_app = o_cur.app_id
                               AND p.apm_tp = o_cur.pay_dtl_chng_tp
                               AND p.history_status = 'A')
                LOOP
                    rdm$rtfl.addparam (p_jbr_id,
                                       'pay_dtl_chng_info',
                                       pd_cur.pay_dtl_chng_info);
                END LOOP;
            ELSE
                rdm$rtfl.addparam (p_jbr_id, 'pay_dtl_chng_info', '');
            END IF;

            rdm$rtfl.addparam (
                p_jbr_id,
                'asstnc_chng_chck_mrk',
                (CASE o_cur.aps_nst WHEN 645 THEN v_check_mark END));
            rdm$rtfl.addparam (
                p_jbr_id,
                'asstnc_chng',
                COALESCE (
                    o_cur.asstnc_chng,
                       '_______________________________\par'
                    || '________________________________________________________________________________\par'
                    || 'у зв’язку ________________________________________________________________________\par'
                    || '________________________________________________________________________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'asstnc_chng_chck_mrk1',
                (CASE WHEN o_cur.aps_nst IN (643, 801) THEN v_check_mark END));
            rdm$rtfl.addparam (
                p_jbr_id,
                'asstnc_chng1',
                COALESCE (
                    o_cur.asstnc_chng1,
                    '______________________________________________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'asstnc_chng_rsn',
                COALESCE (o_cur.asstnc_chng_rsn,
                          '_______________________________________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'ap_create_dt',
                COALESCE (
                    TO_CHAR (COALESCE (o_cur.appeal_dt, o_cur.ap_reg_dt),
                             'DD.MM.YYYY'),
                    '"___" ________________20___ р.'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'ap_reg_dt',
                COALESCE (TO_CHAR (o_cur.ap_create_dt, 'DD.MM.YYYY'),
                          '"___" ________________20___ р. '));
            rdm$rtfl.addparam (p_jbr_id,
                               'ap_reg_num',
                               COALESCE (o_cur.ap_num, '________'));
        END LOOP;

        IF p_jbr_id IS NULL
        THEN
            --#78293 друкована форма заяви про допомогу на проживання ВПО
            FOR vpo_cur
                IN (SELECT (SELECT o.org_name
                              FROM v_opfu o
                             WHERE o.org_id = a.com_org)
                               AS org_name,
                           prst.pers_pib,
                           prst.pers_brth_date,
                           prst.pers_phone_num,
                           CASE
                               WHEN prst.is_dsblt_pers = 'T' THEN 'Так'
                               ELSE 'Ні'
                           END
                               AS is_dsblt_pers,
                           TRIM (
                               CASE prst.pers_rej_inn
                                   WHEN 'T' THEN prst.pers_doc_num
                                   ELSE prst.pers_inn
                               END)
                               AS pers_ident,
                           prst.pers_inn,
                           prst.pers_reg_addr
                               AS pers_reg_addr,
                           prst.pers_fact_addr
                               AS pers_fact_addr,
                           (SELECT DISTINCT
                                   FIRST_VALUE (p.apm_account)
                                       OVER (ORDER BY p.apm_id)
                              FROM v_ap_payment p
                             WHERE     p.apm_ap = p_ap_id
                                   AND p.apm_app = prst.app_id
                                   AND p.history_status = 'A')
                               AS bank_iban,
                           a.ap_reg_dt,
                           pers_passport,
                           pers_email,
                           CASE
                               WHEN pers_vpo_number IS NOT NULL
                               THEN
                                   SUBSTR (pers_vpo_number,
                                           INSTR (pers_vpo_number, '-') + 1)
                           END
                               AS pers_vpo_number,
                           pers_eddr,
                           (SELECT DISTINCT
                                   FIRST_VALUE (b.nb_name)
                                       OVER (ORDER BY p.apm_id)
                              FROM v_ap_payment  p
                                   JOIN uss_ndi.v_ndi_bank b
                                       ON (b.nb_id = p.apm_nb)
                             WHERE     p.apm_ap = p_ap_id
                                   AND p.history_status = 'A'
                                   AND p.apm_app = prst.app_id)
                               AS bank_name,
                           CASE
                               WHEN    a.ap_is_second = 'F'
                                    OR a.ap_is_second IS NULL
                               THEN
                                   'X'
                           END
                               AS perv,
                           CASE WHEN a.ap_is_second = 'T' THEN 'X' END
                               AS dubl,
                           CASE WHEN attr_3700 = 'T' THEN 'X' END
                               AS fight,
                           CASE WHEN attr_3701 = 'T' THEN 'X' END
                               AS destroyed,
                           CASE WHEN attr_3702 IS NOT NULL THEN 'X' END
                               AS other,
                           attr_3702
                               AS other_name
                      FROM v_appeal  a
                           LEFT JOIN
                           (WITH
                                street
                                AS
                                    (SELECT    (CASE
                                                    WHEN nsrt_name
                                                             IS NOT NULL
                                                    THEN
                                                        nsrt_name || ' '
                                                    ELSE
                                                        ''
                                                END)
                                            || ns_name    AS ns_name,
                                            ns_id
                                       FROM uss_ndi.v_ndi_street
                                            LEFT JOIN
                                            uss_ndi.v_ndi_street_type
                                                ON ns_nsrt = nsrt_id)
                            SELECT MAX (prs.pers_name)
                                       AS pers_pib,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt IN (6, 7)
                                                AND da.apda_nda IN (606, 607)
                                           THEN
                                               da.apda_val_dt
                                       END)
                                       AS pers_brth_date,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt = 10045
                                                AND da.apda_nda = 1804
                                           THEN
                                               TRIM (da.apda_val_string)
                                       END)
                                       AS pers_phone_num,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt = 605
                                                AND da.apda_nda = 1772
                                                AND da.apda_val_string
                                                        IS NOT NULL
                                           THEN
                                               da.apda_val_string
                                       END)
                                       AS is_dsblt_pers,
                                   COALESCE (
                                       MAX (prs.app_inn),
                                       MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 5
                                                    AND da.apda_nda = 1
                                               THEN
                                                   TRIM (da.apda_val_string)
                                           END))
                                       AS pers_inn,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt = 605
                                                AND da.apda_nda = 640
                                           THEN
                                               da.apda_val_string
                                       END)
                                       AS pers_rej_inn,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt IN (6, 7)
                                                AND da.apda_nda IN (3, 9)
                                           THEN
                                               da.apda_val_string
                                       END)
                                       AS pers_passport,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt IN (10045)
                                                AND da.apda_nda IN (3697)
                                           THEN
                                               da.apda_val_string
                                       END)
                                       AS pers_email,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt IN (10045)
                                                AND da.apda_nda IN (3700)
                                           THEN
                                               da.apda_val_string
                                       END)
                                       AS attr_3700,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt IN (10045)
                                                AND da.apda_nda IN (3701)
                                           THEN
                                               da.apda_val_string
                                       END)
                                       AS attr_3701,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt IN (10045)
                                                AND da.apda_nda IN (3702)
                                           THEN
                                               da.apda_val_string
                                       END)
                                       AS attr_3702,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt IN (10052)
                                                AND da.apda_nda IN (1756)
                                           THEN
                                               da.apda_val_string
                                       END)
                                       AS pers_vpo_number,
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt IN (7)
                                                AND da.apda_nda IN (810)
                                           THEN
                                               da.apda_val_string
                                       END)
                                       AS pers_eddr,
                                   MAX (prs.app_doc_num)
                                       AS pers_doc_num,
                                   RTRIM (
                                       (   MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 59
                                                        AND nda.nda_pt = 145
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          TRIM (
                                                              da.apda_val_string)
                                                       || ', '
                                               END)
                                        || (LTRIM (
                                                   MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    605
                                                                AND nda.nda_nng =
                                                                    59
                                                                AND nda.nda_pt =
                                                                    140
                                                           THEN
                                                               COALESCE (
                                                                   (SELECT k.kaot_full_name
                                                                      FROM uss_ndi.v_ndi_katottg
                                                                           k
                                                                     WHERE k.kaot_id =
                                                                           da.apda_val_id),
                                                                   TRIM (
                                                                       da.apda_val_string))
                                                       END)
                                                || ', ',
                                                ', '))
                                        || COALESCE (
                                               LTRIM (
                                                      MAX (
                                                          CASE
                                                              WHEN     d.apd_ndt =
                                                                       605
                                                                   AND nda.nda_nng =
                                                                       59
                                                                   AND nda.nda_pt =
                                                                       147
                                                              THEN
                                                                  COALESCE (
                                                                      (SELECT s.ns_name
                                                                         FROM street
                                                                                  s
                                                                        WHERE s.ns_id =
                                                                              da.apda_val_id),
                                                                      TRIM (
                                                                          da.apda_val_string))
                                                          END)
                                                   || ', ',
                                                   ', '),
                                               MAX (
                                                   CASE
                                                       WHEN     d.apd_ndt =
                                                                605
                                                            AND nda.nda_nng =
                                                                59
                                                            AND nda.nda_pt =
                                                                180
                                                            AND TRIM (
                                                                    da.apda_val_string)
                                                                    IS NOT NULL
                                                       THEN
                                                              'вул. '
                                                           || TRIM (
                                                                  da.apda_val_string)
                                                           || ', '
                                                   END))
                                        || MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 59
                                                        AND nda.nda_pt = 148
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          'буд. '
                                                       || TRIM (
                                                              da.apda_val_string)
                                                       || ', '
                                               END)
                                        || MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 59
                                                        AND nda.nda_pt = 149
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          'корп. '
                                                       || TRIM (
                                                              da.apda_val_string)
                                                       || ', '
                                               END)
                                        || MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 59
                                                        AND nda.nda_pt = 150
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          'кв. '
                                                       || TRIM (
                                                              da.apda_val_string)
                                               END)),
                                       ', ')
                                       AS pers_reg_addr,
                                   RTRIM (
                                       (   MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 60
                                                        AND nda.nda_pt = 145
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          TRIM (
                                                              da.apda_val_string)
                                                       || ', '
                                               END)
                                        || (LTRIM (
                                                   MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    605
                                                                AND nda.nda_nng =
                                                                    60
                                                                AND nda.nda_pt =
                                                                    140
                                                           THEN
                                                               COALESCE (
                                                                   (SELECT k.kaot_full_name
                                                                      FROM uss_ndi.v_ndi_katottg
                                                                           k
                                                                     WHERE k.kaot_id =
                                                                           da.apda_val_id),
                                                                   TRIM (
                                                                       da.apda_val_string))
                                                       END)
                                                || ', ',
                                                ', '))
                                        || COALESCE (
                                               LTRIM (
                                                      MAX (
                                                          CASE
                                                              WHEN     d.apd_ndt =
                                                                       605
                                                                   AND nda.nda_nng =
                                                                       60
                                                                   AND nda.nda_pt =
                                                                       147
                                                              THEN
                                                                  COALESCE (
                                                                      (SELECT s.ns_name
                                                                         FROM street
                                                                                  s
                                                                        WHERE s.ns_id =
                                                                              da.apda_val_id),
                                                                      TRIM (
                                                                          da.apda_val_string))
                                                          END)
                                                   || ', ',
                                                   ', '),
                                               MAX (
                                                   CASE
                                                       WHEN     d.apd_ndt =
                                                                605
                                                            AND nda.nda_nng =
                                                                60
                                                            AND nda.nda_pt =
                                                                180
                                                            AND TRIM (
                                                                    da.apda_val_string)
                                                                    IS NOT NULL
                                                       THEN
                                                              'вул. '
                                                           || TRIM (
                                                                  da.apda_val_string)
                                                           || ', '
                                                   END))
                                        || MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 60
                                                        AND nda.nda_pt = 148
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          'буд. '
                                                       || TRIM (
                                                              da.apda_val_string)
                                                       || ', '
                                               END)
                                        || MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 60
                                                        AND nda.nda_pt = 149
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          'корп. '
                                                       || TRIM (
                                                              da.apda_val_string)
                                                       || ', '
                                               END)
                                        || MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 60
                                                        AND nda.nda_pt = 150
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          'кв. '
                                                       || TRIM (
                                                              da.apda_val_string)
                                               END)),
                                       ', ')
                                       AS pers_fact_addr,
                                   MAX (prs.app_id)
                                       AS app_id
                              FROM (SELECT app.app_id,
                                           app.pers_name,
                                           app.app_inn,
                                           app.app_doc_num
                                      FROM (SELECT p.app_id,
                                                   tools.init_cap (
                                                          p.app_ln
                                                       || ' '
                                                       || p.app_fn
                                                       || ' '
                                                       || p.app_mn)
                                                       AS pers_name,
                                                   p.app_inn,
                                                   p.app_doc_num,
                                                   FIRST_VALUE (p.app_id)
                                                       OVER (
                                                           ORDER BY p.app_ln)
                                                       AS frst_app
                                              FROM v_ap_person p
                                             WHERE     p.app_ap = p_ap_id
                                                   AND p.app_tp = 'Z'
                                                   AND p.history_status = 'A')
                                           app
                                     WHERE app_id = frst_app) prs
                                   LEFT JOIN v_ap_document d
                                   JOIN v_ap_document_attr da
                                       ON     da.apda_apd = d.apd_id
                                          AND da.apda_ap = p_ap_id
                                          AND da.history_status = 'A'
                                   JOIN uss_ndi.v_ndi_document_attr nda
                                       ON nda.nda_id = da.apda_nda
                                       ON     d.apd_app = prs.app_id
                                          AND d.apd_ap = p_ap_id
                                          AND d.apd_ndt IN (5,
                                                            6,
                                                            7,
                                                            605,
                                                            10045,
                                                            10052)
                                          AND d.history_status = 'A') prst
                               ON 1 = 1
                     WHERE     a.ap_id = p_ap_id
                           AND EXISTS
                                   (SELECT 1
                                      FROM v_ap_service s
                                     WHERE     s.aps_ap = p_ap_id
                                           AND s.aps_nst = 664
                                           AND s.history_status = 'A')
                           AND ROWNUM < 2)
            LOOP
                --ініціалізація завдання на підготовку звіту
                p_jbr_id :=
                    rdm$rtfl.initreport (get_rt_by_code ('VPO_APPL_R2'));

                rdm$rtfl.addparam (
                    p_jbr_id,
                    'org_name',
                    COALESCE (
                        vpo_cur.org_name,
                        '_____________________________\par__________________________________________________________'));
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'pers_pib',
                    COALESCE (
                        vpo_cur.pers_pib,
                           '________________________________________________________________\par'
                        || '\fs20 (прізвище, власне ім’я, по батькові (за наявності) \fs24'));
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'pers_brth_dt',
                    COALESCE (TO_CHAR (vpo_cur.pers_brth_date, 'DD.MM.YYYY'),
                              '__________________'));
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'pers_phone',
                    COALESCE (vpo_cur.pers_phone_num, '________________'));
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'is_dsblt_pers',
                    COALESCE (
                        vpo_cur.is_dsblt_pers,
                           '__________________\par'
                        || '\fs20                                                                                              (так/ні) \fs24'));

                rdm$rtfl.addparam (p_jbr_id,
                                   'd1',
                                   SUBSTR (vpo_cur.pers_vpo_number, 1, 1));
                rdm$rtfl.addparam (p_jbr_id,
                                   'd2',
                                   SUBSTR (vpo_cur.pers_vpo_number, 2, 1));
                rdm$rtfl.addparam (p_jbr_id,
                                   'd3',
                                   SUBSTR (vpo_cur.pers_vpo_number, 3, 1));
                rdm$rtfl.addparam (p_jbr_id,
                                   'd4',
                                   SUBSTR (vpo_cur.pers_vpo_number, 4, 1));
                rdm$rtfl.addparam (p_jbr_id,
                                   'd5',
                                   SUBSTR (vpo_cur.pers_vpo_number, 5, 1));
                rdm$rtfl.addparam (p_jbr_id,
                                   'd6',
                                   SUBSTR (vpo_cur.pers_vpo_number, 6, 1));
                rdm$rtfl.addparam (p_jbr_id,
                                   'd7',
                                   SUBSTR (vpo_cur.pers_vpo_number, 7, 1));
                rdm$rtfl.addparam (p_jbr_id,
                                   'd8',
                                   SUBSTR (vpo_cur.pers_vpo_number, 8, 1));
                rdm$rtfl.addparam (p_jbr_id,
                                   'd9',
                                   SUBSTR (vpo_cur.pers_vpo_number, 9, 1));
                rdm$rtfl.addparam (p_jbr_id,
                                   'd10',
                                   SUBSTR (vpo_cur.pers_vpo_number, 10, 1));
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'pers_reg_addr',
                    COALESCE (
                        '\ul ' || vpo_cur.pers_reg_addr || '\ul0',
                        '____________________\par________________________________________________________________________________'));
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'pers_fact_addr',
                    COALESCE (
                        '\ul ' || vpo_cur.pers_fact_addr || '\ul0',
                           '_______________________________________\par'
                        || '________________________________________________________________________________'));
                rdm$rtfl.addparam (p_jbr_id, 'bank_iban', vpo_cur.bank_iban);
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'app_dt',
                    COALESCE (TO_CHAR (vpo_cur.ap_reg_dt, 'DD.MM.YYYY'),
                              '____________\par' || '\fs20 (дата) \fs24'));
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'pers_pib',
                    COALESCE (vpo_cur.pers_pib,
                              '_________________\par' || '\fs20 (ПІБ) \fs24'));

                rdm$rtfl.addparam (p_jbr_id,
                                   'passport',
                                   vpo_cur.pers_passport);
                rdm$rtfl.addparam (p_jbr_id, 'pc', vpo_cur.pers_ident);
                rdm$rtfl.addparam (p_jbr_id, 'email', vpo_cur.pers_email);
                rdm$rtfl.addparam (p_jbr_id, 'eddr', vpo_cur.pers_eddr);
                rdm$rtfl.addparam (p_jbr_id, 'bank', vpo_cur.bank_name);
                rdm$rtfl.addparam (p_jbr_id, 'perv', vpo_cur.perv);
                rdm$rtfl.addparam (p_jbr_id, 'dubl', vpo_cur.dubl);
                rdm$rtfl.addparam (p_jbr_id, 'fight', vpo_cur.fight);
                rdm$rtfl.addparam (p_jbr_id, 'destroyed', vpo_cur.destroyed);
                rdm$rtfl.addparam (p_jbr_id, 'other', vpo_cur.other);
                rdm$rtfl.addparam (p_jbr_id, 'other_nam', vpo_cur.other_name);

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'ds',
                       q'[SELECT p.app_id,
           MAX(uss_visit.tools.init_cap(p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn)) AS c1,
           to_char(MAX(CASE
                         WHEN d.apd_ndt IN (6, 7, 37) AND da.apda_nda IN (606, 607, 91) THEN
                          da.apda_val_dt
                       END),
                   'DD.MM.YYYY') AS c2,
           MAX(coalesce(p.app_doc_num,
                        (CASE
                          WHEN d.apd_ndt IN (6, 7, 37) AND da.apda_nda IN (3, 9, 90) THEN
                           TRIM(da.apda_val_string)
                        END))) AS c3,
          coalesce(MAX(p.app_inn),
                      MAX(CASE
                            WHEN d.apd_ndt = 5 AND da.apda_nda = 1 THEN
                             TRIM(da.apda_val_string)
                          END)
                  ) AS c4,

          case when max(case when d.apd_ndt in (200, 201) then 1 end) = 1 then 'Так' else 'Ні' end as c5,
          max(case when d.apd_ndt in (7) and da.apda_nda in (810) then da.apda_val_string end) as c6
      FROM uss_visit.v_ap_person p
      JOIN uss_visit.v_ap_document d ON d.apd_app = p.app_id
                                    AND d.apd_ap = ]'
                    || TO_CHAR (p_ap_id)
                    || q'[
                                    AND d.apd_ndt IN (5, 6, 7, 37, 605, 200, 201)
                                    AND d.history_status = 'A'
      JOIN uss_visit.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                          AND da.apda_ap = ]'
                    || TO_CHAR (p_ap_id)
                    || q'[
                                          AND da.history_status = 'A'
     WHERE p.app_ap = ]'
                    || TO_CHAR (p_ap_id)
                    || q'[
       AND p.app_tp IN ('FP', 'FM')
       AND p.history_status = 'A'
     GROUP BY p.app_id
     ORDER BY 2]');
            END LOOP;

            IF p_jbr_id IS NULL
            THEN
                --#70556 контроль наявності заяви серед документів звернення
                SELECT COUNT (1)
                  INTO v_appeal_exist
                  FROM (SELECT app_id
                          FROM (SELECT p.app_id,
                                       tools.init_cap (
                                              p.app_ln
                                           || ' '
                                           || p.app_fn
                                           || ' '
                                           || p.app_mn)         AS pers_name,
                                       p.app_doc_num,
                                       p.app_ndt,
                                       p.app_inn,
                                       COUNT (*) OVER ()        AS app_cnt,
                                       FIRST_VALUE (p.app_id)
                                           OVER (
                                               ORDER BY
                                                   DECODE (p.app_tp,
                                                           'Z', 1,
                                                           'ANF', 2,
                                                           3),
                                                   p.app_ln)    AS frst_app
                                  FROM v_ap_person p
                                 WHERE     p.app_ap = p_ap_id
                                       AND p.app_tp IN ('Z', 'ANF')
                                       AND p.history_status = 'A')
                         WHERE app_id = frst_app) prs
                       JOIN v_ap_document d
                           ON     d.apd_app = prs.app_id
                              AND d.apd_ap = p_ap_id
                              AND d.history_status = 'A'
                              AND d.apd_ndt = 600;


                -- #103643
                IF (is_service_reg (p_ap_id, 21) > 0)
                THEN
                    FOR xx
                        IN (SELECT t.*,
                                   ap.ap_reg_dt,
                                   pd.*,
                                   api$appeal.get_attr_val_string (
                                       p_apd_id      => d.apd_id,
                                       p_nda_class   => 'DSN')
                                       AS app_doc_num1,
                                   api$appeal.get_attr_val_string (
                                       p_apd_id      => d.apd_id,
                                       p_nda_class   => 'DORG')
                                       AS app_doc_issued1
                              FROM ap_person  t
                                   JOIN appeal ap ON (ap.ap_id = t.app_ap)
                                   LEFT JOIN
                                   (SELECT p.apm_id,
                                           p.apm_app,
                                           p.apm_tp,
                                           p.apm_account,
                                           p.apm_index,
                                           b.nb_mfo,
                                           b.nb_edrpou,
                                           b.nb_name
                                      FROM v_ap_payment  p
                                           LEFT JOIN uss_ndi.v_ndi_bank b
                                               ON b.nb_id = p.apm_nb
                                     WHERE     p.apm_ap = p_ap_id
                                           AND p.history_status = 'A'
                                           AND p.apm_tp = 'BANK'
                                           AND p.apm_app IS NOT NULL) pd
                                       ON pd.apm_app = t.app_id
                                   LEFT JOIN
                                   (SELECT *
                                      FROM ap_document  z
                                           JOIN
                                           uss_ndi.v_ndi_document_type zt
                                               ON (zt.ndt_id = z.apd_ndt)
                                     WHERE     z.apd_ap = p_ap_id
                                           AND zt.ndt_ndc = 13) d
                                       ON (d.apd_app = t.app_id)
                             WHERE     t.app_ap = p_ap_id
                                   AND t.app_tp IN ('Z')
                                   AND t.history_status = 'A')
                    LOOP
                        --ініціалізація завдання на підготовку звіту
                        p_jbr_id :=
                            rdm$rtfl.initreport (
                                get_rt_by_code ('PRINT_APPL_FORM_R2'));

                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'email',
                            get_ap_document_attr_str (p_ap_id,
                                                      xx.app_id,
                                                      10314,
                                                      8447));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'date_act',
                            TO_CHAR (get_ap_document_attr_dt (p_ap_id,
                                                              NULL,
                                                              10312,
                                                              8430),
                                     'DD.MM.YYYY'));
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'num_act',
                                           get_ap_document_attr_str (p_ap_id,
                                                                     NULL,
                                                                     10312,
                                                                     8431));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'date_st',
                            TO_CHAR (get_ap_document_attr_dt (p_ap_id,
                                                              NULL,
                                                              10312,
                                                              8433),
                                     'DD.MM.YYYY'));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'date_end',
                            TO_CHAR (get_ap_document_attr_dt (p_ap_id,
                                                              NULL,
                                                              10312,
                                                              8434),
                                     'DD.MM.YYYY'));

                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'date_app',
                            TO_CHAR (xx.ap_reg_dt, 'DD.MM.YYYY'));
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'pers_inn_info',
                                           NVL (xx.app_inn, xx.app_doc_num));
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'pers_pasp_num',
                                           xx.app_doc_num);
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'pers_pasp_info',
                                           xx.app_doc_issued1);
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pers_name',
                            xx.app_ln || ' ' || xx.app_fn || ' ' || xx.app_mn);
                        RDM$RTFL.AddParam (p_jbr_id, 'bank_info', xx.nb_name);
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'bank_account',
                                           xx.apm_account);
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'post_details',
                                           xx.apm_index);

                        rdm$rtfl.AddDataSet (
                            p_jbr_id,
                            'ds1',
                               '
          SELECT t.app_ln || '' '' || t.app_fn || '' '' || t.app_mn AS child_pib,
                 to_char(i.sco_birth_dt, ''DD.MM.YYYY'') AS child_bd,
                 t.app_doc_num AS child_doc,
                 t.app_inn as child_ipn
            FROM uss_visit.v_ap_person t
            LEFT JOIN uss_person.v_sc_info i ON (i.sco_id = t.app_sc)
           WHERE t.app_ap = '
                            || p_ap_id
                            || '
             AND t.app_tp != ''Z''
             AND t.history_status = ''A''
          union
          SELECT t.app_ln || '' '' || t.app_fn || '' '' || t.app_mn AS child_pib,
                 to_char(i.sco_birth_dt, ''DD.MM.YYYY'') AS child_bd,
                 t.app_doc_num AS child_doc,
                 t.app_inn as child_ipn
            FROM uss_visit.v_ap_person t
            LEFT JOIN uss_person.v_sc_info i ON (i.sco_id = t.app_sc)
            join uss_visit.v_ap_document d on (d.apd_app = t.app_id)
            join uss_visit.v_ap_document_attr a on (a.apda_apd = d.apd_id and a.apda_nda = 8436)
           WHERE t.app_ap = '
                            || p_ap_id
                            || '
             AND t.app_tp = ''Z''
             and a.apda_val_string = ''T''
             AND t.history_status = ''A''
          ');


                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pers_fact_addr',
                               get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8437)
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8438)
                            || ', '
                            || NVL (get_ap_document_attr_str (p_ap_id,
                                                              xx.app_id,
                                                              10314,
                                                              8439),
                                    get_ap_document_attr_str (p_ap_id,
                                                              xx.app_id,
                                                              10314,
                                                              8440))
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8441)
                            || ', кор. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8442)
                            || ', кв. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8443));

                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pers_reg_addr',
                               get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8448)
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8449)
                            || ', '
                            || NVL (get_ap_document_attr_str (p_ap_id,
                                                              xx.app_id,
                                                              10314,
                                                              8450),
                                    get_ap_document_attr_str (p_ap_id,
                                                              xx.app_id,
                                                              10314,
                                                              8451))
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8452)
                            || ', кор. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8453)
                            || ', кв. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10314,
                                                         8454));

                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pers_phone_num',
                            get_ap_document_attr_str (p_ap_id,
                                                      xx.app_id,
                                                      10314,
                                                      8446));
                    END LOOP;
                -- #113821
                ELSIF (is_service_reg (p_ap_id, 22) > 0)
                THEN
                    FOR xx
                        IN (SELECT t.*,
                                   ap.ap_reg_dt,
                                   tdt.ndt_name_short || ' ' || t.app_doc_num
                                       AS pasp,
                                   --api$appeal.get_attr_val_string(p_apd_id => d.apd_id, p_nda_class => 'DSN') AS app_doc_num1,
                                   --api$appeal.get_attr_val_string(p_apd_id => d.apd_id, p_nda_class => 'DORG') AS app_doc_issued1,
                                   api$appeal.Get_Attr_Val_Dt (
                                       p_apd_id      => d.apd_id,
                                       p_nda_class   => 'BDT')
                                       AS bdt,
                                   (SELECT MAX (pp.dpp_name)
                                      FROM ap_document_attr  a
                                           JOIN ap_document d
                                               ON (d.apd_id = a.apda_apd)
                                           JOIN uss_ndi.v_ndi_katottg k
                                               ON (k.kaot_id =
                                                   a.apda_val_id)
                                           JOIN
                                           uss_ndi.v_NDI_PAY_PERSON pp
                                               ON (pp.dpp_kaot =
                                                   k.kaot_kaot_l1)
                                     WHERE     a.apda_ap = p_ap_id
                                           AND a.apda_nda = 8634
                                           AND a.history_status = 'A'
                                           AND d.apd_app = t.app_id
                                           AND pp.dpp_tp = 'ISPF')
                                       AS fzoi_name,
                                   ap.ap_num,
                                   (SELECT MAX (g.DIC_NAME)
                                      FROM uss_ndi.v_ddn_gender g
                                     WHERE g.DIC_VALUE = t.app_gender)
                                       AS gndr,
                                   /*(SELECT uss_visit.api$appeal.get_attr_val_string(p_apd_id => q.apd_id, p_nda_class => 'DSN')
                                            || ' виданий ' ||
                                           uss_visit.api$appeal.get_attr_val_string(p_apd_id => q.apd_id, p_nda_class => 'DORG') AS pasp_pred
                                      FROM (SELECT *
                                              FROM ap_person z
                                              LEFT JOIN (SELECT *
                                                           FROM ap_document zd
                                                           JOIN uss_ndi.v_ndi_document_type zdt ON (zdt.ndt_id = zd.apd_ndt)
                                                          WHERE zd.apd_ap = p_ap_id
                                                            AND zdt.ndt_ndc = 13) d ON (d.apd_app = z.app_id)
                                             where z.app_ap = t.app_ap
                                               and z.app_tp = 'P'
                                               and z.history_status = 'A') q
                                   ) as pasp_pred*/
                                    (SELECT    zdt.ndt_name_short
                                            || ' '
                                            || z.app_doc_num
                                       FROM ap_person  z
                                            JOIN
                                            uss_ndi.v_ndi_document_type zdt
                                                ON (zdt.ndt_id = z.app_ndt)
                                      WHERE     z.app_ap = t.app_ap
                                            AND z.app_tp = 'P'
                                            AND z.history_status = 'A')
                                       AS pasp_pred,
                                   (SELECT MAX (
                                               TRIM (
                                                      z.app_ln
                                                   || ' '
                                                   || z.app_fn
                                                   || ' '
                                                   || z.app_mn))    AS pib
                                      FROM uss_visit.v_ap_person z
                                     WHERE     z.app_ap = t.app_ap
                                           AND z.app_tp = 'P'
                                           AND z.history_status = 'A')
                                       AS p_pib,
                                      t.app_ln
                                   || ' '
                                   || SUBSTR (t.app_fn, 1, 1)
                                   || '. '
                                   || SUBSTR (t.app_mn, 1, 1)
                                   || '. '
                                       AS pib_short,
                                   (SELECT MAX (
                                               TRIM (
                                                      z.app_ln
                                                   || ' '
                                                   || SUBSTR (z.app_fn, 1, 1)
                                                   || '. '
                                                   || SUBSTR (z.app_mn, 1, 1)
                                                   || '. '))    AS pib
                                      FROM uss_visit.v_ap_person z
                                     WHERE     z.app_ap = t.app_ap
                                           AND z.app_tp = 'P'
                                           AND z.history_status = 'A')
                                       AS p_pib_short
                              FROM ap_person  t
                                   JOIN appeal ap ON (ap.ap_id = t.app_ap)
                                   LEFT JOIN uss_ndi.v_ndi_document_type tdt
                                       ON (tdt.ndt_id = t.app_ndt)
                                   LEFT JOIN
                                   (SELECT *
                                      FROM ap_document  z
                                           JOIN
                                           uss_ndi.v_ndi_document_type zt
                                               ON (zt.ndt_id = z.apd_ndt)
                                     WHERE     z.apd_ap = p_ap_id
                                           AND zt.ndt_ndc = 13) d
                                       ON (d.apd_app = t.app_id)
                             WHERE     t.app_ap = p_ap_id
                                   AND t.app_tp IN ('Z')
                                   AND t.history_status = 'A')
                    LOOP
                        --ініціалізація завдання на підготовку звіту
                        p_jbr_id :=
                            rdm$rtfl.initreport (
                                get_rt_by_code ('PRINT_APPL_FORM_R3'));

                        RDM$RTFL.AddParam (p_jbr_id, 'app_num', xx.ap_num);
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'fzoi_name',
                                           xx.fzoi_name);
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pers_pib',
                            xx.app_ln || ' ' || xx.app_fn || ' ' || xx.app_mn);
                        --RDM$RTFL.AddParam(p_jbr_id, 'pasp_info', xx.app_doc_num1 || ' виданий ' || xx.app_doc_issued1);
                        RDM$RTFL.AddParam (p_jbr_id, 'pasp_info', xx.pasp);
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'rnokpp',
                                           NVL (xx.app_inn, xx.app_doc_num));
                        RDM$RTFL.AddParam (p_jbr_id, 'sex', xx.gndr);
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'bday',
                                           TO_CHAR (xx.bdt, 'DD.MM.YYYY'));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'eddr',
                            get_ap_document_attr_str (p_ap_id,
                                                      xx.app_id,
                                                      7,
                                                      810));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pers_pib1',
                            NVL (
                                xx.p_pib,
                                   xx.app_ln
                                || ' '
                                || xx.app_fn
                                || ' '
                                || xx.app_mn));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pers_pib2',
                            NVL (xx.p_pib_short, xx.pib_short));

                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'addr_fact',
                               get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8682)
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8634)
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8635)
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8636)
                            || ', кор. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8637)
                            || ', кв. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8638));

                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'addr_reg',
                               get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8726)
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8725)
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8727)
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8728)
                            || ', кор. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8729)
                            || ', кв. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8730));

                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pers_phone_num',
                            get_ap_document_attr_str (p_ap_id,
                                                      xx.app_id,
                                                      10344,
                                                      8639));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'add_phone_num',
                            get_ap_document_attr_str (p_ap_id,
                                                      xx.app_id,
                                                      10344,
                                                      8640));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pers_mail',
                            get_ap_document_attr_str (p_ap_id,
                                                      xx.app_id,
                                                      10344,
                                                      8683));

                        rdm$rtfl.AddDataSet (
                            p_jbr_id,
                            'pred',
                            '
          SELECT t.app_ln || '' '' || t.app_fn || '' '' || t.app_mn AS pib,
                 nvl(t.app_inn, t.app_doc_num) as rnokpp_pred,
                 ''' || xx.pasp_pred || ''' as pasp_pred
            FROM uss_visit.v_ap_person t
           WHERE t.app_ap = ' || p_ap_id || '
             AND t.app_tp = ''P''
             AND t.history_status = ''A''
          ');

                        rdm$rtfl.AddDataSet (
                            p_jbr_id,
                            'docs',
                               '
          SELECT row_number() over (order by decode(app_tp, ''Z'', 1, 2), t.app_ln) AS nd,
                 tp.ndt_name_short || '' ('' || t.app_ln || '' '' || substr(t.app_fn, 1, 1) || ''. '' || substr(t.app_mn, 1, 1) || ''.) '' as document
            FROM uss_visit.v_ap_person t
            join uss_visit.v_ap_document d on (d.apd_app = t.app_id)
            join uss_ndi.v_ndi_document_type tp on (tp.ndt_id = d.apd_ndt)
           WHERE t.app_ap = '
                            || p_ap_id
                            || '
             AND d.history_status = ''A''
             AND t.history_status = ''A''
          ');

                        rdm$rtfl.AddDataSet (
                            p_jbr_id,
                            'ds',
                               '
          with dat as (select regexp_substr(text ,''[^(\,)]+'', 1, level)  as wrn_id
                       from (select '''
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8642)
                            || ''' as text from dual)
                    connect by length(regexp_substr(text ,''[^(\,)]+'', 1, level)) > 0),
              dat2 as (select regexp_substr(text ,''[^(\,)]+'', 1, level)  as scdr_id
                         from (select '''
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10344,
                                                         8735)
                            || ''' as text from dual)
                      connect by length(regexp_substr(text ,''[^(\,)]+'', 1, level)) > 0)
          SELECT w.wrn_shifr as dzr_shifr,
                 w.wrn_name as dzr_name
            FROM uss_ndi.v_ndi_cbi_wares w
            join dat d on (d.wrn_id = w.wrn_id)
           union all
           SELECT t.wrn_shifr as dzr_shifr,
                  t.wrn_name as dzr_name
             FROM table(uss_person.API$SC_TOOLS.get_sc_dzr_recomm('
                            || NVL (xx.app_sc, -1)
                            || ')) t
             join dat2 d on (d.scdr_id = t.scdr_id)
          ');
                    END LOOP;
                -- #114836
                ELSIF (is_service_reg (p_ap_id, 1141) > 0)
                THEN
                    FOR xx
                        IN (SELECT t.*,
                                   TO_CHAR (
                                       api$appeal.Get_Attr_Val_Dt (
                                           p_apd_id      => d.apd_id,
                                           p_nda_class   => 'BDT'),
                                       'DD.MM.YYYY')    AS bdt
                              FROM ap_person  t
                                   JOIN appeal ap ON (ap.ap_id = t.app_ap)
                                   LEFT JOIN
                                   (SELECT *
                                      FROM ap_document  z
                                           JOIN
                                           uss_ndi.v_ndi_document_type zt
                                               ON (zt.ndt_id = z.apd_ndt)
                                     WHERE     z.apd_ap = p_ap_id
                                           AND zt.ndt_ndc = 13) d
                                       ON (d.apd_app = t.app_id)
                             WHERE     t.app_ap = p_ap_id
                                   AND t.app_tp IN ('Z')
                                   AND t.history_status = 'A')
                    LOOP
                        --ініціалізація завдання на підготовку звіту
                        p_jbr_id :=
                            rdm$rtfl.initreport (
                                get_rt_by_code ('PRINT_APPL_FORM_R4'));

                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'pib',
                               xx.app_ln
                            || ' '
                            || xx.app_fn
                            || ' '
                            || xx.app_mn
                            || ', '
                            || xx.bdt);
                        RDM$RTFL.AddParam (p_jbr_id,
                                           'rnokpp',
                                           NVL (xx.app_inn, xx.app_doc_num));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'eddr',
                            get_ap_document_attr_str (p_ap_id,
                                                      xx.app_id,
                                                      7,
                                                      810));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'phone',
                            get_ap_document_attr_str (p_ap_id,
                                                      xx.app_id,
                                                      10305,
                                                      8335));
                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'email',
                            get_ap_document_attr_str (p_ap_id,
                                                      xx.app_id,
                                                      10305,
                                                      8336));

                        RDM$RTFL.AddParam (
                            p_jbr_id,
                            'addr',
                               get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10305,
                                                         8405)
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10305,
                                                         8409)
                            || ', '
                            || NVL (get_ap_document_attr_str (p_ap_id,
                                                              xx.app_id,
                                                              10305,
                                                              8403),
                                    get_ap_document_attr_str (p_ap_id,
                                                              xx.app_id,
                                                              10305,
                                                              8411))
                            || ', '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10305,
                                                         8402)
                            || ', кор. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10305,
                                                         8401)
                            || ', кв. '
                            || get_ap_document_attr_str (p_ap_id,
                                                         xx.app_id,
                                                         10305,
                                                         8400));


                        rdm$rtfl.AddDataSet (
                            p_jbr_id,
                            'ds',
                               q'[
          with dat as (select regexp_substr(text ,'[^(\,)]+', 1, level) as nbc_id
                        from (SELECT MAX(t.apda_val_string) as text
                                FROM uss_visit.v_ap_person p
                                join uss_visit.v_ap_document d on (d.apd_app = p.app_id)
                                join uss_visit.v_ap_document_attr t on (t.apda_apd = d.apd_id)
                               where p.app_ap = ]'
                            || p_ap_id
                            || q'[
                                 and p.history_status = 'A'
                                 and p.app_tp = 'Z'
                                 and d.history_status = 'A'
                                 and t.history_status = 'A'
                                 and t.apda_nda = 8333)
                     connect by length(regexp_substr(text ,'[^(\,)]+', 1, level)) > 0)
          SELECT c.nbc_name as c1,
                 dt.ndt_name || ', ' || uss_visit.dnet$appeals_reports.get_ap_document_attr_str(d.apd_ap, d.apd_app, dt.ndt_id, 'DSN')  as c2,
                 uss_visit.dnet$appeals_reports.get_ap_document_attr_str(d.apd_ap, d.apd_app, dt.ndt_id, 'DORG') as c3,
                 to_char(uss_visit.dnet$appeals_reports.get_ap_document_attr_dt(d.apd_ap, d.apd_app, dt.ndt_id, 'DGVDT'), 'DD.MM.YYYY') as c4,
                 null as c5
            FROM dat t
            join uss_ndi.v_ndi_benefit_category c on (c.nbc_id = t.nbc_id)
            join uss_ndi.v_ndi_nbc_ndt_setup s on (s.nbts_nbc = c.nbc_id)
            join uss_ndi.v_ndi_document_type dt on (dt.ndt_id = s.nbts_ndt)
            join uss_visit.v_ap_document d on (d.apd_ndt = dt.ndt_id)
           where apd_ap = ]'
                            || p_ap_id);

                        rdm$rtfl.AddDataSet (
                            p_jbr_id,
                            'ds2',
                               q'[
            SELECT p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn as c1,
                   (SELECT max(dic_name)
                      FROM uss_ndi.V_DDN_RELATION_TP t
                     where dic_value = uss_visit.dnet$appeals_reports.get_ap_document_attr_str(d.apd_ap, d.apd_app, 605, 649)
                   ) as c2,
                   to_char( uss_visit.api$appeal.Get_Attr_Val_Dt(p_apd_id => d.apd_id, p_nda_class => 'BDT'), 'DD.MM.YYYY') AS c3,
                   nvl(p.app_inn, p.app_doc_num) as c4,
                   uss_visit.dnet$appeals_reports.get_ap_document_attr_str(p.app_ap, p.app_id, 7, 810) as c5
              FROM uss_visit.v_ap_person p
              LEFT JOIN (SELECT *
                           FROM uss_visit.v_ap_document z
                           JOIN uss_ndi.v_ndi_document_type zt ON (zt.ndt_id = z.apd_ndt)
                          WHERE z.apd_ap = ]'
                            || p_ap_id
                            || q'[
                            AND zt.ndt_ndc = 13) d ON (d.apd_app = p.app_id)
             where p.app_ap = ]'
                            || p_ap_id
                            || q'[
               and p.app_tp = 'FM'
          ]');
                    END LOOP;
                ELSIF v_appeal_exist = 0
                THEN
                    raise_application_error (
                        -20000,
                        'Для друку заяви, необхідно заповнити реквізити заяви в блоці "Документи"');
                ELSE
                    --ініціалізація завдання на підготовку звіту
                    p_jbr_id :=
                        rdm$rtfl.initreport (
                            get_rt_by_code ('PRINT_APPL_FORM_R1'));

                    --ініціалізація основних параметрів звіту
                    FOR ap_cur
                        IN (SELECT COALESCE (a.com_org,
                                             tools.getcurrorg)
                                       AS org_id,
                                   COALESCE (
                                       prst.pers_name,
                                       '_________________________________________________\par________________________________________________')
                                       AS pers_name,
                                   COALESCE (
                                       prst.pers_reg_addr,
                                       '_______________________________________\par________________________________________________')
                                       AS pers_reg_addr,
                                   COALESCE (
                                       prst.pers_fact_addr,
                                       '_________________________________________________\par_________________________________________________')
                                       AS pers_fact_addr,
                                   NVL (prst.pers_phone_num, '_____________')
                                       AS pers_phone_num,
                                   COALESCE (
                                       prst.pers_doc_name,
                                       '________________________________________________')
                                       AS pers_doc_name,
                                   COALESCE (prst.pers_pasp_num,
                                             '_________________')
                                       AS pers_pasp_num,
                                   prst.pers_pasp_info,
                                   prst.pers_pasp_date,
                                   COALESCE (
                                       prst.pers_inn_info,
                                       '___________________________________________________\par___________________________________________________')
                                       AS pers_inn_info,
                                   prst.pers_pasp_eddr,
                                   prst.pers_brth_date,
                                   a.ap_is_second,
                                   COALESCE (a.ap_num, '__________')
                                       AS appeal_num,
                                   a.ap_reg_dt,
                                   prst.was_married,
                                   prst.not_married,
                                   prst.married,
                                   prst.live_with_flg,
                                   prst.receive_pens_flg,
                                   COALESCE (pd.apm_tp, pd1.apm_tp)
                                       AS apm_tp,
                                   COALESCE (pd.apm_account, pd1.apm_account)
                                       AS apm_account,
                                   COALESCE (pd.apm_index, pd1.apm_index)
                                       AS apm_index,
                                   COALESCE (pd.nb_mfo, pd1.nb_mfo)
                                       AS nb_mfo,
                                   COALESCE (pd.nb_edrpou, pd1.nb_edrpou)
                                       AS nb_edrpou,
                                   COALESCE (pd.nb_name, pd1.nb_name)
                                       AS nb_name,
                                   --get_add_docs_term(p_ap_id) AS add_docs_term, --#70845 термін подачі необхідних документів (РОЗПИСКА)/#80311 - для nst_id = 248 - 3 місяці
                                    (SELECT COUNT (1)
                                       FROM uss_visit.v_ap_service
                                      WHERE     aps_ap = p_ap_id
                                            AND aps_nst = 267
                                            AND history_status = 'A')
                                       AS aps_267
                              FROM v_appeal  a
                                   LEFT JOIN
                                   (SELECT MAX (prs.pers_name)
                                               AS pers_name,
                                           COALESCE (
                                               (   MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    1
                                                                AND n.nda_pt =
                                                                    145
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    1
                                                                AND n.nda_pt =
                                                                    143
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'обл. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    1
                                                                AND n.nda_pt =
                                                                    144
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'р-он. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || (CASE
                                                        WHEN MAX (
                                                                 CASE
                                                                     WHEN     d.apd_ndt =
                                                                              600
                                                                          AND n.nda_nng =
                                                                              1
                                                                          AND n.nda_pt =
                                                                              140
                                                                     THEN
                                                                         COALESCE (
                                                                             (SELECT k.kaot_full_name
                                                                                FROM uss_ndi.v_ndi_katottg
                                                                                         k
                                                                               WHERE k.kaot_id =
                                                                                     a.apda_val_id),
                                                                             TRIM (
                                                                                 a.apda_val_string))
                                                                 END)
                                                                 IS NOT NULL
                                                        THEN
                                                               MAX (
                                                                   CASE
                                                                       WHEN     d.apd_ndt =
                                                                                600
                                                                            AND n.nda_nng =
                                                                                1
                                                                            AND n.nda_pt =
                                                                                140
                                                                       THEN
                                                                           COALESCE (
                                                                               (SELECT k.kaot_full_name
                                                                                  FROM uss_ndi.v_ndi_katottg
                                                                                           k
                                                                                 WHERE k.kaot_id =
                                                                                       a.apda_val_id),
                                                                               TRIM (
                                                                                   a.apda_val_string))
                                                                   END)
                                                            || ', ' --#74860  2022.01.24
                                                    END)
                                                || COALESCE (
                                                       MAX (
                                                           CASE
                                                               WHEN     d.apd_ndt =
                                                                        600
                                                                    AND n.nda_nng =
                                                                        1
                                                                    AND n.nda_pt =
                                                                        147
                                                                    AND a.apda_val_id
                                                                            IS NOT NULL
                                                               THEN
                                                                   LTRIM (
                                                                          get_street_info (
                                                                              a.apda_val_id)
                                                                       || ', ',
                                                                       ', ')
                                                           END),
                                                       MAX (
                                                           CASE
                                                               WHEN     d.apd_ndt =
                                                                        600
                                                                    AND n.nda_nng =
                                                                        1
                                                                    AND n.nda_pt =
                                                                        147
                                                                    AND TRIM (
                                                                            a.apda_val_string)
                                                                            IS NOT NULL
                                                               THEN
                                                                      'вул. '
                                                                   || TRIM (
                                                                          a.apda_val_string)
                                                                   || ', '
                                                           END),
                                                       MAX (
                                                           CASE
                                                               WHEN     d.apd_ndt =
                                                                        600
                                                                    AND n.nda_nng =
                                                                        1
                                                                    AND n.nda_pt =
                                                                        180
                                                                    AND TRIM (
                                                                            a.apda_val_string)
                                                                            IS NOT NULL
                                                               THEN
                                                                      'вул. '
                                                                   || TRIM (
                                                                          a.apda_val_string)
                                                                   || ', '
                                                           END))
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    1
                                                                AND n.nda_pt =
                                                                    148
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'буд. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    1
                                                                AND n.nda_pt =
                                                                    149
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'корп. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    1
                                                                AND n.nda_pt =
                                                                    150
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'кв. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                       END)),
                                               MAX (
                                                   CASE
                                                       WHEN     d.apd_ndt =
                                                                600
                                                            AND n.nda_nng = 1
                                                            AND n.nda_id =
                                                                581
                                                            AND n.nda_pt =
                                                                151
                                                       THEN
                                                           TRIM (
                                                               a.apda_val_string)
                                                   END))
                                               AS pers_reg_addr,
                                           COALESCE (
                                               (   MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    2
                                                                AND n.nda_pt =
                                                                    145
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    2
                                                                AND n.nda_pt =
                                                                    143
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'обл. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    2
                                                                AND n.nda_pt =
                                                                    144
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'р-он. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || (CASE
                                                        WHEN MAX (
                                                                 CASE
                                                                     WHEN     d.apd_ndt =
                                                                              600
                                                                          AND n.nda_nng =
                                                                              2
                                                                          AND n.nda_pt =
                                                                              140
                                                                     THEN
                                                                         COALESCE (
                                                                             (SELECT k.kaot_full_name
                                                                                FROM uss_ndi.v_ndi_katottg
                                                                                         k
                                                                               WHERE k.kaot_id =
                                                                                     a.apda_val_id),
                                                                             TRIM (
                                                                                 a.apda_val_string))
                                                                 END)
                                                                 IS NOT NULL
                                                        THEN
                                                               MAX (
                                                                   CASE
                                                                       WHEN     d.apd_ndt =
                                                                                600
                                                                            AND n.nda_nng =
                                                                                2
                                                                            AND n.nda_pt =
                                                                                140
                                                                       THEN
                                                                           COALESCE (
                                                                               (SELECT k.kaot_full_name
                                                                                  FROM uss_ndi.v_ndi_katottg
                                                                                           k
                                                                                 WHERE k.kaot_id =
                                                                                       a.apda_val_id),
                                                                               TRIM (
                                                                                   a.apda_val_string))
                                                                   END)
                                                            || ', ' --#74860  2022.01.24
                                                    END)
                                                || COALESCE (
                                                       MAX (
                                                           CASE
                                                               WHEN     d.apd_ndt =
                                                                        600
                                                                    AND n.nda_nng =
                                                                        2
                                                                    AND n.nda_pt =
                                                                        147
                                                                    AND a.apda_val_id
                                                                            IS NOT NULL
                                                               THEN
                                                                   LTRIM (
                                                                          get_street_info (
                                                                              a.apda_val_id)
                                                                       || ', ',
                                                                       ', ')
                                                           END),
                                                       MAX (
                                                           CASE
                                                               WHEN     d.apd_ndt =
                                                                        600
                                                                    AND n.nda_nng =
                                                                        2
                                                                    AND n.nda_pt =
                                                                        147
                                                                    AND TRIM (
                                                                            a.apda_val_string)
                                                                            IS NOT NULL
                                                               THEN
                                                                      'вул. '
                                                                   || TRIM (
                                                                          a.apda_val_string)
                                                                   || ', '
                                                           END),
                                                       MAX (
                                                           CASE
                                                               WHEN     d.apd_ndt =
                                                                        600
                                                                    AND n.nda_nng =
                                                                        2
                                                                    AND n.nda_pt =
                                                                        180
                                                                    AND TRIM (
                                                                            a.apda_val_string)
                                                                            IS NOT NULL
                                                               THEN
                                                                      'вул. '
                                                                   || TRIM (
                                                                          a.apda_val_string)
                                                                   || ', '
                                                           END))
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    2
                                                                AND n.nda_pt =
                                                                    148
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'буд. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    2
                                                                AND n.nda_pt =
                                                                    149
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'корп. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     d.apd_ndt =
                                                                    600
                                                                AND n.nda_nng =
                                                                    2
                                                                AND n.nda_pt =
                                                                    150
                                                                AND TRIM (
                                                                        a.apda_val_string)
                                                                        IS NOT NULL
                                                           THEN
                                                                  'кв. '
                                                               || TRIM (
                                                                      a.apda_val_string)
                                                       END)),
                                               MAX (
                                                   CASE
                                                       WHEN     d.apd_ndt =
                                                                600
                                                            AND n.nda_nng = 2
                                                            AND n.nda_id =
                                                                593
                                                            AND n.nda_pt =
                                                                151
                                                       THEN
                                                           TRIM (
                                                               a.apda_val_string)
                                                   END))
                                               AS pers_fact_addr,
                                           MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 600
                                                        AND n.nda_nng = 3
                                                        AND n.nda_pt = 153
                                                   THEN
                                                       a.apda_val_string
                                               END)
                                               AS pers_phone_num,
                                           MAX (prs.app_doc_name)
                                               AS pers_doc_name,
                                           MAX (prs.app_doc_num)
                                               AS pers_pasp_num,
                                           MAX (prs.app_doc_issued)
                                               AS pers_pasp_info,
                                           MAX (prs.app_doc_eddr)
                                               AS pers_pasp_eddr,
                                           MAX (prs.app_doc_dt)
                                               AS pers_pasp_date,
                                           MAX (prs.app_inn)
                                               AS pers_inn_info,
                                           MAX (prs.app_birth_dt)
                                               AS pers_brth_date,
                                           MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 600
                                                        AND n.nda_nng = 4
                                                        AND n.nda_id = 669
                                                   THEN
                                                       a.apda_val_string
                                               END)
                                               AS was_married,
                                           MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 600
                                                        AND n.nda_nng = 4
                                                        AND n.nda_id = 670
                                                   THEN
                                                       a.apda_val_string
                                               END)
                                               AS not_married,
                                           MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 600
                                                        AND n.nda_nng = 4
                                                        AND n.nda_id = 671
                                                   THEN
                                                       a.apda_val_string
                                               END)
                                               AS married,
                                           MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 600
                                                        AND n.nda_nng = 4
                                                        AND n.nda_id = 672
                                                   THEN
                                                       a.apda_val_string
                                               END)
                                               AS live_with_flg,
                                           MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 600
                                                        AND n.nda_nng = 4
                                                        AND n.nda_id = 673
                                                   THEN
                                                       a.apda_val_string
                                               END)
                                               AS receive_pens_flg,
                                           MAX (prs.app_id)
                                               AS app_id
                                      FROM (SELECT app_id,
                                                   (CASE
                                                        WHEN app_cnt > 1
                                                        THEN
                                                               '"'
                                                            || pers_name
                                                            || '" та ще '
                                                            || TO_CHAR (
                                                                     app_cnt
                                                                   - 1)
                                                        ELSE
                                                            pers_name
                                                    END)
                                                       AS pers_name,
                                                   app_apd,
                                                   apd_ndt,
                                                   app_doc_name,
                                                   api$appeal.get_attr_val_string (
                                                       p_apd_id      => app_apd,
                                                       p_nda_class   => 'DSN')
                                                       AS app_doc_num,
                                                   api$appeal.get_attr_val_string (
                                                       p_apd_id      => app_apd,
                                                       p_nda_class   => 'DORG')
                                                       AS app_doc_issued,
                                                   api$appeal.get_attr_val_dt (
                                                       p_apd_id   => app_apd,
                                                       p_nda_class   =>
                                                           'DGVDT')
                                                       AS app_doc_dt,
                                                   api$appeal.get_attr_val_dt (
                                                       p_apd_id      => app_apd,
                                                       p_nda_class   => 'BDT')
                                                       AS app_birth_dt,
                                                   (CASE apd_ndt
                                                        WHEN 7
                                                        THEN
                                                            api$appeal.get_attr_val_string (
                                                                p_apd_id   =>
                                                                    app_apd,
                                                                p_nda_id   =>
                                                                    810)
                                                    END)
                                                       AS app_doc_eddr,
                                                   (SELECT a1.apda_val_string
                                                      FROM v_ap_document  d5
                                                           JOIN
                                                           v_ap_document_attr
                                                           a1
                                                               ON     a1.apda_apd =
                                                                      d5.apd_id
                                                                  AND a1.apda_ap =
                                                                      p_ap_id
                                                                  AND a1.apda_nda =
                                                                      1
                                                                  AND a1.history_status =
                                                                      'A'
                                                     WHERE     d5.apd_ap =
                                                               p_ap_id
                                                           AND d5.apd_app =
                                                               app_id
                                                           AND d5.apd_ndt = 5
                                                           AND d5.history_status =
                                                               'A')
                                                       AS app_inn
                                              FROM (SELECT p.app_id,
                                                           tools.init_cap (
                                                                  p.app_ln
                                                               || ' '
                                                               || p.app_fn
                                                               || ' '
                                                               || p.app_mn)
                                                               AS pers_name,
                                                           COUNT (*) OVER ()
                                                               AS app_cnt,
                                                           FIRST_VALUE (
                                                               p.app_id)
                                                               OVER (
                                                                   ORDER BY
                                                                       p.app_ln)
                                                               AS frst_app,
                                                           dd.apd_id
                                                               AS app_apd,
                                                           dd.apd_ndt,
                                                           dt.ndt_name
                                                               AS app_doc_name,
                                                           ROW_NUMBER ()
                                                               OVER (
                                                                   ORDER BY
                                                                       dt.ndt_sc_srch_priority NULLS LAST)
                                                               AS apd_rn
                                                      FROM v_ap_person  p
                                                           LEFT JOIN
                                                           v_ap_document dd
                                                           JOIN
                                                           uss_ndi.v_ndi_document_type
                                                           dt
                                                               ON     dt.ndt_id =
                                                                      dd.apd_ndt
                                                                  AND dt.ndt_ndc =
                                                                      13
                                                               ON     dd.apd_app =
                                                                      p.app_id
                                                                  AND dd.apd_ap =
                                                                      p_ap_id
                                                                  AND dd.apd_ndt IN
                                                                          (6,
                                                                           7,
                                                                           8,
                                                                           9,
                                                                           13)
                                                                  AND dd.history_status =
                                                                      'A'
                                                     WHERE     p.app_ap =
                                                               p_ap_id
                                                           AND p.app_tp IN
                                                                   ('Z',
                                                                    'ANF')
                                                           AND p.history_status =
                                                               'A')
                                             WHERE     app_id = frst_app
                                                   AND apd_rn = 1) prs
                                           LEFT JOIN v_ap_document d
                                           JOIN v_ap_document_attr a
                                               ON     a.apda_apd = d.apd_id
                                                  AND a.apda_ap = p_ap_id
                                                  AND a.history_status = 'A'
                                           JOIN uss_ndi.v_ndi_document_attr n
                                               ON n.nda_id = a.apda_nda
                                               ON     d.apd_app = prs.app_id
                                                  AND d.apd_ap = p_ap_id
                                                  AND d.apd_ndt = 600
                                                  AND d.history_status = 'A')
                                   prst
                                       ON 1 = 1
                                   LEFT JOIN
                                   (SELECT p.apm_id,
                                           p.apm_app,
                                           p.apm_tp,
                                           p.apm_account,
                                           p.apm_index,
                                           b.nb_mfo,
                                           b.nb_edrpou,
                                           b.nb_name,
                                           FIRST_VALUE (p.apm_id)
                                               OVER (PARTITION BY p.apm_app
                                                     ORDER BY p.apm_id DESC)    AS act_apm_id
                                      FROM v_ap_payment  p
                                           LEFT JOIN uss_ndi.v_ndi_bank b
                                               ON b.nb_id = p.apm_nb
                                     WHERE     p.apm_ap = p_ap_id
                                           AND p.history_status = 'A'
                                           AND p.apm_app IS NOT NULL) pd
                                       ON     pd.apm_app = prst.app_id
                                          AND pd.apm_id = pd.act_apm_id
                                   LEFT JOIN
                                   (SELECT p.apm_id,
                                           p.apm_app,
                                           p.apm_tp,
                                           p.apm_account,
                                           p.apm_index,
                                           b.nb_mfo,
                                           b.nb_edrpou,
                                           b.nb_name,
                                           FIRST_VALUE (p.apm_id)
                                               OVER (PARTITION BY p.apm_app
                                                     ORDER BY p.apm_id DESC)    AS act_apm_id
                                      FROM v_ap_payment  p
                                           LEFT JOIN uss_ndi.v_ndi_bank b
                                               ON b.nb_id = p.apm_nb
                                     WHERE     p.apm_ap = p_ap_id
                                           AND p.history_status = 'A'
                                           AND p.apm_app IS NULL) pd1
                                       ON     pd1.apm_id = pd1.act_apm_id
                                          AND pd.apm_id IS NULL
                             WHERE a.ap_id = p_ap_id AND ROWNUM < 2)
                    LOOP
                        --назва організації, #75900 по низькорівневим організаціям необхідно відображати батьківську організацію
                        IF ap_cur.org_id IS NOT NULL
                        THEN
                            SELECT MAX (org_name)
                              INTO v_org_name
                              FROM (    SELECT o.org_id,
                                               o.org_name,
                                               MAX (
                                                   CASE
                                                       WHEN o.org_id =
                                                            ap_cur.org_id
                                                       THEN
                                                           o.org_to
                                                   END)
                                                   OVER ()    AS org_to,
                                               MAX (
                                                   CASE
                                                       WHEN o.org_id > 0
                                                       THEN
                                                           LEVEL
                                                   END)
                                                   OVER ()    AS lvl_cnt,
                                               LEVEL          AS lvl
                                          FROM v_opfu o
                                         WHERE o.org_st = 'A'
                                    START WITH o.org_id = ap_cur.org_id
                                    CONNECT BY PRIOR o.org_org = o.org_id)
                             WHERE lvl =
                                   (CASE
                                        WHEN lvl_cnt > 3 OR org_to > 32
                                        THEN
                                            2
                                        ELSE
                                            1
                                    END);
                        END IF;

                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'org_name',
                            COALESCE (
                                v_org_name,
                                '______________________________________________________________________________________________'));
                        rdm$rtfl.addparam (p_jbr_id,
                                           'pers_name',
                                           ap_cur.pers_name);
                        rdm$rtfl.addparam (p_jbr_id,
                                           'pers_reg_addr',
                                           ap_cur.pers_reg_addr);
                        rdm$rtfl.addparam (p_jbr_id,
                                           'pers_fact_addr',
                                           ap_cur.pers_fact_addr);
                        rdm$rtfl.addparam (p_jbr_id,
                                           'pers_phone_num',
                                           ap_cur.pers_phone_num);
                        rdm$rtfl.addparam (p_jbr_id,
                                           'pers_doc_name',
                                           ap_cur.pers_doc_name);
                        rdm$rtfl.addparam (p_jbr_id,
                                           'pers_pasp_num',
                                           ap_cur.pers_pasp_num);
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'pers_pasp_info',
                            COALESCE (
                                RTRIM (
                                    LTRIM (
                                           ap_cur.pers_pasp_info
                                        || ', '
                                        || (CASE
                                                WHEN ap_cur.pers_pasp_date
                                                         IS NOT NULL
                                                THEN
                                                       TO_CHAR (
                                                           ap_cur.pers_pasp_date,
                                                           'DD')
                                                    || ' '
                                                    || get_month_name (
                                                           ap_cur.pers_pasp_date)
                                                    || ' '
                                                    || TO_CHAR (
                                                           ap_cur.pers_pasp_date,
                                                           'YYYY')
                                            END),
                                        ', '),
                                    ', '),
                                '___________________________________________________\par___________________________________________________'));
                        rdm$rtfl.addparam (p_jbr_id,
                                           'pers_inn_info',
                                           ap_cur.pers_inn_info);
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'pers_pasp_eddr',
                            COALESCE (ap_cur.pers_pasp_eddr, '__________'));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'pers_brth_dt',
                            COALESCE (
                                (CASE
                                     WHEN ap_cur.pers_brth_date IS NOT NULL
                                     THEN
                                            TO_CHAR (ap_cur.pers_brth_date,
                                                     'DD')
                                         || ' '
                                         || get_month_name (
                                                ap_cur.pers_brth_date)
                                         || ' '
                                         || TO_CHAR (ap_cur.pers_brth_date,
                                                     'YYYY')
                                 END),
                                '___________________________________________________'));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'frst_appeal',
                            (CASE ap_cur.ap_is_second
                                 WHEN 'T' THEN ''
                                 ELSE v_check_mark
                             END));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'not_frst_appeal',
                            (CASE ap_cur.ap_is_second
                                 WHEN 'T' THEN v_check_mark
                                 ELSE ''
                             END));
                        rdm$rtfl.addparam (p_jbr_id,
                                           'appeal_num',
                                           ap_cur.appeal_num);
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'appeal_date',
                            COALESCE (
                                TO_CHAR (ap_cur.ap_reg_dt, 'DD.MM.YYYY'),
                                '____________'));
                        --#75875 підкреслювати тільки при допомозі одиноким матерям
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'was_married',
                               (CASE
                                    WHEN     ap_cur.aps_267 = 1
                                         AND ap_cur.was_married = 'T'
                                    THEN
                                        '\ulw '
                                END)
                            || 'Перебувала');
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'not_married',
                               (CASE
                                    WHEN     ap_cur.aps_267 = 1
                                         AND ap_cur.not_married = 'T'
                                    THEN
                                        '\ulw '
                                END)
                            || 'Не перебувала');
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'married',
                               (CASE
                                    WHEN     ap_cur.aps_267 = 1
                                         AND ap_cur.married = 'T'
                                    THEN
                                        '\ulw '
                                END)
                            || 'Перебуваю');
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'live_with',
                               (CASE
                                    WHEN     ap_cur.aps_267 = 1
                                         AND ap_cur.live_with_flg = 'T'
                                    THEN
                                        '\ulw '
                                END)
                            || 'Проживаю');
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'not_live_with',
                               (CASE
                                    WHEN    ap_cur.aps_267 = 0
                                         OR (    ap_cur.aps_267 = 1
                                             AND ap_cur.live_with_flg = 'T')
                                    THEN
                                        ''
                                    ELSE
                                        '\ulw '
                                END)
                            || 'Не проживаю');
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'receive_pens',
                               (CASE
                                    WHEN     ap_cur.aps_267 = 1
                                         AND ap_cur.receive_pens_flg = 'T'
                                    THEN
                                        '\ulw '
                                END)
                            || 'Отримую');
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'not_receive_pens',
                               (CASE
                                    WHEN    ap_cur.aps_267 = 0
                                         OR (    ap_cur.aps_267 = 1
                                             AND ap_cur.receive_pens_flg =
                                                 'T')
                                    THEN
                                        ''
                                    ELSE
                                        '\ulw '
                                END)
                            || 'Не отримую');
                        --#75875 підкреслювати тільки при допомозі одиноким матерям
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'pay_by_post',
                            (CASE ap_cur.apm_tp
                                 WHEN 'POST' THEN v_check_mark
                             END));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'post_details',
                            COALESCE (
                                (CASE ap_cur.apm_tp
                                     WHEN 'POST' THEN ap_cur.apm_index
                                 END),
                                '__________________________________________'));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'pay_by_bank',
                            (CASE ap_cur.apm_tp
                                 WHEN 'BANK' THEN v_check_mark
                             END));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'bank_account',
                            COALESCE (
                                (CASE ap_cur.apm_tp
                                     WHEN 'BANK' THEN ap_cur.apm_account
                                 END),
                                '________________'));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'bank_mfo',
                            COALESCE (
                                (CASE ap_cur.apm_tp
                                     WHEN 'BANK' THEN ap_cur.nb_mfo
                                 END),
                                '___________________'));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'bank_code',
                            COALESCE (
                                (CASE ap_cur.apm_tp
                                     WHEN 'BANK' THEN ap_cur.nb_edrpou
                                 END),
                                '____________________'));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'bank_info',
                            COALESCE (
                                (CASE ap_cur.apm_tp
                                     WHEN 'BANK' THEN ap_cur.nb_name
                                 END),
                                '___________________________________________________________________________________________'));

                        EXECUTE IMMEDIATE 'select uss_visit.dnet$appeals_reports.get_add_docs_term(:1) from dual'
                            INTO l_term
                            USING p_ap_id;

                        --l_term := get_add_docs_term(p_ap_id);
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'dad_day',
                            COALESCE (
                                TO_CHAR (
                                    ADD_MONTHS (ap_cur.ap_reg_dt, l_term),
                                    'DD'),
                                '__'));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'dad_month',
                            COALESCE (
                                get_month_name (
                                    ADD_MONTHS (ap_cur.ap_reg_dt, l_term)),
                                '_______________'));
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            'dad_year',
                            COALESCE (
                                TO_CHAR (
                                    ADD_MONTHS (ap_cur.ap_reg_dt, l_term),
                                    'YYYY'),
                                '20___'));
                    END LOOP;

                    --#73132 - обов’язковість документа Uss_Visit.Dnet$appeals_Reports.Get_Doc_Is_Required(d.Apd_Ndt, d.Apd_Ap, d.Apd_App, p.App_Tp) AS Required не потрібно виводити
                    --Документи, що наявні у зверненні
                    rdm$rtfl.adddataset (p_jbr_id,
                                         'added_docs_list',
                                         REPLACE (q'[
  SELECT p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn AS Owner,
         t.Ndt_Name
    FROM Uss_Visit.v_Ap_Document d
    JOIN Uss_Ndi.v_Ndi_Document_Type t
      ON d.Apd_Ndt = t.Ndt_Id
    JOIN Uss_Visit.v_Ap_Person p
      ON d.Apd_App = p.App_Id
     AND p.History_Status = 'A'
   WHERE d.Apd_Ap = :p_Ap_Id
         AND d.History_Status = 'A'
         AND EXISTS (SELECT NULL
            FROM Uss_Doc.v_Doc_Attachments
           WHERE Dat_Dh = d.Apd_Dh)
   ORDER BY 1,
            2]', ':p_Ap_Id', p_ap_id));

                    --Документи яких не вистачає у зверненні
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'to_add_docs_list',
                        REPLACE (
                            q'[
    --Обов’язкові документи, яких не вистачає у зверненні
  SELECT p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn AS Owner,
       Nvl(t.Ndt_Name,
           --Вибираємо перший документ в рамках категорії
           (SELECT Tt.Ndt_Name
              FROM Uss_Ndi.v_Ndi_Document_Type Tt
             WHERE Tt.Ndt_Ndc = c.Nndc_Ndc
             ORDER BY tt.Ndt_Order
             FETCH FIRST ROW ONLY)) AS Ndt_Name
  FROM Uss_Ndi.v_Ndi_Nst_Doc_Config c
  LEFT JOIN Uss_Ndi.v_Ndi_Document_Type t
    ON c.Nndc_Ndt = t.Ndt_Id
  LEFT JOIN Uss_Visit.v_Ap_Person p
    ON (c.Nndc_App_Tp IS NOT NULL OR c.Nndc_Nda IS NOT NULL)
       AND p.App_Ap = :p_Ap_Id
       AND p.History_Status = 'A'
  LEFT JOIN Uss_Visit.v_Ap_Document d
    ON p.App_Id = d.Apd_App
       AND d.History_Status = 'A'
       AND ((c.Nndc_App_Tp IS NULL AND c.Nndc_Nda IS NULL) OR p.App_Id = d.Apd_App)
       AND (d.Apd_Ndt = c.Nndc_Ndt OR d.Apd_Ndt = c.Nndc_Ndt_Alt1 OR
       (c.Nndc_Ndc IS NOT NULL AND EXISTS (SELECT NULL
                                                  FROM Uss_Ndi.v_Ndi_Document_Type Dt
                                                 WHERE Dt.Ndt_Ndc = c.Nndc_Ndc
                                                       AND Dt.Ndt_Id = d.Apd_Ndt)))
 WHERE c.Nndc_Is_Req = 'T'
       AND c.History_Status = 'A'
       AND c.Nndc_Ndt NOT IN(600)
       AND (c.Nndc_App_Tp IS NULL OR c.Nndc_App_Tp = p.App_Tp)
       AND (EXISTS (SELECT NULL
                      FROM Uss_Visit.v_Ap_Service s
                     WHERE s.Aps_Ap = :p_Ap_Id
                           AND s.History_Status = 'A'
                           AND s.Aps_Nst = c.Nndc_Nst) OR c.Nndc_Nst IS NULL)
       AND (c.Nndc_Nda IS NULL OR EXISTS (SELECT NULL
                                            FROM Uss_Visit.v_Ap_Document f
                                            JOIN Uss_Visit.v_Ap_Document_Attr a
                                              ON f.Apd_Id = a.Apda_Apd
                                                 AND a.apda_ap = f.apd_ap
                                                 AND a.Apda_Nda = c.Nndc_Nda
                                                 AND a.Apda_Val_String = c.Nndc_Val_String
                                                 AND a.History_Status = 'A'
                                           WHERE f.Apd_App = p.App_Id
                                                 AND f.History_Status = 'A'))
       AND (d.Apd_Id IS NULL)
  UNION
  --Документи без вкладень
  SELECT p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn AS Owner,
         t.Ndt_Name
    FROM Uss_Visit.v_Ap_Document d
    JOIN Uss_Ndi.v_Ndi_Document_Type t
      ON d.Apd_Ndt = t.Ndt_Id
     AND t.NDT_IS_HAVE_SCAN = 'T'
    JOIN Uss_Visit.v_Ap_Person p
      ON d.Apd_App = p.App_Id
     AND p.History_Status = 'A'
   WHERE d.Apd_Ap = :p_Ap_Id
         AND d.Apd_Ndt NOT IN(600)
         AND d.History_Status = 'A'
         AND NOT EXISTS (SELECT NULL
            FROM Uss_Doc.v_Doc_Attachments Da
           WHERE Da.Dat_Dh = d.Apd_Dh)
     --#73198 перевірка наявності вкладення по альтернативному документі
     AND NOT EXISTS (SELECT 1
                       FROM uss_ndi.v_ndi_nst_doc_config c
                       JOIN uss_visit.v_ap_document ad ON ad.apd_ndt = c.nndc_ndt_alt1
                                                      AND ad.apd_ap = :p_Ap_Id
                                                      AND ad.apd_app = p.app_id
                       JOIN uss_doc.v_doc_attachments ada ON ada.dat_dh = ad.apd_dh
                      WHERE c.nndc_ndt = d.apd_ndt
                        AND c.nndc_is_req = 'T'
                        AND c.history_status = 'A'
                        AND (c.nndc_app_tp IS NULL OR c.nndc_app_tp = p.app_tp)
                        AND (EXISTS (SELECT 1
                                       FROM uss_visit.v_ap_service s
                                      WHERE s.aps_ap = :p_Ap_Id
                                        AND s.history_status = 'A'
                                        AND s.aps_nst = c.nndc_nst) OR c.nndc_nst IS NULL)
                        AND (c.nndc_nda IS NULL OR EXISTS (SELECT 1
                                                             FROM uss_visit.v_ap_document_attr a
                                                            WHERE a.apda_nda = c.nndc_nda
                                                              AND a.apda_val_string = c.nndc_val_string
                                                              AND a.history_status = 'A')))
   ORDER BY 1,
            2]',
                            ':p_Ap_Id',
                            p_ap_id));

                    --ініціалізація додаткових параметрів звіту (інформація по отриманій допомозі)/#73131 - додано: 248, 249
                    FOR serv_cur
                        IN (SELECT DISTINCT
                                   serv_tp_id,
                                   FIRST_VALUE (serv_st)
                                       OVER (PARTITION BY serv_tp_id
                                             ORDER BY serv_st NULLS LAST)    AS serv_st
                              FROM (SELECT nst_id     AS serv_tp_id,
                                           NULL       AS serv_st
                                      FROM uss_ndi.v_ndi_service_type
                                     WHERE nst_id IN (251,
                                                      269,
                                                      268,
                                                      267,
                                                      265,
                                                      247,
                                                      246,
                                                      245,
                                                      266,
                                                      244,
                                                      243,
                                                      242,
                                                      289,
                                                      264,
                                                      248,
                                                      249,
                                                      862,
                                                      275,
                                                      241,
                                                      250,
                                                      901)
                                    UNION ALL
                                    SELECT aps_nst     AS serv_tp_id,
                                           aps_st      AS serv_st
                                      FROM uss_visit.v_ap_service
                                     WHERE     aps_ap = p_ap_id
                                           AND aps_nst IN (251,
                                                           269,
                                                           268,
                                                           267,
                                                           265,
                                                           247,
                                                           246,
                                                           245,
                                                           266,
                                                           244,
                                                           243,
                                                           242,
                                                           289,
                                                           264,
                                                           248,
                                                           249,
                                                           862,
                                                           275,
                                                           241,
                                                           250,
                                                           901)
                                           AND history_status = 'A'))
                    LOOP
                        rdm$rtfl.addparam (
                            p_jbr_id,
                            's' || TO_CHAR (serv_cur.serv_tp_id),
                            (CASE
                                 WHEN serv_cur.serv_st IS NOT NULL
                                 THEN
                                     v_check_mark
                             END));
                    END LOOP;
                END IF;
            END IF;
        END IF;

        --позначення звіту як готового до формування підсумкового файлу із данними
        IF p_jbr_id IS NOT NULL
        THEN
            rdm$rtfl.putreporttoworkingqueue (p_jbr_id);
        END IF;

        COMMIT;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми заяви по ВПО (стара, форма до 01.08.23)
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #70457
    PROCEDURE reg_application_get_old (p_ap_id    IN     appeal.ap_id%TYPE,
                                       p_jbr_id      OUT DECIMAL)
    IS
    --v_appeal_exist NUMBER;
    --v_org_name     VARCHAR2(1000);
    BEGIN
        ROLLBACK;

        tools.writemsg ('DNET$APPEALS_REPORTS.' || $$PLSQL_UNIT);
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.REG_APPLICATION_GET',
            action_name   => 'p_ap_id=' || TO_CHAR (p_ap_id));


        --#78293 друкована форма заяви про допомогу на проживання ВПО
        FOR vpo_cur
            IN (SELECT (SELECT o.org_name
                          FROM v_opfu o
                         WHERE o.org_id = a.com_org)          AS org_name,
                       prst.pers_pib,
                       prst.pers_brth_date,
                       prst.pers_phone_num,
                       prst.is_dsblt_pers,
                       TRIM (
                           CASE prst.pers_rej_inn
                               WHEN 'T' THEN prst.pers_doc_num
                               ELSE prst.pers_inn
                           END)                               AS pers_ident,
                       prst.pers_reg_addr,
                       prst.pers_fact_addr,
                       (SELECT DISTINCT
                               FIRST_VALUE (p.apm_account)
                                   OVER (ORDER BY p.apm_id)
                          FROM v_ap_payment p
                         WHERE     p.apm_ap = p_ap_id
                               AND p.apm_app = prst.app_id
                               AND p.history_status = 'A')    AS bank_iban,
                       a.ap_reg_dt
                  FROM v_appeal  a
                       LEFT JOIN
                       (WITH
                            street
                            AS
                                (SELECT    (CASE
                                                WHEN nsrt_name IS NOT NULL
                                                THEN
                                                    nsrt_name || ' '
                                                ELSE
                                                    ''
                                            END)
                                        || ns_name    AS ns_name,
                                        ns_id
                                   FROM uss_ndi.v_ndi_street
                                        LEFT JOIN uss_ndi.v_ndi_street_type
                                            ON ns_nsrt = nsrt_id)
                        SELECT MAX (prs.pers_name)      AS pers_pib,
                               MAX (
                                   CASE
                                       WHEN     d.apd_ndt IN (6, 7)
                                            AND da.apda_nda IN (606, 607)
                                       THEN
                                           da.apda_val_dt
                                   END)                 AS pers_brth_date,
                               MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 10045
                                            AND da.apda_nda = 1804
                                       THEN
                                           TRIM (da.apda_val_string)
                                   END)                 AS pers_phone_num,
                               MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 605
                                            AND da.apda_nda = 1772
                                            AND da.apda_val_string
                                                    IS NOT NULL
                                       THEN
                                           (SELECT dic_sname
                                              FROM uss_ndi.v_ddn_boolean
                                             WHERE dic_value =
                                                   da.apda_val_string)
                                   END)                 AS is_dsblt_pers,
                               COALESCE (
                                   MAX (prs.app_inn),
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt = 5
                                                AND da.apda_nda = 1
                                           THEN
                                               TRIM (da.apda_val_string)
                                       END))            AS pers_inn,
                               MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 605
                                            AND da.apda_nda = 640
                                       THEN
                                           da.apda_val_string
                                   END)                 AS pers_rej_inn,
                               MAX (prs.app_doc_num)    AS pers_doc_num,
                               RTRIM (
                                   (   MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 605
                                                    AND nda.nda_nng = 59
                                                    AND nda.nda_pt = 145
                                                    AND TRIM (
                                                            da.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      TRIM (
                                                          da.apda_val_string)
                                                   || ', '
                                           END)
                                    || (LTRIM (
                                               MAX (
                                                   CASE
                                                       WHEN     d.apd_ndt =
                                                                605
                                                            AND nda.nda_nng =
                                                                59
                                                            AND nda.nda_pt =
                                                                140
                                                       THEN
                                                           COALESCE (
                                                               (SELECT k.kaot_full_name
                                                                  FROM uss_ndi.v_ndi_katottg
                                                                       k
                                                                 WHERE k.kaot_id =
                                                                       da.apda_val_id),
                                                               TRIM (
                                                                   da.apda_val_string))
                                                   END)
                                            || ', ',
                                            ', '))
                                    || COALESCE (
                                           LTRIM (
                                                  MAX (
                                                      CASE
                                                          WHEN     d.apd_ndt =
                                                                   605
                                                               AND nda.nda_nng =
                                                                   59
                                                               AND nda.nda_pt =
                                                                   147
                                                          THEN
                                                              COALESCE (
                                                                  (SELECT s.ns_name
                                                                     FROM street
                                                                          s
                                                                    WHERE s.ns_id =
                                                                          da.apda_val_id),
                                                                  TRIM (
                                                                      da.apda_val_string))
                                                      END)
                                               || ', ',
                                               ', '),
                                           MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 59
                                                        AND nda.nda_pt = 180
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          'вул. '
                                                       || TRIM (
                                                              da.apda_val_string)
                                                       || ', '
                                               END))
                                    || MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 605
                                                    AND nda.nda_nng = 59
                                                    AND nda.nda_pt = 148
                                                    AND TRIM (
                                                            da.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      'буд. '
                                                   || TRIM (
                                                          da.apda_val_string)
                                                   || ', '
                                           END)
                                    || MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 605
                                                    AND nda.nda_nng = 59
                                                    AND nda.nda_pt = 149
                                                    AND TRIM (
                                                            da.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      'корп. '
                                                   || TRIM (
                                                          da.apda_val_string)
                                                   || ', '
                                           END)
                                    || MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 605
                                                    AND nda.nda_nng = 59
                                                    AND nda.nda_pt = 150
                                                    AND TRIM (
                                                            da.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      'кв. '
                                                   || TRIM (
                                                          da.apda_val_string)
                                           END)),
                                   ', ')                AS pers_reg_addr,
                               RTRIM (
                                   (   MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 605
                                                    AND nda.nda_nng = 60
                                                    AND nda.nda_pt = 145
                                                    AND TRIM (
                                                            da.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      TRIM (
                                                          da.apda_val_string)
                                                   || ', '
                                           END)
                                    || (LTRIM (
                                               MAX (
                                                   CASE
                                                       WHEN     d.apd_ndt =
                                                                605
                                                            AND nda.nda_nng =
                                                                60
                                                            AND nda.nda_pt =
                                                                140
                                                       THEN
                                                           COALESCE (
                                                               (SELECT k.kaot_full_name
                                                                  FROM uss_ndi.v_ndi_katottg
                                                                       k
                                                                 WHERE k.kaot_id =
                                                                       da.apda_val_id),
                                                               TRIM (
                                                                   da.apda_val_string))
                                                   END)
                                            || ', ',
                                            ', '))
                                    || COALESCE (
                                           LTRIM (
                                                  MAX (
                                                      CASE
                                                          WHEN     d.apd_ndt =
                                                                   605
                                                               AND nda.nda_nng =
                                                                   60
                                                               AND nda.nda_pt =
                                                                   147
                                                          THEN
                                                              COALESCE (
                                                                  (SELECT s.ns_name
                                                                     FROM street
                                                                          s
                                                                    WHERE s.ns_id =
                                                                          da.apda_val_id),
                                                                  TRIM (
                                                                      da.apda_val_string))
                                                      END)
                                               || ', ',
                                               ', '),
                                           MAX (
                                               CASE
                                                   WHEN     d.apd_ndt = 605
                                                        AND nda.nda_nng = 60
                                                        AND nda.nda_pt = 180
                                                        AND TRIM (
                                                                da.apda_val_string)
                                                                IS NOT NULL
                                                   THEN
                                                          'вул. '
                                                       || TRIM (
                                                              da.apda_val_string)
                                                       || ', '
                                               END))
                                    || MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 605
                                                    AND nda.nda_nng = 60
                                                    AND nda.nda_pt = 148
                                                    AND TRIM (
                                                            da.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      'буд. '
                                                   || TRIM (
                                                          da.apda_val_string)
                                                   || ', '
                                           END)
                                    || MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 605
                                                    AND nda.nda_nng = 60
                                                    AND nda.nda_pt = 149
                                                    AND TRIM (
                                                            da.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      'корп. '
                                                   || TRIM (
                                                          da.apda_val_string)
                                                   || ', '
                                           END)
                                    || MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 605
                                                    AND nda.nda_nng = 60
                                                    AND nda.nda_pt = 150
                                                    AND TRIM (
                                                            da.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      'кв. '
                                                   || TRIM (
                                                          da.apda_val_string)
                                           END)),
                                   ', ')                AS pers_fact_addr,
                               MAX (prs.app_id)         AS app_id
                          FROM (SELECT app.app_id,
                                       app.pers_name,
                                       app.app_inn,
                                       app.app_doc_num
                                  FROM (SELECT p.app_id,
                                               tools.init_cap (
                                                      p.app_ln
                                                   || ' '
                                                   || p.app_fn
                                                   || ' '
                                                   || p.app_mn)
                                                   AS pers_name,
                                               p.app_inn,
                                               p.app_doc_num,
                                               FIRST_VALUE (p.app_id)
                                                   OVER (ORDER BY p.app_ln)
                                                   AS frst_app
                                          FROM v_ap_person p
                                         WHERE     p.app_ap = p_ap_id
                                               AND p.app_tp = 'Z'
                                               AND p.history_status = 'A')
                                       app
                                 WHERE app_id = frst_app) prs
                               LEFT JOIN v_ap_document d
                               JOIN v_ap_document_attr da
                                   ON     da.apda_apd = d.apd_id
                                      AND da.apda_ap = p_ap_id
                                      AND da.history_status = 'A'
                               JOIN uss_ndi.v_ndi_document_attr nda
                                   ON nda.nda_id = da.apda_nda
                                   ON     d.apd_app = prs.app_id
                                      AND d.apd_ap = p_ap_id
                                      AND d.apd_ndt IN (5,
                                                        6,
                                                        7,
                                                        605,
                                                        10045)
                                      AND d.history_status = 'A') prst
                           ON 1 = 1
                 WHERE     a.ap_id = p_ap_id
                       AND EXISTS
                               (SELECT 1
                                  FROM v_ap_service s
                                 WHERE     s.aps_ap = p_ap_id
                                       AND s.aps_nst = 664
                                       AND s.history_status = 'A')
                       AND ROWNUM < 2)
        LOOP
            --ініціалізація завдання на підготовку звіту
            p_jbr_id := rdm$rtfl.initreport (get_rt_by_code ('VPO_APPL_R1'));

            rdm$rtfl.addparam (
                p_jbr_id,
                'org_name',
                COALESCE (
                    vpo_cur.org_name,
                    '_____________________________\par__________________________________________________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'pers_pib',
                COALESCE (
                    vpo_cur.pers_pib,
                       '________________________________________________________________\par'
                    || '\fs20 (прізвище, власне ім’я, по батькові (за наявності) \fs24'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'pers_brth_dt',
                COALESCE (TO_CHAR (vpo_cur.pers_brth_date, 'DD.MM.YYYY'),
                          '__________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'pers_phone_num',
                COALESCE (vpo_cur.pers_phone_num, '________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'is_dsblt_pers',
                COALESCE (
                    vpo_cur.is_dsblt_pers,
                       '__________________\par'
                    || '\fs20                                                                                              (так/ні) \fs24'));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc1',
                               SUBSTR (vpo_cur.pers_ident, 1, 1));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc2',
                               SUBSTR (vpo_cur.pers_ident, 2, 1));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc3',
                               SUBSTR (vpo_cur.pers_ident, 3, 1));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc4',
                               SUBSTR (vpo_cur.pers_ident, 4, 1));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc5',
                               SUBSTR (vpo_cur.pers_ident, 5, 1));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc6',
                               SUBSTR (vpo_cur.pers_ident, 6, 1));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc7',
                               SUBSTR (vpo_cur.pers_ident, 7, 1));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc8',
                               SUBSTR (vpo_cur.pers_ident, 8, 1));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc9',
                               SUBSTR (vpo_cur.pers_ident, 9, 1));
            rdm$rtfl.addparam (p_jbr_id,
                               'pc10',
                               SUBSTR (vpo_cur.pers_ident, 10, 1));
            rdm$rtfl.addparam (
                p_jbr_id,
                'pers_reg_addr',
                COALESCE (
                    '\ul' || vpo_cur.pers_reg_addr || '\ul0',
                    '____________________\par________________________________________________________________________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'pers_fact_addr',
                COALESCE (
                    '\ul' || vpo_cur.pers_fact_addr || '\ul0',
                       '_______________________________________\par'
                    || '________________________________________________________________________________'));
            rdm$rtfl.addparam (p_jbr_id, 'bank_iban', vpo_cur.bank_iban);
            rdm$rtfl.addparam (
                p_jbr_id,
                'app_dt',
                COALESCE (TO_CHAR (vpo_cur.ap_reg_dt, 'DD.MM.YYYY'),
                          '____________\par' || '\fs20 (дата) \fs24'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'pers_pib',
                COALESCE (vpo_cur.pers_pib,
                          '_________________\par' || '\fs20 (ПІБ) \fs24'));

            rdm$rtfl.adddataset (
                p_jbr_id,
                'ds',
                   q'[SELECT p.app_id,
         MAX(uss_visit.tools.init_cap(p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn)) AS c1,
         to_char(MAX(CASE
                       WHEN d.apd_ndt IN (6, 7, 37) AND da.apda_nda IN (606, 607, 91) THEN
                        da.apda_val_dt
                     END),
                 'DD.MM.YYYY') AS c2,
         MAX(coalesce(p.app_doc_num,
                      (CASE
                        WHEN d.apd_ndt IN (6, 7, 37) AND da.apda_nda IN (3, 9, 90) THEN
                         TRIM(da.apda_val_string)
                      END))) AS c3
    FROM uss_visit.v_ap_person p
    JOIN uss_visit.v_ap_document d ON d.apd_app = p.app_id
                                  AND d.apd_ap = ]'
                || TO_CHAR (p_ap_id)
                || q'[
                                  AND d.apd_ndt IN (6, 7, 37, 605)
                                  AND d.history_status = 'A'
    JOIN uss_visit.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                        AND da.apda_ap = ]'
                || TO_CHAR (p_ap_id)
                || q'[
                                        AND da.history_status = 'A'
   WHERE p.app_ap = ]'
                || TO_CHAR (p_ap_id)
                || q'[
     AND p.app_tp = 'FP'
     AND p.history_status = 'A'
   GROUP BY p.app_id
   ORDER BY 2]');
        END LOOP;


        --позначення звіту як готового до формування підсумкового файлу із данними
        IF p_jbr_id IS NOT NULL
        THEN
            rdm$rtfl.putreporttoworkingqueue (p_jbr_id);
        END IF;

        COMMIT;
    END;

    -----------------------------------------------------------------
    --Ініціалізація процесу підготовки звіту "Декларація"
    -----------------------------------------------------------------
    PROCEDURE reg_declaration_get (p_ap_id    IN     appeal.ap_id%TYPE,
                                   p_jbr_id      OUT NUMBER)
    IS
        l_apr_id              NUMBER;
        l_apr_start_dt        DATE;
        l_apr_stop_dt         DATE;
        l_org_name            VARCHAR2 (1000);
        l_address             VARCHAR2 (32000);
        l_cnt                 NUMBER;
        l_spendings_det_sql   CLOB;
        l_total1              NUMBER;
        l_total2              NUMBER;
        v_aps_exist           NUMBER;
        v_app_pib             VARCHAR2 (4000);
        v_sql_str             VARCHAR2 (4000);
        v_dt                  DATE;
        v_org_id              NUMBER;
        v_ap_tp               appeal.ap_tp%TYPE;
        v_apd_801             ap_document.apd_id%TYPE;
    BEGIN
        ROLLBACK;
        tools.WriteMsg ('DNET$APPEALS_REPORTS.' || $$PLSQL_UNIT);
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.REG_DECLARATION_GET',
            action_name   => 'p_ap_id=' || TO_CHAR (p_ap_id));

        SELECT MAX (d.apr_id),
               MAX (d.apr_start_dt),
               MAX (d.apr_stop_dt),
               COALESCE (
                   (CASE WHEN MAX (ap.ap_tp) != 'SS' THEN MAX (d.com_org) END),
                   tools.getcurrorg),
               MAX (
                   CASE
                       WHEN ap.ap_tp != 'SS'
                       THEN
                           (SELECT COUNT (1)
                              FROM v_ap_service s
                             WHERE     s.aps_ap = p_ap_id
                                   AND s.aps_nst IN (249, 267)
                                   AND s.history_status = 'A')
                       ELSE
                           0
                   END), --#78461 формат друкованої форми заледжить від наявності послуг 249 і 267
               MAX (
                   (  SELECT p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn
                        FROM v_ap_person p
                       WHERE     p.app_ap = p_ap_id
                             AND p.app_tp = 'Z'
                             AND p.history_status = 'A'
                    ORDER BY p.app_id
                       FETCH FIRST 1 ROW ONLY)),                --ПІБ Заявника
               MAX (
                   CASE
                       WHEN ap.ap_tp != 'SS'
                       THEN
                           (SELECT LISTAGG (
                                       CASE
                                           WHEN a.apda_val_string IS NOT NULL
                                           THEN
                                                  CASE
                                                      WHEN apda_nda NOT IN
                                                               (604, 599)
                                                      THEN
                                                          LOWER (t.pt_name)
                                                  END
                                               || ' '
                                               || a.apda_val_string
                                       END,
                                       ', ')
                                   WITHIN GROUP (ORDER BY
                                                     DECODE (apda_nda,
                                                             599, 1,
                                                             604, 2,
                                                             3),
                                                     n.nda_order)
                              FROM v_ap_document_attr  a
                                   JOIN v_ap_document d
                                       ON     a.apda_apd = d.apd_id
                                          AND d.apd_ap = p_ap_id
                                          AND d.apd_ndt = 600          --Заява
                                          AND d.history_status = 'A'
                                   JOIN uss_ndi.v_ndi_document_attr n
                                       ON     a.apda_nda = n.nda_id
                                          AND n.nda_nng = 2 --Група атрибутів "Адреса проживання"
                                   JOIN uss_ndi.v_ndi_param_type t
                                       ON n.nda_pt = t.pt_id
                             WHERE     a.apda_ap = p_ap_id      --Ід звернення
                                   AND a.history_status = 'A'
                                   AND apda_nda NOT IN (2304))
                   END),                                   --адреса проживання
               MAX (ap.ap_tp),
               MAX (
                   CASE
                       WHEN ap.ap_tp = 'SS'
                       THEN
                           (SELECT MAX (d801.apd_id)
                              FROM v_ap_document  d801
                                   JOIN v_ap_document_attr a1871
                                       ON     a1871.apda_apd = d801.apd_id
                                          AND a1871.apda_ap = p_ap_id
                                          AND a1871.apda_nda = 1871
                                          AND a1871.apda_val_string = 'T'
                                          AND a1871.history_status = 'A'
                             WHERE     d801.apd_ap = p_ap_id
                                   AND d801.apd_ndt = 801              --Заява
                                   AND d801.history_status = 'A')
                   END)
          INTO l_apr_id,
               l_apr_start_dt,
               l_apr_stop_dt,
               v_org_id,
               v_aps_exist,
               v_app_pib,
               l_address,
               v_ap_tp,
               v_apd_801
          FROM v_ap_declaration d JOIN v_appeal ap ON ap.ap_id = p_ap_id
         WHERE d.apr_ap = p_ap_id;

        IF l_apr_id IS NULL
        THEN
            raise_application_error (-20000, 'Декларацію не заповнено!');
        END IF;

        --#83149 контроль доступності друкованої форми декларації для звернення про надання СП
        IF v_ap_tp = 'SS' AND v_apd_801 IS NULL
        THEN
            raise_application_error (
                -20000,
                'Друкована форма декларації недоступна для поточного звернення!');
        END IF;

        --ініціалізація процесу
        p_jbr_id :=
            rdm$rtfl.initreport (
                get_rt_by_code (
                    CASE
                        WHEN v_ap_tp = 'SS' THEN 'PRINT_APR_FORM_R3'
                        WHEN v_aps_exist > 0 THEN 'PRINT_APR_FORM_R2'
                        ELSE 'PRINT_APR_FORM_R1'
                    END));

        IF v_ap_tp = 'SS' --#83149 друкована форма декларації для звернення про надання СП
        THEN
            SELECT o.org_name
              INTO l_org_name
              FROM v_opfu o
             WHERE o.org_id = v_org_id;

            SELECT RTRIM (
                       (   MAX (
                               CASE
                                   WHEN     da.apda_nda = 1625
                                        AND TRIM (da.apda_val_string)
                                                IS NOT NULL
                                   THEN
                                       TRIM (da.apda_val_string) || ', '
                               END)
                        || (LTRIM (
                                   MAX (
                                       CASE da.apda_nda
                                           WHEN 1618
                                           THEN
                                               COALESCE (
                                                   (CASE
                                                        WHEN da.apda_val_id
                                                                 IS NOT NULL
                                                        THEN
                                                            get_katottg_info (
                                                                da.apda_val_id)
                                                    END),
                                                   da.apda_val_string)
                                       END)
                                || ', ',
                                ', '))
                        || COALESCE (
                               LTRIM (
                                      MAX (
                                          CASE da.apda_nda
                                              WHEN 1632
                                              THEN
                                                  COALESCE (
                                                      (CASE
                                                           WHEN da.apda_val_id
                                                                    IS NOT NULL
                                                           THEN
                                                               get_street_info (
                                                                   da.apda_val_id)
                                                       END),
                                                      TRIM (
                                                          da.apda_val_string))
                                          END)
                                   || ', ',
                                   ', '),
                               MAX (
                                   CASE
                                       WHEN     da.apda_nda = 1640
                                            AND TRIM (da.apda_val_string)
                                                    IS NOT NULL
                                       THEN
                                              'вул. '
                                           || TRIM (da.apda_val_string)
                                           || ', '
                                   END))
                        || MAX (
                               CASE
                                   WHEN     da.apda_nda = 1648
                                        AND TRIM (da.apda_val_string)
                                                IS NOT NULL
                                   THEN
                                          'буд. '
                                       || TRIM (da.apda_val_string)
                                       || ', '
                               END)
                        || MAX (
                               CASE
                                   WHEN     da.apda_nda = 1654
                                        AND TRIM (da.apda_val_string)
                                                IS NOT NULL
                                   THEN
                                          'корп. '
                                       || TRIM (da.apda_val_string)
                                       || ', '
                               END)
                        || MAX (
                               CASE
                                   WHEN     da.apda_nda = 1659
                                        AND TRIM (da.apda_val_string)
                                                IS NOT NULL
                                   THEN
                                       'кв. ' || TRIM (da.apda_val_string)
                               END)),
                       ', ')
              INTO l_address
              FROM v_ap_document  d
                   JOIN v_ap_document_attr da
                       ON     da.apda_apd = d.apd_id
                          AND da.apda_ap = p_ap_id
                          AND da.apda_nda IN (1618,
                                              1625,
                                              1632,
                                              1640,
                                              1648,
                                              1654,
                                              1659)
                          AND da.history_status = 'A'
             WHERE     d.apd_ap = p_ap_id
                   AND d.apd_ndt = 605
                   AND d.history_status = 'A';

            rdm$rtfl.addparam (
                p_jbr_id,
                'org_name',
                COALESCE (
                    l_org_name,
                    '_________________________________________________________________________________'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'pib',
                COALESCE (
                    v_app_pib,
                       '_____________________________________________________________________________\par'
                    || '\fs20 (прізвище, ім’я, по батькові (за наявності) особи, яка потребує надання соціальних послуг (далі - заявник) \fs24'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'address',
                COALESCE (
                    l_address,
                       '_________________________________________\par'
                    || '_______________________________________________________________________________\par'
                    || '\fs20 (поштовий індекс, область, район, населений пункт, вулиця, будинок, корпус, квартира) \fs24'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'start_dt',
                COALESCE (TO_CHAR (l_apr_start_dt, 'dd.mm.yyyy'),
                          '_____ 20 __'));
            rdm$rtfl.addparam (
                p_jbr_id,
                'stop_dt',
                COALESCE (TO_CHAR (l_apr_stop_dt, 'dd.mm.yyyy'),
                          '_____ 20 __'));
            rdm$rtfl.addparam (p_jbr_id,
                               'curr_dt',
                               TO_CHAR (SYSDATE, 'DD.MM.YYYY'));

            --Розділ I. Загальні відомості
            --#87905 nda_id=649 - новий nda "Ступінь родинного зв’язку"
            rdm$rtfl.adddataset (
                p_jbr_id,
                'ds1',
                   q'[SELECT p.aprp_id,
       MAX(CASE
             WHEN pp.app_id IS NULL THEN
              p.aprp_ln || ' ' || p.aprp_fn || ' ' || p.aprp_mn
             ELSE
              pp.app_ln || ' ' || pp.app_fn || ' ' || pp.app_mn
           END) AS c1,
       to_char(MAX(CASE
                     WHEN td.apda_nda IN (91, 606, 607) THEN
                      td.apda_val_dt
                   END), 'DD.MM.YYYY') AS c2,
       MAX(CASE
           WHEN td.apda_nda in (813, 649) AND td.apda_val_string IS NOT NULL
                THEN (SELECT t.dic_name FROM uss_ndi.v_ddn_relation_tp t WHERE t.dic_value = td.apda_val_string) END) AS c3,
       MAX(td.app_doc) AS c4,
       MAX(coalesce(p.aprp_inn, pp.app_inn)) AS c5,
       MAX(CASE td.apda_nda WHEN 810 THEN td.apda_val_string END) AS c6
  FROM uss_visit.v_apr_person p
  JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                               AND pp.history_status = 'A'
  LEFT JOIN (SELECT d.apd_id,
                    d.apd_app,
                    dt.ndt_name,
                    da.apda_nda,
                    da.apda_val_dt,
                    da.apda_val_string,
                    FIRST_VALUE(dt.ndt_name || ', ' || da.apda_val_string) OVER (PARTITION BY d.apd_app ORDER BY (CASE WHEN da.apda_nda IN (3, 9, 90) THEN 0 ELSE 1 END),
                                                                                                        (CASE WHEN da.apda_val_string IS NOT NULL THEN 0 ELSE 1 END),
                                                                                                        dt.ndt_order) AS app_doc
              FROM uss_visit.v_ap_document d
              JOIN uss_ndi.v_ndi_document_type dt ON dt.ndt_id = d.apd_ndt
              JOIN uss_visit.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                  AND da.apda_ap = ]'
                || TO_CHAR (p_ap_id)
                || q'[
                                                  AND da.apda_nda IN (3, 9, 90, 91, 606, 607, 810, 813, 649)
                                                  AND da.history_status = 'A'
             WHERE d.apd_ap = ]'
                || TO_CHAR (p_ap_id)
                || q'[
               AND d.apd_ndt IN (6, 7, 37, 605)
               AND d.history_status = 'A') td ON td.apd_app = pp.app_id
 WHERE p.aprp_apr = ]'
                || TO_CHAR (l_apr_id)
                || q'[
   AND p.history_status = 'A'
 GROUP BY p.aprp_id
 ORDER BY 2]');

            --Розділ II. Відомості про доходи потенційного отримувача соціальних послуг, членів його сім’ї
            SELECT COUNT (1)
              INTO l_cnt
              FROM v_apr_income i
             WHERE i.apri_apr = l_apr_id AND i.history_status = 'A';

            IF l_cnt = 0
            THEN
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'ds2',
                       q'[SELECT (pp.app_ln || ' ' || LTRIM(substr(pp.app_fn, 1, 1) || '. ', '. ') || LTRIM(substr(pp.app_mn, 1, 1) || '.', '.')) AS c1, 'Не має' AS c2
  FROM uss_visit.v_apr_person p
  JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                               AND pp.history_status = 'A'
 WHERE p.aprp_apr = ]'
                    || l_apr_id
                    || q'[
   AND p.history_status = 'A']');
            ELSE
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'ds2',
                       q'[SELECT (CASE
         WHEN pp.app_id IS NULL THEN
          p.aprp_ln || ' ' || LTRIM(substr(p.aprp_fn, 1, 1) || '. ', '. ') || LTRIM(substr(p.aprp_mn, 1, 1) || '.', '.')
         ELSE
          pp.app_ln || ' ' || LTRIM(substr(pp.app_fn, 1, 1) || '. ', '. ') || LTRIM(substr(pp.app_mn, 1, 1) || '.', '.')
       END) AS c1,
       t.dic_name AS c2,
       to_char(i.apri_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c3,
       i.apri_source AS c4
  FROM uss_visit.v_apr_income i
  JOIN uss_ndi.v_ddn_apri_tp t ON t.dic_value = i.apri_tp
  JOIN uss_visit.v_apr_person p ON p.aprp_id = i.apri_aprp
  LEFT JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                                    AND pp.history_status = 'A'
 WHERE i.apri_apr = ]'
                    || l_apr_id
                    || q'[
   AND i.history_status = 'A'
 ORDER BY 1]');
            END IF;
        ELSE
            --назва організації, #75900 по низькорівневим організаціям необхідно відображати батьківську організацію
            SELECT MAX (org_name)
              INTO l_org_name
              FROM (    SELECT o.org_id,
                               o.org_name,
                               MAX (
                                   CASE
                                       WHEN o.org_id = v_org_id THEN o.org_to
                                   END)
                                   OVER ()    AS org_to,
                               MAX (CASE WHEN o.org_id > 0 THEN LEVEL END)
                                   OVER ()    AS lvl_cnt,
                               LEVEL          AS lvl
                          FROM v_opfu o
                         WHERE o.org_st = 'A'
                    START WITH o.org_id = v_org_id
                    CONNECT BY PRIOR o.org_org = o.org_id)
             WHERE lvl =
                   (CASE WHEN lvl_cnt > 3 OR org_to > 32 THEN 2 ELSE 1 END);

            rdm$rtfl.addparam (
                p_jbr_id,
                'org_name',
                (CASE v_aps_exist
                     WHEN 0
                     THEN
                         RPAD (RTRIM (NVL (l_org_name, '_'), ','), 110, '_')
                     ELSE
                         COALESCE (
                             l_org_name,
                                '__________________________________\par'
                             || '\fs20     (найменування структурного підрозділу \par'
                             || '     з питань соціального захисту населення) \fs24\par'
                             || '__________________________________')
                 END));

            --ПІБ ЗАЯВНИКА
            rdm$rtfl.addparam (
                p_jbr_id,
                'pib',
                (CASE v_aps_exist
                     WHEN 0
                     THEN
                         v_app_pib
                     ELSE
                         COALESCE (
                             v_app_pib,
                                '________________________________________________________________________________\par'
                             || '\fs20                                    (прізвище, ім''я, по батькові (за наявності) заявника / законного представника заявника /\par'
                             || '                                                                                    уповноваженого представника сім''ї) \fs24')
                 END));

            --АДРЕСА ПРОЖИВАННЯ
            rdm$rtfl.addparam (
                p_jbr_id,
                'address',
                (CASE v_aps_exist
                     WHEN 0
                     THEN
                         RPAD (RTRIM (NVL (l_address, '_'), ','), 80, '_')
                     ELSE
                         COALESCE (
                             l_address,
                                '__________________________________________________________________________________\par'
                             || '\fs20                                    (поштовий індекс, область, район, населений пункт, вулиця, будинок, корпус, квартира) \fs24')
                 END));

            rdm$rtfl.addparam (
                p_jbr_id,
                'start_dt',
                (CASE v_aps_exist
                     WHEN 0
                     THEN
                         TO_CHAR (l_apr_start_dt, 'dd.mm.yyyy')
                     ELSE
                         COALESCE (TO_CHAR (l_apr_start_dt, 'dd.mm.yyyy'),
                                   '____________ 20__')
                 END));
            rdm$rtfl.addparam (
                p_jbr_id,
                'stop_dt',
                (CASE v_aps_exist
                     WHEN 0
                     THEN
                         TO_CHAR (l_apr_stop_dt, 'dd.mm.yyyy')
                     ELSE
                         COALESCE (TO_CHAR (l_apr_stop_dt, 'dd.mm.yyyy'),
                                   '____________ 20__')
                 END));

            IF v_aps_exist = 0
            THEN
                --ЧЛЕНИ СІМ’Ї
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'person_ds',
                    q'[
	SELECT CASE WHEN pp.App_Id is NULL THEN
					Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
				 ELSE
					pp.App_Ln || ' ' || pp.App_Fn || ' ' || pp.App_Mn
				 END AS Aprp_Pib,
				 t.Dic_Name AS Aprp_Rel_Tp,
				 p.Aprp_Inn,
				 p.Aprp_Notes
		FROM Uss_Visit.v_Apr_Person p
		JOIN Uss_Ndi.v_Ddn_Relation_Tp t
			ON p.Aprp_Tp = t.Dic_Value
		LEFT JOIN USS_Visit.v_Ap_Person pp
			ON p.Aprp_App = pp.App_Id
	 WHERE p.Aprp_Apr = ]' || l_apr_id || q'[ AND p.History_Status='A']');

                --ДОХОДИ
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'income_ds',
                    q'[
	SELECT CASE
					WHEN Pp.App_Id IS NULL THEN
					 Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
					ELSE
					 App_Ln || ' ' || App_Fn || ' ' || App_Mn
				 END AS Apri_Pib,
				 t.Dic_Name AS Apri_Tp,
				 i.Apri_Sum,
				 i.Apri_Source
		FROM Uss_Visit.v_Apr_Income i
		JOIN Uss_Ndi.v_Ddn_Apri_Tp t
			ON i.Apri_Tp = t.Dic_Value
		JOIN Uss_Visit.v_Apr_Person p
			ON i.Apri_Aprp = p.Aprp_Id
		LEFT JOIN Uss_Visit.v_Ap_Person Pp
			ON p.Aprp_App = Pp.App_Id
     AND pp.History_Status = 'A'
	 WHERE i.Apri_Apr = ]' || l_apr_id || q'[ AND i.History_Status = 'A']');

                --ЖИТЛОВІ ПРИМІЩЕННЯ
                SELECT COUNT (*)
                  INTO l_cnt
                  FROM apr_living_quarters q
                 WHERE q.aprl_apr = l_apr_id AND q.history_status = 'A';

                IF l_cnt = 0
                THEN
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'living_quarters_ds',
                        q'[
	 SELECT CASE
					 WHEN Pp.App_Id IS NULL THEN
						Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
					 ELSE
						App_Ln || ' ' || App_Fn || ' ' || App_Mn
					END AS Aprl_Pib,
					'Не має' AS Aprl_Area
		 FROM Uss_Visit.v_Apr_Person p
		 JOIN Uss_Visit.v_Ap_Person Pp
			 ON p.Aprp_App = Pp.App_Id
					AND Pp.App_Tp = 'Z'
          AND pp.History_Status = 'A'
		WHERE p.Aprp_Apr = ]' || l_apr_id || q'[ AND p.History_Status = 'A']');
                ELSE
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'living_quarters_ds',
                        q'[
	SELECT CASE
					WHEN Pp.App_Id IS NULL THEN
					 Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
					ELSE
					 App_Ln || ' ' || App_Fn || ' ' || App_Mn
				 END AS Aprl_Pib,
				 q.Aprl_Area,
				 q.Aprl_Qnt,
				 q.Aprl_Address
		FROM Uss_Visit.v_Apr_Living_Quarters q
		JOIN Uss_Visit.v_Apr_Person p
			ON q.Aprl_Aprp = p.Aprp_Id
		LEFT JOIN Uss_Visit.v_Ap_Person Pp
			ON p.Aprp_App = Pp.App_Id
      AND pp.History_Status = 'A'
	 WHERE q.Aprl_Apr =]' || l_apr_id || q'[ AND q.History_Status = 'A']');
                END IF;

                --ТРАНСПОРТНІ ЗАСОБИ
                SELECT COUNT (*)
                  INTO l_cnt
                  FROM apr_vehicle v
                 WHERE v.aprv_apr = l_apr_id AND v.history_status = 'A';

                IF l_cnt = 0
                THEN
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'vehicles_ds',
                        q'[
	 SELECT CASE
					 WHEN Pp.App_Id IS NULL THEN
						Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
					 ELSE
						App_Ln || ' ' || App_Fn || ' ' || App_Mn
					END AS Aprv_Pib,
					'Не має' as brand
		 FROM Uss_Visit.v_Apr_Person p
		 JOIN Uss_Visit.v_Ap_Person Pp
			 ON p.Aprp_App = Pp.App_Id
					AND Pp.App_Tp = 'Z'
          AND pp.History_Status = 'A'
		WHERE p.Aprp_Apr = ]' || l_apr_id || q'[ AND p.History_Status = 'A']');
                ELSE
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'vehicles_ds',
                           q'[
	SELECT CASE
					WHEN Pp.App_Id IS NULL THEN
					 Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
					ELSE
					 App_Ln || ' ' || App_Fn || ' ' || App_Mn
				 END AS Aprv_Pib,
				 v.Aprv_Car_Brand as  brand,
				 v.Aprv_License_Plate as plate,
				 v.Aprv_Production_Year as year,
				 (SELECT b.dic_name FROM uss_ndi.v_ddn_boolean b WHERE b.dic_value = coalesce(v.aprv_is_social_car, 'F')) as social
		FROM Uss_Visit.v_Apr_Vehicle v
		JOIN Uss_Visit.v_Apr_Person p
			ON v.Aprv_Aprp = p.Aprp_Id
		LEFT JOIN Uss_Visit.v_Ap_Person Pp
			ON p.Aprp_App = Pp.App_Id
     AND pp.History_Status = 'A'
	 WHERE v.Aprv_Apr =]'
                        || l_apr_id
                        || q'[ AND v.History_Status = 'A']');
                END IF;

                --ЗЕМЕЛЬНІ ДІЛЯНКИ
                SELECT COUNT (*)
                  INTO l_cnt
                  FROM apr_land_plot l
                 WHERE l.aprt_apr = l_apr_id AND l.history_status = 'A';

                IF l_cnt = 0
                THEN
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'land_plots_ds',
                        q'[
	 SELECT CASE
					 WHEN Pp.App_Id IS NULL THEN
						Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
					 ELSE
						App_Ln || ' ' || App_Fn || ' ' || App_Mn
					END AS Aprt_Pib,
					'Не має' as Aprt_Area
		 FROM Uss_Visit.v_Apr_Person p
		 JOIN Uss_Visit.v_Ap_Person Pp
			 ON p.Aprp_App = Pp.App_Id
					AND Pp.App_Tp = 'Z'
          AND pp.History_Status = 'A'
		WHERE p.Aprp_Apr = ]' || l_apr_id || q'[ AND p.History_Status = 'A']');
                ELSE
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'land_plots_ds',
                        q'[
	 SELECT CASE
					 WHEN Pp.App_Id IS NULL THEN
						Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
					 ELSE
						App_Ln || ' ' || App_Fn || ' ' || App_Mn
					END AS Aprt_Pib,
					l.Aprt_Area,
					l.Aprt_Ownership as Aprt_Own,
					l.Aprt_Purpose as Aprt_Purp
		 FROM Uss_Visit.v_Apr_Land_Plot l
		 JOIN Uss_Visit.v_Apr_Person p
			 ON l.Aprt_Aprp = p.Aprp_Id
		 LEFT JOIN Uss_Visit.v_Ap_Person Pp
			 ON p.Aprp_App = Pp.App_Id
      AND pp.History_Status = 'A'
		WHERE l.Aprt_Apr = ]' || l_apr_id || q'[ AND l.History_Status = 'A']');
                END IF;

                --ДОДАТКОВІ ДЖЕРЕЛА ІСНУВАННЯ
                rdm$rtfl.adddataset (p_jbr_id,
                                     'other_incomes_ds',
                                     q'[
	SELECT t.Dic_Name as Apro_Tp,
				 CASE
					WHEN o.Apro_Id IS NULL THEN
					 'Не має'
					ELSE
					 o.Apro_Income_Info
				 END AS Apro_Income_Info,
				 o.Apro_Income_Usage
		FROM Uss_Ndi.v_Ddn_Apro_Tp t
		LEFT JOIN Uss_Visit.v_Apr_Other_Income o
			ON o.Apro_Apr = ]' || l_apr_id || q'[
				 AND o.History_Status = 'A'
				 AND o.Apro_Tp = t.Dic_Value
	 WHERE t.Dic_St = 'A']');

                --ВИТРАТИ
                SELECT COUNT (*),
                       SUM (
                           CASE
                               WHEN t.dic_srtordr < 7 THEN s.aprs_cost
                               ELSE 0
                           END),
                       SUM (
                           CASE
                               WHEN t.dic_srtordr >= 7 THEN s.aprs_cost
                               ELSE 0
                           END)
                  INTO l_cnt, l_total1, l_total2
                  FROM apr_spending  s
                       JOIN uss_ndi.v_ddn_aprs_tp t
                           ON s.aprs_tp = t.dic_value
                 WHERE s.aprs_apr = l_apr_id AND s.history_status = 'A';

                IF l_cnt = 0
                THEN
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'spendings1_ds',
                        q'[SELECT '-1' as Main_Aprs_Tp, NULL AS Aprs_Tp_Name FROM DUAL]');
                    rdm$rtfl.addparam (p_jbr_id, 'total1', '0');
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'spendings2_ds',
                        q'[SELECT '-1' as Main_Aprs_Tp, NULL AS Aprs_Tp_Name FROM DUAL]');
                    rdm$rtfl.addparam (p_jbr_id, 'total2', '0');
                    l_spendings_det_sql :=
                           q'[
	SELECT * FROM(SELECT CASE
					 WHEN Pp.App_Id IS NULL THEN
						Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
					 ELSE
						App_Ln || ' ' || App_Fn || ' ' || App_Mn
					END AS Aprs_Pib,
					'Не має' AS Aprs_Cost_Tp,
					NULL as Aprs_Cost,
					NULL as Aprs_Dt,
					'-1' as Aprs_Tp
		 FROM Uss_Visit.v_Apr_Person p
		 JOIN Uss_Visit.v_Ap_Person Pp
			 ON p.Aprp_App = Pp.App_Id
					AND Pp.App_Tp = 'Z'
          AND pp.History_Status = 'A'
		WHERE p.Aprp_Apr = ]'
                        || l_apr_id
                        || q'[ AND p.History_Status = 'A') WHERE 1=1]';
                    rdm$rtfl.adddataset (p_jbr_id,
                                         'spendings_det1_ds',
                                         l_spendings_det_sql);
                    rdm$rtfl.adddataset (p_jbr_id,
                                         'spendings_det2_ds',
                                         l_spendings_det_sql);
                ELSE
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'spendings1_ds',
                           q'[
	SELECT DISTINCT s.Aprs_Tp as Main_Aprs_Tp, t.Dic_Name AS Aprs_Tp_Name, t.DIC_SRTORDR
		FROM Uss_Visit.v_Apr_Spending s
		JOIN Uss_Ndi.v_Ddn_Aprs_Tp t
			ON s.Aprs_Tp = t.Dic_Value
	 WHERE s.Aprs_Apr = ]'
                        || l_apr_id
                        || q'[
				 AND s.History_Status = 'A' AND t.DIC_SRTORDR < 7
	 ORDER BY t.DIC_SRTORDR]');
                    rdm$rtfl.addparam (p_jbr_id, 'total1', l_total1);

                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'spendings2_ds',
                           q'[
	SELECT DISTINCT s.Aprs_Tp as Main_Aprs_Tp, t.Dic_Name AS Aprs_Tp_Name, t.DIC_SRTORDR
		FROM Uss_Visit.v_Apr_Spending s
		JOIN Uss_Ndi.v_Ddn_Aprs_Tp t
			ON s.Aprs_Tp = t.Dic_Value
	 WHERE s.Aprs_Apr = ]'
                        || l_apr_id
                        || q'[
				 AND s.History_Status = 'A' AND t.DIC_SRTORDR >= 7
	 ORDER BY t.DIC_SRTORDR]');
                    rdm$rtfl.addparam (p_jbr_id, 'total2', l_total2);

                    l_spendings_det_sql := q'[
	 SELECT CASE
					 WHEN Pp.App_Id IS NULL THEN
						Aprp_Ln || ' ' || Aprp_Fn || ' ' || Aprp_Mn
					 ELSE
						App_Ln || ' ' || App_Fn || ' ' || App_Mn
					END AS Aprs_Pib,
					s.Aprs_Cost_Type AS Aprs_Cost_Tp,
					s.Aprs_Cost,
					to_char(s.Aprs_Dt, 'dd.mm.yyyy') as Aprs_Dt,
					s.Aprs_Tp
		 FROM Uss_Visit.v_Apr_Spending s
		 JOIN Uss_Visit.v_Apr_Person p
			 ON s.Aprs_Aprp = p.Aprp_Id
		 LEFT JOIN Uss_Visit.v_Ap_Person Pp
			 ON p.Aprp_App = Pp.App_Id
      AND pp.History_Status = 'A'
		WHERE s.Aprs_Apr = ]' || l_apr_id || q'[
					AND s.History_Status = 'A']';

                    rdm$rtfl.adddataset (p_jbr_id,
                                         'spendings_det1_ds',
                                         l_spendings_det_sql);
                    rdm$rtfl.adddataset (p_jbr_id,
                                         'spendings_det2_ds',
                                         l_spendings_det_sql);
                END IF;

                rdm$rtfl.addrelation (p_jbr_id,
                                      'spendings1_ds',
                                      'main_aprs_tp',
                                      'spendings_det1_ds',
                                      'aprs_tp');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'spendings2_ds',
                                      'main_aprs_tp',
                                      'spendings_det2_ds',
                                      'aprs_tp');
            ELSE
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'curr_dt',
                    COALESCE (TO_CHAR (SYSDATE, 'DD.MM.YYYY'),
                              '___ ____________ 20__'));

                v_sql_str :=
                       q'[SELECT (pp.app_ln || ' ' || LTRIM(substr(pp.app_fn, 1, 1) || '. ', '. ') || LTRIM(substr(pp.app_mn, 1, 1) || '.', '.')) AS c1, 'Не має' AS c2
  FROM uss_visit.v_apr_person p
  JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                               AND pp.app_tp = 'Z'
                               AND pp.history_status = 'A'
 WHERE p.aprp_apr = ]'
                    || l_apr_id
                    || q'[
   AND p.history_status = 'A']';

                --Розділ I. Загальні відомості, 3. Дані про осіб, які входять до складу сім'ї
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'ds1',
                       q'[SELECT p.aprp_id,
       MAX(CASE
             WHEN pp.app_id IS NULL THEN
              p.aprp_ln || ' ' || p.aprp_fn || ' ' || p.aprp_mn
             ELSE
              pp.app_ln || ' ' || pp.app_fn || ' ' || pp.app_mn
           END) AS c1,
       MAX(t.dic_name) AS c2,
       to_char(MAX(CASE
                     WHEN da.apda_nda IN (91, 606, 607) THEN
                      da.apda_val_dt
                   END), 'DD.MM.YYYY') AS c3,
       MAX(CASE
             WHEN da.apda_nda IN (3, 9, 90) THEN
              da.apda_val_string
           END) AS c4,
       MAX(coalesce(p.aprp_inn, pp.app_inn)) AS c5,
       MAX(p.aprp_notes) AS c6
  FROM uss_visit.v_apr_person p
  JOIN uss_ndi.v_ddn_relation_tp t ON t.dic_value = p.aprp_tp
  LEFT JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                                    AND pp.history_status = 'A'
  LEFT JOIN uss_visit.v_ap_document d
            JOIN uss_visit.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                AND da.apda_ap = d.apd_ap
                                                AND da.apda_nda IN (3, 9, 90, 91, 606, 607)
                                                AND da.history_status = 'A' ON d.apd_app = pp.app_id
                                                                           AND d.apd_ndt IN (6, 7, 37)
                                                                           AND d.history_status = 'A'
 WHERE p.aprp_apr = ]'
                    || l_apr_id
                    || q'[
   AND p.history_status = 'A'
 GROUP BY p.aprp_id
 ORDER BY 2]');

                --Розділ II
                SELECT COUNT (1)
                  INTO l_cnt
                  FROM v_apr_income i
                 WHERE     i.apri_apr = l_apr_id
                       AND i.history_status = 'A'
                       AND i.apri_tp != '5';

                IF l_cnt = 0
                THEN
                    rdm$rtfl.adddataset (p_jbr_id, 'ds2', v_sql_str);
                ELSE
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'ds2',
                           q'[SELECT (CASE
         WHEN pp.app_id IS NULL THEN
          p.aprp_ln || ' ' || LTRIM(substr(p.aprp_fn, 1, 1) || '. ', '. ') || LTRIM(substr(p.aprp_mn, 1, 1) || '.', '.')
         ELSE
          pp.app_ln || ' ' || LTRIM(substr(pp.app_fn, 1, 1) || '. ', '. ') || LTRIM(substr(pp.app_mn, 1, 1) || '.', '.')
       END) AS c1,
       t.dic_name AS c2,
       to_char(i.apri_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c3,
       i.apri_source AS c4
  FROM uss_visit.v_apr_income i
  JOIN uss_ndi.v_ddn_apri_tp t ON t.dic_value = i.apri_tp
  JOIN uss_visit.v_apr_person p ON p.aprp_id = i.apri_aprp
  LEFT JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                                    AND pp.history_status = 'A'
 WHERE i.apri_apr = ]'
                        || l_apr_id
                        || q'[
   AND i.history_status = 'A'
   AND i.apri_tp != '5'
 ORDER BY 1]');
                END IF;

                --Розділ III
                SELECT COUNT (1)
                  INTO l_cnt
                  FROM v_apr_living_quarters q
                 WHERE q.aprl_apr = l_apr_id AND q.history_status = 'A';

                IF l_cnt = 0
                THEN
                    rdm$rtfl.adddataset (p_jbr_id, 'ds3', v_sql_str);
                ELSE
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'ds3',
                           q'[SELECT (CASE
         WHEN pp.app_id IS NULL THEN
          p.aprp_ln || ' ' || LTRIM(substr(p.aprp_fn, 1, 1) || '. ', '. ') || LTRIM(substr(p.aprp_mn, 1, 1) || '.', '.')
         ELSE
          pp.app_ln || ' ' || LTRIM(substr(pp.app_fn, 1, 1) || '. ', '. ') || LTRIM(substr(pp.app_mn, 1, 1) || '.', '.')
       END) AS c1,
       (SELECT tp.dic_name FROM uss_ndi.v_ddn_aprl_tp tp WHERE tp.dic_value = q.aprl_tp) AS c2,
       to_char(q.aprl_area, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c3,
       q.aprl_address AS c4,
       (SELECT ch.dic_name FROM uss_ndi.v_ddn_aprl_ch ch WHERE ch.dic_value = q.aprl_ch) AS c5
  FROM uss_visit.v_apr_living_quarters q
  JOIN uss_visit.v_apr_person p ON p.aprp_id = q.aprl_aprp
  LEFT JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                                    AND pp.history_status = 'A'
 WHERE q.aprl_apr = ]'
                        || l_apr_id
                        || q'[
   AND q.history_status = 'A'
 ORDER BY 1]');
                END IF;

                --Розділ IV
                SELECT COUNT (1)
                  INTO l_cnt
                  FROM v_apr_vehicle v
                 WHERE     v.aprv_apr = l_apr_id
                       AND v.history_status = 'A'
                       AND (  TO_NUMBER (TO_CHAR (SYSDATE, 'YYYY'))
                            - v.aprv_production_year) <
                           15;

                IF l_cnt = 0
                THEN
                    rdm$rtfl.adddataset (p_jbr_id, 'ds4', v_sql_str);
                ELSE
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'ds4',
                           q'[SELECT (CASE
         WHEN pp.app_id IS NULL THEN
          p.aprp_ln || ' ' || LTRIM(substr(p.aprp_fn, 1, 1) || '. ', '. ') || LTRIM(substr(p.aprp_mn, 1, 1) || '.', '.')
         ELSE
          pp.app_ln || ' ' || LTRIM(substr(pp.app_fn, 1, 1) || '. ', '. ') || LTRIM(substr(pp.app_mn, 1, 1) || '.', '.')
       END) AS c1,
       v.aprv_car_brand AS c2,
       v.aprv_license_plate AS c3,
       v.aprv_production_year AS c4,
       (SELECT b.dic_name FROM uss_ndi.v_ddn_boolean b WHERE b.dic_value = coalesce(v.aprv_is_social_car, 'F')) AS c5
  FROM uss_visit.v_apr_vehicle v
  JOIN uss_visit.v_apr_person p ON p.aprp_id = v.aprv_aprp
  LEFT JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                                    AND pp.history_status = 'A'
 WHERE v.aprv_apr = ]'
                        || l_apr_id
                        || q'[
   AND v.history_status = 'A'
   AND (]'
                        || TO_CHAR (SYSDATE, 'YYYY')
                        || ' - v.aprv_production_year) < 15
 ORDER BY 1');
                END IF;

                --Розділ V
                SELECT TRUNC (ADD_MONTHS (ap.ap_reg_dt, -12))
                  INTO v_dt
                  FROM v_appeal ap
                 WHERE ap.ap_id = p_ap_id;

                SELECT COUNT (1)
                  INTO l_cnt
                  FROM v_apr_spending s
                 WHERE     s.aprs_apr = l_apr_id
                       AND s.history_status = 'A'
                       AND s.aprs_cost > 50000
                       AND s.aprs_dt >= v_dt;

                IF l_cnt = 0
                THEN
                    rdm$rtfl.adddataset (p_jbr_id, 'ds5', v_sql_str);
                ELSE
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'ds5',
                           q'[SELECT (CASE
         WHEN pp.app_id IS NULL THEN
          p.aprp_ln || ' ' || LTRIM(substr(p.aprp_fn, 1, 1) || '. ', '. ') || LTRIM(substr(p.aprp_mn, 1, 1) || '.', '.')
         ELSE
          pp.app_ln || ' ' || LTRIM(substr(pp.app_fn, 1, 1) || '. ', '. ') || LTRIM(substr(pp.app_mn, 1, 1) || '.', '.')
       END) AS c1,
       t.dic_name AS c2,
       to_char(s.aprs_cost, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c3,
       s.aprs_dt AS c4
  FROM uss_visit.v_apr_spending s
  JOIN uss_ndi.v_ddn_aprs_tp t ON t.dic_value = s.aprs_tp
  JOIN uss_visit.v_apr_person p ON p.aprp_id = s.aprs_aprp
  LEFT JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                                    AND pp.history_status = 'A'
 WHERE s.aprs_apr = ]'
                        || l_apr_id
                        || q'[
   AND s.history_status = 'A'
   AND s.aprs_cost > 50000
   AND s.aprs_dt >= to_date(']'
                        || TO_CHAR (v_dt, 'DD.MM.YYYY')
                        || q'[', 'DD.MM.YYYY')
 ORDER BY 1]');
                END IF;

                --Розділ VI
                /*SELECT COUNT(1)
                  INTO l_cnt
                  FROM v_apr_income i
                 WHERE i.apri_apr = l_apr_id
                   AND i.history_status = 'A'
                   AND i.apri_tp = '5';

                IF l_cnt = 0
                THEN
                  rdm$rtfl.adddataset(p_jbr_id, 'ds6', v_sql_str);
                ELSE
                  rdm$rtfl.adddataset(p_jbr_id,
                                      'ds6',
                                      q'[SELECT (CASE
                     WHEN pp.app_id IS NULL THEN
                      p.aprp_ln || ' ' || LTRIM(substr(p.aprp_fn, 1, 1) || '. ', '. ') || LTRIM(substr(p.aprp_mn, 1, 1) || '.', '.')
                     ELSE
                      pp.app_ln || ' ' || LTRIM(substr(pp.app_fn, 1, 1) || '. ', '. ') || LTRIM(substr(pp.app_mn, 1, 1) || '.', '.')
                   END) AS c1,
                   '' AS c2,
                   to_char(i.apri_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c3,
                   i.apri_source AS c4
              FROM uss_visit.v_apr_income i
              JOIN uss_visit.v_apr_person p ON p.aprp_id = i.apri_aprp
              LEFT JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                                                AND pp.history_status = 'A'
             WHERE i.apri_apr = ]' || l_apr_id || q'[
               AND i.history_status = 'A'
               AND i.apri_tp = '5'
             ORDER BY 1]');
                END IF;*/
                SELECT COUNT (1)
                  INTO l_cnt
                  FROM v_apr_alimony i
                 WHERE i.apra_apr = l_apr_id AND i.history_status = 'A';

                IF l_cnt = 0
                THEN
                    rdm$rtfl.adddataset (p_jbr_id, 'ds6', v_sql_str);
                ELSE
                    rdm$rtfl.adddataset (
                        p_jbr_id,
                        'ds6',
                           q'[SELECT (CASE
         WHEN pp.app_id IS NULL THEN
          p.aprp_ln || ' ' || LTRIM(substr(p.aprp_fn, 1, 1) || '. ', '. ') || LTRIM(substr(p.aprp_mn, 1, 1) || '.', '.')
         ELSE
          pp.app_ln || ' ' || LTRIM(substr(pp.app_fn, 1, 1) || '. ', '. ') || LTRIM(substr(pp.app_mn, 1, 1) || '.', '.')
       END) AS c1,
       t.apra_payer AS c2,
       to_char(t.apra_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c3,
       case when t.apra_is_have_arrears = 'T' then 'Є' end AS c4
  FROM uss_visit.v_apr_alimony t
  JOIN uss_visit.v_apr_person p ON p.aprp_id = t.apra_aprp
  LEFT JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                                  AND pp.history_status = 'A'
 WHERE t.apra_apr  = ]'
                        || l_apr_id
                        || q'[
   AND t.history_status = 'A'
 ORDER BY 1]');
                END IF;



                rdm$rtfl.adddataset (p_jbr_id,
                                     'ds61',
                                     'select * from dual where 1 = 2');
                rdm$rtfl.adddataset (p_jbr_id,
                                     'ds7',
                                     'select * from dual where 1 = 2');
            END IF;
        END IF;

        --позначення звіту як готового до формування підсумкового файлу із данними
        rdm$rtfl.putreporttoworkingqueue (p_jbr_id);
    END;

    -----------------------------------------------------------------
    --Ініціалізація процесу підготовки звіту "Звіт щодо роботи в ЄСП"
    -----------------------------------------------------------------
    PROCEDURE reg_report_work_esp_get (p_com_org       appeal.com_org%TYPE,
                                       p_d_start       DATE,
                                       p_d_end         DATE,
                                       p_jbr_id    OUT NUMBER)
    IS
        l_sql   VARCHAR2 (4000);
    BEGIN
        tools.WriteMsg ('DNET$APPEALS_REPORTS.' || $$PLSQL_UNIT);
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.REG_REPORT_WORK_ESP_GET',
            action_name   => 'p_com_org=' || TO_CHAR (p_com_org));

        IF p_com_org IS NULL
        THEN
            raise_application_error (-20000, 'Організвцію не заповнено');
        END IF;

        p_jbr_id :=
            rdm$rtfl.initreport (get_rt_by_code ('REPORT_WORK_ESP_R1'));

        rdm$rtfl.addparam (p_jbr_id,
                           'p_d_start',
                           TO_CHAR (p_d_start, 'dd.mm.yyyy'));
        rdm$rtfl.addparam (p_jbr_id,
                           'p_d_end',
                           TO_CHAR (p_d_end, 'dd.mm.yyyy'));

        l_sql :=
            q'[SELECT to_char(dt, 'dd.mm.yyyy') as ds_d, org_code as ds_cod, org_name as ds_name,
             to_char(nvl("cnt1",0), '999990') as ds_cnt1,
             to_char(nvl("cnt2",0), '999990') as ds_cnt2,
             to_char(nvl("cnt3",0), '999990') as ds_cnt3
      FROM (  SELECT TRUNC(ap.ap_reg_dt) dt, op.org_code, op.org_name, '1' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_Visit.v_appeal ap
                   JOIN ikis_sys.v_opfu op ON ap.com_org = op.org_id
              WHERE ap.ap_reg_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_org in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND ap.COM_WU != 97478614 --U53222-DEV
              GROUP BY TRUNC(ap.ap_reg_dt), op.org_code, op.org_name
              UNION ALL
              SELECT TRUNC(hs.hs_dt) dt, op.org_code, op.org_name, '2' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_Visit.v_appeal ap
                   JOIN ikis_sys.v_opfu op ON ap.com_org = op.org_id
                   JOIN Uss_Visit.v_ap_log apl ON apl.apl_ap = ap.ap_id
                   JOIN Uss_Visit.v_histsession hs ON hs.hs_id = apl.apl_hs
              WHERE hs.hs_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_org in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND hs.HS_WU != 97478614 --U53222-DEV
                    AND apl.apl_message != CHR(38)||'20'
              GROUP BY TRUNC(hs.hs_dt), op.org_code, op.org_name
              UNION ALL
              SELECT TRUNC(hs.hs_dt) dt, op.org_code, op.org_name, '3' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_Visit.v_appeal ap
                   JOIN ikis_sys.v_opfu op ON ap.com_org = op.org_id
                   JOIN Uss_Visit.v_ap_log apl ON apl.apl_ap = ap.ap_id
                   JOIN Uss_Visit.v_histsession hs ON hs.hs_id = apl.apl_hs
              WHERE hs.hs_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_org in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND hs.HS_WU != 97478614 --U53222-DEV
                    AND apl.apl_message = CHR(38)||'20'
              GROUP BY TRUNC(hs.hs_dt), op.org_code, op.org_name
           )
           PIVOT
           (
              max(cnt)
              FOR src IN ( 1 "cnt1",  2 "cnt2",  3 "cnt3")
           )
      ORDER BY 1]';

        l_sql := REPLACE (l_sql, 'p_com_org', p_com_org);
        l_sql :=
            REPLACE (l_sql, 'p_d_start', TO_CHAR (p_d_start, 'dd.mm.yyyy'));
        l_sql := REPLACE (l_sql, 'p_d_end', TO_CHAR (p_d_end, 'dd.mm.yyyy'));
        rdm$rtfl.adddataset (p_jbr_id, 'ds1', l_sql);

        l_sql :=
            q'[
      SELECT to_char(nvl("cnt1",0), '999990') as cnt1,
             to_char(nvl("cnt2",0), '999990') as cnt2,
             to_char(nvl("cnt3",0), '999990') as cnt3
      FROM (  SELECT '1' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_Visit.v_appeal ap
                   JOIN ikis_sys.v_opfu op ON ap.com_org = op.org_id
              WHERE ap.ap_reg_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_org in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND ap.COM_WU != 97478614 --U53222-DEV
              UNION ALL
              SELECT '2' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_Visit.v_appeal ap
                   JOIN ikis_sys.v_opfu op ON ap.com_org = op.org_id
                   JOIN Uss_Visit.v_ap_log apl ON apl.apl_ap = ap.ap_id
                   JOIN Uss_Visit.v_histsession hs ON hs.hs_id = apl.apl_hs
              WHERE hs.hs_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_org in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND hs.HS_WU != 97478614 --U53222-DEV
                    AND apl.apl_message != CHR(38)||'20'
              UNION ALL
              SELECT '3' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_Visit.v_appeal ap
                   JOIN ikis_sys.v_opfu op ON ap.com_org = op.org_id
                   JOIN Uss_Visit.v_ap_log apl ON apl.apl_ap = ap.ap_id
                   JOIN Uss_Visit.v_histsession hs ON hs.hs_id = apl.apl_hs
              WHERE hs.hs_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_org in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND hs.HS_WU != 97478614 --U53222-DEV
                    AND apl.apl_message = CHR(38)||'20'
           )
           PIVOT
           (
              max(cnt)
              FOR src IN ( 1 "cnt1",  2 "cnt2",  3 "cnt3")
           )
      ORDER BY 1]';
        l_sql := REPLACE (l_sql, 'p_com_org', p_com_org);
        l_sql :=
            REPLACE (l_sql, 'p_d_start', TO_CHAR (p_d_start, 'dd.mm.yyyy'));
        l_sql := REPLACE (l_sql, 'p_d_end', TO_CHAR (p_d_end, 'dd.mm.yyyy'));
        rdm$rtfl.adddataset (p_jbr_id, 'dssum', l_sql);

        rdm$rtfl.putreporttoworkingqueue (p_jbr_id);
    END;

    ---------------------------------------------------------------------------------------------------
    --Ініціалізація процесу підготовки звіту "Звіт щодо кількості зареєстрованих заяв надавачів"
    ---------------------------------------------------------------------------------------------------
    PROCEDURE reg_report_g_reg_appeals (p_com_org       appeal.com_org%TYPE,
                                        p_d_start       DATE,
                                        p_d_end         DATE,
                                        p_jbr_id    OUT NUMBER)
    IS
    BEGIN
        tools.writemsg ('DNET$APPEALS_REPORTS.' || $$PLSQL_UNIT);

        p_jbr_id := rdm$rtfl.initreport (get_rt_by_code ('PROV_APPL_REG_R1'));

        rdm$rtfl.addparam (p_jbr_id,
                           'rpt_dt',
                           TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS'));
        rdm$rtfl.addparam (p_jbr_id,
                           'rpt_start_dt',
                           TO_CHAR (p_d_start, 'DD.MM.YYYY'));
        rdm$rtfl.addparam (p_jbr_id,
                           'rpt_end_dt',
                           TO_CHAR (p_d_end, 'DD.MM.YYYY'));
        rdm$rtfl.adddataset (
            p_jbr_id,
            'ds',
               q'[SELECT coalesce(org_code, obl_code) AS c1, coalesce(org_name, obl_name) AS c2, c3, c4, c5, c6, c7, c8, c9
  FROM (SELECT obl_code,
               obl_name,
               org_code,
               org_name,
               COUNT(DISTINCT(ap_id)) AS c3,
               COUNT(DISTINCT(CASE ap_st WHEN 'J' THEN ap_id END)) AS c4,
               COUNT(DISTINCT(CASE ap_st WHEN 'X' THEN ap_id END)) AS c5,
               COUNT(DISTINCT(CASE WHEN ap_st IN ('VW', 'VE', 'VO') THEN ap_id END)) AS c6,
               COUNT(DISTINCT(CASE ap_st WHEN 'V' THEN ap_id END)) AS c7,
               COUNT(DISTINCT(CASE ap_st WHEN 'B' THEN ap_id END)) AS c8,
               COUNT(DISTINCT(CASE WHEN ap_st = 'X' AND (prev_st = 'B' OR hs_wu IS NULL) THEN ap_id END)) AS c9,
               GROUPING(obl_code) + GROUPING(obl_name) + GROUPING(org_code) + GROUPING(org_name) AS grp_lvl
          FROM (SELECT oo.org_code AS obl_code,
                       oo.org_name AS obl_name,
                       ot.org_code,
                       ot.org_name,
                       a.ap_id,
                       a.ap_st,
                       a.com_wu,
                       l.apl_st,
                       coalesce(l.apl_st_old, (CASE a.ap_st WHEN l.apl_st THEN lag(l.apl_st) over(PARTITION BY a.ap_id ORDER BY h.hs_dt, l.apl_id) END)) AS prev_st,
                       h.hs_wu
                  FROM uss_visit.v_appeal a
                  JOIN (SELECT d.org_id,
                              d.org_code,
                              d.org_name,
                              d.org_to,
                              decode(d.org_to, 31, d.org_id, decode(p.org_to, 31, p.org_id, decode(g.org_to, 31, g.org_id, decode(u.org_to, 31, u.org_id, nvl(d.org_id, 0))))) org_31
                         FROM ikis_sys.v_opfu d
                         JOIN ikis_sys.v_opfu p ON d.org_org = p.org_id
                         JOIN ikis_sys.v_opfu g ON p.org_org = g.org_id
                         LEFT JOIN ikis_sys.v_opfu u ON g.org_org = u.org_id) ot ON ot.org_id = a.com_org
                  JOIN ikis_sys.v_opfu oo ON oo.org_id = coalesce(ot.org_31, a.com_org)
                  LEFT JOIN uss_visit.v_ap_log l ON l.apl_ap = a.ap_id
                  LEFT JOIN uss_visit.v_histsession h ON h.hs_id = l.apl_hs
                 WHERE a.ap_tp = 'G'
                   AND a.ap_create_dt >= to_date(']'
            || TO_CHAR (p_d_start, 'DD.MM.YYYY')
            || q'[', 'DD.MM.YYYY')
                   AND a.ap_create_dt < to_date(']'
            || TO_CHAR (p_d_end + 1, 'DD.MM.YYYY')
            || q'[', 'DD.MM.YYYY')]'
            || (CASE
                    WHEN p_com_org IS NOT NULL
                    THEN
                           '
                   AND a.com_org IN (SELECT org_id
                                       FROM ikis_sys.v_opfu
                                     CONNECT BY PRIOR org_id = org_org
                                      START WITH org_id = '
                        || TO_CHAR (
                               CASE p_com_org
                                   WHEN 50001 THEN 50000
                                   ELSE p_com_org
                               END)
                        || ')'
                END)
            || ')
         GROUP BY ROLLUP(obl_code, obl_name, org_code, org_name))
 WHERE (obl_code != org_code OR org_code IS NULL)
   AND obl_code IS NOT NULL
   AND obl_name IS NOT NULL
   AND grp_lvl != 1
 ORDER BY obl_code, coalesce(org_code, obl_code)');

        rdm$rtfl.putreporttoworkingqueue (p_jbr_id);
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Додаток 2 до Порядку, Опис документів/відомостей, що подаються реєстратору Реєстру надавачів та отримувачів соціальних послуг"
    -- params: p_rt_id - ідентифікатор звіту
    --         p_ap_id - ідентифікатор звернення
    -- note:   #76280
    FUNCTION annex_2_r1 (p_rt_id   IN rpt_templates.rt_id%TYPE,
                         p_ap_id   IN appeal.ap_id%TYPE)
        RETURN DECIMAL
    IS
        v_jbr_id     DECIMAL;
        v_user_pib   VARCHAR2 (250);
    BEGIN
        v_jbr_id := rdm$rtfl.initreport (p_rt_id);

        FOR data_cur IN (SELECT MAX (a.ap_num)                              AS ap_num,
                                MAX (a.ap_reg_dt)                           AS dt,
                                MAX (
                                    CASE apda.apda_nda
                                        WHEN 953
                                        THEN
                                            TRIM (apda.apda_val_string)
                                    END)                                    AS org_tp,
                                MAX (
                                    CASE apda.apda_nda
                                        WHEN 956
                                        THEN
                                            TRIM (apda.apda_val_string)
                                    END)                                    AS org_name,
                                MAX (
                                    CASE apda.apda_nda
                                        WHEN 963
                                        THEN
                                            TRIM (apda.apda_val_string)
                                    END)                                    AS fop_ln,
                                MAX (
                                    CASE apda.apda_nda
                                        WHEN 964
                                        THEN
                                            TRIM (apda.apda_val_string)
                                    END)                                    AS fop_fn,
                                MAX (
                                    CASE apda.apda_nda
                                        WHEN 965
                                        THEN
                                            TRIM (apda.apda_val_string)
                                    END)                                    AS fop_sn,
                                MAX (
                                    (SELECT TRIM (
                                                FIRST_VALUE (
                                                    tools.init_cap (
                                                           p.app_ln
                                                        || ' '
                                                        || p.app_fn
                                                        || ' '
                                                        || p.app_mn))
                                                    OVER (ORDER BY p.app_id))
                                       FROM v_ap_person p
                                      WHERE     p.app_ap = p_ap_id
                                            AND p.app_tp = 'Z'
                                            AND p.history_status = 'A'))    AS app_pib
                           FROM v_appeal  a
                                LEFT JOIN v_ap_document apd
                                JOIN v_ap_document_attr apda
                                    ON     apda.apda_apd = apd.apd_id
                                       AND apda.apda_ap = p_ap_id
                                       AND apda.apda_nda IN (953,
                                                             956,
                                                             963,
                                                             964,
                                                             965)
                                       AND apda.history_status = 'A'
                                       AND apda.apda_val_string IS NOT NULL
                                    ON     apd.apd_ap = p_ap_id
                                       AND apd.apd_ndt = 700
                                       AND apd.history_status = 'A'
                          WHERE a.ap_id = p_ap_id)
        LOOP
            rdm$rtfl.addparam (v_jbr_id,
                               'ap_num',
                               COALESCE (data_cur.ap_num, '_____________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_name',
                COALESCE (
                    TRIM (
                        (CASE data_cur.org_tp
                             WHEN 'O'
                             THEN
                                 data_cur.org_name
                             WHEN 'F'
                             THEN
                                    data_cur.fop_ln
                                 || ' '
                                 || data_cur.fop_fn
                                 || ' '
                                 || data_cur.fop_sn
                         END)),
                    '________________________________________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_name_lbl',
                (CASE
                     WHEN    data_cur.org_tp NOT IN ('O', 'F')
                          OR COALESCE (data_cur.org_name,
                                       data_cur.fop_ln,
                                       data_cur.fop_fn,
                                       data_cur.fop_sn)
                                 IS NULL
                     THEN
                         '(повне найменування заявника/надавача соціальних послуг)'
                 END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'app_pib',
                COALESCE (
                    TRIM (data_cur.app_pib),
                    '________________________________________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'app_pib_lbl',
                (CASE
                     WHEN data_cur.app_pib IS NULL
                     THEN
                         '(прізвище, ім’я, по батькові (за наявності) особи, що подає відомості)'
                 END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'app_pib1',
                COALESCE (data_cur.app_pib,
                          '_________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'app_pib_lbl1',
                (CASE
                     WHEN data_cur.app_pib IS NULL
                     THEN
                         '(прізвище, ім’я, по батькові (за наявності) заявника)'
                 END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'dt',
                COALESCE (TO_CHAR (data_cur.dt, 'DD.MM.YYYY'), '___________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'dt_lbl',
                (CASE WHEN data_cur.dt IS NULL THEN '(дата)' END));
        END LOOP;

        BEGIN
            v_user_pib := TRIM (tools.getcurruserpib);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        rdm$rtfl.addparam (
            v_jbr_id,
            'emp_pib',
            COALESCE (
                v_user_pib,
                '________________________________________________________________'));
        rdm$rtfl.addparam (
            v_jbr_id,
            'emp_pib_lbl',
            (CASE
                 WHEN v_user_pib IS NULL
                 THEN
                     '(підпис, прізвище, ім’я, по батькові (за наявності) особи, яка прийняла документи)'
             END));
        rdm$rtfl.addparam (v_jbr_id,
                           'curr_dt',
                           TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
        rdm$rtfl.adddataset (
            v_jbr_id,
            'ds',
               q'[SELECT row_number() over(ORDER BY dt.ndt_order) AS c1,
        dt.ndt_name_short AS c2,
        MAX(CASE
              WHEN a.nda_pt = 223 AND da.apda_val_string IS NOT NULL THEN
               (SELECT dic_sname FROM uss_ndi.v_ddn_doc_vid WHERE dic_value = da.apda_val_string)
            END) AS c3,
        MAX(CASE
              WHEN a.nda_pt = 224 AND upper(TRIM(a.nda_name)) = 'ЗАГАЛЬНА КІЛЬКІСТЬ АРКУШІВ' THEN
               da.apda_val_int
            END) AS c4,
        dt.ndt_order
   FROM uss_visit.v_ap_document d
   JOIN uss_ndi.v_ndi_document_type dt ON dt.ndt_id = d.apd_ndt
                                      AND dt.ndt_is_vt_visible = 'T'
   LEFT JOIN uss_visit.v_ap_document_attr da
             JOIN uss_ndi.v_ndi_document_attr a ON a.nda_id = da.apda_nda ON da.apda_apd = d.apd_id
                                                                         AND da.apda_ap = ]'
            || TO_CHAR (p_ap_id)
            || q'[
                                                                         AND da.history_status = 'A'
  WHERE d.apd_ap = ]'
            || TO_CHAR (p_ap_id)
            || q'[
    AND d.apd_ndt != 730
    AND d.history_status = 'A'
  GROUP BY dt.ndt_name_short, dt.ndt_order]');

        rdm$rtfl.putreporttoworkingqueue (v_jbr_id);

        RETURN v_jbr_id;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Додаток 3 до Порядку, Заява надавача соціальних послуг"
    -- params: p_rt_id - ідентифікатор звіту
    --         p_ap_id - ідентифікатор звернення
    -- note:   #76254
    FUNCTION annex_3_r1 (p_rt_id   IN rpt_templates.rt_id%TYPE,
                         p_ap_id   IN appeal.ap_id%TYPE)
        RETURN DECIMAL
    IS
        l_str      VARCHAR2 (32000);
        v_jbr_id   DECIMAL;
    BEGIN
        v_jbr_id := rdm$rtfl.initreport (p_rt_id);

        FOR c
            IN (SELECT MAX (ap_num)
                           AS ap_num,
                       MAX (ap_reg_dt)
                           AS ap_reg_dt,
                       MAX (ap_create_dt)
                           AS ap_create_dt,
                       MAX ( (SELECT TRIM (org_name)
                                FROM ikis_sys.v_opfu
                               WHERE org_id = com_org))
                           AS curr_org_name,
                       MAX (
                           (SELECT app_name
                              FROM (SELECT app_id,
                                           tools.init_cap (
                                                  app_ln
                                               || ' '
                                               || app_fn
                                               || ' '
                                               || app_mn)                AS app_name,
                                           FIRST_VALUE (app_id)
                                               OVER (ORDER BY app_id)    AS frst_app
                                      FROM v_ap_person
                                     WHERE     app_ap = p_ap_id
                                           AND app_tp = 'Z'
                                           AND history_status = 'A') app
                             WHERE app_id = frst_app))
                           AS app_pib,
                       MAX (
                           CASE da.apda_nda
                               WHEN 954 THEN TRIM (da.apda_val_string)
                           END)
                           AS rnsp_tp,                  --"Тип звернення РНСП"
                       MAX (
                           CASE da.apda_nda
                               WHEN 953 THEN TRIM (da.apda_val_string)
                           END)
                           AS org_tp,                                --Тип НСП
                       MAX (
                           CASE da.apda_nda
                               WHEN 956 THEN TRIM (da.apda_val_string)
                           END)
                           AS org_name, --"Повне найменування юридичної особи"
                       MAX (
                           CASE da.apda_nda
                               WHEN 957 THEN TRIM (da.apda_val_string)
                           END)
                           AS org_sname, --"Скорочене найменування юридичної особи"
                       MAX (
                           CASE da.apda_nda
                               WHEN 963 THEN TRIM (da.apda_val_string)
                           END)
                           AS fop_ln,                       --"Прізвище" (ФОП)
                       MAX (
                           CASE da.apda_nda
                               WHEN 964 THEN TRIM (da.apda_val_string)
                           END)
                           AS fop_fn,                           --"Ім’я" (ФОП)
                       MAX (
                           CASE da.apda_nda
                               WHEN 965 THEN TRIM (da.apda_val_string)
                           END)
                           AS fop_sn,                    --"По батькові" (ФОП)
                       MAX (
                           CASE da.apda_nda
                               WHEN 955 THEN TRIM (da.apda_val_string)
                           END)
                           AS jur_edrpo,             --"Код ЄДРПОУ" (юр.особа)
                       MAX (
                           CASE da.apda_nda
                               WHEN 960 THEN TRIM (da.apda_val_string)
                           END)
                           AS fop_rnokpp_discl, --"Ознакa відмови особи від РНОКПП" (ФОП)
                       MAX (
                           CASE da.apda_nda
                               WHEN 961 THEN TRIM (da.apda_val_string)
                           END)
                           AS fop_rnokpp,                     --"РНОКПП" (ФОП)
                       MAX (
                           CASE da.apda_nda
                               WHEN 962 THEN TRIM (da.apda_val_string)
                           END)
                           AS fop_doc, --"Реквізити документу, що посвідчує особу" (ФОП)
                       MAX (
                           CASE
                               WHEN     da.apda_nda = 958
                                    AND da.apda_val_string IS NOT NULL
                               THEN
                                   (SELECT dic_sname
                                      FROM uss_ndi.v_ddn_forms_mngm
                                     WHERE dic_value = da.apda_val_string)
                           END)
                           AS jur_mngm, --"Організаційно-правова форма" (юр.особа)
                       MAX (
                           CASE
                               WHEN     da.apda_nda = 966
                                    AND da.apda_val_string IS NOT NULL
                               THEN
                                   (SELECT dic_sname
                                      FROM uss_ndi.v_ddn_forms_mngm
                                     WHERE dic_value = da.apda_val_string)
                           END)
                           AS fop_mngm,  --"Організаційно-правова форма" (ФОП)
                       MAX (
                           CASE da.apda_nda
                               WHEN 959 THEN TRIM (da.apda_val_string)
                           END)
                           AS jur_vid, --"Вид громадського об’єднання, благодійної чи релігійної організації" (юр.особа)
                       MAX (
                           CASE da.apda_nda
                               WHEN 967 THEN TRIM (da.apda_val_string)
                           END)
                           AS fop_vid, --"Вид громадського об’єднання, благодійної чи релігійної організації" (ФОП)
                          MAX (
                              CASE da.apda_nda
                                  WHEN 968
                                  THEN
                                      LTRIM (
                                          TRIM (da.apda_val_string) || '; ',
                                          '; ')
                              END)
                       || MAX (
                              CASE da.apda_nda
                                  WHEN 969
                                  THEN
                                      LTRIM (
                                          TRIM (da.apda_val_string) || '; ',
                                          '; ')
                              END)
                       || MAX (
                              CASE da.apda_nda
                                  WHEN 970 THEN TRIM (da.apda_val_string)
                              END)
                           AS org_contact, --"контактні телефони", "електронна адреса", "адреса веб-сайту/іншого інформаційного ресурсу"
                       RTRIM (
                           (   MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 700
                                            AND da.apda_nda = 972
                                            AND TRIM (da.apda_val_string)
                                                    IS NOT NULL
                                       THEN
                                           TRIM (da.apda_val_string) || ', '
                                   END)
                            || (LTRIM (
                                       MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 700
                                                    AND da.apda_nda = 971
                                               THEN
                                                   COALESCE (
                                                       (CASE
                                                            WHEN da.apda_val_id
                                                                     IS NOT NULL
                                                            THEN
                                                                get_katottg_info (
                                                                    da.apda_val_id)
                                                        END),
                                                       da.apda_val_string)
                                           END)
                                    || ', ',
                                    ', '))
                            || COALESCE (
                                   LTRIM (
                                          MAX (
                                              CASE
                                                  WHEN     d.apd_ndt = 700
                                                       AND da.apda_nda = 975
                                                  THEN
                                                      COALESCE (
                                                          (CASE
                                                               WHEN da.apda_val_id
                                                                        IS NOT NULL
                                                               THEN
                                                                   get_street_info (
                                                                       da.apda_val_id)
                                                           END),
                                                          TRIM (
                                                              da.apda_val_string))
                                              END)
                                       || ', ',
                                       ', '),
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt = 700
                                                AND da.apda_nda = 2159
                                                AND TRIM (da.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  'вул. '
                                               || TRIM (da.apda_val_string)
                                               || ', '
                                       END))
                            || MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 700
                                            AND da.apda_nda = 976
                                            AND TRIM (da.apda_val_string)
                                                    IS NOT NULL
                                       THEN
                                              'буд. '
                                           || TRIM (da.apda_val_string)
                                           || ', '
                                   END)
                            || MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 700
                                            AND da.apda_nda = 977
                                            AND TRIM (da.apda_val_string)
                                                    IS NOT NULL
                                       THEN
                                              'корп. '
                                           || TRIM (da.apda_val_string)
                                           || ', '
                                   END)
                            || MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 700
                                            AND da.apda_nda = 978
                                            AND TRIM (da.apda_val_string)
                                                    IS NOT NULL
                                       THEN
                                              'оф./кв./пр. '
                                           || TRIM (da.apda_val_string)
                                   END)),
                           ', ')
                           AS org_addr,            --Місцезнаходження надавача
                       MAX (
                           CASE
                               WHEN da.apda_nda = 1093
                               THEN
                                   TRIM (da.apda_val_string)
                           END)
                           AS fact_addr_same,
                       RTRIM (
                           (   MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 700
                                            AND da.apda_nda = 980
                                            AND TRIM (da.apda_val_string)
                                                    IS NOT NULL
                                       THEN
                                           TRIM (da.apda_val_string) || ', '
                                   END)
                            || (LTRIM (
                                       MAX (
                                           CASE
                                               WHEN     d.apd_ndt = 700
                                                    AND da.apda_nda = 979
                                               THEN
                                                   COALESCE (
                                                       (CASE
                                                            WHEN da.apda_val_id
                                                                     IS NOT NULL
                                                            THEN
                                                                get_katottg_info (
                                                                    da.apda_val_id)
                                                        END),
                                                       da.apda_val_string)
                                           END)
                                    || ', ',
                                    ', '))
                            || COALESCE (
                                   LTRIM (
                                          MAX (
                                              CASE
                                                  WHEN     d.apd_ndt = 700
                                                       AND da.apda_nda = 983
                                                  THEN
                                                      COALESCE (
                                                          (CASE
                                                               WHEN da.apda_val_id
                                                                        IS NOT NULL
                                                               THEN
                                                                   get_street_info (
                                                                       da.apda_val_id)
                                                           END),
                                                          TRIM (
                                                              da.apda_val_string))
                                              END)
                                       || ', ',
                                       ', '),
                                   MAX (
                                       CASE
                                           WHEN     d.apd_ndt = 700
                                                AND da.apda_nda = 2160
                                                AND TRIM (da.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  'вул. '
                                               || TRIM (da.apda_val_string)
                                               || ', '
                                       END))
                            || MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 700
                                            AND da.apda_nda = 984
                                            AND TRIM (da.apda_val_string)
                                                    IS NOT NULL
                                       THEN
                                              'буд. '
                                           || TRIM (da.apda_val_string)
                                           || ', '
                                   END)
                            || MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 700
                                            AND da.apda_nda = 985
                                            AND TRIM (da.apda_val_string)
                                                    IS NOT NULL
                                       THEN
                                              'корп. '
                                           || TRIM (da.apda_val_string)
                                           || ', '
                                   END)
                            || MAX (
                                   CASE
                                       WHEN     d.apd_ndt = 700
                                            AND da.apda_nda = 986
                                            AND TRIM (da.apda_val_string)
                                                    IS NOT NULL
                                       THEN
                                              'оф./кв./пр. '
                                           || TRIM (da.apda_val_string)
                                   END)),
                           ', ')
                           AS org_fact_addr, --Місце надання соціальних послуг
                       MAX (
                           CASE da.apda_nda
                               WHEN 1094 THEN TRIM (da.apda_val_string)
                           END)
                           AS resp_pers_pos, --"Посада керівника юридичної особи/ фізичної особи - підприємця"
                          LTRIM (
                              MAX (
                                  CASE
                                      WHEN     da.apda_nda = 1095
                                           AND TRIM (da.apda_val_string)
                                                   IS NOT NULL
                                      THEN
                                          TRIM (da.apda_val_string) || ' '
                                  END))
                       || LTRIM (
                              MAX (
                                  CASE
                                      WHEN     da.apda_nda = 1096
                                           AND TRIM (da.apda_val_string)
                                                   IS NOT NULL
                                      THEN
                                          TRIM (da.apda_val_string) || ' '
                                  END))
                       || MAX (
                              CASE da.apda_nda
                                  WHEN 1097 THEN TRIM (da.apda_val_string)
                              END)
                           AS resp_pers_pib, --"Прізвище, Ім’я, По батькові керівника юридичної особи/ фізичної особи – підприємця"
                       LTRIM (
                           TRIM (
                                  MAX (
                                      CASE da.apda_nda
                                          WHEN 2289
                                          THEN
                                              TRIM (da.apda_val_string)
                                      END)
                               || MAX (
                                      CASE
                                          WHEN     da.apda_nda = 2291
                                               AND TRIM (da.apda_val_string)
                                                       IS NOT NULL
                                          THEN
                                                 ' №'
                                              || TRIM (da.apda_val_string)
                                      END)
                               || MAX (
                                      CASE
                                          WHEN     da.apda_nda = 2290
                                               AND da.apda_val_dt IS NOT NULL
                                          THEN
                                                 ', '
                                              || TO_CHAR (da.apda_val_dt,
                                                          'DD.MM.YYYY')
                                      END)),
                           ', ')
                           AS resp_pers_doc --"Реквізити документу, що підтверджує повноваження уповноваженої особи"
                  FROM v_appeal
                       LEFT JOIN v_ap_document d
                       JOIN v_ap_document_attr da
                           ON     da.apda_apd = d.apd_id
                              AND da.apda_ap = p_ap_id
                              AND da.history_status = 'A'
                           ON     d.apd_ap = p_ap_id
                              AND d.apd_ndt IN (700, 726)
                              AND d.history_status = 'A'
                 WHERE ap_id = p_ap_id)
        LOOP
            rdm$rtfl.addparam (v_jbr_id,
                               'ap_reg_dt',
                               TO_CHAR (c.ap_reg_dt, 'DD.MM.YYYY'));
            rdm$rtfl.addparam (v_jbr_id, 'ap_num', c.ap_num);
            rdm$rtfl.addparam (v_jbr_id, 'app_pib', c.app_pib);
            rdm$rtfl.addparam (
                v_jbr_id,
                'ap_create_dt',
                COALESCE (TO_CHAR (c.ap_create_dt, 'DD.MM.YYYY'),
                          '________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'ap_create_dt_lbl',
                (CASE WHEN c.ap_create_dt IS NULL THEN '(дата)' END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'curr_org_name',
                COALESCE (c.curr_org_name,
                          '________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'curr_org_name_lbl',
                (CASE
                     WHEN c.curr_org_name IS NULL
                     THEN
                         '(найменування реєстратора, якому подається заява)'
                 END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'm1',
                (CASE c.rnsp_tp WHEN 'A' THEN v_check_mark END)); --про внесення документів/відомостей до Реєстру надавачів та отримувачів соціальних послуг
            rdm$rtfl.addparam (
                v_jbr_id,
                'm2',
                (CASE c.rnsp_tp WHEN 'U' THEN v_check_mark END)); --про зміну відомостей в Реєстрі
            rdm$rtfl.addparam (
                v_jbr_id,
                'm3',
                (CASE c.rnsp_tp WHEN 'D' THEN v_check_mark END)); --про виключення з Реєстру надавачів та отримувачів соціальних послуг
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_name',
                COALESCE (
                    (CASE c.org_tp
                         WHEN 'O'
                         THEN
                             LTRIM (
                                 RTRIM (c.org_name || ', ' || c.org_sname,
                                        ', '),
                                 ', ')
                         WHEN 'F'
                         THEN
                             TRIM (
                                    c.fop_ln
                                 || ' '
                                 || c.fop_fn
                                 || ' '
                                 || c.fop_sn)
                     END),
                    '________________________________________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_code',
                COALESCE (
                    TRIM (
                        (CASE
                             WHEN c.org_tp = 'O'
                             THEN
                                 c.jur_edrpo
                             WHEN c.org_tp = 'F' AND c.fop_rnokpp_discl = 'T'
                             THEN
                                 c.fop_doc
                             WHEN c.org_tp = 'F'
                             THEN
                                 c.fop_rnokpp
                         END)),
                    '________________________________________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_tp',
                COALESCE (
                    c.jur_mngm,
                    c.fop_mngm,
                    c.jur_vid,
                    c.fop_vid,
                    '________________________________________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_contact',
                COALESCE (
                    c.org_contact,
                    '___________________________________________________________________________'));

            /*#92762
            якщо apda_nda 1093 =F, то:
            поле1 - виводимо d.apd_ndt = 700(nda = 972 , nda = 971...)  org_addr, --Місцезнаходження надавача
            поле2 - виводимо apd_ndt = 700 (nda = 980, nda = 979...)    org_fact_addr, --Місце надання соціальних послуг
            поле2 - виводимо адреси з 750

            якщо apda_nda 1093 =Т, то:
            поле1 - виводимо d.apd_ndt = 700(nda = 972 , nda = 971...)  org_addr --Місцезнаходження надавача
            поле2 - виводимо адреси з 750
            */

            --Ахтунг! може бути кілька адрес, тому може бути кілька 750-х актуальних документів
            SELECT LISTAGG (   '  '
                            || NVL2 (dnet$appeals_reports.get_ap_document_attr_str (
                                         p.app_ap,
                                         p.app_id,
                                         750,
                                         1133,
                                         d.apd_id),
                                        dnet$appeals_reports.get_ap_document_attr_str (
                                            p.app_ap,
                                            p.app_id,
                                            750,
                                            1133,
                                            d.apd_id)
                                     || ' ',
                                     NULL)
                            || LTRIM (   COALESCE (dnet$appeals_reports.get_katottg_info (
                                                       dnet$appeals_reports.get_ap_document_attr_id (
                                                           p.app_ap,
                                                           p.app_id,
                                                           750,
                                                           1098,
                                                           d.apd_id)),
                                                   dnet$appeals_reports.get_ap_document_attr_str (
                                                       p.app_ap,
                                                       p.app_id,
                                                       750,
                                                       1098,
                                                       d.apd_id))
                                      || ' ',
                                      ', ')
                            || NVL2 (COALESCE (dnet$appeals_reports.get_street_info (
                                                   dnet$appeals_reports.get_ap_document_attr_id (
                                                       p.app_ap,
                                                       p.app_id,
                                                       750,
                                                       2535,
                                                       d.apd_id)),
                                               dnet$appeals_reports.get_ap_document_attr_str (
                                                   p.app_ap,
                                                   p.app_id,
                                                   750,
                                                   2536,
                                                   d.apd_id)),
                                        COALESCE (dnet$appeals_reports.get_street_info (
                                                      dnet$appeals_reports.get_ap_document_attr_id (
                                                          p.app_ap,
                                                          p.app_id,
                                                          750,
                                                          2535,
                                                          d.apd_id)),
                                                  dnet$appeals_reports.get_ap_document_attr_str (
                                                      p.app_ap,
                                                      p.app_id,
                                                      750,
                                                      2536,
                                                      d.apd_id))
                                     || ' ',
                                     NULL)
                            || NVL2 (dnet$appeals_reports.get_ap_document_attr_str (
                                         p.app_ap,
                                         p.app_id,
                                         750,
                                         2537,
                                         d.apd_id),
                                        'буд. '
                                     || dnet$appeals_reports.get_ap_document_attr_str (
                                            p.app_ap,
                                            p.app_id,
                                            750,
                                            2537,
                                            d.apd_id)
                                     || ' ',
                                     NULL)
                            || NVL2 (dnet$appeals_reports.get_ap_document_attr_str (
                                         p.app_ap,
                                         p.app_id,
                                         750,
                                         2538,
                                         d.apd_id),
                                        'корп. '
                                     || dnet$appeals_reports.get_ap_document_attr_str (
                                            p.app_ap,
                                            p.app_id,
                                            750,
                                            2538,
                                            d.apd_id)
                                     || ' ',
                                     NULL)
                            || NVL2 (dnet$appeals_reports.get_ap_document_attr_str (
                                         p.app_ap,
                                         p.app_id,
                                         750,
                                         2539,
                                         d.apd_id),
                                        'оф./кв./пр. '
                                     || dnet$appeals_reports.get_ap_document_attr_str (
                                            p.app_ap,
                                            p.app_id,
                                            750,
                                            2539,
                                            d.apd_id)
                                     || ' ',
                                     NULL),
                            ';\par')
                   WITHIN GROUP (ORDER BY p.app_tp)    adr
              INTO l_str
              FROM ap_person p, ap_document d
             WHERE     p.app_ap = p_ap_id
                   AND p.history_status = 'A'
                   AND d.apd_ap = p.app_ap
                   AND d.apd_ndt = 750
                   AND d.history_status = 'A'
                   AND d.apd_app = p.app_id;

            --raise_application_error(-20000, l_str);
            --#92762 поле1
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_addr',
                COALESCE (
                    c.org_addr, --CASE c.fact_addr_same WHEN 'T' THEN c.org_addr ELSE c.org_fact_addr END,
                    '___________________________________________________________________________'));
            --#92762 поле2
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_fact_addr',
                COALESCE (
                    (   CASE c.fact_addr_same
                            WHEN 'T' THEN NULL
                            ELSE c.org_fact_addr
                        END
                     || '\par'
                     || l_str),
                    '________________________________________________________________'));

            rdm$rtfl.addparam (
                v_jbr_id,
                'resp_pers_doc',
                COALESCE (
                    c.resp_pers_doc,
                    '__________________________________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'resp_pers_info',
                (   c.resp_pers_pos
                 || (CASE
                         WHEN     c.resp_pers_pos IS NOT NULL
                              AND c.resp_pers_pib IS NOT NULL
                         THEN
                             '\par'
                     END)
                 || c.resp_pers_pib));
            rdm$rtfl.addparam (
                v_jbr_id,
                'resp_pers_info_lbl',
                (CASE
                     WHEN COALESCE (c.resp_pers_pos, c.resp_pers_pib) IS NULL
                     THEN
                            '\fs20____________________________________________\par'
                         || '(посада, прізвище, ім’я, по батькові (за наявності)\par'
                         || '____________________________________________\par'
                         || 'керівника юридичної особи / прізвище, ім’я, по\par'
                         || '____________________________________________\par'
                         || 'батькові (за наявності) фізичної особи - підприємця'
                 END));
        END LOOP;

        rdm$rtfl.adddataset (
            v_jbr_id,
            'ds',
               q'[SELECT row_number() over(ORDER BY dt.ndt_order) AS c1,
         dt.ndt_name_short AS c2,
         MAX(CASE
               WHEN a.nda_pt = 224 AND upper(TRIM(a.nda_name)) = 'КІЛЬКІСТЬ ПРИМІРНИКІВ' THEN
                da.apda_val_int
             END) AS c3,
         MAX(CASE
               WHEN a.nda_pt = 224 AND upper(TRIM(a.nda_name)) = 'ЗАГАЛЬНА КІЛЬКІСТЬ АРКУШІВ' THEN
                da.apda_val_int
             END) AS c4,
         dt.ndt_order
    FROM uss_visit.v_ap_document d
    JOIN uss_ndi.v_ndi_document_type dt ON dt.ndt_id = d.apd_ndt
                                       AND dt.ndt_is_vt_visible = 'T'
    LEFT JOIN uss_visit.v_ap_document_attr da
              JOIN uss_ndi.v_ndi_document_attr a ON a.nda_id = da.apda_nda ON da.apda_apd = d.apd_id
                                                                          AND da.apda_ap = ]'
            || TO_CHAR (p_ap_id)
            || q'[
                                                                          AND da.history_status = 'A'
   WHERE d.apd_ap = ]'
            || TO_CHAR (p_ap_id)
            || q'[
     AND d.history_status = 'A'
     AND d.apd_ndt != 730
   GROUP BY dt.ndt_name_short, dt.ndt_order]');

        rdm$rtfl.putreporttoworkingqueue (v_jbr_id);
        RETURN v_jbr_id;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Додаток 4 до Порядку, Перелік соціальних послуг, які має право надавати надавач соціальних послуг, їх зміст та обсяг, умови і порядок отримання"
    -- params: p_rt_id - ідентифікатор звіту
    --         p_ap_id - ідентифікатор звернення
    -- note:   #76303
    FUNCTION annex_4_r1 (p_rt_id   IN rpt_templates.rt_id%TYPE,
                         p_ap_id   IN appeal.ap_id%TYPE)
        RETURN DECIMAL
    IS
        v_jbr_id   DECIMAL;
    BEGIN
        v_jbr_id := rdm$rtfl.initreport (p_rt_id);

        FOR data_cur
            IN (SELECT MAX (
                           CASE apda.apda_nda
                               WHEN 953 THEN TRIM (apda.apda_val_string)
                           END)    AS org_tp,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 956 THEN TRIM (apda.apda_val_string)
                           END)    AS org_name,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 963 THEN TRIM (apda.apda_val_string)
                           END)    AS fop_ln,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 964 THEN TRIM (apda.apda_val_string)
                           END)    AS fop_fn,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 965 THEN TRIM (apda.apda_val_string)
                           END)    AS fop_sn,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 1094 THEN TRIM (apda.apda_val_string)
                           END)    AS head_pos,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 1095 THEN TRIM (apda.apda_val_string)
                           END)    AS head_ln,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 1096 THEN TRIM (apda.apda_val_string)
                           END)    AS head_fn,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 1097 THEN TRIM (apda.apda_val_string)
                           END)    AS head_sn,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 1133 THEN TRIM (apda.apda_val_string)
                           END)    AS head_doc,
                       MAX (
                           CASE apda.apda_nda
                               WHEN 1098 THEN apda.apda_val_dt
                           END)    AS sign_dt
                  FROM v_ap_document  apd
                       JOIN v_ap_document_attr apda
                           ON     apda.apda_apd = apd.apd_id
                              AND apda.apda_ap = p_ap_id
                              AND apda.apda_nda IN (953,
                                                    956,
                                                    963,
                                                    964,
                                                    965,
                                                    1094,
                                                    1095,
                                                    1096,
                                                    1097,
                                                    1133,
                                                    1098)
                              AND apda.history_status = 'A'
                 WHERE     apd.apd_ap = p_ap_id
                       AND apd.apd_ndt = 700
                       AND apd.history_status = 'A')
        LOOP
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_name',
                COALESCE (
                    (CASE data_cur.org_tp
                         WHEN 'O'
                         THEN
                             data_cur.org_name
                         WHEN 'F'
                         THEN
                             TRIM (
                                    data_cur.fop_ln
                                 || ' '
                                 || data_cur.fop_fn
                                 || ' '
                                 || data_cur.fop_sn)
                     END),
                    '_____________________________________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'org_name_lbl',
                (CASE
                     WHEN    data_cur.org_tp NOT IN ('O', 'F')
                          OR COALESCE (data_cur.org_name,
                                       data_cur.fop_ln,
                                       data_cur.fop_fn,
                                       data_cur.fop_sn)
                                 IS NULL
                     THEN
                         '(повне найменування заявника/надавача соціальних послуг)'
                 END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'app_info',
                   RTRIM (
                          (CASE
                               WHEN data_cur.head_pos IS NOT NULL
                               THEN
                                   data_cur.head_pos || '\par'
                           END)
                       || (CASE
                               WHEN data_cur.head_ln IS NOT NULL
                               THEN
                                   data_cur.head_ln || ' '
                           END)
                       || (CASE
                               WHEN data_cur.head_fn IS NOT NULL
                               THEN
                                   data_cur.head_fn || ' '
                           END)
                       || (CASE
                               WHEN data_cur.head_sn IS NOT NULL
                               THEN
                                   data_cur.head_sn
                           END),
                       '\par')
                || (CASE
                        WHEN data_cur.head_doc IS NOT NULL
                        THEN
                            '\par' || data_cur.head_doc || ' '
                    END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'app_info_lbl',
                (CASE
                     WHEN COALESCE (data_cur.head_pos,
                                    data_cur.head_ln,
                                    data_cur.head_fn,
                                    data_cur.head_sn,
                                    data_cur.head_doc)
                              IS NULL
                     THEN
                         '____________________________________________\par
  (посада, прізвище, ім’я, по батькові (за наявності)\par
  ____________________________________________\par
  керівника юридичної особи / прізвище, ім’я, по\par
  ____________________________________________\par
  батькові (за наявності) фізичної особи - підприємця\par
  ____________________________________________\par
  та документ, що підтверджує повноваження\par
  ____________________________________________\par
  уповноваженої особи)'
                 END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'dt',
                COALESCE (TO_CHAR (data_cur.sign_dt, 'DD.MM.YYYY'),
                          '________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'dt_lbl',
                (CASE WHEN data_cur.sign_dt IS NULL THEN '(дата)' END));
        END LOOP;

        rdm$rtfl.adddataset (
            v_jbr_id,
            'ds',
               q'[SELECT row_number() over(ORDER BY dt.ndt_order, t.apd_id) AS c1,
                                  dt.ndt_name_short AS c2,
                                  t.apd_smmr AS c3,
                                  t.apd_cndtns AS c4,
                                  t.apd_pers_tariff AS c5,
                                  t.apd_fml_tariff AS c6
    FROM (SELECT d.apd_id,
                 d.apd_ndt,
                 MAX(CASE pt.pt_code
                       WHEN 'CONTENT' THEN
                        da.apda_val_string
                     END) AS apd_smmr,
                 MAX(CASE pt.pt_code
                       WHEN 'CONDITION' THEN
                        da.apda_val_string
                     END) AS apd_cndtns,
                 MAX(CASE pt.pt_code
                      WHEN 'SUM' THEN
                        da.apda_val_sum
                     END) AS apd_pers_tariff,
                 MAX(CASE pt.pt_code
                      WHEN 'SUM_FM' THEN
                        da.apda_val_sum
                     END) AS apd_fml_tariff
            FROM uss_visit.v_ap_document d
            JOIN uss_visit.v_ap_service s ON s.aps_id = d.apd_aps
                                         AND s.history_status = 'A'
            JOIN uss_visit.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                AND da.apda_ap = ]'
            || TO_CHAR (p_ap_id)
            || q'[
                                                AND da.history_status = 'A'
            JOIN uss_ndi.v_ndi_document_attr a ON a.nda_id = da.apda_nda
            JOIN uss_ndi.v_ndi_param_type pt ON pt.pt_id = a.nda_pt
                                            AND pt.pt_code IN ('CONTENT', 'CONDITION', 'SUM', 'SUM_FM')
           WHERE d.apd_ap = ]'
            || TO_CHAR (p_ap_id)
            || q'[
             AND d.history_status = 'A'
           GROUP BY d.apd_id, d.apd_ndt) t
    JOIN uss_ndi.v_ndi_document_type dt ON dt.ndt_id = t.apd_ndt]');

        rdm$rtfl.putreporttoworkingqueue (v_jbr_id);

        RETURN v_jbr_id;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Заява про надання соціальних послуг"
    -- params: p_rt_id - ідентифікатор звіту,
    --         p_ap_id - ідентифікатор звернення
    -- note:   #77571
    FUNCTION Ss_Prov_Appl_R1 (p_Rt_Id   IN Rpt_Templates.Rt_Id%TYPE,
                              p_Ap_Id   IN Appeal.Ap_Id%TYPE)
        RETURN DECIMAL
    IS
        v_Jbr_Id         DECIMAL;
        v_Tmp_Str        VARCHAR2 (4000);
        v_Ap_Id          Appeal.Ap_Id%TYPE;
        v_Ap_Reg_Dt      Appeal.Ap_Reg_Dt%TYPE;
        v_Ap_Num         Appeal.Ap_Num%TYPE;
        v_Numid          VARCHAR2 (10);
        v_Apr_Id         Ap_Declaration.Apr_Id%TYPE;
        v_Apr_Start_Dt   Ap_Declaration.Apr_Start_Dt%TYPE;
        v_Apr_Stop_Dt    Ap_Declaration.Apr_Stop_Dt%TYPE;
        v_Fact_Addr      VARCHAR2 (4000);
        v_Reg_Addr       VARCHAR2 (4000);
        v_Inv_Exist      VARCHAR2 (1);
        v_Inv_Info       VARCHAR2 (4000);

        l_F17            VARCHAR2 (4000);
        l_F18            DATE;
    BEGIN
        SELECT MAX (Ap_Id)         AS Ap_Id,
               MAX (Ap_Reg_Dt)     AS Ap_Reg_Dt,
               MAX (Ap_Num)        AS Ap_Num
          INTO v_Ap_Id, v_Ap_Reg_Dt, v_Ap_Num
          FROM v_Appeal
         WHERE Ap_Id = p_Ap_Id AND Ap_Tp = 'SS';

        --друкована форма доступна для друку у зверненнях про надання СП (SS)
        IF v_Ap_Id IS NULL
        THEN
            SELECT MAX (Dic_Name)
              INTO v_Tmp_Str
              FROM Uss_Ndi.v_Ddn_Ap_Tp
             WHERE Dic_Value = 'SS';

            Raise_Application_Error (
                -20000,
                   'Формування друкованої форми можливе тільки у зверненнях з типом "'
                || v_Tmp_Str
                || '"');
        ELSE
            FOR c
                IN (SELECT MAX (CASE Prs.Apd_Ndt WHEN 801 THEN 1 END)
                               AS Cntrl_Doc_Exist,
                           MAX (Prs.Pers_Name)
                               AS Pers_Name,
                           MAX (Prs.App_Inn)
                               AS Pers_Inn,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt IN (6, 7)
                                        AND Prs.Apda_Nda IN (606, 607)
                                   THEN
                                       Prs.Apda_Val_Dt
                               END)
                               AS Pers_Brth_Date,
                           RTRIM (
                               (   MAX (
                                       CASE
                                           WHEN     Prs.Apd_Ndt = 605
                                                AND Prs.Apda_Nda = 1625
                                                AND TRIM (
                                                        Prs.Apda_Val_String)
                                                        IS NOT NULL
                                           THEN
                                                  TRIM (Prs.Apda_Val_String)
                                               || ', '
                                       END)
                                || (LTRIM (
                                           MAX (
                                               CASE
                                                   WHEN     Prs.Apd_Ndt = 605
                                                        AND Prs.Apda_Nda =
                                                            1618
                                                   THEN
                                                       COALESCE (
                                                           (CASE
                                                                WHEN Prs.Apda_Val_Id
                                                                         IS NOT NULL
                                                                THEN
                                                                    Get_Katottg_Info (
                                                                        Prs.Apda_Val_Id)
                                                            END),
                                                           Prs.Apda_Val_String)
                                               END)
                                        || ', ',
                                        ', '))
                                || COALESCE (
                                       LTRIM (
                                              MAX (
                                                  CASE
                                                      WHEN     Prs.Apd_Ndt =
                                                               605
                                                           AND Prs.Apda_Nda =
                                                               1632
                                                      THEN
                                                          COALESCE (
                                                              (CASE
                                                                   WHEN Prs.Apda_Val_Id
                                                                            IS NOT NULL
                                                                   THEN
                                                                       Get_Street_Info (
                                                                           Prs.Apda_Val_Id)
                                                               END),
                                                              TRIM (
                                                                  Prs.Apda_Val_String))
                                                  END)
                                           || ', ',
                                           ', '),
                                       MAX (
                                           CASE
                                               WHEN     Prs.Apd_Ndt = 605
                                                    AND Prs.Apda_Nda = 1640
                                                    AND TRIM (
                                                            Prs.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      'вул. '
                                                   || TRIM (
                                                          Prs.Apda_Val_String)
                                                   || ', '
                                           END))
                                || MAX (
                                       CASE
                                           WHEN     Prs.Apd_Ndt = 605
                                                AND Prs.Apda_Nda = 1648
                                                AND TRIM (
                                                        Prs.Apda_Val_String)
                                                        IS NOT NULL
                                           THEN
                                                  'буд. '
                                               || TRIM (Prs.Apda_Val_String)
                                               || ', '
                                       END)
                                || MAX (
                                       CASE
                                           WHEN     Prs.Apd_Ndt = 605
                                                AND Prs.Apda_Nda = 1654
                                                AND TRIM (
                                                        Prs.Apda_Val_String)
                                                        IS NOT NULL
                                           THEN
                                                  'корп. '
                                               || TRIM (Prs.Apda_Val_String)
                                               || ', '
                                       END)
                                || MAX (
                                       CASE
                                           WHEN     Prs.Apd_Ndt = 605
                                                AND Prs.Apda_Nda = 1659
                                                AND TRIM (
                                                        Prs.Apda_Val_String)
                                                        IS NOT NULL
                                           THEN
                                                  'кв. '
                                               || TRIM (Prs.Apda_Val_String)
                                       END)),
                               ', ')
                               AS Pers_Fact_Addr,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 801
                                        AND Prs.Apda_Nda = 1883
                                   THEN
                                       Prs.Apda_Val_String
                               END)
                               AS Pers_Phone_Num,
                           COALESCE (
                               MAX (
                                   CASE
                                       WHEN     Prs.Apd_Ndt = 6
                                            AND Prs.Apda_Nda = 3
                                       THEN
                                           Prs.Apda_Val_String
                                   END),
                               MAX (
                                   CASE
                                       WHEN     Prs.Apd_Ndt = 7
                                            AND Prs.Apda_Nda = 9
                                       THEN
                                           Prs.Apda_Val_String
                                   END))
                               AS Pers_Pasp_Num,
                           COALESCE (
                               TRIM (
                                      MAX (
                                          CASE
                                              WHEN     Prs.Apd_Ndt = 6
                                                   AND Prs.Apda_Nda = 7
                                              THEN
                                                  Prs.Apda_Val_String
                                          END)
                                   || ' '
                                   || MAX (
                                          CASE
                                              WHEN     Prs.Apd_Ndt = 6
                                                   AND Prs.Apda_Nda = 5
                                              THEN
                                                  TO_CHAR (Prs.Apda_Val_Dt,
                                                           'DD.MM.YYYY')
                                          END)),
                               TRIM (
                                      MAX (
                                          CASE
                                              WHEN     Prs.Apd_Ndt = 7
                                                   AND Prs.Apda_Nda = 13
                                              THEN
                                                  Prs.Apda_Val_String
                                          END)
                                   || ' '
                                   || MAX (
                                          CASE
                                              WHEN     Prs.Apd_Ndt = 7
                                                   AND Prs.Apda_Nda = 14
                                              THEN
                                                  TO_CHAR (Prs.Apda_Val_Dt,
                                                           'DD.MM.YYYY')
                                          END)))
                               AS Pers_Pasp_Info,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 7
                                        AND Prs.Apda_Nda = 810
                                   THEN
                                       Prs.Apda_Val_String
                               END)
                               AS Pers_Eddr_Id,
                           MAX (Add_Doc_Ndt)
                               AS Add_Doc_Ndt,
                           --для поля p9
                           MAX (CASE
                                    WHEN     Prs.Apd_Ndt = Prs.Add_Doc_Ndt
                                         AND Prs.Apda_Nda IN (15,
                                                              21,
                                                              46,
                                                              1840)
                                    THEN
                                        Prs.Apda_Val_String
                                END)
                               AS Pers_Add_Doc_Num,
                           TRIM (
                                  MAX (
                                      CASE
                                          WHEN     Prs.Apd_Ndt =
                                                   Prs.Add_Doc_Ndt
                                               AND Prs.Apda_Nda IN (17,
                                                                    23,
                                                                    48,
                                                                    1842)
                                          THEN
                                              Prs.Apda_Val_String
                                      END)
                               || ' '
                               || MAX (
                                      CASE
                                          WHEN     Prs.Apd_Ndt =
                                                   Prs.Add_Doc_Ndt
                                               AND Prs.Apda_Nda IN (20,
                                                                    22,
                                                                    47,
                                                                    1841)
                                          THEN
                                              TO_CHAR (Prs.Apda_Val_Dt,
                                                       'DD.MM.YYYY')
                                      END))
                               AS Pers_Add_Doc_Info,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = Prs.Add_Doc_Ndt
                                        AND Prs.Apda_Nda IN (19, 24)
                                   THEN
                                       TO_CHAR (Prs.Apda_Val_Dt,
                                                'DD.MM.YYYY')
                               END)
                               AS Pers_Add_Doc_End_Dt,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 605
                                        AND Prs.Apda_Nda IN (640, 812)
                                   THEN
                                       Prs.Apda_Val_String
                               END)
                               AS Pers_Rej_Inn,
                           RTRIM (
                               (   MAX (
                                       CASE
                                           WHEN     Prs.Apd_Ndt = 605
                                                AND Prs.Apda_Nda = 1489
                                                AND TRIM (
                                                        Prs.Apda_Val_String)
                                                        IS NOT NULL
                                           THEN
                                                  TRIM (Prs.Apda_Val_String)
                                               || ', '
                                       END)
                                || (LTRIM (
                                           MAX (
                                               CASE
                                                   WHEN     Prs.Apd_Ndt = 605
                                                        AND Prs.Apda_Nda =
                                                            1488
                                                   THEN
                                                       COALESCE (
                                                           (CASE
                                                                WHEN Prs.Apda_Val_Id
                                                                         IS NOT NULL
                                                                THEN
                                                                    Get_Katottg_Info (
                                                                        Prs.Apda_Val_Id)
                                                            END),
                                                           Prs.Apda_Val_String)
                                               END)
                                        || ', ',
                                        ', '))
                                || COALESCE (
                                       LTRIM (
                                              MAX (
                                                  CASE
                                                      WHEN     Prs.Apd_Ndt =
                                                               605
                                                           AND Prs.Apda_Nda =
                                                               1490
                                                      THEN
                                                          COALESCE (
                                                              (CASE
                                                                   WHEN Prs.Apda_Val_Id
                                                                            IS NOT NULL
                                                                   THEN
                                                                       Get_Street_Info (
                                                                           Prs.Apda_Val_Id)
                                                               END),
                                                              TRIM (
                                                                  Prs.Apda_Val_String))
                                                  END)
                                           || ', ',
                                           ', '),
                                       MAX (
                                           CASE
                                               WHEN     Prs.Apd_Ndt = 605
                                                    AND Prs.Apda_Nda = 1591
                                                    AND TRIM (
                                                            Prs.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      'вул. '
                                                   || TRIM (
                                                          Prs.Apda_Val_String)
                                                   || ', '
                                           END))
                                || MAX (
                                       CASE
                                           WHEN     Prs.Apd_Ndt = 605
                                                AND Prs.Apda_Nda = 1599
                                                AND TRIM (
                                                        Prs.Apda_Val_String)
                                                        IS NOT NULL
                                           THEN
                                                  'буд. '
                                               || TRIM (Prs.Apda_Val_String)
                                               || ', '
                                       END)
                                || MAX (
                                       CASE
                                           WHEN     Prs.Apd_Ndt = 605
                                                AND Prs.Apda_Nda = 1605
                                                AND TRIM (
                                                        Prs.Apda_Val_String)
                                                        IS NOT NULL
                                           THEN
                                                  'корп. '
                                               || TRIM (Prs.Apda_Val_String)
                                               || ', '
                                       END)
                                || MAX (
                                       CASE
                                           WHEN     Prs.Apd_Ndt = 605
                                                AND Prs.Apda_Nda = 1611
                                                AND TRIM (
                                                        Prs.Apda_Val_String)
                                                        IS NOT NULL
                                           THEN
                                                  'кв. '
                                               || TRIM (Prs.Apda_Val_String)
                                       END)),
                               ', ')
                               AS Pers_Reg_Addr,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 801
                                        AND Prs.Apda_Nda = 1895
                                        AND Prs.Apda_Val_String IS NOT NULL
                                   THEN
                                       (SELECT LISTAGG (
                                                   (CASE Prs.Apda_Val_String
                                                        WHEN Dic_Value
                                                        THEN
                                                               '\ul '
                                                            || Dic_Sname
                                                            || '\ul0 '
                                                        ELSE
                                                            Dic_Sname
                                                    END),
                                                   ' / ')
                                               WITHIN GROUP (ORDER BY
                                                                 Dic_Srtordr)
                                          FROM Uss_Ndi.v_Ddn_Ss_Provide)
                               END)
                               AS F16,
                           TRIM (
                                  MAX (
                                      CASE
                                          WHEN     Prs.Apd_Ndt = 801
                                               AND Prs.Apda_Nda = 1896
                                               AND Prs.Apda_Val_String
                                                       IS NOT NULL
                                          THEN
                                              Prs.Apda_Val_String || ' '
                                      END)
                               || MAX (
                                      CASE
                                          WHEN     Prs.Apd_Ndt = 801
                                               AND Prs.Apda_Nda = 1897
                                               AND Prs.Apda_Val_String
                                                       IS NOT NULL
                                          THEN
                                              Prs.Apda_Val_String || ' '
                                      END)
                               || MAX (
                                      CASE
                                          WHEN     Prs.Apd_Ndt = 801
                                               AND Prs.Apda_Nda = 1898
                                               AND Prs.Apda_Val_String
                                                       IS NOT NULL
                                          THEN
                                              Prs.Apda_Val_String || ' '
                                      END))
                               AS F17,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 801
                                        AND Prs.Apda_Nda = 1899
                                   THEN
                                       Prs.Apda_Val_Dt
                               END)
                               AS F18,
                           RTRIM (
                                  LTRIM (
                                      MAX (
                                          CASE
                                              WHEN     Prs.Apd_Ndt = 605
                                                   AND Prs.Apda_Nda = 1790
                                                   AND Prs.Apda_Val_String
                                                           IS NOT NULL
                                              THEN
                                                     (SELECT Dic_Sname    AS NAME
                                                        FROM Uss_Ndi.v_Ddn_Scy_Group
                                                       WHERE Dic_Value =
                                                             Prs.Apda_Val_String)
                                                  || ', '
                                          END),
                                      ', ')
                               || MAX (
                                      CASE
                                          WHEN     Prs.Apd_Ndt = 605
                                               AND Prs.Apda_Nda = 1793
                                               AND Prs.Apda_Val_Dt
                                                       IS NOT NULL
                                          THEN
                                              TO_CHAR (Prs.Apda_Val_Dt,
                                                       'DD.MM.YYYY')
                                      END),
                               ', ')
                               AS F20,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 801
                                        AND Prs.Apda_Nda = 1869
                                   THEN
                                       Prs.Apda_Val_String
                               END)
                               AS F21,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 801
                                        AND Prs.Apda_Nda = 1872
                                   THEN
                                       Prs.Apda_Val_String
                               END)
                               AS F23,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 801
                                        AND Prs.Apda_Nda = 1871
                                   THEN
                                       Prs.Apda_Val_String
                               END)
                               AS Nda1871,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 801
                                        AND Prs.Apda_Nda = 1895
                                   THEN
                                       Prs.Apda_Val_String
                               END)
                               AS Nda1895,
                           MAX (
                               CASE
                                   WHEN     Prs.Apd_Ndt = 605
                                        AND Prs.Apda_Nda = 660
                                   THEN
                                       Prs.Apda_Val_String
                               END)
                               AS Nda660
                      FROM (SELECT App_Id,
                                   Pers_Name,
                                   App_Inn,
                                   Apd_Ndt,
                                   Apda_Nda,
                                   Apda_Val_Dt,
                                   Apda_Val_String,
                                   Apda_Val_Id,
                                   MAX (Add_Doc_Ndt) OVER ()    AS Add_Doc_Ndt --для поля p9
                              FROM (SELECT p.App_Id,
                                           Tools.Init_Cap (
                                                  p.App_Ln
                                               || ' '
                                               || p.App_Fn
                                               || ' '
                                               || p.App_Mn)
                                               AS Pers_Name,
                                           p.App_Inn,
                                           FIRST_VALUE (p.App_Id)
                                               OVER (ORDER BY p.App_Ln)
                                               AS Frst_App,
                                           d.Apd_Ndt,
                                           a.Apda_Nda,
                                           a.Apda_Val_Dt,
                                           TRIM (a.Apda_Val_String)
                                               AS Apda_Val_String,
                                           a.Apda_Val_Id,
                                           --Посвідка на постійне проживання, ets
                                           FIRST_VALUE (
                                               (CASE
                                                    WHEN d.Apd_Ndt IN (8,
                                                                       9,
                                                                       14,
                                                                       805)
                                                    THEN
                                                        d.Apd_Ndt
                                                END) IGNORE NULLS)
                                               OVER (PARTITION BY p.App_Id
                                                     ORDER BY Dt.Ndt_Order)
                                               AS Add_Doc_Ndt
                                      FROM v_Ap_Person  p
                                           JOIN v_Ap_Document d
                                               ON     d.Apd_App = p.App_Id
                                                  AND d.Apd_Ap = p_Ap_Id
                                                  AND d.Apd_Ndt IN (6,
                                                                    7,
                                                                    8,
                                                                    9,
                                                                    14,
                                                                    605,
                                                                    801,
                                                                    805)
                                                  AND d.History_Status = 'A'
                                           JOIN
                                           Uss_Ndi.v_Ndi_Document_Type Dt
                                               ON Dt.Ndt_Id = d.Apd_Ndt
                                           JOIN v_Ap_Document_Attr a
                                               ON     a.Apda_Apd = d.Apd_Id
                                                  AND a.Apda_Ap = p_Ap_Id
                                                  AND a.History_Status = 'A'
                                     WHERE     p.App_Ap = p_Ap_Id
                                           AND p.App_Tp IN ('Z',
                                                            'OR',
                                                            'AG',
                                                            'AF',
                                                            'AP')
                                           AND p.History_Status = 'A')
                             WHERE App_Id = Frst_App) Prs)
            LOOP
                --у зверненні повинен бути наявним документ «Заява про надання соціальних послуг» ndt_id=801
                IF c.Cntrl_Doc_Exist = 1
                THEN
                    v_Jbr_Id := Rdm$rtfl.Initreport (p_Rt_Id);
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p14',
                        COALESCE (TO_CHAR (v_Ap_Reg_Dt, 'DD.MM.YYYY'),
                                  '___________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p141',
                        COALESCE (
                            TRIM (
                                   TO_CHAR (v_Ap_Reg_Dt, 'DD')
                                || ' '
                                || Get_Month_Name (v_Ap_Reg_Dt)
                                || ' '
                                || TO_CHAR (v_Ap_Reg_Dt, 'YYYY')),
                            '«___» ____________________ 20___'));
                    Rdm$rtfl.Addparam (v_Jbr_Id,
                                       'p15',
                                       COALESCE (v_Ap_Num, '_________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p29',
                        COALESCE (TO_CHAR (v_Ap_Reg_Dt + 30, 'DD.MM.YYYY'),
                                  '«___» _______________ 20___'));

                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p2',
                        COALESCE (
                            c.Pers_Name,
                            '__________________________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p3',
                        COALESCE (
                            TO_CHAR (c.Pers_Brth_Date, 'DD.MM.YYYY'),
                            '_____________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p4',
                        COALESCE (
                            c.Pers_Fact_Addr,
                               '______________________________\par'
                            || '________________________________________________________\par'
                            || '________________________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p5',
                        COALESCE (
                            c.Pers_Phone_Num,
                            '______________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p6',
                        COALESCE (
                            c.Pers_Pasp_Num,
                            '_________________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p7',
                        COALESCE (
                            c.Pers_Pasp_Info,
                               '_________________________________________\par'
                            || '________________________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p8',
                        COALESCE (c.Pers_Eddr_Id,
                                  '_______________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p9_1',
                           Underline ('посвідки на постійне проживання',
                                      c.Add_Doc_Ndt = 8)
                        || ', '
                        || Underline ('посвідки на тимчасове проживання',
                                      c.Add_Doc_Ndt = 9)
                        || ', '
                        || Underline ('посвідчення біженця',
                                      c.Add_Doc_Ndt = 14)
                        || ', '
                        || Underline (
                               'посвідчення про взяття на облік бездомної особи',
                               c.Add_Doc_Ndt = 805));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p9',
                        COALESCE (
                            c.Pers_Add_Doc_Num,
                            '________________________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p10',
                        COALESCE (
                            c.Pers_Add_Doc_Info,
                               '___________________________________\par'
                            || '________________________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p11',
                        COALESCE (
                            c.Pers_Add_Doc_End_Dt,
                            '_____________________________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p12',
                        COALESCE (
                            (CASE c.Pers_Rej_Inn
                                 WHEN 'Y' THEN c.Pers_Pasp_Num
                                 ELSE c.Pers_Inn
                             END),
                            '________________________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p13',
                        COALESCE (
                            c.Pers_Reg_Addr,
                               '___________________________\par'
                            || '________________________________________________________'));

                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p16',
                        COALESCE (
                            c.F16,
                            'мені / моєму(їй) синові (доньці) / моїй сім’ї / підопічному(ій)'));

                    --#99956  nda_id in (1895) = ‘моїй сім’ї’ в полі 17 виводити тільки прізвище заявника
                    --в полі 18 «дата народження» не виводити нічого
                    IF NVL (Get_Ap_Document_Attr_Str (p_Ap_Id,
                                                      NULL,
                                                      801,
                                                      1895),
                            'x') = 'FM'
                    THEN
                        l_F17 :=
                            Get_Ap_Document_Attr_Str (p_Ap_Id,
                                                      NULL,
                                                      801,
                                                      1896);
                        l_F18 := NULL;
                    ELSE
                        l_F17 := c.F17;
                        l_F18 := c.F18;
                    END IF;

                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p17',
                        COALESCE (
                            l_F17,
                               '_____________________________________________________________________________________\par'
                            || '____________________________________________________________________________________'--'              \fs20 (прізвище, ім’я, по батькові (за наявності) сина (доньки) чи підопічного(ї)) \fs24'
                                                                                                                     ));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p18',
                        COALESCE (
                            TRIM (
                                   TO_CHAR (l_F18, 'DD')
                                || ' '
                                || Get_Month_Name (l_F18)
                                || ' '
                                || TO_CHAR (l_F18, 'YYYY')),
                            '«___» ________________  _______'));

                    --#86789/#87383
                    IF c.Nda1895 IN ('Z', 'FM')
                    THEN
                        --необхідно вказати інформацію із анкети заявника
                        v_Fact_Addr := c.Pers_Fact_Addr;
                        v_Reg_Addr := c.Pers_Reg_Addr;
                        v_Inv_Exist := c.Nda660;
                        v_Inv_Info := c.F20;
                    ELSIF c.Nda1895 IN ('B', 'CHRG')
                    THEN
                        --необхідно вказати адреси із анкети учасника "Особа, що потребує СП"
                        SELECT RTRIM (
                                   (   MAX (
                                           CASE
                                               WHEN     Da.Apda_Nda = 1625
                                                    AND TRIM (
                                                            Da.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      TRIM (
                                                          Da.Apda_Val_String)
                                                   || ', '
                                           END)
                                    || (LTRIM (
                                               MAX (
                                                   CASE
                                                       WHEN Da.Apda_Nda =
                                                            1618
                                                       THEN
                                                           COALESCE (
                                                               (CASE
                                                                    WHEN Da.Apda_Val_Id
                                                                             IS NOT NULL
                                                                    THEN
                                                                        Get_Katottg_Info (
                                                                            Da.Apda_Val_Id)
                                                                END),
                                                               Da.Apda_Val_String)
                                                   END)
                                            || ', ',
                                            ', '))
                                    || COALESCE (
                                           LTRIM (
                                                  MAX (
                                                      CASE
                                                          WHEN Da.Apda_Nda =
                                                               1632
                                                          THEN
                                                              COALESCE (
                                                                  (CASE
                                                                       WHEN Da.Apda_Val_Id
                                                                                IS NOT NULL
                                                                       THEN
                                                                           Get_Street_Info (
                                                                               Da.Apda_Val_Id)
                                                                   END),
                                                                  TRIM (
                                                                      Da.Apda_Val_String))
                                                      END)
                                               || ', ',
                                               ', '),
                                           MAX (
                                               CASE
                                                   WHEN     Da.Apda_Nda =
                                                            1640
                                                        AND TRIM (
                                                                Da.Apda_Val_String)
                                                                IS NOT NULL
                                                   THEN
                                                          'вул. '
                                                       || TRIM (
                                                              Da.Apda_Val_String)
                                                       || ', '
                                               END))
                                    || MAX (
                                           CASE
                                               WHEN     Da.Apda_Nda = 1648
                                                    AND TRIM (
                                                            Da.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      'буд. '
                                                   || TRIM (
                                                          Da.Apda_Val_String)
                                                   || ', '
                                           END)
                                    || MAX (
                                           CASE
                                               WHEN     Da.Apda_Nda = 1654
                                                    AND TRIM (
                                                            Da.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      'корп. '
                                                   || TRIM (
                                                          Da.Apda_Val_String)
                                                   || ', '
                                           END)
                                    || MAX (
                                           CASE
                                               WHEN     Da.Apda_Nda = 1659
                                                    AND TRIM (
                                                            Da.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      'кв. '
                                                   || TRIM (
                                                          Da.Apda_Val_String)
                                           END)),
                                   ', ')    AS Pers_Fact_Addr,
                               RTRIM (
                                   (   MAX (
                                           CASE
                                               WHEN     Da.Apda_Nda = 1489
                                                    AND TRIM (
                                                            Da.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      TRIM (
                                                          Da.Apda_Val_String)
                                                   || ', '
                                           END)
                                    || (LTRIM (
                                               MAX (
                                                   CASE
                                                       WHEN Da.Apda_Nda =
                                                            1488
                                                       THEN
                                                           COALESCE (
                                                               (CASE
                                                                    WHEN Da.Apda_Val_Id
                                                                             IS NOT NULL
                                                                    THEN
                                                                        Get_Katottg_Info (
                                                                            Da.Apda_Val_Id)
                                                                END),
                                                               Da.Apda_Val_String)
                                                   END)
                                            || ', ',
                                            ', '))
                                    || COALESCE (
                                           LTRIM (
                                                  MAX (
                                                      CASE
                                                          WHEN Da.Apda_Nda =
                                                               1490
                                                          THEN
                                                              COALESCE (
                                                                  (CASE
                                                                       WHEN Da.Apda_Val_Id
                                                                                IS NOT NULL
                                                                       THEN
                                                                           Get_Street_Info (
                                                                               Da.Apda_Val_Id)
                                                                   END),
                                                                  TRIM (
                                                                      Da.Apda_Val_String))
                                                      END)
                                               || ', ',
                                               ', '),
                                           MAX (
                                               CASE
                                                   WHEN     Da.Apda_Nda =
                                                            1591
                                                        AND TRIM (
                                                                Da.Apda_Val_String)
                                                                IS NOT NULL
                                                   THEN
                                                          'вул. '
                                                       || TRIM (
                                                              Da.Apda_Val_String)
                                                       || ', '
                                               END))
                                    || MAX (
                                           CASE
                                               WHEN     Da.Apda_Nda = 1599
                                                    AND TRIM (
                                                            Da.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      'буд. '
                                                   || TRIM (
                                                          Da.Apda_Val_String)
                                                   || ', '
                                           END)
                                    || MAX (
                                           CASE
                                               WHEN     Da.Apda_Nda = 1605
                                                    AND TRIM (
                                                            Da.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      'корп. '
                                                   || TRIM (
                                                          Da.Apda_Val_String)
                                                   || ', '
                                           END)
                                    || MAX (
                                           CASE
                                               WHEN     Da.Apda_Nda = 1611
                                                    AND TRIM (
                                                            Da.Apda_Val_String)
                                                            IS NOT NULL
                                               THEN
                                                      'кв. '
                                                   || TRIM (
                                                          Da.Apda_Val_String)
                                           END)),
                                   ', ')    AS Pers_Reg_Addr,
                               MAX (
                                   CASE
                                       WHEN Da.Apda_Nda = 660
                                       THEN
                                           Da.Apda_Val_String
                                   END)     AS Nda660,
                               RTRIM (
                                      LTRIM (
                                          MAX (
                                              CASE
                                                  WHEN     Da.Apda_Nda = 1790
                                                       AND Da.Apda_Val_String
                                                               IS NOT NULL
                                                  THEN
                                                         (SELECT Dic_Sname    AS NAME
                                                            FROM Uss_Ndi.v_Ddn_Scy_Group
                                                           WHERE Dic_Value =
                                                                 Da.Apda_Val_String)
                                                      || ', '
                                              END),
                                          ', ')
                                   || MAX (
                                          CASE
                                              WHEN     Da.Apda_Nda = 1793
                                                   AND Da.Apda_Val_Dt
                                                           IS NOT NULL
                                              THEN
                                                  TO_CHAR (Da.Apda_Val_Dt,
                                                           'DD.MM.YYYY')
                                          END),
                                   ', ')    AS F20
                          INTO v_Fact_Addr,
                               v_Reg_Addr,
                               v_Inv_Exist,
                               v_Inv_Info
                          FROM v_Ap_Person  p
                               JOIN v_Ap_Document d
                                   ON     d.Apd_App = p.App_Id
                                      AND d.Apd_Ap = p_Ap_Id
                                      AND d.Apd_Ndt = 605
                                      AND d.History_Status = 'A'
                               JOIN v_Ap_Document_Attr Da
                                   ON     Da.Apda_Apd = d.Apd_Id
                                      AND Da.Apda_Ap = p_Ap_Id
                                      AND Da.History_Status = 'A'
                         WHERE     p.App_Ap = p_Ap_Id
                               AND p.App_Tp = 'OS'
                               AND p.History_Status = 'A';
                    END IF;

                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p19',
                        (CASE WHEN v_Inv_Exist = 'T' THEN v_Check_Mark END));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p20',
                        COALESCE (
                            v_Inv_Info,
                               '__________________________________________________________,\par'
                            || '                                    (група інвалідності, строк встановлення групи інвалідності)'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p201',
                        COALESCE (
                            v_Fact_Addr,
                            '______________________________________________'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p202',
                        COALESCE (
                            v_Reg_Addr,
                            '_________________________________________________________ '));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p211',
                        (CASE c.F21 WHEN 'F' THEN v_Check_Mark END));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p212',
                        (CASE c.F21 WHEN 'C' THEN v_Check_Mark END));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p213',
                        (CASE c.F21 WHEN 'D' THEN v_Check_Mark END));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p23',
                        COALESCE (
                            c.F23,
                               '__________________________________________________________\par'
                            || '____________________________________________________________________________________\par'--'                                                         \fs20 (зазначити найменування надавача соціальної послуги за потреби) \fs24'
                                                                                                                         ));
                    Rdm$rtfl.Addparam (v_Jbr_Id,
                                       'p25',
                                       COALESCE (NULL, '__________'));
                    Rdm$rtfl.Addparam (v_Jbr_Id,
                                       'p26',
                                       COALESCE (NULL, '_____'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p27',
                        COALESCE (
                            c.F16,
                            'мене / мого(єї) сина (доньки)/ моєї сім’ї / підопічного(ої)'));
                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p31',
                        COALESCE (
                            c.Pers_Name,
                            '________________________________________________\par'--'\fs20                             (прізвище, ім’я, по батькові (за наявності) заявника / законного\par' ||
                                                                                  --'                                    представника / уповноваженого представника сім’ї) \fs24'
                                                                                  ));

                    IF c.Nda1871 = 'T'
                    THEN
                        SELECT MAX (d.Apr_Id),
                               MAX (d.Apr_Start_Dt),
                               MAX (d.Apr_Stop_Dt)
                          INTO v_Apr_Id, v_Apr_Start_Dt, v_Apr_Stop_Dt
                          FROM v_Ap_Declaration d
                         WHERE d.Apr_Ap = p_Ap_Id;
                    END IF;

                    Rdm$rtfl.Addparam (
                        v_Jbr_Id,
                        'p24',
                        (CASE c.Nda1871
                             WHEN 'T'
                             THEN
                                    'Відомості, які використовуються для обчислення середньомісячного сукупного доходу отримувача соціальної послуги за рахунок бюджетних коштів або з установленням диференційованої плати з '
                                 || TO_CHAR (v_Apr_Start_Dt, 'DD.MM.YYYY')
                                 || ' р. до '
                                 || TO_CHAR (v_Apr_Stop_Dt, 'DD.MM.YYYY')
                                 || ' р.*'
                         END));

                    Rdm$rtfl.Adddataset (
                        v_Jbr_Id,
                        'ds',
                           q'[SELECT p.aprp_id,
       MAX(CASE
             WHEN pp.app_id IS NULL THEN
              p.aprp_ln || ' ' || p.aprp_fn || ' ' || p.aprp_mn
             ELSE
              pp.app_ln || ' ' || pp.app_fn || ' ' || pp.app_mn
           END) AS c1,
       MAX(td.app_doc) AS c2,
       coalesce(MAX(coalesce(p.aprp_inn, pp.app_inn)), MAX(CASE td.apda_nda WHEN 3 THEN td.apda_val_string END), MAX(CASE td.apda_nda WHEN 9 THEN td.apda_val_string END)) AS c3
  FROM uss_visit.v_apr_person p
  JOIN uss_visit.v_ap_person pp ON pp.app_id = p.aprp_app
                               AND pp.history_status = 'A'
  LEFT JOIN (SELECT d.apd_id,
                    d.apd_app,
                    dt.ndt_name,
                    da.apda_nda,
                    da.apda_val_dt,
                    da.apda_val_string,
                    FIRST_VALUE(dt.ndt_name || ', ' || da.apda_val_string) OVER (PARTITION BY d.apd_app ORDER BY (CASE WHEN da.apda_nda IN (3, 9, 90) THEN 0 ELSE 1 END),
                                                                                                        (CASE WHEN da.apda_val_string IS NOT NULL THEN 0 ELSE 1 END),
                                                                                                        dt.ndt_order) AS app_doc
              FROM uss_visit.v_ap_document d
              JOIN uss_ndi.v_ndi_document_type dt ON dt.ndt_id = d.apd_ndt
              JOIN uss_visit.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                  AND da.apda_ap = ]'
                        || TO_CHAR (p_Ap_Id)
                        || q'[
                                                  AND da.apda_nda IN (3, 9, 90)
                                                  AND da.history_status = 'A'
             WHERE d.apd_ap = ]'
                        || TO_CHAR (p_Ap_Id)
                        || q'[
               AND d.apd_ndt IN (6, 7, 37)
               AND d.history_status = 'A') td ON td.apd_app = pp.app_id
 WHERE p.aprp_apr = ]'
                        || TO_CHAR (COALESCE (v_Apr_Id, 0))
                        || q'[
   AND p.history_status = 'A'
   AND 'T' = ']'
                        || COALESCE (c.Nda1871, 'F')
                        || q'['
 GROUP BY p.aprp_id
 ORDER BY 2]');
                ELSE
                    SELECT MAX (Ndt_Name)
                      INTO v_Tmp_Str
                      FROM Uss_Ndi.v_Ndi_Document_Type
                     WHERE Ndt_Id = 801;

                    Raise_Application_Error (
                        -20000,
                           'Формування друкованої форми можливе тільки при наявності документа "'
                        || v_Tmp_Str
                        || '"');
                END IF;
            END LOOP;

            --перелік послуг
            -- #99956  у блоку переліку послуг виводити тільки ті, які зазначено в ap_service і які мають history_status = ‘A’
            /*FOR Serv_Cur IN (SELECT DISTINCT Serv_Tp_Id,
                                             First_Value(Serv_St) Over(PARTITION BY Serv_Tp_Id ORDER BY Serv_St NULLS LAST) AS Serv_St
                               FROM (SELECT Nst_Id AS Serv_Tp_Id, NULL AS Serv_St
                                        FROM Uss_Ndi.v_Ndi_Service_Type
                                       WHERE Nst_Id IN
                                             (401, 425, 426, 427, 428, 413, 414, 415, 429, 430, 417, 418, 419, 421, 422, 423, 432, 433, 434,
                                              435, 402, 405, 404, 406, 408, 409, 441, 442, 439, 411, 440, 438, 437, 443)
                                      UNION ALL
                                      SELECT Aps_Nst AS Serv_Tp_Id, Aps_St AS Serv_St
                                        FROM Uss_Visit.v_Ap_Service
                                       WHERE Aps_Ap = p_Ap_Id
                                         AND Aps_Nst IN
                                             (401, 425, 426, 427, 428, 413, 414, 415, 429, 430, 417, 418, 419, 421, 422, 423, 432, 433, 434,
                                              435, 402, 405, 404, 406, 408, 409, 441, 442, 439, 411, 440, 438, 437, 443)
                                         AND History_Status = 'A'))
            LOOP
              Rdm$rtfl.Addparam(v_Jbr_Id, 's' || To_Char(Serv_Cur.Serv_Tp_Id),
                                (CASE WHEN Serv_Cur.Serv_St IS NOT NULL THEN v_Check_Mark END));
            END LOOP;*/

            v_Tmp_Str := q'[
        SELECT Row_Number() Over(ORDER BY Nst.Nst_Order) AS C1,
               Nst.Nst_Name AS C2,
               uss_visit.Dnet$appeals_Reports.Check_Mark AS C3
          FROM Uss_Visit.v_Ap_Service s, Uss_Ndi.v_Ndi_Service_Type Nst
         WHERE s.History_Status = 'A'
           AND Nst.Nst_Id = s.Aps_Nst
           AND s.Aps_Ap = :p_Ap_Id
         ORDER BY Nst.Nst_Order
      ]';

            v_Tmp_Str :=
                REGEXP_REPLACE (v_Tmp_Str,
                                ':p_Ap_Id',
                                p_Ap_Id,
                                1,
                                0,
                                'i');
            Rdm$rtfl.Adddataset (v_Jbr_Id, 'ds_nst', v_Tmp_Str);

            SELECT MAX (Org_Name)
              INTO v_Tmp_Str
              FROM Ikis_Sys.v_Opfu
             WHERE Org_Id = Tools.Getcurrorg;

            Rdm$rtfl.Addparam (
                v_Jbr_Id,
                'p1',
                COALESCE (
                    v_Tmp_Str,
                    '________________________________________________________'));

            BEGIN
                Ikis_Sysweb.Getuser (p_Login   => Tools.Getcurrlogin,
                                     p_Pib     => v_Tmp_Str,
                                     p_Numid   => v_Numid);
            EXCEPTION
                WHEN OTHERS
                THEN
                    v_Tmp_Str := NULL;
            END;

            Rdm$rtfl.Addparam (
                v_Jbr_Id,
                'p30',
                COALESCE (TRIM (REGEXP_SUBSTR (v_Tmp_Str,
                                               '[^,]+',
                                               1,
                                               1)),
                          '\fs20               (прізвище та підпис
                відповідальної особи) \fs24'));

            Rdm$rtfl.Addparam (v_Jbr_Id,
                               'p28',
                               TO_CHAR (SYSDATE, 'DD.MM.YYYY'));

            SELECT LISTAGG (Ndt_Name_Short, ', ')
                       WITHIN GROUP (ORDER BY Ndt_Order, Ndt_Name)
              INTO v_Tmp_Str
              FROM (SELECT DISTINCT c.Nndc_Ndt
                      FROM Uss_Ndi.v_Ndi_Nst_Doc_Config  c
                           --УЧАСНИКИ
                           LEFT JOIN Uss_Visit.v_Ap_Person p
                               ON     (   c.Nndc_App_Tp IS NOT NULL
                                       OR c.Nndc_Nda IS NOT NULL)
                                  AND p.App_Ap = p_Ap_Id
                                  AND p.History_Status = 'A'
                           --ДОКУМЕНТИ
                           LEFT JOIN Uss_Visit.v_Ap_Document d
                               ON     d.Apd_Ap = p_Ap_Id
                                  AND d.History_Status = 'A'
                                  --ОБИРАЄМО ДОКУМЕНТИ УЧАСНИКІВ
                                  --АБО ВСІ ДОКУМЕНТИ В ЗВЕРНЕННІ(якщо в конфігурації вказано лише послугу)
                                  AND (   (    c.Nndc_App_Tp IS NULL
                                           AND c.Nndc_Nda IS NULL)
                                       OR p.App_Id = d.Apd_App)
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
                     WHERE     c.Nndc_Is_Req = 'T'
                           AND c.Nndc_Ap_Tp = 'SS'           --#77124 20220511
                           AND c.History_Status = 'A'
                           --ТИП УЧАСНИКА
                           AND (   c.Nndc_App_Tp IS NULL
                                OR c.Nndc_App_Tp = p.App_Tp)
                           --ПОСЛУГИ
                           AND (   EXISTS
                                       (SELECT NULL
                                          FROM Uss_Visit.v_Ap_Service s
                                         WHERE     s.Aps_Ap = p_Ap_Id
                                               AND s.History_Status = 'A'
                                               AND s.Aps_Nst = c.Nndc_Nst)
                                OR c.Nndc_Nst IS NULL)
                           --АТРИБУТИ В ДОКУМЕНТАХ УЧАСНИКА
                           AND (   c.Nndc_Nda IS NULL
                                OR EXISTS
                                       (SELECT NULL
                                          FROM Uss_Visit.v_Ap_Document  f
                                               JOIN
                                               Uss_Visit.v_Ap_Document_Attr a
                                                   ON     f.Apd_Id =
                                                          a.Apda_Apd
                                                      AND a.Apda_Nda =
                                                          c.Nndc_Nda
                                                      AND a.Apda_Val_String =
                                                          c.Nndc_Val_String
                                                      AND a.History_Status =
                                                          'A'
                                         WHERE     f.Apd_App = p.App_Id
                                               AND f.History_Status = 'A'))
                           AND (d.Apd_Id IS NULL))
                   JOIN Uss_Ndi.v_Ndi_Document_Type ON Ndt_Id = Nndc_Ndt;

            Rdm$rtfl.Addparam (
                v_Jbr_Id,
                'p35',
                COALESCE (
                    v_Tmp_Str,
                    '___________________________________________________________________________________________'));

            Rdm$rtfl.Putreporttoworkingqueue (v_Jbr_Id);
        END IF;

        RETURN v_Jbr_Id;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО"
    -- params: p_rt_id - ідентифікатор звіту,
    --         p_ap_id - ідентифікатор звернення
    -- note:   #77575, #77957
    FUNCTION sjo_info_r1 (p_rt_id   IN rpt_templates.rt_id%TYPE,
                          p_ap_id   IN appeal.ap_id%TYPE)
        RETURN DECIMAL
    IS
        v_jbr_id      DECIMAL;
        v_tmp_str     VARCHAR2 (4000);
        v_ap_id       appeal.ap_id%TYPE;
        v_ap_reg_dt   appeal.ap_reg_dt%TYPE;
        v_ap_num      appeal.ap_num%TYPE;
        v_numid       VARCHAR2 (10);
        l_app_id      NUMBER;
        v_com_org     appeal.com_org%TYPE;
    BEGIN
        SELECT MAX (ap_id),
               MAX (ap_reg_dt),
               MAX (ap_num),
               MAX (com_org)
          INTO v_ap_id,
               v_ap_reg_dt,
               v_ap_num,
               v_com_org
          FROM v_appeal
         WHERE ap_id = p_ap_id AND ap_tp = 'SS';

        --друкована форма доступна для друку у зверненнях про надання СП (SS)
        IF v_ap_id IS NULL
        THEN
            SELECT MAX (dic_name)
              INTO v_tmp_str
              FROM uss_ndi.v_ddn_ap_tp
             WHERE dic_value = 'SS';

            raise_application_error (
                -20000,
                   'Формування друкованої форми можливе тільки у зверненнях з типом "'
                || v_tmp_str
                || '"');
        ELSE
            FOR c
                IN (SELECT MAX (CASE prs.apd_ndt WHEN 802 THEN 1 END)
                               AS cntrl_doc_exist,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1949
                                   THEN
                                       prs.apda_val_dt
                               END)
                               AS f1,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1950
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f2,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1951
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f3,
                           RTRIM (
                               (   MAX (
                                       CASE
                                           WHEN     prs.apd_ndt = 802
                                                AND prs.apda_nda = 1953
                                                AND TRIM (
                                                        prs.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  TRIM (prs.apda_val_string)
                                               || ', '
                                       END)
                                || (LTRIM (
                                           MAX (
                                               CASE
                                                   WHEN     prs.apd_ndt = 802
                                                        AND prs.apda_nda =
                                                            1952
                                                   THEN
                                                       COALESCE (
                                                           (CASE
                                                                WHEN prs.apda_val_id
                                                                         IS NOT NULL
                                                                THEN
                                                                    get_katottg_info (
                                                                        prs.apda_val_id)
                                                            END),
                                                           prs.apda_val_string)
                                               END)
                                        || ', ',
                                        ', '))
                                || COALESCE (
                                       LTRIM (
                                              MAX (
                                                  CASE
                                                      WHEN     prs.apd_ndt =
                                                               802
                                                           AND prs.apda_nda =
                                                               1958
                                                      THEN
                                                          COALESCE (
                                                              (CASE
                                                                   WHEN prs.apda_val_id
                                                                            IS NOT NULL
                                                                   THEN
                                                                       get_street_info (
                                                                           prs.apda_val_id)
                                                               END),
                                                              TRIM (
                                                                  prs.apda_val_string))
                                                  END)
                                           || ', ',
                                           ', '),
                                       MAX (
                                           CASE
                                               WHEN     prs.apd_ndt = 802
                                                    AND prs.apda_nda = 1957
                                                    AND TRIM (
                                                            prs.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      'вул. '
                                                   || TRIM (
                                                          prs.apda_val_string)
                                                   || ', '
                                           END))
                                || MAX (
                                       CASE
                                           WHEN     prs.apd_ndt = 802
                                                AND prs.apda_nda = 1959
                                                AND TRIM (
                                                        prs.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  'буд. '
                                               || TRIM (prs.apda_val_string)
                                               || ', '
                                       END)
                                || MAX (
                                       CASE
                                           WHEN     prs.apd_ndt = 802
                                                AND prs.apda_nda = 1960
                                                AND TRIM (
                                                        prs.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  'корп. '
                                               || TRIM (prs.apda_val_string)
                                               || ', '
                                       END)
                                || MAX (
                                       CASE
                                           WHEN     prs.apd_ndt = 802
                                                AND prs.apda_nda = 1961
                                                AND TRIM (
                                                        prs.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  'кв. '
                                               || TRIM (prs.apda_val_string)
                                       END)),
                               ', ')
                               AS f4,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1982
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f5,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1962
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f6,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1945
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f10,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1944
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f11,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1963
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS a1963,
                           TRIM (
                                  MAX (
                                      CASE
                                          WHEN     prs.apd_ndt = 802
                                               AND prs.apda_nda = 1964
                                          THEN
                                              prs.apda_val_string
                                      END)
                               || ' '
                               || MAX (
                                      CASE
                                          WHEN     prs.apd_ndt = 802
                                               AND prs.apda_nda = 1965
                                          THEN
                                              prs.apda_val_string
                                      END)
                               || ' '
                               || MAX (
                                      CASE
                                          WHEN     prs.apd_ndt = 802
                                               AND prs.apda_nda = 1966
                                          THEN
                                              prs.apda_val_string
                                      END))
                               AS f12,
                           RTRIM (
                               (   MAX (
                                       CASE
                                           WHEN     prs.apd_ndt = 802
                                                AND prs.apda_nda = 1969
                                                AND TRIM (
                                                        prs.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  TRIM (prs.apda_val_string)
                                               || ', '
                                       END)
                                || (LTRIM (
                                           MAX (
                                               CASE
                                                   WHEN     prs.apd_ndt = 802
                                                        AND prs.apda_nda =
                                                            1968
                                                   THEN
                                                       COALESCE (
                                                           (CASE
                                                                WHEN prs.apda_val_id
                                                                         IS NOT NULL
                                                                THEN
                                                                    get_katottg_info (
                                                                        prs.apda_val_id)
                                                            END),
                                                           prs.apda_val_string)
                                               END)
                                        || ', ',
                                        ', '))
                                || COALESCE (
                                       LTRIM (
                                              MAX (
                                                  CASE
                                                      WHEN     prs.apd_ndt =
                                                               802
                                                           AND prs.apda_nda =
                                                               1974
                                                      THEN
                                                          COALESCE (
                                                              (CASE
                                                                   WHEN prs.apda_val_id
                                                                            IS NOT NULL
                                                                   THEN
                                                                       get_street_info (
                                                                           prs.apda_val_id)
                                                               END),
                                                              TRIM (
                                                                  prs.apda_val_string))
                                                  END)
                                           || ', ',
                                           ', '),
                                       MAX (
                                           CASE
                                               WHEN     prs.apd_ndt = 802
                                                    AND prs.apda_nda = 1973
                                                    AND TRIM (
                                                            prs.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      'вул. '
                                                   || TRIM (
                                                          prs.apda_val_string)
                                                   || ', '
                                           END))
                                || MAX (
                                       CASE
                                           WHEN     prs.apd_ndt = 802
                                                AND prs.apda_nda = 1975
                                                AND TRIM (
                                                        prs.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  'буд. '
                                               || TRIM (prs.apda_val_string)
                                               || ', '
                                       END)
                                || MAX (
                                       CASE
                                           WHEN     prs.apd_ndt = 802
                                                AND prs.apda_nda = 1976
                                                AND TRIM (
                                                        prs.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  'корп. '
                                               || TRIM (prs.apda_val_string)
                                               || ', '
                                       END)
                                || MAX (
                                       CASE
                                           WHEN     prs.apd_ndt = 802
                                                AND prs.apda_nda = 1977
                                                AND TRIM (
                                                        prs.apda_val_string)
                                                        IS NOT NULL
                                           THEN
                                                  'кв. '
                                               || TRIM (prs.apda_val_string)
                                       END)),
                               ', ')
                               AS f13,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1978
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f14,
                           TRIM (
                                  MAX (
                                      CASE
                                          WHEN     prs.apd_ndt = 802
                                               AND prs.apda_nda = 1979
                                          THEN
                                              prs.apda_val_string
                                      END)
                               || ' '
                               || MAX (
                                      CASE
                                          WHEN     prs.apd_ndt = 802
                                               AND prs.apda_nda = 1980
                                          THEN
                                              TO_CHAR (prs.apda_val_dt,
                                                       'DD.MM.YYYY')
                                      END))
                               AS f15,
                           TRIM (
                                  MAX (prs.pers_name)
                               || ' '
                               || MAX (
                                      CASE
                                          WHEN     prs.apd_ndt = 605
                                               AND prs.apda_nda = 813
                                               AND prs.apda_val_string
                                                       IS NOT NULL
                                          THEN
                                                 (SELECT dic_sname
                                                    FROM uss_ndi.v_ddn_relation_tp
                                                   WHERE dic_value =
                                                         prs.apda_val_string)
                                              || ' '
                                      END)
                               || MAX (
                                      CASE
                                          WHEN     prs.apd_ndt = 605
                                               AND prs.apda_nda = 825
                                               AND prs.apda_val_string
                                                       IS NOT NULL
                                          THEN
                                              prs.apda_val_string || ' '
                                      END)
                               || MAX (
                                      CASE
                                          WHEN     prs.apd_ndt = 605
                                               AND prs.apda_nda = 826
                                               AND prs.apda_val_string
                                                       IS NOT NULL
                                          THEN
                                              prs.apda_val_string
                                      END))
                               AS f16,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1946
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f17,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1981
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f18,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1983
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f19,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1984
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f24,
                           MAX (
                               CASE
                                   WHEN     prs.apd_ndt = 802
                                        AND prs.apda_nda = 1984
                                   THEN
                                       prs.apda_val_string
                               END)
                               AS f25,
                           MAX (app_id)
                               app_id
                      FROM (SELECT app_id,
                                   pers_name,
                                   app_inn,
                                   apd_ndt,
                                   apda_nda,
                                   apda_val_dt,
                                   apda_val_string,
                                   apda_val_id
                              FROM (SELECT p.app_id,
                                           tools.init_cap (
                                                  p.app_ln
                                               || ' '
                                               || p.app_fn
                                               || ' '
                                               || p.app_mn)
                                               AS pers_name,
                                           p.app_inn,
                                           FIRST_VALUE (p.app_id)
                                               OVER (ORDER BY p.app_ln)
                                               AS frst_app,
                                           d.apd_ndt,
                                           a.apda_nda,
                                           a.apda_val_dt,
                                           TRIM (a.apda_val_string)
                                               AS apda_val_string,
                                           a.apda_val_id
                                      FROM v_ap_person  p
                                           JOIN v_ap_document d
                                               ON     d.apd_app = p.app_id
                                                  AND d.apd_ap = p_ap_id
                                                  AND d.apd_ndt IN (605, 802)
                                                  AND d.history_status = 'A'
                                           JOIN v_ap_document_attr a
                                               ON     a.apda_apd = d.apd_id
                                                  AND a.apda_ap = p_ap_id
                                                  AND a.history_status = 'A'
                                     WHERE     p.app_ap = p_ap_id
                                           AND p.app_tp IN ('Z',
                                                            'OR',
                                                            'AG',
                                                            'AF',
                                                            'AP')
                                           AND p.history_status = 'A')
                             WHERE app_id = frst_app) prs)
            LOOP
                --у зверненні повинен бути наявним документ «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802
                IF c.cntrl_doc_exist = 1
                THEN
                    v_jbr_id := rdm$rtfl.initreport (p_rt_id);
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p1',
                        COALESCE (TO_CHAR (c.f1, 'DD.MM.YYYY'),
                                  '______________'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p2',
                        COALESCE (c.f2, '___________________'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p3456',
                        COALESCE (
                            TRIM (
                                   TRIM (
                                          TRIM (c.f3 || ' ' || c.f4)
                                       || ' '
                                       || c.f5)
                                || ' '
                                || c.f6),
                               '_______________________________________\par'
                            || '_______________________________________\par'
                            || '_______________________________________\par'
                            || '\fs20\qc (найменування організації/установи/закладу, \par'
                            || 'яка (який) направляє повідомлення, \par'
                            || 'поштова та електронна адреси, телефон) \fs24'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p7',
                        COALESCE (TO_CHAR (v_ap_reg_dt, 'DD.MM.YYYY'),
                                  '_______________'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p8',
                        COALESCE (v_ap_num, '__________________'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p101',
                        (CASE c.f10 WHEN 'O' THEN v_check_mark END));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p102',
                        (CASE c.f10 WHEN 'W' THEN v_check_mark END));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p103',
                        (CASE c.f10 WHEN 'TL' THEN v_check_mark END));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p104',
                        (CASE c.f10 WHEN 'EL' THEN v_check_mark END));

                    /*rdm$rtfl.addparam(v_jbr_id,
                                      'p11',
                                      coalesce((CASE WHEN c.f11 = 'Z' AND coalesce(c.a1963, 'N') = 'N' THEN '\ul ' END) || 'особу' ||
                                               (CASE WHEN c.f11 = 'Z' AND coalesce(c.a1963, 'N') = 'N' THEN '\ul0 ' END) || '/' ||
                                               (CASE WHEN c.f11 = 'Z' AND c.a1963 = 'Y' THEN '\ul ' END) || 'дитину' ||
                                               (CASE WHEN c.f11 = 'Z' AND c.a1963 = 'Y' THEN '\ul0 ' END) || '/' || (CASE c.f11 WHEN 'FM' THEN '\ul ' END) ||
                                               'сім’ю' || (CASE c.f11 WHEN 'FM' THEN '\ul0 ' END),
                                               'особу/дитину/сім’ю'));*/

                    --#89512
                    --uss_ndi.V_DDN_SS_NEEDS
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p11',
                        CASE
                            WHEN c.f11 = 'Z' AND c.a1963 = 'T'
                            THEN
                                'особу/\ulдитину\ul0/сім’ю'
                            WHEN c.f11 = 'Z'
                            THEN
                                '\ulособу\ul0/дитину/сім’ю'
                            WHEN c.f11 = 'FM'
                            THEN
                                'особу/дитину/\ulсім’ю\ul0'
                            ELSE
                                'особу/дитину/сім’ю'
                        END);

                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p12',
                        COALESCE (
                            c.f12,
                               '_____________________________________________________________________________\par'
                            || '\fs20 (прізвище, ім’я, по батькові, вік дитини, особи або прізвище сім’ї)  \fs24'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p13',
                        COALESCE (
                            c.f13,
                            '_____________________________________________________'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p14',
                        COALESCE (
                            c.f14,
                            '___________________________________________________________'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p15',
                        COALESCE (
                            c.f15,
                               '____________________________________\par'
                            || '_____________________________________________________________________________\par'
                            || '_____________________________________________________________________________\par'
                            || '_____________________________________________________________________________\par'
                            || '_____________________________________________________________________________'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p16',
                        COALESCE (
                            c.f16,
                               '__________________________________________________________________________\par'
                            || '\fs20\qc (прізвище, ім’я, по батькові особи, яка подає звернення, інша важлива інформація (ким працює, родинний зв’язок тощо)) \fs24'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p171',
                        (CASE c.f17 WHEN 'SA' THEN v_check_mark END));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p172',
                        (CASE c.f17 WHEN 'RL' THEN v_check_mark END));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p173',
                        (CASE c.f17 WHEN 'N' THEN v_check_mark END));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p174',
                        (CASE c.f17 WHEN 'A' THEN v_check_mark END));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p175',
                        (CASE c.f17 WHEN 'SW' THEN v_check_mark END));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p176',
                        (CASE c.f17 WHEN 'O' THEN v_check_mark END));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p18',
                        COALESCE (
                            c.f18,
                               '______________________________________________________________\par'
                            || '\fs20\qc (відвідування, обстеження, огляду, рейду тощо) \fs24'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p19',
                        COALESCE (
                            c.f19,
                               '_____________\par'
                            || '_____________________________________________________________________________\par'
                            || '_____________________________________________________________________________\par'
                            || '_____________________________________________________________________________\par'
                            || '_____________________________________________________________________________'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p24',
                        COALESCE (
                            c.f24,
                               '_________________________\par'
                            || '\fs20 (посада керівника) \fs24'));
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'p25',
                        COALESCE (
                            CASE
                                WHEN get_ap_document_attr_str (p_ap_id,
                                                               c.app_id,
                                                               802,
                                                               1985)
                                         IS NOT NULL
                                THEN
                                       get_ap_document_attr_str (p_ap_id,
                                                                 c.app_id,
                                                                 802,
                                                                 1985)
                                    || ' '
                                    || get_ap_document_attr_str (p_ap_id,
                                                                 c.app_id,
                                                                 802,
                                                                 1728)
                                    || ' '
                                    || get_ap_document_attr_str (p_ap_id,
                                                                 c.app_id,
                                                                 802,
                                                                 2626)
                            END,                                      --#89512
                            c.f25,
                               '_______________________\par'
                            || '\fs20 (прізвище, ім’я, по батькові) \fs24'));
                ELSE
                    SELECT MAX (ndt_name)
                      INTO v_tmp_str
                      FROM uss_ndi.v_ndi_document_type
                     WHERE ndt_id = 802;

                    raise_application_error (
                        -20000,
                           'Формування друкованої форми можливе тільки при наявності документа "'
                        || v_tmp_str
                        || '"');
                END IF;

                l_app_id := c.app_id;
            END LOOP;

            SELECT LISTAGG (ndt_name, ', ') WITHIN GROUP (ORDER BY ndt_order)
              INTO v_tmp_str
              FROM (SELECT DISTINCT dt.ndt_name, dt.ndt_order
                      FROM v_ap_document  d
                           JOIN uss_ndi.v_ndi_document_type dt
                               ON dt.ndt_id = d.apd_ndt
                     WHERE d.apd_ap = p_ap_id AND d.history_status = 'A');

            rdm$rtfl.addparam (
                v_jbr_id,
                'p20',
                COALESCE (
                    v_tmp_str,
                       '__________________________________\par'
                    || '_____________________________________________________________________________'));

            BEGIN
                SELECT org_name
                  INTO v_tmp_str
                  FROM v_opfu
                 WHERE org_id = v_com_org;
            EXCEPTION
                WHEN OTHERS
                THEN
                    v_tmp_str := NULL;
            END;

            rdm$rtfl.addparam (
                v_jbr_id,
                'p9',
                COALESCE (
                    v_tmp_str,
                       '_______________________________________\par'
                    || '_______________________________________\par'
                    || '_______________________________________\par'
                    || '\fs20\qc (найменування організації/установи/закладу, \par'
                    || 'яка отримала (який отримав) повідомлення) \fs24'));

            BEGIN
                ikis_sysweb.getuser (p_login   => tools.getcurrlogin,
                                     p_pib     => v_tmp_str,
                                     p_numid   => v_numid);
            EXCEPTION
                WHEN OTHERS
                THEN
                    v_tmp_str := NULL;
            END;

            --#89512
            v_tmp_str :=
                COALESCE (   get_ap_document_attr_str (p_ap_id,
                                                       l_app_id,
                                                       802,
                                                       1439)
                          || ' '
                          || get_ap_document_attr_str (p_ap_id,
                                                       l_app_id,
                                                       802,
                                                       1449)
                          || ' '
                          || get_ap_document_attr_str (p_ap_id,
                                                       l_app_id,
                                                       802,
                                                       1464)
                          || ', '
                          || get_ap_document_attr_str (p_ap_id,
                                                       l_app_id,
                                                       802,
                                                       1434),
                          v_tmp_str);
            rdm$rtfl.addparam (
                v_jbr_id,
                'p21',
                COALESCE (
                    v_tmp_str,
                       '____________________________________________________________________________\par'
                    || '\fs20 (прізвище, ім’я, по батькові, посада особи/спеціаліста, яка (який) прийняла (прийняв) повідомлення/інформацію) \fs24'));

            rdm$rtfl.addparam (
                v_jbr_id,
                'p22',
                COALESCE (TO_CHAR (get_ap_document_attr_str (p_ap_id,
                                                             l_app_id,
                                                             802,
                                                             1465),
                                   'DD.MM.YYYY'),                     --#89512
                          TO_CHAR (SYSDATE, 'DD.MM.YYYY'),
                          '________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p23',
                COALESCE (TO_CHAR (get_ap_document_attr_str (p_ap_id,
                                                             l_app_id,
                                                             802,
                                                             1465),
                                   'HH24:MI'),                        --#89512
                          TO_CHAR (SYSDATE, 'HH24:MI'),
                          '_____________________'));

            rdm$rtfl.putreporttoworkingqueue (v_jbr_id);
        END IF;

        RETURN v_jbr_id;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми «Заява щодо відмови від отримання соціальних послуг»
    -- params: p_rt_id - ідентифікатор звіту,
    --         p_ap_id - ідентифікатор звернення
    -- note:   #86961
    FUNCTION get_appeal_ros_app_v1 (p_rt_id   IN rpt_templates.rt_id%TYPE,
                                    p_ap_id   IN appeal.ap_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id       DECIMAL;

        CURSOR cur IS
              SELECT a.ap_id,
                     p.app_id,
                     p.app_inn,
                     p.app_doc_num,
                     tools.init_cap (
                         p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn)
                         AS pers_name,                               --Заявник
                     a.ap_reg_dt,                  --14 – дата створення заяви
                     (SELECT o.org_name
                        FROM v_opfu o
                       WHERE o.org_id = a.com_org)
                         AS org_name,                     --найменування СПСЗН
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 605
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 1673)
                         AS num_pfone,                        --Номер телефону
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 605
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3060)
                         AS email,                  --Адреса електронної пошти
                     (SELECT DIC_SNAME
                        FROM uss_ndi.v_ddn_ss_provide pr
                       WHERE pr.DIC_VALUE =
                             (SELECT MAX (da.apda_val_string)
                                FROM ap_document d, ap_document_attr da
                               WHERE     d.apd_ap = a.ap_id
                                     AND d.apd_app = p.app_id
                                     AND d.apd_ndt = 800
                                     AND d.history_status = 'A'
                                     AND d.apd_id = da.apda_apd
                                     AND da.history_status = 'A'
                                     AND da.apda_nda = 3061))
                         AS who_is,                    --6 – послуга надається
                     (  SELECT tools.init_cap (
                                   p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn)    ipb
                          FROM ap_person p
                         WHERE     p.app_ap = a.ap_id
                               AND p.history_status = 'A'
                               AND p.app_tp IN ('Z', 'OS')
                      ORDER BY p.app_tp
                         FETCH FIRST 1 ROW ONLY)
                         AS pers_get,                     --7 – ПІБ отримувача
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 800
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3062)
                         AS dog_num,                          --8 – № договору
                     (SELECT MAX (TO_CHAR (da.apda_val_dt, 'dd/mm/yyyy'))
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 800
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3063)
                         AS dog_date,           --9 – дата підписання договору
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 800
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3064)
                         AS provider,             --11 – найменування надавача
                     (SELECT MAX (TO_CHAR (da.apda_val_dt, 'dd/mm/yyyy'))
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 800
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3065)
                         AS stop_date, --12 – припинити надання соціальних послуг з
                     (SELECT MAX (t.rnp_comment)
                        FROM ap_document                 d,
                             ap_document_attr            da,
                             uss_ndi.v_ndi_reason_not_pay t
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 800
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3066
                             AND t.rnp_id = da.apda_val_string)
                         AS reason --13 – причина дострокового розірвання договору
                FROM v_appeal a
                     LEFT JOIN V_ap_person p
                         ON     p.app_ap = a.ap_id
                            AND p.history_status = 'A'
                            AND p.app_tp IN ('Z')                  --"Заявник"
               WHERE a.ap_id = p_ap_id               --a.ap_num like '%41500%'
            ORDER BY p.app_tp;

        r              cur%ROWTYPE;

        l_address      VARCHAR2 (1000);
        l_who_is       VARCHAR2 (1000);
        l_ap_service   VARCHAR2 (32000);
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        --Адреса проживання для листування
        l_address :=
            get_pers_fact_address (p_ap_id => p_ap_id, p_app_id => r.app_id);

          --c.who_is - \ulТекст\ul0 -втавити тег підкреслення
          SELECT LISTAGG (DIC_SNAME, '/') WITHIN GROUP (ORDER BY dic_name)
            INTO l_who_is
            FROM uss_ndi.v_ddn_ss_provide pr
        ORDER BY DIC_SRTORDR;

        r.who_is := REPLACE (l_who_is, r.who_is, '\ul' || r.who_is || '\ul0');

          SELECT LISTAGG (t.nst_name, '; ') WITHIN GROUP (ORDER BY NST_name)
            INTO l_ap_service
            FROM uss_visit.v_ap_service s
                 JOIN uss_ndi.v_ndi_service_type t ON s.aps_nst = t.nst_id
           WHERE s.aps_ap = p_ap_id AND s.history_status = 'A'
        ORDER BY s.aps_nst;


        l_jbr_id := rdm$rtfl.initreport (p_rt_id);
        rdm$rtfl.addparam (l_jbr_id, 'address', l_address);
        rdm$rtfl.addparam (l_jbr_id, 'pers_name', r.pers_name);
        rdm$rtfl.addparam (l_jbr_id, 'ap_reg_dt', r.ap_reg_dt);
        rdm$rtfl.addparam (l_jbr_id, 'org_name', r.org_name);
        rdm$rtfl.addparam (l_jbr_id, 'num_pfone', r.num_pfone);
        rdm$rtfl.addparam (l_jbr_id, 'email', r.email);
        rdm$rtfl.addparam (l_jbr_id, 'who_is', r.who_is);
        rdm$rtfl.addparam (l_jbr_id, 'pers_get', r.pers_get);
        rdm$rtfl.addparam (l_jbr_id, 'dog_num', r.dog_num);
        rdm$rtfl.addparam (l_jbr_id, 'dog_date', r.dog_date);
        rdm$rtfl.addparam (l_jbr_id, 'provider', r.provider);
        rdm$rtfl.addparam (l_jbr_id, 'stop_date', r.stop_date);
        rdm$rtfl.addparam (l_jbr_id, 'reason', r.reason);
        rdm$rtfl.addparam (l_jbr_id, 'ap_service', l_ap_service);
        rdm$rtfl.putreporttoworkingqueue (l_jbr_id);

        RETURN l_jbr_id;
    END get_appeal_ros_app_v1;

    -- info:   Ініціалізація процесу підготовки друкованої форми «Заява щодо відмови від отримання соціальних послуг» nda=800
    -- params: p_rt_id - ідентифікатор звіту,
    --         p_ap_id - ідентифікатор звернення
    -- note:   #100217
    FUNCTION Get_Appeal_Ros_App_V2 (p_Rt_Id   IN Rpt_Templates.Rt_Id%TYPE,
                                    p_Ap_Id   IN Appeal.Ap_Id%TYPE)
        RETURN DECIMAL
    IS
        l_Jbr_Id       DECIMAL;

        CURSOR Cur IS
              SELECT a.Ap_Id,
                     p.App_Id,
                     p.App_Inn,
                     p.App_Doc_Num,
                     Tools.Init_Cap (
                         p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn)
                         AS Pib_z,                                   --Заявник
                     p.App_Ln,
                     a.Ap_Reg_Dt,                  --14 – дата створення заяви
                     o.Org_Name
                         AS Org_Name                      --найменування СПСЗН
                FROM v_Appeal a, v_Opfu o, v_Ap_Person p
               WHERE     a.Ap_Id = p_Ap_Id           --a.ap_num like '%41500%'
                     AND o.Org_Id = a.Com_Org
                     AND p.App_Ap = a.Ap_Id
                     AND p.History_Status = 'A'
                     AND p.App_Tp IN ('Z')                         --"Заявник"
            ORDER BY p.App_Tp;

        r              Cur%ROWTYPE;

        l_P6           VARCHAR2 (10);
        l_Str          VARCHAR2 (32000);
        l_Address      VARCHAR2 (1000);
        l_Ap_Service   VARCHAR2 (32000);
    BEGIN
        OPEN Cur;

        FETCH Cur INTO r;

        CLOSE Cur;

        l_Jbr_Id := Rdm$rtfl.Initreport (p_Rt_Id);

        Rdm$rtfl.Addparam (l_Jbr_Id, '1', r.Org_Name);
        Rdm$rtfl.Addparam (l_Jbr_Id, '2', r.Pib_z);
        --Адреса проживання для листування
        l_Address :=
            Get_Pers_Fact_Address (p_Ap_Id => p_Ap_Id, p_App_Id => r.App_Id);
        Rdm$rtfl.Addparam (l_Jbr_Id, '3', l_Address);
        Rdm$rtfl.Addparam (l_Jbr_Id,
                           '4',
                           Get_Ap_Document_Attr_Str (p_Ap_Id,
                                                     r.App_Id,
                                                     NULL,
                                                     1673));  --Номер телефону
        Rdm$rtfl.Addparam (l_Jbr_Id,
                           '5',
                           Get_Ap_Document_Attr_Str (p_Ap_Id,
                                                     r.App_Id,
                                                     NULL,
                                                     3060)); --Адреса електронної пошти
        --Відмовляюсь від отримання 6мною / моїм(єю) сином (донькою) / моєю сім’єю / підопічним(ою)
        l_P6 :=
            Get_Ap_Document_Attr_Str (p_Ap_Id,
                                      r.App_Id,
                                      NULL,
                                      3061);
        l_Str :=
               Underline ('мною', l_P6 = 'Z')
            || ' / '
            || Underline ('моїм(єю) сином (донькою)', l_P6 = 'B')
            || ' / '
            || Underline ('моєю сім’єю', l_P6 = 'FM')
            || ' / '
            || Underline ('підопічним(ою)', l_P6 = 'CHRG');
        Rdm$rtfl.Addparam (l_Jbr_Id, '6', l_Str);
        -- ПІБ учасника з п.6. Якщо nda_id in (3061) = FM, то виводити ПІБ учасника Z
        l_Str := CASE WHEN l_P6 = 'FM' THEN r.App_Ln ELSE r.Pib_z END;
        Rdm$rtfl.Addparam (l_Jbr_Id, '7', l_Str);
        Rdm$rtfl.Addparam (l_Jbr_Id,
                           '8',
                           Get_Ap_Document_Attr_Str (p_Ap_Id,
                                                     NULL,
                                                     NULL,
                                                     3062));  --Номер договору
        Rdm$rtfl.Addparam (l_Jbr_Id,
                           '9',
                           TO_CHAR (Get_Ap_Document_Attr_Dt (p_Ap_Id,
                                                             NULL,
                                                             NULL,
                                                             3063),
                                    'dd.mm.yyyy'));

          SELECT LISTAGG (t.Nst_Name, '; \par')
                     WITHIN GROUP (ORDER BY Nst_Name)
            INTO l_Ap_Service
            FROM Uss_Visit.Ap_Service s
                 JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Aps_Nst = t.Nst_Id
           WHERE s.Aps_Ap = p_Ap_Id AND s.History_Status = 'A'
        ORDER BY t.Nst_Order;

        Rdm$rtfl.Addparam (l_Jbr_Id, '10', l_Ap_Service);
        Rdm$rtfl.Addparam (l_Jbr_Id,
                           '11',
                           Get_Ap_Document_Attr_Str (p_Ap_Id,
                                                     NULL,
                                                     NULL,
                                                     3064));         --надавач
        Rdm$rtfl.Addparam (l_Jbr_Id,
                           '12',
                           TO_CHAR (Get_Ap_Document_Attr_Dt (p_Ap_Id,
                                                             NULL,
                                                             NULL,
                                                             3065),
                                    'dd.mm.yyyy'));

        --13 – причина дострокового розірвання договору
        SELECT MAX (t.Rnp_Comment)
          INTO l_Str
          FROM Uss_Ndi.v_Ndi_Reason_Not_Pay t
         WHERE t.Rnp_Id = Get_Ap_Document_Attr_Str (p_Ap_Id,
                                                    NULL,
                                                    NULL,
                                                    3066);


        Rdm$rtfl.Addparam (l_Jbr_Id, '13', l_Str);
        Rdm$rtfl.Addparam (l_Jbr_Id, '14', r.Ap_Reg_Dt);

        Rdm$rtfl.Putreporttoworkingqueue (l_Jbr_Id);
        RETURN l_Jbr_Id;
    END Get_Appeal_Ros_App_V2;

    -- info:   Ініціалізація процесу підготовки друкованої форми «Інформація про припинення надання соціальних послуг»
    -- params: p_rt_id - ідентифікатор звіту,
    --         p_ap_id - ідентифікатор звернення
    -- note:   #86965
    FUNCTION get_appeal_gs_r1 (p_rt_id   IN rpt_templates.rt_id%TYPE,
                               p_ap_id   IN appeal.ap_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id       DECIMAL;

        CURSOR cur IS
              SELECT a.ap_id,
                     p.app_id,
                     p.app_inn,
                     p.app_doc_num,
                     tools.init_cap (
                         p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn)
                         AS pers_name,                               --Заявник
                     a.ap_reg_dt,                  --14 – дата створення заяви
                     (SELECT o.org_name
                        FROM v_opfu o
                       WHERE o.org_id = a.com_org)
                         AS org_name,                     --найменування СПСЗН
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3068)
                         AS provider,              --2 – найменування надавача
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda IN (3069))
                         AS num_pfone,                        --Номер телефону
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3070)
                         AS email,                  --Адреса електронної пошти
                     (SELECT MAX (t.dic_name)
                        FROM ap_document             d,
                             ap_document_attr        da,
                             uss_ndi.v_ddn_ss_mng_doc t
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3071
                             AND t.dic_value = da.apda_val_string)
                         AS rzp_doc_name, --6 – назва розпорядчого документа надавача
                     (SELECT MAX (TO_CHAR (da.apda_val_dt, 'dd/mm/yyyy'))
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3072)
                         AS rzp_doc_date, --7 – дата розпорядчого документа надавача
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3073)
                         AS rzp_doc_num, --8 – номер розпорядчого документа надавача
                     (  SELECT tools.init_cap (
                                   p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn)    ipb
                          FROM ap_person p
                         WHERE     p.app_ap = a.ap_id
                               AND p.history_status = 'A'
                               AND p.app_tp IN ('OS')
                      ORDER BY p.app_tp
                         FETCH FIRST 1 ROW ONLY)
                         AS pers_get,                     --9 – ПІБ отримувача
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3074)
                         AS dog_num,                         --10 – № договору
                     (SELECT MAX (TO_CHAR (da.apda_val_dt, 'dd/mm/yyyy'))
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3075)
                         AS dog_date,          --11 – дата підписання договору
                     (SELECT t.rnp_comment
                        FROM ap_document                 d,
                             ap_document_attr            da,
                             uss_ndi.v_ndi_reason_not_pay t
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3076
                             AND t.rnp_id = da.apda_val_string)
                         AS reason, --13 – причина припинення надання соціальних послуг
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3077)
                         AS reason_info, --14 – Інформація про підставу припинення надання соціальних послуг
                     (SELECT MAX (TO_CHAR (da.apda_val_dt, 'dd/mm/yyyy'))
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3078)
                         AS stop_date, --15 – припинити надання соцільних послуг з
                     (SELECT MAX (da.apda_val_string)
                        FROM ap_document d, ap_document_attr da
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3079)
                         AS menager, --16 – посада керівника надавача соціальних послуг
                     (SELECT    MAX (da.apda_val_string)
                             || ' '
                             || MAX (da2.apda_val_string)
                        FROM ap_document     d,
                             ap_document_attr da,
                             ap_document_attr da2
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_app = p.app_id
                             AND d.apd_ndt = 861
                             AND d.history_status = 'A'
                             AND d.apd_id = da.apda_apd
                             AND da.history_status = 'A'
                             AND da.apda_nda = 3128
                             AND d.apd_id = da2.apda_apd
                             AND da2.history_status = 'A'
                             AND da2.apda_nda = 3129)
                         AS IPB                 --17 – власне ім’я та прізвище
                FROM v_appeal a
                     LEFT JOIN V_ap_person p
                         ON     p.app_ap = a.ap_id
                            AND p.history_status = 'A'
                            AND p.app_tp IN ('Z')                  --"Заявник"
               WHERE a.ap_id = p_ap_id
            ORDER BY p.app_tp;

        r              cur%ROWTYPE;

        l_address      VARCHAR2 (1000);
        l_ap_service   VARCHAR2 (32000);
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        --Адреса для листування
        SELECT RTRIM (
                   (   MAX (
                           CASE
                               WHEN     da.apda_nda = 3122
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   TRIM (da.apda_val_string) || ', '
                           END)
                    || (LTRIM (
                               MAX (
                                   CASE
                                       WHEN da.apda_nda = 1716
                                       THEN
                                           COALESCE (
                                               (CASE
                                                    WHEN da.apda_val_id
                                                             IS NOT NULL
                                                    THEN
                                                        uss_visit.dnet$appeals_reports.get_katottg_info (
                                                            da.apda_val_id)
                                                END),
                                               da.apda_val_string)
                                   END)
                            || ', ',
                            ', '))
                    || COALESCE (
                           LTRIM (
                                  MAX (
                                      CASE
                                          WHEN da.apda_nda = 3123
                                          THEN
                                              COALESCE (
                                                  (CASE
                                                       WHEN da.apda_val_id
                                                                IS NOT NULL
                                                       THEN
                                                           uss_visit.dnet$appeals_reports.get_street_info (
                                                               da.apda_val_id)
                                                   END),
                                                  TRIM (da.apda_val_string))
                                      END)
                               || ', ',
                               ', '),
                           MAX (
                               CASE
                                   WHEN     da.apda_nda = 3124
                                        AND TRIM (da.apda_val_string)
                                                IS NOT NULL
                                   THEN
                                          'вул. '
                                       || TRIM (da.apda_val_string)
                                       || ', '
                               END))
                    || MAX (
                           CASE
                               WHEN     da.apda_nda = 3125
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'буд. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     da.apda_nda = 3126
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                      'корп. '
                                   || TRIM (da.apda_val_string)
                                   || ', '
                           END)
                    || MAX (
                           CASE
                               WHEN     da.apda_nda = 3127
                                    AND TRIM (da.apda_val_string) IS NOT NULL
                               THEN
                                   'кв. ' || TRIM (da.apda_val_string)
                           END)),
                   ', ')    AS pers_reg_addr
          INTO l_address
          FROM v_ap_document  d
               JOIN v_ap_document_attr da
                   ON     da.apda_apd = d.apd_id
                      AND da.apda_ap = d.apd_ap
                      AND d.apd_app = r.app_id
                      AND da.apda_nda IN (3122,
                                          1716,
                                          3123,
                                          3124,
                                          3125,
                                          3126,
                                          3127)
                      AND da.history_status = 'A'
         WHERE     d.apd_ap = p_ap_id
               AND d.apd_ndt = 861
               AND d.history_status = 'A';


          SELECT LISTAGG (t.nst_name, '; ') WITHIN GROUP (ORDER BY NST_name)
            INTO l_ap_service
            FROM uss_visit.v_ap_service s
                 JOIN uss_ndi.v_ndi_service_type t ON s.aps_nst = t.nst_id
           WHERE s.aps_ap = p_ap_id AND s.history_status = 'A'
        ORDER BY s.aps_nst;

        l_jbr_id := rdm$rtfl.initreport (p_rt_id);
        rdm$rtfl.addparam (l_jbr_id, 'pers_name', r.pers_name);
        rdm$rtfl.addparam (l_jbr_id, 'org_name', r.org_name);
        rdm$rtfl.addparam (l_jbr_id, 'provider', r.provider);
        rdm$rtfl.addparam (l_jbr_id, 'num_pfone', r.num_pfone);
        rdm$rtfl.addparam (l_jbr_id, 'email', r.email);
        rdm$rtfl.addparam (l_jbr_id, 'address', l_address);
        rdm$rtfl.addparam (l_jbr_id, 'rzp_doc_name', r.rzp_doc_name);
        rdm$rtfl.addparam (l_jbr_id, 'rzp_doc_date', r.rzp_doc_date);
        rdm$rtfl.addparam (l_jbr_id, 'rzp_doc_num', r.rzp_doc_num);

        rdm$rtfl.addparam (l_jbr_id, 'pers_get', r.pers_get);
        rdm$rtfl.addparam (l_jbr_id, 'dog_num', r.dog_num);
        rdm$rtfl.addparam (l_jbr_id, 'dog_date', r.dog_date);
        rdm$rtfl.addparam (l_jbr_id, 'stop_date', r.stop_date);
        rdm$rtfl.addparam (l_jbr_id, 'reason', r.reason);
        rdm$rtfl.addparam (l_jbr_id, 'reason_info', r.reason_info);
        rdm$rtfl.addparam (l_jbr_id, 'ap_service', l_ap_service);
        rdm$rtfl.addparam (l_jbr_id, 'ipb', r.ipb);
        rdm$rtfl.addparam (l_jbr_id, 'menager', r.menager);
        rdm$rtfl.putreporttoworkingqueue (l_jbr_id);
        RETURN l_jbr_id;
    END get_appeal_gs_r1;

    -- info:   Ініціалізація процесу підготовки друкованої форми «Заява про надання соціальної послуги медіації»
    -- params: p_rt_id - ідентифікатор звіту,
    --         p_ap_id - ідентифікатор звернення
    -- note:   #88712
    FUNCTION get_appeal_smd_r1 (p_rt_id   IN rpt_templates.rt_id%TYPE,
                                p_ap_id   IN appeal.ap_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id           DECIMAL;

        C_EMPTY   CONSTANT VARCHAR2 (500)
            := '__________________________________________________________________' ;

        CURSOR cur1 IS
              SELECT dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 836,
                         p_nda      => 3440)
                         AS p1,                                    --підрозділ
                     tools.init_cap (
                         p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn)
                         AS p2,                                      --Заявник
                     TO_CHAR (COALESCE (dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 6,
                                            p_nda      => 606),
                                        dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 7,
                                            p_nda      => 607),
                                        dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 8,
                                            p_nda      => 2014),
                                        dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 9,
                                            p_nda      => 2015),
                                        dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 805,
                                            p_nda      => 1843)),
                              'dd.mm.yyyy')
                         AS p3,                              --дата народження
                     dnet$appeals_reports.get_pers_fact_address (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id)
                         AS p4,
                     dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 605,
                         p_nda      => 1673)
                         AS p5,
                     dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 6,
                         p_nda      => 3)
                         AS p6,
                     dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 7,
                         p_nda      => 9)
                         AS p7,
                     NVL (   dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => a.ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 6,
                                 p_nda      => 7)
                          || ' '
                          || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                          p_ap_id    => a.ap_id,
                                          p_app_id   => p.app_id,
                                          p_ndt      => 6,
                                          p_nda      => 5),
                                      'dd.mm.yyyy'),
                             dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => a.ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 7,
                                 p_nda      => 13)
                          || ' '
                          || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                          p_ap_id    => a.ap_id,
                                          p_app_id   => p.app_id,
                                          p_ndt      => 6,
                                          p_nda      => 14),
                                      'dd.mm.yyyy'))
                         AS p8,                 --Ким та коли виданий документ
                     dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 7,
                         p_nda      => 810)
                         AS p9,
                     CASE
                         WHEN p10.p10_1 IS NOT NULL
                         THEN
                             '\ulпосвідки на постійне проживання\ul0, посвідки на тимчасове проживання, посвідчення біженця, посвідчення про взяття на облік бездомної особи'
                         WHEN p10.p10_2 IS NOT NULL
                         THEN
                             'посвідки на постійне проживання, \ulпосвідки на тимчасове проживання\ul0, посвідчення біженця, посвідчення про взяття на облік бездомної особи'
                         WHEN p10.p10_3 IS NOT NULL
                         THEN
                             'посвідки на постійне проживання, посвідки на тимчасове проживання, \ulпосвідчення біженця\ul0, посвідчення про взяття на облік бездомної особи'
                         WHEN p10.p10_4 IS NOT NULL
                         THEN
                             'посвідки на постійне проживання, посвідки на тимчасове проживання, посвідчення біженця, \ulпосвідчення про взяття на облік бездомної особи\ul0'
                         ELSE
                             'посвідки на постійне проживання, посвідки на тимчасове проживання, посвідчення біженця, посвідчення про взяття на облік бездомної особи'
                     END
                         AS p10,
                     COALESCE (p10.p10_1,
                               p10.p10_2,
                               p10.p10_3,
                               p10.p10_4,
                               '_____')
                         AS p11,          --номер документа учасника звернення
                     CASE
                         WHEN p10.p10_1 IS NOT NULL
                         THEN
                                dnet$appeals_reports.get_ap_document_attr_str (
                                    p_ap_id    => a.ap_id,
                                    p_app_id   => p.app_id,
                                    p_ndt      => 8,
                                    p_nda      => 17)
                             || ' '
                             || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                             p_ap_id    => a.ap_id,
                                             p_app_id   => p.app_id,
                                             p_ndt      => 8,
                                             p_nda      => 20),
                                         'dd.mm.yyyy')
                         WHEN p10.p10_2 IS NOT NULL
                         THEN
                                dnet$appeals_reports.get_ap_document_attr_str (
                                    p_ap_id    => a.ap_id,
                                    p_app_id   => p.app_id,
                                    p_ndt      => 9,
                                    p_nda      => 23)
                             || ' '
                             || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                             p_ap_id    => a.ap_id,
                                             p_app_id   => p.app_id,
                                             p_ndt      => 9,
                                             p_nda      => 22),
                                         'dd.mm.yyyy')
                         WHEN p10.p10_3 IS NOT NULL
                         THEN
                                dnet$appeals_reports.get_ap_document_attr_str (
                                    p_ap_id    => a.ap_id,
                                    p_app_id   => p.app_id,
                                    p_ndt      => 14,
                                    p_nda      => 48)
                             || ' '
                             || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                             p_ap_id    => a.ap_id,
                                             p_app_id   => p.app_id,
                                             p_ndt      => 14,
                                             p_nda      => 47),
                                         'dd.mm.yyyy')
                         WHEN p10.p10_4 IS NOT NULL
                         THEN
                                dnet$appeals_reports.get_ap_document_attr_str (
                                    p_ap_id    => a.ap_id,
                                    p_app_id   => p.app_id,
                                    p_ndt      => 805,
                                    p_nda      => 1842)
                             || ' '
                             || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                             p_ap_id    => a.ap_id,
                                             p_app_id   => p.app_id,
                                             p_ndt      => 805,
                                             p_nda      => 1841),
                                         'dd.mm.yyyy')
                     END
                         AS p12,                      --Ким та коли видана(не)
                     NVL (TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                       p_ap_id    => a.ap_id,
                                       p_app_id   => p.app_id,
                                       p_ndt      => 8,
                                       p_nda      => 19),
                                   'dd.mm.yyyy'),
                          TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                       p_ap_id    => a.ap_id,
                                       p_app_id   => p.app_id,
                                       p_ndt      => 9,
                                       p_nda      => 24),
                                   'dd.mm.yyyy'))
                         AS p13, --Дата закінчення (продовження) строку дії посвідки
                     p.app_inn
                         AS p14,  --14 – РНОКПП - учасника звернення з поля №2
                     dnet$appeals_reports.get_pers_reg_address (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id)
                         AS p15,              --Зареєстроване місце проживання
                     dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 801,
                         p_nda      => 1871)
                         nda1871,                            --чи є декларація
                     CASE
                         WHEN dnet$appeals_reports.get_ap_document_attr_str (
                                  p_ap_id    => a.ap_id,
                                  p_app_id   => p.app_id,
                                  p_ndt      => 836,
                                  p_nda      => 3443) IN ('B', 'CHRG')
                         THEN
                             'OS'
                         ELSE
                             'Z'
                     END
                         AS p18_is_os,
                     (SELECT LISTAGG (
                                 DECODE (
                                     t.dic_value,
                                     dnet$appeals_reports.get_ap_document_attr_str (
                                         p_ap_id    => a.ap_id,
                                         p_app_id   => p.app_id,
                                         p_ndt      => 836,
                                         p_nda      => 3443),    '\ul'
                                                              || t.dic_name
                                                              || '\ul0',
                                     t.dic_name),
                                 ' / ')
                             WITHIN GROUP (ORDER BY t.dic_srtordr)
                        FROM uss_ndi.v_ddn_ss_provide t)
                         AS p18, --моєму(їй) синові (доньці) / підопічному(ій)
                     DECODE (p24.dic_value, 'F', v_check_mark)
                         AS p24,                                  --безоплатно
                     DECODE (p24.dic_value, 'C', v_check_mark)
                         AS p24_1,
                     DECODE (p24.dic_value, 'D', v_check_mark)
                         AS p24_2,
                     (SELECT LISTAGG (
                                 DECODE (
                                     t.dic_value,
                                     dnet$appeals_reports.get_ap_document_attr_str (
                                         p_ap_id    => a.ap_id,
                                         p_app_id   => p.app_id,
                                         p_ndt      => 836,
                                         p_nda      => 3449),    '\ul'
                                                              || t.dic_name
                                                              || '\ul0',
                                     t.dic_name),
                                 ' / ')
                             WITHIN GROUP (ORDER BY t.dic_srtordr)
                        FROM uss_ndi.v_ddn_ss_cnfl_rsl t)
                         AS p25,
                     (SELECT LISTAGG (
                                 DECODE (
                                     t.dic_value,
                                     dnet$appeals_reports.get_ap_document_attr_str (
                                         p_ap_id    => a.ap_id,
                                         p_app_id   => p.app_id,
                                         p_ndt      => 836,
                                         p_nda      => 3450),    '\ul'
                                                              || t.dic_name
                                                              || '\ul0',
                                     t.dic_name),
                                 ' / ')
                             WITHIN GROUP (ORDER BY t.dic_srtordr)
                        FROM uss_ndi.v_ddn_ss_dispute_btw t)
                         AS p26, --мені / моєму(їй) синові (доньці) / моїй сім’ї / підопічному(ій)
                        ---------------------------------------------------------------------------------------------------
                        dnet$appeals_reports.get_ap_document_attr_str (
                            p_ap_id    => a.ap_id,
                            p_app_id   => p.app_id,
                            p_ndt      => 836,
                            p_nda      => 3452)
                     || ' '
                     || dnet$appeals_reports.get_ap_document_attr_str (
                            p_ap_id    => a.ap_id,
                            p_app_id   => p.app_id,
                            p_ndt      => 836,
                            p_nda      => 3453)
                     || ' '
                     || dnet$appeals_reports.get_ap_document_attr_str (
                            p_ap_id    => a.ap_id,
                            p_app_id   => p.app_id,
                            p_ndt      => 836,
                            p_nda      => 3454)
                         AS p27, --ПІБ іншого учасника ймовірного/наявного конфлікту
                     (SELECT RTRIM (
                                 (   MAX (
                                         CASE
                                             WHEN     da.apda_nda = 3456
                                                  AND TRIM (da.apda_val_string)
                                                          IS NOT NULL
                                             THEN
                                                    TRIM (da.apda_val_string)
                                                 || ', '
                                         END)
                                  || (LTRIM (
                                             MAX (
                                                 CASE
                                                     WHEN da.apda_nda = 3455
                                                     THEN
                                                         COALESCE (
                                                             (CASE
                                                                  WHEN da.apda_val_id
                                                                           IS NOT NULL
                                                                  THEN
                                                                      dnet$appeals_reports.get_katottg_info (
                                                                          da.apda_val_id)
                                                              END),
                                                             da.apda_val_string)
                                                 END)
                                          || ', ',
                                          ', '))
                                  || COALESCE (
                                         LTRIM (
                                                MAX (
                                                    CASE
                                                        WHEN da.apda_nda = 3457
                                                        THEN
                                                            COALESCE (
                                                                (CASE
                                                                     WHEN da.apda_val_id
                                                                              IS NOT NULL
                                                                     THEN
                                                                         dnet$appeals_reports.get_street_info (
                                                                             da.apda_val_id)
                                                                 END),
                                                                TRIM (
                                                                    da.apda_val_string))
                                                    END)
                                             || ', ',
                                             ', '),
                                         MAX (
                                             CASE
                                                 WHEN     da.apda_nda = 3458
                                                      AND TRIM (
                                                              da.apda_val_string)
                                                              IS NOT NULL
                                                 THEN
                                                        'вул. '
                                                     || TRIM (
                                                            da.apda_val_string)
                                                     || ', '
                                             END))
                                  || MAX (
                                         CASE
                                             WHEN     da.apda_nda = 3459
                                                  AND TRIM (da.apda_val_string)
                                                          IS NOT NULL
                                             THEN
                                                    'буд. '
                                                 || TRIM (da.apda_val_string)
                                                 || ', '
                                         END)
                                  || MAX (
                                         CASE
                                             WHEN     da.apda_nda = 3460
                                                  AND TRIM (da.apda_val_string)
                                                          IS NOT NULL
                                             THEN
                                                    'корп. '
                                                 || TRIM (da.apda_val_string)
                                                 || ', '
                                         END)
                                  || MAX (
                                         CASE
                                             WHEN     da.apda_nda = 3461
                                                  AND TRIM (da.apda_val_string)
                                                          IS NOT NULL
                                             THEN
                                                    'кв. '
                                                 || TRIM (da.apda_val_string)
                                         END)),
                                 ', ')    AS addr
                        FROM v_ap_document d
                             JOIN v_ap_document_attr da
                                 ON     da.apda_apd = d.apd_id
                                    AND da.apda_ap = d.apd_ap
                                    AND da.apda_nda IN (3456,
                                                        3455,
                                                        3457,
                                                        3458,
                                                        3459,
                                                        3460,
                                                        3461)
                                    AND da.history_status = 'A'
                       WHERE     d.apd_ap = a.ap_id
                             AND d.apd_ndt = 836
                             AND d.history_status = 'A')
                         AS p28, --Місце проживання/перебування іншого учасника ймовірного/наявного конфлікту
                     dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 836,
                         p_nda      => 3462)
                         AS p29,
                     dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 836,
                         p_nda      => 3463)
                         AS p30,
                     dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 836,
                         p_nda      => 3451)
                         AS p31,
                     DECODE (dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => a.ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 836,
                                 p_nda      => 3464),
                             'T', v_check_mark)
                         AS p32, --підтвердження про надання інформації заявником
                     CASE
                         WHEN dnet$appeals_reports.get_ap_document_attr_str (
                                  p_ap_id    => a.ap_id,
                                  p_app_id   => p.app_id,
                                  p_ndt      => 836,
                                  p_nda      => 3447) = 'ON'
                         THEN
                             '\ulонлайн\ul0 / офлайн'
                         WHEN dnet$appeals_reports.get_ap_document_attr_str (
                                  p_ap_id    => a.ap_id,
                                  p_app_id   => p.app_id,
                                  p_ndt      => 836,
                                  p_nda      => 3447) = 'OF'
                         THEN
                             'онлайн / \ulофлайн\ul0'
                         ELSE
                             'онлайн / офлайн'
                     END
                         AS p33,             --uss_ndi.V_DDN_SS_FORM_MEDIATION
                     DECODE (dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => a.ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 836,
                                 p_nda      => 3465),
                             'T', v_check_mark)
                         AS p34,
                     dnet$appeals_reports.get_ap_document_attr_str (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id,
                         p_ndt      => 836,
                         p_nda      => 3448)
                         AS p35,                                 -- надавач СП
                     (SELECT    NVL2 (
                                    MAX (d.apr_start_dt),
                                       TO_CHAR (MAX (d.apr_start_dt),
                                                'dd.mm.yyyy')
                                    || 'р.',
                                    '____________')
                             || ' до '
                             || NVL2 (
                                    MAX (d.apr_stop_dt),
                                       TO_CHAR (MAX (d.apr_stop_dt),
                                                'dd.mm.yyyy')
                                    || 'р.',
                                    '____________')
                        FROM v_ap_declaration d
                       WHERE d.apr_ap = a.ap_id)
                         AS p36,
                     '_____'
                         p40,      -- кількість поданих у зверненні документів
                     DECODE (dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => a.ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 836,
                                 p_nda      => 3466),
                             'T', v_check_mark)
                         AS p41,
                     DECODE (dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => a.ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 836,
                                 p_nda      => 3467),
                             'T', v_check_mark)
                         AS p42,
                     DECODE (dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => a.ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 836,
                                 p_nda      => 3468),
                             'T', v_check_mark)
                         AS p43,
                     DECODE (dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => a.ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 836,
                                 p_nda      => 3469),
                             'T', v_check_mark)
                         AS p44,
                     NVL (   TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                          p_ap_id    => a.ap_id,
                                          p_app_id   => p.app_id,
                                          p_ndt      => 836,
                                          p_nda      => 3470),
                                      'dd.mm.yyyy')
                          || 'p.',
                          '_________')
                         AS p45
                FROM v_appeal a
                     LEFT JOIN v_ap_person p
                         ON     p.app_ap = a.ap_id
                            AND p.history_status = 'A'
                            AND p.app_tp = 'Z'                     --"Заявник"
                     LEFT JOIN
                     (SELECT dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => p_ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 8,
                                 p_nda      => 15)     p10_1,
                             dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => p_ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 9,
                                 p_nda      => 21)     p10_2,
                             dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => p_ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 14,
                                 p_nda      => 46)     p10_3,
                             dnet$appeals_reports.get_ap_document_attr_str (
                                 p_ap_id    => p_ap_id,
                                 p_app_id   => p.app_id,
                                 p_ndt      => 805,
                                 p_nda      => 1840)   p10_4
                        FROM v_ap_person p
                       WHERE     p.app_ap = p_ap_id
                             AND p.history_status = 'A'
                             AND p.app_tp = 'Z') p10
                         ON 1 = 1
                     LEFT JOIN uss_ndi.v_ddn_ss_method p24
                         ON p24.dic_value = dnet$appeals_reports.get_ap_document_attr_str (
                                                p_ap_id    => a.ap_id,
                                                p_app_id   => p.app_id,
                                                p_ndt      => 836,
                                                p_nda      => 3441)
               WHERE a.ap_id = p_ap_id
            ORDER BY p.app_tp;

        r1                 cur1%ROWTYPE;

        --ЗАЯВА ПРО НАДАННЯ СОЦІАЛЬНОЇ ПОСЛУГИ МЕДІАЦІЇ
        CURSOR cur2 IS
              SELECT TO_CHAR (a.ap_reg_dt, 'dd.mm.yyyy')
                         AS p16,
                     a.ap_num
                         AS p17,
                     tools.init_cap (
                         p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn)
                         AS p19,
                     TO_CHAR (COALESCE (dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 6,
                                            p_nda      => 606),
                                        dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 7,
                                            p_nda      => 607),
                                        dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 8,
                                            p_nda      => 2014),
                                        dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 9,
                                            p_nda      => 2015),
                                        dnet$appeals_reports.get_ap_document_attr_dt (
                                            p_ap_id    => a.ap_id,
                                            p_app_id   => p.app_id,
                                            p_ndt      => 805,
                                            p_nda      => 1843)),
                              'dd.mm.yyyy')
                         AS p20,                             --дата народження
                     CASE WHEN p21.dic_value IS NOT NULL THEN v_check_mark END
                         AS p21,                                     --інвалід
                        p21.dic_name
                     || ' '
                     || NVL2 (dnet$appeals_reports.get_ap_document_attr_dt (
                                  p_ap_id    => a.ap_id,
                                  p_app_id   => p.app_id,
                                  p_ndt      => 605,
                                  p_nda      => 1793),
                                 TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                              p_ap_id    => a.ap_id,
                                              p_app_id   => p.app_id,
                                              p_ndt      => 605,
                                              p_nda      => 1793),
                                          'dd.mm.yyyy')
                              || 'p.',
                              NULL)
                         AS p21_1,            -- інвалід група, дата посвіченя
                     dnet$appeals_reports.get_pers_fact_address (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id)
                         AS p22,
                     dnet$appeals_reports.get_pers_reg_address (
                         p_ap_id    => a.ap_id,
                         p_app_id   => p.app_id)
                         AS p23               --Зареєстроване місце проживання
                FROM v_appeal a
                     LEFT JOIN v_ap_person p
                         ON     p.app_ap = a.ap_id
                            AND p.history_status = 'A'
                            AND p.app_tp IN (r1.p18_is_os, 'Z')
                     LEFT JOIN uss_ndi.v_Ddn_Scy_Group p21
                         ON p21.DIC_VALUE = dnet$appeals_reports.get_ap_document_attr_str (
                                                p_ap_id    => a.ap_id,
                                                p_app_id   => p.app_id,
                                                p_ndt      => 605,
                                                p_nda      => 1790)
               WHERE a.ap_id = p_ap_id
            ORDER BY p.app_tp;

        r2                 cur2%ROWTYPE;


        CURSOR cur3 IS
            SELECT NVL2 (
                       p.app_ln,
                       tools.init_cap (
                           p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn),
                       C_EMPTY)                                       AS p46, --ПІБ законного представника
                   NVL2 (p.app_ln,
                         TO_CHAR (COALESCE (dnet$appeals_reports.get_ap_document_attr_dt (
                                                p_ap_id    => a.ap_id,
                                                p_app_id   => p.app_id,
                                                p_ndt      => 6,
                                                p_nda      => 606),
                                            dnet$appeals_reports.get_ap_document_attr_dt (
                                                p_ap_id    => a.ap_id,
                                                p_app_id   => p.app_id,
                                                p_ndt      => 7,
                                                p_nda      => 607),
                                            dnet$appeals_reports.get_ap_document_attr_dt (
                                                p_ap_id    => a.ap_id,
                                                p_app_id   => p.app_id,
                                                p_ndt      => 8,
                                                p_nda      => 2014),
                                            dnet$appeals_reports.get_ap_document_attr_dt (
                                                p_ap_id    => a.ap_id,
                                                p_app_id   => p.app_id,
                                                p_ndt      => 9,
                                                p_nda      => 2015),
                                            dnet$appeals_reports.get_ap_document_attr_dt (
                                                p_ap_id    => a.ap_id,
                                                p_app_id   => p.app_id,
                                                p_ndt      => 805,
                                                p_nda      => 1843)),
                                  'dd.mm.yyyy'),
                         '___________')                               AS p47, --дата народження
                   NVL2 (
                       p.app_ln,
                       dnet$appeals_reports.get_pers_fact_address (
                           p_ap_id    => a.ap_id,
                           p_app_id   => p.app_id),
                       C_EMPTY)                                       AS p48,
                   dnet$appeals_reports.get_ap_document_attr_str (
                       p_ap_id    => a.ap_id,
                       p_app_id   => p.app_id,
                       p_ndt      => 605,
                       p_nda      => 1673)                            AS p49,
                   dnet$appeals_reports.get_ap_document_attr_str (
                       p_ap_id    => a.ap_id,
                       p_app_id   => p.app_id,
                       p_ndt      => 605,
                       p_nda      => 3060)                            AS p50,
                   dnet$appeals_reports.get_ap_document_attr_str (
                       p_ap_id    => a.ap_id,
                       p_app_id   => p.app_id,
                       p_ndt      => 6,
                       p_nda      => 3)                               AS p51,
                   dnet$appeals_reports.get_ap_document_attr_str (
                       p_ap_id    => a.ap_id,
                       p_app_id   => p.app_id,
                       p_ndt      => 7,
                       p_nda      => 9)                               AS p52, --D-картка учасника звернення з типом ‘OR’
                   NVL (   dnet$appeals_reports.get_ap_document_attr_str (
                               p_ap_id    => a.ap_id,
                               p_app_id   => p.app_id,
                               p_ndt      => 6,
                               p_nda      => 7)
                        || ' '
                        || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                        p_ap_id    => a.ap_id,
                                        p_app_id   => p.app_id,
                                        p_ndt      => 6,
                                        p_nda      => 5),
                                    'dd.mm.yyyy'),
                           dnet$appeals_reports.get_ap_document_attr_str (
                               p_ap_id    => a.ap_id,
                               p_app_id   => p.app_id,
                               p_ndt      => 7,
                               p_nda      => 13)
                        || ' '
                        || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                        p_ap_id    => a.ap_id,
                                        p_app_id   => p.app_id,
                                        p_ndt      => 7,
                                        p_nda      => 14),
                                    'dd.mm.yyyy'))                    AS p53,
                   dnet$appeals_reports.get_ap_document_attr_str (
                       p_ap_id    => a.ap_id,
                       p_app_id   => p.app_id,
                       p_ndt      => 7,
                       p_nda      => 810)                             AS p54, --номер ЄДДР
                   COALESCE (p10.p10_1,
                             p10.p10_2,
                             p10.p10_3,
                             p10.p10_4)                               AS p55, --номер документа учасника звернення
                   CASE
                       WHEN p10.p10_1 IS NOT NULL
                       THEN
                           '\ulпосвідки на постійне проживання\ul0, посвідки на тимчасове проживання, посвідчення біженця, посвідчення про взяття на облік бездомної особи'
                       WHEN p10.p10_2 IS NOT NULL
                       THEN
                           'посвідки на постійне проживання, \ulпосвідки на тимчасове проживання\ul0, посвідчення біженця, посвідчення про взяття на облік бездомної особи'
                       WHEN p10.p10_3 IS NOT NULL
                       THEN
                           'посвідки на постійне проживання, посвідки на тимчасове проживання, \ulпосвідчення біженця\ul0, посвідчення про взяття на облік бездомної особи'
                       WHEN p10.p10_4 IS NOT NULL
                       THEN
                           'посвідки на постійне проживання, посвідки на тимчасове проживання, \ulпосвідчення біженця\ul0, \ulпосвідчення про взяття на облік бездомної особи\ul0'
                   END                                                AS p56,
                   CASE
                       WHEN p10.p10_1 IS NOT NULL
                       THEN
                              dnet$appeals_reports.get_ap_document_attr_str (
                                  p_ap_id    => a.ap_id,
                                  p_app_id   => p.app_id,
                                  p_ndt      => 8,
                                  p_nda      => 17)
                           || ' '
                           || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                           p_ap_id    => a.ap_id,
                                           p_app_id   => p.app_id,
                                           p_ndt      => 8,
                                           p_nda      => 20),
                                       'dd.mm.yyyy')
                       WHEN p10.p10_2 IS NOT NULL
                       THEN
                              dnet$appeals_reports.get_ap_document_attr_str (
                                  p_ap_id    => a.ap_id,
                                  p_app_id   => p.app_id,
                                  p_ndt      => 9,
                                  p_nda      => 23)
                           || ' '
                           || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                           p_ap_id    => a.ap_id,
                                           p_app_id   => p.app_id,
                                           p_ndt      => 9,
                                           p_nda      => 22),
                                       'dd.mm.yyyy')
                       WHEN p10.p10_3 IS NOT NULL
                       THEN
                              dnet$appeals_reports.get_ap_document_attr_str (
                                  p_ap_id    => a.ap_id,
                                  p_app_id   => p.app_id,
                                  p_ndt      => 14,
                                  p_nda      => 48)
                           || ' '
                           || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                           p_ap_id    => a.ap_id,
                                           p_app_id   => p.app_id,
                                           p_ndt      => 14,
                                           p_nda      => 47),
                                       'dd.mm.yyyy')
                       WHEN p10.p10_4 IS NOT NULL
                       THEN
                              dnet$appeals_reports.get_ap_document_attr_str (
                                  p_ap_id    => a.ap_id,
                                  p_app_id   => p.app_id,
                                  p_ndt      => 805,
                                  p_nda      => 1842)
                           || ' '
                           || TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                           p_ap_id    => a.ap_id,
                                           p_app_id   => p.app_id,
                                           p_ndt      => 805,
                                           p_nda      => 1841),
                                       'dd.mm.yyyy')
                   END                                                AS p57, --Ким та коли видана(не)
                   NVL (TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                     p_ap_id    => a.ap_id,
                                     p_app_id   => p.app_id,
                                     p_ndt      => 8,
                                     p_nda      => 19),
                                 'dd.mm.yyyy'),
                        TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                     p_ap_id    => a.ap_id,
                                     p_app_id   => p.app_id,
                                     p_ndt      => 9,
                                     p_nda      => 24),
                                 'dd.mm.yyyy'))                       AS p58, --Дата закінчення (продовження) строку дії посвідки
                   p.app_inn                                          AS p59, --РНОКПП - учасника звернення
                   dnet$appeals_reports.get_pers_fact_address (
                       p_ap_id    => a.ap_id,
                       p_app_id   => p.app_id)                        AS p60, --Зареєстроване місце проживання
                   DECODE (dnet$appeals_reports.get_ap_document_attr_str (
                               p_ap_id    => a.ap_id,
                               p_app_id   => p.app_id,
                               p_ndt      => 836,
                               p_nda      => 3471),
                           'T', v_check_mark)                         AS p61,
                   CASE
                       WHEN dnet$appeals_reports.get_ap_document_attr_str (
                                p_ap_id    => a.ap_id,
                                p_app_id   => p.app_id,
                                p_ndt      => 836,
                                p_nda      => 3472) = 'ON'
                       THEN
                           '\ulонлайн\ul0 / офлайн'
                       WHEN dnet$appeals_reports.get_ap_document_attr_str (
                                p_ap_id    => a.ap_id,
                                p_app_id   => p.app_id,
                                p_ndt      => 836,
                                p_nda      => 3472) = 'OF'
                       THEN
                           'онлайн / \ulофлайн\ul0'
                       ELSE
                           'онлайн / офлайн'
                   END                                                AS p62,
                   CASE dnet$appeals_reports.get_ap_document_attr_str (
                            p_ap_id    => a.ap_id,
                            p_app_id   => p.app_id,
                            p_ndt      => 836,
                            p_nda      => 3473)
                       WHEN 'PR'
                       THEN
                           '\ulмоїй присутності\ul0 / за моєї відсутності'
                       WHEN 'AB'
                       THEN
                           'моїй присутності / \ulза моєї відсутності\ul0'
                   END                                                AS p63,
                   DECODE (dnet$appeals_reports.get_ap_document_attr_str (
                               p_ap_id    => a.ap_id,
                               p_app_id   => p.app_id,
                               p_ndt      => 836,
                               p_nda      => 3474),
                           'T', v_check_mark)                         AS p64,
                   DECODE (dnet$appeals_reports.get_ap_document_attr_str (
                               p_ap_id    => a.ap_id,
                               p_app_id   => p.app_id,
                               p_ndt      => 836,
                               p_nda      => 3475),
                           'T', v_check_mark)                         AS p65,
                   NVL2 (p.app_ln,
                         TO_CHAR (dnet$appeals_reports.get_ap_document_attr_dt (
                                      p_ap_id    => a.ap_id,
                                      p_app_id   => p.app_id,
                                      p_ndt      => 836,
                                      p_nda      => 3476),
                                  'dd.mm.yyyy'),
                         '________')                                  AS p66,
                   NVL2 (
                       p.app_ln,
                          tools.init_cap (p.app_ln)
                       || ' '
                       || SUBSTR (p.app_fn, 1, 1)
                       || '.'
                       || SUBSTR (p.app_mn, 1, 1)
                       || '.',
                       '____________')                                AS p67, --прізвище та ініціали законного представника
                   TO_CHAR (a.ap_reg_dt + 30, 'dd.mm.yyyy')           AS p68,
                   uss_visit.TOOLS.GetUserPib (P_WU_ID => a.com_wu)   AS p70 -- ПІБ поточного користувача, який зареєстрував звернення
              FROM v_appeal  a
                   LEFT JOIN v_ap_person p
                       ON     p.app_ap = a.ap_id
                          AND p.history_status = 'A'
                          AND p.app_tp = 'OR'
                   LEFT JOIN
                   (SELECT dnet$appeals_reports.get_ap_document_attr_str (
                               p_ap_id    => p_ap_id,
                               p_app_id   => p.app_id,
                               p_ndt      => 8,
                               p_nda      => 15)     p10_1,
                           dnet$appeals_reports.get_ap_document_attr_str (
                               p_ap_id    => p_ap_id,
                               p_app_id   => p.app_id,
                               p_ndt      => 9,
                               p_nda      => 21)     p10_2,
                           dnet$appeals_reports.get_ap_document_attr_str (
                               p_ap_id    => p_ap_id,
                               p_app_id   => p.app_id,
                               p_ndt      => 14,
                               p_nda      => 46)     p10_3,
                           dnet$appeals_reports.get_ap_document_attr_str (
                               p_ap_id    => p_ap_id,
                               p_app_id   => p.app_id,
                               p_ndt      => 805,
                               p_nda      => 1840)   p10_4
                      FROM v_ap_person p
                     WHERE     p.app_ap = p_ap_id
                           AND p.history_status = 'A'
                           AND p.app_tp = 'OR') p10
                       ON 1 = 1
             WHERE a.ap_id = p_ap_id;

        r3                 cur3%ROWTYPE;
        l_flag             NUMBER;
        l_sql              VARCHAR2 (32000);
    BEGIN
        --зараз відсутні поля:
        --0 - номер
        --40 – кількість поданих у зверненні документів ??
        --69 - список не поданих документів
        --(зараз не робочий код)для p69 див. FUNCTION ss_prov_appl_r1(p35) рядок 3172 SELECT listagg(ndt_name_short, ', ') within GROUP(ORDER BY ndt_order, ndt_name)

        OPEN cur1;

        FETCH cur1 INTO r1;

        CLOSE cur1;

        OPEN cur2;

        FETCH cur2 INTO r2;

        CLOSE cur2;

        OPEN cur3;

        FETCH cur3 INTO r3;

        CLOSE cur3;

        SELECT COUNT (*)
          INTO l_flag
          FROM ap_document t
         WHERE     t.apd_ap = p_ap_id
               AND t.apd_ndt = 836
               AND t.history_status = 'A';

        -- #93242: який жах
        IF (l_flag = 0)
        THEN
            raise_application_error (
                -20000,
                'Обраний для друку документ відсутній у зверненні.');
        END IF;

        l_sql :=
               q'[
    select
          p37,
          case
            when p1 is not null then 'паспорт'
            when p2 is not null then 'ID-картка'

            when p3 is not null then 'посвідка на постійне проживання'
            when p4 is not null then 'посвідки на тимчасове проживання'
            when p5 is not null then 'посвідчення біженця'
            when p6 is not null then 'посвідчення про взяття на облік бездомної особи'
          end ||' № '||coalesce(p1, p2, p3, p4, p5, p6) as p38,
          coalesce(p.app_inn, p1, p2) as p39
     from
      (select
              app_tp, p.app_inn,
              p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn p37,
              max(decode(da.apda_nda,    3, da.apda_val_string)) p1,
              max(decode(da.apda_nda,    9, da.apda_val_string)) p2,
              max(decode(da.apda_nda,   15, da.apda_val_string)) p3,
              max(decode(da.apda_nda,   21, da.apda_val_string)) p4,
              max(decode(da.apda_nda,   46, da.apda_val_string)) p5,
              max(decode(da.apda_nda, 1840, da.apda_val_string)) p6
        from uss_visit.v_ap_person p, uss_visit.v_ap_document d, uss_visit.v_ap_document_attr da

       where p.app_ap = ]'
            || TO_CHAR (p_ap_id)
            || q'[and 'T'=']'
            || COALESCE (r1.nda1871, 'F')
            ||     --таблиця заповнюється тільки у разі присутності декларації
               q'[' and p.history_status = 'A' and p.app_tp in ('OS', 'Z', 'FM')
         and d.apd_ap = p.app_ap and d.apd_ndt in (6, 7, 8, 9, 14, 805) and d.history_status = 'A' and d.apd_app = p.app_id
         and d.apd_id = da.apda_apd and da.history_status = 'A' and da.apda_nda in (3, 9, 15, 21, 46, 1840)
      group by app_tp, p.app_inn, p.app_ln || ' ' || p.app_fn || ' ' || p.app_mn
      ) p
    order by p.app_tp
    ]';


        l_jbr_id := rdm$rtfl.initreport (p_rt_id);
        rdm$rtfl.addparam (l_jbr_id, 'p0', NULL);
        rdm$rtfl.addparam (l_jbr_id, 'p1', r1.p1);
        rdm$rtfl.addparam (l_jbr_id, 'p2', r1.p2);
        rdm$rtfl.addparam (l_jbr_id, 'p3', r1.p3);
        rdm$rtfl.addparam (l_jbr_id, 'p4', r1.p4);
        rdm$rtfl.addparam (l_jbr_id, 'p5', r1.p5);
        rdm$rtfl.addparam (l_jbr_id, 'p6', r1.p6);
        rdm$rtfl.addparam (l_jbr_id, 'p7', r1.p7);
        rdm$rtfl.addparam (l_jbr_id, 'p8', r1.p8);
        rdm$rtfl.addparam (l_jbr_id, 'p9', r1.p9);

        rdm$rtfl.addparam (l_jbr_id, 'p10', r1.p10);
        rdm$rtfl.addparam (l_jbr_id, 'p11', r1.p11);
        rdm$rtfl.addparam (l_jbr_id, 'p12', r1.p12);
        rdm$rtfl.addparam (l_jbr_id, 'p13', r1.p13);
        rdm$rtfl.addparam (l_jbr_id, 'p14', r1.p14);
        rdm$rtfl.addparam (l_jbr_id, 'p15', r1.p15);

        rdm$rtfl.addparam (l_jbr_id, 'p16', r2.p16);
        rdm$rtfl.addparam (l_jbr_id, 'p17', r2.p17);
        rdm$rtfl.addparam (l_jbr_id, 'p18', r1.p18);
        rdm$rtfl.addparam (l_jbr_id, 'p19', r2.p19);

        rdm$rtfl.addparam (l_jbr_id, 'p20', r2.p20);
        rdm$rtfl.addparam (l_jbr_id, 'p21', r2.p21);
        rdm$rtfl.addparam (l_jbr_id, 'p21_1', r2.p21_1);
        rdm$rtfl.addparam (l_jbr_id, 'p22', r2.p22);
        rdm$rtfl.addparam (l_jbr_id, 'p23', r2.p23);
        rdm$rtfl.addparam (l_jbr_id, 'p24', r1.p24);
        rdm$rtfl.addparam (l_jbr_id, 'p25', r1.p25);
        rdm$rtfl.addparam (l_jbr_id, 'p26', r1.p26);
        rdm$rtfl.addparam (l_jbr_id, 'p27', r1.p27);
        rdm$rtfl.addparam (l_jbr_id, 'p28', r1.p28);
        rdm$rtfl.addparam (l_jbr_id, 'p29', r1.p29);

        rdm$rtfl.addparam (l_jbr_id, 'p30', r1.p30);
        rdm$rtfl.addparam (l_jbr_id, 'p31', r1.p31);
        rdm$rtfl.addparam (l_jbr_id, 'p32', r1.p32);
        rdm$rtfl.addparam (l_jbr_id, 'p33', r1.p33);
        rdm$rtfl.addparam (l_jbr_id, 'p34', r1.p34);
        rdm$rtfl.addparam (l_jbr_id, 'p35', r1.p35);
        rdm$rtfl.addparam (l_jbr_id, 'p36', r1.p36);

        rdm$rtfl.adddataset (l_jbr_id, 'ds', l_sql);

        rdm$rtfl.addparam (l_jbr_id, 'p40', r1.p40);
        rdm$rtfl.addparam (l_jbr_id, 'p41', r1.p41);
        rdm$rtfl.addparam (l_jbr_id, 'p42', r1.p42);
        rdm$rtfl.addparam (l_jbr_id, 'p43', r1.p43);
        rdm$rtfl.addparam (l_jbr_id, 'p44', r1.p44);
        rdm$rtfl.addparam (l_jbr_id, 'p45', r1.p45);

        rdm$rtfl.addparam (l_jbr_id, 'p46', r3.p46);
        rdm$rtfl.addparam (l_jbr_id, 'p47', r3.p47);
        rdm$rtfl.addparam (l_jbr_id, 'p48', r3.p48);
        rdm$rtfl.addparam (l_jbr_id, 'p49', r3.p49);

        rdm$rtfl.addparam (l_jbr_id, 'p50', r3.p50);
        rdm$rtfl.addparam (l_jbr_id, 'p51', r3.p51);
        rdm$rtfl.addparam (l_jbr_id, 'p52', r3.p52);
        rdm$rtfl.addparam (l_jbr_id, 'p53', r3.p53);
        rdm$rtfl.addparam (l_jbr_id, 'p54', r3.p54);
        rdm$rtfl.addparam (l_jbr_id, 'p55', r3.p55);
        rdm$rtfl.addparam (l_jbr_id, 'p56', r3.p56);
        rdm$rtfl.addparam (l_jbr_id, 'p57', r3.p57);
        rdm$rtfl.addparam (l_jbr_id, 'p58', r3.p58);
        rdm$rtfl.addparam (l_jbr_id, 'p59', r3.p59);

        rdm$rtfl.addparam (l_jbr_id, 'p60', r3.p60);
        rdm$rtfl.addparam (l_jbr_id, 'p61', r3.p61);
        rdm$rtfl.addparam (l_jbr_id, 'p62', r3.p62);
        rdm$rtfl.addparam (l_jbr_id, 'p63', r3.p63);
        rdm$rtfl.addparam (l_jbr_id, 'p64', r3.p64);
        rdm$rtfl.addparam (l_jbr_id, 'p65', r3.p65);
        rdm$rtfl.addparam (l_jbr_id, 'p66', r3.p66);
        rdm$rtfl.addparam (l_jbr_id, 'p67', r3.p67);
        rdm$rtfl.addparam (l_jbr_id, 'p68', r3.p68);
        rdm$rtfl.addparam (l_jbr_id, 'p69', NULL); --для p69 див. FUNCTION ss_prov_appl_r1(p35) рядок 3172 SELECT listagg(ndt_name_short, ', ') within GROUP(ORDER BY ndt_order, ndt_name)

        rdm$rtfl.addparam (l_jbr_id, 'p70', r3.p70);
        rdm$rtfl.addparam (l_jbr_id, 'p71', COALESCE (r1.p2, r3.p46)); --71 – ПІБ учасника звернення з типом «Заявник» ‘Z’ або ‘OR’

        rdm$rtfl.putreporttoworkingqueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    -- info:   формування друкованих форм документів для надавачів соціальних послуг
    -- params: p_rt_id - ідентифікатор звіту
    --         p_ap_id - ідентифікатор звернення
    -- note:
    PROCEDURE reg_nsp_doc_get (p_rt_id    IN     rpt_templates.rt_id%TYPE,
                               p_ap_id    IN     appeal.ap_id%TYPE,
                               p_jbr_id      OUT DECIMAL)
    IS
    BEGIN
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.REG_NSP_DOC_GET',
            action_name   =>
                   'p_rt_id='
                || TO_CHAR (p_rt_id)
                || ';'
                || 'p_ap_id='
                || TO_CHAR (p_ap_id));

        CASE get_rt_code (p_rt_id)
            WHEN 'ANNEX_2_R1'
            THEN
                p_jbr_id := annex_2_r1 (p_rt_id, p_ap_id);
            WHEN 'ANNEX_3_R1'
            THEN
                p_jbr_id := annex_3_r1 (p_rt_id, p_ap_id);
            WHEN 'ANNEX_4_R1'
            THEN
                p_jbr_id := annex_4_r1 (p_rt_id, p_ap_id);
            WHEN 'RECEIPT_INFO_GET_R1'
            THEN
                reg_receip_info_get (p_ap_id, p_jbr_id);
            WHEN 'SS_PROV_APPL_R1'
            THEN
                p_jbr_id := ss_prov_appl_r1 (p_rt_id, p_ap_id);
            WHEN 'SJO_INFO_R1'
            THEN
                p_jbr_id := sjo_info_r1 (p_rt_id, p_ap_id);
            WHEN 'APPEAL_ROS_APPL'
            THEN
                p_jbr_id := get_appeal_ros_app_v2 (p_rt_id, p_ap_id);
            WHEN 'APPEAL_GS_R1'
            THEN
                p_jbr_id := get_appeal_gs_r1 (p_rt_id, p_ap_id);
            WHEN 'APPEAL_SMD_R1'
            THEN
                p_jbr_id := get_appeal_smd_r1 (p_rt_id, p_ap_id);
            ELSE
                NULL;
        END CASE;
    END;

    -- info:   Стандартизація відображення інформації для шаблону "Довідка щодо наявної інформації про осіб з інвалідністю І та ІІ груп ..."
    -- params: p_ap_id - строка
    -- note:   #76148
    FUNCTION proc_info_str (p_str IN VARCHAR2, p_rt_code IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN (CASE p_rt_code
                    WHEN 'REFERENCE_DISABILITY_R1'
                    THEN
                        '\ul ' || COALESCE (p_str, 'Інформація відсутня')
                    ELSE
                        p_str
                END);
    END;

    -- info:   Отримання друкованої форми "Довідка щодо наявної інформації про осіб з інвалідністю І та ІІ груп ..."
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #76148, в разі успішного підготовки файл необхідно зберегти/оновити документ звернення
    PROCEDURE get_reference_disability_doc (
        p_ap_id     IN     appeal.ap_id%TYPE,
        p_res_doc      OUT SYS_REFCURSOR)
    IS
        v_clob   CLOB;
        v_msg    VARCHAR2 (250);
    BEGIN
        FOR data_cur
            IN (SELECT a.ap_num,
                       a.ap_reg_dt,
                       a.ap_tp,
                       st.nst_id,
                       st.nst_name,
                       prs.app_id,
                       prs.app_sc,
                       prs.pib,
                       prs.doc_num,
                       (CASE
                            WHEN COALESCE (
                                     TO_CHAR (dsb.scy_group),
                                     uss_doc.api$documents.get_attr_val_str (
                                         p_nda_id   => 1104,
                                         p_dh_id    =>
                                             prs.dh_id_dpndnt),
                                     uss_doc.api$documents.get_attr_val_str (
                                         p_nda_id   => 349,
                                         p_dh_id    => prs.dh_id_msec),
                                     uss_doc.api$documents.get_attr_val_str (
                                         p_nda_id   => 1125,
                                         p_dh_id    => prs.dh_id_ppp),
                                     uss_doc.api$documents.get_attr_val_str (
                                         p_nda_id   => 1128,
                                         p_dh_id    => prs.dh_id_epp))
                                     IS NOT NULL
                            THEN
                                0
                            ELSE
                                1
                        END)
                           AS dsblty_grp_restr,
                       uss_doc.api$documents.get_attr_val_str (
                           p_nda_id   => 1099,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS kod_raj,
                       uss_doc.api$documents.get_attr_val_str (
                           p_nda_id   => 1100,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS eoc,
                       (SELECT npt_name
                          FROM uss_ndi.v_ndi_payment_type
                         WHERE npt_code =
                               uss_doc.api$documents.get_attr_val_str (
                                   p_nda_id   => 1101,
                                   p_dh_id    => prs.dh_id_dpndnt))
                           AS vid_vypl,
                       uss_doc.api$documents.get_attr_val_dt (
                           p_nda_id   => 1102,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS start_date_v,
                       uss_doc.api$documents.get_attr_val_dt (
                           p_nda_id   => 1103,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS stop_date_v,
                       (SELECT dic_sname
                          FROM uss_ndi.v_ddn_asopd_scy_group
                         WHERE dic_code =
                               uss_doc.api$documents.get_attr_val_str (
                                   p_nda_id   => 1104,
                                   p_dh_id    => prs.dh_id_dpndnt))
                           AS msp_group,
                       (SELECT dic_sname
                          FROM uss_ndi.v_ddn_asopd_scy_reason
                         WHERE dic_code =
                               uss_doc.api$documents.get_attr_val_str (
                                   p_nda_id   => 2193,
                                   p_dh_id    => prs.dh_id_dpndnt))
                           AS msp_reason,
                       uss_doc.api$documents.get_attr_val_dt (
                           p_nda_id   => 1105,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS msp_start_date,
                       uss_doc.api$documents.get_attr_val_dt (
                           p_nda_id   => 1106,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS msp_stop_date,
                       uss_doc.api$documents.get_attr_val_str (
                           p_nda_id   => 1107,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS passport_otr,
                       uss_doc.api$documents.get_attr_val_str (
                           p_nda_id   => 2263,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS numident_otr,
                       uss_doc.api$documents.get_attr_val_str (
                           p_nda_id   => 1108,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS last_name_otr,
                       uss_doc.api$documents.get_attr_val_str (
                           p_nda_id   => 1109,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS first_name_otr,
                       uss_doc.api$documents.get_attr_val_str (
                           p_nda_id   => 1110,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS sec_name_otr,
                       uss_doc.api$documents.get_attr_val_dt (
                           p_nda_id   => 1111,
                           p_dh_id    => prs.dh_id_dpndnt)
                           AS birthday_otr,
                       uss_doc.api$documents.get_attr_val_str (
                           p_nda_id   => 346,
                           p_dh_id    => prs.dh_id_msec)
                           AS msek_num,
                       (SELECT dic_sname
                          FROM uss_ndi.v_ddn_scy_group g
                         WHERE g.dic_code =
                               uss_doc.api$documents.get_attr_val_str (
                                   p_nda_id   => 349,
                                   p_dh_id    => prs.dh_id_msec))
                           AS cb_group,
                       (SELECT dic_sname
                          FROM uss_ndi.v_ddn_scy_sgroup
                         WHERE dic_code =
                               uss_doc.api$documents.get_attr_val_str (
                                   p_nda_id   => 791,
                                   p_dh_id    => prs.dh_id_msec))
                           AS cb_sgroup,
                       (SELECT dic_sname
                          FROM uss_ndi.v_ddn_inv_reason
                         WHERE dic_code =
                               uss_doc.api$documents.get_attr_val_str (
                                   p_nda_id   => 353,
                                   p_dh_id    => prs.dh_id_msec))
                           AS cb_reason,
                       uss_doc.api$documents.get_attr_val_dt (
                           p_nda_id   => 352,
                           p_dh_id    => prs.dh_id_msec)
                           AS cb_start_date,
                       uss_doc.api$documents.get_attr_val_dt (
                           p_nda_id   => 347,
                           p_dh_id    => prs.dh_id_msec)
                           AS cb_stop_date,
                       COALESCE (
                           uss_doc.api$documents.get_attr_val_str (
                               p_nda_id   => 608,
                               p_dh_id    => prs.dh_id_ppp),
                           uss_doc.api$documents.get_attr_val_str (
                               p_nda_id   => 620,
                               p_dh_id    => prs.dh_id_epp))
                           AS pp_num,
                       COALESCE (
                           uss_doc.api$documents.get_attr_val_str (
                               p_nda_id   => 613,
                               p_dh_id    => prs.dh_id_ppp),
                           uss_doc.api$documents.get_attr_val_str (
                               p_nda_id   => 625,
                               p_dh_id    => prs.dh_id_epp))
                           AS pp_oc,
                       COALESCE (
                           uss_doc.api$documents.get_attr_val_str (
                               p_nda_id   => 614,
                               p_dh_id    => prs.dh_id_ppp),
                           uss_doc.api$documents.get_attr_val_str (
                               p_nda_id   => 626,
                               p_dh_id    => prs.dh_id_epp))
                           AS pp_vyd_pensii,
                       COALESCE (
                           uss_doc.api$documents.get_attr_val_dt (
                               p_nda_id   => 615,
                               p_dh_id    => prs.dh_id_ppp),
                           uss_doc.api$documents.get_attr_val_dt (
                               p_nda_id   => 627,
                               p_dh_id    => prs.dh_id_epp))
                           AS pp_termin,
                       uss_doc.api$documents.get_attr_val_dt (
                           p_nda_id   => 616,
                           p_dh_id    => prs.dh_id_ppp)
                           AS pp_date_in,
                       uss_doc.api$documents.get_attr_val_str (
                           p_nda_id   => 619,
                           p_dh_id    => prs.dh_id_ppp)
                           AS pp_seriya
                  FROM v_appeal  a
                       JOIN uss_ndi.v_ndi_service_type st
                       LEFT JOIN v_ap_service s
                           ON     s.aps_nst = st.nst_id
                              AND s.aps_ap = p_ap_id
                              AND s.history_status = 'A'
                           ON st.nst_code = '134'
                       LEFT JOIN
                       (SELECT tt.app_id,
                               tt.app_sc,
                               tt.pib,
                               tt.doc_num,
                               (SELECT MAX (d.scd_dh)
                                  FROM uss_person.v_sc_document d
                                 WHERE     d.scd_sc = tt.app_sc
                                       AND d.scd_ndt = 201
                                       AND d.scd_st = '1')    AS dh_id_msec,
                               (SELECT MAX (d.scd_dh)
                                  FROM uss_person.v_sc_document d
                                 WHERE     d.scd_sc = tt.app_sc
                                       AND d.scd_ndt = 601
                                       AND d.scd_st = '1')    AS dh_id_ppp,
                               (SELECT MAX (d.scd_dh)
                                  FROM uss_person.v_sc_document d
                                 WHERE     d.scd_sc = tt.app_sc
                                       AND d.scd_ndt = 602
                                       AND d.scd_st = '1')    AS dh_id_epp,
                               (SELECT MAX (d.scd_dh)
                                  FROM uss_person.v_sc_document d
                                 WHERE     d.scd_sc = tt.app_sc
                                       AND d.scd_ndt = 10041
                                       AND d.scd_st = '1')    AS dh_id_dpndnt
                          FROM (SELECT p.app_id,
                                       tools.init_cap (
                                              p.app_ln
                                           || ' '
                                           || p.app_fn
                                           || ' '
                                           || p.app_mn)
                                           AS pib,
                                       COALESCE (p.app_inn, p.app_doc_num)
                                           AS doc_num,
                                       p.app_sc,
                                       FIRST_VALUE (p.app_id)
                                           OVER (
                                               ORDER BY
                                                   (CASE
                                                        WHEN p.app_sc
                                                                 IS NOT NULL
                                                        THEN
                                                            0
                                                        ELSE
                                                            1
                                                    END),
                                                   p.app_id)
                                           AS frst_app
                                  FROM v_ap_person p
                                 WHERE     p.app_ap = p_ap_id
                                       AND p.app_tp = 'Z'
                                       AND p.history_status = 'A') tt
                         WHERE tt.app_id = tt.frst_app) prs
                           ON 1 = 1
                       LEFT JOIN uss_person.v_sc_disability dsb
                           ON     dsb.scy_sc = prs.app_sc
                              AND dsb.history_status = 'A'
                 WHERE a.ap_id = p_ap_id AND ROWNUM < 2)
        LOOP
            --отримати друковану форму можливо тільки для типу звернення "Довідка"
            IF data_cur.ap_tp != 'D'
            THEN
                raise_application_error (
                    -20000,
                    'Сформувати документ можливо тільки для типу звернення "Довідка"!');
            ELSIF data_cur.nst_id IS NULL --отримати друковану форму можливо тільки в разі наявності послуги "Довідка щодо наявної інформації про осіб з інвалідністю І та ІІ груп"
            THEN
                raise_application_error (
                    -20000,
                       'Сформувати документ можливо тільки для послуги "'
                    || data_cur.nst_name
                    || '"!');
            ELSIF data_cur.app_sc IS NULL --#76459 заборонено формувати довідку якщо при натисканні кнопки «Лупа» в ЄСР не знайдено жодної СРК, в тому числі і тимчасової для учасника «Заявник»
            THEN
                raise_application_error (
                    -20000,
                    'Відомості про особу з інвалідністю відсутні в Єдиному соціальному реєстрі. Перевірте правильність внесеної інформації в блоці учасника звернення "Заявник"!');
            ELSIF data_cur.dsblty_grp_restr = 1 --#78869 якщо хоч в одному із трьох джерел наявна інформація щодо групи інвалідності у особи (будь-якої), то Довідка повинна формуватися
            THEN
                raise_application_error (
                    -20000,
                    'Для типу учасник звернення «Заявник» в Єдиному соціальному реєстрі відсутні відомості щодо інвалідності І, ІІ та ІІІ групи. Нажаль Довідку не можливо сформувати!');
            END IF;

            --#76459 якщо в даних АСОПД знайшли  справу в якій наявна інформація щодо особи з інвалідністю «Заявник», але ПІБ + ІНН, за відсутності ІНН ПІБ + Серія та номер документу, іншого учасника цієї справи відрізняються від даних внесених для «Представника заявника»
            FOR cntrl_cur
                IN (SELECT 1
                      FROM v_ap_person pp
                     WHERE     pp.app_ap = p_ap_id
                           AND pp.app_tp = 'P'
                           AND pp.history_status = 'A'
                           AND COALESCE (
                                   UPPER (
                                          TRIM (pp.app_ln)
                                       || TRIM (pp.app_fn)
                                       || TRIM (pp.app_mn)),
                                   'NULL') !=
                               COALESCE (
                                   UPPER (
                                          TRIM (data_cur.last_name_otr)
                                       || TRIM (data_cur.first_name_otr)
                                       || TRIM (data_cur.sec_name_otr)),
                                   'NULL')
                           AND (   (    data_cur.numident_otr IS NOT NULL
                                    AND COALESCE (pp.app_inn, 'NULL') !=
                                        data_cur.numident_otr)
                                OR (    data_cur.numident_otr IS NULL
                                    AND COALESCE (pp.app_doc_num, 'NULL') !=
                                        COALESCE (data_cur.passport_otr,
                                                  'NULL')))
                     FETCH FIRST 1 ROW ONLY)
            LOOP
                raise_application_error (
                    -20000,
                    'За даними Центрального сховища Мінсоцполітики в особовій справі відомості щодо представника заявника відрізняються від даних внесених в блоці учасника звернення «Представник заявника». Перевірте правильність внесеної інформації в блоці учасника звернення «Представник заявника»!');
            END LOOP;

            --#77216 контроль терміну документу про інвалідность
            IF TRUNC (
                   GREATEST (
                       COALESCE (data_cur.msp_stop_date,
                                 data_cur.cb_stop_date,
                                 data_cur.pp_termin,
                                 TO_DATE ('23.02.2022', 'DD.MM.YYYY')),
                       COALESCE (data_cur.cb_stop_date,
                                 data_cur.pp_termin,
                                 TO_DATE ('23.02.2022', 'DD.MM.YYYY')),
                       COALESCE (data_cur.pp_termin,
                                 TO_DATE ('23.02.2022', 'DD.MM.YYYY')))) <
               TO_DATE ('24.02.2022', 'DD.MM.YYYY')
            THEN
                raise_application_error (
                    -20000,
                    'В інформаційних системах соціальної сфери відсутня інформація щодо діючих документів про інвалідність заявника!');
            END IF;

            --#77216 попередження по терміну документу про інвалідность
            IF TRUNC (
                   GREATEST (
                       COALESCE (data_cur.msp_stop_date,
                                 data_cur.cb_stop_date,
                                 data_cur.pp_termin),
                       COALESCE (data_cur.cb_stop_date,
                                 data_cur.pp_termin,
                                 data_cur.msp_stop_date),
                       COALESCE (data_cur.pp_termin,
                                 data_cur.msp_stop_date,
                                 data_cur.cb_stop_date))) <
               TRUNC (SYSDATE)
            THEN
                v_msg :=
                    '*Зверніть увагу на відсутність діючих документів в інформаційних системах соціальної сфери';
            END IF;

            v_clob :=
                REPLACE (
                    tools.convertb2c (
                        get_template_by_code ('REFERENCE_DISABILITY_R1')),
                    '#ap_num#',
                    data_cur.ap_num);
            v_clob :=
                REPLACE (v_clob,
                         '#ap_reg_dt#',
                         TO_CHAR (data_cur.ap_reg_dt, 'DD.MM.YYYY'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pib#',
                    proc_info_str (data_cur.pib, 'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#ipn#',
                    proc_info_str (data_cur.doc_num,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#kod_raj#',
                    proc_info_str (data_cur.kod_raj,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#eoc#',
                    proc_info_str (data_cur.eoc, 'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#vid_vypl#',
                    proc_info_str (data_cur.vid_vypl,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#start_date_v#',
                    proc_info_str (
                        TO_CHAR (data_cur.start_date_v, 'DD.MM.YYYY'),
                        'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#stop_date_v#',
                    proc_info_str (
                        TO_CHAR (data_cur.stop_date_v, 'DD.MM.YYYY'),
                        'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#msp_det_info#',
                       proc_info_str (data_cur.msp_group,
                                      'REFERENCE_DISABILITY_R1')
                    || ', Інформація відсутня, '
                    || proc_info_str (data_cur.msp_reason,
                                      'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#msp_start_date#',
                    proc_info_str (
                        TO_CHAR (data_cur.msp_start_date, 'DD.MM.YYYY'),
                        'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#msp_stop_date#',
                    proc_info_str (
                        TO_CHAR (data_cur.msp_stop_date, 'DD.MM.YYYY'),
                        'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#passport_otr#',
                    proc_info_str (data_cur.passport_otr,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#last_name_otr#',
                    proc_info_str (data_cur.last_name_otr,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#first_name_otr#',
                    proc_info_str (data_cur.first_name_otr,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#sec_name_otr#',
                    proc_info_str (data_cur.sec_name_otr,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#birthday_otr#',
                    proc_info_str (
                        TO_CHAR (data_cur.birthday_otr, 'DD.MM.YYYY'),
                        'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#msek_num#',
                    proc_info_str (data_cur.msek_num,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#cb_det_info#',
                       proc_info_str (data_cur.cb_group,
                                      'REFERENCE_DISABILITY_R1')
                    || ', '
                    || proc_info_str (data_cur.cb_sgroup,
                                      'REFERENCE_DISABILITY_R1')
                    || ', '
                    || proc_info_str (data_cur.cb_reason,
                                      'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#cb_start_date#',
                    proc_info_str (
                        TO_CHAR (data_cur.cb_start_date, 'DD.MM.YYYY'),
                        'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#cb_stop_date#',
                    proc_info_str (
                        TO_CHAR (data_cur.cb_stop_date, 'DD.MM.YYYY'),
                        'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pp_num#',
                    proc_info_str (data_cur.pp_num,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pp_oc#',
                    proc_info_str (data_cur.pp_oc, 'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pp_vyd_pensii#',
                    proc_info_str (data_cur.pp_vyd_pensii,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pp_termin#',
                    proc_info_str (
                        TO_CHAR (data_cur.pp_termin, 'DD.MM.YYYY'),
                        'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pp_date_in#',
                    proc_info_str (
                        TO_CHAR (data_cur.pp_date_in, 'DD.MM.YYYY'),
                        'REFERENCE_DISABILITY_R1'));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pp_seriya#',
                    proc_info_str (data_cur.pp_seriya,
                                   'REFERENCE_DISABILITY_R1'));
            v_clob := REPLACE (v_clob, '#msg#', '\par\b\i' || v_msg);

            --інформація для збереження/оновлення документа в зверненні
            OPEN p_res_doc FOR
                SELECT t.rt_name || '.pdf'                       AS file_name,
                       'application/pdf'                         AS file_mime_type,
                       tools.convertc2b (v_clob)                 AS file_blob,
                       d.apd_id,
                       COALESCE (d.apd_ndt, 10048)               AS apd_ndt,
                       tp.ndt_name                               AS apd_ndt_name,
                       d.apd_doc,
                       COALESCE (d.apd_app, data_cur.app_id)     AS apd_app,
                       d.apd_dh,
                       COALESCE (d.apd_aps, data_cur.nst_id)     AS apd_aps,
                       LTRIM (v_msg, '*')                        AS warning
                  FROM v_rpt_templates  t
                       LEFT JOIN v_ap_document d
                           ON     d.apd_ap = p_ap_id
                              AND d.apd_app = data_cur.app_id
                              AND d.apd_ndt = 10048
                              AND d.history_status = 'A'
                       LEFT JOIN uss_ndi.v_ndi_document_type tp
                           ON (tp.ndt_id = COALESCE (d.apd_ndt, 10048))
                 WHERE t.rt_code = 'REFERENCE_DISABILITY_R1';
        END LOOP;
    END;

    PROCEDURE get_piljg_dovidka_doc (p_ap_id     IN     appeal.ap_id%TYPE,
                                     p_res_doc      OUT SYS_REFCURSOR)
    IS
        l_sc         NUMBER;
        l_app        NUMBER;
        l_ap_num     VARCHAR2 (100);
        l_blob       BLOB;
        l_org_name   VARCHAR2 (500);
        l_num        VARCHAR2 (200);
    BEGIN
        SELECT MAX (t.app_sc),
               MAX (t.app_id),
               MAX (ap_num),
               MAX (o.org_code || ' ' || o.org_name),
               MAX (sc.sc_unique || TO_CHAR (SYSDATE, 'DDMMYYYY'))
          INTO l_sc,
               l_app,
               l_ap_num,
               l_org_name,
               l_num
          FROM ap_person  t
               JOIN uss_person.v_socialcard sc ON (sc.sc_id = t.app_sc)
               JOIN v_opfu o ON (o.org_id = tools.getcurrorg)
               JOIN appeal p ON (ap_id = t.app_ap)
         WHERE t.app_ap = p_ap_id AND t.app_tp = 'Z';

        IF (l_sc IS NULL)
        THEN
            raise_application_error (-20000,
                                     'Не знайдено соц. картку заявника!');
        END IF;

        reportfl_engine.InitReport ('USS_VISIT', 'BENEFIT_DOVIDKA_R1');

        reportfl_engine.AddParam ('gen_dt', TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
        reportfl_engine.AddParam ('org_name', l_org_name);
        reportfl_engine.AddParam ('num', l_num);

        reportfl_engine.AddDataSet (
            'ds',
               'SELECT t.pib,
             t.nbc_name as cat_name,
             to_char(t.start_dt, ''DD.MM.YYYY'') AS start_dt,
             to_char(t.stop_dt, ''DD.MM.YYYY'') AS stop_dt
        FROM (SELECT t.scp3_sc,
                     c.nbc_name,
                     uss_person.api$sc_tools.GET_PIB(t.scp3_sc) AS pib,
                     SUM(nvl(t.scp3_sum_m1, 0) + nvl(t.scp3_sum_m2, 0) + nvl(t.scp3_sum_m3, 0) + nvl(t.scp3_sum_m4, 0) + nvl(t.scp3_sum_m5, 0) + nvl(t.scp3_sum_m6, 0) + nvl(t.scp3_sum_m7, 0) + nvl(t.scp3_sum_m8, 0) + nvl(t.scp3_sum_m9, 0) + nvl(t.scp3_sum_m10, 0) + nvl(t.scp3_sum_m11, 0) + nvl(t.scp3_sum_m12, 0)) AS has_sum,
                     ps.scpp_pfu_pd_start_dt AS start_dt,
                     ps.scpp_pfu_pd_stop_dt AS stop_dt
                from uss_person.v_sc_pfu_pay_period t
                JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
                join uss_ndi.v_ndi_benefit_category c on (c.nbc_id = t.scp3_nbc)
               WHERE t.scp3_sc = '
            || l_sc
            || '
                 AND t.scp3_nbc IN (2,20,22,23,26,30,99,40,64,69,15,41,42,43,124,125,48,35,54,55,56,19,17)
               group by scp3_sc, nbc_name, scpp_pfu_pd_start_dt , scpp_pfu_pd_stop_dt
            ) t
          WHERE has_sum IS NOT null AND has_sum != 0
       UNION
       --#111819
      SELECT Uss_Person.Api$sc_Tools.Get_Pib(Bc.Scbc_Sc) AS Pib,
             c.Nbc_Name AS Cat_Name,
             To_Char(Ps.Scpp_Pfu_Pd_Start_Dt, ''DD.MM.YYYY'') AS Start_Dt,
             To_Char(Ps.Scpp_Pfu_Pd_Stop_Dt, ''DD.MM.YYYY'') AS Stop_Dt
        FROM Uss_Person.v_Sc_Benefit_Category Bc, Uss_Ndi.v_Ndi_Benefit_Category c,
             Uss_Person.v_Sc_Pfu_Pay_Summary Ps
       WHERE Bc.Scbc_Sc = '
            || l_sc
            || '
         AND Bc.Scbc_Nbc IN (2, 20, 22, 23, 26, 30, 99, 40, 64, 69, 15, 41, 42, 43, 124, 125, 48, 35, 54, 55, 56, 19, 17)
         AND Bc.Scbc_St IN (''A'', ''VO'')
         AND c.Nbc_Id = Bc.Scbc_Nbc
         AND Ps.Scpp_Pfu_Payment_Tp = ''BENEFIT''
         AND Ps.Scpp_St IN (''A'', ''VO'')
         AND Nvl(Ps.History_Status, ''A'') = ''A''
         AND EXISTS (SELECT 1
                       FROM Uss_Person.v_Sc_Scpp_Family f, Uss_Person.v_Sc_Pfu_Accrual a
                      WHERE f.Scpf_Scpp = Ps.Scpp_Id
                        AND (f.Scpf_Sc = Bc.Scbc_Sc OR f.Scpf_Sc_Main = Bc.Scbc_Sc)
                        AND Nvl(f.Scpf_St, ''A'') IN (''A'', ''VO'')
                        AND Nvl(f.History_Status, ''A'') = ''A''
                        AND a.Scpc_Scpp = Ps.Scpp_Id
                        AND a.Scpc_Acd_Sum > 0
                        AND a.Scpc_St IN (''A'', ''VO'')
                        AND Nvl(a.History_Status, ''A'') = ''A'')');


        l_blob := reportfl_engine.PublishReportBlob;

        OPEN p_res_doc FOR
            SELECT t.rt_name || '.pdf'             AS file_name,
                   'application/pdf'               AS file_mime_type,
                   l_blob                          AS file_blob,
                   d.apd_id,
                   COALESCE (d.apd_ndt, 10227)     AS apd_ndt,
                   tp.ndt_name                     AS apd_ndt_name,
                   d.apd_doc,
                   COALESCE (d.apd_app, l_app)     AS apd_app,
                   d.apd_dh
              FROM v_rpt_templates  t
                   LEFT JOIN v_ap_document d
                       ON     d.apd_ap = p_ap_id
                          AND d.apd_app = l_app
                          AND d.apd_ndt = 10227
                          AND d.history_status = 'A'
                   LEFT JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = COALESCE (d.apd_ndt, 10227))
             WHERE t.rt_code = 'BENEFIT_DOVIDKA_R1';
    END;

    -- info:   Отримання друкованої форми довідки
    -- params: p_ap_id - ідентифікатор звернення
    -- note:  в разі успішного підготовки файл необхідно зберегти/оновити документ звернення
    PROCEDURE get_dovidka_doc (p_ap_id     IN     appeal.ap_id%TYPE,
                               p_res_doc      OUT SYS_REFCURSOR)
    IS
        l_nst   NUMBER;
    BEGIN
        SELECT MAX (t.aps_nst)
          INTO l_nst
          FROM ap_service t
         WHERE t.aps_ap = p_ap_id AND t.history_status = 'A';

        IF (l_nst = 981)
        THEN
            get_piljg_dovidka_doc (p_ap_id, p_res_doc);
        ELSIF (l_nst = 663)
        THEN
            get_reference_disability_doc (p_ap_id, p_res_doc);
        ELSE
            raise_application_error (
                -20000,
                'Для поточної послуги немає реалізації довідки або не вибрано послугу!');
        END IF;
    END;

    -- info:   Отримання blob-а з файлом пам'ятки
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #78649, кнопка "Друк пам'ятки"
    PROCEDURE get_note_rpt_blob (p_ap_id            IN     appeal.ap_id%TYPE,
                                 p_code             IN     VARCHAR2,
                                 p_file_name           OUT VARCHAR2,
                                 p_file_mime_type      OUT VARCHAR2,
                                 p_rpt_blob            OUT BLOB)
    IS
    BEGIN
        FOR c
            IN (SELECT MAX (a.ap_id)         AS ap_id,
                       MAX (at.dic_name)     AS ap_tp_name,
                       MAX (s.aps_id)        AS aps_id,
                       MAX (st.nst_name)     AS aps_tp_name
                  FROM uss_ndi.v_ddn_ap_tp  at
                       LEFT JOIN v_appeal a
                           ON a.ap_id = p_ap_id AND a.ap_tp = 'D'
                       JOIN uss_ndi.v_ndi_service_type st
                       LEFT JOIN v_ap_service s
                           ON     s.aps_nst = st.nst_id
                              AND s.aps_ap = p_ap_id
                              AND s.history_status = 'A'
                           ON (st.nst_code IN ('134', '135', '136'))
                 WHERE at.dic_value = 'D')
        LOOP
            IF c.ap_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                       q'[Сформувати пам'ятку можливо тільки для типу звернення "]'
                    || c.ap_tp_name
                    || '"!');
            ELSIF c.aps_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                       q'[Сформувати пам'ятку можливо тільки для послуги "]'
                    || c.aps_tp_name
                    || '"!');
            ELSE
                SELECT rt_name || '.' || rt_file_tp,
                       'application/pdf',
                       rt_text
                  INTO p_file_name, p_file_mime_type, p_rpt_blob
                  FROM v_rpt_templates
                 WHERE rt_code = COALESCE (p_code, 'NOTE_R1');
            END IF;
        END LOOP;
    END;

    PROCEDURE get_ap_edarp_dovidka (p_ap_id     IN     NUMBER,
                                    p_res_doc      OUT SYS_REFCURSOR)
    IS
        l_sc       NUMBER;
        l_app      NUMBER;
        l_ap_num   VARCHAR2 (100);
        l_blob     BLOB;
    BEGIN
        SELECT MAX (t.app_sc), MAX (t.app_id), MAX (ap_num)
          INTO l_sc, l_app, l_ap_num
          FROM ap_person t JOIN appeal p ON (ap_id = t.app_ap)
         WHERE t.app_ap = p_ap_id AND t.app_tp = 'Z';

        IF (l_sc IS NULL)
        THEN
            raise_application_error (-20000,
                                     'Не знайдено соц. картку заявника!');
        END IF;

        reportfl_engine.InitReport ('USS_VISIT', 'EDARP_DOVIDKA_R1');

        reportfl_engine.AddParam ('user_pib', tools.GetCurrUserPIB ());

        reportfl_engine.adddataset (
            'ds_info',
               '
        WITH dat AS (SELECT t.RAJ, t.R_NCARDP
                       FROM uss_person.v_x_trg t
                       join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                      WHERE c.scbc_sc = '
            || l_sc
            || '
                      FETCH FIRST ROW ONLY
                      )
        select distinct to_char(SYSDATE, ''DD.MM.YYYY'')  AS cur_dt,
               ''_______'' AS ap_num,
               r.R_NAME1 AS last_name,
               r.R_NAME2 AS first_name,
               r.R_NAME3 AS middle_name,
               to_char(b.fam_dtbirth, ''DD.MM.YYYY'') AS birth_dt,
               b.fam_numtaxp AS rnokpp,
               case when os.osoba_znach2 > 0 then substr(regexp_replace(os.osoba_strznach, ''\D''), 1, 13) else null end AS unzr,
               decode(b.fam_pol, 1, ''чоловік'', ''жінка'') AS gender,
               case when os.osoba_znach2 > 0 then LPAD(to_char(ROUND(os.osoba_znach2)), 9, ''0'')
                    else to_char(REPLACE(REPLACE(trim(b.fam_pasp), '' '', ''''), ''-'', ''''))
                END AS pasp_info,
               case when trim(r.r_strtel) is not null and nvl(trim(r.r_kolkat),0) <>0 then to_char(''+380''||nvl(lpad(trim(r.r_kolkat),2,0),''00'')||lpad(trim(r.r_strtel),7,0))
                    else lpad(to_char(trim(r.r_strtel)),7,0)
                END AS phone_num,
               case when (select count(*) from uss_person.v_b_katpp z where t.raj = z.raj and t.r_ncardp = z.r_ncardp and z.katp_cd in (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)) > 0 then
                      to_char(trunc(r.raj,-2) || ''; '' || r.raj )
                    else
                      to_char(b2.klat_name) ||''; ''|| to_char(b1.klat_name) || ''; '' || to_char(r.r_index) ||''; ''|| to_char(ind.klind_adr) || ''; ''
                          || to_char(ku.klkatul_name) || '' '' || to_char(q.klul_name)|| ''; '' || nvl2(to_char(r.r_house), ''Буд. '' || to_char(r.r_house)
                          || '' '', '''') || to_char(r.r_build) || nvl2(to_char(r.r_apt), ''; кв. '' || to_char(r.r_apt), '''')
               end AS addr_reg,
               case when (sel.osoba_code != 9 or sel.osoba_code is null) and (select count(*) from uss_person.v_b_katpp z where t.raj = z.raj and t.r_ncardp = z.r_ncardp and z.katp_cd in (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139) ) > 0 then
                      to_char(trunc(r.raj,-2) || ''; '' || r.raj )
                    when (sel.osoba_code != 9 or sel.osoba_code is null) then
                      to_char(b2.klat_name) ||''; ''|| to_char(b1.klat_name) || ''; '' || to_char(r.r_index) ||''; ''|| to_char(ind.klind_adr) || ''; ''
                          || to_char(ku.klkatul_name) || '' '' || to_char(q.klul_name)|| ''; '' || nvl2(to_char(r.r_house), ''Буд. '' || to_char(r.r_house)
                          || '' '', '''') || to_char(r.r_build) || nvl2(to_char(r.r_apt), ''; кв. '' || to_char(r.r_apt), '''')
               end as addr_liv,
               decode(sel.osoba_code, 9, ''ні'', ''так'') AS addr_identical,
               to_char(b.fam_dtbeg , ''DD.MM.YYYY'')  AS get_dt,
               to_char(b.fam_dtexit, ''DD.MM.YYYY'')  AS post_dt,
               p.klpsn_name AS post_reason,
               r.raj||''-''||b1.klat_name as oszn,
               t.r_ncardp AS card_num
         FROM dat t
         JOIN uss_person.v_b_reestrlg r ON (r.raj = t.RAJ AND r.R_NCARDP = t.R_NCARDP)
         join uss_person.v_b_famp b on b.raj = r.raj and b.r_ncardp = r.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
         left join uss_person.v_b_klul q on q.klul_codern = r.raj and q.klul_codeul = r.r_cdul
         left join uss_person.v_b_klkatul ku on ku.klkatul_code = q.klul_codekul
         left join uss_person.v_b_klat b1 on r.raj = b1.klat_code
         left join uss_person.v_b_klat b2 on trunc(r.raj,-2) = b2.klat_code
         left join uss_person.v_b_klind ind on r.r_index = ind.klind_ind
         left join uss_person.v_b_osobap os on os.raj = b.raj and os.r_ncardp = b.r_ncardp and os.osoba_nfam = b.fam_nomf and os.osoba_code = 50
         left join (select  distinct o.raj, o.r_ncardp, o.osoba_code from uss_person.v_b_osobap o where o.osoba_code = 9 and o.osoba_cdexit = 0 and o.osoba_znach1 = 0 and o.osoba_dtend is null) sel on sel.raj = r.raj and sel.r_ncardp = r.r_ncardp
         left join uss_person.v_b_klpsn p on b.fam_cdexit = p.klpsn_code -- треба поправити довідник, додам  b_klpsn
        where trunc(sysdate) between b.fam_dtbeg and b.fam_dtexit -- діюча картка пільговика (по заякнику b.fam_nomf = 0)
     ');

        reportfl_engine.adddataset (
            'ds1',
               'WITH dat AS (SELECT t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || l_sc
            || '
                          FETCH FIRST ROW ONLY
                          )

            select b.fam_nomf as rn,
                   ftp.klfam_name as fam_tp,
                   trim(b.fam_fio) AS pib,
                   to_char(b.fam_dtbirth, ''DD.MM.YYYY'') AS birth_dt,
                   b.fam_numtaxp as rnokpp,
                   case when os.osoba_znach2 > 0 then substr(regexp_replace(os.osoba_strznach,''\D''),1,13) else null end as unzr,
                   decode(b.fam_pol, 1, ''чоловік'', ''жінка'') as gender,
                   case when os.osoba_znach2 > 0 then LPAD(to_char(ROUND(os.osoba_znach2)), 9, ''0'')
                        else to_char(REPLACE(REPLACE(trim(b.fam_pasp), '' '', ''''), ''-'', ''''))
                    END AS doc_info,
                   to_char(b.fam_dtbeg , ''DD.MM.YYYY'') AS start_dt,
                   to_char(b.fam_dtexit, ''DD.MM.YYYY'') AS stop_dt,
                   p.klpsn_name as stop_reason
              FROM dat t
              JOIN uss_person.v_b_reestrlg r ON (r.raj = t.RAJ AND r.R_NCARDP = t.R_NCARDP)
              join uss_person.v_b_famp b on b.raj = r.raj and b.r_ncardp = r.r_ncardp /*and b.fam_nomf != 0 -- заявник -- пільговик*/
              LEFT JOIN uss_person.v_B_klFam ftp ON (ftp.klfam_code = b.FAM_CDRELAT)
              left join uss_person.v_b_osobap os on (os.raj = b.raj and os.r_ncardp = b.r_ncardp and os.osoba_nfam = b.fam_nomf and os.osoba_code = 50)
              left join uss_person.v_b_klpsn p on (p.klpsn_code = b.fam_cdexit)
             where trunc(sysdate) between b.fam_dtbeg and b.fam_dtexit
               and (select count(*) from uss_person.v_b_katpp z where t.raj = z.raj and t.r_ncardp = z.r_ncardp) > 0
             order by b.fam_nomf
        ');

        reportfl_engine.adddataset (
            'ds2',
               'WITH dat AS (SELECT t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || l_sc
            || '
                          FETCH FIRST ROW ONLY
                          )

          select l.klplgkat_name||'' (''||k.katp_cd||'')'' as cat_name, -- Категорії пільговика
                 u.underc_name as subcat_name, --Підкатегорія
                 w.kllaw_name as law_name, --Закон
                 l.klplgkat_stat as law_det_name, --Стаття
                 k.katp_doc as pasp_info, --серія та номер Посвідчення
                 to_char(k.katp_dt, ''DD.MM.YYYY'') as pasp_dt, --дата видачі
                 to_char(k.katp_dte, ''DD.MM.YYYY'') as pasp_end_dt, --термін дії
                 k.katp_dep as pasp_who, --ким видане
                 sel2.cdd as type_list, --Перелік видів пільг на які пільговик має право, відповідно до категорії -- тут буде довідник -- працюємо
                 decode(sel2.ozn,1,''так'',null) as is_main_cat
            from dat t
            JOIN uss_person.v_b_famp b ON (b.raj = t.RAJ AND b.R_NCARDP = t.R_NCARDP)
            left join uss_person.v_b_katpp k on b.raj = k.raj and b.r_ncardp = k.r_ncardp
            left join uss_person.v_b_klplgkat l on k.katp_cd = l.klplgkat_code
            left join uss_person.v_b_kllaw w on l.klplgkat_lcd = w.kllaw_code
            left join uss_person.v_b_osobap o on b.raj = o.raj and b.r_ncardp = o.r_ncardp and b.fam_nomf = o.osoba_nfam and o.osoba_code = ''1''||lpad(k.katp_cd,3,0) and o.osoba_dtbeg = to_date(''2000-01-01'',''YYYY-MM-DD'')
            left join uss_person.v_b_underc u on k.katp_cd = u.underc_kat and o.osoba_cdexit = u.underc_ukat
            left join (
            select sel.raj, sel.r_ncardp, sel.lg_cdkat, max(case when sel.tplgot_code in (5,6) then 1 else null end) ozn, LISTAGG(sel.tplgot_name, '', '') WITHIN GROUP (ORDER BY sel.tplgot_name) cdd
              from (select g.raj, g.r_ncardp, g.lg_cdkat, o.tplgot_code, o.tplgot_name
                      from uss_person.v_b_lgp g
                      JOIN dat zd ON (zd.raj = g.raj AND zd.r_ncardp = g.r_ncardp)
                      left join uss_person.v_b_lgot j on g.lg_cd = j.lgot_code
                      left join uss_person.v_b_tplgot o on j.lgot_cdtip = o.tplgot_code
                     where trunc(sysdate) between g.lg_dtb and g.lg_dte
                     group by g.raj, g.r_ncardp, g.lg_cdkat, o.tplgot_code, o.tplgot_name
                   ) sel
             group by sel.raj, sel.r_ncardp, sel.lg_cdkat
            ) sel2 on (b.raj = sel2.raj and b.r_ncardp = sel2.r_ncardp and k.katp_cd = sel2.lg_cdkat) -- тут буде довідник
           where trunc(sysdate) between b.fam_dtbeg and b.fam_dtexit -- діюча картка пільговика (по заякнику b.fam_nomf = 0)
             and b.fam_nomf = 0
            ORDER BY k.katp_cd, l.klplgkat_name
            ');

        reportfl_engine.adddataset (
            'ds3',
               'WITH dat AS (SELECT distinct t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || l_sc
            || '
                          )
           select distinct
                  n.lg_cdkat AS cat_code, -- Категорія пільговика
                  n.lg_cd AS pilg_code, --код пільги
                  l.lgot_name AS pilg_name, -- назва пільги
                  n.lg_dtb,
                  to_char(GREATEST(n.lg_dtb, b.fam_dtbeg), ''DD.MM.YYYY'') ||''-''|| to_char(least(nvl(b.fam_dtexit, n.lg_dte), n.lg_dte), ''DD.MM.YYYY'') AS pilg_period, --Дата початку та кінця надання пільги
                  n.raj||''-''||n.r_ncardp ||''; ''||
                    b2.klat_name ||''; ''|| b1.klat_name || ''; '' || r.r_index ||''; ''|| ind.klind_adr || ''; ''
                    || ku.klkatul_name || '' '' || q.klul_name || ''; '' || nvl2(r.r_house, ''Буд. '' || r.r_house
                    || '' '', '''') || r.r_build || nvl2(r.r_apt, ''; кв. '' || r.r_apt, '''')
                   as addr,
                  t.tplgot_name AS gkp, -- ЖКП/СГТП
                  case when n.lg_kod <> 0 then g.klorgz_name ||'' (''||g.klorgz_code||'')'' else null end AS supplier, -- Організація надавач послуг
                  n.lg_cdo AS acc, --Особовий рахунок
                  s.riznpos_name AS service, --Різновид послуги
                  t.tar_cost AS tarif, --Тариф
                  (select mm.klpsn_name from uss_person.v_b_klpsn mm where mm.klpsn_code = (case when n.lg_cdpsn = 0 and trunc(sysdate) not between n.lg_dtb and n.lg_dte then 15
                     when n.lg_cdpsn <> 0 or (n.lg_cdpsn = 0 and trunc(sysdate) between b.fam_dtbeg and b.fam_dtexit) then n.lg_cdpsn
                     else b.fam_cdexit end)) AS stop_reason--, --Причина припинення пільги
             from dat t
             JOIN uss_person.v_b_lgp n ON (n.raj = t.raj and n.r_ncardp = t.r_ncardp)
             join uss_person.v_b_reestrlg r on n.raj = r.raj and n.r_ncardp = r.r_ncardp
             join uss_person.v_b_famp b on b.raj = r.raj and b.r_ncardp = r.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
             left join uss_person.v_b_klul q on q.klul_codern = r.raj and q.klul_codeul = r.r_cdul
             left join uss_person.v_b_klkatul ku on ku.klkatul_code = q.klul_codekul
             left join uss_person.v_b_klat b1 on r.raj = b1.klat_code
             left join uss_person.v_b_klat b2 on trunc(r.raj,-2) = b2.klat_code
             left join uss_person.v_b_klind ind on r.r_index = ind.klind_ind
             left join uss_person.v_b_lgot l on n.lg_cd = l.lgot_code
             left join uss_person.v_b_tplgot t on l.lgot_cdtip = t.tplgot_code
             left join uss_person.v_b_klorgz g on n.raj = g.raj and n.lg_kod = g.klorgz_code  and n.lg_kod <> 0
             left join uss_person.v_b_klrizpos s on n.raj = s.raj and n.lg_cd = s.riznpos_cdpos and n.lg_paydservcd = s.riznpos_code
             left join uss_person.v_b_tarif t on n.raj = t.raj and n.lg_cd = t.tar_cdplg and n.lg_paydservcd = t.tar_serv and n.lg_paysys= t.tar_code and trunc(sysdate) between t.tar_dateb and t.tar_datee
            WHERE 1 = 1
            order by n.lg_cdkat, n.lg_cd, n.lg_dtb
            ');

        reportfl_engine.adddataset (
            'ds4',
               'WITH dat AS (SELECT distinct t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || l_sc
            || '
                          )
           select distinct to_char(year) || to_char(month) as main_param,
                  year,
                  month
             from (
             select
                    h.lgnac_godin as year, -- рік нарахування
                    h.lgnac_mecin as month -- місяць нарахування
               from dat t
               JOIN uss_person.v_b_lgp n ON (n.raj = t.raj and n.r_ncardp = t.r_ncardp)
               left join  uss_person.v_b_lgot l on (n.lg_cd = l.lgot_code)
               left join uss_person.v_b_klvposl k on (n.lg_cd = k.klvposl_cdposl)
               left join uss_person.v_b_lgnacp h on (n.raj = h.raj and n.r_ncardp = h.r_ncardp and n.lg_cdkat = h.lg_cdkat and n.lg_cd = h.lg_cd and n.lg_dtb = h.lg_dtb)
              where 1 = 1
                and h.LGNAC_MECIN is not null
                and h.LGNAC_GODIN is not null
                and nvl(h.lgnac_sum,0) <> 0
            union
            SELECT scp3_year as year,
                   to_number(pmonth) as month
             from uss_person.v_sc_pfu_pay_period t
             JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
             left JOIN uss_ndi.v_ndi_benefit_category c ON (c.nbc_id = t.scp3_nbc)
             JOIN uss_ndi.v_ndi_pfu_payment_type p ON (p.nppt_id = t.scp3_nppt)
            unpivot(
             period_sum for pmonth in (
              scp3_sum_m1 as ''1'',
              scp3_sum_m2 as ''2'',
              scp3_sum_m3 as ''3'',
              scp3_sum_m4 as ''4'',
              scp3_sum_m5 as ''5'',
              scp3_sum_m6 as ''6'',
              scp3_sum_m7 as ''7'',
              scp3_sum_m8 as ''8'',
              scp3_sum_m9 as ''9'',
              scp3_sum_m10 as ''10'',
              scp3_sum_m11 as ''11'',
              scp3_sum_m12 as ''12''
             )

            )
            where scp3_sc  = '
            || l_sc
            || '
            UNION
            --#111819
            SELECT To_Number(To_Char(a.Scpc_Acd_Dt, ''yyyy'')) AS YEAR,
                   To_Number(To_Char(a.Scpc_Acd_Dt, ''mm'')) AS MONTH
              FROM Uss_Person.v_Sc_Pfu_Pay_Summary Ps, Uss_Person.v_Sc_Pfu_Accrual a
             WHERE Ps.Scpp_Pfu_Payment_Tp = ''BENEFIT''
               AND Ps.Scpp_St IN (''A'', ''VO'')
               AND Nvl(Ps.History_Status, ''A'') = ''A''
               AND EXISTS (SELECT 1
                             FROM Uss_Person.v_Sc_Scpp_Family f
                            WHERE f.Scpf_Scpp = Ps.Scpp_Id
                              AND (Ps.Scpp_Sc = '
            || l_sc
            || ' OR f.Scpf_Sc = '
            || l_sc
            || ')
                              AND Nvl(f.Scpf_St, ''A'') IN (''A'', ''VO'')
                              AND Nvl(f.History_Status, ''A'') = ''A'')
               AND a.Scpc_Scpp = Ps.Scpp_Id
               AND a.Scpc_St IN (''A'', ''VO'')
               AND Nvl(a.History_Status, ''A'') = ''A''
        )
        order by year, month
          ');

        reportfl_engine.adddataset (
            'ds4_m',
               'WITH dat AS (SELECT distinct t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || l_sc
            || '
                          )
           select t.*,
                  to_char(year) || to_char(month) as param,
                  row_number() over (order by year_to, month_to, code) as rn
            from (
             select to_char(n.lg_cd) as code, --код пільги
                    to_char(nvl(l.lgot_name,k.klvposl_name)) as name, -- назва пільги
                    h.lgnac_godin as year, -- рік нарахування
                    h.lgnac_mecin as month, -- місяць нарахування
                    h.lgnac_god as year_to,
                    h.lgnac_mec as month_to,
                    to_char(h.lgnac_sum, ''FM9999999999999990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''') as pilg_sum
               from dat t
               JOIN uss_person.v_b_lgp n ON (n.raj = t.raj and n.r_ncardp = t.r_ncardp)
               left join  uss_person.v_b_lgot l on (n.lg_cd = l.lgot_code)
               left join uss_person.v_b_klvposl k on (n.lg_cd = k.klvposl_cdposl)
               left join uss_person.v_b_lgnacp h on (n.raj = h.raj and n.r_ncardp = h.r_ncardp and n.lg_cdkat = h.lg_cdkat and n.lg_cd = h.lg_cd and n.lg_dtb = h.lg_dtb)
              where 1 = 1
                and h.LGNAC_MECIN is not null
                and h.LGNAC_GODIN is not null
                and nvl(h.lgnac_sum,0) <> 0
            union
            SELECT nppt_code as code,
                   nppt_name as name,
                   scp3_year as year,
                   to_number(pmonth) as month,
                   scp3_year as year_to,
                   to_number(pmonth) as month_to,
                   to_char(period_sum, ''FM9999999999999990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')  as pilg_sum
             from uss_person.v_sc_pfu_pay_period t
             JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
             left JOIN uss_ndi.v_ndi_benefit_category c ON (c.nbc_id = t.scp3_nbc)
             JOIN uss_ndi.v_ndi_pfu_payment_type p ON (p.nppt_id = t.scp3_nppt)
            unpivot(
             period_sum for pmonth in (
              scp3_sum_m1 as ''1'',
              scp3_sum_m2 as ''2'',
              scp3_sum_m3 as ''3'',
              scp3_sum_m4 as ''4'',
              scp3_sum_m5 as ''5'',
              scp3_sum_m6 as ''6'',
              scp3_sum_m7 as ''7'',
              scp3_sum_m8 as ''8'',
              scp3_sum_m9 as ''9'',
              scp3_sum_m10 as ''10'',
              scp3_sum_m11 as ''11'',
              scp3_sum_m12 as ''12''
             )

            )
            where scp3_sc  = '
            || l_sc
            || '
            UNION
            --#111819
           SELECT Nppt_Code AS Code,
                  Nppt_Name AS NAME,
                  To_Number(To_Char(a.Scpc_Acd_Dt, ''yyyy'')) AS YEAR,
                  To_Number(To_Char(a.Scpc_Acd_Dt, ''mm'')) AS MONTH,
                  To_Number(To_Char(a.Scpc_Acd_Dt, ''yyyy'')) AS Year_To,
                  To_Number(To_Char(a.Scpc_Acd_Dt, ''mm'')) AS Month_To,
                  To_Char(a.Scpc_Acd_Sum, ''FM9999999999999990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''') AS Pilg_Sum
             FROM Uss_Person.v_Sc_Pfu_Pay_Summary Ps,
                  Uss_Person.v_Sc_Pfu_Accrual a,
                  Uss_Ndi.v_Ndi_Pfu_Payment_Type p
            WHERE Ps.Scpp_Pfu_Payment_Tp = ''BENEFIT''
              AND Ps.Scpp_St IN (''A'', ''VO'')
              AND Nvl(Ps.History_Status, ''A'') = ''A''
              AND EXISTS (SELECT 1
                            FROM Uss_Person.v_Sc_Scpp_Family f
                           WHERE f.Scpf_Scpp = Ps.Scpp_Id
                             AND (Ps.Scpp_Sc = '
            || l_sc
            || ' OR f.Scpf_Sc = '
            || l_sc
            || ')
                             AND Nvl(f.Scpf_St, ''A'') IN (''A'', ''VO'')
                             AND Nvl(f.History_Status, ''A'') = ''A'')
              AND a.Scpc_Scpp = Ps.Scpp_Id
              AND a.Scpc_St IN (''A'', ''VO'')
              AND Nvl(a.History_Status, ''A'') = ''A''
              AND p.Nppt_Id = a.Scpc_Nppt
        ) t
        where 1 = 1
          ');

        reportfl_engine.adddataset (
            'ds4_t',
               'WITH dat AS (SELECT distinct t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || l_sc
            || '
                          )
           select t.year,
                  t.month,
                  to_char(year) || to_char(month) as param,
                  to_char(sum(t.pilg_sum), ''FM9999999999999990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''') as tot_sum
            from (
             select h.lgnac_godin as year, -- рік нарахування
                    h.lgnac_mecin as month, -- місяць нарахування
                    h.lgnac_sum as pilg_sum
               from dat t
               JOIN uss_person.v_b_lgp n ON (n.raj = t.raj and n.r_ncardp = t.r_ncardp)
               left join  uss_person.v_b_lgot l on (n.lg_cd = l.lgot_code)
               left join uss_person.v_b_klvposl k on (n.lg_cd = k.klvposl_cdposl)
               left join uss_person.v_b_lgnacp h on (n.raj = h.raj and n.r_ncardp = h.r_ncardp and n.lg_cdkat = h.lg_cdkat and n.lg_cd = h.lg_cd and n.lg_dtb = h.lg_dtb)
              where 1 = 1
                and h.LGNAC_MECIN is not null
                and h.LGNAC_GODIN is not null
                and nvl(h.lgnac_sum,0) <> 0
            union
            SELECT scp3_year as year,
                   to_number(pmonth) as month,
                   period_sum  as pilg_sum
             from uss_person.v_sc_pfu_pay_period t
             JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
             left JOIN uss_ndi.v_ndi_benefit_category c ON (c.nbc_id = t.scp3_nbc)
             JOIN uss_ndi.v_ndi_pfu_payment_type p ON (p.nppt_id = t.scp3_nppt)
            unpivot(
             period_sum for pmonth in (
              scp3_sum_m1 as ''1'',
              scp3_sum_m2 as ''2'',
              scp3_sum_m3 as ''3'',
              scp3_sum_m4 as ''4'',
              scp3_sum_m5 as ''5'',
              scp3_sum_m6 as ''6'',
              scp3_sum_m7 as ''7'',
              scp3_sum_m8 as ''8'',
              scp3_sum_m9 as ''9'',
              scp3_sum_m10 as ''10'',
              scp3_sum_m11 as ''11'',
              scp3_sum_m12 as ''12''
             )

            )
            where scp3_sc  = '
            || l_sc
            || '
            UNION
            --#111819
           SELECT To_Number(To_Char(a.Scpc_Acd_Dt, ''yyyy'')) AS YEAR,
                  To_Number(To_Char(a.Scpc_Acd_Dt, ''mm'')) AS MONTH,
                  a.Scpc_Acd_Sum AS Pilg_Sum
             FROM Uss_Person.v_Sc_Pfu_Pay_Summary Ps, Uss_Person.v_Sc_Pfu_Accrual a
            WHERE Ps.Scpp_Pfu_Payment_Tp = ''BENEFIT''
              AND Ps.Scpp_St IN (''A'', ''VO'')
              AND Nvl(Ps.History_Status, ''A'') = ''A''
              AND EXISTS (SELECT 1
                            FROM Uss_Person.v_Sc_Scpp_Family f
                           WHERE f.Scpf_Scpp = Ps.Scpp_Id
                             AND (Ps.Scpp_Sc = '
            || l_sc
            || ' OR f.Scpf_Sc = '
            || l_sc
            || ')
                             AND Nvl(f.Scpf_St, ''A'') IN (''A'', ''VO'')
                             AND Nvl(f.History_Status, ''A'') = ''A'')
              AND a.Scpc_Scpp = Ps.Scpp_Id
              AND a.Scpc_St IN (''A'', ''VO'')
              AND Nvl(a.History_Status, ''A'') = ''A''
        ) t
        group by year, month
        having 1 = 1
          ');


        reportfl_engine.AddRelation ('ds4',
                                     'main_param',
                                     'ds4_m',
                                     'param');
        reportfl_engine.AddRelation ('ds4',
                                     'main_param',
                                     'ds4_t',
                                     'param');

        l_blob := reportfl_engine.PublishReportBlob;

        uss_person.Api$socialcard.write_sc_log (
            l_sc,
            NULL,
            NULL,
            CHR (38) || '222#' || l_ap_num,
            NULL,
            NULL);

        OPEN p_res_doc FOR
            SELECT t.rt_name || '.pdf'             AS file_name,
                   'application/pdf'               AS file_mime_type,
                   l_blob                          AS file_blob,
                   d.apd_id,
                   COALESCE (d.apd_ndt, 10219)     AS apd_ndt,
                   d.apd_doc,
                   COALESCE (d.apd_app, l_app)     AS apd_app,
                   d.apd_dh                                                --,
              --coalesce(d.apd_aps, data_cur.nst_id) AS apd_aps--,
              --LTRIM(v_msg, '*') AS warning
              FROM v_rpt_templates  t
                   LEFT JOIN v_ap_document d
                       ON     d.apd_ap = p_ap_id
                          AND d.apd_app = l_app
                          AND d.apd_ndt = 10219
                          AND d.history_status = 'A'
             WHERE t.rt_code = 'EDARP_DOVIDKA_R1';
    END;
BEGIN
    NULL;
END;
/