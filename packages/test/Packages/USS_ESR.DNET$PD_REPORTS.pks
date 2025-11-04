/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PD_REPORTS
IS
    -- Author  : LEVCHENKO
    -- Created : 22.07.2021 15:09:02
    -- Purpose : Звіти для рішення про призначення допомоги

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

    --у випадку p_chk_val = p_val повертає галочку v_check_mark
    FUNCTION chk_val (p_chk_val VARCHAR2, p_val VARCHAR2)
        RETURN VARCHAR2;

    -- info:   Отримання друкованої форми "Рішення про припинення надання соціальних послуг" безпосередньо в БД
    -- params: p_rt_code - код шаблону шаблону
    --         p_at_id - ідентифікатор рішення
    -- note:   #87276
    FUNCTION get_decision_term_prov_ss_r1_blob (
        p_rt_code   IN rpt_templates.rt_code%TYPE,
        p_at_id     IN NUMBER)
        RETURN BLOB;

    -- info:   Отримання друкованої форми "Повідомлення про припинення надання соціальних послуг" безпосередньо в БД
    -- params: p_rt_code - код шаблону шаблону
    --         p_at_id - ідентифікатор рішення
    -- note:   #87278
    FUNCTION get_message_term_prov_ss_r1_blob (
        p_rt_code   IN rpt_templates.rt_code%TYPE,
        p_at_id     IN NUMBER)
        RETURN BLOB;

    -- info:   Ініціалізація процесу підготовки друкованої форми по рішенню
    -- params: p_rt_id - ідентифікатор шаблону
    --         p_pd_id - ідентифікатор рішення
    -- note:   #70506
    PROCEDURE reg_report (p_rt_id    IN     NUMBER,
                          p_pd_id    IN     NUMBER,
                          p_jbr_id      OUT DECIMAL);

    -----------------------------------------------------------------
    --Ініціалізація процесу підготовки звіту "Звіт щодо роботи в ЄСР"
    -----------------------------------------------------------------
    PROCEDURE reg_report_work_esr_get (p_com_org       appeal.com_org%TYPE,
                                       p_d_start       DATE,
                                       p_d_end         DATE,
                                       p_jbr_id    OUT NUMBER);

    -- info:   Отримання файла друкованої форми "Рішення" з додатковими параметрами для подальшої конвертації/збереження як документа
    -- params: p_pd_id - ідентифікатор рішення
    -- note:   #77050, #78724, #82581
    PROCEDURE get_decision (p_pd_id     IN     pc_decision.pd_id%TYPE,
                            p_doc_cur      OUT SYS_REFCURSOR);

    -- #81832: Нарахування по допомогам
    PROCEDURE accrual_help_rpt (p_dt       IN     DATE,
                                p_pd_nst   IN     NUMBER,
                                p_org_id   IN     NUMBER,
                                p_ap_src   IN     VARCHAR2,
                                res_cur       OUT SYS_REFCURSOR);

    -- #82138: Не виплачені кошти
    PROCEDURE not_pay_rpt (p_dt          IN     DATE,
                           p_pr_npc      IN     NUMBER,
                           p_org_id      IN     NUMBER,
                           p_prs_nb      IN     NUMBER,
                           p_pr_pay_tp   IN     VARCHAR2,
                           res_cur          OUT SYS_REFCURSOR);

    -- info:   Отримання вкладення для документа рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_ndt_id - ідентифікатор типу документа
    -- note:   #86747
    FUNCTION get_decision_doc_attach (p_pd_id NUMBER, p_ndt_id NUMBER)
        RETURN BLOB;

    FUNCTION reg_pay_order_report (p_po_id IN NUMBER)
        RETURN DECIMAL;


    -- info:   Отримання вкладення для документа акту про припинення
    -- params: p_at_id - ідентифікатор акту
    --         p_ndt_id - ідентифікатор типу документа
    -- note:
    FUNCTION get_act_term_doc_attach (p_at_id NUMBER, p_ndt_id NUMBER)
        RETURN BLOB;
END;
/


GRANT EXECUTE ON USS_ESR.DNET$PD_REPORTS TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PD_REPORTS TO II01RC_USS_ESR_RPT
/

GRANT EXECUTE ON USS_ESR.DNET$PD_REPORTS TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.DNET$PD_REPORTS TO USS_RPT
/


/* Formatted on 8/12/2025 5:49:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PD_REPORTS
IS
    v_check_mark      VARCHAR2 (200)
        := '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}';

    c_ekr1   CONSTANT VARCHAR2 (10) := '[' || CHR (1) || ']';            --"\"
    c_ekr2   CONSTANT VARCHAR2 (10) := '[' || CHR (2) || ']';            --"{"
    c_ekr3   CONSTANT VARCHAR2 (10) := '[' || CHR (3) || ']';            --"}"

    --c_chr10     constant varchar2(10) := '\par ';

    -- info:   Отримання коду шаблону по ідентифікатору
    -- params: p_rt_id - ідентифікатор шаблону
    -- note:
    FUNCTION get_rpt_code (p_rt_id IN rpt_templates.rt_id%TYPE)
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

    -- info:   Отримання ідентифікатора шаблону по коду
    -- params: p_rt_code - коду шаблону
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

    -- info:   Отримання шаблону звіту по коду
    -- params: p_rt_code - коду шаблону
    -- note:
    FUNCTION get_rpt_blob_by_code (p_rt_code rpt_templates.rt_code%TYPE)
        RETURN BLOB
    IS
        v_rt_blob   rpt_templates.rt_text%TYPE;
    BEGIN
        SELECT rt_text
          INTO v_rt_blob
          FROM v_rpt_templates
         WHERE rt_code = p_rt_code;

        RETURN v_rt_blob;
    END;

    FUNCTION org2ekr (p_value VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        --екранувати '\{}'
        IF Rdm$rtfl_Univ.Get_g_Bld_Tp = rdm$rtfl_univ.c_Bld_Tp_Db
        THEN
            RETURN REPLACE (
                       REPLACE (REPLACE (p_value, '\', c_ekr1), '{', c_ekr2),
                       '}',
                       c_ekr3);
        ELSE
            RETURN p_value;
        END IF;
    END;

    PROCEDURE AddParam (p_Param_Name VARCHAR2, p_Param_Value VARCHAR2)
    IS
    BEGIN
        rdm$rtfl_univ.addparam (p_Param_Name    => p_Param_Name,
                                p_Param_Value   => org2ekr (p_Param_Value));
    END;

    --заміна c_ekr1/c_ekr2/c_ekr3 на оригінальні символи
    PROCEDURE replace_ekr (p_result IN OUT BLOB)
    IS
        l_clob   CLOB;
    BEGIN
        IF Rdm$rtfl_Univ.Get_g_Bld_Tp = rdm$rtfl_univ.c_Bld_Tp_Db
        THEN
            DBMS_LOB.createtemporary (l_clob, TRUE, DBMS_LOB.SESSION);
            l_clob :=
                REPLACE (
                    REPLACE (
                        REPLACE (tools.ConvertB2C (p_result), c_ekr1, '\'),
                        c_ekr2,
                        '{'),
                    c_ekr3,
                    '}');
            p_result := tools.convertc2b (l_clob);
            DBMS_LOB.freetemporary (l_clob);
        END IF;
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

    -- info:   перевірка можливості отримання друкованої форми по наявності підписаних документів
    -- params: p_pd_id - ідентифікатор рішення
    --         p_ndt_id - ідентифікатор типу документа
    -- note:   #86747
    PROCEDURE check_signed_docs (p_pd_id NUMBER, p_ndt_id NUMBER)
    IS
    BEGIN
        FOR c
            IN (SELECT (SELECT t.ndt_name
                          FROM uss_ndi.v_ndi_document_type t
                         WHERE t.ndt_id = p_ndt_id)    AS doc_name
                  FROM v_pd_document  d
                       JOIN v_pd_signers s
                           ON     s.pdi_pdo = d.pdo_id
                              AND s.pdi_pd = p_pd_id
                              AND s.pdi_is_signed = 'T'
                 WHERE     d.pdo_pd = p_pd_id
                       AND d.pdo_ndt = p_ndt_id
                       AND d.history_status = 'A')
        LOOP
            raise_application_error (
                -20000,
                   'Заборонено отримання друкованої форму при наявності в рішенні підписаного документа  «'
                || c.doc_name
                || '»');
        END LOOP;
    END;

    PROCEDURE check_at_signed_docs (p_at_id NUMBER, p_ndt_id NUMBER)
    IS
    BEGIN
        FOR c
            IN (SELECT (SELECT t.ndt_name
                          FROM uss_ndi.v_ndi_document_type t
                         WHERE t.ndt_id = p_ndt_id)    AS doc_name
                  FROM v_at_document  d
                       JOIN v_at_signers s
                           ON     s.ati_atd = d.atd_id
                              AND s.ati_at = p_at_id
                              AND s.ati_is_signed = 'T'
                 WHERE     d.atd_at = p_at_id
                       AND d.atd_ndt = p_ndt_id
                       AND d.history_status = 'A')
        LOOP
            raise_application_error (
                -20000,
                   'Заборонено отримання друкованої форму при наявності в рішенні підписаного документа  «'
                || c.doc_name
                || '»');
        END LOOP;
    END;

    -- info:   Отримання кількості документів в зверненні
    -- params: p_ap_id - ідентифікатор звернення
    --         p_ndt_id - ідентифікатор типу документа
    -- note:
    FUNCTION get_doc_cnt (p_ap_id NUMBER, p_ndt_id NUMBER)
        RETURN NUMBER
    IS
        v_res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO v_res
          FROM v_ap_document
         WHERE     apd_ap = p_ap_id
               AND apd_ndt = p_ndt_id
               AND history_status = 'A';

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання назви документа
    -- params: p_ndt_id - ідентифікатор типу документа
    -- note:
    FUNCTION get_ndt_name (p_ndt_id NUMBER)
        RETURN NUMBER
    IS
        v_res   VARCHAR2 (4000);
    BEGIN
        SELECT ndt_name
          INTO v_res
          FROM uss_ndi.v_ndi_document_type
         WHERE ndt_id = p_ndt_id;

        RETURN v_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --#87820
    FUNCTION get_doc_atr_str (p_pd_id NUMBER, p_ndt NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        l_result   uss_esr.pd_document_attr.pdoa_val_string%TYPE;
    BEGIN
        SELECT MAX (da.pdoa_val_string)
          INTO l_result
          FROM uss_esr.pd_document d, uss_esr.pd_document_attr da
         WHERE     d.pdo_pd = p_pd_id
               AND d.pdo_ndt = p_ndt
               AND d.history_status = 'A'
               AND da.pdoa_pdo = d.pdo_id
               AND da.pdoa_nda = p_nda
               AND da.history_status = 'A';

        RETURN l_result;
    END;

    FUNCTION get_doc_atr_dt (p_pd_id NUMBER, p_ndt NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        l_result   uss_esr.pd_document_attr.pdoa_val_dt%TYPE;
    BEGIN
        SELECT MAX (da.pdoa_val_dt)
          INTO l_result
          FROM uss_esr.pd_document d, uss_esr.pd_document_attr da
         WHERE     d.pdo_pd = p_pd_id
               AND d.pdo_ndt = p_ndt
               AND d.history_status = 'A'
               AND da.pdoa_pdo = d.pdo_id
               AND da.pdoa_nda = p_nda
               AND da.history_status = 'A';

        RETURN CASE
                   WHEN l_result IS NOT NULL
                   THEN
                       TO_CHAR (l_result, 'dd.mm.yyyy')
               END;
    END;

    FUNCTION get_doc_atr_sum (p_pd_id NUMBER, p_ndt NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        l_result   uss_esr.pd_document_attr.pdoa_val_string%TYPE;
    BEGIN
        SELECT MAX (da.pdoa_val_sum)
          INTO l_result
          FROM uss_esr.pd_document d, uss_esr.pd_document_attr da
         WHERE     d.pdo_pd = p_pd_id
               AND d.pdo_ndt = p_ndt
               AND d.history_status = 'A'
               AND da.pdoa_pdo = d.pdo_id
               AND da.pdoa_nda = p_nda
               AND da.history_status = 'A';

        RETURN CASE
                   WHEN l_result IS NOT NULL
                   THEN
                       TO_CHAR (l_result,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
               END;
    END;

    --повертає атрибути в одну строку
    --p_nda = '2955, 2956, 2957'
    FUNCTION get_doc_atr_row (p_pd_id   NUMBER,
                              p_ndt     NUMBER,
                              p_nda     VARCHAR2,
                              dlmt      VARCHAR2:= ' ')
        RETURN VARCHAR2
    IS
        l_result   uss_esr.pd_document_attr.pdoa_val_string%TYPE;
    BEGIN
        FOR c IN (SELECT TO_NUMBER (COLUMN_VALUE) nda FROM XMLTABLE (p_nda))
        LOOP
            l_result :=
                l_result || dlmt || get_doc_atr_str (p_pd_id, p_ndt, c.nda);
        END LOOP;

        RETURN TRIM (l_result);
    END;

    FUNCTION get_at_doc_atr_str (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT MAX (a.atda_val_string)
              FROM at_document d, at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   at_document_attr.atda_val_string%TYPE;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION get_at_doc_atr_dt (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT MAX (a.atda_val_dt)
              FROM at_document d, at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   DATE;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN CASE WHEN r IS NOT NULL THEN TO_CHAR (r, 'dd.mm.yyyy') END;
    END;

    FUNCTION get_at_doc_atr_sum (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT MAX (a.atda_val_sum)
              FROM at_document d, at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   NUMBER;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN CASE
                   WHEN r IS NOT NULL
                   THEN
                       TO_CHAR (r,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
               END;
    END;

    FUNCTION get_at_doc_atr_id (p_at_id NUMBER, p_nda NUMBER)
        RETURN NUMBER
    IS
        CURSOR cur IS
            SELECT MAX (a.atda_val_id)
              FROM at_document d, at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   at_document_attr.atda_val_id%TYPE;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    --повертає атрибути в одну строку
    --p_nda = '2955, 2956, 2957'
    FUNCTION get_at_doc_atr_row (p_at_id   NUMBER,
                                 p_nda     VARCHAR2,
                                 dlmt      VARCHAR2:= ' ')
        RETURN VARCHAR2
    IS
        l_result   uss_esr.pd_document_attr.pdoa_val_string%TYPE;
    BEGIN
        FOR c IN (SELECT TO_NUMBER (COLUMN_VALUE) nda FROM XMLTABLE (p_nda))
        LOOP
            l_result :=
                l_result || dlmt || get_at_doc_atr_str (p_at_id, c.nda);
        END LOOP;

        RETURN TRIM (l_result);
    END;

    --p_nst = '123, 3451'
    FUNCTION get_nst (p_nst VARCHAR2)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (1000);
    BEGIN
        SELECT LISTAGG (st.nst_name, ', ')
                   WITHIN GROUP (ORDER BY st.nst_order)
          INTO l_res
          FROM uss_ndi.v_ndi_service_type st, XMLTABLE (p_nst) t
         WHERE st.nst_id IN TO_NUMBER (t.COLUMN_VALUE);

        RETURN l_res;
    END;

    --список соц.послуг
    FUNCTION AtSrv_Nst_List (p_at_id act.at_id%TYPE, p_tp NUMBER --1- надати, 0- відмовити
                                                                )
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT LISTAGG (s.ats_nst, ', ')
                       WITHIN GROUP (ORDER BY s.ats_nst)
              FROM uss_esr.at_service s         --uss_ndi.v_ddn_tctr_ats_st st
             WHERE     s.ats_at = p_at_id
                   AND s.history_status = 'A'
                   AND CASE
                           WHEN p_tp = 1 AND s.ats_st IN ('PP', 'SG', 'P')
                           THEN
                               1                                   --1- надати
                           WHEN p_tp = 0 AND s.ats_st IN ('PR', 'V')
                           THEN
                               1                                --0- відмовити
                       END =
                       1;

        l_res   VARCHAR2 (1000);
    BEGIN
        OPEN cur;

        FETCH cur INTO l_res;

        CLOSE cur;

        RETURN l_res;
    END;

    --у випадку p_chk_val = p_val повертає галочку v_check_mark
    FUNCTION chk_val (p_chk_val VARCHAR2, p_val VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_chk_val = p_val
        THEN
            RETURN org2ekr (v_check_mark);
        ELSE
            RETURN NULL;
        END IF;
    END;

    FUNCTION Get_adr (p_ind     VARCHAR2,
                      p_katot   VARCHAR2,
                      p_strit   VARCHAR2,
                      p_bild    VARCHAR2,
                      p_korp    VARCHAR2,
                      p_kv      VARCHAR2)
        RETURN VARCHAR2
    IS
        CURSOR c_adr IS
            SELECT    NVL2 (p_ind, p_ind || ' ', NULL)
                   || NVL2 (p_katot, p_katot || ', ', NULL)
                   || NVL2 (p_strit, p_strit || ' ', NULL)
                   || NVL2 (p_bild, p_bild || ' ', NULL)
                   || NVL2 (p_korp, 'корп.' || p_korp || ' ', NULL)
                   || NVL2 (p_kv, 'кв.' || p_kv, NULL)    adr
              FROM DUAL;

        r   VARCHAR2 (4000);
    BEGIN
        OPEN c_adr;

        FETCH c_adr INTO r;

        CLOSE c_adr;

        RETURN r;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Рішення"
    -- params: p_rt_id - ідентифікатор шаблону
    --         p_pd_id - ідентифікатор рішення
    -- note:   #70506, #72145
    FUNCTION assistance_decision (p_rt_id   IN rpt_templates.rt_id%TYPE,
                                  p_pd_id   IN NUMBER)
        RETURN DECIMAL
    IS
        v_jbr_id    NUMBER;
        v_rt_code   rpt_templates.rt_code%TYPE := get_rpt_code (p_rt_id);
        v_str       VARCHAR2 (4000);
        l_cnt       NUMBER;
    BEGIN
        --#77794 друкована форма для рішення про надання/відмову в наданні СП (SS)/#77873 «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу»
        FOR c
            IN (  SELECT pd.pd_id,
                         MAX (
                             COALESCE (
                                 (SELECT MAX (sc.sc_id)
                                    FROM v_pd_pay_method pm
                                         JOIN uss_person.v_socialcard sc
                                             ON sc.sc_scc = pm.pdm_scc
                                   WHERE     pm.pdm_pd = p_pd_id
                                         AND pm.history_status = 'A'
                                         AND pm.pdm_is_actual = 'T'),
                                 (SELECT pc.pc_sc
                                    FROM v_personalcase pc
                                   WHERE pc.pc_id = pd.pd_pc)))
                             AS pd_sc,
                         o.org_id,
                         o.org_name,
                         o.org_to,
                         pd.pd_st,
                         pd.pd_dt,
                         pd.pd_num,
                         MAX (
                             COALESCE (
                                 (SELECT pde_val_string
                                    FROM pd_features
                                   WHERE pde_pd = p_pd_id AND pde_nft = 9),
                                 (CASE
                                      WHEN     d.apd_ndt = 801
                                           AND da.apda_nda = 1872
                                      THEN
                                          da.apda_val_string
                                  END)))
                             AS ss_org_name,
                         MAX (CASE f.pde_nft WHEN 10 THEN f.pde_val_string END)
                             AS ss_pay_need,
                         MAX (
                             CASE
                                 WHEN pd.pd_st IN ('PV', 'AV', 'V')
                                 THEN
                                     (SELECT LISTAGG (njr_name || ';',
                                                      CHR (10) || '\par')
                                             WITHIN GROUP (ORDER BY
                                                               njr_order,
                                                               njr_code,
                                                               njr_name)    AS rej_info
                                        FROM v_pd_reject_info
                                             JOIN uss_ndi.v_ndi_reject_reason
                                                 ON njr_id = pri_njr
                                       WHERE pri_pd = p_pd_id)
                             END)
                             AS reject_reason,
                         a.ap_id,
                         a.ap_reg_dt,
                         a.ap_num,
                         a.ap_is_second,
                         a.com_org
                             AS ap_org,
                         MAX ( (SELECT st.nst_name
                                  FROM uss_ndi.v_ndi_service_type st
                                 WHERE st.nst_id = pd.pd_nst))
                             AS nst_name_list,
                         MAX ( (SELECT u.wu_pib
                                  FROM ikis_sysweb.v$all_users u
                                 WHERE u.wu_id = pd.com_wu))
                             AS wu_pib,
                         lt.sign_dt,
                         lt.sign_pib,
                         ic.pic_id,
                         ic.pic_total_income_6m,
                         ic.pic_month_income,
                         ic.pic_member_month_income,
                         ic.pic_limit,
                         lt.make_dt,
                         /*MAX(CASE
                               WHEN d.apd_ndt = 801 AND da.apda_nda = 1871 THEN
                                da.apda_val_string
                             END) AS p1871,
                         MAX(CASE
                               WHEN d.apd_ndt = 802 AND da.apda_nda = 1948 THEN
                                da.apda_val_string
                             END) AS p1948,*/
                         COALESCE (
                             MAX (
                                 CASE
                                     WHEN     d.apd_ndt IN (818, 819)
                                          AND da.apda_nda IN (2061, 2039)
                                     THEN
                                         da.apda_val_string
                                 END),
                             MAX (dda.pdoa_val_string))
                             AS f9,
                         MAX (CASE d.apd_ndt
                                  WHEN 803
                                  THEN
                                      (SELECT ndt_name
                                         FROM uss_ndi.v_ndi_document_type
                                        WHERE ndt_id = 803)
                              END)
                             AS ndt803_exist,
                         lt.appr_pib,
                         MAX (CASE f.pde_nft WHEN 32 THEN f.pde_val_string END)
                             AS f32,
                         MAX (CASE f.pde_nft WHEN 33 THEN f.pde_val_string END)
                             AS f33,
                         pd.pd_is_signed,
                         (CASE COUNT (
                                   CASE d.apd_ndt WHEN 801 THEN d.apd_id END)
                              WHEN 0
                              THEN
                                  (SELECT ndt_name
                                     FROM uss_ndi.v_ndi_document_type
                                    WHERE ndt_id = 801)
                          END)
                             AS ndt801_need
                    FROM v_pc_decision pd
                         JOIN v_opfu o ON o.org_id = pd.com_org
                         JOIN v_appeal a
                             ON a.ap_id = pd.pd_ap AND a.ap_tp = 'SS'
                         JOIN v_ap_person p
                             ON     p.app_ap = a.ap_id
                                AND p.app_tp = 'Z'
                                AND p.history_status = 'A'
                         LEFT JOIN v_ap_document d
                             ON     d.apd_ap = pd.pd_ap
                                AND d.apd_app = p.app_id
                                AND d.apd_ndt IN (801,                /*802,*/
                                                  803,
                                                  818,
                                                  819)
                                AND d.history_status = 'A'
                         LEFT JOIN v_ap_document_attr da
                             ON     da.apda_ap = pd.pd_ap
                                AND da.apda_apd = d.apd_id
                                AND da.apda_nda IN (                 /*1871,*/
                                                    1872,            /*1948,*/
                                                          2039, 2061)
                                AND da.history_status = 'A'
                         LEFT JOIN uss_esr.v_pd_document dd
                         JOIN uss_esr.pd_document_attr dda
                             ON     dda.pdoa_pd = p_pd_id
                                AND dda.pdoa_pdo = dd.pdo_id
                                AND dda.pdoa_nda IN (2061, 2039)
                                AND dda.history_status = 'A'
                             ON     dd.pdo_pd = p_pd_id
                                AND dd.pdo_ap = pd.pd_ap
                                AND COALESCE (dd.pdo_app, p.app_id) = p.app_id
                                AND dd.pdo_ndt IN (818, 819)
                                AND dd.history_status = 'A'
                         JOIN
                         (SELECT MAX (make_dt)      AS make_dt,
                                 MAX (sign_dt)      AS sign_dt,
                                 MAX (sign_pib)     AS sign_pib,
                                 MAX (appr_pib)     AS appr_pib
                            FROM (SELECT FIRST_VALUE (
                                             (CASE l.pdl_st
                                                  WHEN 'WD' THEN h.hs_dt
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS make_dt,
                                         FIRST_VALUE (
                                             (CASE l.pdl_st
                                                  WHEN 'P' THEN h.hs_dt
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS sign_dt,
                                         FIRST_VALUE (
                                             (CASE l.pdl_st
                                                  WHEN 'P' THEN u.wu_pib
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS sign_pib,
                                         FIRST_VALUE (
                                             (CASE
                                                  WHEN    (    l.pdl_st = 'WD'
                                                           AND l.pdl_st_old =
                                                               'R1')
                                                       OR (    l.pdl_st = 'AV'
                                                           AND l.pdl_st_old =
                                                               'PV')
                                                  THEN
                                                      u.wu_pib
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS appr_pib
                                    FROM v_pd_log l
                                         JOIN v_histsession h
                                             ON h.hs_id = l.pdl_hs
                                         JOIN ikis_sysweb.v$all_users u
                                             ON u.wu_id = h.hs_wu
                                   WHERE     l.pdl_pd = p_pd_id
                                         AND l.pdl_st IN ('WD', 'P', 'AV'))) lt
                             ON 1 = 1
                         LEFT JOIN v_pd_income_calc ic ON ic.pic_pd = p_pd_id
                         LEFT JOIN v_pd_features f
                             ON     f.pde_pd = p_pd_id
                                AND f.pde_nft IN (10, 32, 33)
                   WHERE pd.pd_id = p_pd_id
                GROUP BY pd.pd_id,
                         o.org_id,
                         o.org_name,
                         o.org_to,
                         pd.pd_st,
                         pd.pd_dt,
                         pd.pd_num,
                         a.ap_id,
                         a.ap_reg_dt,
                         a.ap_num,
                         a.ap_is_second,
                         a.com_org,
                         lt.sign_dt,
                         lt.sign_pib,
                         ic.pic_id,
                         ic.pic_total_income_6m,
                         ic.pic_month_income,
                         ic.pic_member_month_income,
                         ic.pic_limit,
                         lt.make_dt,
                         lt.appr_pib,
                         pd.pd_is_signed)
        LOOP
            --#77050 заборонено формування рішення при наявності документа «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803
            IF c.ndt803_exist IS NOT NULL OR get_doc_cnt (c.ap_id, 803) > 0
            THEN
                raise_application_error (
                    -20000,
                       'Звернення було створено на основі документа «'
                    || COALESCE (c.ndt803_exist, get_ndt_name (803))
                    || '», для якого відсутні друковані форми Рішення/Повідомлення');
            ELSIF     c.ndt801_need IS NOT NULL
                  AND get_doc_cnt (c.ap_id, 801) = 0
            THEN                                                      --#86747
                raise_application_error (
                    -20000,
                       'В зверненні відсутній ініціативний документ «'
                    || c.ndt801_need
                    || '»');
            ELSIF c.pd_is_signed = 'T'
            THEN
                raise_application_error (
                    -20000,
                    'Підписані рішення недоступні для формування!');
            END IF;

            --#79593/#77873 формування «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу»
            IF /*c.pd_st NOT IN ('PV', 'AV', 'V') AND (c.p1871 = 'T' OR c.p1948 = 'T')*/
               c.f32 = 'T' AND c.f33 = 'T' AND c.ap_org = tools.getcurrorg
            THEN
                check_signed_docs (p_pd_id => p_pd_id, p_ndt_id => 852);
                v_jbr_id :=
                    rdm$rtfl.initreport (
                        get_rt_by_code ('PLACEMENT_APPLICATION_R1'));

                IF c.org_to > 31
                THEN
                        SELECT MAX (
                                   CASE
                                       WHEN po.org_to IN (31, 34)
                                       THEN
                                           po.org_name
                                   END)
                          INTO v_str
                          FROM v_opfu po
                         WHERE po.org_st = 'A'
                    START WITH po.org_id =
                               COALESCE (c.org_id, tools.getcurrorg)
                    CONNECT BY PRIOR po.org_org = po.org_id;
                END IF;

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p1',
                    COALESCE (v_str,
                              c.org_name,
                              '________________________________'));

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p2',
                    COALESCE (
                        uss_person.api$sc_tools.get_pib (c.pd_sc),
                           '________________________________________________________________\par'
                        || '(прізвище, ім’я, по батькові (за наявності) заявника)\par'
                        || '______________________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p3',
                    COALESCE (TO_CHAR (c.ap_reg_dt, 'DD.MM.YYYY'),
                              '_______________'));
                rdm$rtfl.addparam (v_jbr_id,
                                   'p4',
                                   COALESCE (c.ap_num, '________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p5',
                    COALESCE (
                        c.org_name,
                        '____________________________________________________________________________________\par'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p6',
                    COALESCE (
                        uss_person.api$sc_tools.get_pib (c.pd_sc),
                           '____________________________________________________________________________________\par'
                        || '\fs20                                (прізвище, ім.’я, по батькові (за наявності) особи, яка потребує надання соціальних послуг) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p7',
                    COALESCE (
                        (CASE c.ss_pay_need
                             WHEN 'F'
                             THEN
                                 '\ul безоплатно \ul0 , платно, з установленням диференційованої плати'
                             WHEN 'C'
                             THEN
                                 'безоплатно, \ul платно \ul0 , з установленням диференційованої плати'
                             WHEN 'D'
                             THEN
                                 'безоплатно, платно, \ul з установленням диференційованої плати \ul0'
                         END),
                        'безоплатно, платно, з установленням диференційованої плати'));

                SELECT LISTAGG (ndt_name, ', ')
                           WITHIN GROUP (ORDER BY ndt_order)
                  INTO v_str
                  FROM (SELECT DISTINCT dt.ndt_name, dt.ndt_order
                          FROM v_ap_document  d
                               JOIN uss_ndi.v_ndi_document_type dt
                                   ON dt.ndt_id = d.apd_ndt
                         WHERE d.apd_ap = c.ap_id AND d.history_status = 'A');

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p8',
                    COALESCE (v_str,
                              'пакет документів (зазначити повний перелік)'));

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p81',
                    (CASE
                         WHEN c.nst_name_list IS NOT NULL
                         THEN
                             ' ' || c.nst_name_list
                     END));
                /*#87820
                rdm$rtfl.addparam(v_jbr_id, 'p9', coalesce(NULL, '__________________\par' || '\fs20              (посада) \fs24'));
                rdm$rtfl.addparam(v_jbr_id,
                                  'p10',
                                  coalesce(c.sign_pib,
                                           '_________________________________________\par' ||
                                           '\fs20                (прізвище, ім’я, по батькові (за наявності)) \fs24'));*/
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p9',
                    COALESCE (
                        get_doc_atr_str (p_pd_id   => p_pd_id,
                                         p_ndt     => 852,
                                         p_nda     => 2993),
                           '__________________\par'
                        || '\fs20              (посада) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p10',
                    COALESCE (
                        get_doc_atr_row (p_pd_id, 852, '2994, 2995, 2996'),
                           '_________________________________________\par'
                        || '\fs20                (прізвище, ім’я, по батькові (за наявності)) \fs24'));                                   --#87820

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p11',
                    COALESCE (TO_CHAR (c.sign_dt, 'DD.MM.YYYY'),
                              '___  _______________ 20___'));
            ELSE
                check_signed_docs (p_pd_id => p_pd_id, p_ndt_id => 850);
                --#77794/#83639 друкована форма для рішення про надання/відмову в наданні СП (SS)
                v_jbr_id :=
                    rdm$rtfl.initreport (
                        get_rt_by_code ('ASSISTANCE_DECISION_R2')); --одна форма на відмову і на підтвердження
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p1',
                    COALESCE (
                        TO_CHAR (c.pd_dt, 'DD.MM.YYYY'),
                           '____________________\par'
                        || '\fs20      (число, місяць, рік) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p2',
                    COALESCE (
                        c.pd_num,
                           '____________________\par'
                        || '\fs20             (номер рішення) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p3',
                    COALESCE (
                        c.org_name,
                        '_____________________________________________________________________________________\par'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p4',
                    COALESCE (TO_CHAR (c.ap_reg_dt, 'DD.MM.YYYY'),
                              '________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p5',
                    COALESCE (c.ap_num, '_______________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p6',
                    (CASE c.ap_is_second
                         WHEN 'T' THEN 'первинне/ \ul повторне \ul0'
                         ELSE '\ul первинне \ul0 /повторне'
                     END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p7',
                    COALESCE (
                        uss_person.api$sc_tools.get_pib (c.pd_sc),
                           '_____________________________________________________________________________\par'
                        || '\fs20                                               (прізвище, ім’я, по батькові (за наявності) заявника / законного представника/\par'
                        || '                                                                                   уповноваженого представника сім’ї) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p8',
                    COALESCE (
                        uss_person.api$sc_tools.get_pib (c.pd_sc),
                           '___________________________________\par'
                        || '____________________________________________________________________________________\par'
                        || '\fs20                                                                                 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p9',
                    COALESCE (
                        (CASE c.f9
                             WHEN 'F'
                             THEN
                                 'Сім''я/особа не потребує надання соціальних послуг'
                             WHEN 'T'
                             THEN
                                 'Сім''я/особа потребує надання соціальних послуг'
                         END),
                           '_____________________________________________\par'
                        || '\fs20                                                                                                                       (зазначити результат оцінювання потреб) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p10',
                    COALESCE (
                        TO_CHAR (c.pic_member_month_income,
                                 'FM9G999G999G999G999G990D00',
                                 'NLS_NUMERIC_CHARACTERS=''.'''''),
                        '________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p11',
                    COALESCE (
                           (CASE
                                WHEN c.nst_name_list IS NOT NULL
                                THEN
                                    '\ul надати соціальну послугу \ul0 '
                            END)
                        || c.nst_name_list,
                           'надати соціальну послугу ____________________________________________________________\par'
                        || '\fs20                                                                                                                      (назва соціальної послуги) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p121',
                    (CASE c.ss_pay_need WHEN 'F' THEN v_check_mark END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p122',
                    (CASE c.ss_pay_need WHEN 'C' THEN v_check_mark END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p123',
                    (CASE c.ss_pay_need WHEN 'D' THEN v_check_mark END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p13',
                    COALESCE (
                        TO_CHAR (c.pic_limit,
                                 'FM9G999G999G999G999G990D00',
                                 'NLS_NUMERIC_CHARACTERS=''.'''''),
                        '___________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p14',
                    COALESCE (
                        c.ss_org_name,
                           '____________________________________________________________\par'
                        || '\fs20                                                                                     (найменування установи, закладу, підприємства, організації) \fs24\par'
                        || '___________________________________________________________________________________  '));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p15',
                    COALESCE (
                        (CASE
                             WHEN c.pd_st IN ('PV', 'AV', 'V')
                             THEN
                                    (CASE
                                         WHEN c.nst_name_list IS NOT NULL
                                         THEN
                                             '\ul відмовити в наданні соціальної послуги \ul0 '
                                     END)
                                 || c.nst_name_list
                         END),
                           'відмовити в наданні соціальної послуги _______________________________________________\par'
                        || '\fs20                                                                                                                                   (назва соціальної(их) послуги) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p16',
                    COALESCE (
                        (CASE
                             WHEN c.pd_st IN ('PV', 'AV', 'V')
                             THEN
                                 c.reject_reason
                         END),
                           '_______________________________________________________________________________\par'
                        || '\fs20                                                                                           (причина відмови) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p17',
                    COALESCE (
                        NULL,
                           '__________________________\par'
                        || '\fs20                        (посада) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p18',
                    COALESCE (
                        CASE
                            WHEN get_doc_atr_str (p_pd_id, 850, 2955)
                                     IS NOT NULL
                            THEN                                      --#86997
                                   get_doc_atr_str (p_pd_id, 850, 2955)
                                || ' '
                                || get_doc_atr_str (p_pd_id, 850, 2956)
                                || ' '
                                || get_doc_atr_str (p_pd_id, 850, 2957)
                        END,
                        c.wu_pib,
                           '____________________________________\par'
                        || '\fs20         (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                rdm$rtfl.addparam (v_jbr_id,
                                   'p181',
                                   COALESCE (c.wu_pib, '_________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p19',
                    COALESCE (
                        NULL,
                           '__________________________\par'
                        || '\fs20                        (посада) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p20',
                    COALESCE (
                        CASE
                            WHEN get_doc_atr_str (p_pd_id, 850, 2958)
                                     IS NOT NULL
                            THEN                                      --#86997
                                   get_doc_atr_str (p_pd_id, 850, 2958)
                                || ' '
                                || get_doc_atr_str (p_pd_id, 850, 2959)
                                || ' '
                                || get_doc_atr_str (p_pd_id, 850, 2960)
                        END,
                        c.sign_pib,
                           '____________________________________\par'
                        || '\fs20         (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p21',
                    COALESCE (TO_CHAR (c.sign_dt, 'DD.MM.YYYY'),
                              '___  ___________________ 20___'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p52',
                    COALESCE (
                        TO_CHAR (c.pic_total_income_6m,
                                 'FM9G999G999G999G999G990D00',
                                 'NLS_NUMERIC_CHARACTERS=''.'''''),
                        '_________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p53',
                    COALESCE (
                        TO_CHAR (c.pic_month_income,
                                 'FM9G999G999G999G999G990D00',
                                 'NLS_NUMERIC_CHARACTERS=''.'''''),
                        '_________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p54',
                    COALESCE (
                        TO_CHAR (c.pic_member_month_income,
                                 'FM9G999G999G999G999G990D00',
                                 'NLS_NUMERIC_CHARACTERS=''.'''''),
                        '_________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p55',
                    COALESCE (
                        TO_CHAR (c.pic_limit,
                                 'FM9G999G999G999G999G990D00',
                                 'NLS_NUMERIC_CHARACTERS=''.'''''),
                        '_________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p56',
                    COALESCE (TO_CHAR (c.make_dt, 'DD.MM.YYYY'), '_________'));

                rdm$rtfl.adddataset (
                    v_jbr_id,
                    'ds',
                       q'[SELECT row_number() over(ORDER BY c2, c3) AS c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
    FROM (SELECT t.app_id,
                 pt.dic_sname AS c2,
                 uss_person.api$sc_tools.get_pib(t.app_sc) AS c3,
                 td.rltn_tp AS c4,
                 td.doc AS c5,
                 tt.inc_tp AS c6,
                 to_char(SUM(coalesce(t.pid_calc_sum, 0)), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c7,
                 to_char(MAX(CASE WHEN t.pid_month = add_months(t.last_month, -2) THEN t.pid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  || ' \par ' ||
                 to_char(SUM(CASE WHEN t.pid_month = add_months(t.last_month, -2) THEN t.pid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c8,
                 to_char(MAX(CASE WHEN t.pid_month = add_months(t.last_month, -1) THEN t.pid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  ||' \par '||
                 to_char(SUM(CASE WHEN t.pid_month = add_months(t.last_month, -1) THEN t.pid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c9,
                 to_char(MAX(CASE WHEN t.pid_month = t.last_month THEN t.pid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian') || ' \par ' ||
                 to_char(SUM(CASE WHEN t.pid_month = t.last_month THEN t.pid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c10
            FROM (SELECT ap.app_id, ap.app_sc, ap.app_tp, pd.pid_month, pd.pid_calc_sum, MAX(pd.pid_month) over(PARTITION BY ap.app_id) AS last_month
                    FROM uss_esr.v_ap_person ap
                    JOIN uss_esr.v_pd_income_detail pd ON pd.pid_app = ap.app_id
                                                      AND pd.pid_sc = ap.app_sc
                                                      AND pd.pid_is_family_member = 'T']'
                    || (CASE
                            WHEN c.pic_id IS NOT NULL
                            THEN
                                   '
                                                      AND pd.pid_pic = '
                                || TO_CHAR (c.pic_id)
                        END)
                    || '
                   WHERE ap.app_ap = '
                    || TO_CHAR (c.ap_id)
                    || q'[
                     AND ap.history_status = 'A'
                     AND ap.app_tp IN ('Z', 'FM', 'OS')) t
            JOIN uss_ndi.v_ddn_app_tp pt ON pt.dic_value = t.app_tp
            LEFT JOIN (SELECT d.apd_app,
                             MAX(CASE
                                   WHEN da.apda_nda = 813 AND da.apda_val_string IS NOT NULL
                                     THEN (SELECT t.dic_name FROM uss_ndi.v_ddn_relation_tp t WHERE t.dic_value = da.apda_val_string)
                                 END) AS rltn_tp,
                             coalesce(MAX(CASE da.apda_nda WHEN 1 THEN da.apda_val_string END),
                                      MAX(CASE WHEN da.apda_nda IN (3, 9) THEN da.apda_val_string END)) AS doc
                        FROM uss_esr.v_ap_document d
                        JOIN uss_esr.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                          AND da.apda_ap = ]'
                    || TO_CHAR (c.ap_id)
                    || q'[
                                                          AND da.apda_nda IN (1, 3, 9, 813)
                                                          AND da.history_status = 'A'
                       WHERE d.apd_ap = ]'
                    || TO_CHAR (c.ap_id)
                    || q'[
                         AND d.apd_ndt IN (5, 6, 7, 605)
                         AND d.history_status = 'A'
                       GROUP BY d.apd_app) td ON td.apd_app = t.app_id
            LEFT JOIN (SELECT pis_app, pis_sc, listagg(dic_sname, ', ') within GROUP(ORDER BY dic_srtordr) AS inc_tp
                         FROM (SELECT DISTINCT s.pis_app, s.pis_sc, st.dic_sname, st.dic_srtordr
                                 FROM uss_esr.v_pd_income_src s
                                 JOIN uss_ndi.v_ddn_apri_tp st ON st.dic_value = s.pis_tp
                                WHERE s.pis_pd = ]'
                    || TO_CHAR (p_pd_id)
                    || q'[)
                        GROUP BY pis_app, pis_sc) tt ON tt.pis_app = t.app_id
                                                    AND tt.pis_sc = t.app_sc
           WHERE t.pid_month >= add_months(t.last_month, -2)
           GROUP BY t.app_id, pt.dic_sname, t.app_sc, td.rltn_tp, td.doc, tt.inc_tp)]');
            END IF;

            rdm$rtfl.putreporttoworkingqueue (v_jbr_id);
        END LOOP;

        IF v_jbr_id IS NOT NULL
        THEN
            RETURN v_jbr_id;
        ELSE
            --#72145 тип друкованої форми залежить від статусу рішення/#73661/#74090 - різне наповнення для допомоги з Ід=248, Ід=249 та інших
            FOR data_cur
                IN (SELECT pd.pd_num,
                           TO_CHAR (pd.pd_dt, 'DD.MM.YYYY')
                               AS pd_date,
                           pc.pc_id,
                           pc.pc_sc,
                           pc.pc_num
                               AS pers_case_num,
                           pa.pa_num
                               AS pers_acc_num,
                           (CASE pm.pdm_pay_tp
                                WHEN 'BANK'
                                THEN
                                       (CASE st.nst_id
                                            WHEN 664
                                            THEN
                                                (SELECT dic_name
                                                   FROM uss_ndi.v_ddn_apm_tp
                                                  WHERE dic_value =
                                                        pm.pdm_pay_tp)
                                        END)
                                    || CHR (10)
                                    || '\par Банківська установа: '
                                    || b.nb_name
                                    || --#80742
                                       (CASE
                                            WHEN st.nst_id != 664
                                            THEN
                                                   CHR (10)
                                                || '\par Номер банківської установи: '
                                                || CHR (10)
                                                || '\par Номер відділення: '
                                        END)
                                    || CHR (10)
                                    || '\par Номер вкладу: '
                                    || pm.pdm_account
                                WHEN 'POST'
                                THEN
                                       (CASE st.nst_id
                                            WHEN 664
                                            THEN
                                                (SELECT dic_name
                                                   FROM uss_ndi.v_ddn_apm_tp
                                                  WHERE dic_value =
                                                        pm.pdm_pay_tp)
                                        END)
                                    || CHR (10)
                                    || '\par Підприємство зв’язку: '
                                    || k.kaot_name
                                    || CHR (10)
                                    || '\par №: '
                                    || pm.pdm_index
                            END)
                               pay_tp_info,
                           COALESCE (
                               TRIM (
                                      i.sci_ln
                                   || ' '
                                   || i.sci_fn
                                   || ' '
                                   || i.sci_mn),
                               uss_person.api$sc_tools.get_pib (
                                   COALESCE (sc.sc_id, pc.pc_sc)))
                               AS app_name,
                           COALESCE (
                               (  SELECT p.scd_seria || p.scd_number
                                    FROM uss_person.v_sc_document p
                                   WHERE     p.scd_sc =
                                             COALESCE (sc.sc_id, pc.pc_sc)
                                         AND p.scd_ndt = 5
                                         AND p.scd_st IN ('A', '1')
                                ORDER BY TO_NUMBER (p.scd_start_dt) DESC
                                   FETCH FIRST ROW ONLY),
                               uss_person.api$sc_tools.get_numident (
                                   COALESCE (sc.sc_id, pc.pc_sc)))
                               AS app_code,
                           TO_CHAR (ap.ap_reg_dt, 'DD.MM.YYYY')
                               AS appeal_dt,
                           (SELECT DISTINCT
                                   FIRST_VALUE (da.apda_val_dt)
                                       OVER (
                                           ORDER BY
                                               (CASE dt.ndt_id
                                                    WHEN 600 THEN 10
                                                    ELSE dt.ndt_order
                                                END))
                              FROM v_ap_document  d
                                   JOIN uss_ndi.v_ndi_document_type dt
                                       ON     dt.ndt_id = d.apd_ndt
                                          AND (   dt.ndt_ndc = 13
                                               OR dt.ndt_id = 600)
                                   JOIN v_ap_document_attr da
                                       ON     da.apda_apd = d.apd_id
                                          AND da.apda_val_dt IS NOT NULL
                                   JOIN uss_ndi.v_ndi_document_attr a
                                       ON     a.nda_id = da.apda_nda
                                          AND a.nda_class = 'BDT'
                             WHERE     d.history_status = 'A'
                                   AND d.apd_ap = pd.pd_ap
                                   AND d.apd_app IN
                                           (SELECT p.app_id
                                              FROM v_ap_person p
                                             WHERE     p.app_ap = pd.pd_ap
                                                   AND p.app_tp = 'Z'
                                                   AND p.app_sc =
                                                       COALESCE (sc.sc_id,
                                                                 pc.pc_sc)
                                                   AND p.history_status = 'A'))
                               AS app_brth_dt, --дату народження необхідно брати із заяви (#73316) або із паспорта (#77940)/#80742
                           (SELECT LISTAGG (
                                       n.nda_name || ' ' || a.apda_val_string,
                                       ' ')
                                   WITHIN GROUP (ORDER BY n.nda_order)
                              FROM v_ap_document_attr  a
                                   JOIN v_ap_document d
                                       ON     a.apda_apd = d.apd_id
                                          AND d.apd_ndt = 600
                                          AND d.apd_app IN
                                                  (SELECT p.app_id
                                                     FROM v_ap_person p
                                                    WHERE     p.app_ap =
                                                              pd.pd_ap
                                                          AND p.app_tp = 'Z'
                                                          AND p.app_sc =
                                                              COALESCE (
                                                                  sc.sc_id,
                                                                  pc.pc_sc)
                                                          AND p.history_status =
                                                              'A')
                                          AND d.history_status = 'A'
                                   JOIN uss_ndi.v_ndi_document_attr n
                                       ON     a.apda_nda = n.nda_id
                                          AND n.nda_nng = 2
                             WHERE     a.apda_ap = pd.pd_ap
                                   AND a.history_status = 'A'
                                   AND a.apda_val_string IS NOT NULL)
                               AS app_fact_addr,
                           (SELECT LISTAGG (
                                       n.nda_name || ' ' || a.apda_val_string,
                                       ' ')
                                   WITHIN GROUP (ORDER BY n.nda_order)
                              FROM v_ap_document_attr  a
                                   JOIN v_ap_document d
                                       ON     a.apda_apd = d.apd_id
                                          AND d.apd_ndt = 10314
                                          AND d.apd_app IN
                                                  (SELECT p.app_id
                                                     FROM v_ap_person p
                                                    WHERE     p.app_ap =
                                                              pd.pd_ap
                                                          AND p.app_tp = 'Z'
                                                          AND p.app_sc =
                                                              COALESCE (
                                                                  sc.sc_id,
                                                                  pc.pc_sc)
                                                          AND p.history_status =
                                                              'A')
                                          AND d.history_status = 'A'
                                   JOIN uss_ndi.v_ndi_document_attr n
                                       ON     a.apda_nda = n.nda_id
                                          AND n.nda_nng = 2
                             WHERE     a.apda_ap = pd.pd_ap
                                   AND a.history_status = 'A'
                                   AND a.apda_val_string IS NOT NULL)
                               AS app_fact_addr_21,
                           (CASE v_rt_code
                                WHEN 'ASSISTANCE_DECISION_R1'
                                THEN
                                    TO_CHAR (pc.pc_create_dt, 'DD.MM.YYYY')
                            END)
                               AS pers_acc_dt,
                           st.nst_id,
                           st.nst_name,
                           (CASE v_rt_code
                                WHEN 'PAY_REJECT_DECISION_R1'
                                THEN
                                    (SELECT LISTAGG (
                                                   njr_code
                                                || ' '
                                                || njr_name
                                                || ';',
                                                CHR (10) || '\par')
                                            WITHIN GROUP (ORDER BY
                                                              njr_order,
                                                              njr_code,
                                                              njr_name)
                                       FROM v_pd_reject_info
                                            JOIN uss_ndi.v_ndi_reject_reason
                                                ON njr_id = pri_njr
                                      WHERE pri_pd = p_pd_id)
                            END)
                               AS reject_reason,
                           (CASE st.nst_id
                                WHEN 249
                                THEN
                                    (SELECT (CASE
                                                 WHEN SUM (
                                                          COALESCE (pdp_sum,
                                                                    0)) >
                                                      0
                                                 THEN
                                                     LISTAGG (
                                                            '\par Розмір соціальної допомоги з '
                                                         || TO_CHAR (
                                                                pdp_start_dt,
                                                                'DD.MM.YYYY')
                                                         || ' по '
                                                         || TO_CHAR (
                                                                pdp_stop_dt,
                                                                'DD.MM.YYYY')
                                                         || ' '
                                                         || TO_CHAR (
                                                                pdp_sum,
                                                                'FM9G999G999G999G999G990D00',
                                                                'NLS_NUMERIC_CHARACTERS=''.'''''),
                                                         ' ')
                                                     WITHIN GROUP (ORDER BY
                                                                       pdp_start_dt,
                                                                       pdp_stop_dt)
                                                 ELSE
                                                     '\par Відмовлено у призначенні допомоги в зв’язку із тим, що середньомісячний сукупний дохід перевищує розмір рівня забезпечення прожиткового мінімуму для сім’ї' --#85333
                                             END)
                                       FROM v_pd_payment pz
                                      WHERE     pdp_pd = p_pd_id
                                            AND pz.history_status = 'A')
                            END)
                               AS pay_info_lines,
                           (CASE st.nst_id
                                WHEN 248
                                THEN
                                    (   '\par Заявник                                                       : '
                                     || (CASE
                                             WHEN (SELECT a.apda_val_string
                                                     FROM v_ap_document_attr
                                                          a
                                                          JOIN
                                                          v_ap_document d
                                                              ON     a.apda_apd =
                                                                     d.apd_id
                                                                 AND d.apd_ndt =
                                                                     605
                                                                 AND d.apd_app IN
                                                                         (SELECT p.app_id
                                                                            FROM v_ap_person
                                                                                     p
                                                                           WHERE     p.app_ap =
                                                                                     pd.pd_ap
                                                                                 AND p.app_tp =
                                                                                     'Z'
                                                                                 AND p.app_sc =
                                                                                     COALESCE (
                                                                                         sc.sc_id,
                                                                                         pc.pc_sc)
                                                                                 AND p.history_status =
                                                                                     'A')
                                                                 AND d.history_status =
                                                                     'A'
                                                    WHERE     a.apda_ap =
                                                              pd.pd_ap
                                                          AND a.history_status =
                                                              'A'
                                                          AND a.apda_nda =
                                                              650) =
                                                  'T'
                                             THEN
                                                 'Працює'
                                             WHEN (SELECT a.apda_val_string
                                                     FROM v_ap_document_attr
                                                          a
                                                          JOIN
                                                          v_ap_document d
                                                              ON     a.apda_apd =
                                                                     d.apd_id
                                                                 AND d.apd_ndt =
                                                                     605
                                                                 AND d.apd_app IN
                                                                         (SELECT p.app_id
                                                                            FROM v_ap_person
                                                                                     p
                                                                           WHERE     p.app_ap =
                                                                                     pd.pd_ap
                                                                                 AND p.app_tp =
                                                                                     'Z'
                                                                                 AND p.app_sc =
                                                                                     COALESCE (
                                                                                         sc.sc_id,
                                                                                         pc.pc_sc)
                                                                                 AND p.history_status =
                                                                                     'A')
                                                                 AND d.history_status =
                                                                     'A'
                                                    WHERE     a.apda_ap =
                                                              pd.pd_ap
                                                          AND a.history_status =
                                                              'A'
                                                          AND a.apda_nda =
                                                              663) =
                                                  'T'
                                             THEN
                                                 'Не працює'
                                         END)
                                     || '\par Додаткові відомості про заявника       :'
                                     || (CASE
                                             WHEN (SELECT a.apda_val_string
                                                     FROM v_ap_document_attr
                                                          a
                                                          JOIN
                                                          v_ap_document d
                                                              ON     a.apda_apd =
                                                                     d.apd_id
                                                                 AND d.apd_ndt =
                                                                     605
                                                                 AND d.apd_app IN
                                                                         (SELECT p.app_id
                                                                            FROM v_ap_person
                                                                                     p
                                                                           WHERE     p.app_ap =
                                                                                     pd.pd_ap
                                                                                 AND p.app_tp =
                                                                                     'Z'
                                                                                 AND p.app_sc =
                                                                                     COALESCE (
                                                                                         sc.sc_id,
                                                                                         pc.pc_sc)
                                                                                 AND p.history_status =
                                                                                     'A')
                                                                 AND d.history_status =
                                                                     'A'
                                                    WHERE     a.apda_ap =
                                                              pd.pd_ap
                                                          AND a.history_status =
                                                              'A'
                                                          AND a.apda_nda =
                                                              641) =
                                                  'T'
                                             THEN
                                                 'одинокий/одинока'
                                         END))
                            END)
                               AS app_add_info,
                           (SELECT COALESCE (MAX (zdd.dnd_value), 0)
                              FROM deduction  zd
                                   JOIN pc_state_alimony a
                                       ON (a.ps_id = zd.dn_ps)
                                   JOIN dn_detail zdd
                                       ON (zdd.dnd_dn = zd.dn_id)
                             WHERE     1 = 1
                                   AND zd.dn_pc = pd.pd_pc
                                   AND TRUNC (SYSDATE) BETWEEN a.ps_start_dt
                                                           AND COALESCE (
                                                                   a.ps_stop_dt,
                                                                   SYSDATE)
                                   AND zdd.dnd_tp = 'PD'
                                   AND dn_debt_current IS NOT NULL
                                   AND dn_debt_current != 0)
                               AS dn_percentage,
                           --ap.ap_id,
                           COALESCE (pd.pd_ap_reason, pd.pd_ap)
                               AS ap_id, -- 85007 (для врахування змін складу корегуючим зверненням)
                           pd.pd_is_signed
                      FROM v_pc_decision  pd
                           JOIN v_pc_account pa ON pa.pa_id = pd.pd_pa
                           JOIN v_personalcase pc ON pc.pc_id = pd.pd_pc
                           JOIN v_appeal ap ON ap.ap_id = pd.pd_ap
                           JOIN uss_ndi.v_ndi_service_type st
                               ON st.nst_id = pd.pd_nst
                           LEFT JOIN v_pd_pay_method pm
                               ON     pm.pdm_pd = p_pd_id
                                  AND pm.history_status = 'A'
                                  AND pm.pdm_is_actual = 'T'
                           LEFT JOIN uss_ndi.v_ndi_katottg k
                               ON k.kaot_id = pm.pdm_kaot
                           LEFT JOIN uss_ndi.v_ndi_bank b
                               ON b.nb_id = pm.pdm_nb
                           LEFT JOIN uss_person.v_socialcard sc
                               ON sc.sc_scc = pm.pdm_scc
                           LEFT JOIN uss_person.v_sc_change ch
                           JOIN uss_person.v_sc_identity i
                               ON i.sci_id = ch.scc_sci
                               ON ch.scc_id = pm.pdm_scc
                     WHERE     pd.pd_id = p_pd_id
                           AND (   (    v_rt_code = 'ASSISTANCE_DECISION_R1'
                                    AND COALESCE (pd.pd_st, 'E') NOT IN
                                            ('PV', 'AV', 'V'))
                                OR (    v_rt_code = 'PAY_REJECT_DECISION_R1'
                                    AND pd.pd_st IN ('PV', 'AV', 'V')))
                           AND ROWNUM < 2)
            LOOP
                --#77050 заборонено формування підписаних рішень
                IF     data_cur.nst_id IN (664,
                                           269,
                                           268,
                                           267,
                                           265,
                                           249,
                                           248,
                                           901,
                                           251,
                                           275,
                                           862,
                                           21,
                                           1221)
                   AND data_cur.pd_is_signed = 'T'
                THEN
                    raise_application_error (
                        -20000,
                        'Підписані рішення недоступні для формування!');
                END IF;

                --ініціалізація завдання виконується тільки якщо статус рішення відповідає шаблону
                v_jbr_id := rdm$rtfl.initreport (p_rt_id);

                --#73661/#74090 деталізація в заголовку залежить від типу допомоги
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'head_desc',
                    (CASE data_cur.nst_id
                         WHEN 248
                         THEN
                             'про призначення допомоги особам \par з інвалідністю з дитинства та дітям з інвалідністю'
                         WHEN 249
                         THEN
                             'про призначення державної соціальної \par допомоги малозабезпеченій сім’ї'
                         WHEN 664
                         THEN
                             'Про призначення допомоги переміщеним особам на проживання'
                         ELSE
                             'про призначення допомоги сім’ям з дітьми'
                     END));

                rdm$rtfl.addparam (v_jbr_id, 'pd_num', data_cur.pd_num);
                rdm$rtfl.addparam (v_jbr_id, 'pd_date', data_cur.pd_date);
                rdm$rtfl.addparam (v_jbr_id,
                                   'pers_case_num',
                                   data_cur.pers_case_num);
                rdm$rtfl.addparam (v_jbr_id,
                                   'pers_acc_num',
                                   data_cur.pers_acc_num);
                rdm$rtfl.addparam (v_jbr_id,
                                   'pay_tp_info',
                                   data_cur.pay_tp_info);
                rdm$rtfl.addparam (v_jbr_id, 'serv_name', data_cur.nst_name);
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'serv_name_dod',
                    CASE
                        WHEN data_cur.nst_id IN (267, 268, 251)
                        THEN
                            'Підвищення за проживання в гірському населеному пункті'
                        WHEN data_cur.nst_id IN (275)
                        THEN
                            'Державна соціальна допомога дітям-сиротам'
                    END);
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'serv_name_dod2',
                    CASE
                        WHEN data_cur.nst_id IN (275, 265, 269)
                        THEN
                            'Підвищення за проживання в гірському населеному пункті'
                    END);
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'serv_name_dod3',
                    CASE
                        WHEN data_cur.nst_id IN (275)
                        THEN
                            'Підвищення за проживання в гірському населеному пункті (для Грошового забезпечення)'
                    END);

                IF    data_cur.nst_id NOT IN (249, 21)
                   OR v_rt_code = 'PAY_REJECT_DECISION_R1'
                THEN
                    rdm$rtfl.addparam (v_jbr_id,
                                       'app_fact_addr',
                                       data_cur.app_fact_addr);
                ELSIF data_cur.nst_id IN (21)
                THEN
                    rdm$rtfl.addparam (v_jbr_id,
                                       'app_fact_addr',
                                       data_cur.app_fact_addr_21);
                END IF;

                IF v_rt_code = 'ASSISTANCE_DECISION_R1'
                THEN
                    rdm$rtfl.addparam (
                        v_jbr_id,
                        'gen_info',
                        (CASE data_cur.nst_id
                             WHEN 249
                             THEN
                                    'Адреса: '
                                 || data_cur.app_fact_addr
                                 || ' \par '
                                 || '\par Уповноважений представник сім’ї: '
                                 || data_cur.app_name
                                 || '\par РНОКПП                                                 : '
                                 || data_cur.app_code
                                 || ' \par '
                                 || data_cur.pay_info_lines
                             ELSE
                                    'ЗАЯВНИК                 : '
                                 || data_cur.app_name
                                 || '\par РНОКПП заявника: '
                                 || data_cur.app_code
                                 || ' \par '
                                 || '\par Дата звернення                                        : '
                                 || data_cur.appeal_dt
                                 || '\par Дата народження                                    : '
                                 || TO_CHAR (data_cur.app_brth_dt,
                                             'DD.MM.YYYY')
                                 || data_cur.app_add_info
                         END));
                    rdm$rtfl.addparam (v_jbr_id,
                                       'pers_acc_dt',
                                       data_cur.pers_acc_dt);
                    rdm$rtfl.addparam (v_jbr_id,
                                       'w_esr_mdecision_ep_pib',
                                       NULL);
                    rdm$rtfl.addparam (v_jbr_id, 'w_esr_mwork_ep_pib', NULL);
                    rdm$rtfl.addparam (v_jbr_id, 'w_esr_work_ep_pib', NULL);

                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_else',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' NOT IN (248, 249, 664, 901, 251, 275, 862, 21, 1221) AND rownum <= 1');

                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_901',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 901 AND rownum <= 1');

                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_249',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 249 AND rownum <= 1');

                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_21',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 21 AND rownum <= 1');

                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_1221',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 1221 AND rownum <= 1');

                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_664',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 664 AND rownum <= 1');

                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_248',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 248 AND rownum <= 1');

                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_251',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 251 AND rownum <= 1');

                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_275',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 275 AND rownum <= 1');


                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'main_ds_862',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 862 AND rownum <= 1');


                    IF data_cur.nst_id = 248 --#74090 Друкована форма Рішення для допомоги з Ід=248
                    THEN
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'main_ds_249',
                               'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                            || data_cur.nst_id
                            || ' = 249 AND rownum <= 1');

                        --Утриманці
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds248',
                               q'[SELECT (CASE pt.dic_value
             WHEN 'FP' THEN
              ' \par ' || upper(pt.dic_sname)
           END) AS app_fp_lbl,
           uss_person.api$sc_tools.get_pib(app_sc) AS app_pib,
           to_char(pdf_birth_dt, 'DD.MM.YYYY') AS app_birth_dt,
           (CASE WHEN app_dsblt_grp IS NOT NULL THEN 'Група інвалідності: ' || app_dsblt_grp || ' ' END) ||
           (CASE WHEN app_dsblt_sub_grp IS NOT NULL THEN 'Підгрупа інвалідності: ' || app_dsblt_sub_grp END) ||
           (CASE WHEN app_dsblt_grp IS NOT NULL OR app_dsblt_sub_grp IS NOT NULL THEN '\par ' END) ||
           (CASE WHEN app_dsblt_rsn IS NOT NULL THEN 'Причина інвалідності: ' || app_dsblt_rsn || '\par ' END) AS app_dsblt_info,
           app_dsblt_cat,
           app_dsblt_period,
           app_state_dt,
           app_sc_info,
           mountain
      FROM (SELECT p.app_sc,
                   p.app_tp,
                   f.pdf_birth_dt,
                   MAX((CASE pf.pde_nft
                         WHEN 3 THEN
                          pf.pde_val_string
                       END)) AS app_dsblt_grp,
                   MAX((CASE pf.pde_nft
                         WHEN 4 THEN
                          pf.pde_val_string
                       END)) AS app_dsblt_sub_grp,
                  MAX((CASE
                         WHEN pf.pde_nft = 5 AND pf.pde_val_string IS NOT NULL THEN
                          (SELECT dic_sname FROM uss_ndi.v_ddn_inv_reason WHERE dic_code = pf.pde_val_string)
                       END)) AS app_dsblt_rsn,
                   MAX((CASE
                         WHEN pf.pde_nft = 6 AND pf.pde_val_string IS NOT NULL THEN
                          (SELECT dic_sname FROM uss_ndi.v_ddn_inv_child WHERE dic_code = pf.pde_val_string)
                       END)) AS app_dsblt_cat,
                   MAX((CASE pf.pde_nft
                         WHEN 7 THEN
                          to_char(pf.pde_val_dt, 'DD.MM.YYYY')
                       END)) || ' по ' || MAX((CASE pf.pde_nft
                                                WHEN 8 THEN
                                                 (CASE WHEN EXTRACT(YEAR FROM pf.pde_val_dt) = 2099 THEN 'довічно' ELSE to_char(pf.pde_val_dt, 'DD.MM.YYYY') END)
                                              END)) AS app_dsblt_period,
                   MAX((CASE pf.pde_nft
                         WHEN 2 THEN
                          to_char(pf.pde_val_dt, 'DD.MM.YYYY')
                       END)) AS app_state_dt,
                   app_sc_info,
                   max((select max(case when z.apda_val_string = 'T' then 'Так' else 'Ні' end)
                          from uss_esr.v_ap_document_attr z
                         where z.apda_ap = p.app_ap
                           and z.apda_nda = 2658
                           and z.history_status = 'A'
                       )) as mountain
              FROM uss_esr.v_ap_person p
              JOIN uss_esr.v_pd_family f ON f.pdf_sc = p.app_sc
                                         and f.history_status = 'A'
                                         AND f.pdf_pd = ]'
                            || p_pd_id
                            || '
              JOIN uss_esr.v_pd_features pf ON pf.pde_pdf = f.pdf_id
                                           AND pf.pde_pd = '
                            || p_pd_id
                            || q'[
              LEFT JOIN (SELECT rtrim(listagg(CASE rsn_tp
                                               WHEN 'V' THEN
                                                '\par Канікули/Лікування з ' || to_char(dprt_dt, 'DD.MM.YYYY') || ' по ' || to_char(arrvl_dt, 'DD.MM.YYYY')
                                             END) within
                                     GROUP(ORDER BY dprt_dt, arrvl_dt) || '\par ' || listagg(CASE
                                                                                               WHEN rsn_tp IN ('TR', 'UN', 'DE', 'HL') THEN
                                                                                                '\par Вибув з ' || to_char(dprt_dt, 'DD.MM.YYYY')
                                                                                             END) within GROUP(ORDER BY dprt_dt, arrvl_dt),
                                     '\par ') AS app_sc_info
                            FROM (SELECT d.apd_id,
                                         MAX(CASE atr.apda_nda
                                               WHEN 909 THEN
                                                atr.apda_val_string
                                             END) AS rsn_tp,
                                         MAX(CASE atr.apda_nda
                                               WHEN 907 THEN
                                                atr.apda_val_dt
                                             END) AS dprt_dt,
                                         MAX(CASE atr.apda_nda
                                               WHEN 908 THEN
                                                atr.apda_val_dt
                                             END) AS arrvl_dt
                                    FROM uss_esr.v_personalcase pc
                                    JOIN uss_esr.v_appeal a ON a.ap_pc = pc.pc_id
                                    JOIN uss_esr.v_ap_person p ON p.app_ap = a.ap_id
                                    JOIN uss_esr.v_ap_document d ON d.apd_ap = a.ap_id
                                                                AND d.apd_app = p.app_id
                                                                AND d.apd_ndt IN (10035)
                                    JOIN uss_esr.v_ap_document_attr atr ON atr.apda_apd = d.apd_id
                                                                       AND atr.apda_nda IN (909, 907, 908)
                                   WHERE pc.pc_id = ]'
                            || data_cur.pc_id
                            || '
                                   GROUP BY d.apd_id)) ON 1 = 1
             WHERE p.app_ap = '
                            || data_cur.ap_id
                            || q'[
               AND p.history_status = 'A'
             GROUP BY p.app_sc, p.app_tp, f.pdf_birth_dt, app_sc_info)
      JOIN uss_ndi.v_ddn_app_tp pt ON pt.dic_code = app_tp
     ORDER BY pt.dic_srtordr, 2]');

                          --РОЗМІР ДЕРЖАВНОЇ СОЦІАЛЬНОЇ ДОПОМОГИ:
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                            SUM (d.pdd_value),
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON (    pt.npt_id = d.pdd_npt
                                         --AND pt.npt_code = '169'
                                         AND pt.npt_nbg = '11'
                                         AND pt.npt_code NOT IN ('290', '256'))
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_npt = 1
                                 AND d.pdd_value IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id, 'asstnc_info1', v_str);

                          -- НАДБАВКА НА ДОГЛЯД
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                            SUM (d.pdd_value),
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code = '290'
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_npt = 1
                                 AND d.pdd_value IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id, 'asstnc_info2', v_str);

                          -- НАДБАВКА ЗА ПРОЖИВАННЯ В ГІРСЬКОМУ НАС.ПУНКТІ
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM d.pdd_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (d.pdd_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                            SUM (d.pdd_value),
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   d.pdd_start_dt,
                                                   d.pdd_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code IN ('256')
                           WHERE     p.pdp_pd = p_pd_id
                                 AND d.pdd_ndp = 294
                                 AND p.pdp_sum IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY d.pdd_start_dt, d.pdd_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id, 'asstnc_info2_m', v_str);

                          -- ДЕРЖАВНА АДРЕСНА ДОПОМОГА
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                            SUM (d.pdd_value),
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code = '995'
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_sum IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id, 'asstnc_info3', v_str);

                          --ДОПЛАТА
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                            SUM (d.pdd_value),
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code IN ('986', '998')
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_sum IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id, 'asstnc_info4', v_str);

                          -- dn_percentage
                          --ДЕРЖАВНУ СОЦІАЛЬНУ ДОПОМОГУ
                          /* SELECT listagg('з ' || to_char(d.pdd_start_dt, 'DD.MM.YYYY') || ' по ' || (CASE WHEN EXTRACT(YEAR FROM d.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(d.pdd_stop_dt, 'DD.MM.YYYY') END) || ' ' ||
                                          to_char(d.pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''),
                                          ' \par ') within GROUP(ORDER BY d.pdd_start_dt, d.pdd_stop_dt, d.pdd_value)
                             INTO v_str
                             FROM v_pd_payment p
                             JOIN uss_ndi.v_ndi_payment_type pt ON pt.npt_id = p.pdp_npt
                                                                   AND pt.npt_code = '169'
                             JOIN v_pd_detail d ON d.pdd_pdp = p.pdp_id
                                               AND d.pdd_row_order = 401
                                               AND d.pdd_value IS NOT NULL
                            WHERE p.pdp_pd = p_pd_id
                              AND p.history_status = 'A';*/

                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                              SUM (d.pdd_value)
                                            * (100 - data_cur.dn_percentage)
                                            / 100,
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON (    pt.npt_id = d.pdd_npt
                                         --AND pt.npt_code = '169'
                                         AND pt.npt_nbg = '11'
                                         AND pt.npt_code NOT IN ('290', '256'))
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_npt = 1
                                 AND d.pdd_value IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id,
                                           'add_asstnc_info1',
                                           v_str);

                          -- НАДБАВКУ НА ДОГЛЯД
                          /*SELECT listagg('з ' || to_char(d.pdd_start_dt, 'DD.MM.YYYY') || ' по ' || (CASE WHEN EXTRACT(YEAR FROM d.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(d.pdd_stop_dt, 'DD.MM.YYYY') END) || ' ' ||
                                         to_char(d.pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''),
                                         ' \par ') within GROUP(ORDER BY d.pdd_start_dt, d.pdd_stop_dt, d.pdd_value)
                            INTO v_str
                            FROM v_pd_payment p
                            JOIN uss_ndi.v_ndi_payment_type pt ON (pt.npt_id = p.pdp_npt
                                                              AND pt.npt_code = '290')
                            JOIN v_pd_detail d ON d.pdd_pdp = p.pdp_id
                                              AND d.pdd_row_order = 401
                                              AND d.pdd_value IS NOT NULL
                           WHERE p.pdp_pd = p_pd_id
                             AND p.history_status = 'A';*/
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                              SUM (d.pdd_value)
                                            * (100 - data_cur.dn_percentage)
                                            / 100,
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code = '290'
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_npt = 1
                                 AND d.pdd_value IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id,
                                           'add_asstnc_info2',
                                           v_str);

                          -- НАДБАВКУ ЗА ПРОЖИВАННЯ В ГІРСЬКОМУ НАС.ПУНКТІ
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM d.pdd_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (d.pdd_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                              SUM (d.pdd_value)
                                            * (100 - data_cur.dn_percentage)
                                            / 100,
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   d.pdd_start_dt,
                                                   d.pdd_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code = '256'
                           WHERE     p.pdp_pd = p_pd_id
                                 AND d.pdd_ndp = 294
                                 AND p.pdp_sum IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY d.pdd_start_dt, d.pdd_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id,
                                           'add_asstnc_info2_m',
                                           v_str);

                          --ДЕРЖАВНА АДРЕСНА ДОПОМОГА
                          /*SELECT listagg('з ' || to_char(d.pdd_start_dt, 'DD.MM.YYYY') || ' по ' || (CASE WHEN EXTRACT(YEAR FROM d.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(d.pdd_stop_dt, 'DD.MM.YYYY') END) || ' ' ||
                                         to_char(d.pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''),
                                         ' \par ') within GROUP(ORDER BY d.pdd_start_dt, d.pdd_stop_dt, d.pdd_value)
                            INTO v_str
                            FROM v_pd_payment p
                            JOIN uss_ndi.v_ndi_payment_type pt ON pt.npt_id = p.pdp_npt
                                                              AND pt.npt_code = '995'
                            JOIN v_pd_detail d ON d.pdd_pdp = p.pdp_id
                                              AND d.pdd_row_order = 401
                                              AND d.pdd_value IS NOT NULL
                           WHERE p.pdp_pd = p_pd_id
                             AND p.history_status = 'A';*/
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                              SUM (d.pdd_value)
                                            * (100 - data_cur.dn_percentage)
                                            / 100,
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code = '995'
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_sum IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id,
                                           'add_asstnc_info3',
                                           v_str);

                          --ДОПЛАТУ
                          /*SELECT listagg('з ' || to_char(d.pdd_start_dt, 'DD.MM.YYYY') || ' по ' || (CASE WHEN EXTRACT(YEAR FROM d.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(d.pdd_stop_dt, 'DD.MM.YYYY') END) || ' ' ||
                                         to_char(d.pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''),
                                         ' \par ') within GROUP(ORDER BY d.pdd_start_dt, d.pdd_stop_dt, d.pdd_value)
                            INTO v_str
                            FROM v_pd_payment p
                            JOIN uss_ndi.v_ndi_payment_type pt ON pt.npt_id = p.pdp_npt
                                                              AND pt.npt_code = '986'
                            JOIN v_pd_detail d ON d.pdd_pdp = p.pdp_id
                                              AND d.pdd_row_order = 401
                                              AND d.pdd_value IS NOT NULL
                           WHERE p.pdp_pd = p_pd_id
                             AND p.history_status = 'A';*/
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                              SUM (d.pdd_value)
                                            * (100 - data_cur.dn_percentage)
                                            / 100,
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code IN ('986', '998')
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_sum IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt;

                        rdm$rtfl.addparam (v_jbr_id,
                                           'add_asstnc_info4',
                                           v_str);

                          --СУМА, ЯКА ПЕРЕРАХОВУЄТЬСЯ В ЗАКЛАД ДЕРЖУТРИМАННЯ
                          --ДЕРЖАВНУ СОЦІАЛЬНУ ДОПОМОГУ
                          /* SELECT listagg('з ' || to_char(d.pdd_start_dt, 'DD.MM.YYYY') || ' по ' || (CASE WHEN EXTRACT(YEAR FROM d.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(d.pdd_stop_dt, 'DD.MM.YYYY') END) || ' ' ||
                                          to_char(d.pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''),
                                          ' \par ') within GROUP(ORDER BY d.pdd_start_dt, d.pdd_stop_dt, d.pdd_value)
                             INTO v_str
                             FROM v_pd_payment p
                             JOIN uss_ndi.v_ndi_payment_type pt ON pt.npt_id = p.pdp_npt
                                                               AND pt.npt_code = '169'
                             JOIN v_pd_detail d ON d.pdd_pdp = p.pdp_id
                                               AND d.pdd_row_order = 400
                                               AND d.pdd_value IS NOT NULL
                            WHERE p.pdp_pd = p_pd_id
                              AND p.history_status = 'A';*/
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                              SUM (d.pdd_value)
                                            * data_cur.dn_percentage,
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON (    pt.npt_id = d.pdd_npt
                                         --AND pt.npt_code = '169'
                                         AND pt.npt_nbg = '11'
                                         AND pt.npt_code NOT IN ('290', '256'))
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_npt = 1
                                 AND d.pdd_value IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt
                          HAVING SUM (d.pdd_value) * data_cur.dn_percentage !=
                                 0;

                        rdm$rtfl.addparam (v_jbr_id,
                                           'add_asstnc_info5',
                                           v_str);

                          --НАДБАВКУ НА ДОГЛЯД
                          /*SELECT listagg('з ' || to_char(d.pdd_start_dt, 'DD.MM.YYYY') || ' по ' || (CASE WHEN EXTRACT(YEAR FROM d.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(d.pdd_stop_dt, 'DD.MM.YYYY') END) || ' ' ||
                                         to_char(d.pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''),
                                         ' \par ') within GROUP(ORDER BY d.pdd_start_dt, d.pdd_stop_dt, d.pdd_value)
                            INTO v_str
                            FROM v_pd_payment p
                            JOIN uss_ndi.v_ndi_payment_type pt ON pt.npt_id = p.pdp_npt
                                                              AND pt.npt_code = '290'
                            JOIN v_pd_detail d ON d.pdd_pdp = p.pdp_id
                                              AND d.pdd_row_order = 400
                                              AND d.pdd_value IS NOT NULL
                           WHERE p.pdp_pd = p_pd_id
                             AND p.history_status = 'A';*/
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                              SUM (d.pdd_value)
                                            * data_cur.dn_percentage,
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code = '290'
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_npt = 1
                                 AND d.pdd_value IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt
                          HAVING SUM (d.pdd_value) * data_cur.dn_percentage !=
                                 0;

                        rdm$rtfl.addparam (v_jbr_id,
                                           'add_asstnc_info6',
                                           v_str);

                          --ДЕРЖАВНА АДРЕСНА ДОПОМОГА
                          /* SELECT listagg('з ' || to_char(d.pdd_start_dt, 'DD.MM.YYYY') || ' по ' || (CASE WHEN EXTRACT(YEAR FROM d.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(d.pdd_stop_dt, 'DD.MM.YYYY') END) || ' ' ||
                                          to_char(d.pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''),
                                          ' \par ') within GROUP(ORDER BY d.pdd_start_dt, d.pdd_stop_dt, d.pdd_value)
                             INTO v_str
                             FROM v_pd_payment p
                             JOIN uss_ndi.v_ndi_payment_type pt ON pt.npt_id = p.pdp_npt
                                                               AND pt.npt_code = '995'
                             JOIN v_pd_detail d ON d.pdd_pdp = p.pdp_id
                                               AND d.pdd_row_order = 400
                                               AND d.pdd_value IS NOT NULL
                            WHERE p.pdp_pd = p_pd_id
                              AND p.history_status = 'A';*/
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                              SUM (d.pdd_value)
                                            * data_cur.dn_percentage,
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code = '995'
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_sum IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt
                          HAVING SUM (d.pdd_value) * data_cur.dn_percentage !=
                                 0;

                        rdm$rtfl.addparam (v_jbr_id,
                                           'add_asstnc_info7',
                                           v_str);

                          --ДОПЛАТУ
                          /*SELECT listagg('з ' || to_char(d.pdd_start_dt, 'DD.MM.YYYY') || ' по ' || (CASE WHEN EXTRACT(YEAR FROM d.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(d.pdd_stop_dt, 'DD.MM.YYYY') END) || ' ' ||
                                         to_char(d.pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''),
                                         ' \par ') within GROUP(ORDER BY d.pdd_start_dt, d.pdd_stop_dt, d.pdd_value)
                            INTO v_str
                            FROM v_pd_payment p
                            JOIN uss_ndi.v_ndi_payment_type pt ON pt.npt_id = p.pdp_npt
                                                              AND pt.npt_code = '986'
                            JOIN v_pd_detail d ON d.pdd_pdp = p.pdp_id
                                              AND d.pdd_row_order = 400
                                              AND d.pdd_value IS NOT NULL
                           WHERE p.pdp_pd = p_pd_id
                             AND p.history_status = 'A';*/
                          SELECT LISTAGG (
                                        'з '
                                     || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                     || ' по '
                                     || (CASE
                                             WHEN EXTRACT (
                                                      YEAR FROM p.pdp_stop_dt) =
                                                  2099
                                             THEN
                                                 'довічно'
                                             ELSE
                                                 TO_CHAR (p.pdp_stop_dt,
                                                          'DD.MM.YYYY')
                                         END)
                                     || ' '
                                     || TO_CHAR (
                                              SUM (d.pdd_value)
                                            * data_cur.dn_percentage,
                                            'FM9G999G999G999G999G990D00',
                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                     ' \par ')
                                 WITHIN GROUP (ORDER BY
                                                   p.pdp_start_dt,
                                                   p.pdp_stop_dt,
                                                   SUM (d.pdd_value))
                            INTO v_str
                            FROM v_pd_payment p
                                 JOIN v_pd_detail d ON (d.pdd_pdp = p.pdp_id)
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = d.pdd_npt
                                        AND pt.npt_code IN ('986', '998')
                           WHERE     p.pdp_pd = p_pd_id
                                 AND p.pdp_sum IS NOT NULL
                                 AND p.history_status = 'A'
                        GROUP BY p.pdp_start_dt, p.pdp_stop_dt
                          HAVING SUM (d.pdd_value) * data_cur.dn_percentage !=
                                 0;

                        rdm$rtfl.addparam (v_jbr_id,
                                           'add_asstnc_info8',
                                           v_str);
                    ELSIF data_cur.nst_id = 249
                    THEN
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'main_ds_249',
                               q'[SELECT pdp_id,
           to_char(pdp_start_dt, 'DD.MM.YYYY') AS period_start_dt,
           (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS period_end_dt,
           to_char((SELECT SUM(pdd_value) FROM uss_esr.v_pd_detail WHERE pdd_pdp = pdp_id AND pdd_ndp = 132), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS avg_sbstnc_lvl,
           to_char((SELECT SUM(pic_month_income) FROM uss_esr.v_pd_income_calc WHERE pic_pd = ]'
                            || p_pd_id
                            || q'[), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS avg_tot_fml_income,
           to_char((SELECT SUM(pdd_value) FROM uss_esr.v_pd_detail WHERE pdd_pdp = pdp_id AND pdd_ndp = 133), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS min_tot_fml_income
      FROM uss_esr.v_pd_payment pdp
     WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || '
     ORDER BY pdp_start_dt, pdp_stop_dt');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds249',
                               q'[SELECT ROW_NUMBER() OVER (ORDER BY REPLACE(fml_member_pib, 'Розмір рівня забезпечення для ')) AS rn,
           fml_member_pib || case when fml_92 > 0 then ' (гірський нас. пункт)'
                                  when years <= 14 and fml_92_main > 0 then ' (гірський нас. пункт)'
                             end as fml_member_pib,
           fml_member_brth_dt,
           to_char(pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS fml_member_min_lvl
      FROM (SELECT uss_person.api$sc_tools.get_pib(pdf_sc) AS fml_member_pib,
                   to_char(pdf_birth_dt, 'DD.MM.YYYY') AS fml_member_brth_dt,
                   (select count(*)
                      from uss_esr.v_ap_document z
                      join uss_esr.v_ap_person p on (p.app_id = z.apd_app and p.app_ap = z.apd_ap)
                     where z.apd_ap = ]'
                            || data_cur.ap_id
                            || '
                       and p.app_sc = pdf_sc
                       and z.history_status = ''A''
                       and z.apd_ndt = 92) as fml_92,
                   (select count(*)
                      from uss_esr.v_ap_document z
                      join uss_esr.v_ap_person p on (p.app_id = z.apd_app and p.app_ap = z.apd_ap)
                     where z.apd_ap = '
                            || data_cur.ap_id
                            || '
                       and p.app_sc = '
                            || data_cur.pc_sc
                            || '
                       and z.apd_ndt = 92) as fml_92_main,
                   round(months_between(trunc(sysdate), pdf_birth_dt) / 12) as years
              FROM uss_esr.v_pd_family f
             WHERE f.history_status = ''A''
               and pdf_pd = '
                            || p_pd_id
                            || ')
      JOIN uss_esr.v_pd_detail ON pdd_ndp = 131
                              AND instr(upper(pdd_row_name), upper(fml_member_pib)) > 0
      JOIN uss_esr.v_pd_payment pdp ON pdp_id = pdd_pdp AND pdp.history_status = ''A''
                               AND pdp_pd = '
                            || p_pd_id
                            || '
     WHERE 1 = 1');

                        rdm$rtfl.addrelation (v_jbr_id,
                                              'main_ds_249',
                                              'pdp_id',
                                              'ds249',
                                              'pdd_pdp');
                    ELSIF data_cur.nst_id = 664 --#77049 друкована форма рішення по допомозі ВПО
                    THEN
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'main_ds_249',
                               'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                            || data_cur.nst_id
                            || ' = 249 AND rownum <= 1');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds664',
                               q'[SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(p.app_sc)) AS rn,
           uss_person.api$sc_tools.get_pib(p.app_sc) AS app_pib,
           (SELECT MAX('особа з інвалідністю')
              FROM uss_esr.v_ap_document d
              JOIN uss_esr.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                AND da.apda_nda IN (1772, 349)
                                                AND da.apda_val_string IS NOT NULL
              WHERE d.apd_ap = ]'
                            || data_cur.ap_id
                            || q'[
                AND d.apd_app = p.app_id
                AND d.apd_ndt IN (10053, 201)
                AND d.history_status = 'A') AS app_info,
           to_char(uss_person.api$sc_tools.get_birthdate(p.app_sc), 'DD.MM.YYYY') AS app_brth_dt
      FROM uss_esr.v_ap_person p
     WHERE p.app_ap = ]'
                            || data_cur.ap_id
                            || q'[
       AND p.app_tp IN ('Z', 'O', 'FP', 'FM')
       AND p.history_status = 'A']');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2',
                               q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       'з ' || to_char(pd.pdd_start_dt, 'DD.MM.YYYY') AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND (pd.pdd_ndp = 300)
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot',
                               q'[SELECT 'з ' || to_char(pdp_start_dt, 'DD.MM.YYYY') AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = pdp.pdp_id
                                     AND (pd.pdd_ndp = 300)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
         GROUP BY 'з ' || to_char(pdp_start_dt, 'DD.MM.YYYY')
         ORDER BY 1]');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_dod',
                               q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       'з ' || to_char(pd.pdd_start_dt, 'DD.MM.YYYY') AS period_info,
                       pd.pdd_value AS SUM,
                       pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 294
                                             AND pd.pdd_npt IN (843, 845)
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_dod_tot',
                               q'[SELECT 'з ' || to_char(pdp_start_dt, 'DD.MM.YYYY') AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = pdp.pdp_id
                                     AND pd.pdd_ndp = 294
                                     AND pd.pdd_npt IN (843, 845)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
         GROUP BY 'з ' || to_char(pdp_start_dt, 'DD.MM.YYYY')
         ORDER BY 1]');
                    ELSIF data_cur.nst_id = 901
                    THEN
                        SELECT COUNT (*)
                          INTO l_cnt
                          FROM uss_esr.v_pd_payment  p
                               JOIN uss_esr.v_pd_detail pd
                                   ON (    pd.pdd_pdp = p.pdp_id
                                       AND pd.pdd_npt IN (896))
                         WHERE     p.history_status = 'A'
                               AND p.pdp_pd = p_pd_id
                               AND pd.pdd_value != 0;

                        IF (l_cnt > 0)
                        THEN
                            RDM$RTFL.AddParam (v_jbr_id,
                                               'c_901_fop',
                                               '(ФОП)');
                        END IF;

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'main_ds_249',
                               'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                            || data_cur.nst_id
                            || ' = 249 AND rownum <= 1');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds1',
                               q'[SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn, uss_person.api$sc_tools.get_pib(f.pdf_sc) AS dependent_pib, to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS dependent_brth_dt
          FROM uss_esr.v_pd_family f
         WHERE f.history_status = 'A'
           and f.pdf_pd = ]'
                            || p_pd_id
                            || '
           AND f.pdf_sc != '
                            || data_cur.pc_sc);

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds_901_1',
                               q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                 --AND f.pdf_sc != '
                            || data_cur.pc_sc
                            || q'[
                 ) ft
          JOIN (SELECT pd.pdd_row_name,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_npt IN (839, 896))
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || '
                   AND pd.pdd_value != 0) pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds_901_2',
                               q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                 AND f.pdf_sc != '
                            || data_cur.pc_sc
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_npt = 840)
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || '
                   AND pd.pdd_value != 0) pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds_901_3',
                               q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_npt = 895)
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || '
                   AND pd.pdd_value != 0) pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds_901_1_tot',
                               q'[SELECT to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS period_info,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS SUM
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND pd.pdd_npt IN (839, 896)
           AND pd.pdd_value != 0
         GROUP BY to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1]');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds_901_2_tot',
                               q'[SELECT to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS period_info,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS SUM
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND pd.pdd_npt = 840
           AND pd.pdd_value != 0
         GROUP BY to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1]');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds_901_3_tot',
                               q'[SELECT to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS period_info,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS SUM
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND pd.pdd_npt = 895
           AND pd.pdd_value != 0
         GROUP BY to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1]');
                    ELSIF (data_Cur.nst_id = 251)
                    THEN
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'main_ds_249',
                               'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                            || data_cur.nst_id
                            || ' = 249 AND rownum <= 1');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds1',
                               q'[SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn, uss_person.api$sc_tools.get_pib(f.pdf_sc) AS dependent_pib, to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS dependent_brth_dt
                                    FROM uss_esr.v_pd_family f
                                   WHERE f.history_status = 'A'
                                     and f.pdf_pd = ]'
                            || p_pd_id);

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2',
                               q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 500
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_dod',
                               q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 296
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot',
                               q'[SELECT to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND pd.pdd_ndp = 500
         GROUP BY to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1]');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot_dod',
                               q'[SELECT to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND pd.pdd_ndp = 296
         GROUP BY to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1]');
                    ELSIF (data_Cur.nst_id = 275)
                    THEN
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'main_ds_249',
                               'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                            || data_cur.nst_id
                            || ' = 249 AND rownum <= 1');
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds1',
                               q'[SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn, uss_person.api$sc_tools.get_pib(f.pdf_sc) AS dependent_pib, to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS dependent_brth_dt
                                    FROM uss_esr.v_pd_family f
                                   WHERE f.history_status = 'A'
                                     and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                                     AND f.pdf_sc != '
                            || data_cur.pc_sc);

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2',
                               q'[SELECT ft.rn, pdd_start_dt, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       pd.pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 522
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdd_start_dt, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot',
                               q'[SELECT pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
          left join uss_esr.v_pd_family f on (f.pdf_id = pd.pdd_key and f.history_status = 'A')
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND (pd.pdd_ndp in (522) or pd.pdd_ndp in (294) and f.pdf_sc = ]'
                            || data_cur.pc_sc
                            || q'[)
         GROUP BY pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1, 2]');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_dod',
                               q'[SELECT ft.rn, pdd_start_dt, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                   AND f.pdf_sc != '
                            || data_cur.pc_sc
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 521
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdd_start_dt, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot_dod',
                               q'[SELECT pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
          left join uss_esr.v_pd_family f on (f.pdf_id = pd.pdd_key and f.history_status = 'A')
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND (pd.pdd_ndp in (521) or pd.pdd_ndp in (294) and f.pdf_sc != ]'
                            || data_cur.pc_sc
                            || q'[)
         GROUP BY pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1, 2]');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_dod2',
                               q'[SELECT ft.rn, pdd_start_dt, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                 AND f.pdf_sc != '
                            || data_cur.pc_sc
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 294
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdd_start_dt, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_dod3',
                               q'[SELECT ft.rn, pdd_start_dt, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                   AND f.pdf_sc = '
                            || data_cur.pc_sc
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 294
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdd_start_dt, pdt.period_info, pdt.sum');
                    ELSIF (data_Cur.nst_id = 862)
                    THEN
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'main_ds_249',
                               'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                            || data_cur.nst_id
                            || ' = 249 AND rownum <= 1');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds1',
                               q'[SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn, uss_person.api$sc_tools.get_pib(f.pdf_sc) AS dependent_pib, to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS dependent_brth_dt
                                    FROM uss_esr.v_pd_family f
                                   WHERE f.history_status = 'A'
                                     and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                                     AND f.pdf_sc != '
                            || data_cur.pc_sc);

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2',
                               q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || q'[
                   AND f.pdf_sc != ]'
                            || data_cur.pc_sc
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       pd.pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 510
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdd_start_dt, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot',
                               q'[SELECT to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND pd.pdd_ndp = 510
         GROUP BY to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1]');
                    ELSIF (data_Cur.nst_id = 21)
                    THEN
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds1',
                               q'[SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn, uss_person.api$sc_tools.get_pib(f.pdf_sc) AS dependent_pib, to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS dependent_brth_dt
                                    FROM uss_esr.v_pd_family f
                                   WHERE f.history_status = 'A'
                                     and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                                     AND f.pdf_sc != '
                            || data_cur.pc_sc);

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2',
                               q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || q'[
                   AND f.pdf_sc != ]'
                            || data_cur.pc_sc
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       pd.pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 521
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdd_start_dt, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot',
                               q'[SELECT to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND pd.pdd_ndp = 521
         GROUP BY to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1]');
                    ELSIF (data_Cur.nst_id = 1221)
                    THEN
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2',
                               q'[SELECT pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT pd.pdd_row_name,
                       pd.pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 522
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt
         ORDER BY pdd_start_dt, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot',
                               q'[SELECT to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND pd.pdd_ndp = 522
         GROUP BY to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1]');
                    ELSE
                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds1',
                               q'[SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn, uss_person.api$sc_tools.get_pib(f.pdf_sc) AS dependent_pib, to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS dependent_brth_dt
                                    FROM uss_esr.v_pd_family f
                                   WHERE f.history_status = 'A'
                                     and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                                     AND f.pdf_sc != '
                            || data_cur.pc_sc);

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2',
                               q'[SELECT ft.rn, pdd_start_dt, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                   AND f.pdf_sc != '
                            || data_cur.pc_sc
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pd.pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 300
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdd_start_dt, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot',
                               q'[SELECT pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND (pd.pdd_ndp = 300
                OR pd.pdd_ndp = 294 AND pd.pdd_npt IN (843, 845))
         GROUP BY pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1, 2]');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_dod',
                               q'[SELECT ft.rn, pdd_start_dt, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                 AND f.pdf_sc != '
                            || data_cur.pc_sc
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 294
                                             AND pd.pdd_npt IN (843, 845)
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdd_start_dt, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_dod_tot',
                               q'[SELECT pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = pdp.pdp_id
                                     AND pd.pdd_ndp = 294
                                     AND pd.pdd_npt IN (843, 845)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
         GROUP BY pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1, 2]');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_dod2',
                               q'[SELECT ft.rn, pdd_start_dt, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
          FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                       upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                       to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt,
                       f.pdf_id
                  FROM uss_esr.v_pd_family f
                 WHERE f.history_status = 'A'
                   and f.pdf_pd = ]'
                            || p_pd_id
                            || '
                 AND f.pdf_sc != '
                            || data_cur.pc_sc
                            || q'[) ft
          JOIN (SELECT pd.pdd_row_name,
                       pdd_start_dt,
                       to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                       pd.pdd_value AS SUM,
                       pdd_key
                  FROM uss_esr.v_pd_payment p
                  JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                             AND pd.pdd_ndp = 294
                 WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                            || p_pd_id
                            || ') pdt ON (pdf_id = pdd_key)
         ORDER BY ft.rn, pdd_start_dt, pdt.period_info, pdt.sum');

                        rdm$rtfl.adddataset (
                            v_jbr_id,
                            'ds2_tot_dod2',
                               q'[SELECT pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
               to_char(SUM(pdd_value), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
          FROM uss_esr.v_pd_payment pdp
          JOIN uss_esr.v_pd_detail pd ON (pd.pdd_pdp = pdp_id)
         WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                            || p_pd_id
                            || q'[
           AND pd.pdd_ndp = 294
         GROUP BY pdp_start_dt, to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
         ORDER BY 1, 2]');
                    END IF;
                ELSE
                    rdm$rtfl.addparam (v_jbr_id,
                                       'app_name',
                                       data_cur.app_name);
                    rdm$rtfl.addparam (v_jbr_id,
                                       'app_code',
                                       data_cur.app_code);
                    rdm$rtfl.addparam (v_jbr_id,
                                       'appeal_dt',
                                       data_cur.appeal_dt);
                    rdm$rtfl.addparam (v_jbr_id,
                                       'app_brth_dt',
                                       data_cur.app_brth_dt);
                    rdm$rtfl.addparam (v_jbr_id,
                                       'reject_reason',
                                       data_cur.reject_reason);
                END IF;

                rdm$rtfl.putreporttoworkingqueue (v_jbr_id);
            END LOOP;

            RETURN v_jbr_id;
        END IF;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Сукупний дохід"
    -- params: p_rt_id - ідентифікатор шаблону
    --         p_pd_id - ідентифікатор рішення
    -- note:   #70506, #71260 - різне наповнення друкованої форми для послуги з ІД=268 і інших послуг
    FUNCTION total_revenue_r1 (p_rt_id   IN rpt_templates.rt_id%TYPE,
                               p_pd_id   IN NUMBER)
        RETURN DECIMAL
    IS
        v_jbr_id   NUMBER;
    BEGIN
        FOR data_cur
            IN (SELECT pd.pd_ap,
                       pd.pd_nst,
                       CASE
                           WHEN pd.pd_nst = 664 THEN 'за 3 місяців'
                           WHEN pd.pd_nst = 268 THEN 'за 10 місяців'
                           ELSE 'за 6 місяців'
                       END                                   AS nst_months,
                       pd.pd_num,
                       pd.pd_dt,
                       pa.pa_num,
                       uss_person.api$sc_tools.get_pib (
                           COALESCE (sc.sc_id, pc.pc_sc))    AS app_name,
                       c.pic_total_income_6m,
                       c.pic_plot_income_6m,
                       c.pic_month_income,
                       c.pic_members_number,
                       c.pic_member_month_income,
                       c.pic_id
                  FROM v_pc_decision  pd
                       LEFT JOIN v_pc_account pa ON pa.pa_id = pd.pd_pa
                       LEFT JOIN v_pd_income_calc c ON c.pic_pd = pd.pd_id
                       LEFT JOIN v_pd_pay_method pm
                       JOIN uss_person.v_socialcard sc
                           ON sc.sc_scc = pm.pdm_scc
                           ON     pm.pdm_pd = p_pd_id
                              AND pm.history_status = 'A'
                              AND pm.pdm_is_actual = 'T'
                       LEFT JOIN v_personalcase pc
                           ON pc.pc_id = pd.pd_pc AND sc.sc_id IS NULL
                 WHERE pd.pd_id = p_pd_id AND ROWNUM < 2)
        LOOP
            v_jbr_id := rdm$rtfl.initreport (p_rt_id);
            rdm$rtfl.addparam (
                v_jbr_id,
                'head',
                   (CASE
                        WHEN data_cur.pd_nst IN (249, 267, 268)
                        THEN
                            'до Рішення №' || data_cur.pd_num
                        ELSE
                            'до Протоколу ' || data_cur.pa_num
                    END)
                || ' від '
                || (CASE
                        WHEN data_cur.pd_nst IN (249, 267, 268)
                        THEN
                            TO_CHAR (data_cur.pd_dt, 'DD.MM.YYYY')
                    END));           --#74183 заголовок залежить від типу послуги
            rdm$rtfl.addparam (v_jbr_id,
                               'app_name',
                               TRIM (data_cur.app_name));
            rdm$rtfl.addparam (
                v_jbr_id,
                'pers_list_lbl',
                (CASE data_cur.pd_nst WHEN 268 THEN 'СПИСОК УТРИМАНЦІВ' END));

            IF data_cur.pd_nst != 268
            THEN
                rdm$rtfl.adddataset (
                    v_jbr_id,
                    'tot_calc_sum_ds',
                       'SELECT ''Сукупний дохід сім’ї '
                    || data_cur.nst_months
                    || ' (крім доходу від землі) \par Сукупний дохід '
                    || data_cur.nst_months
                    || ' від землі \par '
                    || 'Сукупний середньомісячний дохід сім’ї \par Кількість членів сім’ї \par Середньомісячний дохід члена сім’ї'' AS tot_calc_sum_lbl,
                                   '
                    || 'q''['
                    || TO_CHAR (data_cur.pic_total_income_6m,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
                    || ' \par '
                    || TO_CHAR (data_cur.pic_plot_income_6m,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
                    || ' \par '
                    || TO_CHAR (data_cur.pic_month_income,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
                    || ' \par '
                    || data_cur.pic_members_number
                    || ' \par '
                    || TO_CHAR (data_cur.pic_member_month_income,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
                    || ']'''
                    || ' AS tot_calc_sums
                          FROM uss_ndi.v_ndi_service_type st WHERE '
                    || data_cur.pd_nst
                    || ' NOT IN (249, 267) AND rownum <= 1');

                rdm$rtfl.adddataset (
                    v_jbr_id,
                    'tot_calc_sum_ds1',
                       'SELECT ''Сукупний дохід сім’ї '
                    || data_cur.nst_months
                    || ' (крім доходу від землі) \par Сукупний середньомісячний дохід сім’ї \par Кількість членів сім’ї \par Середньомісячний дохід члена сім’ї'' AS tot_calc_sum_lbl,
                                   '
                    || 'q''['
                    || TO_CHAR (data_cur.pic_total_income_6m,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
                    || ' \par '
                    || TO_CHAR (data_cur.pic_month_income,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
                    || ' \par '
                    || data_cur.pic_members_number
                    || ' \par '
                    || TO_CHAR (data_cur.pic_member_month_income,
                                'FM9G999G999G999G999G990D00',
                                'NLS_NUMERIC_CHARACTERS=''.''''')
                    || ']'''
                    || ' AS tot_calc_sums
                          FROM uss_ndi.v_ndi_service_type st WHERE '
                    || data_cur.pd_nst
                    || ' IN (249, 267) AND rownum <= 1');
            END IF;

            rdm$rtfl.adddataset (
                v_jbr_id,
                'group_ds',
                   q'[SELECT ap.app_id AS pers_id,
       '\par ' || TRIM(uss_person.api$sc_tools.get_pib(MAX(ap.app_sc))) || (CASE
                                                                              WHEN SUM(coalesce(pd.pid_fact_sum, 0)) = 0 THEN
                                                                               '\par Дохід відсутній'
                                                                            END) AS pers_name
  FROM uss_esr.v_ap_person ap
  LEFT JOIN uss_esr.v_pd_income_detail pd ON pd.pid_app = ap.app_id
                                         AND pd.pid_sc = ap.app_sc
                                         AND pd.pid_is_family_member = 'T']'
                || (CASE
                        WHEN data_cur.pic_id IS NOT NULL
                        THEN
                            '
                                         AND pd.pid_pic = ' || data_cur.pic_id
                    END)
                || '
 WHERE ap.app_ap = '
                || data_cur.pd_ap
                || q'[
   AND ap.history_status = 'A'
   AND 268 != ]'
                || data_cur.pd_nst
                || '
 GROUP BY ap.app_id
 ORDER BY 2');

            rdm$rtfl.adddataset (
                v_jbr_id,
                'main_ds',
                   q'[ SELECT app_id, to_char(pid_month, 'MM') AS c1, to_char(pid_month, 'YYYY') AS c2, c3, c4, c5, c6, row_number() over(ORDER BY pid_month) AS rn
  FROM (SELECT app_id,
               pid_month,
               listagg(dic_name, ', ') within GROUP(ORDER BY dic_srtordr) AS c3,
               listagg(pis_edrpou, ', ') within GROUP(ORDER BY pis_edrpou) AS c4,
               to_char(pid_fact_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS c5,
               to_char(pid_calc_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS c6
          FROM (select app_id,
                       pid_month,
                       dic_name,
                       dic_srtordr,
                       pis_edrpou,
                       pid_fact_sum,
                       pid_calc_sum
                  from (SELECT ap.app_id, pd.pid_month, ps.pis_edrpou, pd.pid_fact_sum, pd.pid_calc_sum, ps.pis_tp
                          FROM uss_esr.v_pc_decision d
                          JOIN uss_esr.v_ap_person ap ON ap.app_ap = d.pd_ap
                                                     AND ap.history_status = 'A'
                          JOIN uss_esr.v_pd_income_detail pd ON pd.pid_app = ap.app_id
                                                            AND pd.pid_sc = ap.app_sc
                                                            AND pd.pid_is_family_member = 'T']'
                || (CASE
                        WHEN data_cur.pic_id IS NOT NULL
                        THEN
                               '
                                                            AND pd.pid_pic = '
                            || data_cur.pic_id
                    END)
                || '
                          LEFT JOIN uss_esr.v_pd_income_src ps ON ps.pis_pd = '
                || p_pd_id
                || q'[
                                                              AND ps.pis_app = ap.app_id
                                                              AND ps.pis_is_use = 'T'
                         WHERE d.pd_id = ]'
                || p_pd_id
                || '
                           AND 268 != '
                || data_cur.pd_nst
                || '
                           and (pd.pid_fact_sum is not null or pd.pid_calc_sum is not null)
                        UNION ALL
                        SELECT im.aim_app, im.aim_month, NULL AS pis_edrpou, im.aim_sum AS pid_fact_sum, im.aim_sum AS pid_calc_sum, im.aim_tp AS pis_tp
                          FROM uss_esr.v_apd_income_month im
                         WHERE im.aim_ap = '
                || data_cur.pd_ap
                || '
                           AND '
                || data_cur.pd_nst
                || ' NOT IN (248, 267, 664)
                           and im.aim_sum is not null
                       )
                  LEFT JOIN uss_ndi.v_ddn_apri_tp ON dic_value = pis_tp
                  GROUP BY app_id, pid_month, dic_name, dic_srtordr, pis_edrpou, pid_fact_sum, pid_calc_sum
                )
         GROUP BY app_id, pid_month, pid_fact_sum, pid_calc_sum)
 WHERE 1 = 1');

            rdm$rtfl.adddataset (
                v_jbr_id,
                'total_ds',
                   q'[ SELECT app_id, c5, c6
  FROM (SELECT app_id,
               to_char(sum(pid_fact_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS c5,
               to_char(sum(pid_calc_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS c6
          FROM (SELECT ap.app_id, pd.pid_month, /*ps.pis_edrpou,*/ pd.pid_fact_sum, pd.pid_calc_sum--, ps.pis_tp
                  FROM uss_esr.v_pc_decision d
                  JOIN uss_esr.v_ap_person ap ON ap.app_ap = d.pd_ap
                                             AND ap.history_status = 'A'
                  JOIN uss_esr.v_pd_income_detail pd ON pd.pid_app = ap.app_id
                                                    AND pd.pid_sc = ap.app_sc
                                                    AND pd.pid_is_family_member = 'T']'
                || (CASE
                        WHEN data_cur.pic_id IS NOT NULL
                        THEN
                               '
                                                    AND pd.pid_pic = '
                            || data_cur.pic_id
                    END)
                || '
                  /*LEFT JOIN uss_esr.v_pd_income_src ps ON ps.pis_pd = '
                || p_pd_id
                || q'[
                                                      AND ps.pis_app = ap.app_id
                                                      AND ps.pis_is_use = 'T'*/
                 WHERE d.pd_id = ]'
                || p_pd_id
                || '
                   AND 268 != '
                || data_cur.pd_nst
                || '
                   and (pd.pid_fact_sum is not null or pd.pid_calc_sum is not null)
                UNION ALL
                SELECT im.aim_app, im.aim_month, /*NULL AS pis_edrpou,*/ im.aim_sum AS pid_fact_sum, im.aim_sum AS pid_calc_sum--, im.aim_tp AS pis_tp
                  FROM uss_esr.v_apd_income_month im
                 WHERE im.aim_ap = '
                || data_cur.pd_ap
                || '
                   AND '
                || data_cur.pd_nst
                || ' NOT IN (248, 267, 664)
                   and im.aim_sum is not null
                )
         GROUP BY app_id)
 WHERE 1 = 1');

            rdm$rtfl.addrelation (v_jbr_id,
                                  'group_ds',
                                  'pers_id',
                                  'main_ds',
                                  'app_id');
            rdm$rtfl.addrelation (v_jbr_id,
                                  'group_ds',
                                  'pers_id',
                                  'total_ds',
                                  'app_id');

            rdm$rtfl.adddataset (
                v_jbr_id,
                'group_ds1',
                   q'[SELECT app_id AS pers_id,
       '\par ' || pers_name || (CASE
         WHEN SUM(coalesce(pid_fact_sum, 0)) = 0 THEN
          '\par Дохід відсутній'
       END) AS pers_name1,
       'Сукупний дохід за 12 місяців \par' || 'Сукупний середньомісячний дохід' AS tot_calc_sum_lbl1,
       to_char(SUM(coalesce(pid_fact_sum, 0)), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') || ' \par ' ||
       to_char((SELECT MAX(pdd.pdd_value)
                 FROM uss_esr.v_pd_payment p
                 JOIN uss_esr.v_pd_detail pdd ON pdd.pdd_pdp = p.pdp_id
                                             AND pdd.pdd_ndp = 110
                                             AND instr(upper(pdd.pdd_row_name), upper(pers_name)) > 0
                WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                || p_pd_id
                || q'[),
               'FM9G999G999G999G999G990D00',
               'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_calc_sums1
  FROM (SELECT ap.app_id, ap.app_sc, TRIM(uss_person.api$sc_tools.get_pib(ap.app_sc)) AS pers_name, pd.pid_fact_sum
          FROM uss_esr.v_ap_person ap
          LEFT JOIN uss_esr.v_pd_income_detail pd ON pd.pid_app = ap.app_id
                                                 AND pd.pid_sc = ap.app_sc
                                                 AND pd.pid_is_family_member = 'T']'
                || (CASE
                        WHEN data_cur.pic_id IS NOT NULL
                        THEN
                               '
                                                 AND pd.pid_pic = '
                            || data_cur.pic_id
                    END)
                || '
         WHERE ap.app_ap = '
                || data_cur.pd_ap
                || q'[
           AND ap.history_status = 'A'
           AND ap.app_tp = 'FP'
           AND 268 = ]'
                || data_cur.pd_nst
                || ')
 GROUP BY app_id, pers_name
 ORDER BY 2');

            rdm$rtfl.adddataset (
                v_jbr_id,
                'main_ds1',
                   q'[SELECT app_id, to_char(pid_month, 'MM') AS c1, to_char(pid_month, 'YYYY') AS c2, c3, c4, c5, row_number() over(ORDER BY pid_month) AS rn
  FROM (SELECT app_id,
               pid_month,
               listagg(dic_name, ', ') within GROUP(ORDER BY dic_srtordr) AS c3,
               listagg(pis_edrpou, ', ') within GROUP(ORDER BY pis_edrpou) AS c4,
               to_char(pid_fact_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS c5
          FROM (select app_id,
                       pid_month,
                       tp.dic_name,
                       tp.dic_srtordr,
                       ps.pis_edrpou,
                       pd.pid_fact_sum
                  from uss_esr.v_pc_decision d
                  JOIN uss_esr.v_ap_person ap ON ap.app_ap = d.pd_ap
                                             AND ap.history_status = 'A'
                  JOIN uss_esr.v_pd_income_detail pd ON pd.pid_app = ap.app_id
                                                    AND pd.pid_sc = ap.app_sc
                                                    AND pd.pid_is_family_member = 'T']'
                || (CASE
                        WHEN data_cur.pic_id IS NOT NULL
                        THEN
                               '
                                                    AND pd.pid_pic = '
                            || data_cur.pic_id
                    END)
                || '
                  LEFT JOIN uss_esr.v_pd_income_src ps ON ps.pis_pd = '
                || p_pd_id
                || q'[
                                                      AND ps.pis_app = ap.app_id
                                                      AND ps.pis_is_use = 'T'
                  LEFT JOIN uss_ndi.v_ddn_apri_tp tp ON tp.dic_value = ps.pis_tp
                 WHERE d.pd_id = ]'
                || p_pd_id
                || '
                   AND 268 = '
                || data_cur.pd_nst
                || '
                   and pid_fact_sum is not null
                 GROUP BY ap.app_id, pd.pid_month, pd.pid_fact_sum, pis_edrpou, dic_name, dic_srtordr
               )
         GROUP BY app_id, pid_month, pid_fact_sum)
         WHERE 1 = 1');

            rdm$rtfl.adddataset (
                v_jbr_id,
                'total_ds1',
                   q'[SELECT app_id, c5
  FROM (SELECT ap.app_id,
               to_char(sum(pd.pid_fact_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') AS c5
          FROM uss_esr.v_pc_decision d
          JOIN uss_esr.v_ap_person ap ON ap.app_ap = d.pd_ap
                                     AND ap.history_status = 'A'
          JOIN uss_esr.v_pd_income_detail pd ON pd.pid_app = ap.app_id
                                            AND pd.pid_sc = ap.app_sc
                                            AND pd.pid_is_family_member = 'T']'
                || (CASE
                        WHEN data_cur.pic_id IS NOT NULL
                        THEN
                               '
                                            AND pd.pid_pic = '
                            || data_cur.pic_id
                    END)
                || '
          LEFT JOIN uss_esr.v_pd_income_src ps ON ps.pis_pd = '
                || p_pd_id
                || q'[
                                              AND ps.pis_app = ap.app_id
                                              AND ps.pis_is_use = 'T'
          LEFT JOIN uss_ndi.v_ddn_apri_tp tp ON tp.dic_value = ps.pis_tp
         WHERE d.pd_id = ]'
                || p_pd_id
                || '
           AND 268 = '
                || data_cur.pd_nst
                || '
         GROUP BY ap.app_id)
         WHERE 1 = 1');

            rdm$rtfl.addrelation (v_jbr_id,
                                  'group_ds1',
                                  'pers_id',
                                  'main_ds1',
                                  'app_id');
            rdm$rtfl.addrelation (v_jbr_id,
                                  'group_ds1',
                                  'pers_id',
                                  'total_ds1',
                                  'app_id');

            rdm$rtfl.putreporttoworkingqueue (v_jbr_id);
        END LOOP;

        RETURN v_jbr_id;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Повідомлення"
    -- params: p_rt_id - ідентифікатор шаблону
    --         p_pd_id - ідентифікатор рішення
    -- note:   #70506, #72145, #77804
    FUNCTION assistance_message (p_rt_id   IN rpt_templates.rt_id%TYPE,
                                 p_pd_id   IN NUMBER)
        RETURN DECIMAL
    IS
        v_jbr_id    NUMBER;
        v_rt_code   rpt_templates.rt_code%TYPE;
        v_tmp_str   VARCHAR2 (4000);
    BEGIN
        --#77804 друкована форма для рішень про надання СП (SS)
        FOR c
            IN (  SELECT pd.pd_id,
                         a.ap_id,
                         COALESCE (sc.sc_id, pc.pc_sc)
                             AS pd_sc,
                         RTRIM (
                                MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1874
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                            TRIM (da.apda_val_string) || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1875
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'обл. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1876
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'р-он. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1873
                                        THEN
                                            LTRIM (
                                                   COALESCE (
                                                       (SELECT k.kaot_full_name
                                                          FROM uss_ndi.v_ndi_katottg
                                                               k
                                                         WHERE k.kaot_id =
                                                               da.apda_val_id),
                                                       TRIM (
                                                           da.apda_val_string))
                                                || ', ',
                                                ', ')
                                    END)
                             || COALESCE (
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1879
                                            THEN
                                                LTRIM (
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
                                                    || ', ',
                                                    ', ')
                                        END),
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1878
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   TRIM (da.apda_val_string)
                                                || ', '
                                        END))
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1880
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'буд. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1881
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'корп. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1882
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'кв. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END),
                             ', ')
                             AS pers_fact_addr,
                         o.org_id,
                         o.org_name,
                         pd.pd_st,
                         pd.pd_dt,
                         pd.pd_num,
                         COALESCE (
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 9 THEN f.pde_val_string
                                 END),
                             MAX (
                                 CASE
                                     WHEN     d.apd_ndt = 801
                                          AND da.apda_nda = 1872
                                     THEN
                                         da.apda_val_string
                                 END))
                             AS ss_org_name,
                         MAX (
                             CASE f.pde_nft WHEN 10 THEN f.pde_val_string END)
                             AS ss_pay_need,
                         MAX (
                             CASE
                                 WHEN pd.pd_st IN ('PV', 'AV', 'V')
                                 THEN
                                     (SELECT LISTAGG (
                                                    njr_code
                                                 || ' '
                                                 || njr_name
                                                 || ';',
                                                 CHR (10) || '\par')
                                             WITHIN GROUP (ORDER BY
                                                               njr_order,
                                                               njr_code,
                                                               njr_name)    AS rej_info
                                        FROM v_pd_reject_info
                                             JOIN uss_ndi.v_ndi_reject_reason
                                                 ON njr_id = pri_njr
                                       WHERE pri_pd = p_pd_id)
                             END)
                             AS reject_reason,
                         lt.appr_dt,
                         lt.appr_pib,
                         MAX (CASE d.apd_ndt
                                  WHEN 803
                                  THEN
                                      (SELECT ndt_name
                                         FROM uss_ndi.v_ndi_document_type
                                        WHERE ndt_id = 803)
                              END)
                             AS ndt803_exist,
                         (CASE COUNT (
                                   CASE d.apd_ndt WHEN 801 THEN d.apd_id END)
                              WHEN 0
                              THEN
                                  (SELECT ndt_name
                                     FROM uss_ndi.v_ndi_document_type
                                    WHERE ndt_id = 801)
                          END)
                             AS ndt801_need
                    FROM v_pc_decision pd
                         JOIN v_opfu o ON o.org_id = pd.com_org
                         JOIN v_appeal a
                             ON a.ap_id = pd.pd_ap AND a.ap_tp = 'SS'
                         LEFT JOIN v_pd_pay_method pm
                         JOIN uss_person.v_socialcard sc
                             ON sc.sc_scc = pm.pdm_scc
                             ON     pm.pdm_pd = p_pd_id
                                AND pm.history_status = 'A'
                                AND pm.pdm_is_actual = 'T'
                         LEFT JOIN v_personalcase pc
                             ON pc.pc_id = pd.pd_pc AND sc.sc_id IS NULL
                         LEFT JOIN v_ap_person p
                         JOIN v_ap_document d
                             ON     d.apd_app = p.app_id
                                AND d.apd_ap = p.app_ap
                                AND d.apd_ndt IN (801, 803)
                                AND d.history_status = 'A'
                         JOIN v_ap_document_attr da
                             ON     da.apda_apd = d.apd_id
                                AND da.apda_ap = d.apd_ap
                                AND da.history_status = 'A'
                             ON     p.app_ap = a.ap_id
                                AND p.app_sc = COALESCE (sc.sc_id, pc.pc_sc)
                                AND p.app_tp = 'Z'
                                AND p.history_status = 'A'
                         LEFT JOIN
                         (SELECT l.pdl_id,
                                 FIRST_VALUE (l.pdl_id)
                                     OVER (ORDER BY h.hs_dt DESC)
                                     AS lpdl_id,
                                 h.hs_dt
                                     AS appr_dt,
                                 u.wu_pib
                                     AS appr_pib
                            FROM v_pd_log l
                                 JOIN v_histsession h ON h.hs_id = l.pdl_hs
                                 JOIN ikis_sysweb.v$all_users u
                                     ON u.wu_id = h.hs_wu
                           WHERE l.pdl_pd = p_pd_id AND l.pdl_st = 'P') lt
                             ON lt.pdl_id = lt.lpdl_id AND pd.pd_st = 'P'
                         LEFT JOIN v_pd_features f
                             ON f.pde_pd = p_pd_id AND f.pde_nft IN (9, 10)
                   WHERE pd.pd_id = p_pd_id
                GROUP BY pd.pd_id,
                         a.ap_id,
                         COALESCE (sc.sc_id, pc.pc_sc),
                         o.org_id,
                         o.org_name,
                         pd.pd_st,
                         pd.pd_dt,
                         pd.pd_num,
                         lt.appr_dt,
                         lt.appr_pib)
        LOOP
            --#77050 заборонено формування повідомлення при наявності документа «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803
            IF c.ndt803_exist IS NOT NULL OR get_doc_cnt (c.ap_id, 803) > 0
            THEN
                raise_application_error (
                    -20000,
                       'Звернення було створено на основі документа «'
                    || COALESCE (c.ndt803_exist, get_ndt_name (803))
                    || '», для якого відсутні друковані форми Рішення/Повідомлення');
            ELSIF     c.ndt801_need IS NOT NULL
                  AND get_doc_cnt (c.ap_id, 801) = 0
            THEN                                                      --#86747
                raise_application_error (
                    -20000,
                       'В зверненні відсутній ініціативний документ «'
                    || c.ndt801_need
                    || '»');
            END IF;

            check_signed_docs (p_pd_id => p_pd_id, p_ndt_id => 851);

            v_jbr_id :=
                rdm$rtfl.initreport (
                    get_rt_by_code ('ASSISTANCE_MESSAGE_R2')); --одна форма на відмову і на підтвердження
            rdm$rtfl.addparam (
                v_jbr_id,
                'p1',
                COALESCE (
                    uss_person.api$sc_tools.get_pib (c.pd_sc),
                       '__________________________________________________\par'
                    || '\fs20                    (прізвище, ім’я, по батькові (за наявності) заявника/\par'
                    || '           законного представника / уповноваженого представника сім’ї) \fs24'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p2',
                COALESCE (
                    c.pers_fact_addr,
                       '__________________________________________________\par'
                    || '\fs20                                         (місце проживання/перебування) \fs24\par'
                    || '__________________________________________________\par'
                    || '__________________________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p3',
                COALESCE (
                    c.org_name,
                    '____________________________________________________________________________________\par'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p4',
                COALESCE (
                    (CASE
                         WHEN c.pd_st IN ('R1', 'WD', 'P')
                         THEN
                             '\ul надання \ul0 / відмову'
                         WHEN c.pd_st IN ('PV', 'AV', 'V')
                         THEN
                             'надання / \ul відмову \ul0'
                     END),
                    'надання / відмову'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p5',
                COALESCE (TO_CHAR (c.pd_dt, 'DD.MM.YYYY'), '_______________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p6',
                COALESCE (c.pd_num, '__________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p7',
                COALESCE (
                    uss_person.api$sc_tools.get_pib (c.pd_sc),
                       '____________________________________________________________________________________\par'
                    || '\fs20                               (прізвище, ім’я, по батькові (за наявності) особи, яка потребує надання соціальних послуг) \fs24'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p8',
                COALESCE (
                    c.ss_org_name,
                       '____________________________________________________________________________________\par'
                    || '\fs20                                                               (найменування установи, закладу, організації, підприємства) \fs24'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p91',
                (CASE c.ss_pay_need WHEN 'F' THEN v_check_mark END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p92',
                (CASE c.ss_pay_need WHEN 'C' THEN v_check_mark END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p93',
                (CASE c.ss_pay_need WHEN 'D' THEN v_check_mark END));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p10',
                COALESCE (
                    (CASE
                         WHEN c.pd_st IN ('PV', 'AV', 'V')
                         THEN
                             c.reject_reason
                     END),
                       '_____________________________________________________________________\par'
                    || '____________________________________________________________________________________\par'
                    || '____________________________________________________________________________________\par'
                    || '____________________________________________________________________________________'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p11',
                   '_________________________\par'
                || '\fs20                       (посада) \fs24');
            rdm$rtfl.addparam (
                v_jbr_id,
                'p12',
                COALESCE (
                    TRIM (c.appr_pib),
                       '___________________________________\par'
                    || '\fs20       (прізвище, ім’я, по батькові (за наявності)) \fs24'));
            rdm$rtfl.addparam (
                v_jbr_id,
                'p13',
                COALESCE (TO_CHAR (c.appr_dt, 'DD.MM.YYYY'),
                          '___  _________________ 20___'));

            rdm$rtfl.putreporttoworkingqueue (v_jbr_id);
        END LOOP;

        IF v_jbr_id IS NOT NULL
        THEN
            RETURN v_jbr_id;
        ELSE
            v_rt_code := get_rpt_code (p_rt_id);

            --#72145 тип друкованої форми залежить від статусу рішення
            FOR data_cur
                IN (SELECT uss_person.api$sc_tools.get_pib (
                               COALESCE (sc.sc_id, pc.pc_sc))
                               AS app_name,
                           (CASE pd.pd_nst
                                WHEN 664
                                THEN
                                    (SELECT RTRIM (
                                                   MAX (
                                                       CASE
                                                           WHEN     da.apda_nda =
                                                                    1782
                                                                AND COALESCE (
                                                                        da.apda_val_string,
                                                                        TO_CHAR (
                                                                            da.apda_val_id))
                                                                        IS NOT NULL
                                                           THEN
                                                                  COALESCE (
                                                                      da.apda_val_string,
                                                                      TO_CHAR (
                                                                          da.apda_val_id))
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     da.apda_nda =
                                                                    1781
                                                                AND da.apda_val_string
                                                                        IS NOT NULL
                                                           THEN
                                                                  da.apda_val_string
                                                               || ', '
                                                       END)
                                                || LTRIM (
                                                          COALESCE (
                                                              MAX (
                                                                  CASE da.apda_nda
                                                                      WHEN 1783
                                                                      THEN
                                                                          COALESCE (
                                                                              (CASE
                                                                                   WHEN da.apda_val_id
                                                                                            IS NOT NULL
                                                                                   THEN
                                                                                       get_street_info (
                                                                                           da.apda_val_id)
                                                                               END),
                                                                              da.apda_val_string)
                                                                  END),
                                                              MAX (
                                                                  CASE da.apda_nda
                                                                      WHEN 1786
                                                                      THEN
                                                                          da.apda_val_string
                                                                  END))
                                                       || ', ',
                                                       ', ')
                                                || MAX (
                                                       CASE
                                                           WHEN     da.apda_nda =
                                                                    1784
                                                                AND da.apda_val_string
                                                                        IS NOT NULL
                                                           THEN
                                                                  da.apda_val_string
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     da.apda_nda =
                                                                    1787
                                                                AND da.apda_val_string
                                                                        IS NOT NULL
                                                           THEN
                                                                  da.apda_val_string
                                                               || ', '
                                                       END)
                                                || MAX (
                                                       CASE
                                                           WHEN     da.apda_nda =
                                                                    1780
                                                                AND da.apda_val_string
                                                                        IS NOT NULL
                                                           THEN
                                                                  da.apda_val_string
                                                               || ', '
                                                       END),
                                                ', ')
                                       FROM v_ap_document  d
                                            JOIN v_ap_document_attr da
                                                ON     da.apda_apd = d.apd_id
                                                   AND da.history_status =
                                                       'A'
                                            JOIN
                                            uss_ndi.v_ndi_document_attr a
                                                ON     a.nda_id = da.apda_nda
                                                   AND a.nda_nng = 60
                                      WHERE     d.apd_ap = pd.pd_ap
                                            AND d.apd_ndt = 605
                                            AND d.history_status = 'A'
                                            AND d.apd_app IN
                                                    (SELECT p.app_id
                                                       FROM v_ap_person p
                                                      WHERE     p.app_ap =
                                                                pd.pd_ap
                                                            AND p.app_tp =
                                                                'Z'
                                                            AND p.app_sc =
                                                                COALESCE (
                                                                    sc.sc_id,
                                                                    pc.pc_sc)
                                                            AND p.history_status =
                                                                'A'))
                                ELSE
                                    (SELECT LISTAGG (
                                                   n.nda_name
                                                || ' '
                                                || a.apda_val_string,
                                                ' ')
                                            WITHIN GROUP (ORDER BY
                                                              n.nda_order)
                                       FROM v_ap_document_attr  a
                                            JOIN v_ap_document d
                                                ON     a.apda_apd = d.apd_id
                                                   AND d.apd_ndt = 600
                                                   AND d.apd_app IN
                                                           (SELECT p.app_id
                                                              FROM v_ap_person
                                                                   p
                                                             WHERE     p.app_ap =
                                                                       pd.pd_ap
                                                                   AND p.app_tp =
                                                                       'Z'
                                                                   AND p.app_sc =
                                                                       COALESCE (
                                                                           sc.sc_id,
                                                                           pc.pc_sc)
                                                                   AND p.history_status =
                                                                       'A')
                                                   AND d.history_status = 'A'
                                            JOIN
                                            uss_ndi.v_ndi_document_attr n
                                                ON     a.apda_nda = n.nda_id
                                                   AND n.nda_nng = 2
                                      WHERE     a.apda_ap = pd.pd_ap
                                            AND a.history_status = 'A')
                            END)
                               AS app_fact_addr,
                           pa.pa_num
                               AS pers_acc_num,
                           pd.pd_nst,
                           (SELECT nst_name
                              FROM uss_ndi.v_ndi_service_type
                             WHERE nst_id = pd.pd_nst)
                               AS nst_name,
                           (CASE pm.pdm_pay_tp
                                WHEN 'BANK'
                                THEN
                                       'Банківська установа: '
                                    || b.nb_name
                                    || --#80742
                                       (CASE
                                            WHEN pd.pd_nst != 664
                                            THEN
                                                   CHR (10)
                                                || '\par Номер банківської установи: '
                                                || CHR (10)
                                                || '\par Номер відділення: '
                                        END)
                                    || CHR (10)
                                    || '\par Номер вкладу: '
                                    || pm.pdm_account
                                WHEN 'POST'
                                THEN
                                       'Підприємство зв’язку: '
                                    || k.kaot_name
                                    || CHR (10)
                                    || '\par №: '
                                    || pm.pdm_index
                            END)
                               pay_tp_info,
                           pd.com_org,
                           (SELECT org_name
                              FROM v_opfu
                             WHERE org_id = pd.com_org)
                               AS org_name,
                           (SELECT TRIM (
                                          org_adr
                                       || (CASE
                                               WHEN org_adr IS NOT NULL
                                               THEN
                                                   ', '
                                           END)
                                       || (CASE
                                               WHEN org_tel_upr IS NOT NULL
                                               THEN
                                                   org_tel_upr || ', '
                                           END)
                                       || org_email)
                              FROM ikis_sys.opfu_txtparams
                             WHERE org_id = pd.com_org)
                               AS org_addr,
                           (CASE v_rt_code
                                WHEN 'PAY_REJECT_MESSAGE_R1' THEN pc.pc_num
                            END)
                               AS pers_case_num,
                           (CASE v_rt_code
                                WHEN 'PAY_REJECT_MESSAGE_R1'
                                THEN
                                    (SELECT LISTAGG (
                                                   njr_code
                                                || ' '
                                                || njr_name
                                                || ';',
                                                CHR (10) || '\par')
                                            WITHIN GROUP (ORDER BY
                                                              njr_order,
                                                              njr_code,
                                                              njr_name)
                                       FROM v_pd_reject_info
                                            JOIN uss_ndi.v_ndi_reject_reason
                                                ON njr_id = pri_njr
                                      WHERE pri_pd = p_pd_id)
                            END)
                               AS reject_reason,
                           (CASE pd.pd_nst
                                WHEN 249
                                THEN
                                    (SELECT COALESCE (
                                                SUM (COALESCE (pdp_sum, 0)),
                                                0)
                                       FROM v_pd_payment pz
                                      WHERE     pdp_pd = p_pd_id
                                            AND pz.history_status = 'A')
                            END)
                               AS pd_sum
                      FROM v_pc_decision  pd
                           JOIN v_personalcase pc ON pc.pc_id = pd.pd_pc
                           JOIN v_pc_account pa ON pa.pa_id = pd.pd_pa
                           LEFT JOIN v_pd_pay_method pm
                               ON     pm.pdm_pd = p_pd_id
                                  AND pm.history_status = 'A'
                                  AND pm.pdm_is_actual = 'T'
                           LEFT JOIN uss_person.v_socialcard sc
                               ON sc.sc_scc = pm.pdm_scc
                           LEFT JOIN uss_ndi.v_ndi_katottg k
                               ON k.kaot_id = pm.pdm_kaot
                           LEFT JOIN uss_ndi.v_ndi_bank b
                               ON b.nb_id = pm.pdm_nb
                     WHERE     pd.pd_id = p_pd_id
                           AND (   (    v_rt_code = 'ASSISTANCE_MESSAGE_R1'
                                    AND COALESCE (pd.pd_st, 'E') NOT IN
                                            ('PV', 'AV', 'V'))
                                OR (    v_rt_code = 'PAY_REJECT_MESSAGE_R1'
                                    AND pd.pd_st IN ('PV', 'AV', 'V')))
                           AND ROWNUM < 2)
            LOOP
                --ініціалізація завдання виконується тільки якщо статус рішення відповідає шаблону
                v_jbr_id := rdm$rtfl.initreport (p_rt_id);

                --#73661 деталізація в заголовку залежить від типу допомоги
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'head_desc',
                    (CASE data_cur.pd_nst
                         WHEN 249
                         THEN
                             'ПРО НАДАННЯ ДЕРЖАВНОЇ СОЦІАЛЬНОЇ ДОПОМОГИ \par МАЛОЗАБЕЗПЕЧЕНИМ СІМ’ЯМ'
                         ELSE
                             'ПРО НАДАННЯ ДЕРЖАВНОЇ ДОПОМОГИ СІМ’ЯМ З ДІТЬМИ'
                     END));
                rdm$rtfl.addparam (v_jbr_id, 'app_name', data_cur.app_name);
                rdm$rtfl.addparam (v_jbr_id,
                                   'app_fact_addr',
                                   data_cur.app_fact_addr);
                rdm$rtfl.addparam (v_jbr_id,
                                   'pers_acc_num',
                                   data_cur.pers_acc_num);


                rdm$rtfl.addparam (
                    v_jbr_id,
                    'serv_name',
                    (CASE
                         WHEN data_cur.pd_nst = 249 AND data_cur.pd_sum = 0 --#85333
                         THEN
                             'Відмовлено у призначенні допомоги в зв’язку із тим, що середньомісячний сукупний дохід перевищує розмір рівня забезпечення прожиткового мінімуму для сім’ї'
                         ELSE
                             data_cur.nst_name
                     END));
                rdm$rtfl.addparam (v_jbr_id,
                                   'pay_tp_info',
                                   data_cur.pay_tp_info);
                rdm$rtfl.addparam (v_jbr_id, 'org_name', data_cur.org_name);
                rdm$rtfl.addparam (v_jbr_id, 'org_addr', data_cur.org_addr);

                BEGIN
                    FOR cur
                        IN (  SELECT u1.wu_login, ut.wut_code, u2.wu_pib
                                FROM ikis_sysweb.v$w_users_4gic u1
                                     JOIN ikis_sysweb.v$w_user_type ut
                                         ON ut.wut_id = u1.wu_wut
                                     JOIN ikis_sysweb.v$all_users u2
                                         ON u2.wu_id = u1.wu_id
                               WHERE (   u1.wu_id = tools.getcurrwu
                                      OR u1.wu_org =
                                         COALESCE (data_cur.com_org,
                                                   tools.getcurrorg))
                            ORDER BY (CASE
                                          WHEN u1.wu_id = tools.getcurrwu
                                          THEN
                                              0
                                          ELSE
                                              1
                                      END),
                                     TRIM (u2.wu_pib) NULLS LAST)
                    LOOP
                        IF ikis_sysweb.is_role_assigned (cur.wu_login,
                                                         'W_ESR_MDECISION',
                                                         cur.wut_code)
                        THEN
                            v_tmp_str := TRIM (cur.wu_pib);
                            EXIT;
                        END IF;
                    END LOOP;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

                rdm$rtfl.addparam (v_jbr_id,
                                   'w_esr_mdecision_ep_pib',
                                   v_tmp_str);

                IF v_rt_code = 'ASSISTANCE_MESSAGE_R1'
                THEN
                    rdm$rtfl.adddataset (
                        v_jbr_id,
                        'ds1',
                        (CASE data_cur.pd_nst
                             WHEN 664
                             THEN
                                    q'[SELECT 'з ' || to_char(start_dt, 'DD.MM.YYYY') AS period_info, tot_sum
    FROM (SELECT trunc(pdp_start_dt) AS start_dt,
                 to_char(SUM(pdp_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
            FROM uss_esr.v_pd_payment pdp
           WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                                 || p_pd_id
                                 || q'[
           GROUP BY trunc(pdp_start_dt))
   ORDER BY abs(SYSDATE - start_dt)]'
                             ELSE
                                    q'[SELECT 'з ' || to_char(start_dt, 'DD.MM.YYYY') || ' по ' || (CASE WHEN EXTRACT(YEAR FROM stop_dt) = 2099 THEN 'довічно' ELSE to_char(stop_dt, 'DD.MM.YYYY') END) AS period_info, tot_sum
    FROM (SELECT trunc(pdp_start_dt) AS start_dt,
                 trunc(pdp_stop_dt) AS stop_dt,
                 to_char(SUM(pdp_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
            FROM uss_esr.v_pd_payment pdp
           WHERE 1 = ]'
                                 || (CASE
                                         WHEN     data_cur.pd_nst = 249
                                              AND data_cur.pd_sum = 0
                                         THEN
                                             0
                                         ELSE
                                             1
                                     END)
                                 || q'[
             AND pdp.history_status = 'A'
             AND pdp_pd = ]'
                                 || p_pd_id
                                 || q'[
           GROUP BY trunc(pdp_start_dt), trunc(pdp_stop_dt))
   ORDER BY (CASE WHEN SYSDATE BETWEEN start_dt AND stop_dt THEN 0 ELSE 1 END),
            abs(SYSDATE - start_dt),
            abs(SYSDATE - stop_dt)]'
                         END));
                ELSE
                    rdm$rtfl.addparam (v_jbr_id,
                                       'pers_case_num',
                                       data_cur.pers_case_num);
                    rdm$rtfl.addparam (v_jbr_id,
                                       'reject_reason',
                                       data_cur.reject_reason);
                END IF;

                rdm$rtfl.putreporttoworkingqueue (v_jbr_id);
            END LOOP;

            RETURN v_jbr_id;
        END IF;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу"
    -- params: p_rt_id - ідентифікатор шаблону
    --         p_pd_id - ідентифікатор рішення
    -- note:   #78240
    FUNCTION send_request_notification_r1 (
        p_rt_id   IN rpt_templates.rt_id%TYPE,
        p_pd_id   IN NUMBER)
        RETURN DECIMAL
    IS
        v_jbr_id   NUMBER;
        v_str      VARCHAR2 (4000);
    BEGIN
        FOR c
            IN (  SELECT pd.pd_ap,
                         pd.pd_st,
                         COALESCE (sc.sc_id, pc.pc_sc)
                             AS pd_sc,
                         RTRIM (
                                MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1874
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                            TRIM (da.apda_val_string) || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1875
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'обл. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1876
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'р-он. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1873
                                        THEN
                                            LTRIM (
                                                   COALESCE (
                                                       (SELECT k.kaot_full_name
                                                          FROM uss_ndi.v_ndi_katottg
                                                               k
                                                         WHERE k.kaot_id =
                                                               da.apda_val_id),
                                                       TRIM (
                                                           da.apda_val_string))
                                                || ', ',
                                                ', ')
                                    END)
                             || COALESCE (
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1879
                                            THEN
                                                LTRIM (
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
                                                    || ', ',
                                                    ', ')
                                        END),
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1878
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   TRIM (da.apda_val_string)
                                                || ', '
                                        END))
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1880
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'буд. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1881
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'корп. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1882
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'кв. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END),
                             ', ')
                             AS pers_fact_addr,
                         o.org_id,
                         o.org_name,
                         o.org_to,
                         a.ap_reg_dt,
                         a.ap_num,
                         a.com_org
                             AS ap_org,
                         (SELECT LISTAGG (st.nst_name, ', ')
                                     WITHIN GROUP (ORDER BY st.nst_order)
                            FROM v_ap_service ss
                                 JOIN uss_ndi.v_ndi_service_type st
                                     ON st.nst_id = ss.aps_nst
                           WHERE     ss.aps_ap = pd.pd_ap
                                 AND ss.history_status = 'A')
                             AS nst_name_list,
                         MAX (CASE f.pde_nft WHEN 10 THEN f.pde_val_string END)
                             AS ss_pay_need,
                         lt.reg_trnsfr_dt,
                         lt.appr_pib,
                         /*MAX(CASE
                               WHEN d.apd_ndt = 801 AND da.apda_nda = 1871 THEN
                                da.apda_val_string
                             END) AS p1871,
                         MAX(CASE
                               WHEN d.apd_ndt = 802 AND da.apda_nda = 1948 THEN
                                da.apda_val_string
                             END) AS p1948,*/
                         MAX (CASE d.apd_ndt
                                  WHEN 803
                                  THEN
                                      (SELECT ndt_name
                                         FROM uss_ndi.v_ndi_document_type
                                        WHERE ndt_id = 803)
                              END)
                             AS ndt803_exist,
                         MAX (CASE f.pde_nft WHEN 32 THEN f.pde_val_string END)
                             AS f32,
                         MAX (CASE f.pde_nft WHEN 33 THEN f.pde_val_string END)
                             AS f33,
                         (CASE COUNT (
                                   CASE d.apd_ndt WHEN 801 THEN d.apd_id END)
                              WHEN 0
                              THEN
                                  (SELECT ndt_name
                                     FROM uss_ndi.v_ndi_document_type
                                    WHERE ndt_id = 801)
                          END)
                             AS ndt801_need
                    FROM v_pc_decision pd
                         JOIN v_opfu o ON o.org_id = pd.com_org
                         JOIN v_appeal a
                             ON a.ap_id = pd.pd_ap AND a.ap_tp = 'SS'
                         LEFT JOIN pd_features f
                             ON     f.pde_pd = p_pd_id
                                AND f.pde_nft IN (10, 32, 33)
                         LEFT JOIN v_pd_pay_method pm
                         JOIN uss_person.v_socialcard sc
                             ON sc.sc_scc = pm.pdm_scc
                             ON     pm.pdm_pd = p_pd_id
                                AND pm.history_status = 'A'
                                AND pm.pdm_is_actual = 'T'
                         LEFT JOIN v_personalcase pc
                             ON pc.pc_id = pd.pd_pc AND sc.sc_id IS NULL
                         LEFT JOIN v_ap_person p
                         JOIN v_ap_document d
                             ON     d.apd_app = p.app_id
                                AND d.apd_ap = p.app_ap
                                AND d.apd_ndt IN (801,                /*802,*/
                                                       803)
                                AND d.history_status = 'A'
                         JOIN v_ap_document_attr da
                             ON     da.apda_apd = d.apd_id
                                AND da.apda_ap = d.apd_ap
                                AND da.history_status = 'A'
                             ON     p.app_ap = a.ap_id
                                AND p.app_sc = COALESCE (sc.sc_id, pc.pc_sc)
                                AND p.app_tp = 'Z'
                                AND p.history_status = 'A'
                         JOIN
                         (SELECT MAX (t.reg_trnsfr_dt)     AS reg_trnsfr_dt,
                                 MAX (t.appr_pib)          AS appr_pib
                            FROM (SELECT FIRST_VALUE (
                                             (CASE l.pdl_st
                                                  WHEN 'O.S' THEN h.hs_dt
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS reg_trnsfr_dt,
                                         FIRST_VALUE (
                                             (CASE l.pdl_st
                                                  WHEN 'P' THEN u.wu_pib
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS appr_pib
                                    FROM v_pd_log l
                                         JOIN v_histsession h
                                             ON h.hs_id = l.pdl_hs
                                         JOIN ikis_sysweb.v$all_users u
                                             ON u.wu_id = h.hs_wu
                                   WHERE     l.pdl_pd = p_pd_id
                                         AND l.pdl_st IN ('O.S', 'P')) t) lt
                             ON 1 = 1
                   WHERE pd.pd_id = p_pd_id
                GROUP BY pd.pd_ap,
                         pd.pd_st,
                         COALESCE (sc.sc_id, pc.pc_sc),
                         o.org_id,
                         o.org_name,
                         o.org_to,
                         a.ap_reg_dt,
                         a.ap_num,
                         a.com_org,
                         lt.reg_trnsfr_dt,
                         lt.appr_pib)
        LOOP
            --#77050 заборонено формування рішення при наявності документа «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803
            IF c.ndt803_exist IS NOT NULL OR get_doc_cnt (c.pd_ap, 803) > 0
            THEN
                raise_application_error (
                    -20000,
                       'Звернення було створено на основі документа «'
                    || COALESCE (c.ndt803_exist, get_ndt_name (803))
                    || '», для якого відсутні друковані форми Рішення/Повідомлення');
            ELSIF     c.ndt801_need IS NOT NULL
                  AND get_doc_cnt (c.pd_ap, 801) = 0
            THEN                                                      --#86747
                raise_application_error (
                    -20000,
                       'В зверненні відсутній ініціативний документ «'
                    || c.ndt801_need
                    || '»');
            ELSIF /*c.pd_st NOT IN ('PV', 'AV', 'V') AND (c.p1871 = 'T' OR c.p1948 = 'T')*/
                  --#77873 форма доступна тільки якщо замість рішення формується «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу»
                  c.f32 = 'T' AND c.f33 = 'T' AND c.ap_org = tools.getcurrorg --#79593
            THEN
                check_signed_docs (p_pd_id => p_pd_id, p_ndt_id => 853);
                v_jbr_id := rdm$rtfl.initreport (p_rt_id);

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p1',
                    COALESCE (
                        CASE
                            WHEN get_doc_atr_row (p_pd_id,
                                                  853,
                                                  '2998,2999,3000',
                                                  NULL)
                                     IS NOT NULL
                            THEN
                                get_doc_atr_row (p_pd_id,
                                                 853,
                                                 '2998,2999,3000')
                        END,                                          --#86997
                        uss_person.api$sc_tools.get_pib (c.pd_sc),
                           '____________________________________________________\par'
                        || '\fs20            (прізвище, ім’я, по батькові (за наявності) заявника/\par'
                        || '                      законного представника / уповноваженого\par'
                        || '                                            представника сім’ї) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p2',
                    COALESCE (
                        CASE
                            WHEN get_doc_atr_row (p_pd_id,
                                                  853,
                                                  '3001,3002,3003',
                                                  NULL)
                                     IS NOT NULL
                            THEN
                                   get_doc_atr_row (p_pd_id,
                                                    853,
                                                    '3001,3002,3003')
                                || CASE
                                       WHEN get_doc_atr_str (p_pd_id,
                                                             853,
                                                             3004)
                                                IS NOT NULL
                                       THEN
                                              ' буд. '
                                           || get_doc_atr_str (p_pd_id,
                                                               853,
                                                               3004)
                                   END
                                || CASE
                                       WHEN get_doc_atr_str (p_pd_id,
                                                             853,
                                                             3005)
                                                IS NOT NULL
                                       THEN
                                              ' корп. '
                                           || get_doc_atr_str (p_pd_id,
                                                               853,
                                                               3005)
                                   END
                                || CASE
                                       WHEN get_doc_atr_str (p_pd_id,
                                                             853,
                                                             3006)
                                                IS NOT NULL
                                       THEN
                                              ' кв. '
                                           || get_doc_atr_str (p_pd_id,
                                                               853,
                                                               3006)
                                   END
                        END,                                          --#86997
                        c.pers_fact_addr,
                           '____________________________________________________\par'
                        || '\fs20                              (Місце проживання/перебування) \fs24\par'
                        || '____________________________________________________\par'
                        || '____________________________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p3',
                    COALESCE (
                        get_doc_atr_str (p_pd_id, 853, 3007),         --#86997
                        c.org_name,
                        '____________________________________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p31',
                    COALESCE (
                        get_doc_atr_str (p_pd_id, 853, 3007),         --#86997
                        c.org_name,
                           '________________\par'
                        || '_____________________________________________________________________________________\par'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p32',
                    COALESCE (
                        get_doc_atr_str (p_pd_id, 853, 3007),         --#86997
                        c.org_name,
                           '_____________________________________________\par'
                        || '_____________________________________________________________________________________\par'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p4',
                    COALESCE (get_doc_atr_dt (p_pd_id, 853, 3008),    --#86997
                              TO_CHAR (c.ap_reg_dt, 'DD.MM.YYYY'),
                              '______________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p5',
                    COALESCE (get_doc_atr_str (p_pd_id, 853, 3009),   --#86997
                              c.ap_num,
                              '_____________'));

                IF c.org_to > 31
                THEN
                        SELECT MAX (
                                   CASE
                                       WHEN po.org_to IN (31, 34)
                                       THEN
                                           po.org_name
                                   END)
                          INTO v_str
                          FROM v_opfu po
                         WHERE po.org_st = 'A'
                    START WITH po.org_id =
                               COALESCE (c.org_id, tools.getcurrorg)
                    CONNECT BY PRIOR po.org_org = po.org_id;
                END IF;

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p6',
                    COALESCE (
                        v_str,
                        get_doc_atr_str (p_pd_id, 853, 3010),         --#86997
                        c.org_name,
                        '____________________________________________________________________________________\par'));

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p7',
                    COALESCE (get_doc_atr_dt (p_pd_id, 853, 3011),    --#86997
                              TO_CHAR (c.reg_trnsfr_dt, 'DD.MM.YYYY'),
                              '____________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p8',
                    COALESCE (
                        get_doc_atr_row (p_pd_id, 853, '3012,3013,3014'), --#86997
                        uss_person.api$sc_tools.get_pib (c.pd_sc),
                           '______________________________________\par'
                        || '_____________________________________________________________________________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p81',
                    COALESCE (
                        get_doc_atr_row (p_pd_id, 853, '3012,3013,3014'), --#86997
                        uss_person.api$sc_tools.get_pib (c.pd_sc),
                           '_______________________________________________________________________\par'
                        || '\fs20                                                  (прізвище, ім’я, по батькові (за наявності) отримувача соціальної(них) послуги(г) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p9',
                    COALESCE (get_doc_atr_str (p_pd_id, 853, 3015),
                              '_________'));
                rdm$rtfl.addparam (v_jbr_id,
                                   'p10',
                                   COALESCE (c.nst_name_list, '___________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p111',
                    (CASE c.ss_pay_need WHEN 'F' THEN v_check_mark END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p112',
                    (CASE c.ss_pay_need WHEN 'C' THEN v_check_mark END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p113',
                    (CASE c.ss_pay_need WHEN 'D' THEN v_check_mark END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p12',
                    (CASE c.ss_pay_need
                         WHEN 'C'
                         THEN
                             '\ul платно \ul0 або з установленням диференційованої плати'
                         WHEN 'D'
                         THEN
                             'платно або \ul з установленням диференційованої плати \ul0'
                         ELSE
                             'платно або з установленням диференційованої плати'
                     END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p13',
                    COALESCE (
                        get_doc_atr_str (p_pd_id, 853, 3130),
                           '__________________________\par'
                        || '\fs20 (посада) \fs24'));                        --#87820
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p14',
                    COALESCE (
                        get_doc_atr_row (p_pd_id, 853, '3017,3018,3019'),
                           '____________________________________\par'
                        || '\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p15',
                    COALESCE (TO_CHAR (c.reg_trnsfr_dt, 'DD.MM.YYYY'),
                              '___  _________________ 20___'));       --#87820

                rdm$rtfl.putreporttoworkingqueue (v_jbr_id);
            ELSE
                raise_application_error (
                    -20000,
                    'Формування обраної друкованої форми недоступно для поточного рішення!');
            END IF;
        END LOOP;

        RETURN v_jbr_id;
    END;

    --#91713  РІШЕННЯ про надання / відмову в наданні соціальних послуг (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_850)
    PROCEDURE ASSISTANCE_DECISION_R2_850 (p_at_id    IN     NUMBER,  --id акту
                                          p_Bld_Tp   IN     VARCHAR2, --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)
                                          p_jbr_id      OUT NUMBER,
                                          p_blob        OUT BLOB)
    IS
        CURSOR c_act IS
            SELECT ap.ap_id, ap.ap_is_second
              FROM act a, v_appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id(+) = a.at_ap;

        c       c_act%ROWTYPE;

        l_sql   VARCHAR2 (32000);
    BEGIN
        check_at_signed_docs (p_at_id => p_at_id, p_ndt_id => 850);

        rdm$rtfl_univ.initreport (p_code     => 'ASSISTANCE_DECISION_R2',
                                  p_bld_tp   => p_Bld_Tp);

        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;


        --------------------------------------------------------
        AddParam (
            'p1',
            COALESCE (
                get_at_doc_atr_dt (p_at_id, 2934),
                   '____________________\par'
                || '\fs20      (число, місяць, рік) \fs24'));
        AddParam (
            'p2',
            COALESCE (
                get_at_doc_atr_str (p_at_id, 2935),
                   '____________________\par'
                || '\fs20             (номер рішення) \fs24'));
        AddParam (
            'p3',
            COALESCE (
                get_at_doc_atr_str (p_at_id, 2936),
                '_____________________________________________________________________________________\par'));
        AddParam (
            'p4',
            COALESCE (get_at_doc_atr_dt (p_at_id, 2937),
                      '________________________________'));
        AddParam (
            'p5',
            COALESCE (get_at_doc_atr_str (p_at_id, 2938),
                      '_______________________'));
        AddParam (
            'p6',
            (CASE c.ap_is_second
                 WHEN 'T' THEN 'первинне/ \ul повторне \ul0'
                 ELSE '\ul первинне \ul0 /повторне'
             END));
        AddParam (
            'p7',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '2939,2940,2941', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '2939,2940,2941')
                END,
                   '_____________________________________________________________________________\par'
                || '\fs20                                               (прізвище, ім’я, по батькові (за наявності) заявника / законного представника/\par'
                || '                                                                                   уповноваженого представника сім’ї) \fs24'));
        AddParam (
            'p8',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '2942,2943,2944', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '2942,2943,2944')
                END,
                   '___________________________________\par'
                || '____________________________________________________________________________________\par'
                || '\fs20                                                                                 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
        AddParam (
            'p9',
            COALESCE (
                (CASE get_at_doc_atr_str (p_at_id, 2945)
                     WHEN 'F'
                     THEN
                         'Сім''я/особа не потребує надання соціальних послуг'
                     WHEN 'T'
                     THEN
                         'Сім''я/особа потребує надання соціальних послуг'
                 END),
                   '_____________________________________________\par'
                || '\fs20                                                                                                                       (зазначити результат оцінювання потреб) \fs24'));
        AddParam (
            'p10',
            COALESCE (get_at_doc_atr_sum (p_at_id, 2949),
                      '________________________________'));
        --надати соціальну послугу
        AddParam (
            'p11',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_str (p_at_id, 2951) IS NOT NULL
                    THEN
                           '\ul надати соціальну послугу \ul0 '
                        || get_nst (get_at_doc_atr_str (p_at_id, 2951))
                END,
                   'надати соціальну послугу ____________________________________________________________\par'
                || '\fs20                                                                                                                      (назва соціальної послуги) \fs24'));
        AddParam ('p121', chk_val ('F', get_at_doc_atr_str (p_at_id, 2953)));
        AddParam ('p122', chk_val ('C', get_at_doc_atr_str (p_at_id, 2953)));
        AddParam ('p123', chk_val ('D', get_at_doc_atr_str (p_at_id, 2953)));
        AddParam (
            'p13',
            COALESCE (get_at_doc_atr_sum (p_at_id, 2950), '___________'));
        AddParam (
            'p14',
            COALESCE (
                get_at_doc_atr_str (p_at_id, 2946),
                   '____________________________________________________________\par'
                || '\fs20                                                                                     (найменування установи, закладу, підприємства, організації) \fs24\par'
                || '___________________________________________________________________________________  '));
        --відмовити в наданні соціальної послуги
        AddParam (
            'p15',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_str (p_at_id, 4286) IS NOT NULL
                    THEN
                           '\ul відмовити в наданні соціальної послуги \ul0 '
                        || get_nst (get_at_doc_atr_str (p_at_id, 4286))
                END,
                   'відмовити в наданні соціальної послуги _______________________________________________\par'
                || '\fs20                                                                                                                                   (назва соціальної(их) послуги) \fs24'));
        AddParam (
            'p16',
            COALESCE (
                get_at_doc_atr_str (p_at_id, 2954),
                   '_______________________________________________________________________________\par'
                || '\fs20                                                                                           (причина відмови) \fs24'));

        AddParam (
            'p17',
            COALESCE (
                get_at_doc_atr_str (p_at_id, 3082),
                   '__________________________\par'
                || '\fs20                        (посада) \fs24'));
        AddParam (
            'p18',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '2955,2956,2957', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '2955,2956,2957')
                END,
                   '____________________________________\par'
                || '\fs20         (прізвище, ім’я, по батькові (за наявності)) \fs24'));

        AddParam (
            'p19',
            COALESCE (
                get_at_doc_atr_str (p_at_id, 3083),
                   '__________________________\par'
                || '\fs20                        (посада) \fs24'));
        AddParam (
            'p20',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '2958,2959,2960', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '2958,2959,2960')
                END,
                   '____________________________________\par'
                || '\fs20         (прізвище, ім’я, по батькові (за наявності)) \fs24'));

        AddParam (
            'p52',
            COALESCE (get_at_doc_atr_sum (p_at_id, 2947),
                      '_________________________________'));
        AddParam (
            'p53',
            COALESCE (get_at_doc_atr_sum (p_at_id, 2948),
                      '_________________________________'));
        AddParam (
            'p54',
            COALESCE (get_at_doc_atr_sum (p_at_id, 2949),
                      '_________________________________'));
        AddParam (
            'p55',
            COALESCE (get_at_doc_atr_sum (p_at_id, 2950),
                      '_________________________________'));

        --код датасета поцуплений з: FUNCTION USS_ESR.dnet$pd_reports / assistance_decision, дивись частину до документу 850, рядок приблизно 663
        l_sql :=
            q'[
    SELECT row_number() over(ORDER BY c2, c3) AS c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
     FROM (SELECT t.atp_id,
                 pt.dic_sname AS c2,
                 uss_person.api$sc_tools.get_pib(t.atp_sc) AS c3,
                 td.rltn_tp AS c4,
                 td.doc AS c5,
                 tt.inc_tp AS c6,
                 to_char(SUM(coalesce(t.aid_calc_sum, 0)), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c7,
                 to_char(MAX(CASE WHEN t.aid_month = add_months(t.last_month, -2) THEN t.aid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  || ' \par ' ||
                 to_char(SUM(CASE WHEN t.aid_month = add_months(t.last_month, -2) THEN t.aid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c8,
                 to_char(MAX(CASE WHEN t.aid_month = add_months(t.last_month, -1) THEN t.aid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  ||' \par '||
                 to_char(SUM(CASE WHEN t.aid_month = add_months(t.last_month, -1) THEN t.aid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c9,
                 to_char(MAX(CASE WHEN t.aid_month = t.last_month THEN t.aid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian') || ' \par ' ||
                 to_char(SUM(CASE WHEN t.aid_month = t.last_month THEN t.aid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c10
            FROM (SELECT ap.atp_id, ap.atp_sc, ap.atp_at, ap.atp_app_tp, pd.aid_month, pd.aid_calc_sum, MAX(pd.aid_month) over(PARTITION BY ap.atp_id) AS last_month
                    FROM uss_esr.v_at_person ap
                    JOIN uss_esr.v_personalcase pc ON pc.pc_sc = ap.atp_sc
                    JOIN uss_esr.v_at_income_calc ic ON ic.aic_at = ap.atp_at and ic.aic_pc = pc.pc_id
                    JOIN uss_esr.v_at_income_detail pd ON pd.aid_app = ap.atp_id
                                                      AND pd.aid_sc = ap.atp_sc
                                                      AND pd.aid_is_family_member = 'T'
                                                      AND pd.aid_aic = ic.aic_id
                   WHERE ap.atp_at = :p_at_id
                     AND ap.history_status = 'A'
                     AND ap.atp_app_tp IN ('Z', 'FM', 'OS')) t

            JOIN uss_ndi.v_Ddn_App_Tp pt ON pt.dic_value = t.atp_app_tp
            LEFT JOIN (SELECT d.apd_app,
                             MAX(CASE
                                   WHEN da.apda_nda = 813 AND da.apda_val_string IS NOT NULL
                                     THEN (SELECT t.dic_name FROM uss_ndi.v_ddn_relation_tp t WHERE t.dic_value = da.apda_val_string)
                                 END) AS rltn_tp,
                             coalesce(MAX(CASE da.apda_nda WHEN 1 THEN da.apda_val_string END),
                                      MAX(CASE WHEN da.apda_nda IN (3, 9) THEN da.apda_val_string END)) AS doc
                        FROM uss_esr.v_ap_document d
                        JOIN uss_esr.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                          AND da.apda_ap = d.apd_ap
                                                          AND da.apda_nda IN (1, 3, 9, 813)
                                                          AND da.history_status = 'A'
                       WHERE d.apd_ap = :p_ap_id
                         AND d.apd_ndt IN (5, 6, 7, 605)
                         AND d.history_status = 'A'
                       GROUP BY d.apd_app) td ON td.apd_app = t.atp_id
            LEFT JOIN (SELECT ais_app, ais_sc, listagg(dic_sname, ', ') within GROUP(ORDER BY dic_srtordr) AS inc_tp
                         FROM (SELECT DISTINCT s.ais_app, s.ais_sc, st.dic_sname, st.dic_srtordr
                                 FROM uss_esr.v_at_income_src s
                                 JOIN uss_ndi.v_ddn_apri_tp st ON st.dic_value = s.ais_tp
                                WHERE s.ais_at = :p_at_id)
                        GROUP BY ais_app, ais_sc) tt ON tt.ais_app = t.atp_id
                                                    AND tt.ais_sc = t.atp_sc
           WHERE t.aid_month >= add_months(t.last_month, -2)
           GROUP BY t.atp_id, pt.dic_sname, t.atp_sc, td.rltn_tp, td.doc, tt.inc_tp)
    ]';

        l_sql :=
            REPLACE (REPLACE (l_sql, ':p_at_id', p_at_id),
                     ':p_ap_id',
                     c.ap_id);
        rdm$rtfl_univ.AddDataset ('ds', l_sql);

        /*rdm$rtfl_univ.AddDataset('ds',
                            q'[SELECT row_number() over(ORDER BY c2, c3) AS c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
         FROM (SELECT t.app_id,
                 pt.dic_sname AS c2,
                 uss_person.api$sc_tools.get_pib(t.app_sc) AS c3,
                 td.rltn_tp AS c4,
                 td.doc AS c5,
                 tt.inc_tp AS c6,
                 to_char(SUM(coalesce(t.pid_calc_sum, 0)), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c7,
                 to_char(MAX(CASE WHEN t.pid_month = add_months(t.last_month, -2) THEN t.pid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  || ' \par ' ||
                 to_char(SUM(CASE WHEN t.pid_month = add_months(t.last_month, -2) THEN t.pid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c8,
                 to_char(MAX(CASE WHEN t.pid_month = add_months(t.last_month, -1) THEN t.pid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  ||' \par '||
                 to_char(SUM(CASE WHEN t.pid_month = add_months(t.last_month, -1) THEN t.pid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c9,
                 to_char(MAX(CASE WHEN t.pid_month = t.last_month THEN t.pid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian') || ' \par ' ||
                 to_char(SUM(CASE WHEN t.pid_month = t.last_month THEN t.pid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c10
            FROM (SELECT ap.app_id, ap.app_sc, ap.app_tp, pd.pid_month, pd.pid_calc_sum, MAX(pd.pid_month) over(PARTITION BY ap.app_id) AS last_month
                    FROM uss_esr.v_ap_person ap
                    JOIN uss_esr.v_pd_income_detail pd ON pd.pid_app = ap.app_id
                                                      AND pd.pid_sc = ap.app_sc
                                                      AND pd.pid_is_family_member = 'T']' ||
                                                      (CASE WHEN c.pic_idnull IS NOT NULL THEN '
                                                      AND pd.pid_pic = ' || to_char(c.pic_id)null END) || '
                   WHERE ap.app_ap = ' || nullto_char(c.ap_id) || q'[
                     AND ap.history_status = 'A'
                     AND ap.app_tp IN ('Z', 'FM', 'OS')) t
            JOIN uss_ndi.v_ddn_app_tp pt ON pt.dic_value = t.app_tp
            LEFT JOIN (SELECT d.apd_app,
                             MAX(CASE
                                   WHEN da.apda_nda = 813 AND da.apda_val_string IS NOT NULL
                                     THEN (SELECT t.dic_name FROM uss_ndi.v_ddn_relation_tp t WHERE t.dic_value = da.apda_val_string)
                                 END) AS rltn_tp,
                             coalesce(MAX(CASE da.apda_nda WHEN 1 THEN da.apda_val_string END),
                                      MAX(CASE WHEN da.apda_nda IN (3, 9) THEN da.apda_val_string END)) AS doc
                        FROM uss_esr.v_ap_document d
                        JOIN uss_esr.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                          AND da.apda_ap = ]' || to_char(c.ap_id) null|| q'[
                                                          AND da.apda_nda IN (1, 3, 9, 813)
                                                          AND da.history_status = 'A'
                       WHERE d.apd_ap = ]' || to_char(c.ap_id) null|| q'[
                         AND d.apd_ndt IN (5, 6, 7, 605)
                         AND d.history_status = 'A'
                       GROUP BY d.apd_app) td ON td.apd_app = t.app_id
            LEFT JOIN (SELECT pis_app, pis_sc, listagg(dic_sname, ', ') within GROUP(ORDER BY dic_srtordr) AS inc_tp
                         FROM (SELECT DISTINCT s.pis_app, s.pis_sc, st.dic_sname, st.dic_srtordr
                                 FROM uss_esr.v_pd_income_src s
                                 JOIN uss_ndi.v_ddn_apri_tp st ON st.dic_value = s.pis_tp
                                WHERE s.pis_pd = ]' || to_char(p_pd_id)null || q'[)
                        GROUP BY pis_app, pis_sc) tt ON tt.pis_app = t.app_id
                                                    AND tt.pis_sc = t.app_sc
           WHERE t.pid_month >= add_months(t.last_month, -2)
           GROUP BY t.app_id, pt.dic_sname, t.app_sc, td.rltn_tp, td.doc, tt.inc_tp)]');*/

        -----------------------------------------
        --результуючий blob
        rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                         p_rpt_blob   => p_blob);
        replace_ekr (p_blob);
    END;

    --#91716 ПОВІДОМЛЕННЯ про надання / відмову в наданні соціальних послуг  (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_851)
    PROCEDURE ASSISTANCE_MESSAGE_R2_851 (p_at_id    IN     NUMBER,   --id акту
                                         p_Bld_Tp   IN     VARCHAR2, --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)
                                         p_jbr_id      OUT NUMBER,
                                         p_blob        OUT BLOB)
    IS
    BEGIN
        check_at_signed_docs (p_at_id => p_at_id, p_ndt_id => 851);

        rdm$rtfl_univ.initreport (p_code     => 'ASSISTANCE_MESSAGE_R2',
                                  p_bld_tp   => p_Bld_Tp);

        --------------------------------------------------------
        AddParam (
            'p1',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '2963,2964,2965', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '2963,2964,2965')
                END,
                '_______________________________________________'));
        AddParam (
            'p2',
            COALESCE (
                Get_adr (p_ind     => get_at_doc_atr_str (p_at_id, 2966),
                         p_katot   => get_at_doc_atr_str (p_at_id, 2967),
                         p_strit   => get_at_doc_atr_str (p_at_id, 2968),
                         p_bild    => get_at_doc_atr_str (p_at_id, 2969),
                         p_korp    => get_at_doc_atr_str (p_at_id, 2970),
                         p_kv      => get_at_doc_atr_str (p_at_id, 2971)),
                '_______________________________________________'));


        AddParam (
            'p3',
            COALESCE (
                get_at_doc_atr_str (p_at_id, 2975),
                '_________________________________________________________________________________'));

        --надання / відмову в наданні соціальних послуг
        AddParam (
            'p4',
            CASE get_at_doc_atr_str (p_at_id, 2997)
                WHEN 'T' THEN '\ulнадання\ul0 / відмову в наданні'
                WHEN 'F' THEN 'надання / \ulвідмову в наданні\ul0'
                ELSE 'надання / відмову в наданні'
            END);

        AddParam (
            'p5',
            COALESCE (get_at_doc_atr_dt (p_at_id, 2961), '____________'));
        AddParam (
            'p6',
            COALESCE (get_at_doc_atr_str (p_at_id, 2962), '____________'));
        --отримувач
        AddParam (
            'p7',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '2972,2973,2974', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '2972,2973,2974')
                END,
                '_________________________________________________________________________________'));
        --установа надавач послуг
        AddParam (
            'p8',
            COALESCE (
                get_at_doc_atr_str (p_at_id, 3084),
                '_________________________________________________________________________________'));
        --cпосіб надання соціальних послуг
        AddParam ('p91', chk_val ('F', get_at_doc_atr_str (p_at_id, 2976)));
        AddParam ('p92', chk_val ('C', get_at_doc_atr_str (p_at_id, 2976)));
        AddParam ('p93', chk_val ('D', get_at_doc_atr_str (p_at_id, 2976)));
        --Причина відмови
        AddParam (
            'p10',
            COALESCE (get_at_doc_atr_dt (p_at_id, 2977),
                      '___________________________'));
        --підпис
        AddParam ('p11', get_at_doc_atr_str (p_at_id, 3085));
        AddParam ('p12', get_at_doc_atr_row (p_at_id, '2978,2979,2980'));

        AddParam (
            'p13',
            NVL (get_at_doc_atr_dt (p_at_id, 5348),
                 '___  _______________ 20___'));

        -----------------------------------------
        --результуючий blob
        rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                         p_rpt_blob   => p_blob);
        replace_ekr (p_blob);
    END;

    --#91717 Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу
    PROCEDURE PLACEMENT_APPLICATION_R1_852 (p_at_id    IN     NUMBER, --id акту
                                            p_Bld_Tp   IN     VARCHAR2, --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)
                                            p_jbr_id      OUT NUMBER,
                                            p_blob        OUT BLOB)
    IS
        CURSOR c_act IS
            SELECT ap.ap_id
              FROM act a, v_appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id = a.at_ap;

        c       c_act%ROWTYPE;

        l_str   VARCHAR2 (32000);
    BEGIN
        check_at_signed_docs (p_at_id => p_at_id, p_ndt_id => 852);

        rdm$rtfl_univ.initreport (p_code     => 'PLACEMENT_APPLICATION_R1',
                                  p_bld_tp   => p_Bld_Tp);

        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --------------------------------------------------------
        AddParam ('p1', get_at_doc_atr_str (p_at_id, 2982));
        AddParam ('p2', get_at_doc_atr_row (p_at_id, '2983,2984,2985')); --заявник
        AddParam ('p3', get_at_doc_atr_dt (p_at_id, 2986));
        AddParam ('p4', get_at_doc_atr_str (p_at_id, 2987));
        AddParam ('p5', get_at_doc_atr_str (p_at_id, 2988)); --організація надавач
        AddParam ('p6', get_at_doc_atr_row (p_at_id, '2989,2990,2991')); --отримувач

        l_str := get_at_doc_atr_str (p_at_id, 2992);

          SELECT LISTAGG (
                     DECODE (l_str,
                             t.dic_value, '\ul' || t.dic_name || '\ul0',
                             t.dic_name))
                 WITHIN GROUP (ORDER BY dic_srtordr)
            INTO l_str
            FROM uss_ndi.v_ddn_ss_method t
           WHERE t.dic_st = 'A'
        ORDER BY t.dic_srtordr;

        AddParam ('p7', l_str);

        SELECT LISTAGG (ndt_name, ', ') WITHIN GROUP (ORDER BY ndt_order)
          INTO l_str
          FROM (SELECT DISTINCT dt.ndt_name, dt.ndt_order
                  FROM v_ap_document  d
                       JOIN uss_ndi.v_ndi_document_type dt
                           ON dt.ndt_id = d.apd_ndt
                 WHERE d.apd_ap = c.ap_id AND d.history_status = 'A');

        AddParam (
            'p8',
            COALESCE (l_str, 'пакет документів (зазначити повний перелік)'));

        --підпис
        AddParam (
            'p9',
            COALESCE (get_at_doc_atr_str (p_at_id, 2993),
                      '__________________'));
        AddParam (
            'p10',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '2994,2995,2996', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '2994,2995,2996')
                END,
                '_______________________________'));

        AddParam ('p11', '___  _______________ 20___');

        -----------------------------------------
        --результуючий blob
        rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                         p_rpt_blob   => p_blob);
        replace_ekr (p_blob);
    END;

    -- #91719 Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу
    PROCEDURE SEND_REQUEST_NOTIFICATION_R1_853 (p_at_id    IN     NUMBER, --id акту
                                                p_Bld_Tp   IN     VARCHAR2, --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)
                                                p_jbr_id      OUT NUMBER,
                                                p_blob        OUT BLOB)
    IS
        CURSOR c_act IS
            SELECT ap.ap_id
              FROM act a, v_appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id = a.at_ap;

        c       c_act%ROWTYPE;

        l_str   VARCHAR2 (32000);
    BEGIN
        check_at_signed_docs (p_at_id => p_at_id, p_ndt_id => 853);

        rdm$rtfl_univ.initreport (p_code     => 'SEND_REQUEST_NOTIFICATION_R1',
                                  p_bld_tp   => p_Bld_Tp);

        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --------------------------------------------------------
        AddParam ('p1', get_at_doc_atr_row (p_at_id, '2998,2999,3000')); --заявник
        AddParam (
            'p2',
            COALESCE (
                Get_adr (p_ind     => get_at_doc_atr_str (p_at_id, 3001),
                         p_katot   => get_at_doc_atr_str (p_at_id, 3002),
                         p_strit   => get_at_doc_atr_str (p_at_id, 3003),
                         p_bild    => get_at_doc_atr_str (p_at_id, 3004),
                         p_korp    => get_at_doc_atr_str (p_at_id, 3005),
                         p_kv      => get_at_doc_atr_str (p_at_id, 3006)),
                '_______________________________________________'));


        AddParam ('p3', get_at_doc_atr_str (p_at_id, 3007)); --організація місцева
        AddParam ('p4', get_at_doc_atr_dt (p_at_id, 3008));            --заява
        AddParam ('p5', get_at_doc_atr_str (p_at_id, 3009));

        AddParam ('p6', get_at_doc_atr_str (p_at_id, 3010)); --організація обласного рівня
        AddParam ('p7', get_at_doc_atr_dt (p_at_id, 3011));
        AddParam ('p8', get_at_doc_atr_row (p_at_id, '3012,3013,3014')); --отримувач
        AddParam ('p9', get_at_doc_atr_sum (p_at_id, 3015)); --середньомісячний сукупний дохід

          SELECT LISTAGG (st.nst_name, ', ')
                     WITHIN GROUP (ORDER BY st.nst_order)
            INTO l_str
            FROM uss_esr.at_service s, uss_ndi.v_ndi_service_type st
           WHERE     s.ats_at = p_at_id
                 AND s.history_status = 'A'
                 AND s.ats_st IN ('PP', 'SG', 'P')
                 AND st.nst_id = s.ats_nst
        ORDER BY st.nst_order;

        AddParam ('p10', l_str);              --соціальна(і) послуга - перелік

        --cпосіб надання соціальних послуг
        AddParam ('p111', chk_val ('F', get_at_doc_atr_str (p_at_id, 3016)));
        AddParam ('p112', chk_val ('C', get_at_doc_atr_str (p_at_id, 3016)));
        AddParam ('p113', chk_val ('D', get_at_doc_atr_str (p_at_id, 3016)));
        AddParam (
            'p12',
            CASE
                WHEN get_at_doc_atr_str (p_at_id, 3016) = 'C'
                THEN
                    '\ulплатно\ul0 або з установленням диференційованої плати'
                WHEN get_at_doc_atr_str (p_at_id, 3016) = 'D'
                THEN
                    'платно або \ulз установленням диференційованої плати\ul0'
                ELSE
                    'платно або з установленням диференційованої плати'
            END);       -- критерії поки невідомі, виводиться без підкреслення
        --підпис
        AddParam (
            'p13',
            COALESCE (get_at_doc_atr_str (p_at_id, NULL),
                      '__________________'));
        AddParam (
            'p14',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '3017,3018,3019', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '3017,3018,3019')
                END,
                '_______________________________'));

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                         p_rpt_blob   => p_blob);
        replace_ekr (p_blob);
    END;

    --#91721 ndt 854 «Путівка на влаштування до інтернатної(го) установи/закладу»  (uss_esr.DNET$PAY_TERMINATE/FUNCTION Fill_Attrs_854)
    PROCEDURE PLACEMENT_VOUCHER_R1_854 (p_at_id    IN     NUMBER,    --id акту
                                        p_Bld_Tp   IN     VARCHAR2, --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)
                                        p_jbr_id      OUT NUMBER,
                                        p_blob        OUT BLOB)
    IS
        CURSOR c_act IS
            SELECT ap.ap_id
              FROM act a, v_appeal ap
             WHERE a.at_id = p_at_id AND ap.ap_id = a.at_ap;

        c       c_act%ROWTYPE;

        l_str   VARCHAR2 (32000);
    BEGIN
        check_at_signed_docs (p_at_id => p_at_id, p_ndt_id => 854);

        rdm$rtfl_univ.initreport (p_code     => 'PLACEMENT_VOUCHER_R1',
                                  p_bld_tp   => p_Bld_Tp);

        OPEN c_act;

        FETCH c_act INTO c;

        CLOSE c_act;

        --------------------------------------------------------

        AddParam ('p1', get_at_doc_atr_str (p_at_id, 3021));     --організація
        AddParam (
            'p2',
            COALESCE (
                Get_adr (p_ind     => get_at_doc_atr_str (p_at_id, 3032),
                         p_katot   => get_at_doc_atr_str (p_at_id, 3033),
                         p_strit   => get_at_doc_atr_str (p_at_id, 3034),
                         p_bild    => get_at_doc_atr_str (p_at_id, 3035),
                         p_korp    => get_at_doc_atr_str (p_at_id, 3036),
                         p_kv      => get_at_doc_atr_str (p_at_id, 3037)),
                '_________________________________________'));

        AddParam (
            'p3',
            COALESCE (
                Get_adr (p_ind     => get_at_doc_atr_str (p_at_id, 3038),
                         p_katot   => get_at_doc_atr_str (p_at_id, 3039),
                         p_strit   => get_at_doc_atr_str (p_at_id, 3040),
                         p_bild    => get_at_doc_atr_str (p_at_id, 3041),
                         p_korp    => get_at_doc_atr_str (p_at_id, 3042),
                         p_kv      => get_at_doc_atr_str (p_at_id, 3043)),
                '_________________________________________'));

        AddParam ('p4', get_at_doc_atr_row (p_at_id, '3022,3023,3024')); --отримувач
        AddParam (
            'p5',
            COALESCE (get_at_doc_atr_dt (p_at_id, 3025), '________________')); --дата народження
        AddParam (
            'p6',
            COALESCE (get_at_doc_atr_str (p_at_id, 3026), '________________')); --група інвалідності
        --cпосіб надання соціальних послуг
        AddParam ('p71', chk_val ('F', get_at_doc_atr_str (p_at_id, 3016)));
        AddParam ('p72', chk_val ('C', get_at_doc_atr_str (p_at_id, 3016)));
        AddParam ('p73', chk_val ('D', get_at_doc_atr_str (p_at_id, 3016)));
        AddParam ('p8', get_at_doc_atr_sum (p_at_id, 3028)); --середньомісячний сукупний дохід
        AddParam ('p9', get_at_doc_atr_sum (p_at_id, 3029));
        AddParam ('p10', 'пенсії / \ul державної соціальної допомоги \ul0');
        AddParam ('p11', get_at_doc_atr_str (p_at_id, 3031));    --організація
        AddParam ('p12', '______');
        AddParam (
            'p13',
            COALESCE (get_at_doc_atr_dt (p_at_id, 3044), '________________'));
        AddParam (
            'p14',
            COALESCE (get_at_doc_atr_dt (p_at_id, 3045), '________________'));
        --постійно, тимчасово
        l_str := get_at_doc_atr_str (p_at_id, 3046);

        SELECT LISTAGG (
                   CASE l_str
                       WHEN dic_value THEN '\ul ' || dic_sname || '\ul0 '
                       ELSE dic_sname
                   END,
                   ' / ')
               WITHIN GROUP (ORDER BY dic_srtordr)
          INTO l_str
          FROM uss_ndi.v_ddn_rnsp_stay t;

        AddParam ('p15-0', l_str);

        AddParam (
            'p15',
            COALESCE (get_at_doc_atr_dt (p_at_id, 3047), '________________'));
        AddParam (
            'p16',
            COALESCE (get_at_doc_atr_dt (p_at_id, 3048), '________________'));
        AddParam (
            'p17',
            COALESCE (get_at_doc_atr_dt (p_at_id, 3049), '________________'));

        --підпис
        AddParam (
            'p20',
            COALESCE (get_at_doc_atr_str (p_at_id, 3050),
                      '__________________'));
        AddParam (
            'p21',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '3051,3052,3053', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '3051,3052,3053')
                END,
                '_______________________________'));
        AddParam (
            'p22',
            COALESCE (get_at_doc_atr_str (p_at_id, 3055),
                      '__________________'));
        AddParam (
            'p23',
            COALESCE (
                CASE
                    WHEN get_at_doc_atr_row (p_at_id, '3056,3057,3058', NULL)
                             IS NOT NULL
                    THEN
                        get_at_doc_atr_row (p_at_id, '3056,3057,3058')
                END,
                '_______________________________'));
        AddParam (
            'p24',
            COALESCE (get_at_doc_atr_dt (p_at_id, NULL),
                      '"____"________________20___року'));

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                         p_rpt_blob   => p_blob);
        replace_ekr (p_blob);
    END PLACEMENT_VOUCHER_R1_854;

    --91436 Повідомлення СПСЗН про прийняття особи на обслуговування до інтернатного закладу
    PROCEDURE ACT_DOC_855_R1 (p_at_id    IN     NUMBER,              --id акту
                              p_Bld_Tp   IN     VARCHAR2, --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)
                              p_jbr_id      OUT NUMBER,
                              p_blob        OUT BLOB)
    IS
    BEGIN
        check_at_signed_docs (p_at_id => p_at_id, p_ndt_id => 855);

        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_855_R1',
                                  p_bld_tp   => p_Bld_Tp);
        --------------------------------------------------------

        AddParam ('p1', get_at_doc_atr_str (p_at_id, 4232));       --Путівка №
        AddParam ('p2', get_at_doc_atr_Dt (p_at_id, 4233));
        AddParam ('p3', get_at_doc_atr_str (p_at_id, 4234)); --найменування СПСЗН обласного рівня
        AddParam ('p4', get_at_doc_atr_row (p_at_id, '4235,4236,4237')); --отримувач
        AddParam ('p5', get_at_doc_atr_str (p_at_id, 4238)); --найменування інтернатної установи/закладу
        AddParam ('p6', get_at_doc_atr_Dt (p_at_id, 4239));      --дата наказу
        AddParam ('p7', get_at_doc_atr_str (p_at_id, 4240));        --№ наказу
        AddParam ('p9', get_at_doc_atr_str (p_at_id, 4241)); --найменування органу ПФУ/СПСЗН
        AddParam ('p9', get_at_doc_atr_str (p_at_id, 4242)); --Повідомлення направлено
        AddParam ('p10', get_at_doc_atr_row (p_at_id, '4243,4244,4245')); --ПІБ директора

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                         p_rpt_blob   => p_blob);
        replace_ekr (p_blob);
    END ACT_DOC_855_R1;

    --#91438 «Повідомлення органу ПФУ про прийняття на обслуговування до інтернатного закладу»
    PROCEDURE ACT_DOC_856_R1 (p_at_id    IN     NUMBER,              --id акту
                              p_Bld_Tp   IN     VARCHAR2, --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)
                              p_jbr_id      OUT NUMBER,
                              p_blob        OUT BLOB)
    IS
    BEGIN
        check_at_signed_docs (p_at_id => p_at_id, p_ndt_id => 856);

        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_856_R1',
                                  p_bld_tp   => p_Bld_Tp);
        --------------------------------------------------------

        AddParam ('p1',
                  Get_adr (p_ind     => get_at_doc_atr_str (p_at_id, 4247),
                           p_katot   => get_at_doc_atr_str (p_at_id, 4246),
                           p_strit   => get_at_doc_atr_str (p_at_id, 4248),
                           p_bild    => get_at_doc_atr_str (p_at_id, 4249),
                           p_korp    => get_at_doc_atr_str (p_at_id, 4250),
                           p_kv      => NULL)); ----Місце знаходження органу ПФУ/СППСЗН
        AddParam ('p2', get_at_doc_atr_str (p_at_id, 4251)); --найменування інтернатної установи/закладу
        AddParam ('p3',
                  Get_adr (p_ind     => get_at_doc_atr_str (p_at_id, 4253),
                           p_katot   => get_at_doc_atr_str (p_at_id, 4252),
                           p_strit   => get_at_doc_atr_str (p_at_id, 4254),
                           p_bild    => get_at_doc_atr_str (p_at_id, 4255),
                           p_korp    => get_at_doc_atr_str (p_at_id, 4256),
                           p_kv      => NULL)); --місцезнаходження інтернатної установи/закладу
        AddParam ('p4', get_at_doc_atr_Dt (p_at_id, 4257));      --дата наказу
        AddParam ('p5', get_at_doc_atr_str (p_at_id, 4258));
        AddParam ('p6', get_at_doc_atr_Dt (p_at_id, 4259)); --дата прийняття до інтернатної установи/закладу
        AddParam ('p7', get_at_doc_atr_row (p_at_id, '4260,4261,4262')); --отримувач
        AddParam ('p8', get_at_doc_atr_Dt (p_at_id, 4263));
        AddParam ('p9',
                  Get_adr (p_ind     => get_at_doc_atr_str (p_at_id, 4265),
                           p_katot   => get_at_doc_atr_str (p_at_id, 4264),
                           p_strit   => get_at_doc_atr_str (p_at_id, 4266),
                           p_bild    => get_at_doc_atr_str (p_at_id, 4267),
                           p_korp    => get_at_doc_atr_str (p_at_id, 4268),
                           p_kv      => get_at_doc_atr_str (p_at_id, 4269))); --отримувач - адреса
        AddParam ('p10', get_at_doc_atr_str (p_at_id, 4270));
        AddParam ('p11', get_at_doc_atr_str (p_at_id, 4271));
        AddParam ('p12', get_at_doc_atr_str (p_at_id, 4272));
        AddParam ('p13', get_at_doc_atr_row (p_at_id, '4273,4274,4275')); --прізвище отримувача / законного представника
        AddParam ('p14', get_at_doc_atr_str (p_at_id, 4276)); --заява особи чи її законного представника або заява керівника інтернатної(го) установи/закладу
        AddParam ('p15', get_at_doc_atr_row (p_at_id, '4277,42778,4279')); --ПІБ директора

        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                         p_rpt_blob   => p_blob);
        replace_ekr (p_blob);
    END ACT_DOC_856_R1;

    --#91757 «Повідомлення надавача про надання / відмову в наданні соціальних послуг»
    PROCEDURE ACT_DOC_843_R1 (p_at_id    IN     NUMBER,              --id акту
                              p_Bld_Tp   IN     VARCHAR2, --тип звіту (rdm$rtfl_univ.c_Bld_Tp_Svc/rdm$rtfl_univ.c_Bld_Tp_Db)
                              p_jbr_id      OUT NUMBER,
                              p_blob        OUT BLOB)
    IS
        l_sql   VARCHAR2 (32000);
    BEGIN
        check_at_signed_docs (p_at_id => p_at_id, p_ndt_id => 843);

        rdm$rtfl_univ.initreport (p_code     => 'ACT_DOC_843_R1',
                                  p_bld_tp   => p_Bld_Tp);
        --------------------------------------------------------
        AddParam ('p1', get_at_doc_atr_row (p_at_id, '3665,3666,3667')); --ПІБ заявника
        AddParam (
            'p2',
            get_at_doc_atr_str (
                p_at_id,
                Get_adr (p_ind     => get_at_doc_atr_str (p_at_id, 3669),
                         p_katot   => get_at_doc_atr_str (p_at_id, 3668),
                         p_strit   => get_at_doc_atr_str (p_at_id, 3670),
                         p_bild    => get_at_doc_atr_str (p_at_id, 3671),
                         p_korp    => get_at_doc_atr_str (p_at_id, 3672),
                         p_kv      => get_at_doc_atr_str (p_at_id, 3673)))); -- адреса
        AddParam ('p3', get_at_doc_atr_str (p_at_id, 3659)); --Найменування надавача соціальних послуг
        AddParam ('p4', get_at_doc_atr_str (p_at_id, 3660)); --Назва розпорядчого документу
        AddParam ('p5', get_at_doc_atr_dt (p_at_id, 3662));
        AddParam ('p6', get_at_doc_atr_str (p_at_id, 3661));

        --рішення про #p7#надання / відмову
        AddParam (
            'p7',
            CASE
                WHEN     AtSrv_Nst_List (p_at_id, 1) IS NOT NULL
                     AND AtSrv_Nst_List (p_at_id, 0) IS NULL
                THEN
                    '\ulнадання\ul0 / відмову в наданні' --надати соціальну послугу
                WHEN     AtSrv_Nst_List (p_at_id, 1) IS NULL
                     AND AtSrv_Nst_List (p_at_id, 0) IS NOT NULL
                THEN
                    'надання / \ulвідмову в наданні\ul0'           --відмовити
                ELSE
                    'надання / відмову в наданні' --монета встала на ребро, не можемо визначитись...
            END);            -- прийняте рішення uss_ndi.V_DDN_RNSP_PROVIDE_SS

        l_sql :=
            q'[
      select
            nst_name,
            uss_esr.dnet$pd_reports.chk_val('F', tp) p8_1,
            uss_esr.dnet$pd_reports.chk_val('C', tp) p8_2,
            uss_esr.dnet$pd_reports.chk_val('D', tp) p8_3
       from
           (select s.ats_st, nst.nst_name,
                   case (select max(l.arl_nrr) from uss_esr.at_right_log l where l.arl_at = s.ats_at
                            and l.arl_ats = s.ats_id and l.arl_nrr in (222,224,225) and l.arl_result = 'T')
                        when 222 then 'F'-- безоплатно
                        when 224 then 'C'-- платно
                        when 225 then 'D'-- діф.плата
                   end tp
              from uss_esr.at_service s, uss_ndi.v_ndi_service_type nst
             where s.ats_at = #p_at_id# and s.history_status = 'A' and nst.nst_id = s.ats_nst
               --and s.ats_st in ('PP', 'SG', 'P')
            )
    ]';
        l_sql := REPLACE (l_sql, '#p_at_id#', p_at_id);
        rdm$rtfl_univ.AddDataset ('ds', l_sql);

        AddParam ('p8', get_at_doc_atr_str (p_at_id, NULL));

        AddParam ('p9', get_at_doc_atr_row (p_at_id, '3674,3675,3676')); --прізвище отримувача
        --cпосіб надання соціальних послуг
        AddParam ('p10_1', chk_val ('F', get_at_doc_atr_str (p_at_id, 3677)));
        AddParam ('p10_2', chk_val ('C', get_at_doc_atr_str (p_at_id, 3677)));
        AddParam ('p10_3', chk_val ('D', get_at_doc_atr_str (p_at_id, 3677)));

        AddParam ('p11', get_at_doc_atr_str (p_at_id, 3678)); --Причина відмови

        AddParam ('p12', get_at_doc_atr_str (p_at_id, 3679)); --Посада підписанта
        AddParam ('p15', get_at_doc_atr_row (p_at_id, '3680,3681,3682')); --ПІБ директора
        -----------------------------------------
        rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                         p_rpt_blob   => p_blob);
        replace_ekr (p_blob);
    END ACT_DOC_843_R1;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Путівка на влаштування до інтернатної(го) установи/закладу"
    -- params: p_rt_id - ідентифікатор шаблону
    --         p_pd_id - ідентифікатор рішення
    -- note:   #78241
    FUNCTION placement_voucher_r1 (p_rt_id   IN rpt_templates.rt_id%TYPE,
                                   p_pd_id   IN NUMBER)
        RETURN DECIMAL
    IS
        v_jbr_id   NUMBER;
        p142       VARCHAR2 (1000);
    BEGIN
        FOR c
            IN (  SELECT pd.pd_st,
                         MAX (
                             CASE f.pde_nft WHEN 9 THEN f.pde_val_string END)
                             AS ss_org_name, -- назва надавача інтернатної установи, якого було встановлено у рішенні на вкладці «Надавач»
                         RTRIM (
                                MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1874
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                            TRIM (da.apda_val_string) || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1875
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'обл. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1876
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'р-он. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1873
                                        THEN
                                            LTRIM (
                                                   COALESCE (
                                                       (SELECT k.kaot_full_name
                                                          FROM uss_ndi.v_ndi_katottg
                                                               k
                                                         WHERE k.kaot_id =
                                                               da.apda_val_id),
                                                       TRIM (
                                                           da.apda_val_string))
                                                || ', ',
                                                ', ')
                                    END)
                             || COALESCE (
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1879
                                            THEN
                                                LTRIM (
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
                                                    || ', ',
                                                    ', ')
                                        END),
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1878
                                                 AND TRIM (da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   TRIM (da.apda_val_string)
                                                || ', '
                                        END))
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1880
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'буд. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1881
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'корп. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1882
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'кв. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END),
                             ', ')
                             AS pers_fact_addr, -- місце проживання/перебування отримувача
                         RTRIM (
                                MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1886
                                        THEN
                                            TRIM (da.apda_val_string) || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1887
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'обл. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1888
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'р-он. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1889
                                        THEN
                                            LTRIM (
                                                   COALESCE (
                                                       (SELECT k.kaot_full_name
                                                          FROM uss_ndi.v_ndi_katottg
                                                               k
                                                         WHERE k.kaot_id =
                                                               da.apda_val_id),
                                                       TRIM (
                                                           da.apda_val_string))
                                                || ', ',
                                                ', ')
                                    END)
                             || COALESCE (
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1891
                                            THEN
                                                LTRIM (
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
                                                    || ', ',
                                                    ', ')
                                        END),
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1890
                                                 AND TRIM (da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   TRIM (da.apda_val_string)
                                                || ', '
                                        END))
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1892
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'буд. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1893
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'корп. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END)
                             || MAX (
                                    CASE
                                        WHEN     d.apd_ndt = 801
                                             AND da.apda_nda = 1894
                                             AND TRIM (da.apda_val_string)
                                                     IS NOT NULL
                                        THEN
                                               'кв. '
                                            || TRIM (da.apda_val_string)
                                            || ', '
                                    END),
                             ', ')
                             AS pers_reg_addr, -- зареєстроване місце проживання
                         COALESCE (sc.sc_id, pc.pc_sc)
                             AS pd_sc,                            -- отримувач
                         MAX (
                             CASE
                                 WHEN     d.apd_ndt IN (6, 7, 801)
                                      AND da.apda_nda IN (606, 607, 1899)
                                 THEN
                                     da.apda_val_dt
                             END)
                             AS app_brth_dt,     -- дата народження отримувача
                         MAX (
                             CASE
                                 WHEN     d.apd_ndt = 605
                                      AND da.apda_nda IN (666, 1790)
                                      AND da.apda_val_string IS NOT NULL
                                 THEN
                                     (SELECT dic_sname
                                        FROM uss_ndi.v_ddn_scy_group
                                       WHERE dic_value = da.apda_val_string)
                             END)
                             AS dsblt_grp,               -- група інвалідності
                         MAX (CASE f.pde_nft WHEN 10 THEN f.pde_val_string END)
                             AS ss_pay_need, -- тип оплати відповідно до встановленого у рішенні (ставити символ «v» у відповідному квадратику)
                         o.org_name, -- назва органу ПФУ / органу СЗН, в якому проводиться виплата
                         MAX (CASE f.pde_nft WHEN 14 THEN f.pde_val_dt END)
                             AS pass_start_dt,          -- cтрок дії путівки з
                         MAX (CASE f.pde_nft WHEN 13 THEN f.pde_val_dt END)
                             AS pass_stop_dt,          -- cтрок дії путівки по
                         MAX (CASE f.pde_nft WHEN 12 THEN f.pde_val_dt END)
                             AS term_start_dt,         -- термін перебування з
                         MAX (CASE f.pde_nft WHEN 11 THEN f.pde_val_dt END)
                             AS term_stop_dt,         -- термін перебування по
                         lt.prep_pib,
                         lt.appr_pib,
                         lt.fnl_appr_pib,
                         lt.fnl_appr_dt,
                         MAX (CASE d.apd_ndt
                                  WHEN 803
                                  THEN
                                      (SELECT ndt_name
                                         FROM uss_ndi.v_ndi_document_type
                                        WHERE ndt_id = 803)
                              END)
                             AS ndt803_exist,
                         MAX (CASE f.pde_nft WHEN 32 THEN f.pde_val_string END)
                             AS f32,
                         MAX (CASE f.pde_nft WHEN 33 THEN f.pde_val_string END)
                             AS f33,
                         (CASE COUNT (
                                   CASE d.apd_ndt WHEN 801 THEN d.apd_id END)
                              WHEN 0
                              THEN
                                  (SELECT ndt_name
                                     FROM uss_ndi.v_ndi_document_type
                                    WHERE ndt_id = 801)
                          END)
                             AS ndt801_need,
                         a.ap_id
                    FROM v_pc_decision pd
                         JOIN v_opfu o ON o.org_id = pd.com_org
                         JOIN v_appeal a
                             ON a.ap_id = pd.pd_ap AND a.ap_tp = 'SS'
                         LEFT JOIN v_pd_pay_method pm
                         JOIN uss_person.v_socialcard sc
                             ON sc.sc_scc = pm.pdm_scc
                             ON     pm.pdm_pd = p_pd_id
                                AND pm.history_status = 'A'
                                AND pm.pdm_is_actual = 'T'
                         LEFT JOIN v_personalcase pc
                             ON pc.pc_id = pd.pd_pc AND sc.sc_id IS NULL
                         LEFT JOIN pd_features f
                             ON     f.pde_pd = p_pd_id
                                AND f.pde_nft IN (9,
                                                  10,
                                                  11,
                                                  12,
                                                  13,
                                                  14,
                                                  32,
                                                  33)
                         LEFT JOIN v_ap_person p
                         JOIN v_ap_document d
                             ON     d.apd_app = p.app_id
                                AND d.apd_ap = p.app_ap
                                AND d.apd_ndt IN (6,
                                                  7,
                                                  605,
                                                  801,
                                                  802,
                                                  803)
                                AND d.history_status = 'A'
                         JOIN v_ap_document_attr da
                             ON     da.apda_apd = d.apd_id
                                AND da.apda_ap = d.apd_ap
                                AND da.history_status = 'A'
                             ON     p.app_ap = a.ap_id
                                AND p.app_sc = COALESCE (sc.sc_id, pc.pc_sc)
                                AND p.app_tp = 'Z'
                                AND p.history_status = 'A'
                         JOIN
                         (SELECT MAX (t.prep_pib)         AS prep_pib,
                                 MAX (t.appr_pib)         AS appr_pib,
                                 MAX (t.fnl_appr_pib)     AS fnl_appr_pib,
                                 MAX (t.fnl_appr_dt)      AS fnl_appr_dt
                            FROM (SELECT FIRST_VALUE (
                                             (CASE
                                                  WHEN     l.pdl_st_old =
                                                           'O.R0'
                                                       AND l.pdl_st = 'O.R2'
                                                  THEN
                                                      u.wu_pib
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS prep_pib,
                                         FIRST_VALUE (
                                             (CASE
                                                  WHEN     l.pdl_st_old =
                                                           'O.R2'
                                                       AND l.pdl_st = 'O.WD'
                                                  THEN
                                                      u.wu_pib
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS appr_pib,
                                         FIRST_VALUE (
                                             (CASE
                                                  WHEN     l.pdl_st_old =
                                                           'O.WD'
                                                       AND l.pdl_st = 'O.P'
                                                  THEN
                                                      u.wu_pib
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS fnl_appr_pib,
                                         FIRST_VALUE (
                                             (CASE l.pdl_st
                                                  WHEN 'O.P' THEN h.hs_dt
                                              END) IGNORE NULLS)
                                             OVER (ORDER BY h.hs_dt DESC)
                                             AS fnl_appr_dt
                                    FROM v_pd_log l
                                         JOIN v_histsession h
                                             ON h.hs_id = l.pdl_hs
                                         JOIN ikis_sysweb.v$all_users u
                                             ON u.wu_id = h.hs_wu
                                   WHERE     l.pdl_pd = p_pd_id
                                         AND l.pdl_st IN
                                                 ('O.R2', 'O.WD', 'O.P')) t) lt
                             ON 1 = 1
                   WHERE pd.pd_id = p_pd_id
                GROUP BY pd.pd_st,
                         COALESCE (sc.sc_id, pc.pc_sc),
                         o.org_name,
                         lt.prep_pib,
                         lt.appr_pib,
                         lt.fnl_appr_pib,
                         lt.fnl_appr_dt,
                         a.com_org,
                         a.ap_id)
        LOOP
            --#77050 заборонено формування рішення при наявності документа «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803
            IF c.ndt803_exist IS NOT NULL OR get_doc_cnt (c.ap_id, 803) > 0
            THEN
                raise_application_error (
                    -20000,
                       'Звернення було створено на основі документа «'
                    || COALESCE (c.ndt803_exist, get_ndt_name (803))
                    || '», для якого відсутні друковані форми Рішення/Повідомлення');
            ELSIF     c.ndt801_need IS NOT NULL
                  AND get_doc_cnt (c.ap_id, 801) = 0
            THEN                                                      --#86747
                raise_application_error (
                    -20000,
                       'В зверненні відсутній ініціативний документ «'
                    || c.ndt801_need
                    || '»');
            ELSIF               /*c.pd_st IN ('O.R0', 'O.R2', 'O.WD', 'O.P')*/
                  --#77873 форма доступна тільки у рішеннях про надання СП (SS) в зверненнях, які знаходяться у статусах O.R0 / O.R2 / O.WD / O.P
                     (c.f32 = 'T' AND COALESCE (c.f33, 'F') = 'F')
                  OR (    c.pd_st IN ('O.R0',
                                      'O.R2',
                                      'O.WD',
                                      'O.P')
                      AND tools.getcurrorgto IN (31, 34))             --#79593
            THEN
                check_signed_docs (p_pd_id => p_pd_id, p_ndt_id => 854);
                v_jbr_id := rdm$rtfl.initreport (p_rt_id);

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p1',
                    COALESCE (
                        get_doc_atr_str (p_pd_id   => p_pd_id,
                                         p_ndt     => 854,
                                         p_nda     => 3021),          --#86997
                        c.ss_org_name,
                           ' _____________________________________________________________________________________\par'
                        || '\fs20                                                                              (найменування інтернатної установи/закладу) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p2',
                    COALESCE (
                        CASE
                            WHEN get_doc_atr_row (
                                     p_pd_id   => p_pd_id,
                                     p_ndt     => 854,
                                     p_nda     =>
                                         '3032,3033,3034,3035,3036,3037',
                                     dlmt      => NULL)
                                     IS NOT NULL
                            THEN
                                   get_doc_atr_row (
                                       p_pd_id   => p_pd_id,
                                       p_ndt     => 854,
                                       p_nda     => '3032,3033,3034')
                                || CASE
                                       WHEN get_doc_atr_str (
                                                p_pd_id   => p_pd_id,
                                                p_ndt     => 854,
                                                p_nda     => 3035)
                                                IS NOT NULL
                                       THEN
                                              ' буд. '
                                           || get_doc_atr_str (
                                                  p_pd_id   => p_pd_id,
                                                  p_ndt     => 854,
                                                  p_nda     => 3035)
                                   END
                                || CASE
                                       WHEN get_doc_atr_str (
                                                p_pd_id   => p_pd_id,
                                                p_ndt     => 854,
                                                p_nda     => 3036)
                                                IS NOT NULL
                                       THEN
                                              ' корп. '
                                           || get_doc_atr_str (
                                                  p_pd_id   => p_pd_id,
                                                  p_ndt     => 854,
                                                  p_nda     => 3036)
                                   END
                                || CASE
                                       WHEN get_doc_atr_str (
                                                p_pd_id   => p_pd_id,
                                                p_ndt     => 854,
                                                p_nda     => 3037)
                                                IS NOT NULL
                                       THEN
                                              ' кв. '
                                           || get_doc_atr_str (
                                                  p_pd_id   => p_pd_id,
                                                  p_ndt     => 854,
                                                  p_nda     => 3037)
                                   END
                        END,                                          --#86997
                        c.pers_fact_addr,
                           '___________________________________________\par'
                        || '_________________________________________________________________________________ '));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p3',
                    COALESCE (
                        CASE
                            WHEN get_doc_atr_row (
                                     p_pd_id   => p_pd_id,
                                     p_ndt     => 854,
                                     p_nda     =>
                                         '3038,3039,3040,3041,3042,3043',
                                     dlmt      => NULL)
                                     IS NOT NULL
                            THEN
                                   get_doc_atr_row (
                                       p_pd_id   => p_pd_id,
                                       p_ndt     => 854,
                                       p_nda     => '3038,3039,3040')
                                || CASE
                                       WHEN get_doc_atr_str (
                                                p_pd_id   => p_pd_id,
                                                p_ndt     => 854,
                                                p_nda     => 3041)
                                                IS NOT NULL
                                       THEN
                                              ' буд. '
                                           || get_doc_atr_str (
                                                  p_pd_id   => p_pd_id,
                                                  p_ndt     => 854,
                                                  p_nda     => 3041)
                                   END
                                || CASE
                                       WHEN get_doc_atr_str (
                                                p_pd_id   => p_pd_id,
                                                p_ndt     => 854,
                                                p_nda     => 3042)
                                                IS NOT NULL
                                       THEN
                                              ' корп. '
                                           || get_doc_atr_str (
                                                  p_pd_id   => p_pd_id,
                                                  p_ndt     => 854,
                                                  p_nda     => 3042)
                                   END
                                || CASE
                                       WHEN get_doc_atr_str (
                                                p_pd_id   => p_pd_id,
                                                p_ndt     => 854,
                                                p_nda     => 3043)
                                                IS NOT NULL
                                       THEN
                                              ' кв. '
                                           || get_doc_atr_str (
                                                  p_pd_id   => p_pd_id,
                                                  p_ndt     => 854,
                                                  p_nda     => 3043)
                                   END
                        END,                                          --#86997
                        c.pers_reg_addr,
                        '_______________________________________________________ '));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p4',
                    COALESCE (
                        CASE
                            WHEN get_doc_atr_row (
                                     p_pd_id   => p_pd_id,
                                     p_ndt     => 854,
                                     p_nda     => '3022,3023,3024',
                                     dlmt      => NULL)
                                     IS NOT NULL
                            THEN
                                get_doc_atr_row (
                                    p_pd_id   => p_pd_id,
                                    p_ndt     => 854,
                                    p_nda     => '3022,3023,3024')
                        END,                                          --#86997
                        uss_person.api$sc_tools.get_pib (c.pd_sc),
                           '____________________________________________________________________________________ ,\par'
                        || '\fs20                                                        (прізвище, ім’я, по батькові (за наявності) особи, яка направляється) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p5',
                    COALESCE (
                        get_doc_atr_dt (p_pd_id   => p_pd_id,
                                        p_ndt     => 854,
                                        p_nda     => 3025),           --#86997
                        TO_CHAR (c.app_brth_dt, 'DD.MM.YYYY'),
                        '«___» _____________________  ________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p6',
                    COALESCE (
                        get_doc_atr_str (p_pd_id   => p_pd_id,
                                         p_ndt     => 854,
                                         p_nda     => 3026),          --#86997
                        c.dsblt_grp,
                        '________________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p61',
                    (CASE
                         WHEN     c.dsblt_grp IS NULL
                              AND c.app_brth_dt IS NULL
                              AND get_doc_atr_dt (p_pd_id   => p_pd_id,
                                                  p_ndt     => 854,
                                                  p_nda     => 3025)
                                      IS NULL
                              AND get_doc_atr_dt (p_pd_id   => p_pd_id,
                                                  p_ndt     => 854,
                                                  p_nda     => 3026)
                                      IS NULL
                         THEN
                             '\fs20                                                                                                                                   (за наявності) \fs24'
                         WHEN     c.dsblt_grp IS NULL
                              AND get_doc_atr_dt (p_pd_id   => p_pd_id,
                                                  p_ndt     => 854,
                                                  p_nda     => 3026)
                                      IS NULL
                              AND (   c.app_brth_dt IS NOT NULL
                                   OR get_doc_atr_dt (p_pd_id   => p_pd_id,
                                                      p_ndt     => 854,
                                                      p_nda     => 3025)
                                          IS NOT NULL)
                         THEN
                             '\fs20                                                                   (за наявності) \fs24'
                     END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p71',
                    (CASE c.ss_pay_need WHEN 'F' THEN v_check_mark END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p72',
                    (CASE c.ss_pay_need WHEN 'C' THEN v_check_mark END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p73',
                    (CASE c.ss_pay_need WHEN 'D' THEN v_check_mark END));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p8',
                    COALESCE (get_doc_atr_sum (p_pd_id, 854, 3028),
                              '__________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p9',
                    COALESCE (get_doc_atr_sum (p_pd_id, 854, 3029),
                              '___________'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p10',
                    'пенсії / \ul державної соціальної допомоги \ul0');
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p11',
                    COALESCE (
                        get_doc_atr_str (p_pd_id, 854, 3031),         --#86997
                        c.org_name,
                           '____________________________________________________________________________________ .\par'
                        || '\fs20 (найменування органу Пенсійного фонду України / структурного підрозділу з питань соціального захисту населення\par'
                        || '                       районної, районної у місті Києві / Севастополі державної адміністрації, виконавчого органу міської,\par'
                        || '                                                районної у місті (крім міст Києва та Севастополя) ради (у разі її утворення) \fs24'));
                rdm$rtfl.addparam (v_jbr_id,
                                   'p12',
                                   COALESCE (NULL, '______'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p13',
                    COALESCE (get_doc_atr_dt (p_pd_id, 854, 3044),
                              TO_CHAR (c.pass_start_dt, 'DD.MM.YYYY'),
                              '«___» _____________  _______'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p14',
                    COALESCE (get_doc_atr_dt (p_pd_id, 854, 3045),
                              TO_CHAR (c.pass_stop_dt, 'DD.MM.YYYY'),
                              '«___» _____________  _______'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p141',
                    (CASE
                         WHEN     (   c.pass_start_dt IS NULL
                                   OR c.pass_stop_dt IS NULL)
                              AND (   get_doc_atr_dt (p_pd_id, 854, 3044)
                                          IS NULL
                                   OR get_doc_atr_dt (p_pd_id, 854, 3045)
                                          IS NULL)
                         THEN
                             '\par                                                                   (не може бути більше ніж 14 календарних днів) \fs24'
                     END));
                --постійно, тимчасово
                p142 := get_doc_atr_str (p_pd_id, 854, 3046);

                SELECT LISTAGG (
                           CASE p142
                               WHEN dic_value
                               THEN
                                   '\ul ' || dic_sname || '\ul0 '
                               ELSE
                                   dic_sname
                           END,
                           ' / ')
                       WITHIN GROUP (ORDER BY dic_srtordr)
                  INTO p142
                  FROM uss_ndi.v_ddn_rnsp_stay t;

                rdm$rtfl.addparam (v_jbr_id, 'p142', p142);

                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p15',
                    COALESCE (get_doc_atr_dt (p_pd_id, 854, 3047),
                              TO_CHAR (c.term_start_dt, 'DD.MM.YYYY'),
                              '«___»_________ _______'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p16',
                    COALESCE (get_doc_atr_dt (p_pd_id, 854, 3048),
                              TO_CHAR (c.term_stop_dt, 'DD.MM.YYYY'),
                              '«___» __________  ____'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p17',
                    COALESCE (get_doc_atr_dt (p_pd_id, 854, 3049),
                              TO_CHAR (SYSDATE, 'DD.MM.YYYY'),
                              '___  _______________  _______'));
                /* #87820
                rdm$rtfl.addparam(v_jbr_id, 'p18', coalesce(NULL, '____________________________\par\fs20                         (посада) \fs24'));
                rdm$rtfl.addparam(v_jbr_id,
                                  'p19',
                                  coalesce(c.prep_pib,
                                           '______________________________________\par\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                rdm$rtfl.addparam(v_jbr_id, 'p20', coalesce(NULL, '____________________________\par\fs20                         (посада) \fs24'));
                rdm$rtfl.addparam(v_jbr_id,
                                  'p21',
                                  coalesce(c.appr_pib,
                                           '______________________________________\par\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));*/
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p18',
                    COALESCE (
                        NULL,
                        '____________________________\par\fs20                         (посада) \fs24'));       --#87820
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p19',
                    COALESCE (
                        NULL,
                        '______________________________________\par\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));                                   --#87820
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p20',
                    COALESCE (
                        get_doc_atr_str (p_pd_id   => p_pd_id,
                                         p_ndt     => 854,
                                         p_nda     => 3050),
                        '____________________________\par\fs20                         (посада) \fs24'));       --#87820
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p21',
                    COALESCE (
                        get_doc_atr_row (p_pd_id, 854, '3051, 3052, 3053'),
                        '______________________________________\par\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));                                   --#87820
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p22',
                    COALESCE (
                        get_doc_atr_str (p_pd_id   => p_pd_id,
                                         p_ndt     => 854,
                                         p_nda     => 3055),
                           '_______________________________\par\fs20 (посада керівника структурного підрозділу\par'
                        || 'з питань соціального захисту населення) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p23',
                    COALESCE (
                        get_doc_atr_row (p_pd_id, 854, '3056, 3057, 3058'), --c.fnl_appr_pib,
                        '______________________________________\par\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                rdm$rtfl.addparam (
                    v_jbr_id,
                    'p24',
                    COALESCE (TO_CHAR (c.fnl_appr_dt, 'DD.MM.YYYY'),
                              '___  ___________________ 20___'));

                rdm$rtfl.putreporttoworkingqueue (v_jbr_id);
            ELSE
                /*SELECT listagg('"' || dic_sname || '"', ', ') within GROUP(ORDER BY dic_srtordr)
                  INTO v_str
                  FROM uss_ndi.v_ddn_pd_st
                 WHERE dic_code IN ('O.R0', 'O.R2', 'O.WD', 'O.P');
                raise_application_error(-20000,
                                        'Формування обраної друкованої форми доступно тільки для рішень в статусах ' || v_str);*/
                raise_application_error (
                    -20000,
                    'Формування обраної друкованої форми недоступно для поточного рішення!');
            END IF;
        END LOOP;

        RETURN v_jbr_id;
    END;

    -----------------------------------------------------------------
    --Ініціалізація процесу підготовки звіту "Звіт щодо роботи в ЄСР"
    -----------------------------------------------------------------
    PROCEDURE reg_report_work_esr_get (p_com_org       appeal.com_org%TYPE,
                                       p_d_start       DATE,
                                       p_d_end         DATE,
                                       p_jbr_id    OUT NUMBER)
    IS
        l_sql    VARCHAR2 (4000);
        o_name   VARCHAR2 (4000);
    BEGIN
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.REG_REPORT_WORK_ESP_GET',
            action_name   => 'p_com_org=' || TO_CHAR (p_com_org));
        p_jbr_id :=
            rdm$rtfl.initreport (get_rt_by_code ('REPORT_WORK_ESR_R1'));

        IF p_com_org IS NULL
        THEN
            raise_application_error (-20000, 'Організвцію не заповнено');
        END IF;

        SELECT org_code || ' ' || org_name
          INTO o_name
          FROM ikis_sys.v_opfu
         WHERE org_id = p_com_org;


        rdm$rtfl.addparam (p_jbr_id,
                           'p_d_start',
                           TO_CHAR (p_d_start, 'dd.mm.yyyy'));
        rdm$rtfl.addparam (p_jbr_id,
                           'p_d_end',
                           TO_CHAR (p_d_end, 'dd.mm.yyyy'));
        rdm$rtfl.addparam (p_jbr_id, 'p_org_name', o_name);

        l_sql :=
            q'[
      SELECT to_char(dt, 'dd.mm.yyyy') as ds_d, org_code as ds_cod, org_name as ds_name,
             to_char(nvl("cnt1",0), '999990') as ds_cnt1,
             to_char(nvl("cnt2",0), '999990') as ds_cnt2,
             to_char(nvl("cnt3",0), '999990') as ds_cnt3
      FROM (  SELECT TRUNC(ap.ap_reg_dt) dt, op.org_code, op.org_name, '1' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_esr.v_Appeal ap
                   JOIN ikis_sys.v_opfu  op ON ap.com_org = op.org_id
              WHERE ap.ap_reg_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_id in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND ap.com_wu != 97478614 --U53222-DEV
              GROUP BY TRUNC(ap.ap_reg_dt), op.org_code, op.org_name
              UNION ALL
              SELECT TRUNC(hs.hs_dt) dt, op.org_code, op.org_name, '2' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_esr.v_Appeal ap
                   JOIN ikis_sys.v_opfu  op ON ap.com_org = op.org_id
                   JOIN Uss_esr.v_Pc_Decision pd ON  pd.pd_ap = ap.ap_id OR pd.pd_ap_reason = ap.ap_id
                   JOIN Uss_esr.v_pd_log pdl ON pdl.pdl_pd = pd.pd_id
                   JOIN Uss_esr.v_histsession hs ON hs.hs_id = pdl.pdl_hs
              WHERE hs.hs_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_id in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND NOT ( pdl.pdl_message = CHR(38)||'17'
                              AND pdl.pdl_st_old = 'R0'
                              AND pdl.pdl_st = 'W' )
                    AND hs.HS_WU != 97478614 --U53222-DEV
              GROUP BY TRUNC(hs.hs_dt), op.org_code, op.org_name
              UNION ALL
              SELECT TRUNC(hs.hs_dt) dt, op.org_code, op.org_name, '3' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_esr.v_appeal ap
                   JOIN ikis_sys.v_opfu op ON ap.com_org = op.org_id
                   JOIN Uss_esr.v_Pc_Decision pd ON pd.pd_ap = ap.ap_id
                   JOIN Uss_esr.v_pd_log pdl ON pdl.pdl_pd = pd.pd_id
                   JOIN Uss_esr.v_histsession hs ON hs.hs_id = pdl.pdl_hs
              WHERE hs.hs_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_id in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND  ( pdl.pdl_message = CHR(38)||'17'
                           AND pdl.pdl_st_old = 'R0'
                           AND pdl.pdl_st = 'W' )
                    AND hs.HS_WU != 97478614 --U53222-DEV
              GROUP BY TRUNC(hs.hs_dt), op.org_code, op.org_name
           )
           PIVOT
           (
              max(cnt)
              FOR src IN ( 1 "cnt1",  2 "cnt2",  3 "cnt3")
           )
      ORDER BY dt]';

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
              FROM Uss_esr.v_Appeal ap
                   JOIN ikis_sys.v_opfu  op ON ap.com_org = op.org_id
              WHERE ap.ap_reg_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_id in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND ap.com_wu != 97478614 --U53222-DEV
              UNION ALL
              SELECT '2' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_esr.v_Pc_Decision pd
                   JOIN Uss_esr.v_appeal ap  ON ap.ap_id = pd.pd_ap
                   JOIN ikis_sys.v_opfu op ON ap.com_org = op.org_id
                   JOIN Uss_esr.v_pd_log pdl ON pdl.pdl_pd = pd.pd_id
                   JOIN Uss_esr.v_histsession hs ON hs.hs_id = pdl.pdl_hs
              WHERE hs.hs_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_id in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND NOT ( pdl.pdl_message = CHR(38)||'17'
                              AND pdl.pdl_st_old = 'R0'
                              AND pdl.pdl_st = 'W' )
                    AND hs.HS_WU != 97478614 --U53222-DEV
              UNION ALL
              SELECT '3' src, COUNT(DISTINCT ap.ap_id ) cnt
              FROM Uss_esr.v_appeal ap
                   JOIN ikis_sys.v_opfu op ON ap.com_org = op.org_id
                   JOIN Uss_esr.v_Pc_Decision pd ON pd.pd_ap = ap.ap_id
                   JOIN Uss_esr.v_pd_log pdl ON pdl.pdl_pd = pd.pd_id
                   JOIN Uss_esr.v_histsession hs ON hs.hs_id = pdl.pdl_hs
              WHERE hs.hs_dt BETWEEN to_date('p_d_start','dd.mm.yyyy') AND to_date('p_d_end 23:59:59','dd.mm.yyyy hh24:mi:ss')
                    AND op.org_id in (SELECT org_id FROM ikis_sys.v_opfu t WHERE t.org_st = 'A' CONNECT BY PRIOR t.org_id = t.org_org START WITH t.org_id = p_com_org)
                    AND ( pdl.pdl_message = CHR(38)||'17'
                          AND pdl.pdl_st_old = 'R0'
                          AND pdl.pdl_st = 'W' )
                    AND hs.HS_WU != 97478614 --U53222-DEV
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

    -- info:   Ініціалізація процесу підготовки друкованої форми "Рішення про припинення надання соціальних послуг"
    -- params: p_rt_code - код шаблону шаблону
    --         p_at_id - ідентифікатор рішення
    -- note:   #87276   ndt_id = 860
    PROCEDURE decision_term_prov_ss_r1_main (
        p_rt_code    IN     rpt_templates.rt_code%TYPE,
        p_at_id      IN     NUMBER,
        p_bld_tp     IN     VARCHAR2,
        p_jbr_id        OUT NUMBER,
        p_rpt_blob      OUT BLOB)
    IS
        v_tmp_str   VARCHAR2 (4000);
    --l_val     VARCHAR2(4000);
    BEGIN
        FOR c
            IN (SELECT a.at_dt,
                       a.at_num,
                       o.org_name,
                       uss_person.api$sc_tools.get_pib (p.app_sc)
                           AS app_name,
                       (SELECT TRIM (
                                   REPLACE (
                                       (CASE r.rnspm_tp
                                            WHEN 'O'
                                            THEN
                                                COALESCE (r.rnsps_last_name,
                                                          r.rnsps_first_name)
                                            ELSE
                                                   r.rnsps_last_name
                                                || ' '
                                                || r.rnsps_first_name
                                                || ' '
                                                || r.rnsps_middle_name
                                        END),
                                       '  '))
                          FROM uss_rnsp.v_rnsp r
                         WHERE r.rnspm_id = a.at_rnspm)
                           AS ss_org_name,
                       (SELECT rn.rnp_name
                          FROM uss_ndi.v_ndi_reason_not_pay rn
                         WHERE rn.rnp_id = a.at_rnp)
                           AS term_reason,
                       ts.sign_first_pib,
                       ts.sign_last_pib,
                       ap.ap_id
                  FROM v_act  a
                       JOIN v_appeal ap
                           ON     ap.ap_id = a.at_ap
                              AND ap.ap_tp IN ('R.OS', 'R.GS')
                       JOIN v_opfu o ON o.org_id = a.at_org
                       LEFT JOIN
                       (SELECT MAX (
                                      (CASE
                                           WHEN     t.ati_id =
                                                    t.sign_first
                                                AND REGEXP_SUBSTR (
                                                        t.wu_pib,
                                                        '[^ ]+',
                                                        1,
                                                        2)
                                                        IS NOT NULL
                                           THEN
                                               INITCAP (
                                                   REGEXP_SUBSTR (
                                                       t.wu_pib,
                                                       '[^ ]+',
                                                       1,
                                                       2))
                                       END)
                                   || (CASE
                                           WHEN     t.ati_id =
                                                    t.sign_first
                                                AND REGEXP_SUBSTR (
                                                        t.wu_pib,
                                                        '[^ ]+',
                                                        1,
                                                        1)
                                                        IS NOT NULL
                                           THEN
                                                  ' '
                                               || UPPER (
                                                      REGEXP_SUBSTR (
                                                          t.wu_pib,
                                                          '[^ ]+',
                                                          1,
                                                          1))
                                       END))    AS sign_first_pib,
                               MAX (
                                      (CASE
                                           WHEN     t.ati_id =
                                                    t.sign_last
                                                AND t.ati_id !=
                                                    t.sign_first
                                                AND REGEXP_SUBSTR (
                                                        t.wu_pib,
                                                        '[^ ]+',
                                                        1,
                                                        2)
                                                        IS NOT NULL
                                           THEN
                                               INITCAP (
                                                   REGEXP_SUBSTR (
                                                       t.wu_pib,
                                                       '[^ ]+',
                                                       1,
                                                       2))
                                       END)
                                   || (CASE
                                           WHEN     t.ati_id =
                                                    t.sign_last
                                                AND t.ati_id !=
                                                    t.sign_first
                                                AND REGEXP_SUBSTR (
                                                        t.wu_pib,
                                                        '[^ ]+',
                                                        1,
                                                        1)
                                                        IS NOT NULL
                                           THEN
                                                  ' '
                                               || UPPER (
                                                      REGEXP_SUBSTR (
                                                          t.wu_pib,
                                                          '[^ ]+',
                                                          1,
                                                          1))
                                       END))    AS sign_last_pib
                          FROM (SELECT s.ati_id,
                                       FIRST_VALUE (s.ati_id)
                                           OVER (
                                               ORDER BY
                                                   COALESCE (s.ati_order, 1),
                                                   s.ati_id)
                                           AS sign_first,
                                       LAST_VALUE (s.ati_id)
                                           OVER (
                                               ORDER BY
                                                   COALESCE (s.ati_order, 1),
                                                   s.ati_id)
                                           AS sign_last,
                                       u.wu_pib
                                  FROM v_at_signers  s
                                       JOIN v_at_document d
                                           ON     d.atd_id = s.ati_atd
                                              AND d.atd_at = p_at_id
                                              AND d.atd_doc = 860
                                              AND d.history_status = 'A'
                                       JOIN ikis_sysweb.v$all_users u
                                           ON u.wu_id = s.ati_wu
                                 WHERE     s.ati_at = p_at_id
                                       AND s.history_status = 'A') t) ts
                           ON 1 = 1
                       LEFT JOIN v_ap_person p
                           ON     p.app_ap = a.at_ap
                              AND p.app_tp = 'OS'
                              AND p.history_status = 'A'
                 WHERE a.at_id = p_at_id AND ROWNUM < 2)
        LOOP
            rdm$rtfl_univ.initreport (p_code     => p_rt_code,
                                      p_bld_tp   => p_bld_tp);

            addparam (
                p_param_name   => 'p1',
                p_param_value   =>
                    COALESCE (    /*#92295 get_at_doc_atr_dt(p_at_id, 3080),*/
                              TO_CHAR (c.at_dt, 'DD.MM.YYYY'),
                              '____________________'));
            addparam (
                p_param_name   => 'p2',
                p_param_value   =>
                    COALESCE (   /*#92295 get_at_doc_atr_str(p_at_id, 3081),*/
                              c.at_num, ' ____________________'));
            addparam (
                p_param_name   => 'p3',
                p_param_value   =>
                    COALESCE (   /*#92295 get_at_doc_atr_str(p_at_id, 3086),*/
                        c.org_name,
                        '__________________________________________________________________________________'));
            addparam (
                p_param_name   => 'p4',
                p_param_value   =>
                    COALESCE ( /*#92295 case when get_at_doc_atr_str(p_at_id, 3087) is not null then
                                 get_at_doc_atr_str(p_at_id, 3087)||' '||get_at_doc_atr_str(p_at_id, 3088)||' '||get_at_doc_atr_str(p_at_id, 3089)
                               end,*/
                        c.app_name,
                        '_________________________________________
                                                                                       (прізвище, ім’я, по батькові (за наявності)
_________________________________________________________________________________'));
            addparam (
                p_param_name   => 'p5',
                p_param_value   =>
                    COALESCE (   /*#92295 get_at_doc_atr_str(p_at_id, 3090),*/
                        c.ss_org_name,
                        '___________________________________________________
_________________________________________________________________________________'));

            --Перелік соціальних послуг
            SELECT LISTAGG (TO_CHAR (rn) || ') ' || nst_name,
                            ';' || CHR (10))
                   WITHIN GROUP (ORDER BY nst_order)
              INTO v_tmp_str
              FROM (SELECT ROW_NUMBER () OVER (ORDER BY st.nst_order)
                               AS rn,
                           st.nst_name,
                           st.nst_order
                      FROM v_ap_service  s
                           JOIN uss_ndi.v_ndi_service_type st
                               ON st.nst_id = s.aps_nst
                     WHERE s.aps_ap = c.ap_id AND s.history_status = 'A');

            addparam (
                'p6',
                COALESCE (
                    v_tmp_str,
                    '1) ____________________________________________________________________________ ;
2) ____________________________________________________________________________ ;
3) ____________________________________________________________________________.'));

            /* #92295
            if c.term_reason is null then
              l_val:= get_at_doc_atr_str(p_at_id, 3092);
              select max(rn.rnp_name) into c.term_reason
                from uss_ndi.v_ndi_reason_not_pay rn
               where rn.rnp_id = l_val;
            end if;*/
            addparam (
                p_param_name   => 'p7',
                p_param_value   =>
                    COALESCE (
                        c.term_reason,
                        '________________________________
_________________________________________________________________________________'));
            addparam (
                p_param_name   => 'p9',
                p_param_value   =>
                    COALESCE ( /*#92295 case when get_at_doc_atr_str(p_at_id, 3094) is not null then
                                               get_at_doc_atr_str(p_at_id, 3094)||' '||get_at_doc_atr_str(p_at_id, 3095)
                                             end,*/
                              c.sign_first_pib,
                              '______________________________'));
            addparam (
                p_param_name   => 'p9_lbl',
                p_param_value   =>
                    (CASE
                         WHEN /*#92295 get_at_doc_atr_str(p_at_id, 3094) is null and*/
                              c.sign_first_pib IS NULL
                         THEN
                             '(Власне ім’я та ПРІЗВИЩЕ)'
                     END));

            addparam (
                p_param_name   => 'p10',
                p_param_value   =>
                    COALESCE ( /*#92295 case when get_at_doc_atr_str(p_at_id, 3097) is not null then
                                              get_at_doc_atr_str(p_at_id, 3097)||' '||get_at_doc_atr_str(p_at_id, 3098)
                                            end,*/
                              c.sign_last_pib,
                              '______________________________'));
            addparam (
                p_param_name   => 'p10_lbl',
                p_param_value   =>
                    (CASE
                         WHEN /*#92295 get_at_doc_atr_str(p_at_id, 3097) is null and*/
                              c.sign_last_pib IS NULL
                         THEN
                             '(Власне ім’я та ПРІЗВИЩЕ)'
                     END));

            addparam ('p11', TO_CHAR (c.at_dt, 'dd.mm.yyyy') || ' року');

            ------------------------
            rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                             p_rpt_blob   => p_rpt_blob);
            replace_ekr (p_rpt_blob);
        END LOOP;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Рішення про припинення надання соціальних послуг" через сервіс
    -- params: p_rt_code - код шаблону шаблону
    --         p_at_id - ідентифікатор рішення
    -- note:   #87276
    FUNCTION get_decision_term_prov_ss_r1 (
        p_rt_code   IN rpt_templates.rt_code%TYPE,
        p_at_id     IN NUMBER)
        RETURN DECIMAL
    IS
        v_jbr_id     DECIMAL;
        v_rpt_blob   BLOB;
    BEGIN
        decision_term_prov_ss_r1_main (
            p_rt_code    => p_rt_code,
            p_at_id      => p_at_id,
            p_bld_tp     => rdm$rtfl_univ.c_bld_tp_svc,
            p_jbr_id     => v_jbr_id,
            p_rpt_blob   => v_rpt_blob);
        RETURN v_jbr_id;
    END;

    -- info:   Отримання друкованої форми "Рішення про припинення надання соціальних послуг" безпосередньо в БД
    -- params: p_rt_code - код шаблону шаблону
    --         p_at_id - ідентифікатор рішення
    -- note:   #87276
    FUNCTION get_decision_term_prov_ss_r1_blob (
        p_rt_code   IN rpt_templates.rt_code%TYPE,
        p_at_id     IN NUMBER)
        RETURN BLOB
    IS
        v_jbr_id     DECIMAL;
        v_rpt_blob   BLOB;
    BEGIN
        decision_term_prov_ss_r1_main (
            p_rt_code    => p_rt_code,
            p_at_id      => p_at_id,
            p_bld_tp     => rdm$rtfl_univ.c_bld_tp_db,
            p_jbr_id     => v_jbr_id,
            p_rpt_blob   => v_rpt_blob);
        RETURN v_rpt_blob;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Повідомлення про припинення надання соціальних послуг"
    -- params: p_rt_code - код шаблону шаблону
    --         p_at_id - ідентифікатор рішення
    -- note:   #87278   ndt_id = 862
    PROCEDURE message_term_prov_ss_r1_main (
        p_rt_code    IN     rpt_templates.rt_code%TYPE,
        p_at_id      IN     NUMBER,
        p_bld_tp     IN     VARCHAR2,
        p_jbr_id        OUT NUMBER,
        p_rpt_blob      OUT BLOB)
    IS
    --l_val varchar2(4000);
    BEGIN
        FOR c
            IN (SELECT uss_person.api$sc_tools.get_pib (a.at_sc)
                           AS app_name_z,
                       (SELECT RTRIM (
                                   (   MAX (
                                           CASE
                                               WHEN     da.apda_nda = 3122
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
                                                       WHEN da.apda_nda =
                                                            1716
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
                                                          WHEN da.apda_nda =
                                                               3123
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
                                                   WHEN     da.apda_nda =
                                                            3124
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
                                               WHEN     da.apda_nda = 3125
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
                                               WHEN     da.apda_nda = 3126
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
                                               WHEN     da.apda_nda = 3127
                                                    AND TRIM (
                                                            da.apda_val_string)
                                                            IS NOT NULL
                                               THEN
                                                      'оф./кв./прим. '
                                                   || TRIM (
                                                          da.apda_val_string)
                                           END)),
                                   ', ')
                          FROM v_ap_person  p
                               JOIN v_ap_document d
                                   ON     d.apd_app = p.app_id
                                      AND d.apd_ap = a.at_ap
                                      AND d.apd_ndt = 861
                                      AND d.history_status = 'A'
                               JOIN v_ap_document_attr da
                                   ON     da.apda_apd = d.apd_id
                                      AND da.apda_ap = a.at_ap
                                      AND da.history_status = 'A'
                         WHERE     p.app_ap = a.at_ap
                               AND p.app_tp = 'Z'
                               AND p.history_status = 'A')
                           AS addr_str,
                       o.org_name,
                       a.at_dt,
                       a.at_num,
                       uss_person.api$sc_tools.get_pib (p.app_sc)
                           AS app_name_os,
                       (SELECT TRIM (
                                   REPLACE (
                                       (CASE r.rnspm_tp
                                            WHEN 'O'
                                            THEN
                                                COALESCE (r.rnsps_last_name,
                                                          r.rnsps_first_name)
                                            ELSE
                                                   r.rnsps_last_name
                                                || ' '
                                                || r.rnsps_first_name
                                                || ' '
                                                || r.rnsps_middle_name
                                        END),
                                       '  '))
                          FROM uss_rnsp.v_rnsp r
                         WHERE r.rnspm_id = a.at_rnspm)
                           AS ss_org_name,
                       (SELECT rn.rnp_name
                          FROM uss_ndi.v_ndi_reason_not_pay rn
                         WHERE rn.rnp_id = a.at_rnp)
                           AS term_reason,
                       ts.sign_first_pib
                  FROM v_act  a
                       JOIN v_appeal ap
                           ON     ap.ap_id = a.at_ap
                              AND ap.ap_tp IN ('R.OS', 'R.GS')
                       JOIN v_opfu o ON o.org_id = a.at_org
                       LEFT JOIN
                       (SELECT MAX (
                                      (CASE
                                           WHEN     t.ati_id =
                                                    t.sign_first
                                                AND REGEXP_SUBSTR (
                                                        t.wu_pib,
                                                        '[^ ]+',
                                                        1,
                                                        2)
                                                        IS NOT NULL
                                           THEN
                                               INITCAP (
                                                   REGEXP_SUBSTR (
                                                       t.wu_pib,
                                                       '[^ ]+',
                                                       1,
                                                       2))
                                       END)
                                   || (CASE
                                           WHEN     t.ati_id =
                                                    t.sign_first
                                                AND REGEXP_SUBSTR (
                                                        t.wu_pib,
                                                        '[^ ]+',
                                                        1,
                                                        1)
                                                        IS NOT NULL
                                           THEN
                                                  ' '
                                               || UPPER (
                                                      REGEXP_SUBSTR (
                                                          t.wu_pib,
                                                          '[^ ]+',
                                                          1,
                                                          1))
                                       END))    AS sign_first_pib
                          FROM (SELECT s.ati_id,
                                       FIRST_VALUE (s.ati_id)
                                           OVER (
                                               ORDER BY
                                                   COALESCE (s.ati_order, 1),
                                                   s.ati_id)
                                           AS sign_first,
                                       u.wu_pib
                                  FROM v_at_signers  s
                                       JOIN v_at_document d
                                           ON     d.atd_id = s.ati_atd
                                              AND d.atd_at = p_at_id
                                              AND d.atd_doc = 860
                                              AND d.history_status = 'A'
                                       JOIN ikis_sysweb.v$all_users u
                                           ON u.wu_id = s.ati_wu
                                 WHERE     s.ati_at = p_at_id
                                       AND s.history_status = 'A') t) ts
                           ON 1 = 1
                       LEFT JOIN v_ap_person p
                           ON     p.app_ap = a.at_ap
                              AND p.app_tp = 'OS'
                              AND p.history_status = 'A'
                 WHERE a.at_id = p_at_id AND ROWNUM < 2)
        LOOP
            rdm$rtfl_univ.initreport (p_code     => p_rt_code,
                                      p_bld_tp   => p_bld_tp);

            addparam (
                p_param_name   => 'p1',
                p_param_value   =>
                    COALESCE ( /*#92296 case when get_at_doc_atr_str(p_at_id, 3099) is not null then
                                  get_at_doc_atr_str(p_at_id, 3099)||' '||get_at_doc_atr_str(p_at_id, 3100)||' '||get_at_doc_atr_str(p_at_id, 3101)
                                end,*/
                        c.app_name_z,
                        '______________________________________________'));

            addparam (
                p_param_name   => 'p2',
                p_param_value   =>
                    COALESCE ( /*#92296 case when replace(get_at_doc_atr_row(p_at_id, '3102,3103,3104,3105,3106,3107', null), ' ') is not null then
                                   get_at_doc_atr_row(p_at_id, '3102,3103,3104')||
                                   case when get_at_doc_atr_str(p_at_id, 3105) is not null then ' буд. '||get_at_doc_atr_str(p_at_id, 3105) end||
                                   case when get_at_doc_atr_str(p_at_id, 3106) is not null then ' корп. '||get_at_doc_atr_str(p_at_id, 3106) end||
                                   case when get_at_doc_atr_str(p_at_id, 3107) is not null then ' кв. '||get_at_doc_atr_str(p_at_id, 3107) end
                                 end,*/
                        c.addr_str,
                        '______________________________________________'));
            addparam (
                p_param_name   => 'p3',
                p_param_value   =>
                    COALESCE (   /*#92296 get_at_doc_atr_str(p_at_id, 3108),*/
                        c.org_name,
                        '__________________________________________________________________________________'));
            addparam (
                p_param_name   => 'p4',
                p_param_value   =>
                    COALESCE (    /*#92296 get_at_doc_atr_dt(p_at_id, 3109),*/
                              TO_CHAR (c.at_dt, 'DD.MM.YYYY'), '__________'));
            addparam (p_param_name    => 'p5',
                      p_param_value   => COALESCE ( /*#92296 get_at_doc_atr_str(p_at_id, 3110),*/
                                                   c.at_num, '____________'));
            addparam (
                p_param_name   => 'p6',
                p_param_value   =>
                    COALESCE ( /*#92296 case when get_at_doc_atr_str(p_at_id, 3111) is not null then
                                 get_at_doc_atr_str(p_at_id, 3111)||' '||get_at_doc_atr_str(p_at_id, 3112)||' '||get_at_doc_atr_str(p_at_id, 3113)
                               end,*/
                        c.app_name_os,
                        '_________________________________________________________________________________'));
            addparam (
                p_param_name   => 'p7',
                p_param_value   =>
                    COALESCE (   /*#92296 get_at_doc_atr_str(p_at_id, 3114),*/
                        c.ss_org_name,
                        '_________________________________________
_________________________________________________________________________________'));
            /*#92296
            if c.term_reason is null then
              l_val:= get_at_doc_atr_str(p_at_id, 3115);
              select max(rn.rnp_name) into c.term_reason
                from uss_ndi.v_ndi_reason_not_pay rn
               where rn.rnp_id = l_val;
            end if;*/

            addparam (
                p_param_name   => 'p8',
                p_param_value   =>
                    COALESCE (
                        c.term_reason,
                        '_______________________________________
_________________________________________________________________________________
_________________________________________________________________________________
_________________________________________________________________________________ '));

            addparam ('p9_1', NULL);                               --підписант
            addparam (
                p_param_name   => 'p9_2',
                p_param_value   =>
                    COALESCE ( /*#92296 case when get_at_doc_atr_str(p_at_id, 3117) is not null then
                                              get_at_doc_atr_str(p_at_id, 3117)||' '||get_at_doc_atr_str(p_at_id, 3118)
                                            end,*/
                              c.sign_first_pib,
                              '______________________________'));
            --addparam(p_param_name => 'p10_lbl', p_param_value => (CASE WHEN /*#92296 get_at_doc_atr_str(p_at_id, 3117) is null and*/ c.sign_first_pib IS NULL THEN '(Власне ім’я та ПРІЗВИЩЕ)' END));
            addparam ('p10', TO_CHAR (c.at_dt, 'dd.mm.yyyy') || ' року');

            ---------------------------
            rdm$rtfl_univ.get_report_result (p_jbr_id     => p_jbr_id,
                                             p_rpt_blob   => p_rpt_blob);
            replace_ekr (p_rpt_blob);
        END LOOP;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми "Повідомлення про припинення надання соціальних послуг" через сервіс
    -- params: p_rt_code - код шаблону шаблону
    --         p_at_id - ідентифікатор рішення
    -- note:   #87278
    FUNCTION get_message_term_prov_ss_r1 (
        p_rt_code   IN rpt_templates.rt_code%TYPE,
        p_at_id     IN NUMBER)
        RETURN DECIMAL
    IS
        v_jbr_id     DECIMAL;
        v_rpt_blob   BLOB;
    BEGIN
        message_term_prov_ss_r1_main (
            p_rt_code    => p_rt_code,
            p_at_id      => p_at_id,
            p_bld_tp     => rdm$rtfl_univ.c_bld_tp_svc,
            p_jbr_id     => v_jbr_id,
            p_rpt_blob   => v_rpt_blob);
        RETURN v_jbr_id;
    END;

    -- info:   Отримання друкованої форми "Повідомлення про припинення надання соціальних послуг" безпосередньо в БД
    -- params: p_rt_code - код шаблону шаблону
    --         p_at_id - ідентифікатор рішення
    -- note:   #87278
    FUNCTION get_message_term_prov_ss_r1_blob (
        p_rt_code   IN rpt_templates.rt_code%TYPE,
        p_at_id     IN NUMBER)
        RETURN BLOB
    IS
        v_jbr_id     DECIMAL;
        v_rpt_blob   BLOB;
    BEGIN
        message_term_prov_ss_r1_main (
            p_rt_code    => p_rt_code,
            p_at_id      => p_at_id,
            p_bld_tp     => rdm$rtfl_univ.c_bld_tp_db,
            p_jbr_id     => v_jbr_id,
            p_rpt_blob   => v_rpt_blob);
        RETURN v_rpt_blob;
    END;

    -- info:   Ініціалізація процесу підготовки друкованої форми по рішенню
    -- params: p_rt_id - ідентифікатор шаблону
    --         p_pd_id - ідентифікатор рішення
    -- note:   #70506
    PROCEDURE reg_report (p_rt_id    IN     NUMBER,
                          p_pd_id    IN     NUMBER,
                          p_jbr_id      OUT DECIMAL)
    IS
        v_rt_code   rpt_templates.rt_code%TYPE := get_rpt_code (p_rt_id);
    BEGIN
        tools.WriteMsg ('DNET$PD_REPORTS.' || $$PLSQL_UNIT);
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT,
            action_name   =>
                   'p_rt_id='
                || TO_CHAR (p_rt_id)
                || '; p_pd_id='
                || TO_CHAR (p_pd_id));

        CASE
            WHEN v_rt_code IN
                     ('ASSISTANCE_DECISION_R1',
                      'PAY_REJECT_DECISION_R1',
                      'ASSISTANCE_DECISION_R2')
            THEN
                p_jbr_id := assistance_decision (p_rt_id, p_pd_id);
            WHEN v_rt_code IN
                     ('ASSISTANCE_MESSAGE_R1',
                      'PAY_REJECT_MESSAGE_R1',
                      'ASSISTANCE_MESSAGE_R2')
            THEN
                p_jbr_id := assistance_message (p_rt_id, p_pd_id);
            WHEN v_rt_code = 'TOTAL_REVENUE_R1'
            THEN
                p_jbr_id := total_revenue_r1 (p_rt_id, p_pd_id);
            WHEN v_rt_code = 'SEND_REQUEST_NOTIFICATION_R1'
            THEN
                p_jbr_id := send_request_notification_r1 (p_rt_id, p_pd_id);
            WHEN v_rt_code = 'PLACEMENT_VOUCHER_R1'
            THEN
                p_jbr_id := placement_voucher_r1 (p_rt_id, p_pd_id);
            WHEN v_rt_code = 'DECISION_TERM_PROV_SS_R1'
            THEN
                p_jbr_id := get_decision_term_prov_ss_r1 (v_rt_code, p_pd_id);
            WHEN v_rt_code = 'MESSAGE_TERM_PROV_SS_R2'
            THEN
                p_jbr_id := get_message_term_prov_ss_r1 (v_rt_code, p_pd_id);
            ELSE
                NULL;
        END CASE;
    END;

    -- info:   Отримання файла друкованої форми "Рішення" з додатковими параметрами для подальшої конвертації/збереження як документа
    -- params: p_pd_id - ідентифікатор рішення
    -- note:   #77050, #78724, #82581
    PROCEDURE get_decision (p_pd_id     IN     pc_decision.pd_id%TYPE,
                            p_doc_cur      OUT SYS_REFCURSOR)
    IS
        v_rpt_blob       BLOB;
        v_rpt_clob       CLOB;
        v_pd_num         pc_decision.pd_num%TYPE;
        v_pd_dt          pc_decision.pd_dt%TYPE;
        v_pd_org         pc_decision.com_org%TYPE;
        v_str            VARCHAR2 (4000);
        v_rt_code        rpt_templates.rt_code%TYPE;
        v_pdo_id         pd_document.pdo_id%TYPE;
        v_pdoa_id        pd_document_attr.pdoa_id%TYPE;
        v_pdp_start_dt   pd_payment.pdp_start_dt%TYPE;
        v_pdp_stop_dt    pd_payment.pdp_stop_dt%TYPE;
        v_pdp_sum        pd_payment.pdp_sum%TYPE;
    BEGIN
        tools.WriteMsg ('DNET$PD_REPORTS.' || $$PLSQL_UNIT);

        --контроль доступності формування по ролі
        FOR c
            IN (SELECT MAX (u.wu_login)      AS wu_login,
                       MAX (ut.wut_code)     AS wut_code,
                       MAX (r.wr_descr)      AS wr_descr,
                       MAX (au.wu_pib)       AS wu_pib
                  FROM ikis_sysweb.v$w_users_4gic  u
                       JOIN ikis_sysweb.v_full_user_types ut
                           ON ut.wut_id = u.wu_wut
                       JOIN ikis_sysweb.v$w_roles r
                           ON r.wr_name = 'W_ESR_MDECISION'
                       LEFT JOIN ikis_sysweb.v$all_users au
                           ON au.wu_id = u.wu_id
                 WHERE u.wu_id = tools.getcurrwu)
        LOOP
            IF c.wu_login IS NULL OR c.wut_code IS NULL
            THEN
                raise_application_error (
                    -20000,
                    'Не вдалося перевірити доступність формування друкованої форми рішення для поточного користувача!');
            ELSIF NOT (ikis_sysweb.is_role_assigned (c.wu_login,
                                                     'W_ESR_MDECISION',
                                                     c.wut_code))
            THEN
                raise_application_error (
                    -20000,
                       'Формування друкованої форми рішення поточному користувачу недоступно, відсутня '
                    || COALESCE (
                           REPLACE ('роль "' || TRIM (c.wr_descr) || '"',
                                    'роль ""'),
                           'необхідна роль')
                    || '!');
            END IF;

            v_str := c.wu_pib;
        END LOOP;

        --#72145 тип друкованої форми залежить від статусу рішення/#73661/#74090 - різне наповнення для допомоги з Ід=248, Ід=249 та інших
        FOR data_cur
            IN (SELECT pd.pd_num,
                       TO_CHAR (pd.pd_dt, 'DD.MM.YYYY')
                           AS pd_date,
                       pc.pc_id,
                       pc.pc_num
                           AS pers_case_num,
                       pa.pa_num
                           AS pers_acc_num,
                       (CASE pm.pdm_pay_tp
                            WHEN 'BANK'
                            THEN
                                   (CASE st.nst_id
                                        WHEN 664
                                        THEN
                                            (SELECT dic_name
                                               FROM uss_ndi.v_ddn_apm_tp
                                              WHERE dic_value = pm.pdm_pay_tp)
                                    END)
                                || CHR (10)
                                || '\par Банківська установа: '
                                || b.nb_name
                                || --#80742
                                   (CASE
                                        WHEN st.nst_id != 664
                                        THEN
                                               CHR (10)
                                            || '\par Номер банківської установи: '
                                            || CHR (10)
                                            || '\par Номер відділення: '
                                    END)
                                || CHR (10)
                                || '\par Номер вкладу: '
                                || pm.pdm_account
                            WHEN 'POST'
                            THEN
                                   (CASE st.nst_id
                                        WHEN 664
                                        THEN
                                            (SELECT dic_name
                                               FROM uss_ndi.v_ddn_apm_tp
                                              WHERE dic_value = pm.pdm_pay_tp)
                                    END)
                                || CHR (10)
                                || '\par Підприємство зв’язку: '
                                || k.kaot_name
                                || CHR (10)
                                || '\par №: '
                                || pm.pdm_index
                        END)
                           pay_tp_info,
                       COALESCE (
                           TRIM (
                               i.sci_ln || ' ' || i.sci_fn || ' ' || i.sci_mn),
                           uss_person.api$sc_tools.get_pib (
                               COALESCE (sc.sc_id, pc.pc_sc)))
                           AS app_name,
                       COALESCE (
                           (  SELECT p.scd_seria || p.scd_number
                                FROM uss_person.v_sc_document p
                               WHERE     p.scd_sc =
                                         COALESCE (sc.sc_id, pc.pc_sc)
                                     AND p.scd_ndt = 5
                                     AND p.scd_st IN ('A', '1')
                            ORDER BY TO_NUMBER (p.scd_start_dt) DESC
                               FETCH FIRST ROW ONLY),
                           uss_person.api$sc_tools.get_numident (
                               COALESCE (sc.sc_id, pc.pc_sc)))
                           AS app_code,
                       TO_CHAR (ap.ap_reg_dt, 'DD.MM.YYYY')
                           AS appeal_dt,
                       (SELECT DISTINCT
                               FIRST_VALUE (da.apda_val_dt)
                                   OVER (
                                       ORDER BY
                                           (CASE dt.ndt_id
                                                WHEN 600 THEN 10
                                                ELSE dt.ndt_order
                                            END))
                          FROM v_ap_document  d
                               JOIN uss_ndi.v_ndi_document_type dt
                                   ON     dt.ndt_id = d.apd_ndt
                                      AND (dt.ndt_ndc = 13 OR dt.ndt_id = 600)
                               JOIN v_ap_document_attr da
                                   ON     da.apda_apd = d.apd_id
                                      AND da.apda_val_dt IS NOT NULL
                               JOIN uss_ndi.v_ndi_document_attr a
                                   ON     a.nda_id = da.apda_nda
                                      AND a.nda_class = 'BDT'
                         WHERE     d.history_status = 'A'
                               AND d.apd_ap = pd.pd_ap
                               AND d.apd_app IN
                                       (SELECT p.app_id
                                          FROM v_ap_person p
                                         WHERE     p.app_ap = pd.pd_ap
                                               AND p.app_tp = 'Z'
                                               AND p.app_sc =
                                                   COALESCE (sc.sc_id,
                                                             pc.pc_sc)
                                               AND p.history_status = 'A'))
                           AS app_brth_dt, --дату народження необхідно брати із заяви (#73316) або із паспорта (#77940)/#80742
                       (SELECT LISTAGG (
                                   n.nda_name || ' ' || a.apda_val_string,
                                   ' ')
                               WITHIN GROUP (ORDER BY n.nda_order)
                          FROM v_ap_document_attr  a
                               JOIN v_ap_document d
                                   ON     a.apda_apd = d.apd_id
                                      AND d.apd_ndt = 600
                                      AND d.apd_app IN
                                              (SELECT p.app_id
                                                 FROM v_ap_person p
                                                WHERE     p.app_ap = pd.pd_ap
                                                      AND p.app_tp = 'Z'
                                                      AND p.app_sc =
                                                          COALESCE (sc.sc_id,
                                                                    pc.pc_sc)
                                                      AND p.history_status =
                                                          'A')
                                      AND d.history_status = 'A'
                               JOIN uss_ndi.v_ndi_document_attr n
                                   ON a.apda_nda = n.nda_id AND n.nda_nng = 2
                         WHERE     a.apda_ap = pd.pd_ap
                               AND a.history_status = 'A'
                               AND a.apda_val_string IS NOT NULL)
                           AS app_fact_addr,
                       TO_CHAR (pc.pc_create_dt, 'DD.MM.YYYY')
                           AS pers_acc_dt,
                       st.nst_id,
                       st.nst_name,
                       (CASE st.nst_id
                            WHEN 249
                            THEN
                                (SELECT (CASE
                                             WHEN SUM (COALESCE (pdp_sum, 0)) >
                                                  0
                                             THEN
                                                 LISTAGG (
                                                        '\par Розмір соціальної допомоги з '
                                                     || TO_CHAR (
                                                            pdp_start_dt,
                                                            'DD.MM.YYYY')
                                                     || ' по '
                                                     || TO_CHAR (
                                                            pdp_stop_dt,
                                                            'DD.MM.YYYY')
                                                     || ' '
                                                     || TO_CHAR (
                                                            pdp_sum,
                                                            'FM9G999G999G999G999G990D00',
                                                            'NLS_NUMERIC_CHARACTERS=''.'''''),
                                                     ' ')
                                                 WITHIN GROUP (ORDER BY
                                                                   pdp_start_dt,
                                                                   pdp_stop_dt)
                                             ELSE
                                                 '\par Відмовлено у призначенні допомоги в зв’язку із тим, що середньомісячний сукупний дохід перевищує розмір рівня забезпечення прожиткового мінімуму для сім’ї' --#85333
                                         END)
                                   FROM v_pd_payment pdp
                                  WHERE     pdp_pd = p_pd_id
                                        AND pdp.history_status = 'A')
                        END)
                           AS pay_info_lines,
                       (CASE st.nst_id
                            WHEN 248
                            THEN
                                (   '\par Заявник                                                       : '
                                 || (CASE
                                         WHEN (SELECT a.apda_val_string
                                                 FROM v_ap_document_attr  a
                                                      JOIN v_ap_document d
                                                          ON     a.apda_apd =
                                                                 d.apd_id
                                                             AND d.apd_ndt =
                                                                 605
                                                             AND d.apd_app IN
                                                                     (SELECT p.app_id
                                                                        FROM v_ap_person
                                                                                 p
                                                                       WHERE     p.app_ap =
                                                                                 pd.pd_ap
                                                                             AND p.app_tp =
                                                                                 'Z'
                                                                             AND p.app_sc =
                                                                                 COALESCE (
                                                                                     sc.sc_id,
                                                                                     pc.pc_sc)
                                                                             AND p.history_status =
                                                                                 'A')
                                                             AND d.history_status =
                                                                 'A'
                                                WHERE     a.apda_ap =
                                                          pd.pd_ap
                                                      AND a.history_status =
                                                          'A'
                                                      AND a.apda_nda = 650) =
                                              'T'
                                         THEN
                                             'Працює'
                                         WHEN (SELECT a.apda_val_string
                                                 FROM v_ap_document_attr  a
                                                      JOIN v_ap_document d
                                                          ON     a.apda_apd =
                                                                 d.apd_id
                                                             AND d.apd_ndt =
                                                                 605
                                                             AND d.apd_app IN
                                                                     (SELECT p.app_id
                                                                        FROM v_ap_person
                                                                                 p
                                                                       WHERE     p.app_ap =
                                                                                 pd.pd_ap
                                                                             AND p.app_tp =
                                                                                 'Z'
                                                                             AND p.app_sc =
                                                                                 COALESCE (
                                                                                     sc.sc_id,
                                                                                     pc.pc_sc)
                                                                             AND p.history_status =
                                                                                 'A')
                                                             AND d.history_status =
                                                                 'A'
                                                WHERE     a.apda_ap =
                                                          pd.pd_ap
                                                      AND a.history_status =
                                                          'A'
                                                      AND a.apda_nda = 663) =
                                              'T'
                                         THEN
                                             'Не працює'
                                     END)
                                 || '\par Додаткові відомості про заявника       :'
                                 || (CASE
                                         WHEN (SELECT a.apda_val_string
                                                 FROM v_ap_document_attr  a
                                                      JOIN v_ap_document d
                                                          ON     a.apda_apd =
                                                                 d.apd_id
                                                             AND d.apd_ndt =
                                                                 605
                                                             AND d.apd_app IN
                                                                     (SELECT p.app_id
                                                                        FROM v_ap_person
                                                                                 p
                                                                       WHERE     p.app_ap =
                                                                                 pd.pd_ap
                                                                             AND p.app_tp =
                                                                                 'Z'
                                                                             AND p.app_sc =
                                                                                 COALESCE (
                                                                                     sc.sc_id,
                                                                                     pc.pc_sc)
                                                                             AND p.history_status =
                                                                                 'A')
                                                             AND d.history_status =
                                                                 'A'
                                                WHERE     a.apda_ap =
                                                          pd.pd_ap
                                                      AND a.history_status =
                                                          'A'
                                                      AND a.apda_nda = 641) =
                                              'T'
                                         THEN
                                             'одинокий/одинока'
                                     END))
                        END)
                           AS app_add_info,
                       ap.ap_id,
                       (SELECT MAX (aps.aps_id)
                          FROM v_ap_service aps
                         WHERE     aps.aps_ap = pd.pd_ap
                               AND aps.aps_nst = pd.pd_nst
                               AND aps.history_status = 'A')
                           AS aps_id,
                       (SELECT MAX (app.app_id)
                          FROM v_ap_person app
                         WHERE     app.app_ap = pd.pd_ap
                               AND app.app_sc = COALESCE (sc.sc_id, pc.pc_sc)
                               AND app.history_status = 'A')
                           AS app_id,
                       pd.pd_is_signed,
                       pd.pd_st,
                       pd.pd_dt,
                       pd.com_org,
                       (CASE pd.pd_st
                            WHEN 'V'
                            THEN
                                (SELECT LISTAGG (
                                               njr_code
                                            || ' '
                                            || njr_name
                                            || ';',
                                            CHR (10) || '\par')
                                        WITHIN GROUP (ORDER BY
                                                          njr_order,
                                                          njr_code,
                                                          njr_name)
                                   FROM v_pd_reject_info
                                        JOIN uss_ndi.v_ndi_reject_reason
                                            ON njr_id = pri_njr
                                  WHERE pri_pd = p_pd_id)
                        END)
                           AS reject_reason
                  FROM v_pc_decision  pd
                       JOIN v_pc_account pa ON pa.pa_id = pd.pd_pa
                       JOIN v_personalcase pc ON pc.pc_id = pd.pd_pc
                       JOIN v_appeal ap ON ap.ap_id = pd.pd_ap
                       JOIN uss_ndi.v_ndi_service_type st
                           ON st.nst_id = pd.pd_nst
                       LEFT JOIN v_pd_pay_method pm
                           ON     pm.pdm_pd = p_pd_id
                              AND pm.history_status = 'A'
                              AND pm.pdm_is_actual = 'T'
                       LEFT JOIN uss_ndi.v_ndi_katottg k
                           ON k.kaot_id = pm.pdm_kaot
                       LEFT JOIN uss_ndi.v_ndi_bank b ON b.nb_id = pm.pdm_nb
                       LEFT JOIN uss_person.v_socialcard sc
                           ON sc.sc_scc = pm.pdm_scc
                       LEFT JOIN uss_person.v_sc_change ch
                       JOIN uss_person.v_sc_identity i
                           ON i.sci_id = ch.scc_sci
                           ON ch.scc_id = pm.pdm_scc
                 WHERE pd.pd_id = p_pd_id AND ROWNUM < 2)
        LOOP
            --Контролі
            IF data_cur.nst_id NOT IN (664,
                                       269,
                                       268,
                                       267,
                                       265,
                                       249,
                                       248) --підписання рішення доступно тільки для переліку послуг
            THEN
                raise_application_error (
                    -20000,
                    'Формування друкованої форми рішення недоступно для послуги вказаної в рішенні!');
            ELSIF data_cur.pd_st NOT IN ('P', 'V') --рішення повинно бути в статусі "Призначено"/"Відмовлено"
            THEN
                SELECT LISTAGG ('"' || dic_sname || '"', '/')
                           WITHIN GROUP (ORDER BY dic_srtordr)
                  INTO v_str
                  FROM uss_ndi.v_ddn_pd_st
                 WHERE dic_value IN ('P', 'V');

                raise_application_error (
                    -20000,
                       'Формування друкованої форми рішення доступно тільки в статусі рішення '
                    || v_str
                    || '!');
            ELSIF data_cur.pd_is_signed = 'T' --повторна спроба підписання рішення (рішення вже підписано)
            THEN
                raise_application_error (-20000, 'Рішення вже підписано!');
            END IF;

            v_rt_code :=
                (CASE data_cur.pd_st
                     WHEN 'V' THEN 'PAY_REJECT_DECISION_R1'
                     ELSE 'ASSISTANCE_DECISION_R1'
                 END);
            --ініціалізація підготовки рішення по шаблону
            reportfl_engine.initreport ('USS_ESR', v_rt_code);

            reportfl_engine.addparam ('head_desc', '$head_desc$');
            reportfl_engine.addparam ('pd_num', data_cur.pd_num);
            reportfl_engine.addparam ('pd_date', data_cur.pd_date);
            reportfl_engine.addparam ('pers_case_num',
                                      data_cur.pers_case_num);
            reportfl_engine.addparam ('pers_acc_num', data_cur.pers_acc_num);
            reportfl_engine.addparam ('pay_tp_info', '$pay_tp_info$');
            reportfl_engine.addparam ('serv_name', data_cur.nst_name);

            --рішення про відмову
            IF v_rt_code = 'PAY_REJECT_DECISION_R1'
            THEN
                reportfl_engine.addparam ('app_name', data_cur.app_name);
                reportfl_engine.addparam ('app_code', data_cur.app_code);
                reportfl_engine.addparam ('appeal_dt', data_cur.appeal_dt);
                reportfl_engine.addparam ('app_brth_dt',
                                          data_cur.app_brth_dt);
                reportfl_engine.addparam ('serv_name', data_cur.nst_name);
                reportfl_engine.addparam ('reject_reason',
                                          data_cur.reject_reason);
                reportfl_engine.addparam ('app_fact_addr',
                                          data_cur.app_fact_addr);
            ELSE
                reportfl_engine.addparam ('gen_info', '$gen_info$');
                reportfl_engine.addparam ('pers_acc_dt',
                                          data_cur.pers_acc_dt);
                reportfl_engine.addparam ('w_esr_mdecision_ep_pib', v_str);
                reportfl_engine.addparam ('w_esr_mwork_ep_pib', NULL);
                reportfl_engine.addparam ('w_esr_work_ep_pib', NULL);

                reportfl_engine.adddataset (
                    'main_ds_else',
                       'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                    || data_cur.nst_id
                    || ' NOT IN (248, 249, 664) AND rownum <= 1');

                IF data_cur.nst_id = 248 --#74090 Друкована форма Рішення для допомоги з Ід=248
                THEN
                    reportfl_engine.adddataset (
                        'main_ds_249',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 249 AND rownum <= 1');
                    reportfl_engine.adddataset (
                        'main_ds_664',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 664 AND rownum <= 1');
                    reportfl_engine.adddataset (
                        'main_ds_248',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 248 AND rownum <= 1');

                    --Утриманці
                    reportfl_engine.adddataset (
                        'ds248',
                           q'[SELECT (CASE pt.dic_value
           WHEN 'FP' THEN
            ' \par ' || upper(pt.dic_sname)
         END) AS app_fp_lbl,
         uss_person.api$sc_tools.get_pib(app_sc) AS app_pib,
         to_char(pdf_birth_dt, 'DD.MM.YYYY') AS app_birth_dt,
         (CASE WHEN app_dsblt_grp IS NOT NULL THEN 'Група інвалідності: ' || app_dsblt_grp || ' ' END) ||
         (CASE WHEN app_dsblt_sub_grp IS NOT NULL THEN 'Підгрупа інвалідності: ' || app_dsblt_sub_grp END) ||
         (CASE WHEN app_dsblt_grp IS NOT NULL OR app_dsblt_sub_grp IS NOT NULL THEN '\par ' END) ||
         (CASE WHEN app_dsblt_rsn IS NOT NULL THEN 'Причина інвалідності: ' || app_dsblt_rsn || '\par ' END) AS app_dsblt_info,
         app_dsblt_cat,
         app_dsblt_period,
         app_state_dt,
         app_sc_info
    FROM (SELECT p.app_sc,
                 p.app_tp,
                 f.pdf_birth_dt,
                 MAX((CASE pf.pde_nft
                       WHEN 3 THEN
                        pf.pde_val_string
                     END)) AS app_dsblt_grp,
                 MAX((CASE pf.pde_nft
                       WHEN 4 THEN
                        pf.pde_val_string
                     END)) AS app_dsblt_sub_grp,
                MAX((CASE
                       WHEN pf.pde_nft = 5 AND pf.pde_val_string IS NOT NULL THEN
                        (SELECT dic_sname FROM uss_ndi.v_ddn_inv_reason WHERE dic_code = pf.pde_val_string)
                     END)) AS app_dsblt_rsn,
                 MAX((CASE
                       WHEN pf.pde_nft = 6 AND pf.pde_val_string IS NOT NULL THEN
                        (SELECT dic_sname FROM uss_ndi.v_ddn_inv_child WHERE dic_code = pf.pde_val_string)
                     END)) AS app_dsblt_cat,
                 MAX((CASE pf.pde_nft
                       WHEN 7 THEN
                        to_char(pf.pde_val_dt, 'DD.MM.YYYY')
                     END)) || ' по ' || MAX((CASE pf.pde_nft
                                              WHEN 8 THEN
                                               (CASE WHEN EXTRACT(YEAR FROM pf.pde_val_dt) = 2099 THEN 'довічно' ELSE to_char(pf.pde_val_dt, 'DD.MM.YYYY') END)
                                            END)) AS app_dsblt_period,
                 MAX((CASE pf.pde_nft
                       WHEN 2 THEN
                        to_char(pf.pde_val_dt, 'DD.MM.YYYY')
                     END)) AS app_state_dt,
                 app_sc_info
            FROM uss_esr.v_ap_person p
            JOIN uss_esr.v_pd_family f ON f.pdf_sc = p.app_sc
                                      and f.history_status = 'A'
                                      AND f.pdf_pd = ]'
                        || p_pd_id
                        || '
            JOIN uss_esr.v_pd_features pf ON pf.pde_pdf = f.pdf_id
                                         AND pf.pde_pd = '
                        || p_pd_id
                        || q'[
            LEFT JOIN (SELECT rtrim(listagg(CASE rsn_tp
                                             WHEN 'V' THEN
                                              '\par Канікули/Лікування з ' || to_char(dprt_dt, 'DD.MM.YYYY') || ' по ' || to_char(arrvl_dt, 'DD.MM.YYYY')
                                           END) within
                                   GROUP(ORDER BY dprt_dt, arrvl_dt) || '\par ' || listagg(CASE
                                                                                             WHEN rsn_tp IN ('TR', 'UN', 'DE', 'HL') THEN
                                                                                              '\par Вибув з ' || to_char(dprt_dt, 'DD.MM.YYYY')
                                                                                           END) within GROUP(ORDER BY dprt_dt, arrvl_dt),
                                   '\par ') AS app_sc_info
                          FROM (SELECT d.apd_id,
                                       MAX(CASE atr.apda_nda
                                             WHEN 909 THEN
                                              atr.apda_val_string
                                           END) AS rsn_tp,
                                       MAX(CASE atr.apda_nda
                                             WHEN 907 THEN
                                              atr.apda_val_dt
                                           END) AS dprt_dt,
                                       MAX(CASE atr.apda_nda
                                             WHEN 908 THEN
                                              atr.apda_val_dt
                                           END) AS arrvl_dt
                                  FROM uss_esr.v_personalcase pc
                                  JOIN uss_esr.v_appeal a ON a.ap_pc = pc.pc_id
                                  JOIN uss_esr.v_ap_person p ON p.app_ap = a.ap_id
                                  JOIN uss_esr.v_ap_document d ON d.apd_ap = a.ap_id
                                                              AND d.apd_app = p.app_id
                                                              AND d.apd_ndt IN (10035)
                                  JOIN uss_esr.v_ap_document_attr atr ON atr.apda_apd = d.apd_id
                                                                     AND atr.apda_nda IN (909, 907, 908)
                                 WHERE pc.pc_id = ]'
                        || data_cur.pc_id
                        || '
                                 GROUP BY d.apd_id)) ON 1 = 1
           WHERE p.app_ap = '
                        || data_cur.ap_id
                        || q'[
             AND p.history_status = 'A'
           GROUP BY p.app_sc, p.app_tp, f.pdf_birth_dt, app_sc_info)
    JOIN uss_ndi.v_ddn_app_tp pt ON pt.dic_code = app_tp
   ORDER BY pt.dic_srtordr, 2]');

                    --РОЗМІР ДЕРЖАВНОЇ СОЦІАЛЬНОЇ ДОПОМОГИ:
                    reportfl_engine.addparam ('asstnc_info1',
                                              '$asstnc_info1$');

                    --НАДБАВКА НА ДОГЛЯД
                    reportfl_engine.addparam ('asstnc_info2',
                                              '$asstnc_info2$');

                    --ДЕРЖАВНА АДРЕСНА ДОПОМОГА
                    reportfl_engine.addparam ('asstnc_info3',
                                              '$asstnc_info3$');

                    --ДОПЛАТА
                    reportfl_engine.addparam ('asstnc_info4',
                                              '$asstnc_info4$');

                    --ДЕРЖАВНУ СОЦІАЛЬНУ ДОПОМОГУ
                    reportfl_engine.addparam ('add_asstnc_info1',
                                              '$add_asstnc_info1$');

                    --НАДБАВКУ НА ДОГЛЯД
                    reportfl_engine.addparam ('add_asstnc_info2',
                                              '$add_asstnc_info2$');

                    --ДЕРЖАВНА АДРЕСНА ДОПОМОГА
                    reportfl_engine.addparam ('add_asstnc_info3',
                                              '$add_asstnc_info3$');

                    --ДОПЛАТУ
                    reportfl_engine.addparam ('add_asstnc_info4',
                                              '$add_asstnc_info4$');

                    --СУМА, ЯКА ПЕРЕРАХОВУЄТЬСЯ В ЗАКЛАД ДЕРЖУТРИМАННЯ
                    --ДЕРЖАВНУ СОЦІАЛЬНУ ДОПОМОГУ
                    reportfl_engine.addparam ('add_asstnc_info5',
                                              '$add_asstnc_info5$');

                    --НАДБАВКУ НА ДОГЛЯД
                    reportfl_engine.addparam ('add_asstnc_info6',
                                              '$add_asstnc_info6$');

                    --ДЕРЖАВНА АДРЕСНА ДОПОМОГА
                    reportfl_engine.addparam ('add_asstnc_info7',
                                              '$add_asstnc_info7$');

                    --ДОПЛАТУ
                    reportfl_engine.addparam ('add_asstnc_info8',
                                              '$add_asstnc_info8$');
                ELSIF data_cur.nst_id = 249
                THEN
                    reportfl_engine.adddataset (
                        'main_ds_248',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 248 AND rownum <= 1');
                    reportfl_engine.adddataset (
                        'main_ds_664',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 664 AND rownum <= 1');
                    reportfl_engine.adddataset (
                        'main_ds_249',
                           q'[SELECT pdp_id,
         to_char(pdp_start_dt, 'DD.MM.YYYY') AS period_start_dt,
         (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS period_end_dt,
         to_char((SELECT SUM(pdd_value) FROM uss_esr.v_pd_detail WHERE pdd_pdp = pdp_id AND pdd_ndp = 132), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS avg_sbstnc_lvl,
         to_char((SELECT SUM(pic_month_income) FROM uss_esr.v_pd_income_calc WHERE pic_pd = ]'
                        || p_pd_id
                        || q'[), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS avg_tot_fml_income,
         to_char((SELECT SUM(pdd_value) FROM uss_esr.v_pd_detail WHERE pdd_pdp = pdp_id AND pdd_ndp = 133), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS min_tot_fml_income
    FROM uss_esr.v_pd_payment pdp
   WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                        || p_pd_id
                        || '
   ORDER BY pdp_start_dt, pdp_stop_dt');

                    reportfl_engine.adddataset (
                        'ds249',
                           q'[SELECT ROW_NUMBER() OVER (ORDER BY REPLACE(fml_member_pib, 'Розмір рівня забезпечення для ')) AS rn,
         fml_member_pib,
         fml_member_brth_dt,
         to_char(pdd_value, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS fml_member_min_lvl
    FROM (SELECT uss_person.api$sc_tools.get_pib(pdf_sc) AS fml_member_pib, to_char(pdf_birth_dt, 'DD.MM.YYYY') AS fml_member_brth_dt
            FROM uss_esr.v_pd_family
           WHERE pdf_pd = ]'
                        || p_pd_id
                        || ')
    JOIN uss_esr.v_pd_detail ON pdd_ndp = 131
                            AND instr(upper(pdd_row_name), upper(fml_member_pib)) > 0
    JOIN uss_esr.v_pd_payment pdp ON pdp_id = pdd_pdp AND pdp.history_status = ''A''
                             AND pdp_pd = '
                        || p_pd_id
                        || '
   WHERE 1 = 1');

                    reportfl_engine.addrelation ('main_ds_249',
                                                 'pdp_id',
                                                 'ds249',
                                                 'pdd_pdp');
                ELSIF data_cur.nst_id = 664 --#77049 друкована форма рішення по допомозі ВПО
                THEN
                    reportfl_engine.adddataset (
                        'main_ds_248',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 248 AND rownum <= 1');
                    reportfl_engine.adddataset (
                        'main_ds_249',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 249 AND rownum <= 1');

                    reportfl_engine.adddataset (
                        'ds664',
                           q'[SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(p.app_sc)) AS rn,
         uss_person.api$sc_tools.get_pib(p.app_sc) AS app_pib,
         (SELECT MAX('особа з інвалідністю')
            FROM uss_esr.v_ap_document d
            JOIN uss_esr.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                              AND da.apda_nda IN (1772, 349)
                                              AND da.apda_val_string IS NOT NULL
            WHERE d.apd_ap = ]'
                        || data_cur.ap_id
                        || q'[
              AND d.apd_app = p.app_id
              AND d.apd_ndt IN (10053, 201)
              AND d.history_status = 'A') AS app_info,
         to_char(uss_person.api$sc_tools.get_birthdate(p.app_sc), 'DD.MM.YYYY') AS app_brth_dt
    FROM uss_esr.v_ap_person p
   WHERE p.app_ap = ]'
                        || data_cur.ap_id
                        || q'[
     AND p.app_tp IN ('Z', 'FP')
     AND p.history_status = 'A']');

                    reportfl_engine.adddataset (
                        'ds2',
                           q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
        FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                     upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                     to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt
                FROM uss_esr.v_pd_family f
               WHERE f.pdf_pd = ]'
                        || p_pd_id
                        || q'[) ft
        JOIN (SELECT pd.pdd_row_name,
                     'з ' || to_char(pd.pdd_start_dt, 'DD.MM.YYYY') AS period_info,
                     pd.pdd_value AS SUM
                FROM uss_esr.v_pd_payment p
                JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                           AND pd.pdd_ndp = 300
               WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                        || p_pd_id
                        || ') pdt ON instr(upper(pdt.pdd_row_name), ft.pib) > 0
                                       AND instr(pdt.pdd_row_name, ft.birth_dt) > 0
       ORDER BY ft.rn, pdt.period_info, pdt.sum');

                    reportfl_engine.adddataset (
                        'ds2_tot',
                           q'[SELECT 'з ' || to_char(pdp_start_dt, 'DD.MM.YYYY') AS group_period,
             to_char(SUM(pdp_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
        FROM uss_esr.v_pd_payment pdp
       WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                        || p_pd_id
                        || q'[
       GROUP BY 'з ' || to_char(pdp_start_dt, 'DD.MM.YYYY')
       ORDER BY 1]');
                ELSE
                    reportfl_engine.adddataset (
                        'main_ds_248',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 248 AND rownum <= 1');
                    reportfl_engine.adddataset (
                        'main_ds_249',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 249 AND rownum <= 1');
                    reportfl_engine.adddataset (
                        'main_ds_664',
                           'SELECT 1 FROM uss_ndi.v_ndi_service_type st WHERE '
                        || data_cur.nst_id
                        || ' = 664 AND rownum <= 1');

                    reportfl_engine.adddataset (
                        'ds1',
                           q'[SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn, uss_person.api$sc_tools.get_pib(f.pdf_sc) AS dependent_pib, to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS dependent_brth_dt
        FROM uss_esr.v_pd_family f
       WHERE f.pdf_pd = ]'
                        || p_pd_id);

                    reportfl_engine.adddataset (
                        'ds2',
                           q'[SELECT ft.rn, pdt.period_info, to_char(pdt.sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS sum
        FROM (SELECT row_number() over(ORDER BY uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS rn,
                     upper(uss_person.api$sc_tools.get_pib(f.pdf_sc)) AS pib,
                     to_char(f.pdf_birth_dt, 'DD.MM.YYYY') AS birth_dt
                FROM uss_esr.v_pd_family f
               WHERE f.pdf_pd = ]'
                        || p_pd_id
                        || q'[) ft
        JOIN (SELECT pd.pdd_row_name,
                     to_char(pd.pdd_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pd.pdd_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pd.pdd_stop_dt, 'DD.MM.YYYY') END) AS period_info,
                     pd.pdd_value AS SUM
                FROM uss_esr.v_pd_payment p
                JOIN uss_esr.v_pd_detail pd ON pd.pdd_pdp = p.pdp_id
                                           AND pd.pdd_ndp = 300
               WHERE p.history_status = 'A' AND p.pdp_pd = ]'
                        || p_pd_id
                        || ') pdt ON instr(upper(pdt.pdd_row_name), ft.pib) > 0
                                       AND instr(pdt.pdd_row_name, ft.birth_dt) > 0
       ORDER BY ft.rn, pdt.period_info, pdt.sum');

                    reportfl_engine.adddataset (
                        'ds2_tot',
                           q'[SELECT to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END) AS group_period,
             to_char(SUM(pdp_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum
        FROM uss_esr.v_pd_payment pdp
       WHERE pdp.history_status = 'A' AND pdp_pd = ]'
                        || p_pd_id
                        || q'[
       GROUP BY to_char(pdp_start_dt, 'DD.MM.YYYY') || '-' || (CASE WHEN EXTRACT(YEAR FROM pdp_stop_dt) = 2099 THEN 'довічно' ELSE to_char(pdp_stop_dt, 'DD.MM.YYYY') END)
       ORDER BY 1]');
                END IF;
            END IF;

            v_rpt_blob := reportfl_engine.publishreportblob;

            IF v_rpt_blob IS NOT NULL
            THEN
                --заповнення параметрів із спецсимволами
                v_rpt_clob := tools.convertb2c (v_rpt_blob);
                --#73661/#74090 деталізація в заголовку залежить від типу допомоги
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '$head_desc$',
                        (CASE data_cur.nst_id
                             WHEN 248
                             THEN
                                 'про призначення допомоги особам \par з інвалідністю з дитинства та дітям з інвалідністю'
                             WHEN 249
                             THEN
                                 'про призначення державної соціальної \par допомоги малозабезпеченій сім’ї'
                             WHEN 664
                             THEN
                                 'Про призначення допомоги переміщеним особам на проживання'
                             ELSE
                                 'про призначення допомоги сім’ям з дітьми'
                         END));
                v_rpt_clob :=
                    REPLACE (v_rpt_clob,
                             '$pay_tp_info$',
                             data_cur.pay_tp_info);

                IF v_rt_code = 'ASSISTANCE_DECISION_R1'
                THEN
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '$gen_info$',
                            (CASE data_cur.nst_id
                                 WHEN 249
                                 THEN
                                        'Адреса: '
                                     || data_cur.app_fact_addr
                                     || ' \par '
                                     || '\par Уповноважений представник сім’ї: '
                                     || data_cur.app_name
                                     || '\par РНОКПП                                                 : '
                                     || data_cur.app_code
                                     || ' \par '
                                     || data_cur.pay_info_lines
                                 ELSE
                                        'ЗАЯВНИК                 : '
                                     || data_cur.app_name
                                     || '\par РНОКПП заявника: '
                                     || data_cur.app_code
                                     || ' \par '
                                     || '\par Дата звернення                                        : '
                                     || data_cur.appeal_dt
                                     || '\par Дата народження                                    : '
                                     || data_cur.app_brth_dt
                                     || data_cur.app_add_info
                             END));

                    IF data_cur.nst_id = 248 --#74090 Друкована форма Рішення для допомоги з Ід=248
                    THEN
                        --РОЗМІР ДЕРЖАВНОЇ СОЦІАЛЬНОЇ ДОПОМОГИ:
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM p.pdp_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (p.pdp_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          p.pdp_sum,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 p.pdp_start_dt,
                                                 p.pdp_stop_dt,
                                                 p.pdp_sum)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '169'
                         WHERE     p.pdp_pd = p_pd_id
                               AND p.pdp_sum IS NOT NULL
                               AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$asstnc_info1$', v_str);

                        --НАДБАВКА НА ДОГЛЯД
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM p.pdp_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (p.pdp_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          p.pdp_sum,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 p.pdp_start_dt,
                                                 p.pdp_stop_dt,
                                                 p.pdp_sum)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '290'
                         WHERE     p.pdp_pd = p_pd_id
                               AND p.pdp_sum IS NOT NULL
                               AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$asstnc_info2$', v_str);

                        --ДЕРЖАВНА АДРЕСНА ДОПОМОГА
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM p.pdp_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (p.pdp_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          p.pdp_sum,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 p.pdp_start_dt,
                                                 p.pdp_stop_dt,
                                                 p.pdp_sum)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '995'
                         WHERE     p.pdp_pd = p_pd_id
                               AND p.pdp_sum IS NOT NULL
                               AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$asstnc_info3$', v_str);

                        --ДОПЛАТА
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (p.pdp_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM p.pdp_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (p.pdp_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          p.pdp_sum,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 p.pdp_start_dt,
                                                 p.pdp_stop_dt,
                                                 p.pdp_sum)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '986'
                         WHERE     p.pdp_pd = p_pd_id
                               AND p.pdp_sum IS NOT NULL
                               AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$asstnc_info4$', v_str);

                        --ДЕРЖАВНУ СОЦІАЛЬНУ ДОПОМОГУ
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM d.pdd_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (d.pdd_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          d.pdd_value,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 d.pdd_start_dt,
                                                 d.pdd_stop_dt,
                                                 d.pdd_value)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '169'
                               JOIN v_pd_detail d
                                   ON     d.pdd_pdp = p.pdp_id
                                      AND d.pdd_row_order = 401
                                      AND d.pdd_value IS NOT NULL
                         WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$add_asstnc_info1$', v_str);

                        --НАДБАВКУ НА ДОГЛЯД
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM d.pdd_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (d.pdd_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          d.pdd_value,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 d.pdd_start_dt,
                                                 d.pdd_stop_dt,
                                                 d.pdd_value)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '290'
                               JOIN v_pd_detail d
                                   ON     d.pdd_pdp = p.pdp_id
                                      AND d.pdd_row_order = 401
                                      AND d.pdd_value IS NOT NULL
                         WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$add_asstnc_info2$', v_str);

                        --ДЕРЖАВНА АДРЕСНА ДОПОМОГА
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM d.pdd_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (d.pdd_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          d.pdd_value,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 d.pdd_start_dt,
                                                 d.pdd_stop_dt,
                                                 d.pdd_value)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '995'
                               JOIN v_pd_detail d
                                   ON     d.pdd_pdp = p.pdp_id
                                      AND d.pdd_row_order = 401
                                      AND d.pdd_value IS NOT NULL
                         WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$add_asstnc_info3$', v_str);

                        --ДОПЛАТУ
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM d.pdd_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (d.pdd_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          d.pdd_value,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 d.pdd_start_dt,
                                                 d.pdd_stop_dt,
                                                 d.pdd_value)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '986'
                               JOIN v_pd_detail d
                                   ON     d.pdd_pdp = p.pdp_id
                                      AND d.pdd_row_order = 401
                                      AND d.pdd_value IS NOT NULL
                         WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$add_asstnc_info4$', v_str);

                        --СУМА, ЯКА ПЕРЕРАХОВУЄТЬСЯ В ЗАКЛАД ДЕРЖУТРИМАННЯ
                        --ДЕРЖАВНУ СОЦІАЛЬНУ ДОПОМОГУ
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM d.pdd_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (d.pdd_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          d.pdd_value,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 d.pdd_start_dt,
                                                 d.pdd_stop_dt,
                                                 d.pdd_value)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '169'
                               JOIN v_pd_detail d
                                   ON     d.pdd_pdp = p.pdp_id
                                      AND d.pdd_row_order = 400
                                      AND d.pdd_value IS NOT NULL
                         WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$add_asstnc_info5$', v_str);

                        --НАДБАВКУ НА ДОГЛЯД
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM d.pdd_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (d.pdd_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          d.pdd_value,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 d.pdd_start_dt,
                                                 d.pdd_stop_dt,
                                                 d.pdd_value)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '290'
                               JOIN v_pd_detail d
                                   ON     d.pdd_pdp = p.pdp_id
                                      AND d.pdd_row_order = 400
                                      AND d.pdd_value IS NOT NULL
                         WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$add_asstnc_info6$', v_str);

                        --ДЕРЖАВНА АДРЕСНА ДОПОМОГА
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM d.pdd_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (d.pdd_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          d.pdd_value,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 d.pdd_start_dt,
                                                 d.pdd_stop_dt,
                                                 d.pdd_value)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '995'
                               JOIN v_pd_detail d
                                   ON     d.pdd_pdp = p.pdp_id
                                      AND d.pdd_row_order = 400
                                      AND d.pdd_value IS NOT NULL
                         WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$add_asstnc_info7$', v_str);

                        --ДОПЛАТУ
                        SELECT LISTAGG (
                                      'з '
                                   || TO_CHAR (d.pdd_start_dt, 'DD.MM.YYYY')
                                   || ' по '
                                   || (CASE
                                           WHEN EXTRACT (
                                                    YEAR FROM d.pdd_stop_dt) =
                                                2099
                                           THEN
                                               'довічно'
                                           ELSE
                                               TO_CHAR (d.pdd_stop_dt,
                                                        'DD.MM.YYYY')
                                       END)
                                   || ' '
                                   || TO_CHAR (
                                          d.pdd_value,
                                          'FM9G999G999G999G999G990D00',
                                          'NLS_NUMERIC_CHARACTERS=''.'''''),
                                   ' \par ')
                               WITHIN GROUP (ORDER BY
                                                 d.pdd_start_dt,
                                                 d.pdd_stop_dt,
                                                 d.pdd_value)
                          INTO v_str
                          FROM v_pd_payment  p
                               JOIN uss_ndi.v_ndi_payment_type pt
                                   ON     pt.npt_id = p.pdp_npt
                                      AND pt.npt_code = '986'
                               JOIN v_pd_detail d
                                   ON     d.pdd_pdp = p.pdp_id
                                      AND d.pdd_row_order = 400
                                      AND d.pdd_value IS NOT NULL
                         WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                        v_rpt_clob :=
                            REPLACE (v_rpt_clob, '$add_asstnc_info8$', v_str);
                    END IF;
                END IF;

                v_rpt_blob := tools.convertc2b (v_rpt_clob);

                --створення нового документа
                api$documents.create_decision (p_pd_id        => p_pd_id,
                                               p_ap_id        => data_cur.ap_id,
                                               p_app_id       => data_cur.app_id,
                                               p_aps_id       => data_cur.aps_id,
                                               p_new_pdo_id   => v_pdo_id);
                --Послуга
                api$documents.save_pd_document_attr (
                    p_pdoa_id           => NULL,
                    p_pdoa_pdo          => v_pdo_id,
                    p_pdoa_pd           => p_pd_id,
                    p_pdoa_nda          => 1747,
                    p_pdoa_val_string   => TO_CHAR (data_cur.nst_id),
                    p_new_id            => v_pdoa_id);
                --Статус
                api$documents.save_pd_document_attr (
                    p_pdoa_id           => NULL,
                    p_pdoa_pdo          => v_pdo_id,
                    p_pdoa_pd           => p_pd_id,
                    p_pdoa_nda          => 1748,
                    p_pdoa_val_string   => data_cur.pd_st,
                    p_new_id            => v_pdoa_id);
                --Коментар
                api$documents.save_pd_document_attr (
                    p_pdoa_id    => NULL,
                    p_pdoa_pdo   => v_pdo_id,
                    p_pdoa_pd    => p_pd_id,
                    p_pdoa_nda   => 1749,
                    p_new_id     => v_pdoa_id);

                SELECT MAX (pdp_start_dt), MAX (pdp_stop_dt), MAX (pdp_sum)
                  INTO v_pdp_start_dt, v_pdp_stop_dt, v_pdp_sum
                  FROM (  SELECT pdp_start_dt, pdp_stop_dt, pdp_sum
                            FROM v_pd_payment pdp
                           WHERE pdp_pd = p_pd_id AND pdp.history_status = 'A'
                        ORDER BY pdp_start_dt
                           FETCH FIRST 1 ROW ONLY);

                --Призначено з
                api$documents.save_pd_document_attr (
                    p_pdoa_id       => NULL,
                    p_pdoa_pdo      => v_pdo_id,
                    p_pdoa_pd       => p_pd_id,
                    p_pdoa_nda      => 1750,
                    p_pdoa_val_dt   => v_pdp_start_dt,
                    p_new_id        => v_pdoa_id);
                --Призначено по
                api$documents.save_pd_document_attr (
                    p_pdoa_id       => NULL,
                    p_pdoa_pdo      => v_pdo_id,
                    p_pdoa_pd       => p_pd_id,
                    p_pdoa_nda      => 1751,
                    p_pdoa_val_dt   => v_pdp_stop_dt,
                    p_new_id        => v_pdoa_id);
                --Сума
                api$documents.save_pd_document_attr (
                    p_pdoa_id        => NULL,
                    p_pdoa_pdo       => v_pdo_id,
                    p_pdoa_pd        => p_pd_id,
                    p_pdoa_nda       => 1752,
                    p_pdoa_val_sum   => v_pdp_sum,
                    p_new_id         => v_pdoa_id);
                --Причина відмови
                api$documents.save_pd_document_attr (
                    p_pdoa_id           => NULL,
                    p_pdoa_pdo          => v_pdo_id,
                    p_pdoa_pd           => p_pd_id,
                    p_pdoa_nda          => 1753,
                    p_pdoa_val_string   =>
                        (CASE data_cur.pd_st
                             WHEN 'V' THEN data_cur.reject_reason
                         END),
                    p_new_id            => v_pdoa_id);

                v_pd_num := data_cur.pd_num;
                v_pd_dt := data_cur.pd_dt;
                v_pd_org := data_cur.com_org;
            END IF;
        END LOOP;

        IF v_rpt_blob IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не вдалося сформувати друковану форму рішення, перевірте виконання умов отримання друкованої форми і повторіть спробу пізніше або зверніться до технічної підтримки!');
        ELSE
            OPEN p_doc_cur FOR
                SELECT NULL
                           AS doc_id,
                       NULL
                           AS dh_id,
                       o.org_code || TO_CHAR (v_pd_dt, 'YYYY') || d.pdo_id
                           AS barcode,
                          o.org_name
                       || ';'
                       || v_pd_num
                       || ' від '
                       || TO_CHAR (v_pd_dt, 'DD.MM.YYYY')
                           AS qrcode,
                       o.org_name,
                       TO_CHAR (v_pd_dt, 'DD.MM.YYYY') || ' ' || v_pd_num
                           AS card_info,
                          v_rt_code
                       || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                       || '.pdf'
                           AS filename,
                       v_rpt_blob
                           AS content
                  FROM v_pd_document  d
                       LEFT JOIN ikis_sysweb.v$v_opfu_all o
                           ON o.org_id = v_pd_org
                 WHERE     d.pdo_pd = p_pd_id
                       AND d.pdo_ndt = 10051
                       AND d.history_status = 'A';
        END IF;
    END;

    -- #81832: Нарахування по допомогам
    PROCEDURE accrual_help_rpt (p_dt       IN     DATE,
                                p_pd_nst   IN     NUMBER,
                                p_org_id   IN     NUMBER,
                                p_ap_src   IN     VARCHAR2,
                                res_cur       OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER := tools.getcurrorgto;
    BEGIN
        OPEN res_cur FOR
            SELECT t.com_org                               AS org_id,
                   st.nst_code,
                   pc.pc_num,
                   t.pd_num,
                   (SELECT SUM (z.pdp_sum)
                      FROM pd_payment z
                     WHERE     z.pdp_pd = t.pd_id
                           AND z.history_status = 'A')     AS all_sum,
                   /*
                   (SELECT SUM(z.pdp_sum)
                      FROM pd_payment z
                     WHERE z.pdp_pd = t.pd_id
                       AND z.pdp_start_dt <= p_pd
                       AND z.pdp_stop_dt >= p_pd
                       AND z.history_status = 'A') AS cur_sum*/

                    (SELECT SUM (zd.acd_sum)
                       FROM accrual  z
                            JOIN ac_detail zd ON (zd.acd_ac = z.ac_id)
                      WHERE     zd.acd_pd = t.pd_id
                            AND zd.history_status = 'A'
                            AND zd.acd_start_dt = p_dt)    AS cur_sum
              FROM pc_decision  t
                   JOIN personalcase pc ON (pc.pc_id = t.pd_pc)
                   JOIN uss_ndi.v_ndi_service_type st
                       ON (st.nst_id = t.pd_nst)
                   JOIN v_opfu p ON (p.org_id = t.com_org)
             WHERE     t.pd_st IN ('P', 'S')
                   AND t.pd_nst IN (664,
                                    248,
                                    268,
                                    269,
                                    267,
                                    249,
                                    265)
                   AND t.pd_nst = COALESCE (p_pd_nst, t.pd_nst)
                   AND (   p_org_id IS NULL
                        OR l_org_to IN (30, 40) AND p.org_org = p_org_id
                        OR l_org_to NOT IN (30, 40) AND p.org_id = p_org_id)
                   AND t.com_org = COALESCE (p_org_id, t.com_org)
                   AND EXISTS
                           (SELECT *
                              FROM accrual  z
                                   JOIN ac_detail zd ON (zd.acd_ac = z.ac_id)
                             WHERE zd.acd_pd = t.pd_id AND z.ac_month = p_dt);
    END;

    -- #82138: Не виплачені кошти
    PROCEDURE not_pay_rpt (p_dt          IN     DATE,
                           p_pr_npc      IN     NUMBER,
                           p_org_id      IN     NUMBER,
                           p_prs_nb      IN     NUMBER,
                           p_pr_pay_tp   IN     VARCHAR2,
                           res_cur          OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT s.prs_pc_num,
                     t.com_org
                         AS org_id,
                     s.prs_ln || ' ' || s.prs_fn || ' ' || s.prs_mn
                         AS pib,
                     s.prs_inn,
                     s.prs_account,
                     s.prs_num,
                     t.pr_fix_dt,
                     st.DIC_NAME
                         AS prs_st_name,
                     s.prs_pay_dt,
                     hs.hs_dt
                         AS not_pay_dt,
                     SUM (prs_sum)
                         AS blocked_sum
                FROM payroll t
                     JOIN pr_sheet s ON (s.prs_pr = t.pr_id)
                     JOIN uss_ndi.v_ddn_prs_st st ON (st.DIC_VALUE = s.prs_st)
                     JOIN v_pc_block b ON (b.pcb_id = s.prs_pcb)
                     JOIN histsession hs ON (hs.hs_id = b.pcb_hs_lock)
               WHERE     1 = 1
                     AND b.pcb_exch_code IS NOT NULL
                     AND t.pr_npc = COALESCE (p_pr_npc, t.pr_npc)
                     AND t.com_org = COALESCE (p_org_id, t.com_org)
                     AND t.pr_pay_tp = COALESCE (p_pr_pay_tp, t.pr_pay_tp)
                     AND s.prs_nb = COALESCE (p_prs_nb, s.prs_nb)
                     AND t.pr_month = p_dt
            GROUP BY s.prs_pc_num,
                     t.com_org,
                     s.prs_ln || ' ' || s.prs_fn || ' ' || s.prs_mn,
                     s.prs_inn,
                     s.prs_account,
                     s.prs_num,
                     t.pr_fix_dt,
                     st.DIC_NAME,
                     s.prs_pay_dt,
                     hs.hs_dt;
    END;

    PROCEDURE add_spec_param (p_param_name VARCHAR2)
    IS
    BEGIN
        reportfl_engine.addparam (p_param_name, '$' || p_param_name || '$');
    END;

    -- info:   Отримання вкладення для документа рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_ndt_id - ідентифікатор типу документа
    -- note:   #86747
    FUNCTION get_decision_doc_attach (p_pd_id NUMBER, p_ndt_id NUMBER)
        RETURN BLOB
    IS
        v_rpt_blob   BLOB;
        v_rpt_clob   CLOB;
        v_str        VARCHAR2 (4000);
        l_p18        VARCHAR2 (4000);
        p142         VARCHAR2 (4000);
    BEGIN
        IF p_ndt_id IN (850, 852)
        THEN                                             --assistance_decision
            --#77794 друкована форма для рішення про надання/відмову в наданні СП (SS)/#77873 «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу»
            FOR c
                IN (  SELECT pd.pd_id,
                             MAX (
                                 COALESCE (
                                     (SELECT MAX (sc.sc_id)
                                        FROM v_pd_pay_method pm
                                             JOIN uss_person.v_socialcard sc
                                                 ON sc.sc_scc = pm.pdm_scc
                                       WHERE     pm.pdm_pd = p_pd_id
                                             AND pm.history_status = 'A'
                                             AND pm.pdm_is_actual = 'T'),
                                     (SELECT pc.pc_sc
                                        FROM v_personalcase pc
                                       WHERE pc.pc_id = pd.pd_pc)))
                                 AS pd_sc,
                             o.org_id,
                             o.org_name,
                             o.org_to,
                             pd.pd_st,
                             pd.pd_dt,
                             pd.pd_num,
                             MAX (
                                 COALESCE (
                                     (SELECT pde_val_string
                                        FROM pd_features
                                       WHERE pde_pd = p_pd_id AND pde_nft = 9),
                                     (CASE
                                          WHEN     d.apd_ndt = 801
                                               AND da.apda_nda = 1872
                                          THEN
                                              da.apda_val_string
                                      END)))
                                 AS ss_org_name,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 10 THEN f.pde_val_string
                                 END)
                                 AS ss_pay_need,
                             MAX (
                                 CASE
                                     WHEN pd.pd_st IN ('PV', 'AV', 'V')
                                     THEN
                                         (SELECT LISTAGG (njr_name || ';',
                                                          CHR (10) || '\par')
                                                 WITHIN GROUP (ORDER BY
                                                                   njr_order,
                                                                   njr_code,
                                                                   njr_name)    AS rej_info
                                            FROM v_pd_reject_info
                                                 JOIN
                                                 uss_ndi.v_ndi_reject_reason
                                                     ON njr_id = pri_njr
                                           WHERE pri_pd = p_pd_id)
                                 END)
                                 AS reject_reason,
                             a.ap_id,
                             a.ap_reg_dt,
                             a.ap_num,
                             a.ap_is_second,
                             a.com_org
                                 AS ap_org,
                             MAX ( (SELECT st.nst_name
                                      FROM uss_ndi.v_ndi_service_type st
                                     WHERE st.nst_id = pd.pd_nst))
                                 AS nst_name_list,
                             MAX ( (SELECT u.wu_pib
                                      FROM ikis_sysweb.v$all_users u
                                     WHERE u.wu_id = pd.com_wu))
                                 AS wu_pib,
                             lt.sign_dt,
                             lt.sign_pib,
                             ic.pic_id,
                             ic.pic_total_income_6m,
                             ic.pic_month_income,
                             ic.pic_member_month_income,
                             ic.pic_limit,
                             lt.make_dt,
                             /*MAX(CASE
                                   WHEN d.apd_ndt = 801 AND da.apda_nda = 1871 THEN
                                    da.apda_val_string
                                 END) AS p1871,
                             MAX(CASE
                                   WHEN d.apd_ndt = 802 AND da.apda_nda = 1948 THEN
                                    da.apda_val_string
                                 END) AS p1948,*/
                             COALESCE (
                                 MAX (
                                     CASE
                                         WHEN     d.apd_ndt IN (818, 819)
                                              AND da.apda_nda IN (2061, 2039)
                                         THEN
                                             da.apda_val_string
                                     END),
                                 MAX (dda.pdoa_val_string))
                                 AS f9,
                             MAX (CASE d.apd_ndt
                                      WHEN 803
                                      THEN
                                          (SELECT ndt_name
                                             FROM uss_ndi.v_ndi_document_type
                                            WHERE ndt_id = 803)
                                  END)
                                 AS ndt803_exist,
                             lt.appr_pib,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 32 THEN f.pde_val_string
                                 END)
                                 AS f32,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 33 THEN f.pde_val_string
                                 END)
                                 AS f33,
                             pd.pd_is_signed,
                             (CASE COUNT (
                                       CASE d.apd_ndt
                                           WHEN 801 THEN d.apd_id
                                       END)
                                  WHEN 0
                                  THEN
                                      (SELECT ndt_name
                                         FROM uss_ndi.v_ndi_document_type
                                        WHERE ndt_id = 801)
                              END)
                                 AS ndt801_need
                        FROM v_pc_decision pd
                             JOIN v_opfu o ON o.org_id = pd.com_org
                             JOIN v_appeal a
                                 ON a.ap_id = pd.pd_ap AND a.ap_tp = 'SS'
                             JOIN v_ap_person p
                                 ON     p.app_ap = a.ap_id
                                    AND p.app_tp = 'Z'
                                    AND p.history_status = 'A'
                             LEFT JOIN v_ap_document d
                                 ON     d.apd_ap = pd.pd_ap
                                    AND d.apd_app = p.app_id
                                    AND d.apd_ndt IN (801,            /*802,*/
                                                      803,
                                                      818,
                                                      819)
                                    AND d.history_status = 'A'
                             LEFT JOIN v_ap_document_attr da
                                 ON     da.apda_ap = pd.pd_ap
                                    AND da.apda_apd = d.apd_id
                                    AND da.apda_nda IN (             /*1871,*/
                                                        1872,        /*1948,*/
                                                              2039, 2061)
                                    AND da.history_status = 'A'
                             LEFT JOIN uss_esr.v_pd_document dd
                             JOIN uss_esr.pd_document_attr dda
                                 ON     dda.pdoa_pd = p_pd_id
                                    AND dda.pdoa_pdo = dd.pdo_id
                                    AND dda.pdoa_nda IN (2061, 2039)
                                    AND dda.history_status = 'A'
                                 ON     dd.pdo_pd = p_pd_id
                                    AND dd.pdo_ap = pd.pd_ap
                                    AND COALESCE (dd.pdo_app, p.app_id) =
                                        p.app_id
                                    AND dd.pdo_ndt IN (818, 819)
                                    AND dd.history_status = 'A'
                             JOIN
                             (SELECT MAX (make_dt)      AS make_dt,
                                     MAX (sign_dt)      AS sign_dt,
                                     MAX (sign_pib)     AS sign_pib,
                                     MAX (appr_pib)     AS appr_pib
                                FROM (SELECT FIRST_VALUE (
                                                 (CASE l.pdl_st
                                                      WHEN 'WD' THEN h.hs_dt
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS make_dt,
                                             FIRST_VALUE (
                                                 (CASE l.pdl_st
                                                      WHEN 'P' THEN h.hs_dt
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS sign_dt,
                                             FIRST_VALUE (
                                                 (CASE l.pdl_st
                                                      WHEN 'P' THEN u.wu_pib
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS sign_pib,
                                             FIRST_VALUE (
                                                 (CASE
                                                      WHEN    (    l.pdl_st =
                                                                   'WD'
                                                               AND l.pdl_st_old =
                                                                   'R1')
                                                           OR (    l.pdl_st =
                                                                   'AV'
                                                               AND l.pdl_st_old =
                                                                   'PV')
                                                      THEN
                                                          u.wu_pib
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS appr_pib
                                        FROM v_pd_log l
                                             JOIN v_histsession h
                                                 ON h.hs_id = l.pdl_hs
                                             JOIN ikis_sysweb.v$all_users u
                                                 ON u.wu_id = h.hs_wu
                                       WHERE     l.pdl_pd = p_pd_id
                                             AND l.pdl_st IN ('WD', 'P', 'AV')))
                             lt
                                 ON 1 = 1
                             LEFT JOIN v_pd_income_calc ic
                                 ON ic.pic_pd = p_pd_id
                             LEFT JOIN v_pd_features f
                                 ON     f.pde_pd = p_pd_id
                                    AND f.pde_nft IN (10, 32, 33)
                       WHERE pd.pd_id = p_pd_id
                    GROUP BY pd.pd_id,
                             o.org_id,
                             o.org_name,
                             o.org_to,
                             pd.pd_st,
                             pd.pd_dt,
                             pd.pd_num,
                             a.ap_id,
                             a.ap_reg_dt,
                             a.ap_num,
                             a.ap_is_second,
                             a.com_org,
                             lt.sign_dt,
                             lt.sign_pib,
                             ic.pic_id,
                             ic.pic_total_income_6m,
                             ic.pic_month_income,
                             ic.pic_member_month_income,
                             ic.pic_limit,
                             lt.make_dt,
                             lt.appr_pib,
                             pd.pd_is_signed)
            LOOP
                --#77050 заборонено формування рішення при наявності документа «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803
                IF    c.ndt803_exist IS NOT NULL
                   OR get_doc_cnt (c.ap_id, 803) > 0
                THEN
                    raise_application_error (
                        -20000,
                           'Звернення було створено на основі документа «'
                        || COALESCE (c.ndt803_exist, get_ndt_name (803))
                        || '», для якого відсутні друковані форми Рішення/Повідомлення');
                ELSIF     c.ndt801_need IS NOT NULL
                      AND get_doc_cnt (c.ap_id, 801) = 0
                      AND get_doc_cnt (c.ap_id, 836) = 0
                THEN                        --#86747 / #90238: 20230801 bogdan
                    raise_application_error (
                        -20000,
                           'В зверненні відсутній ініціативний документ «'
                        || c.ndt801_need
                        || '»');
                ELSIF c.pd_is_signed = 'T'
                THEN
                    raise_application_error (
                        -20000,
                        'Підписані рішення недоступні для формування!');
                END IF;

                --#79593/#77873 формування «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу»
                IF /*c.pd_st NOT IN ('PV', 'AV', 'V') AND (c.p1871 = 'T' OR c.p1948 = 'T')*/
                       c.f32 = 'T'
                   AND c.f33 = 'T'
                   AND c.ap_org = tools.getcurrorg
                THEN
                    IF p_ndt_id = 850
                    THEN
                        raise_application_error (
                            -20000,
                            'Умови формування вкладення не відповідають поточним!');
                    END IF;

                    reportfl_engine.initreport ('USS_ESR',
                                                'PLACEMENT_APPLICATION_R1');

                    IF c.org_to > 31
                    THEN
                            SELECT MAX (
                                       CASE
                                           WHEN po.org_to IN (31, 34)
                                           THEN
                                               po.org_name
                                       END)
                              INTO v_str
                              FROM v_opfu po
                             WHERE po.org_st = 'A'
                        START WITH po.org_id =
                                   COALESCE (c.org_id, tools.getcurrorg)
                        CONNECT BY PRIOR po.org_org = po.org_id;
                    END IF;

                    reportfl_engine.addparam (
                        'p1',
                        COALESCE (v_str,
                                  c.org_name,
                                  '________________________________'));

                    add_spec_param ('p2');
                    reportfl_engine.addparam (
                        'p3',
                        COALESCE (TO_CHAR (c.ap_reg_dt, 'DD.MM.YYYY'),
                                  '_______________'));
                    reportfl_engine.addparam (
                        'p4',
                        COALESCE (c.ap_num, '________________'));
                    add_spec_param ('p5');
                    add_spec_param ('p6');
                    add_spec_param ('p7');

                    SELECT LISTAGG (ndt_name, ', ')
                               WITHIN GROUP (ORDER BY ndt_order)
                      INTO v_str
                      FROM (SELECT DISTINCT dt.ndt_name, dt.ndt_order
                              FROM v_ap_document  d
                                   JOIN uss_ndi.v_ndi_document_type dt
                                       ON dt.ndt_id = d.apd_ndt
                             WHERE     d.apd_ap = c.ap_id
                                   AND d.history_status = 'A');

                    reportfl_engine.addparam (
                        'p8',
                        COALESCE (
                            v_str,
                            'пакет документів (зазначити повний перелік)'));

                    add_spec_param ('p9');
                    reportfl_engine.addparam (
                        'p81',
                        (CASE
                             WHEN c.nst_name_list IS NOT NULL
                             THEN
                                 ' ' || c.nst_name_list
                         END));
                    add_spec_param ('p9');
                    add_spec_param ('p10');
                    reportfl_engine.addparam (
                        'p11',
                        COALESCE (TO_CHAR (c.sign_dt, 'DD.MM.YYYY'),
                                  '___  _______________ 20___'));
                ELSE
                    IF p_ndt_id = 852
                    THEN
                        raise_application_error (
                            -20000,
                            'Умови формування вкладення не відповідають поточним!');
                    END IF;

                    --#77794/#83639 друкована форма для рішення про надання/відмову в наданні СП (SS)
                    reportfl_engine.initreport ('USS_ESR',
                                                'ASSISTANCE_DECISION_R2'); --одна форма на відмову і на підтвердження
                    add_spec_param ('p1');
                    add_spec_param ('p2');
                    add_spec_param ('p3');
                    reportfl_engine.addparam (
                        'p4',
                        COALESCE (TO_CHAR (c.ap_reg_dt, 'DD.MM.YYYY'),
                                  '________________________________'));
                    reportfl_engine.addparam (
                        'p5',
                        COALESCE (c.ap_num, '_______________________'));
                    add_spec_param ('p6');
                    add_spec_param ('p7');
                    add_spec_param ('p8');
                    add_spec_param ('p9');
                    reportfl_engine.addparam (
                        'p10',
                        COALESCE (
                            TO_CHAR (c.pic_member_month_income,
                                     'FM9G999G999G999G999G990D00',
                                     'NLS_NUMERIC_CHARACTERS=''.'''''),
                            '________________________________'));
                    add_spec_param ('p11');
                    add_spec_param ('p121');
                    add_spec_param ('p122');
                    add_spec_param ('p123');
                    reportfl_engine.addparam (
                        'p13',
                        COALESCE (
                            TO_CHAR (c.pic_limit,
                                     'FM9G999G999G999G999G990D00',
                                     'NLS_NUMERIC_CHARACTERS=''.'''''),
                            '___________'));
                    add_spec_param ('p14');
                    add_spec_param ('p15');
                    add_spec_param ('p16');
                    reportfl_engine.addparam (
                        'p17',
                        get_doc_atr_str (p_pd_id   => p_pd_id,
                                         p_ndt     => 850,
                                         p_nda     => 3082)); --#87820 add_spec_param('p17');
                    l_p18 :=
                        get_doc_atr_row (p_pd_id, 850, '2955, 2956, 2957');
                    reportfl_engine.addparam ('p18', l_p18); --#87820 add_spec_param('p18');
                    reportfl_engine.addparam ('p181',
                                              COALESCE (l_p18     /*c.wu_pib*/
                                                             , '_________'));
                    reportfl_engine.addparam (
                        'p19',
                        get_doc_atr_str (p_pd_id   => p_pd_id,
                                         p_ndt     => 850,
                                         p_nda     => 3083)); --#87820 add_spec_param('p19');
                    reportfl_engine.addparam (
                        'p20',
                        get_doc_atr_row (p_pd_id, 850, '2958, 2959, 2960')); --#87820 add_spec_param('p20');

                    reportfl_engine.addparam (
                        'p21',
                        COALESCE (TO_CHAR (c.sign_dt, 'DD.MM.YYYY'),
                                  '___  ___________________ 20___'));
                    reportfl_engine.addparam (
                        'p52',
                        COALESCE (
                            TO_CHAR (c.pic_total_income_6m,
                                     'FM9G999G999G999G999G990D00',
                                     'NLS_NUMERIC_CHARACTERS=''.'''''),
                            '_________________________________'));
                    reportfl_engine.addparam (
                        'p53',
                        COALESCE (
                            TO_CHAR (c.pic_month_income,
                                     'FM9G999G999G999G999G990D00',
                                     'NLS_NUMERIC_CHARACTERS=''.'''''),
                            '_________________________________'));
                    reportfl_engine.addparam (
                        'p54',
                        COALESCE (
                            TO_CHAR (c.pic_member_month_income,
                                     'FM9G999G999G999G999G990D00',
                                     'NLS_NUMERIC_CHARACTERS=''.'''''),
                            '_________________________________'));
                    reportfl_engine.addparam (
                        'p55',
                        COALESCE (
                            TO_CHAR (c.pic_limit,
                                     'FM9G999G999G999G999G990D00',
                                     'NLS_NUMERIC_CHARACTERS=''.'''''),
                            '_________________________________'));
                    reportfl_engine.addparam (
                        'p56',
                        COALESCE (TO_CHAR (c.make_dt, 'DD.MM.YYYY'),
                                  '_________'));

                    --#86997 "\par" на друку не замінюється на chr(10), тому зробив явно
                    reportfl_engine.adddataset (
                        'ds',
                           q'[SELECT row_number() over(ORDER BY c2, c3) AS c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
      FROM (SELECT t.app_id,
                   pt.dic_sname AS c2,
                   uss_person.api$sc_tools.get_pib(t.app_sc) AS c3,
                   td.rltn_tp AS c4,
                   td.doc AS c5,
                   tt.inc_tp AS c6,
                   to_char(SUM(coalesce(t.pid_calc_sum, 0)), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c7,
                   to_char(MAX(CASE WHEN t.pid_month = add_months(t.last_month, -2) THEN t.pid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  ||' '||chr(10) ||' '||
                   to_char(SUM(CASE WHEN t.pid_month = add_months(t.last_month, -2) THEN t.pid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c8,
                   to_char(MAX(CASE WHEN t.pid_month = add_months(t.last_month, -1) THEN t.pid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian')  ||' '|| chr(10) ||' '||
                   to_char(SUM(CASE WHEN t.pid_month = add_months(t.last_month, -1) THEN t.pid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c9,
                   to_char(MAX(CASE WHEN t.pid_month = t.last_month THEN t.pid_month END), 'MONTH YYYY', 'nls_date_language=Ukrainian') ||' '|| chr(10) ||' '||
                   to_char(SUM(CASE WHEN t.pid_month = t.last_month THEN t.pid_calc_sum ELSE 0 END), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c10
              FROM (SELECT ap.app_id, ap.app_sc, ap.app_tp, pd.pid_month, pd.pid_calc_sum, MAX(pd.pid_month) over(PARTITION BY ap.app_id) AS last_month
                      FROM uss_esr.v_ap_person ap
                      JOIN uss_esr.v_pd_income_detail pd ON pd.pid_app = ap.app_id
                                                        AND pd.pid_sc = ap.app_sc
                                                        AND pd.pid_is_family_member = 'T']'
                        || (CASE
                                WHEN c.pic_id IS NOT NULL
                                THEN
                                       '
                                                        AND pd.pid_pic = '
                                    || TO_CHAR (c.pic_id)
                            END)
                        || '
                     WHERE ap.app_ap = '
                        || TO_CHAR (c.ap_id)
                        || q'[
                       AND ap.history_status = 'A'
                       AND ap.app_tp IN ('Z', 'FM', 'OS')) t
              JOIN uss_ndi.v_ddn_app_tp pt ON pt.dic_value = t.app_tp
              LEFT JOIN (SELECT d.apd_app,
                               MAX(CASE
                                     WHEN da.apda_nda = 813 AND da.apda_val_string IS NOT NULL
                                       THEN (SELECT t.dic_name FROM uss_ndi.v_ddn_relation_tp t WHERE t.dic_value = da.apda_val_string)
                                   END) AS rltn_tp,
                               coalesce(MAX(CASE da.apda_nda WHEN 1 THEN da.apda_val_string END),
                                        MAX(CASE WHEN da.apda_nda IN (3, 9) THEN da.apda_val_string END)) AS doc
                          FROM uss_esr.v_ap_document d
                          JOIN uss_esr.v_ap_document_attr da ON da.apda_apd = d.apd_id
                                                            AND da.apda_ap = ]'
                        || TO_CHAR (c.ap_id)
                        || q'[
                                                            AND da.apda_nda IN (1, 3, 9, 813)
                                                            AND da.history_status = 'A'
                         WHERE d.apd_ap = ]'
                        || TO_CHAR (c.ap_id)
                        || q'[
                           AND d.apd_ndt IN (5, 6, 7, 605)
                           AND d.history_status = 'A'
                         GROUP BY d.apd_app) td ON td.apd_app = t.app_id
              LEFT JOIN (SELECT pis_app, pis_sc, listagg(dic_sname, ', ') within GROUP(ORDER BY dic_srtordr) AS inc_tp
                           FROM (SELECT DISTINCT s.pis_app, s.pis_sc, st.dic_sname, st.dic_srtordr
                                   FROM uss_esr.v_pd_income_src s
                                   JOIN uss_ndi.v_ddn_apri_tp st ON st.dic_value = s.pis_tp
                                  WHERE s.pis_pd = ]'
                        || TO_CHAR (p_pd_id)
                        || q'[)
                          GROUP BY pis_app, pis_sc) tt ON tt.pis_app = t.app_id
                                                      AND tt.pis_sc = t.app_sc
             WHERE t.pid_month >= add_months(t.last_month, -2)
             GROUP BY t.app_id, pt.dic_sname, t.app_sc, td.rltn_tp, td.doc, tt.inc_tp)]');
                END IF;

                v_rpt_blob := reportfl_engine.publishreportblob;

                IF v_rpt_blob IS NOT NULL
                THEN
                    --заповнення параметрів із спецсимволами
                    v_rpt_clob := tools.convertb2c (v_rpt_blob);

                    IF p_ndt_id = 852
                    THEN
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p2$',
                                COALESCE (
                                    uss_person.api$sc_tools.get_pib (c.pd_sc),
                                       '________________________________________________________________\par'
                                    || '(прізвище, ім’я, по батькові (за наявності) заявника)\par'
                                    || '______________________________________________'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p5$',
                                COALESCE (
                                    c.org_name,
                                    '____________________________________________________________________________________\par'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p6$',
                                COALESCE (
                                    uss_person.api$sc_tools.get_pib (c.pd_sc),
                                       '____________________________________________________________________________________\par'
                                    || '\fs20                                (прізвище, ім.’я, по батькові (за наявності) особи, яка потребує надання соціальних послуг) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p7$',
                                COALESCE (
                                    (CASE c.ss_pay_need
                                         WHEN 'F'
                                         THEN
                                             '\ul безоплатно \ul0 , платно, з установленням диференційованої плати'
                                         WHEN 'C'
                                         THEN
                                             'безоплатно, \ul платно \ul0 , з установленням диференційованої плати'
                                         WHEN 'D'
                                         THEN
                                             'безоплатно, платно, \ul з установленням диференційованої плати \ul0'
                                     END),
                                    'безоплатно, платно, з установленням диференційованої плати'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p9$',
                                COALESCE (
                                    NULL,
                                       '__________________\par'
                                    || '\fs20              (посада) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p10$',
                                COALESCE (
                                    c.sign_pib,
                                       '_________________________________________\par'
                                    || '\fs20                (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                    ELSE
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p1$',
                                COALESCE (
                                    TO_CHAR (c.pd_dt, 'DD.MM.YYYY'),
                                       '____________________\par'
                                    || '\fs20      (число, місяць, рік) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p2$',
                                COALESCE (
                                    c.pd_num,
                                       '____________________\par'
                                    || '\fs20             (номер рішення) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p3$',
                                COALESCE (
                                    c.org_name,
                                    '_____________________________________________________________________________________\par'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p6$',
                                (CASE c.ap_is_second
                                     WHEN 'T'
                                     THEN
                                         'первинне/ \ul повторне \ul0'
                                     ELSE
                                         '\ul первинне \ul0 /повторне'
                                 END));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p7$',
                                COALESCE (
                                    uss_person.api$sc_tools.get_pib (c.pd_sc),
                                       '_____________________________________________________________________________\par'
                                    || '\fs20                                               (прізвище, ім’я, по батькові (за наявності) заявника / законного представника/\par'
                                    || '                                                                                   уповноваженого представника сім’ї) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p8$',
                                COALESCE (
                                    uss_person.api$sc_tools.get_pib (c.pd_sc),
                                       '___________________________________\par'
                                    || '____________________________________________________________________________________\par'
                                    || '\fs20                                                                                 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p9$',
                                COALESCE (
                                    (CASE c.f9
                                         WHEN 'F'
                                         THEN
                                             'Сім''я/особа не потребує надання соціальних послуг'
                                         WHEN 'T'
                                         THEN
                                             'Сім''я/особа потребує надання соціальних послуг'
                                     END),
                                       '_____________________________________________\par'
                                    || '\fs20                                                                                                                       (зазначити результат оцінювання потреб) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p11$',
                                COALESCE (
                                       (CASE
                                            WHEN c.nst_name_list IS NOT NULL
                                            THEN
                                                '\ul надати соціальну послугу \ul0 '
                                        END)
                                    || c.nst_name_list,
                                       'надати соціальну послугу ____________________________________________________________\par'
                                    || '\fs20                                                                                                                      (назва соціальної послуги) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p121$',
                                (CASE c.ss_pay_need
                                     WHEN 'F' THEN v_check_mark
                                 END));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p122$',
                                (CASE c.ss_pay_need
                                     WHEN 'C' THEN v_check_mark
                                 END));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p123$',
                                (CASE c.ss_pay_need
                                     WHEN 'D' THEN v_check_mark
                                 END));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p14$',
                                COALESCE (
                                    c.ss_org_name,
                                       '____________________________________________________________\par'
                                    || '\fs20                                                                                     (найменування установи, закладу, підприємства, організації) \fs24\par'
                                    || '___________________________________________________________________________________  '));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p15$',
                                COALESCE (
                                    (CASE
                                         WHEN c.pd_st IN ('PV', 'AV', 'V')
                                         THEN
                                                (CASE
                                                     WHEN c.nst_name_list
                                                              IS NOT NULL
                                                     THEN
                                                         '\ul відмовити в наданні соціальної послуги \ul0 '
                                                 END)
                                             || c.nst_name_list
                                     END),
                                       'відмовити в наданні соціальної послуги _______________________________________________\par'
                                    || '\fs20                                                                                                                                   (назва соціальної(их) послуги) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p16$',
                                COALESCE (
                                    (CASE
                                         WHEN c.pd_st IN ('PV', 'AV', 'V')
                                         THEN
                                             c.reject_reason
                                     END),
                                       '________________________________________________________________________________\par'
                                    || '\fs20                                                                                           (причина відмови) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p17$',
                                COALESCE (
                                    NULL,
                                       '__________________________\par'
                                    || '\fs20                        (посада) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p18$',
                                COALESCE (
                                    CASE
                                        WHEN get_doc_atr_str (p_pd_id,
                                                              850,
                                                              2955)
                                                 IS NOT NULL
                                        THEN                          --#86997
                                               get_doc_atr_str (p_pd_id,
                                                                850,
                                                                2955)
                                            || ' '
                                            || get_doc_atr_str (p_pd_id,
                                                                850,
                                                                2956)
                                            || ' '
                                            || get_doc_atr_str (p_pd_id,
                                                                850,
                                                                2957)
                                    END,
                                    c.wu_pib,
                                       '____________________________________\par'
                                    || '\fs20         (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p19$',
                                COALESCE (
                                    NULL,
                                       '__________________________\par'
                                    || '\fs20                        (посада) \fs24'));
                        v_rpt_clob :=
                            REPLACE (
                                v_rpt_clob,
                                '$p20$',
                                COALESCE (
                                    CASE
                                        WHEN get_doc_atr_str (p_pd_id,
                                                              850,
                                                              2958)
                                                 IS NOT NULL
                                        THEN                          --#86997
                                               get_doc_atr_str (p_pd_id,
                                                                850,
                                                                2958)
                                            || ' '
                                            || get_doc_atr_str (p_pd_id,
                                                                850,
                                                                2959)
                                            || ' '
                                            || get_doc_atr_str (p_pd_id,
                                                                850,
                                                                2960)
                                    END,
                                    c.sign_pib,
                                       '____________________________________\par'
                                    || '\fs20         (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                    END IF;

                    v_rpt_blob := tools.convertc2b (v_rpt_clob);
                END IF;
            END LOOP;
        --assistance_decision
        ELSIF p_ndt_id = 851
        THEN                                              --assistance_message
            --#77804 друкована форма для рішень про надання СП (SS)
            FOR c
                IN (  SELECT pd.pd_id,
                             COALESCE (sc.sc_id, pc.pc_sc)
                                 AS pd_sc,
                             RTRIM (
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1874
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1875
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'обл. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1876
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'р-он. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1873
                                            THEN
                                                LTRIM (
                                                       COALESCE (
                                                           (SELECT k.kaot_full_name
                                                              FROM uss_ndi.v_ndi_katottg
                                                                   k
                                                             WHERE k.kaot_id =
                                                                   da.apda_val_id),
                                                           TRIM (
                                                               da.apda_val_string))
                                                    || ', ',
                                                    ', ')
                                        END)
                                 || COALESCE (
                                        MAX (
                                            CASE
                                                WHEN     d.apd_ndt = 801
                                                     AND da.apda_nda = 1879
                                                THEN
                                                    LTRIM (
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
                                                        || ', ',
                                                        ', ')
                                            END),
                                        MAX (
                                            CASE
                                                WHEN     d.apd_ndt = 801
                                                     AND da.apda_nda = 1878
                                                     AND TRIM (
                                                             da.apda_val_string)
                                                             IS NOT NULL
                                                THEN
                                                       TRIM (
                                                           da.apda_val_string)
                                                    || ', '
                                            END))
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1880
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'буд. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1881
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'корп. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1882
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'кв. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END),
                                 ', ')
                                 AS pers_fact_addr,
                             o.org_id,
                             o.org_name,
                             pd.pd_st,
                             pd.pd_dt,
                             pd.pd_num,
                             COALESCE (
                                 MAX (
                                     CASE f.pde_nft
                                         WHEN 9 THEN f.pde_val_string
                                     END),
                                 MAX (
                                     CASE
                                         WHEN     d.apd_ndt = 801
                                              AND da.apda_nda = 1872
                                         THEN
                                             da.apda_val_string
                                     END))
                                 AS ss_org_name,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 10 THEN f.pde_val_string
                                 END)
                                 AS ss_pay_need,
                             MAX (
                                 CASE
                                     WHEN pd.pd_st IN ('PV', 'AV', 'V')
                                     THEN
                                         (SELECT LISTAGG (
                                                        njr_code
                                                     || ' '
                                                     || njr_name
                                                     || ';',
                                                     CHR (10) || '\par')
                                                 WITHIN GROUP (ORDER BY
                                                                   njr_order,
                                                                   njr_code,
                                                                   njr_name)    AS rej_info
                                            FROM v_pd_reject_info
                                                 JOIN
                                                 uss_ndi.v_ndi_reject_reason
                                                     ON njr_id = pri_njr
                                           WHERE pri_pd = p_pd_id)
                                 END)
                                 AS reject_reason,
                             lt.appr_dt,
                             lt.appr_pib,
                             MAX (CASE d.apd_ndt
                                      WHEN 803
                                      THEN
                                          (SELECT ndt_name
                                             FROM uss_ndi.v_ndi_document_type
                                            WHERE ndt_id = 803)
                                  END)
                                 AS ndt803_exist,
                             (CASE COUNT (
                                       CASE d.apd_ndt
                                           WHEN 801 THEN d.apd_id
                                       END)
                                  WHEN 0
                                  THEN
                                      (SELECT ndt_name
                                         FROM uss_ndi.v_ndi_document_type
                                        WHERE ndt_id = 801)
                              END)
                                 AS ndt801_need,
                             a.ap_id
                        FROM v_pc_decision pd
                             JOIN v_opfu o ON o.org_id = pd.com_org
                             JOIN v_appeal a
                                 ON a.ap_id = pd.pd_ap AND a.ap_tp = 'SS'
                             LEFT JOIN v_pd_pay_method pm
                             JOIN uss_person.v_socialcard sc
                                 ON sc.sc_scc = pm.pdm_scc
                                 ON     pm.pdm_pd = p_pd_id
                                    AND pm.history_status = 'A'
                                    AND pm.pdm_is_actual = 'T'
                             LEFT JOIN v_personalcase pc
                                 ON pc.pc_id = pd.pd_pc AND sc.sc_id IS NULL
                             LEFT JOIN v_ap_person p
                             JOIN v_ap_document d
                                 ON     d.apd_app = p.app_id
                                    AND d.apd_ap = p.app_ap
                                    AND d.apd_ndt IN (801, 803)
                                    AND d.history_status = 'A'
                             JOIN v_ap_document_attr da
                                 ON     da.apda_apd = d.apd_id
                                    AND da.apda_ap = d.apd_ap
                                    AND da.history_status = 'A'
                                 ON     p.app_ap = a.ap_id
                                    AND p.app_sc =
                                        COALESCE (sc.sc_id, pc.pc_sc)
                                    AND p.app_tp = 'Z'
                                    AND p.history_status = 'A'
                             LEFT JOIN
                             (SELECT l.pdl_id,
                                     FIRST_VALUE (l.pdl_id)
                                         OVER (ORDER BY h.hs_dt DESC)
                                         AS lpdl_id,
                                     h.hs_dt
                                         AS appr_dt,
                                     u.wu_pib
                                         AS appr_pib
                                FROM v_pd_log l
                                     JOIN v_histsession h ON h.hs_id = l.pdl_hs
                                     JOIN ikis_sysweb.v$all_users u
                                         ON u.wu_id = h.hs_wu
                               WHERE l.pdl_pd = p_pd_id AND l.pdl_st = 'P') lt
                                 ON lt.pdl_id = lt.lpdl_id AND pd.pd_st = 'P'
                             LEFT JOIN v_pd_features f
                                 ON f.pde_pd = p_pd_id AND f.pde_nft IN (9, 10)
                       WHERE pd.pd_id = p_pd_id
                    GROUP BY pd.pd_id,
                             COALESCE (sc.sc_id, pc.pc_sc),
                             o.org_id,
                             o.org_name,
                             pd.pd_st,
                             pd.pd_dt,
                             pd.pd_num,
                             lt.appr_dt,
                             lt.appr_pib,
                             a.ap_id)
            LOOP
                --#77050 заборонено формування повідомлення при наявності документа «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803
                IF    c.ndt803_exist IS NOT NULL
                   OR get_doc_cnt (c.ap_id, 803) > 0
                THEN
                    raise_application_error (
                        -20000,
                           'Звернення було створено на основі документа «'
                        || COALESCE (c.ndt803_exist, get_ndt_name (803))
                        || '», для якого відсутні друковані форми Рішення/Повідомлення');
                ELSIF     c.ndt801_need IS NOT NULL
                      AND get_doc_cnt (c.ap_id, 801) = 0
                THEN                                                  --#86747
                    raise_application_error (
                        -20000,
                           'В зверненні відсутній ініціативний документ «'
                        || c.ndt801_need
                        || '»');
                END IF;

                v_rpt_clob :=
                    tools.convertb2c (
                        get_rpt_blob_by_code ('ASSISTANCE_MESSAGE_R2')); --одна форма на відмову і на підтвердження

                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p1#',
                        COALESCE (
                            uss_person.api$sc_tools.get_pib (c.pd_sc),
                               '__________________________________________________\par'
                            || '\fs20                    (прізвище, ім’я, по батькові (за наявності) заявника/\par'
                            || '           законного представника / уповноваженого представника сім’ї) \fs24'));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p2#',
                        COALESCE (
                            c.pers_fact_addr,
                               '__________________________________________________\par'
                            || '\fs20                                         (місце проживання/перебування) \fs24\par'
                            || '__________________________________________________\par'
                            || '__________________________________________________'));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p3#',
                        COALESCE (
                            c.org_name,
                            '____________________________________________________________________________________\par'));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p4#',
                        COALESCE (
                            (CASE
                                 WHEN c.pd_st IN ('R1', 'WD', 'P')
                                 THEN
                                     '\ul надання \ul0 / відмову'
                                 WHEN c.pd_st IN ('PV', 'AV', 'V')
                                 THEN
                                     'надання / \ul відмову \ul0'
                             END),
                            'надання / відмову'));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p5#',
                        COALESCE (TO_CHAR (c.pd_dt, 'DD.MM.YYYY'),
                                  '_______________'));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p6#',
                        COALESCE (c.pd_num, '__________________________'));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p7#',
                        COALESCE (
                            uss_person.api$sc_tools.get_pib (c.pd_sc),
                               '____________________________________________________________________________________\par'
                            || '\fs20                               (прізвище, ім’я, по батькові (за наявності) особи, яка потребує надання соціальних послуг) \fs24'));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p8#',
                        COALESCE (
                            c.ss_org_name,
                               '____________________________________________________________________________________\par'
                            || '\fs20                                                               (найменування установи, закладу, організації, підприємства) \fs24'));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p91#',
                        (CASE c.ss_pay_need WHEN 'F' THEN v_check_mark END));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p92#',
                        (CASE c.ss_pay_need WHEN 'C' THEN v_check_mark END));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p93#',
                        (CASE c.ss_pay_need WHEN 'D' THEN v_check_mark END));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p10#',
                        COALESCE (
                            (CASE
                                 WHEN c.pd_st IN ('PV', 'AV', 'V')
                                 THEN
                                     c.reject_reason
                             END),
                               '_____________________________________________________________________\par'
                            || '____________________________________________________________________________________\par'
                            || '____________________________________________________________________________________\par'
                            || '____________________________________________________________________________________'));
                --#87820
                /*v_rpt_clob := REPLACE(v_rpt_clob, '#p11#', '_________________________\par' || '\fs20                       (посада) \fs24');
                v_rpt_clob := REPLACE(v_rpt_clob, '#p12#',
                                  coalesce(TRIM(c.appr_pib),
                                           '___________________________________\par' || '\fs20       (прізвище, ім’я, по батькові (за наявності)) \fs24'));*/
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p11#',
                        get_doc_atr_str (p_pd_id   => p_pd_id,
                                         p_ndt     => 851,
                                         p_nda     => 3085));
                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p12#',
                        COALESCE (
                               get_doc_atr_str (p_pd_id, 851, 2978)
                            || ' '
                            || get_doc_atr_str (p_pd_id, 851, 2979)
                            || ' '
                            || get_doc_atr_str (p_pd_id, 851, 2980),
                               '___________________________________\par'
                            || '\fs20       (прізвище, ім’я, по батькові (за наявності)) \fs24'));


                v_rpt_clob :=
                    REPLACE (
                        v_rpt_clob,
                        '#p13#',
                        COALESCE (TO_CHAR (c.appr_dt, 'DD.MM.YYYY'),
                                  '___  _________________ 20___'));

                v_rpt_blob := tools.convertc2b (v_rpt_clob);
            END LOOP;
        --assistance_message
        ELSIF p_ndt_id = 853
        THEN                                    --send_request_notification_r1
            FOR c
                IN (  SELECT pd.pd_ap,
                             pd.pd_st,
                             COALESCE (sc.sc_id, pc.pc_sc)
                                 AS pd_sc,
                             RTRIM (
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1874
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1875
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'обл. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1876
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'р-он. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1873
                                            THEN
                                                LTRIM (
                                                       COALESCE (
                                                           (SELECT k.kaot_full_name
                                                              FROM uss_ndi.v_ndi_katottg
                                                                   k
                                                             WHERE k.kaot_id =
                                                                   da.apda_val_id),
                                                           TRIM (
                                                               da.apda_val_string))
                                                    || ', ',
                                                    ', ')
                                        END)
                                 || COALESCE (
                                        MAX (
                                            CASE
                                                WHEN     d.apd_ndt = 801
                                                     AND da.apda_nda = 1879
                                                THEN
                                                    LTRIM (
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
                                                        || ', ',
                                                        ', ')
                                            END),
                                        MAX (
                                            CASE
                                                WHEN     d.apd_ndt = 801
                                                     AND da.apda_nda = 1878
                                                     AND TRIM (
                                                             da.apda_val_string)
                                                             IS NOT NULL
                                                THEN
                                                       TRIM (
                                                           da.apda_val_string)
                                                    || ', '
                                            END))
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1880
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'буд. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1881
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'корп. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1882
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'кв. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END),
                                 ', ')
                                 AS pers_fact_addr,
                             o.org_id,
                             o.org_name,
                             o.org_to,
                             a.ap_reg_dt,
                             a.ap_num,
                             a.com_org
                                 AS ap_org,
                             (SELECT LISTAGG (st.nst_name, ', ')
                                         WITHIN GROUP (ORDER BY st.nst_order)
                                FROM v_ap_service ss
                                     JOIN uss_ndi.v_ndi_service_type st
                                         ON st.nst_id = ss.aps_nst
                               WHERE     ss.aps_ap = pd.pd_ap
                                     AND ss.history_status = 'A')
                                 AS nst_name_list,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 10 THEN f.pde_val_string
                                 END)
                                 AS ss_pay_need,
                             lt.reg_trnsfr_dt,
                             lt.appr_pib,
                             /*MAX(CASE
                                   WHEN d.apd_ndt = 801 AND da.apda_nda = 1871 THEN
                                    da.apda_val_string
                                 END) AS p1871,
                             MAX(CASE
                                   WHEN d.apd_ndt = 802 AND da.apda_nda = 1948 THEN
                                    da.apda_val_string
                                 END) AS p1948,*/
                             MAX (CASE d.apd_ndt
                                      WHEN 803
                                      THEN
                                          (SELECT ndt_name
                                             FROM uss_ndi.v_ndi_document_type
                                            WHERE ndt_id = 803)
                                  END)
                                 AS ndt803_exist,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 32 THEN f.pde_val_string
                                 END)
                                 AS f32,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 33 THEN f.pde_val_string
                                 END)
                                 AS f33,
                             (CASE COUNT (
                                       CASE d.apd_ndt
                                           WHEN 801 THEN d.apd_id
                                       END)
                                  WHEN 0
                                  THEN
                                      (SELECT ndt_name
                                         FROM uss_ndi.v_ndi_document_type
                                        WHERE ndt_id = 801)
                              END)
                                 AS ndt801_need
                        FROM v_pc_decision pd
                             JOIN v_opfu o ON o.org_id = pd.com_org
                             JOIN v_appeal a
                                 ON a.ap_id = pd.pd_ap AND a.ap_tp = 'SS'
                             LEFT JOIN pd_features f
                                 ON     f.pde_pd = p_pd_id
                                    AND f.pde_nft IN (10, 32, 33)
                             LEFT JOIN v_pd_pay_method pm
                             JOIN uss_person.v_socialcard sc
                                 ON sc.sc_scc = pm.pdm_scc
                                 ON     pm.pdm_pd = p_pd_id
                                    AND pm.history_status = 'A'
                                    AND pm.pdm_is_actual = 'T'
                             LEFT JOIN v_personalcase pc
                                 ON pc.pc_id = pd.pd_pc AND sc.sc_id IS NULL
                             LEFT JOIN v_ap_person p
                             JOIN v_ap_document d
                                 ON     d.apd_app = p.app_id
                                    AND d.apd_ap = p.app_ap
                                    AND d.apd_ndt IN (801,            /*802,*/
                                                           803)
                                    AND d.history_status = 'A'
                             JOIN v_ap_document_attr da
                                 ON     da.apda_apd = d.apd_id
                                    AND da.apda_ap = d.apd_ap
                                    AND da.history_status = 'A'
                                 ON     p.app_ap = a.ap_id
                                    AND p.app_sc =
                                        COALESCE (sc.sc_id, pc.pc_sc)
                                    AND p.app_tp = 'Z'
                                    AND p.history_status = 'A'
                             JOIN
                             (SELECT MAX (t.reg_trnsfr_dt)    AS reg_trnsfr_dt,
                                     MAX (t.appr_pib)         AS appr_pib
                                FROM (SELECT FIRST_VALUE (
                                                 (CASE l.pdl_st
                                                      WHEN 'O.S' THEN h.hs_dt
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS reg_trnsfr_dt,
                                             FIRST_VALUE (
                                                 (CASE l.pdl_st
                                                      WHEN 'P' THEN u.wu_pib
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS appr_pib
                                        FROM v_pd_log l
                                             JOIN v_histsession h
                                                 ON h.hs_id = l.pdl_hs
                                             JOIN ikis_sysweb.v$all_users u
                                                 ON u.wu_id = h.hs_wu
                                       WHERE     l.pdl_pd = p_pd_id
                                             AND l.pdl_st IN ('O.S', 'P')) t)
                             lt
                                 ON 1 = 1
                       WHERE pd.pd_id = p_pd_id
                    GROUP BY pd.pd_ap,
                             pd.pd_st,
                             COALESCE (sc.sc_id, pc.pc_sc),
                             o.org_id,
                             o.org_name,
                             o.org_to,
                             a.ap_reg_dt,
                             a.ap_num,
                             a.com_org,
                             lt.reg_trnsfr_dt,
                             lt.appr_pib)
            LOOP
                --#77050 заборонено формування рішення при наявності документа «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803
                IF    c.ndt803_exist IS NOT NULL
                   OR get_doc_cnt (c.pd_ap, 803) > 0
                THEN
                    raise_application_error (
                        -20000,
                           'Звернення було створено на основі документа «'
                        || COALESCE (c.ndt803_exist, get_ndt_name (803))
                        || '», для якого відсутні друковані форми Рішення/Повідомлення');
                ELSIF     c.ndt801_need IS NOT NULL
                      AND get_doc_cnt (c.pd_ap, 801) = 0
                THEN                                                  --#86747
                    raise_application_error (
                        -20000,
                           'В зверненні відсутній ініціативний документ «'
                        || c.ndt801_need
                        || '»');
                ELSIF /*c.pd_st NOT IN ('PV', 'AV', 'V') AND (c.p1871 = 'T' OR c.p1948 = 'T')*/
                      --#77873 форма доступна тільки якщо замість рішення формується «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу»
                          c.f32 = 'T'
                      AND c.f33 = 'T'
                      AND c.ap_org = tools.getcurrorg                 --#79593
                THEN
                    v_rpt_clob :=
                        tools.convertb2c (
                            get_rpt_blob_by_code (
                                'SEND_REQUEST_NOTIFICATION_R1'));

                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p1#',
                            COALESCE (
                                CASE
                                    WHEN get_doc_atr_row (p_pd_id,
                                                          853,
                                                          '2998,2999,3000',
                                                          NULL)
                                             IS NOT NULL
                                    THEN
                                        get_doc_atr_row (p_pd_id,
                                                         853,
                                                         '2998,2999,3000')
                                END,                                  --#86997
                                uss_person.api$sc_tools.get_pib (c.pd_sc),
                                   '____________________________________________________\par'
                                || '\fs20            (прізвище, ім’я, по батькові (за наявності) заявника/\par'
                                || '                      законного представника / уповноваженого\par'
                                || '                                            представника сім’ї) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p2#',
                            COALESCE (
                                CASE
                                    WHEN get_doc_atr_row (p_pd_id,
                                                          853,
                                                          '3001,3002,3003',
                                                          NULL)
                                             IS NOT NULL
                                    THEN
                                           get_doc_atr_row (p_pd_id,
                                                            853,
                                                            '3001,3002,3003')
                                        || CASE
                                               WHEN get_doc_atr_str (p_pd_id,
                                                                     853,
                                                                     3004)
                                                        IS NOT NULL
                                               THEN
                                                      ' буд. '
                                                   || get_doc_atr_str (
                                                          p_pd_id,
                                                          853,
                                                          3004)
                                           END
                                        || CASE
                                               WHEN get_doc_atr_str (p_pd_id,
                                                                     853,
                                                                     3005)
                                                        IS NOT NULL
                                               THEN
                                                      ' корп. '
                                                   || get_doc_atr_str (
                                                          p_pd_id,
                                                          853,
                                                          3005)
                                           END
                                        || CASE
                                               WHEN get_doc_atr_str (p_pd_id,
                                                                     853,
                                                                     3006)
                                                        IS NOT NULL
                                               THEN
                                                      ' кв. '
                                                   || get_doc_atr_str (
                                                          p_pd_id,
                                                          853,
                                                          3006)
                                           END
                                END,                                  --#86997
                                c.pers_fact_addr,
                                   '____________________________________________________\par'
                                || '\fs20                              (Місце проживання/перебування) \fs24\par'
                                || '____________________________________________________\par'
                                || '____________________________________________________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p3#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id, 853, 3007), --#86997
                                c.org_name,
                                '____________________________________________________________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p31#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id, 853, 3007), --#86997
                                c.org_name,
                                   '________________\par'
                                || '_____________________________________________________________________________________\par'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p32#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id, 853, 3007), --#86997
                                c.org_name,
                                   '_____________________________________________\par'
                                || '_____________________________________________________________________________________\par'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p4#',
                            COALESCE (get_doc_atr_dt (p_pd_id, 853, 3008), --#86997
                                      TO_CHAR (c.ap_reg_dt, 'DD.MM.YYYY'),
                                      '______________________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p5#',
                            COALESCE (get_doc_atr_str (p_pd_id, 853, 3009), --#86997
                                      c.ap_num,
                                      '_____________'));

                    IF c.org_to > 31
                    THEN
                            SELECT MAX (
                                       CASE
                                           WHEN po.org_to IN (31, 34)
                                           THEN
                                               po.org_name
                                       END)
                              INTO v_str
                              FROM v_opfu po
                             WHERE po.org_st = 'A'
                        START WITH po.org_id =
                                   COALESCE (c.org_id, tools.getcurrorg)
                        CONNECT BY PRIOR po.org_org = po.org_id;
                    END IF;

                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p6#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id, 853, 3010), --#86997
                                v_str,
                                c.org_name,
                                '____________________________________________________________________________________\par'));

                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p7#',
                            COALESCE (
                                get_doc_atr_dt (p_pd_id, 853, 3011),  --#86997
                                TO_CHAR (c.reg_trnsfr_dt, 'DD.MM.YYYY'),
                                '____________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p8#',
                            COALESCE (
                                get_doc_atr_row (p_pd_id,
                                                 853,
                                                 '3012,3013,3014'),   --#86997
                                uss_person.api$sc_tools.get_pib (c.pd_sc),
                                   '______________________________________\par'
                                || '_____________________________________________________________________________________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p81#',
                            COALESCE (
                                get_doc_atr_row (p_pd_id,
                                                 853,
                                                 '3012,3013,3014'),   --#86997
                                uss_person.api$sc_tools.get_pib (c.pd_sc),
                                   '_______________________________________________________________________\par'
                                || '\fs20                                                  (прізвище, ім’я, по батькові (за наявності) отримувача соціальної(них) послуги(г) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p9#',
                            COALESCE (get_doc_atr_str (p_pd_id, 853, 3015),
                                      '_________'));
                    v_rpt_clob :=
                        REPLACE (v_rpt_clob,
                                 '#p10#',
                                 COALESCE (c.nst_name_list, '___________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p111#',
                            (CASE c.ss_pay_need
                                 WHEN 'F' THEN v_check_mark
                             END));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p112#',
                            (CASE c.ss_pay_need
                                 WHEN 'C' THEN v_check_mark
                             END));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p113#',
                            (CASE c.ss_pay_need
                                 WHEN 'D' THEN v_check_mark
                             END));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p12#',
                            (CASE c.ss_pay_need
                                 WHEN 'C'
                                 THEN
                                     '\ul платно \ul0 або з установленням диференційованої плати'
                                 WHEN 'D'
                                 THEN
                                     'платно або \ul з установленням диференційованої плати \ul0'
                                 ELSE
                                     'платно або з установленням диференційованої плати'
                             END));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p13#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id, 853, 3130),
                                   '__________________________\par'
                                || '\fs20 (посада) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p14#',
                            COALESCE (
                                get_doc_atr_row (p_pd_id,
                                                 853,
                                                 '3017,3018,3019'),
                                c.appr_pib,
                                   '____________________________________\par'
                                || '\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p15#',
                            COALESCE (
                                TO_CHAR (c.reg_trnsfr_dt, 'DD.MM.YYYY'),
                                '___  _________________ 20___'));

                    v_rpt_blob := tools.convertc2b (v_rpt_clob);
                ELSE
                    raise_application_error (
                        -20000,
                        'Формування обраної друкованої форми недоступно для поточного рішення!');
                END IF;
            END LOOP;
        --send_request_notification_r1
        ELSIF p_ndt_id = 854
        THEN                                            --placement_voucher_r1
            FOR c
                IN (  SELECT pd.pd_st,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 9 THEN f.pde_val_string
                                 END)
                                 AS ss_org_name, -- назва надавача інтернатної установи, якого було встановлено у рішенні на вкладці «Надавач»
                             RTRIM (
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1874
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1875
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'обл. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1876
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'р-он. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1873
                                            THEN
                                                LTRIM (
                                                       COALESCE (
                                                           (SELECT k.kaot_full_name
                                                              FROM uss_ndi.v_ndi_katottg
                                                                   k
                                                             WHERE k.kaot_id =
                                                                   da.apda_val_id),
                                                           TRIM (
                                                               da.apda_val_string))
                                                    || ', ',
                                                    ', ')
                                        END)
                                 || COALESCE (
                                        MAX (
                                            CASE
                                                WHEN     d.apd_ndt = 801
                                                     AND da.apda_nda = 1879
                                                THEN
                                                    LTRIM (
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
                                                        || ', ',
                                                        ', ')
                                            END),
                                        MAX (
                                            CASE
                                                WHEN     d.apd_ndt = 801
                                                     AND da.apda_nda = 1878
                                                     AND TRIM (
                                                             da.apda_val_string)
                                                             IS NOT NULL
                                                THEN
                                                       TRIM (
                                                           da.apda_val_string)
                                                    || ', '
                                            END))
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1880
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'буд. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1881
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'корп. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1882
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'кв. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END),
                                 ', ')
                                 AS pers_fact_addr, -- місце проживання/перебування отримувача
                             RTRIM (
                                    MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1886
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1887
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'обл. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1888
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'р-он. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1889
                                            THEN
                                                LTRIM (
                                                       COALESCE (
                                                           (SELECT k.kaot_full_name
                                                              FROM uss_ndi.v_ndi_katottg
                                                                   k
                                                             WHERE k.kaot_id =
                                                                   da.apda_val_id),
                                                           TRIM (
                                                               da.apda_val_string))
                                                    || ', ',
                                                    ', ')
                                        END)
                                 || COALESCE (
                                        MAX (
                                            CASE
                                                WHEN     d.apd_ndt = 801
                                                     AND da.apda_nda = 1891
                                                THEN
                                                    LTRIM (
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
                                                        || ', ',
                                                        ', ')
                                            END),
                                        MAX (
                                            CASE
                                                WHEN     d.apd_ndt = 801
                                                     AND da.apda_nda = 1890
                                                     AND TRIM (
                                                             da.apda_val_string)
                                                             IS NOT NULL
                                                THEN
                                                       TRIM (
                                                           da.apda_val_string)
                                                    || ', '
                                            END))
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1892
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'буд. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1893
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'корп. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END)
                                 || MAX (
                                        CASE
                                            WHEN     d.apd_ndt = 801
                                                 AND da.apda_nda = 1894
                                                 AND TRIM (
                                                         da.apda_val_string)
                                                         IS NOT NULL
                                            THEN
                                                   'кв. '
                                                || TRIM (da.apda_val_string)
                                                || ', '
                                        END),
                                 ', ')
                                 AS pers_reg_addr, -- зареєстроване місце проживання
                             COALESCE (sc.sc_id, pc.pc_sc)
                                 AS pd_sc,                        -- отримувач
                             MAX (
                                 CASE
                                     WHEN     d.apd_ndt IN (6, 7, 801)
                                          AND da.apda_nda IN (606, 607, 1899)
                                     THEN
                                         da.apda_val_dt
                                 END)
                                 AS app_brth_dt, -- дата народження отримувача
                             MAX (
                                 CASE
                                     WHEN     d.apd_ndt = 605
                                          AND da.apda_nda IN (666, 1790)
                                          AND da.apda_val_string IS NOT NULL
                                     THEN
                                         (SELECT dic_sname
                                            FROM uss_ndi.v_ddn_scy_group
                                           WHERE dic_value =
                                                 da.apda_val_string)
                                 END)
                                 AS dsblt_grp,           -- група інвалідності
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 10 THEN f.pde_val_string
                                 END)
                                 AS ss_pay_need, -- тип оплати відповідно до встановленого у рішенні (ставити символ «v» у відповідному квадратику)
                             o.org_name, -- назва органу ПФУ / органу СЗН, в якому проводиться виплата
                             MAX (
                                 CASE f.pde_nft WHEN 14 THEN f.pde_val_dt END)
                                 AS pass_start_dt,      -- cтрок дії путівки з
                             MAX (CASE f.pde_nft WHEN 13 THEN f.pde_val_dt END)
                                 AS pass_stop_dt,      -- cтрок дії путівки по
                             MAX (CASE f.pde_nft WHEN 12 THEN f.pde_val_dt END)
                                 AS term_start_dt,     -- термін перебування з
                             MAX (CASE f.pde_nft WHEN 11 THEN f.pde_val_dt END)
                                 AS term_stop_dt,     -- термін перебування по
                             lt.prep_pib,
                             lt.appr_pib,
                             lt.fnl_appr_pib,
                             lt.fnl_appr_dt,
                             MAX (CASE d.apd_ndt
                                      WHEN 803
                                      THEN
                                          (SELECT ndt_name
                                             FROM uss_ndi.v_ndi_document_type
                                            WHERE ndt_id = 803)
                                  END)
                                 AS ndt803_exist,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 32 THEN f.pde_val_string
                                 END)
                                 AS f32,
                             MAX (
                                 CASE f.pde_nft
                                     WHEN 33 THEN f.pde_val_string
                                 END)
                                 AS f33,
                             (CASE COUNT (
                                       CASE d.apd_ndt
                                           WHEN 801 THEN d.apd_id
                                       END)
                                  WHEN 0
                                  THEN
                                      (SELECT ndt_name
                                         FROM uss_ndi.v_ndi_document_type
                                        WHERE ndt_id = 801)
                              END)
                                 AS ndt801_need,
                             a.ap_id
                        FROM v_pc_decision pd
                             JOIN v_opfu o ON o.org_id = pd.com_org
                             JOIN v_appeal a
                                 ON a.ap_id = pd.pd_ap AND a.ap_tp = 'SS'
                             LEFT JOIN v_pd_pay_method pm
                             JOIN uss_person.v_socialcard sc
                                 ON sc.sc_scc = pm.pdm_scc
                                 ON     pm.pdm_pd = p_pd_id
                                    AND pm.history_status = 'A'
                                    AND pm.pdm_is_actual = 'T'
                             LEFT JOIN v_personalcase pc
                                 ON pc.pc_id = pd.pd_pc AND sc.sc_id IS NULL
                             LEFT JOIN pd_features f
                                 ON     f.pde_pd = p_pd_id
                                    AND f.pde_nft IN (9,
                                                      10,
                                                      11,
                                                      12,
                                                      13,
                                                      14,
                                                      32,
                                                      33)
                             LEFT JOIN v_ap_person p
                             JOIN v_ap_document d
                                 ON     d.apd_app = p.app_id
                                    AND d.apd_ap = p.app_ap
                                    AND d.apd_ndt IN (6,
                                                      7,
                                                      605,
                                                      801,
                                                      802,
                                                      803)
                                    AND d.history_status = 'A'
                             JOIN v_ap_document_attr da
                                 ON     da.apda_apd = d.apd_id
                                    AND da.apda_ap = d.apd_ap
                                    AND da.history_status = 'A'
                                 ON     p.app_ap = a.ap_id
                                    AND p.app_sc =
                                        COALESCE (sc.sc_id, pc.pc_sc)
                                    AND p.app_tp = 'Z'
                                    AND p.history_status = 'A'
                             JOIN
                             (SELECT MAX (t.prep_pib)         AS prep_pib,
                                     MAX (t.appr_pib)         AS appr_pib,
                                     MAX (t.fnl_appr_pib)     AS fnl_appr_pib,
                                     MAX (t.fnl_appr_dt)      AS fnl_appr_dt
                                FROM (SELECT FIRST_VALUE (
                                                 (CASE
                                                      WHEN     l.pdl_st_old =
                                                               'O.R0'
                                                           AND l.pdl_st =
                                                               'O.R2'
                                                      THEN
                                                          u.wu_pib
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS prep_pib,
                                             FIRST_VALUE (
                                                 (CASE
                                                      WHEN     l.pdl_st_old =
                                                               'O.R2'
                                                           AND l.pdl_st =
                                                               'O.WD'
                                                      THEN
                                                          u.wu_pib
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS appr_pib,
                                             FIRST_VALUE (
                                                 (CASE
                                                      WHEN     l.pdl_st_old =
                                                               'O.WD'
                                                           AND l.pdl_st = 'O.P'
                                                      THEN
                                                          u.wu_pib
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS fnl_appr_pib,
                                             FIRST_VALUE (
                                                 (CASE l.pdl_st
                                                      WHEN 'O.P' THEN h.hs_dt
                                                  END) IGNORE NULLS)
                                                 OVER (ORDER BY h.hs_dt DESC)
                                                 AS fnl_appr_dt
                                        FROM v_pd_log l
                                             JOIN v_histsession h
                                                 ON h.hs_id = l.pdl_hs
                                             JOIN ikis_sysweb.v$all_users u
                                                 ON u.wu_id = h.hs_wu
                                       WHERE     l.pdl_pd = p_pd_id
                                             AND l.pdl_st IN
                                                     ('O.R2', 'O.WD', 'O.P')) t)
                             lt
                                 ON 1 = 1
                       WHERE pd.pd_id = p_pd_id
                    GROUP BY pd.pd_st,
                             COALESCE (sc.sc_id, pc.pc_sc),
                             o.org_name,
                             lt.prep_pib,
                             lt.appr_pib,
                             lt.fnl_appr_pib,
                             lt.fnl_appr_dt,
                             a.com_org,
                             a.ap_id)
            LOOP
                --#77050 заборонено формування рішення при наявності документа «Акт про надання соціальних послуг екстрено (кризово)» ndt_id=803
                IF    c.ndt803_exist IS NOT NULL
                   OR get_doc_cnt (c.ap_id, 803) > 0
                THEN
                    raise_application_error (
                        -20000,
                           'Звернення було створено на основі документа «'
                        || COALESCE (c.ndt803_exist, get_ndt_name (803))
                        || '», для якого відсутні друковані форми Рішення/Повідомлення');
                ELSIF     c.ndt801_need IS NOT NULL
                      AND get_doc_cnt (c.ap_id, 801) = 0
                THEN                                                  --#86747
                    raise_application_error (
                        -20000,
                           'В зверненні відсутній ініціативний документ «'
                        || c.ndt801_need
                        || '»');
                ELSIF           /*c.pd_st IN ('O.R0', 'O.R2', 'O.WD', 'O.P')*/
                      --#77873 форма доступна тільки у рішеннях про надання СП (SS) в зверненнях, які знаходяться у статусах O.R0 / O.R2 / O.WD / O.P
                         (c.f32 = 'T' AND COALESCE (c.f33, 'F') = 'F')
                      OR (    c.pd_st IN ('O.R0',
                                          'O.R2',
                                          'O.WD',
                                          'O.P')
                          AND tools.getcurrorgto IN (31, 34))         --#79593
                THEN
                    v_rpt_clob :=
                        tools.convertb2c (
                            get_rpt_blob_by_code ('PLACEMENT_VOUCHER_R1'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p1#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id   => p_pd_id,
                                                 p_ndt     => 854,
                                                 p_nda     => 3021),  --#86997
                                c.ss_org_name,
                                   ' _____________________________________________________________________________________\par'
                                || '\fs20                                                                              (найменування інтернатної установи/закладу) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p2#',
                            COALESCE (
                                CASE
                                    WHEN get_doc_atr_row (
                                             p_pd_id   => p_pd_id,
                                             p_ndt     => 854,
                                             p_nda     =>
                                                 '3032,3033,3034,3035,3036,3037',
                                             dlmt      => NULL)
                                             IS NOT NULL
                                    THEN
                                           get_doc_atr_row (
                                               p_pd_id   => p_pd_id,
                                               p_ndt     => 854,
                                               p_nda     => '3032,3033,3034')
                                        || CASE
                                               WHEN get_doc_atr_str (
                                                        p_pd_id   => p_pd_id,
                                                        p_ndt     => 854,
                                                        p_nda     => 3035)
                                                        IS NOT NULL
                                               THEN
                                                      ' буд. '
                                                   || get_doc_atr_str (
                                                          p_pd_id   => p_pd_id,
                                                          p_ndt     => 854,
                                                          p_nda     => 3035)
                                           END
                                        || CASE
                                               WHEN get_doc_atr_str (
                                                        p_pd_id   => p_pd_id,
                                                        p_ndt     => 854,
                                                        p_nda     => 3036)
                                                        IS NOT NULL
                                               THEN
                                                      ' корп. '
                                                   || get_doc_atr_str (
                                                          p_pd_id   => p_pd_id,
                                                          p_ndt     => 854,
                                                          p_nda     => 3036)
                                           END
                                        || CASE
                                               WHEN get_doc_atr_str (
                                                        p_pd_id   => p_pd_id,
                                                        p_ndt     => 854,
                                                        p_nda     => 3037)
                                                        IS NOT NULL
                                               THEN
                                                      ' кв. '
                                                   || get_doc_atr_str (
                                                          p_pd_id   => p_pd_id,
                                                          p_ndt     => 854,
                                                          p_nda     => 3037)
                                           END
                                END,                                  --#86997
                                c.pers_fact_addr,
                                   '___________________________________________\par'
                                || '_________________________________________________________________________________ '));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p3#',
                            COALESCE (
                                CASE
                                    WHEN get_doc_atr_row (
                                             p_pd_id   => p_pd_id,
                                             p_ndt     => 854,
                                             p_nda     =>
                                                 '3038,3039,3040,3041,3042,3043',
                                             dlmt      => NULL)
                                             IS NOT NULL
                                    THEN
                                           get_doc_atr_row (
                                               p_pd_id   => p_pd_id,
                                               p_ndt     => 854,
                                               p_nda     => '3038,3039,3040')
                                        || CASE
                                               WHEN get_doc_atr_str (
                                                        p_pd_id   => p_pd_id,
                                                        p_ndt     => 854,
                                                        p_nda     => 3041)
                                                        IS NOT NULL
                                               THEN
                                                      ' буд. '
                                                   || get_doc_atr_str (
                                                          p_pd_id   => p_pd_id,
                                                          p_ndt     => 854,
                                                          p_nda     => 3041)
                                           END
                                        || CASE
                                               WHEN get_doc_atr_str (
                                                        p_pd_id   => p_pd_id,
                                                        p_ndt     => 854,
                                                        p_nda     => 3042)
                                                        IS NOT NULL
                                               THEN
                                                      ' корп. '
                                                   || get_doc_atr_str (
                                                          p_pd_id   => p_pd_id,
                                                          p_ndt     => 854,
                                                          p_nda     => 3042)
                                           END
                                        || CASE
                                               WHEN get_doc_atr_str (
                                                        p_pd_id   => p_pd_id,
                                                        p_ndt     => 854,
                                                        p_nda     => 3043)
                                                        IS NOT NULL
                                               THEN
                                                      ' кв. '
                                                   || get_doc_atr_str (
                                                          p_pd_id   => p_pd_id,
                                                          p_ndt     => 854,
                                                          p_nda     => 3043)
                                           END
                                END,                                  --#86997
                                c.pers_reg_addr,
                                '_______________________________________________________ '));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p4#',
                            COALESCE (
                                CASE
                                    WHEN get_doc_atr_row (
                                             p_pd_id   => p_pd_id,
                                             p_ndt     => 854,
                                             p_nda     => '3022,3023,3024',
                                             dlmt      => NULL)
                                             IS NOT NULL
                                    THEN
                                        get_doc_atr_row (
                                            p_pd_id   => p_pd_id,
                                            p_ndt     => 854,
                                            p_nda     => '3022,3023,3024')
                                END,                                  --#86997
                                uss_person.api$sc_tools.get_pib (c.pd_sc),
                                   '____________________________________________________________________________________ ,\par'
                                || '\fs20                                                        (прізвище, ім’я, по батькові (за наявності) особи, яка направляється) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p5#',
                            COALESCE (
                                get_doc_atr_dt (p_pd_id   => p_pd_id,
                                                p_ndt     => 854,
                                                p_nda     => 3025),   --#86997
                                TO_CHAR (c.app_brth_dt, 'DD.MM.YYYY'),
                                '«___» _____________________  ________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p6#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id   => p_pd_id,
                                                 p_ndt     => 854,
                                                 p_nda     => 3026),  --#86997
                                c.dsblt_grp,
                                '________________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p61#',
                            (CASE
                                 WHEN     c.dsblt_grp IS NULL
                                      AND c.app_brth_dt IS NULL
                                 THEN
                                     '\fs20                                                                                                                                   (за наявності) \fs24'
                                 WHEN     c.dsblt_grp IS NULL
                                      AND c.app_brth_dt IS NOT NULL
                                 THEN
                                     '\fs20                                                                   (за наявності) \fs24'
                             END));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p71#',
                            (CASE c.ss_pay_need
                                 WHEN 'F' THEN v_check_mark
                             END));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p72#',
                            (CASE c.ss_pay_need
                                 WHEN 'C' THEN v_check_mark
                             END));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p73#',
                            (CASE c.ss_pay_need
                                 WHEN 'D' THEN v_check_mark
                             END));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p8#',
                            COALESCE (get_doc_atr_sum (p_pd_id, 854, 3028),
                                      '__________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p9#',
                            COALESCE (get_doc_atr_sum (p_pd_id, 854, 3029),
                                      '___________'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p10#',
                            'пенсії / \ul державної соціальної допомоги \ul0');
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p11#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id, 854, 3031), --#86997
                                c.org_name,
                                   '____________________________________________________________________________________ .\par'
                                || '\fs20 (найменування органу Пенсійного фонду України / структурного підрозділу з питань соціального захисту населення\par'
                                || '                       районної, районної у місті Києві / Севастополі державної адміністрації, виконавчого органу міської,\par'
                                || '                                                районної у місті (крім міст Києва та Севастополя) ради (у разі її утворення) \fs24'));
                    v_rpt_clob :=
                        REPLACE (v_rpt_clob,
                                 '#p12#',
                                 COALESCE (NULL, '______'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p13#',
                            COALESCE (
                                get_doc_atr_dt (p_pd_id, 854, 3044),
                                TO_CHAR (c.pass_start_dt, 'DD.MM.YYYY'),
                                '«___» _____________  _______'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p14#',
                            COALESCE (get_doc_atr_dt (p_pd_id, 854, 3045),
                                      TO_CHAR (c.pass_stop_dt, 'DD.MM.YYYY'),
                                      '«___» _____________  _______'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p141#',
                            (CASE
                                 WHEN    c.pass_start_dt IS NULL
                                      OR c.pass_stop_dt IS NULL
                                 THEN
                                     '\par                                                                              (не може бути більше ніж 14 календарних днів) \fs24'
                             END));
                    --постійно, тимчасово
                    p142 := get_doc_atr_str (p_pd_id, 854, 3046);

                    SELECT LISTAGG (
                               CASE p142
                                   WHEN dic_value
                                   THEN
                                       '\ul ' || dic_sname || '\ul0 '
                                   ELSE
                                       dic_sname
                               END,
                               ' / ')
                           WITHIN GROUP (ORDER BY dic_srtordr)
                      INTO p142
                      FROM uss_ndi.v_ddn_rnsp_stay t;

                    v_rpt_clob := REPLACE (v_rpt_clob, '#p142#', p142);

                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p15#',
                            COALESCE (
                                get_doc_atr_dt (p_pd_id, 854, 3047),
                                TO_CHAR (c.term_start_dt, 'DD.MM.YYYY'),
                                '«___»_________\par_______'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p16#',
                            COALESCE (get_doc_atr_dt (p_pd_id, 854, 3048),
                                      TO_CHAR (c.term_stop_dt, 'DD.MM.YYYY'),
                                      '«___» ____________  ____'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p17#',
                            COALESCE (get_doc_atr_dt (p_pd_id, 854, 3049),
                                      TO_CHAR (SYSDATE, 'DD.MM.YYYY'),
                                      '___  _______________  _______'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p18#',
                            COALESCE (
                                NULL,
                                '____________________________\par\fs20                         (посада) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p19#',
                            COALESCE (
                                c.prep_pib,
                                '______________________________________\par\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p20#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id   => p_pd_id,
                                                 p_ndt     => 854,
                                                 p_nda     => 3050),
                                '____________________________\par\fs20                         (посада) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p21#',
                            COALESCE (
                                get_doc_atr_row (p_pd_id,
                                                 854,
                                                 '3051, 3052, 3053'),
                                c.appr_pib,
                                '______________________________________\par\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p22#',
                            COALESCE (
                                get_doc_atr_str (p_pd_id   => p_pd_id,
                                                 p_ndt     => 854,
                                                 p_nda     => 3055),
                                   '_______________________________\par\fs20 (посада керівника структурного підрозділу\par'
                                || 'з питань соціального захисту населення) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p23#',
                            COALESCE (
                                get_doc_atr_row (p_pd_id,
                                                 854,
                                                 '3056, 3057, 3058'),
                                c.fnl_appr_pib,
                                '______________________________________\par\fs20 (прізвище, ім’я, по батькові (за наявності)) \fs24'));
                    v_rpt_clob :=
                        REPLACE (
                            v_rpt_clob,
                            '#p24#',
                            COALESCE (TO_CHAR (c.fnl_appr_dt, 'DD.MM.YYYY'),
                                      '___  ___________________ 20___'));

                    v_rpt_blob := tools.convertc2b (v_rpt_clob);
                ELSE
                    /*SELECT listagg('"' || dic_sname || '"', ', ') within GROUP(ORDER BY dic_srtordr)
                      INTO v_str
                      FROM uss_ndi.v_ddn_pd_st
                     WHERE dic_code IN ('O.R0', 'O.R2', 'O.WD', 'O.P');
                    raise_application_error(-20000,
                                            'Формування обраної друкованої форми доступно тільки для рішень в статусах ' || v_str);*/
                    raise_application_error (
                        -20000,
                        'Формування обраної друкованої форми недоступно для поточного рішення!');
                END IF;
            END LOOP;
        --placement_voucher_r1
        END IF;

        RETURN v_rpt_blob;
    END;

    FUNCTION reg_pay_order_report (p_po_id IN NUMBER)
        RETURN DECIMAL
    IS
        v_base_sql   VARCHAR2 (4000);
        p_jbr_id     DECIMAL;
    BEGIN
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.reg_pay_order_report',
            action_name   => 'p_po_id=' || TO_CHAR (p_po_id));

        --#71102 набір документів які необхідно сформувати залежить від типу виплати в відомості
        FOR pr_cur
            IN (SELECT p.po_pay_dt     AS pr_month,
                       NULL            AS pr_start_dt,
                       NULL            AS pr_stop_dt,
                       NULL            AS pr_start_day,
                       NULL            AS pr_stop_day,
                       r.pe_pay_tp     AS pr_pay_tp,
                       p.po_st         AS pr_st,
                       pc.npc_name,
                       pc.npc_code,
                       r.com_org,
                       o.org_name,
                       o.org_code
                  FROM v_Pay_Order  p
                       JOIN v_payroll_reestr r ON (r.pe_po = p.po_id)
                       JOIN uss_ndi.v_ndi_payment_codes pc
                           ON pc.npc_id = r.pe_npc
                       JOIN v_opfu o ON o.org_id = r.com_org
                 WHERE po_id = p_po_id AND ROWNUM = 1)
        LOOP
            IF pr_cur.pr_pay_tp = '2'             --виплатна відомість на банк
            THEN
                --ініціалізація завдання на підготовку звіту
                p_jbr_id :=
                    rdm$rtfl.initreport (get_rt_by_code ('PAY_ORDER_R3'));

                rdm$rtfl.addparam (p_jbr_id, 'org_name1', pr_cur.org_name);
                rdm$rtfl.addparam (p_jbr_id, 'inform_type', pr_cur.npc_name);
                rdm$rtfl.addparam (p_jbr_id,
                                   'inform_type1',
                                   UPPER (pr_cur.npc_name));
                rdm$rtfl.addparam (p_jbr_id,
                                   'inform_type_num',
                                   pr_cur.npc_code);
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'supl_desc_dt',
                       UPPER (
                           TO_CHAR (pr_cur.pr_month,
                                    'MONTH',
                                    'NLS_DATE_LANGUAGE = UKRAINIAN'))
                    || ' '
                    || TO_CHAR (pr_cur.pr_month, 'YYYY'));

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'main_ds3',
                       q'[SELECT (CASE grp_lvl
         WHEN 0 THEN
          nb_name
         ELSE
          'РАЗОМ:'
       END) AS c1,
       (CASE grp_lvl
         WHEN 0 THEN
          '1'
       END) AS c2,
       c3,
       c4
  FROM (SELECT prs_nb,
               TRIM(nb_mfo) || ' ' || TRIM(nb_name) AS nb_name,
               COUNT(DISTINCT(prs_pc)) AS c3,
               to_char(SUM(prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c4,
               (GROUPING(prs_nb) + GROUPING(TRIM(nb_mfo) || ' ' || TRIM(nb_name))) AS grp_lvl
          FROM uss_esr.v_payroll_reestr r
          join uss_esr.v_pr_sheet s on (r.pe_pr = s.prs_pr and r.pe_nb = s.prs_nb and r.pe_pay_dt = s.prs_pay_dt)
          JOIN uss_ndi.v_ndi_bank ON nb_id = prs_nb
         WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
           AND coalesce(prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU')
         GROUP BY ROLLUP(TRIM(nb_mfo) || ' ' || TRIM(nb_name), prs_nb))
 WHERE grp_lvl IN (0, 1)
 ORDER BY nb_name, grp_lvl]');

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'total_ds3',
                       q'[SELECT COUNT(DISTINCT(prs_pc)) AS c1, to_char(SUM(prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c2
  FROM uss_esr.v_payroll_reestr r
  join uss_esr.v_pr_sheet s on (r.pe_pr = s.prs_pr and r.pe_nb = s.prs_nb and r.pe_pay_dt = s.prs_pay_dt)
  JOIN uss_ndi.v_ndi_bank ON nb_id = prs_nb
 WHERE pe_po = ]'
                    || p_po_id
                    || q'[
   AND coalesce(prs_st, 'NULL') != 'PP'
   and prs_tp not in ('ABU', 'ADV', 'AUU')]');

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'ds',
                       q'[SELECT pst.nb_id,
             coalesce((CASE WHEN TRIM(pst.bank_name) IS NOT NULL THEN TRIM(pst.bank_name) || ' Код філії ' || TRIM(pst.nb_mfo) END), '____________________________________________________________________') AS bank_name,
             coalesce((CASE WHEN TRIM(pst.bank_name) IS NOT NULL THEN 'в ' || TRIM(pst.bank_name) || ' Код філії ' || TRIM(pst.nb_mfo) END), '____________________________________________________________________') AS bank_name1,
             (CASE WHEN TRIM(pst.bank_name) IS NULL THEN ']'
                    || '(найменування уповноваженого банку)'
                    || q'[' END) AS bank_name_lbl,
             coalesce(TRIM(o.org_name), '________________________________________________________________________________
      ________________________________________________________________________________') AS org_name,
             (CASE WHEN TRIM(o.org_name) IS NULL THEN ']'
                    || '(найменування органу Пенсійного фонду або органу соціального захисту населення)'
                    || q'[' END) AS org_name_lbl,
             coalesce(TRIM(bp.nbg_sname), '________________________________________________________________') AS nbg_name,
             (CASE WHEN TRIM(bp.nbg_sname) IS NULL THEN ']'
                    || '(назва органу, що здійснює фінансування)'
                    || q'[' END) AS nbg_name_lbl,
             /*coalesce(to_char(p.pr_start_dt, 'DD.MM.YYYY'), '______________________________') AS start_dt,
             coalesce(to_char(p.pr_stop_dt, 'DD.MM.YYYY'), '____________________________________') AS stop_dt,
             */
             coalesce(to_char(pst.pers_cnt), '___________') AS pers_cnt,
             coalesce((to_char(pst.tot_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') || (CASE WHEN pst.tot_sum IS NOT NULL THEN ' ' || uss_esr.dnet$payment_reports.sum_in_words(pst.tot_sum, 'гривня', 'гривні', 'гривень', 'коп.') END)), '____________') AS tot_sum,
             pst1.tot_lines AS total_lines, --дата виплати, кількість поточних рахунків, загальна сума по ос.рахунках на обрану дату
             '1' AS list_num,
             ROW_NUMBER() OVER (ORDER BY pst.bank_name) AS rn
        FROM uss_esr.v_pay_order p
        JOIN (SELECT b.nb_id,
                     b.nb_name AS bank_name,
                     b.nb_mfo,
                     COUNT(DISTINCT(ps.prs_pc)) AS pers_cnt,
                     SUM(ps.prs_sum) AS tot_sum,
                     --MAX(ps.prs_npt) AS prs_npt #85222
                     MAX((SELECT MAX(d.prsd_npt) FROM uss_esr.v_pr_sheet_detail d WHERE d.prsd_prs = ps.prs_id AND d.prsd_tp in ('PWI', 'RDN'))) AS prs_npt
                FROM uss_esr.v_payroll_reestr r
                join uss_esr.v_pr_sheet ps on (r.pe_pr = ps.prs_pr and r.pe_nb = ps.prs_nb and r.pe_pay_dt = ps.prs_pay_dt)
                JOIN uss_ndi.v_ndi_bank b ON b.nb_id = ps.prs_nb
               WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
                 AND coalesce(ps.prs_st, 'NULL') != 'PP'
                 and ps.prs_tp not in ('ABU', 'ADV', 'AUU')
              GROUP BY b.nb_id, b.nb_name, b.nb_mfo) pst ON 1 = 1
        JOIN (SELECT prs_nb, listagg(tot_lines, '\par ') within GROUP(ORDER BY tot_lines) AS tot_lines
                FROM (SELECT ps.prs_nb,
                             to_char(ps.prs_pay_dt, 'MM.YYYY') || ', ' || COUNT(DISTINCT(ps.prs_pc)) || ', ' ||
                             to_char(SUM(ps.prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_lines
                        FROM uss_esr.v_payroll_reestr r
                        join uss_esr.v_pr_sheet ps on (r.pe_pr = ps.prs_pr and r.pe_nb = ps.prs_nb and r.pe_pay_dt = ps.prs_pay_dt)
                       WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
                         AND coalesce(ps.prs_st, 'NULL') != 'PP'
                         and ps.prs_tp not in ('ABU', 'ADV', 'AUU')
                       GROUP BY ps.prs_nb, to_char(ps.prs_pay_dt, 'MM.YYYY'))
               GROUP BY prs_nb) pst1 ON pst1.prs_nb = pst.nb_id
        LEFT JOIN v_opfu o ON o.org_id = p.com_org_src
        LEFT JOIN uss_ndi.v_ndi_npt_config nc
        JOIN uss_ndi.v_ndi_service_type st ON st.nst_id = nc.nptc_nst
        JOIN uss_ndi.v_ndi_budget_program bp ON bp.nbg_id = st.nst_nbg ON nc.nptc_npt = pst.prs_npt
       WHERE p.po_id = ]'
                    || p_po_id);

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'main_ds1',
                       q'[SELECT c1 AS c1, --Дата виплати
             TRIM(nb_mfo) AS c2, --Номер установи (філії) банку
             1 AS c3, --Номер списку
             c4,
             c5
        FROM (SELECT ps.prs_nb,
                     to_char(prs_pay_dt, 'MM.YYYY') as c1,
                     COUNT(DISTINCT(ps.prs_pc)) AS c4, --Кількість одержувачів
                     to_char(SUM(ps.prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c5 --Сума, гривень
                FROM uss_esr.v_payroll_reestr r
                join uss_esr.v_pr_sheet ps on (r.pe_pr = ps.prs_pr and r.pe_nb = ps.prs_nb and r.pe_pay_dt = ps.prs_pay_dt)
               WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
                 AND coalesce(ps.prs_st, 'NULL') != 'PP'
                 and prs_tp not in ('ABU', 'ADV', 'AUU')
               GROUP BY ps.prs_nb, to_char(prs_pay_dt, 'MM.YYYY'))
        JOIN uss_ndi.v_ndi_bank ON nb_id = prs_nb
       WHERE 1 = 1]');

                rdm$rtfl.addrelation (p_jbr_id,
                                      'ds',
                                      'nb_id',
                                      'main_ds1',
                                      'prs_nb');

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'main_ds',
                       q'[SELECT c1, --Дата виплати
       row_number() over(ORDER BY c1_ord, c4) AS c2, --№ п/п
       c3, --Номер поточного рахунку
       c4, --Прізвище ім’я та по батькові
       c5, --Сума
       c6, --Номер ЕОС
       c7, --РНОКПП
       NULL AS c8, --Позначка про перебування на обліку внутрішньо переміщених осіб
       NULL AS c9 --Причина незарахування
  FROM (SELECT ps.prs_nb,
               to_char(ps.prs_pay_dt, 'MM.YYYY') AS c1, --Дата виплати
               to_char(ps.prs_pay_dt, 'YYYYMMDD') AS c1_ord, --Дата виплати для сортування
               ps.prs_account AS c3, --Номер поточного рахунку
               ps.prs_ln || ' ' || ps.prs_fn || ' ' || ps.prs_mn AS c4, --Прізвище ім’я та по батькові
               to_char(SUM(ps.prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c5, --Сума
               ps.prs_pc_num AS c6, --Номер ЕОС
               ps.prs_inn AS c7 --РНОКПП
          FROM uss_esr.v_payroll_reestr r
          join uss_esr.v_pr_sheet ps on (r.pe_pr = ps.prs_pr and r.pe_nb = ps.prs_nb and r.pe_pay_dt = ps.prs_pay_dt)
         WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
           AND coalesce(ps.prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU')
         GROUP BY ps.prs_nb, ps.prs_pay_dt, ps.prs_account, ps.prs_ln || ' ' || ps.prs_fn || ' ' || ps.prs_mn, ps.prs_pc_num, ps.prs_inn)
 WHERE 1 = 1]');

                rdm$rtfl.addrelation (p_jbr_id,
                                      'ds',
                                      'nb_id',
                                      'main_ds',
                                      'prs_nb');

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'main_ds2',
                       q'[SELECT c1, --Дата виплати
       row_number() over(ORDER BY c1, c3) AS c2, --№ п/п
       c3, --Номер поточного рахунку
       c4, --Прізвище ім’я та по батькові
       c5, --Сума
       c6, --Номер ЕОС
       c7, --РНОКПП
       NULL AS c8, --Позначка про перебування на обліку внутрішньо переміщених осіб
       NULL AS c9 --Причина незарахування
  FROM (SELECT ps.prs_nb,
               to_char(ps.prs_pay_dt, 'DD.MM.YYYY') AS c1, --Дата виплати
               ps.prs_account AS c3, --Номер поточного рахунку
               ps.prs_ln || ' ' || ps.prs_fn || ' ' || ps.prs_mn AS c4, --Прізвище ім’я та по батькові
               to_char(SUM(ps.prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c5, --Сума
               ps.prs_pc_num AS c6, --Номер ЕОС
               ps.prs_inn AS c7 --РНОКПП
          FROM uss_esr.v_payroll_reestr r
          join uss_esr.v_pr_sheet ps on (r.pe_pr = ps.prs_pr and r.pe_nb = ps.prs_nb and r.pe_pay_dt = ps.prs_pay_dt)
         WHEREr.pe_po = ]'
                    || p_po_id
                    || q'[
           AND coalesce(ps.prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU')
         GROUP BY ps.prs_nb, ps.prs_pay_dt, ps.prs_account, ps.prs_ln || ' ' || ps.prs_fn || ' ' || ps.prs_mn, ps.prs_pc_num, ps.prs_inn)
 WHERE 1 = 1]');

                rdm$rtfl.addrelation (p_jbr_id,
                                      'ds',
                                      'nb_id',
                                      'main_ds2',
                                      'prs_nb');
            ELSIF pr_cur.pr_pay_tp = '1'         --виплатна відомість на пошту
            THEN
                --ініціалізація завдання на підготовку звіту
                p_jbr_id :=
                    rdm$rtfl.initreport (
                        get_rt_by_code ('POST_PAY_ORDER_R1'));


                /* rdm$rtfl.addparam(p_jbr_id, 'period_start', TRIM(to_char(pr_cur.pr_start_day) || ' ' || get_month_name(pr_cur.pr_start_dt)));
                 rdm$rtfl.addparam(p_jbr_id, 'period_stop', TRIM(to_char(pr_cur.pr_stop_day) || ' ' || get_month_name(pr_cur.pr_stop_dt)));*/
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'period_year',
                    COALESCE (TO_CHAR (pr_cur.pr_month, 'YY'), '__'));
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'org_name',
                    COALESCE (
                        pr_cur.org_name,
                        '____________________________________________________________'));
                rdm$rtfl.addparam (p_jbr_id, 'org_name1', pr_cur.org_name);
                rdm$rtfl.addparam (p_jbr_id, 'org_code', pr_cur.org_code);
                rdm$rtfl.addparam (p_jbr_id, 'inform_type', pr_cur.npc_name);
                rdm$rtfl.addparam (p_jbr_id,
                                   'inform_type1',
                                   UPPER (pr_cur.npc_name));
                rdm$rtfl.addparam (p_jbr_id,
                                   'inform_type_num',
                                   pr_cur.npc_code);
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'supl_desc_dt',
                       UPPER (
                           TO_CHAR (pr_cur.pr_month,
                                    'MONTH',
                                    'NLS_DATE_LANGUAGE = UKRAINIAN'))
                    || ' '
                    || TO_CHAR (pr_cur.pr_month, 'YYYY'));
                rdm$rtfl.addparam (
                    p_jbr_id,
                    'fnl_stmnt_dt',
                       UPPER (
                           TO_CHAR (pr_cur.pr_month,
                                    'MONTH',
                                    'NLS_DATE_LANGUAGE = UKRAINIAN'))
                    || ' МІСЯЦЬ '
                    || TO_CHAR (pr_cur.pr_month, 'YYYY')
                    || ' РІК');

                v_base_sql :=
                       q'[FROM uss_esr.v_payroll_reestr r
                           join uss_esr.v_pr_sheet s on (r.pe_pr = s.prs_pr and r.pe_nb = s.prs_nb and r.pe_pay_dt = s.prs_pay_dt)
          JOIN uss_ndi.v_ndi_post_office po ON po.npo_index = s.prs_index
                                           AND po.history_status = 'A'
                                           AND po.npo_kaot = nvl(s.prs_kaot, po.npo_kaot)
                                           /*AND po.npo_org = ]'
                    || pr_cur.com_org
                    || q'[*/
          left JOIN uss_ndi.v_ndi_comm_node cn ON cn.ncn_id = po.npo_ncn
                                         AND cn.history_status = 'A'
                                         AND substr(to_char(coalesce(cn.ncn_org, ]'
                    || TO_CHAR (pr_cur.com_org)
                    || ')), 1, 3) = substr(to_char('
                    || TO_CHAR (pr_cur.com_org)
                    || '), 1, 3)
         WHERE r.pe_po = '
                    || p_po_id
                    || q'[
           AND coalesce(s.prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU')]';

                --#71180 cторінки супровідного опису формуються по ndi_comm_node, групування по ncn_id, в одному звіті може бути декілька супровідних описів
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'group_ds',
                       q'[SELECT po.npo_id,
       (']'
                    || TO_CHAR (p_po_id)
                    || '/'
                    || q'[' || MAX(po.npo_index)) AS accomp_desc_num,
       null AS post_name,
       (to_char(SUM(s.prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') || ' ' || uss_esr.dnet$payment_reports.sum_in_words(SUM(s.prs_sum), 'гривня', 'гривні', 'гривень', 'коп.')) AS total_sum
       ]'
                    || v_base_sql
                    || '
       GROUP BY po.npo_id');

                /*rdm$rtfl.adddataset(p_jbr_id, 'group_ds', q'[SELECT cn.ncn_id,
                  (']' || to_char(p_pr_id) || '/' || q'[' || MAX(cn.ncn_code)) AS accomp_desc_num,
                  coalesce(MAX(TRIM(cn.ncn_name)), '________________________________________________________________') AS post_name,
                  (to_char(SUM(s.prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') || ' ' || uss_esr.dnet$payment_reports.sum_in_words(SUM(s.prs_sum), 'гривня', 'гривні', 'гривень', 'коп.')) AS total_sum
                  ]' || v_base_sql || '
                  GROUP BY cn.ncn_id');*/

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'main_ds1',
                       q'[SELECT (CASE grp_lvl
         WHEN 0 THEN
          to_char(row_number() over(ORDER BY grp_lvl, prs_index))
         ELSE
          'Усього'
       END) AS c1, --Порядковий номер
       prs_index AS c2, --Найменування виплатного об’єкта
       (CASE grp_lvl
         WHEN 0 THEN
           prs_cnt
         ELSE
           SUM(CASE grp_lvl WHEN 0 THEN prs_cnt ELSE 0 END) OVER ()
       END) AS c3, --Кількість відомостей
       inn_cnt AS c4, --Кількість одержувачів
       to_char(tot_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c5, --Сума пенсій, грошової допомоги за відомостями
       NULL AS c5 --Примітка
  FROM (SELECT po.npo_id as npo_child,
               s.prs_index,
               MAX(s.prs_num) AS prs_cnt,
               COUNT(DISTINCT(s.prs_pc)) AS inn_cnt,
               SUM(s.prs_sum) AS tot_sum,
               GROUPING(po.npo_id) + GROUPING(s.prs_index) AS grp_lvl
          ]'
                    || v_base_sql
                    || '
         GROUP BY ROLLUP(po.npo_id, s.prs_index))
 WHERE grp_lvl IN (0, 1)');
                --rdm$rtfl.addrelation(p_jbr_id, 'group_ds', 'ncn_id', 'main_ds1', 'npo_ncn');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds',
                                      'npo_id',
                                      'main_ds1',
                                      'npo_child');

                -- #73809 «Супровідний опис» 2 екземпляра по кажному поштамту, вузлу (центру) поштового зв'язку
                rdm$rtfl.adddataset (p_jbr_id,
                                     'group_ds3',
                                     'SELECT 1
  FROM (SELECT DISTINCT po.npo_id as npo_child
          ' || v_base_sql || '
        UNION ALL
        SELECT DISTINCT po.npo_id as npo_child
          ' || v_base_sql || ')
  WHERE 1 = 1');
                --rdm$rtfl.addrelation(p_jbr_id, 'group_ds', 'npo_id', 'group_ds3', 'npo_ncn');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds',
                                      'npo_id',
                                      'group_ds3',
                                      'npo_child');

                --#71269 СУПРОВIДНА  ВIДОМIСТЬ
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'main_ds4',
                       q'[SELECT prs_index AS c1, c2, c3, c4, row_number() over(ORDER BY prs_index) AS sd_rn
  FROM (SELECT po.npo_id as npo_child,
               s.prs_index,
               (MIN(s.prs_num) || ' - ' || MAX(s.prs_num)) AS c2,
               COUNT(DISTINCT(s.prs_pc)) AS c3,
               to_char(SUM(s.prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c4
          ]'
                    || v_base_sql
                    || '
         GROUP BY po.npo_id, s.prs_index)
         WHERE 1 = 1');
                --rdm$rtfl.addrelation(p_jbr_id, 'group_ds', 'ncn_id', 'main_ds4', 'npo_ncn');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds',
                                      'npo_id',
                                      'main_ds4',
                                      'npo_child');

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'total_ds4',
                       q'[SELECT SUM(c1) AS c1, SUM(c2) AS c2, to_char(SUM(c3), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''')  AS c3
  FROM (SELECT po.npo_id as npo_child, s.prs_index, MAX(s.prs_num) c1, COUNT(DISTINCT(s.prs_pc)) AS c2, SUM(s.prs_sum) AS c3
          ]'
                    || v_base_sql
                    || '
         GROUP BY po.npo_id, s.prs_index)
         WHERE 1 = 1');
                --rdm$rtfl.addrelation(p_jbr_id, 'group_ds', 'ncn_id', 'total_ds4', 'npo_ncn');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds',
                                      'npo_id',
                                      'total_ds4',
                                      'npo_child');

                --#71181 реєстрів будується стільки, скільки унікальних prs_index в відомості
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'group_ds1',
                       q'[SELECT npo_index, (npo_index) AS post_info, row_number() over(ORDER BY npo_index)
  FROM (SELECT DISTINCT po.npo_id as npo_child, s.prs_index AS npo_index
          ]'
                    || v_base_sql
                    || ')
 WHERE 1 = 1');
                --rdm$rtfl.addrelation(p_jbr_id, 'group_ds', 'ncn_id', 'group_ds1', 'npo_ncn');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds',
                                      'npo_id',
                                      'group_ds1',
                                      'npo_child');

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'main_ds2',
                       q'[SELECT (CASE grp_lvl
         WHEN 0 THEN
          to_char(prs_pay_dt, 'DD.MM.YYYY')
         ELSE
          'Усього'
       END) AS c1, --Дата виплати
       prs_num AS c2, --Номер відомості
       inn_cnt AS c3, --Кількість одержувачів
       to_char(tot_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c4, --Загальна сума до виплати
       NULL AS c5, --Примітки
       row_number() over(ORDER BY grp_lvl, prs_num, prs_pay_dt) AS rn
  FROM (SELECT s.prs_index,
               s.prs_pay_dt,
               s.prs_num,
               COUNT(DISTINCT(s.prs_pc)) AS inn_cnt,
               SUM(s.prs_sum) AS tot_sum,
               GROUPING(s.prs_index) + GROUPING(s.prs_pay_dt) + GROUPING(s.prs_num) AS grp_lvl
          FROM uss_esr.v_payroll_reestr r
          join uss_esr.v_pr_sheet s on (r.pe_pr = s.prs_pr and r.pe_nb = s.prs_nb and r.pe_pay_dt = s.prs_pay_dt)
         WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
           AND coalesce(s.prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU')
         GROUP BY ROLLUP(s.prs_index, s.prs_pay_dt, s.prs_num))
 WHERE grp_lvl IN (0, 2)]');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds1',
                                      'npo_index',
                                      'main_ds2',
                                      'prs_index');

                --#71516 Підсумкова відомість і Звіт (8 тип відомості) будуються стільки, скільки унікальних prs_index в відомості
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'main_ds5',
                       q'[SELECT row_number() over(ORDER BY prs_cnt, inn_cnt, tot_sum) AS c1,
       ']'
                    || TO_CHAR (pr_cur.pr_start_day)
                    || '-'
                    || TO_CHAR (pr_cur.pr_stop_day)
                    || q'[' AS c2,
       prs_cnt AS c3,
       inn_cnt AS c4,
       to_char(tot_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c5
  FROM (SELECT s.prs_index,
               MAX(s.prs_num) AS prs_cnt,
               COUNT(DISTINCT(s.prs_pc)) AS inn_cnt,
               SUM(s.prs_sum) AS tot_sum
          FROM uss_esr.v_payroll_reestr r
          join uss_esr.v_pr_sheet s on (r.pe_pr = s.prs_pr and r.pe_nb = s.prs_nb and r.pe_pay_dt = s.prs_pay_dt)
         WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
          /* AND 'C' = ']'
                    || pr_cur.pr_st
                    || q'['*/
           AND coalesce(s.prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU')
         GROUP BY s.prs_index)
 WHERE 1 = 1]');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds1',
                                      'npo_index',
                                      'main_ds5',
                                      'prs_index');

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'total_ds5',
                       q'[SELECT MAX(prs_num) AS c1,
       COUNT(DISTINCT(prs_pc)) AS c2,
       to_char(SUM(prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c3
  FROM (SELECT s.prs_index, s.prs_num, s.prs_inn, s.prs_sum, prs_pc
          FROM uss_esr.v_payroll_reestr r
          join uss_esr.v_pr_sheet s on (r.pe_pr = s.prs_pr and r.pe_nb = s.prs_nb and r.pe_pay_dt = s.prs_pay_dt)
         WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
           /*AND 'C' = ']'
                    || pr_cur.pr_st
                    || q'['*/
           AND coalesce(s.prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU'))
 WHERE 1 = 1]');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds1',
                                      'npo_index',
                                      'total_ds5',
                                      'prs_index');

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'total_ds6',
                       q'[SELECT COUNT(DISTINCT(prs_inn)) AS c1,
       regexp_substr(to_char(SUM(prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''), '[^.]*') AS c2,
       REPLACE(to_char(SUM(prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''),
               regexp_substr(to_char(SUM(prs_sum), 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.'''''), '[^.]*') || '.') AS c3,
       NULL AS c4,
       NULL AS c5,
       NULL AS c6,
       NULL AS c7,
       NULL AS c8,
       NULL AS c9,
       NULL AS c10
  FROM (SELECT s.prs_index, s.prs_inn, s.prs_sum
          FROM uss_esr.v_payroll_reestr r
          join uss_esr.v_pr_sheet s on (r.pe_pr = s.prs_pr and r.pe_nb = s.prs_nb and r.pe_pay_dt = s.prs_pay_dt)
         WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
          /* AND 'C' = ']'
                    || pr_cur.pr_st
                    || q'['*/
           AND coalesce(s.prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU'))
 WHERE 1 = 1]');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds1',
                                      'npo_index',
                                      'total_ds6',
                                      'prs_index');

                --#71183 відомість будується по унікальним prs_num в відомості - тобто повинно бути стільки екземплярів форми, скільки унікальних prs_num
                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'group_ds2',
                       q'[SELECT prs_grp_key,
       prs_num AS desc_num,
       (lower(to_char(prs_pay_dt, 'MONTH', 'NLS_DATE_LANGUAGE = UKRAINIAN')) || ' ' || to_char(prs_pay_dt, 'YYYY')) AS desc_date,
       to_char(prs_pay_dt, 'DD.MM.YYYY') AS desc_pay_date,
       prs_index AS del_station_info,
       nd_code as dd_info,
       tot_acc_cnt,
       (to_char(tot_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') || ' ' || uss_esr.dnet$payment_reports.sum_in_words(tot_sum, 'гривня', 'гривні', 'гривень', 'коп.')) AS tot_sum_to_pay,
       row_number() over(ORDER BY rnk) AS rn
  FROM (SELECT DISTINCT s.prs_index || '/' || s.prs_num || '/' || to_char(s.prs_pay_dt, 'DDMMYYYY') AS prs_grp_key,
                        s.prs_num,
                        s.prs_pay_dt,
                        s.prs_index,
                        dl.nd_code,
                        COUNT(DISTINCT(s.prs_pc)) over(PARTITION BY s.prs_index || '/' || s.prs_num || '/' || to_char(s.prs_pay_dt, 'DDMMYYYY')) AS tot_acc_cnt,
                        SUM(s.prs_sum) over(PARTITION BY s.prs_index || '/' || s.prs_num || '/' || to_char(s.prs_pay_dt, 'DDMMYYYY')) AS tot_sum,
                        rank() over(ORDER BY s.prs_index, s.prs_num, to_char(s.prs_pay_dt, 'YYYYMMDD')) AS rnk
          FROM uss_esr.v_payroll_reestr r
          join uss_esr.v_pr_sheet s on (r.pe_pr = s.prs_pr and r.pe_nb = s.prs_nb and r.pe_pay_dt = s.prs_pay_dt)
          left join uss_ndi.v_ndi_delivery dl on (dl.nd_id = s.prs_nd)
         WHERE r.pe_po = ]'
                    || p_po_id
                    || q'[
           AND coalesce(s.prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU'))
 WHERE 1 = 1]');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds1',
                                      'npo_index',
                                      'group_ds2',
                                      'prs_index');

                rdm$rtfl.adddataset (
                    p_jbr_id,
                    'main_ds3',
                       q'[SELECT prs_pc_num AS c1, --Номер особового рахунка одержувача
       (prs_ln || ' ' || prs_fn || ' ' || prs_mn) AS c2, --Прізвище, власне ім’я, по батькові (за наявності)
       prs_address AS c3, --Місце проживання
       to_char(prs_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c4, --Сума пенсії, грошової допомоги (цифрами)
       prs_doc_num AS c5, --Паспорт громадянина України або документ, що посвідчує особу (серія, номер)
       to_char(prs_pay_dt, 'DD.MM.YYYY') AS c6, --Дата виплати
       NULL AS c7, --Підпис одержувача
       NULL AS c8, --Підпис працівника виплатного об’єкта
       to_char(prs_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS c9, --Сума пенсії, грошової допомоги (цифрами)
       prs_pc_num AS c10, --Номер особового рахунка одержувача
       NULL AS c11, --Примітка
       row_number() over(ORDER BY(prs_ln || ' ' || prs_fn || ' ' || prs_mn), prs_pay_dt) AS trn
  FROM (SELECT s.prs_index || '/' || s.prs_num || '/' || to_char(s.prs_pay_dt, 'DDMMYYYY') AS prs_row_key,
               s.prs_pc_num,
               s.prs_ln,
               s.prs_fn,
               s.prs_mn,
               s.prs_address,
               s.prs_doc_num,
               s.prs_pay_dt,
               SUM(s.prs_sum) AS prs_sum
          FROM uss_esr.v_payroll_reestr r
          join uss_esr.v_pr_sheet s on (r.pe_pr = s.prs_pr and r.pe_nb = s.prs_nb and r.pe_pay_dt = s.prs_pay_dt)
         WHERE r.pe_Po = ]'
                    || p_po_id
                    || q'[
           AND coalesce(s.prs_st, 'NULL') != 'PP'
           and prs_tp not in ('ABU', 'ADV', 'AUU')
         GROUP BY s.prs_index || '/' || s.prs_num || '/' || to_char(s.prs_pay_dt, 'DDMMYYYY'),
                  s.prs_pc_num,
                  s.prs_ln,
                  s.prs_fn,
                  s.prs_mn,
                  s.prs_address,
                  s.prs_doc_num,
                  s.prs_pay_dt)
 WHERE 1 = 1]');
                rdm$rtfl.addrelation (p_jbr_id,
                                      'group_ds2',
                                      'prs_grp_key',
                                      'main_ds3',
                                      'prs_row_key');
            END IF;
        END LOOP;

        RDM$RTFL.AddParam (p_jbr_id,
                           'c_main_pib_short',
                           tools.get_acc_setup_pib (0));
        RDM$RTFL.AddParam (p_jbr_id,
                           'c_main_buch_pib',
                           tools.get_acc_setup_pib (1));

        --позначення звіту як готового до формування файлу із данними
        IF p_jbr_id > 0
        THEN
            rdm$rtfl.putreporttoworkingqueue (p_jbr_id);
        END IF;

        RETURN p_jbr_id;
    END;

    -- info:   Отримання вкладення для документа акту про припинення
    -- params: p_at_id - ідентифікатор акту
    --         p_ndt_id - ідентифікатор типу документа
    -- note:
    FUNCTION get_act_term_doc_attach (p_at_id NUMBER, p_ndt_id NUMBER)
        RETURN BLOB
    IS
        v_blob   BLOB;
        v_jbr    NUMBER;
    BEGIN
        IF (p_ndt_id = 860)
        THEN
            decision_term_prov_ss_r1_main (
                p_rt_code    => 'DECISION_TERM_PROV_SS_R1',
                p_at_id      => p_at_id,
                p_bld_tp     => rdm$rtfl_univ.c_Bld_Tp_Db,
                p_jbr_id     => v_jbr,
                p_rpt_blob   => v_blob);
        ELSIF (p_ndt_id = 862)
        THEN
            message_term_prov_ss_r1_main (
                p_rt_code    => 'MESSAGE_TERM_PROV_SS_R2',
                p_at_id      => p_at_id,
                p_bld_tp     => rdm$rtfl_univ.c_Bld_Tp_Db,
                p_jbr_id     => v_jbr,
                p_rpt_blob   => v_blob);
        ELSIF p_ndt_id = 843
        THEN
            ACT_DOC_843_R1 (p_at_id    => p_at_id,
                            p_Bld_Tp   => rdm$rtfl_univ.c_Bld_Tp_Db,
                            p_jbr_id   => v_jbr,
                            p_blob     => v_blob);
        ELSIF p_ndt_id = 850
        THEN
            ASSISTANCE_DECISION_R2_850 (
                p_at_id    => p_at_id,
                p_Bld_Tp   => rdm$rtfl_univ.c_Bld_Tp_Db,
                p_jbr_id   => v_jbr,
                p_blob     => v_blob);
        ELSIF p_ndt_id = 851
        THEN
            ASSISTANCE_MESSAGE_R2_851 (
                p_at_id    => p_at_id,
                p_Bld_Tp   => rdm$rtfl_univ.c_Bld_Tp_Db,
                p_jbr_id   => v_jbr,
                p_blob     => v_blob);
        ELSIF p_ndt_id = 852
        THEN
            PLACEMENT_APPLICATION_R1_852 (
                p_at_id    => p_at_id,
                p_Bld_Tp   => rdm$rtfl_univ.c_Bld_Tp_Db,
                p_jbr_id   => v_jbr,
                p_blob     => v_blob);
        ELSIF p_ndt_id = 853
        THEN
            SEND_REQUEST_NOTIFICATION_R1_853 (
                p_at_id    => p_at_id,
                p_Bld_Tp   => rdm$rtfl_univ.c_Bld_Tp_Db,
                p_jbr_id   => v_jbr,
                p_blob     => v_blob);
        ELSIF p_ndt_id = 854
        THEN
            PLACEMENT_VOUCHER_R1_854 (p_at_id    => p_at_id,
                                      p_Bld_Tp   => rdm$rtfl_univ.c_Bld_Tp_Db,
                                      p_jbr_id   => v_jbr,
                                      p_blob     => v_blob);
        ELSIF p_ndt_id = 855
        THEN
            ACT_DOC_855_R1 (p_at_id    => p_at_id,
                            p_Bld_Tp   => rdm$rtfl_univ.c_Bld_Tp_Db,
                            p_jbr_id   => v_jbr,
                            p_blob     => v_blob);
        ELSIF p_ndt_id = 856
        THEN
            ACT_DOC_856_R1 (p_at_id    => p_at_id,
                            p_Bld_Tp   => rdm$rtfl_univ.c_Bld_Tp_Db,
                            p_jbr_id   => v_jbr,
                            p_blob     => v_blob);
        END IF;

        RETURN v_blob;
    END;
BEGIN
    NULL;
END;
/