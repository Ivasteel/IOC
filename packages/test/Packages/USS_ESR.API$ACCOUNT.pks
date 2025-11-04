/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACCOUNT
IS
    -- Author  : LESHA
    -- Created : 10.08.2022 14:09:56
    -- Purpose : Історічність персон та документів за pc_account

    --=========================================================================--
    FUNCTION get_app_start_dt (p_pd_nst     pc_decision.pd_nst%TYPE,
                               p_app        ap_person.app_id%TYPE,
                               p_app_tp     ap_person.app_tp%TYPE,
                               p_start_dt   DATE)
        RETURN DATE;

    --=========================================================================--
    FUNCTION get_app_stop_dt (p_pd_nst    pc_decision.pd_nst%TYPE,
                              p_app       ap_person.app_id%TYPE,
                              p_app_tp    ap_person.app_tp%TYPE,
                              p_stop_dt   DATE)
        RETURN DATE;

    --Отримання параметру Дата з документу по учаснику
    FUNCTION get_docx_dt (p_pd        pc_decision.pd_id%TYPE,
                          p_sc        ap_person.app_id%TYPE,
                          p_ndt       ap_document.apd_ndt%TYPE,
                          p_nda       ap_document_attr.apda_nda%TYPE,
                          p_calc_dt   DATE)
        RETURN DATE;

    --Отримання параметру Дата ( мінімальна ) з документів по зверненню
    FUNCTION get_docx_dt_min (p_pd        pc_decision.pd_id%TYPE,
                              p_sc        ap_person.app_id%TYPE,
                              p_ndt       ap_document.apd_ndt%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_calc_dt   DATE)
        RETURN DATE;

    --Отримання параметру Дата ( максимальна ) з документу по зверненню
    FUNCTION get_docx_dt_max (p_pd        pc_decision.pd_id%TYPE,
                              p_sc        ap_person.app_id%TYPE,
                              p_ndt       ap_document.apd_ndt%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_calc_dt   DATE)
        RETURN DATE;

    --Отримання параметру Дата з документу по учаснику, але дата не менша за дату звернення.
    FUNCTION get_docx_dt_not_less_ap (p_pd        pc_decision.pd_id%TYPE,
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

    FUNCTION get_docx_507_string (p_pd        pc_decision.pd_id%TYPE,
                                  p_sc        ap_person.app_id%TYPE,
                                  p_tp        VARCHAR2,
                                  p_calc_dt   DATE,
                                  p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION get_docx_507_start_dt (p_pd        pc_decision.pd_id%TYPE,
                                    p_sc        ap_person.app_id%TYPE,
                                    p_tp        VARCHAR2,
                                    p_calc_dt   DATE)
        RETURN DATE;

    --Отримання id параметру документу по учаснику
    FUNCTION get_docx_id (p_pd        pc_decision.pd_id%TYPE,
                          p_sc        ap_person.app_id%TYPE,
                          p_ndt       ap_document.apd_ndt%TYPE,
                          p_nda       ap_document_attr.apda_nda%TYPE,
                          p_calc_dt   DATE,
                          p_default   NUMBER DEFAULT NULL)
        RETURN NUMBER;

    --Отримання sum параметру документу по учаснику
    FUNCTION get_docx_sum (p_pd        pc_decision.pd_id%TYPE,
                           p_sc        ap_person.app_id%TYPE,
                           p_ndt       ap_document.apd_ndt%TYPE,
                           p_nda       ap_document_attr.apda_nda%TYPE,
                           p_calc_dt   DATE,
                           p_default   NUMBER DEFAULT NULL)
        RETURN NUMBER;

    --Отримання наявності документу
    FUNCTION get_docx_count (p_pd        pc_decision.pd_id%TYPE,
                             p_sc        ap_person.app_id%TYPE,
                             p_ndt       ap_document.apd_ndt%TYPE,
                             p_calc_dt   DATE)
        RETURN NUMBER;

    --Отримання наявності документу, з перевіркою тільки по p_calc_dt < tpd_dt_to
    --робилось для перевірки права у випадках, коли період дії документа не залежить від дати зверненя.
    FUNCTION get_docx_cnt_dt_to (p_pd        pc_decision.pd_id%TYPE,
                                 p_sc        ap_person.app_id%TYPE,
                                 p_ndt       ap_document.apd_ndt%TYPE,
                                 p_calc_dt   DATE)
        RETURN NUMBER;

    FUNCTION check_docx_exists (p_pd        pc_decision.pd_id%TYPE,
                                p_sc        ap_person.app_id%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_calc_dt   DATE)
        RETURN VARCHAR2;


    --  Функція формування історіі персон та документів звернення
    --  p_mode 1=з p_ap_id, 2=з таблиці TMP_ACCOUNT_IDS
    PROCEDURE init_tmp (p_mode INTEGER, p_pa_id pc_account.pa_id%TYPE);

    --  Функція формування історіі персон та документів звернення
    --  на підставі звернень у tmp_work_ids
    PROCEDURE init_tmp_for_pd;

    --  Функція формування історіі персон та документів звернення
    --  на підставі зверненя
    PROCEDURE init_tmp_for_pd (p_pd_id pc_decision.pd_id%TYPE);

    --  Функція формування історіі kaots
    PROCEDURE init_tmp_kaots;

    --  Функція формування окупованих kaots на дату.
    PROCEDURE init_tmp_kaots_all_TO (p_dt DATE);
END API$ACCOUNT;
/


/* Formatted on 8/12/2025 5:48:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACCOUNT
IS
    --=========================================================================--
    FUNCTION get_app_start_dt (p_pd_nst     pc_decision.pd_nst%TYPE,
                               p_app        ap_person.app_id%TYPE,
                               p_app_tp     ap_person.app_tp%TYPE,
                               p_start_dt   DATE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        /*
        SELECT  PE_APP_TP,  PE_PD_NST,  PE_TP,  PE_NDT,  PE_NDAFROM TABLE(api$anketa.Get_app_period)
        */
        SELECT NVL (MAX (apda_val_dt + p.pe_correct), p_start_dt)
          INTO l_rez
          FROM TABLE (api$anketa.Get_app_period)  p
               JOIN ap_document apd
                   ON     apd_app = p_app
                      AND apd_ndt = PE_NDT
                      AND apd.history_status = 'A'
               JOIN ap_document_attr apda
                   ON     apda_apd = apd_id
                      AND apda_nda = PE_NDA
                      AND apda.history_status = 'A'
         WHERE     p.pe_app_tp = p_app_tp
               AND PE_PD_NST = p_pd_nst
               AND PE_TP = 'START';

        RETURN l_rez;
    END;

    --=========================================================================--
    FUNCTION get_app_stop_dt (p_pd_nst    pc_decision.pd_nst%TYPE,
                              p_app       ap_person.app_id%TYPE,
                              p_app_tp    ap_person.app_tp%TYPE,
                              p_stop_dt   DATE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        /*
        SELECT  PE_APP_TP,  PE_PD_NST,  PE_TP,  PE_NDT,  PE_NDAFROM TABLE(api$anketa.Get_app_period)
        */
        SELECT NVL (MAX (apda_val_dt + p.pe_correct), p_stop_dt)
          INTO l_rez
          FROM TABLE (api$anketa.Get_app_period)  p
               JOIN ap_document apd
                   ON     apd_app = p_app
                      AND apd_ndt = PE_NDT
                      AND apd.history_status = 'A'
               JOIN ap_document_attr apda
                   ON     apda_apd = apd_id
                      AND apda_nda = PE_NDA
                      AND apda.history_status = 'A'
         WHERE     p.pe_app_tp = p_app_tp
               AND PE_PD_NST = p_pd_nst
               AND PE_TP = 'STOP';

        RETURN l_rez;
    END;

    --=========================================================================--

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
        IF p_sc IS NOT NULL
        THEN
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
        ELSE
            SELECT MAX (apda_val_dt)
              INTO l_rez
              FROM tmp_pa_documents
                   JOIN ap_document_attr
                       ON     apda_apd = tpd_apd
                          AND ap_document_attr.history_status = 'A'
             WHERE     tpd_pd = p_pd
                   AND tpd_ndt = p_ndt
                   AND apda_nda = p_nda
                   AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;
        END IF;

        RETURN l_rez;
    END;

    --Отримання параметру Дата ( мінімальна ) з документу по зверненню
    FUNCTION get_docx_dt_min (p_pd        pc_decision.pd_id%TYPE,
                              p_sc        ap_person.app_id%TYPE,
                              p_ndt       ap_document.apd_ndt%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_calc_dt   DATE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        IF p_sc IS NOT NULL
        THEN
            SELECT MIN (apda_val_dt)
              INTO l_rez
              FROM tmp_pa_documents
                   JOIN ap_document_attr
                       ON     apda_apd = tpd_apd
                          AND ap_document_attr.history_status = 'A'
             WHERE     tpd_pd = p_pd
                   AND tpd_sc = p_sc
                   AND tpd_ndt = p_ndt
                   AND apda_nda = p_nda
                   AND NVL (p_calc_dt, tpd_dt_from) BETWEEN tpd_dt_from
                                                        AND tpd_dt_to;
        ELSE
            SELECT MIN (apda_val_dt)
              INTO l_rez
              FROM tmp_pa_documents
                   JOIN ap_document_attr
                       ON     apda_apd = tpd_apd
                          AND ap_document_attr.history_status = 'A'
             WHERE     tpd_pd = p_pd
                   AND tpd_ndt = p_ndt
                   AND apda_nda = p_nda
                   AND NVL (p_calc_dt, tpd_dt_from) BETWEEN tpd_dt_from
                                                        AND tpd_dt_to;
        END IF;

        RETURN l_rez;
    END;


    --Отримання параметру Дата ( максимальна ) з документу по зверненню
    FUNCTION get_docx_dt_max (p_pd        pc_decision.pd_id%TYPE,
                              p_sc        ap_person.app_id%TYPE,
                              p_ndt       ap_document.apd_ndt%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_calc_dt   DATE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        IF p_sc IS NOT NULL
        THEN
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
                   AND NVL (p_calc_dt, tpd_dt_from) BETWEEN tpd_dt_from
                                                        AND tpd_dt_to;
        ELSE
            SELECT MAX (apda_val_dt)
              INTO l_rez
              FROM tmp_pa_documents
                   JOIN ap_document_attr
                       ON     apda_apd = tpd_apd
                          AND ap_document_attr.history_status = 'A'
             WHERE     tpd_pd = p_pd
                   AND tpd_ndt = p_ndt
                   AND apda_nda = p_nda
                   AND NVL (p_calc_dt, tpd_dt_from) BETWEEN tpd_dt_from
                                                        AND tpd_dt_to;
        END IF;

        RETURN l_rez;
    END;


    --Отримання параметру Дата з документу по учаснику, але дата не менша за дату звернення.
    FUNCTION get_docx_dt_not_less_ap (p_pd        pc_decision.pd_id%TYPE,
                                      p_sc        ap_person.app_id%TYPE,
                                      p_ndt       ap_document.apd_ndt%TYPE,
                                      p_nda       ap_document_attr.apda_nda%TYPE,
                                      p_calc_dt   DATE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        SELECT MAX (
                   CASE
                       WHEN apda_val_dt < tpd_dt_from THEN tpd_dt_from
                       ELSE apda_val_dt
                   END)
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
        IF p_sc IS NOT NULL
        THEN
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
        ELSE
            SELECT MAX (apda_val_string)
              INTO l_rez
              FROM tmp_pa_documents
                   JOIN ap_document_attr
                       ON     apda_apd = tpd_apd
                          AND ap_document_attr.history_status = 'A'
             WHERE     tpd_pd = p_pd
                   AND tpd_ndt = p_ndt
                   AND apda_nda = p_nda
                   AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;
        END IF;

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    FUNCTION get_docx_507_string (p_pd        pc_decision.pd_id%TYPE,
                                  p_sc        ap_person.app_id%TYPE,
                                  p_tp        VARCHAR2,
                                  p_calc_dt   DATE,
                                  p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (a808.apda_val_string)
          INTO l_rez
          FROM tmp_pa_documents
               JOIN ap_document_attr a802
                   ON     a802.apda_apd = tpd_apd
                      AND a802.apda_nda = 802
                      AND a802.history_status = 'A'
               JOIN ap_document_attr a808
                   ON     a808.apda_apd = tpd_apd
                      AND a808.apda_nda = 808
                      AND a808.history_status = 'A'
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = 507
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to
               AND a802.apda_val_string = p_tp;

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    FUNCTION get_docx_507_start_dt (p_pd        pc_decision.pd_id%TYPE,
                                    p_sc        ap_person.app_id%TYPE,
                                    p_tp        VARCHAR2,
                                    p_calc_dt   DATE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        SELECT MAX (tpd_dt_from)
          INTO l_rez
          FROM tmp_pa_documents
               JOIN ap_document_attr a802
                   ON     a802.apda_apd = tpd_apd
                      AND a802.apda_nda = 802
                      AND a802.history_status = 'A'
               JOIN ap_document_attr a808
                   ON     a808.apda_apd = tpd_apd
                      AND a808.apda_nda = 808
                      AND a808.history_status = 'A'
         WHERE     tpd_pd = p_pd
               AND tpd_sc = p_sc
               AND tpd_ndt = 507
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to
               AND a802.apda_val_string = p_tp;

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

    --Отримання sum параметру документу по учаснику
    FUNCTION get_docx_sum (p_pd        pc_decision.pd_id%TYPE,
                           p_sc        ap_person.app_id%TYPE,
                           p_ndt       ap_document.apd_ndt%TYPE,
                           p_nda       ap_document_attr.apda_nda%TYPE,
                           p_calc_dt   DATE,
                           p_default   NUMBER DEFAULT NULL)
        RETURN NUMBER
    IS
        l_rez   NUMBER;
    BEGIN
        SELECT MAX (apda_val_sum)
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

    --Отримання наявності документу
    FUNCTION get_docx_count (p_pd        pc_decision.pd_id%TYPE,
                             p_sc        ap_person.app_id%TYPE,
                             p_ndt       ap_document.apd_ndt%TYPE,
                             p_calc_dt   DATE)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10);
    BEGIN
        IF p_sc IS NOT NULL
        THEN
            SELECT COUNT (1)
              INTO l_rez
              FROM tmp_pa_documents
             WHERE     tpd_pd = p_pd
                   AND tpd_sc = p_sc
                   AND tpd_ndt = p_ndt
                   AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;
        ELSE
            SELECT COUNT (1)
              INTO l_rez
              FROM tmp_pa_documents
             WHERE     tpd_pd = p_pd
                   AND tpd_ndt = p_ndt
                   AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;
        END IF;

        RETURN l_rez;
    END;

    --Отримання наявності документу, з перевіркою тільки по p_calc_dt < tpd_dt_to
    --робилось для перевірки права у випадках, коли період дії документа не залежить від дати зверненя.
    FUNCTION get_docx_cnt_dt_to (p_pd        pc_decision.pd_id%TYPE,
                                 p_sc        ap_person.app_id%TYPE,
                                 p_ndt       ap_document.apd_ndt%TYPE,
                                 p_calc_dt   DATE)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10);
    BEGIN
        IF p_sc IS NOT NULL
        THEN
            SELECT COUNT (1)
              INTO l_rez
              FROM tmp_pa_documents
             WHERE     tpd_pd = p_pd
                   AND tpd_sc = p_sc
                   AND tpd_ndt = p_ndt
                   AND p_calc_dt < tpd_dt_to;
        ELSE
            SELECT COUNT (1)
              INTO l_rez
              FROM tmp_pa_documents
             WHERE     tpd_pd = p_pd
                   AND tpd_ndt = p_ndt
                   AND p_calc_dt < tpd_dt_to;
        END IF;

        RETURN l_rez;
    END;

    FUNCTION check_docx_exists (p_pd        pc_decision.pd_id%TYPE,
                                p_sc        ap_person.app_id%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_calc_dt   DATE)
        RETURN VARCHAR2
    IS
        l_cnt_doc   NUMBER (10);
    BEGIN
        IF get_docx_count (p_pd,
                           p_sc,
                           p_ndt,
                           p_calc_dt) > 0
        THEN
            RETURN 'T';
        END IF;

        RETURN 'F';
    END;

    --=========================================================
    PROCEDURE Init_tmp_account_ids_for_pd
    IS
    BEGIN
        DELETE FROM tmp_account_ids
              WHERE 1 = 1;

        INSERT INTO tmp_account_ids (x_id)
            SELECT DISTINCT pd_pa
              FROM pc_decision JOIN tmp_work_ids ON pd_id = x_id;
    END;

    --=========================================================

    --  Функція формування історіі персон та документів звернення
    --  p_mode 1=з p_ap_id, 2=з таблиці TMP_ACCOUNT_IDS
    PROCEDURE init_tmp (p_mode INTEGER, p_pa_id pc_account.pa_id%TYPE)
    IS
        l_cnt   NUMBER;
        f       tmp_pa_persons_first%ROWTYPE;
    BEGIN
        IF p_mode = 1 AND p_pa_id IS NOT NULL
        THEN
            DELETE FROM tmp_account_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_account_ids (x_id)
                 VALUES (p_pa_id);

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_account_ids, pc_account
             WHERE x_id = pa_id;
        END IF;

        DELETE FROM tmp_pa_persons_first
              WHERE 1 = 1;

        DELETE FROM tmp_pa_persons
              WHERE 1 = 1;

        DELETE FROM tmp_pa_documents
              WHERE 1 = 1;

        INSERT INTO tmp_pa_persons_first (tppf_pa,
                                          tppf_pd,
                                          tppf_app_tp,
                                          tppf_sc,
                                          tppf_ch_fm,
                                          tppf_dt_from,
                                          tppf_dt_to)
            WITH
                nxt
                AS
                    (SELECT DISTINCT
                            pd_pa,
                            pd_id,
                            pd_nst,
                            app.app_id,
                            app.app_tp,
                            app.app_sc,
                            /*CASE
                            WHEN API$ACCOUNT.get_app_stop_dt ( pd_nst, app_id, app_tp, to_date('01.01.3000','dd.mm.yyyy') ) = to_date('01.01.3000','dd.mm.yyyy') THEN
                              api$pc_decision.get_doc_string(app.app_id, 605,2452)
                            ELSE
                              ''
                            END AS ch_fm,*/
                            --це ознака операції з персоною
                            --BB Народження дитини, INS Включення у склад сім'ї, DEL Виключення зі складу сім'ї
                            api$pc_decision.get_doc_string (
                                app.app_id,
                                605,
                                2452)
                                AS ch_fm,
                            API$ACCOUNT.get_app_start_dt (pd_nst,
                                                          app_id,
                                                          app_tp,
                                                          ap_reg_dt)
                                AS start_dt,
                            API$ACCOUNT.get_app_stop_dt (
                                pd_nst,
                                app_id,
                                app_tp,
                                TO_DATE ('01.01.3000', 'dd.mm.yyyy'))
                                AS stop_dt
                       FROM tmp_account_ids
                            JOIN pc_decision
                                ON pd_pa = x_id AND pd_st NOT IN ('V', 'W')
                            JOIN appeal ap
                                ON ap_id IN
                                       (SELECT s.pds_ap
                                          FROM pd_source s
                                         WHERE     s.pds_pd = pd_id
                                               AND s.pds_tp = 'AP'
                                               AND s.history_status = 'A')
                            JOIN ap_person app
                                ON     app.app_ap = ap_id
                                   AND app.app_tp != 'O'
                                   AND app.history_status = 'A')
                SELECT DISTINCT
                       pd_pa,
                       pd_id,
                       app_tp,
                       app_sc,              --Це в нас по первинному зверненню
                       ''
                           AS ch_fm,
                       API$ACCOUNT.get_app_start_dt (pd_nst,
                                                     app_id,
                                                     app_tp,
                                                     ap_reg_dt)
                           AS start_dt,
                       API$ACCOUNT.get_app_stop_dt (
                           pd_nst,
                           app_id,
                           app_tp,
                           TO_DATE ('01.01.3000', 'dd.mm.yyyy'))
                           AS stop_dt
                  FROM tmp_account_ids
                       JOIN pc_decision ON pd_pa = x_id
                       JOIN appeal ap ON ap_id = pd_ap
                       JOIN ap_person app
                           ON     app_ap = ap_id
                              AND app_tp != 'O'
                              AND app.history_status = 'A'
                UNION ALL
                SELECT pd_pa,
                       pd_id,
                       app_tp,
                       app_sc,
                       ch_fm,              --Це в нас по коригуючим зверненням
                       --           start_dt,
                       --CASE ch_fm
                       --  WHEN 'DEL' THEN --start_dt
                       --    API$ACCOUNT.get_app_stop_dt ( pd_nst, app_id, app_tp, to_date('01.01.3000','dd.mm.yyyy') )
                       --  ELSE stop_dt
                       --END AS stop_dt
                       CASE
                           WHEN start_dt > stop_dt THEN stop_dt
                           ELSE start_dt
                       END    AS start_dt,
                       stop_dt
                  FROM nxt
                ORDER BY 2, 4, 5;



        INSERT INTO tmp_pa_persons_first (tppf_pa,
                                          tppf_pd,
                                          tppf_app_tp,
                                          tppf_sc,
                                          tppf_ch_fm,
                                          tppf_dt_from,
                                          tppf_dt_to)
            SELECT tppf_pa,
                   tppf_pd,
                   tppf_app_tp,
                   tppf_sc,
                   'DEL'         AS tppf_ch_fm,
                   tppf_dt_from,
                   ap_reg_dt     AS tppf_dt_to
              FROM tmp_pa_persons_first
                   JOIN appeal ap
                       ON ap_id IN
                              (SELECT s.pds_ap
                                 FROM pd_source s
                                WHERE     s.pds_pd = tppf_pd
                                      AND s.pds_tp = 'AN'
                                      AND s.history_status = 'A')
                   JOIN ap_person app
                       ON     app.app_ap = ap_id
                          AND app.app_tp != 'O'
                          AND app.app_sc = tppf_sc
                          AND app.history_status = 'A'
             WHERE tppf_dt_from <= ap_reg_dt
            UNION ALL
            SELECT tppf_pa,
                   tppf_pd,
                   tppf_app_tp,
                   tppf_sc,
                   'DEL'                                           AS tppf_ch_fm,
                   tppf_dt_from,
                   api$appeal.Get_ap_Doc_Dt (ap_id, 'DP',           /*10295,*/
                                                          7260)    AS x_dt_to
              FROM tmp_pa_persons_first
                   JOIN appeal ap
                       ON ap_id IN
                              (SELECT s.pds_ap
                                 FROM pd_source s
                                WHERE     s.pds_pd = tppf_pd
                                      AND s.pds_tp = 'DP'
                                      AND s.history_status = 'A')
                   JOIN ap_person app
                       ON     app.app_ap = ap_id
                          AND app.app_tp NOT IN ('O', 'Z')
                          AND app.app_sc = tppf_sc
                          AND app.history_status = 'A';

        FOR rec IN (  SELECT DISTINCT *
                        FROM tmp_pa_persons_first
                    ORDER BY tppf_pa,
                             tppf_pd,
                             tppf_sc,
                             tppf_app_tp,
                             tppf_dt_from)
        LOOP
            IF f.tppf_pa IS NULL
            THEN
                f := rec;
                CONTINUE;
            END IF;

            IF     rec.tppf_pa = f.tppf_pa
               AND rec.tppf_pd = f.tppf_pd
               AND rec.tppf_sc = f.tppf_sc
            THEN
                IF rec.tppf_ch_fm IS NULL AND f.tppf_ch_fm IS NULL
                THEN
                    CONTINUE;
                ELSIF rec.tppf_ch_fm = 'DEL'
                THEN
                    f.tppf_dt_to := rec.tppf_dt_from;
                    f.tppf_ch_fm := rec.tppf_ch_fm;

                    INSERT INTO tmp_pa_persons (tpp_pa,
                                                tpp_pd,
                                                tpp_app_tp,
                                                tpp_sc,
                                                tpp_ch_fm,
                                                tpp_dt_from,
                                                tpp_dt_to)
                         VALUES (f.tppf_pa,
                                 f.tppf_pd,
                                 f.tppf_app_tp,
                                 f.tppf_sc,
                                 f.tppf_ch_fm,
                                 f.tppf_dt_from,
                                 f.tppf_dt_to);

                    f := NULL;
                ELSIF f.tppf_dt_to < rec.tppf_dt_from
                THEN
                    INSERT INTO tmp_pa_persons (tpp_pa,
                                                tpp_pd,
                                                tpp_app_tp,
                                                tpp_sc,
                                                tpp_ch_fm,
                                                tpp_dt_from,
                                                tpp_dt_to)
                         VALUES (f.tppf_pa,
                                 f.tppf_pd,
                                 f.tppf_app_tp,
                                 f.tppf_sc,
                                 f.tppf_ch_fm,
                                 f.tppf_dt_from,
                                 f.tppf_dt_to);

                    f := rec;
                END IF;
            ELSE
                INSERT INTO tmp_pa_persons (tpp_pa,
                                            tpp_pd,
                                            tpp_app_tp,
                                            tpp_sc,
                                            tpp_ch_fm,
                                            tpp_dt_from,
                                            tpp_dt_to)
                     VALUES (f.tppf_pa,
                             f.tppf_pd,
                             f.tppf_app_tp,
                             f.tppf_sc,
                             f.tppf_ch_fm,
                             f.tppf_dt_from,
                             f.tppf_dt_to);

                f := rec;
            END IF;
        END LOOP;

        IF f.tppf_pa IS NOT NULL
        THEN
            INSERT INTO tmp_pa_persons (tpp_pa,
                                        tpp_pd,
                                        tpp_app_tp,
                                        tpp_sc,
                                        tpp_ch_fm,
                                        tpp_dt_from,
                                        tpp_dt_to)
                 VALUES (f.tppf_pa,
                         f.tppf_pd,
                         f.tppf_app_tp,
                         f.tppf_sc,
                         f.tppf_ch_fm,
                         f.tppf_dt_from,
                         f.tppf_dt_to);
        END IF;


        -- Сформуємо дату закінчення дії запису
        MERGE INTO tmp_pa_persons
             USING (SELECT t.tpp_pd                               AS x_pd, /*t.tpp_app AS x_app,*/
                           t.tpp_sc                               x_sc,
                           tpp_dt_from                            AS x_dt_from,
                           ROW_NUMBER ()
                               OVER (PARTITION BY t.tpp_pd, t.tpp_sc
                                     ORDER BY tpp_dt_from ASC)    AS x_rn,
                           NVL (
                               (  LEAD (t.tpp_dt_from)
                                      OVER (PARTITION BY t.tpp_pd, t.tpp_sc
                                            ORDER BY tpp_dt_from ASC)
                                - 1),
                               t.tpp_dt_to)                       AS x_dt_to,
                           (CASE t.tpp_app_tp
                                WHEN 'O' THEN 'Z'
                                ELSE t.tpp_app_tp
                            END)                                  AS x_app_tp
                      FROM tmp_pa_persons t)
                ON (    tpp_pd = x_pd
                    AND tpp_sc = x_sc
                    AND tpp_dt_from = x_dt_from)
        WHEN MATCHED
        THEN
            UPDATE SET
                tpp_rn = x_rn,
                tpp_dt_to =
                    CASE
                        WHEN tpp_dt_to > x_dt_to THEN x_dt_to
                        ELSE tpp_dt_to
                    END                                                    --,
                       --tpp_sc = x_sc
                       --tpp_app_tp = x_app_tp
                       ;

        -- Видалимо фіктивний діапазн для "Виключення зі складу сім'ї"
        --    DELETE tmp_pa_persons tpp WHERE tpp_ch_fm = 'DEL';

        --      raise_application_error(-20000, 'sql%ROWCOUNT='||sql%ROWCOUNT);

        INSERT INTO tmp_pa_documents (tpd_pa,
                                      tpd_ap,
                                      tpd_pd,
                                      tpd_app_tp,
                                      tpd_sc,
                                      tpd_apd,
                                      tpd_ndt,
                                      tpd_dt_from,
                                      tpd_dt_to,
                                      tpd_utp)
            WITH
                apd
                AS
                    (SELECT DISTINCT
                            pd_id
                                AS x_pd,
                            app.app_sc
                                AS x_sc,
                            ap_id
                                AS x_ap,
                            API$ACCOUNT.get_app_start_dt (pd_nst,
                                                          app_id,
                                                          app_tp,
                                                          ap_reg_dt)
                                AS start_dt,
                            API$ACCOUNT.get_app_stop_dt (
                                pd_nst,
                                app_id,
                                app_tp,
                                TO_DATE ('01.01.3000', 'dd.mm.yyyy'))
                                AS stop_dt,
                            --                       ap_reg_dt AS start_dt,
                            --                       to_date('01.01.3000','dd.mm.yyyy') AS stop_dt,
                            apd.apd_id,
                            apd.apd_ndt,
                            CASE apd_ndt
                                WHEN 507
                                THEN
                                    (SELECT apda.apda_val_string
                                       FROM ap_document_attr apda
                                      WHERE     apda_apd = apd_id
                                            AND apda_nda = 802
                                            AND apda.history_status = 'A')
                                ELSE
                                    '-'
                            END
                                AS x_utp
                       FROM tmp_account_ids
                            JOIN pc_decision ON pd_pa = x_id
                            JOIN appeal ap
                                ON    ap_id = pd_ap
                                   OR ap_id IN
                                          (SELECT s.pds_ap
                                             FROM pd_source s
                                            WHERE     s.pds_pd = pd_id
                                                  AND s.pds_tp = 'AP'
                                                  AND s.history_status = 'A')
                            JOIN ap_person app
                                ON     app.app_ap = ap_id
                                   AND app.history_status = 'A'
                            JOIN ap_document apd
                                ON     apd.apd_app = app_id
                                   AND apd.history_status = 'A')
              SELECT DISTINCT tpp.tpp_pa,
                              apd.x_ap,
                              tpp.tpp_pd,                     /*tpp.tpp_app,*/
                              tpp.tpp_app_tp,
                              tpp.tpp_sc,
                              apd.apd_id,
                              apd.apd_ndt,
                              --tpp.tpp_dt_from AS start_dt, --2023.02.03
                              apd.start_dt     AS start_dt,
                              --to_date('01.01.3000','dd.mm.yyyy') AS stop_dt,
                              stop_dt,
                              x_utp
                FROM tmp_pa_persons tpp
                     JOIN apd
                         ON     x_pd = tpp_pd
                            AND x_sc = tpp_sc
                            AND (   apd_ndt != 605
                                 OR (    apd_ndt = 605
                                     AND tpp.tpp_rn = 1
                                     AND tpp.tpp_dt_from = apd.start_dt) --2023.02.03
                                                                        )
            ORDER BY 2, 3, 6;

        UPDATE tmp_pa_documents
           SET tpd_dt_from =
                   CASE
                       WHEN tpd_ndt = 200
                       THEN
                           (SELECT NVL (apda_val_dt, tpd_dt_from)
                              FROM ap_document_attr apda
                             WHERE     apda_apd = tpd_apd
                                   AND apda_nda = 792
                                   AND apda.history_status = 'A')
                       WHEN tpd_ndt = 201
                       THEN
                           (SELECT NVL (apda_val_dt, tpd_dt_from)
                              FROM ap_document_attr apda
                             WHERE     apda_apd = tpd_apd
                                   AND apda_nda = 352
                                   AND apda.history_status = 'A')
                       ELSE
                           tpd_dt_from
                   END
         WHERE     tpd_ndt IN (200, 201)
               AND NOT EXISTS
                       (SELECT 1
                          FROM pc_account
                         WHERE pa_id = tpd_pa AND pa_nst = 664);

        UPDATE tmp_pa_documents
           SET tpd_dt_from =
                   CASE
                       WHEN tpd_ndt = 10205
                       THEN
                           (SELECT NVL (apda_val_dt, tpd_dt_from)
                              FROM ap_document_attr apda
                             WHERE     apda_apd = tpd_apd
                                   AND apda_nda = 2688
                                   AND apda.history_status = 'A')
                       ELSE
                           tpd_dt_from
                   END
         WHERE     tpd_ndt IN (10205)
               AND EXISTS
                       (SELECT 1
                          FROM pc_account
                         WHERE pa_id = tpd_pa AND pa_nst = 901);

        /*
                 apd_ndt=507    Довідка про доходи
                 apd_id = 249601
                    799  Дата видачі документа = 04.07.2024
        */
        UPDATE tmp_pa_documents
           SET tpd_dt_from =
                   CASE
                       WHEN tpd_ndt = 507
                       THEN
                           (SELECT TRUNC (NVL (apda_val_dt, tpd_dt_from),
                                          'MM')
                              FROM ap_document_attr apda
                             WHERE     apda_apd = tpd_apd
                                   AND apda_nda = 799
                                   AND apda.history_status = 'A')
                       ELSE
                           tpd_dt_from
                   END
         WHERE tpd_ndt IN (507);


        UPDATE tmp_pa_documents
           SET tpd_dt_from =
                   CASE
                       WHEN tpd_ndt = 661
                       THEN
                           (SELECT NVL (apda_val_dt, tpd_dt_from)
                              FROM ap_document_attr apda
                             WHERE     apda_apd = tpd_apd
                                   AND apda_nda = 2666
                                   AND apda.history_status = 'A')
                       WHEN tpd_ndt = 662
                       THEN
                           (SELECT NVL (apda_val_dt, tpd_dt_from)
                              FROM ap_document_attr apda
                             WHERE     apda_apd = tpd_apd
                                   AND apda_nda = 2667
                                   AND apda.history_status = 'A')
                       ELSE
                           tpd_dt_from
                   END
         WHERE tpd_ndt IN (661, 662);

        UPDATE tmp_pa_documents
           SET tpd_dt_from =
                   CASE
                       WHEN tpd_ndt = 10323
                       THEN
                           (SELECT NVL (apda_val_dt, tpd_dt_from)
                              FROM ap_document_attr apda
                             WHERE     apda_apd = tpd_apd
                                   AND apda_nda = 8522
                                   AND apda.history_status = 'A')
                       ELSE
                           tpd_dt_from
                   END
         WHERE tpd_ndt IN (10323);

        -- Set_app_period( 'Z', 1201, 'START', 10323, 8522); --Дата початку
        -- Set_app_period( 'Z', 1201, 'STOP',  10323, 8523); --Дата завершеня


        /*
            SELECT  tpp.tpp_pa, tpp.tpp_pd, tpp.tpp_app_tp, tpp.tpp_sc, apd.apd_id, apd.apd_ndt,
                    tpp.tpp_dt_from AS start_dt,
                    to_date('01.01.3000','dd.mm.yyyy') AS stop_dt
            FROM tmp_pa_persons tpp
                 JOIN apd ON x_pd = tpp_pd AND x_sc = tpp_sc
                             AND (apd_ndt != 605 OR (apd_ndt = 605 AND tpp.tpp_rn = 1))
            ORDER BY 2, 3, 6;
        */
        /*
            -- Сформуємо дату закінчення дії запису
              MERGE INTO tmp_pa_documents
              USING ( SELECT distinct t.tpd_pd AS x_pd, t.tpd_sc x_sc, t.tpd_apd x_apd,
                             t.tpd_dt_from as x_dt_from,
                             NVL( (LEAD(t.tpd_dt_from) OVER (PARTITION BY t.tpd_pd, t.tpd_sc, t.tpd_ndt ORDER BY tpd_dt_from ASC)-1), t.tpd_dt_to) AS x_dt_to
                      FROM tmp_pa_documents t
                    )
                ON (tpd_pd = x_pd AND tpd_sc = x_sc AND tpd_apd = x_apd and tpd_dt_from = x_dt_from)
              WHEN MATCHED THEN
                UPDATE SET tpd_dt_to = x_dt_to ;
        */
        -- Сформуємо дату закінчення дії запису
        MERGE INTO tmp_pa_documents
             USING (SELECT DISTINCT t.tpd_pd            AS x_pd,
                                    t.tpd_sc            x_sc,
                                    t.tpd_apd           x_apd,
                                    t.tpd_ap            AS x_tpd_ap,
                                    t.tpd_utp           AS x_utp,
                                    t.tpd_dt_from       AS x_dt_from,
                                    NVL (
                                        (  LEAD (t.tpd_dt_from)
                                               OVER (
                                                   PARTITION BY t.tpd_pd,
                                                                t.tpd_sc,
                                                                t.tpd_ndt,
                                                                tpd_utp
                                                   ORDER BY tpd_dt_from ASC)
                                         - 1),
                                        t.tpd_dt_to)    AS x_dt_to
                      FROM tmp_pa_documents t)
                --ON (tpd_pd = x_pd AND tpd_sc = x_sc AND tpd_apd = x_apd and tpd_dt_from = x_dt_from  AND tpd_ap != x_tpd_ap)
                ON (    tpd_pd = x_pd
                    AND tpd_sc = x_sc
                    AND tpd_apd = x_apd
                    AND tpd_dt_from = x_dt_from
                    AND tpd_utp = x_utp)
        WHEN MATCHED
        THEN
            UPDATE SET tpd_dt_to = x_dt_to;
    END;

    PROCEDURE init_tmp_for_pd
    IS
    BEGIN
        Init_tmp_account_ids_for_pd;
        init_tmp (2, NULL);
    END;

    PROCEDURE init_tmp_for_pd (p_pd_id pc_decision.pd_id%TYPE)
    IS
    BEGIN
        DELETE FROM tmp_account_ids
              WHERE 1 = 1;

        INSERT INTO tmp_account_ids (x_id)
            SELECT DISTINCT pd_pa
              FROM pc_decision
             WHERE pd_id = p_pd_id;

        init_tmp (2, NULL);
    END;


    --  Функція формування історіі kaots
    PROCEDURE init_tmp_kaots
    IS
    BEGIN
        DELETE FROM tmp_kaots
              WHERE 1 = 1;

        DELETE FROM tmp_work_ids1
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids1 (x_id)
            SELECT DISTINCT apda_val_id
              FROM tmp_work_ids
                   JOIN pc_decision d ON d.pd_id = x_id
                   JOIN ap_document_attr
                       ON     apda_ap = d.pd_ap
                          AND apda_nda IN (1775, 2292)
                          AND ap_document_attr.history_status = 'A'
            UNION
            SELECT DISTINCT apda_val_id
              FROM tmp_work_ids
                   JOIN pc_decision d ON d.pd_id = x_id
                   JOIN pd_source s ON s.pds_pd = x_id
                   JOIN ap_document_attr
                       ON     apda_ap = s.pds_ap
                          AND apda_nda IN (1775, 2292)
                          AND ap_document_attr.history_status = 'A';

        /*
            SELECT DISTINCT apda.apda_val_id
            FROM tmp_work_ids
                 JOIN pc_decision d  ON d.pd_id = x_id
                 JOIN ap_document_attr apda ON ( apda_ap = d.pd_ap OR apda_ap IN (SELECT s.pds_ap FROM pd_source s WHERE s.pds_pd = x_id))
                                               AND apda.apda_nda IN (1775, 2292) AND apda.history_status = 'A';*/


        INSERT INTO TMP_KAOTS (TKS_ID,
                               TKS_KAOT,
                               TKS_KAOT_INIT,
                               TKS_TP,
                               TKS_START_DT,
                               TKS_STOP_DT)
            WITH
                kaots_prev_next
                AS
                    (SELECT kaots_id,
                            kaots_kaot,
                            kaot_id,
                            kaots_tp,
                            kaots_start_dt,
                            kaots_stop_dt,
                            LAG (kaots_stop_dt)
                                OVER (PARTITION BY kaots_kaot, kaots_tp
                                      ORDER BY kaots_start_dt ASC)
                                PREV_stop_dt,
                            LEAD (kaots_id)
                                OVER (PARTITION BY kaots_kaot, kaots_tp
                                      ORDER BY kaots_start_dt ASC)
                                NEXT_id,
                            LEAD (kaots_start_dt)
                                OVER (PARTITION BY kaots_kaot, kaots_tp
                                      ORDER BY kaots_start_dt ASC)
                                NEXT_start_dt
                       FROM tmp_work_ids1
                            JOIN uss_ndi.v_NDI_KATOTTG
                                ON kaot_id = x_id AND kaot_st = 'A'
                            JOIN uss_ndi.v_NDI_KAOT_STATE
                                ON    (kaots_kaot = kaot_id AND kaot_TP = 'K')
                                   OR (    kaot_id = kaot_kaot_l3
                                       AND kaots_kaot = kaot_kaot_l3)
                                   OR (    kaot_id = kaot_kaot_l4
                                       AND (   kaots_kaot = kaot_kaot_l3
                                            OR kaots_kaot = kaot_kaot_l4))
                                   OR (    kaot_id = kaot_kaot_l5
                                       AND (   kaots_kaot = kaot_kaot_l3
                                            OR kaots_kaot = kaot_kaot_l4
                                            OR kaots_kaot = kaot_kaot_l5))
                      WHERE     history_status = 'A'
                            AND kaots_tp IN ('TO', 'PMO', 'BD')),
                kaots_start
                AS
                    (SELECT S.kaots_id,
                            S.kaots_kaot,
                            s.kaot_id,
                            kaots_tp,
                            S.kaots_start_dt,
                            S.kaots_stop_dt
                       FROM kaots_prev_next s
                      WHERE    PREV_stop_dt IS NULL
                            OR S.kaots_start_dt != PREV_stop_dt + 1),
                kaots_history
                AS
                    (SELECT S.kaots_id,
                            S.kaots_kaot,
                            s.kaot_id,
                            S.kaots_start_dt,
                            S.kaots_stop_dt,
                            CASE
                                WHEN S.kaots_stop_dt + 1 = next_start_dt
                                THEN
                                    NEXT_id
                            END    AS NEXT_id
                       FROM kaots_prev_next s)
            SELECT S.kaots_id,
                   S.kaots_kaot,
                   s.kaot_id,
                   kaots_tp,
                   S.kaots_start_dt,                        -- S.kaots_stop_dt
                   (    SELECT MAX (
                                   NVL (kaots_stop_dt,
                                        TO_DATE ('01.01.3000', 'dd.mm.yyyy')))
                          FROM kaots_history nkh
                    START WITH nkh.kaots_id = s.kaots_id
                    CONNECT BY PRIOR nkh.NEXT_id = nkh.kaots_id)    AS kaots_stop_dt
              FROM kaots_prev_next s
             WHERE    PREV_stop_dt IS NULL
                   OR S.kaots_start_dt != PREV_stop_dt + 1;
    END;

    --  Функція формування окупованих kaots на дату.
    PROCEDURE init_tmp_kaots_all_TO (p_dt DATE)
    IS
    BEGIN
        DELETE FROM tmp_kaots
              WHERE 1 = 1;

        INSERT INTO TMP_KAOTS (TKS_ID,
                               TKS_KAOT,
                               TKS_KAOT_INIT,
                               TKS_TP,
                               TKS_START_DT,
                               TKS_STOP_DT)
            WITH
                kaots_prev_next
                AS
                    (SELECT kaots_id,
                            kaots_kaot,
                            kaot_id,
                            kaots_tp,
                            kaots_start_dt,
                            kaots_stop_dt,
                            kaot_name,
                            LAG (kaots_stop_dt)
                                OVER (PARTITION BY kaots_kaot, kaots_tp
                                      ORDER BY kaots_start_dt ASC)
                                PREV_stop_dt,
                            LEAD (kaots_id)
                                OVER (PARTITION BY kaots_kaot, kaots_tp
                                      ORDER BY kaots_start_dt ASC)
                                NEXT_id,
                            LEAD (kaots_start_dt)
                                OVER (PARTITION BY kaots_kaot, kaots_tp
                                      ORDER BY kaots_start_dt ASC)
                                NEXT_start_dt
                       FROM uss_ndi.v_NDI_KATOTTG
                            JOIN uss_ndi.v_NDI_KAOT_STATE
                                ON    (kaots_kaot = kaot_id AND kaot_TP = 'K')
                                   OR (    kaot_id = kaot_kaot_l3
                                       AND kaots_kaot = kaot_kaot_l3)
                                   OR (    kaot_id = kaot_kaot_l4
                                       AND (   kaots_kaot = kaot_kaot_l3
                                            OR kaots_kaot = kaot_kaot_l4))
                                   OR (    kaot_id = kaot_kaot_l5
                                       AND (   kaots_kaot = kaot_kaot_l3
                                            OR kaots_kaot = kaot_kaot_l4
                                            OR kaots_kaot = kaot_kaot_l5))
                      WHERE     history_status = 'A'
                            AND kaot_st = 'A'
                            AND kaots_tp = 'TO'),
                kaots_start
                AS
                    (SELECT S.kaots_id,
                            S.kaots_kaot,
                            s.kaot_id,
                            kaots_tp,
                            S.kaots_start_dt,
                            S.kaots_stop_dt,
                            kaot_name
                       FROM kaots_prev_next s
                      WHERE    PREV_stop_dt IS NULL
                            OR S.kaots_start_dt != PREV_stop_dt + 1),
                kaots_history
                AS
                    (SELECT S.kaots_id,
                            S.kaots_kaot,
                            s.kaot_id,
                            S.kaots_start_dt,
                            S.kaots_stop_dt,
                            kaot_name,
                            CASE
                                WHEN S.kaots_stop_dt + 1 = next_start_dt
                                THEN
                                    NEXT_id
                            END    AS NEXT_id
                       FROM kaots_prev_next s),
                all_to
                AS
                    (SELECT S.kaots_id,
                            S.kaots_kaot,
                            s.kaot_id,
                            kaots_tp,
                            S.kaots_start_dt,
                            (    SELECT MAX (
                                            NVL (
                                                kaots_stop_dt,
                                                TO_DATE ('01.01.3000',
                                                         'dd.mm.yyyy')))
                                   FROM kaots_history nkh
                             START WITH nkh.kaots_id = s.kaots_id
                             CONNECT BY PRIOR nkh.NEXT_id = nkh.kaots_id)    AS kaots_stop_dt
                       FROM kaots_prev_next s
                      WHERE    PREV_stop_dt IS NULL
                            OR S.kaots_start_dt != PREV_stop_dt + 1)
            SELECT kaots_id,
                   kaots_kaot,
                   kaot_id,
                   kaots_tp,
                   kaots_start_dt,
                   kaots_stop_dt
              FROM all_to
             WHERE kaots_stop_dt > p_dt;
    END;
END API$ACCOUNT;
/