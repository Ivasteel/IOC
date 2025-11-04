/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$RNSP_REPORTS
IS
    -- Author  : LEV
    -- Created : 27.04.2022 18:05:28
    -- Purpose : Робота зі звітами

    -- info:   отримання списку звернень для підготовки звіту
    -- params:
    -- note:
    PROCEDURE get_app_list (p_res_cur OUT SYS_REFCURSOR);

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

    FUNCTION REESTR_RNSP
        RETURN DECIMAL;

    PROCEDURE register_report (p_rt_id      IN     NUMBER,
                               p_rnspm_id   IN     NUMBER,
                               p_start_dt   IN     DATE,
                               p_stop_dt    IN     DATE,
                               p_jbr_id        OUT DECIMAL);
END;
/


GRANT EXECUTE ON USS_RNSP.DNET$RNSP_REPORTS TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.DNET$RNSP_REPORTS TO II01RC_USS_RNSP_WEB
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.DNET$RNSP_REPORTS
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

    -- info:   отримання списку звернень для підготовки звіту
    -- params:
    -- note:
    PROCEDURE get_app_list (p_res_cur OUT SYS_REFCURSOR)
    IS
        l_blob   BLOB := NULL;
        l_id     NUMBER (14, 0) := 0;
    BEGIN
        --tools.WriteMsg('DNET$RNSP_REPORTS.'||utl_call_stack.subprogram(1)(2) );
        OPEN p_res_cur FOR
            SELECT a.ap_id,
                   a.ap_id     AS p_ap_id,
                   l_blob      AS p_file,
                   l_id        AS p_doc_id,
                   l_id        AS p_dh_id,
                   ''          AS p_doc_name,
                   ''          AS p_is_error
              FROM v_appeal  a
                   JOIN v_ap_service s
                       ON     s.aps_ap = a.ap_id
                          AND s.aps_nst = 701
                          AND s.history_status = 'A'
                   JOIN v_ap_document d
                       ON     d.apd_ap = a.ap_id
                          AND d.apd_ndt = 740
                          AND d.history_status = 'A'
             WHERE a.ap_tp = 'D' AND a.ap_st = 'S';
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

            v_sql := REPLACE (v_sql, 'and rownum <=', ' and -1 != ');

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

    FUNCTION Get_Ap_Doc_Atr_Str (p_Ap_Id   NUMBER,
                                 p_Nda     NUMBER,
                                 p_App     NUMBER:= NULL)
        RETURN VARCHAR2
    IS
        CURSOR Cur IS
            SELECT a.Apda_Val_String
              FROM Ap_Document d, Ap_Document_Attr a
             WHERE     d.Apd_Ap = p_Ap_Id
                   AND d.History_Status = 'A'
                   AND d.Apd_App = NVL (p_App, d.Apd_App)
                   AND a.Apda_Apd = d.Apd_Id
                   AND a.Apda_Nda = p_Nda
                   AND a.History_Status = 'A';

        r   Ap_Document_Attr.Apda_Val_String%TYPE;
    BEGIN
        OPEN Cur;

        FETCH Cur INTO r;

        CLOSE Cur;

        RETURN r;
    END;

    -- info:   отримання blob-файлу звіту для звернення
    -- params: p_ap_id - ідентифікатор звернення
    -- note:
    PROCEDURE get_app_rpt_blob (p_ap_id      IN     NUMBER,
                                p_is_error      OUT VARCHAR2,
                                p_doc_name      OUT VARCHAR2,
                                p_blob          OUT BLOB)
    IS
        v_clob        CLOB
            := tools.convertb2c (get_template_by_code ('ANNEX_7_R1'));
        v_ap_num      appeal.ap_num%TYPE;
        v_ap_reg_dt   DATE;
        v_nda_1715    VARCHAR2 (4000);
        v_nda_1716    VARCHAR2 (4000);
        v_nda_1717    VARCHAR2 (4000);
        v_nda_1718    VARCHAR2 (4000);
        v_nda_1719    VARCHAR2 (4000);
        v_nda_1720    VARCHAR2 (4000);
        v_nda_1721    VARCHAR2 (4000);
        v_nda_1722    VARCHAR2 (4000);
        v_nda_1723    VARCHAR2 (4000);
        v_nda_1724    VARCHAR2 (4000);
        v_nda_1725    VARCHAR2 (4000);
        v_nda_1726    VARCHAR2 (4000);
        v_nda_1727    VARCHAR2 (4000);
        v_nda_1740    VARCHAR2 (4000);
        v_nda_2161    VARCHAR2 (4000);
        v_field_58    VARCHAR2 (4000);
        v_curr_dt     DATE := SYSDATE;
        v_reg_wu      VARCHAR2 (4000);
        v_user_pib    VARCHAR2 (4000);
        v21           VARCHAR2 (4000);
        v22           VARCHAR2 (4000);
        v43           VARCHAR2 (32000);
        l_hs          NUMBER;
    BEGIN
        l_hs := tools.GetHistSessionA;
        DNET$RNSP_JOURNALS.Write_LogA (p_Apl_Ap        => p_ap_id,
                                       p_Apl_Hs        => l_hs,
                                       p_Apl_St        => 'S',
                                       p_Apl_Message   => 'Формування звіту');


        tools.WriteMsg ('DNET$RNSP_REPORTS.' || $$PLSQL_UNIT);
        v_clob :=
            REPLACE (v_clob,
                     '#curr_dt#',
                     TO_CHAR (v_curr_dt, 'DD.MM.YYYY HH24:MI:SS'));

        SELECT a.ap_num,
               a.ap_reg_dt,
               a.com_wu,
               (SELECT u.wu_pib
                  FROM ikis_sysweb.v$all_users u
                 WHERE u.wu_id = a.com_wu)
          INTO v_ap_num,
               v_ap_reg_dt,
               v_reg_wu,
               v_user_pib
          FROM v_appeal a
         WHERE a.ap_id = p_ap_id;

        v_clob := REPLACE (v_clob, '#ap_num#', v_ap_num);
        v_clob :=
            REPLACE (v_clob,
                     '#ap_reg_dt#',
                     TO_CHAR (v_ap_reg_dt, 'DD.MM.YYYY'));
        v_clob :=
            REPLACE (v_clob,
                     '#v611#',
                     SUBSTR (TO_CHAR (v_ap_reg_dt, 'DDMMYYYY'), 1, 1));
        v_clob :=
            REPLACE (v_clob,
                     '#v612#',
                     SUBSTR (TO_CHAR (v_ap_reg_dt, 'DDMMYYYY'), 2, 1));
        v_clob :=
            REPLACE (v_clob,
                     '#v613#',
                     SUBSTR (TO_CHAR (v_ap_reg_dt, 'DDMMYYYY'), 3, 1));
        v_clob :=
            REPLACE (v_clob,
                     '#v614#',
                     SUBSTR (TO_CHAR (v_ap_reg_dt, 'DDMMYYYY'), 4, 1));
        v_clob :=
            REPLACE (v_clob,
                     '#v615#',
                     SUBSTR (TO_CHAR (v_ap_reg_dt, 'DDMMYYYY'), 5, 1));
        v_clob :=
            REPLACE (v_clob,
                     '#v616#',
                     SUBSTR (TO_CHAR (v_ap_reg_dt, 'DDMMYYYY'), 6, 1));
        v_clob :=
            REPLACE (v_clob,
                     '#v617#',
                     SUBSTR (TO_CHAR (v_ap_reg_dt, 'DDMMYYYY'), 7, 1));
        v_clob :=
            REPLACE (v_clob,
                     '#v618#',
                     SUBSTR (TO_CHAR (v_ap_reg_dt, 'DDMMYYYY'), 8, 1));


        IF v_user_pib IS NULL
        THEN
            BEGIN
                v_user_pib := TRIM (tools.getuserpib (v_reg_wu));
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;
        END IF;

        v_clob := REPLACE (v_clob, '#curr_user_pib#', v_user_pib);

        --ЄСП
        FOR c
            IN (  SELECT da.apda_nda,
                         TRIM (
                             CASE pt.pt_data_type
                                 WHEN 'STRING'
                                 THEN
                                     dnet$rnsp_reports.get_dict_val (
                                         pt.pt_ndc,
                                         NULL,
                                         da.apda_val_string)
                                 WHEN 'ID'
                                 THEN
                                     dnet$rnsp_reports.get_dict_val (
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
                             ON dat.nda_id = da.apda_nda AND dat.nda_ndt = 740
                         JOIN uss_ndi.v_ndi_param_type pt
                             ON pt.pt_id = dat.nda_pt
                   WHERE     d.apd_ap = p_ap_id
                         AND d.history_status = 'A'
                         AND d.apd_ndt = 740
                ORDER BY dat.nda_order)
        LOOP
            CASE c.apda_nda
                WHEN 1715
                THEN
                    v_nda_1715 := c.nda_val;
                WHEN 1716
                THEN
                    v_nda_1716 := c.nda_val;
                WHEN 1717
                THEN
                    v_nda_1717 := c.nda_val;
                WHEN 1718
                THEN
                    v_nda_1718 := c.nda_val;
                WHEN 1719
                THEN
                    v_nda_1719 := c.nda_val;
                WHEN 1720
                THEN
                    v_nda_1720 := c.nda_val;
                WHEN 1721
                THEN
                    v_nda_1721 := c.nda_val;
                WHEN 1722
                THEN
                    v_nda_1722 := c.nda_val;
                WHEN 1723
                THEN
                    v_nda_1723 := c.nda_val;
                WHEN 1724
                THEN
                    v_nda_1724 := c.nda_val;
                WHEN 1740
                THEN
                    v_nda_1740 := c.nda_val;
                WHEN 2161
                THEN
                    v_nda_2161 := c.nda_val;
                ELSE
                    NULL;
            END CASE;

            IF c.apda_nda IN (1725, 1726, 1727)
            THEN
                CASE c.apda_nda
                    WHEN 1725
                    THEN
                        v_nda_1725 := c.nda_val;
                    WHEN 1726
                    THEN
                        v_nda_1726 := c.nda_val;
                    WHEN 1727
                    THEN
                        v_nda_1727 := c.nda_val;
                    ELSE
                        NULL;
                END CASE;

                FOR i
                    IN (    SELECT LEVEL                                  AS num,
                                   TRIM (SUBSTR (c.nda_val, LEVEL, 1))    AS smbl
                              FROM DUAL
                        CONNECT BY LEVEL <=
                                   GREATEST (
                                       COALESCE (LENGTH (c.nda_val), 0),
                                       13))
                LOOP
                    v_clob :=
                        REPLACE (
                            v_clob,
                               '#v'
                            || TO_CHAR (c.apda_nda)
                            || TO_CHAR (i.num)
                            || '#',
                            i.smbl);
                END LOOP;
            ELSIF c.apda_nda IN (1743, 1744)
            THEN
                v_field_58 :=
                    (CASE c.apda_nda
                         WHEN 1743 THEN c.nda_val || v_field_58
                         ELSE v_field_58 || ' ' || c.nda_val
                     END);
            ELSIF c.apda_nda NOT IN (1740, 2161)
            THEN
                v_clob :=
                    REPLACE (
                        v_clob,
                        '#v' || TO_CHAR (c.apda_nda) || '#',
                        (CASE
                             WHEN c.apda_nda IN (1714,
                                                 1715,
                                                 1718,
                                                 1719,
                                                 1720,
                                                 1729,
                                                 1730,
                                                 1731)
                             THEN
                                 (CASE c.nda_val
                                      WHEN 'T' THEN v_check_mark
                                  END)
                             WHEN c.apda_nda = 1721
                             THEN
                                 (CASE v_nda_1718 WHEN 'T' THEN c.nda_val END)
                             WHEN c.apda_nda IN (1722, 1723, 1724)
                             THEN
                                 (CASE v_nda_1719
                                      WHEN 'T'
                                      THEN
                                             c.nda_val
                                          || (CASE
                                                  WHEN c.nda_val IS NOT NULL
                                                  THEN
                                                      ' '
                                              END)
                                  END)
                             WHEN     c.apda_nda NOT IN (1714,
                                                         1715,
                                                         1718,
                                                         1719,
                                                         1720,
                                                         1729,
                                                         1730,
                                                         1731)
                                  AND c.nda_val NOT IN ('F', 'T')
                             THEN
                                 c.nda_val
                         END));
            END IF;
        END LOOP;

        v_clob := REPLACE (v_clob, '#v58#', TRIM (v_field_58));
        v_clob :=
            REPLACE (v_clob,
                     '#v1740#',
                     COALESCE (TRIM (v_nda_2161), TRIM (v_nda_1740))); --#78637 пріоритет значень "Вулиця"
        v_clob :=
            REPLACE (
                v_clob,
                '#v17151#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 1, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v17152#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 2, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v17153#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 4, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v17154#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 5, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v17155#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 7, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v17156#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 8, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v17157#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 9, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v17158#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 10, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v17159#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 12, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v171510#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 13, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v171511#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 15, 1) END));
        v_clob :=
            REPLACE (
                v_clob,
                '#v171512#',
                (CASE v_nda_1715 WHEN 'T' THEN SUBSTR (v_nda_1717, 16, 1) END));

        --РНСП
        FOR c1
            IN (SELECT MAX (rnsps_id)     AS rnsps,
                       MAX (org_tp)       AS org_tp,
                       MAX (st)           AS st,
                       MAX (tp)           AS tp,
                       MAX (v10)          AS v10,
                       MAX (v11)          AS v11,
                       MAX (v12)          AS v12,
                       MAX (v13)          AS v13,
                       MAX (v14)          AS v14,
                       MAX (v15)          AS v15,
                       MAX (v16)          AS v16,
                       MAX (v17)          AS v17,
                       MAX (v18)          AS v18,
                       MAX (v19)          AS v19,
                       MAX (v20)          AS v20,
                       MAX (v23)          AS v23,
                       MAX (v24)          AS v24,
                       MAX (v25)          AS v25,
                       MAX (v26)          AS v26,
                       MAX (v27)          AS v27,
                       MAX (v27_1)        AS v27_1,
                       MAX (v28)          AS v28,
                       MAX (v29)          AS v29,
                       MAX (v30)          AS v30,
                       MAX (v31)          AS v31,
                       MAX (v32)          AS v32,
                       MAX (v33)          AS v33,
                       MAX (v34)          AS v34,
                       MAX (v35)          AS v35,
                       MAX (v36)          AS v36,
                       MAX (v43)          AS v43
                  FROM (  SELECT rnsps_id,
                                 org_tp,
                                 st,
                                 tp,
                                 v10,
                                 v11,
                                 v12,
                                 v13,
                                 v14,
                                 v15,
                                 v16,
                                 v17,
                                 v18,
                                 v19,
                                 v20,
                                 v23,
                                 v24,
                                 v25,
                                 v26,
                                 v27,
                                 v27_1,
                                 v28,
                                 v29,
                                 v30,
                                 v31,
                                 v32,
                                 v33,
                                 v34,
                                 v35,
                                 v36,
                                 v43
                            FROM (  SELECT r.rnsps_id,
                                           MAX (r.rnspm_tp)
                                               AS tp,
                                           MAX (r.rnspm_org_tp)
                                               AS org_tp,
                                           MAX (r.rnspm_st)
                                               AS st,
                                           MAX (r.rnsps_last_name)
                                               AS v10,                 -- +v37
                                           MAX (r.rnsps_first_name)
                                               AS v11,
                                           MAX (r.rnsps_middle_name)
                                               AS v12,
                                           MAX (r.rnsps_numident)
                                               AS v13,                 -- +v38
                                           MAX (r.rnsps_is_numident_missing)
                                               AS v14,
                                           MAX (r.rnsps_pass_seria)
                                               AS v15,
                                           MAX (r.rnsps_pass_num)
                                               AS v16,
                                           MAX (r.rnspo_phone)
                                               AS v17,                 -- +v39
                                           MAX (r.rnspo_email)
                                               AS v18, --+v40
                                           MAX (r.rnspo_web)
                                               AS v19,                 -- +v41
                                           MAX (
                                               RTRIM (
                                                   LTRIM (
                                                          TRIM (r.rnspa_index)
                                                       || ', '
                                                       || (SELECT    (CASE
                                                                          WHEN k.kaot_kaot_l1 =
                                                                               k.kaot_id
                                                                          THEN
                                                                              NULL
                                                                          ELSE
                                                                              (SELECT    k1.kaot_full_name
                                                                                      || ', '
                                                                                 FROM uss_ndi.v_ndi_katottg
                                                                                          k1
                                                                                WHERE k1.kaot_id =
                                                                                      k.kaot_kaot_l1)
                                                                      END)
                                                                  || (CASE
                                                                          WHEN k.kaot_kaot_l2 =
                                                                               k.kaot_id
                                                                          THEN
                                                                              NULL
                                                                          ELSE
                                                                              (SELECT    k2.kaot_full_name
                                                                                      || ', '
                                                                                 FROM uss_ndi.v_ndi_katottg
                                                                                          k2
                                                                                WHERE k2.kaot_id =
                                                                                      k.kaot_kaot_l2)
                                                                      END)
                                                                  || k.kaot_full_name
                                                                  || ', '
                                                             FROM uss_ndi.v_ndi_katottg
                                                                  k
                                                            WHERE k.kaot_id =
                                                                  r.rnspa_kaot)
                                                       || LTRIM (
                                                                 TRIM (
                                                                     r.rnspa_street)
                                                              || ', '
                                                              || LTRIM (
                                                                        RTRIM (
                                                                               'буд. '
                                                                            || TRIM (
                                                                                   r.rnspa_building),
                                                                            'буд. ')
                                                                     || ', '
                                                                     || LTRIM (
                                                                               RTRIM (
                                                                                      'копр. '
                                                                                   || TRIM (
                                                                                          r.rnspa_korp),
                                                                                   'копр. ')
                                                                            || ', '
                                                                            || RTRIM (
                                                                                      'кв./оф. '
                                                                                   || TRIM (
                                                                                          r.rnspa_appartement),
                                                                                   'кв./оф. '),
                                                                            ', '),
                                                                     ', '),
                                                              ', '),
                                                       ', '),
                                                   ', '))
                                               AS v20,                         -- +v42
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '113' THEN rl.aprl_result
                                               END)
                                               AS v23,
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '114' THEN rl.aprl_result
                                               END)
                                               AS v24,
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '115' THEN rl.aprl_result
                                               END)
                                               AS v25,
                                           COALESCE (
                                               MAX (
                                                   CASE d.apd_ndt
                                                       WHEN 706 THEN 'T'
                                                   END),
                                               'F')
                                               AS v26,
                                           COALESCE (
                                               MAX (
                                                   CASE d.apd_ndt
                                                       WHEN 704 THEN 'T'
                                                   END),
                                               'F')
                                               AS v27, --трудових договорів з найманими працівниками
                                           COALESCE (
                                               MAX (
                                                   CASE d.apd_ndt
                                                       WHEN 703 THEN 'T'
                                                   END),
                                               'F')
                                               AS v27_1,     --штатний розклад
                                           COALESCE (
                                               MAX (
                                                   CASE d.apd_ndt
                                                       WHEN 709 THEN 'T'
                                                   END),
                                               'F')
                                               AS v28,
                                           COALESCE (
                                               MAX (
                                                   CASE
                                                       WHEN     d.apd_ndt = 700
                                                            AND da.apda_nda =
                                                                1133
                                                            AND da.apda_val_string
                                                                    IS NOT NULL
                                                       THEN
                                                           'T'
                                                   END),
                                               'F')
                                               AS v29,
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '206' THEN rl.aprl_result
                                               END)
                                               AS v30,
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '202' THEN rl.aprl_result
                                               END)
                                               AS v31,
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '201' THEN rl.aprl_result
                                               END)
                                               AS v32,
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '118' THEN rl.aprl_result
                                               END)
                                               AS v33,
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '203' THEN rl.aprl_result
                                               END)
                                               AS v34,
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '204' THEN rl.aprl_result
                                               END)
                                               AS v35,
                                           MAX (
                                               CASE rr.nrr_code
                                                   WHEN '205' THEN rl.aprl_result
                                               END)
                                               AS v36,
                                           MAX (
                                               COALESCE (
                                                   (SELECT RTRIM (
                                                                  (CASE
                                                                       WHEN a.rnspa_index
                                                                                IS NOT NULL
                                                                       THEN
                                                                              a.rnspa_index
                                                                           || ', '
                                                                   END)
                                                               || (CASE
                                                                       WHEN k.kaot_kaot_l1
                                                                                IS NOT NULL
                                                                       THEN
                                                                           (SELECT    k1.kaot_full_name
                                                                                   || ', '
                                                                              FROM uss_ndi.v_ndi_katottg
                                                                                       k1
                                                                             WHERE k1.kaot_id =
                                                                                   k.kaot_kaot_l1)
                                                                   END)
                                                               || (CASE
                                                                       WHEN k.kaot_kaot_l2
                                                                                IS NOT NULL
                                                                       THEN
                                                                           (SELECT    k2.kaot_full_name
                                                                                   || ', '
                                                                              FROM uss_ndi.v_ndi_katottg
                                                                                       k2
                                                                             WHERE k2.kaot_id =
                                                                                   k.kaot_kaot_l2)
                                                                   END)
                                                               || (CASE
                                                                       WHEN k.kaot_full_name
                                                                                IS NOT NULL
                                                                       THEN
                                                                              k.kaot_full_name
                                                                           || ', '
                                                                   END)
                                                               || (CASE
                                                                       WHEN a.rnspa_street
                                                                                IS NOT NULL
                                                                       THEN
                                                                              a.rnspa_street
                                                                           || ', '
                                                                   END)
                                                               || (CASE
                                                                       WHEN a.rnspa_building
                                                                                IS NOT NULL
                                                                       THEN
                                                                              'буд. '
                                                                           || a.rnspa_building
                                                                           || ', '
                                                                   END)
                                                               || (CASE
                                                                       WHEN a.rnspa_korp
                                                                                IS NOT NULL
                                                                       THEN
                                                                              'корп. '
                                                                           || a.rnspa_korp
                                                                           || ', '
                                                                   END)
                                                               || (CASE
                                                                       WHEN a.rnspa_appartement
                                                                                IS NOT NULL
                                                                       THEN
                                                                              'оф./кв. '
                                                                           || a.rnspa_appartement
                                                                   END),
                                                               ', ')
                                                      FROM rnsp_address a
                                                           JOIN RNSP2ADDRESS s2a
                                                               ON a.rnspa_id =
                                                                  s2a.rnsp2a_rnspa
                                                           LEFT JOIN
                                                           uss_ndi.v_ndi_katottg
                                                           k
                                                               ON k.kaot_id =
                                                                  a.rnspa_kaot
                                                     WHERE     s2a.rnsp2a_rnsps =
                                                               r.rnsps_id
                                                           AND a.rnspa_tp = 'S'
                                                           AND ROWNUM < 2),
                                                   r.rnspo_service_location))
                                               AS v43
                                      FROM uss_rnsp.v_rnsp r
                                           LEFT JOIN uss_rnsp.v_appeal a
                                           JOIN uss_rnsp.v_ap_service s
                                               ON     s.aps_ap = a.ap_id
                                                  AND s.history_status = 'A'
                                           JOIN uss_ndi.v_ndi_service_type st
                                               ON     st.nst_id = s.aps_nst
                                                  AND st.history_status = 'A'
                                           LEFT JOIN uss_rnsp.v_ap_right_log rl
                                           JOIN uss_ndi.v_ndi_right_rule rr
                                               ON rr.nrr_id = rl.aprl_nrr
                                               ON rl.aprl_aps = s.aps_id
                                               ON a.ap_ext_ident = r.rnspm_id
                                           LEFT JOIN uss_rnsp.v_ap_document d
                                           JOIN uss_rnsp.v_ap_document_attr da
                                               ON     da.apda_apd = d.apd_id
                                                  AND da.history_status = 'A'
                                               ON     d.apd_ap = a.ap_id
                                                  AND d.apd_ndt IN (706,
                                                                    703,
                                                                    704,
                                                                    709,
                                                                    700)
                                                  AND d.history_status = 'A'
                                     WHERE     r.rnspm_tp =
                                               (CASE
                                                    WHEN v_nda_1718 = 'T'
                                                    THEN
                                                        'O'
                                                    WHEN v_nda_1719 = 'T'
                                                    THEN
                                                        'F'
                                                    WHEN v_nda_1720 = 'T'
                                                    THEN
                                                        r.rnspm_tp
                                                END)
                                           AND COALESCE (r.rnsps_last_name, '-$') =
                                               COALESCE (v_nda_1721,
                                                         v_nda_1722,
                                                         r.rnsps_last_name,
                                                         '-$')
                                           AND COALESCE (r.rnsps_first_name,
                                                         '-$') =
                                               COALESCE (v_nda_1723,
                                                         r.rnsps_first_name,
                                                         '-$')
                                           AND COALESCE (r.rnsps_middle_name,
                                                         '-$') =
                                               COALESCE (v_nda_1724,
                                                         r.rnsps_middle_name,
                                                         '-$')
                                           AND COALESCE (r.rnsps_numident, '-$') =
                                               COALESCE (v_nda_1725,
                                                         r.rnsps_numident,
                                                         '-$')
                                           AND COALESCE (r.rnsps_pass_seria,
                                                         '-$') =
                                               COALESCE (v_nda_1726,
                                                         r.rnsps_pass_seria,
                                                         '-$')
                                           AND COALESCE (r.rnsps_pass_num, '-$') =
                                               COALESCE (v_nda_1727,
                                                         r.rnsps_pass_num,
                                                         '-$')
                                           AND (   v_nda_1721 IS NOT NULL
                                                OR v_nda_1725 IS NOT NULL
                                                OR (    v_nda_1726 IS NOT NULL
                                                    AND v_nda_1727 IS NOT NULL)
                                                OR COALESCE (v_nda_1722,
                                                             v_nda_1723,
                                                             v_nda_1724)
                                                       IS NOT NULL)
                                           AND r.rnspm_date_in <=
                                               (CASE v_nda_1715
                                                    WHEN 'T'
                                                    THEN
                                                        TO_DATE (
                                                            v_nda_1717,
                                                            'DD.MM.YYYY HH24:MI:SS')
                                                    ELSE
                                                        SYSDATE
                                                END)
                                  GROUP BY r.rnsps_id)
                        ORDER BY (CASE org_tp WHEN 'PR' THEN 0 ELSE 1 END) --#81424
                           FETCH FIRST 1 ROW ONLY)
                 WHERE st NOT IN ('N', 'D')) --#81424 Не формувати повний витяг (з даними щодо надавача), якщо надавач має статус «Виключено з РНСП»
        LOOP
            IF c1.rnsps IS NOT NULL
            THEN
                SELECT LISTAGG (nst_name, ', ')
                           WITHIN GROUP (ORDER BY nst_order),
                       LISTAGG (
                           CASE rnspds_is_standards
                               WHEN 'T' THEN nst_name
                           END,
                           ', ')
                       WITHIN GROUP (ORDER BY nst_order)
                  INTO v21, v22
                  FROM (SELECT DISTINCT
                               ds.rnspds_is_standards,
                               tp.nst_name,
                               tp.nst_order
                          FROM uss_rnsp.v_rnsp2service  rs
                               JOIN uss_rnsp.v_rnsp_dict_service ds
                                   ON ds.rnspds_id = rs.rnsp2s_rnspds
                               JOIN uss_ndi.v_ndi_service_type tp
                                   ON     tp.nst_id = ds.rnspds_nst
                                      AND tp.history_status = 'A'
                         WHERE rs.rnsp2s_rnsps = c1.rnsps);
            END IF;


            --#98785  поле №43 виводити всі адреси надання – з нового рядка
            SELECT LISTAGG (
                       RTRIM (
                              (CASE
                                   WHEN a.rnspa_index IS NOT NULL
                                   THEN
                                       a.rnspa_index || ', '
                               END)
                           || (CASE
                                   WHEN k.kaot_kaot_l1 IS NOT NULL
                                   THEN
                                       (SELECT k1.kaot_full_name || ', '
                                          FROM uss_ndi.v_ndi_katottg k1
                                         WHERE k1.kaot_id = k.kaot_kaot_l1)
                               END)
                           || (CASE
                                   WHEN k.kaot_kaot_l2 IS NOT NULL
                                   THEN
                                       (SELECT k2.kaot_full_name || ', '
                                          FROM uss_ndi.v_ndi_katottg k2
                                         WHERE k2.kaot_id = k.kaot_kaot_l2)
                               END)
                           || (CASE
                                   WHEN k.kaot_full_name IS NOT NULL
                                   THEN
                                       k.kaot_full_name || ', '
                               END)
                           || (CASE
                                   WHEN a.rnspa_street IS NOT NULL
                                   THEN
                                       a.rnspa_street || ', '
                               END)
                           || (CASE
                                   WHEN a.rnspa_building IS NOT NULL
                                   THEN
                                       'буд. ' || a.rnspa_building || ', '
                               END)
                           || (CASE
                                   WHEN a.rnspa_korp IS NOT NULL
                                   THEN
                                       'корп. ' || a.rnspa_korp || ', '
                               END)
                           || (CASE
                                   WHEN a.rnspa_appartement IS NOT NULL
                                   THEN
                                       'оф./кв. ' || a.rnspa_appartement
                               END),
                           ', '),
                       '\par ')
                   WITHIN GROUP (ORDER BY 1)
              INTO v43
              FROM rnsp_address  a
                   JOIN RNSP2ADDRESS s2a ON a.rnspa_id = s2a.rnsp2a_rnspa
                   LEFT JOIN uss_ndi.v_ndi_katottg k
                       ON k.kaot_id = a.rnspa_kaot
             WHERE s2a.rnsp2a_rnsps = c1.rnsps AND a.rnspa_tp = 'S';

            v43 := COALESCE (v43, c1.v43);

            v_clob := REPLACE (v_clob, '#v21#', v21);
            v_clob :=
                REPLACE (v_clob,
                         '#v211#',
                         (CASE WHEN v21 IS NOT NULL THEN v_check_mark END));
            v_clob := REPLACE (v_clob, '#v22#', v22);
            v_clob :=
                REPLACE (v_clob,
                         '#v221#',
                         (CASE WHEN v22 IS NOT NULL THEN v_check_mark END));

            v_clob :=
                REPLACE (v_clob,
                         '#v10#',
                         (CASE c1.tp WHEN 'F' THEN c1.v10 END));
            v_clob :=
                REPLACE (v_clob,
                         '#v11#',
                         (CASE c1.tp WHEN 'F' THEN c1.v11 END));
            v_clob :=
                REPLACE (v_clob,
                         '#v12#',
                         (CASE c1.tp WHEN 'F' THEN c1.v12 END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v131#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 1, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v132#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 2, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v133#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 3, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v134#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 4, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v135#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 5, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v136#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 6, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v137#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 7, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v138#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 8, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v139#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 9, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v1310#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v13, 10, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v14#',
                    (CASE c1.tp
                         WHEN 'F'
                         THEN
                             (CASE c1.v14 WHEN 'T' THEN v_check_mark END)
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v151#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v15, 1, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v152#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v15, 2, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v161#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v16, 1, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v162#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v16, 2, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v163#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v16, 3, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v164#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v16, 4, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v165#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v16, 5, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v166#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v16, 6, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn171#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 1, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn172#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 2, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn173#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 3, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn174#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 4, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn175#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 5, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn176#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 6, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn177#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 7, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn178#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 8, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn179#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 9, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn1710#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 10, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn1711#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 11, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn1712#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 12, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn1713#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 13, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn1714#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 14, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#pn1715#',
                    (CASE c1.tp WHEN 'F' THEN SUBSTR (c1.v17, 15, 1) END));
            v_clob :=
                REPLACE (v_clob,
                         '#v18#',
                         (CASE c1.tp WHEN 'F' THEN c1.v18 END));
            v_clob :=
                REPLACE (v_clob,
                         '#v19#',
                         (CASE c1.tp WHEN 'F' THEN c1.v19 END));
            v_clob :=
                REPLACE (v_clob,
                         '#v20#',
                         (CASE c1.tp WHEN 'F' THEN c1.v20 END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v23#',
                    (CASE c1.v23
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v24#',
                    (CASE c1.v24
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v25#',
                    (CASE c1.v25
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v26#',
                    (CASE c1.v26
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v27#',
                    (CASE c1.v27
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v27-1#',
                    (CASE c1.v27_1
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v28#',
                    (CASE c1.v28
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v29#',
                    (CASE c1.v29
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v30#',
                    (CASE c1.v30
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v31#',
                    (CASE c1.v31
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v32#',
                    (CASE c1.v32
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v33#',
                    (CASE c1.v33
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v34#',
                    (CASE c1.v34
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v35#',
                    (CASE c1.v35
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v36#',
                    (CASE c1.v36
                         WHEN 'T' THEN v_check_mark
                         WHEN 'F' THEN NULL
                     END));
            v_clob :=
                REPLACE (v_clob,
                         '#v37#',
                         (CASE c1.tp WHEN 'O' THEN c1.v10 END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v381#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 1, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v382#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 2, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v383#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 3, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v384#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 4, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v385#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 5, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v386#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 6, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v387#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 7, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v388#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 8, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v389#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 9, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v3810#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v13, 10, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v391#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 1, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v392#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 2, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v393#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 3, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v394#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 4, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v395#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 5, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v396#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 6, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v397#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 7, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v398#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 8, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v399#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 9, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v3910#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 10, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v3911#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 11, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v3912#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 12, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v3913#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 13, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v3914#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 14, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v3915#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 15, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v3916#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 16, 1) END));
            v_clob :=
                REPLACE (
                    v_clob,
                    '#v3917#',
                    (CASE c1.tp WHEN 'O' THEN SUBSTR (c1.v17, 17, 1) END));
            v_clob :=
                REPLACE (v_clob,
                         '#v40#',
                         (CASE c1.tp WHEN 'O' THEN c1.v18 END));
            v_clob :=
                REPLACE (v_clob,
                         '#v41#',
                         (CASE c1.tp WHEN 'O' THEN c1.v19 END));
            v_clob :=
                REPLACE (v_clob,
                         '#v42#',
                         (CASE c1.tp WHEN 'O' THEN c1.v20 END));
            v_clob :=
                REPLACE (v_clob, '#v43#', (CASE c1.tp WHEN 'O' THEN v43 END));
        END LOOP;


        v_clob := REPLACE (v_clob, '#v1722#', '');
        v_clob := REPLACE (v_clob, '#v1723#', '');
        v_clob := REPLACE (v_clob, '#v1724#', '');
        v_clob := REPLACE (v_clob, '#v17261#', '');
        v_clob := REPLACE (v_clob, '#v17262#', '');
        v_clob := REPLACE (v_clob, '#v17271#', '');
        v_clob := REPLACE (v_clob, '#v17272#', '');
        v_clob := REPLACE (v_clob, '#v17273#', '');
        v_clob := REPLACE (v_clob, '#v17274#', '');
        v_clob := REPLACE (v_clob, '#v17275#', '');
        v_clob := REPLACE (v_clob, '#v17276#', '');


        v_clob := REPLACE (v_clob, '#v1729#', '');
        v_clob :=
            REPLACE (v_clob, '#v1729_2#', Get_Ap_Doc_Atr_Str (p_ap_id, 1732));
        v_clob := REPLACE (v_clob, '#v1730#', '');
        v_clob := REPLACE (v_clob, '#v1731#', '');
        -- v_clob := REPLACE(v_clob, '#v1732#', '');
        v_clob := REPLACE (v_clob, '#v1733#', '');
        v_clob := REPLACE (v_clob, '#v1734#', '');
        v_clob := REPLACE (v_clob, '#v1735#', '');
        v_clob := REPLACE (v_clob, '#v1736#', '');
        v_clob := REPLACE (v_clob, '#v1737#', '');
        v_clob := REPLACE (v_clob, '#v1738#', '');
        v_clob := REPLACE (v_clob, '#v1739#', '');
        -- v_clob := REPLACE(v_clob, '#v1740#', '');
        v_clob := REPLACE (v_clob, '#v1741#', '');
        v_clob := REPLACE (v_clob, '#v1742#', '');
        -- v_clob := REPLACE(v_clob, '#v1743#', '');
        -- v_clob := REPLACE(v_clob, '#v1744#', '');
        v_clob := REPLACE (v_clob, '#v1745#', '');

        p_blob := tools.convertc2b (v_clob);
        p_is_error := 'F';
        p_doc_name := get_filename_by_code ('ANNEX_7_R1');
    --при виникненні помилки повертаєтся файл із поясненням та помилкою
    EXCEPTION
        WHEN OTHERS
        THEN
            DNET$RNSP_JOURNALS.Write_LogA (
                p_Apl_Ap   => p_ap_id,
                p_Apl_Hs   => l_hs,
                p_Apl_St   => 'S',
                p_Apl_Message   =>
                    'Помилка побудови витягу' || CHR (10) || SQLERRM);
            p_is_error := 'T';
            p_doc_name := get_filename_by_code ('ANNEX_7_R1');
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
        v_new_id   NUMBER;
    BEGIN
        tools.WriteMsg ('DNET$RNSP_REPORTS.' || $$PLSQL_UNIT);

        FOR cur
            IN (SELECT d.apd_id, d.apd_app, s.aps_id
                  FROM v_appeal  a
                       JOIN v_ap_service s
                           ON     s.aps_ap = a.ap_id
                              AND s.aps_nst = 701
                              AND s.history_status = 'A'
                       JOIN v_ap_document d
                           ON     d.apd_ap = a.ap_id
                              AND d.apd_ndt = 740
                              AND d.history_status = 'A'
                 WHERE a.ap_id = p_ap_id AND a.ap_st = 'S' AND a.ap_tp = 'D')
        LOOP
            --збереження сформованої довідки
            api$document.save_document (p_rnd_id    => NULL,
                                        p_rnd_ap    => p_ap_id,
                                        p_rnd_ndt   => 740,
                                        p_rnd_doc   => p_doc_id,
                                        p_rnd_app   => cur.apd_app,
                                        p_new_id    => v_new_id,
                                        p_com_wu    => NULL,
                                        p_rnd_dh    => p_dh_id,
                                        p_rnd_aps   => cur.aps_id);

            UPDATE rn_document d
               SET d.rnd_apd = cur.apd_id
             WHERE d.rnd_id = v_new_id;

            --переведення звернення в виконане
            UPDATE appeal a
               SET a.ap_st = 'V'
             WHERE a.ap_id = p_ap_id;

            --підготовка до зворотнього копіювання сформованої довідки
            api$rnsp_action.preparecopy_rnsp2visit (p_ap_id, 'S', NULL);
        END LOOP;
    END;

    --=============================================================================--
    FUNCTION REESTR_RNSP
        RETURN DECIMAL
    IS
        l_rt_id       rpt_templates.rt_id%TYPE;
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (250);
    BEGIN
        tools.WriteMsg ('dnet$rnsp_reports.' || $$PLSQL_UNIT);

        SELECT rt_id
          INTO l_rt_id
          FROM v_rpt_templates
         WHERE rt_code = 'REESTR_RNSP';

        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => l_rt_id);

        l_file_name :=
            'Реєстр_' || TO_DATE (SYSDATE, 'dd.mm.yyyy') || '.xml.xls';

        ikis_sysweb.REPORTFL_ENGINE_EX.SetFileName (
            p_jbr_id      => l_jbr_id,
            p_file_name   => l_file_name);

        RDM$RTFL.AddDataSet (
            l_jbr_id,
            'ds',
            q'[SELECT ABS(NVL(v.rnspm_rnspm, v.RNSPM_ID)) AS ORDER1,  ABS(NVL(v.rnspm_rnspm, 0)) AS  ORDER2,
       COALESCE(v.RNSPS_NUMIDENT, v.RNSPS_PASS_SERIA||v.RNSPS_PASS_NUM) AS d1,
       CASE v.RNSPM_TP
       WHEN 'O' THEN replace(v.RNSPS_LAST_NAME, '>', '/>')
       WHEN 'F' THEN replace(v.RNSPS_LAST_NAME||' '||v.RNSPS_FIRST_NAME||' '||v.RNSPS_MIDDLE_NAME, '>', '/>')
       END AS d2,
       CASE v.RNSPM_TP
       WHEN 'O' THEN v.RNSPS_FIRST_NAME
       END AS d3,
       (SELECT t.DIC_SNAME FROM uss_ndi.V_DDN_FORMS_MNGM t WHERE t.DIC_CODE = v.RNSPO_PROP_FORM) AS d4,
       (SELECT v.RNSPS_NUMIDENT FROM uss_rnsp.v_rnsp vv WHERE vv.RNSPM_ID = v.rnspm_rnspm) AS d5,
       (SELECT ow.DIC_SNAME FROM uss_ndi.v_ddn_rnsp_ownership ow WHERE ow.DIC_CODE = v.rnsps_ownership) as d60,
       v.RNSPO_PHONE AS d6,
       uss_rnsp.DNET$RNSP_VIEW.xml_replace(v.RNSPO_EMAIL) AS d7,
       uss_rnsp.DNET$RNSP_VIEW.xml_replace(v.RNSPO_WEB)   AS d8,
       v.RNSPA_INDEX AS d9,
       uss_rnsp.DNET$RNSP_VIEW.GetAddress(v.RNSPA_ID) AS d10,
       uss_rnsp.DNET$RNSP_VIEW.GetAddress_Index(v.rnsps_id, 'S', 1) AS d11,
       uss_rnsp.DNET$RNSP_VIEW.GetAddress(v.rnsps_id, 'S', 1) AS d12,
       (SELECT MAX(to_char(c.Rnspc_Date, 'dd.mm.yyyy') )
        FROM uss_rnsp.v_rnsp_check c
        WHERE c.Rnspc_Rnspm = v.RNSPM_ID
          AND c.Rnspc_Date = (SELECT MAX(cc.Rnspc_Date) FROM uss_rnsp.v_RNSP_CHECK cc WHERE cc.Rnspc_Rnspm = v.RNSPM_ID )
       ) AS d13,
       uss_rnsp.DNET$RNSP_VIEW.xml_replace((SELECT MAX(c.rnspc_name )
        FROM uss_rnsp.v_rnsp_check c
        WHERE c.Rnspc_Rnspm = v.RNSPM_ID
          AND c.Rnspc_Date = (SELECT MAX(cc.Rnspc_Date) FROM uss_rnsp.v_rnsp_check cc WHERE cc.Rnspc_Rnspm = v.RNSPM_ID )
       )) AS d14,
       uss_rnsp.DNET$RNSP_VIEW.xml_replace((SELECT MAX(rnspc_res||' '||rnspc_info  )
        FROM uss_rnsp.v_rnsp_check c
        WHERE c.Rnspc_Rnspm = v.RNSPM_ID
          AND c.Rnspc_Date = (SELECT MAX(cc.Rnspc_Date) FROM uss_rnsp.v_rnsp_check cc WHERE cc.Rnspc_Rnspm = v.RNSPM_ID )
       )) AS d15,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '001.0') AS d16,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '002.0') AS d17,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '002.1') AS d18,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '003.0') AS d19,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '004.0') AS d20,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '005.0') AS d21,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '005.1') AS d22,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '006.0') AS d23,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '007.0') AS d24,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '008.1') AS d25,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '009.1') AS d26,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '009.2') AS d27,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '009.3') AS d28,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '010.1') AS d29,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '010.2') AS d30,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '011.0') AS d31,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '012.0') AS d32,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '013.0') AS d33,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '013.1') AS d34,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '014.0') AS d35,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.1') AS d36,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.2') AS d37,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.3') AS d38,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.3.1') AS d39,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.4') AS d40,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '016.0') AS d41,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '017.1') AS d42,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '017.2') AS d43,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '017.3') AS d44,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '017.4') AS d45,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '018.1') AS d46,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '018.2') AS d47,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '019.0') AS d48,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '020.0') AS d49,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '021.0') AS d50,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '022.0') AS d51,
           uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '023.0') AS d52,
       (SELECT  to_char( MAX(SS.RNSPSR_DATE) , 'dd.mm.yyyy') FROM uss_rnsp.v_rnsp_status_register SS WHERE SS.RNSPSR_RNSPM = v.RNSPM_ID) AS d53
