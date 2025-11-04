/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$RPT_ANNEX
IS
    -- Author  : LEV
    -- Created : 27.07.2022 14:31:21
    -- Purpose : Робота зі звітами які готуються через сервіс асинхронно

    -- info:   отримання списку звернень для підготовки звіту
    -- params:
    -- note:
    PROCEDURE get_app_list (p_res_cur OUT SYS_REFCURSOR);

    PROCEDURE get_app_list (p_nst_id IN NUMBER, p_res_cur OUT SYS_REFCURSOR);

    -- info:   Отримання значення довідника
    -- params: p_dict_id - ідентифікатор довідника
    --         p_id_num - числовий ідентифікатор значення довідника
    --         p_id_str - строковий ідентифікатор значення довідника
    -- note:
    FUNCTION get_dict_val (p_dict_id   IN NUMBER,
                           p_id_num    IN NUMBER,
                           p_id_str    IN VARCHAR2)
        RETURN VARCHAR2;

    -- info:   отримання blob-файлу звіту для звернення
    -- params: p_ap_id - ідентифікатор звернення
    -- note:
    PROCEDURE get_app_rpt_blob (p_ap_id      IN     NUMBER,
                                p_is_error      OUT VARCHAR2,
                                p_doc_name      OUT VARCHAR2,
                                p_blob          OUT BLOB);

    -- info:   збереження файла документа в зверненні
    -- params: p_ap_id - ідентифікатор звернення
    --         p_doc_id - ідентифікатор документа
    --         p_dh_id - ідентифікатор зрізу документа
    -- note:
    PROCEDURE set_app_doc (p_ap_id    IN NUMBER,
                           p_doc_id   IN NUMBER,
                           p_dh_id    IN NUMBER);


    -- info:   збереження файла документа в зверненні
    -- params: p_ap_id - ідентифікатор звернення
    --         p_nst_id - ідентифікатор послуги
    --         p_ndt_id - ідентифікатор типу документа
    --         p_doc_id - ідентифікатор документа в архіві
    --         p_dh_id - ідентифікатор зрізу документа в архіві
    -- note:
    PROCEDURE set_app_doc (p_ap_id    IN NUMBER,
                           p_nst_id   IN NUMBER,
                           p_ndt_id   IN NUMBER,
                           p_doc_id   IN NUMBER,
                           p_dh_id    IN NUMBER);

    PROCEDURE get_app_rpt_blob (p_ap_id      IN     NUMBER,
                                p_nst_id     IN     NUMBER,
                                p_is_error      OUT VARCHAR2,
                                p_doc_name      OUT VARCHAR2,
                                p_blob          OUT BLOB);


    -- info:   отримання blob-файлу звіту довідки 61 / 10372 (результат)
    -- params: p_ap_id - ідентифікатор звернення
    -- note:
    PROCEDURE get_dovidka_61_rpt_blob (p_ap_id      IN     NUMBER,
                                       p_sc_id      IN     NUMBER,
                                       p_is_error      OUT VARCHAR2,
                                       p_doc_name      OUT VARCHAR2,
                                       p_blob          OUT BLOB);
END;
/


