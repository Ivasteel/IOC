/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$CALC_RIGHT
IS
    --Назва документа
    FUNCTION Get_Doc_Name (p_ndt ap_document.apd_ndt%TYPE)
        RETURN VARCHAR2;

    --Перевірка заповненості атрибутів документів - повертає кількість незаповнених атрибутів
    FUNCTION check_docx_filled (p_pd         pc_decision.pd_id%TYPE,
                                p_sc         ap_person.app_id%TYPE,
                                p_ndt        ap_document.apd_ndt%TYPE,
                                p_nda_list   VARCHAR2,
                                p_calc_dt    DATE,
                                p_Is_Need    NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    --Перевірка заповненості атрибутів документів - повертає кількість незаповнених атрибутів
    --p_nda_alt_list - тут можна задати алтернативні атрибути
    FUNCTION check_docx_filled (p_pd             pc_decision.pd_id%TYPE,
                                p_sc             ap_person.app_id%TYPE,
                                p_ndt            ap_document.apd_ndt%TYPE,
                                p_nda_list       VARCHAR2,
                                p_nda_alt_list   VARCHAR2,
                                p_calc_dt        DATE,
                                p_Is_Need        NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    --Перевірка заповненості атрибутів документа 201 - повертає перелік незаповнених атрибутів
    FUNCTION check_docx_201 (p_pd        pc_decision.pd_id%TYPE,
                             p_sc        ap_person.app_id%TYPE,
                             p_calc_dt   DATE,
                             p_Is_Need   NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    --Перевірка заповненості атрибутів документа 809 - повертає перелік незаповнених атрибутів
    FUNCTION check_docx_809 (p_pd        pc_decision.pd_id%TYPE,
                             p_sc        ap_person.app_id%TYPE,
                             p_calc_dt   DATE,
                             p_Is_Need   NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    /*
      FUNCTION check_documents_filled_ap1(p_ap ap_document.apd_ap%TYPE,
                                         p_ndt ap_document.apd_ndt%TYPE,
                                         p_nda_list VARCHAR2,
                                         p_calc_dt  DATE,
                                         p_Is_Need  number default 1
                                         ) RETURN VARCHAR2;
    */
    FUNCTION check_docx_filled_pib (p_pd         pc_decision.pd_id%TYPE,
                                    p_sc         ap_person.app_id%TYPE,
                                    p_ndt        ap_document.apd_ndt%TYPE,
                                    p_nda_list   VARCHAR2,
                                    p_nda_pib    VARCHAR2,
                                    p_calc_dt    DATE)
        RETURN VARCHAR2;

    FUNCTION check_docx_filled_val (p_pd         pc_decision.pd_id%TYPE,
                                    p_sc         ap_person.app_id%TYPE,
                                    p_ndt        ap_document.apd_ndt%TYPE,
                                    p_nda_list   VARCHAR2,
                                    p_str_list   VARCHAR2,
                                    p_calc_dt    DATE,
                                    p_Is_Need    NUMBER DEFAULT 1)
        RETURN VARCHAR2;

    FUNCTION check_docx_filled_600 (p_pd        pc_decision.pd_id%TYPE,
                                    p_sc        ap_person.app_id%TYPE,
                                    p_calc_dt   DATE)
        RETURN VARCHAR2;

    FUNCTION check_docx_list_class (p_pd         pc_decision.pd_id%TYPE,
                                    p_sc         ap_person.app_id%TYPE,
                                    p_list_ndt   VARCHAR2,
                                    p_class      VARCHAR2,
                                    p_calc_dt    DATE)
        RETURN VARCHAR2;

    --==============================================================--
    --  Перевірка наявності документа
    --==============================================================--
    FUNCTION check_docx_exists (p_pd        pc_decision.pd_id%TYPE,
                                p_sc        ap_person.app_id%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_calc_dt   DATE)
        RETURN VARCHAR2;

    --==============================================================--
    --  Перевірка статусу веріфікації документа
    --==============================================================--
    FUNCTION check_vfx_st (p_pd        pc_decision.pd_id%TYPE,
                           p_sc        ap_person.app_id%TYPE,
                           p_ndt       ap_document.apd_ndt%TYPE,
                           p_calc_dt   DATE)
        RETURN VARCHAR2;

    --==============================================================--
    --  Перевірка, що попереднє рішення закінчилось на p_stop_td
    --==============================================================--
    FUNCTION check_accrual_period (p_pd_id          NUMBER,
                                   p_start_new_td   DATE,
                                   p_stop_td        DATE)
        RETURN NUMBER;

    FUNCTION check_248x_10040 (p_pd        pc_decision.pd_id%TYPE,
                               p_sc        ap_person.app_id%TYPE,
                               p_ndt       ap_document.apd_ndt%TYPE,
                               p_calc_dt   DATE)
        RETURN VARCHAR2;

    FUNCTION Check_Income_Stat (p_pd        pc_decision.pd_id%TYPE,
                                p_sc        ap_person.app_id%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_nda       ap_document_attr.apda_nda%TYPE,
                                p_calc_dt   DATE)
        RETURN VARCHAR2;

    FUNCTION Is_Check_ALG_n (p_pd_id pc_decision.pd_id%TYPE, p_alg VARCHAR2)
        RETURN NUMBER;

    FUNCTION get_month_start (p_dt DATE, p_mode INTEGER:= 1)
        RETURN INTEGER;


    --Отримання текстового параметру документу по учаснику
    FUNCTION get_pd_doc_string (p_pd        pc_decision.pd_id%TYPE,
                                p_sc        ap_person.app_id%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_nda       ap_document_attr.apda_nda%TYPE,
                                p_calc_dt   DATE,
                                p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION Get_Docx_Scan (p_pd        pc_decision.pd_id%TYPE,
                            p_sc        ap_person.app_id%TYPE,
                            p_ndt       ap_document.apd_ndt%TYPE,
                            p_calc_dt   DATE)
        RETURN NUMBER;

    --Отримання параметру Дата з документу по учаснику
    FUNCTION get_docx_dt (p_pd        pc_decision.pd_id%TYPE,
                          p_sc        ap_person.app_id%TYPE,
                          p_ndt       ap_document.apd_ndt%TYPE,
                          p_nda       ap_document_attr.apda_nda%TYPE,
                          p_calc_dt   DATE)
        RETURN DATE;

    --Отримання параметру строка з документу по учаснику
    FUNCTION get_docx_string (p_pd        pc_decision.pd_id%TYPE,
                              p_sc        ap_person.app_id%TYPE,
                              p_ndt       ap_document.apd_ndt%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_calc_dt   DATE,
                              p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --Отримання id параметру документу по учаснику
    FUNCTION get_docx_id (p_pd        pc_decision.pd_id%TYPE,
                          p_sc        ap_person.app_id%TYPE,
                          p_ndt       ap_document.apd_ndt%TYPE,
                          p_nda       ap_document_attr.apda_nda%TYPE,
                          p_calc_dt   DATE,
                          p_default   NUMBER DEFAULT NULL)
        RETURN NUMBER;

    --Отримання текстового параметру документу по документу
    FUNCTION get_attr_string (p_apd       ap_document.apd_id%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;


    FUNCTION get_docx_ndc13_count (p_pd        pc_decision.pd_id%TYPE,
                                   p_sc        ap_person.app_id%TYPE,
                                   p_calc_dt   DATE)
        RETURN NUMBER;

    FUNCTION get_docx_ndc13_count_ (p_pd        pc_decision.pd_id%TYPE,
                                    p_sc        ap_person.app_id%TYPE,
                                    p_calc_dt   DATE)
        RETURN NUMBER;

    FUNCTION get_docx_list_cnt (p_pd         pc_decision.pd_id%TYPE,
                                p_sc         ap_person.app_id%TYPE,
                                p_list_ndt   VARCHAR2,
                                p_calc_dt    DATE)
        RETURN NUMBER;

    --==============================================================--
    --  Ознака «Категорія отримувача соціальних послуг» - наявність документів
    --==============================================================--
    FUNCTION IsRecip_SS_doc_exists (p_pd        pc_decision.pd_id%TYPE,
                                    p_sc        ap_person.app_id%TYPE,
                                    p_calc_dt   DATE)
        RETURN NUMBER;

    --==============================================================--
    --                    ПЕРЕВІРКА СПОСОБІВ ВИПЛАТ
    --==============================================================--
    FUNCTION Validate_pdm_pay (P_PD_ID IN NUMBER)
        RETURN VARCHAR2;

    -- Перевірка відповідності двох kaot з урахування рівня
    FUNCTION Check_kaot (p_ank_kaot_id     NUMBER,
                         p_ank_kaot_code   VARCHAR2,
                         p_ank_kaot_lv     NUMBER,
                         p_doc_kaot_id     NUMBER,
                         p_doc_kaot_code   VARCHAR2,
                         p_doc_kaot_lv     NUMBER,
                         p_sc              NUMBER)
        RETURN VARCHAR2;

    --========================================
    --Перерахунок результату контроля по послузі після корегування pd_right_log
    PROCEDURE Recalc_ALG66 (p_pd_id pc_decision.pd_id%TYPE);

    --Перевірка наявності права на допомогу
    PROCEDURE init_right_for_decision (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                                       p_pd_id          pc_decision.pd_id%TYPE,
                                       p_messages   OUT SYS_REFCURSOR);


    --+++++++++++++++++++++
    PROCEDURE dbms_output_decision_info (p_id NUMBER);

    PROCEDURE dbms_output_appeal_info (p_id NUMBER);

    PROCEDURE Test_right (id NUMBER);
--+++++++++++++++++++++

END;
/


/* Formatted on 8/12/2025 5:48:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$CALC_RIGHT
IS
    g_10             VARCHAR2 (10) := CHR (13) || CHR (10);

    Is_dbms_output   BOOLEAN := FALSE;

    --========================================
    PROCEDURE PutLine (p_val VARCHAR2)
    IS
    BEGIN
        IF Is_dbms_output
        THEN
            DBMS_OUTPUT.put_line (p_val);
        END IF;
    END;

    --========================================
    PROCEDURE Set_Rec_Anketa_z (
        p_pd               NUMBER,
        Rec_Anketa_Z   OUT API$ANKETA.Type_Rec_Anketa)
    IS
    BEGIN
        FOR a IN (SELECT *
                    FROM TABLE (API$ANKETA.get_Anketa)
                   WHERE pd_id = p_pd AND app_tp IN ('Z', 'ANF'))
        LOOP
            Rec_Anketa_Z := a;
        END LOOP;
    END;

    --========================================
    PROCEDURE write_pd_log (p_pdl_pd        pd_log.pdl_pd%TYPE,
                            p_pdl_hs        pd_log.pdl_hs%TYPE,
                            p_pdl_st        pd_log.pdl_st%TYPE,
                            p_pdl_message   pd_log.pdl_message%TYPE,
                            p_pdl_st_old    pd_log.pdl_st_old%TYPE,
                            p_pdl_tp        pd_log.pdl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --l_hs := NVL(p_pdl_hs, TOOLS.GetHistSession);
        l_hs := p_pdl_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        INSERT INTO pd_log (pdl_id,
                            pdl_pd,
                            pdl_hs,
                            pdl_st,
                            pdl_message,
                            pdl_st_old,
                            pdl_tp)
             VALUES (0,
                     p_pdl_pd,
                     l_hs,
                     p_pdl_st,
                     p_pdl_message,
                     p_pdl_st_old,
                     NVL (p_pdl_tp, 'SYS'));
    END;

    --========================================

    FUNCTION get_month_start (p_dt DATE, p_mode INTEGER:= 1)
        RETURN INTEGER
    IS
        l_month   INTEGER;
        l_rez     INTEGER;
    BEGIN
        IF p_mode = 1
        THEN
            l_month := 0 + TO_CHAR (p_dt, 'MM');

            l_rez :=
                CASE l_month
                    WHEN 1 THEN 3
                    WHEN 2 THEN 1
                    WHEN 3 THEN 2
                    WHEN 4 THEN 3
                    WHEN 5 THEN 1
                    WHEN 6 THEN 2
                    WHEN 7 THEN 3
                    WHEN 8 THEN 1
                    WHEN 9 THEN 2
                    WHEN 10 THEN 3
                    WHEN 11 THEN 1
                    WHEN 12 THEN 2
                END;
        ELSIF p_mode = 2
        THEN
            l_rez := 0;
        END IF;

        RETURN l_rez;
    END;

    --Отримання текстового параметру документу по учаснику
    FUNCTION get_pd_doc_string (p_pd        pc_decision.pd_id%TYPE,
                                p_sc        ap_person.app_id%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_nda       ap_document_attr.apda_nda%TYPE,
                                p_calc_dt   DATE,
                                p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (pdoa_val_string)
          INTO l_rez
          FROM pd_document  pdo
               --JOIN ap_person app ON app.app_id = pdo.pdo_app AND app.app_ap = pdo.pdo_ap AND app.history_status = 'A'
               JOIN pd_document_attr pdoa
                   ON     pdoa.pdoa_pdo = pdo.pdo_id
                      AND pdoa.history_status = 'A'
         WHERE pdo.pdo_pd = p_pd --    AND app.app_sc  = p_sc
                                 AND pdo.pdo_ndt = p_ndt AND pdoa_nda = p_nda;

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    --===============================================================================--
    FUNCTION Get_Doc_Name (p_ndt ap_document.apd_ndt%TYPE)
        RETURN VARCHAR2
    IS
        ret   VARCHAR2 (2000);
    BEGIN
        SELECT MAX (t.ndt_name_short)
          INTO ret
          FROM uss_ndi.v_ndi_document_type t
         WHERE t.ndt_id = p_ndt;

        RETURN ret;
    END;

    --===============================================================================--
    FUNCTION Get_Docx_Scan (p_pd        pc_decision.pd_id%TYPE,
                            p_sc        ap_person.app_id%TYPE,
                            p_ndt       ap_document.apd_ndt%TYPE,
                            p_calc_dt   DATE)
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
          FROM Ap_Document  apd
               JOIN tmp_pa_documents d ON apd.apd_id = d.tpd_apd
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = p_ndt
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

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

    --Отримання параметру Дата з документу по учаснику
    FUNCTION get_docx_dt (p_pd        pc_decision.pd_id%TYPE,
                          p_sc        ap_person.app_id%TYPE,
                          p_ndt       ap_document.apd_ndt%TYPE,
                          p_nda       ap_document_attr.apda_nda%TYPE,
                          p_calc_dt   DATE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        SELECT MAX (apda_val_dt)
          INTO l_rez
          FROM tmp_pa_documents
               JOIN ap_document_attr
                   ON     apda_apd = tpd_apd
                      AND ap_document_attr.history_status = 'A'
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = p_ndt
               AND apda_nda = p_nda
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        RETURN l_rez;
    END;


    --Отримання текстового параметру документу по учаснику
    FUNCTION get_docx_string (p_pd        pc_decision.pd_id%TYPE,
                              p_sc        ap_person.app_id%TYPE,
                              p_ndt       ap_document.apd_ndt%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_calc_dt   DATE,
                              p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM tmp_pa_documents
               JOIN ap_document_attr
                   ON     apda_apd = tpd_apd
                      AND ap_document_attr.history_status = 'A'
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = p_ndt
               AND apda_nda = p_nda
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    --Отримання id параметру документу по учаснику
    FUNCTION get_docx_id (p_pd        pc_decision.pd_id%TYPE,
                          p_sc        ap_person.app_id%TYPE,
                          p_ndt       ap_document.apd_ndt%TYPE,
                          p_nda       ap_document_attr.apda_nda%TYPE,
                          p_calc_dt   DATE,
                          p_default   NUMBER DEFAULT NULL)
        RETURN NUMBER
    IS
        l_rez   NUMBER (14);
    BEGIN
        SELECT MAX (apda_val_id)
          INTO l_rez
          FROM tmp_pa_documents
               JOIN ap_document_attr
                   ON     apda_apd = tpd_apd
                      AND ap_document_attr.history_status = 'A'
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = p_ndt
               AND apda_nda = p_nda
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    --Отримання текстового параметру документу по документу
    FUNCTION get_attr_string (p_apd       ap_document.apd_id%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM ap_document_attr
         WHERE apda_apd = p_apd AND apda_nda = p_nda AND history_status = 'A';

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    /*
    --Отримання наявності документу
    FUNCTION get_docx_count(p_pd      pc_decision.pd_id%TYPE,
                            p_sc      ap_person.app_id%TYPE,
                            p_ndt     ap_document.apd_ndt%TYPE,
                            p_calc_dt DATE
                            ) RETURN NUMBER IS
      l_rez number(10);
    BEGIN
      SELECT count(1) INTO l_rez
      FROM tmp_pa_documents
      WHERE tpd_pd  = p_pd
        AND tpd_sc  = p_sc
        AND tpd_ndt = p_ndt
        AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

      RETURN l_rez;
    END;
    */
    FUNCTION get_docx_ndc13_count (p_pd        pc_decision.pd_id%TYPE,
                                   p_sc        ap_person.app_id%TYPE,
                                   p_calc_dt   DATE)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO l_rez
          FROM tmp_pa_documents
               JOIN Uss_Ndi.v_Ndi_Document_Type
                   ON ndt_id = tpd_ndt AND ndt_ndc = 13
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        RETURN l_rez;
    END;

    FUNCTION get_docx_ndc13_count_ (p_pd        pc_decision.pd_id%TYPE,
                                    p_sc        ap_person.app_id%TYPE,
                                    p_calc_dt   DATE)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO l_rez
          FROM tmp_pa_documents
               JOIN Uss_Ndi.v_Ndi_Document_Type
                   ON     ndt_id = tpd_ndt
                      AND ndt_ndc = 13
                      AND ndt_id NOT IN (37, 673)
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        RETURN l_rez;
    END;


    FUNCTION get_docx_list_cnt (p_pd         pc_decision.pd_id%TYPE,
                                p_sc         ap_person.app_id%TYPE,
                                p_list_ndt   VARCHAR2,
                                p_calc_dt    DATE)
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
          FROM tmp_pa_documents JOIN ndt_list ON tpd_ndt = i_ndt
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        RETURN l_rez;
    END;


    --Перевірка заповненості атрибутів документів - повертає кількість незаповнених атрибутів
    FUNCTION check_docx_filled (p_pd         pc_decision.pd_id%TYPE,
                                p_sc         ap_person.app_id%TYPE,
                                p_ndt        ap_document.apd_ndt%TYPE,
                                p_nda_list   VARCHAR2,
                                p_calc_dt    DATE,
                                p_Is_Need    NUMBER DEFAULT 1)
        RETURN VARCHAR2
    IS
        l_cnt        INTEGER;
        l_rez        INTEGER := 1;
        l_tmp        VARCHAR2 (4000);
        l_err_list   VARCHAR2 (4000);
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_pa_documents
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = p_ndt
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        IF l_cnt > 0
        THEN
            --Рахуємо кількість незаповнених атрибутів
            WITH
                nda_list
                AS
                    (    SELECT REGEXP_SUBSTR (p_nda_list,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS i_nda
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (p_nda_list, '[^,]*'))
                                + 1)
            SELECT SUM (da.x_err)                    AS x_err_cnt,
                   LISTAGG (
                       CASE WHEN da.x_err = 1 THEN da.nda_name ELSE '' END,
                       ', ')
                   WITHIN GROUP (ORDER BY nda_id)    AS x_err_fields_list
              INTO l_rez, l_tmp
              FROM tmp_pa_documents
                   JOIN v_ap_document_attr_check da ON apd_id = tpd_apd
                   JOIN nda_list ON da.nda_id = i_nda
             WHERE     tpd_pd = p_pd
                   AND tpd_sc = p_sc
                   AND tpd_ndt = p_ndt
                   AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

            IF l_rez > 0
            THEN
                SELECT    'Для '
                       || uss_person.api$sc_tools.get_pib (p_sc)
                       || ' в документі з типом '
                       || ndt_name_short
                       || ' не заповнені атрибути: '
                       || l_tmp
                  INTO l_err_list
                  FROM uss_ndi.v_ndi_document_type
                 WHERE ndt_id = p_ndt;
            END IF;
        ELSIF p_Is_Need = 1
        THEN
            SELECT    'Для '
                   || uss_person.api$sc_tools.get_pib (p_sc)
                   || ' не знайдено документа з типом '
                   || ndt_name
              INTO l_err_list
              FROM uss_ndi.v_ndi_document_type
             WHERE ndt_id = p_ndt;
        END IF;

        IF l_rez > 0
        THEN
            RETURN l_err_list;
        ELSE
            RETURN '';
        END IF;
    END;


    --Перевірка заповненості атрибутів документів - повертає кількість незаповнених атрибутів
    --p_nda_alt_list - тут можна задати алтернативні атрибути
    FUNCTION check_docx_filled (p_pd             pc_decision.pd_id%TYPE,
                                p_sc             ap_person.app_id%TYPE,
                                p_ndt            ap_document.apd_ndt%TYPE,
                                p_nda_list       VARCHAR2,
                                p_nda_alt_list   VARCHAR2,
                                p_calc_dt        DATE,
                                p_Is_Need        NUMBER DEFAULT 1)
        RETURN VARCHAR2
    IS
        l_cnt        INTEGER;
        l_rez        INTEGER := 1;
        l_tmp        VARCHAR2 (4000);
        l_err_list   VARCHAR2 (4000);
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_pa_documents
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = p_ndt
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        IF l_cnt > 0
        THEN
            --Рахуємо кількість незаповнених атрибутів
            WITH
                nda_list
                AS
                    (    SELECT REGEXP_SUBSTR (p_nda_list,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS i_nda,
                                REGEXP_SUBSTR (p_nda_alt_list,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS i_alt_nda
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (p_nda_list, '[^,]*'))
                                + 1)
            SELECT SUM (
                       CASE
                           WHEN da.x_err = 1 AND al.x_err = 1 THEN 1
                           ELSE 0
                       END)                             AS x_err_cnt,
                   LISTAGG (
                       CASE
                           WHEN da.x_err = 1 AND al.x_err = 1
                           THEN
                               da.nda_name
                           ELSE
                               ''
                       END,
                       ', ')
                   WITHIN GROUP (ORDER BY da.nda_id)    AS x_err_fields_list
              INTO l_rez, l_tmp
              FROM tmp_pa_documents
                   JOIN v_ap_document_attr_check da ON da.apd_id = tpd_apd
                   JOIN v_ap_document_attr_check al ON al.apd_id = tpd_apd
                   JOIN nda_list
                       ON da.nda_id = i_nda AND al.nda_id = i_alt_nda
             WHERE     tpd_pd = p_pd
                   AND tpd_sc = p_sc
                   AND tpd_ndt = p_ndt
                   AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

            IF l_rez > 0
            THEN
                SELECT    'Для '
                       || uss_person.api$sc_tools.get_pib (p_sc)
                       || ' в документі з типом '
                       || ndt_name_short
                       || ' не заповнені атрибути: '
                       || l_tmp
                  INTO l_err_list
                  FROM uss_ndi.v_ndi_document_type
                 WHERE ndt_id = p_ndt;
            END IF;
        ELSIF p_Is_Need = 1
        THEN
            SELECT    'Для '
                   || uss_person.api$sc_tools.get_pib (p_sc)
                   || ' не знайдено документа з типом '
                   || ndt_name
              INTO l_err_list
              FROM uss_ndi.v_ndi_document_type
             WHERE ndt_id = p_ndt;
        END IF;

        IF l_rez > 0
        THEN
            RETURN l_err_list;
        ELSE
            RETURN '';
        END IF;
    END;

    --Перевірка заповненості атрибутів документа 201 - повертає кількість незаповнених атрибутів
    FUNCTION check_docx_201 (p_pd        pc_decision.pd_id%TYPE,
                             p_sc        ap_person.app_id%TYPE,
                             p_calc_dt   DATE,
                             p_Is_Need   NUMBER DEFAULT 1)
        RETURN VARCHAR2
    IS
        l_cnt        INTEGER;
        l_err_list   VARCHAR2 (4000);
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_pa_documents
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = 201
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        IF l_cnt > 0
        THEN
            --349  група інвалідності  V_DDN_SCY_GROUP
            --791  підгрупа інвалідності  V_DDN_SCY_SGROUP
            IF get_docx_string (p_pd,
                                p_sc,
                                201,
                                349,
                                p_calc_dt,
                                '-') = '1'
            THEN
                l_err_list :=
                    check_docx_filled (p_pd,
                                       p_sc,
                                       201,
                                       '346,348,349,791,350,352,347',
                                       p_calc_dt,
                                       0);
            ELSE
                l_err_list :=
                    check_docx_filled (p_pd,
                                       p_sc,
                                       201,
                                       '346,348,349,350,352,347',
                                       p_calc_dt,
                                       0);
            END IF;
        ELSIF p_Is_Need = 1
        THEN
            l_err_list :=
                check_docx_filled (p_pd,
                                   p_sc,
                                   201,
                                   '346,348,349,791,350,352,347',
                                   p_calc_dt,
                                   1);
        END IF;

        RETURN l_err_list;
    END;

    --========================================
    --Перевірка заповненості атрибутів документа 809 - повертає кількість незаповнених атрибутів
    FUNCTION check_docx_809 (p_pd        pc_decision.pd_id%TYPE,
                             p_sc        ap_person.app_id%TYPE,
                             p_calc_dt   DATE,
                             p_Is_Need   NUMBER DEFAULT 1)
        RETURN VARCHAR2
    IS
        l_cnt        INTEGER;
        l_err_list   VARCHAR2 (4000);
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_pa_documents
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = 809
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        IF l_cnt > 0
        THEN
            --1937  група інвалідності  V_DDN_SCY_GROUP
            --1938  підгрупа інвалідності  V_DDN_SCY_SGROUP
            IF get_docx_string (p_pd,
                                p_sc,
                                809,
                                1937,
                                p_calc_dt,
                                '-') = '1'
            THEN
                l_err_list :=
                    check_docx_filled (p_pd,
                                       p_sc,
                                       809,
                                       '1810,1808,1937,1938,1805,1939,1806',
                                       p_calc_dt,
                                       0);
            ELSE
                l_err_list :=
                    check_docx_filled (p_pd,
                                       p_sc,
                                       809,
                                       '1810,1808,1937,1805,1939,1806',
                                       p_calc_dt,
                                       0);
            END IF;
        ELSIF p_Is_Need = 1
        THEN
            l_err_list :=
                check_docx_filled (p_pd,
                                   p_sc,
                                   809,
                                   '1810,1808,1937,1938,1805,1939,1806',
                                   p_calc_dt,
                                   0);
        END IF;

        RETURN l_err_list;
    END;

    --========================================
    FUNCTION check_docx_filled_pib (p_pd         pc_decision.pd_id%TYPE,
                                    p_sc         ap_person.app_id%TYPE,
                                    p_ndt        ap_document.apd_ndt%TYPE,
                                    p_nda_list   VARCHAR2,
                                    p_nda_pib    VARCHAR2,
                                    p_calc_dt    DATE)
        RETURN VARCHAR2
    IS
        l_cnt        INTEGER;
        --    l_ap      pc_decision.pd_ap%type;
        l_rez        INTEGER := 1;
        l_cnt_pib    INTEGER := 1;
        l_tmp        VARCHAR2 (4000);
        l_pib        VARCHAR2 (4000);
        l_err_list   VARCHAR2 (4000);
    BEGIN
        SELECT COUNT (1)                                     /*, max(apd_ap)*/
          INTO l_cnt                                                  --, l_ap
          FROM tmp_pa_documents
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = p_ndt
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        IF l_cnt > 0
        THEN
            --Рахуємо кількість незаповнених атрибутів
            WITH
                nda_list
                AS
                    (    SELECT REGEXP_SUBSTR (p_nda_list,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS i_nda
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (p_nda_list, '[^,]*'))
                                + 1)
            SELECT SUM (da.x_err)                    AS x_err_cnt,
                   LISTAGG (
                       CASE da.x_err WHEN 1 THEN da.nda_name ELSE '' END,
                       ', ')
                   WITHIN GROUP (ORDER BY nda_id)    AS x_err_fields_list
              INTO l_rez, l_tmp
              FROM tmp_pa_documents
                   JOIN v_ap_document_attr_check da ON apd_id = tpd_apd
                   JOIN nda_list ON da.nda_id = i_nda
             WHERE     tpd_pd = p_pd
                   AND tpd_sc = p_sc
                   AND da.apd_ndt = p_ndt
                   AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

            l_pib :=
                get_docx_string (p_pd,
                                 p_sc,
                                 p_ndt,
                                 p_nda_pib,
                                 p_calc_dt);                          --||'_';

            --dbms_output.put_line('l_pib='||l_pib);

            IF l_pib IS NOT NULL
            THEN
                SELECT COUNT (1)
                  INTO l_cnt_pib
                  FROM v_tmp_person_for_decision
                 WHERE     tpp_pd = p_pd
                       AND tpp_sc = p_sc
                       AND tpp_app_tp = 'FP'
                       AND LOWER (uss_person.api$sc_tools.get_pib (tpp_sc)) =
                           LOWER (l_pib);
            END IF;

            --dbms_output.put_line('l_cnt_pib='||l_cnt_pib);
            --зазначено ПІБ усиновленої дитини, яка не є утриманцем серед учасників звернення

            IF l_rez > 0
            THEN
                SELECT    'Для '
                       || uss_person.api$sc_tools.get_pib (p_sc)
                       || ' в документі з типом '
                       || ndt_name_short
                       || ' не заповнені атрибути: '
                       || l_tmp
                       || (CASE l_cnt_pib
                               WHEN 0
                               THEN
                                   ', зазначено ПІБ усиновленої дитини, яка не є утриманцем серед учасників звернення'
                               ELSE
                                   ''
                           END)
                  INTO l_err_list
                  FROM uss_ndi.v_ndi_document_type
                 WHERE ndt_id = p_ndt;
            ELSE
                SELECT    'Для '
                       || uss_person.api$sc_tools.get_pib (p_sc)
                       || ' в документі з типом '
                       || ndt_name_short
                       || ' зазначено ПІБ усиновленої дитини, яка не є утриманцем серед учасників звернення'
                  INTO l_err_list
                  FROM uss_ndi.v_ndi_document_type
                 WHERE ndt_id = p_ndt;
            END IF;
        ELSE
            SELECT    'Для '
                   || uss_person.api$sc_tools.get_pib (p_sc)
                   || ' не знайдено документа з типом '
                   || ndt_name_short
              INTO l_err_list
              FROM uss_ndi.v_ndi_document_type
             WHERE ndt_id = p_ndt;
        END IF;

        IF l_rez > 0 OR l_cnt_pib = 0
        THEN
            RETURN l_err_list;
        ELSE
            RETURN '';
        END IF;
    END;

    --========================================
    FUNCTION check_docx_filled_val (p_pd         pc_decision.pd_id%TYPE,
                                    p_sc         ap_person.app_id%TYPE,
                                    p_ndt        ap_document.apd_ndt%TYPE,
                                    p_nda_list   VARCHAR2,
                                    p_str_list   VARCHAR2,
                                    p_calc_dt    DATE,
                                    p_Is_Need    NUMBER DEFAULT 1)
        RETURN VARCHAR2
    IS
        l_cnt         INTEGER;
        l_rez_empty   INTEGER := 1;
        l_rez_fail    INTEGER := 1;
        l_err_empty   VARCHAR2 (4000);
        l_err_fail    VARCHAR2 (4000);
        l_err_list    VARCHAR2 (4000);
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_pa_documents
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = p_ndt
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        IF l_cnt > 0
        THEN
            --Рахуємо кількість незаповнених атрибутів
            WITH
                nda_list
                AS
                    (    SELECT REGEXP_SUBSTR (p_nda_list,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS i_nda,
                                SUBSTR (
                                    REGEXP_SUBSTR (
                                        REPLACE (',' || p_str_list, ',', ', '),
                                        '[^,]+',
                                        1,
                                        LEVEL),
                                    2)                   AS da_val
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (p_nda_list, '[^,]*'))
                                + 1)
            SELECT SUM (da.x_err)                    AS x_err_cnt,
                   LISTAGG (
                       CASE WHEN da.x_err = 1 THEN da.nda_name ELSE '' END,
                       ', ')
                   WITHIN GROUP (ORDER BY nda_id)    AS x_err_fields_list,
                   SUM (
                       CASE
                           WHEN     da_val IS NOT NULL
                                AND da_val !=
                                    NVL (da.apda_val_string, 'NULL')
                                AND da.apda_val_string IS NOT NULL
                           THEN
                               1
                           ELSE
                               0
                       END)                          AS x_err_val_cnt,
                   LISTAGG (
                       CASE
                           WHEN     da_val IS NOT NULL
                                AND da_val !=
                                    NVL (da.apda_val_string, 'NULL')
                                AND da.apda_val_string IS NOT NULL
                           THEN
                               ' до актового запису про народження дитини відомості про батька дитини  внесено не за вказівкою матері'
                           ELSE
                               ''
                       END,
                       ', ')
                   WITHIN GROUP (ORDER BY nda_id)    AS x_err_fields_list
              INTO l_rez_empty,
                   l_err_empty,
                   l_rez_fail,
                   l_err_fail
              FROM tmp_pa_documents
                   JOIN v_ap_document_attr_check da ON apd_id = tpd_apd
                   JOIN nda_list ON da.nda_id = i_nda
             WHERE     tpd_pd = p_pd
                   AND tpd_sc = p_sc
                   AND tpd_ndt = p_ndt
                   AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

            IF l_rez_empty > 0
            THEN
                SELECT    'Для '
                       || uss_person.api$sc_tools.get_pib (p_sc)
                       || ' в документі з типом '
                       || ndt_name_short
                       || ' не заповнені атрибути: '
                       || l_err_empty
                  INTO l_err_list
                  FROM uss_ndi.v_ndi_document_type
                 WHERE ndt_id = p_ndt;
            END IF;

            IF l_rez_fail > 0
            THEN
                SELECT    (CASE
                               WHEN l_err_list IS NOT NULL
                               THEN
                                   l_err_list || ', '
                               ELSE
                                   ''
                           END)
                       || 'Для '
                       || uss_person.api$sc_tools.get_pib (p_sc)
                       || ' за даними документу типом '
                       || ndt_name_short
                       || l_err_fail
                  INTO l_err_list
                  FROM uss_ndi.v_ndi_document_type
                 WHERE ndt_id = p_ndt;
            END IF;
        ELSIF p_Is_Need = 1
        THEN
            SELECT    'Для '
                   || uss_person.api$sc_tools.get_pib (p_sc)
                   || ' не знайдено документа з типом '
                   || ndt_name_short
              INTO l_err_list
              FROM uss_ndi.v_ndi_document_type, ap_person
             WHERE ndt_id = p_ndt;
        END IF;

        IF l_rez_empty > 0 OR l_rez_fail > 0
        THEN
            RETURN l_err_list;
        ELSE
            RETURN '';
        END IF;
    END;

    --========================================
    FUNCTION check_docx_filled_600 (p_pd        pc_decision.pd_id%TYPE,
                                    p_sc        ap_person.app_id%TYPE,
                                    p_calc_dt   DATE)
        RETURN VARCHAR2
    IS
        l_ndt        ap_document.apd_ndt%TYPE := 600;
        l_cnt        INTEGER;
        l_rez        INTEGER := 1;
        l_err        VARCHAR2 (4000);
        l_err_list   VARCHAR2 (4000);
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_pa_documents
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = l_ndt
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        --Для правила "Обов'язкові документи надано" для всіх типів допомог з Ід=269, 268, 267, 265,248 серед документів має бути обов'язковий документ
        --"Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг". у цьому документі (в Заяві) має бути заповнено хоча б одне поле в адресі проживання та в адресі реєстрації,
        --Якщо заява взагалі відсутня видавати повідомлення: "Для допомоги <тип допомоги> не подано Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг".
        --Якщо заяву подано але не заповнено жодного поля в адресі проживання або в адресі реєстрації, то видавати повідомлення:
        IF l_cnt > 0
        THEN
            SELECT SUM (x_err),
                   LISTAGG (x_err_text, ', ') WITHIN GROUP (ORDER BY 1)
              INTO l_rez, l_err
              FROM (  SELECT 1              x_err,
                                'В Заяві про призначення усіх видів соціальної допомоги, компенсацій та пільг не заповнено жодного поля в адресі '
                             || NNG_Name    x_err_text
                        FROM tmp_pa_documents
                             JOIN v_ap_document_attr_check dac
                                 ON apd_id = tpd_apd
                       WHERE     apd_app = 1171
                             AND apd_ndt = 600
                             AND nda_nng IN (1, 2)
                             AND x_err = 0
                             AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to
                    GROUP BY NNG_Name
                      HAVING COUNT (1) = 0);
        ELSE
            SELECT    'Для допомоги '
                   || nst.nst_name
                   || ' не подано Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг'
              INTO l_err_list
              FROM pc_decision  pd
                   INNER JOIN uss_ndi.v_ndi_service_type nst
                       ON pd.pd_nst = nst.nst_id
             WHERE pd_id = p_pd;
        END IF;

        IF l_rez > 0
        THEN
            RETURN l_err_list;
        ELSE
            RETURN '';
        END IF;
    END;

    --==============================================================--
    FUNCTION check_docx_list_class (p_pd         pc_decision.pd_id%TYPE,
                                    p_sc         ap_person.app_id%TYPE,
                                    p_list_ndt   VARCHAR2,
                                    p_class      VARCHAR2,
                                    p_calc_dt    DATE)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
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
        SELECT LISTAGG (
                      'Для '
                   || uss_person.api$sc_tools.get_pib (tpd.tpd_sc)
                   || ' в документі з типом "'
                   || d.ndt_name_short
                   || '" не заповнено атрибут "'
                   || a.nda_name
                   || '"',
                   CHR (13) || CHR (10))
          INTO l_rez
          FROM tmp_pa_documents  tpd
               JOIN ndt_list ON tpd_ndt = i_ndt
               JOIN uss_ndi.v_ndi_document_type d ON d.ndt_id = tpd_ndt
               JOIN v_ap_document_attr_check a
                   ON a.apd_ndt = tpd.tpd_ndt AND a.apd_id = tpd.tpd_apd
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND a.nda_class = p_class
               AND a.x_err = 1
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;


        RETURN l_rez;
    END;

    --==============================================================--
    --  Перевірка наявності документа
    --==============================================================--
    FUNCTION check_docx_exists (p_pd        pc_decision.pd_id%TYPE,
                                p_sc        ap_person.app_id%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_calc_dt   DATE)
        RETURN VARCHAR2
    IS
        l_err_list   VARCHAR2 (4000);
    BEGIN
        IF p_sc IS NOT NULL
        THEN
            SELECT LISTAGG (ndt.ndt_name_short, ', ')
                       WITHIN GROUP (ORDER BY 1)
              INTO l_err_list
              FROM uss_ndi.v_ndi_document_type  ndt
                   LEFT JOIN tmp_pa_documents
                       ON     tpd_ndt = ndt.ndt_id
                          AND tpd_pd = p_pd
                          AND tpd_sc = p_sc
                          AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to
             WHERE ndt.ndt_id = p_ndt AND tpd_apd IS NULL;
        ELSE
            SELECT LISTAGG (ndt.ndt_name_short, ', ')
                       WITHIN GROUP (ORDER BY 1)
              INTO l_err_list
              FROM uss_ndi.v_ndi_document_type  ndt
                   LEFT JOIN tmp_pa_documents
                       ON     tpd_ndt = ndt.ndt_id
                          AND tpd_pd = p_pd
                          AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to
             WHERE ndt.ndt_id = p_ndt AND tpd_apd IS NULL;
        END IF;

        RETURN l_err_list;
    END;

    --==============================================================--
    --Отримання текстового параметру документу по учаснику з рышення
    --==============================================================--
    /*
        FUNCTION get_pd_doc_string(p_pd       pc_decision.pd_id%TYPE,
                                   p_sc       ap_person.app_id%TYPE,
                                   p_ndt      ap_document.apd_ndt%TYPE,
                                   p_nda      ap_document_attr.apda_nda%TYPE,
                                   p_calc_dt  DATE,
                                   p_default  varchar2 default null ) RETURN VARCHAR2
        IS
          l_rez VARCHAR2(4000);
        BEGIN
          SELECT MAX(pdoa_val_string)
          INTO l_rez
          FROM pd_document
               JOIN pd_document_attr ON pdoa_pdo = pdo_id AND pd_document_attr.history_status = 'A'
          WHERE pdo_pd  = p_pd
            AND pd0_sc  = p_sc
            AND pd0_ndt = p_ndt
            AND pdoa_nda = p_nda
            AND pd_document.history_status = 'A';

          if p_default is not null Then
            RETURN nvl(l_rez, p_default);
          end if;
          RETURN l_rez;
        END;
    */
    --==============================================================--
    --  Перевірка статусу веріфікації документа
    --==============================================================--
    FUNCTION check_vfx_st (p_pd        pc_decision.pd_id%TYPE,
                           p_sc        ap_person.app_id%TYPE,
                           p_ndt       ap_document.apd_ndt%TYPE,
                           p_calc_dt   DATE)
        RETURN VARCHAR2
    IS
        l_vf_st   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (NVL (vf.vf_st, '-'))
          INTO l_vf_st
          FROM tmp_pa_documents
               JOIN ap_document ON apd_id = tpd_apd
               LEFT JOIN verification vf ON apd_vf = vf_id
         WHERE     tpd_ndt = p_ndt
               AND tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        RETURN l_vf_st;
    END;

    --==============================================================--
    --  Перевірка, що попереднє рішення закінчилось на p_stop_td
    --==============================================================--
    FUNCTION check_accrual_period (p_pd_id          NUMBER,
                                   p_start_new_td   DATE,
                                   p_stop_td        DATE)
        RETURN NUMBER
    IS
        l_Is_Curr   NUMBER;
        l_Is_next   NUMBER;
    BEGIN
        -- Перевірка, шо рішення діє зараз
        SELECT COUNT (1)
          INTO l_Is_next
          FROM pd_accrual_period ac
         WHERE     pdap_pd = p_pd_id
               AND ac.history_status = 'A'
               AND p_start_new_td < ac.pdap_stop_dt;

        IF l_Is_next > 0
        THEN
            --RETURN 0;
            RETURN 1;
        END IF;

        -- Перевірка, шо рішення діяло в попередньому місяці.
        SELECT COUNT (1)
          INTO l_Is_Curr
          FROM pd_accrual_period ac
         WHERE     pdap_pd = p_pd_id
               AND ac.history_status = 'A'
               AND p_stop_td = ac.pdap_stop_dt;

        IF l_Is_Curr > 0
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END;

    --==============================================================--
    --  Перевірка наявності документа 10040
    --==============================================================--
    FUNCTION check_248x_10040 (p_pd        pc_decision.pd_id%TYPE,
                               p_sc        ap_person.app_id%TYPE,
                               p_ndt       ap_document.apd_ndt%TYPE,
                               p_calc_dt   DATE)
        RETURN VARCHAR2
    IS
        l_doc_name   VARCHAR2 (4000);
        l_apd_id     NUMBER (14);
        l_attr_val   VARCHAR2 (4000);
        l_err_list   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (ndt.ndt_name_short, ', ') WITHIN GROUP (ORDER BY 1),
               MAX (tpd_apd),
               MAX (apda_val_string)
          INTO l_doc_name, l_apd_id, l_attr_val
          FROM uss_ndi.v_ndi_document_type  ndt
               LEFT JOIN tmp_pa_documents
                   ON     tpd_ndt = ndt.ndt_id
                      AND tpd_pd = p_pd
                      AND tpd_sc = p_sc
                      AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to
               LEFT JOIN ap_document_attr apda
                   ON     apda_apd = tpd_apd
                      AND apda.apda_nda = 939
                      AND apda.history_status = 'A'
         WHERE ndt.ndt_id = p_ndt;

        CASE
            WHEN l_apd_id IS NULL
            THEN
                l_err_list :=
                       'Відсутній документ '
                    || l_doc_name
                    || ', який підтверджує, що особа '
                    || uss_person.api$sc_tools.get_pib (p_sc)
                    || ' є дитиною з інвалідністю внаслідок аварії на ЧАЕС';
            WHEN NVL (l_attr_val, 'F') <> 'T'
            THEN
                l_err_list :=
                       'Для особи '
                    || uss_person.api$sc_tools.get_pib (p_sc)
                    || ' копію посвідчення серії Д не додано '
                    || '(згідно атрибуту "Копія посвідчення додається" для документа "Вкладка до посвідчення дитини, яка потерпіла від Чорнобильської катастрофи") , вкладка без посвідчення недійсна';
            ELSE
                NULL;
        END CASE;

        RETURN l_err_list;
    END;

    --========================================
    FUNCTION Check_Income_Stat (p_pd        pc_decision.pd_id%TYPE,
                                p_sc        ap_person.app_id%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_nda       ap_document_attr.apda_nda%TYPE,
                                p_calc_dt   DATE)
        RETURN VARCHAR2
    IS
        l_val         VARCHAR2 (4000);
        l_err_list    VARCHAR2 (4000);
        month_count   NUMBER;
    BEGIN
        l_val :=
            get_docx_string (p_pd,
                             p_sc,
                             p_ndt,
                             p_nda,
                             p_calc_dt);
        l_val := REGEXP_REPLACE (l_val, CHR (13) || '|' || CHR (10), '');

        IF l_val IS NOT NULL
        THEN
            WITH
                Inc_list
                AS
                    (    SELECT REGEXP_SUBSTR (l_val,
                                               '[^,]+',
                                               1,
                                               LEVEL)    AS str
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                LENGTH (REGEXP_REPLACE (l_val, '[^,]*')) + 1),
                val_list
                AS
                    (SELECT SUBSTR (
                                REGEXP_SUBSTR (
                                    REPLACE ('=' || str, '=', '= '),
                                    '[^=]+',
                                    1,
                                    1),
                                2)    AS str1,
                            SUBSTR (
                                REGEXP_SUBSTR (
                                    REPLACE ('=' || str, '=', '= '),
                                    '[^=]+',
                                    1,
                                    2),
                                2)    AS str2
                       FROM Inc_list)
            SELECT COUNT (1)
              INTO month_count
              FROM val_list
             WHERE str1 IS NOT NULL AND str2 IS NOT NULL;

            DBMS_OUTPUT.put_line ('month_count=' || month_count);

            IF month_count != 12
            THEN
                SELECT    'Для '
                       || uss_person.api$sc_tools.get_pib (p_sc)
                       || ' в документі з типом '
                       || ndt_name_short
                       || ' розмір доходів не за період 12 місяців'
                  INTO l_err_list
                  FROM uss_ndi.v_ndi_document_type
                 WHERE ndt_id = p_ndt;
            END IF;
        ELSE
            NULL;
        END IF;

        RETURN l_err_list;
    END;

    --==============================================================--
    --  Ознака «Категорія отримувача соціальних послуг»
    --==============================================================--
    FUNCTION IsRecip_SS (p_pd        pc_decision.pd_id%TYPE,
                         p_sc        ap_person.app_id%TYPE,
                         p_calc_dt   DATE)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO l_rez
          FROM tmp_pa_documents
               JOIN ap_document_attr
                   ON     apda_apd = tpd_apd
                      AND ap_document_attr.history_status = 'A'
               JOIN uss_ndi.v_ndi_document_attr ON apda_nda = nda_id
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = 605                                     -- Анкета
               AND nda_nng = 19    -- «Категорія отримувача соціальних послуг»
               AND NVL (apda_val_string, 'F') = 'T'
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        RETURN SIGN (l_rez);
    END;

    --==============================================================--
    --  Ознака «Категорія отримувача соціальних послуг» - наявність документів
    --==============================================================--
    FUNCTION IsRecip_SS_doc_exists (p_pd        pc_decision.pd_id%TYPE,
                                    p_sc        ap_person.app_id%TYPE,
                                    p_calc_dt   DATE)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10) := 0;
    BEGIN
        SELECT SUM (CASE apda_nda
                        WHEN 1795
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '820,821',
                                                              p_calc_dt)
                        WHEN 1796
                        THEN
                            api$calc_right.get_docx_list_cnt (
                                p_pd,
                                p_sc,
                                '822,823,824,825,826,827,828,829',
                                p_calc_dt)
                        WHEN 1797
                        THEN
                            api$calc_right.get_docx_list_cnt (
                                p_pd,
                                p_sc,
                                '203,200,202,676,10038',
                                p_calc_dt)
                        WHEN 1798
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '201,809',
                                                              p_calc_dt)
                        WHEN 1799
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '830,831',
                                                              p_calc_dt)
                        WHEN 1800
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '830,831',
                                                              p_calc_dt)
                        WHEN 1801
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '830,831',
                                                              p_calc_dt)
                        WHEN 1802
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '830,831',
                                                              p_calc_dt)
                        WHEN 1803
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '660,816',
                                                              p_calc_dt)
                        WHEN 1856
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '660',
                                                              p_calc_dt)
                        WHEN 1857
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '660',
                                                              p_calc_dt)
                        WHEN 1858
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '93',
                                                              p_calc_dt)
                        WHEN 1859
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '660,661',
                                                              p_calc_dt)
                        WHEN 1860
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '811',
                                                              p_calc_dt)
                        WHEN 1861
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '669',
                                                              p_calc_dt)
                        WHEN 1862
                        THEN
                            api$calc_right.get_docx_list_cnt (
                                p_pd,
                                p_sc,
                                '832,684,10052',
                                p_calc_dt)
                        WHEN 2560
                        THEN
                            api$calc_right.get_docx_list_cnt (p_pd,
                                                              p_sc,
                                                              '833',
                                                              p_calc_dt)
                        ELSE
                            0
                    END)    AS doc_list_cnt
          INTO l_rez
          FROM tmp_pa_documents
               JOIN ap_document_attr
                   ON     apda_apd = tpd_apd
                      AND ap_document_attr.history_status = 'A'
               JOIN uss_ndi.v_ndi_document_attr ON apda_nda = nda_id
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to
               AND tpd_ndt = 605                                     -- Анкета
               AND nda_nng = 19    -- «Категорія отримувача соціальних послуг»
               AND NVL (apda_val_string, 'F') != 'F';

        RETURN SIGN (NVL (l_rez, 0));
    END;

    --========================================
    PROCEDURE MERGE_tmp_errors_list (id NUMBER, info VARCHAR2)
    IS
    BEGIN
        MERGE INTO tmp_errors_list
             USING (SELECT id id, info info
                      FROM DUAL
                     WHERE info IS NOT NULL)
                ON (id = tel_id)
        WHEN MATCHED
        THEN
            UPDATE SET tel_text = tel_text || ', ' || info
        WHEN NOT MATCHED
        THEN
            INSERT     (tel_id, tel_text)
                VALUES (id, info);
    END;

    --========================================
    -- Перевірка відповідності двох kaot з урахування рівня
    FUNCTION Check_kaot (p_ank_kaot_id     NUMBER,
                         p_ank_kaot_code   VARCHAR2,
                         p_ank_kaot_lv     NUMBER,
                         p_doc_kaot_id     NUMBER,
                         p_doc_kaot_code   VARCHAR2,
                         p_doc_kaot_lv     NUMBER,
                         p_sc              NUMBER)
        RETURN VARCHAR2
    IS
        l_kaot_id     NUMBER;
        l_kaot_code   VARCHAR2 (200);
        sql_str       VARCHAR2 (2000);
        ret           VARCHAR2 (2000);
    BEGIN
        IF p_ank_kaot_lv = p_doc_kaot_lv
        THEN
            IF     p_ank_kaot_code IS NOT NULL
               AND p_doc_kaot_code IS NOT NULL
               AND p_ank_kaot_code != p_doc_kaot_code
            THEN
                ret :=
                       'В довідці ВПО та анкеті для особи '
                    || uss_person.api$sc_tools.get_pib (p_sc)
                    || ' зазначено різні значення, '
                    || 'а саме, в полі КАТТОТГ у довідці ВПО зазначено '
                    || p_doc_kaot_code
                    || ', а в Анкеті зазначено '
                    || p_ank_kaot_code;
            END IF;
        ELSIF p_ank_kaot_lv > p_doc_kaot_lv
        THEN
            sql_str :=
                   'SELECT kk.kaot_id, kk.kaot_code '
                || 'FROM uss_ndi.v_Ndi_Katottg  k '
                || '     JOIN uss_ndi.v_Ndi_Katottg  kk ON k.kaot_kaot_l'
                || p_doc_kaot_lv
                || ' = kk.kaot_id and kk.kaot_st = ''A'' '
                || 'WHERE k.kaot_id = :1';

            EXECUTE IMMEDIATE sql_str
                INTO l_kaot_id, l_kaot_code
                USING p_ank_kaot_id;

            IF     l_kaot_code IS NOT NULL
               AND p_doc_kaot_code IS NOT NULL
               AND l_kaot_code != p_doc_kaot_code
            THEN
                ret :=
                       'В довідці ВПО та анкеті для особи '
                    || uss_person.api$sc_tools.get_pib (p_sc)
                    || ' зазначено різні значення, '
                    || 'а саме, в полі КАТТОТГ у довідці ВПО зазначено '
                    || p_doc_kaot_code
                    || ', а в Анкеті зазначено '
                    || p_ank_kaot_code;
            END IF;
        ELSIF p_ank_kaot_lv < p_doc_kaot_lv
        THEN
            sql_str :=
                   'SELECT kk.kaot_id, kk.kaot_code '
                || 'FROM uss_ndi.v_Ndi_Katottg  k '
                || '     JOIN uss_ndi.v_Ndi_Katottg  kk ON k.kaot_kaot_l'
                || p_ank_kaot_lv
                || ' = kk.kaot_id and kk.kaot_st = ''A'' '
                || 'WHERE k.kaot_id = :1';

            EXECUTE IMMEDIATE sql_str
                INTO l_kaot_id, l_kaot_code
                USING p_doc_kaot_id;

            IF     p_ank_kaot_code IS NOT NULL
               AND l_kaot_code IS NOT NULL
               AND p_ank_kaot_code != l_kaot_code
            THEN
                ret :=
                       'В довідці ВПО та анкеті для особи '
                    || uss_person.api$sc_tools.get_pib (p_sc)
                    || ' зазначено різні значення, '
                    || 'а саме, в полі КАТТОТГ у довідці ВПО зазначено '
                    || p_doc_kaot_code
                    || ', а в Анкеті зазначено '
                    || p_ank_kaot_code;
            END IF;
        END IF;

        RETURN ret;
    END;

    --========================================
    PROCEDURE Set_pd_right_log (p_nrr_id NUMBER, p_pd_id NUMBER)
    IS
    BEGIN
        MERGE INTO pd_right_log
             USING (SELECT x_id                      AS b_pd,
                           p_nrr_id                  AS b_nrr,
                           CASE
                               WHEN (SELECT COUNT (*)
                                       FROM tmp_errors_list
                                      WHERE x_id = tel_id) > 0
                               THEN
                                   'F'
                               ELSE
                                   'T'
                           END                       AS b_result,
                           (SELECT MAX (tel_text)
                              FROM tmp_errors_list
                             WHERE x_id = tel_id)    AS b_info
                      FROM tmp_work_ids
                     WHERE x_id = p_pd_id)
                ON (prl_pd = b_pd AND prl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET prl_calc_result = b_result,
                       prl_hs_rewrite = NULL,
                       prl_result = b_result,
                       prl_calc_info = b_info
        WHEN NOT MATCHED
        THEN
            INSERT     (prl_id,
                        prl_pd,
                        prl_nrr,
                        prl_result,
                        prl_calc_result,
                        prl_calc_info)
                VALUES (0,
                        b_pd,
                        b_nrr,
                        b_result,
                        b_result,
                        b_info);
    END;

    --========================================
    PROCEDURE Check_ALG1 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT x_id, 'Не вказано заявника' AS x_text                          --1
                        FROM tmp_work_ids
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE app.pd_id = x_id AND tpp_app_tp = 'Z')
                      UNION ALL
                      SELECT p_pd                                              AS x_id,
                             API$CALC_RIGHT.check_docx_filled_600 (p_pd,
                                                                   tpp_sc,
                                                                   calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z')
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_20 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count_ (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                        'До звернення не долучено документ, що посвідчує особу Заявника'
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' Паспорт громадянина України, ІD картка тощо'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                        'До звернення не долучено документ, що посвідчує особу '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' Паспорт громадянина України, ІD картка, свідоцтво про народження тощо'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP', 'FM')/*
                                                                                       UNION ALL
                                                                                       SELECT p_pd as x_id,
                                                                                              CASE
                                                                                              WHEN api$calc_right.get_docx_count(tpp_pd, tpp_sc, 600, calc_dt) = 0 THEN
                                                                                               'До звернення не долучено Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг'
                                                                                              END AS x_text          --1
                                                                                       FROM  v_tmp_person_for_decision app
                                                                                       WHERE tpp_pd = p_pd
                                                                                             and tpp_app_tp IN ('Z')*/
                                                                         )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_21 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT pd_id    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count_ (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                        'До звернення не долучено документ, що посвідчує особу Заявника'
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' Паспорт громадянина України, ІD картка тощо'
                             END      AS x_text                            --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT pd_id    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                        'До звернення не долучено документ, що посвідчує особу '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' Паспорт громадянина України, ІD картка, свідоцтво про народження тощо'
                             END      AS x_text                            --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP', 'FM')
                      UNION ALL
                      --В документі з Ід=10312  обов’язково мають бути заповненими всі атрибути.
                      SELECT pd_id     AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 10312,
                                 '8433,8434,8430,8431,8432',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd
                      UNION ALL
                      --В документах з Ід=37, 7, 673, 6, 8, 9, 13, 11 має бути обов’язково зазначена дата нарожження.
                      SELECT pd_id           AS x_id,
                             API$CALC_RIGHT.check_docx_list_class (
                                 pd_id,
                                 tpp_sc,
                                 '37,7,673,6,8,9,13,11',
                                 'BDT',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd
                      UNION ALL
                      --В документі з Ід=98  обов’язково бути заповненими атрибути щодо періоду навчання і форма навчання.
                      SELECT pd_id                                   AS x_id,
                             API$CALC_RIGHT.check_docx_filled (pd_id,
                                                               tpp_sc,
                                                               98,
                                                               '687,688,690',
                                                               calc_dt,
                                                               0)    AS Err
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd
                      UNION ALL
                      --В документі з Ід=200  обов’язково мають бути заповненими всі атрибути.
                      SELECT pd_id     AS x_id,
                             api$calc_right.check_docx_filled (
                                 pd_id,
                                 tpp_sc,
                                 200,
                                 '792,793,797,804',
                                 calc_dt,
                                 0)
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        /*
        В документі з Ід=10312  обов’язково мають бути заповненими всі атрибути.
        В документах з Ід=37, 7, 673, 6, 8, 9, 13, 11 має бути обов’язково зазначена дата нарожження.
        В документі з Ід=98  обов’язково бути заповненими атрибути щодо періоду навчання і форма навчання.
        В документі з Ід=200  обов’язково мають бути заповненими всі атрибути.
        */

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_23 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        -- наявність обов'язкового документу "Копія договору про умови запровадження патронату" (NDT_ID 10204)
        -- наявність звернення за послугою "Надання послуги патронату на дитиною" (NST_ID 1201) (нульовий договір)
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count_ (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                        'До звернення не долучено документ, що посвідчує особу Заявника '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' Паспорт громадянина України, ІD картка тощо'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_241 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
          Але для правила "Обов'язкові документи надано"
          система перевіряє наявність для учасника звернення з типом "Померла особа" документа
          "Свідоцтво про смерть" (NDT_ID 10140) та
          "Витяг з ДРАЦC про смерть для отримання допомоги на поховання" (NDT_ID 10295).*/

        /*
        - "Витяг з ДРАЦ про смерть для отримання допомоги на поховання" (NDT_ID 10295),

        - "Свідоцтво РАГС про смерть" (NDT_ID 89), альтернативними документами для якого є:
        "Довідка про смерть особи" (NDT_ID 10300);
        "Довідка про смерть особи (видана за межами України)" (NDT_ID 10296).
        */

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_list_cnt (
                                          tpp_pd,
                                          tpp_sc,
                                          '89,10296,10300',
                                          calc_dt) = 0
                                 THEN
                                     'До звернення не долучено документ "Свідоцтво РАГС про смерть" або "Довідка про смерть особи" або "Довідка про смерть особи (видана за межами України)"'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('DP')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  10295,
                                                                  calc_dt) = 0
                                 THEN
                                     'До звернення не долучено документ "Витяг з ДРАЦC про смерть для отримання допомоги на поховання"'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('DP'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_248 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd AS x_id, 'Не вказано заявника' AS x_text                  --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z')
                      UNION ALL
                      SELECT p_pd                                                  AS x_id,
                             API$CALC_RIGHT.check_docx_filled_600 (p_pd,
                                                                   tpp_sc,
                                                                   app.calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z'
                      UNION ALL
                      --2.  Свідоцтво про народження  дитини  Утриманець
                      --Атрибути: серія №, дата видачі, орган видачі, батьки дитини, дата народження
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 37,
                                 '90,94,93,679,680,91',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     api$calc_right.get_docx_list_cnt (
                                              p_pd,
                                              app_sc,
                                              '37,673,7',
                                              calc_dt) = 0
                                      AND AgeYear >= 12
                                 THEN
                                        'Відсутні жодний з документів: '
                                     || 'або "Свідоцтво про народження дитини"  '
                                     || 'або "Легалізований документ про народження  дитини від компетентного органу іноземної держави " '
                                     || 'або "ID картка" '
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     api$calc_right.get_docx_list_cnt (
                                              p_pd,
                                              app_sc,
                                              '37,673',
                                              calc_dt) = 0
                                      AND AgeYear < 12
                                 THEN
                                        'Відсутні жодний з документів: '
                                     || 'або "Свідоцтво про народження дитини"  '
                                     || 'або "Легалізований документ про народження  дитини від компетентного органу іноземної держави "'
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP'
                      UNION ALL
                      --3.  Рішення суду про усиновлення  Підтип заявника = Усиновлювач
                      --Атрибути: серія, номер, дата видачі, дата набрання законної сили рішення, ПІБ усиновлених дітей, обирається із списку учасників звернення
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 114,
                                 '705,704,708,709',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND L_Z.Adopter = 'T'
                      UNION ALL
                      --5.exists  Рішення органу опіки та піклування Підтип заявника = опікун або піклувальник
                      SELECT p_pd
                                 AS x_id,
                             'Не вказано рішення органу опіки та піклування або рішення суду про встановлення опіки чи піклування над дитиною'
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND (L_Z.Guardian = 'T'                  --опікун
                                                     OR L_Z.Trustee = 'T' --піклувальник
                                                                         )
                             AND api$calc_right.get_docx_list_cnt (p_pd,
                                                                   tpp_sc,
                                                                   '81,660',
                                                                   calc_dt) = 0
                      UNION ALL
                      --5.1  Рішення органу опіки та піклування Підтип заявника = опікун або піклувальник
                      --Атрибути: номер, дата видачі, ПІБ підопічного, обирається із списку учасників звернення, дата встановлення опіки
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 81,
                                 '193,195,774,775',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND (L_Z.Guardian = 'T'                  --опікун
                                                     OR L_Z.Trustee = 'T' --піклувальник
                                                                         )
                      UNION ALL
                      --5.2 Рішення суду про встановлення опіки чи піклування над дитиною Підтип заявника = опікун або піклувальник
                      --Атрибути: номер, дата видачі, дата набрання законної сили рішення, ПІБ підопічного, обирається із списку учасників звернення
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 660,
                                 '712,711,715,716',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND (L_Z.Guardian = 'T'                  --опікун
                                                     OR L_Z.Trustee = 'T' --піклувальник
                                                                         )
                      UNION ALL
                      --6. Рішення про влаштування дитини до дитячого будинку або прийомної сім’ї Підтип заявника = Один з батьків-вихователів/прийомних батьків
                      --Атрибути: номер, дата видачі, ПІБ підопічного, обирається із списку учасників звернення, дата влаштування дитини до дитячого будинку або прийомної сім’ї
                      SELECT p_pd
                                 AS x_id,
                             'Не вказано рішення про влаштування дитини до дитячого будинку або прийомної сім’ї'
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND L_Z.Еducator = 'T'  --Один з батьків-вихователів/прийомних батьків
                             AND api$calc_right.get_docx_list_cnt (p_pd,
                                                                   tpp_sc,
                                                                   '661,662',
                                                                   calc_dt) = 0
                      UNION ALL
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 661,
                                 '719,718,723,722',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND L_Z.Еducator = 'T'  --Один з батьків-вихователів/прийомних батьків
                      UNION ALL
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 662,
                                 '726,725,730,729',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND L_Z.Еducator = 'T'  --Один з батьків-вихователів/прийомних батьків
                      UNION ALL
                      -- Довідка  про потребу дитини (дитини з інвалідністю) у домашньому догляді
                      SELECT p_pd                                    AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               tpp_sc,
                                                               676,
                                                               '772',
                                                               calc_dt,
                                                               1)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND L_Z.NotSalary = 'T'
                      UNION ALL
                      --#74290 2021.12.22
                      SELECT pd_id     AS x_id,
                                'Відсутні документи, які підтверджують, що особа знаходиться на держутриманні:'
                             || CASE
                                    WHEN     x_errors_10033 IS NOT NULL
                                         AND x_errors_10034 IS NULL
                                         AND x_errors_10033_ap IS NOT NULL
                                    THEN
                                        x_errors_10033
                                    WHEN     x_errors_10033 IS NULL
                                         AND x_errors_10034 IS NOT NULL
                                    THEN
                                        x_errors_10034
                                    ELSE
                                           x_errors_10033
                                        || ', '
                                        || x_errors_10034
                                END    AS x_errors_list
                        FROM (SELECT API$CALC_RIGHT.check_docx_exists (pd_id,
                                                                       app_sc,
                                                                       10033,
                                                                       calc_dt)
                                         AS x_errors_10033,
                                     API$CALC_RIGHT.check_docx_exists (pd_id,
                                                                       NULL,
                                                                       10033,
                                                                       calc_dt)
                                         AS x_errors_10033_ap,
                                     API$CALC_RIGHT.check_docx_exists (pd_id,
                                                                       app_sc,
                                                                       10034,
                                                                       calc_dt)
                                         AS x_errors_10034,
                                     pd_id
                                FROM TABLE (API$ANKETA.get_Anketa)
                               WHERE pd_id = p_pd AND MainTenance = 'T')
                       WHERE    (    x_errors_10033 IS NOT NULL
                                 AND x_errors_10033_ap IS NOT NULL)
                             OR x_errors_10034 IS NOT NULL
                      /*
                      select p_pd as x_id, API$CALC_RIGHT.check_documents_exists(app_id, 10033) AS x_errors_list --10033"Заява про перерахування коштів на банківський рахунок закладу держутримання"
                      from table(API$ANKETA.get_Anketa)
                      where pd_id = p_pd AND MainTenance = 'T'
                      UNION ALL
                      select p_pd as x_id, API$CALC_RIGHT.check_documents_exists(app_id, 10034) AS x_errors_list --10034"Довідка про зарахувння особи на повне державне утримання" та
                      from table(API$ANKETA.get_Anketa)
                      where pd_id = p_pd AND MainTenance = 'T'
                      */
                      --#74338  2021.12.23
                      UNION ALL
                      SELECT p_pd                                         AS x_id,
                             API$CALC_RIGHT.check_248x_10040 (p_pd,
                                                              app_sc,
                                                              10040,
                                                              calc_dt)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND DisabilityChildNPP = 'T'
                      ----------------------------Новое, от перехода на один  запрос
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN AgeYear < 0
                                 THEN
                                     'Не можливо визначити вік за відсутністью дати народження в паспорті або id карті'
                                 --#73563 2021.11.30
                                 WHEN (   (    DisabilityState = 'I'
                                           AND DisabilityReason = 'ID')
                                       OR DisabilityState = 'IZ')
                                 THEN
                                     api$calc_right.check_docx_201 (pd_id,
                                                                    app_sc,
                                                                    calc_dt,
                                                                    1)
                                 ELSE
                                     ''
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'Z'
                      UNION ALL
                      /*
                      Система не призначає допомогу по послузі з Ід=248, якщо в документі з Ід= 201 зазначено причину іншу причину ніж "Інвалідність з дитинства".
                      Необхідно додати контроль під час визначення права щоб користувач бачив причину чому система не призначає допомогу.
                      Для правила "Обов'язкові документи надано" для послуги з Ід=248, у випадку, якщо в складі документів звернення наявний документ з Ід=201, перевіряти в атрибуті з Ід= 353 причину, якщо принина не дорівнює "Інвалідність з дитинства", то помилка і видавати повідомлення про помилку з тестом:
                      "У документі "Виписка з акту огляду МСЕК" зазначену причину інвалідності відмінну від "Інвалідність з дитинства"
                      */
                      --#87957
                      SELECT pd_id    AS x_id,
                             CASE
                                 WHEN     api$account.get_docx_count (pd_id,
                                                                      app_sc,
                                                                      201,
                                                                      calc_dt) >
                                          0
                                      AND api$calc_right.get_docx_string (
                                              pd_id,
                                              app_sc,
                                              201,
                                              353,
                                              calc_dt,
                                              '-') != 'ID'
                                 THEN
                                     'У документі "Виписка з акту огляду МСЕК" зазначену причину інвалідності відмінну від "Інвалідність з дитинства"'
                                 ELSE
                                     ''
                             END      AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd
                      UNION ALL
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 app_sc,
                                 89,
                                 '217,219,786,222,807',
                                 calc_dt,
                                 0)    AS Err
                        FROM TABLE (API$ANKETA.get_Anketa) z
                       WHERE     pd_id = p_pd
                             AND app_tp = 'Z'
                             AND EXISTS
                                     (SELECT 1
                                        FROM TABLE (API$ANKETA.get_Anketa) fp
                                       WHERE     fp.pd_id = p_pd
                                             AND fp.app_tp = 'FP'
                                             AND fp.AgeYear BETWEEN 0 AND 18)
                             AND NotSalary = 'T'
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN Alone <> 'T' OR Disability = 'T'
                                 THEN
                                     ''
                                 WHEN     Alone = 'T'
                                      AND Disability <> 'T'
                                      AND (  api$account.get_docx_count (
                                                 p_pd,
                                                 app_sc,
                                                 10039,
                                                 calc_dt)
                                           + api$account.get_docx_count (
                                                 p_pd,
                                                 app_sc,
                                                 89,
                                                 calc_dt)) > 0
                                 THEN
                                     ''
                                 WHEN     Alone = 'T'
                                      AND Disability <> 'T'
                                      AND NOT EXISTS
                                              (SELECT 1
                                                 FROM ap_person app
                                                WHERE     app.app_ap = app_ap
                                                      AND app.app_tp = 'FP'
                                                      AND app.history_status =
                                                          'A'
                                                      AND api$account.get_docx_count (
                                                              p_pd,
                                                              app_sc,
                                                              663,
                                                              calc_dt) = 0)
                                 THEN
                                     ''
                                 ELSE
                                        'Відсутні документи "Витяг з Державного реєстру актів цивільного стану про народження дитини"'
                                     || ', або "Свідоцтво РАГС про смерть", або "Рішення суду про позбавлення батьківських прав"'
                                     || ', які підтверджують, що особа Заявник є одинокою/одиноким'
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'Z'
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN AgeYear < 0
                                 THEN
                                     'Не можливо визначити вік за відсутністью дати народження в свідоцтві о народженні'
                                 WHEN api$calc_right.get_docx_string (p_pd,
                                                                      app_sc,
                                                                      200,
                                                                      796,
                                                                      calc_dt,
                                                                      '-') =
                                      'DI'
                                 THEN                      --#73563 2021.11.30
                                     api$calc_right.check_docx_filled (
                                         p_pd,
                                         app_sc,
                                         200,
                                         '792,793,797,804',
                                         calc_dt,
                                         1)
                                 ELSE
                                     ''
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 app_sc,
                                 98,
                                 '247,249,248,690,687,688,689',
                                 calc_dt)    AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE     pd_id = p_pd
                             AND app_tp = 'FP'
                             AND AgeYear BETWEEN 14 AND 18
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     AgeYear BETWEEN 0 AND 18
                                      AND L_Z.Alone = 'T'
                                      AND L_Z.Widow = 'F'
                                 THEN
                                     API$CALC_RIGHT.check_docx_filled_val (
                                         p_pd,
                                         app_sc,
                                         663,
                                         '697,701,699,700,702,684',
                                         ',,,,,T',
                                         calc_dt,
                                         0)
                                 ELSE
                                     ''
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     AgeYear BETWEEN 0 AND 18
                                      AND L_Z.Alone = 'T'
                                      AND L_Z.Widow = 'F'
                                 THEN
                                     API$CALC_RIGHT.check_docx_filled_val (
                                         p_pd,
                                         app_sc,
                                         672,
                                         '753,757,755,756,760',
                                         ',,,,T',
                                         calc_dt,
                                         0)
                                 ELSE
                                     ''
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     AgeYear BETWEEN 0 AND 18
                                      AND L_Z.Alone = 'T'
                                      AND L_Z.Widow = 'F'
                                 THEN
                                     API$CALC_RIGHT.check_docx_filled_val (
                                         p_pd,
                                         app_sc,
                                         673,
                                         '761,765,763,764,768',
                                         ',,,,T',
                                         calc_dt,
                                         0)
                                 ELSE
                                     ''
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     api$calc_right.get_docx_list_cnt (
                                              p_pd,
                                              app_sc,
                                              '663,672,673',
                                              calc_dt) = 0
                                      AND AgeYear BETWEEN 0 AND 18
                                      AND L_Z.Alone = 'T'
                                      AND L_Z.Widow = 'F'
                                 THEN
                                        'Відсутні жодний з документів: '
                                     || 'або "Витяг з Державного реєстру актів цивільного стану громадян про державну реєстрацію народження дитини, виданий відділом державної реєстрації актів цивільного стану"  '
                                     || 'або "Довідка про народження, видана виконавчим органом сільської, селищної, міської (крім міст обласного значення) рад" '
                                     || 'або "Документ про народження, виданий компетентним органом іноземної держави, в якому відсутні відомості про батька, за умови його легалізації в установленому законодавством порядку" '
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd      AS x_id,
                                'Для послуги "Державна соціальна допомога інвалідам з дитинства та дітям-інвалідам" для учасника звернення '
                             || Uss_Person.Api$sc_Tools.Get_Pib (App_Sc)
                             || ' не прикріплено документ: '
                             || CASE
                                    WHEN (   (    Disabilitystate = 'I'
                                              AND Disabilityreason = 'ID')
                                          OR Disabilitystate = 'IZ')
                                    THEN
                                        Api$calc_Right.Check_Docx_Exists (
                                            p_pd,
                                            app_sc,
                                            201,
                                            calc_dt)
                                    WHEN Disabilitystate = 'DI'
                                    THEN
                                        Api$calc_Right.Check_Docx_Exists (
                                            p_pd,
                                            app_sc,
                                            200,
                                            calc_dt)
                                END    AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE     pd_id = p_pd
                             AND (   (    Disabilitystate = 'I'
                                      AND Disabilityreason = 'ID')
                                  OR Disabilitystate = 'IZ'
                                  OR Disabilitystate = 'DI')
                             AND   api$account.Get_Docx_Count (p_pd,
                                                               app_sc,
                                                               201,
                                                               calc_dt)
                                 + api$account.Get_Docx_Count (p_pd,
                                                               app_sc,
                                                               200,
                                                               calc_dt) < 1)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        /*
        7. Виписка з акту огляду МСЕК Вік заявника >18 років (вік визначається за датою народження у одному з документів «Паспорт громадянина України» або «ID картка») Атрибути: серія та номер документа, дата видачі, група інвалідності, підгрупа інвалідності, дата огляду, дата встановлення інвалідності, встановлено на період по, причина інвалідності, потребує постійного стороннього догляду
        8. Медичний висновок (для дітей з інвалідністю до 18 років) Утриманець віком <=18 років Атрибути: Серія та номер документа, Дата видачі, Дата огляду, Дата встановлення інвалідності, Встановлено на період до, Категорія, Причина
        9. Довідка про навчання Утриманець віком <=18 років Атрибути: серія та номер документа, дата видачі, ким видано, Початок періоду навчання, Кінець періоду навчання, Форма навчання (денна, дуальна, заочна), На повному державному утриманні (так/ні).
        10.1. Витяг з Державного реєстру актів цивільного стану громадян про державну реєстрацію народження дитини, виданий відділом державної реєстрації актів цивільного стану. Підтип заявника=Одинокий/одинока, заявник не вдова,
        є Утриманець віком <=18 років Атрибути: № витягу, дата витягу, орган видачі, дитина (з переліку утриманців), батьки дитини, запис про батька згідно ч.1 статті 135 (так)
        10.2. Довідка про народження, видана виконавчим органом сільської, селищної, міської (крім міст обласного значення) рад, із зазначенням підстави внесення відомостей про батька дитини до актового запису про народження дитини відповідно до абзацу першого частини першої статті 135 Сімейного кодексу України  Підтип заявника=Одинокий/одинока,  заявник не вдова,
        є Утриманець віком <=18 років Атрибути: № довідки, дата довідки, орган видачі, дитина (з переліку утриманців), запис про батька згідно ч.1 статті 135 (так)
        10.3. Легалізований документ про народження від компетентного органу іноземної держави в якому відсутні відомості про батька; Підтип заявника=Одинокий/одинока, заявник не вдова, є Утриманець віком <=18 років Атрибути: № довідки, дата довідки, орган видачі, дитина (з переліку утриманців), запис про батька відсутній (так)
        11. Довідка  про потребу дитини (дитини з інвалідністю) у домашньому догляді  В Анкеті «Перебуває у відпустці без збереження заробітної плати»=так
          Атрибути: Дата видачі довідки, ПІБ дитини, Дата народження дитини, Дата набуття статусу «дитина з інвалідністю», Дата, з якої дитина потребує домашнього догляду, Довідка  дійсна до
        */
        /*    For b in Check_FP_Age loop
              MERGE_tmp_errors_list(p_pd,b.Err_Text);
              IsBeby := IsBeby + b.IsBeby;
            end loop;
        */
        /*
        10.4. Свідоцтво РАГС про смерть Підтип заявника=Одинокий/одинока, заявник вдова, є Утриманець віком <=18 років  Атрибути: № довідки, дата довідки, орган видачі, ПІБ особи, дата смерті.
        */
        /*    For b in Check_Z_Age loop
              MERGE_tmp_errors_list(p_pd,b.Err_Text);
            end loop;
        */



        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_249 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   api$anketa.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (--1.Заява;  Одинока/одинокий, ІД послуги =267
                      SELECT p_pd AS x_id, 'Не вказано заявника' AS x_text                  --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z')
                      UNION ALL
                      SELECT p_pd                                              AS x_id,
                             API$CALC_RIGHT.check_docx_filled_600 (p_pd,
                                                                   tpp_sc,
                                                                   calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z'
                      /*              UNION ALL
                                    SELECT x_id, 'Не одинока/одинокий' AS x_text          --1
                                    FROM  tmp_work_ids
                                          inner join v_tmp_person_for_decision app on app.pd_id = x_id and app_tp = 'Z'
                                    WHERE L_Z.Alone='F' --стан не Одинока/одинокий*/
                      UNION ALL
                      --2.exists
                      /*
                                    SELECT p_pd as x_id, 'Не вказано жодного утриманця'
                                    FROM dual
                                    WHERE NOT EXISTS (SELECT 1
                                                      FROM v_tmp_person_for_decision app
                                                      WHERE app.pd_id = p_pd  AND tpp_app_tp = 'FP')
                                    UNION ALL
                      */
                      SELECT p_pd                                           AS x_id,
                                'Для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' відсутній жодний з документів: '
                             || 'або "Паспорт громадянина України"  '
                             || 'або "ІD картка" '
                             || 'або "Свідоцтво про народження дитини" '    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND api$calc_right.get_docx_list_cnt (
                                     p_pd,
                                     tpp_sc,
                                     '6,7,8,37,673',
                                     calc_dt) = 0
                      UNION ALL
                      SELECT p_pd                                    AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               tpp_sc,
                                                               6,
                                                               '3,5,7,606',
                                                               calc_dt,
                                                               0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd
                      UNION ALL
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 7,
                                 '9,10,13,14,607',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd
                      UNION ALL
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 37,
                                 '90,94,93,679,680,91',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd
                      UNION ALL
                      --3. Декларація про доходи та майновий стан осіб, які звернулися за призначенням усіх видів соціальної допомоги, що складається за формою, затвердженою Мінсоцполітики (в декларації зазначається інформація про склад сім’ї заявника); Ід послуги = 267
                      SELECT p_pd                                              AS x_id,
                             'Не вказано декларацію про доходи та майновий'    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND api$account.get_docx_count (p_pd,
                                                             tpp_sc,
                                                             671,
                                                             calc_dt) = 0
                      UNION ALL
                      SELECT p_pd                                 AS x_id,
                             api$calc_right.check_docx_201 (p_pd,
                                                            app_sc,
                                                            calc_dt,
                                                            1)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE     pd_id = p_pd
                             AND app_tp IN ('Z', 'FM')
                             AND DisabilityState IN ('I', 'IZ'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_250 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        l_BD_dt   DATE;
    BEGIN
        SELECT MAX (COALESCE (api$calc_right.get_docx_dt (tpp_pd,
                                                          tpp_sc,
                                                          37,
                                                          91,
                                                          calc_dt),
                              api$calc_right.get_docx_dt (tpp_pd,
                                                          tpp_sc,
                                                          673,
                                                          762,
                                                          calc_dt)))    AS BD_dt
          INTO l_BD_dt
          FROM v_tmp_person_for_decision app
         WHERE tpp_pd = p_pd AND tpp_app_tp NOT IN ('Z');

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN    l_BD_dt IS NULL
                                      OR ABS (
                                             MONTHS_BETWEEN (app.calc_dt,
                                                             l_BD_dt)) >
                                         12
                                 THEN
                                        'Допомога при народженні дитини призначається якщо звернення надійшло не пізніше ніж '
                                     || 'за 12 календарних місяців після народження дитини.'
                                     || app.calc_dt
                                     || '  '
                                     || l_BD_dt
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z')
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_265 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd AS x_id, 'Не вказано заявника' AS x_text                  --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z')
                      UNION ALL
                      SELECT p_pd                                              AS x_id,
                             API$CALC_RIGHT.check_docx_filled_600 (p_pd,
                                                                   tpp_sc,
                                                                   calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z'
                      UNION ALL
                      --2.exists
                      SELECT p_pd AS x_id, 'Не вказано ні одного утриманця'
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP')
                      UNION ALL
                      --2.  Свідоцтво про народження  дитини  Утриманець
                      --Атрибути: серія №, дата видачі, орган видачі, батьки дитини, дата народження
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 37,
                                 '90,94,93,679,680,91',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd                                    AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               tpp_sc,
                                                               673,
                                                               '762',
                                                               calc_dt,
                                                               0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd                                    AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               tpp_sc,
                                                               7,
                                                               '607',
                                                               calc_dt,
                                                               0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      /*
                      1)Зараз під час розрахунку допомоги по послузі з ІД=265 для утриманця (Ступінь родинного зв'язку: Син/донька, Підопічний/підопічна, Усиновлений/усиновлена) визначено обов'язковий документ свідоцтво про народження видане в Україні - документ з Ід=37.
                      Згідно задачі https://redmine.med/issues/95286 будуть додані альтернативні документи з Ід=673 і з Ід=7.
                      Необхідно під час розрахунку враховувати дату народження з альтернативних документів, а саме,
                      з документу з Ід=673 (Свідоцтво про народження дитини (видане за межами України)) атрибут з Ід= 762
                      з документу з Ід=7 (ID картка) атрибут з Ід=607
                      2)Крім того, у правилі "Обов'язкові документи додано" змінити контроль щодо обов'язкового документу для "Утриманця"
                      Для тестування звернення 1000000000230000043396 на Соні (після того як Богдан зробить задачу https://redmine.med/issues/95286)
                      */
                      SELECT p_pd    AS x_id,
                             CASE API$CALC_RIGHT.get_docx_list_cnt (p_pd,
                                                                    tpp_sc,
                                                                    '37,673,7',
                                                                    calc_dt)
                                 WHEN 0
                                 THEN
                                        'для утриманця повинен бути один з документів: '
                                     || 'Свідоцтво про народження дитини, '
                                     || 'Свідоцтво про народження дитини (видане за межами України), '
                                     || 'ID картка.'
                                 ELSE
                                     ''
                             END     AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      --3.  Довідка про захворювання дитини (форма № 080-3/о) Утриманець
                      --Атрибути: номер, дата видачі довідки, ПІБ дитини, дата народження дитини, дата, до якої довідка дійсна.
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 669,
                                 '691,693,696,805,695',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      --4.  Рішення суду про усиновлення  Підтип заявника = Усиновлювач
                      --Атрибути: серія, номер, дата видачі, дата набрання законної сили рішення, ПІБ усиновлених дітей, обирається із списку учасників звернення
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 114,
                                 '705,704,708,709',
                                 calc_dt,
                                 1)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 644,
                                                                 calc_dt,
                                                                 'F') = 'T'
                      UNION ALL
                      --5.1  Рішення органу опіки та піклування Підтип заявника = опікун або піклувальник
                      --Атрибути: номер, дата видачі, ПІБ підопічного, обирається із списку учасників звернення, дата встановлення опіки
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 81,
                                 '193,195,774,775',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND (L_Z.Guardian = 'T'                  --опікун
                                                     OR L_Z.Trustee = 'T' --піклувальник
                                                                         )
                      UNION ALL
                      --5.2 Рішення суду про встановлення опіки чи піклування над дитиною Підтип заявника = опікун або піклувальник
                      --Атрибути: номер, дата видачі, дата набрання законної сили рішення, ПІБ підопічного, обирається із списку учасників звернення
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 660,
                                 '712,711,715,716',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND (L_Z.Guardian = 'T'                  --опікун
                                                     OR L_Z.Trustee = 'T' --піклувальник
                                                                         )
                      UNION ALL
                      --6. Рішення про влаштування дитини до дитячого будинку або прийомної сім’ї Підтип заявника = Один з батьків-вихователів/прийомних батьків
                      --Атрибути: номер, дата видачі, ПІБ підопічного, обирається із списку учасників звернення, дата влаштування дитини до дитячого будинку або прийомної сім’ї
                      SELECT p_pd
                                 AS x_id,
                             'Не вказано рішення про влаштування дитини до дитячого будинку або прийомної сім’ї'
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND L_Z.Еducator = 'T'  --Один з батьків-вихователів/прийомних батьків
                             AND api$calc_right.get_docx_list_cnt (p_pd,
                                                                   tpp_sc,
                                                                   '661,662',
                                                                   calc_dt) = 0
                      UNION ALL
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 661,
                                 '719,718,723,722',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND L_Z.Еducator = 'T'  --Один з батьків-вихователів/прийомних батьків
                      UNION ALL
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 662,
                                 '726,725,730,729',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND L_Z.Еducator = 'T'  --Один з батьків-вихователів/прийомних батьків
                                                    )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_267 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (  --1.Заява;  Одинока/одинокий, ІД послуги =267
                        SELECT pd_id    AS x_id,
                               CASE COUNT (1)
                                   WHEN 0 THEN 'Не вказано заявника'
                                   ELSE ''
                               END      AS x_text                                           --1
                          FROM TABLE (API$ANKETA.get_Anketa)
                         WHERE pd_id = p_pd AND app_tp = 'Z'
                      GROUP BY pd_id
                      UNION ALL
                      SELECT p_pd                                              AS x_id,
                             API$CALC_RIGHT.check_docx_filled_600 (p_pd,
                                                                   app_sc,
                                                                   calc_dt)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'Z'
                      UNION ALL
                      SELECT p_pd AS x_id, 'Не одинока/одинокий' AS x_text                  --1
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'Z' AND Alone = 'F' --стан не Одинока/одинокий
                      UNION ALL
                        --2.exists
                        SELECT pd_id    AS x_id,
                               CASE COUNT (1)
                                   WHEN 0 THEN 'Не вказано жодного утриманця'
                                   ELSE ''
                               END      AS x_text                                                   --1
                          FROM TABLE (API$ANKETA.get_Anketa)
                         WHERE pd_id = p_pd AND app_tp = 'FP'
                      GROUP BY pd_id
                      UNION ALL
                      --2.  Свідоцтво про народження  дитини  Утриманець
                      --Атрибути: серія №, дата видачі, орган видачі, батьки дитини, дата народження
                      SELECT pd_id           AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 app_sc,
                                 37,
                                 '90,94,93,679,680,91',
                                 calc_dt)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE     pd_id = p_pd
                             AND app_tp = 'FP'
                             AND ChildBornNotUA = 'F'
                      UNION ALL
                      --2.1  Якщо в анкеті (Ід=605) в атрибуті Ід=871 зазначено "так", то НЕ вимагати щодо дитини (тип учасника звенення "Утриманець") документ
                      --     свідоцтва про народження в Україні (Ід=37), але вимагати щодо дитини документ з Ід=673.
                      --Атрибути: дата народження
                      SELECT pd_id                                         AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               app_sc,
                                                               673,
                                                               '762',
                                                               calc_dt)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE     pd_id = p_pd
                             AND app_tp = 'FP'
                             AND ChildBornNotUA = 'T'
                      UNION ALL
                      --Задача #72575
                      --якщо в атрибутах Анкети Заявника встановлено відмітку "Доглядає за дитиною до 6-ти років" = "Так"
                      --то перевіряти наявність документа "Довідка про період догляду за дитиною до 6-ти років"
                      --та обов'язкового заповнення атрибутів "Початок періоду догляду з" та "Кінець періоду догляду"
                      SELECT p_pd                                          AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               app_sc,
                                                               10029,
                                                               '875,876',
                                                               calc_dt)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE     pd_id = p_pd
                             AND app_tp = 'Z'
                             AND CaringChildUnder6 = 'T'
                      UNION ALL
                      --3. Декларація про доходи та майновий стан осіб, які звернулися за призначенням усіх видів соціальної допомоги, що складається за формою, затвердженою Мінсоцполітики (в декларації зазначається інформація про склад сім’ї заявника); Ід послуги = 267
                      SELECT p_pd                                              AS x_id,
                             'Не вказано декларацію про доходи та майновий'    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE     pd_id = p_pd
                             AND app_tp = 'Z'
                             AND api$account.get_docx_count (p_pd,
                                                             app_sc,
                                                             671,
                                                             calc_dt) = 0
                      UNION ALL
                      --4.exists
                      SELECT p_pd                                                                                                                                                                                            AS x_id,
                                'Відсутні жодний з документів: '
                             || 'або "Витяг з Державного реєстру актів цивільного стану громадян про державну реєстрацію народження дитини, виданий відділом державної реєстрації актів цивільного стану"  '
                             || 'або "Довідка про народження, видана виконавчим органом сільської, селищної, міської (крім міст обласного значення) рад" '
                             || 'або "Документ про народження, виданий компетентним органом іноземної держави, в якому відсутні відомості про батька, за умови його легалізації в установленому законодавством порядку" '    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa) t
                       WHERE     pd_id = p_pd
                             AND app_tp = 'FP'
                             AND L_Z.Widow = 'F'            --Не Вдова/вдівець
                             AND api$calc_right.get_docx_list_cnt (
                                     p_pd,
                                     app_sc,
                                     '663,672,673',
                                     calc_dt) = 0
                      UNION ALL
                      --4.1. Витяг з Державного реєстру актів цивільного стану громадян про державну реєстрацію народження дитини, виданий відділом державної реєстрації актів цивільного стану.  Утриманець, заявник не вдова
                      --Атрибути: № витягу, дата витягу, орган видачі, дитина (з переліку утриманців), батьки дитини, запис про батька згідно ч.1 статті 135 (так)
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled_val (
                                 p_pd,
                                 app_sc,
                                 663,
                                 '697,701,699,700,702,684',
                                 ',,,,,T',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP' AND L_Z.Widow = 'F' --Не Вдова/вдівець
                      UNION ALL
                      ---4.2. Довідка про народження, видана виконавчим органом сільської, селищної, міської (крім міст обласного значення) рад, із зазначенням підстави внесення відомостей про батька дитини до актового запису про народження дитини відповідно до абзацу першого частини першої статті 135 Сімейного кодексу України Утриманець, заявник не вдова
                      --Атрибути: № довідки, дата довідки, орган видачі, дитина (з переліку утриманців), запис про батька згідно ч.1 статті 135 (так)
                      --759  ПІБ батька --760  Запис про батька згідно ч.1 статті 135"
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled_val (
                                 p_pd,
                                 app_sc,
                                 672,
                                 '753,757,755,756,760',
                                 ',,,,T',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP' AND L_Z.Widow = 'F' --Не Вдова/вдівець
                      UNION ALL
                      --4.3. Документ про народження, виданий компетентним органом іноземної держави, в якому відсутні відомості про батька, за умови його легалізації в установленому законодавством порядку;  Утриманець, заявник не вдова
                      --Атрибути: № довідки, дата довідки, орган видачі, дитина (з переліку утриманців), запис про батька відсутній (так)
                      --767  ПІБ батька  --768  Запис про батька згідно ч.1 статті 135"
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled_val (
                                 p_pd,
                                 app_sc,
                                 673,
                                 '761,765,763,764,768',
                                 ',,,,T',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP' AND L_Z.Widow = 'F' --Не Вдова/вдівець
                      /*
                                    UNION ALL
                                    SELECT p_pd AS x_id, API$CALC_RIGHT.check_documents_filled_val(app_id, 673, '761,765,763,764,768',',,,,T',1) AS x_errors_list
                                    FROM table(API$ANKETA.get_Anketa)
                                    WHERE pd_id = p_pd
                                          AND app_tp = 'FP'
                                          AND ChildBornOutside = 'T' --вік > 14 років
                      */
                      UNION ALL
                      --4.4. Смерть одного з батьків дитини, та неотримання на неї пенсії або державної соціальної допомоги.  заявник вдова
                      --Атрибути: № довідки, дата довідки, орган видачі, ПІБ особи, дата смерті.
                      --89, '217,219,786,222'
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 app_sc,
                                 89,
                                 '217,219,786,222,807',
                                 calc_dt,
                                 1)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'Z' AND Widow = 'T' --Вдова/вдівець
                      UNION ALL
                      --5. Копія рішення про усиновлення  Заявник усиновлювач
                      --Атрибути: серія, номер, дата видачі, дата набрання законної сили рішення, ПІБ усиновлених дітей, обирається із списку учасників звернення
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 app_sc,
                                 114,
                                 '705,704,708,709',
                                 calc_dt)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'Z' AND Adopter = 'T'
                      UNION ALL
                      --6. Довідка закладу освіти про навчання за денною формою Утриманець, вік > 14 років
                      --Атрибути: номер, дата видачі, навчальний заклад, форма навчання, період навчання, розмір стипендії: період 6 місяців, розмір
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 app_sc,
                                 98,
                                 '247,249,248,690,687,688',
                                 calc_dt)    AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP' AND AgeYear >= 14 --вік > 14 років
                      UNION ALL
                      SELECT p_pd                           AS x_id,
                             'Форма навчання не денна.'     AS x_errors_list
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE     pd_id = p_pd
                             AND app_tp = 'FP'
                             AND AgeYear >= 14                --вік > 14 років
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 app_sc,
                                                                 98,
                                                                 690,
                                                                 calc_dt)
                                     IS NULL--
                                            )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_268 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        /*
        Під час перевірки права по послузі з Ід=268,
        для правила "Обов'язкові документи надано" система перевіряє наявність у підопічного документу з Ід=37 (Свідоцтво про народження дитини (місце народження в Україні).
        Необхідно змінити контроль, а саме, у підопічного обов'язково має бути наданий один із документів або документ з Ід=37,
        або документ з Ід=673 (Свідоцтво про народження дитини (видане за межами України)), якщо до звернення не додано один із зазначених документів, то це помилка.
        Текст помилки: Для <ПІБ> не знайдено одного з документів: Свідоцтво про народження дитини (місце народження в Україні або Свідоцтво про народження дитини (видане за межами України)
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd AS x_id, 'Не вказано заявника' AS x_text                  --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z')
                      UNION ALL
                      SELECT p_pd                                              AS x_id,
                             API$CALC_RIGHT.check_docx_filled_600 (p_pd,
                                                                   tpp_sc,
                                                                   calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z'
                      UNION ALL
                      --2.exists
                      SELECT p_pd AS x_id, 'Не вказано ні одного утриманця'
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP')
                      UNION ALL
                      --2.param
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 37,
                                 '90,94,93,679,680,91',
                                 calc_dt,
                                 0)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      --#88179
                      SELECT p_pd
                                 AS x_id,
                                'Для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' не знайдено одного з документів: Свідоцтво про народження дитини (місце народження в Україні '
                             || 'або Свідоцтво про народження дитини (видане за межами України)'
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND api$calc_right.get_docx_list_cnt (p_pd,
                                                                   tpp_sc,
                                                                   '37,673',
                                                                   calc_dt) = 0
                      UNION ALL
                      --3.exists
                      SELECT p_pd
                                 AS x_id,
                             'Не вказано рішення органу опіки та піклування або рішення суду про встановлення опіки чи піклування над дитиною'
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND api$calc_right.get_docx_list_cnt (p_pd,
                                                                   tpp_sc,
                                                                   '81,660',
                                                                   calc_dt) = 0
                      UNION ALL
                      --3.1
                      SELECT p_pd                    AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 81,
                                 '193,195,774,775',
                                 calc_dt,
                                 p_Is_Need   => 0)   AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      --3.2
                      SELECT p_pd                                                  AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               tpp_sc,
                                                               660,
                                                               '712,711,715',
                                                               calc_dt,
                                                               p_Is_Need   => 0)   AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      --4.param
                      SELECT p_pd                                          AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               tpp_sc,
                                                               18,
                                                               '58,59,803',
                                                               calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z'
                      UNION ALL
                      --5.param
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 200,
                                 '792,793,797,804',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 796,
                                                                 calc_dt,
                                                                 'N') = 'T' --стан інвалідності з анкети
                      UNION ALL
                      --6.param
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 98,
                                 '247,249,248,690,687,688,689',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 662,
                                                                 calc_dt,
                                                                 'F') = 'T' --стан Навчається з анкети
                      UNION ALL
                      --7.exists
                      /*
                      507 801 Ким видано
                      507 799 Дата видачі документа
                      507 800 Номер документа
                      507 808 Дані про доходи
                      */
                      SELECT x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 507,
                                 '799,800,801,808',
                                 calc_dt)    AS x_errors_list
                        FROM tmp_work_ids
                             INNER JOIN v_tmp_person_for_decision app
                                 ON app.pd_id = x_id AND tpp_app_tp = 'Z'
                       WHERE EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE     app.pd_id = x_id
                                         AND tpp_app_tp = 'FP'
                                         AND L_Z.CarriedPayments = 'T') --На підопічного здійснюються виплати (аліменти, пенсія, допомога, стипендія)
                      UNION ALL
                      SELECT x_id,
                             API$CALC_RIGHT.Check_Income_Stat (p_pd,
                                                               tpp_sc,
                                                               507,
                                                               808,
                                                               calc_dt)    AS x_errors_list
                        FROM tmp_work_ids
                             INNER JOIN v_tmp_person_for_decision app
                                 ON app.pd_id = x_id AND tpp_app_tp = 'Z'
                       WHERE EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE     app.pd_id = x_id
                                         AND tpp_app_tp = 'FP'
                                         AND L_Z.CarriedPayments = 'T') --На підопічного здійснюються виплати (аліменти, пенсія, допомога, стипендія)
                                                                       )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_269 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT x_id, 'Не вказано заявника' AS x_text
                        FROM tmp_work_ids
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM pc_decision, ap_person app
                                   WHERE     app_ap = pd_ap
                                         AND pd_id = x_id
                                         AND app_tp = 'Z'
                                         AND app.history_status = 'A')
                      UNION ALL
                      SELECT p_pd                                              AS x_id,
                             API$CALC_RIGHT.check_docx_filled_600 (p_pd,
                                                                   tpp_sc,
                                                                   calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z'
                      UNION ALL
                      SELECT x_id, 'Не вказано ні одного утриманця'
                        FROM tmp_work_ids
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM pc_decision, ap_person app
                                   WHERE     app_ap = pd_ap
                                         AND pd_id = x_id
                                         AND app_tp = 'FP'
                                         AND app.history_status = 'A')
                      UNION ALL
                      SELECT p_pd                                          AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               tpp_sc,
                                                               605,
                                                               '644',
                                                               calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE pd_id = p_pd AND tpp_app_tp = 'Z'
                      UNION ALL
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 37,
                                 '90,94,93,679,91,680',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd        AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 114,
                                 '704,705,708,709',
                                 calc_dt,
                                 709)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE pd_id = p_pd AND tpp_app_tp = 'FP')
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    /*
    Документ з категорією 13 для учасника звернення з типом "Заявник", крім свідоцтв про народження NDT_ID=37 або NDT_ID=673,
    якщо відсутній, то видавати повідомлення з типом помилка
    "До звернення не долучено документ, що посвідчує особу Заявника <ПІБ> Паспорт громадянина України, ІD картка тощо"

    Документ "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" NDT_ID=600, якщо відсутній, то видавати повідомлення з типом помилка
    "До звернення не долучено Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг".

    Документ "Свідоцтво про народження" NDT_ID=37 для кожного учасника звернення з типом "Утриманець", якщо відсутній, то видавати повідомлення з типом помилка
    "Для <ПІБ> не долучено документ "Свідоцтво про народження дитини".
    Якщо в документі "Свідоцтво про народження" NDT_ID=37 не заповнене поле "Дата народження", то видавати повідомлення з типом помилка "Для <ПІБ> у документі
    "Свідоцтво про народження дитини" не зазначено дату народження дитини.
    --
    Для заявника, у якого в анкеті в атрибуті "Прийомні батьки (батько/мати)" nda_id=2654 зазначено "так", то обов'язково має бути долучений документ
    "Рішення органу опіки чи піклування про влаштування дитини до прийомної сім'ї" NDT_ID=662,
    прикріплений до кожного "Утриманця", якщо документ відсутній, то видавати повідомлення з типом помилка
    "До звернення не долучено документ "Рішення органу опіки чи піклування про влаштування дитини до прийомної сім'ї".

    Для заявника, у якого в анкеті в атрибуті "Батько/мати-вихователь дитячого будинку сімейного типу" nda_id=1858 зазначено "так", то обов'язково має бути долучений документ "
    Рішення органу опіки чи піклування про влаштування дитини до дитячого будинку сімейного типу"
    " NDT_ID=661, прикріплений до кожного "Утриманця", якщо документ відсутній, то видавати повідомлення з типом помилка
    "До звернення не долучено документ "Рішення органу опіки чи піклування про влаштування дитини до дитячого будинку сімейного типу".


    Для утриманця, у якого в анкеті в атрибуті "Дитина з інвалідністю" nda_id=1797 зазначено "так" або в атрибуті "Статус інвалідності" nda_id=796 зазначено "Дитина з інвалідністю" , то обов'язково має бути долучений документ "Медичний висновок (для дітей з інвалідністю до 18 років)" nda_id=200
    " NDT_ID=200, якщо документ відсутній, то видавати повідомлення з типом помилка
    "Для <ПІБ> до звернення не долучено документ "Медичний висновок (для дітей з інвалідністю до 18 років)".*/
    PROCEDURE Check_ALG1_275 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count_ (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                        'До звернення не долучено документ, що посвідчує особу Заявника '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' Паспорт громадянина України, ІD картка тощо'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  600,
                                                                  calc_dt) = 0
                                 THEN
                                     'До звернення не долучено Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  7,
                                                                  calc_dt) > 0
                                 THEN
                                     API$CALC_RIGHT.check_docx_filled (
                                         p_pd,
                                         tpp_sc,
                                         7,
                                         '9,10,13,14,607',
                                         calc_dt,
                                         0)
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  37,
                                                                  calc_dt) > 0
                                 THEN
                                     Api$calc_Right.check_docx_filled (tpp_pd,
                                                                       tpp_sc,
                                                                       37,
                                                                       '91',
                                                                       calc_dt,
                                                                       1)
                                 ELSE
                                        'Для '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' не знайдено документа з типом Свідоцтво про народження дитини або ID картки'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP')
                      UNION ALL
                      --1858 "EducatorFT",    --"Батько/мати-вихователь дитячого будинку сімейного типу"
                      --2654 "ParentsAdp",    --Прийомні батьки (батько/мати)
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     L_Z.EducatorFT = 'T'
                                      AND api$account.get_docx_cnt_dt_to (
                                              tpp_pd,
                                              tpp_sc,
                                              661,
                                              calc_dt) = 0
                                 THEN
                                     'До звернення не долучено документ "Рішення органу опіки чи піклування про влаштування дитини до прийомної сім''ї"'
                                 WHEN     L_Z.ParentsAdp = 'T'
                                      AND api$account.get_docx_cnt_dt_to (
                                              tpp_pd,
                                              tpp_sc,
                                              662,
                                              calc_dt) = 0
                                 THEN
                                     'До звернення не долучено документ "Рішення органу опіки чи піклування про влаштування дитини до дитячого будинку сімейного типу"'
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     (   L_Z.DisabilityChild = 'T'
                                           OR L_Z.DisabilityState = 'DI')
                                      AND api$account.get_docx_count (tpp_pd,
                                                                      tpp_sc,
                                                                      200,
                                                                      calc_dt) =
                                          0
                                 THEN
                                        'Для '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' до звернення не долучено документ "Медичний висновок (для дітей з інвалідністю до 18 років)'
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_62x (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT x_id, 'Не вказано заявника' AS x_text
                        FROM tmp_work_ids
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM pc_decision, ap_person app
                                   WHERE     app_ap = pd_ap
                                         AND pd_id = x_id
                                         AND app_tp = 'Z'
                                         AND app.history_status = 'A')
                      UNION ALL
                      SELECT p_pd                                              AS x_id,
                             API$CALC_RIGHT.check_docx_filled_600 (p_pd,
                                                                   tpp_sc,
                                                                   calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z'
                      UNION ALL
                      SELECT p_pd AS x_id, 'Не вказано ні одного утриманця'
                        FROM tmp_work_ids
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM pc_decision, ap_person app
                                   WHERE     app_ap = pd_ap
                                         AND pd_id = x_id
                                         AND app_tp = 'FP'
                                         AND app.history_status = 'A')
                      UNION ALL
                      SELECT p_pd                                          AS x_id,
                             API$CALC_RIGHT.check_docx_filled (p_pd,
                                                               tpp_sc,
                                                               605,
                                                               '644',
                                                               calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE pd_id = p_pd AND tpp_app_tp = 'Z'
                      UNION ALL
                      SELECT p_pd            AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 37,
                                 '90,94,93,679,91,680',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE pd_id = p_pd AND tpp_app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd        AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 114,
                                 '704,705,708,709',
                                 calc_dt,
                                 709)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE pd_id = p_pd AND tpp_app_tp = 'FP')
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    /*
    1. Обов'язкові документи надано.
    Документ з категорією 13 для учасника звернення з типом "Заявник", крім свідоцтв про народження NDT_ID=37 або NDT_ID=673,
    якщо відсутній, то видавати повідомлення з типом помилка
    "До звернення не долучено документ, що посвідчує особу Заявника <ПІБ> Паспорт громадянина України, ІD картка тощо"

    Документ "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" NDT_ID=600,
    якщо відсутній, то видавати повідомлення з типом помилка
    "До звернення не долучено Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг".

    Документ "Свідоцтво про народження" NDT_ID=37 для кожного учасника звернення з типом "Утриманець",
    якщо відсутній, то видавати повідомлення з типом помилка
    "Для <ПІБ> не долучено документ "Свідоцтво про народження дитини".

    Документ "Посвідчення батьків багатодітної сім’ї" NDT_ID=10108,
    якщо документ відсутній, то видавати повідомлення з типом помилка "До звернення не долучено документ "Посвідчення батьків багатодітної сім’ї".

    Якщо в документі "Посвідчення батьків багатодітної сім’ї" NDT_ID=10108 не зазначено дату в атрибуті nda_id= 2275,
    то видавати повідомлення з типом помилка "У документ "Посвідчення батьків багатодітної сім’ї" не зазначено дату, до якої діє посвідчення".

    Якщо в документі "Свідоцтво про народження" NDT_ID=37 не заповнене поле "Дата народження", то видавати повідомлення з типом помилка
    "Для <ПІБ> у документі "Свідоцтво про народження дитини" не зазначено дату народження дитини.
    */

    --========================================
    PROCEDURE Check_ALG1_862 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count_ (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                        'До звернення не долучено документ, що посвідчує особу Заявника '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' Паспорт громадянина України, ІD картка тощо'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  600,
                                                                  calc_dt) = 0
                                 THEN
                                     'До звернення не долучено Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     api$calc_right.get_docx_list_cnt (
                                              p_pd,
                                              app_sc,
                                              '37,673,7',
                                              calc_dt) = 0
                                      AND AgeYear >= 12
                                 THEN
                                        'Відсутні жодний з документів: '
                                     || 'або "Свідоцтво про народження дитини"  '
                                     || 'або "Легалізований документ про народження  дитини від компетентного органу іноземної держави " '
                                     || 'або "ID картка" '
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     api$calc_right.get_docx_list_cnt (
                                              p_pd,
                                              app_sc,
                                              '37,673',
                                              calc_dt) = 0
                                      AND AgeYear < 12
                                 THEN
                                        'Відсутні жодний з документів: '
                                     || 'або "Свідоцтво про народження дитини"  '
                                     || 'або "Легалізований документ про народження  дитини від компетентного органу іноземної держави "'
                             END     AS Err
                        FROM TABLE (API$ANKETA.get_Anketa)
                       WHERE pd_id = p_pd AND app_tp = 'FP'
                      UNION ALL
                      SELECT p_pd            AS x_id,
                             --                     Api$calc_Right.check_docx_filled (tpp_pd, tpp_sc, 37, '91', calc_dt,0) AS x_text          --1
                             API$CALC_RIGHT.check_docx_list_class (
                                 pd_id,
                                 tpp_sc,
                                 '37,7,673,6,8,9,13,11',
                                 'BDT',
                                 calc_dt)    AS x_errors_list
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  10202,
                                                                  calc_dt) > 0
                                 THEN
                                     Api$calc_Right.check_docx_filled (tpp_pd,
                                                                       tpp_sc,
                                                                       10202,
                                                                       '2649',
                                                                       calc_dt,
                                                                       0)
                                 ELSE
                                     Api$calc_Right.check_docx_filled (tpp_pd,
                                                                       tpp_sc,
                                                                       10108,
                                                                       '2275',
                                                                       calc_dt,
                                                                       1)
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    /*
    --Документ з категорією 13 для учасника звернення з типом "Заявник", крім свідоцтв про народження NDT_ID=37 або NDT_ID=673, якщо відсутній, то видавати повідомлення з типом помилка "
    --    До звернення не долучено документ, що посвідчує особу Заявника <ПІБ> Паспорт громадянина України, ІD картка тощо"

    --Документ "Заява про призначення усіх видів соціальної допомоги, компенсацій та пільг" NDT_ID=600, якщо відсутній, то видавати повідомлення з типом помилка
    --    "До звернення не долучено Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг".

    --Документ "Свідоцтво про народження" NDT_ID=37 або "ID картка" NDT_ID=7 для кожного учасника звернення з типом "Утриманець", якщо відсутній, то видавати повідомлення з типом помилка
    --     "Для <ПІБ> не долучено документ "Свідоцтво про народження дитини" або "ID картка".
    --Якщо в документі "Свідоцтво про народження" NDT_ID=37 або "ID картка" NDT_ID=7 не заповнене поле "Дата народження", то видавати повідомлення з типом помилка
    --"Для <ПІБ> у документі <назва документу> не зазначено дату народження дитини.

    --Для заявника, у якого в анкеті в атрибуті "Патронатний вихователь" nda_id=2668 зазначено "так",
    --то обов'язково має бути долучений документ "Копія договору про умови запровадження патронату" NDT_ID=10204

    --Для утриманців обов'язково має бути долучений документ NDT_ID=10205 "Копія наказу служби у справах дітей про передачу дитини до сім’ї патронатного вихователя",
    --прикріплений до кожного "Утриманця", якщо документ відсутній, то видавати повідомлення з типом помилка "До звернення не долучено документ
    --"Копія наказу служби у справах дітей про передачу дитини до сім’ї патронатного вихователя" для <ПІБ>".

    --В документі NDT_ID=10205 "Копія наказу служби у справах дітей про передачу дитини до сім’ї патронатного вихователя" має бути обов'язково зазначена дата в атрибуті nda_id=2688 "Дата влаштування дитини у сім’ю патронатного вихователя" має бути зазначена дата, якщо дата відсутня, то видавати повідомлення "Для <ПІБ> в документі "Копія наказу служби у справах дітей про передачу дитини до сім’ї патронатного вихователя" не зазначена "Дата влаштування дитини у сім’ю патронатного вихователя"

    --В документі NDT_ID=10205 "Копія наказу служби у справах дітей про передачу дитини до сім’ї патронатного вихователя" має бути обов'язково зазначена дата в атрибуті nda_id=2689 "День вибуття зі сім'ї патронатного вихователяя" має бути зазначена дата, якщо дата відсутня, то видавати повідомлення "Для <ПІБ> в документі "Копія наказу служби у справах дітей про передачу дитини до сім’ї патронатного вихователя" не зазначена "День вибуття зі сім'ї патронатного вихователя"


    Для утриманця, у якого в анкеті в атрибуті "Дитина з інвалідністю" nda_id=1797 зазначено "так" або в атрибуті "Статус інвалідності" nda_id=796 зазначено "Дитина з інвалідністю" , то обов'язково має бути долучений документ "Медичний висновок (для дітей з інвалідністю до 18 років)" nda_id=200
    " NDT_ID=200, якщо документ відсутній, то видавати повідомлення з типом помилка "Для <ПІБ> до звернення не долучено документ "Медичний висновок (для дітей з інвалідністю до 18 років)".
    */
    PROCEDURE Check_ALG1_901 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count_ (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                        'До звернення не долучено документ, що посвідчує особу Заявника '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' Паспорт громадянина України, ІD картка тощо'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  600,
                                                                  calc_dt) = 0
                                 THEN
                                     'До звернення не долучено Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_list_cnt (
                                          tpp_pd,
                                          tpp_sc,
                                          '37,7,673',
                                          calc_dt) = 0
                                 THEN
                                        'Для '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' не долучено документ "Свідоцтво про народження дитини" або "ID картка"'
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  '37',
                                                                  calc_dt) = 1
                                 THEN
                                     Api$calc_Right.check_docx_filled (tpp_pd,
                                                                       tpp_sc,
                                                                       37,
                                                                       '91',
                                                                       calc_dt,
                                                                       0)
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  '7',
                                                                  calc_dt) = 1
                                 THEN
                                     Api$calc_Right.check_docx_filled (tpp_pd,
                                                                       tpp_sc,
                                                                       7,
                                                                       '607',
                                                                       calc_dt,
                                                                       0)
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  '673',
                                                                  calc_dt) = 1
                                 THEN
                                     Api$calc_Right.check_docx_filled (tpp_pd,
                                                                       tpp_sc,
                                                                       673,
                                                                       '762',
                                                                       calc_dt,
                                                                       0) --761,765,763,764,768
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     L_Z.TeacherFoster = 'T'
                                      AND api$account.get_docx_count (tpp_pd,
                                                                      tpp_sc,
                                                                      10204,
                                                                      calc_dt) =
                                          0
                                 THEN
                                        'До звернення не долучено документ "'
                                     || API$CALC_RIGHT.Get_Doc_Name (10204)
                                     || '"'
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN L_Z.TeacherFoster = 'T'
                                 THEN
                                     Api$calc_Right.check_docx_filled (
                                         tpp_pd,
                                         tpp_sc,
                                         10205,
                                         '2688,2689',
                                         calc_dt,
                                         0)
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     (   L_Z.DisabilityChild = 'T'
                                           OR L_Z.DisabilityState = 'DI')
                                      AND api$account.get_docx_count (tpp_pd,
                                                                      tpp_sc,
                                                                      200,
                                                                      calc_dt) =
                                          0
                                 THEN
                                        'Для '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' до звернення не долучено документ "Медичний висновок (для дітей з інвалідністю до 18 років)'
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG1_1221 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        -- наявність обов'язкового документу "Копія договору про умови запровадження патронату" (NDT_ID 10204)
        -- наявність звернення за послугою "Надання послуги патронату на дитиною" (NST_ID 1201) (нульовий договір)


        Set_Rec_Anketa_Z (p_pd, l_Z);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count_ (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                        'До звернення не долучено документ, що посвідчує особу Заявника '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' Паспорт громадянина України, ІD картка тощо'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')/*
                                                                                UNION ALL
                                                                                SELECT p_pd as x_id,
                                                                                       'Вісутній договір патронатного вихователя ' AS x_text          --1
                                                                                FROM  v_tmp_person_for_decision app
                                                                                WHERE tpp_pd = p_pd
                                                                                      and tpp_app_tp IN ('PV')
                                                                                      AND NOT EXISTS ( SELECT 1
                                                                                                       FROM PERSONALCASE pc
                                                                                                         JOIN appeal a ON a.ap_pc = pc_id -- AND a.ap_reg_dt < app.calc_dt --AND a.ap_st = 'O'
                                                                                                         JOIN ap_service s ON aps_ap = ap_id AND s.aps_nst = 1201 AND s.history_status = 'A'
                                                                                                       WHERE pc.pc_sc = app.tpp_sc
                                                                                                         AND api$appeal.Get_Ap_z_Doc_String(a.ap_id, 605, 2668) = 'T'
                                                                                                     )
                                                                  */
                                                                  )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG2 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
        2. Згідно додаткових відомостей у заяві право має: (Так/Ні)
        Умова для «ТАК»:
        В заяві  атрибут «Пенсію в разі втрати годувальника» - «Ні»
        В заяві атрибут «З особою, від якої маю дитину» -«Не проживаю»
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                         AS x_id,
                             'З особою, від якої маю дитину, проживаю'    AS x_text                                --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 600,
                                                                 672,
                                                                 calc_dt,
                                                                 'N') = 'T' --З особою, від якої маю дитину проживаю
                      UNION ALL
                      SELECT p_pd                                                                AS x_id,
                             'Отримую пенсію в разі втрати годувальника або соціальну пенсію'    AS x_text                                                       --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 600,
                                                                 672,
                                                                 calc_dt,
                                                                 'N') = 'T' --З особою, від якої маю дитину проживаю
                                                                           )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG3 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                                                                   AS x_id,
                                uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' не має права на допомогу на дітей одиноким матерям в зв’язку із тим, що отримує пенсію по втраті годувальника'    AS x_text                                                                                            --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 600,
                                                                 673,
                                                                 calc_dt,
                                                                 'N') = 'T' --отримує пенсію по втраті годувальника
                      UNION ALL
                      SELECT p_pd                                                                                                                   AS x_id,
                                uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' не має права на допомогу на дітей одиноким матерям в зв’язку із тим, що проживає з особою від якої має дитину'    AS x_text                                                                                          --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 600,
                                                                 672,
                                                                 calc_dt,
                                                                 'N') = 'T' --З особою, від якої маю дитину проживаю
                      UNION ALL
                      SELECT p_pd                                                                                                                     AS x_id,
                                'Неможливо визначити право для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в зв’язку із тим, що для допомоги на дітей одиноким матерям в Анкеті Заявника не визначено працездатність особи'    AS x_text                                                                                                                         --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND NOT (   API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             664,
                                             calc_dt,
                                             'N') = 'T'         --Працездатний
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             665,
                                             calc_dt,
                                             'N') = 'T'      --НЕ працездатний
                                                       )
                      UNION ALL
                      SELECT p_pd                                                                                                                                           AS x_id,
                                'Неможливо визначити право для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в зв’язку із тим, що для допомоги на дітей одиноким матерям в Анкеті одночасно зазначено, що особа "Працездатний" і "Непрацездатний".'    AS x_text                                                                                                                                       --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 664,
                                                                 calc_dt,
                                                                 'N') = 'T' --Працездатний
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 665,
                                                                 calc_dt,
                                                                 'N') = 'T' --НЕ працездатний
                      UNION ALL
                      SELECT p_pd,
                                'За даними анкети неможливо визначити право для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || '  в зв’язку із тим, що для допомоги на дітей одиноким матерям в Анкеті Заявника визначено, що Заявник «Працездатний» при цьому не визначено жодного із типів зайнятості'    AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 664,
                                                                 calc_dt,
                                                                 'N') = 'T' --Працездатний
                             AND NOT (   API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             650,
                                             calc_dt,
                                             'N') = 'T'               --Працює
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             651,
                                             calc_dt,
                                             'N') = 'T'                  --ФОП
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             652,
                                             calc_dt,
                                             'N') = 'T' --На обліку в центрі зайнятості
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             653,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за дитиною до 3-х років
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             654,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за дитиною до 6-ти років
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             655,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за особою похилого віку, 80-ти річною особою
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             656,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за хворою дитиною, якій не встановлено інвалідність
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             657,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за особою з інвалідністю І групи
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             658,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за особою з інвалідністю ІІ групи внаслідок психічного розладу
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             659,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за дитиною з інвалідністю до 18-років
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             662,
                                             calc_dt,
                                             'N') = 'T'           --Навчається
                                                       )
                      UNION ALL
                      SELECT p_pd,
                                'За даними анкети неможливо визначити право для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || '  в зв’язку із тим, що для допомоги на дітей одиноким матерям в Анкеті Заявника визначено, що Заявник «Непрацездатний» при цьому не визначено жодної причини непрацездатності (особа Заявник – «Пенсіонер» чи «Особа з інвалідністю»)'    AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'Z'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 665,
                                                                 calc_dt,
                                                                 'N') = 'T' --НЕ працездатний
                             AND NOT (   API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             660,
                                             calc_dt,
                                             'N') = 'T' --Особа з інвалідністю
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             661,
                                             calc_dt)
                                             IS NOT NULL --Пенсіонер (вид пенсії)
                                                        ))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG4 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                                                                     AS x_id,
                                'Неможливо визначити право для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в зв’язку із тим, що для допомоги на дітей одиноким матерям в Анкеті Заявника не визначено працездатність особи'    AS x_text                                                                                                                         --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FM'
                             AND NOT (   API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             664,
                                             calc_dt,
                                             'N') = 'T'         --Працездатний
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             665,
                                             calc_dt,
                                             'N') = 'T'      --НЕ працездатний
                                                       )
                      UNION ALL
                      SELECT p_pd                                                                                                                                           AS x_id,
                                'Неможливо визначити право для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в зв’язку із тим, що для допомоги на дітей одиноким матерям в Анкеті одночасно зазначено, що особа "Працездатний" і "Непрацездатний".'    AS x_text                                                                                                                                       --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FM'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 664,
                                                                 calc_dt,
                                                                 'N') = 'T' --Працездатний
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 665,
                                                                 calc_dt,
                                                                 'N') = 'T' --НЕ працездатний
                      UNION ALL
                      SELECT p_pd,
                                'За даними анкети неможливо визначити право для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || '  в зв’язку із тим, що для допомоги на дітей одиноким матерям в Анкеті визначено, що Член сім’ї «Працездатний» при цьому не визначено жодного із типів зайнятості'    AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FM'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 664,
                                                                 calc_dt,
                                                                 'N') = 'T' --Працездатний
                             AND NOT (   API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             650,
                                             calc_dt,
                                             'N') = 'T'               --Працює
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             651,
                                             calc_dt,
                                             'N') = 'T'                  --ФОП
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             652,
                                             calc_dt,
                                             'N') = 'T' --На обліку в центрі зайнятості
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             653,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за дитиною до 3-х років
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             654,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за дитиною до 6-ти років
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             655,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за особою похилого віку, 80-ти річною особою
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             656,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за хворою дитиною, якій не встановлено інвалідність
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             657,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за особою з інвалідністю І групи
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             658,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за особою з інвалідністю ІІ групи внаслідок психічного розладу
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             659,
                                             calc_dt,
                                             'N') = 'T' --Доглядає за дитиною з інвалідністю до 18-років
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             662,
                                             calc_dt,
                                             'N') = 'T'           --Навчається
                                                       )
                      UNION ALL
                      SELECT p_pd,
                                'За даними анкети неможливо визначити право для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || '  в зв’язку із тим, що для допомоги на дітей одиноким матерям в Анкеті визначено, що Член сім’ї «Непрацездатний» при цьому не визначено жодної причини непрацездатності (особа – «Пенсіонер» чи «Особа з інвалідністю»)'    AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FM'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 665,
                                                                 calc_dt,
                                                                 'N') = 'T' --НЕ працездатний
                             AND NOT (   API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             660,
                                             calc_dt,
                                             'N') = 'T' --Особа з інвалідністю
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             605,
                                             661,
                                             calc_dt)
                                             IS NOT NULL --Пенсіонер (вид пенсії)
                                                        ))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG5 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
            SELECT p_pd AS x_id, 'Ручне підтвердження' AS x_errors_list
              FROM DUAL;

        --#101455 + #103257
        /*
                SELECT x_id, listagg(x_text, g_10 ON OVERFLOW TRUNCATE '...' ) WITHIN GROUP (ORDER BY x_id) AS x_errors_list
                FROM (

                        WITH months AS (SELECT level AS x_month FROM dual CONNECT BY level < 13),
                            period AS (SELECT MIN(r_month) AS q_month_min, MAX(r_month) AS q_month_max
                                       FROM (SELECT ADD_MONTHS(TRUNC(pd.pd_dt, 'MM'), -(x_month + API$CALC_RIGHT.get_month_start(ap_reg_dt, 1))) AS r_month
                                             FROM appeal ap
                                                  inner join pc_decision pd on ap.ap_id=pd.pd_ap and pd.pd_id=p_pd,
                                                  months)),
                            app_income AS (SELECT tpp_sc AS x_sc, COUNT(*) AS x_payed_esv_min
                                           FROM v_tmp_person_for_decision app, pd_income_src, period
                                           WHERE app.pd_id = p_pd
                                             AND tpp_app_tp IN ('Z', 'FM')
                                             AND pis_pd = tpp_pd
                                             AND pis_sc = tpp_sc
                                             AND pis_src = 'PFU'
                                             AND pis_start_dt BETWEEN q_month_min AND q_month_max
                                             AND pis_esv_min = 'T'
                                           GROUP BY tpp_sc),
                            app_esv_payed AS (SELECT tpp_sc, NVL((SELECT x_payed_esv_min FROM app_income WHERE x_sc = tpp_sc), 0) AS b_esv_min_payed
                                              FROM v_tmp_person_for_decision app
                                              WHERE app.pd_id = p_pd
                                                AND tpp_app_tp IN ('Z', 'FM'))
                         SELECT p_pd as x_id, 'Для '||uss_person.api$sc_tools.get_pib(tpp_sc)||' за даними ПФУ відсутня інформація про сплату ЄСВ за три місяці' as x_text
                         FROM app_esv_payed WHERE b_esv_min_payed < 3
                      )
                WHERE x_text IS NOT NULL
                GROUP BY x_id;
        */

        Set_pd_right_log (p_nrr_id, p_pd);
    /*
    --Для <ПІБ учасника звернення> за даними ПФУ відсутня інформація про сплату ЄСВ за три місяці"
          MERGE INTO pd_right_log
            USING (SELECT p_pd AS b_pd, p_nrr_id AS b_nrr,
                          CASE WHEN (WITH months AS (SELECT level AS x_month FROM dual CONNECT BY level < 13),
                                          period AS (SELECT MIN(r_month) AS q_month_min, MAX(r_month) AS q_month_max
                                                     FROM (SELECT ADD_MONTHS(TRUNC(pd.pd_dt, 'MM'), -(x_month + API$CALC_RIGHT.get_month_start(ap_reg_dt, 1))) AS r_month
                                                           FROM appeal ap
                                                                inner join pc_decision pd on ap.ap_id=pd.pd_ap and pd.pd_id=p_pd,
                                                                months)),
                                          app_income AS (SELECT app_id AS x_app, COUNT(*) AS x_payed_esv_min
                                                         FROM v_tmp_person_for_decision app, pd_income_src, period
                                                         WHERE app.pd_id = p_pd
                                                           AND app_tp IN ('Z', 'FM')
                                                           AND pis_app = app_id
                                                           AND pis_src = 'PFU'
                                                           AND pis_start_dt BETWEEN q_month_min AND q_month_max
                                                           AND pis_esv_min = 'T'
                                                         GROUP BY app_id),
                                          app_esv_payed AS (SELECT app_id, NVL((SELECT x_payed_esv_min FROM app_income WHERE x_app = app_id), 0) AS b_esv_min_payed
                                                            FROM v_tmp_person_for_decision app
                                                            WHERE app.pd_id = p_pd
                                                              AND app_tp IN ('Z', 'FM'))
                                       SELECT COUNT(*) FROM app_esv_payed WHERE b_esv_min_payed < 3) > 0
                                 THEN 'F'
                               ELSE 'T'
                          END AS b_result,
                          (SELECT MAX(tel_text) FROM tmp_errors_list WHERE x_id = tel_id) AS b_info
                   FROM tmp_work_ids)
            ON (prl_pd = b_pd AND prl_nrr = b_nrr)
            WHEN MATCHED THEN
              UPDATE SET prl_calc_result = b_result, prl_hs_rewrite = NULL, prl_result = b_result, prl_calc_info = b_info
            WHEN NOT MATCHED THEN
              INSERT (prl_id, prl_pd, prl_nrr, prl_result, prl_calc_result, prl_calc_info)
                 VALUES (0, b_pd, b_nrr, b_result, b_result, b_info);
    */
    END;

    --========================================
    PROCEDURE Check_ALG6 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        MERGE INTO pd_right_log
             USING (SELECT x_id        AS b_pd,
                           p_nrr_id    AS b_nrr,
                           CASE
                               WHEN (SELECT COUNT (*)
                                       FROM pc_decision,
                                            ap_declaration,
                                            apr_person,
                                            apr_living_quarters,
                                            ap_person
                                      WHERE     x_id = pd_id
                                            AND pd_ap = apr_ap
                                            AND aprp_apr = apr_id
                                            AND aprp_app = app_id
                                            AND app_tp IN ('FM', 'Z', 'FP')
                                            AND aprl_apr = apr_id
                                            AND aprl_aprp = aprp_id
                                            AND apr_living_quarters.history_status =
                                                'A'
                                            AND apr_person.history_status =
                                                'A'
                                            AND ap_person.history_status =
                                                'A') <
                                    2
                               THEN
                                   'T'
                               ELSE
                                   'F'
                           END         AS b_result
                      FROM tmp_work_ids)
                ON (prl_pd = b_pd AND prl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET
                prl_calc_result = b_result,
                prl_hs_rewrite = NULL,
                prl_result = b_result
        WHEN NOT MATCHED
        THEN
            INSERT     (prl_id,
                        prl_pd,
                        prl_nrr,
                        prl_result,
                        prl_calc_result)
                VALUES (0,
                        b_pd,
                        b_nrr,
                        b_result,
                        b_result);
    END;

    --========================================
    PROCEDURE Check_ALG7 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        MERGE INTO pd_right_log
             USING (SELECT x_id        AS b_pd,
                           p_nrr_id    AS b_nrr,
                           CASE
                               WHEN (SELECT COUNT (*)
                                       FROM pc_decision,
                                            ap_declaration,
                                            apr_person,
                                            apr_vehicle,
                                            ap_person
                                      WHERE     x_id = pd_id
                                            AND pd_ap = apr_ap
                                            AND aprp_apr = apr_id
                                            AND aprp_app = app_id
                                            AND app_tp IN ('FM', 'Z', 'FP')
                                            AND aprv_apr = apr_id
                                            AND aprv_aprp = aprp_id
                                            AND apr_vehicle.history_status =
                                                'A'
                                            AND apr_person.history_status =
                                                'A'
                                            AND ap_person.history_status =
                                                'A') <
                                    2
                               THEN
                                   'T'
                               ELSE
                                   'F'
                           END         AS b_result
                      FROM tmp_work_ids)
                ON (prl_pd = b_pd AND prl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET
                prl_calc_result = b_result,
                prl_hs_rewrite = NULL,
                prl_result = b_result
        WHEN NOT MATCHED
        THEN
            INSERT     (prl_id,
                        prl_pd,
                        prl_nrr,
                        prl_result,
                        prl_calc_result)
                VALUES (0,
                        b_pd,
                        b_nrr,
                        b_result,
                        b_result);
    END;

    --========================================
    PROCEDURE Check_ALG8 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        MERGE INTO pd_right_log
             USING (SELECT x_id        AS b_pd,
                           p_nrr_id    AS b_nrr,
                           CASE
                               WHEN NVL (
                                        (SELECT SUM (aprs_cost)
                                           FROM pc_decision,
                                                ap_declaration,
                                                apr_person,
                                                apr_spending,
                                                ap_person
                                          WHERE     x_id = pd_id
                                                AND pd_ap = apr_ap
                                                AND aprp_apr = apr_id
                                                AND aprp_app = app_id
                                                AND app_tp IN
                                                        ('FM', 'Z', 'FP')
                                                AND aprs_tp IN ('MA',
                                                                'MB',
                                                                'MF',
                                                                'ML',
                                                                'MM',
                                                                'MT')
                                                AND aprs_apr = apr_id
                                                AND aprs_aprp = aprp_id
                                                AND apr_spending.history_status =
                                                    'A'
                                                AND apr_person.history_status =
                                                    'A'
                                                AND ap_person.history_status =
                                                    'A'),
                                        0) <
                                    50000
                               THEN
                                   'T'
                               ELSE
                                   'F'
                           END         AS b_result
                      FROM tmp_work_ids)
                ON (prl_pd = b_pd AND prl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET
                prl_calc_result = b_result,
                prl_hs_rewrite = NULL,
                prl_result = b_result
        WHEN NOT MATCHED
        THEN
            INSERT     (prl_id,
                        prl_pd,
                        prl_nrr,
                        prl_result,
                        prl_calc_result)
                VALUES (0,
                        b_pd,
                        b_nrr,
                        b_result,
                        b_result);
    END;

    --========================================
    PROCEDURE Check_ALG9 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        MERGE INTO pd_right_log
             USING (SELECT x_id        AS b_pd,
                           p_nrr_id    AS b_nrr,
                           CASE
                               WHEN NVL (
                                        (SELECT SUM (aprs_cost)
                                           FROM pc_decision,
                                                ap_declaration,
                                                apr_person,
                                                apr_spending,
                                                ap_person
                                          WHERE     x_id = pd_id
                                                AND pd_ap = apr_ap
                                                AND aprp_apr = apr_id
                                                AND aprp_app = app_id
                                                AND app_tp IN
                                                        ('FM', 'Z', 'FP')
                                                AND aprs_tp IN ('PA',
                                                                'PE',
                                                                'PP',
                                                                'PR',
                                                                'PS')
                                                AND aprs_apr = apr_id
                                                AND aprs_aprp = aprp_id
                                                AND apr_spending.history_status =
                                                    'A'
                                                AND apr_person.history_status =
                                                    'A'
                                                AND ap_person.history_status =
                                                    'A'),
                                        0) <
                                    50000
                               THEN
                                   'T'
                               ELSE
                                   'F'
                           END         AS b_result
                      FROM tmp_work_ids)
                ON (prl_pd = b_pd AND prl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET
                prl_calc_result = b_result,
                prl_hs_rewrite = NULL,
                prl_result = b_result
        WHEN NOT MATCHED
        THEN
            INSERT     (prl_id,
                        prl_pd,
                        prl_nrr,
                        prl_result,
                        prl_calc_result)
                VALUES (0,
                        b_pd,
                        b_nrr,
                        b_result,
                        b_result);
    END;

    --========================================
    PROCEDURE Check_ALG10 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        MERGE INTO pd_right_log
             USING (SELECT x_id AS b_pd, p_nrr_id AS b_nrr, 'F' AS b_result
                      FROM tmp_work_ids)
                ON (prl_pd = b_pd AND prl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET
                prl_calc_result = b_result,
                prl_hs_rewrite = NULL,
                prl_result = b_result
        WHEN NOT MATCHED
        THEN
            INSERT     (prl_id,
                        prl_pd,
                        prl_nrr,
                        prl_result,
                        prl_calc_result)
                VALUES (0,
                        b_pd,
                        b_nrr,
                        b_result,
                        b_result);
    END;

    --========================================
    PROCEDURE Check_ALG12 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                          AS x_id,
                             'Відсутня довідка про захворювання дитини'    AS x_text                                     --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND api$calc_right.get_docx_list_cnt (p_pd,
                                                                   tpp_sc,
                                                                   '669',
                                                                   calc_dt) = 0)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG13 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                  AS x_id,
                                uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' знаходиться на держутриманні'    AS x_text                           --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 677,
                                                                 calc_dt,
                                                                 'N') = 'T' --стан знаходження на держутриманні з анкети
                                                                           )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG13_267 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                                                    AS x_id,
                                'Для утриманця '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' заявник не має права на допомогу, в зв’язку із тим, що утриманець знаходиться на держутриманні'    AS x_text                                                                                            --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 677,
                                                                 calc_dt,
                                                                 'N') = 'T' --стан знаходження на держутриманні з анкети
                      UNION ALL
                      SELECT p_pd                                                                                                                                                                                             AS x_id,
                                'Для утриманця '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' не можливо визначити право на допомогу, в зв’язку із тим, що в Анкеті одночасно зазначено, що утриманець навчається в школі та за денною, дуальною, заочною формою навчання до 23 років'    AS x_text                                                                                                                                                                 --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 675,
                                                                 calc_dt)
                                     IS NOT NULL --Особа, яка навчається за денною, дуальною формою до 23 років. Форма навчання
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 676,
                                                                 calc_dt,
                                                                 'N') = 'T' --Учень/учениця
                      UNION ALL
                      SELECT p_pd                                                                                                                                    AS x_id,
                                'Для утриманця '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' заявник не має права на допомогу, в зв’язку із тим, що в Анкеті зазначено, що утриманець навчається за заочною формою навчання'    AS x_text                                                                                                                     --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND TRUNC (  MONTHS_BETWEEN (SYSDATE,
                                                          NVL (API$CALC_RIGHT.get_docx_dt (
                                                                   p_pd,
                                                                   tpp_sc,
                                                                   37,
                                                                   91,
                                                                   calc_dt),
                                                               SYSDATE))
                                        / 12,
                                        0) >= 14              --вік > 14 років
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 675,
                                                                 calc_dt,
                                                                 'N') = 'Z' --Особа, яка навчається за денною, дуальною формою до 23 років. Форма навчання
                      UNION ALL
                      SELECT p_pd                                                                                                                                                                                                                                                                                  AS x_id,
                                'Для утриманця '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' заявник не має права на допомогу, в зв’язку із тим, що в Анкеті відсутня, що утриманець навчається в школі або навчається за денною, дуальною, заочною формою навчання в закладах загальної середньої, професійної (професійно-технічної), фахової передвищої та вищої освіт'    AS x_text                                                                                                                                                                                                                                           --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND TRUNC (  MONTHS_BETWEEN (SYSDATE,
                                                          NVL (API$CALC_RIGHT.get_docx_dt (
                                                                   p_pd,
                                                                   tpp_sc,
                                                                   37,
                                                                   91,
                                                                   calc_dt),
                                                               SYSDATE))
                                        / 12,
                                        0) >= 14              --вік > 14 років
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 676,
                                                                 calc_dt,
                                                                 'N') = 'N' --Учень/учениця
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 675,
                                                                 calc_dt)
                                     IS NULL --Особа, яка навчається за денною, дуальною формою до 23 років. Форма навчання
                      UNION ALL
                      SELECT p_pd                                                                                             AS x_id,
                                'Для утриманця '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' заявник не має права на допомогу, в зв’язку із тим, що вік утриманця більше ніж 23 роки'    AS x_text                                                                                 --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND TRUNC (  MONTHS_BETWEEN (SYSDATE,
                                                          NVL (API$CALC_RIGHT.get_docx_dt (
                                                                   p_pd,
                                                                   tpp_sc,
                                                                   37,
                                                                   91,
                                                                   calc_dt),
                                                               SYSDATE))
                                        / 12,
                                        0) >= 23              --вік > 23 років
                                                )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG14 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                               AS x_id,
                             'Знаходиться на держутриманні'     AS x_text                            --1
                        FROM v_tmp_person_for_decision app
                       WHERE     app.pd_id = p_pd
                             AND tpp_app_tp = 'FP'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 667,
                                                                 calc_dt,
                                                                 'N') != 'N' --стан знаходження на держутриманні з анкети
                                                                            )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG15 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT pd_id    AS x_id,
                             CASE
                                 WHEN API$CALC_RIGHT.get_docx_dt (p_pd,
                                                                  tpp_sc,
                                                                  114,
                                                                  708,
                                                                  calc_dt)
                                          IS NULL
                                 THEN
                                        'Для Рішення суду про всиновлення для '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' не можливо визначити право, тому що дата початку дії рішення суду про всиновлення не зазначена'
                                 WHEN MONTHS_BETWEEN (ap_reg_dt,
                                                      API$CALC_RIGHT.get_docx_dt (
                                                          p_pd,
                                                          tpp_sc,
                                                          114,
                                                          708,
                                                          calc_dt)) >= 12
                                 THEN
                                     'Звернення за призначенням допомоги надійшло пізніше ніж через 12 календарних місяців з дня набрання законної сили рішенням про усиновлення дитини'
                                 ELSE
                                     ''
                             END      AS x_text                            --1
                        FROM v_tmp_person_for_decision app
                             JOIN appeal ON pd_ap = ap_id
                       WHERE tpp_app_tp = 'FP' AND pd_id = p_pd)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG16 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Check_ALG1_248 (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG17 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z          API$ANKETA.Type_Rec_Anketa;
        help_id      NUMBER (10);
        premium_id   NUMBER (10);
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        PutLine ('L_Z.DisabilityFromChild = ' || L_Z.DisabilityFromChild);

        IF L_Z.DisabilityFromChild = 'T'
        THEN
            FOR Dis
                IN (SELECT tpd_apd,
                           tpd_sc,
                           tpd_ndt,
                           NVL (apda349.apda_val_string, 'F')
                               DisabilityGroup,           --група інвалідності
                           NVL (apda791.apda_val_string, 'F')
                               DisabilitySubGroup,     --підгрупа інвалідності
                           NVL (apda790.apda_val_string, 'F')
                               TthirdPartyCare --потребує постійного стороннього догляду
                      FROM                                   --ap_document apd
 --inner join v_tmp_person_for_decision app on app.app_id=apd.apd_app and app.app_tp='Z'
                      v_tmp_document_for_decision
                      LEFT JOIN ap_document_attr apda349
                          ON     apda349.apda_apd = tpd_apd
                             AND apda349.apda_nda = 349
                             AND apda349.history_status = 'A'
                      LEFT JOIN ap_document_attr apda791
                          ON     apda791.apda_apd = tpd_apd
                             AND apda791.apda_nda = 791
                             AND apda791.history_status = 'A'
                      LEFT JOIN ap_document_attr apda790
                          ON     apda790.apda_apd = tpd_apd
                             AND apda790.apda_nda = 790
                             AND apda790.history_status = 'A'
                     WHERE     tpd_ndt = 201
                           AND tpd_pd = p_pd
                           AND tpd_app_tp = 'Z')
            LOOP
                CASE dis.DisabilityGroup
                    WHEN '1'
                    THEN
                        help_id := 247; -- 3.1 допомога інвалідам з дитинства I групи

                        IF dis.DisabilitySubGroup IN ('A'              /*Lat*/
                                                         , 'А'         /*Кір*/
                                                              )
                        THEN
                            premium_id := 244; -- 3.5 надбавка на догляд за інвалідом з дитинства підгрупи А I групи
                        ELSIF dis.DisabilitySubGroup IN ('B'           /*Lat*/
                                                            , 'Б'      /*Кір*/
                                                                 )
                        THEN
                            premium_id := 243; -- 3.6 надбавка на догляд за інвалідом з дитинства підгрупи Б I групи
                        ELSE
                            MERGE_tmp_errors_list (
                                p_pd,
                                'Заявник не має права на надбавку на догляд за інвалідом з дитинства підгрупи А чи Б I групи');
                        END IF;
                    WHEN '2'
                    THEN
                        help_id := 246; -- 3.2 допомога інвалідам з дитинства II групи

                        IF dis.TthirdPartyCare = 'T' AND L_Z.Alone = 'T'
                        THEN
                            premium_id := 242; -- 3.7 одиноким інвалідам з  дитинства II і III груп, які за висновком ЛКК  закладу охорони здоров’я  потребують постійного стороннього  догляду
                        ELSE
                            MERGE_tmp_errors_list (
                                p_pd,
                                   'Заявник не є особою з інвалідністю з дитинства 1 групи.'
                                || CHR (13)
                                || CHR (10)
                                || 'Заявник є особою з інвалідністю 2, проте за даними'
                                || CASE
                                       WHEN dis.TthirdPartyCare != 'T'
                                       THEN
                                           '«Виписки з акту огляду МСЕК» не потребує сторонього догляду'
                                       WHEN L_Z.Alone != 'T'
                                       THEN
                                           '«Анкети» не є одинокою особою'
                                       ELSE
                                           NULL
                                   END);
                        END IF;
                    WHEN '3'
                    THEN
                        help_id := 245; -- 3.3 допомога інвалідам з дитинства III групи

                        IF dis.TthirdPartyCare = 'T' AND L_Z.Alone = 'T'
                        THEN
                            premium_id := 242; -- 3.7 одиноким інвалідам з  дитинства II і III груп, які за висновком ЛКК  закладу охорони здоров’я  потребують постійного стороннього  догляду
                        ELSE
                            MERGE_tmp_errors_list (
                                p_pd,
                                   'Заявник не є особою з інвалідністю з дитинства 1 групи.'
                                || CHR (13)
                                || CHR (10)
                                || 'Заявник є особою з інвалідністю 3, проте за даними'
                                || CASE
                                       WHEN dis.TthirdPartyCare != 'T'
                                       THEN
                                           '«Виписки з акту огляду МСЕК» не потребує сторонього догляду'
                                       WHEN L_Z.Alone != 'T'
                                       THEN
                                           '«Анкети» не є одинокою особою'
                                       ELSE
                                           NULL
                                   END);
                        END IF;
                    ELSE
                        MERGE_tmp_errors_list (
                            p_pd,
                            'Заявник не інвалід I, II або III групи з дитинства');
                END CASE;
            END LOOP;
        ELSE
            --dbms_output.put_line('L_Z.DisabilityFromChild != T');
            FOR Dis
                IN ( /*with age as (select app.tpp_pd, app.tpp_sc, calc_dt,
                                         nvl(trunc(months_between (sysdate, api$calc_right.get_docx_dt(tpp_pd, tpp_sc, 37,91, calc_dt) )/12,0),-1) age_year --свідоцтво про народження дитини
                                  from v_tmp_person_for_decision app
                                  where tpp_app_tp='FP' and app.pd_id=p_pd  )
                          select  tpp_pd, tpp_sc, age_year,
                                  api$calc_right.get_docx_string(tpp_pd, tpp_sc, 200, 797, calc_dt, 'F' ) AS DisabilityCategory, --Категорія інвалідності
                                  api$calc_right.get_docx_string(tpp_pd, tpp_sc, 605, 677, calc_dt, 'F' ) AS StateMaintenance --Знаходиться на держутриманні
                          from  age
                          where age_year between 0 and 18*/
                    SELECT pd_id,
                           app_sc,
                           calc_dt,
                           AgeYear
                               AS age_year,
                           api$calc_right.get_docx_string (pd_id,
                                                           app_sc,
                                                           200,
                                                           797,
                                                           calc_dt,
                                                           'F')
                               AS DisabilityCategory, --Категорія інвалідності
                           MainTenance
                               AS StateMaintenance
                      FROM TABLE (api$anketa.Get_Anketa)
                     WHERE     AgeYear BETWEEN 0 AND 18
                           AND (app_tp = 'FP' OR app_tp = 'DU')
                           AND pd_id = p_pd)
            LOOP
                help_id := 266; -- 3.4 Допомога на дітей-інвалідів віком до 18 років

                IF Dis.StateMaintenance = 'T'
                THEN
                    MERGE_tmp_errors_list (
                        p_pd,
                        'У разі перебування дитини з інвалідністю віком до 18 років на повному державному утриманні надбавка на догляд не призначається.');
                ELSIF api$account.get_docx_count (Dis.pd_id,
                                                  Dis.app_sc,
                                                  10035,
                                                  Dis.calc_dt) > 0
                THEN                                                 --#101415
                    MERGE_tmp_errors_list (
                        p_pd,
                           'Особа '
                        || uss_person.api$sc_tools.get_pib (Dis.app_sc)
                        || ' знаходиться на повному державному утриманні.');
                ELSIF Dis.DisabilityCategory = 'DI'
                THEN                                   --Дитина з інвалідністю
                    IF    (    L_Z.NotWorking = 'T'
                           AND L_Z.Studying = 'F'
                           AND L_Z.Military = 'F')
                       OR (    L_Z.NotWorking = 'T'
                           AND L_Z.Studying = 'T'
                           AND L_Z.StudyingForm = 'Z'
                           AND L_Z.Military = 'F')
                       --or  L_Z.CaringChildUnder3 = 'T' --#94192
                       OR L_Z.MaternityLeave = 'T'
                       OR L_Z.NotSalary = 'T'
                       OR L_Z.Alone = 'T'
                    THEN                                   --#74287 2021.12.22
                        IF dis.age_year < 6
                        THEN
                            premium_id := 289; -- 3.8 надбавка на догляд за дитиною-інвалідом віком до 6 років
                        ELSE
                            premium_id := 264; -- 3.9 надбавка на догляд за дитиною-інвалідом віком від 6 до 18 років
                        END IF;
                    ELSE
                        MERGE_tmp_errors_list (
                            p_pd,
                            'Дитині не встановлено категорію «Дитина з інвалідністю підгрупи "А"», заявник не одинокий/одинока, надбавка на догляд за дитиною з інвалідністю віком до 18 років не призначається одному з батьків, усиновлювачів, опікуну, піклувальнику, які працюють, навчаються (крім заочної форми здобуття освіти), не проходять військову службу, не одинокий/одинока.');
                    END IF;
                ELSIF Dis.DisabilityCategory = 'DIA'
                THEN                                   --Дитина з інвалідністю
                    IF dis.age_year < 6
                    THEN
                        premium_id := 289; -- 3.8 надбавка на догляд за дитиною-інвалідом віком до 6 років
                    ELSE
                        premium_id := 264; -- 3.9 надбавка на догляд за дитиною-інвалідом віком від 6 до 18 років
                    END IF;
                END IF;
            END LOOP;
        END IF;

        /*
        api$calc_right.get_docx_count(pd_id, app_sc, 10035, calc_dt ) > 0
        1. Якщо у рішенні наявний документ Ід=10035 Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань
         AND документ з Ід=200 (Медичний висновок (для дітей з інвалідністю до 18 років) ), то в правилі
         "Має право на надбавку(на весь період інвалідності)" зазначати "Ні", текст попередження
         "Особа <ПІБ особи, до якої прикріплено документ з Ід=200> знаходиться на повному державному утриманні"

        Для тестування 52611-92353-2024-5 (сформоване на підставі звернення 8000000000240000044600)
        */
        --#97503
        /*
        1. Якщо у рішенні наявний
           документ з Ід=10034 (Довідка про зарахування особи на повне державне утримання)
           AND документ з Ід=200 (Медичний висновок (для дітей з інвалідністю до 18 років) ),
           то в правилі "Має право на надбавку(на весь період інвалідності)" зазначати "Ні", текст попередження
           "Особа <ПІБ особи, до якої прикріплено документ з Ід=200> знаходиться на повному державному утриманні"
        2. Якщо у рішенні наявний
           документ з Ід=98 (Довідка про навчання), якому в атрибуті з Ід=856 "На повному державному утриманні" зазначено "Так"
           AND* документ з Ід=200 (Медичний висновок (для дітей з інвалідністю до 18 років) ),
           то в правилі "Має право на надбавку(на весь період інвалідності)" зазначати "Ні", текст попередження "Особа <ПІБ особи, до якої прикріплено документ з Ід=200> знаходиться на повному державному утриманні"
        */

        FOR rec
            IN (SELECT API$ACCOUNT.get_docx_count (app.pd_id,
                                                   app.tpp_sc,
                                                   200,
                                                   app.calc_dt)
                           AS cnt_200,
                       API$ACCOUNT.get_docx_count (app.pd_id,
                                                   app.tpp_sc,
                                                   10034,
                                                   app.calc_dt)
                           AS cnt_10034,
                       --API$ACCOUNT.get_docx_count(app.pd_id, app.tpp_sc,    98, app.calc_dt) AS cnt_98,
                       API$ACCOUNT.get_docx_string (app.pd_id,
                                                    app.tpp_sc,
                                                    98,
                                                    856,
                                                    app.calc_dt,
                                                    'F')
                           AS val_856,
                       app.tpp_sc,
                       (SELECT COUNT (1)
                          FROM PC_STATE_ALIMONY ps
                         WHERE     ps.ps_pc = pd_pc
                               AND ps.ps_sc = tpp_sc
                               AND ps.ps_st = 'R')
                           AS is_State_Alimony
                  FROM v_tmp_person_for_decision  app
                       JOIN TABLE (api$anketa.Get_Anketa) t
                           ON app.pd_id = t.pd_id AND app.tpp_sc = t.app_sc
                 WHERE app.pd_id = p_pd AND AGEYEAR < 18)
        LOOP
            IF rec.cnt_200 > 0 AND rec.cnt_10034 > 0
            THEN
                MERGE_tmp_errors_list (
                    p_pd,
                       'Особа '
                    || uss_person.api$sc_tools.get_pib (rec.tpp_sc)
                    || ' знаходиться на повному державному утриманні');
            ELSIF rec.cnt_200 > 0 AND rec.val_856 = 'T'
            THEN
                MERGE_tmp_errors_list (
                    p_pd,
                       'Особа '
                    || uss_person.api$sc_tools.get_pib (rec.tpp_sc)
                    || ' знаходиться на повному державному утриманні');
            ELSIF rec.is_State_Alimony > 0
            THEN
                MERGE_tmp_errors_list (
                    p_pd,
                       'Особа '
                    || uss_person.api$sc_tools.get_pib (rec.tpp_sc)
                    || ' знаходиться на повному державному утриманні');
            END IF;
        END LOOP;

        PutLine ('help_id = ' || help_id);
        PutLine ('premium_id = ' || premium_id);

        /*
        3. В анкеті Заявника в групі «Ознака роботи (зайнятості)» встановлено відмітки:
        L_Z.NotWorking='T' and
        (
        «Не працює»=Так і «Навчається»=Ні  і «Проходить військову службу»=Ні)
        або «Не працює»=Так і «Навчається»=«так» і в документі «Довідка про навчання» форма навчання = «заочна» і «Проходить військову службу»=Ні)
        або «Доглядає за дитиною до 3-х років»=Так
        або «Перебуває у відпустці у зв’язку з вагітністю та пологами»=Так,
        або «Перебуває у відпустці без збереження заробітної плати»=Так
        )
        */
        /*
        244 3.5 надбавка на догляд за інвалідом з дитинства підгрупи А I групи
        243 3.6 надбавка на догляд за інвалідом з дитинства підгрупи Б I групи
        242 3.7 одиноким інвалідам з  дитинства II і III груп, які за висновком ЛКК  закладу охорони здоров’я  потребують постійного стороннього  догляду
        289 3.8 надбавка на догляд за дитиною-інвалідом віком до 6 років
        264 3.9 надбавка на догляд за дитиною-інвалідом віком від 6 до 18 років
        */
        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG18 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        MERGE INTO pd_right_log
             USING (SELECT x_id        AS b_pd,
                           p_nrr_id    AS b_nrr,
                           CASE
                               WHEN (SELECT COUNT (*)
                                       FROM v_tmp_person_for_decision  app
                                            JOIN ap_declaration
                                                ON apr_ap = app.pd_ap
                                            JOIN apr_person
                                                ON     aprp_apr = apr_id
                                                   AND aprp_app =
                                                       (SELECT app_id
                                                          FROM ap_person t
                                                         WHERE     app_sc =
                                                                   app.tpp_sc
                                                               AND app_ap =
                                                                   app.pd_ap
                                                               AND t.history_status =
                                                                   'A') --tpp_app
                                                   AND apr_person.history_status =
                                                       'A'
                                            JOIN apr_living_quarters
                                                ON     aprl_apr = apr_id
                                                   AND apr_living_quarters.history_status =
                                                       'A'
                                      WHERE     tpp_pd = p_pd
                                            AND tpp_app_tp IN
                                                    ('FM', 'Z', 'FP')) >=
                                    2
                               THEN
                                   CASE
                                       WHEN (WITH
                                                 app
                                                 AS
                                                     (SELECT tpp_sc
                                                                 AS x_sc,
                                                             calc_dt
                                                                 AS x_dt,
                                                             API$CALC_RIGHT.get_docx_string (
                                                                 tpp_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 649,
                                                                 calc_dt)
                                                                 AS x_tp,
                                                             API$CALC_RIGHT.get_docx_dt (
                                                                 tpp_pd,
                                                                 tpp_sc,
                                                                 37,
                                                                 91,
                                                                 calc_dt)
                                                                 AS x_birth_dt,
                                                             API$CALC_RIGHT.get_docx_string (
                                                                 tpp_pd,
                                                                 tpp_sc,
                                                                 98,
                                                                 690,
                                                                 calc_dt)
                                                                 AS x_edu_tp
                                                        FROM v_tmp_person_for_decision
                                                             app
                                                       WHERE     tpp_pd =
                                                                 p_pd
                                                             AND tpp_app_tp IN
                                                                     ('FM',
                                                                      'FP'))
                                             SELECT COUNT (*)
                                               FROM app
                                              WHERE     x_tp IN ('B') --Дитина (рідна, усиновлена)
                                                    AND (   ADD_MONTHS (
                                                                x_birth_dt,
                                                                216) >
                                                            x_dt --не досягли 18 років
                                                         OR (    ADD_MONTHS (
                                                                     x_birth_dt,
                                                                     276) >
                                                                 x_dt
                                                             AND x_edu_tp IN
                                                                     ('U',
                                                                      'D'))) --не досягли 23 років і навчається на денній/дуальній формі
                                                                            ) >=
                                            3 --якщо дітей більше або рівне 3, то сім`я багатодітна і порівнюємо суму житлових приміщень з "нормою"
                                       THEN
                                           CASE
                                               WHEN (SELECT SUM (aprl_area)
                                                       FROM v_tmp_person_for_decision
                                                            app
                                                            JOIN
                                                            ap_declaration
                                                                ON apr_ap =
                                                                   app.pd_ap
                                                            JOIN apr_person
                                                                ON     aprp_apr =
                                                                       apr_id
                                                                   AND aprp_app =
                                                                       (SELECT app_id
                                                                          FROM ap_person
                                                                                   t
                                                                         WHERE     app_sc =
                                                                                   app.tpp_sc
                                                                               AND app_ap =
                                                                                   app.pd_ap
                                                                               AND t.history_status =
                                                                                   'A') --tpp_app
                                                                   AND apr_person.history_status =
                                                                       'A'
                                                            JOIN
                                                            apr_living_quarters
                                                                ON     aprl_apr =
                                                                       apr_id
                                                                   AND apr_living_quarters.history_status =
                                                                       'A'
                                                      WHERE     tpp_pd = p_pd
                                                            AND tpp_app_tp IN
                                                                    ('FM',
                                                                     'Z',
                                                                     'FP')) <=
                                                    (  35.22
                                                     +   13.65
                                                       * (SELECT COUNT (*)
                                                            FROM v_tmp_person_for_decision
                                                           WHERE     tpp_pd =
                                                                     p_pd
                                                                 AND tpp_app_tp IN
                                                                         ('FM',
                                                                          'Z',
                                                                          'FP')))
                                               THEN
                                                   'T'
                                               ELSE
                                                   'F'
                                           END
                                       ELSE
                                           'T'
                                   END
                               ELSE
                                   'T'
                           END         AS b_result
                      FROM tmp_work_ids)
                ON (prl_pd = b_pd AND prl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET
                prl_calc_result = b_result,
                prl_hs_rewrite = NULL,
                prl_result = b_result
        WHEN NOT MATCHED
        THEN
            INSERT     (prl_id,
                        prl_pd,
                        prl_nrr,
                        prl_result,
                        prl_calc_result)
                VALUES (0,
                        b_pd,
                        b_nrr,
                        b_result,
                        b_result);
    END;

    --========================================
    PROCEDURE Check_ALG19 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        CURSOR Check_Family IS
            WITH
                bd
                AS
                    (SELECT tpp_pd,
                            tpp_app_tp,
                            tpp_sc,
                            DECODE (tpp_app_tp,
                                    'Z', 'Заявника',
                                    'FP', 'Утриманця',
                                    'FM', 'Члена сім’ї',
                                    '')    AS app_tp_name,
                            NVL (
                                TRUNC (
                                      MONTHS_BETWEEN (
                                          SYSDATE,
                                          COALESCE (api$calc_right.get_docx_dt (
                                                        tpp_pd,
                                                        tpp_sc,
                                                        6,
                                                        606,
                                                        calc_dt),    --Паспорт
                                                    api$calc_right.get_docx_dt (
                                                        tpp_pd,
                                                        tpp_sc,
                                                        7,
                                                        607,
                                                        calc_dt),  --ID картка
                                                    api$calc_right.get_docx_dt (
                                                        tpp_pd,
                                                        tpp_sc,
                                                        37,
                                                        91,
                                                        calc_dt), --свідоцтво про народження дитини
                                                    api$calc_right.get_docx_dt (
                                                        tpp_pd,
                                                        tpp_sc,
                                                        673,
                                                        762,
                                                        calc_dt) --Легалізований документ про народження  дитини від компетентного органу іноземної держави
                                                                ))
                                    / 12,
                                    0),
                                -1)        age_year
                       FROM v_tmp_person_for_decision app
                      WHERE app.pd_id = p_pd),
                Checks
                AS
                    (SELECT bd.tpp_pd,
                            bd.tpp_app_tp,
                            bd.tpp_sc,
                            CASE
                                WHEN     apa.Workable != 'T'
                                     AND apa.NotWorkable != 'T'
                                     AND age_year >= 18
                                THEN
                                       'Неможливо визначити право для '
                                    || uss_person.api$sc_tools.get_pib (
                                           tpp_sc)
                                    || ' в зв’язку із тим, що для допомоги на дітей малозабезпечиним сім''ям в Анкеті '
                                    || app_tp_name
                                    || ' не визначено працездатність особи'
                                WHEN     apa.Workable = 'T'
                                     AND apa.NotWorkable = 'T'
                                     AND age_year >= 18
                                THEN
                                       'Неможливо визначити право для '
                                    || uss_person.api$sc_tools.get_pib (
                                           tpp_sc)
                                    || ' в зв’язку із тим, що для допомоги на дітей малозабезпечиним сім''ям в Анкеті '
                                    || app_tp_name
                                    || ' не визначено працездатність особи'
                                WHEN age_year < 0
                                THEN
                                       'Неможливо визначити право для '
                                    || uss_person.api$sc_tools.get_pib (
                                           tpp_sc)
                                    || ' в зв’язку із тим, що для допомоги на дітей малозабезпечиним сім''ям за документами '
                                    || app_tp_name
                                    || ' не визначено вік особи'
                                ELSE
                                    ''
                            END    AS Err_1,
                            CASE
                                WHEN     apa.Workable = 'T'
                                     AND apa.NotWorkable != 'T'
                                     AND age_year >= 18
                                     AND NOT (   apa.IsWork = 'T'
                                              OR                    --Працює ;
                                                 apa.IsFOP = 'T'
                                              OR                        --ФОП;
                                                 apa.IsEmploymentCenter = 'T'
                                              OR --На обліку в центрі зайнятості;
                                                 apa.IsCaringChildUnder3 =
                                                 'T'
                                              OR --стан Доглядає за дитиною до 3 років з анкети
                                                 apa.IsCaringChildUnder6 =
                                                 'T'
                                              OR --стан Доглядає за дитиною до 6 років з анкети
                                                 apa.IsCaringOlderPerson =
                                                 'T'
                                              OR --Доглядає за особою похилого віку, 80-ти річною особою
                                                 apa.IsCaringSickChild = 'T'
                                              OR --Доглядає за хворою дитиною, якій не встановлено інвалідність
                                                 apa.IsCaringInvalid_1 = 'T'
                                              OR --Доглядає за особою з інвалідністю І групи
                                                 apa.IsCaringInvalid_2 = 'T'
                                              OR --Доглядає за особою з інвалідністю ІІ групи внаслідок психічного розладу
                                                 apa.IsCaringInvChildUnder18 =
                                                 'T'
                                              OR --стан Доглядає за дитиною до 6 років з анкети
                                                 apa.IsShool = 'T' --Навчається;
                                                                  )
                                THEN
                                       'За даними анкети неможливо визначити право для '
                                    || uss_person.api$sc_tools.get_pib (
                                           tpp_sc)
                                    || 'в зв’язку із тим, що для допомоги малозабезпеченим сім’ям в Анкеті '
                                    || app_tp_name
                                    || ' визначено, що Заявник «Працездатний» при цьому не визначено жодного із типів зайнятості'
                                ELSE
                                    ''
                            END    AS Err_2,
                            CASE
                                WHEN     apa.Workable != 'T'
                                     AND apa.NotWorkable = 'T'
                                     AND age_year >= 18
                                     AND NOT (   apa.IsPensioner = 'T'
                                              OR apa.IsInvalid = 'T'
                                              OR (    apa.IsNotWork = 'T'
                                                  AND apa.FamilyConnect IN
                                                          ('PILM', 'PILF')))
                                THEN
                                       'За даними анкети неможливо визначити право для '
                                    || uss_person.api$sc_tools.get_pib (
                                           tpp_sc)
                                    || 'в зв’язку із тим, що для допомоги малозабезпеченим сім’ям в Анкеті '
                                    || app_tp_name
                                    || ' визначено, що Заявник «Непрацездатний» при цьому не визначено жодної причини непрацездатності (особа Заявник – «Пенсіонер» чи «Особа з інвалідністю» або «Не працює» для «Свекор/свекруха» або «Тесть/теща»)'
                                WHEN apa.Workable = 'T' AND age_year >= 60
                                THEN
                                       'За даними анкети неможливо визначити право для '
                                    || uss_person.api$sc_tools.get_pib (
                                           tpp_sc)
                                    || 'в зв’язку із тим, що для допомоги малозабезпеченим сім’ям в Анкеті '
                                    || app_tp_name
                                    || ' вказано «Працездатний» при цьому особа досягла віку більше ніж 60 років'
                                ELSE
                                    ''
                            END    AS Err_3
                       FROM bd
                            JOIN v_ap_person_anceta apa
                                ON     apa.tpd_sc = bd.tpp_sc
                                   AND apa.tpd_pd = bd.tpp_pd
                      WHERE    tpp_app_tp IN ('Z', 'FM')
                            OR (    tpp_app_tp = 'FP'
                                AND apa.FamilyConnect IN ('B', 'UB')))
              SELECT LISTAGG ("TXT", g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY 1)    Err_Text
                FROM Checks
                         UNPIVOT (TXT
                             FOR rn
                             IN (Err_1 AS 1, Err_2 AS 2, Err_3 AS 3))
            GROUP BY tpp_pd;
    --Для перевірки права для правила "Члени сім'ї відповідають умовам Порядку №250 для призначення" для послуги з Ід=249 необхідно додати контроль:
    --Якщо будь-якому учаснику звернення більш ніж 60 років включно і в анкеті в атрибуті "Працездатний" зазначено "Так", то помилка.
    --Текст помилки: "Особа <ПІБ> досягла віку більше ніж 60 років, проте в анкеті вказано, що вона працездатна"

    BEGIN
        FOR p IN Check_Family
        LOOP
            MERGE_tmp_errors_list (p_pd, p.Err_Text);
        END LOOP;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG20 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
        Якщо по особі "Заявник" знайдено інше рішення по послузі у статусі "На розрахунку", "Розраховано", "Призначено", то видавати повідомлення:
        "Для Заявника <ПІБ> в органі соціального захисту" <код органу> призначається <назва послуги> <номер рішення> за зверненням особи <номер звернення> від <дата звернення>"
        Якщо по особі "Заявник" знайдено інше рішення у статусі "Нараховано", то видавати повідомлення: "Для Заявника <ПІБ> в органі соціального захисту" <код органу> призначено <назва послуги> <номер рішення>"
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          app
                          AS
                              (SELECT calc_dt,
                                      tpp_pd,
                                      tpp_sc,
                                      tpp_app_tp,
                                      DECODE (tpp_app_tp,
                                              'Z', 'Заявника',
                                              'FP', 'Утриманця',
                                              'FM', 'Члена сім’ї',
                                              '')    AS app_tp_name,
                                      app.pd_nst,
                                      app.pd_ap,
                                      ap1.ap_ap_main
                                 FROM v_tmp_person_for_decision app
                                      JOIN appeal ap1 ON ap1.ap_id = app.pd_ap
                                WHERE     tpp_pd = p_pd
                                      AND pd_nst != 248
                                      AND pd_nst != 251
                                      AND (   (    pd_nst IN (275, 901)
                                               AND tpp_app_tp = 'FP')
                                           OR pd_nst NOT IN (275, 901))),
                          app248
                          AS
                              (SELECT calc_dt,
                                      tpp_pd,
                                      tpp_sc,
                                      tpp_app_tp,
                                      DECODE (tpp_app_tp,
                                              'Z', 'Заявника',
                                              'FP', 'Утриманця',
                                              'FM', 'Члена сім’ї',
                                              '')    AS app_tp_name,
                                      app.pd_nst,
                                      app.pd_ap,
                                      ap1.ap_ap_main
                                 FROM v_tmp_person_for_decision app
                                      JOIN appeal ap1 ON ap1.ap_id = app.pd_ap
                                WHERE     tpp_pd = p_pd
                                      AND pd_nst = 248
                                      AND API$CALC_RIGHT.get_docx_list_cnt (
                                              tpp_pd,
                                              tpp_sc,
                                              '115,200,201,809',
                                              calc_dt) > 0),
                          app251
                          AS
                              (SELECT calc_dt,
                                      tpp_pd,
                                      tpp_sc,
                                      tpp_app_tp,
                                      DECODE (tpp_app_tp,
                                              'Z', 'Заявника',
                                              'FP', 'Утриманця',
                                              'FM', 'Члена сім’ї',
                                              '')
                                          AS app_tp_name,
                                      app.pd_nst,
                                      app.pd_ap,
                                      ap1.ap_ap_main,
                                      API$ACCOUNT.get_docx_dt (tpp_pd,
                                                               tpp_sc,
                                                               10196,
                                                               2579,
                                                               app.calc_dt)
                                          AS doc_start_dt,
                                      API$ACCOUNT.get_docx_dt (tpp_pd,
                                                               tpp_sc,
                                                               10196,
                                                               2580,
                                                               app.calc_dt)
                                          AS doc_stop_dt
                                 FROM v_tmp_person_for_decision app
                                      JOIN appeal ap1 ON ap1.ap_id = app.pd_ap
                                WHERE tpp_pd = p_pd AND pd_nst = 251),
                          pd
                          AS
                              (SELECT ap.ap_id,
                                      ap.ap_ap_main,
                                      --app.app_id, app.app_tp,
                                      app.app_sc        AS x_sc,
                                      pd.pd_nst,
                                      pd.pd_st,
                                      pd.com_org,
                                      pd.pd_start_dt    AS x_start_dt,
                                      pd.pd_stop_dt     AS x_stop_dt,
                                         ' призначається '
                                      || st.nst_name
                                      || ' '
                                      || pd.pd_num
                                      || ' за зверненням особи '
                                      || ap.ap_num
                                      || ' від '
                                      || TO_CHAR (ap.ap_reg_dt, 'dd.mm.yyyy')
                                      || '.'            AS pd_st_txt
                                 FROM appeal ap
                                      JOIN ap_person app
                                          ON     app.app_ap = ap.ap_id
                                             AND app.app_tp IN
                                                     ('Z', 'FP', 'FM')
                                             AND app.history_status = 'A'
                                      JOIN pc_decision pd
                                          ON     pd.pd_ap = ap.ap_id
                                             AND pd.pd_st IN ('R0',
                                                              'R1',
                                                              'P',
                                                              'K')
                                      JOIN uss_ndi.v_ndi_service_type st
                                          ON pd.pd_nst = st.nst_id
                                WHERE        pd_nst NOT IN (248, 251)
                                         AND (    pd_nst IN (275,
                                                             901,
                                                             268,
                                                             265)
                                              AND app_tp = 'FP')
                                      OR     pd_nst NOT IN (275,
                                                            901,
                                                            268,
                                                            265)
                                         AND EXISTS
                                                 (SELECT 1
                                                    FROM v_tmp_person_for_decision
                                                         t
                                                   WHERE t.tpp_sc = app_sc)
                               UNION ALL
                               SELECT ap.ap_id,
                                      ap.ap_ap_main,
                                      --app.app_id, app.app_tp,
                                      f.pdf_sc
                                          AS x_sc,
                                      pd.pd_nst,
                                      pd.pd_st,
                                      pd.com_org,
                                      (SELECT MIN (d.pdd_start_dt)
                                         FROM pd_payment p
                                              JOIN pd_detail d
                                                  ON     p.pdp_id = d.pdd_pdp
                                                     AND d.pdd_key = f.pdf_id
                                        WHERE     p.pdp_pd = pd_id
                                              AND p.history_status = 'A')
                                          AS x_start_dt,
                                      (SELECT MAX (d.pdd_stop_dt)
                                         FROM pd_payment p
                                              JOIN pd_detail d
                                                  ON     p.pdp_id = d.pdd_pdp
                                                     AND d.pdd_key = f.pdf_id
                                        WHERE     p.pdp_pd = pd_id
                                              AND p.history_status = 'A')
                                          AS x_stop_dt,
                                         ' призначено '
                                      || st.nst_name
                                      || ' '
                                      || pd.pd_num
                                      || '.'
                                          AS pd_st_txt
                                 FROM appeal ap
                                      JOIN pc_decision pd
                                          ON     pd.pd_ap = ap.ap_id
                                             AND pd.pd_st IN ('S', 'PS')
                                      JOIN pd_family f
                                          ON     f.pdf_pd = pd_id
                                             AND f.history_status = 'A'
                                      JOIN uss_ndi.v_ndi_service_type st
                                          ON pd.pd_nst = st.nst_id
                                WHERE     pd_nst NOT IN (248, 251)
                                      AND EXISTS
                                              (SELECT 1
                                                 FROM v_tmp_person_for_decision
                                                      t
                                                WHERE t.tpp_sc = f.pdf_sc)--AND (pd_nst IN (275, 901, 268, 265) /*AND app_tp = 'FP'*/)
                                                                          --     OR
                                                                          --     pd_nst NOT IN (275, 901, 268, 265)
                                                                          ),
                          pd248
                          AS
                              (SELECT ap.ap_id,
                                      ap.ap_ap_main,
                                      app.app_id,
                                      app.app_sc,
                                      app.app_tp,
                                      pd.pd_nst,
                                      pd.pd_st,
                                      pd.pd_start_dt,
                                      pd.pd_stop_dt,
                                      pd.com_org,
                                      CASE
                                          WHEN pd.pd_st IN ('R0',
                                                            'R1',
                                                            'P',
                                                            'K')
                                          THEN
                                                 ' призначається '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || ' за зверненням особи '
                                              || ap.ap_num
                                              || ' від '
                                              || TO_CHAR (ap.ap_reg_dt,
                                                          'dd.mm.yyyy')
                                              || '.'
                                          ELSE
                                                 ' призначено '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || '.'
                                      END    AS pd_st_txt
                                 FROM appeal ap
                                      JOIN ap_person app
                                          ON     app.app_ap = ap.ap_id
                                             AND app.app_tp IN
                                                     ('Z', 'FP', 'FM')
                                             AND app.history_status = 'A'
                                      JOIN pc_decision pd
                                          ON     pd.pd_ap = ap.ap_id
                                             AND pd.pd_st IN ('R0',
                                                              'R1',
                                                              'P',
                                                              'K',
                                                              'S')
                                      JOIN uss_ndi.v_ndi_service_type st
                                          ON pd.pd_nst = st.nst_id
                                WHERE pd_nst = 248),
                          pd251
                          AS
                              (SELECT ap.ap_id,
                                      ap.ap_ap_main,
                                      app.app_id,
                                      app.app_sc,
                                      app.app_tp,
                                      pd.pd_nst,
                                      pd.pd_st,
                                      pd.pd_start_dt,
                                      pd.pd_stop_dt,
                                      pd.com_org,
                                      CASE
                                          WHEN pd.pd_st IN ('R0',
                                                            'R1',
                                                            'P',
                                                            'K')
                                          THEN
                                                 ' призначається '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || ' за зверненням особи '
                                              || ap.ap_num
                                              || ' від '
                                              || TO_CHAR (ap.ap_reg_dt,
                                                          'dd.mm.yyyy')
                                              || '.'
                                          ELSE
                                                 ' призначено '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || '.'
                                      END
                                          AS pd_st_txt,
                                      API$PC_DECISION.get_doc_dt (app_id,
                                                                  10196,
                                                                  2579)
                                          AS doc_start_dt,
                                      API$PC_DECISION.get_doc_dt (app_id,
                                                                  10196,
                                                                  2580)
                                          AS doc_stop_dt
                                 FROM appeal ap
                                      JOIN ap_person app
                                          ON     app.app_ap = ap.ap_id
                                             AND app.app_tp IN
                                                     ('Z', 'FP', 'FM')
                                             AND app.history_status = 'A'
                                      JOIN pc_decision pd
                                          ON     pd.pd_ap = ap.ap_id
                                             AND pd.pd_st IN ('R0',
                                                              'R1',
                                                              'P',
                                                              'K',
                                                              'S')
                                      JOIN uss_ndi.v_ndi_service_type st
                                          ON pd.pd_nst = st.nst_id
                                WHERE pd_nst = 251)
                          SELECT p_pd               AS x_id,
                                    'Для '
                                 || app.app_tp_name
                                 || ' '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' в органі соціального захисту '
                                 || pd.com_org
                                 || pd.pd_st_txt    AS x_text
                            FROM app, pd
                           WHERE     app.pd_ap != pd.ap_id
                                 AND (   app.pd_ap != pd.ap_ap_main
                                      OR pd.ap_ap_main IS NULL)
                                 AND (   app.ap_ap_main != pd.ap_id
                                      OR app.ap_ap_main IS NULL)
                                 AND (   (    app.pd_nst IN (275, 901)
                                          AND pd.pd_nst IN (275, 901))
                                      OR (app.pd_nst = pd.pd_nst))
                                 AND app.tpp_sc = pd.x_sc
                                 AND (   (    pd.pd_st = 'S'
                                          AND app.calc_dt BETWEEN pd.x_start_dt
                                                              AND pd.x_stop_dt)
                                      OR (pd.pd_st IN ('R0',
                                                       'R1',
                                                       'P',
                                                       'K')))
                          UNION ALL
                          SELECT p_pd               AS x_id,
                                    'Для '
                                 || app.app_tp_name
                                 || ' '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' в органі соціального захисту '
                                 || pd.com_org
                                 || pd.pd_st_txt    AS x_text
                            FROM app248 app
                                 JOIN pd248 pd
                                     ON     app.tpp_sc = pd.app_sc
                                        AND app.pd_ap != pd.ap_id
                                 JOIN ap_document apd
                                     ON     apd_app = pd.app_id
                                        AND apd_ndt IN (200, 201)
                                        AND apd.history_status = 'A'
                           WHERE     (   app.pd_ap != pd.ap_ap_main
                                      OR pd.ap_ap_main IS NULL)
                                 AND (   app.ap_ap_main != pd.ap_id
                                      OR app.ap_ap_main IS NULL)
                          UNION ALL
                          SELECT p_pd               AS x_id,
                                    'Для '
                                 || app.app_tp_name
                                 || ' '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' в органі соціального захисту '
                                 || pd.com_org
                                 || pd.pd_st_txt    AS x_text
                            FROM app251 app
                                 JOIN pd251 pd
                                     ON     app.tpp_sc = pd.app_sc
                                        AND app.pd_ap != pd.ap_id
                                        AND (   app.doc_start_dt BETWEEN pd.doc_start_dt
                                                                     AND pd.doc_stop_dt
                                             OR app.doc_stop_dt BETWEEN pd.doc_start_dt
                                                                    AND pd.doc_stop_dt
                                             OR pd.doc_start_dt BETWEEN app.doc_start_dt
                                                                    AND app.doc_stop_dt
                                             OR pd.doc_stop_dt BETWEEN app.doc_start_dt
                                                                   AND app.doc_stop_dt)
                           WHERE     (   app.pd_ap != pd.ap_ap_main
                                      OR pd.ap_ap_main IS NULL)
                                 AND (   app.ap_ap_main != pd.ap_id
                                      OR app.ap_ap_main IS NULL)
                                 AND (   (    pd.pd_st = 'S'
                                          AND app.calc_dt BETWEEN pd.pd_start_dt
                                                              AND ADD_MONTHS (
                                                                      pd.pd_stop_dt,
                                                                      6))
                                      OR (pd.pd_st IN ('R0',
                                                       'R1',
                                                       'P',
                                                       'K'))))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG21 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
        якщо у зверненні відсутній документ "Довідка про взяття на облік внутрішньо переміщеної особи" прикріплений до Заявника:
        Текст повідомлення про помилку : "Для Заявника <ПІБ> не долучено до звернення "Довідка про взяття на облік внутрішньо переміщеної особи"

        якщо у зверненні у документі "Довідка про взяття на облік внутрішньо переміщеної особи", який прикріплений до Заявника не заповнено атрибути:
        "Дата видачі довідки", "Номер довідки", "Назва органу, що видав довідку"
        Текст повідомлення про помилку : "Для Заявника <ПІБ> не заповнено обов'язкові атрибути документу "Довідка про взяття на облік внутрішньо переміщеної особи" "Дата видачі довідки", "Номер довідки", "Назва органу, що видав довідку"

        якщо у зверненні у документі "Довідка про взяття на облік внутрішньо переміщеної особи", який прикріплений до Заявника в атрибуті "Статус довідки" пусто або зазначено "Знята з обліку"
        Текст повідомлення про помилку : "Для Заявника <ПІБ> документ "Довідка про взяття на облік внутрішньо переміщеної особи" не дійсний, бо в атрибуті
        "Статус довідки" пусто або зазначено "Знята з обліку"
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          vpo
                          AS
                              (SELECT app.com_org,
                                      tpp_sc,
                                      tpp_app_tp,
                                      REGEXP_REPLACE (api$calc_right.get_docx_string (
                                                          app.pd_id,
                                                          tpp_sc,
                                                          10052,
                                                          1756,
                                                          calc_dt,
                                                          ''),
                                                      '^\D*',
                                                      '')    AS vpo_num
                                 FROM v_tmp_person_for_decision app
                                WHERE app.pd_id = p_pd),
                          vporeg
                          AS
                              (SELECT com_org,
                                      tpp_sc,
                                      tpp_app_tp,
                                      --lpad(SUBSTR(vpo_num, 1, regexp_INSTR (vpo_num, '-', 1 ,1 )-1 ),4,'0') AS com_org_vpo
                                      LPAD (
                                          REGEXP_REPLACE (
                                              SUBSTR (vpo_num,
                                                      1,
                                                        REGEXP_INSTR (vpo_num,
                                                                      '-',
                                                                      1,
                                                                      1)
                                                      - 1),
                                              '\D',
                                              ''),
                                          4,
                                          '0')    AS com_org_vpo
                                 FROM vpo)
                          SELECT                       --com_org, com_org_vpo,
                                 p_pd    AS x_id,
                                 CASE
                                     WHEN com_org =
                                          uss_ndi.API$DIC_DECODING.District2ComOrgV01 (
                                              p_org_src   => com_org_vpo)
                                     THEN
                                         ''
                                     WHEN com_org = '5' || com_org_vpo
                                     THEN
                                         ''
                                     WHEN com_org =
                                          (SELECT MAX (org_org)
                                             FROM v_opfu
                                            WHERE     org_code =
                                                      '5' || com_org_vpo
                                                  AND org_to = 32)
                                     THEN
                                         ''
                                     ELSE
                                            'Довідка про взяття на облік внутрішньо переміщеної особи" для '
                                         || uss_person.api$sc_tools.get_pib (
                                                tpp_sc)
                                         || ' видана іншим структурним підрозділом з питань соціального захисту населення '
                                         || com_org_vpo
                                         || ', який не належить до території діяльності органу '
                                         || com_org
                                 END     AS x_text
                            FROM vporeg
                           WHERE tpp_app_tp IN ('Z', 'FP')
                          UNION ALL
                          SELECT p_pd      AS x_id,
                                 api$calc_right.check_docx_filled (
                                     p_pd,
                                     tpp_sc,
                                     10052,
                                     '1756,1757,1759',
                                     calc_dt,
                                     1)    AS x_text                       --1
                            FROM v_tmp_person_for_decision app
                           WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z'
                          UNION ALL
                          SELECT p_pd                                                           AS x_id,
                                    'Для Заявника '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' документ "Довідка про взяття на облік внутрішньо переміщеної особи" не дійсний, бо в атрибуті'
                                 || ' "Статус довідки" пусто або зазначено "Знята з обліку"'    AS x_text                                           --1
                            FROM v_tmp_person_for_decision app
                           WHERE     app.pd_id = p_pd
                                 AND tpp_app_tp = 'Z'
                                 AND api$calc_right.get_docx_string (p_pd,
                                                                     tpp_sc,
                                                                     10052,
                                                                     1855,
                                                                     calc_dt,
                                                                     '-') !=
                                     'A'
                          UNION ALL
                          SELECT p_pd                                                                            AS x_id,
                                    'Довідка ВПО для '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' не пройшла верифікацію (результат верифікації у протоколі верифікації)'    AS x_text
                            FROM v_tmp_person_for_decision app
                           WHERE     app.pd_id = p_pd
                                 AND tpp_app_tp = 'Z'
                                 AND api$calc_right.check_vfx_st (p_pd,
                                                                  tpp_sc,
                                                                  10052,
                                                                  calc_dt) !=
                                     'X'
                          UNION ALL
                          SELECT p_pd      AS x_id,
                                 api$calc_right.check_docx_filled (
                                     p_pd,
                                     tpp_sc,
                                     10052,
                                     '1756,1757,1759',
                                     calc_dt,
                                     1)    AS x_text                       --1
                            FROM v_tmp_person_for_decision app
                           WHERE app.pd_id = p_pd AND tpp_app_tp = 'Z'
                          UNION ALL
                          SELECT p_pd                                                                                         AS x_id,
                                    'Для Утриманця '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' не долучено до звернення "Довідка про взяття на облік внутрішньо переміщеної особи"'    AS x_text                                                                       --1
                            FROM v_tmp_person_for_decision app
                           WHERE     app.pd_id = p_pd
                                 AND tpp_app_tp = 'FP'
                                 AND api$account.get_docx_count (p_pd,
                                                                 tpp_sc,
                                                                 10052,
                                                                 calc_dt) = 0
                          /*
                                              and NOT EXISTS (SELECT 1 FROM ap_person app1
                                                              WHERE app1.app_ap = app.app_ap
                                                                    AND app1.app_tp = 'FP'
                                                                    AND app1.history_status = 'A'
                                                                    AND api$calc_right.get_docx_count(p_pd, tpp_sc, 10052, calc_dt) > 0)*/
                          UNION ALL
                          SELECT p_pd                                                           AS x_id,
                                    'Для Утриманця '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' документ "Довідка про взяття на облік внутрішньо переміщеної особи" не дійсний, бо в атрибуті'
                                 || ' "Статус довідки" пусто або зазначено "Знята з обліку"'    AS x_text                                           --1
                            FROM v_tmp_person_for_decision app
                           WHERE     tpp_pd = p_pd
                                 AND tpp_app_tp = 'FP'
                                 AND api$account.get_docx_count (p_pd,
                                                                 tpp_sc,
                                                                 10052,
                                                                 calc_dt) > 0
                                 AND api$calc_right.get_docx_string (p_pd,
                                                                     tpp_sc,
                                                                     10052,
                                                                     1855,
                                                                     calc_dt,
                                                                     '-') !=
                                     'A'
                          UNION ALL
                          SELECT p_pd                                                                            AS x_id,
                                    'Довідка ВПО для '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' не пройшла верифікацію (результат верифікації у протоколі верифікації)'    AS x_text
                            FROM v_tmp_person_for_decision app
                           WHERE     tpp_pd = p_pd
                                 AND tpp_app_tp = 'FP'
                                 AND api$calc_right.check_vfx_st (p_pd,
                                                                  tpp_sc,
                                                                  10052,
                                                                  calc_dt) !=
                                     'X')
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    EXCEPTION
        WHEN OTHERS
        THEN
            FOR pd IN (SELECT *
                         FROM pc_decision
                        WHERE pd_id = p_pd)
            LOOP
                DBMS_OUTPUT.put_line (' Зверненя з помилкою = ' || pd.pd_ap);
            END LOOP;

            RAISE;
    END;

    --========================================
    PROCEDURE Check_ALG22 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
        3. Для правила "Наявність статусу ВПО у неповнолітніх дітей, які перемістились з ВПО" встановлювати "Помилка":

        якщо у зверненні відсутній документ "Довідка про взяття на облік внутрішньо переміщеної особи" прикріплений до хоча б одного із "Утриманців":
        Текст повідомлення про помилку : "Для "Утриманця" <ПІБ> не долучено до звернення "Довідка про взяття на облік внутрішньо переміщеної особи"

        якщо у зверненні у документі "Довідка про взяття на облік внутрішньо переміщеної особи", який прикріплений до хоча б одного із "Утриманців" не заповнено атрибути:
        "Дата видачі довідки", "Номер довідки", "Назва органу, що видав довідку"
        Текст повідомлення про помилку : "Для "Утриманця" <ПІБ> не заповнено обов'язкові атрибути документу "Довідка про взяття на облік внутрішньо переміщеної особи" "Дата видачі довідки", "Номер довідки", "Назва органу, що видав довідку"

        якщо у зверненні у документі "Довідка про взяття на облік внутрішньо переміщеної особи", який прикріплений до хоча б одного із "Утриманців" в атрибуті "Статус довідки" пусто або зазначено "Знята з обліку"
        Текст повідомлення про помилку : "Для "Утриманця" <ПІБ> документ "Довідка про взяття на облік внутрішньо переміщеної особи" не дійсний, бо в атрибуті
        "Статус довідки" пусто або зазначено "Знята з обліку"
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          vpo
                          AS
                              (SELECT app.com_org,
                                      tpp_sc,
                                      tpp_app_tp,
                                      REGEXP_REPLACE (api$calc_right.get_docx_string (
                                                          app.pd_id,
                                                          tpp_sc,
                                                          10052,
                                                          1756,
                                                          calc_dt,
                                                          ''),
                                                      '^\D*',
                                                      '')    AS vpo_num
                                 FROM v_tmp_person_for_decision app
                                WHERE app.pd_id = p_pd),
                          vporeg
                          AS
                              (SELECT com_org,
                                      tpp_sc,
                                      tpp_app_tp,
                                      LPAD (SUBSTR (vpo_num,
                                                    1,
                                                      REGEXP_INSTR (vpo_num,
                                                                    '-',
                                                                    1,
                                                                    1)
                                                    - 1),
                                            4,
                                            '0')    AS com_org_vpo
                                 FROM vpo)
                          SELECT                       --com_org, com_org_vpo,
                                 p_pd    AS x_id,
                                 CASE
                                     WHEN com_org =
                                          uss_ndi.API$DIC_DECODING.District2ComOrgV01 (
                                              p_org_src   => com_org_vpo)
                                     THEN
                                         ''
                                     WHEN com_org = '5' || com_org_vpo
                                     THEN
                                         ''
                                     WHEN com_org =
                                          (SELECT MAX (org_org)
                                             FROM v_opfu
                                            WHERE     org_code =
                                                      '5' || com_org_vpo
                                                  AND org_to = 32)
                                     THEN
                                         ''
                                     ELSE
                                            'Довідка про взяття на облік внутрішньо переміщеної особи" для '
                                         || uss_person.api$sc_tools.get_pib (
                                                tpp_sc)
                                         || 'видана іншим структурним підрозділом з питань соціального захисту населення '
                                         || com_org_vpo
                                         || ', який не належить до території діяльності органу '
                                         || com_org
                                 END     AS x_text
                            FROM vporeg
                           WHERE tpp_app_tp = 'FP'
                          UNION ALL
                          SELECT p_pd AS x_id, 'Утриманці відсутні' AS x_text                  --1
                            FROM v_tmp_person_for_decision app
                           WHERE     tpp_pd = p_pd
                                 AND tpp_app_tp = 'Z'
                                 AND NOT EXISTS
                                         (SELECT 1
                                            FROM v_tmp_person_for_decision app
                                           WHERE     tpp_pd = p_pd
                                                 AND tpp_app_tp != 'Z')
                          UNION ALL
                          SELECT p_pd                                                                                         AS x_id,
                                    'Для Утриманця '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' не долучено до звернення "Довідка про взяття на облік внутрішньо переміщеної особи"'    AS x_text                                                                       --1
                            FROM v_tmp_person_for_decision app
                           WHERE     tpp_pd = p_pd
                                 AND tpp_app_tp = 'FP'
                                 AND api$account.get_docx_count (p_pd,
                                                                 tpp_sc,
                                                                 10052,
                                                                 calc_dt) = 0
                          /*
                          and NOT EXISTS (SELECT 1 FROM ap_person app1
                                          WHERE app1.app_ap = app.app_ap
                                                AND app1.app_tp = 'FP'
                                                AND app1.history_status = 'A'
                                                AND api$calc_right.get_docx_count(p_pd, tpp_sc, 10052, calc_dt) > 0)*/
                          UNION ALL
                          SELECT p_pd      AS x_id,
                                 api$calc_right.check_docx_filled (
                                     p_pd,
                                     tpp_sc,
                                     10052,
                                     '1756,1757,1759',
                                     calc_dt,
                                     0)    AS x_text                       --1
                            FROM v_tmp_person_for_decision app
                           WHERE tpp_pd = p_pd AND tpp_app_tp = 'FP'
                          UNION ALL
                          SELECT p_pd                                                           AS x_id,
                                    'Для Утриманця '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' документ "Довідка про взяття на облік внутрішньо переміщеної особи" не дійсний, бо в атрибуті'
                                 || ' "Статус довідки" пусто або зазначено "Знята з обліку"'    AS x_text                                           --1
                            FROM v_tmp_person_for_decision app
                           WHERE     tpp_pd = p_pd
                                 AND tpp_app_tp = 'FP'
                                 AND api$account.get_docx_count (p_pd,
                                                                 tpp_sc,
                                                                 10052,
                                                                 calc_dt) > 0
                                 AND api$calc_right.get_docx_string (p_pd,
                                                                     tpp_sc,
                                                                     10052,
                                                                     1855,
                                                                     calc_dt,
                                                                     '-') !=
                                     'A'
                          UNION ALL
                          SELECT p_pd                                                                            AS x_id,
                                    'Довідка ВПО для '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' не пройшла верифікацію (результат верифікації у протоколі верифікації)'    AS x_text
                            FROM v_tmp_person_for_decision app
                           WHERE     tpp_pd = p_pd
                                 AND tpp_app_tp = 'FP'
                                 AND api$calc_right.check_vfx_st (p_pd,
                                                                  tpp_sc,
                                                                  10052,
                                                                  calc_dt) !=
                                     'X')
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG23 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    --l_reg_dt DATE;
    BEGIN
        /*
            SELECT MAX(ap.ap_reg_dt)
               INTO l_reg_dt
            FROM appeal ap
                 JOIN pc_decision ON ap_id = pd_ap
            WHERE pd_id = p_pd;
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                          AS x_id,
                                --'Учасники звернення не перемістилися з території територіальних громад, '||
                                --'що розташовані в районі проведення воєнних (бойових) дій або які перебувають в тимчасовій окупації, '||
                                --'оточенні (блокуванні)'
                                --'Станом на дату звернення (на дату реєстрації заяви) учасники звернення не перемістилися з території територіальних громад, '||
                                --'що розташовані в районі проведення воєнних (бойових) дій або які перебувають в тимчасовій окупації, оточенні (блокуванні)'
                                'Станом на дату звернення (на дату реєстрації заяви) '
                             || 'особа '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' не перемістилася з території територіальних громад, '
                             || 'що розташовані в районі проведення воєнних (бойових) дій або які перебувають в тимчасовій окупації, '
                             || 'оточенні (блокуванні)'    --', при цьому інші учасники звернення перемістилися з території територіальних громад, '||
                                                           --'що розташовані в районі проведення воєнних (бойових) дій або які перебувають в тимчасовій окупації, оточенні (блокуванні)'
                                                           AS x_text       --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z'                 /*, 'FP'*/
                                                   )
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM uss_ndi.v_Ndi_Katottg k
                                             JOIN uss_ndi.V_NDI_KAOT_STATE s
                                                 ON     (   (    s.kaots_kaot =
                                                                 k.kaot_id
                                                             AND k.kaot_TP =
                                                                 'K')
                                                         OR (    k.kaot_id =
                                                                 k.kaot_kaot_l3
                                                             AND s.kaots_kaot =
                                                                 k.kaot_kaot_l3)
                                                         OR (    k.kaot_id =
                                                                 k.kaot_kaot_l4
                                                             AND (   s.kaots_kaot =
                                                                     k.kaot_kaot_l3
                                                                  OR s.kaots_kaot =
                                                                     k.kaot_kaot_l4))
                                                         OR (    k.kaot_id =
                                                                 k.kaot_kaot_l5
                                                             AND (   s.kaots_kaot =
                                                                     k.kaot_kaot_l3
                                                                  OR s.kaots_kaot =
                                                                     k.kaot_kaot_l4
                                                                  OR s.kaots_kaot =
                                                                     k.kaot_kaot_l5)))
                                                    AND s.history_status = 'A'
                                       WHERE     kaot_id =
                                                 COALESCE (API$CALC_RIGHT.get_docx_id (
                                                               tpp_pd,
                                                               tpp_sc,
                                                               10052,
                                                               2292,
                                                               app.calc_dt),
                                                           API$CALC_RIGHT.get_docx_id (
                                                               tpp_pd,
                                                               tpp_sc,
                                                               605,
                                                               1775,
                                                               app.calc_dt))
                                             AND app.calc_dt BETWEEN NVL (
                                                                         KAOTS_START_DT,
                                                                         app.calc_dt)
                                                                 AND NVL (
                                                                         KAOTS_STOP_DT,
                                                                         app.calc_dt)
                                             AND app.calc_dt BETWEEN NVL (
                                                                         KAOT_START_DT,
                                                                         app.calc_dt)
                                                                 AND NVL (
                                                                         KAOT_STOP_DT,
                                                                         app.calc_dt)
                                             AND KAOTS_TP IN
                                                     ('TO', 'PMO', 'BD'))
                      /*UNION ALL
                      SELECT p_pd as x_id,
                             CASE WHEN k_a.kaot_code IS NOT NULL AND k_d.kaot_code IS NOT NULL AND k_a.kaot_code != k_d.kaot_code
                               THEN
                                 'В довідці ВПО та анкеті для особи ' ||uss_person.api$sc_tools.get_pib(tpp_sc)|| ' зазначено різні значення, ' ||
                                  'а саме, в полі КАТТОТГ у довідці ВПО зазначено ' || k_d.kaot_code ||
                                  ', а в Анкеті зазначено ' || k_a.kaot_code
                               ELSE
                                 ''
                             END  AS x_text          --1
                      FROM  v_tmp_person_for_decision app
                            LEFT JOIN uss_ndi.v_Ndi_Katottg k_a ON k_a.kaot_id = API$CALC_RIGHT.get_docx_id(tpp_pd, tpp_sc,   605, 1775, app.calc_dt, 0)
                            LEFT JOIN uss_ndi.v_Ndi_Katottg k_d ON k_d.kaot_id = API$CALC_RIGHT.get_docx_id(tpp_pd, tpp_sc, 10052, 2292, app.calc_dt, 0)
                      WHERE tpp_pd = p_pd
                            and tpp_app_tp IN ('Z')*/
                      UNION ALL
                      SELECT p_pd                                  AS x_id,
                             -- Перевірка відповідності двох kaot з урахування рівня
                             api$calc_right.Check_kaot (ank_kaot_id,
                                                        ank_kaot_code,
                                                        ank_kaot_lvl,
                                                        doc_kaot_id,
                                                        doc_kaot_code,
                                                        doc_kaot_lvl,
                                                        tpp_sc)    AS x_text
                        FROM (SELECT p_pd             AS x_id,
                                     tpp_sc,
                                     k_a.kaot_id      AS ank_kaot_id,
                                     k_a.kaot_code    AS ank_kaot_code,
                                     k_d.kaot_id      AS doc_kaot_id,
                                     k_d.kaot_code    AS doc_kaot_code,
                                     CASE k_a.kaot_id
                                         WHEN k_a.kaot_kaot_l1 THEN 1
                                         WHEN k_a.kaot_kaot_l2 THEN 2
                                         WHEN k_a.kaot_kaot_l3 THEN 3
                                         WHEN k_a.kaot_kaot_l4 THEN 4
                                         WHEN k_a.kaot_kaot_l5 THEN 5
                                     END              AS ank_kaot_lvl,
                                     CASE k_d.kaot_id
                                         WHEN k_d.kaot_kaot_l1 THEN 1
                                         WHEN k_d.kaot_kaot_l2 THEN 2
                                         WHEN k_d.kaot_kaot_l3 THEN 3
                                         WHEN k_d.kaot_kaot_l4 THEN 4
                                         WHEN k_d.kaot_kaot_l5 THEN 5
                                     END              AS doc_kaot_lvl
                                FROM v_tmp_person_for_decision app
                                     LEFT JOIN uss_ndi.v_Ndi_Katottg k_a
                                         ON k_a.kaot_id = API$CALC_RIGHT.get_docx_id (
                                                              tpp_pd,
                                                              tpp_sc,
                                                              605,
                                                              1775,
                                                              app.calc_dt,
                                                              0)
                                     LEFT JOIN uss_ndi.v_Ndi_Katottg k_d
                                         ON k_d.kaot_id = API$CALC_RIGHT.get_docx_id (
                                                              tpp_pd,
                                                              tpp_sc,
                                                              10052,
                                                              2292,
                                                              app.calc_dt,
                                                              0)
                               WHERE     tpp_pd = p_pd
                                     AND tpp_app_tp IN ('Z')
                                     AND k_a.kaot_code IS NOT NULL
                                     AND k_d.kaot_code IS NOT NULL)
                       WHERE 1 = 1)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        /*
                l_Ankt_kaot_id := get_val_id(ankt.Apd_Id, 1775);
                l_Doc_kaot_id  := get_doc_id(ankt.App_Id, 10052, 2292);
                IF l_Ankt_kaot_id IS NOT NULL AND l_Doc_kaot_id IS NOT NULL AND l_Ankt_kaot_id != l_Doc_kaot_id THEN

                  SELECT MAX(m.kaot_code)
                    INTO l_Ankt_kaot_cod
                  FROM uss_ndi.v_Ndi_Katottg m
                  WHERE m.kaot_id = l_Ankt_kaot_id;

                  SELECT MAX(m.kaot_code)
                    INTO l_Doc_kaot_cod
                  FROM uss_ndi.v_Ndi_Katottg m
                  WHERE m.kaot_id = l_Doc_kaot_id;

                    Add_Warning('В довідці ВПО та анкеті для особи ' || Uss_Person.Api$sc_Tools.Get_Pib(Ankt.App_Sc) || ' зазначено різні значення, ' ||
                              'а саме, в полі КАТТОТГ у довідці ВПО зазначено ' || l_Doc_kaot_cod ||
                              ', а в Анкеті зазначено ' || l_Ankt_kaot_cod
                             );
                END IF;*/
        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG24 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                                                                      AS x_id,
                             'В Анкеті учасника звернення "Заявник" не зазначено "Так" в атрибуті "Житло зруйноване або непридатне для проживання"'    AS x_text                                                                                                --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp = 'Z'
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 605,
                                                                 2101,
                                                                 calc_dt,
                                                                 '-') != 'T'
                      UNION ALL
                      SELECT p_pd                                                                                                                                          AS x_id,
                             'Не долучено до звернення "Документ - підтвердження факту пошкодження/знищення нерухомого майна військовою агресією Російської Федерації"'    AS x_text                                                                                                                       --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp = 'Z'
                             AND api$account.get_docx_count (p_pd,
                                                             tpp_sc,
                                                             10090,
                                                             calc_dt) = 0
                      UNION ALL
                      SELECT p_pd                                                                                                                                                                                           AS x_id,
                             'В "Документ - підтвердження факту пошкодження/знищення нерухомого майна військовою агресією Російської Федерації зазначене житло не визначене як зруйноване або непридатне для проживання'    AS x_text                                                                                                                                                                  --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp = 'Z'
                             AND api$account.get_docx_count (p_pd,
                                                             tpp_sc,
                                                             10090,
                                                             calc_dt) > 0
                             AND API$CALC_RIGHT.get_docx_string (p_pd,
                                                                 tpp_sc,
                                                                 10090,
                                                                 2100,
                                                                 calc_dt,
                                                                 '-') NOT IN
                                     ('D', 'UH')/*
                                                              UNION ALL
                                                              SELECT p_pd as x_id, 'Адреса житла, яке зруйноване або непридатне для проживання, зазначене в "Документі - підтвердженні факту пошкодження/знищення нерухомого майна" не відповідає "Адресі місця проживання, звідки перемістилася особа, яка зазначена в Анкеті учасника звернення' AS x_text          --1
                                                              FROM  v_tmp_person_for_decision z
                                                              WHERE tpp_pd = p_pd
                                                                    and tpp_app_tp = 'Z'
                                                                    and api$calc_right.get_docx_count( p_pd, tpp_sc, 10090, z.calc_dt) > 0
                                                                    AND (
                                                                        API$CALC_RIGHT.get_docx_id(p_pd, tpp_sc, 605, 1775, z.calc_dt, -1) != API$CALC_RIGHT.get_docx_id(p_pd, tpp_sc, 10090, 2089, z.calc_dt, -1)
                                                                        OR
                                                                        --API$CALC_RIGHT.get_doc_id(z.app_id, 605, 1776, -1) != API$CALC_RIGHT.get_doc_id(z.app_id, 10090, 2094, -1)
                                                                        --OR
                                                                        API$CALC_RIGHT.get_docx_id(p_pd, tpp_sc, 605, 1777, z.calc_dt, -1) != API$CALC_RIGHT.get_docx_id(p_pd, tpp_sc, 10090, 2095, z.calc_dt, -1)
                                                                        OR
                                                                        API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 605, 1785, z.calc_dt, '-') != API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 10090, 2096, z.calc_dt, '-')
                                                                        OR
                                                                        API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 605, 1778, z.calc_dt, '-') != API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 10090, 2097, z.calc_dt, '-')
                                                                        OR
                                                                        API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 605, 1779, z.calc_dt, '-') != API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 10090, 2098, z.calc_dt, '-')
                                                                        OR
                                                                        API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 605, 1788, z.calc_dt, '-') != API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 10090, 2099, z.calc_dt, '-')
                                                                        )*/
                                                )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        /*
        2184  D D зруйноване  зруйноване  A 1
        2184  UH  UH  непридатне для проживання непридатне для проживання A 2
        */


        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --1. Для визначення права додати додаткову перевірку для правила "Особа є особою з інвалідністю":
    --   якщо у зверненні в анкеті "Анкета учасника звернення за допомогою ВПО" NDT_ID=10053 встановлено ознаку Особа з інвалідністю=Так і відсутні документи,
    --   що підтверджують інвалідність (Ід=201, або 601, 809), то необхідно перевіряти наявність ознаки в ЄСР - особа з інвалідністю.
    --   Приклад особи з інвалідністю в ЄСР: особа з РНОКПП – 4000000001 - ЦБІ (інформація в соц.картці, в статусах проставлено "особа з інвалідністю" = "так")
    --========================================
    PROCEDURE Check_ALG25 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
              SELECT COUNT(1)
                INTO l_cnt_all
              FROM  v_tmp_person_for_decision app
              WHERE tpp_pd = p_pd;

              SELECT COUNT(1)
                INTO l_cnt_not_inv
              FROM  v_tmp_person_for_decision app
              WHERE tpp_pd = p_pd
                    AND api$calc_right.get_docx_count(p_pd, tpp_sc, 201, calc_dt) = 0
                    AND api$calc_right.get_docx_count(p_pd, tpp_sc, 809, calc_dt) = 0
                    AND api$calc_right.get_docx_count(p_pd, tpp_sc, 115, calc_dt) = 0
                    AND (
                          (
                          api$calc_right.get_docx_string(p_pd, tpp_sc, 601, 1125, calc_dt, NULL) IS NULL
                          AND api$calc_right.get_docx_dt(p_pd, tpp_sc, 601, 615, calc_dt) IS NULL
                          )
                         OR
                          (
                          api$calc_right.get_docx_string(p_pd, tpp_sc, 601, 1125, calc_dt, NULL) IS NOT NULL
                          AND nvl(api$calc_right.get_docx_dt(p_pd, tpp_sc, 601, 615, calc_dt), to_date('1974','YYYY')) < to_date(' 24.09.2021', 'dd.mm.yyyy')
                          )
                        )
                    AND NOT EXISTS (SELECT 1
                                    FROM  uss_person.v_sc_disability scy
                                    WHERE scy_sc = tpp_sc
                                          AND SYSDATE BETWEEN scy.scy_start_dt AND NVL(scy.scy_stop_dt, to_date('3000','yyyy'))
                                          AND scy.history_status = 'A'
                                          AND scy_group IS NOT NULL
                                          AND api$calc_right.get_docx_string(p_pd, tpp_sc, 605, 1772, calc_dt, 'F') = 'T'
                                          AND api$calc_right.get_docx_count( p_pd, tpp_sc, 201, calc_dt) = 0
                                          AND api$calc_right.get_docx_count( p_pd, tpp_sc, 809, calc_dt) = 0
                                    );

          */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd AS x_id, 'Особа без інвалідності' AS x_text                     --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp = 'Z'
                             AND api$account.get_docx_count (p_pd,
                                                             tpp_sc,
                                                             201,
                                                             calc_dt) = 0
                             AND api$account.get_docx_count (p_pd,
                                                             tpp_sc,
                                                             809,
                                                             calc_dt) = 0
                             AND api$account.get_docx_count (p_pd,
                                                             tpp_sc,
                                                             115,
                                                             calc_dt) = 0
                             AND (   (    api$calc_right.get_docx_string (
                                              p_pd,
                                              tpp_sc,
                                              601,
                                              1125,
                                              calc_dt,
                                              NULL)
                                              IS NULL
                                      AND api$calc_right.get_docx_dt (p_pd,
                                                                      tpp_sc,
                                                                      601,
                                                                      615,
                                                                      calc_dt)
                                              IS NULL)
                                  OR (    api$calc_right.get_docx_string (
                                              p_pd,
                                              tpp_sc,
                                              601,
                                              1125,
                                              calc_dt,
                                              NULL)
                                              IS NOT NULL
                                      AND NVL (api$calc_right.get_docx_dt (
                                                   p_pd,
                                                   tpp_sc,
                                                   601,
                                                   615,
                                                   calc_dt),
                                               TO_DATE ('1974', 'YYYY')) <
                                          TO_DATE (' 24.09.2021', 'dd.mm.yyyy')))
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM uss_person.v_sc_disability scy
                                       WHERE     scy_sc = tpp_sc
                                             AND SYSDATE BETWEEN scy.scy_start_dt
                                                             AND NVL (
                                                                     scy.scy_stop_dt,
                                                                     TO_DATE (
                                                                         '3000',
                                                                         'yyyy'))
                                             AND scy.history_status = 'A'
                                             AND scy_group IS NOT NULL
                                             AND api$calc_right.get_docx_string (
                                                     p_pd,
                                                     tpp_sc,
                                                     605,
                                                     1772,
                                                     calc_dt,
                                                     'F') = 'T'
                                             AND api$account.get_docx_count (
                                                     p_pd,
                                                     tpp_sc,
                                                     201,
                                                     calc_dt) = 0
                                             AND api$account.get_docx_count (
                                                     p_pd,
                                                     tpp_sc,
                                                     809,
                                                     calc_dt) = 0)
                      --1125 Група інвалідності STRING V_DDN_SCY_GROUP
                      --1126 Причина інвалідності STRING
                      --1127 Встановлено на період по DATE

                      --AND api$calc_right.check_documents_exists(app.app_id, 809) = 0
                      UNION ALL
                      SELECT p_pd                                 AS x_id,
                             api$calc_right.check_docx_201 (p_pd,
                                                            tpp_sc,
                                                            calc_dt,
                                                            0)    AS x_text --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp = 'Z'
                      UNION ALL
                      SELECT p_pd                                 AS x_id,
                             api$calc_right.check_docx_809 (p_pd,
                                                            tpp_sc,
                                                            calc_dt,
                                                            0)    AS x_text --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp = 'Z')
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG26 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN tpp_app_tp = 'Z' AND d.pd_st != 'S'
                                 THEN
                                        'Для Заявника '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначається допомога на проживання ВПО '
                                     || d.pd_num
                                     || ' за зверненням особи '
                                     || a.ap_num
                                     || ' від '
                                     || TO_CHAR (a.ap_reg_dt, 'dd.mm.yyyy')
                                     || '.'
                                 WHEN tpp_app_tp = 'Z' AND d.pd_st = 'S'
                                 THEN
                                        'Для Заявника '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначено допомогу на проживання ВПО '
                                     || d.pd_num
                                     || '.'
                                 WHEN tpp_app_tp = 'FP' AND d.pd_st != 'S'
                                 THEN
                                        'Для Утриманця '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначається допомога на проживання ВПО '
                                     || d.pd_num
                                     || ' за зверненням особи '
                                     || a.ap_num
                                     || ' від '
                                     || TO_CHAR (a.ap_reg_dt, 'dd.mm.yyyy')
                                     || '.'
                                 WHEN tpp_app_tp = 'FP'
                                 THEN
                                        'Для Утриманця '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначено допомогу на проживання ВПО '
                                     || d.pd_num
                                     || '.'
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN appeal ap ON ap.ap_id = app.pd_ap
                             JOIN pd_family pf
                                 ON     pf.pdf_sc = tpp_sc
                                    AND (   pf.pdf_tp = 'CALC'
                                         OR pf.pdf_tp IS NULL)
                             --JOIN ap_person   p ON p.app_ap != app.pd_ap AND p.app_sc = tpp_sc AND p.app_tp IN ('Z', 'FP') AND p.history_status = 'A'
                             JOIN pc_decision d
                                 ON     d.pd_id = pf.pdf_pd
                                    AND app.tpp_pd != d.pd_id
                                    AND app.pd_nst = d.pd_nst
                                    AND (   (    d.pd_st IN ('S', 'P')
                                             AND ap.ap_reg_dt BETWEEN d.pd_start_dt
                                                                  AND d.pd_stop_dt)
                                         OR (d.pd_st IN ('R0', 'R1',  /*'P',*/
                                                                     'K')))
                             JOIN appeal a ON a.ap_id = d.pd_ap
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z', 'FP')
                             AND EXISTS
                                     (SELECT 1
                                        FROM pd_detail pdd
                                       WHERE     pdd.pdd_key = pf.pdf_id
                                             AND ap.ap_reg_dt BETWEEN pdd.pdd_start_dt
                                                                  AND pdd.pdd_stop_dt)
                             AND EXISTS
                                     (SELECT 1
                                        FROM pd_accrual_period pdap
                                       WHERE     pdap_pd = d.pd_id
                                             AND ap.ap_reg_dt BETWEEN pdap_start_dt
                                                                  AND pdap_stop_dt
                                             AND pdap.history_status = 'A')/*              FROM  v_tmp_person_for_decision app
                                                                                               JOIN appeal     ap ON ap.ap_id = app.pd_ap
                                                                                               JOIN ap_person   p ON p.app_ap != app.pd_ap AND p.app_sc = tpp_sc AND p.app_tp IN ('Z', 'FP') AND p.history_status = 'A'
                                                                                               JOIN pc_decision d ON d.pd_ap = p.app_ap
                                                                                                                     AND app.pd_nst = d.pd_nst
                                                                                                                     AND (
                                                                                                                          ( d.pd_st = 'S' AND ap.ap_reg_dt BETWEEN d.pd_start_dt AND d.pd_stop_dt)
                                                                                                                          OR
                                                                                                                          ( d.pd_st IN ('R0', 'R1', 'P', 'K') )
                                                                                                                         )
                                                                                               JOIN appeal a ON a.ap_id = p.app_ap
                                                                                         WHERE tpp_pd = p_pd
                                                                                               and tpp_app_tp IN ('Z', 'FP')*/
                                                                           )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG27 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                                                                                         AS x_id,
                             'Не виконано жодну з умов: "Переміщено з ТГ, у яких воєнні дії, окупація, оточення" або "Житло зруйноване або непридатне для проживання"'    AS x_text                                                                                                            --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT nrr_alg,
                                         prl.prl_calc_result,
                                         prl.prl_calc_info
                                    FROM pd_right_log prl
                                         JOIN uss_ndi.v_ndi_right_rule
                                             ON nrr_id = prl.prl_nrr
                                   WHERE     prl.prl_pd = p_pd
                                         AND nrr_alg IN ('ALG23', 'ALG24')
                                         AND prl.prl_calc_result = 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG29 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                               AS x_id,
                                'ЕОС зареєстрована в органі '
                             || pfu.org_code
                             || ' '
                             || pfu.org_name
                             || '. Для призначення допомоги необхідно передати справу із зазначеного органу'    AS x_text                                                                                        --1
                        FROM pc_decision
                             JOIN personalcase pc ON pd_pc = pc_id
                             JOIN v_opfu pfu ON pc.com_org = pfu.org_id
                       WHERE pd_id = p_pd AND pc_decision.com_org != pc.com_org)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    ---------------------------------------------------------------------
    --                    ПЕРЕВІРКА СПОСОБІВ ВИПЛАТ
    ---------------------------------------------------------------------
    FUNCTION Validate_pdm_pay (P_PD_ID IN NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        FOR Rec
            IN (SELECT pd.pd_nst,
                       pd.pd_st,
                       p.pdm_pay_tp,
                       t.Dic_Sname
                           pdm_tp_Name,
                       p.pdm_Nb,
                       p.pdm_Account,
                       REGEXP_SUBSTR (p.pdm_Account, '[0-9]{6}', 5)
                           pdm_mfo,
                       b.nb_mfo,
                       b.nb_name,
                       p.pdm_pay_dt,
                       p.pdm_Index,
                       p.pdm_kaot,
                       p.pdm_street,
                       p.pdm_ns,
                       p.pdm_building
                  FROM pc_decision  pd
                       LEFT JOIN pd_pay_method p
                           ON pdm_pd = pd.pd_id AND p.pdm_is_actual = 'T'
                       LEFT JOIN Uss_Ndi.v_Ddn_Apm_Tp t
                           ON p.pdm_pay_tp = t.Dic_Code
                       LEFT JOIN Uss_Ndi.v_NDI_BANK b ON p.pdm_nb = b.nb_id
                 WHERE pd.pd_id = P_PD_ID AND p.history_status = 'A')
        LOOP
            IF Rec.Pdm_Pay_Tp IS NULL
            THEN
                RETURN 'Не обрано спосіб (тип) виплати допомоги в закладці "Параметри виплати"';
            --      ELSIF Rec.pd_nst NOT IN ( 781) AND rec.pd_st NOT IN ('R0') AND Rec.pdm_pay_dt NOT BETWEEN 4 AND 25 THEN
            --          RETURN 'День виплати повинен бути між 4 та 25 числом!';
            ELSIF Rec.pdm_pay_tp = 'BANK'
            THEN
                IF Rec.pdm_Nb IS NULL OR Rec.pdm_Account IS NULL /*OR Rec.pdm_pay_dt IS NULL*/
                THEN
                    RETURN 'Для способу виплати "Банківська установа" не заповнено поля, що стосуються виплати в Банківській установі"';
                END IF;

                IF Rec.pdm_Account IS NULL
                THEN
                    RETURN    'Тип виплати '
                           || Rec.pdm_tp_Name
                           || ', не вказано банківський рахунок';
                ELSIF Rec.pdm_mfo IS NULL OR Rec.pdm_mfo != Rec.nb_mfo
                THEN
                    RETURN    'У введеному рахунку IBAN код банку (МФО, зазначається з 3-тої по 8-му позицію в цифровій частині IBAN) '
                           || Rec.pdm_mfo
                           || ' не відповідає коду банку (МФО) '
                           || Rec.nb_mfo
                           || ' для банківської установи '
                           || Rec.nb_name
                           || '.';
                END IF;
            ELSIF Rec.Pdm_Pay_Tp = 'POST' AND Rec.pd_nst = '664'
            THEN
                RETURN 'Виплата допомоги на проживання внутрішньо перемішеним особам здійснюється через банківські установи, змініть спосіб виплати на "Банківська установа"';
            ELSIF Rec.pdm_pay_tp = 'POST'
            THEN
                IF    rec.pdm_kaot IS NULL
                   OR rec.pdm_Index IS NULL
                   OR (rec.pdm_street IS NULL AND rec.pdm_ns IS NULL)
                   OR rec.pdm_building IS NULL
                THEN
                    RETURN 'Для способу виплати "Пошта" не заповнено поля, що стосуються виплати в поштовому відділення, а саме, поля, в яких зазначається інформація про адресу особи';
                END IF;
            END IF;
        END LOOP;

        RETURN '';
    END;

    --========================================
    PROCEDURE Check_ALG28 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM ( /*
                       SELECT p_pd as x_id,
                              'Для '||uss_person.api$sc_tools.get_pib(app_sc)||' в Адресі місця проживання, '||
                              'звідки перемістилася особа не заповнено населений пункт '||
                              '(назва КАТОТТГ в "Адресі місця проживання, звідки перемістилася особа" в анкеті учасника звернення)'
                              AS x_text          --1
                       FROM  v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd
                             and app_tp IN ('Z', 'FP')
                             and API$CALC_RIGHT.get_doc_id(app_id, 605, 1775, app.calc_dt, 0) = 0
                       UNION ALL*/
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     ap.ap_reg_dt BETWEEN TO_DATE (
                                                                   '01.05.2022',
                                                                   'dd.mm.yyyy')
                                                           AND TO_DATE (
                                                                   '31.07.2023',
                                                                   'dd.mm.yyyy')
                                      AND Api$account.get_docx_count (tpp_pd,
                                                                      tpp_sc,
                                                                      10250,
                                                                      calc_dt) =
                                          0
                                 THEN
                                     'До звернення щодо допомоги ВПО за період до 01.08.2023 не долучено документ "Підстава щодо призначення допомоги за попередній період"'
                                 WHEN     ap.ap_reg_dt BETWEEN TO_DATE (
                                                                   '01.05.2022',
                                                                   'dd.mm.yyyy')
                                                           AND TO_DATE (
                                                                   '31.07.2023',
                                                                   'dd.mm.yyyy')
                                      AND Api$account.Get_Docx_String (tpp_pd,
                                                                       tpp_sc,
                                                                       10250,
                                                                       4360,
                                                                       calc_dt)
                                              IS NULL
                                 THEN
                                     'У зверненні за період до 01.08.2023 не зазначено піставу в атрибуті "Підстава"'
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN appeal ap ON ap.ap_id = app.pd_ap
                       WHERE app.pd_id = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN     ap.ap_reg_dt BETWEEN TO_DATE (
                                                                   '01.05.2022',
                                                                   'dd.mm.yyyy')
                                                           AND TO_DATE (
                                                                   '31.07.2023',
                                                                   'dd.mm.yyyy')
                                      AND Api$calc_Right.Get_Docx_Scan (
                                              tpp_pd,
                                              tpp_sc,
                                              10250,
                                              calc_dt) = 0
                                 THEN
                                     'До звернення за період до 01.08.2023 не долучено скан документу підстави щодо призначення допомоги за попередній період'
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN appeal ap ON ap.ap_id = app.pd_ap
                       WHERE app.pd_id = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd                                                                         AS x_id,
                                'Для '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' відсутня інформація про дату народження. '
                             || 'Дата народження має зазначатися в документах, що ідентифікують особу'    AS x_text --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z', 'FP')
                             AND (SELECT MAX (apda.apda_val_dt)     bdt
                                    FROM ap_document_attr apda
                                         JOIN uss_ndi.v_ndi_document_attr nda
                                             ON     nda.nda_id = apda.apda_nda
                                                AND nda.nda_class = 'BDT'
                                         --JOIN ap_document apd ON apd.apd_id = apda.apda_apd AND apd.history_status = 'A'
                                         JOIN tmp_pa_documents tpd
                                             ON tpd_apd = apda.apda_apd
                                         JOIN uss_ndi.v_ndi_document_type ndt
                                             ON     ndt.ndt_id = tpd_ndt
                                                AND ndt.ndt_ndc = 13
                                   WHERE     apda.history_status = 'A'
                                         AND tpd.tpd_pd = tpp_pd
                                         AND tpd.tpd_sc = tpp_sc)
                                     IS NULL
                      /*
                      and COALESCE(api$calc_right.get_docx_dt(p_pd, tpp_sc, 6,606, calc_dt), --Паспорт
                                   api$calc_right.get_docx_dt(p_pd, tpp_sc, 7,607, calc_dt), --ID картка
                                   api$calc_right.get_docx_dt(p_pd, tpp_sc, 37,91, calc_dt) --свідоцтво про народження дитини  )
                                   ) IS NULL
                      */
                      UNION ALL
                      SELECT p_pd                                      AS x_id,
                             api$calc_right.Validate_pdm_pay (p_pd)    AS x_text
                        FROM DUAL
                      UNION ALL
                      SELECT p_pd      AS x_id,
                             API$CALC_RIGHT.check_docx_filled (
                                 p_pd,
                                 tpp_sc,
                                 10090,
                                 '5850,2089,2091,2092,2093,2095,2097,2100',
                                 '5850,2089,2091,2092,2093,2096,2097,2100',
                                 calc_dt,
                                 0)    AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE app.pd_id = p_pd)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        /*
            IF g_Ap_Reg_Dt BETWEEN to_date('01.05.2022', 'dd.mm.yyyy') AND to_date('31.07.2023', 'dd.mm.yyyy')
               AND Api$validation.Get_Ap_Doc_Scan(g_Ap_Id , 10250) = 0
               THEN
                 IF Err_List IS NULL THEN
                    Err_List := 'До звернення за період до 01.08.2023 не долучено скан документу підстави щодо призначення допомоги за попередній період';
                 ELSE
                    Err_List := Err_List||', До звернення за період до 01.08.2023 не долучено скан документу підстави щодо призначення допомоги за попередній період';
                 END IF;
            END IF;
        */
        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG30 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  10196,
                                                                  calc_dt) = 0
                                 THEN
                                     'До звернення не долучено документ "Лікарняний у зв''язку з вагітністю та пологами'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$calc_right.get_docx_ndc13_count_ (
                                          tpp_pd,
                                          tpp_sc,
                                          calc_dt) =
                                      0
                                 THEN
                                     'До звернення не долучено документ, що посвідчує особу Паспорт громадянина України, ІD картка тощо'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z')
                      UNION ALL
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN api$account.get_docx_count (tpp_pd,
                                                                  tpp_sc,
                                                                  600,
                                                                  calc_dt) = 0
                                 THEN
                                     'До звернення не долучено Заяву про призначення усіх видів соціальної допомоги, компенсацій та пільг'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG31 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --Контроль: якщо звернення за допомогою надійшло пізніше ніж через шість місяців з дня закінчення відпустки у зв'язку з вагітністю та пологами, а саме,
        --перевіряти "Дату звернення"= "Дата подання заяви" і дату в атрибуті nda_id=2580 в документі NDT_ID=10196,
        --якщо "Дата подання заяви" пізніше ніж через 6 місяців після дати nda_id=2580, то це помилка текст помилки: "Звернення за допомогою надійшло пізніше ніж через шість місяців з дня закінчення відпустки у зв'язку з вагітністю та пологами"
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN MONTHS_BETWEEN (ap_reg_dt,
                                                      api$calc_right.get_docx_dt (
                                                          tpp_pd,
                                                          tpp_sc,
                                                          10196,
                                                          2580,
                                                          calc_dt)) >= 6
                                 THEN
                                     'Звернення за допомогою надійшло пізніше ніж через шість місяців з дня закінчення відпустки у зв''язку з вагітністю та пологами'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                             JOIN appeal ON pd_ap = ap_id
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG32 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --Для правила "Особа не отримує допомогу ВПО"
        --перевіряти чи наявне рішення щодо заявника чи інших учасників звернення про призначення допомоги з Ід=664,
        --у якого термін призначення по 30.06.2023, якщо таке рішення знайдено, то помилка, повідомлення про помилку:
        --"Для особи <ПІБ> знайдено рішення <номер рішення> про призначення допомоги ВПО в органі <номер органу>"
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT tpp_pd                                 AS x_id,
                                'Щодо особи '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' зареєстроване звернення № '
                             || ap_num
                             || ' від '
                             || TO_CHAR (ap_reg_dt, 'dd.mm.yyyy')
                             || ' щодо призначення допомоги ВПО'    AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN ap_person app
                                 ON     app_sc = tpp_sc
                                    AND app.history_status = 'A'
                             JOIN appeal
                                 ON     app_ap = ap_id
                                    AND ap_reg_dt BETWEEN TO_DATE (
                                                              '01.05.2023',
                                                              'dd.mm.yyyy')
                                                      AND TO_DATE (
                                                              '05.06.2023',
                                                              'dd.mm.yyyy')
                             JOIN ap_service aps
                                 ON     aps_ap = ap_id
                                    AND aps.history_status = 'A'
                                    AND aps_nst = 20
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z', 'FP')
                      UNION ALL
                      SELECT DISTINCT
                             tpp_pd           AS x_id,
                                'Щодо особи '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' здійснювалась виплата згідно відомості '
                             || pr_id
                             || ' ОСЗН '
                             || payroll.com_org
                             || ' номер ЕОС '
                             || prs_pc_num    AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN pd_family f
                                 ON f.pdf_sc = tpp_sc AND f.pdf_pd != tpp_pd
                             --JOIN pc_decision pd ON pd.pd_id = f.pdf_pd AND pd.pd_nst = 664
                             JOIN pr_sheet ON prs_pc = pd_pc
                             JOIN payroll
                                 ON     prs_pr = pr_id
                                    AND (   pr_month IN
                                                (TO_DATE ('01.05.2023',
                                                          'DD.MM.YYYY'))
                                         OR     (    pr_tp = 'M'
                                                 AND pr_month IN
                                                         (TO_DATE (
                                                              '01.06.2023',
                                                              'DD.MM.YYYY')))
                                            AND pr_npc = 24
                                            AND prs_st IN ('NA', 'KV1', 'KV2'))
                       WHERE     tpp_pd = p_pd
                             AND pd_nst = 664
                             AND tpp_app_tp IN ('Z', 'FP'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG33 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --Для правила Адреса заявника належить до переліку населених пунктів, що розташовані в районах підтоплень контролів нема.

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                   AS x_id,
                             'Користувач самостійно перевіряє зазначене правило'    x_text                                              --1
                        FROM DUAL)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG34 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --Особи не за кордоном за результатами превентивної верифікації

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                              AS x_id,
                             'Користувач самостійно перевіряє зазначене правило за результатом верифікації'    x_text                                                                      --1
                        FROM DUAL)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG35 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --Нове правило - "Відсутність діючого рішення для заявника та інших учасників звернення".
        --Перевіряти по заявнику та утриманцях наявність іншого діючого рішення (у статусі "Нараховано") по послузі з ІД=20,
        --якщо знайдено, то помилка. Текст помилка. Текст помилки:
        --"Особі з <ПІБ> вже призначено одноразову грошову винагороду згідно рішення <№ рішення> в органі <номер органу>.
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT tpp_pd           AS x_id,
                                'Особі з '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' вже призначено одноразову грошову винагороду згідно рішення № '
                             || pd.pd_num
                             || ' в органі '
                             || pd.com_org    AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN pd_family pdf
                                 ON     pdf.pdf_sc = tpp_sc
                                    AND pdf.pdf_pd != tpp_pd
                             JOIN pc_decision pd
                                 ON     pd.pd_id = pdf.pdf_pd
                                    AND pd.pd_nst = 20
                                    AND pd.pd_st = 'S'
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z', 'FP'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG36 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --"Раніше заявнику не виплачувалась одноразова допомога"
        --Перевіряти по ЕОС заявника чи фігурувала ЕОС його в відомостях на виплату по послузі з Ід=20,
        --якщо фігурувала, то помилка. Текст помилки:
        --"Заявник <ПІБ> вже одержав одноразову допомогу згідно відомості № <номер відомості> район <номер району>".
        RETURN;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd             AS x_id,
                                'Щодо особи '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' здійснювалась виплата згідно відомості '
                             || pr_id
                             || ' ОСЗН '
                             || payroll.com_org
                             || ' номер ЕОС '
                             || prs_pc_num    AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN pd_family f
                                 ON f.pdf_sc = tpp_sc AND f.pdf_pd != tpp_pd
                             --JOIN pc_decision pd ON pd.pd_id = f.pdf_pd AND pd.pd_nst = 20
                             JOIN pr_sheet ON prs_pc = pd_pc
                             JOIN payroll
                                 ON     prs_pr = pr_id
                                    AND (   pr_month IN
                                                (TO_DATE ('01.05.2023',
                                                          'DD.MM.YYYY'))
                                         OR     (    pr_tp = 'M'
                                                 AND pr_month IN
                                                         (TO_DATE (
                                                              '01.06.2023',
                                                              'DD.MM.YYYY')))
                                            AND pr_npc = 24
                                            AND prs_st IN ('NA', 'KV1', 'KV2'))
                       WHERE     tpp_pd = p_pd
                             AND pd_nst = 20
                             AND tpp_app_tp IN ('Z', 'FP'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    FUNCTION Is_Check_SS_ALG__ (p_pd_id   pc_decision.pd_id%TYPE,
                                p_alg     VARCHAR2)
        RETURN BOOLEAN
    IS
        l_res   VARCHAR2 (2000);
    BEGIN
        SELECT MAX (prl.prl_calc_result)
          INTO l_res
          FROM pd_right_log  prl
               JOIN uss_ndi.v_ndi_right_rule ON nrr_id = prl.prl_nrr
         WHERE prl.prl_pd = p_pd_id AND nrr_alg = P_ALG;

        RETURN (NVL (l_res, 'F') = 'T');
    END;

    --========================================
    FUNCTION Is_Check_ALG (p_pd_id pc_decision.pd_id%TYPE, p_alg VARCHAR2)
        RETURN BOOLEAN
    IS
        l_res   VARCHAR2 (2000);
    BEGIN
        SELECT MAX (prl.prl_calc_result)
          INTO l_res
          FROM pd_right_log  prl
               JOIN uss_ndi.v_ndi_right_rule ON nrr_id = prl.prl_nrr
         WHERE prl.prl_pd = p_pd_id AND nrr_alg = P_ALG;

        RETURN (NVL (l_res, 'F') = 'T');
    END;

    --========================================
    FUNCTION Is_Check_ALG_n (p_pd_id pc_decision.pd_id%TYPE, p_alg VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        IF Is_Check_ALG (p_pd_id, p_alg)
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END;

    --========================================
    FUNCTION Is_Check_SS_ALG01 (p_pd_id pc_decision.pd_id%TYPE)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN Is_Check_SS_ALG__ (p_pd_id, 'SS.ALG01');
    END;

    --========================================
    --#88644
    --При опрацюванні документа ndt_id=835:
    -- для перевірки права використовувати тільки правило №2, оскільки дані для застосування інших правил відсутні
    -- автоматичне заповнення поля «Спосіб надання» не виконувати – дані для цього відсутні
    FUNCTION Is_Exists_835 (p_pd_id pc_decision.pd_id%TYPE)
        RETURN BOOLEAN
    IS
        l_res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_res
          FROM tmp_pa_documents tpd
         WHERE tpd.tpd_pd = p_pd_id AND tpd.tpd_ndt = 835;

        RETURN l_res = 1;
    END;

    --========================================
    FUNCTION Is_Exists_ndt (p_pd_id pc_decision.pd_id%TYPE, p_ndt NUMBER)
        RETURN BOOLEAN
    IS
        l_res   NUMBER;
    BEGIN
        SELECT api$account.get_docx_count (app.tpp_pd,
                                           app.tpp_sc,
                                           p_ndt,
                                           app.calc_dt)
          INTO l_res
          FROM v_tmp_person_for_decision app
         WHERE app.tpp_app_tp IN ('Z') AND app.pd_id = p_pd_id;

        RETURN l_res > 0;
    END;

    --========================================
    FUNCTION Get_SS_METHOD (p_pd_id pc_decision.pd_id%TYPE)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (10);
    BEGIN
        SELECT COALESCE (api$account.get_docx_string (app.pd_id,
                                                      app.tpp_sc,
                                                      801,
                                                      1869,
                                                      app.calc_dt),
                         api$account.get_docx_string (app.pd_id,
                                                      app.tpp_sc,
                                                      836,
                                                      3441,
                                                      app.calc_dt),
                         '-')
          INTO l_res
          FROM v_tmp_person_for_decision app
         WHERE app.pd_id = p_pd_id AND app.tpp_app_tp = 'Z';

        RETURN l_res;
    END;

    --========================================
    PROCEDURE Check_SS_ALG01 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                  AS x_id,
                             'Випадок не Екстрений (кризовий)'     AS x_text --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z')
                             AND NOT (   API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             801,
                                             1870,
                                             calc_dt,
                                             'F') = 'T'
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             802,
                                             1947,
                                             calc_dt,
                                             'F') = 'T'
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             803,
                                             2032,
                                             calc_dt,
                                             'F') = 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_SS_ALG02 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            NULL;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        END IF;

        /*
        Документам «Висновок оцінки потреб сім'ї» ndt_id=818 та «Висновок оцінки потреб особи» ndt_id=819
        встановлено history_status = A, а їх атрибути перенесено в документ «Акт оцінки потреб сім’ї/особи» ndt_id=804

        Задача: для визначення права за правилом №2 «Особа/сім’я потребує надання соціальних послуг»
        використовувати один з наявних атрибутів ndt_id=804:
        - nda_id = 2061
        - nda_id = 2039
        */

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                AS x_id,
                             'Особа/сім’я потребує надання соціальних послуг'    AS x_text --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z')
                             AND NOT ( --   API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 819, 2039, calc_dt, 'F') = 'T'
 --OR API$CALC_RIGHT.get_docx_string(p_pd, tpp_sc, 818, 2061, calc_dt, 'F') = 'T'
 --API$CALC_RIGHT.get_pd_doc_string(p_pd, tpp_sc, 819, 2039, calc_dt, 'F') = 'T'
 --OR API$CALC_RIGHT.get_pd_doc_string(p_pd, tpp_sc, 818, 2061, calc_dt, 'F') = 'T'
                                        API$CALC_RIGHT.get_pd_doc_string (
                                            p_pd,
                                            tpp_sc,
                                            804,
                                            2039,
                                            calc_dt,
                                            'F') = 'T'
                                     OR API$CALC_RIGHT.get_pd_doc_string (
                                            p_pd,
                                            tpp_sc,
                                            804,
                                            2061,
                                            calc_dt,
                                            'F') = 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_SS_ALG03 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        l_cnt801   NUMBER;
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        END IF;

        --Якщо немає 801 документу, то перевіряти нічого
        SELECT MAX (api$account.get_docx_count (p_pd,
                                                tpp_sc,
                                                801,
                                                calc_dt))
          INTO l_cnt801
          FROM v_tmp_person_for_decision app
         WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z');

        IF l_cnt801 = 0
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE API$CALC_RIGHT.get_docx_string (p_pd,
                                                                  tpp_sc,
                                                                  801,
                                                                  1869,
                                                                  calc_dt,
                                                                  '-')
                                 WHEN 'F'
                                 THEN
                                     'Безоплатно'
                                 WHEN 'C'
                                 THEN
                                     ''
                                 WHEN 'D'
                                 THEN
                                     'З установленням диференційованої плати'
                             END     AS x_text                             --1
                        FROM v_tmp_person_for_decision app
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('Z'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    -- Якщо у зверненні встановлено «платно» – результат перевірки = «Так».
    END;

    --========================================
    --Якщо у зверненні встановлено «безоплатно» – результат перевірки = «Так», якщо:
    --========================================
    PROCEDURE Check_SS_ALG04 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                  AS x_id,
                             'Випадок не Екстрений (кризовий)'     AS x_text --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z')
                             AND NOT (   API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             801,
                                             1870,
                                             calc_dt,
                                             'F') = 'T'
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             802,
                                             1947,
                                             calc_dt,
                                             'F') = 'T'
                                      OR API$CALC_RIGHT.get_docx_string (
                                             p_pd,
                                             tpp_sc,
                                             803,
                                             2032,
                                             calc_dt,
                                             'F') = 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    -- Якщо у зверненні встановлено «платно» – результат перевірки = «Так».
    END;

    --========================================
    --5) Право на безоплатне надання соціальних послуг підтверджено (послуга безоплатна)
    -- обрана у зверненні соціальна послуга має значення ознаки «Послуга безоплатна для всіх категорій отримувачів» = «Так» ndi_service_type.nst_is_payed=F (файл «Перелік соц_послуг_new.xlsx») --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG05 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd AS x_id, 'Послуга платна' AS x_text                   --1
                        FROM DUAL
                       WHERE (SELECT COUNT (1)
                                FROM uss_ndi.v_ndi_service_type
                                     JOIN pc_decision pd ON pd.pd_nst = nst_id
                               WHERE pd.pd_id = p_pd AND nst_is_payed = 'T') >
                             0)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --6) Право на безоплатне надання соціальних послуг підтверджено (заявник має відповідну категорію)
    -- у документі «Заява про надання соціальних послуг» ndt_id=801 вказано
    --  «Соціальних послуг потребує» nda_id in (1868)=«Особа» &
    --  «Послугу надати» nda_id in (1895)=«мені» (тобто заявнику) &
    -- в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» &
    --  у зверненні є пов’язаний до заявника документ, що підтверджує вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG06 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                      AS x_id,
                             'Заявник не має відповідної категорії'    AS x_text                                 --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                   WHERE     tpp_pd = p_pd
                                         AND tpp_app_tp IN ('Z')
                                         AND API$CALC_RIGHT.get_docx_string (
                                                 p_pd,
                                                 tpp_sc,
                                                 801,
                                                 1868,
                                                 calc_dt,
                                                 '-') = 'Z' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT.get_docx_string (
                                                 p_pd,
                                                 tpp_sc,
                                                 801,
                                                 1895,
                                                 calc_dt,
                                                 '-') = 'Z'   --Послугу надати
                                         AND API$CALC_RIGHT.IsRecip_SS_doc_exists (
                                                 p_pd,
                                                 tpp_sc,
                                                 calc_dt) >
                                             0))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --7) Право на безоплатне надання соціальних послуг підтверджено (особа у заяві має відповідну категорію)
    -- у документі «Заява про надання соціальних послуг» ndt_id=801 вказано
    -- «Соціальних послуг потребує» nda_id in (1868)=«Особа» & значення атрибуту
    -- «Послугу надати» nda_id in (1895)=«моєму(їй) синові (доньці)»/«підопічному(ій)» &
    -- у зверненні є учасник з типом «Особа, що потребує соціальних послуг» & в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язаний до даної особи документ, що підтверджує вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG07 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                     AS x_id,
                             'Особа не має відповідної категорії'     AS x_text                               --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                         JOIN v_tmp_person_for_decision app_os
                                             ON app_os.tpp_pd = app.tpp_pd
                                   WHERE     app.tpp_pd = p_pd
                                         AND app.tpp_app_tp IN ('Z')
                                         AND app_os.tpp_app_tp IN ('OS')
                                         AND API$CALC_RIGHT.get_docx_string (
                                                 p_pd,
                                                 app.tpp_sc,
                                                 801,
                                                 1868,
                                                 app.calc_dt,
                                                 '-') = 'Z' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT.get_docx_string (
                                                 p_pd,
                                                 app.tpp_sc,
                                                 801,
                                                 1895,
                                                 app.calc_dt,
                                                 '-') = 'B'   --Послугу надати
                                         AND API$CALC_RIGHT.IsRecip_SS_doc_exists (
                                                 p_pd,
                                                 app_os.tpp_sc,
                                                 app_os.calc_dt) >
                                             0))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --8) Право на безоплатне надання соціальних послуг підтверджено (особа у повідомленні має відповідну категорію)
    -- у документі «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 вказано
    -- «Соціальних послуг потребує» nda_id in (1944)=«Особа» & у зверненні є учасник з типом
    -- «Особа, що потребує соціальних послуг» & в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язаний до даної особи документ, що підтверджує вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG08 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                     AS x_id,
                             'Особа не має відповідної категорії'     AS x_text                               --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                         JOIN v_tmp_person_for_decision app_os
                                             ON app_os.tpp_pd = app.tpp_pd
                                   WHERE     app.pd_id = p_pd
                                         AND app.tpp_app_tp IN ('Z')
                                         AND app_os.tpp_app_tp IN ('OS')
                                         AND API$CALC_RIGHT.get_docx_string (
                                                 p_pd,
                                                 app.tpp_sc,
                                                 802,
                                                 1944,
                                                 app.calc_dt,
                                                 '-') = 'Z' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT.IsRecip_SS_doc_exists (
                                                 p_pd,
                                                 app_os.tpp_sc,
                                                 app_os.calc_dt) >
                                             0))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --9) Право на безоплатне надання соціальних послуг підтверджено (всі члени сім’ї у заяві мають відповідні категорії)
    -- у документі «Заява про надання соціальних послуг» ndt_id=801 вказано
    -- «Соціальних послуг потребує» nda_id in (1868)=«Сім’я» &
    -- у зверненні є учасник(и) з типом «Особа, що потребує соціальних послуг» або «Член сім’ї» & в його (їх) «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язані до даних осіб документи, що підтверджують вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG09 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                       AS x_id,
                             'Не всі члени сім’ї у заяві мають відповідні категорії'    AS x_text                                               --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                         JOIN v_tmp_person_for_decision app_os
                                             ON app_os.tpp_pd = app.tpp_pd
                                   WHERE     app.pd_id = p_pd
                                         AND app.tpp_app_tp IN ('Z')
                                         AND app_os.tpp_app_tp IN ('OS', 'FM')
                                         AND API$CALC_RIGHT.get_docx_string (
                                                 app.pd_id,
                                                 app.tpp_sc,
                                                 801,
                                                 1868,
                                                 app.calc_dt,
                                                 '-') = 'FM' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT.IsRecip_SS_doc_exists (
                                                 app.pd_id,
                                                 app_os.tpp_sc,
                                                 app.calc_dt) >
                                             0))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --10) Право на безоплатне надання соціальних послуг підтверджено (особа та всі члени сім’ї у повідомленні мають відповідні категорії)
    -- у документі «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 вказано
    -- «Соціальних послуг потребує» nda_id in (1944)=«Сім’я» & у зверненні є учасник(и) з типом
    -- «Особа, що потребує соціальних послуг» або «Член сім’ї» & в його (їх) «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язані до даних осіб документи, що підтверджують вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG10 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                       AS x_id,
                             'Не всі особа та члени сім’ї у повідомленні мають відповідні категорії'    AS x_text                                                             --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM v_tmp_person_for_decision app
                                         JOIN v_tmp_person_for_decision app_os
                                             ON app_os.tpp_pd = app.tpp_pd
                                   WHERE     app.pd_id = p_pd
                                         AND app.tpp_app_tp IN ('Z')
                                         AND app_os.tpp_app_tp IN ('OS', 'FM')
                                         AND API$CALC_RIGHT.get_docx_string (
                                                 p_pd,
                                                 app.tpp_sc,
                                                 802,
                                                 1944,
                                                 app.calc_dt,
                                                 '-') = 'FM' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT.IsRecip_SS_doc_exists (
                                                 p_pd,
                                                 app_os.tpp_sc,
                                                 app_os.calc_dt) >
                                             0))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --11) Право на безоплатне надання соціальних послуг підтверджено (всі члени сім’ї у повідомленні мають відповідні категорії)
    -- у документі «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 вказано
    -- «Соціальних послуг потребує» nda_id in (1944)=«Сім’я» & у зверненні
    -- немає учасника з типом «Особа, що потребує соціальних послуг» &
    -- є учасник(и) з типом «Член сім’ї» & в його (їх) «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язані до даних осіб документи, що підтверджують вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»  --========================================
    PROCEDURE Check_SS_ALG11 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        ELSIF NOT Is_Exists_ndt (p_pd, 802)
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT DISTINCT
                             p_pd    AS x_id,
                             CASE
                                 WHEN     need_ss_tp = 'FM'
                                      AND SS_doc_exists > 0
                                      AND Is_OS_exists = 0
                                 THEN
                                     ''
                                 ELSE
                                     'Не всі особа та члени сім’ї у повідомленні мають відповідні категорії'
                             END     AS x_text                             --1
                        FROM (SELECT API$CALC_RIGHT.get_docx_string (
                                         app.tpp_pd,
                                         app.tpp_sc,
                                         802,
                                         1944,
                                         app.calc_dt,
                                         '-')                                    AS need_ss_tp,
                                     API$CALC_RIGHT.IsRecip_SS_doc_exists (
                                         app.tpp_pd,
                                         app_fm.tpp_sc,
                                         app_fm.calc_dt)                         AS SS_doc_exists,
                                     (SELECT COUNT (1)
                                        FROM v_tmp_person_for_decision app_os
                                       WHERE     app_os.tpp_pd = app.tpp_pd
                                             AND app_os.tpp_app_tp IN ('OS'))    AS Is_OS_exists
                                FROM v_tmp_person_for_decision app
                                     JOIN v_tmp_person_for_decision app_fm
                                         ON app_fm.tpp_pd = app.tpp_pd
                               WHERE     app.tpp_app_tp IN ('Z')
                                     AND app_fm.tpp_app_tp IN ('FM')
                                     AND app.pd_id = p_pd)/*
                                                          SELECT p_pd as x_id, 'Не всі особа та члени сім’ї у повідомленні мають відповідні категорії' AS x_text          --1
                                                          FROM  dual
                                                          WHERE NOT EXISTS
                                                               (SELECT 1
                                                                FROM  v_tmp_person_for_decision app
                                                                      JOIN v_tmp_person_for_decision app_fm ON app_fm.tpp_pd = app.tpp_pd
                                                                WHERE app.pd_id = p_pd
                                                                      and app.tpp_app_tp    IN ('Z')
                                                                      AND app_fm.tpp_app_tp IN ('FM')
                                                                      AND NOT EXISTS (SELECT 1 FROM v_tmp_person_for_decision app_os
                                                                                      WHERE app_os.tpp_pd = app.tpp_pd AND app_os.tpp_app_tp IN ('OS')
                                                                                      )
                                                                      and NOT (     API$CALC_RIGHT.get_docx_string(p_pd, app.tpp_sc, 802, 1944, app.calc_dt, '-') = 'FM' --Соціальних послуг потребує
                                                                                and API$CALC_RIGHT.IsRecip_SS_doc_exists(p_pd, app_fm.tpp_sc, app_fm.calc_dt)>0
                                                                               )
                                                               )*/
                                                          )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE set_features_10 (p_pd pc_decision.pd_id%TYPE, p_val VARCHAR2)
    IS
        sqlrowcount   NUMBER;
    BEGIN
        UPDATE pd_features
           SET pde_val_string = p_val
         WHERE pde_pd = p_pd AND pde_nft = 10;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount = 0
        THEN
            INSERT INTO pd_features (pde_id,
                                     pde_pd,
                                     pde_nft,
                                     pde_val_string)
                 VALUES (0,
                         p_pd,
                         10,
                         p_val);
        END IF;
    END;

    --========================================
    PROCEDURE set_features_91 (p_pd pc_decision.pd_id%TYPE, p_val VARCHAR2)
    IS
        sqlrowcount   NUMBER;
    BEGIN
        UPDATE pd_features
           SET pde_val_string = p_val
         WHERE pde_pd = p_pd AND pde_nft = 91;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount = 0
        THEN
            INSERT INTO pd_features (pde_id,
                                     pde_pd,
                                     pde_nft,
                                     pde_val_string)
                 VALUES (0,
                         p_pd,
                         91,
                         p_val);
        END IF;
    END;

    --========================================
    PROCEDURE Check_SS_ALG12 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Is_Check_SS_ALG01 (p_pd)
        THEN
            RETURN;
        ELSIF Get_SS_METHOD (p_pd) != 'F'
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd AS x_id, 'Не виконано жодну з умов' AS x_text                     --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT nrr_alg,
                                         prl.prl_calc_result,
                                         prl.prl_calc_info
                                    FROM pd_right_log prl
                                         JOIN uss_ndi.v_ndi_right_rule
                                             ON nrr_id = prl.prl_nrr
                                   WHERE     prl.prl_pd = p_pd
                                         AND nrr_alg IN ('SS.ALG04',
                                                         'SS.ALG05',
                                                         'SS.ALG06',
                                                         'SS.ALG07',
                                                         'SS.ALG08',
                                                         'SS.ALG09',
                                                         'SS.ALG10',
                                                         'SS.ALG11',
                                                         'SS.ALG13')
                                         AND prl.prl_calc_result = 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);

        IF Is_Check_SS_ALG__ (p_pd, 'SS.ALG12')
        THEN
            --F безоплатно
            --C платно
            --D з установленням диференційованої плати
            set_features_10 (p_pd, 'F');
        END IF;
    END;

    --========================================
    PROCEDURE Check_SS_ALG13 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Get_SS_METHOD (p_pd) != 'F'
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          lw
                          AS
                              (SELECT app.pd_id,
                                      (SELECT MAX (
                                                  CASE
                                                      WHEN Ank.AgeYear < 6
                                                      THEN
                                                          lw.lgw_6year_sum
                                                      WHEN Ank.AgeYear < 18
                                                      THEN
                                                          lw.lgw_18year_sum
                                                      WHEN    Ank.Workable =
                                                              'F'
                                                           OR Ank.NotWorkable =
                                                              'T'
                                                      THEN
                                                          lw.lgw_work_unable_sum
                                                      ELSE
                                                          lw.lgw_work_able_sum
                                                  END)    AS living_wage
                                         FROM uss_ndi.v_ndi_living_wage lw
                                        WHERE     Ank.calc_dt >=
                                                  lw.lgw_start_dt
                                              AND (   Ank.calc_dt <=
                                                      lw.lgw_stop_dt
                                                   OR lw.lgw_stop_dt IS NULL)
                                              AND lw.history_status = 'A')    AS living_wage
                                 FROM v_tmp_person_for_decision app
                                      JOIN TABLE (api$Anketa.Get_Anketa) Ank
                                          ON     Ank.pd_id = app.pd_id
                                             AND ank.app_sc = app.tpp_sc
                                      --JOIN pc_decision  pd ON pd.pd_id = app.pd_id
                                      JOIN personalcase pc
                                          ON     pc_id = pd_pc
                                             AND pc_sc = app.tpp_sc
                                WHERE app.pd_id = p_pd)
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN pic_pd IS NULL
                                 THEN
                                     'Не розраховано середньомісячний сукупний дохід'
                                 WHEN NOT (pic_member_month_income <=
                                           lw.living_wage * 2)
                                 THEN
                                     --WHEN NOT (pic_member_month_income > lw.living_wage * 2 AND pic_member_month_income <= lw.living_wage * 4) THEN
                                     --WHEN NOT (pic_member_month_income > lw.living_wage * 4) THEN
                                     'Не виконано умову - середньомісячний сукупний дохід < 2 прожиткових мінімумів'
                             END     AS x_text                             --1
                        FROM lw LEFT JOIN pd_income_calc ON lw.pd_id = pic_pd)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_SS_ALG14 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Get_SS_METHOD (p_pd) != 'C'
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          lw
                          AS
                              (SELECT app.pd_id,
                                      (SELECT MAX (
                                                  CASE
                                                      WHEN Ank.AgeYear < 6
                                                      THEN
                                                          lw.lgw_6year_sum
                                                      WHEN Ank.AgeYear < 18
                                                      THEN
                                                          lw.lgw_18year_sum
                                                      WHEN    Ank.Workable =
                                                              'F'
                                                           OR Ank.NotWorkable =
                                                              'T'
                                                      THEN
                                                          lw.lgw_work_unable_sum
                                                      ELSE
                                                          lw.lgw_work_able_sum
                                                  END)    AS living_wage
                                         FROM uss_ndi.v_ndi_living_wage lw
                                        WHERE     Ank.calc_dt >=
                                                  lw.lgw_start_dt
                                              AND (   Ank.calc_dt <=
                                                      lw.lgw_stop_dt
                                                   OR lw.lgw_stop_dt IS NULL)
                                              AND lw.history_status = 'A')    AS living_wage
                                 FROM v_tmp_person_for_decision app
                                      JOIN TABLE (api$Anketa.Get_Anketa) Ank
                                          ON     Ank.pd_id = app.pd_id
                                             AND ank.app_sc = app.tpp_sc
                                      --JOIN pc_decision  pd ON pd.pd_id = app.pd_id
                                      JOIN personalcase pc
                                          ON     pc_id = pd_pc
                                             AND pc_sc = app.tpp_sc
                                WHERE app.pd_id = p_pd)
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN pic_pd IS NULL
                                 THEN
                                     'Не розраховано середньомісячний сукупний дохід'
                                 WHEN NOT (pic_member_month_income >
                                           lw.living_wage * 4)
                                 THEN
                                     'Не виконано умову - середньомісячний сукупний дохід > 4 прожиткових мінімумів'
                             END     AS x_text                             --1
                        FROM lw LEFT JOIN pd_income_calc ON lw.pd_id = pic_pd)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);

        IF     Is_Check_SS_ALG__ (p_pd, 'SS.ALG14')
           AND NOT (   Is_Check_SS_ALG__ (p_pd, 'SS.ALG12')
                    OR Is_Check_SS_ALG__ (p_pd, 'SS.ALG13'))
        THEN
            --F безоплатно
            --C платно
            --D з установленням диференційованої плати
            set_features_10 (p_pd, 'C');
        END IF;
    END;

    --========================================
    PROCEDURE Check_SS_ALG15 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Exists_835 (p_pd)
        THEN
            RETURN;
        ELSIF Get_SS_METHOD (p_pd) != 'D'
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          lw
                          AS
                              (SELECT app.pd_id,
                                      (SELECT MAX (
                                                  CASE
                                                      WHEN Ank.AgeYear < 6
                                                      THEN
                                                          lw.lgw_6year_sum
                                                      WHEN Ank.AgeYear < 18
                                                      THEN
                                                          lw.lgw_18year_sum
                                                      WHEN    Ank.Workable =
                                                              'F'
                                                           OR Ank.NotWorkable =
                                                              'T'
                                                      THEN
                                                          lw.lgw_work_unable_sum
                                                      ELSE
                                                          lw.lgw_work_able_sum
                                                  END)    AS living_wage
                                         FROM uss_ndi.v_ndi_living_wage lw
                                        WHERE     Ank.calc_dt >=
                                                  lw.lgw_start_dt
                                              AND (   Ank.calc_dt <=
                                                      lw.lgw_stop_dt
                                                   OR lw.lgw_stop_dt IS NULL)
                                              AND lw.history_status = 'A')    AS living_wage
                                 FROM v_tmp_person_for_decision app
                                      JOIN TABLE (api$Anketa.Get_Anketa) Ank
                                          ON     Ank.pd_id = app.pd_id
                                             AND ank.app_sc = app.tpp_sc
                                      --JOIN pc_decision  pd ON pd.pd_id = app.pd_id
                                      JOIN personalcase pc
                                          ON     pc_id = pd_pc
                                             AND pc_sc = app.tpp_sc
                                WHERE app.pd_id = p_pd)
                      SELECT p_pd    AS x_id,
                             CASE
                                 WHEN pic_pd IS NULL
                                 THEN
                                     'Не розраховано середньомісячний сукупний дохід'
                                 WHEN NOT (    pic_member_month_income >
                                               lw.living_wage * 2
                                           AND pic_member_month_income <=
                                               lw.living_wage * 4)
                                 THEN
                                     'Не виконано умову - 2 прожиткові мінімуми < середньомісячний сукупний дохід < 4 прожиткових мінімумів'
                             END     AS x_text                             --1
                        FROM lw LEFT JOIN pd_income_calc ON lw.pd_id = pic_pd)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);

        IF     Is_Check_SS_ALG__ (p_pd, 'SS.ALG14')
           AND NOT Is_Check_SS_ALG__ (p_pd, 'SS.ALG12')
        THEN
            --F безоплатно
            --C платно
            --D з установленням диференційованої плати
            set_features_10 (p_pd, 'D');
        END IF;
    END;

    --========================================
    --1. Обов’язкову інформацію надано.
    PROCEDURE Check_ALG40 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Check_ALG28 (p_nrr_id, p_pd);
    --Set_pd_right_log(p_nrr_id, p_pd);
    END;

    --========================================
    --2. Наявність довідки ВПО у заявника і отримувачів
    PROCEDURE Check_ALG41 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          vpo
                          AS
                              (SELECT app.com_org,
                                      tpp_sc,
                                      tpp_app_tp,
                                      REGEXP_REPLACE (api$calc_right.get_docx_string (
                                                          app.pd_id,
                                                          tpp_sc,
                                                          10052,
                                                          1756,
                                                          calc_dt,
                                                          ''),
                                                      '^\D*',
                                                      '')    AS vpo_num
                                 FROM v_tmp_person_for_decision app
                                WHERE app.pd_id = p_pd),
                          vporeg
                          AS
                              (SELECT com_org,
                                      tpp_sc,
                                      tpp_app_tp,
                                      --lpad(SUBSTR(vpo_num, 1, regexp_INSTR (vpo_num, '-', 1 ,1 )-1 ),4,'0') AS com_org_vpo
                                      LPAD (
                                          REGEXP_REPLACE (
                                              SUBSTR (vpo_num,
                                                      1,
                                                        REGEXP_INSTR (vpo_num,
                                                                      '-',
                                                                      1,
                                                                      1)
                                                      - 1),
                                              '\D',
                                              ''),
                                          4,
                                          '0')    AS com_org_vpo
                                 FROM vpo)
                          SELECT                       --com_org, com_org_vpo,
                                 p_pd    AS x_id,
                                 CASE
                                     WHEN com_org =
                                          uss_ndi.API$DIC_DECODING.District2ComOrgV01 (
                                              p_org_src   => com_org_vpo)
                                     THEN
                                         ''
                                     WHEN com_org = '5' || com_org_vpo
                                     THEN
                                         ''
                                     WHEN com_org =
                                          (SELECT MAX (org_org)
                                             FROM v_opfu
                                            WHERE     org_code =
                                                      '5' || com_org_vpo
                                                  AND org_to = 32)
                                     THEN
                                         ''
                                     ELSE
                                            'Довідка про взяття на облік внутрішньо переміщеної особи" для '
                                         || uss_person.api$sc_tools.get_pib (
                                                tpp_sc)
                                         || ' видана іншим структурним підрозділом з питань соціального захисту населення '
                                         || com_org_vpo
                                         || ', який не належить до території діяльності органу '
                                         || com_org
                                 END     AS x_text
                            FROM vporeg
                           WHERE tpp_app_tp IN ('Z', 'FP', 'FM')
                          UNION ALL
                          SELECT p_pd      AS x_id,
                                 api$calc_right.check_docx_filled (
                                     p_pd,
                                     tpp_sc,
                                     10052,
                                     '1756,1757,1759',
                                     calc_dt,
                                     1)    AS x_text                       --1
                            FROM v_tmp_person_for_decision app
                           WHERE     app.pd_id = p_pd
                                 AND tpp_app_tp IN ('Z', 'FP', 'FM')
                          UNION ALL
                          SELECT p_pd                                                           AS x_id,
                                    'Для особи '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' документ "Довідка про взяття на облік внутрішньо переміщеної особи" не дійсний, бо в атрибуті'
                                 || ' "Статус довідки" пусто або зазначено "Знята з обліку"'    AS x_text                                           --1
                            FROM v_tmp_person_for_decision app
                           WHERE     app.pd_id = p_pd
                                 AND tpp_app_tp IN ('Z', 'FP', 'FM')
                                 AND api$calc_right.get_docx_string (p_pd,
                                                                     tpp_sc,
                                                                     10052,
                                                                     1855,
                                                                     calc_dt,
                                                                     '-') !=
                                     'A'
                          UNION ALL
                          SELECT p_pd                                                                            AS x_id,
                                    'Довідка ВПО для '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' не пройшла верифікацію (результат верифікації у протоколі верифікації)'    AS x_text
                            FROM v_tmp_person_for_decision app
                           WHERE     app.pd_id = p_pd
                                 AND tpp_app_tp IN ('Z', 'FP', 'FM')
                                 AND api$calc_right.check_vfx_st (p_pd,
                                                                  tpp_sc,
                                                                  10052,
                                                                  calc_dt) !=
                                     'X'--              UNION ALL
                                        --              SELECT p_pd as x_id, api$calc_right.check_docx_filled(p_pd, tpp_sc, 10052, '1756,1757,1759', calc_dt, 1) AS x_text          --1
                                        --              FROM  v_tmp_person_for_decision app
                                        --              WHERE app.pd_id = p_pd
                                        --                    and tpp_app_tp = 'Z'
                                        /*
                                                      UNION ALL
                                                      SELECT p_pd as x_id, 'Для Утриманця '||uss_person.api$sc_tools.get_pib(tpp_sc)||
                                                                              ' не долучено до звернення "Довідка про взяття на облік внутрішньо переміщеної особи"' AS x_text          --1
                                                      FROM  v_tmp_person_for_decision app
                                                      WHERE app.pd_id = p_pd
                                                            and tpp_app_tp = 'FP'
                                                            AND api$calc_right.get_docx_count(p_pd, tpp_sc, 10052, calc_dt) = 0
                                                      UNION ALL
                                                      SELECT p_pd as x_id, 'Для Утриманця '||uss_person.api$sc_tools.get_pib(tpp_sc)||
                                                                              ' документ "Довідка про взяття на облік внутрішньо переміщеної особи" не дійсний, бо в атрибуті'||
                                                                              ' "Статус довідки" пусто або зазначено "Знята з обліку"' AS x_text          --1
                                                      FROM  v_tmp_person_for_decision app
                                                      WHERE tpp_pd = p_pd
                                                            and tpp_app_tp = 'FP'
                                                            AND api$calc_right.get_docx_count(p_pd, tpp_sc, 10052, calc_dt) > 0
                                                            AND api$calc_right.get_docx_string(p_pd, tpp_sc, 10052, 1855, calc_dt, '-') != 'A'

                                                      UNION ALL
                                                      SELECT p_pd as x_id, 'Довідка ВПО для '||uss_person.api$sc_tools.get_pib(tpp_sc)||
                                                                           ' не пройшла верифікацію (результат верифікації у протоколі верифікації)' AS x_text
                                                      FROM  v_tmp_person_for_decision app
                                                      WHERE tpp_pd = p_pd
                                                            and tpp_app_tp = 'FP'
                                                            AND api$calc_right.check_vfx_st(p_pd, tpp_sc, 10052, calc_dt) != 'X'
                                        */

                                        )
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --3. Переміщено з ТГ, у яких воєнні дії, окупація, оточення
    PROCEDURE Check_ALG42 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Check_ALG23 (p_nrr_id, p_pd);
    --Set_pd_right_log(p_nrr_id, p_pd);
    END;

    --========================================
    --4. Житло зруйноване або непридатне для проживання
    PROCEDURE Check_ALG43 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Check_ALG24 (p_nrr_id, p_pd);
    --Set_pd_right_log(p_nrr_id, p_pd);
    END;

    --========================================
    --5. Особа з інвалідністю, має право на 3000 грн
    PROCEDURE Check_ALG44 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Check_ALG25 (p_nrr_id, p_pd);
    --Set_pd_right_log(p_nrr_id, p_pd);
    END;

    --========================================
    --Відсутність  рішень про призначення допомоги заявнику та членам сім`ї до 01.08.2023
    PROCEDURE Check_ALG45 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    --    l_start_new_dt DATE;
    --    l_stop_prev_dt DATE;
    BEGIN
        --    l_start_new_dt := trunc(SYSDATE, 'MM');
        --    l_stop_prev_dt := trunc(SYSDATE, 'MM')-1;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT tpp_pd                                   AS x_id,
                                'Учасник звернення  '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || --                       ' раніше вже звертався за призначенням допомоги і станом на липень 2023 не був отримувачем допомоги ВПО' AS x_text
                                ' раніше вже звертався за призначенням допомоги і станом на '
                             || TO_CHAR (TRUNC (app.calc_dt, 'MM') - 1,
                                         'dd.mm.yyyy')
                             || ' не був отримувачем допомоги ВПО'    AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z', 'FP', 'FM')
                             AND EXISTS
                                     (SELECT 1
                                        FROM pd_family f_
                                             JOIN pc_decision d_
                                                 ON d_.pd_id = f_.pdf_pd
                                             JOIN appeal a_
                                                 ON a_.ap_id = d_.pd_ap
                                       WHERE     d_.pd_nst = 664
                                             AND d_.pd_id != tpp_pd
                                             AND d_.pd_ap != app.pd_ap
                                             AND d_.pd_st IN ('S',
                                                              'PS',
                                                              'P',
                                                              'R0',
                                                              'V')
                                             AND a_.ap_reg_dt <
                                                 TRUNC (app.calc_dt, 'MM') --l_start_new_dt--to_date('01.08.2023', 'dd.mm.yyyy')
                                             AND f_.pdf_sc = app.tpp_sc
                                             AND check_accrual_period (
                                                     d_.pd_id,
                                                     TRUNC (app.calc_dt, 'MM'),
                                                       TRUNC (app.calc_dt,
                                                              'MM')
                                                     - 1) =
                                                 0--AND check_accrual_period(d_.pd_id, l_start_new_dt, l_stop_prev_dt) = 0
                                                  ))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --6. ЕОС знаходиться в іншому районі
    PROCEDURE Check_ALG46 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Check_ALG29 (p_nrr_id, p_pd);
    --Set_pd_right_log(p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG47 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG48 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG49 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG50 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG51 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG52 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG53 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --Потрібно підтвердити в ручному режимі
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                       AS x_id,
                             'Потрібно підтвердити в ручному режимі'    AS x_text
                        FROM DUAL)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG54 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                       AS x_id,
                             'Потрібно підтвердити в ручному режимі'    AS x_text
                        FROM DUAL)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG55 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                                                            AS x_id,
                                'Особа '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' за даними превентивної верифікації перебувала за межами території України більш як 30 календарних днів'    AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z', 'FP', 'FM')
                             AND EXISTS
                                     (SELECT 1
                                        FROM Uss_esr.Ap_Person p
                                             JOIN Uss_esr.Verification v
                                                 ON     p.App_Vf = v.Vf_Vf_Main
                                                    AND v.Vf_Nvt = 33
                                             JOIN uss_esr.ap_vf_answers a
                                                 ON v.Vf_Id = a.apva_vf
                                       WHERE     p.app_sc = app.tpp_sc
                                             AND p.app_ap = app.pd_ap
                                             AND a.apva_id_param = '432'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG56 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                                                                                                                         AS x_id,
                             'Не виконано жодну з умов: "Переміщено з ТГ, у яких воєнні дії, окупація, оточення" або "Житло зруйноване або непридатне для проживання"'    AS x_text                                                                                                            --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT nrr_alg,
                                         prl.prl_calc_result,
                                         prl.prl_calc_info
                                    FROM pd_right_log prl
                                         JOIN uss_ndi.v_ndi_right_rule
                                             ON nrr_id = prl.prl_nrr
                                   WHERE     prl.prl_pd = p_pd
                                         AND nrr_alg IN ('ALG42', 'ALG43')
                                         AND prl.prl_calc_result = 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG57 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd    AS x_id,
                             CASE
                                 WHEN tpp_app_tp = 'Z' AND d.pd_st != 'S'
                                 THEN
                                        'Для Заявника '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначається допомога на проживання ВПО '
                                     || d.pd_num
                                     || ' за зверненням особи '
                                     || a.ap_num
                                     || ' від '
                                     || TO_CHAR (a.ap_reg_dt, 'dd.mm.yyyy')
                                     || '.'
                                 WHEN tpp_app_tp = 'Z' AND d.pd_st = 'S'
                                 THEN
                                        'Для Заявника '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначено допомогу на проживання ВПО '
                                     || d.pd_num
                                     || '.'
                                 WHEN tpp_app_tp = 'FP' AND d.pd_st != 'S'
                                 THEN
                                        'Для Утриманця '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначається допомога на проживання ВПО '
                                     || d.pd_num
                                     || ' за зверненням особи '
                                     || a.ap_num
                                     || ' від '
                                     || TO_CHAR (a.ap_reg_dt, 'dd.mm.yyyy')
                                     || '.'
                                 WHEN tpp_app_tp = 'FP'
                                 THEN
                                        'Для Утриманця '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначено допомогу на проживання ВПО '
                                     || d.pd_num
                                     || '.'
                                 WHEN tpp_app_tp = 'FM' AND d.pd_st != 'S'
                                 THEN
                                        'Для Утриманця '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначається допомога на проживання ВПО '
                                     || d.pd_num
                                     || ' за зверненням особи '
                                     || a.ap_num
                                     || ' від '
                                     || TO_CHAR (a.ap_reg_dt, 'dd.mm.yyyy')
                                     || '.'
                                 WHEN tpp_app_tp = 'FM'
                                 THEN
                                        'Для Утриманця '
                                     || uss_person.api$sc_tools.get_pib (
                                            tpp_sc)
                                     || ' в органі соціального захисту '
                                     || d.com_org
                                     || ' призначено допомогу на проживання ВПО '
                                     || d.pd_num
                                     || '.'
                             END     AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN appeal ap ON ap.ap_id = app.pd_ap
                             JOIN pd_family pf ON pf.pdf_sc = tpp_sc
                             --JOIN ap_person   p ON p.app_ap != app.pd_ap AND p.app_sc = tpp_sc AND p.app_tp IN ('Z', 'FP') AND p.history_status = 'A'
                             JOIN pc_decision d
                                 ON     d.pd_id = pf.pdf_pd
                                    AND app.tpp_pd != d.pd_id
                                    AND app.pd_ap != d.pd_ap_reason
                                    AND app.pd_nst = d.pd_nst
                                    AND (   (    d.pd_st IN ('S', 'P')
                                             AND ap.ap_reg_dt BETWEEN d.pd_start_dt
                                                                  AND d.pd_stop_dt)
                                         OR (d.pd_st IN ('R0', 'R1',  /*'P',*/
                                                                     'K')))
                             JOIN appeal a ON a.ap_id = d.pd_ap
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z', 'FP', 'FM')
                             --AND ap.ap_reg_dt < to_date('31.07.2023', 'dd.mm.yyyy')
                             AND EXISTS
                                     (SELECT 1
                                        FROM pd_detail pdd
                                       WHERE     pdd.pdd_key = pf.pdf_id
                                             AND ap.ap_reg_dt BETWEEN pdd.pdd_start_dt
                                                                  AND pdd.pdd_stop_dt)
                             AND EXISTS
                                     (SELECT 1
                                        FROM pd_accrual_period pdap
                                       WHERE     pdap_pd = d.pd_id
                                             AND ap.ap_reg_dt BETWEEN pdap_start_dt
                                                                  AND pdap_stop_dt
                                             AND pdap.history_status = 'A'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG58 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        /*
        Якщо
        в атрибуті анкети щодо Заявника зазначено «ТАК»
        в атрибуті з Ід= 650
        AND
         (в атрибуті 654 (Доглядає за дитиною до 6-х років)
          OR в атрибуті 659 (Доглядає за дитиною з інвалідністю до 18-років)
          )
        AND Наявний документ "Копія наказу (розпорядження) роботодавця про надання відпустки" Ід=675
        AND Наявний документ Довідка про потребу дитини (дитини-інваліда) у домашньому догляді Ід=10028
        то в правилі "Має право на надбавку по довідці ЛКК" встановлювати "Так"
        Тип контролю "Попередження"
        */
        IF     L_Z.Working = 'T'
           AND (   L_Z.CaringChildUnder3 = 'T'
                OR L_Z.CaringChildUnder6 = 'T'
                OR L_Z.CaringInvUnder18 = 'T')
           AND api$account.get_docx_count (L_Z.pd_id,
                                           L_Z.app_sc,
                                           675,
                                           L_Z.calc_dt) > 0
           AND api$account.get_docx_count (L_Z.pd_id,
                                           L_Z.app_sc,
                                           676,
                                           L_Z.calc_dt) > 0
        THEN
            NULL;
        ELSE
            MERGE_tmp_errors_list (
                p_pd,
                'Заявник не має права на надбавку на догляд за інвалідом по довідці ЛКК');
        END IF;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG59 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        IF Is_Check_ALG (p_pd, 'ALG45')
        THEN
            RETURN;
        END IF;


        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (
                         CASE
                             WHEN    x_text IS NULL
                                  OR x_text1 IS NULL
                                  OR x_text2 IS NULL
                             THEN
                                 ''
                             ELSE
                                    'Особа '
                                 || x_pib
                                 || ' не відповідає критеріям, які зазначено в п.5 абз.8-9 або абз.14-16 Порядку 332'
                         END,
                         g_10
                         ON OVERFLOW TRUNCATE '...')
                     WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT DISTINCT x_id,
                                      CASE
                                          WHEN     DMG_st IN ('D', 'UH')
                                               AND DMG_cnt > 0
                                               AND EXISTS
                                                       (SELECT 1
                                                          FROM pd_accrual_period
                                                               ac
                                                         WHERE     pdap_pd =
                                                                   x_pd
                                                               AND ac.pdap_stop_dt >
                                                                   DMG_dt
                                                               AND ac.history_status =
                                                                   'A')
                                          THEN
                                                 'В особи '
                                              || uss_person.api$sc_tools.get_pib (
                                                     tpp_sc)
                                              || ' житлове приміщення було знищено або пошкоджено до припинення виплати допомоги по рішенню '
                                              || x_pd_num
                                          WHEN DMG_cnt = 0
                                          THEN
                                                 'В особи '
                                              || uss_person.api$sc_tools.get_pib (
                                                     tpp_sc)
                                              || ' житлове приміщення не було знищено або пошкоджено.'
                                      END                                         AS x_text,
                                      CASE
                                          WHEN     kaot_id IS NOT NULL
                                               --                             AND DMG_cnt = 0
                                               AND NOT EXISTS
                                                       (SELECT *
                                                          FROM tmp_kaots t
                                                         WHERE     t.tks_kaot =
                                                                   kaot_id
                                                               AND t.tks_start_dt >=
                                                                   TO_DATE (
                                                                       '01.12.2023',
                                                                       'dd.mm.yyyy')
                                                               AND t.tks_stop_dt >=
                                                                   TO_DATE (
                                                                       '01.01.2099',
                                                                       'dd.mm.yyyy'))
                                          THEN
                                                 'Особа '
                                              || uss_person.api$sc_tools.get_pib (
                                                     tpp_sc)
                                              || ' не перемістилася з територій, які включені до переліку територій після 1 грудня 2023 року'
                                      END                                         AS x_text1,
                                      CASE
                                          WHEN cnt_evac = 0
                                          THEN
                                                 'Особа '
                                              || uss_person.api$sc_tools.get_pib (
                                                     tpp_sc)
                                              || ' не евакуйована'
                                          WHEN cnt_evac > 0 AND cnt_pd > 0
                                          THEN
                                                 'Особа '
                                              || uss_person.api$sc_tools.get_pib (
                                                     tpp_sc)
                                              || ' евакуйована, але вже отримала допомогу'
                                      END                                         AS x_text2,
                                      uss_person.api$sc_tools.get_pib (tpp_sc)    x_pib
                        FROM (SELECT tpp_pd
                                         AS x_id,
                                     API$ACCOUNT.get_docx_id (tpp_pd,
                                                              tpp_sc,
                                                              10052,
                                                              2292,
                                                              app.calc_dt)
                                         AS kaot_id,
                                     API$ACCOUNT.get_docx_count (tpp_pd,
                                                                 tpp_sc,
                                                                 10090,
                                                                 app.calc_dt)
                                         AS DMG_cnt,
                                     API$ACCOUNT.get_docx_dt (tpp_pd,
                                                              tpp_sc,
                                                              10090,
                                                              5850,
                                                              app.calc_dt)
                                         AS DMG_dt,
                                     API$ACCOUNT.get_docx_string (tpp_pd,
                                                                  tpp_sc,
                                                                  10090,
                                                                  2100,
                                                                  app.calc_dt)
                                         AS DMG_st,
                                     tpp_sc,
                                     x_pd,
                                     x_pd_num,
                                     (SELECT COUNT (1)
                                        FROM src_evacuees_reestr r
                                       WHERE r.ser_sc = app.tpp_sc)
                                         AS cnt_evac,
                                     (SELECT COUNT (1)
                                        FROM pd_family pdf
                                             JOIN pd_features pde
                                                 ON     pdf.pdf_id =
                                                        pde.pde_pdf
                                                    AND pde.pde_nft = 92
                                       WHERE     pdf.pdf_sc = app.tpp_sc
                                             AND pde.pde_val_string = 'T'
                                             AND pde.pde_pd != tpp_pd)
                                         AS cnt_pd
                                FROM v_tmp_person_for_decision app,
                                     (SELECT d_.pd_id         AS x_pd,
                                             d_.pd_ap         AS x_ap,
                                             d_.pd_num        AS x_pd_num,
                                             f_.pdf_sc        AS x_sc,
                                             a_.ap_reg_dt     AS x_reg_dt
                                        FROM pd_family f_
                                             JOIN pc_decision d_
                                                 ON d_.pd_id = f_.pdf_pd
                                             JOIN appeal a_
                                                 ON a_.ap_id = d_.pd_ap
                                       WHERE     d_.pd_nst = 664
                                             AND d_.pd_st IN ('S',
                                                              'PS',
                                                              'P',
                                                              'R0',
                                                              'V'))
                               WHERE     tpp_pd IN
                                             (SELECT x_id FROM tmp_work_ids) --= p_pd
                                     AND tpp_app_tp IN ('Z', 'FP', 'FM')
                                     AND x_pd != app.tpp_pd
                                     AND x_ap != app.pd_ap
                                     AND x_sc = app.tpp_sc
                                     AND x_reg_dt < TRUNC (app.calc_dt, 'MM')))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        DELETE FROM tmp_errors_list t
              WHERE t.tel_text IS NULL;

        Set_pd_right_log (p_nrr_id, p_pd);

        IF Is_Check_SS_ALG__ (p_pd, 'ALG59')
        THEN
            set_features_91 (p_pd, 'T');
        END IF;
    END;

    --========================================
    PROCEDURE Check_ALG60 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --Нове правило - "Відсутні діючі рішення про призначення".

        --Якщо по особі "Утриманець" знайдено інше рішення у статусі "На розрахунку", "Розраховано", "Призначено", то видавати повідомлення:
        --"Для Утриманця <ПІБ> в органі соціального захисту" <код органу> призначається <назва послуги> <номер рішення> за зверненням особи <номер звернення> від <дата звернення>"

        --Якщо по особі "Утриманець" знайдено інше рішення у статусі "Нараховано", то видавати повідомлення:
        --"Для Утриманця <ПІБ> в органі соціального захисту" <код органу> призначено <назва послуги> <номер рішення>".
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT tpp_pd    AS x_id,
                                'Для Утриманця '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в органі соціального захисту '
                             || pd.com_org
                             || CASE pd.pd_st
                                    WHEN 'S'
                                    THEN
                                           ' призначено '
                                        || st.nst_name
                                        || ' '
                                        || pd.pd_num
                                        || '.'
                                    ELSE
                                           ' призначається '
                                        || st.nst_name
                                        || ' '
                                        || pd.pd_num
                                        || ' за зверненням особи '
                                        || ap.ap_num
                                        || ' від '
                                        || TO_CHAR (ap.ap_reg_dt, 'dd.mm.yyyy')
                                        || '.'
                                END    AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN pd_family pdf
                                 ON     pdf.pdf_sc = tpp_sc
                                    AND pdf.pdf_pd != tpp_pd
                             JOIN pc_decision pd
                                 ON     pd.pd_id = pdf.pdf_pd
                                    AND pd.pd_nst = app.pd_nst
                                    AND pd.pd_st IN ('R0',
                                                     'R1',
                                                     'P',
                                                     'K',
                                                     'S')
                             JOIN appeal ap ON ap.ap_id = pd.pd_ap_reason
                             JOIN uss_ndi.v_ndi_service_type st
                                 ON pd.pd_nst = st.nst_id
                       WHERE tpp_pd = p_pd AND tpp_app_tp IN ('FP'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;



        /*

                             pd AS (select ap.ap_id, ap.ap_ext_ident2,
                                           app.app_id, app.app_sc, app.app_tp,
                                           pd.pd_nst, pd.pd_st, pd.pd_start_dt, pd.pd_stop_dt, pd.com_org,
                                           CASE
                                           WHEN pd.pd_st IN ('R0', 'R1', 'P', 'K') THEN
                                                ' призначається ' || st.nst_name || ' ' || pd.pd_num || ' за зверненням особи '||ap.ap_num||' від '||to_char(ap.ap_reg_dt, 'dd.mm.yyyy')||'.'
                                           ELSE
                                                ' призначено ' || st.nst_name || ' ' || pd.pd_num || '.'
                                           END
                                               AS pd_st_txt
                                    from appeal ap
                                         JOIN ap_person   app ON app.app_ap = ap.ap_id AND app.app_tp IN ('Z', 'FP', 'FM') AND app.history_status = 'A'
                                         JOIN pc_decision pd  ON pd.pd_ap   = ap.ap_id AND pd.pd_st IN ('R0', 'R1', 'P', 'K', 'S')
                                         JOIN uss_ndi.v_ndi_service_type st ON pd.pd_nst = st.nst_id
                                    WHERE (pd_nst IN (275, 901) AND app_tp = 'FP')
                                          OR
                                          pd_nst NOT IN (275, 901)
                                    )

                        SELECT p_pd as x_id,
                               'Для '||app.app_tp_name||' '||uss_person.api$sc_tools.get_pib(tpp_sc)||' в органі соціального захисту '||pd.com_org||pd.pd_st_txt  AS x_text
                        FROM  app,
                              pd
                        WHERE app.pd_ap != pd.ap_id
                              AND app.pd_ap != pd.ap_ext_ident2
                              AND app.ap_ext_ident2 != pd.ap_id
                              AND (
                                     ( app.pd_nst IN (275, 901) AND pd.pd_nst  IN (275, 901))
                                     OR
                                     ( app.pd_nst = pd.pd_nst )
                                  )
                              AND app.tpp_sc = pd.app_sc
                              AND (
                                    ( pd.pd_st = 'S' AND app.calc_dt BETWEEN pd.pd_start_dt AND pd.pd_stop_dt)
                                    OR
                                    ( pd.pd_st IN ('R0', 'R1', 'P', 'K') )
                                  )


        */



        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG61 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --Нове правило - "Відсутні діючі рішення про призначення".

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT tpp_pd    AS x_id,
                                'Для Утриманця '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в органі соціального захисту '
                             || pd.com_org
                             || CASE pd.pd_st
                                    WHEN 'S'
                                    THEN
                                           ' призначено '
                                        || st.nst_name
                                        || ' '
                                        || pd.pd_num
                                        || '.'
                                    ELSE
                                           ' призначається '
                                        || st.nst_name
                                        || ' '
                                        || pd.pd_num
                                        || ' за зверненням особи '
                                        || ap.ap_num
                                        || ' від '
                                        || TO_CHAR (ap.ap_reg_dt, 'dd.mm.yyyy')
                                        || '.'
                                END    AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN pd_family pdf
                                 ON     pdf.pdf_sc = tpp_sc
                                    AND pdf.pdf_pd != tpp_pd
                             JOIN pc_decision pd
                                 ON     pd.pd_id = pdf.pdf_pd
                                    AND pd.pd_nst = app.pd_nst
                                    AND pd.pd_st IN ('R0',
                                                     'R1',
                                                     'P',
                                                     'K',
                                                     'S',
                                                     'PS')
                             JOIN appeal ap ON ap.ap_id = pd.pd_ap_reason
                             JOIN ap_person p
                                 ON     p.app_ap = ap.ap_id
                                    AND p.app_sc = pdf.pdf_sc
                                    AND p.history_status = 'A'
                             JOIN uss_ndi.v_ndi_service_type st
                                 ON pd.pd_nst = st.nst_id
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('DP')
                             AND NOT (app.tpp_app_tp = 'DP' AND p.app_tp = 'Z'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG62 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
            SELECT p_pd,
                   'Має підтверджуватись в ручному режимі'    AS x_errors_list
              FROM DUAL;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG63 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
            SELECT p_pd,
                   'Має підтверджуватись в ручному режимі'    AS x_errors_list
              FROM DUAL;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG64 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
            SELECT p_pd,
                   'Має підтверджуватись в ручному режимі'    AS x_errors_list
              FROM DUAL;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG65 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
            SELECT p_pd,
                   'Має підтверджуватись в ручному режимі'    AS x_errors_list
              FROM DUAL;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG66 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
        15. Підлягає розрахунку допомоги.
        Контролі: Якщо в одному із правил або
        'ALG45' п.9, або
        'ALG59' п. 10, або
        'ALG63' 'ALG64' 'ALG65' один з п.12, п.13, п. 14  зазначено «так», то в п. 15 встановлювати галочку системою, ця галочка означає,
        що дозволяємо розраховувати допомогу ВПО. (ручне встановлення галочки заборонено)
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          alg
                          AS
                              (SELECT NVL ("ALG45", 'F')     AS ALG45,
                                      NVL ("ALG59", 'F')     AS ALG59,
                                      NVL ("ALG63", 'F')     AS ALG63,
                                      NVL ("ALG64", 'F')     AS ALG64,
                                      NVL ("ALG65", 'F')     AS ALG65
                                 FROM (SELECT nrr_alg, prl.prl_result
                                         FROM pd_right_log prl
                                              JOIN uss_ndi.v_ndi_right_rule
                                                  ON nrr_id = prl.prl_nrr
                                        WHERE     prl.prl_pd = p_pd
                                              AND nrr_alg IN ('ALG45',
                                                              'ALG59',
                                                              'ALG63',
                                                              'ALG64',
                                                              'ALG65'))
                                          PIVOT (
                                                MAX (prl_result)
                                                FOR nrr_alg
                                                IN ('ALG45' "ALG45",
                                                   'ALG59' "ALG59",
                                                   'ALG63' "ALG63",
                                                   'ALG64' "ALG64",
                                                   'ALG65' "ALG65")))
                          SELECT p_pd                                                  AS x_id,
                                 'Не виконано жодну з умов для розрахунку допомоги'    AS x_text                                          --1
                            FROM alg
                           WHERE    (    ALG45 = 'F'
                                     AND ALG59 = 'F'
                                     AND ALG63 = 'F'
                                     AND ALG64 = 'F'
                                     AND ALG65 = 'F')
                                 OR (    ALG45 = 'T'
                                     AND ALG63 = 'F'
                                     AND ALG64 = 'F'
                                     AND ALG65 = 'F')
                          /*
                                        WHERE NOT EXISTS (  SELECT nrr_alg, prl.prl_calc_result, prl.prl_calc_info
                                                            FROM  pd_right_log prl
                                                                  JOIN uss_ndi.v_ndi_right_rule ON nrr_id = prl.prl_nrr
                                                            WHERE prl.prl_pd = p_pd
                                                                  AND nrr_alg IN ('ALG45', 'ALG59', 'ALG63', 'ALG64', 'ALG65')
                                                                  AND prl.prl_calc_result = 'T'
                                                         )
                          */
                          UNION ALL
                          SELECT tpp_pd                                                                AS x_id,
                                    'Для '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' в органі соціального захисту '
                                 || pd.com_org
                                 || ' призначено '
                                 || st.nst_name
                                 || ' по '
                                 || pd.pd_num
                                 || 'попереднім місяцем. Оберіть варіант подовження по Порядку 332'    AS x_text
                            FROM v_tmp_person_for_decision app
                                 JOIN pd_family pdf
                                     ON     pdf.pdf_sc = tpp_sc
                                        AND pdf.pdf_pd != tpp_pd
                                 JOIN pc_decision pd
                                     ON     pd.pd_id = pdf.pdf_pd
                                        AND pd.pd_nst = app.pd_nst
                                        AND pd.pd_st IN ('S', 'PS')
                                 JOIN uss_ndi.v_ndi_service_type st
                                     ON pd.pd_nst = st.nst_id
                           WHERE     tpp_pd = p_pd
                                 AND EXISTS
                                         (SELECT 1
                                            FROM pd_accrual_period ac
                                           WHERE     ac.pdap_pd = pd.pd_id
                                                 AND app.calc_dt BETWEEN ac.pdap_start_dt
                                                                     AND ac.pdap_stop_dt)
                                 AND NOT EXISTS
                                         (SELECT nrr_alg,
                                                 prl.prl_calc_result,
                                                 prl.prl_calc_info
                                            FROM pd_right_log prl
                                                 JOIN uss_ndi.v_ndi_right_rule
                                                     ON nrr_id = prl.prl_nrr
                                           WHERE     prl.prl_pd = p_pd
                                                 AND nrr_alg IN
                                                         ('ALG63',
                                                          'ALG64',
                                                          'ALG65')
                                                 AND prl.prl_calc_result = 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    --Перерахунок результату контроля по послузі після корегування pd_right_log
    PROCEDURE Recalc_ALG66 (p_pd_id pc_decision.pd_id%TYPE)
    IS
        l_result     VARCHAR2 (2000) := 'T';
        l_info       VARCHAR2 (2000)
                         := 'Не виконано жодну з умов для розрахунку допомоги';
        x_err_list   VARCHAR2 (4000);

        CURSOR ats IS
            SELECT prl_id
              FROM pd_right_log  prl
                   JOIN uss_ndi.v_ndi_right_rule
                       ON nrr_id = prl_nrr AND nrr_alg = 'ALG66'
             WHERE prl_pd = p_pd_id;
    BEGIN
        FOR rec IN ats
        LOOP
            IF     Is_Check_ALG (p_pd_id, 'ALG45')
               AND (   Is_Check_ALG (p_pd_id, 'ALG63')
                    OR Is_Check_ALG (p_pd_id, 'ALG64')
                    OR Is_Check_ALG (p_pd_id, 'ALG65'))
            THEN
                l_result := 'T';
                l_info := '';
            END IF;

            IF Is_Check_ALG (p_pd_id, 'ALG59')
            THEN
                l_result := 'T';
                l_info := '';
            END IF;

            IF    Is_Check_ALG (p_pd_id, 'ALG63')
               OR Is_Check_ALG (p_pd_id, 'ALG64')
               OR Is_Check_ALG (p_pd_id, 'ALG65')
            THEN
                l_result := 'T';
                l_info := '';
            END IF;



            SELECT LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                       WITHIN GROUP (ORDER BY 1)    AS x_errors_list
              INTO x_err_list
              FROM (SELECT 'Не виконано жодну з умов для розрахунку допомоги'    AS x_text                                          --1
                      FROM DUAL
                    UNION ALL
                    SELECT    'Для '
                           || uss_person.api$sc_tools.get_pib (tpp_sc)
                           || ' в органі соціального захисту '
                           || pd.com_org
                           || ' призначено '
                           || st.nst_name
                           || ' по '
                           || pd.pd_num
                           || 'попереднім місяцем. Оберіть варіант подовження по Порядку 332'    AS x_text
                      FROM v_tmp_person_for_decision  app
                           JOIN pd_family pdf
                               ON     pdf.pdf_sc = tpp_sc
                                  AND pdf.pdf_pd != tpp_pd
                           JOIN pc_decision pd
                               ON     pd.pd_id = pdf.pdf_pd
                                  AND pd.pd_nst = app.pd_nst
                                  AND pd.pd_st IN ('S', 'PS')
                           JOIN uss_ndi.v_ndi_service_type st
                               ON pd.pd_nst = st.nst_id
                     WHERE     tpp_pd = p_pd_id
                           AND EXISTS
                                   (SELECT 1
                                      FROM pd_accrual_period ac
                                     WHERE     ac.pdap_pd = pd.pd_id
                                           AND app.calc_dt BETWEEN ac.pdap_start_dt
                                                               AND ac.pdap_stop_dt)
                           AND NOT EXISTS
                                   (SELECT nrr_alg,
                                           prl.prl_calc_result,
                                           prl.prl_calc_info
                                      FROM pd_right_log  prl
                                           JOIN uss_ndi.v_ndi_right_rule
                                               ON nrr_id = prl.prl_nrr
                                     WHERE     prl.prl_pd = tpp_pd
                                           AND nrr_alg IN
                                                   ('ALG63', 'ALG64', 'ALG65')
                                           AND prl.prl_calc_result = 'T'))
             WHERE x_text IS NOT NULL;


            UPDATE pd_right_log prl
               SET prl.prl_calc_result = l_result,
                   prl.prl_result = l_result,
                   prl.prl_calc_info = l_info
             WHERE prl.prl_id = rec.prl_id;
        END LOOP;
    END;

    --========================================
    PROCEDURE Check_ALG67 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
        L_Z   API$ANKETA.Type_Rec_Anketa;
    BEGIN
        Set_Rec_Anketa_Z (p_pd, l_Z);

        --Нове правило - "Відсутні діючі рішення про призначення".

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT tpp_pd    AS x_id,
                                'Для Утриманця '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в органі соціального захисту '
                             || pd.com_org
                             || CASE pd.pd_st
                                    WHEN 'S'
                                    THEN
                                           ' призначено '
                                        || st.nst_name
                                        || ' '
                                        || pd.pd_num
                                        || '.'
                                    ELSE
                                           ' призначається '
                                        || st.nst_name
                                        || ' '
                                        || pd.pd_num
                                        || ' за зверненням особи '
                                        || ap.ap_num
                                        || ' від '
                                        || TO_CHAR (ap.ap_reg_dt, 'dd.mm.yyyy')
                                        || '.'
                                END    AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN pd_family pdf
                                 ON     pdf.pdf_sc = tpp_sc
                                    AND pdf.pdf_pd != tpp_pd
                             JOIN pc_decision pd
                                 ON     pd.pd_id = pdf.pdf_pd
                                    AND pd.pd_nst = app.pd_nst
                                    AND pd.pd_st IN ('R0',
                                                     'R1',
                                                     'P',
                                                     'K',
                                                     'S',
                                                     'PS')
                             JOIN appeal ap ON ap.ap_id = pd.pd_ap_reason
                             JOIN uss_ndi.v_ndi_service_type st
                                 ON pd.pd_nst = st.nst_id
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('FP')
                             AND API$ACCOUNT.get_docx_dt (tpp_pd,
                                                          L_Z.app_sc,
                                                          605,
                                                          8543,
                                                          app.calc_dt)
                                     IS NULL
                      UNION ALL
                      SELECT tpp_pd     AS x_id,
                                'Для Утриманця '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' не призначено "'
                             || st.nst_name
                             || '".'    AS x_text
                        FROM v_tmp_person_for_decision app
                             JOIN uss_ndi.v_ndi_service_type st
                                 ON st.nst_id = app.pd_nst
                             LEFT JOIN pd_family pdf
                                 ON     pdf.pdf_sc = tpp_sc
                                    AND pdf.pdf_pd != tpp_pd
                             LEFT JOIN pc_decision pd
                                 ON     pd.pd_id = pdf.pdf_pd
                                    AND pd.pd_nst = app.pd_nst
                                    AND pd.pd_st IN ('S', 'PS')
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('FP')
                             AND pd.pd_id IS NULL
                             AND API$ACCOUNT.get_docx_dt (tpp_pd,
                                                          L_Z.app_sc,
                                                          605,
                                                          8543,
                                                          app.calc_dt)
                                     IS NOT NULL)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG68 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        --У правилі не встановлювати "так", якщо^
        --в документі з Ід=10314 "Заява про надання тимчасової допомоги "Дитина не одна"
        --в атрибуті з Ід=8437 "КАТТОТГ (місця проживання)"
        --зазначено КАОТТОГ, який в довіднику КАТТОТГ має відкритий період з типом "Тимчасово окуповано"
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_pd                                        AS x_id,
                                'Станом на дату звернення (на дату реєстрації заяви) '
                             || 'особа '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' проживає на окупованих терріторіях'    AS x_text --1
                        FROM (SELECT app.*,
                                     API$CALC_RIGHT.get_docx_id (tpp_pd,
                                                                 tpp_sc,
                                                                 10314,
                                                                 8437,
                                                                 app.calc_dt)    AS x_kaot
                                FROM v_tmp_person_for_decision app
                               WHERE tpp_pd = p_pd) app
                       WHERE     x_kaot IS NOT NULL
                             AND EXISTS
                                     (SELECT s.*
                                        FROM uss_ndi.v_Ndi_Katottg k
                                             JOIN uss_ndi.V_NDI_KAOT_STATE s
                                                 ON     (   (    s.kaots_kaot =
                                                                 k.kaot_id
                                                             AND k.kaot_TP =
                                                                 'K')
                                                         OR (    k.kaot_id =
                                                                 k.kaot_kaot_l3
                                                             AND s.kaots_kaot =
                                                                 k.kaot_kaot_l3)
                                                         OR (    k.kaot_id =
                                                                 k.kaot_kaot_l4
                                                             AND (   s.kaots_kaot =
                                                                     k.kaot_kaot_l3
                                                                  OR s.kaots_kaot =
                                                                     k.kaot_kaot_l4))
                                                         OR (    k.kaot_id =
                                                                 k.kaot_kaot_l5
                                                             AND (   s.kaots_kaot =
                                                                     k.kaot_kaot_l3
                                                                  OR s.kaots_kaot =
                                                                     k.kaot_kaot_l4
                                                                  OR s.kaots_kaot =
                                                                     k.kaot_kaot_l5)))
                                                    AND s.history_status = 'A'
                                       WHERE     kaot_id = x_kaot
                                             AND app.calc_dt BETWEEN NVL (
                                                                         KAOTS_START_DT,
                                                                         app.calc_dt)
                                                                 AND NVL (
                                                                         KAOTS_STOP_DT,
                                                                         app.calc_dt)
                                             AND app.calc_dt BETWEEN NVL (
                                                                         KAOT_START_DT,
                                                                         app.calc_dt)
                                                                 AND NVL (
                                                                         KAOT_STOP_DT,
                                                                         app.calc_dt)
                                             AND KAOTS_TP IN ('TO')))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG69 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
        Якщо по особі "Заявник" знайдено інше рішення по послузі у статусі "На розрахунку", "Розраховано", "Призначено", то видавати повідомлення:
        "Для Заявника <ПІБ> в органі соціального захисту" <код органу> призначається <назва послуги> <номер рішення> за зверненням особи <номер звернення> від <дата звернення>"
        Якщо по особі "Заявник" знайдено інше рішення у статусі "Нараховано", то видавати повідомлення: "Для Заявника <ПІБ> в органі соціального захисту" <код органу> призначено <назва послуги> <номер рішення>"
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          app
                          AS
                              (SELECT calc_dt,
                                      tpp_pd,
                                      tpp_sc,
                                      tpp_app_tp,
                                      tpp_dt_from,
                                      tpp_dt_to,
                                      DECODE (tpp_app_tp,
                                              'Z', 'Заявника',
                                              'FP', 'Утриманця',
                                              'FM', 'Члена сім’ї',
                                              '')    AS app_tp_name,
                                      app.pd_nst,
                                      app.pd_ap,
                                      ap1.ap_ap_main
                                 FROM v_tmp_person_for_decision app
                                      JOIN appeal ap1 ON ap1.ap_id = app.pd_ap
                                WHERE     tpp_pd = p_pd
                                      AND pd_nst = 901
                                      AND tpp_app_tp = 'FP'),
                          pd
                          AS
                              (SELECT ap.ap_id,
                                      ap.ap_ap_main,
                                      app.app_id,
                                      app.app_sc,
                                      app.app_tp,
                                      pd.pd_nst,
                                      pd.pd_st,
                                      pd.pd_start_dt,
                                      pd.pd_stop_dt,
                                      pd.com_org,
                                      f.pdf_start_dt,
                                      f.pdf_stop_dt,
                                      CASE
                                          WHEN pd.pd_st IN ('R0',
                                                            'R1',
                                                            'P',
                                                            'K')
                                          THEN
                                                 ' призначається '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || ' за зверненням особи '
                                              || ap.ap_num
                                              || ' від '
                                              || TO_CHAR (ap.ap_reg_dt,
                                                          'dd.mm.yyyy')
                                              || '.'
                                          ELSE
                                                 ' призначено '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || '.'
                                      END    AS pd_st_txt
                                 FROM appeal ap
                                      JOIN ap_person app
                                          ON     app.app_ap = ap.ap_id
                                             AND app.app_tp IN
                                                     ('Z', 'FP', 'FM')
                                             AND app.history_status = 'A'
                                      JOIN pc_decision pd
                                          ON     pd.pd_ap = ap.ap_id
                                             AND pd.pd_st IN ('R0',
                                                              'R1',
                                                              'P',
                                                              'K',
                                                              'S')
                                      JOIN pd_family f
                                          ON     f.pdf_pd = pd.pd_id
                                             AND f.pdf_sc = app_sc
                                             AND f.history_status = 'A'
                                      JOIN uss_ndi.v_ndi_service_type st
                                          ON pd.pd_nst = st.nst_id
                                WHERE pd_nst = 901 AND app_tp = 'FP')
                      SELECT p_pd               AS x_id,
                                'Для '
                             || app.app_tp_name
                             || ' '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в органі соціального захисту '
                             || pd.com_org
                             || pd.pd_st_txt    AS x_text
                        --,pdf_start_dt, pdf_stop_dt, tpp_dt_from, tpp_dt_to
                        FROM app, pd
                       WHERE     app.pd_ap != pd.ap_id
                             AND (   app.pd_ap != pd.ap_ap_main
                                  OR pd.ap_ap_main IS NULL)
                             AND (   app.ap_ap_main != pd.ap_id
                                  OR app.ap_ap_main IS NULL)
                             AND app.tpp_sc = pd.app_sc
                             AND (   pdf_start_dt BETWEEN tpp_dt_from
                                                      AND tpp_dt_to
                                  OR pdf_stop_dt BETWEEN tpp_dt_from
                                                     AND tpp_dt_to
                                  OR tpp_dt_from BETWEEN pdf_start_dt
                                                     AND pdf_stop_dt
                                  OR tpp_dt_to BETWEEN pdf_start_dt
                                                   AND pdf_stop_dt))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG70 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT tpp_pd                                                           AS x_id,
                             'Відсутній договір про надання послуги патронату над дитиною'    AS x_text                                                     --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z')
                             AND app.pd_nst = 901
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM PERSONALCASE pc
                                             JOIN appeal a
                                                 ON     a.ap_pc = pc_id
                                                    AND a.ap_reg_dt <=
                                                        app.calc_dt
                                                    AND a.ap_st IN
                                                            ('O', 'WD', 'V') -- #116029, в V переводять при обробці рішення по 1201
                                             JOIN ap_service s
                                                 ON     aps_ap = ap_id
                                                    AND s.aps_nst = 1201
                                                    AND s.history_status = 'A'
                                       WHERE     pc.pc_sc = app.tpp_sc
                                             AND api$appeal.Get_Ap_z_Doc_String (
                                                     a.ap_id,
                                                     605,
                                                     2668) =
                                                 'T')
                      UNION ALL
                      SELECT tpp_pd                                                   AS x_id,
                             'Відсутній договір помічника патронатного вихователя'    AS x_text                                                --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z')
                             AND app.pd_nst = 1221
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM PERSONALCASE pc
                                             JOIN appeal a
                                                 ON     a.ap_pc = pc_id
                                                    AND a.ap_reg_dt <=
                                                        app.calc_dt
                                                    AND a.ap_st IN
                                                            ('O', 'WD', 'V') -- #116029, в V переводять при обробці рішення по 1201
                                             JOIN ap_service s
                                                 ON     aps_ap = ap_id
                                                    AND s.aps_nst = 1201
                                                    AND s.history_status = 'A'
                                       WHERE     pc.pc_sc = app.tpp_sc
                                             AND api$appeal.Get_Ap_z_Doc_String (
                                                     a.ap_id,
                                                     605,
                                                     8462) =
                                                 'T')
                      UNION ALL
                      SELECT tpp_pd                                                           AS x_id,
                             'Відсутній договір про надання послуги патронату над дитиною'    AS x_text                                                     --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z')
                             AND app.pd_nst = 23
                             AND api$account.get_docx_dt (tpp_pd,
                                                          tpp_sc,
                                                          605,
                                                          2668,
                                                          calc_dt) = 'T'
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM PERSONALCASE pc
                                             JOIN appeal a
                                                 ON     a.ap_pc = pc_id
                                                    AND a.ap_reg_dt <=
                                                        app.calc_dt
                                                    AND a.ap_st IN
                                                            ('O', 'WD', 'V') -- #116029, в V переводять при обробці рішення по 1201
                                             JOIN ap_service s
                                                 ON     aps_ap = ap_id
                                                    AND s.aps_nst = 1201
                                                    AND s.history_status = 'A'
                                       WHERE     pc.pc_sc = app.tpp_sc
                                             AND api$appeal.Get_Ap_z_Doc_String (
                                                     a.ap_id,
                                                     605,
                                                     2668) =
                                                 'T')
                      UNION ALL
                      SELECT tpp_pd                                                   AS x_id,
                             'Відсутній договір помічника патронатного вихователя'    AS x_text                                                --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z')
                             AND app.pd_nst = 23
                             AND api$account.get_docx_dt (tpp_pd,
                                                          tpp_sc,
                                                          605,
                                                          8462,
                                                          calc_dt) = 'T'
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM PERSONALCASE pc
                                             JOIN appeal a
                                                 ON     a.ap_pc = pc_id
                                                    AND a.ap_reg_dt <=
                                                        app.calc_dt
                                                    AND a.ap_st IN
                                                            ('O', 'WD', 'V') -- #116029, в V переводять при обробці рішення по 1201
                                             JOIN ap_service s
                                                 ON     aps_ap = ap_id
                                                    AND s.aps_nst = 1201
                                                    AND s.history_status = 'A'
                                       WHERE     pc.pc_sc = app.tpp_sc
                                             AND api$appeal.Get_Ap_z_Doc_String (
                                                     a.ap_id,
                                                     605,
                                                     8462) =
                                                 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG71 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (-- "Заява про надання послуги помічника патронатного вихователя" (ІД 10321) в атрибуті "Дата початку надання послуги" (ІД 8522).
                      SELECT p_pd                                                                                      AS x_id,
                             '"Дата звернення" / "Дата початку надання послуги" має бути не раніше ніж 04.06.2024 '    AS x_text                                                         --1
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z')
                             AND (   calc_dt <
                                     TO_DATE ('04.06.2024', 'dd.mm.yyyy')
                                  OR api$account.get_docx_dt (tpp_pd,
                                                              tpp_sc,
                                                              10323,
                                                              8522,
                                                              calc_dt) <
                                     TO_DATE ('04.06.2024', 'dd.mm.yyyy')))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG72 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
        Якщо по особі "Заявник" знайдено інше рішення по послузі у статусі "На розрахунку", "Розраховано", "Призначено", то видавати повідомлення:
        "Для Заявника <ПІБ> в органі соціального захисту" <код органу> призначається <назва послуги> <номер рішення> за зверненням особи <номер звернення> від <дата звернення>"
        Якщо по особі "Заявник" знайдено інше рішення у статусі "Нараховано", то видавати повідомлення: "Для Заявника <ПІБ> в органі соціального захисту" <код органу> призначено <назва послуги> <номер рішення>"
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          app
                          AS
                              (SELECT calc_dt,
                                      tpp_pd,
                                      tpp_sc,
                                      tpp_app_tp,
                                      api$account.get_docx_dt (tpp_pd,
                                                               tpp_sc,
                                                               10342,
                                                               8625,
                                                               calc_dt)
                                          AS x_from_dt,
                                      api$account.get_docx_dt (tpp_pd,
                                                               tpp_sc,
                                                               10342,
                                                               8626,
                                                               calc_dt)
                                          AS x_to_dt,
                                      DECODE (tpp_app_tp,
                                              'Z', 'Заявника',
                                              'FP', 'Утриманця',
                                              'FM', 'Члена сім’ї',
                                              '')
                                          AS app_tp_name,
                                      app.pd_nst,
                                      app.pd_ap,
                                      app.pd_pc
                                 FROM v_tmp_person_for_decision app
                                WHERE     tpp_pd = p_pd
                                      AND pd_nst = 23
                                      AND tpp_app_tp = 'Z'),
                          pd
                          AS
                              (SELECT ap.ap_id,
                                      ap.ap_ap_main,
                                      app.app_id,
                                      app.app_sc,
                                      app.app_tp,
                                      pd.pd_id,
                                      pd.pd_nst,
                                      pd.pd_st,
                                      pd.com_org,
                                      f.pdf_start_dt,
                                      f.pdf_stop_dt,
                                      CASE
                                          WHEN pd.pd_st IN ('R0',
                                                            'R1',
                                                            'P',
                                                            'K')
                                          THEN
                                                 ' призначається '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || ' за зверненням особи '
                                              || ap.ap_num
                                              || ' від '
                                              || TO_CHAR (ap.ap_reg_dt,
                                                          'dd.mm.yyyy')
                                              || '.'
                                          ELSE
                                                 ' призначено '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || '.'
                                      END    AS pd_st_txt
                                 FROM appeal ap
                                      JOIN ap_person app
                                          ON     app.app_ap = ap.ap_id
                                             AND app.app_tp IN ('Z')
                                             AND app.history_status = 'A'
                                      JOIN pc_decision pd
                                          ON     pd.pd_ap = ap.ap_id
                                             AND pd.pd_st IN ('R0',
                                                              'R1',
                                                              'P',
                                                              'K',
                                                              'S')
                                      JOIN pd_family f
                                          ON     f.pdf_pd = pd.pd_id
                                             AND f.pdf_sc = app_sc
                                             AND f.history_status = 'A'
                                      JOIN uss_ndi.v_ndi_service_type st
                                          ON pd.pd_nst = st.nst_id
                                WHERE     EXISTS
                                              (SELECT 1
                                                 FROM app
                                                WHERE     app.pd_pc = pd.pd_pc
                                                      AND app.pd_ap != pd.pd_ap
                                                      AND app.tpp_pd = p_pd)
                                      AND pd_nst IN (23, 901, 1221))
                      SELECT p_pd               AS x_id,
                                'Для '
                             || app.app_tp_name
                             || ' '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в органі соціального захисту '
                             || pd.com_org
                             || pd.pd_st_txt    AS x_text
                        --,pdf_start_dt, pdf_stop_dt, tpp_dt_from, tpp_dt_to
                        FROM app, pd
                       WHERE     app.pd_ap != pd.ap_id
                             AND app.tpp_sc = pd.app_sc
                             AND EXISTS
                                     (SELECT *
                                        FROM pd_payment pdp
                                       WHERE     pdp.pdp_pd = pd.pd_id
                                             AND (   pdp.pdp_npt = 839
                                                  OR pdp.pdp_npt = 856
                                                  OR pdp.pdp_npt = 854)
                                             AND pdp.history_status = 'A'
                                             AND (   x_from_dt BETWEEN pdp.pdp_start_dt
                                                                   AND pdp.pdp_stop_dt
                                                  OR x_to_dt BETWEEN pdp.pdp_start_dt
                                                                 AND pdp.pdp_stop_dt
                                                  OR pdp.pdp_start_dt BETWEEN x_from_dt
                                                                          AND x_to_dt
                                                  OR pdp.pdp_stop_dt BETWEEN x_from_dt
                                                                         AND x_to_dt))
                             AND (   EXISTS
                                         (SELECT *
                                            FROM pd_accrual_period pdap
                                           WHERE     pdap.pdap_pd = pd.pd_id
                                                 AND pdap.history_status = 'A'
                                                 AND (   x_from_dt BETWEEN pdap.pdap_start_dt
                                                                       AND pdap.pdap_stop_dt
                                                      OR x_to_dt BETWEEN pdap.pdap_start_dt
                                                                     AND pdap.pdap_stop_dt
                                                      OR pdap.pdap_start_dt BETWEEN x_from_dt
                                                                                AND x_to_dt
                                                      OR pdap.pdap_stop_dt BETWEEN x_from_dt
                                                                               AND x_to_dt))
                                  OR pd.pd_st != 'S'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG73 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        /*
        Якщо по особі "Заявник" знайдено інше рішення по послузі у статусі "На розрахунку", "Розраховано", "Призначено", то видавати повідомлення:
        "Для Заявника <ПІБ> в органі соціального захисту" <код органу> призначається <назва послуги> <номер рішення> за зверненням особи <номер звернення> від <дата звернення>"
        Якщо по особі "Заявник" знайдено інше рішення у статусі "Нараховано", то видавати повідомлення: "Для Заявника <ПІБ> в органі соціального захисту" <код органу> призначено <назва послуги> <номер рішення>"
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          app
                          AS
                              (SELECT calc_dt,
                                      tpp_pd,
                                      tpp_sc,
                                      tpp_app_tp,
                                      DECODE (tpp_app_tp,
                                              'Z', 'Заявника',
                                              'FP', 'Утриманця',
                                              'FM', 'Члена сім’ї',
                                              '')    AS app_tp_name,
                                      app.pd_nst,
                                      app.pd_ap,
                                      app.pd_pc
                                 FROM v_tmp_person_for_decision app
                                WHERE     tpp_pd = p_pd
                                      AND pd_nst IN (901, 1221)
                                      AND tpp_app_tp = 'Z'),
                          pd
                          AS
                              (SELECT ap.ap_id,
                                      ap.ap_ap_main,
                                      app.app_id,
                                      app.app_sc,
                                      app.app_tp,
                                      pd.pd_id,
                                      pd.pd_nst,
                                      pd.pd_st,
                                      pd.com_org,
                                      CASE
                                          WHEN pd.pd_st IN ('R0',
                                                            'R1',
                                                            'P',
                                                            'K')
                                          THEN
                                                 ' призначається '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || ' за зверненням особи '
                                              || ap.ap_num
                                              || ' від '
                                              || TO_CHAR (ap.ap_reg_dt,
                                                          'dd.mm.yyyy')
                                              || '.'
                                          ELSE
                                                 ' призначено '
                                              || st.nst_name
                                              || ' '
                                              || pd.pd_num
                                              || '.'
                                      END    AS pd_st_txt
                                 FROM appeal ap
                                      JOIN ap_person app
                                          ON     app.app_ap = ap.ap_id
                                             AND app.app_tp IN ('Z')
                                             AND app.history_status = 'A'
                                      JOIN pc_decision pd
                                          ON     pd.pd_ap = ap.ap_id
                                             AND pd.pd_st IN ('R0',
                                                              'R1',
                                                              'P',
                                                              'K',
                                                              'S')
                                      JOIN uss_ndi.v_ndi_service_type st
                                          ON pd.pd_nst = st.nst_id
                                WHERE     EXISTS
                                              (SELECT 1
                                                 FROM app
                                                WHERE     app.pd_pc = pd.pd_pc
                                                      AND app.pd_ap != pd.pd_ap)
                                      AND pd_nst IN (268, 275))
                      SELECT p_pd               AS x_id,
                                'Для '
                             || app.app_tp_name
                             || ' '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || ' в органі соціального захисту '
                             || pd.com_org
                             || pd.pd_st_txt    AS x_text
                        --,pdf_start_dt, pdf_stop_dt, tpp_dt_from, tpp_dt_to
                        FROM app, pd
                       WHERE     app.pd_ap != pd.ap_id
                             AND app.tpp_sc = pd.app_sc
                             AND (   EXISTS
                                         (SELECT *
                                            FROM pd_accrual_period pdap
                                           WHERE     pdap.pdap_pd = pd.pd_id
                                                 AND pdap.history_status = 'A'
                                                 AND (calc_dt BETWEEN pdap.pdap_start_dt
                                                                  AND pdap.pdap_stop_dt))
                                  OR pd.pd_st != 'S'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG74 (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          anove
                          AS
                              (  SELECT pd.pd_id,
                                        pd.pd_num,
                                        pd.com_org,
                                        pd_nst,
                                        MIN (ac.pdap_start_dt)     AS x_start_dt,
                                        MAX (ac.pdap_stop_dt)      AS x_stop_dt
                                   FROM pc_decision pd
                                        JOIN pd_accrual_period ac
                                            ON     ac.pdap_pd = pd.pd_id
                                               AND ac.history_status = 'A'
                                  WHERE     pd_nst IN (23, 1201)
                                        AND pd_st IN ('S', 'PS')
                                        AND EXISTS
                                                (SELECT 1
                                                   FROM v_tmp_person_for_decision
                                                        t
                                                  WHERE     t.pd_id = p_pd
                                                        AND t.pd_pc = pd.pd_pc)
                               GROUP BY pd.pd_id,
                                        pd.pd_num,
                                        pd.com_org,
                                        pd_nst)
                          SELECT tpp_pd    AS x_id,
                                    'Для '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' в органі соціального захисту '
                                 || a.com_org
                                 || CASE a.pd_nst
                                        WHEN 23
                                        THEN
                                            ' призначено виплати "За використання накопичених днів"'
                                        WHEN 1201
                                        THEN
                                            ' призначено виплати "За період очікування дитини", "За 7 днів (профілактика проф.вигорання)"'
                                        ELSE
                                            ' призначено'
                                    END
                                 || ' за рішенням '
                                 || a.pd_num
                                 || ' з '
                                 || TO_CHAR (x_start_dt, 'dd.mm.yy')
                                 || ' по '
                                 || TO_CHAR (x_start_dt, 'dd.mm.yy')
                                 || '.'    AS x_text
                            FROM v_tmp_person_for_decision app
                                 JOIN anove a
                                     ON app.calc_dt BETWEEN a.x_start_dt
                                                        AND a.x_stop_dt
                           WHERE     tpp_pd = p_pd
                                 AND tpp_app_tp IN ('Z')
                                 AND app.pd_nst = 901
                          UNION ALL
                          SELECT tpp_pd    AS x_id,
                                    'Для '
                                 || uss_person.api$sc_tools.get_pib (tpp_sc)
                                 || ' в органі соціального захисту '
                                 || a.com_org
                                 || CASE a.pd_nst
                                        WHEN 23
                                        THEN
                                            ' призначено виплати "За використання накопичених днів"'
                                        WHEN 1201
                                        THEN
                                            ' призначено виплати "За період очікування дитини", "За 7 днів (профілактика проф.вигорання)"'
                                        ELSE
                                            ' призначено'
                                    END
                                 || ' за рішенням '
                                 || a.pd_num
                                 || ' з '
                                 || TO_CHAR (x_start_dt, 'dd.mm.yy')
                                 || ' по '
                                 || TO_CHAR (x_start_dt, 'dd.mm.yy')
                                 || '.'    AS x_text
                            FROM v_tmp_person_for_decision app
                                 JOIN anove a
                                     ON app.calc_dt BETWEEN a.x_start_dt
                                                        AND a.x_stop_dt
                           WHERE     tpp_pd = p_pd
                                 AND tpp_app_tp IN ('Z')
                                 AND app.pd_nst = 1221)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;

    --========================================
    PROCEDURE Check_ALG45__ (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, g_10 ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT tpp_pd                                   AS x_id,
                                'Учасник звернення  '
                             || uss_person.api$sc_tools.get_pib (tpp_sc)
                             || --                       ' раніше вже звертався за призначенням допомоги і станом на липень 2023 не був отримувачем допомоги ВПО' AS x_text
                                ' раніше вже звертався за призначенням допомоги і станом на '
                             || TO_CHAR (TRUNC (app.calc_dt, 'MM') - 1,
                                         'dd.mm.yyyy')
                             || ' не був отримувачем допомоги ВПО'    AS x_text
                        FROM v_tmp_person_for_decision app
                       WHERE     tpp_pd = p_pd
                             AND tpp_app_tp IN ('Z', 'FP', 'FM')
                             AND EXISTS
                                     (SELECT 1
                                        FROM pd_family f_
                                             JOIN pc_decision d_
                                                 ON d_.pd_id = f_.pdf_pd
                                             JOIN appeal a_
                                                 ON a_.ap_id = d_.pd_ap
                                       WHERE     d_.pd_nst = 664
                                             AND d_.pd_id != tpp_pd
                                             AND d_.pd_ap != app.pd_ap
                                             AND d_.pd_st IN ('S',
                                                              'PS',
                                                              'P',
                                                              'R0',
                                                              'V')
                                             AND a_.ap_reg_dt <
                                                 TRUNC (app.calc_dt, 'MM') --l_start_new_dt--to_date('01.08.2023', 'dd.mm.yyyy')
                                             AND f_.pdf_sc = app.tpp_sc
                                             AND check_accrual_period (
                                                     d_.pd_id,
                                                     TRUNC (app.calc_dt, 'MM'),
                                                       TRUNC (app.calc_dt,
                                                              'MM')
                                                     - 1) =
                                                 0--AND check_accrual_period(d_.pd_id, l_start_new_dt, l_stop_prev_dt) = 0
                                                  ))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_pd_right_log (p_nrr_id, p_pd);
    END;



    --========================================
    PROCEDURE Check_Other (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        MERGE INTO pd_right_log
             USING (SELECT x_id AS b_pd, p_nrr_id AS b_nrr, 'F' AS b_result
                      FROM tmp_work_ids
                     WHERE x_id = p_pd)
                ON (prl_pd = b_pd AND prl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET
                prl_calc_result = b_result,
                prl_hs_rewrite = NULL,
                prl_result = b_result
        WHEN NOT MATCHED
        THEN
            INSERT     (prl_id,
                        prl_pd,
                        prl_nrr,
                        prl_result,
                        prl_calc_result)
                VALUES (0,
                        b_pd,
                        b_nrr,
                        b_result,
                        b_result);
    END;

    --========================================
    PROCEDURE Clear_pd_payment
    IS
    BEGIN
        --Видаляємо існуючі деталі розрахунку рішення
        DELETE FROM pd_detail
              WHERE pdd_pdp IN (SELECT pdp_id
                                  FROM pd_payment, tmp_work_ids
                                 WHERE pdp_pd = x_id);

        --Видаляємо існуючі розрахунки рішення
        DELETE FROM pd_payment
              WHERE pdp_pd IN (SELECT x_id FROM tmp_work_ids);
    END;

    --========================================
    PROCEDURE init_right_for_decision (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                                       p_pd_id          pc_decision.pd_id%TYPE,
                                       p_messages   OUT SYS_REFCURSOR)
    IS
        l_messages   TOOLS.t_messages := TOOLS.t_messages ();
        l_cnt        INTEGER;
        l_hs         histsession.hs_id%TYPE;
    BEGIN
        l_messages.delete;

        IF p_mode = 1 AND p_pd_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT pd_id
                  FROM pc_decision
                 WHERE pd_id = p_pd_id;

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, pc_decision
             WHERE x_id = pd_id;
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію перевірки наявності права на виплату не передано ідентифікаторів проектів рішень на виплату!');
        END IF;

        l_hs := TOOLS.GetHistSession;

        Clear_pd_payment;                                   ---#77881 20220610

        --Видаляємо ті правила перевірки права, яких немає в налаштуваннях для типу допомоги
        DELETE FROM pd_right_log
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_work_ids
                          WHERE prl_pd = x_id) /*
               AND NOT EXISTS (SELECT 1
                               FROM uss_ndi.v_ndi_nrr_config, pc_decision, tmp_work_ids
                               WHERE nruc_nst = pd_nst
                                 AND pd_id = x_id
                                 AND nruc_nrr = prl_nrr)*/
                                              ;

        --Заполним буфер для анкеті заявителя
        API$ANKETA.Set_Anketa;
        api$account.init_tmp_kaots;

        --Вставляємо всі правила по типу допомоги або якщо для типу послуги немає налаштуваннь, то ті правила, які не прив`язані до налаштувань
        FOR xx
            IN (SELECT nrr_id,
                       nrr_name,
                       nrr_alg,
                       nrr_order,
                       pd_nst     AS y_nst,
                       pd_id      AS x_pd,
                       pd_dt      AS x_pd_dt                 --, pd_ap AS x_ap
                  FROM tmp_work_ids
                       JOIN pc_decision ON x_id = pd_id
                       JOIN appeal ON ap_id = pd_ap_reason
                       JOIN uss_ndi.v_ndi_nrr_config
                           ON nruc_nst = pd_nst AND history_status = 'A'
                       JOIN uss_ndi.v_ndi_right_rule
                           ON nruc_nrr = nrr_id AND nrr_alg NOT LIKE 'G.%'
                 WHERE TRUNC (ap_reg_dt) BETWEEN nruc_start_dt
                                             AND nruc_stop_dt
                UNION ALL
                SELECT nrr_id,
                       nrr_name,
                       nrr_alg,
                       nrr_order,
                       0,
                       pd_id     AS x_pd,
                       pd_dt     AS x_pd_dt                  --, pd_ap AS x_ap
                  FROM uss_ndi.v_ndi_right_rule, tmp_work_ids, pc_decision
                 WHERE     x_id = pd_id
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM uss_ndi.v_ndi_nrr_config
                                 WHERE nruc_nst = pd_nst)
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM uss_ndi.v_ndi_nrr_config
                                 WHERE nruc_nrr = nrr_id)
                ORDER BY nrr_order)
        LOOP
            DELETE FROM tmp_errors_list
                  WHERE 1 = 1;

            CASE xx.nrr_alg
                WHEN 'ALG1'
                THEN
                    CASE xx.y_nst
                        WHEN 20
                        THEN
                            Check_ALG1_20 (xx.nrr_id, xx.x_pd);
                        WHEN 21
                        THEN
                            Check_ALG1_21 (xx.nrr_id, xx.x_pd);
                        WHEN 241
                        THEN
                            Check_ALG1_241 (xx.nrr_id, xx.x_pd);
                        WHEN 250
                        THEN
                            Check_ALG1_250 (xx.nrr_id, xx.x_pd);
                        WHEN 248
                        THEN
                            Check_ALG1_248 (xx.nrr_id, xx.x_pd);
                        /*  Визначення права на допомогу по особам з інвалідністю з дитинства та дітям з інвалідністю:
                        1. Обов’язкові документи для призначення допомоги надано (Так/Ні):           ALG1
                        Для ІД послуги (надбавки)=244, 243, 242, 289, 264
                        2. Має право на надбавку <вид надбавки в залежності від Ід >(Так/Ні):        ALG?
                        */
                        WHEN 249
                        THEN
                            Check_ALG1_249 (xx.nrr_id, xx.x_pd);
                        /*  Визначення права на отримання допомоги малозабезпеченим сім_ям:

                        */
                        WHEN 265
                        THEN
                            Check_ALG1_265 (xx.nrr_id, xx.x_pd);
                        /* 71892 Визначення права на допомогу по догляду за хворою дитиною  ІД послуги = 265
                        1. Обов’язкові документи надано (Так/Ні)                                     ALG1
                        2. Утриманець відповідає умовам Порядку №1751 (Так/Ні):                      ALG13
                        */
                        WHEN 267
                        THEN
                            Check_ALG1_267 (xx.nrr_id, xx.x_pd);
                        /* 71894 Розрахунок допомоги одиноким матерям    ІД послуги = 267
                        1. Обов’язкові документи надано (Так/Ні):                                    ALG1
                        2. Згідно додаткової інформації у заяві право має: (Так/Ні)                  ALG2
                        3. Заявник <ПІБ> відповідає умовам Порядку №1751 для призначення: (Так/Ні)   ALG3
                        4. Член сім’ї <ПІБ> відповідає умовам Порядку №1751 для призначення:(Так/Ні) ALG4
                        5. Наявність сплати ЄСВ для <ПІБ, заявника, члена сім’ї>: кількість місяців. ALG5
                        6. Кількість будинків/квартир менше ніж 2: (Так/Ні)                          ALG6
                        7. Кількість транспортних засобів менше ніж 2: (Так/Ні)                      ALG7
                        8. Здійснено покупку, що перевершує 50 тис грн: (Так/Ні)                     ALG8
                        9. Протягом року оплачено послуги, що перевищують суму 50 тис. грн: (Так/Ні) ALG9
                        10. Додаткові, підтверджуючі документи надано: (Так/Ні)                       ALG10
                        */
                        WHEN 268
                        THEN
                            /* 71732 Визначення права на допомогу на дітей, над якими встановлено опіку чи піклування   ІД послуги = 268
                            1. Обов’язкові документи надано (Так/Ні):                  ALG1
                            2. Підопічний відповідає умовам Порядку №1751 (Так/Ні):    ALG14
                            */
                            Check_ALG1_268 (xx.nrr_id, xx.x_pd);
                        WHEN 269
                        THEN
                            /* 71893 Визначення права на допомогу з усиновлення   ІД послуги = 269
                            1. Обов’язкові документи надано (Так/Ні)                                   ALG1
                            2. Рішення суду про усиновлення відповідає умовам Порядку №1751 (Так/Ні)   ALG15
                            3. Утриманець відповідає умовам Порядку №1751 (Так/Ні)                     ALG18
                            */
                            Check_ALG1_269 (xx.nrr_id, xx.x_pd);
                        WHEN 275
                        THEN
                            Check_ALG1_275 (xx.nrr_id, xx.x_pd);
                        WHEN 620
                        THEN
                            Check_ALG1_62x (xx.nrr_id, xx.x_pd);
                        WHEN 621
                        THEN
                            Check_ALG1_62x (xx.nrr_id, xx.x_pd);
                        WHEN 862
                        THEN
                            Check_ALG1_862 (xx.nrr_id, xx.x_pd);
                        WHEN 901
                        THEN
                            Check_ALG1_901 (xx.nrr_id, xx.x_pd);
                        WHEN 1221
                        THEN
                            Check_ALG1_1221 (xx.nrr_id, xx.x_pd);
                        WHEN 23
                        THEN
                            Check_ALG1_23 (xx.nrr_id, xx.x_pd);
                        ELSE
                            Check_ALG1 (xx.nrr_id, xx.x_pd);
                    END CASE;
                WHEN 'ALG2'
                THEN
                    Check_ALG2 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG3'
                THEN
                    Check_ALG3 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG4'
                THEN
                    Check_ALG4 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG5'
                THEN
                    Check_ALG5 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG6'
                THEN
                    Check_ALG6 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG7'
                THEN
                    Check_ALG7 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG8'
                THEN
                    Check_ALG8 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG9'
                THEN
                    Check_ALG9 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG10'
                THEN
                    Check_ALG10 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG12'
                THEN
                    Check_ALG12 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG13'
                THEN
                    CASE xx.y_nst
                        WHEN 267
                        THEN
                            Check_ALG13_267 (xx.nrr_id, xx.x_pd);
                        ELSE
                            Check_ALG13 (xx.nrr_id, xx.x_pd);
                    END CASE;
                WHEN 'ALG14'
                THEN
                    Check_ALG14 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG15'
                THEN
                    Check_ALG15 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG16'
                THEN
                    Check_ALG16 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG17'
                THEN
                    Check_ALG17 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG18'
                THEN
                    Check_ALG18 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG19'
                THEN
                    Check_ALG19 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG20'
                THEN
                    Check_ALG20 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG21'
                THEN
                    Check_ALG21 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG22'
                THEN
                    Check_ALG22 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG23'
                THEN
                    Check_ALG23 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG24'
                THEN
                    Check_ALG24 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG25'
                THEN
                    Check_ALG25 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG26'
                THEN
                    Check_ALG26 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG27'
                THEN
                    Check_ALG27 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG28'
                THEN
                    Check_ALG28 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG29'
                THEN
                    Check_ALG29 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG30'
                THEN
                    Check_ALG30 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG31'
                THEN
                    Check_ALG31 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG32'
                THEN
                    Check_ALG32 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG33'
                THEN
                    Check_ALG33 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG34'
                THEN
                    Check_ALG34 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG35'
                THEN
                    Check_ALG35 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG36'
                THEN
                    Check_ALG36 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG01'
                THEN
                    Check_SS_ALG01 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG02'
                THEN
                    Check_SS_ALG02 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG03'
                THEN
                    Check_SS_ALG03 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG04'
                THEN
                    Check_SS_ALG04 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG05'
                THEN
                    Check_SS_ALG05 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG06'
                THEN
                    Check_SS_ALG06 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG07'
                THEN
                    Check_SS_ALG07 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG08'
                THEN
                    Check_SS_ALG08 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG09'
                THEN
                    Check_SS_ALG09 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG10'
                THEN
                    Check_SS_ALG10 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG11'
                THEN
                    Check_SS_ALG11 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG12'
                THEN
                    Check_SS_ALG12 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG13'
                THEN
                    Check_SS_ALG13 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG14'
                THEN
                    Check_SS_ALG14 (xx.nrr_id, xx.x_pd);
                WHEN 'SS.ALG15'
                THEN
                    Check_SS_ALG15 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG40'
                THEN
                    Check_ALG40 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG41'
                THEN
                    Check_ALG41 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG42'
                THEN
                    Check_ALG42 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG43'
                THEN
                    Check_ALG43 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG44'
                THEN
                    Check_ALG44 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG45'
                THEN
                    Check_ALG45 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG46'
                THEN
                    Check_ALG46 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG47'
                THEN
                    Check_ALG47 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG48'
                THEN
                    Check_ALG48 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG49'
                THEN
                    Check_ALG49 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG50'
                THEN
                    Check_ALG50 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG51'
                THEN
                    Check_ALG51 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG52'
                THEN
                    Check_ALG52 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG53'
                THEN
                    Check_ALG53 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG54'
                THEN
                    Check_ALG54 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG55'
                THEN
                    Check_ALG55 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG56'
                THEN
                    Check_ALG56 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG57'
                THEN
                    Check_ALG57 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG58'
                THEN
                    Check_ALG58 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG59'
                THEN
                    Check_ALG59 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG60'
                THEN
                    Check_ALG60 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG61'
                THEN
                    Check_ALG61 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG62'
                THEN
                    Check_ALG62 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG63'
                THEN
                    Check_ALG63 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG64'
                THEN
                    Check_ALG64 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG65'
                THEN
                    Check_ALG65 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG66'
                THEN
                    Check_ALG66 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG67'
                THEN
                    Check_ALG67 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG68'
                THEN
                    Check_ALG68 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG69'
                THEN
                    Check_ALG69 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG70'
                THEN
                    Check_ALG70 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG71'
                THEN
                    Check_ALG71 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG72'
                THEN
                    Check_ALG72 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG73'
                THEN
                    Check_ALG73 (xx.nrr_id, xx.x_pd);
                WHEN 'ALG74'
                THEN
                    Check_ALG74 (xx.nrr_id, xx.x_pd);
                ELSE
                    Check_Other (xx.nrr_id, xx.x_pd);
            END CASE;

            l_cnt := SQL%ROWCOUNT;
        --    IF p_mode = 1 THEN --(алгоритм='||xx.nrr_alg||')
        --SELECT MAX(tel_text) INTO l_text FROM tmp_errors_list;
        --if l_text is not null Then
        --  TOOLS.add_message(l_messages, 'W', 'За правилом "'||xx.nrr_name||'" не має права в зв''язку із тим, що: '||l_text);
        --end if;
        --    ELSIF p_mode = 2 AND l_cnt > 0 THEN
        --      TOOLS.add_message(l_messages, 'W', 'За правилом "'||xx.nrr_name||'" не має права для '||l_cnt||' проектів рішень!');
        --    END IF;

        END LOOP;

        FOR m
            IN (  SELECT    'За правилом "'
                         || nrr.nrr_name
                         || '" не має права в зв''язку із тим, що: '
                         || SUBSTR (prl.prl_calc_info, 1, 3750)    AS text,
                         NVL (nrr.nrr_tp, 'E')                     AS nrr_tp
                    FROM pd_right_log prl
                         JOIN tmp_work_ids ON prl_pd = x_id
                         LEFT JOIN uss_ndi.v_ndi_right_rule nrr
                             ON nrr.nrr_id = prl_nrr
                   WHERE prl.prl_calc_info IS NOT NULL
                ORDER BY nrr.nrr_order)
        LOOP
            TOOLS.add_message (l_messages, m.nrr_tp, m.text);
        END LOOP;

        FOR xx IN (SELECT x_id FROM tmp_work_ids)
        LOOP
            API$CALC_RIGHT.write_pd_log (xx.x_id,
                                         l_hs,
                                         'R0',
                                         CHR (38) || '12',
                                         NULL);
        END LOOP;

        OPEN p_Messages FOR SELECT * FROM TABLE (l_Messages);
    END;

    --+++++++++++++++++++++
    PROCEDURE info_docum (p_app_id NUMBER)
    IS
        CURSOR doc (p_app_id NUMBER)
        IS
            SELECT apd.apd_id,
                   apd.apd_app,
                   apd.apd_ndt,
                   ndt.ndt_name_short,
                      /*'apd_app='||rpad( apd.apd_app, 4,' ')||*/
                      ' apd_ndt='
                   || RPAD (apd.apd_ndt, 6, ' ')
                   || ' '
                   || ndt.ndt_name_short    doc
              FROM ap_document  apd
                   INNER JOIN uss_ndi.v_ndi_document_type ndt
                       ON ndt.ndt_id = apd.apd_ndt
             WHERE p_app_id = apd.apd_app AND apd.history_status = 'A';

        CURSOR atr (p_apd_id NUMBER)
        IS
            WITH
                atr
                AS
                    (  SELECT apda.apda_apd,
                              apda.apda_id,
                              CASE pt_data_type
                                  WHEN 'STRING'
                                  THEN
                                      apda_val_string
                                  WHEN 'INTEGER'
                                  THEN
                                      TO_CHAR (apda_val_int)
                                  WHEN 'SUM'
                                  THEN
                                      TO_CHAR (apda_val_sum)
                                  WHEN 'ID'
                                  THEN
                                      TO_CHAR (apda_val_id)
                                  WHEN 'DATE'
                                  THEN
                                      TO_CHAR (apda_val_dt, 'dd.mm.yyyy')
                                  ELSE
                                      '???'
                              END                                AS apda_val,
                              nda.nda_id,
                              NVL (nda.nda_name, npt.pt_name)    nda_name,
                              --nda.nda_nng, (select nng.nng_name from uss_ndi.v_ndi_nda_group nng where nng.nng_id=nda.nda_nng) nng_name,
                              npt.pt_data_type
                         FROM ap_document_attr apda
                              INNER JOIN uss_ndi.v_ndi_document_attr nda
                                  ON nda.nda_id = apda.apda_nda
                              INNER JOIN uss_ndi.v_ndi_param_type npt
                                  ON npt.pt_id = nda.nda_pt
                        WHERE apda.history_status = 'A'
                     ORDER BY 1, 2)
              SELECT apda_apd,
                     LISTAGG (
                            LPAD (' ', 12, ' ')
                         || nda_id
                         || '  '
                         || nda_name
                         || ' = '
                         || apda_val,
                         CHR (13) || CHR (10))
                     WITHIN GROUP (ORDER BY apda_apd)    apda_list
                FROM atr
               WHERE apda_val IS NOT NULL AND atr.apda_apd = p_apd_id
            GROUP BY apda_apd;
    BEGIN
        FOR docum IN doc (p_app_id)
        LOOP
            DBMS_OUTPUT.put_line ('        ' || docum.doc);
            DBMS_OUTPUT.put_line ('         apd_id = ' || docum.apd_id);

            FOR a IN atr (docum.apd_id)
            LOOP
                DBMS_OUTPUT.put_line (a.apda_list);
            END LOOP;
        END LOOP;
    END;

    --+++++++++++++++++++++
    PROCEDURE dbms_output_decision_info (p_id NUMBER)
    IS
        CURSOR pd IS
            SELECT pd.pd_id,
                   pd.pd_nst,
                   a.ap_id,
                   a.ap_reg_dt,
                   a.ap_is_second
              FROM pc_decision pd JOIN appeal a ON ap_id = pd_ap
             WHERE pd_id = p_id;

        CURSOR Z (p_pd_id NUMBER)
        IS
            SELECT *
              FROM v_ap_person_for_decision
             WHERE pd_id = p_pd_id AND app_tp IN ('Z', 'O', 'ANF');

        CURSOR FP (p_pd_id NUMBER)
        IS
            SELECT *
              FROM v_ap_person_for_decision
             WHERE pd_id = p_pd_id AND app_tp IN ('FP', 'OS');

        CURSOR FM (p_pd_id NUMBER)
        IS
            SELECT *
              FROM v_ap_person_for_decision
             WHERE pd_id = p_pd_id AND app_tp = 'FM';

        CURSOR doc (p_app_id NUMBER)
        IS
            SELECT apd.apd_id,
                   apd.apd_app,
                   apd.apd_ndt,
                   ndt.ndt_name_short,
                      /*'apd_app='||rpad( apd.apd_app, 4,' ')||*/
                      ' apd_ndt='
                   || RPAD (apd.apd_ndt, 12, ' ')
                   || ' '
                   || ndt.ndt_name_short    doc
              FROM ap_document  apd
                   INNER JOIN uss_ndi.v_ndi_document_type ndt
                       ON ndt.ndt_id = apd.apd_ndt
             WHERE p_app_id = apd.apd_app AND apd.history_status = 'A';

        CURSOR atr_pd (p_pdo_id NUMBER)
        IS
            WITH
                atr
                AS
                    (  SELECT pdoa.pdoa_pdo,
                              pdoa.pdoa_id,
                              CASE pt_data_type
                                  WHEN 'STRING'
                                  THEN
                                      pdoa_val_string
                                  WHEN 'INTEGER'
                                  THEN
                                      TO_CHAR (pdoa_val_int)
                                  WHEN 'SUM'
                                  THEN
                                      TO_CHAR (pdoa_val_sum)
                                  WHEN 'ID'
                                  THEN
                                      TO_CHAR (pdoa_val_id)
                                  WHEN 'DATE'
                                  THEN
                                      TO_CHAR (pdoa_val_dt, 'dd.mm.yyyy')
                                  ELSE
                                      '???'
                              END                                AS pdoa_val,
                              nda.nda_id,
                              NVL (nda.nda_name, npt.pt_name)    nda_name,
                              --nda.nda_nng, (select nng.nng_name from uss_ndi.v_ndi_nda_group nng where nng.nng_id=nda.nda_nng) nng_name,
                              npt.pt_data_type
                         FROM pd_document_attr pdoa
                              INNER JOIN uss_ndi.v_ndi_document_attr nda
                                  ON nda.nda_id = pdoa.pdoa_nda
                              INNER JOIN uss_ndi.v_ndi_param_type npt
                                  ON npt.pt_id = nda.nda_pt
                        WHERE pdoa.history_status = 'A'
                     ORDER BY 1, 2)
              SELECT pdoa_pdo,
                     LISTAGG (
                            LPAD (' ', 12, ' ')
                         || nda_id
                         || '  '
                         || nda_name
                         || ' = '
                         || pdoa_val,
                         CHR (13) || CHR (10))
                     WITHIN GROUP (ORDER BY pdoa_pdo)    pdoa_list
                FROM atr
               WHERE pdoa_val IS NOT NULL AND atr.pdoa_pdo = p_pdo_id
            GROUP BY pdoa_pdo;
    BEGIN
        FOR d IN pd
        LOOP
            DBMS_OUTPUT.put_line (
                   '  ap_id='
                || d.ap_id
                || '  ap_reg_dt='
                || d.ap_reg_dt
                || '    ap_is_second='
                || d.ap_is_second);
            DBMS_OUTPUT.put_line ('pd_nst=' || d.pd_nst);

            FOR p IN Z (d.pd_id)
            LOOP
                DBMS_OUTPUT.put_line (
                       '    '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 8, ' ')
                    || '  sc='
                    || p.app_sc
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));
                info_docum (p.app_id);
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FP (d.pd_id)
            LOOP
                DBMS_OUTPUT.put_line ('    ' || p.app_tp || '  ' || p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 8, ' ')
                    || '  sc='
                    || p.app_sc
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));
                info_docum (p.app_id);
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FM (d.pd_id)
            LOOP
                DBMS_OUTPUT.put_line ('    ' || p.app_tp || '  ' || p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 8, ' ')
                    || '  sc='
                    || p.app_sc
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));
                info_docum (p.app_id);
            END LOOP;
        END LOOP;
    END;

    --+++++++++++++++++++++
    PROCEDURE dbms_output_appeal_info (p_id NUMBER)
    IS
        CURSOR ap IS
            SELECT *
              FROM appeal
             WHERE ap_id = p_id;

        CURSOR S (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_service
             WHERE aps_ap = p_ap_id AND history_status = 'A';

        CURSOR Z (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp IN ('Z', 'O', 'ANF')
                   AND history_status = 'A';

        CURSOR FP (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp IN ('FP', 'DU', 'OS')
                   AND history_status = 'A';

        CURSOR FM (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp NOT IN ('Z',
                                      'O',
                                      'FP',
                                      'DU',
                                      'OS')
                   AND history_status = 'A';
    --    Cursor OS(p_ap_id number) is select * from  ap_person where app_ap=p_ap_id and app_tp IN ('FP','DU') AND history_status = 'A';
    BEGIN
        FOR d IN ap
        LOOP
            DBMS_OUTPUT.put_line ('  ' || RPAD ('--', 32, '='));
            DBMS_OUTPUT.put_line ('  ' || RPAD (d.ap_tp, 32, d.ap_tp));
            DBMS_OUTPUT.put_line (
                   '  ap_id='
                || d.ap_id
                || '  ap_reg_dt='
                || d.ap_reg_dt
                || '    ap_is_second='
                || d.ap_is_second);

            FOR p IN S (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line ('    nst=' || p.aps_nst);
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN Z (d.ap_id)
            LOOP
                --dbms_output.put_line('    '||p.app_tp||'  '||p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    '
                    || p.app_tp
                    || '  app_id='
                    || RPAD (p.app_id, 8, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));
                info_docum (p.app_id);
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FP (d.ap_id)
            LOOP
                --dbms_output.put_line('    '||p.app_tp||'  '||p.app_tp||'  '||p.app_tp||'  '||p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    '
                    || p.app_tp
                    || '  app_id='
                    || RPAD (p.app_id, 8, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));
                info_docum (p.app_id);
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FM (d.ap_id)
            LOOP
                --dbms_output.put_line('    '||p.app_tp||'  '||p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    '
                    || p.app_tp
                    || '  app_id='
                    || RPAD (p.app_id, 8, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));
                info_docum (p.app_id);
            END LOOP;
        END LOOP;
    END;

    --+++++++++++++++++++++
    PROCEDURE Test_right (id NUMBER)
    IS
        p_messages   SYS_REFCURSOR;

        PROCEDURE fetch2andclose (rc IN SYS_REFCURSOR)
        IS
            msg_tp        VARCHAR2 (10);
            msg_tp_name   VARCHAR2 (20);
            msg_text      VARCHAR2 (4000);
        BEGIN
            LOOP
                FETCH rc INTO msg_tp, msg_tp_name, msg_text;

                EXIT WHEN rc%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE (
                    msg_tp || '   ' || msg_tp_name || '   ' || msg_text);
            END LOOP;

            CLOSE rc;
        END;
    BEGIN
        Is_dbms_output := TRUE;
        API$CALC_RIGHT.init_right_for_decision (1, id, p_messages);
        fetch2andclose (p_messages);
        dbms_output_decision_info (id);
        COMMIT;
    END;
--+++++++++++++++++++++
END;
/