FROM uss_rnsp.v_rnsp v
WHERE v.RNSPM_ST = 'A'
UNION ALL
SELECT  ABS(NVL(v.rnspm_rnspm, v.RNSPM_ID)) AS ORDER1,  ABS(NVL(v.rnspm_rnspm, 0)) + rn AS ORDER2,
       COALESCE(v.RNSPS_NUMIDENT, v.RNSPS_PASS_SERIA||v.RNSPS_PASS_NUM) AS d1,
       CASE v.RNSPM_TP
       WHEN 'O' THEN replace(v.RNSPS_LAST_NAME, '>', '/>')
       WHEN 'F' THEN replace(v.RNSPS_LAST_NAME||' '||v.RNSPS_FIRST_NAME||' '||v.RNSPS_MIDDLE_NAME, '>', '/>')
       END AS d2,
       CASE v.RNSPM_TP
       WHEN 'O' THEN v.RNSPS_FIRST_NAME
       END AS d3,
       (SELECT t.DIC_SNAME FROM uss_ndi.V_DDN_FORMS_MNGM t WHERE t.DIC_CODE = v.RNSPO_PROP_FORM) AS d4,
       (SELECT v.RNSPS_NUMIDENT FROM uss_rnsp.v_rnsp vv WHERE vv.RNSPM_ID = v.rnspm_rnspm) AS d5,
       (SELECT ow.DIC_SNAME FROM uss_ndi.v_ddn_rnsp_ownership ow WHERE ow.DIC_CODE = v.rnsps_ownership) as d60,
       v.RNSPO_PHONE AS d6,
       uss_rnsp.DNET$RNSP_VIEW.xml_replace(v.RNSPO_EMAIL) AS d7,
       uss_rnsp.DNET$RNSP_VIEW.xml_replace(v.RNSPO_WEB)   AS d8,
           null as d9,
           null as d10,
           uss_rnsp.DNET$RNSP_VIEW.GetAddress_Index(v.rnsps_id, 'S', rn) AS d11,
           uss_rnsp.DNET$RNSP_VIEW.GetAddress(v.rnsps_id,       'S', rn) AS d12,
           null as d13,
           null as d14,
           null as d15,
           null as d16,
           null as d17,
           null as d18,
           null as d19,
           null as d20,
           null as d21,
           null as d22,
           null as d23,
           null as d24,
           null as d25,
           null as d26,
           null as d27,
           null as d28,
           null as d29,
           null as d30,
           null as d31,
           null as d32,
           null as d33,
           null as d34,
           null as d35,
           null as d36,
           null as d37,
           null as d38,
           null as d39,
           null as d40,
           null as d41,
           null as d42,
           null as d43,
           null as d44,
           null as d45,
           null as d46,
           null as d47,
           null as d48,
           null as d49,
           null as d50,
           null as d51,
           null as d52,
           null as d53