GRANT EXECUTE ON USS_ESR.DNET$RPT_ANNEX TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$RPT_ANNEX TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$RPT_ANNEX
IS
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

    -- info:   Отримання назви файлу звіту
    -- params: p_rt_code - код шаблону
    -- note:
    FUNCTION get_filename_by_code (p_rt_code IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (250);
    BEGIN
        SELECT TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS') || '_' || rt_filename
          INTO l_name
          FROM v_rpt_templates
         WHERE rt_code = p_rt_code;

        RETURN l_name;
    END;

    FUNCTION get_bool_str (p_val IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE
                   WHEN p_val IS NULL THEN NULL
                   WHEN p_val IN ('T', '1') THEN 'Так'
                   ELSE 'Ні'
               END;
    END;

    -- info:   отримання списку звернень для підготовки звіту
    -- params:
    -- note:
    PROCEDURE get_app_list (p_res_cur OUT SYS_REFCURSOR)
    IS
        l_blob   BLOB := NULL;
        l_id     NUMBER (14, 0) := 0;
    BEGIN
        OPEN p_res_cur FOR
            SELECT a.ap_id,
                   a.ap_id     AS p_ap_id,
                   l_blob      AS p_file,
                   l_id        AS p_doc_id,
                   l_id        AS p_dh_id,
                   ''          AS p_doc_name,
                   ''          AS p_is_error,
                   'RTF'       ori_format,
                   'PDF'       AS dest_format
              FROM appeal  a
                   JOIN v_ap_service s
                       ON     s.aps_ap = a.ap_id
                          AND s.aps_nst = 761
                          AND s.history_status = 'A'
                   JOIN v_ap_document d
                       ON     d.apd_ap = a.ap_id
                          AND d.apd_ndt = 741
                          AND d.history_status = 'A'
             WHERE a.ap_tp = 'D' AND a.ap_st = 'O';
    END;

    -- info:   отримання списку звернень для підготовки звіту
    -- params:
    -- note:
    PROCEDURE get_app_list (p_nst_id IN NUMBER, p_res_cur OUT SYS_REFCURSOR)
    IS
        l_blob   BLOB := NULL;
        l_id     NUMBER (14, 0) := 0;
    BEGIN
        OPEN p_res_cur FOR
            SELECT a.ap_id,
                   a.ap_id                                       AS p_ap_id,
                   p_nst_id                                      AS p_nst_id,
                   l_blob                                        AS p_file,
                   l_id                                          AS p_doc_id,
                   l_id                                          AS p_dh_id,
                   ''                                            AS p_doc_name,
                   ''                                            AS p_is_error,
                   'RTF'                                         ori_format,
                   'PDF'                                         AS dest_format,
                      'Витяг від '
                   || TO_CHAR (SYSDATE, 'DD.MM.YYYY')
                   || ' №'
                   || a.ap_num
                   || ' '                                        AS qr_prefix,
                   ' ' || TO_CHAR (a.ap_reg_dt, 'DD.MM.YYYY')    AS qr_syfix
              FROM appeal  a
                   JOIN v_ap_service s
                       ON     s.aps_ap = a.ap_id
                          AND s.aps_nst = p_nst_id
                          AND s.history_status = 'A'
             WHERE a.ap_tp = 'D' AND a.ap_st = 'O';
    END;

    -- info:   Отримання значення довідника
    -- params: p_dict_id - ідентифікатор довідника
    --         p_id_num - числовий ідентифікатор значення довідника
    --         p_id_str - строковий ідентифікатор значення довідника
    -- note:
    FUNCTION get_dict_val (p_dict_id   IN NUMBER,
                           p_id_num    IN NUMBER,
                           p_id_str    IN VARCHAR2)
        RETURN VARCHAR2
    IS
        v_sql   VARCHAR2 (4000);
        v_val   VARCHAR2 (4000);
    BEGIN
        IF     p_dict_id IS NOT NULL
           AND (p_id_num IS NOT NULL OR p_id_str IS NOT NULL)
        THEN
            SELECT ndc_sql
              INTO v_sql
              FROM uss_ndi.v_ndi_dict_config
             WHERE ndc_id = p_dict_id;

            EXECUTE IMMEDIATE   'SELECT MAX(name) FROM ('
                             || v_sql
                             || ') WHERE id = '
                             || (CASE
                                     WHEN p_id_num IS NOT NULL
                                     THEN
                                         TO_CHAR (p_id_num)
                                     ELSE
                                         q'[']' || p_id_str || q'[']'
                                 END)
                INTO v_val;
        ELSE
            RETURN COALESCE (TO_CHAR (p_id_num), p_id_str);
        END IF;

        RETURN v_val;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN COALESCE (TO_CHAR (p_id_num), p_id_str);
    END;

    -- info:   отримання blob-файлу звіту для звернення
    -- params: p_ap_id - ідентифікатор звернення
    -- note:
    PROCEDURE get_app_rpt_blob (p_ap_id      IN     NUMBER,
                                p_is_error      OUT VARCHAR2,
                                p_doc_name      OUT VARCHAR2,
                                p_blob          OUT BLOB)
    IS
        v_curr_dt                     DATE := SYSDATE;
        v_clob                        CLOB
            := tools.convertb2c (get_template_by_code ('ANNEX_8_R1'));
        v_reg_wu                      VARCHAR2 (4000);
        v_rnspm_id                    NUMBER;
        v_rnsps_last_name             VARCHAR2 (4000);
        v_rnsps_first_name            VARCHAR2 (4000);
        v_rnsps_middle_name           VARCHAR2 (4000);
        v_rnsps_numident              VARCHAR2 (4000);
        v_rnsps_is_numident_missing   VARCHAR2 (4000);
        v_rnsps_pass_seria            VARCHAR2 (4000);
        v_rnsps_pass_num              VARCHAR2 (4000);
        v_nda_2183                    VARCHAR2 (4000);
        v_nda_2184                    VARCHAR2 (4000);
        v_param_73                    VARCHAR2 (4000);
    BEGIN
        FOR c
            IN (    SELECT SUBSTR (TO_CHAR (v_curr_dt, 'DDMMYYYY'), LEVEL, 1)
                               AS dt,
                           TO_CHAR (LEVEL)
                               AS lvl
                      FROM DUAL
                CONNECT BY LEVEL <= LENGTH (TO_CHAR (v_curr_dt, 'DDMMYYYY'))
                  ORDER BY LEVEL)
        LOOP
            v_clob := REPLACE (v_clob, '#curr_dt' || c.lvl || '#', c.dt);
        END LOOP;

        FOR c1 IN (SELECT ap_num,
                          ap_reg_dt,
                          (SELECT wu_pib
                             FROM ikis_sysweb.v$all_users
                            WHERE wu_id = com_wu)    AS ap_reg_user,
                          com_wu
                     FROM appeal
                    WHERE ap_id = p_ap_id)
        LOOP
            v_clob := REPLACE (v_clob, '#ap_num#', c1.ap_num);
            v_clob :=
                REPLACE (v_clob,
                         '#ap_reg_dt#',
                         TO_CHAR (c1.ap_reg_dt, 'DD.MM.YYYY'));

            IF c1.ap_reg_user IS NOT NULL
            THEN
                v_clob := REPLACE (v_clob, '#ap_reg_user#', c1.ap_reg_user);
            ELSIF c1.com_wu IS NOT NULL
            THEN
                BEGIN
                    v_clob :=
                        REPLACE (v_clob,
                                 '#ap_reg_user#',
                                 TRIM (tools.getuserpib (v_reg_wu)));
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        v_clob := REPLACE (v_clob, '#ap_reg_user#', '');
                END;
            ELSE
                v_clob := REPLACE (v_clob, '#ap_reg_user#', '');
            END IF;
        END LOOP;

        --пошук надавача соціальних послуг
        FOR c2
            IN (SELECT MAX (
                           CASE da.apda_nda
                               WHEN 2162 THEN da.apda_val_string
                           END)
                           AS on_curr_dt,
                       MAX (
                           CASE da.apda_nda
                               WHEN 2163 THEN da.apda_val_string
                           END)
                           AS on_other_dt,
                       MAX (
                           CASE da.apda_nda WHEN 2164 THEN da.apda_val_dt END)
                           AS other_dt,
                       MAX (
                           CASE da.apda_nda
                               WHEN 2165 THEN da.apda_val_string
                           END)
                           AS is_fiz_pers,
                       MAX (
                           CASE da.apda_nda
                               WHEN 2166 THEN da.apda_val_string
                           END)
                           AS last_name,
                       MAX (
                           CASE da.apda_nda
                               WHEN 2167 THEN da.apda_val_string
                           END)
                           AS first_name,
                       MAX (
                           CASE da.apda_nda
                               WHEN 2168 THEN da.apda_val_string
                           END)
                           AS middle_name,
                       MAX (
                           CASE da.apda_nda
                               WHEN 2169 THEN da.apda_val_string
                           END)
                           AS numident,
                       MAX (
                           CASE da.apda_nda
                               WHEN 2170 THEN da.apda_val_string
                           END)
                           AS pass_seria,
                       MAX (
                           CASE da.apda_nda
                               WHEN 2171 THEN da.apda_val_string
                           END)
                           AS pass_num
                  FROM ap_document  d
                       JOIN ap_document_attr da
                           ON     da.apda_apd = d.apd_id
                              AND da.apda_ap = p_ap_id
                              AND da.history_status = 'A'
                              AND da.apda_nda IN (2162,
                                                  2163,
                                                  2164,
                                                  2165,
                                                  2166,
                                                  2167,
                                                  2168,
                                                  2169,
                                                  2170,
                                                  2171)
                              AND (   da.apda_val_dt IS NOT NULL
                                   OR da.apda_val_string IS NOT NULL)
                 WHERE     d.apd_ap = p_ap_id
                       AND d.history_status = 'A'
                       AND d.apd_ndt = 741)
        LOOP
            --Тип витягу
            v_clob :=
                REPLACE (v_clob,
                         '#p2162#',
                         (CASE c2.on_curr_dt WHEN 'T' THEN v_check_mark END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p2163#',
                    (CASE c2.on_other_dt WHEN 'T' THEN v_check_mark END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p21641#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 1,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p21642#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 2,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p21643#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 3,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p21644#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 4,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p21645#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 5,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p21646#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 6,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p21647#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 7,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p21648#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 8,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p21649#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 9,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p216410#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 10,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p216411#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 11,
                                 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p216412#',
                    (CASE c2.on_other_dt
                         WHEN 'T'
                         THEN
                             SUBSTR (
                                 TO_CHAR (c2.other_dt, 'DDMMYYYYHH24MISS'),
                                 12,
                                 1)
                     END));

            --Критерії пошуку відомостей
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p2165#',
                    (CASE c2.is_fiz_pers WHEN 'T' THEN v_check_mark END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#p7#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T'
                         THEN
                                c2.last_name
                             || ' '
                             || c2.first_name
                             || ' '
                             || c2.middle_name
                     END));
            v_clob :=
                REPLACE (v_clob, '#p21691#', SUBSTR (c2.numident, 1, 1));
            v_clob :=
                REPLACE (v_clob, '#p21692#', SUBSTR (c2.numident, 2, 1));
            v_clob :=
                REPLACE (v_clob, '#p21693#', SUBSTR (c2.numident, 3, 1));
            v_clob :=
                REPLACE (v_clob, '#p21694#', SUBSTR (c2.numident, 4, 1));
            v_clob :=
                REPLACE (v_clob, '#p21695#', SUBSTR (c2.numident, 5, 1));
            v_clob :=
                REPLACE (v_clob, '#p21696#', SUBSTR (c2.numident, 6, 1));
            v_clob :=
                REPLACE (v_clob, '#p21697#', SUBSTR (c2.numident, 7, 1));
            v_clob :=
                REPLACE (v_clob, '#p21698#', SUBSTR (c2.numident, 8, 1));
            v_clob :=
                REPLACE (v_clob, '#p21699#', SUBSTR (c2.numident, 9, 1));
            v_clob :=
                REPLACE (v_clob, '#p216910#', SUBSTR (c2.numident, 10, 1));
            v_clob :=
                REPLACE (v_clob, '#p21701#', SUBSTR (c2.pass_seria, 1, 1));
            v_clob :=
                REPLACE (v_clob, '#p21702#', SUBSTR (c2.pass_seria, 2, 1));
            v_clob :=
                REPLACE (v_clob, '#p21711#', SUBSTR (c2.pass_num, 1, 1));
            v_clob :=
                REPLACE (v_clob, '#p21712#', SUBSTR (c2.pass_num, 2, 1));
            v_clob :=
                REPLACE (v_clob, '#p21713#', SUBSTR (c2.pass_num, 3, 1));
            v_clob :=
                REPLACE (v_clob, '#p21714#', SUBSTR (c2.pass_num, 4, 1));
            v_clob :=
                REPLACE (v_clob, '#p21715#', SUBSTR (c2.pass_num, 5, 1));
            v_clob :=
                REPLACE (v_clob, '#p21716#', SUBSTR (c2.pass_num, 6, 1));

            --пошук надавача соціальних послуг
            v_rnspm_id :=
                uss_rnsp.api$find.get_nsp (
                    p_rnsps_last_name     => c2.last_name,
                    p_rnsps_first_name    => c2.first_name,
                    p_rnsps_middle_name   => c2.middle_name,
                    p_rnsps_numident      => c2.numident,
                    p_rnsps_pass_seria    => c2.pass_seria,
                    p_rnsps_pass_num      => c2.pass_num,
                    p_is_fiz_pers         =>
                        (CASE c2.is_fiz_pers WHEN 'T' THEN 1 ELSE 0 END),
                    p_max_date_in         =>
                        (CASE
                             WHEN c2.on_curr_dt = 'T' THEN v_curr_dt
                             WHEN c2.on_other_dt = 'T' THEN c2.other_dt
                         END));

            --отримання атрибутів надавача соціальних послуг
            IF v_rnspm_id IS NOT NULL
            THEN
                uss_rnsp.api$find.get_nsp_attr (
                    p_rnspm_id                    => v_rnspm_id,
                    p_rnsps_last_name             => v_rnsps_last_name,
                    p_rnsps_first_name            => v_rnsps_first_name,
                    p_rnsps_middle_name           => v_rnsps_middle_name,
                    p_rnsps_numident              => v_rnsps_numident,
                    p_rnsps_is_numident_missing   =>
                        v_rnsps_is_numident_missing,
                    p_rnsps_pass_seria            => v_rnsps_pass_seria,
                    p_rnsps_pass_num              => v_rnsps_pass_num);
            END IF;

            --надавач соціальних послуг - фізична особа
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_last_name#',
                    (CASE c2.is_fiz_pers WHEN 'T' THEN v_rnsps_last_name END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_first_name#',
                    (CASE c2.is_fiz_pers WHEN 'T' THEN v_rnsps_first_name END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_middle_name#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN v_rnsps_middle_name
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident1#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 1, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident2#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 2, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident3#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 3, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident4#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 4, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident5#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 5, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident6#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 6, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident7#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 7, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident8#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 8, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident9#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 9, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#fiz_rnsps_numident10#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_numident, 10, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_is_numident_missing#',
                    (CASE
                         WHEN     c2.is_fiz_pers = 'T'
                              AND v_rnsps_is_numident_missing = 'T'
                         THEN
                             v_check_mark
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_pass_seria1#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_pass_seria, 1, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_pass_seria2#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_pass_seria, 2, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_pass_num1#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_pass_num, 1, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_pass_num2#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_pass_num, 2, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_pass_num3#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_pass_num, 3, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_pass_num4#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_pass_num, 4, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_pass_num5#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_pass_num, 5, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#rnsps_pass_num6#',
                    (CASE c2.is_fiz_pers
                         WHEN 'T' THEN SUBSTR (v_rnsps_pass_num, 6, 1)
                     END));

            --надавач соціальних послуг - юридична особа
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_last_name#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             v_rnsps_last_name
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident1#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 1, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident2#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 2, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident3#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 3, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident4#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 4, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident5#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 5, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident6#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 6, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident7#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 7, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident8#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 8, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident9#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 9, 1)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#jur_rnsps_numident10#',
                    (CASE
                         WHEN COALESCE (c2.is_fiz_pers, 'F') = 'F'
                         THEN
                             SUBSTR (v_rnsps_numident, 10, 1)
                     END));
        END LOOP;

        --Отримувачі соціальних послуг
        FOR c3
            IN (SELECT param_name, param_val
                  FROM (SELECT COUNT (
                                   CASE da.apda_nda
                                       WHEN 2194 THEN da.apda_id
                                   END)      AS p2194,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2211 THEN da.apda_id
                                   END)      AS p2211,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2195 THEN da.apda_id
                                   END)      AS p2195,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2196 THEN da.apda_id
                                   END)      AS p2196,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 660 THEN da.apda_id
                                   END)      AS p660,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2197 THEN da.apda_id
                                   END)      AS p2197,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2198 THEN da.apda_id
                                   END)      AS p2198,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2199 THEN da.apda_id
                                   END)      AS p2199,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2207 THEN da.apda_id
                                   END)      AS p2207,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2208 THEN da.apda_id
                                   END)      AS p2208,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2210 THEN da.apda_id
                                   END)      AS p2210,
                                 COUNT (
                                     CASE da.apda_nda
                                         WHEN 1801 THEN da.apda_id
                                     END)
                               + COUNT (
                                     CASE da.apda_nda
                                         WHEN 1802 THEN da.apda_id
                                     END)    AS p32,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2206 THEN da.apda_id
                                   END)      AS p2206,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2200 THEN da.apda_id
                                   END)      AS p2200,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2214 THEN da.apda_id
                                   END)      AS p2214,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2215 THEN da.apda_id
                                   END)      AS p2215,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 1796 THEN da.apda_id
                                   END)      AS p1796,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 1795 THEN da.apda_id
                                   END)      AS p1795,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2203 THEN da.apda_id
                                   END)      AS p2203,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2201 THEN da.apda_id
                                   END)      AS p2201,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2202 THEN da.apda_id
                                   END)      AS p2202,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 1862 THEN da.apda_id
                                   END)      AS p1862,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2216 THEN da.apda_id
                                   END)      AS p2216,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2217 THEN da.apda_id
                                   END)      AS p2217,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2218 THEN da.apda_id
                                   END)      AS p2218,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2219 THEN da.apda_id
                                   END)      AS p2219,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2220 THEN da.apda_id
                                   END)      AS p2220,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2221 THEN da.apda_id
                                   END)      AS p2221,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2222 THEN da.apda_id
                                   END)      AS p2222,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2223 THEN da.apda_id
                                   END)      AS p2223,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2224 THEN da.apda_id
                                   END)      AS p2224,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2225 THEN da.apda_id
                                   END)      AS p2225,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2226 THEN da.apda_id
                                   END)      AS p2226,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2204 THEN da.apda_id
                                   END)      AS p2204,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2205 THEN da.apda_id
                                   END)      AS p2205,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2209 THEN da.apda_id
                                   END)      AS p2209,
                               COUNT (
                                   CASE da.apda_nda
                                       WHEN 2236 THEN da.apda_id
                                   END)      AS p2236
                          FROM ap_person  pz
                               JOIN ap_person p
                                   ON (    p.app_ap != p_ap_id
                                       AND pz.app_sc = p.app_sc
                                       AND p.history_status = 'A')
                               JOIN appeal ap
                                   ON (    ap.ap_id = p.app_ap
                                       AND ap.ap_tp = 'SS')
                               JOIN act t
                                   ON (    t.at_ap = ap.ap_id
                                       AND t.at_st IN ('SA', 'O.SA'))
                               JOIN at_features f ON (f.atf_at = t.at_id)
                               JOIN ap_document d
                                   ON (    d.apd_ap = t.at_ap
                                       AND d.history_status = 'A'
                                       AND d.apd_ndt = 605)
                               JOIN ap_document_attr da
                                   ON (    da.apda_apd = d.apd_id
                                       AND da.apda_ap = t.at_ap
                                       AND da.history_status = 'A'
                                       AND da.apda_val_string = 'T')
                         WHERE     pz.app_ap = p_ap_id
                               AND p.history_status = 'A'
                               AND f.atf_nft = 9
                               AND f.atf_val_id = v_rnspm_id)
                           UNPIVOT (param_val
                               FOR param_name
                               IN (p2194,
                                   p2211,
                                   p2195,
                                   p2196,
                                   p660,
                                   p2197,
                                   p2198,
                                   p2199,
                                   p2207,
                                   p2208,
                                   p2210,
                                   p32,
                                   p2206,
                                   p2200,
                                   p2214,
                                   p2215,
                                   p1796,
                                   p1795,
                                   p2203,
                                   p2201,
                                   p2202,
                                   p1862,
                                   p2216,
                                   p2217,
                                   p2218,
                                   p2219,
                                   p2220,
                                   p2221,
                                   p2222,
                                   p2223,
                                   p2224,
                                   p2225,
                                   p2226,
                                   p2204,
                                   p2205,
                                   p2209,
                                   p2236)))
        LOOP
            v_clob :=
                REPLACE (v_clob,
                         '#' || LOWER (c3.param_name) || '#',
                         (CASE WHEN c3.param_val > 0 THEN v_check_mark END));
        END LOOP;

        --Відомості про спосіб видачі витягу
        FOR c4
            IN (  SELECT da.apda_nda,
                         TRIM (
                             CASE pt.pt_data_type
                                 WHEN 'STRING'
                                 THEN
                                     dnet$rpt_annex.get_dict_val (
                                         pt.pt_ndc,
                                         NULL,
                                         da.apda_val_string)
                                 WHEN 'ID'
                                 THEN
                                     dnet$rpt_annex.get_dict_val (
                                         pt.pt_ndc,
                                         da.apda_val_id,
                                         NULL)
                                 WHEN 'DATE'
                                 THEN
                                     TO_CHAR (da.apda_val_dt,
                                              'DD.MM.YYYY HH24:MI:SS')
                                 WHEN 'INTEGER'
                                 THEN
                                     TO_CHAR (da.apda_val_int)
                                 WHEN 'SUM'
                                 THEN
                                     TO_CHAR (da.apda_val_sum,
                                              'FM9G999G999G999G999G990D00',
                                              'NLS_NUMERIC_CHARACTERS=''.''''')
                             END)    AS nda_val
                    FROM v_ap_document d
                         JOIN v_ap_document_attr da
                             ON     da.apda_apd = d.apd_id
                                AND da.apda_ap = p_ap_id
                                AND da.history_status = 'A'
                         JOIN uss_ndi.v_ndi_document_attr dat
                             ON dat.nda_id = da.apda_nda AND dat.nda_ndt = 741
                         JOIN uss_ndi.v_ndi_param_type pt
                             ON pt.pt_id = dat.nda_pt
                   WHERE     d.apd_ap = p_ap_id
                         AND d.history_status = 'A'
                         AND d.apd_ndt = 741
                ORDER BY dat.nda_order)
        LOOP
            IF c4.apda_nda IN (2183, 2184)
            THEN
                CASE c4.apda_nda
                    WHEN 2183
                    THEN
                        v_nda_2183 := c4.nda_val;
                    WHEN 2184
                    THEN
                        v_nda_2184 := c4.nda_val;
                    ELSE
                        NULL;
                END CASE;
            ELSIF c4.apda_nda IN (2187, 2188)
            THEN
                v_param_73 :=
                    (CASE c4.apda_nda
                         WHEN 2187 THEN c4.nda_val || v_param_73
                         ELSE v_param_73 || ' ' || c4.nda_val
                     END);
            ELSE
                v_clob :=
                    REPLACE (
                        v_clob,
                        '#p' || TO_CHAR (c4.apda_nda) || '#',
                        (CASE
                             WHEN c4.apda_nda IN (2172, 2173, 2174)
                             THEN
                                 (CASE c4.nda_val
                                      WHEN 'T' THEN v_check_mark
                                  END)
                             ELSE
                                 c4.nda_val
                         END));
            END IF;
        END LOOP;

        v_clob :=
            REPLACE (v_clob,
                     '#p70#',
                     COALESCE (TRIM (v_nda_2184), TRIM (v_nda_2183))); -- пріоритет значень "Вулиця"
        v_clob := REPLACE (v_clob, '#p73#', TRIM (v_param_73));

        -- ЗАГЛУШКА БО ТЕГИ НІКУДИ НЕ ДІЛИСЬ
        v_clob := REPLACE (v_clob, '#p2172#', '');
        v_clob := REPLACE (v_clob, '#p2173#', '');
        v_clob := REPLACE (v_clob, '#p2174#', '');
        v_clob := REPLACE (v_clob, '#p2175#', '');
        v_clob := REPLACE (v_clob, '#p2176#', '');
        v_clob := REPLACE (v_clob, '#p2177#', '');
        v_clob := REPLACE (v_clob, '#p2178#', '');
        v_clob := REPLACE (v_clob, '#p2179#', '');
        v_clob := REPLACE (v_clob, '#p2180#', '');
        v_clob := REPLACE (v_clob, '#p2181#', '');
        v_clob := REPLACE (v_clob, '#p2182#', '');
        v_clob := REPLACE (v_clob, '#p2185#', '');
        v_clob := REPLACE (v_clob, '#p2186#', '');
        v_clob := REPLACE (v_clob, '#p2189#', '');


        p_blob := tools.convertc2b (v_clob);
        p_is_error := 'F';
        p_doc_name := get_filename_by_code ('ANNEX_8_R1');
    --при виникненні помилки повертаєтся файл із поясненням та помилкою
    EXCEPTION
        WHEN OTHERS
        THEN
            p_is_error := 'T';
            p_doc_name := get_filename_by_code ('ANNEX_8_R1');
            p_blob :=
                tools.convertc2b (
                    TO_CLOB (
                           'Помилка побудови витягу, зверніться до технічної підтримки і після відповіді - повторно сформуйте звернення (функцією копіювання)!'
                        || CHR (10)
                        || SQLERRM));
    END;

    -- info:   збереження файла документа в зверненні
    -- params: p_ap_id - ідентифікатор звернення
    --         p_doc_id - ідентифікатор документа
    --         p_dh_id - ідентифікатор зрізу документа
    -- note:
    PROCEDURE set_app_doc (p_ap_id    IN NUMBER,
                           p_doc_id   IN NUMBER,
                           p_dh_id    IN NUMBER)
    IS
        v_pdo_id   pd_document.pdo_id%TYPE;
    BEGIN
        set_app_doc (p_ap_id,
                     761,
                     741,
                     p_doc_id,
                     p_dh_id);
    END;

    PROCEDURE set_app_doc (p_ap_id    IN NUMBER,
                           p_nst_id   IN NUMBER,
                           p_ndt_id   IN NUMBER,
                           p_doc_id   IN NUMBER,
                           p_dh_id    IN NUMBER)
    IS
        v_pdo_id   pd_document.pdo_id%TYPE;
    BEGIN
        FOR c
            IN (SELECT                                             --d.apd_id,
                       (SELECT MAX (app_id)
                          FROM ap_person z
                         WHERE     z.app_ap = a.ap_id
                               AND z.history_status = 'A'
                               AND z.app_tp = 'Z')             AS apd_app,
                       s.aps_id,
                       (SELECT MAX (dd.pdo_id)
                          FROM pd_document dd
                         WHERE     dd.pdo_ap = p_ap_id
                               AND dd.pdo_ndt = p_ndt_id
                               AND dd.history_status = 'A')    AS pdo_exist
                  FROM appeal  a
                       JOIN v_ap_service s
                           ON     s.aps_ap = p_ap_id
                              AND s.aps_nst = p_nst_id
                              AND s.history_status = 'A' /*
            JOIN v_ap_document d ON d.apd_ap = p_ap_id
                                AND d.apd_ndt = p_ndt_id
                                AND d.history_status = 'A'*/
                 WHERE a.ap_id = p_ap_id AND a.ap_tp = 'D' AND a.ap_st = 'O')
        LOOP
            --видаленння існуючого документа
            IF c.pdo_exist IS NOT NULL
            THEN
                api$documents.delete_pd_document (c.pdo_exist);
            END IF;

            --збереження сформованої довідки
            api$documents.save_pd_document (p_pdo_id   => v_pdo_id,
                                            p_doc_id   => p_doc_id,
                                            p_dh_id    => p_dh_id,
                                            p_ap_id    => p_ap_id,
                                            p_app_id   => c.apd_app,
                                            p_aps_id   => c.aps_id,
                                            p_apd_id   => NULL,
                                            p_ndt_id   => p_ndt_id,
                                            p_pd_id    => NULL,
                                            p_new_id   => v_pdo_id);

            --переведення звернення в виконане
            UPDATE appeal
               SET ap_st = 'V'
             WHERE ap_id = p_ap_id;

            --підготовка до зворотнього копіювання сформованої довідки
            api$esr_action.preparecopy_esr2visit (p_ap_id, 'O', NULL);
        END LOOP;
    END;

    FUNCTION get_inv_group (p_value IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF (p_value IS NULL)
        THEN
            RETURN '';
        ELSIF (p_value = '1B')
        THEN
            RETURN '1Б';
        ELSE
            RETURN p_value;
        END IF;
    END;

    -- info:   отримання blob-файлу звіту довідки 61 / 10372 (результат)
    -- params: p_ap_id - ідентифікатор звернення
    -- note:
    PROCEDURE get_dovidka_61_rpt_blob (p_ap_id      IN     NUMBER,
                                       p_sc_id      IN     NUMBER,
                                       p_is_error      OUT VARCHAR2,
                                       p_doc_name      OUT VARCHAR2,
                                       p_blob          OUT BLOB)
    IS
        l_sc_id    NUMBER := p_sc_id;
        l_jbr_id   NUMBER;
    BEGIN
        IF (l_sc_id IS NULL)
        THEN
            SELECT MAX (app_sc)
              INTO l_sc_id
              FROM ap_person t
             WHERE t.app_ap = p_ap_id AND t.history_status = 'A';
        END IF;

        rdm$rtfl_univ.initreport (p_code     => 'ANNEX_61_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

    FOR xx IN (
      WITH dat AS ( SELECT *
                      FROM uss_person.v_sc_pfu_data_ident d
                     WHERE d.scdi_id = (SELECT MAX(t.scdi_id)
                                          FROM uss_person.v_SC_PFU_DATA_IDENT t
                                         WHERE t.scdi_sc = l_sc_id
                                           AND t.scdi_nrt = 129)
                  )
      SELECT t.*,    -- 22
             a.*,    -- 47
             z.*,    -- 18
             --r.*,    -- 9
             (SELECT MAX(tp.ndt_name_short) FROM uss_ndi.v_ndi_document_type tp WHERE tp.ndt_id = SCDI_DOC_TP) AS SCDI_DOC_TP_name,
             (SELECT MAX(dic_name) FROM uss_ndi.v_ddN_gender g WHERE g.dic_value = SCDI_SEX) AS SCDI_SEX_name,
             (SELECT MAX(dic_name) FROM uss_ndi.V_DDN_SCMA_CAR_PROVISION cp WHERE cp.dic_value = SCMA_IS_CAR_PROVISION) AS SCMA_IS_CAR_PROVISION_name,
             (SELECT LISTAGG(dic_name, ', ') WITHIN GROUP (ORDER BY 1)
                FROM uss_ndi.V_DDN_SCMA_ADD_NEEDS cp
               WHERE cp.dic_value IN (SELECT REGEXP_SUBSTR(text ,'[^(\,)]+', 1, LEVEL)  AS z_rdt_id
                                        FROM (SELECT SCMA_ADD_NEEDS AS text FROM DUAL)
                                     CONNECT BY LENGTH(REGEXP_SUBSTR(text ,'[^(\,)]+', 1, LEVEL)) > 0)
             ) AS SCMA_ADD_NEEDS_name,
             (SELECT LISTAGG(dic_name, ', ') WITHIN GROUP (ORDER BY 1)
                FROM uss_ndi.V_DDN_INV_REASON q
               WHERE q.dic_value IN (SELECT REGEXP_SUBSTR(text ,'[^(\,)]+', 1, LEVEL)  AS z_rdt_id
                                        FROM (SELECT TO_CHAR(SCMA_REASONS) AS text FROM DUAL)
                                     CONNECT BY LENGTH(REGEXP_SUBSTR(text ,'[^(\,)]+', 1, LEVEL)) > 0)
             ) AS SCMA_REASONS_name
        FROM dat t
        JOIN uss_person.v_SC_MOZ_ASSESSMENT a ON (a.scma_scdi = t.scdi_id)
        JOIN uss_person.v_SC_MOZ_ZOZ z ON (z.scmz_scdi = t.scdi_id)
      UNION ALL
        SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL--, null, null
          FROM DUAL
         WHERE NOT EXISTS (SELECT 1
                             FROM dat t
                             JOIN uss_person.v_SC_MOZ_ASSESSMENT a ON (a.scma_scdi = t.scdi_id)
                             JOIN uss_person.v_SC_MOZ_ZOZ z ON (z.scmz_scdi = t.scdi_id)
                           --  join uss_person.v_SC_MOZ_DZR_RECOMM r on (r.scmd_scdi = t.scdi_id)
                           )
    ) LOOP
      rdm$rtfl_univ.AddParam('pc_num', NVL(xx.SCMA_DECISION_NUM, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('pc_date', NVL(TO_CHAR(xx.SCMA_DECISION_DT, 'DD.MM.YYYY'), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('pers_pib', NVL(TRIM(xx.SCDI_LN || ' ' || xx.SCDI_FN || ' ' || xx.SCDI_MN), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('pasp_info', NVL(TRIM(xx.SCDI_DOC_TP_name || ' ' || xx.SCDI_DOC_SN), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('rnokpp', NVL(TO_CHAR(xx.SCDI_NUMIDENT), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('sex', NVL(xx.SCDI_SEX_name, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('eddr', NVL(xx.SCDI_UNZR, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('bday', NVL(TO_CHAR(xx.SCDI_BIRTHDAY, 'DD.MM.YYYY'), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('zoz_name', NVL(CASE WHEN xx.SCMZ_ORG_NAME IS NOT NULL THEN xx.SCMZ_ORG_NAME || '(ЄДРПОУ ' || xx.SCMZ_ORG_ID || ')' END, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('zoz_address', NVL(xx.SCMZ_REGION_NAME || ', ' ||
                                                xx.SCMZ_DISTRICT_NAME || ', ' ||
                                                xx.SCMZ_COMMUNITY_NAME || ', ' ||
                                                xx.SCMZ_CITY_NAME || ', ' ||
                                                xx.SCMZ_STREET_NAME || ', буд. ' ||
                                                xx.SCMZ_BUILDING || ', кв. ' ||
                                                xx.SCMZ_ROOM
                                            , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('date_assess', NVL(TO_CHAR(xx.SCMA_EVAL_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('disability', NVL(get_bool_str(xx.SCMA_IS_GROUP), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_date', NVL(TO_CHAR(xx.SCMA_START_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_group', get_inv_group(xx.SCMA_GROUP));
      rdm$rtfl_univ.AddParam('dis_diagnosis', NVL(xx.SCMA_MAIN_DIAGNOSIS, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_diagnosis1', NVL(xx.SCMA_ADD_DIAGNOSES, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_is_endless', NVL(get_bool_str(xx.SCMA_IS_ENDLESS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_date1', NVL(TO_CHAR(xx.SCMA_END_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_reason', NVL(xx.SCMA_REASONS_name, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_is_prev', NVL(get_bool_str(xx.SCMA_IS_PREV), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('efficiency', NVL(get_bool_str(xx.SCMA_IS_LOSS_PROF_ABILITY), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('eff_date', NVL(TO_CHAR(xx.SCMA_DISEASE_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      --rdm$rtfl_univ.AddParam('eff_date_percent', nvl(to_char(xx.SCML_LOSS_PROF_ABILITY_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      --rdm$rtfl_univ.AddParam('eff_percent', nvl(to_char(xx.SCMA_LOSS_PROF_ABILITY_PERC, 'FM9999999999999990D00999', 'NLS_NUMERIC_CHARACTERS='', '''''), 'Відсутні дані'));
      --rdm$rtfl_univ.AddParam('eff_reason', nvl(xx.SCMA_LOSS_PROF_ABILITY_CAUSE, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('eff_date1', NVL(TO_CHAR(xx.SCMA_REEXAM_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('sick_add', NVL(get_bool_str(xx.SCMA_IS_EXT_TEMP_DIS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('sick_term', NVL(TO_CHAR(xx.SCMA_EXT_TEMP_DIS_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('auto', NVL(get_bool_str(xx.SCMA_IS_CAR_NEEDED), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('auto_pc', NVL(xx.SCMA_IS_CAR_PROVISION_name, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('auto_indication', NVL(get_bool_str(xx.SCMA_IS_MED_IND), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('auto_contr_ind', NVL(get_bool_str(xx.SCMA_IS_MED_CONTR_IND), 'Відсутні дані'));


      rdm$rtfl_univ.AddParam('sanatorium', NVL(get_bool_str(xx.SCMA_IS_SAN_TRTMNT), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('rec_pfu', NVL(get_bool_str(xx.SCMA_IS_PFU_REC), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('rec_oszn', NVL(get_bool_str(xx.SCMA_IS_OSZN_REC), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('soc_rehab', NVL(get_bool_str(xx.SCMA_IS_SOC_REHAB), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('incl_res', NVL(get_bool_str(xx.SCMA_IS_PSYCHOLOG_REC), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('psychol_rehab', NVL(get_bool_str(xx.SCMA_IS_PSYCHOLOG_REHAB), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('workplace', NVL(get_bool_str(xx.SCMA_IS_WORKPLACE_ARRGMNT), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('rec_employ', NVL(get_bool_str(xx.SCMA_IS_JOB_CENTER_REC), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('gen_restrict', NVL(get_bool_str(xx.SCMA_IS_PROF_LIMITS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('labor_rehab', NVL(get_bool_str(xx.SCMA_IS_PROF_REHAB), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('need_training', NVL(get_bool_str(xx.SCMA_IS_SPORTS_SKILLS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('need_sport', NVL(get_bool_str(xx.SCMA_IS_SPORTS_TRAININGS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('add_needs', NVL(xx.SCMA_ADD_NEEDS_name, 'Відсутні дані'));

      rdm$rtfl_univ.AddDataset('ds', q'[
        with dat as ( SELECT *
                        FROM uss_person.v_sc_pfu_data_ident d
                       where d.scdi_id = (SELECT max(t.scdi_id)
                                            FROM uss_person.v_SC_PFU_DATA_IDENT t
                                           where t.scdi_sc = ]'|| l_sc_id || q'[
                                             and t.scdi_nrt = 129)
                    )
        SELECT SCMD_DZR_NAME as dzr_name,
               SCMD_ISO_CODE as dzr_iso
          FROM dat t
          join uss_person.v_SC_MOZ_DZR_RECOMM r on (r.scmd_scdi = t.scdi_id)
        ]');

      rdm$rtfl_univ.AddDataset('ds1', q'[
        with dat as ( SELECT *
                        FROM uss_person.v_sc_pfu_data_ident d
                       where d.scdi_id = (SELECT max(t.scdi_id)
                                            FROM uss_person.v_SC_PFU_DATA_IDENT t
                                           where t.scdi_sc = ]'|| l_sc_id || q'[
                                             and t.scdi_nrt = 129)
                    )
        SELECT m.dic_name as med_name,
               to_char(SCMM_MED_NEEDED_DT, 'DD.MM.YYYY')  as med_termin,
               uss_esr.tools.QNT_TO_TEXT(SCMM_MED_QTY) as med_qty
          FROM dat t
          join uss_person.v_SC_MOZ_MED_DATA_RECOMM r on (r.scmm_scdi = t.scdi_id)
          left join uss_ndi.V_DDN_SCMM_MED m on (dic_value = SCMM_MED_NAME)
        ]');

      rdm$rtfl_univ.AddDataset('ds2', q'[
        with dat as ( SELECT *
                        FROM uss_person.v_sc_pfu_data_ident d
                       where d.scdi_id = (SELECT max(t.scdi_id)
                                            FROM uss_person.v_SC_PFU_DATA_IDENT t
                                           where t.scdi_sc = ]'|| l_sc_id || q'[
                                             and t.scdi_nrt = 129)
                    )
        SELECT nvl(to_char(scml_loss_prof_ability_dt , 'DD.MM.YYYY') , 'Відсутні дані') as eff_date_percent,
               nvl(to_char(SCMl_LOSS_PROF_ABILITY_PERC, 'FM9999999999999990D00999', 'NLS_NUMERIC_CHARACTERS='', '''''), 'Відсутні дані') as eff_percent,
               nvl(l.dic_name, 'Відсутні дані') as eff_reason
          FROM dat t
          join uss_person.v_sc_moz_LOSS_prof_ability r on (r.scml_scdi  = t.scdi_id)
          left join uss_ndi.V_DDN_SCMA_LPAC l on (l.dic_value = r.SCMl_LOSS_PROF_ABILITY_CAUSE)
        ]');
    END LOOP;

        --p_blob     := tools.convertc2b(v_clob);
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => p_blob);
        p_is_error := 'F';
        p_doc_name := get_filename_by_code ('ANNEX_61_R1');
    --при виникненні помилки повертаєтся файл із поясненням та помилкою
    EXCEPTION
        WHEN OTHERS
        THEN
            p_is_error := 'T';
            p_doc_name := get_filename_by_code ('ANNEX_61_R1');
            p_blob :=
                tools.convertc2b (
                    TO_CLOB (
                           'Помилка побудови витягу, зверніться до технічної підтримки і після відповіді - повторно сформуйте звернення (функцією копіювання)!'
                        || CHR (10)
                        || SQLERRM));
    END;

    -- info:   отримання blob-файлу звіту довідки 101 / 10374 (результат)
    -- params: p_ap_id - ідентифікатор звернення
    -- note:
    PROCEDURE get_dovidka_101_rpt_blob (p_ap_id      IN     NUMBER,
                                        p_is_error      OUT VARCHAR2,
                                        p_doc_name      OUT VARCHAR2,
                                        p_blob          OUT BLOB)
    IS
        l_sc_id    NUMBER;
        l_jbr_id   NUMBER;
    BEGIN
        SELECT MAX (app_sc)
          INTO l_sc_id
          FROM ap_person t
         WHERE t.app_ap = p_ap_id AND t.history_status = 'A';

        rdm$rtfl_univ.initreport (p_code     => 'ANNEX_101_R1',
                                  p_bld_tp   => rdm$rtfl_univ.c_bld_tp_db);

    FOR xx IN (
      WITH dat AS ( SELECT *

                      FROM uss_person.v_sc_pfu_data_ident d
                     WHERE d.scdi_id = (SELECT MAX(t.scdi_id)
                                          FROM uss_person.v_SC_PFU_DATA_IDENT t
                                         WHERE t.scdi_sc = l_sc_id
                                           AND t.scdi_nrt = 129)
                  )
      SELECT t.*,    -- 22
             a.*,    -- 47
             z.*,    -- 18
             --r.*,    -- 9
             (SELECT MAX(tp.ndt_name_short) FROM uss_ndi.v_ndi_document_type tp WHERE tp.ndt_id = SCDI_DOC_TP) AS SCDI_DOC_TP_name,
             (SELECT MAX(dic_name) FROM uss_ndi.v_ddN_gender g WHERE g.dic_value = SCDI_SEX) AS SCDI_SEX_name,
             (SELECT MAX(dic_name) FROM uss_ndi.V_DDN_SCMA_CAR_PROVISION cp WHERE cp.dic_value = SCMA_IS_CAR_PROVISION) AS SCMA_IS_CAR_PROVISION_name,
             (SELECT LISTAGG(dic_name, ', ') WITHIN GROUP (ORDER BY 1)
                FROM uss_ndi.V_DDN_SCMA_ADD_NEEDS cp
               WHERE cp.dic_value IN (SELECT REGEXP_SUBSTR(text ,'[^(\,)]+', 1, LEVEL)  AS z_rdt_id
                                        FROM (SELECT SCMA_ADD_NEEDS AS text FROM DUAL)
                                     CONNECT BY LENGTH(REGEXP_SUBSTR(text ,'[^(\,)]+', 1, LEVEL)) > 0)
             ) AS SCMA_ADD_NEEDS_name,
             (SELECT LISTAGG(dic_name, ', ') WITHIN GROUP (ORDER BY 1)
                FROM uss_ndi.V_DDN_INV_REASON cp
               WHERE cp.dic_value IN (SELECT REGEXP_SUBSTR(text ,'[^(\,)]+', 1, LEVEL)  AS z_rdt_id
                                        FROM (SELECT TO_CHAR(SCMA_REASONS) AS text FROM DUAL)
                                     CONNECT BY LENGTH(REGEXP_SUBSTR(text ,'[^(\,)]+', 1, LEVEL)) > 0)
             ) AS SCMA_REASONS_name
        FROM dat t
        JOIN uss_person.v_SC_MOZ_ASSESSMENT a ON (a.scma_scdi = t.scdi_id)
        JOIN uss_person.v_SC_MOZ_ZOZ z ON (z.scmz_scdi = t.scdi_id)
      UNION ALL
        SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
               NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL--, null, null
          FROM DUAL
         WHERE NOT EXISTS (SELECT 1
                             FROM dat t
                             JOIN uss_person.v_SC_MOZ_ASSESSMENT a ON (a.scma_scdi = t.scdi_id)
                             JOIN uss_person.v_SC_MOZ_ZOZ z ON (z.scmz_scdi = t.scdi_id)
                       --      join uss_person.v_SC_MOZ_DZR_RECOMM r on (r.scmd_scdi = t.scdi_id)
                           )
    ) LOOP
      rdm$rtfl_univ.AddParam('pc_num', NVL(xx.SCMA_DECISION_NUM, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('pc_date', NVL(TO_CHAR(xx.SCMA_DECISION_DT, 'DD.MM.YYYY'), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('pers_pib', NVL(TRIM(xx.SCDI_LN || ' ' || xx.SCDI_FN || ' ' || xx.SCDI_MN), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('pasp_info', NVL(TRIM(xx.SCDI_DOC_TP_name || ' ' || xx.SCDI_DOC_SN), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('rnokpp', NVL(TO_CHAR(xx.SCDI_NUMIDENT), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('sex', NVL(xx.SCDI_SEX_name, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('eddr', NVL(xx.SCDI_UNZR, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('bday', NVL(TO_CHAR(xx.SCDI_BIRTHDAY, 'DD.MM.YYYY'), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('zoz_name', NVL(CASE WHEN xx.SCMZ_ORG_NAME IS NOT NULL THEN xx.SCMZ_ORG_NAME || '(ЄДРПОУ ' || xx.SCMZ_ORG_ID || ')' END, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('zoz_address', NVL(xx.SCMZ_REGION_NAME || ', ' ||
                                                xx.SCMZ_DISTRICT_NAME || ', ' ||
                                                xx.SCMZ_COMMUNITY_NAME || ', ' ||
                                                xx.SCMZ_CITY_NAME || ', ' ||
                                                xx.SCMZ_STREET_NAME || ', буд. ' ||
                                                xx.SCMZ_BUILDING || ', кв. ' ||
                                                xx.SCMZ_ROOM
                                            , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('date_assess', NVL(TO_CHAR(xx.SCMA_EVAL_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('disability', NVL(get_bool_str(xx.SCMA_IS_GROUP), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_date', NVL(TO_CHAR(xx.SCMA_START_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_group', get_inv_group(xx.Scma_Group));
      rdm$rtfl_univ.AddParam('dis_diagnosis', NVL(xx.SCMA_MAIN_DIAGNOSIS, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_diagnosis1', NVL(xx.SCMA_ADD_DIAGNOSES, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_is_endless', NVL(get_bool_str(xx.SCMA_IS_ENDLESS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_date1', NVL(TO_CHAR(xx.SCMA_END_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_reason', NVL(xx.SCMA_REASONS_name, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('dis_is_prev', NVL(get_bool_str(xx.SCMA_IS_PREV), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('efficiency', NVL(get_bool_str(xx.SCMA_IS_LOSS_PROF_ABILITY), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('eff_date', NVL(TO_CHAR(xx.SCMA_DISEASE_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      --rdm$rtfl_univ.AddParam('eff_date_percent', nvl(to_char(xx.SCMA_LOSS_PROF_ABILITY_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      --rdm$rtfl_univ.AddParam('eff_percent', nvl(to_char(xx.SCMA_LOSS_PROF_ABILITY_PERC, 'FM9999999999999990D00999', 'NLS_NUMERIC_CHARACTERS='', '''''), 'Відсутні дані'));
      --rdm$rtfl_univ.AddParam('eff_reason', nvl(xx.SCMA_LOSS_PROF_ABILITY_CAUSE, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('eff_date1', NVL(TO_CHAR(xx.SCMA_REEXAM_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('sick_add', NVL(get_bool_str(xx.SCMA_IS_EXT_TEMP_DIS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('sick_term', NVL(TO_CHAR(xx.SCMA_EXT_TEMP_DIS_DT, 'DD.MM.YYYY') , 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('auto', NVL(get_bool_str(xx.SCMA_IS_CAR_NEEDED), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('auto_pc', NVL(xx.Scma_Is_Car_Provision_Name, 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('auto_indication', NVL(get_bool_str(xx.SCMA_IS_MED_IND), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('auto_contr_ind', NVL(get_bool_str(xx.SCMA_IS_MED_CONTR_IND), 'Відсутні дані'));


      rdm$rtfl_univ.AddParam('sanatorium', NVL(get_bool_str(xx.SCMA_IS_SAN_TRTMNT), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('rec_pfu', NVL(get_bool_str(xx.SCMA_IS_PFU_REC), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('rec_oszn', NVL(get_bool_str(xx.SCMA_IS_OSZN_REC), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('soc_rehab', NVL(get_bool_str(xx.SCMA_IS_SOC_REHAB), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('incl_res', NVL(get_bool_str(xx.SCMA_IS_PSYCHOLOG_REC), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('psychol_rehab', NVL(get_bool_str(xx.SCMA_IS_PSYCHOLOG_REHAB), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('workplace', NVL(get_bool_str(xx.SCMA_IS_WORKPLACE_ARRGMNT), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('rec_employ', NVL(get_bool_str(xx.SCMA_IS_JOB_CENTER_REC), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('gen_restrict', NVL(get_bool_str(xx.SCMA_IS_PROF_LIMITS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('labor_rehab', NVL(get_bool_str(xx.SCMA_IS_PROF_REHAB), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('need_training', NVL(get_bool_str(xx.SCMA_IS_SPORTS_SKILLS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('need_sport', NVL(get_bool_str(xx.SCMA_IS_SPORTS_TRAININGS), 'Відсутні дані'));
      rdm$rtfl_univ.AddParam('add_needs', NVL(xx.Scma_Add_Needs_Name, 'Відсутні дані'));

      rdm$rtfl_univ.AddDataset('ds', q'[
        with dat as ( SELECT *
                        FROM uss_person.v_sc_pfu_data_ident d
                       where d.scdi_id = (SELECT max(t.scdi_id)
                                            FROM uss_person.v_SC_PFU_DATA_IDENT t
                                           where t.scdi_sc = ]'|| l_sc_id || q'[
                                             and t.scdi_nrt = 129)
                    )
        SELECT SCMD_DZR_NAME as dzr_name,
               SCMD_ISO_CODE as dzr_iso
          FROM dat t
          join uss_person.v_SC_MOZ_DZR_RECOMM r on (r.scmd_scdi = t.scdi_id)
        ]');

      rdm$rtfl_univ.AddDataset('ds1', q'[
        with dat as ( SELECT *
                        FROM uss_person.v_sc_pfu_data_ident d
                       where d.scdi_id = (SELECT max(t.scdi_id)
                                            FROM uss_person.v_SC_PFU_DATA_IDENT t
                                           where t.scdi_sc = ]'|| l_sc_id || q'[
                                             and t.scdi_nrt = 129)
                    )
        SELECT m.dic_name as med_name,
               to_char(SCMM_MED_NEEDED_DT, 'DD.MM.YYYY')  as med_termin,
               uss_esr.tools.QNT_TO_TEXT(SCMM_MED_QTY) as med_qty
          FROM dat t
          join uss_person.v_SC_MOZ_MED_DATA_RECOMM r on (r.scmm_scdi = t.scdi_id)
          left join uss_ndi.V_DDN_SCMM_MED m on (dic_value = SCMM_MED_NAME)
        ]');

      rdm$rtfl_univ.AddDataset('ds2', q'[
        with dat as ( SELECT *
                        FROM uss_person.v_sc_pfu_data_ident d
                       where d.scdi_id = (SELECT max(t.scdi_id)
                                            FROM uss_person.v_SC_PFU_DATA_IDENT t
                                           where t.scdi_sc = ]'|| l_sc_id || q'[
                                             and t.scdi_nrt = 129)
                    )
        SELECT nvl(to_char(scml_loss_prof_ability_dt , 'DD.MM.YYYY') , 'Відсутні дані') as eff_date_percent,
               nvl(to_char(SCMl_LOSS_PROF_ABILITY_PERC, 'FM9999999999999990D00999', 'NLS_NUMERIC_CHARACTERS='', '''''), 'Відсутні дані') as eff_percent,
               nvl(l.dic_name, 'Відсутні дані') as eff_reason
          FROM dat t
          join uss_person.v_sc_moz_LOSS_prof_ability r on (r.scml_scdi  = t.scdi_id)
          left join uss_ndi.V_DDN_SCMA_LPAC l on (l.dic_value = r.SCMl_LOSS_PROF_ABILITY_CAUSE)
        ]');
    END LOOP;

        --p_blob     := tools.convertc2b(v_clob);
        rdm$rtfl_univ.get_report_result (p_jbr_id     => l_jbr_id,
                                         p_rpt_blob   => p_blob);
        p_is_error := 'F';
        p_doc_name := get_filename_by_code ('ANNEX_101_R1');
    --при виникненні помилки повертаєтся файл із поясненням та помилкою
    EXCEPTION
        WHEN OTHERS
        THEN
            p_is_error := 'T';
            p_doc_name := get_filename_by_code ('ANNEX_101_R1');
            p_blob :=
                tools.convertc2b (
                    TO_CLOB (
                           'Помилка побудови витягу, зверніться до технічної підтримки і після відповіді - повторно сформуйте звернення (функцією копіювання)!'
                        || CHR (10)
                        || SQLERRM));
    END;

    PROCEDURE get_app_rpt_blob (p_ap_id      IN     NUMBER,
                                p_nst_id     IN     NUMBER,
                                p_is_error      OUT VARCHAR2,
                                p_doc_name      OUT VARCHAR2,
                                p_blob          OUT BLOB)
    IS
    BEGIN
        IF (p_nst_id IN (61))
        THEN
            get_dovidka_61_rpt_blob (p_ap_id,
                                     NULL,
                                     p_is_error,
                                     p_doc_name,
                                     p_blob);
        ELSIF (p_nst_id IN (101))
        THEN
            get_dovidka_101_rpt_blob (p_ap_id,
                                      p_is_error,
                                      p_doc_name,
                                      p_blob);
        ELSE
            p_is_error := 'T';
            p_doc_name := NULL;
            p_blob :=
                tools.convertc2b (
                    TO_CLOB (
                           'Помилка побудови витягу, зверніться до технічної підтримки і після відповіді - повторно сформуйте звернення (функцією копіювання)! '
                        || 'Не зареєстровано функцію побудови звіту!'));
        END IF;
    END;
BEGIN
    NULL;
END;
/