FROM uss_rnsp.v_rnsp v
  JOIN ( SELECT s2a.rnsp2a_rnsps, a.rnspa_id,  ROW_NUMBER () OVER (PARTITION BY s2a.rnsp2a_rnsps, a.rnspa_tp ORDER BY a.rnspa_id ASC) AS rn
           FROM uss_rnsp.v_rnsp2address s2a
           JOIN uss_rnsp.v_rnsp_address a ON a.rnspa_id = s2a.rnsp2a_rnspa
           WHERE a.rnspa_tp = 'S'
       ) ON rnsp2a_rnsps = v.RNSPS_ID
         AND rn > 1
WHERE v.RNSPM_ST = 'A'
ORDER BY 1,2]'/*
             q'[SELECT COALESCE(v.RNSPS_NUMIDENT, v.RNSPS_PASS_SERIA||v.RNSPS_PASS_NUM) AS d1,
                    CASE v.RNSPM_TP
                    WHEN 'O' THEN v.RNSPS_LAST_NAME
                    WHEN 'F' THEN v.RNSPS_LAST_NAME||' '||v.RNSPS_FIRST_NAME||' '||v.RNSPS_MIDDLE_NAME
                    END AS d2,
                    CASE v.RNSPM_TP
                    WHEN 'O' THEN v.RNSPS_FIRST_NAME
                    END AS d3,
                    (SELECT t.DIC_SNAME FROM uss_ndi.V_DDN_FORMS_MNGM t WHERE t.DIC_CODE = v.RNSPO_PROP_FORM) AS d4,
                    (SELECT v.RNSPS_NUMIDENT FROM uss_rnsp.v_rnsp vv WHERE vv.RNSPM_ID = v.rnspm_rnspm) AS d5,
                    (SELECT ow.DIC_SNAME FROM uss_ndi.v_ddn_rnsp_ownership ow WHERE ow.DIC_CODE = v.rnsps_ownership) as d60,
                    v.RNSPO_PHONE AS d6,
                    uss_rnsp.DNET$RNSP_VIEW.xml_replace(v.RNSPO_EMAIL) AS d7,
                    uss_rnsp.DNET$RNSP_VIEW.xml_replace(v.RNSPO_WEB)   AS d8,
                    v.RNSPA_INDEX AS d9,
                    uss_rnsp.DNET$RNSP_VIEW.GetAddress(v.RNSPA_ID) AS d10,
                    uss_rnsp.DNET$RNSP_VIEW.GetAddress_Index(v.rnsps_id, 'S', 1) AS d11,
                    uss_rnsp.DNET$RNSP_VIEW.GetAddress(v.rnsps_id, 'S', 1) AS d12,
                    uss_rnsp.DNET$RNSP_VIEW.GetAddress_Index(v.rnsps_id, 'S', 2) AS d54,
                    uss_rnsp.DNET$RNSP_VIEW.GetAddress(v.rnsps_id, 'S', 2) AS d55,
                    uss_rnsp.DNET$RNSP_VIEW.GetAddress_Index(v.rnsps_id, 'S', 3) AS d56,
                    uss_rnsp.DNET$RNSP_VIEW.GetAddress(v.rnsps_id, 'S', 3) AS d57,
                    uss_rnsp.DNET$RNSP_VIEW.GetAddress_Index(v.rnsps_id, 'S', 4) AS d58,
                    uss_rnsp.DNET$RNSP_VIEW.GetAddress(v.rnsps_id, 'S', 4) AS d59,
                    (SELECT MAX(to_char(c.Rnspc_Date, 'dd.mm.yyyy') )
                     FROM uss_rnsp.v_rnsp_check c
                     WHERE c.Rnspc_Rnspm = v.RNSPM_ID
                       AND c.Rnspc_Date = (SELECT MAX(cc.Rnspc_Date) FROM uss_rnsp.v_RNSP_CHECK cc WHERE cc.Rnspc_Rnspm = v.RNSPM_ID )
                    ) AS d13,
                    uss_rnsp.DNET$RNSP_VIEW.xml_replace((SELECT MAX(c.rnspc_name )
                     FROM uss_rnsp.v_rnsp_check c
                     WHERE c.Rnspc_Rnspm = v.RNSPM_ID
                       AND c.Rnspc_Date = (SELECT MAX(cc.Rnspc_Date) FROM uss_rnsp.v_rnsp_check cc WHERE cc.Rnspc_Rnspm = v.RNSPM_ID )
                    )) AS d14,
                    uss_rnsp.DNET$RNSP_VIEW.xml_replace((SELECT MAX(rnspc_res||' '||rnspc_info  )
                     FROM uss_rnsp.v_rnsp_check c
                     WHERE c.Rnspc_Rnspm = v.RNSPM_ID
                       AND c.Rnspc_Date = (SELECT MAX(cc.Rnspc_Date) FROM uss_rnsp.v_rnsp_check cc WHERE cc.Rnspc_Rnspm = v.RNSPM_ID )
                    )) AS d15,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '001.0') AS d16,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '002.0') AS d17,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '002.1') AS d18,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '003.0') AS d19,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '004.0') AS d20,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '005.0') AS d21,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '005.1') AS d22,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '006.0') AS d23,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '007.0') AS d24,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '008.1') AS d25,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '009.1') AS d26,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '009.2') AS d27,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '009.3') AS d28,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '010.1') AS d29,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '010.2') AS d30,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '011.0') AS d31,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '012.0') AS d32,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '013.0') AS d33,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '013.1') AS d34,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '014.0') AS d35,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.1') AS d36,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.2') AS d37,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.3') AS d38,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.3.1') AS d39,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '015.4') AS d40,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '016.0') AS d41,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '017.1') AS d42,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '017.2') AS d43,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '017.3') AS d44,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '017.4') AS d45,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '018.1') AS d46,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '018.2') AS d47,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '019.0') AS d48,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '020.0') AS d49,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '021.0') AS d50,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '022.0') AS d51,
                        uss_rnsp.DNET$RNSP_VIEW.GetIsService(v.RNSPS_ID, '023.0') AS d52,
                    (SELECT  to_char( MAX(SS.RNSPSR_DATE) , 'dd.mm.yyyy') FROM uss_rnsp.v_rnsp_status_register SS WHERE SS.RNSPSR_RNSPM = v.RNSPM_ID) AS d53
             FROM uss_rnsp.v_rnsp v
             WHERE v.RNSPM_ST = 'A'
             ORDER BY ABS(NVL(v.rnspm_rnspm, v.RNSPM_ID)),  ABS(NVL(v.rnspm_rnspm, 0))
                 ]'*/
             );

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    --=============================================================================--

    FUNCTION ORG_INFO_R1 (p_rnspm_id   IN NUMBER,
                          p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id   NUMBER;
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_REPORTS.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        RDM$RTFL.AddDataSet (
            l_jbr_id,
            'ds',
               'SELECT t.os_name AS c1,
               COUNT(DISTINCT CASE WHEN f.history_status = ''T'' THEN f.ost_id END) AS c2,
               COUNT(DISTINCT CASE WHEN es.emf_id IS NOT NULL THEN f.ost_id END) AS c3,
               COUNT(DISTINCT CASE WHEN es.emf_subcontract = ''T'' OR es.emf_servcontract = ''T'' THEN e.em_id END) AS c4
          FROM uss_rnsp.v_orgstructure t
          JOIN uss_rnsp.v_os_staff f ON (f.ost_os = t.os_id)
          LEFT JOIN uss_rnsp.v_em_staff es
               JOIN uss_rnsp.v_emploee e ON (e.em_id = es.emf_em and sysdate between e.em_start_dt and nvl(e.em_stop_dt, sysdate))
            ON (es.emf_ost = f.ost_id)
         WHERE 1 = 1
           and t.history_status = ''A''
           AND t.os_rnspm = '
            || p_rnspm_id
            || '
         group by t.os_name');

        RDM$RTFL.AddDataSet (
            l_jbr_id,
            'ds_tot',
               'SELECT COUNT(DISTINCT CASE WHEN f.history_status = ''T'' THEN f.ost_id END) AS c2,
               COUNT(DISTINCT CASE WHEN es.emf_id IS NOT NULL THEN f.ost_id END) AS c3,
               COUNT(DISTINCT CASE WHEN es.emf_subcontract = ''T'' OR es.emf_servcontract = ''T'' THEN e.em_id END) AS c4
          FROM uss_rnsp.v_orgstructure t
          JOIN uss_rnsp.v_os_staff f ON (f.ost_os = t.os_id)
          LEFT JOIN uss_rnsp.v_em_staff es
               JOIN uss_rnsp.v_emploee e ON (e.em_id = es.emf_em and sysdate between e.em_start_dt and nvl(e.em_stop_dt, sysdate))
            ON (es.emf_ost = f.ost_id)
         WHERE 1 = 1
           and t.history_status = ''A''
           AND t.os_rnspm = '
            || p_rnspm_id);

        FOR xx
            IN (SELECT    s.RNSPS_LAST_NAME
                       || ' '
                       || s.RNSPS_FIRST_NAME
                       || ' '
                       || s.RNSPS_MIDDLE_NAME    AS org_name
                  FROM rnsp_main  t
                       JOIN rnsp_state s
                           ON (    s.rnsps_rnspm = t.rnspm_id
                               AND s.history_status = 'A')
                 WHERE t.rnspm_id = p_rnspm_id)
        LOOP
            RDM$RTFL.AddParam (l_jbr_id, 'org_name', xx.org_name);
            RDM$RTFL.AddParam (l_jbr_id,
                               'date',
                               TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
        END LOOP;

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    PROCEDURE register_report (p_rt_id      IN     NUMBER,
                               p_rnspm_id   IN     NUMBER,
                               p_start_dt   IN     DATE,
                               p_stop_dt    IN     DATE,
                               p_jbr_id        OUT DECIMAL)
    IS
        l_code   VARCHAR2 (50);
    BEGIN
        SELECT t.rt_code
          INTO l_code
          FROM rpt_templates t
         WHERE t.rt_id = p_rt_id;

        p_jbr_id :=
            CASE
                WHEN l_code = 'ORG_INFO_R1'
                THEN
                    ORG_INFO_R1 (p_rnspm_id, p_rt_id)
                ELSE
                    NULL
            END;
    END;
BEGIN
    NULL;
END;
/