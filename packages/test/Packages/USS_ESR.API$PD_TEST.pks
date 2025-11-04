/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PD_TEST
IS
    -- Author  : VANO
    -- Created : 16.07.2021 11:09:28
    -- Purpose : Функції роботи з рішеннями про призначення

    g_save_job_messages     INTEGER := 2;

    Package_Name   CONSTANT VARCHAR2 (100) := 'API$PC_DECISION';

    TYPE r_pd_features IS RECORD
    (
        pde_id            pd_features.pde_id%TYPE,
        pde_pd            pd_features.pde_pd%TYPE,
        pde_nft           pd_features.pde_nft%TYPE,
        pde_val_int       pd_features.pde_val_int%TYPE,
        pde_val_sum       pd_features.pde_val_sum%TYPE,
        pde_val_id        pd_features.pde_val_id%TYPE,
        pde_val_dt        pd_features.pde_val_dt%TYPE,
        pde_val_string    pd_features.pde_val_string%TYPE,
        pde_pdf           pd_features.pde_pdf%TYPE,
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_pd_features IS TABLE OF r_pd_features;

    FUNCTION get_attr_date (p_doc_id NUMBER, p_nda_id NUMBER)
        RETURN DATE;

    FUNCTION get_attr_str (p_doc_id NUMBER, p_nda_id NUMBER)
        RETURN VARCHAR2;

    PROCEDURE SaveMessage (p_message IN VARCHAR2);

    PROCEDURE write_pd_log (p_pdl_pd        pd_log.pdl_pd%TYPE,
                            p_pdl_hs        pd_log.pdl_hs%TYPE,
                            p_pdl_st        pd_log.pdl_st%TYPE,
                            p_pdl_message   pd_log.pdl_message%TYPE,
                            p_pdl_st_old    pd_log.pdl_st_old%TYPE,
                            p_pdl_tp        pd_log.pdl_tp%TYPE:= 'SYS');

    PROCEDURE set_pa_stage_2 (p_pa_id    pc_account.pa_id%TYPE,
                              p_pal_hs   pa_log.pal_hs%TYPE);

    --Отримання ID параметру документу по учаснику
    FUNCTION get_doc_id (p_app   ap_document.apd_app%TYPE,
                         p_ndt   ap_document.apd_ndt%TYPE,
                         p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN NUMBER;

    FUNCTION get_doc_id (p_app       ap_document.apd_app%TYPE,
                         p_ndt       ap_document.apd_ndt%TYPE,
                         p_nda       ap_document_attr.apda_nda%TYPE,
                         p_calc_dt   DATE)
        RETURN NUMBER;

    --Отримання текстового параметру документу по учаснику
    FUNCTION get_doc_string (p_app   ap_document.apd_app%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2;

    FUNCTION get_doc_string (p_app       ap_document.apd_app%TYPE,
                             p_ndt       ap_document.apd_ndt%TYPE,
                             p_nda       ap_document_attr.apda_nda%TYPE,
                             p_calc_dt   DATE,
                             p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --Отримання параметру Дата з документу по учаснику
    FUNCTION get_doc_dt (p_app   ap_document.apd_app%TYPE,
                         p_ndt   ap_document.apd_ndt%TYPE,
                         p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN DATE;

    FUNCTION get_doc_dt (p_app       ap_document.apd_app%TYPE,
                         p_ndt       ap_document.apd_ndt%TYPE,
                         p_nda       ap_document_attr.apda_nda%TYPE,
                         p_calc_dt   DATE)
        RETURN DATE;

    --Копирование документов из ЕСР в соцкарточку
    PROCEDURE Copy_Document2Socialcard (p_ap pc_decision.pd_ap%TYPE);

    --  Перевірка наявності документа
    FUNCTION check_documents_exists_old (p_app   ap_document.apd_app%TYPE,
                                         p_ndt   ap_document.apd_ndt%TYPE)
        RETURN VARCHAR2;

    --Отримання текстового параметру документу по Заявнику
    FUNCTION get_ap_z_doc_string (p_ap    ap_document.apd_ap%TYPE,
                                  p_ndt   ap_document.apd_ndt%TYPE,
                                  p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2;

    FUNCTION get_care_raise (p_alg VARCHAR2, p_dt DATE)
        RETURN NUMBER;

    FUNCTION get_month_start (p_dt DATE, p_mode INTEGER:= 1)
        RETURN INTEGER;

    FUNCTION get_SA_pd_start_dt (p_action_tp VARCHAR2, p_action_dt DATE)
        RETURN DATE;

    --=============================================================
    /*
      PROCEDURE decision_block(p_pd       pc_decision.pd_id%TYPE,
                               p_stop_dt  pc_decision.pd_stop_dt%TYPE,
                               p_pnp_code VARCHAR2,
                               p_ap_src   appeal.ap_id%TYPE,
                               p_hs       histsession.hs_id%TYPE
                             );
    */
    PROCEDURE decision_block (p_pd         pc_decision.pd_id%TYPE,
                              p_pnp_code   VARCHAR2,
                              p_ap_src     appeal.ap_id%TYPE,
                              p_hs         histsession.hs_id%TYPE);

    PROCEDURE decision_UnBlock (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE);

    PROCEDURE get_month_max (p_nst NUMBER, p_months OUT DATE);

    PROCEDURE activate_accrual (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE);

    PROCEDURE proces_pc_decision_by_664;

    PROCEDURE proces_pc_decision_by_appeals;

    --Функція формування проектів рішень про призначення на основі звернення
    PROCEDURE init_pc_decision_by_appeals (p_mode           INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                           p_ap_id          appeal.ap_id%TYPE,
                                           p_messages   OUT SYS_REFCURSOR);

    --Розрахунок сукупного доходу
    PROCEDURE calc_income_for_pd (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                                  p_pd_id          pc_decision.pd_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR);

    --Функція розрахунку виплат по проектам рішень на виплату
    PROCEDURE calc_pd (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                       p_pd_id          pc_decision.pd_id%TYPE,
                       p_messages   OUT SYS_REFCURSOR);

    --Для тесту розрахунку виплат по проектам рішень на виплату
    PROCEDURE Test_calc_pd (id NUMBER DEFAULT NULL);


    --Розраховуємо суму допомоги як суму прожиткового мінімуму на дату розриву
    PROCEDURE compute_by_simple_lgw;

    --Розраховуємо суму допомоги як суму різницю між сумою прожиткового мінімуму та середньоособового доходу
    PROCEDURE compute_by_diff_income_lgw;

    --Розраховуємо суму допомоги як прожитковий мінімум з коефіцієнтом на основі параметрів інвалідності
    PROCEDURE compute_by_koef_lgw;

    --Розраховуємо суму допомоги як константні суми
    PROCEDURE compute_by_const_sum;

    --Розраховуємо суму допомоги прожитковий мінімум з коефіцієнтом та надбавки аналогічно
    PROCEDURE compute_by_inv_category;

    --Розраховуємо суму допомоги як порівняння прожиткового мінімуму сім'ї та рівня забезпечення ПМ
    PROCEDURE compute_by_lgw_leveling;

    --Процедура перевірки періоду дії рішення
    PROCEDURE Check_accrual_period (p_pd_src   pc_decision%ROWTYPE,
                                    p_hs       histsession.hs_id%TYPE);

    --Процедура перерахунку реальних періодів дії рішень для кореткного врахування в нарухуваннях, при появі нових рішень по ключу (pc,nst)
    PROCEDURE recalc_pd_periods (p_pd_id   pc_decision.pd_id%TYPE,
                                 p_hs      histsession.hs_id%TYPE);

    --=============================================================================--
    -- Для "Поновлення виплати" в картці рішення
    -- Процедура перерахунку реальних періодів дії рішень для кореткного врахування в нарухуваннях, при появі нових рішень по ключу (pc,nst)
    --=============================================================================--
    PROCEDURE recalc_pd_periods (
        p_pd_id         pc_decision.pd_id%TYPE,
        p_pd_start_dt   pc_decision.pd_start_dt%TYPE,
        p_pd_stop_dt    pc_decision.pd_stop_dt%TYPE,
        p_hs            histsession.hs_id%TYPE);

    FUNCTION Parse_Features (p_pd_Features IN CLOB)
        RETURN t_pd_Features;

    PROCEDURE Save_Features (
        p_pde_id           IN     pd_features.pde_id%TYPE,
        p_pde_pd           IN     pd_features.pde_pd%TYPE,
        p_pde_nft          IN     pd_features.pde_nft%TYPE,
        p_pde_val_int      IN     pd_features.pde_val_int%TYPE,
        p_pde_val_sum      IN     pd_features.pde_val_sum%TYPE,
        p_pde_val_id       IN     pd_features.pde_val_id%TYPE,
        p_pde_val_dt       IN     pd_features.pde_val_dt%TYPE,
        p_pde_val_string   IN     pd_features.pde_val_string%TYPE,
        p_pde_pdf          IN     pd_features.pde_pdf%TYPE,
        p_new_id              OUT pd_features.pde_id%TYPE);

    PROCEDURE Delete_Features (p_pde_id IN pd_features.pde_id%TYPE);

    -- Блокування рішення
    PROCEDURE decision_block (
        p_pd        pc_decision.pd_id%TYPE,
        p_stop_dt   pd_accrual_period.pdap_stop_dt%TYPE,
        p_PCB_RNP   pc_block.PCB_RNP%TYPE);

    -- Поновлення рішення після блокування
    PROCEDURE decision_Unblock (p_pd   pc_decision.pd_id%TYPE,
                                p_hs   histsession.hs_id%TYPE);
END API$PD_TEST;
/


/* Formatted on 8/12/2025 5:49:16 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PD_TEST
IS
    g_messages   TOOLS.t_messages;

    PROCEDURE SaveMessage (p_message IN VARCHAR2)
    AS
    BEGIN
        IF g_save_job_messages = 1
        THEN
            ikis_sysweb_jobs.savemessage (p_message);
        ELSIF g_save_job_messages = 2
        THEN
            TOOLS.add_message (g_messages, 'I', p_message);
            DBMS_APPLICATION_INFO.set_action (action_name => p_message);
        ELSE
            DBMS_OUTPUT.put_line (SYSTIMESTAMP || ' : ' || p_message);
        END IF;
    END;

    PROCEDURE write_pd_log (p_pdl_pd        pd_log.pdl_pd%TYPE,
                            p_pdl_hs        pd_log.pdl_hs%TYPE,
                            p_pdl_st        pd_log.pdl_st%TYPE,
                            p_pdl_message   pd_log.pdl_message%TYPE,
                            p_pdl_st_old    pd_log.pdl_st_old%TYPE,
                            p_pdl_tp        pd_log.pdl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := NVL (p_pdl_hs, TOOLS.GetHistSession);

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

    PROCEDURE write_pa_log (p_pal_pa        pa_log.pal_pa%TYPE,
                            p_pal_hs        pa_log.pal_hs%TYPE,
                            p_pal_st        pa_log.pal_st%TYPE,
                            p_pal_message   pa_log.pal_message%TYPE,
                            p_pal_st_old    pa_log.pal_st_old%TYPE,
                            p_pal_tp        pa_log.pal_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := NVL (p_pal_hs, TOOLS.GetHistSession);

        INSERT INTO pa_log (pal_id,
                            pal_pa,
                            pal_hs,
                            pal_st,
                            pal_message,
                            pal_st_old,
                            pal_tp)
             VALUES (0,
                     p_pal_pa,
                     l_hs,
                     p_pal_st,
                     p_pal_message,
                     p_pal_st_old,
                     NVL (p_pal_tp, 'SYS'));
    END;

    FUNCTION get_attr_date (p_doc_id NUMBER, p_nda_id NUMBER)
        RETURN DATE
    IS
        l_date   DATE;
    BEGIN
        SELECT aa.apda_val_dt
          INTO l_date
          FROM ap_document_attr aa
         WHERE aa.apda_apd = p_doc_id AND aa.apda_nda = p_nda_id;

        RETURN l_date;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    FUNCTION get_attr_str (p_doc_id NUMBER, p_nda_id NUMBER)
        RETURN VARCHAR2
    IS
        l_str   VARCHAR2 (4000);
    BEGIN
        SELECT aa.apda_val_string
          INTO l_str
          FROM ap_document_attr aa
         WHERE aa.apda_apd = p_doc_id AND aa.apda_nda = p_nda_id;

        RETURN l_str;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    FUNCTION gen_pa_num (p_pc_id personalcase.pc_id%TYPE)
        RETURN VARCHAR2
    IS
        l_cnt   INTEGER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM pc_account
         WHERE pa_pc = p_pc_id AND pa_num IS NOT NULL;

        RETURN '' || (l_cnt + 1);
    END;

    PROCEDURE set_pa_stage_2 (p_pa_id    pc_account.pa_id%TYPE,
                              p_pal_hs   pa_log.pal_hs%TYPE)
    IS
    BEGIN
        UPDATE pc_account
           SET pa_stage = '2'
         WHERE pa_id = p_pa_id AND pa_stage = 1;

        IF SQL%ROWCOUNT > 0
        THEN
            NULL;
            write_pa_log (p_pa_id,
                          p_pal_hs,
                          '2',
                          CHR (38) || '90',
                          '1');
        END IF;
    END;

    FUNCTION gen_pd_num (p_pc_id personalcase.pc_id%TYPE)
        RETURN VARCHAR2
    IS
        l_cnt      INTEGER;
        l_pc_num   personalcase.pc_num%TYPE;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM pc_decision
         WHERE     pd_pc = p_pc_id
               AND pd_dt BETWEEN TRUNC (SYSDATE, 'YYYY')
                             AND LAST_DAY (
                                     ADD_MONTHS (TRUNC (SYSDATE, 'YYYY'), 11))
               AND pd_num IS NOT NULL;

        DBMS_OUTPUT.put_line (l_cnt);

        SELECT pc_num
          INTO l_pc_num
          FROM personalcase
         WHERE pc_id = p_pc_id;

        DBMS_OUTPUT.put_line (l_pc_num);
        DBMS_OUTPUT.put_line (
               l_pc_num
            || '-'
            || TO_CHAR (SYSDATE, 'YYYY')
            || '-'
            || (l_cnt + 1));
        RETURN    l_pc_num
               || '-'
               || TO_CHAR (SYSDATE, 'YYYY')
               || '-'
               || (l_cnt + 1);
    END;

    --==============================================================--
    --  Перевірка наявності документа
    --==============================================================--
    FUNCTION check_documents_exists_old (p_app   ap_document.apd_app%TYPE,
                                         p_ndt   ap_document.apd_ndt%TYPE)
        RETURN VARCHAR2
    IS
        l_cnt_doc   NUMBER (10);
    BEGIN
        SELECT COUNT (apd.apd_id)
          INTO l_cnt_doc
          FROM uss_ndi.v_ndi_document_type  ndt
               JOIN ap_document apd
                   ON     apd.apd_ndt = ndt.ndt_id
                      AND apd.apd_app = p_app
                      AND apd.history_status = 'A'
         WHERE ndt.ndt_id = p_ndt;

        IF l_cnt_doc > 0
        THEN
            RETURN 'T';
        END IF;

        RETURN 'F';
    END;

    --Отримання ID параметру документу по учаснику
    FUNCTION get_doc_id (p_app   ap_document.apd_app%TYPE,
                         p_ndt   ap_document.apd_ndt%TYPE,
                         p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN NUMBER
    IS
        l_rez   NUMBER;
    BEGIN
        SELECT MAX (apda_val_id)
          INTO l_rez
          FROM ap_document, ap_document_attr
         WHERE     apda_apd = apd_id
               AND ap_document.history_status = 'A'
               AND apd_app = p_app
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda;

        RETURN l_rez;
    END;

    FUNCTION get_doc_id (p_app       ap_document.apd_app%TYPE,
                         p_ndt       ap_document.apd_ndt%TYPE,
                         p_nda       ap_document_attr.apda_nda%TYPE,
                         p_calc_dt   DATE)
        RETURN NUMBER
    IS
        l_rez   NUMBER;
    BEGIN
        SELECT MAX (apda_val_id)
          INTO l_rez
          FROM v_ap_document_period
               JOIN ap_document_attr
                   ON     apda_apd = apd_id
                      AND ap_document_attr.history_status = 'A'
         WHERE     tpd_app = p_app
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        RETURN l_rez;
    END;

    --Отримання текстового параметру документу по учаснику
    FUNCTION get_doc_string (p_app   ap_document.apd_app%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM ap_document, ap_document_attr
         WHERE     apda_apd = apd_id
               AND ap_document.history_status = 'A'
               AND apd_app = p_app
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda;

        RETURN l_rez;
    END;

    --Отримання текстового параметру документу по учаснику
    FUNCTION get_doc_string (p_app       ap_document.apd_app%TYPE,
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
          FROM v_ap_document_period
               JOIN ap_document_attr
                   ON     apda_apd = apd_id
                      AND ap_document_attr.history_status = 'A'
         WHERE     tpd_app = p_app
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    --Отримання параметру Дата з документу по учаснику
    FUNCTION get_doc_dt (p_app   ap_document.apd_app%TYPE,
                         p_ndt   ap_document.apd_ndt%TYPE,
                         p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        SELECT MAX (apda_val_dt)
          INTO l_rez
          FROM ap_document, ap_document_attr
         WHERE     apda_apd = apd_id
               AND ap_document.history_status = 'A'
               AND apd_app = p_app
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda;

        RETURN l_rez;
    END;

    --Отримання параметру Дата з документу по учаснику
    FUNCTION get_doc_dt (p_app       ap_document.apd_app%TYPE,
                         p_ndt       ap_document.apd_ndt%TYPE,
                         p_nda       ap_document_attr.apda_nda%TYPE,
                         p_calc_dt   DATE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        SELECT MAX (apda_val_dt)
          INTO l_rez
          FROM v_ap_document_period
               JOIN ap_document_attr ON apda_apd = apd_id
         WHERE     tpd_app = p_app
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        RETURN l_rez;
    END;

    --Отримання текстового параметру документу по Заявнику
    FUNCTION get_ap_z_doc_string (p_ap    ap_document.apd_ap%TYPE,
                                  p_ndt   ap_document.apd_ndt%TYPE,
                                  p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM ap_person, ap_document, ap_document_attr
         WHERE     ap_person.history_status = 'A'
               AND ap_document.history_status = 'A'
               AND apd_app = app_id
               AND apda_apd = apd_id
               AND app_tp = 'Z'
               AND app_ap = p_ap
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda;

        RETURN l_rez;
    END;

    FUNCTION get_ap_z_doc_string (p_ap        ap_document.apd_ap%TYPE,
                                  p_ndt       ap_document.apd_ndt%TYPE,
                                  p_nda       ap_document_attr.apda_nda%TYPE,
                                  p_calc_dt   DATE)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM ap_person, v_ap_document_period, ap_document_attr
         WHERE     ap_person.history_status = 'A'
               AND tpd_app = app_id
               AND apda_apd = apd_id
               AND app_tp = 'Z'
               AND app_ap = p_ap
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda
               AND p_calc_dt BETWEEN tpd_dt_from AND tpd_dt_to;

        RETURN l_rez;
    END;

    --Отримання відсотку надбавки
    FUNCTION get_care_raise (p_alg VARCHAR2, p_dt DATE)
        RETURN NUMBER
    IS
        l_rez   NUMBER;
    BEGIN
        SELECT MAX (ncr_percent)
          INTO l_rez
          FROM uss_ndi.v_ndi_care_raise
         WHERE     history_status = 'A'
               AND ncr_alg = p_alg
               AND p_dt >= ncr_start_dt
               AND (p_dt <= ncr_stop_dt OR ncr_stop_dt IS NULL);

        RETURN l_rez;
    END;

    FUNCTION get_SA_pd_start_dt (p_action_tp VARCHAR2, p_action_dt DATE)
        RETURN DATE
    IS
        l_dt   DATE := NULL;
    BEGIN
        l_dt :=
            CASE
                WHEN p_action_tp = 'C_NEW'
                THEN
                    ADD_MONTHS (TRUNC (p_action_dt, 'MM'), 1)
                WHEN p_action_tp = 'U_STATE'
                THEN
                    TRUNC (p_action_dt, 'MM')
            END;
        RETURN l_dt;
    END;

    --=============================================================
    --Копирование документов из ЕСР в соцкарточку
    --=============================================================
    PROCEDURE Copy_Document2Socialcard (p_ap pc_decision.pd_ap%TYPE)
    IS
        l_Doc_Attrs   Uss_Person.Api$socialcard.t_Doc_Attrs;
        l_Scd_Id      NUMBER;

        CURSOR document IS
            SELECT *
              FROM (SELECT d.Apd_Id,
                           d.Apd_Doc,
                           d.Apd_Dh,
                           d.Apd_Ndt,
                           p.App_Sc,
                           ROW_NUMBER ()
                               OVER (
                                   PARTITION BY d.Apd_App,
                                                t.Ndt_Ndc,
                                                NVL (t.Ndt_Uniq_Group,
                                                     t.Ndt_Id)
                                   ORDER BY t.Ndt_Order)    AS Rn
                      FROM Uss_Esr.Ap_Document  d
                           JOIN Uss_Esr.Ap_Person p
                               ON     d.Apd_App = p.App_Id
                                  AND p.History_Status = 'A'
                           JOIN Uss_Ndi.v_Ndi_Document_Type t
                               ON     d.Apd_Ndt = t.Ndt_Id
                                  AND t.Ndt_Copy_Esr_Signed = 'T'
                     WHERE     d.Apd_Ap = p_Ap
                           AND EXISTS
                                   (SELECT 1
                                      FROM Uss_Esr.Ap_Document_Attr  apda
                                           JOIN
                                           Uss_Ndi.v_ndi_document_attr nda
                                               ON     nda.nda_id =
                                                      apda.apda_nda
                                                  AND nda.nda_class IN
                                                          ('DSN')
                                     WHERE     apda.apda_apd = d.apd_id
                                           AND apda.apda_val_string
                                                   IS NOT NULL
                                           AND apda.history_status = 'A')
                           AND d.History_Status = 'A')
             WHERE Rn = 1;
    BEGIN
        FOR Rec IN document
        LOOP
            SELECT a.Apda_Nda,
                   a.Apda_Val_String,
                   a.Apda_Val_Dt,
                   a.Apda_Val_Int,
                   a.Apda_Val_Id
              BULK COLLECT INTO l_Doc_Attrs
              FROM Uss_Esr.Ap_Document_Attr a
             WHERE a.Apda_Apd = rec.apd_id AND a.History_Status = 'A';

            Uss_Person.Api$socialcard.Save_Document (
                p_Sc_Id         => Rec.App_Sc,
                p_Ndt_Id        => Rec.Apd_Ndt,
                p_Doc_Attrs     => l_Doc_Attrs,
                p_Src_Id        => '37',
                p_Src_Code      => 'ESR',
                p_Scd_Note      =>
                    'Створено із звернення громадянина з системи ЄІССС: ЄСР',
                p_Scd_Id        => l_Scd_Id,
                p_Doc_Id        => Rec.Apd_Doc,
                p_Dh_Id         => Rec.Apd_Dh,
                p_Set_Feature   => TRUE                       --TODO: уточнить
                                       );

            Uss_Person.Api$socialcard.Init_Sc_Info (p_Sc_Id => Rec.App_Sc);
        END LOOP;
    END;



    --=============================================================
    /*
      PROCEDURE decision_block(p_pd       pc_decision.pd_id%TYPE,
                               p_stop_dt  pc_decision.pd_stop_dt%TYPE,
                               p_pnp_code VARCHAR2,
                               p_ap_src   appeal.ap_id%TYPE,
                               p_hs       histsession.hs_id%TYPE
                             ) IS
        l_pcb pc_block.pcb_id%TYPE;
      BEGIN
        l_pcb := id_pc_block(NULL);
        INSERT INTO pc_block (pcb_id,
                              pcb_pc,
                              pcb_pd,
                              pcb_tp,
                              pcb_rnp,
                              pcb_lock_pnp_tp,
                              pcb_hs_lock,
                              pcb_ap_src)
          (
          SELECT l_pcb, pd.pd_pc, pd.pd_id, 'MR',
                 np.rnp_id, np.rnp_pnp_tp,
                 p_hs, p_ap_src
          FROM pc_decision pd
               JOIN Pd_Pay_Method pm ON pm.pdm_pd = pd.pd_id AND  pm.pdm_is_actual='T' AND pm.history_status = 'A'
               JOIN uss_ndi.V_NDI_REASON_NOT_PAY np ON np.rnp_pay_tp = pm.pdm_pay_tp
                                                       AND np.rnp_code = p_pnp_code
                                                       AND np.history_status = 'A'
          WHERE pd.pd_id = p_pd);



          UPDATE pc_decision pd SET
            pd_stop_dt        = last_day(p_stop_dt),
            pd_st             = 'PS',
            pd_suspend_reason = p_pnp_code,
            pd_ap_reason      = p_ap_src,
            pd.pd_pcb         = l_pcb
          WHERE pd.pd_id = p_pd;
          recalc_pd_periods(p_pd_id => p_pd);
      END;
      */
    --=============================================================
    -- Фукнція провірки можливості виконання дій з pc_decision на основі відповідності pc_decision.com_org & personalcase.com_org & tools.getcurrorg
    -- Відомі на поточний момент сполучення p_type:
    --1. Будь-яка дія : pc_decision.com_org = personalcase.com_org = tools.getcurrorg => OK; Свої рішення кожен ОСЗН може редагувати як хоче
    --2. Перевірка права : (tools.getcurrorg = pc_decision.com_org) != personalcase.com_org => OK; Мається на увазі, що можна створити проект рішення та перевірити право.
    --3. Затвердження : tools.getcurrorg = 50001 != (pc_decision.com_org) = personalcase.com_org) => OK; ІОЦ має право перевести рішення з "Призначено" до "Нараховано" і все
    --4. Призупинення : (tools.getcurrorg = personalcase.com_org) != pc_decision.com_org => OK; Рішення Своїх справ, навіть створених в чужих ОСЗН, користувач ОСЗН має право призупинити
    --5. Поновлення : (tools.getcurrorg = personalcase.com_org) != pc_decision.com_org => OK; Рішення Своїх справ, навіть створених в чужих ОСЗН, користувач ОСЗН має право поновити
    --=============================================================

    PROCEDURE Check_decision_comorg (p_pd_id   pc_decision.pd_id%TYPE,
                                     p_type    NUMBER)
    IS
    BEGIN
        NULL;
    END;

    --=============================================================
    PROCEDURE decision_block (p_pd         pc_decision.pd_id%TYPE,
                              p_pnp_code   VARCHAR2,
                              p_ap_src     appeal.ap_id%TYPE,
                              p_hs         histsession.hs_id%TYPE)
    IS
        l_pcb   pc_block.pcb_id%TYPE;
    BEGIN
        API$PC_BLOCK.CLEAR_BLOCK;

        INSERT INTO tmp_pc_block (b_id,
                                  b_pc,
                                  b_pd,
                                  b_tp,
                                  b_rnp,
                                  b_locl_pnp_tp,
                                  b_hs_lock,
                                  b_ap_src)
            (SELECT l_pcb,
                    pd.pd_pc,
                    pd.pd_id,
                    'PAP',
                    np.rnp_id,
                    np.rnp_pnp_tp,
                    p_hs,
                    p_ap_src
               FROM pc_decision  pd
                    JOIN Pd_Pay_Method pm
                        ON     pm.pdm_pd = pd.pd_id
                           AND pm.pdm_is_actual = 'T'
                           AND pm.history_status = 'A'
                    JOIN uss_ndi.V_NDI_REASON_NOT_PAY np
                        ON     np.rnp_pay_tp = pm.pdm_pay_tp
                           AND np.rnp_code = p_pnp_code
                           AND np.history_status = 'A'
              WHERE pd.pd_id = p_pd);

        API$PC_BLOCK.decision_block;
    /*
        l_pcb := id_pc_block(NULL);
        INSERT INTO pc_block (pcb_id,
                              pcb_pc,
                              pcb_pd,
                              pcb_tp,
                              pcb_rnp,
                              pcb_lock_pnp_tp,
                              pcb_hs_lock,
                              pcb_ap_src)
          (
          SELECT l_pcb, pd.pd_pc, pd.pd_id, 'PAP',
                 np.rnp_id, np.rnp_pnp_tp,
                 p_hs, p_ap_src
          FROM pc_decision pd
               JOIN Pd_Pay_Method pm ON pm.pdm_pd = pd.pd_id AND  pm.pdm_is_actual='T' AND pm.history_status = 'A'
               JOIN uss_ndi.V_NDI_REASON_NOT_PAY np ON np.rnp_pay_tp = pm.pdm_pay_tp
                                                       AND np.rnp_code = p_pnp_code
                                                       AND np.history_status = 'A'
          WHERE pd.pd_id = p_pd);



          UPDATE pc_decision pd SET
            pd_st             = 'PS',
            pd_suspend_reason = p_pnp_code,
            pd_ap_reason      = p_ap_src,
            pd.pd_pcb         = l_pcb
          WHERE pd.pd_id = p_pd;
      */
    END;

    --=============================================================
    PROCEDURE decision_block (
        p_pd        pc_decision.pd_id%TYPE,
        p_stop_dt   pd_accrual_period.pdap_stop_dt%TYPE,
        p_PCB_RNP   pc_block.PCB_RNP%TYPE)
    IS
        --l_pcb pc_block.pcb_id%TYPE;
        --l_pnp_code  VARCHAR2(20) := 'PC';
        l_hs         histsession.hs_id%TYPE;
        l_start_dt   pc_decision.pd_start_dt%TYPE;
        l_stop_dt    pc_decision.pd_stop_dt%TYPE;
    BEGIN
        SELECT pd.pd_start_dt, pd.pd_stop_dt
          INTO l_start_dt, l_stop_dt
          FROM pc_decision pd
         WHERE pd.pd_id = p_pd;

        IF l_start_dt > p_stop_dt
        THEN
            raise_application_error (
                -20000,
                'Дата не може бути менша за номінальний початок строку дії рішення!');
        END IF;

        IF L_stop_dt + 1 < p_stop_dt
        THEN
            raise_application_error (
                -20000,
                'Така дата не може бути більша за наступний день від закінчення номінального періоду дії рішення!');
        END IF;


        l_hs := tools.GetHistSession;

        API$PC_BLOCK.CLEAR_BLOCK;

        INSERT INTO tmp_pc_block (b_id,
                                  b_pc,
                                  b_pd,
                                  b_tp,
                                  b_rnp,
                                  b_locl_pnp_tp,
                                  b_hs_lock,
                                  b_dt)
            (SELECT 0,
                    pd.pd_pc,
                    pd.pd_id,
                    'HPD',
                    p_PCB_RNP,
                    (SELECT np.rnp_code
                       FROM uss_ndi.V_NDI_REASON_NOT_PAY np
                      WHERE np.rnp_id = p_PCB_RNP),
                    l_hs,
                    p_stop_dt
               FROM pc_decision pd
              WHERE pd.pd_id = p_pd);

        /*
              (
              SELECT 0, pd.pd_pc, pd.pd_id, 'HPD',
                     np.rnp_id, np.rnp_pnp_tp,
                     l_hs, p_stop_dt
              FROM pc_decision pd
                   JOIN Pd_Pay_Method pm ON pm.pdm_pd = pd.pd_id AND  pm.pdm_is_actual='T' AND pm.history_status = 'A'
                   JOIN uss_ndi.V_NDI_REASON_NOT_PAY np ON np.rnp_pay_tp = pm.pdm_pay_tp
                                                           AND np.rnp_code = l_pnp_code
                                                           AND np.history_status = 'A'
              WHERE pd.pd_id = p_pd);*/

        write_pd_log (
            p_pdl_pd        => p_pd,
            p_pdl_hs        => l_hs,
            p_pdl_st        => 'PS',
            p_pdl_message   =>
                CHR (38) || '119#' || TO_CHAR (p_stop_dt, 'dd.mm.yyyy'),
            p_pdl_st_old    => 'S');

        API$PC_BLOCK.decision_block;
    END;

    --=============================================================
    PROCEDURE decision_Unblock (p_pd   pc_decision.pd_id%TYPE,
                                p_hs   histsession.hs_id%TYPE)
    IS
        l_suspend_reason   VARCHAR2 (200);
    BEGIN
        l_suspend_reason :=
            tools.ggp ('CHANGE_PAYMENT_CODE_UNBLOCK', SYSDATE);

        UPDATE pc_block b
           SET b.pcb_unlock_pnp_tp =
                   (SELECT rup_id
                      FROM uss_ndi.v_ndi_reason_unlock_pay
                     WHERE rup_code = l_suspend_reason),
               b.pcb_hs_unlock = p_hs
         WHERE b.pcb_pd = p_pd;

        UPDATE pc_decision pd
           SET pd.pd_pcb = NULL, pd.pd_suspend_reason = NULL
         WHERE pd.pd_id = p_pd;

        write_pd_log (p_pdl_pd        => p_pd,
                      p_pdl_hs        => p_hs,
                      p_pdl_st        => 'S',
                      p_pdl_message   => CHR (38) || '120',
                      p_pdl_st_old    => 'PS');

        recalc_pd_periods (p_pd_id => p_pd, p_hs => p_hs);
    END;

    --=============================================================
    PROCEDURE decision_UnBlock (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE)
    IS
        l_suspend_reason   VARCHAR2 (200);
        l_hs               histsession.hs_id%TYPE;
        l_pd               pc_decision%ROWTYPE;
        l_src_dn           deduction.dn_id%TYPE;
    BEGIN
        SELECT *
          INTO l_pd
          FROM pc_decision
         WHERE pd_id = p_pd;


        l_suspend_reason :=
            tools.ggp ('CHANGE_PAYMENT_CODE_UNBLOCK', SYSDATE);
        l_hs := tools.GetHistSession;

        --    SELECT MAX(pd_nst) INTO l_nst
        --    FROM pc_decision pd
        --    WHERE pd.pd_id = p_pd;

        IF l_pd.pd_nst IS NULL
        THEN
            raise_application_error (
                -20000,
                'В функцію поновлення виплат не передано зверненнь!');
        ELSIF l_pd.pd_nst = 664
        THEN
            IF p_start_dt != TRUNC (p_start_dt, 'MM')
            THEN
                raise_application_error (
                    -20000,
                    'Початок виплат може бути тільки перше число місяця!');
            ELSIF p_stop_dt != LAST_DAY (p_stop_dt)
            THEN
                raise_application_error (
                    -20000,
                    'Закінчення виплат може бути тільки останній день місяця!');
            END IF;
        END IF;

        IF l_pd.pd_start_dt > p_stop_dt
        THEN
            raise_application_error (
                -20000,
                'Дата початку періоду не може бути менша за номінальний початок строку дії рішення!');
        END IF;

        IF l_pd.pd_stop_dt + 1 < p_stop_dt
        THEN
            raise_application_error (
                -20000,
                'Дата завершення періоду не може бути більша за наступний день від закінчення номінального періоду дії рішення!');
        END IF;

        UPDATE pc_block b
           SET b.pcb_unlock_pnp_tp =
                   (SELECT rup_id
                      FROM uss_ndi.v_ndi_reason_unlock_pay
                     WHERE rup_code = l_suspend_reason),
               b.pcb_hs_unlock = l_hs
         WHERE b.pcb_pd = p_pd;

        UPDATE pc_decision pd
           SET pd.pd_st = 'S', pd.pd_pcb = NULL, pd.pd_suspend_reason = NULL
         WHERE pd.pd_id = p_pd;

        --перерахуєм періоди, новій період створюється по (p_start_dt - p_stop_dt)
        recalc_pd_periods (l_pd.pd_id,
                           p_start_dt,
                           p_stop_dt,
                           l_hs);

        write_pd_log (
            p_pdl_pd        => l_pd.pd_id,
            p_pdl_hs        => l_hs,
            p_pdl_st        => 'S',
            p_pdl_message   =>
                   CHR (38)
                || '118#'
                || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                || '#'
                || TO_CHAR (p_stop_dt, 'dd.mm.yyyy'),
            p_pdl_st_old    => 'PS');
    END;

    --=============================================================
    /*
    Що повинна робити:
    перевіряти наявність pd_accrual_period, формувати запис в pc_accrual_queue за (період з, період по).
    Перевірка pd_accrual_period. Варіанти того, що може знайти:
    Якщо рішення в "Нараховано" (S) і є pd_accrual_period. Звірити період, що переданий в функцію з періодом дії рішення. У випадку невходження періоду-параметру в період дії рішення, повинне бути видане повідомлення:  "Вказано період, в якому частково не діє рішення. Визначте коректний період дії рішень на особовому рахунку по послузі, виконайте призупинення виплат та відновлення виплат у відповідних рішеннях";
    Якщо рішення в "Призупинено" (P) і є pd_accrual_period. Звірити період, що переданий в функцію з періодом дії рішення. У випадку невходження періоду-параметру в період дії рішення, повинне бути видане повідомлення: "Вказано період, в якому частково не діє рішення. Визначте коректний період дії рішень на особовому рахунку по послузі, виконайте призупинення виплат та відновлення виплат у відповідних рішеннях";

    Якщо ж контролі проходять, то просто створити запис в pc_accrual_queue.
    */

    PROCEDURE get_month_max (p_nst NUMBER, p_months OUT DATE)
    IS
    BEGIN
        SELECT MAX (x_month)
          INTO p_months
          FROM (SELECT DISTINCT bp_month     AS x_month
                  FROM billing_period, tmp_org
                 WHERE     bp_org = u_org
                       AND bp_class =
                           (CASE p_nst WHEN 664 THEN 'VPO' ELSE 'V' END)
                       AND bp_st = 'R');
    END;


    PROCEDURE activate_accrual (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE)
    IS
        l_hs        histsession.hs_id%TYPE;
        l_acc_cnt   NUMBER;
        l_pd        pc_decision%ROWTYPE;
        l_src_dn    deduction.dn_id%TYPE;
        l_min_dt    pd_accrual_period.pdap_start_dt%TYPE
                        := TO_DATE ('01.03.2022', 'dd.mm.yyyy');
        l_max_dt    pd_accrual_period.pdap_stop_dt%TYPE;
    BEGIN
        --Додаткові контролі
        IF p_start_dt IS NULL OR p_stop_dt IS NULL OR p_start_dt > p_stop_dt
        THEN
            raise_application_error (-20000,
                                     'Некоректно вказано період активації!');
        END IF;

        IF p_start_dt < l_min_dt
        THEN
            raise_application_error (
                -20000,
                'Не дозволяється виконувати перерахунки до 01.03.2022!');
        END IF;

        --Перевірка pd_accrual_period.
        SELECT *
          INTO l_pd
          FROM pc_decision
         WHERE pd_id = p_pd;

        -- кінець розрахунковому періоду
        get_month_max (l_pd.pd_nst, l_max_dt);
        l_max_dt := LAST_DAY (l_max_dt);

        IF p_stop_dt > l_max_dt
        THEN
            raise_application_error (
                -20000,
                   'Не дозволяється виконувати перерахунки після '
                || TO_CHAR (l_max_dt, 'dd.mm.yyyy')
                || ' !');
        END IF;


        Check_accrual_period (l_pd, l_hs);

        SELECT COUNT (1)
          INTO l_acc_cnt
          FROM pd_accrual_period
         WHERE pdap_pd = p_pd AND history_status = 'A';

        IF l_pd.pd_st = 'S' AND l_acc_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'Виявлено помилку періоду дії рішення. Визначте коректний період дії рішень на особовому рахунку по послузі, виконайте призупинення виплат та відновлення виплат у відповідних рішеннях!');
        ELSIF l_pd.pd_st = 'PS' AND l_acc_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'Призупинене рішення не діє ні одного місяця. Якщо це помилка, визначте коректний період дії рішень на особовому рахунку по послузі, виконайте призупинення виплат та відновлення виплат у відповідних рішеннях!');
        ELSIF     l_pd.pd_st IN ('S', 'PS')
              AND (   l_pd.pd_start_dt > p_start_dt
                   OR l_pd.pd_stop_dt < p_stop_dt)
        THEN
            raise_application_error (
                -20000,
                'Вказано період, в якому частково не діє рішення. Визначте коректний період дії рішень на особовому рахунку по послузі, виконайте призупинення виплат та відновлення виплат у відповідних рішеннях!');
        END IF;

        --Якщо ж контролі проходять, то просто створити запис в pc_accrual_queue.
        l_hs := tools.GetHistSession;

        IF l_pd.pd_src = 'SA'
        THEN
            SELECT MIN (dn_id)
              INTO l_src_dn
              FROM deduction
             WHERE dn_ps = l_pd.pd_ps;
        END IF;

        API$PERSONALCASE.add_pc_accrual_queue (
            l_pd.pd_pc,
            CASE l_pd.pd_src
                WHEN 'FS' THEN 'PD'
                WHEN 'PV' THEN 'PD'
                WHEN 'SA' THEN 'PS'
            END,
            p_start_dt,
            p_stop_dt,
            CASE l_pd.pd_src
                WHEN 'FS' THEN l_pd.pd_id
                WHEN 'PV' THEN l_pd.pd_id
                WHEN 'SA' THEN l_src_dn
            END);


        write_pd_log (
            p_pdl_pd        => p_pd,
            p_pdl_hs        => l_hs,
            p_pdl_st        => 'PS',
            p_pdl_message   =>
                   CHR (38)
                || '126#'
                || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                || '#'
                || TO_CHAR (p_stop_dt, 'dd.mm.yyyy'),
            p_pdl_st_old    => 'S');
    END;

    --=============================================================
    --  Перевірка, що в нас тільки один запис буде з pdm_is_actual = 'T'
    --=============================================================
    PROCEDURE Check_pd_pay_method (p_pd_id NUMBER)
    IS
        cnt   NUMBER;
    BEGIN
        UPDATE pd_pay_method
           SET pdm_is_actual = 'F'
         WHERE     pdm_is_actual = 'T'
               AND history_Status = 'A'
               AND pdm_pd = p_pd_id;

        UPDATE pd_pay_method
           SET pdm_is_actual = 'T'
         WHERE     pdm_is_actual = 'F'
               AND history_Status = 'A'
               AND pdm_pd = p_pd_id
               AND pdm_start_dt =
                   (SELECT MAX (xx.pdm_start_dt)
                      FROM pd_pay_method xx
                     WHERE xx.history_Status = 'A' AND xx.pdm_pd = p_pd_id);

        cnt := SQL%ROWCOUNT;

        IF cnt != 1
        THEN
            raise_application_error (
                -20000,
                   'Помилка маніпуляцій з історією параметрів виплати! Активних записів '
                || cnt);
        END IF;
    END;

    --=============================================================
    --  Функція автоматичного формування проектів рішень про призначення 664 на основі звернення та іх обробки.
    --=============================================================
    PROCEDURE proces_pc_decision_by_664
    IS
        l_messages   SYS_REFCURSOR;
        l_cnt        PLS_INTEGER;
    --    l_com_org  pc_decision.com_org%TYPE;
    --    l_com_wu   pc_decision.com_wu%TYPE;
    BEGIN
        --GetSecretWU(l_com_wu, l_com_org);
        -- Створемо рішення по 664
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ap_id
              FROM appeal
             WHERE     EXISTS
                           (SELECT 1
                              FROM ap_service
                             WHERE aps_ap = ap_id AND aps_nst = 664)
                   AND ap_st IN ('O')
                   AND ap_tp IN ('V', 'U', 'SS')
                   AND ROWNUM <= 500;

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt > 0
        THEN
            init_pc_decision_by_appeals (4, NULL, l_messages);
        END IF;

        -- Перевіремо право та розрахуємо

        -- Дістаємо нові звернення
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT pd_id
              FROM pc_decision
             WHERE     NOT EXISTS
                           (SELECT 1
                              FROM pd_right_log
                             WHERE prl_pd = pd_id)
                   --AND com_wu = l_com_wu
                   AND pd_nst = 664
                   AND pd_st = 'R0';

        l_cnt := SQL%ROWCOUNT;

        --Перевіремо, чи є звернення для обробки
        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        -- Перевіремо право
        api$calc_right.init_right_for_decision (p_mode       => 2,
                                                p_pd_id      => NULL,
                                                p_messages   => l_messages);
        /*
            -- Розрахуємо дохід
            api$calc_income.calc_income_for_pd(p_mode     => 2,
                                               p_pd_id    => NULL,
                                               p_messages => l_messages);
        */
        -- Розрахуємо допомогу.
        -- При розрахунку допомоги враховуються тількі зверненя, де право підтвержено
        -- Якщо права нема - то запис видаляється з tmp_work_ids
        calc_pd (p_mode => 2, p_pd_id => NULL, p_messages => l_messages);

        -- видалимо те, що не пораховано
        DELETE FROM tmp_work_ids
              WHERE NOT EXISTS
                        (SELECT 1
                           FROM pd_payment
                          WHERE pdp_pd = x_id);

        -- Чи залишилось в нас щось для подальшого розрахунку?
        SELECT COUNT (1) INTO l_cnt FROM tmp_work_ids;

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        --пройдемо ланцюжок до виплати
        FOR rec IN (SELECT x_id INTO l_cnt FROM tmp_work_ids)
        LOOP
            --Ошибки игнорируем, есть где что зависло - пусть юзверь разбирается
            BEGIN
                Dnet$pay_Assignments.APPROVE_DECISION_PAYMENTS (rec.x_id);
                Dnet$pay_Assignments.APPROVE_DECISION_PAYMENTS (rec.x_id);
            --        Dnet$pay_Assignments.APPROVE_DECISION_PAYMENTS(rec.x_id);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;
        END LOOP;
    END;

    --=============================================================
    --  Функція автоматичного формування проектів рішень про призначення на основі звернення AI та іх обробки.
    --=============================================================
    PROCEDURE proces_pc_decision_by_IA
    IS
        l_cnt         PLS_INTEGER;

        l_num         pc_decision.pd_num%TYPE;
        l_lock_init   TOOLS.t_lockhandler;
        l_lock        TOOLS.t_lockhandler;

        l_txt         VARCHAR2 (4000);
    BEGIN
        DBMS_OUTPUT.disable;

        FOR rec
            IN (SELECT ap_id
                  FROM (SELECT ap_id,
                               ROW_NUMBER ()
                                   OVER (ORDER BY ap.ap_reg_dt, ap.ap_id)    AS rn
                          FROM appeal  ap
                               JOIN ap_service s
                                   ON     s.aps_ap = ap.ap_id
                                      AND s.aps_nst IS NOT NULL
                         WHERE     ap_st IN ('O')
                               AND ap_tp IN ('IA')
                               AND ap.ap_pc IS NOT NULL/*and not exists (select p.app_ap, p.app_sc
                                                                       from ap_person p
                                                                       where p.app_ap = ap.ap_id group by p.app_ap, p.app_sc
                                                                       having count(*) > 1)*/
                                                       )
                 WHERE rn < 201)
        LOOP
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                 VALUES (rec.ap_id);

            l_lock_init :=
                TOOLS.request_lock (
                    p_descr   => 'INIT_PC_DECISION' || rec.ap_id,
                    p_error_msg   =>
                        'В даний момент вже виконується створення проектів рішень по зверненню!');

            -- ==================================================================================================================
            -- СТВОРЕННЯ ОСОБОВИХ РАХУНКЫВ
            INSERT INTO pc_account (pa_id, pa_pc, pa_nst)
                SELECT DISTINCT 0, ap_pc, s.aps_nst
                  FROM tmp_work_ids  t
                       JOIN appeal ap ON ap.ap_id = t.x_id
                       JOIN ap_service s ON s.aps_ap = ap.ap_id
                       JOIN personalcase pc ON ap.ap_pc = pc.pc_id
                 WHERE     1 = 1
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM pc_account pa
                                 WHERE     pa.pa_pc = pc_id
                                       AND pa.pa_nst = s.aps_nst);

            --if sql%rowcount = 0 then
            --  TOOLS.add_message(g_messages, 'I', 'Нових особових рахунків не створено!');
            --end if;

            -- НОМЕРА ДЛЯ PC_ACCOUNT
            FOR xx
                IN (  SELECT pa_id, pc_id, pc_num
                        FROM tmp_work_ids,
                             appeal,
                             personalcase,
                             pc_account
                       WHERE     ap_id = x_id
                             AND ap_pc = pc_id
                             AND pa_pc = pc_id
                             AND pa_num IS NULL
                    ORDER BY pa_id ASC)
            LOOP
                --ВІШАЄМО LOCK НА ГЕНЕРАЦІЮ НОМЕРА ДЛЯ PC_ACCOUNT
                l_lock :=
                    TOOLS.request_lock (
                        p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                        p_error_msg   =>
                               'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                            || xx.pc_num
                            || '!');

                l_num := gen_pa_num (xx.pc_id);

                UPDATE pc_account
                   SET pa_num = l_num
                 WHERE pa_id = xx.pa_id;

                TOOLS.release_lock (l_lock);
            --TOOLS.add_message(g_messages, 'I', 'Створено особовий рахунок № '||l_num||' для ЕОС № '||xx.pc_num||'.');
            END LOOP;

            -- ===========================================================================================================
            -- СТВОРЮЭМО РіШЕННЯ
            INSERT INTO pc_decision (pd_pc,
                                     pd_ap,
                                     pd_id,
                                     pd_pa,
                                     pd_dt,
                                     pd_st,
                                     pd_start_dt,
                                     pd_stop_dt,
                                     pd_num,
                                     pd_nst,
                                     com_org)
                SELECT pa.pa_pc,
                       ap.ap_id,
                       NULL,
                       pa.pa_id,
                       ap.ap_reg_dt,
                       'R0',
                       ap.ap_reg_dt,
                       NULL,
                       NULL,
                       s.aps_nst,
                       ap.com_org
                  FROM tmp_work_ids  t
                       JOIN appeal ap ON ap.ap_id = t.x_id
                       JOIN ap_service s ON s.aps_ap = ap.ap_id
                       JOIN ap_person app
                           ON     app.app_ap = ap.ap_id
                              AND app.history_status = 'A'
                              AND app.app_tp = 'Z'
                       LEFT JOIN ap_payment apm
                           ON     apm.apm_ap = ap.ap_id
                              AND apm.apm_app = app.app_id
                              AND apm.history_status = 'A'
                       JOIN pc_account pa
                           ON pa.pa_pc = ap.ap_pc AND pa_nst = s.aps_nst
                       LEFT JOIN pc_decision ddd
                           ON ddd.pd_ap = ap.ap_id AND ddd.pd_nst = s.aps_nst
                 WHERE ddd.pd_id IS NULL;

            l_cnt := SQL%ROWCOUNT;

            -- ФОРМИРОВАНИЕ НОМЕРА РЕШЕНИЯ
            FOR xx
                IN (SELECT *
                      FROM tmp_work_ids  t
                           JOIN appeal ap ON ap.ap_id = t.x_id
                           JOIN personalcase pc ON pc.pc_id = ap.ap_pc
                           JOIN pc_decision pd
                               ON pd.pd_ap = ap.ap_id AND pd.pd_num IS NULL
                           JOIN uss_ndi.v_ndi_service_type s
                               ON s.nst_id = pd.pd_nst)
            LOOP
                l_lock :=
                    tools.request_lock (
                        p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                        p_error_msg   =>
                               'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                            || xx.pc_num
                            || '!');

                l_num := gen_pd_num (xx.pc_id);

                UPDATE pc_decision
                   SET pd_num = l_num
                 WHERE pd_id = xx.pd_id;

                tools.release_lock (l_lock);
                --tools.add_message(g_messages, 'I', 'Створено проект рішення рахунок № '||l_num||' для ЕОС № '||xx.pc_num||' по послузі: '||xx.nst_name||'.');
                api$pc_decision.write_pd_log (
                    xx.pd_id,
                    NULL,
                    'R0',
                       CHR (38)
                    || '11#'
                    || l_num
                    || '#'
                    || xx.pc_num
                    || '#'
                    || xx.nst_name,
                    NULL);
                api$esr_action.preparewrite_visit_ap_log (
                    xx.pd_id,
                       CHR (38)
                    || '11#'
                    || l_num
                    || '#'
                    || xx.pc_num
                    || '#'
                    || xx.nst_name,
                    NULL);
            END LOOP;

            -- pd_payment
            INSERT INTO pd_payment (pdp_id,
                                    pdp_pd,
                                    pdp_npt,
                                    pdp_start_dt,
                                    pdp_stop_dt,
                                    pdp_sum)
                SELECT --+ index(t) index(ap) use_nl(t ap) index(pd) use_nl(ap pd)
                       NULL,
                       pd.pd_id,
                       NULL,
                       ap.ap_reg_dt,
                       NULL,
                       0
                  FROM tmp_work_ids  t
                       JOIN appeal ap ON ap.ap_id = t.x_id
                       JOIN pc_decision pd ON pd.pd_ap = ap.ap_id;

            -- pd_pay_method
            INSERT INTO pd_pay_method (pdm_id,
                                       pdm_pd,
                                       pdm_start_dt,
                                       pdm_stop_dt,
                                       history_status,
                                       pdm_pay_tp,
                                       pdm_account)
                SELECT --+ index(t) index(ap) use_nl(t ap) index(pd) use_nl(ap pd)
                       NULL,
                       pd.pd_id,
                       pd.pd_start_dt,
                       pd.pd_stop_dt,
                       'A',
                       'BANK',
                       apm.apm_account
                  FROM tmp_work_ids  t
                       JOIN appeal ap ON ap.ap_id = t.x_id
                       JOIN ap_person app
                           ON     app.app_ap = ap.ap_id
                              AND app.history_status = 'A'
                              AND app.app_tp = 'Z'
                       LEFT JOIN ap_payment apm
                           ON     apm.apm_ap = ap.ap_id
                              AND apm.apm_app = app.app_id
                              AND apm.history_status = 'A'
                       JOIN pc_decision pd ON pd.pd_ap = ap.ap_id;

            -- pd_family
            -- в связи с тем что заявитель может быть указан еще и участником, и при этом может быть указаны разные ДР то в цикле выбираем
            -- в приоритете дата рождения заявителя., далее по мере поступления
            FOR rec_f
                IN (  SELECT --+ index(t) index(pd) use_nl(t pd) index(app) use_nl(pd app) index(d) use_nl(app d)
                             app.app_id,
                             app.app_sc,
                             app.app_tp,
                             pd.pd_id,
                             get_attr_date (
                                 d.apd_id,
                                 CASE
                                     WHEN d.apd_ndt = 37 THEN 91
                                     WHEN d.apd_ndt = 6 THEN 606
                                     WHEN d.apd_ndt = 7 THEN 607
                                     WHEN d.apd_ndt = 8 THEN 2014
                                     WHEN d.apd_ndt = 9 THEN 2015
                                     WHEN d.apd_ndt = 13 THEN 2016
                                     ELSE -1
                                 END)    AS birth_dt
                        FROM tmp_work_ids t
                             JOIN pc_decision pd ON pd.pd_ap = t.x_id
                             JOIN ap_person app
                                 ON     app.app_ap = pd.pd_ap
                                    AND app.history_status = 'A'
                             LEFT JOIN uss_esr.ap_document d
                             JOIN uss_ndi.v_ndi_document_type dd
                                 ON dd.ndt_id = d.apd_ndt AND dd.ndt_ndc = 13
                                 ON d.apd_app = app.app_id
                    ORDER BY app.app_tp DESC, app.app_id)
            LOOP
                INSERT INTO pd_family (pdf_id,
                                       pdf_sc,
                                       pdf_pd,
                                       pdf_birth_dt)
                    SELECT NULL,
                           rec_f.app_sc,
                           rec_f.pd_id,
                           rec_f.birth_dt
                      FROM DUAL
                     WHERE NOT EXISTS
                               (SELECT 1
                                  FROM pd_family fff
                                 WHERE     fff.pdf_pd = rec_f.pd_id
                                       AND fff.pdf_sc = rec_f.app_sc);
            END LOOP;

            --IF l_cnt = 0 THEN
            --  TOOLS.add_message(g_messages, 'W', 'Проектів рішень за зверненням не знайдено, стан звернення не змінено!');
            --END IF;

            --Переводимо звернення в стан 'WD' = Опрацювання рішення, якщо хоча б одне рішення створене
            API$APPEAL.mark_appeal_working (2,
                                            1,
                                            NULL,
                                            l_cnt);

            -- feature
            FOR fr
                IN (SELECT /*+ index(t) index(ap) use_nl(t ap)
               index(s) use_nl(ap s)
               index(app) use_nl(ap app)
               index(pd) use_nl(ap pd)
               index(pdf) use_nl(pd pdf)
               index(d_605) use_nl(app d_605)
               index(d_909) use_nl(app d_909)
               index(f) use_nl(pdf f)
               index(f) use_nl(pdf f)
               index(epdf) index(epd) index(epdp) index(npt)*/
                           DISTINCT
                           vt.*,
                           RANK ()
                               OVER (PARTITION BY vt.pd_id
                                     ORDER BY vt.pdf_id, vt.app_id)
                               AS rn,
                           RANK ()
                               OVER (PARTITION BY vt.pd_id, vt.pdf_sc
                                     ORDER BY vt.app_id)
                               AS rn_sc,
                           MAX (
                               CASE
                                   WHEN    (    COALESCE (ap_is_inv, '-') =
                                                'Так'
                                            AND COALESCE (scf_is_dasabled,
                                                          '-') <>
                                                'Так')
                                        OR (    COALESCE (ap_is_pens, '-') =
                                                'Так'
                                            AND COALESCE (scf_is_pension,
                                                          '-') <>
                                                'Так')
                                        OR (    COALESCE (ap_is_alone, '-') =
                                                'Так'
                                            AND COALESCE (scf_is_alone, '-') <>
                                                'Так')
                                        OR (    COALESCE (ap_is_large, '-') =
                                                'Так'
                                            AND COALESCE (scf_is_large, '-') <>
                                                'Так')
                                        OR (    COALESCE (ap_is_poor, '-') =
                                                'Так'
                                            AND COALESCE (scf_is_poor, '-') <>
                                                'Так')
                                        OR epd.pd_id IS NOT NULL
                                   THEN
                                       1
                                   ELSE
                                       0
                               END)
                               OVER (PARTITION BY vt.pd_id)
                               AS is_error_pd,
                           FIRST_VALUE (epd.pd_st)
                               OVER (
                                   PARTITION BY vt.pd_id
                                   ORDER BY
                                       CASE
                                           WHEN epd.pd_st = 'S' THEN 1
                                           WHEN epd.pd_st = 'AM' THEN 2
                                           WHEN epd.pd_st = 'AP' THEN 3
                                           WHEN epd.pd_st = 'R1' THEN 4
                                       END,
                                       epd.pd_id)
                               AS pd_st,
                           FIRST_VALUE (npt.npt_legal_act)
                               OVER (
                                   PARTITION BY vt.pd_id
                                   ORDER BY
                                       CASE
                                           WHEN epd.pd_st = 'S' THEN 1
                                           WHEN epd.pd_st = 'AM' THEN 2
                                           WHEN epd.pd_st = 'AP' THEN 3
                                           WHEN epd.pd_st = 'R1' THEN 4
                                       END,
                                       epd.pd_id)
                               AS npt_legal_act
                      FROM (SELECT ap.ap_id,
                                   pd.pd_id,
                                   pd.pd_nst,
                                   pdf.pdf_id,
                                   pdf.pdf_sc,
                                   app.app_id,
                                   app.app_tp,
                                   NVL2 (
                                       d_605.apd_id,
                                       DECODE (
                                           get_attr_str (d_605.apd_id, 641),
                                           'T', 'Так',
                                           'F', 'Ні'),
                                       'Ні')
                                       AS ap_is_alone,        -- Одинока/одинокий  STRING  T/F
                                   NVL2 (
                                       d_605.apd_id,
                                       DECODE (
                                           get_attr_str (d_605.apd_id, 660),
                                           'T', 'Так',
                                           'F', 'Ні'),
                                       'Ні')
                                       AS ap_is_inv,        -- Особа з інвалідністю  STRING  T/F
                                   NVL2 (
                                       d_605.apd_id,
                                       DECODE (
                                           get_attr_str (d_605.apd_id, 661),
                                           'T', 'Так',
                                           'F', 'Ні'),
                                       'Ні')
                                       AS ap_is_pens,        -- Пенсіонер  STRING  T/F
                                   NVL2 (
                                       d_909.apd_id,
                                       DECODE (
                                           get_attr_str (d_909.apd_id, 2011),
                                           'T', 'Так',
                                           'F', 'Ні'),
                                       'Ні')
                                       AS ap_is_large,        -- Багатодітна сім’я  STRING  T/F
                                   NVL2 (
                                       d_909.apd_id,
                                       DECODE (
                                           get_attr_str (d_909.apd_id, 2012),
                                           'T', 'Так',
                                           'F', 'Ні'),
                                       'Ні')
                                       AS ap_is_empty,        -- Жодних вказаних вище  STRING  T/F
                                   NVL2 (
                                       d_909.apd_id,
                                       DECODE (
                                           get_attr_str (d_909.apd_id, 2013),
                                           'T', 'Так',
                                           'F', 'Ні'),
                                       'Ні')
                                       AS ap_is_poor,        -- Отримувач допомоги малозабезпеченим сім’ям  STRING  T/F
                                   get_attr_str (d_909.apd_id, 2004)
                                       AS ap_kaottg_from,
                                   get_attr_str (d_909.apd_id, 2005)
                                       AS ap_kaottg_to,
                                   CASE
                                       WHEN v_10052.vf_st = 'X' THEN 'Так'
                                       ELSE 'Ні'
                                   END
                                       AS is_vpo,
                                   DECODE (COALESCE (f.scf_is_pension, 'F'),
                                           'T', 'Так',
                                           'F', 'Ні')
                                       AS scf_is_pension,
                                   DECODE (COALESCE (f.scf_is_dasabled, 'F'),
                                           'T', 'Так',
                                           'F', 'Ні')
                                       AS scf_is_dasabled,
                                   DECODE (
                                       COALESCE (f.scf_is_singl_parent, 'F'),
                                       'T', 'Так',
                                       'F', 'Ні')
                                       AS scf_is_alone,
                                   DECODE (
                                       COALESCE (f.scf_is_large_family, 'F'),
                                       'T', 'Так',
                                       'F', 'Ні')
                                       AS scf_is_large,
                                   DECODE (
                                       COALESCE (f.scf_is_low_income, 'F'),
                                       'T', 'Так',
                                       'F', 'Ні')
                                       AS scf_is_poor
                              FROM uss_esr.tmp_work_ids  t
                                   JOIN uss_esr.appeal ap
                                       ON ap.ap_id = t.x_id
                                   JOIN uss_esr.ap_person app
                                       ON     app.app_ap = ap.ap_id
                                          AND app.history_status = 'A'
                                   JOIN uss_esr.pc_decision pd
                                       ON pd.pd_ap = ap.ap_id
                                   JOIN uss_esr.pd_family pdf
                                       ON     pdf.pdf_pd = pd.pd_id
                                          AND pdf.pdf_sc = app.app_sc
                                   LEFT JOIN uss_esr.ap_document d_605
                                       ON     d_605.apd_app = app_id
                                          AND d_605.apd_ndt = 605
                                   LEFT JOIN uss_esr.ap_document d_909
                                       ON     d_909.apd_app = app_id
                                          AND d_909.apd_ndt = 909
                                   LEFT JOIN ap_document d_10052
                                   JOIN verification v_10052
                                       ON d_10052.apd_vf = v_10052.vf_id
                                       ON     app.app_id = d_10052.apd_app
                                          AND d_10052.apd_ndt = 10052
                                          AND d_10052.history_status = 'A'
                                   LEFT JOIN uss_person.v_sc_feature f
                                       ON f.scf_sc = pdf.pdf_sc) vt
                           LEFT JOIN uss_esr.pc_decision epd
                           JOIN uss_esr.pd_family epdf
                               ON epdf.pdf_pd = epd.pd_id
                           JOIN uss_esr.pd_payment epdp
                               ON epdp.pdp_pd = epd.pd_id
                           LEFT JOIN uss_ndi.v_ndi_payment_type npt
                               ON npt.npt_id = epdp.pdp_npt
                               ON     epd.pd_nst = vt.pd_nst
                                  AND epdf.pdf_sc = vt.pdf_sc
                                  AND epd.pd_st IN ('AP',
                                                    'AM',
                                                    'S',
                                                    'R1',
                                                    'WD')
                                  AND epd.pd_id <> vt.pd_id)
            LOOP
                -- фичи учитіваются только для первого упоминания об сц в зверненни
                IF fr.rn_sc = 1
                THEN
                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 15,
                                 fr.ap_is_inv,
                                 fr.pdf_id); -- 15 Ознака інвалідності за заявою

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 17,
                                 fr.ap_is_pens,
                                 fr.pdf_id);  -- 17 Ознака пенсіонер за заявою

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 22,
                                 fr.ap_is_alone,
                                 fr.pdf_id); -- 22 Ознака Одинока/одинокий за заявою

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 23,
                                 fr.ap_is_large,
                                 fr.pdf_id); -- 23 Ознака Багатодітна сім’я за заявою

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 24,
                                 fr.ap_is_empty,
                                 fr.pdf_id); -- 24 Ознака Жодних вказаних вище за заявою

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 25,
                                 fr.ap_is_poor,
                                 fr.pdf_id); -- 25 Ознака Отримувач допомоги малозабезпеченим сім’ям за заявою

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 26,
                                 fr.ap_kaottg_from,
                                 fr.pdf_id); -- 26 Регіон з якого перміщується особа

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 27,
                                 fr.ap_kaottg_to,
                                 fr.pdf_id); -- 27 Регіон в який перміщується особа

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 28,
                                 fr.is_vpo,
                                 fr.pdf_id);                  -- 28 Ознака ВПО

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 18,
                                 fr.scf_is_pension,
                                 fr.pdf_id);      -- 18 Ознака пенсіонер в ЄСР

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 16,
                                 fr.scf_is_dasabled,
                                 fr.pdf_id);   -- 16 Ознака інвалідності в ЄСР

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 29,
                                 fr.scf_is_alone,
                                 fr.pdf_id); -- 29 Ознака одинокої мати чи батька

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 30,
                                 fr.scf_is_large,
                                 fr.pdf_id); -- 30 Ознака багатодітної сім''ї';

                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_pdf)
                         VALUES (NULL,
                                 fr.pd_id,
                                 31,
                                 fr.scf_is_poor,
                                 fr.pdf_id); -- 31 Ознака отримувача допомоги малозабезпеченим сім''ям';

                    --#80245 збереження кількості учасників звернення, заповнюємо тільки для заявника
                    IF fr.app_tp = 'Z'
                    THEN
                        INSERT INTO pd_features (pde_id,
                                                 pde_pd,
                                                 pde_nft,
                                                 pde_val_string,
                                                 pde_pdf)
                            SELECT NULL,
                                   fr.pd_id,
                                   19,
                                   TO_CHAR (
                                       COUNT (
                                           DISTINCT
                                               (COALESCE (app_sc, app_id)))),
                                   fr.pdf_id
                              FROM ap_person
                             WHERE app_ap = fr.ap_id AND history_status = 'A';
                    END IF;

                    ---------------------------------------------------------------------------------------------------------------------------
                    IF fr.is_error_pd = 1
                    THEN   -- локальніе ошибки для каждого участника обращения
                        ---------------------------------------------------------------------------------------------------------------------------
                        -- Вказані вами соціальні статуси _____статус______у заявці не відповідають інформації, що наявна у Мінсоцполітики.
                        l_txt := NULL;

                        IF     COALESCE (fr.ap_is_inv, '-') = 'Так'
                           AND COALESCE (fr.scf_is_dasabled, '-') <> 'Так'
                        THEN
                            l_txt := l_txt || ', особа з інвалідністю';
                        END IF;

                        IF     COALESCE (fr.ap_is_pens, '-') = 'Так'
                           AND COALESCE (fr.scf_is_pension, '-') <> 'Так'
                        THEN
                            l_txt := l_txt || ', пенсіонер';
                        END IF;

                        IF     COALESCE (fr.ap_is_alone, '-') = 'Так'
                           AND COALESCE (fr.scf_is_alone, '-') <> 'Так'
                        THEN
                            l_txt := l_txt || ', одинокої мати чи батька';
                        END IF;

                        IF     COALESCE (fr.ap_is_large, '-') = 'Так'
                           AND COALESCE (fr.scf_is_large, '-') <> 'Так'
                        THEN
                            l_txt := l_txt || ', багатодітної сім''ї';
                        END IF;

                        IF     COALESCE (fr.ap_is_poor, '-') = 'Так'
                           AND COALESCE (fr.scf_is_poor, '-') <> 'Так'
                        THEN
                            l_txt :=
                                   l_txt
                                || ', отримувача допомоги малозабезпеченим сім''ям';
                        END IF;

                        IF l_txt IS NOT NULL
                        THEN
                            UPDATE pc_decision t
                               SET t.pd_st = 'R1'
                             WHERE t.pd_id = fr.pd_id AND t.pd_st = 'R0';

                            l_txt := '75#' || SUBSTR (l_txt, 2, 1000); --'Вказані вами соціальні статуси '||substr(l_txt, 2, 1000)||' у заявці не відповідають інформації, що наявна у Мінсоцполітики. Вам необхідно звернутися до органів соціального захисту для актуалізації статусу. Після актуалізації статусів у вас буде можливість подати заявку знову з цими статусами.  Якщо соціальні статуси були вказані помилково натисніть “Подати виправлену заявку” та заповніть заявку.';
                            api$pc_decision.write_pd_log (fr.pd_id,
                                                          NULL,
                                                          'R1',
                                                          CHR (38) || l_txt,
                                                          'R0');
                            api$esr_action.preparewrite_visit_ap_log (
                                fr.pd_id,
                                CHR (38) || l_txt);
                        END IF;
                    END IF;
                END IF;

                ---------------------------------------------------------------------------------------------------------------------------
                IF fr.rn = 1 AND fr.is_error_pd = 1
                THEN                 --  глобальніе ошибки для всего обращения
                    ---------------------------------------------------------------------------------------------------------------------------
                    -- Інша Заявка члена вашої сім’ї знаходиться в очікуванні на виплату від міжнародної організації
                    l_txt := NULL;

                    IF fr.pd_st IN ('AM')
                    THEN
                        UPDATE pc_decision t
                           SET t.pd_st = 'V'
                         WHERE t.pd_id = fr.pd_id;

                        l_txt := '74#' || fr.npt_legal_act; -- 'Інша Заявка члена вашої сім’ї знаходиться в очікуванні на виплату від міжнародної організації.';
                        api$pc_decision.write_pd_log (fr.pd_id,
                                                      NULL,
                                                      'V',
                                                      CHR (38) || l_txt,
                                                      'R0');
                        api$esr_action.preparewrite_visit_ap_log (
                            fr.pd_id,
                            CHR (38) || l_txt);
                    END IF;

                    ------------------
                    -- Інша Заявка члена вашої сім’ї знаходиться в очікуванні на виплату від міжнародної організації
                    l_txt := NULL;

                    IF fr.pd_st IN ('AP', 'R1', 'WD')
                    THEN
                        UPDATE pc_decision t
                           SET t.pd_st = 'WD'
                         WHERE t.pd_id = fr.pd_id;

                        l_txt := '74#'; -- 'Інша Заявка члена вашої сім’ї знаходиться в очікуванні на виплату від міжнародної організації.';
                        api$pc_decision.write_pd_log (fr.pd_id,
                                                      NULL,
                                                      'WD',
                                                      CHR (38) || l_txt,
                                                      'R0');
                        api$esr_action.preparewrite_visit_ap_log (
                            fr.pd_id,
                            CHR (38) || l_txt);
                    END IF;

                    ------------------
                    -- Інша Заявка члена вашої сім’ї знаходиться в очікуванні на виплату від міжнародної організації
                    l_txt := NULL;

                    IF fr.pd_st IN ('S')
                    THEN
                        UPDATE pc_decision t
                           SET t.pd_st = 'V'
                         WHERE t.pd_id = fr.pd_id;

                        l_txt := '73#' || fr.npt_legal_act; -- 'Виплата членам вашій сім’ї вже відбулась від '
                        api$pc_decision.write_pd_log (fr.pd_id,
                                                      NULL,
                                                      'V',
                                                      CHR (38) || l_txt,
                                                      'R0');
                        api$esr_action.preparewrite_visit_ap_log (
                            fr.pd_id,
                            CHR (38) || l_txt);
                    END IF;
                ----------------------------------------------------------------------------------------------------------------------------
                ELSIF fr.rn = 1 AND fr.is_error_pd = 0
                THEN               -- переводим решение в Данні заяви прийнято
                    UPDATE pc_decision t
                       SET t.pd_st = 'AP'
                     WHERE t.pd_id = fr.pd_id;

                    l_txt := NULL;
                    l_txt := '72'; --'Ваші дані підтверджено. Заявка буде передана міжнародній організації за умови відповідності вашої соціальної категорії (статусу) до умов виплат, які визначають міжнародні організації.';
                    api$pc_decision.write_pd_log (fr.pd_id,
                                                  NULL,
                                                  'AP',
                                                  CHR (38) || l_txt,
                                                  'R0');
                    api$esr_action.preparewrite_visit_ap_log (
                        fr.pd_id,
                        CHR (38) || l_txt);
                /*UPDATE pc_decision t
                SET t.pd_st = 'AM'
                WHERE t.pd_id = fr.pd_id;

                l_txt:= Null;
                l_txt:= '76#'||'RED ROSE CPS LIMITED';
                api$pc_decision.write_pd_log(fr.pd_id, null, 'AM', chr(38)||l_txt, 'AP');
                api$esr_action.preparewrite_visit_ap_log(fr.pd_id, chr(38)||l_txt);*/
                END IF;
            END LOOP;

            TOOLS.release_lock (l_lock_init);
        END LOOP;
    END;

    --=============================================================
    --  Функція автоматичного формування проектів рішень про призначення на основі звернення та іх обробки.
    --=============================================================
    PROCEDURE proces_pc_decision_by_appeals
    IS
        l_cnt   NUMBER (10);
    BEGIN
        --#78995 2022.08.01
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        SELECT COUNT (ap_id)
          INTO l_cnt
          FROM appeal
         WHERE     EXISTS
                       (SELECT 1
                          FROM ap_service
                         WHERE     aps_ap = ap_id
                               AND aps_nst = 664
                               AND history_status = 'A')
               AND ap_st IN ('O')
               AND ap_tp IN ('V', 'U', 'SS');

        IF l_cnt > 0
        THEN
            proces_pc_decision_by_664;
        END IF;

        SELECT COUNT (ap_id)
          INTO l_cnt
          FROM appeal
         WHERE ap_st IN ('O') AND ap_tp IN ('IA');

        IF l_cnt > 0
        THEN
            proces_pc_decision_by_IA;
        END IF;
    END;

    --====================================================================================--
    --  Функція призупинення рішень про призначення на основі звернення щодо змін обставин!
    --  p_mode 1=з p_ap_id, 2=з таблиці tmp_work_ids
    --====================================================================================--
    PROCEDURE init_pc_decision_by_ap_tp_O (
        p_mode              INTEGER,
        p_ap_id             appeal.ap_id%TYPE,
        p_messages   IN OUT SYS_REFCURSOR,
        p_hs         IN     histsession.hs_id%TYPE,
        p_com_wu            pc_decision.com_wu%TYPE)
    IS
        l_cnt        INTEGER;
        pay_method   pd_pay_method%ROWTYPE;
        decision     pc_decision%ROWTYPE;
        l_pd_id      NUMBER;
        l_start_dt   DATE;
        l_stop_dt    DATE;

        -- 642 послуга
        CURSOR ap_tp_o_642 IS
            SELECT ap.ap_id,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   ap.ap_st,
                   app.app_id, --app.app_fn||' '||app.app_mn||' '||app.app_ln AS app_fio,
                   app.app_sc,
                   apda.apda_val_string     AS nst,
                   pd_id,
                   pd_num,
                   apm.apm_kaot,
                   apm.apm_nb,
                   apm.apm_tp,
                   apm.apm_index,
                   apm.apm_account,
                   apm.apm_need_account,
                   apm.history_status,
                   apm.apm_street,
                   apm.apm_ns,
                   apm.apm_building,
                   apm.apm_block,
                   apm.apm_apartment
              FROM tmp_work_ids
                   JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                   JOIN ap_service aps
                       ON     aps_ap = ap_id
                          AND aps_nst = 642
                          AND aps.history_status = 'A'
                   JOIN ap_person app
                       ON     app_ap = ap_id
                          AND app_tp = 'O'
                          AND app.history_status = 'A'
                   JOIN personalcase pc ON pc_sc = app_sc
                   JOIN ap_payment apm
                       ON apm_ap = ap_id AND app.history_status = 'A'
                   LEFT JOIN ap_document apd
                       ON     apd_ap = ap_id
                          AND apd_ndt = 10091
                          AND apd.history_status = 'A'
                   LEFT JOIN ap_document_attr apda
                       ON     apda.apda_apd = apd.apd_id
                          AND apda.apda_nda = 2191
                          AND apda.history_status = 'A'
                   LEFT JOIN pc_decision pd
                       ON     pc_id = pd_pc
                          AND pd.pd_nst =
                              REGEXP_SUBSTR (apda.apda_val_string,
                                             '[[:digit:]]+')
                          AND ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                               AND pd.pd_stop_dt
                          AND pd_st IN ('S');

        CURSOR pdm (p_pd NUMBER)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE p.pdm_pd = p_pd AND p.history_status = 'A'
            ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;

        -- 641 послуга
        CURSOR ap_tp_o_641 IS
            SELECT ap.ap_id,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   ap.ap_st,
                   app.app_id, --app.app_fn||' '||app.app_mn||' '||app.app_ln AS app_fio,
                   app.app_sc,
                   pc_id
              FROM tmp_work_ids
                   JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                   JOIN ap_service aps
                       ON     aps_ap = ap_id
                          AND aps_nst = 641
                          AND aps.history_status = 'A'
                   JOIN ap_person app
                       ON     app_ap = ap_id
                          AND app_tp = 'O'
                          AND app.history_status = 'A'
                   JOIN personalcase pc ON pc_sc = app_sc;

        CURSOR decision_641 (p_pc NUMBER, p_calc_dt DATE)
        IS
            SELECT pd.pd_id, pd.pd_num
              FROM pc_decision pd
             WHERE     pd_pc = p_pc
                   AND p_calc_dt BETWEEN pd.pd_start_dt AND pd.pd_stop_dt
                   AND pd_st IN ('S');

        CURSOR method (p_pd NUMBER, p_calc_dt DATE)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE     p.pdm_pd = p_pd
                     AND p.history_status = 'A'
                     AND p_calc_dt BETWEEN p.pdm_start_dt AND p.pdm_stop_dt
            ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;


        -- Зміна складу сім`ї
        CURSOR ap_tp_o_change IS
            SELECT ap.ap_id,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   ap.ap_st,
                   aps_nst,
                   app.app_id, --app.app_fn||' '||app.app_mn||' '||app.app_ln AS app_fio,
                   app.app_sc,
                   API$PC_DECISION.get_doc_string (app.app_id, 10098, 2262)
                       AS nst,
                   pd_id,
                   pd_num,
                   CASE pd_st WHEN 'S' THEN 'I' ELSE 'U' END
                       AS pd_Mode,
                   (SELECT LISTAGG (
                               uss_person.api$sc_tools.get_pib (
                                   app_new.app_sc),
                               ', '
                               ON OVERFLOW TRUNCATE '...')
                           WITHIN GROUP (ORDER BY app_new.app_ap)
                      FROM ap_person  app_old
                           JOIN ap_person app_new
                               ON app_old.app_sc = app_new.app_sc
                     WHERE     app_old.app_ap = pd.pd_ap
                           AND app_new.app_ap = ap.ap_id
                           AND app_old.app_tp = 'FP'
                           AND app_new.app_tp = 'FP'
                           AND app_old.history_status = 'A'
                           AND app_new.history_status = 'A')
                       AS Dubl_PIB
              FROM tmp_work_ids
                   JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                   JOIN ap_service aps
                       ON     aps_ap = ap_id
                          AND aps_nst = 643
                          AND aps.history_status = 'A'
                   JOIN ap_person app
                       ON     app_ap = ap_id
                          AND app_tp = 'O'
                          AND app.history_status = 'A'
                   JOIN personalcase pc ON pc_sc = app_sc
                   LEFT JOIN pc_decision pd
                       ON     pc_id = pd_pc
                          AND pd.pd_nst =
                              REGEXP_SUBSTR (
                                  API$PC_DECISION.get_doc_string (app.app_id,
                                                                  10098,
                                                                  2262) --apda.apda_val_string
                                                                       ,
                                  '[[:digit:]]+')
                          AND ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                               AND pd.pd_stop_dt
                          AND pd_st IN ('S', 'PS')
            UNION ALL
            SELECT ap.ap_id,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   ap.ap_st,
                   aps_nst,
                   app.app_id, --app.app_fn||' '||app.app_mn||' '||app.app_ln AS app_fio,
                   app.app_sc,
                   API$PC_DECISION.get_doc_string (app.app_id, 10099, 2260)
                       AS nst,
                   pd_id,
                   pd_num,
                   CASE pd_st WHEN 'S' THEN 'I' ELSE 'U' END
                       AS pd_Mode,
                   ''
              FROM tmp_work_ids
                   JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                   JOIN ap_service aps
                       ON     aps_ap = ap_id
                          AND aps_nst = 801
                          AND aps.history_status = 'A'
                   JOIN ap_person app
                       ON     app_ap = ap_id
                          AND app_tp = 'O'
                          AND app.history_status = 'A'
                   JOIN personalcase pc ON pc_sc = app_sc
                   LEFT JOIN pc_decision pd
                       ON     pc_id = pd_pc
                          AND pd.pd_nst =
                              REGEXP_SUBSTR (
                                  API$PC_DECISION.get_doc_string (app.app_id,
                                                                  10099,
                                                                  2260) --apda.apda_val_string
                                                                       ,
                                  '[[:digit:]]+')
                          AND ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                               AND pd.pd_stop_dt
                          AND pd_st IN ('S', 'PS');
    BEGIN
        IF p_mode IN (1) AND p_ap_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT ap_id
                  FROM appeal
                 WHERE ap_id = p_ap_id AND ap_st IN ('O') AND ap_tp IN ('O');

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, appeal
             WHERE x_id = ap_id AND ap_st IN ('O') AND ap_tp IN ('O');
        END IF;

        --raise_application_error(-20000, 'init_pc_decision_by_ap_tp_O p_mode='||p_mode||'    p_ap_id='||p_ap_id);

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування проектів рішень про призначення не передано зверненнь щодо змін обставин!');
        END IF;

        -- 641 послуга
        FOR rec IN ap_tp_o_641
        LOOP
            --dbms_output.put_line('pc_id='||rec.pc_id||'   rec.app_sc='||rec.app_sc);
            Copy_Document2Socialcard (p_ap => rec.ap_id);

            FOR pd IN decision_641 (rec.pc_id, rec.ap_reg_dt)
            LOOP
                --dbms_output.put_line('pd.pd_id='||pd.pd_id||'    rec.ap_reg_dt='||rec.ap_reg_dt);
                FOR pdm IN method (pd.pd_id, rec.ap_reg_dt)
                LOOP
                    --dbms_output.put_line('p.pdm_id='||pdm.pdm_id);
                    --Вкорочуємо старій запис.
                    UPDATE pd_pay_method p
                       SET p.pdm_stop_dt = rec.ap_reg_dt - 1,
                           p.pdm_is_actual = 'F'
                     WHERE p.pdm_id = pdm.pdm_id;

                    --створюємо новий
                    pay_method := pdm;
                    pay_method.pdm_id := NULL;
                    pay_method.pdm_start_dt := rec.ap_reg_dt;
                    pay_method.pdm_ap_src := rec.ap_id;

                    SELECT MAX (sc_scc)
                      INTO pay_method.pdm_scc
                      FROM uss_person.v_socialcard sc
                     WHERE sc.sc_id = rec.app_sc;

                    INSERT INTO pd_pay_method
                         VALUES pay_method;
                END LOOP;

                write_pd_log (
                    p_pdl_pd        => pd.pd_id,
                    p_pdl_hs        => p_hs,
                    p_pdl_st        => 'S',
                    p_pdl_message   => CHR (38) || '130#' || pd.pd_num,
                    p_pdl_st_old    => 'S');

                API$ESR_Action.PrepareWrite_Visit_ap_log (
                    rec.ap_id,
                    'O',
                    pd.pd_id,
                    CHR (38) || '130#' || pd.pd_num);


                Check_pd_pay_method (pd.pd_id);
            END LOOP;
        END LOOP;

        -- 642 послуга
        FOR rec IN ap_tp_o_642
        LOOP
            IF rec.pd_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                    'Опрацювання звернення "Зміна виплатних реквізитів" не можливо. Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано" для виду допомоги, яка вказана у документі "Зміна виплатних реквізитів" в атрибуті "Вид допомоги"');
            ELSE
                l_stop_dt := LAST_DAY (rec.ap_reg_dt);
                l_start_dt := LAST_DAY (rec.ap_reg_dt) + 1;

                FOR pm IN pdm (rec.pd_id)
                LOOP
                    pay_method := pm;

                    UPDATE pd_pay_method p
                       SET p.pdm_stop_dt = l_stop_dt
                     WHERE p.pdm_id = pm.pdm_id;

                    pay_method.pdm_id := NULL;
                    pay_method.pdm_ap_src := rec.ap_id;
                    pay_method.pdm_start_dt := l_start_dt;
                    pay_method.pdm_kaot := rec.apm_kaot;
                    pay_method.pdm_nb := rec.apm_nb;
                    pay_method.pdm_pay_tp := rec.apm_tp;
                    pay_method.pdm_index := rec.apm_index;
                    pay_method.pdm_account := rec.apm_account;
                    pay_method.pdm_street := rec.apm_street;
                    pay_method.pdm_ns := rec.apm_ns;
                    pay_method.pdm_building := rec.apm_building;
                    pay_method.pdm_block := rec.apm_block;
                    pay_method.pdm_apartment := rec.apm_apartment;
                    pay_method.pdm_is_actual := 'T';

                    UPDATE pd_pay_method p
                       SET p.pdm_is_actual = 'F'
                     WHERE p.pdm_pd = rec.pd_id;

                    INSERT INTO pd_pay_method
                         VALUES pay_method;

                    decision_block (
                        rec.pd_id,
                        tools.ggp ('CHANGE_PAYMENT_CODE', rec.ap_reg_dt),
                        rec.ap_id,
                        p_hs);

                    write_pd_log (
                        p_pdl_pd        => rec.pd_id,
                        p_pdl_hs        => p_hs,
                        p_pdl_st        => 'PS',
                        p_pdl_message   => CHR (38) || '81#' || rec.ap_num,
                        p_pdl_st_old    => 'S');

                    API$ESR_Action.PrepareWrite_Visit_ap_log (
                        rec.ap_id,
                        'O',
                        rec.pd_id,
                        CHR (38) || '80#' || rec.pd_num);
                    EXIT;
                END LOOP;
            END IF;

            recalc_pd_periods (p_pd_id => rec.pd_id, p_hs => p_hs);
        END LOOP;


        FOR rec IN ap_tp_o_change
        LOOP
            IF rec.pd_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                    'Опрацювання звернення "Зміна складу сім''ї " не можливо. Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано" для виду допомоги, яка вказана у документі "Зміна виплатних реквізитів" в атрибуті "Вид допомоги"');
            END IF;

            --      IF rec.Dubl_PIB IS NOT NULL THEN
            --         raise_application_error(-20000, 'Опрацювання звернення "Зміна складу сім'ї " не можливо. Утриманець '|| rec.Dubl_PIB ||' у рішенні у статусі Нараховано');
            --      END IF;

            IF rec.pd_Mode = 'I'
            THEN
                decision_block (
                    rec.pd_id,
                    tools.ggp ('CHANGE_FAMILY_CODE', rec.ap_reg_dt),
                    rec.ap_id,
                    p_hs);


                l_pd_id := id_pc_decision (0);

                INSERT INTO pc_decision (pd_id,
                                         pd_pc,
                                         pd_ap,
                                         pd_pa,
                                         pd_dt,
                                         pd_st,
                                         pd_nst,
                                         com_org,
                                         com_wu,
                                         pd_src,
                                         pd_ps,
                                         pd_src_id,
                                         pd_has_right,
                                         pd_start_dt,
                                         pd_stop_dt,
                                         pd_ap_reason,
                                         pd_scc)
                    SELECT l_pd_id,
                           pd_pc,
                           pd_ap,
                           pd_pa,
                           TRUNC (SYSDATE),
                           'R0',
                           pd_nst,
                           com_org,
                           p_com_wu,
                           'PV'      AS x_pd_src,
                           pd_ps     AS x_pd_ps,
                           --pd_id, pd_has_right, last_day(rec.ap_reg_dt)+1, pd_stop_dt,
                           pd_id,
                           pd_has_right,
                           pd_start_dt,
                           pd_stop_dt,
                           rec.ap_id,
                           pd_scc
                      FROM pc_decision pd
                     WHERE     pd.pd_id = rec.pd_id
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM pc_decision pdsl
                                     WHERE pdsl.pd_ap_reason = rec.ap_id);

                FOR pm IN pdm (rec.pd_id)
                LOOP
                    pay_method := pm;
                END LOOP;

                IF pay_method.pdm_pd IS NOT NULL
                THEN
                    pay_method.pdm_id := NULL;
                    pay_method.pdm_pd := l_pd_id;

                    INSERT INTO pd_pay_method
                         VALUES pay_method;
                END IF;
            ELSE
                UPDATE pc_decision pd
                   SET pd_st = 'PS',
                       pd_suspend_reason =
                           tools.ggp ('CHANGE_FAMILY_CODE', rec.ap_reg_dt)
                 WHERE pd_id = rec.pd_id;

                UPDATE pc_decision
                   SET pd_st = 'R0'
                 WHERE pd_ap_reason = rec.ap_id;
            END IF;

            INSERT INTO pd_source (pds_id,
                                   pds_pd,
                                   pds_tp,
                                   pds_ap,
                                   pds_create_dt,
                                   history_status)
                SELECT 0,
                       pds_pd,
                       pds_tp,
                       pds_ap,
                       pds_create_dt,
                       history_status
                  FROM pd_source
                 WHERE pds_pd = rec.pd_id AND history_status = 'A'
                UNION ALL
                SELECT 0,
                       l_pd_id       AS pds_pd,
                       'AP'          AS pds_tp,
                       rec.ap_id     AS pds_ap,
                       SYSDATE,
                       'A'
                  FROM DUAL;


            recalc_pd_periods (p_pd_id => rec.pd_id, p_hs => p_hs);
        END LOOP;
    END;

    --  Функція формування проектів рішень про призначення на основі звернення
    --  p_mode 1=з p_ap_id, 2=з таблиці tmp_work_ids 3=з p_ap_id у авторежимі  4=з таблиці tmp_work_ids у авторежимі
    PROCEDURE init_pc_decision_by_appeals (p_mode           INTEGER,
                                           p_ap_id          appeal.ap_id%TYPE,
                                           p_messages   OUT SYS_REFCURSOR)
    IS
        l_cnt               INTEGER;
        l_lock_init         TOOLS.t_lockhandler;
        l_lock              TOOLS.t_lockhandler;
        g_messages          TOOLS.t_messages := TOOLS.t_messages ();
        l_num               pc_account.pa_num%TYPE;
        l_hs                histsession.hs_id%TYPE;
        l_com_org           pc_decision.com_org%TYPE;
        l_com_wu            pc_decision.com_wu%TYPE;
        l_is_have_ap_tp_U   INTEGER;
        l_is_have_ap_tp_O   INTEGER;
    BEGIN
        IF p_mode IN (1, 2)
        THEN
            l_com_org := TOOLS.GetCurrOrg;
            l_com_wu := TOOLS.GetCurrWu;

            IF l_com_org IS NULL
            THEN
                raise_application_error (
                    -20000,
                    'Не можу визначити орган призначення!');
            END IF;

            IF l_com_wu IS NULL
            THEN
                raise_application_error (-20000,
                                         'Не можу визначити користувача!');
            END IF;
        ELSIF p_mode IN (3, 4)
        THEN
            NULL;
        --GetSecretWU(l_com_wu, l_com_org);
        END IF;

        l_lock_init :=
            TOOLS.request_lock (
                p_descr   => 'INIT_PC_DECISION_' || p_ap_id,
                p_error_msg   =>
                       'В даний момент вже виконується створення проектів рішень по зверненню '
                    || p_ap_id
                    || '!');


        --  raise_application_error(-20000, 'p_mode='||p_mode||'    p_ap_id='||p_ap_id);


        IF p_mode IN (1, 3) AND p_ap_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT ap_id
                  FROM appeal
                 WHERE     ap_id = p_ap_id
                       AND ap_st IN ('O')
                       AND ap_tp IN ('V',
                                     'U',
                                     'SS',
                                     'O');

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, appeal
             WHERE     x_id = ap_id
                   AND ap_st IN ('O')
                   AND ap_tp IN ('V',
                                 'U',
                                 'SS',
                                 'O');
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування проектів рішень про призначення не передано зверненнь!');
        END IF;

        l_hs := TOOLS.GetHistSession;

        --Якщо є рішення по дерутриманню, ініціалізуємо по ним держутримання/відрахування
        SELECT COUNT (*)
          INTO l_is_have_ap_tp_O
          FROM tmp_work_ids, appeal
         WHERE x_id = ap_id AND ap_st IN ('O') AND ap_tp IN ('O');

        IF l_is_have_ap_tp_O > 0
        THEN
            init_pc_decision_by_ap_tp_O (2,
                                         NULL,
                                         p_messages,
                                         l_hs,
                                         l_com_wu);
        END IF;

        --Якщо є рішення по дерутриманню, ініціалізуємо по ним держутримання/відрахування
        SELECT COUNT (*)
          INTO l_is_have_ap_tp_U
          FROM tmp_work_ids, appeal
         WHERE x_id = ap_id AND ap_st IN ('O') AND ap_tp IN ('U');

        IF l_is_have_ap_tp_U > 0
        THEN
            API$PC_STATE_ALIMONY.init_pc_state_alimony_by_appeals (
                2,
                NULL,
                p_messages);
        END IF;

        --Генеруємо необхідну кількість нових Особових рахунків
        INSERT INTO pc_account (pa_id, pa_pc, pa_nst)
            SELECT DISTINCT 0, ap_pc, aps_nst
              FROM appeal,
                   tmp_work_ids,
                   uss_ndi.v_ndi_service_type,
                   personalcase,
                   (SELECT CASE
                               WHEN nst_nst_main = 248 THEN nst_nst_main
                               ELSE nst_id
                           END    AS aps_nst,
                           aps_ap
                      FROM tmp_work_ids,
                           ap_service,
                           uss_ndi.v_ndi_service_type
                     WHERE     aps_ap = x_id
                           AND aps_nst = nst_id
                           AND ap_service.history_status = 'A')
             WHERE     ap_id = x_id
                   AND ap_tp IN ('V', 'U', 'SS')
                   AND aps_ap = ap_id
                   AND aps_ap = x_id
                   AND aps_nst = nst_id
                   AND ap_pc = pc_id
                   AND ap_pc IS NOT NULL
                   AND nst_is_or_generate = 'T'
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pc_decision
                             WHERE pd_pc = pc_id AND pd_nst = aps_nst)
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pc_account
                             WHERE pa_pc = pc_id AND pa_nst = aps_nst);

        IF SQL%ROWCOUNT = 0
        THEN
            TOOLS.add_message (g_messages,
                               'I',
                               'Нових особових рахунків не створено!');
        END IF;

        FOR xx
            IN (  SELECT pa_id, pc_id, pc_num
                    FROM tmp_work_ids,
                         appeal,
                         personalcase,
                         pc_account
                   WHERE     ap_id = x_id
                         AND ap_pc = pc_id
                         AND pa_pc = pc_id
                         AND pa_num IS NULL
                ORDER BY pa_id ASC)
        LOOP
            --Вішаємо lock на генерацію номера для ЕОС
            l_lock :=
                TOOLS.request_lock (
                    p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                    p_error_msg   =>
                           'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                        || xx.pc_num
                        || '!');

            l_num := gen_pa_num (xx.pc_id);

            UPDATE pc_account
               SET pa_num = l_num
             WHERE pa_id = xx.pa_id;

            TOOLS.release_lock (l_lock);
            TOOLS.add_message (
                g_messages,
                'I',
                   'Створено особовий рахунок № '
                || l_num
                || ' для ЕОС № '
                || xx.pc_num
                || '.');
        END LOOP;

        --       raise_application_error(-20000, 'p_mode = '||p_mode||' l_com_org = ' || l_com_org  );

        --Створюємо проекти рішень в стані "Розраховується" для тих послуг, по яким вказано флаг nst_is_or_generate (і якщо ще не створено по зверненню і такій послузі нічого)
        --для зверненнь "Допомога"
        INSERT INTO pc_decision (pd_id,
                                 pd_pc,
                                 pd_ap,
                                 pd_pa,
                                 pd_dt,
                                 pd_st,
                                 pd_nst,
                                 com_org,
                                 com_wu,
                                 pd_src,
                                 pd_ap_reason,
                                 pd_scc)
            SELECT DISTINCT 0,
                            ap_pc,
                            ap_id,
                            pa_id,
                            TRUNC (SYSDATE),
                            'R0',
                            pa_nst,
                            CASE
                                WHEN p_mode IN (1, 2)
                                THEN
                                    l_com_org
                                ELSE
                                    (SELECT MAX (
                                                CASE t.org_to
                                                    WHEN 33 THEN t.org_org
                                                    ELSE t.org_id
                                                END)
                                       FROM v_opfu t
                                      WHERE     t.org_st = 'A'
                                            AND t.org_id = com_org)
                            END    AS com_org,
                            CASE
                                WHEN p_mode IN (1, 2) THEN l_com_wu
                                ELSE NULL
                            END    AS com_wu,
                            CASE
                                WHEN (SELECT COUNT (*)
                                        FROM pc_decision
                                       WHERE pd_pa = pa_id AND pd_st = 'S') >
                                     0 --Якщо вже є нараховані рішення - то це повторне призначення
                                THEN
                                    'PV'
                                ELSE
                                    'FS' --нарахованих зверненнь - немає, отже - це первинне призначення
                            END    AS x_pd_src,
                            ap_id,
                            api$personalcase.Get_scc_by_appeal (ap_id)
              FROM appeal,
                   tmp_work_ids,
                   uss_ndi.v_ndi_service_type,
                   pc_account,
                   (SELECT CASE
                               WHEN nst_nst_main = 248 THEN nst_nst_main
                               ELSE nst_id
                           END    AS aps_nst,
                           aps_ap
                      FROM tmp_work_ids,
                           ap_service,
                           uss_ndi.v_ndi_service_type
                     WHERE     aps_ap = x_id
                           AND aps_nst = nst_id
                           AND ap_service.history_status = 'A')
             WHERE     ap_id = x_id
                   AND ap_tp IN ('V', 'SS')
                   AND aps_ap = ap_id
                   AND aps_ap = x_id
                   AND aps_nst = nst_id
                   AND ap_pc IS NOT NULL
                   AND nst_is_or_generate = 'T'
                   AND pa_pc = ap_pc
                   AND pa_nst = nst_id
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pc_decision
                             WHERE pd_ap = aps_ap AND pd_nst = aps_nst);

        /*
            INSERT INTO pd_features (pde_id, pde_pd, pde_nft, pde_val_id, pde_val_string)
            SELECT 0, pd.pd_id, 9,
                 (SELECT MAX(apda_val_id)
                  FROM ap_document
                       JOIN ap_document_attr ON apda_apd = apd_id
                  WHERE ap_document.history_status = 'A'
                        AND apd_ap = pd_ap
                        AND ( (apd_ndt = 801 AND apda_nda = 1872)
                              OR
                              (apd_ndt = 803 AND apda_nda = 2083)   )
                  ) AS val_id,
                 (SELECT MAX(apda_val_string)
                  FROM ap_document
                       JOIN ap_document_attr ON apda_apd = apd_id
                  WHERE ap_document.history_status = 'A'
                        AND apd_ap = pd_ap
                        AND ( (apd_ndt = 801 AND apda_nda = 1872)
                              OR
                              (apd_ndt = 803 AND apda_nda = 2083)   )
                  ) AS val_string
            FROM  pc_decision pd
                  JOIN tmp_work_ids ON pd_ap = x_id
                  JOIN uss_ndi.v_ndi_service_type nst ON nst_id = pd_nst
                  JOIN uss_ndi.v_ndi_ap_nst_config nanc ON nanc.nanc_nst = nst_id AND nanc.history_status = 'A'
            WHERE nanc.nanc_ap_tp = 'SS'
                  AND NOT EXISTS (SELECT 1 FROM pd_features pde WHERE pde.pde_pd = pd.pd_id AND pde.pde_nft = 9);
        */
        MERGE INTO pd_features
             USING (SELECT 0            AS x_pde_id,
                           pd.pd_id     AS x_pd_id,
                           nft_id       AS x_nft_id
                      FROM pc_decision                    pd
                           JOIN tmp_work_ids ON pd_ap = x_id
                           JOIN uss_ndi.v_ndi_service_type nst
                               ON nst_id = pd_nst
                           JOIN uss_ndi.v_ndi_ap_nst_config nanc
                               ON     nanc.nanc_nst = nst_id
                                  AND nanc.history_status = 'A',
                           uss_ndi.v_ndi_pd_feature_type  nft
                     WHERE nanc.nanc_ap_tp = 'SS' AND nft.nft_view = 'SS')
                ON (pde_pd = x_pd_id AND pde_nft = x_nft_id)
        WHEN NOT MATCHED
        THEN
            INSERT     (pde_id, pde_pd, pde_nft)
                VALUES (x_pde_id, x_pd_id, x_nft_id);

        UPDATE pd_features pde
           SET (pde_val_id, pde_val_string) =
                   (SELECT MAX (apda_val_id), MAX (apda_val_string)
                      FROM pc_decision
                           JOIN ap_document
                               ON     apd_ap = pd_ap
                                  AND ap_document.history_status = 'A'
                           JOIN ap_document_attr
                               ON     apda_apd = apd_id
                                  AND ap_document_attr.history_status = 'A'
                     WHERE     pd_id = pde_pd
                           AND (   (apd_ndt = 801 AND apda_nda = 1872)
                                OR (apd_ndt = 803 AND apda_nda = 2083)))
         WHERE     pde.pde_nft = 9
               AND pde.pde_pd IN
                       (SELECT pd_id
                          FROM pc_decision  pd
                               JOIN tmp_work_ids ON pd_ap = x_id);


        --Створюємо проекти рішень в стані "Розраховується" для тих проектів рішень, які в стані "Нараховано" по послугам, по яким можливе відрахування по держутриманню
        --Повинна бути заповнена табличка tmp_state_alimony (заповнюється в функції init_pc_state_alimony_by_appeals)!
        INSERT INTO pc_decision (pd_id,
                                 pd_pc,
                                 pd_ap,
                                 pd_pa,
                                 pd_dt,
                                 pd_st,
                                 pd_nst,
                                 com_org,
                                 com_wu,
                                 pd_src,
                                 pd_ps,
                                 pd_src_id,
                                 pd_has_right,
                                 pd_start_dt,
                                 pd_stop_dt,
                                 pd_ap_reason,
                                 pd_scc)
            WITH
                new_pd_matrix
                AS
                    (SELECT tsa.*, row_tp
                       FROM tmp_state_alimony  tsa,
                            (    SELECT LEVEL     AS row_tp
                                   FROM DUAL
                             CONNECT BY LEVEL < 2) --3 ставити тільки за необхідності в 2 рішеннях
                      WHERE     xps_action IN ('U_STATE', 'C_NEW')
                            AND (   (    row_tp = 1
                                     AND xps_action IN ('U_STATE', 'C_NEW')) --Перше рішення - для нових держутриманнь та виїзду/заїзду
                                 OR (    row_tp = 2
                                     AND xps_action IN ('U_STATE')
                                     AND xps_second_dt IS NOT NULL))), --Друге рішення - для виїзду/заїзду, якщо 2 дати вказано в зверненні
                ndn_list
                AS
                    (SELECT dn_ps, dn_ndn
                       FROM deduction, new_pd_matrix
                      WHERE dn_ap = xps_ap
                     UNION
                     SELECT dn_ps, dn_ndn
                       FROM deduction,
                            dn_detail  dnd,
                            ps_changes,
                            new_pd_matrix
                      WHERE     dnd_psc = psc_id
                            AND psc_ap = xps_ap
                            AND dnd.history_status = 'A'
                            AND dnd_dn = dn_id)
              SELECT 0,
                     pd_pc,
                     pd_ap,
                     pd_pa,
                     TRUNC (SYSDATE),
                     'R0',
                     pd_nst,
                     l_com_org,
                     l_com_wu,
                     'SA'
                         AS x_pd_src,
                     dn_ps
                         AS x_pd_ps,
                     pd_id,
                     pd_has_right,
                     CASE
                         WHEN xps_action = 'C_NEW'
                         THEN
                             ADD_MONTHS (TRUNC (xps_rstart_dt, 'MM'), 1)
                         WHEN xps_action = 'U_STATE' AND row_tp = 1
                         THEN
                             TRUNC (xps_first_dt, 'MM')
                         WHEN xps_action = 'U_STATE' AND row_tp = 2
                         THEN
                             xps_second_dt
                     END, --!!!! Ці дати будуть переписані розрахунком!!! Треба виводити в інтерфейсі дати з таблиці pd_accrual_period
                     NULL /*CASE WHEN xps_action = 'U_STATE' AND xps_second_dt IS NOT NULL
                             THEN xps_second_dt  - 1
                      END*/
                         , --!!!! Ці дати будуть переписані розрахунком!!! Треба виводити в інтерфейсі дати з таблиці pd_accrual_period
                     xps_ap,
                     pdma.pd_scc
                FROM appeal,
                     tmp_work_ids,
                     pc_decision pdma,
                     ndn_list,
                     uss_ndi.v_ndi_nst_dn_config,
                     new_pd_matrix
               WHERE     ap_id = x_id
                     AND ap_tp = 'U'
                     AND ap_pc = pd_pc
                     AND pd_nst = nnnc_nst
                     AND dn_ndn = nnnc_ndn
                     AND pd_st = 'S'
                     AND NOT EXISTS
                             (SELECT 1
                                FROM pc_decision pdsl
                               WHERE pdsl.pd_ap = ap_id) --!!! Условие бессмысленное. По зверненням держутримання рішення, привязанные именно к этим зверненням - создаваться не будут.
                     AND pd_id =
                         (SELECT MAX (pd_id)
                            FROM pc_decision pdsl
                           WHERE pdma.pd_pa = pdsl.pd_pa AND pdsl.pd_st = 'S')
                     AND xps_pc = pd_pc
            ORDER BY CASE
                         WHEN xps_action = 'C_NEW'
                         THEN
                             ADD_MONTHS (TRUNC (xps_rstart_dt, 'MM'), 1)
                         WHEN xps_action = 'U_STATE' AND row_tp = 1
                         THEN
                             TRUNC (xps_first_dt, 'MM')
                         WHEN xps_action = 'U_STATE' AND row_tp = 2
                         THEN
                             xps_second_dt
                     END;

        --Розрахунок
        --Видаляємо лог попереднього розрахунку
        DELETE FROM pd_right_log
              WHERE prl_pd IN (SELECT pd_id
                                 FROM pc_decision, tmp_work_ids
                                WHERE pd_ap = x_id);

        --Видаляємо існуючі деталі розрахунку рішення
        DELETE FROM pd_detail
              WHERE pdd_pdp IN (SELECT pdp_id
                                  FROM pd_payment, pc_decision, tmp_work_ids
                                 WHERE pdp_pd = pd_id AND pd_ap = x_id);

        --Видаляємо існуючі розрахунки рішення
        DELETE FROM pd_payment
              WHERE pdp_pd IN (SELECT pd_id
                                 FROM pc_decision, tmp_work_ids
                                WHERE pd_ap = x_id);

        --Розрахунку доходу
        --Видаляємо лог попереднього розрахунку доходу
        DELETE FROM pd_income_log
              WHERE pil_pid IN
                        (SELECT pid_id
                           FROM pd_income_detail,
                                pd_income_calc,
                                pc_decision,
                                tmp_work_ids
                          WHERE     pid_pic = pic_id
                                AND pic_pd = pd_id
                                AND pd_ap = x_id);

        --Видаляємо детальний розрахунок доходу
        DELETE FROM pd_income_detail
              WHERE pid_pic IN
                        (SELECT pic_id
                           FROM pd_income_calc, pc_decision, tmp_work_ids
                          WHERE pic_pd = pd_id AND pd_ap = x_id);

        --Видаляємо розрахунок доходу
        DELETE FROM pd_income_calc
              WHERE pic_pd IN (SELECT pd_id
                                 FROM pc_decision, tmp_work_ids
                                WHERE pd_ap = x_id);


        UPDATE pc_decision
           SET pd_st = 'R0'
         WHERE     pd_st IN ('W', 'E')
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE pd_ap = x_id);

        IF SQL%ROWCOUNT > 0
        THEN
            TOOLS.add_message (
                g_messages,
                'W',
                'Повернуто на розрахунок ' || SQL%ROWCOUNT || ' рішень!');
        END IF;



        MERGE INTO pd_pay_method
             USING (SELECT pd_id,
                           pd_start_dt,
                           pd_stop_dt,
                           'A'                      AS x_history_status,
                           pd_ap,
                           apm_tp,
                           apm_index,
                           apm_kaot,
                           apm_nb,
                           apm_account,
                           apm_street,
                           apm_ns,
                           apm_building,
                           apm_block,
                           apm_apartment,
                           CASE
                               WHEN pd_nst = 664   /* !!! тільки для ВПО ?!?*/
                               THEN
                                   CASE
                                       WHEN EXTRACT (DAY FROM ap_reg_dt) < 4
                                       THEN
                                           4
                                       WHEN EXTRACT (DAY FROM ap_reg_dt) > 25
                                       THEN
                                           25
                                       ELSE
                                           EXTRACT (DAY FROM ap_reg_dt)
                                   END
                               ELSE
                                   NULL
                           END                      AS x_pay_dt,
                           l_hs                     AS x_hs,
                           NVL (app_scc, pd_scc)    AS pd_scc,
                           'T'                      AS x_is_actual
                      FROM tmp_work_ids
                           JOIN pc_decision ON pd_ap = x_id
                           JOIN appeal ON ap_id = pd_ap
                           LEFT JOIN
                           (SELECT *
                              FROM ap_payment
                             WHERE apm_id IN
                                       (  SELECT MAX (apm_id)
                                            FROM ap_payment
                                                 JOIN tmp_work_ids
                                                     ON apm_ap = x_id
                                           WHERE ap_payment.history_status =
                                                 'A'
                                        GROUP BY apm_ap))
                               ON apm_ap = pd_ap
                           LEFT JOIN ap_person ON app_id = apm_app)
                ON (    pdm_pd = pd_id
                    AND history_status = x_history_status
                    AND pdm_is_actual = x_is_actual)
        WHEN MATCHED
        THEN
            UPDATE SET pdm_start_dt = pd_start_dt,
                       pdm_stop_dt = pd_stop_dt,
                       pdm_ap_src = pd_ap,
                       pdm_pay_tp = apm_tp,
                       pdm_index = apm_index,
                       pdm_kaot = apm_kaot,
                       pdm_nb = apm_nb,
                       pdm_account = apm_account,
                       pdm_street = apm_street,
                       pdm_ns = apm_ns,
                       pdm_building = apm_building,
                       pdm_block = apm_block,
                       pdm_apartment = apm_apartment,
                       pdm_pay_dt = x_pay_dt,
                       pdm_hs = x_hs,
                       pdm_scc = pd_scc
        WHEN NOT MATCHED
        THEN
            INSERT     (pdm_id,
                        pdm_pd,
                        pdm_start_dt,
                        pdm_stop_dt,
                        history_status,
                        pdm_ap_src,
                        pdm_pay_tp,
                        pdm_index,
                        pdm_kaot,
                        pdm_nb,
                        pdm_account,
                        pdm_street,
                        pdm_ns,
                        pdm_building,
                        pdm_block,
                        pdm_apartment,
                        pdm_pay_dt,
                        pdm_hs,
                        pdm_scc,
                        pdm_is_actual)
                VALUES (0,
                        pd_id,
                        pd_start_dt,
                        pd_stop_dt,
                        x_history_status,
                        pd_ap,
                        apm_tp,
                        apm_index,
                        apm_kaot,
                        apm_nb,
                        apm_account,
                        apm_street,
                        apm_ns,
                        apm_building,
                        apm_block,
                        apm_apartment,
                        x_pay_dt,
                        x_hs,
                        pd_scc,
                        x_is_actual);


        /*

                INSERT INTO pd_pay_method( pdm_id, pdm_pd, pdm_start_dt, pdm_stop_dt, history_status, pdm_ap_src,
                                           pdm_pay_tp, pdm_index, pdm_kaot, pdm_nb, pdm_account, pdm_street, pdm_ns, pdm_building, pdm_block, pdm_apartment,
                                           pdm_pay_dt, pdm_hs, pdm_scc,pdm_is_actual)
            SELECT 0, pd_id, pd_start_dt, pd_stop_dt, 'A', pd_ap,
                   apm_tp, apm_index, apm_kaot, apm_nb, apm_account, apm_street, apm_ns, apm_building, apm_block, apm_apartment,
                   CASE
                   WHEN pd_nst = 664 -- !!! тільки для ВПО ?!?
                        THEN CASE WHEN extract (day from ap_reg_dt) < 4
                                      THEN 4
                                    WHEN extract (day from ap_reg_dt) > 25
                                      THEN 25
                                    ELSE extract (day from ap_reg_dt)
                               END
                        ELSE NULL
                   END, l_hs,
                   nvl(app_scc, pd_scc),
                   'T'
            FROM tmp_work_ids
                 JOIN pc_decision ON pd_ap = x_id
                 JOIN appeal ON ap_id = pd_ap
                 LEFT JOIN (SELECT *
                           FROM ap_payment
                           WHERE apm_id IN (SELECT MAX(apm_id)
                                            FROM ap_payment JOIN tmp_work_ids ON apm_ap = x_id
                                            WHERE ap_payment.history_status='A'
                                            GROUP BY apm_ap)
                           )
                           ON apm_ap = pd_ap
                 LEFT JOIN ap_person  ON app_id = apm_app;*/
        --    WHERE apm_id = (SELECT MAX(sl.apm_id) FROM ap_payment sl WHERE sl.apm_ap = pd_ap AND sl.history_status = 'A');


        --  RETURN;
        --Проставляємо номери рішень
        FOR xx
            IN (  SELECT pd_id,
                         pc_id,
                         pc_num,
                         nst_name,
                         pa_num
                    FROM (SELECT pd_id,
                                 pc_id,
                                 pc_num,
                                 nst_name,
                                 pa_num
                            FROM tmp_work_ids,
                                 appeal,
                                 personalcase,
                                 pc_decision,
                                 uss_ndi.v_ndi_service_type,
                                 pc_account
                           WHERE     ap_id = x_id
                                 AND ap_pc = pc_id
                                 AND pd_pc = pc_id
                                 AND pd_ap = ap_id
                                 AND pd_nst = nst_id
                                 AND pd_num IS NULL
                                 AND pd_pa = pa_id
                          --ORDER BY LPAD(pa_num, 10, '0') ASC, pd_id ASC
                          UNION
                          SELECT pd_id,
                                 pc_id,
                                 pc_num,
                                 nst_name,
                                 pa_num
                            FROM tmp_work_ids,
                                 appeal,
                                 personalcase,
                                 pc_decision,
                                 uss_ndi.v_ndi_service_type,
                                 pc_account
                           WHERE     ap_id = x_id
                                 AND ap_pc = pc_id
                                 AND pd_pc = pc_id
                                 AND pd_ap_reason = ap_id
                                 AND pd_nst = nst_id
                                 AND pd_num IS NULL
                                 AND pd_pa = pa_id
                          UNION
                          SELECT pd_id,
                                 pc_id,
                                 pc_num,
                                 nst_name,
                                 pa_num
                            FROM tmp_work_ids,
                                 pc_state_alimony,
                                 personalcase,
                                 pc_decision,
                                 uss_ndi.v_ndi_service_type,
                                 pc_account
                           WHERE     pd_ps = ps_id
                                 AND ps_ap = x_id
                                 AND pd_pc = pc_id
                                 AND pd_pa = pa_id
                                 AND pd_nst = nst_id
                                 AND pd_num IS NULL
                          UNION
                          SELECT pd_id,
                                 pc_id,
                                 pc_num,
                                 nst_name,
                                 pa_num
                            FROM tmp_work_ids,
                                 pc_state_alimony,
                                 personalcase,
                                 pc_decision,
                                 uss_ndi.v_ndi_service_type,
                                 pc_account
                           WHERE     pd_ps = ps_id
                                 AND pd_ap_reason = x_id
                                 AND pd_pc = pc_id
                                 AND pd_pa = pa_id
                                 AND pd_nst = nst_id
                                 AND pd_num IS NULL)
                ORDER BY LPAD (pa_num, 10, '0') ASC, pd_id ASC)
        LOOP
            --Вішаємо lock на генерацію номера для ЕОС
            l_lock :=
                TOOLS.request_lock (
                    p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                    p_error_msg   =>
                           'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                        || xx.pc_num
                        || '!');

            l_num := gen_pd_num (xx.pc_id);

            UPDATE pc_decision
               SET pd_num = l_num
             WHERE pd_id = xx.pd_id;

            --#81214 20221104
            API$PC_ATTESTAT.Check_pc_com_org (xx.pd_id, SYSDATE, l_hs);

            TOOLS.release_lock (l_lock);
            TOOLS.add_message (
                g_messages,
                'I',
                   'Створено проект рішення рахунок № '
                || l_num
                || ' для ЕОС № '
                || xx.pc_num
                || ' по послузі: '
                || xx.nst_name
                || '.');
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                'R0',
                   CHR (38)
                || '11#'
                || l_num
                || '#'
                || xx.pc_num
                || '#'
                || xx.nst_name,
                NULL);
            --#73634 2021.12.02
            API$ESR_Action.PrepareWrite_Visit_ap_log (
                xx.pd_id,
                   CHR (38)
                || '11#'
                || l_num
                || '#'
                || xx.pc_num
                || '#'
                || xx.nst_name,
                NULL);
        END LOOP;

        --Збираємо первинну інформацію про доходи:
        --Видаляємо дані по декларації
        DELETE FROM pd_income_src
              WHERE     pis_src <> 'HND'
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_ids, pc_decision
                              WHERE pd_ap = x_id AND pis_pd = pd_id);

        --Вставляємо дані по декларації - для Допомог
        INSERT INTO pd_income_src (pis_id,
                                   pis_src,
                                   pis_tp,
                                   pis_edrpou,
                                   pis_fact_sum,
                                   pis_final_sum,
                                   pis_sc,
                                   pis_esv_paid,
                                   pis_esv_min,
                                   pis_start_dt,
                                   pis_stop_dt,
                                   pis_pd,
                                   pis_app,
                                   pis_is_use,
                                   pis_exch_tp)
            SELECT 0,
                   'APR',
                   apri_tp,
                   '0',
                   apri_sum,
                   apri_sum,
                   app_sc,
                   'F',
                   'F',
                   apri_start_dt,
                   apri_stop_dt,
                   pd_id,
                   app_id,
                   'T',
                   NULL
              FROM tmp_work_ids,
                   pc_decision,
                   ap_declaration,
                   apr_person,
                   apr_income,
                   ap_person,
                   appeal
             WHERE     x_id = pd_ap
                   AND apr_ap = x_id
                   AND apri_apr = apr_id
                   AND apri_aprp = aprp_id
                   AND aprp_app = app_id
                   AND app_ap = x_id
                   AND app_ap = pd_ap
                   AND apr_person.history_status = 'A'
                   AND apr_income.history_status = 'A'
                   AND ap_person.history_status = 'A'
                   AND ap_id = x_id
                   AND ap_tp IN ('V', 'SS')
            UNION ALL
            SELECT 0,
                   api_src,
                   api_tp,
                   api_edrpou,
                   api_sum,
                   api_sum,
                   app_sc,
                   DECODE (api_esv_paid,  '0', 'F',  '1', 'T',  'F'),
                   DECODE (api_esv_min,  '0', 'F',  '1', 'T',  'F'),
                   NVL (api_start_dt, api_month),
                   NVL (api_stop_dt, LAST_DAY (api_month)),
                   pd_id,
                   app_id,
                   'F',
                   api_exch_tp
              FROM tmp_work_ids,
                   pc_decision,
                   ap_person,
                   ap_income,
                   appeal
             WHERE     x_id = pd_ap
                   AND app_ap = pd_ap
                   AND api_app = app_id
                   AND ap_person.history_status = 'A'
                   AND ap_id = x_id
                   AND ap_tp IN ('V', 'SS');

        --Для Держутримань доходи беруться з оригінальних рішень
        INSERT INTO pd_income_src (pis_id,
                                   pis_src,
                                   pis_tp,
                                   pis_edrpou,
                                   pis_fact_sum,
                                   pis_final_sum,
                                   pis_sc,
                                   pis_esv_paid,
                                   pis_esv_min,
                                   pis_start_dt,
                                   pis_stop_dt,
                                   pis_pd,
                                   pis_app,
                                   pis_is_use,
                                   pis_exch_tp)
            SELECT 0,
                   pis_src,
                   pis_tp,
                   pis_edrpou,
                   pis_fact_sum,
                   pis_final_sum,
                   pis_sc,
                   pis_esv_paid,
                   pis_esv_min,
                   pis_start_dt,
                   pis_stop_dt,
                   dest.pd_id,
                   pis_app,
                   pis_is_use,
                   pis_exch_tp
              FROM tmp_work_ids,
                   appeal,
                   pc_state_alimony,
                   pc_decision  src,
                   pd_income_src,
                   pc_decision  dest
             WHERE     x_id = ap_id
                   AND ps_ap = ap_id
                   AND dest.pd_ps = ps_id
                   AND src.pd_id = dest.pd_src_id
                   AND pis_pd = src.pd_id
                   AND ap_tp = 'U';

        --Для Держутримань підтвердження права береться з оригінальних рішень
        INSERT INTO pd_right_log (prl_id,
                                  prl_pd,
                                  prl_nrr,
                                  prl_result,
                                  prl_hs_rewrite,
                                  prl_calc_result,
                                  prl_calc_info)
            SELECT 0,
                   dest.pd_id,
                   prl_nrr,
                   prl_result,
                   prl_hs_rewrite,
                   prl_calc_result,
                   prl_calc_info
              FROM tmp_work_ids,
                   appeal,
                   pc_state_alimony,
                   pc_decision  src,
                   pd_right_log,
                   pc_decision  dest
             WHERE     x_id = ap_id
                   AND ps_ap = ap_id
                   AND dest.pd_ps = ps_id
                   AND src.pd_id = dest.pd_src_id
                   AND prl_pd = src.pd_id
                   AND ap_tp = 'U';

        --!!!дотягнути дані по доходам з ДФС

        --!!!дотягнути дані по доходам з ДЦЗ

        --Переводимо звернення в стан 'WD' = Опрацювання рішення, якщо хоча б одне рішення створене
        API$APPEAL.mark_appeal_working (2,
                                        1,
                                        NULL,
                                        l_cnt);

        IF l_cnt = 0
        THEN
            TOOLS.add_message (
                g_messages,
                'W',
                'Проектів рішень за зверненням не знайдено, стан звернення не змінено!');
        END IF;

        TOOLS.release_lock (l_lock_init);

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;


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

    --Розрахунок сукупного доходу
    PROCEDURE calc_income_for_pd (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                                  p_pd_id          pc_decision.pd_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$calc_income.calc_income_for_pd (p_mode, p_pd_id, p_messages);
    END;

    --Чистимо допоміжні таблиці
    PROCEDURE clean_temp_tables
    IS
    BEGIN
        DELETE FROM tmp_calc_pd
              WHERE 1 = 1;

        DELETE FROM tmp_tar_dates1
              WHERE 1 = 1;

        DELETE FROM tmp_tar_dates
              WHERE 1 = 1;

        DELETE FROM tmp_pd_detail_calc
              WHERE 1 = 1;

        DELETE FROM tmp_pay_dates1
              WHERE 1 = 1;

        DELETE FROM tmp_pay_dates
              WHERE 1 = 1;

        DELETE FROM tmp_calc_app_params
              WHERE 1 = 1;

        DELETE FROM tmp_pd_calc_params
              WHERE 1 = 1;

        DELETE FROM tmp_pdf_calc_params
              WHERE 1 = 1;
    END;

    FUNCTION is_have_nst_by_alg (p_alg_tp VARCHAR2, p_alg_value VARCHAR2)
        RETURN INTEGER
    IS
        l_cnt   INTEGER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_ids, pc_decision, uss_ndi.v_ndi_nst_calc_config
         WHERE     pd_id = x_id
               AND pd_nst = ncc_nst
               AND (   (    p_alg_tp = 'CALC_PERIOD'
                        AND ncc_calc_period = p_alg_value)
                    OR (    p_alg_tp = 'APP_GROUP'
                        AND ncc_app_group = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_LGW'
                        AND ncc_break_lgw = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_BIRTH'
                        AND ncc_break_birth = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_6YEARS'
                        AND ncc_break_6years = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_18YEARS'
                        AND ncc_break_18years = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_23YEARS'
                        AND ncc_break_23years = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_INV'
                        AND ncc_break_inv = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_1MONTHS'
                        AND ncc_break_1months = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_RAISE'
                        AND ncc_break_raise = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_LGW_LEVEL'
                        AND ncc_break_lgw_level = p_alg_value)
                    OR (p_alg_tp = 'BREAK_DN' AND ncc_break_dn = p_alg_value)
                    OR (p_alg_tp = 'BREAK_BD' AND ncc_break_bd = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_PDF_PERIOD'
                        AND ncc_break_pdf_period = p_alg_value)
                    OR 1 = 2);

        RETURN l_cnt;
    END;

    --Отримання параметрів рішення та звернення
    PROCEDURE obtain_pd_params
    IS
    BEGIN
        INSERT INTO tmp_pd_calc_params (xpd_id,
                                        xpd_ap,
                                        xpd_nst,
                                        xpd_ap_reg_dt,
                                        xpd_calc_alg,
                                        xpd_mount_live,
                                        xpd_family_income,
                                        xpd_pc,
                                        xpd_src,
                                        xpd_start_dt,
                                        xpd_calc_dt)
            SELECT pd_id,
                   pd_ap,
                   pd_nst,
                   TRUNC (
                       CASE
                           WHEN pd_nst = 269 --!!! Какая-то хрень. Почему MAX, а не MIN?
                           THEN
                               (SELECT NVL (
                                           MAX (
                                               API$PC_DECISION.get_doc_dt (
                                                   app_id,
                                                   114,
                                                   708)),
                                           ap_reg_dt)
                                  FROM ap_person app
                                 WHERE     app_tp = 'FP'
                                       AND history_status = 'A'
                                       AND app_ap = ap_id)
                           ELSE
                               ap_reg_dt
                       END)
                       AS ap_reg_dt,
                   ncc_calc_alg,
                   NVL (
                       API$PC_DECISION.get_ap_z_doc_string (ap_id, 605, -999),
                       'F'), --стан Проживає в гірському НП ---!!!! ще немає в Анкеті - 605.
                   NVL ( (SELECT pic_month_income
                            FROM pd_income_calc
                           WHERE pic_pd = x_id),
                        0),                  --Середньомісячний сукупний дохід
                   pd_pc,
                   pd_src,
                   pd_start_dt,
                   CASE
                       WHEN pd_ap_reason IS NOT NULL
                       THEN
                           (SELECT MAX (ap_r.ap_reg_dt)
                              FROM appeal ap_r
                             WHERE ap_r.ap_id = pd_ap_reason)
                       ELSE
                           ap_reg_dt
                   END
              FROM tmp_work_ids,
                   pc_decision,
                   appeal,
                   uss_ndi.v_ndi_nst_calc_config
             WHERE pd_id = x_id AND pd_ap = ap_id AND pd_nst = ncc_nst;
    END;

    --Отримання параметрів утриманців
    PROCEDURE obtain_pdf_params
    IS
    BEGIN
        IF is_have_nst_by_alg ('APP_GROUP', 'PER_APP') > 0
        THEN
            INSERT INTO tmp_pdf_calc_params (xpdf_id,
                                             xpdf_pd,
                                             xpdf_sc,            /*xpdf_app,*/
                                             xpdf_birth_dt)
                SELECT pdf_id,
                       pdf_pd,
                       pdf_sc,                                     /*app_id,*/
                       pdf_birth_dt
                  FROM pd_family,
                       tmp_pd_calc_params,
                       --ap_person,
                       uss_ndi.v_ndi_nst_calc_config
                 WHERE     pdf_pd = xpd_id
                       --AND app_ap = xpd_ap
                       --AND ap_person.history_status = 'A'
                       --AND app_sc = pdf_sc
                       AND xpd_nst = ncc_nst
                       AND ncc_app_group = 'PER_APP';

            /*
                !!!!! не нужно, в теории мы уже всё собрали в pd_family !!!!!
                 --Доливаем добавившихся членов семьи.
                INSERT INTO tmp_pdf_calc_params (xpdf_id, xpdf_pd, xpdf_sc, xpdf_app, xpdf_birth_dt)
                  SELECT pdf_id, pdf_pd, pdf_sc, app_id, pdf_birth_dt
                  FROM pd_family, tmp_pd_calc_params, pc_decision, ap_person, uss_ndi.v_ndi_nst_calc_config
                  WHERE pdf_pd = xpd_id
                    AND pd_id = xpd_id
                    AND app_ap = pd_ap_reason
                    AND ap_person.history_status = 'A'
                    AND app_sc = pdf_sc
                    AND xpd_nst = ncc_nst
                    AND ncc_app_group = 'PER_APP'
                    AND NOT EXISTS (SELECT *
                                    FROM tmp_pdf_calc_params
                                    WHERE xpdf_pd = xpd_id AND xpdf_sc = app_sc);
            */

            /*
                  JOIN appeal    ap  ON ap_id = pd_ap_reason
                  JOIN tmp_pa_persons tpp ON tpp.tpp_pd = pd_id AND ap.ap_reg_dt BETWEEN tpp.tpp_dt_from AND tpp.tpp_dt_to
                  JOIN ap_person app ON app_id = tpp_app
            */


            INSERT INTO tmp_calc_app_params (tc_pd,
                                             tc_sc,                /*tc_app,*/
                                             tc_tp,
                                             tc_pdf,
                                             tc_calc_dt,
                                             tc_sc_start_dt,
                                             tc_sc_stop_dt)
                SELECT xpdf_pd,
                       xpdf_sc,                                  /*xpdf_app,*/
                       tpp_app_tp,
                       xpdf_id,
                       xpd_calc_dt,
                       CASE
                           --WHEN tpp.tpp_ch_fm = 'BB'  THEN xpdf_birth_dt
                           WHEN pd_nst = 664
                           THEN
                               TRUNC (tpp.tpp_dt_from, 'MM')
                           WHEN tpp.tpp_ch_fm = 'BB'
                           THEN
                               TRUNC (xpdf_birth_dt, 'MM')
                           WHEN tpp.tpp_ch_fm = 'INS'
                           THEN
                               TRUNC (tpp.tpp_dt_from, 'MM')
                           ELSE
                               tpp.tpp_dt_from
                       END    AS dt_from,
                       CASE
                           WHEN pd_nst = 664
                           THEN
                               LAST_DAY (TRUNC (tpp.tpp_dt_to, 'MM'))
                           WHEN tpp.tpp_ch_fm = 'DEL'
                           THEN
                               LAST_DAY (TRUNC (tpp.tpp_dt_to, 'MM'))
                           ELSE
                               tpp.tpp_dt_to
                       END    AS dt_to
                  FROM tmp_pd_calc_params,
                       tmp_pdf_calc_params,                     /*ap_person,*/
                       tmp_pa_persons  tpp,
                       pc_decision,
                       uss_ndi.v_ndi_nst_calc_config
                 WHERE     xpdf_pd = xpd_id
                       --AND  xpdf_app = app_id
                       AND xpdf_pd = tpp_pd
                       AND xpdf_sc = tpp_sc
                       AND xpd_nst = ncc_nst
                       AND ncc_calc_app_params = 'T'
                       AND xpd_id = pd_id;

            --#73564 2021.11.29 --#77479 20220530
            UPDATE tmp_calc_app_params
               SET tc_inv_state =
                       CASE
                           WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             201,
                                                             353,
                                                             tc_calc_dt,
                                                             '-') = 'ID'
                           THEN
                               'IZ'
                           WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             201,
                                                             353,
                                                             tc_calc_dt,
                                                             '-') <> '-'
                           THEN
                               'I'
                           WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             809,
                                                             1937,
                                                             tc_calc_dt,
                                                             '-') <> '-'
                           THEN
                               'I'
                           WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             200,
                                                             797,
                                                             tc_calc_dt,
                                                             '-') <> '-'
                           THEN
                               'DI'
                           ELSE
                               'N'
                       END,                       --стан інвалідності з анкети
                   tc_inv_group =
                       COALESCE (API$ACCOUNT.get_docx_string (tc_pd,
                                                              tc_sc,
                                                              201,
                                                              349,
                                                              tc_calc_dt),
                                 API$ACCOUNT.get_docx_string (tc_pd,
                                                              tc_sc,
                                                              809,
                                                              1937,
                                                              tc_calc_dt),
                                 '-'),  --група інвалідності з медогляду МСЕК,
                   tc_inv_sgroup =
                       COALESCE (API$ACCOUNT.get_docx_string (tc_pd,
                                                              tc_sc,
                                                              201,
                                                              791,
                                                              tc_calc_dt),
                                 API$ACCOUNT.get_docx_string (tc_pd,
                                                              tc_sc,
                                                              809,
                                                              1938,
                                                              tc_calc_dt),
                                 '-'), --підгрупа інвалідності з медогляду МСЕК
                   tc_inv_reason =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    201,
                                                    353,
                                                    tc_calc_dt,
                                                    '-'), --причина інвалідності з медогляду МСЕК
                   tc_need_care =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    201,
                                                    790,
                                                    tc_calc_dt,
                                                    'F'), --ознака потреби в постійному догляді з медогляду МСЕК
                   tc_is_lonely =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    641,
                                                    tc_calc_dt,
                                                    'N'), --стан одинокий з анкети
                   tc_inv_child =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    200,
                                                    797,
                                                    tc_calc_dt,
                                                    '-'), --категорія дитини з інвалідністю з медичного висновку
                   tc_state_care =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    667,
                                                    tc_calc_dt,
                                                    'N'), --стан знаходження на держутриманні з анкети
                   tc_state_care_dt =
                       NVL (API$ACCOUNT.get_docx_dt (tc_pd,
                                                     tc_sc,
                                                     10034,
                                                     923,
                                                     tc_calc_dt),
                            SYSDATE), --Дата зарахування на держутриманні з "Довідка про зарахування особи на повне державне утримання"
                   tc_is_working =
                       CASE API$ACCOUNT.get_docx_string (tc_pd,
                                                         tc_sc,
                                                         605,
                                                         663,
                                                         tc_calc_dt,
                                                         'F')
                           WHEN 'T' THEN 'F'
                           ELSE 'F'
                       END,                          --стан Не працює з анкети
                   tc_is_study =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    662,
                                                    tc_calc_dt,
                                                    'F'), --стан Навчається з анкети
                   tc_is_military =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    0,
                                                    tc_calc_dt,
                                                    '-'), --стан Проходить військову службу з анкети --!!!не знайдено в анкеті!!!
                   tc_is_3year_care =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    653,
                                                    tc_calc_dt,
                                                    'F'), --стан Доглядає за дитиною до 3 років з анкети
                   tc_is_pregnant =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    653,
                                                    tc_calc_dt,
                                                    'F'), --стан Перебуває у відпустці у зв’язку з вагітністю та пологами з анкети --!!!не знайдено в анкеті!!!
                   tc_is_unpaid_live =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    653,
                                                    tc_calc_dt,
                                                    'F'), --стан Перебуває у відпустці без збереження заробітної плати --!!!не знайдено в анкеті!!!
                   tc_birth_dt =
                       NVL ( (SELECT pdf_birth_dt
                                FROM pd_family
                               WHERE pdf_id = tc_pdf),
                            API$ACCOUNT.get_docx_dt (tc_pd,
                                                     tc_sc,
                                                     91,
                                                     37,
                                                     tc_calc_dt)), --дата народження з утриманців рішення, або з свідоцтва про народження
                   tc_inv_start_dt =
                       COALESCE (API$ACCOUNT.get_docx_dt (tc_pd,
                                                          tc_sc,
                                                          201,
                                                          352,
                                                          tc_calc_dt),
                                 API$ACCOUNT.get_docx_dt (tc_pd,
                                                          tc_sc,
                                                          809,
                                                          1939,
                                                          tc_calc_dt),
                                 API$ACCOUNT.get_docx_dt (tc_pd,
                                                          tc_sc,
                                                          200,
                                                          792,
                                                          tc_calc_dt)), --Дата встановлення інвалідності з медогляду МСЕК або мед.висновнку по дитині
                   tc_inv_stop_dt =
                       COALESCE (API$ACCOUNT.get_docx_dt (tc_pd,
                                                          tc_sc,
                                                          201,
                                                          347,
                                                          tc_calc_dt),
                                 API$ACCOUNT.get_docx_dt (tc_pd,
                                                          tc_sc,
                                                          809,
                                                          1806,
                                                          tc_calc_dt),
                                 API$ACCOUNT.get_docx_dt (tc_pd,
                                                          tc_sc,
                                                          200,
                                                          793,
                                                          tc_calc_dt)), --Встановлено на період до з медогляду МСЕК або мед.висновнку по дитині
                   tc_is_work_able =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    664,
                                                    tc_calc_dt,
                                                    'T'), --стан Працездатний з анкети. По замовчанню - працездатний
                   tc_is_state_alimony =
                       CASE
                           WHEN (SELECT COUNT (*)
                                   FROM pc_state_alimony, ps_changes psc
                                  WHERE     psc_ps = ps_id
                                        AND ps_st = 'R'
                                        AND psc.history_status = 'A'
                                        AND ps_sc = tc_sc) >
                                0
                           THEN
                               'T'
                           ELSE
                               'F'
                       END, --стан знаходження на держутриманні з реєстраційних записів Держутримання
                   tc_is_child_inv_chaes =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    10040,
                                                    939,
                                                    tc_calc_dt,
                                                    'F'), --"Копія посвідчення додається"="Так"
                   tc_is_child_sick =
                       API$ACCOUNT.check_docx_exists (tc_pd,
                                                      tc_sc,
                                                      669,
                                                      tc_calc_dt), --Довідка про захворювання дитини
                   tc_study_start_dt =
                       API$ACCOUNT.get_docx_dt (tc_pd,
                                                tc_sc,
                                                98,
                                                687,
                                                tc_calc_dt), --Початок періоду навчання   --#75887 2022.02.22
                   tc_study_stop_dt =
                       API$ACCOUNT.get_docx_dt (tc_pd,
                                                tc_sc,
                                                98,
                                                688,
                                                tc_calc_dt), --Кінець періоду навчання
                   tc_FamilyConnect =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    649,
                                                    tc_calc_dt,
                                                    '-'), --Ступінь родинного зв’язку
                   tc_is_vpo =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    10052,
                                                    1855,
                                                    tc_calc_dt,
                                                    '-'), --ознака документу, що підтвержує ВПО, в активному статусі 'A'
                   tc_bd_kaot_id =
                       API$ACCOUNT.get_docx_id (tc_pd,
                                                tc_sc,
                                                605,
                                                1775,
                                                tc_calc_dt)
             WHERE 1 = 1;
        ELSIF is_have_nst_by_alg ('APP_GROUP', 'ONE_BY_PD') > 0
        THEN
            INSERT INTO tmp_pdf_calc_params (xpdf_id,
                                             xpdf_pd,
                                             xpdf_sc,            /*xpdf_app,*/
                                             xpdf_birth_dt)
                SELECT 0 - xpd_id,
                       xpd_id,
                       NULL,                                         /*NULL,*/
                       NULL
                  FROM tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config
                 WHERE xpd_nst = ncc_nst AND ncc_app_group = 'ONE_BY_PD';
        END IF;
    END;

    --Перераховуємо або розраховуємо деякі додаткові параметри по  учасникам - для кожної дати окремо.
    PROCEDURE recalc_pdf_params
    IS
    BEGIN
        SaveMessage ('Перераховуємо додаткові параметри по учасникам');

        /*
          UPDATE tmp_calc_app_params
            SET (tc_inv_start_dt, tc_inv_stop_dt) = (SELECT scy_decision_dt, scy_till_dt
                                                     FROM uss_person.v_sc_disability
                                                     WHERE tc_sc = scy_sc
                                                       AND history_status = 'A'
                                                       AND sysdate >= scy_start_dt
                                                       AND (sysdate <= scy_stop_dt OR scy_stop_dt IS NULL))
            WHERE tc_inv_start_dt IS NULL
              AND EXISTS (SELECT 1
                          FROM uss_person.v_sc_disability
                          WHERE tc_sc = scy_sc
                            AND history_status = 'A'
                            AND sysdate >= scy_start_dt
                            AND (sysdate <= scy_stop_dt OR scy_stop_dt IS NULL)
                            AND scy_group IS NOT NULL);
        */
        /*
        1126 Причина інвалідності STRING
        1127 Встановлено на період по DATE
        _ _ 608 № посвідчення STRING
        609 Прізвище STRING
        610 Ім’я STRING
        611 По батькові STRING
        612 Дата народження DATE
        613 Номер особового рахунку STRING
        614 Вид пенсії STRING
        615 Термін дії DATE
        616 Дата видачі DATE
        617 Ким видано STRING
        618 Ідентифікаційний штрих-код STRING
        619 Серія та номер STRING
        */
        UPDATE tmp_calc_app_params
           SET tc_is_have18_vpo =
                   CASE
                       WHEN tc_start_dt < ADD_MONTHS (tc_birth_dt, 216)
                       THEN
                           'F'
                       ELSE
                           'T'
                   END,
               --        tc_is_inv_vpo = CASE WHEN TOOLS.GGPD('WAR_2PHASE_START') BETWEEN tc_inv_start_dt AND tc_inv_stop_dt THEN 'T'
               --                             WHEN tc_start_dt BETWEEN tc_inv_start_dt AND tc_inv_stop_dt THEN 'T'
               --                             ELSE 'F'
               --                        END,
               tc_inv_start_dt =
                   COALESCE (API$ACCOUNT.get_docx_dt (tc_pd,
                                                      tc_sc,
                                                      201,
                                                      352,
                                                      tc_calc_dt),
                             API$ACCOUNT.get_docx_dt (tc_pd,
                                                      tc_sc,
                                                      809,
                                                      1939,
                                                      tc_calc_dt)),
               tc_inv_stop_dt =
                   COALESCE (API$ACCOUNT.get_docx_dt (tc_pd,
                                                      tc_sc,
                                                      201,
                                                      347,
                                                      tc_calc_dt),
                             API$ACCOUNT.get_docx_dt (tc_pd,
                                                      tc_sc,
                                                      809,
                                                      1806,
                                                      tc_calc_dt))
         WHERE 1 = 1;


        UPDATE tmp_calc_app_params
           SET tc_is_inv_vpo =
                   CASE
                       WHEN TOOLS.GGPD ('WAR_2PHASE_START') BETWEEN tc_inv_start_dt
                                                                AND tc_inv_stop_dt
                       THEN
                           'T'
                       WHEN tc_start_dt BETWEEN TRUNC (tc_inv_start_dt, 'mm')
                                            AND tc_inv_stop_dt
                       THEN
                           'T'
                       WHEN     API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             601,
                                                             1125,
                                                             tc_calc_dt,
                                                             NULL)
                                    IS NOT NULL
                            AND NVL (API$ACCOUNT.get_docx_dt (tc_pd,
                                                              tc_sc,
                                                              601,
                                                              615,
                                                              tc_calc_dt),
                                     TO_DATE ('1974', 'YYYY')) >=
                                TO_DATE (' 24.09.2021', 'dd.mm.yyyy')
                       THEN
                           'T'
                       WHEN EXISTS
                                (SELECT 1
                                   FROM uss_person.v_sc_disability
                                  WHERE     tc_sc = scy_sc
                                        AND history_status = 'A'
                                        AND SYSDATE >= scy_start_dt
                                        AND (   SYSDATE <= scy_stop_dt
                                             OR scy_stop_dt IS NULL)
                                        AND scy_group IS NOT NULL
                                        AND api$calc_right.get_docx_string (
                                                tc_pd,
                                                tc_sc,
                                                605,
                                                1772,
                                                tc_calc_dt,
                                                'F') = 'T')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE 1 = 1;
    END;

    --Розраховуємо суму допомоги як суму прожиткового мінімуму на дату розриву
    PROCEDURE compute_by_simple_lgw_old
    IS
    BEGIN
        SaveMessage (
            'Розраховуємо суму допомоги як суму прожиткового мінімуму на дату розриву');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            SELECT 300,
                   300,
                   NULL,
                   td_pd,
                   td_begin,
                   td_end,
                   'Нараховано допомоги по догляду за хворою дитиною у розмірі прожиткового мінімуму для осіб, що втратили працездатність',
                   lgw_work_unable_sum,
                   37
              FROM tmp_tar_dates,
                   uss_ndi.v_ndi_living_wage  lw,
                   tmp_pd_calc_params
             WHERE     lw.history_status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'SIMPLE_LGW';
    END;

    -- #75610 20220214
    PROCEDURE compute_by_simple_lgw
    IS
    BEGIN
        SaveMessage (
            'Розраховуємо суму допомоги як суму прожиткового мінімуму на дату розриву');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            SELECT 300,
                   300,
                   NULL
                       tc_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   'Нараховано допомоги по догляду за хворою дитиною у розмірі прожиткового мінімуму для осіб, що втратили працездатність',
                   lgw_work_unable_sum,
                   37
              FROM tmp_tar_dates,
                   uss_ndi.v_ndi_living_wage  lw,
                   tmp_pd_calc_params
             WHERE     lw.history_status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND td_pd = xpd_id
                   AND xpd_ap_reg_dt < TO_DATE ('01.01.2022', 'dd.mm.yyyy')
                   --      AND xpd_ap_reg_dt < to_date('10.12.2021', 'dd.mm.yyyy')
                   AND xpd_calc_alg = 'SIMPLE_LGW'
            UNION ALL
            SELECT 300,
                   300,
                   tc_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   'Нараховано допомоги по догляду за хворою дитиною у розмірі прожиткового мінімуму',
                   CASE
                       WHEN tc_start_dt BETWEEN tc_birth_dt
                                            AND ADD_MONTHS (tc_birth_dt, 72)
                       THEN
                           lgw_6year_sum * 2
                       WHEN tc_start_dt BETWEEN ADD_MONTHS (tc_birth_dt, 72)
                                            AND ADD_MONTHS (tc_birth_dt, 216)
                       THEN
                           lgw_18year_sum * 2
                   END,
                   37
              FROM tmp_tar_dates,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage,
                   tmp_pd_calc_params
             WHERE     td_begin = tc_start_dt
                   AND td_pdf = tc_pdf
                   AND td_pd = tc_pd
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND history_status = 'A'
                   AND td_pd = xpd_id
                   AND xpd_ap_reg_dt >= TO_DATE ('01.01.2022', 'dd.mm.yyyy')
                   --      AND xpd_ap_reg_dt >= to_date('10.12.2021', 'dd.mm.yyyy')
                   AND tc_is_child_sick = 'T'
                   AND td_begin < ADD_MONTHS (tc_birth_dt, 216)
                   AND xpd_calc_alg = 'SIMPLE_LGW';
    END;


    PROCEDURE compute_by_diff_income_lgw
    IS
    BEGIN
        --Маємо таблицю розривів по кожному утриманцю.
        SaveMessage (
            'Розраховуємо ознаку форми навчання на денній/дуальній формі навчання для тих, хто на дату розриву досяг 18 років але менше 23 років');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value)
            SELECT 100,
                   100,
                   'Навчання за денною/дуальною формою',
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   CASE
                       WHEN (SELECT COUNT (*)
                               FROM tmp_pa_documents,           --ap_document,
                                                      ap_document_attr
                              WHERE     tpd_pd = xpdf_pd  --apd_app = xpdf_app
                                    AND tpd_sc = xpdf_sc
                                    AND apda_apd = tpd_apd            --apd_id
                                    --AND ap_document.history_status = 'A'
                                    AND tpd_ndt = 98 --Довідки про денну форму навч. (п. 2, част. 2, ст. 36 ЗУ №1058)
                                    AND apda_nda = 690 --Форма навчання (денна, дуальна, заочна)
                                    AND apda_val_string IN ('T', 'D', 'U') --Так, Денна, Дуальна
                                                                          ) >
                            0
                       THEN
                           1
                       ELSE
                           0
                   END
              FROM tmp_tar_dates, tmp_pdf_calc_params, tmp_pd_calc_params
             WHERE     td_pdf = xpdf_id
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'DIFF_W_LGW'
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_pdf_calc_params
                             WHERE     td_pdf = xpdf_id
                                   AND td_begin BETWEEN ADD_MONTHS (
                                                            xpdf_birth_dt,
                                                            216)
                                                    AND   ADD_MONTHS (
                                                              xpdf_birth_dt,
                                                              276)
                                                        - 1);

        SaveMessage (
            'Розраховуємо ознаку роботи тих, хто на дату розриву досяг 18 років але менше 23 років');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value)
            SELECT 200,
                   200,
                   'Ознака парцює',
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   CASE
                       WHEN (SELECT COUNT (*)
                               FROM tmp_pdf_calc_params,
                                    tmp_pa_documents,           --ap_document,
                                    ap_document_attr
                              WHERE     td_pdf = xpdf_id
                                    AND tpd_pd = xpdf_pd  --apd_app = xpdf_app
                                    AND tpd_sc = xpdf_sc
                                    --AND apd_app = xpdf_app
                                    AND apda_apd = tpd_apd
                                    --AND ap_document.history_status = 'A'
                                    AND tpd_ndt = 605 --Довідки про денну форму навч. (п. 2, част. 2, ст. 36 ЗУ №1058)
                                    AND apda_nda = 650                --Працює
                                    AND apda_val_string IN ('T') --Так, Денна, Дуальна
                                                                ) >
                            0
                       THEN
                           1
                       ELSE
                           0
                   END
              FROM tmp_tar_dates, tmp_pd_calc_params
             WHERE     td_pd = xpd_id
                   AND xpd_calc_alg = 'DIFF_W_LGW'
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_pdf_calc_params
                             WHERE     td_pdf = xpdf_id
                                   AND td_begin BETWEEN ADD_MONTHS (
                                                            xpdf_birth_dt,
                                                            216)
                                                    AND   ADD_MONTHS (
                                                              xpdf_birth_dt,
                                                              276)
                                                        - 1);

        SaveMessage ('Розраховуємо суму допомоги на кожного утриманця');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            SELECT 300,
                   300,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      uss_person.api$sc_tools.get_pib (xpdf_sc)
                   || ' дата народж. '
                   || TO_CHAR (xpdf_birth_dt, 'DD.MM.YYYY'),
                   CASE
                       WHEN     td_begin BETWEEN xpdf_birth_dt
                                             AND (  ADD_MONTHS (
                                                        xpdf_birth_dt,
                                                        72)
                                                  - 1)
                            AND lgw_6year_sum > pic_member_month_income --для до6річних
                       THEN
                           lgw_6year_sum - pic_member_month_income
                       WHEN     td_begin BETWEEN ADD_MONTHS (xpdf_birth_dt,
                                                             72)
                                             AND (  ADD_MONTHS (
                                                        xpdf_birth_dt,
                                                        216)
                                                  - 1)
                            AND lgw_18year_sum > pic_member_month_income --для до18річних
                       THEN
                           lgw_18year_sum - pic_member_month_income --для до18річних - різниця між прож.мін та доходом сім'ї
                       WHEN     td_begin BETWEEN ADD_MONTHS (xpdf_birth_dt,
                                                             216)
                                             AND (  ADD_MONTHS (
                                                        xpdf_birth_dt,
                                                        276)
                                                  - 1)
                            AND lgw_work_able_sum > pic_member_month_income --для до23річних
                            AND 1 =
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 100),
                                    0) --для учбовців на денній/дуальній формі
                            AND 0 =
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 200),
                                    1)                       --для непрацюючих
                       THEN
                           lgw_work_able_sum - pic_member_month_income
                       ELSE
                           0
                   END,
                   23
              FROM tmp_tar_dates,
                   pd_income_calc,
                   uss_ndi.v_ndi_living_wage  lw,
                   tmp_pdf_calc_params,
                   tmp_pd_calc_params
             WHERE     td_pd = pic_pd
                   AND td_pdf = xpdf_id
                   AND lw.history_status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'DIFF_W_LGW';
    END;

    PROCEDURE compute_by_koef_lgw
    IS
    BEGIN
        --Маємо таблицю розривів по кожному утриманцю.
        SaveMessage (
            'Розраховуємо ознаку (як суму) наявності доходів типів (аліменти, пенсія, допомога, стипендія)');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value)
            SELECT 110,
                   110,
                      'Середньомісячна сума доходів (аліменти, пенсія, допомога, стипендія)'
                   || ' '
                   || uss_person.api$sc_tools.get_pib (xpdf_sc),
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   NVL (
                       (SELECT ROUND (SUM (pid_calc_sum) / 12, 2)
                          FROM pd_income_calc,
                               pd_income_detail,
                               tmp_pdf_calc_params
                         WHERE     pic_pd = td_pd
                               AND pid_pic = pic_id
                               AND pid_sc = xpdf_sc
                               AND td_pd = xpdf_pd
                               AND td_pdf = xpdf_id
                               AND pid_calc_sum > 0),
                       0)
              FROM tmp_tar_dates, tmp_pd_calc_params, tmp_pdf_calc_params
             WHERE     td_pd = xpd_id
                   AND td_pdf = xpdf_id
                   AND xpd_calc_alg = 'KOEF_LGW' /*
                    AND EXISTS (SELECT 1
                                FROM tmp_pdf_calc_params
                                WHERE td_pdf = xpdf_id)*/
                                                ;

        SaveMessage ('Розраховуємо ознаку інвалідності');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value)
            SELECT 120,
                   120,
                   'Ознака інвалідності',
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   CASE
                       WHEN (SELECT COUNT (*)
                               FROM (  SELECT xpdf_id
                                                  AS x_pdf,
                                              MAX (
                                                  DECODE (apda_nda,
                                                          792, apda_val_dt))
                                                  AS x_inv_begin,
                                                MAX (
                                                    DECODE (apda_nda,
                                                            793, apda_val_dt))
                                              - 1
                                                  AS x_inv_end --#75883 2022,02,22
                                         FROM tmp_pdf_calc_params,
                                              tmp_pa_documents, --ap_document,
                                              ap_document_attr
                                        WHERE     xpdf_id = td_pdf
                                              --AND apd_app = xpdf_app
                                              AND tpd_pd = xpdf_pd --apd_app = xpdf_app
                                              AND tpd_sc = xpdf_sc
                                              AND apda_apd = tpd_apd
                                              --AND ap_document.history_status = 'A'
                                              AND tpd_ndt = 200 --Медичний висновок (для дітей інвалідів до 18 років)
                                              AND apda_nda IN (792, 793) --дата встановлення інвалідності, встановлено на період по
                                     --AND apd_ndt = 201 --Виписка з акту огляду МСЕК про встановлення, зняття або зміну групи інвалідності
                                     --AND apda_nda IN (352, 347) --дата встановлення інвалідності, встановлено на період по
                                     GROUP BY xpdf_id)
                              WHERE     td_pdf = x_pdf
                                    AND td_begin BETWEEN x_inv_begin
                                                     AND x_inv_end) >
                            0
                       THEN
                           1
                       ELSE
                           0
                   END
              FROM tmp_tar_dates, tmp_pd_calc_params
             WHERE     td_pd = xpd_id
                   AND xpd_calc_alg = 'KOEF_LGW'
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_pdf_calc_params
                             WHERE td_pdf = xpdf_id);

        SaveMessage ('Розраховуємо суму допомоги на кожного утриманця');

        FOR xx IN (SELECT pd_num
                     FROM tmp_pd_calc_params, pc_decision
                    WHERE     xpd_id = pd_id
                          AND NOT EXISTS
                                  (SELECT 1
                                     FROM pd_income_calc
                                    WHERE pic_pd = xpd_id))
        LOOP
            SaveMessage (
                   'Для рішення <'
                || xx.pd_num
                || '> не виконувався розрахунок доходу - неможливо визначити гілку алгоритму розрахунку розміру допомоги!');
        END LOOP;

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            SELECT 300,
                   300,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      uss_person.api$sc_tools.get_pib (xpdf_sc)
                   || ' дата народж. '
                   || TO_CHAR (xpdf_birth_dt, 'DD.MM.YYYY'),
                   CASE
                       WHEN     0 =
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 110),
                                    0)                    --якшо немає доходів
                            AND 1 =
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 120),
                                    0)                               --інвалід
                       THEN
                             3.5
                           * CASE
                                 WHEN td_begin BETWEEN xpdf_birth_dt
                                                   AND (  ADD_MONTHS (
                                                              xpdf_birth_dt,
                                                              72)
                                                        - 1)   --для до6річних
                                 THEN
                                     lgw_6year_sum
                                 WHEN td_begin BETWEEN xpdf_birth_dt
                                                   AND (  ADD_MONTHS (
                                                              xpdf_birth_dt,
                                                              216)
                                                        - 1)  --для до18річних
                                 THEN
                                     lgw_18year_sum
                                 ELSE
                                     0 --lgw_work_unable_sum --для тих, хто втратив працездатність (і старший за 18 років)
                             END
                       WHEN     0 =
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 110),
                                    0)                    --якшо немає доходів
                            AND 0 =
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 120),
                                    0)                            --не інвалід
                       THEN
                             2.5
                           * CASE
                                 WHEN td_begin BETWEEN xpdf_birth_dt
                                                   AND (  ADD_MONTHS (
                                                              xpdf_birth_dt,
                                                              72)
                                                        - 1)   --для до6річних
                                 THEN
                                     lgw_6year_sum
                                 WHEN td_begin BETWEEN xpdf_birth_dt
                                                   AND (  ADD_MONTHS (
                                                              xpdf_birth_dt,
                                                              216)
                                                        - 1)  --для до18річних
                                 THEN
                                     lgw_18year_sum
                                 ELSE
                                     0 --lgw_work_able_sum --для працездатних (і старший за 18 років)
                             END
                       WHEN     0 <
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 110),
                                    0)                         --якшо є доходи
                            AND 1 =
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 120),
                                    0)                               --інвалід
                       THEN
                               3.5
                             * CASE
                                   WHEN td_begin BETWEEN xpdf_birth_dt
                                                     AND (  ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                72)
                                                          - 1) --для до6річних
                                   THEN
                                       lgw_6year_sum
                                   WHEN td_begin BETWEEN xpdf_birth_dt
                                                     AND (  ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                216)
                                                          - 1) --для до18річних
                                   THEN
                                       lgw_18year_sum
                                   ELSE
                                       0 --lgw_work_unable_sum --для тих, хто втратив працездатність (і старший за 18 років)
                               END
                           - NVL (
                                 (SELECT tdc_value
                                    FROM tmp_pd_detail_calc
                                   WHERE     tdc_pd = td_pd
                                         AND tdc_key = td_pdf
                                         AND tdc_start_dt = td_begin
                                         AND tdc_ndp = 110),
                                 0)
                       WHEN     0 <
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 110),
                                    0)                         --якшо є доходи
                            AND 0 =
                                NVL (
                                    (SELECT tdc_value
                                       FROM tmp_pd_detail_calc
                                      WHERE     tdc_pd = td_pd
                                            AND tdc_key = td_pdf
                                            AND tdc_start_dt = td_begin
                                            AND tdc_ndp = 120),
                                    0)                            --не інвалід
                       THEN
                               2.5
                             * CASE
                                   WHEN td_begin BETWEEN xpdf_birth_dt
                                                     AND (  ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                72)
                                                          - 1) --для до6річних
                                   THEN
                                       lgw_6year_sum
                                   WHEN td_begin BETWEEN xpdf_birth_dt
                                                     AND (  ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                216)
                                                          - 1) --для до18річних
                                   THEN
                                       lgw_18year_sum
                                   ELSE
                                       0 --lgw_work_able_sum --для працездатних (і старший за 18 років)
                               END
                           - NVL (
                                 (SELECT tdc_value
                                    FROM tmp_pd_detail_calc
                                   WHERE     tdc_pd = td_pd
                                         AND tdc_key = td_pdf
                                         AND tdc_start_dt = td_begin
                                         AND tdc_ndp = 110),
                                 0)
                       ELSE
                           0
                   END,
                   31
              FROM tmp_tar_dates,
                   tmp_pdf_calc_params,
                   pd_income_calc,
                   uss_ndi.v_ndi_living_wage  lw,
                   tmp_pd_calc_params
             WHERE     td_pd = pic_pd
                   AND td_pdf = xpdf_id
                   AND lw.history_status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'KOEF_LGW';

        SaveMessage ('Занулюємо відємні значення');

        UPDATE tmp_pd_detail_calc
           SET tdc_value = 0
         WHERE     tdc_value < 0
               AND tdc_ndp = 300
               AND EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE tdc_pd = xpd_id AND xpd_calc_alg = 'KOEF_LGW');
    END;

    PROCEDURE compute_by_const_sum
    IS
    BEGIN
        /*
        SaveMessage('Розраховуємо суму одноразової допомоги константою');
        INSERT INTO tmp_pd_detail_calc (tdc_ndp, tdc_row_order, tdc_key, tdc_pd, tdc_start_dt, tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value, tdc_npt)
          SELECT 300, 300, td_pdf, td_pd, td_begin, td_end,
                 'Нараховано допомоги з усиновлення - одноразова допомога ('||uss_person.api$sc_tools.get_pib(xpdf_sc)||' дата народж. '||to_char(xpdf_birth_dt, 'DD.MM.YYYY')||')',
                 10320.00, 41
          FROM tmp_tar_dates ma, tmp_pd_calc_params, tmp_pdf_calc_params
          WHERE td_begin = (SELECT MIN(sl.td_begin) FROM tmp_tar_dates sl WHERE sl.td_pdf = ma.td_pdf)
            AND td_pd = xpd_id
            AND xpd_calc_alg = 'CONST_SUM'
            AND td_pd = xpdf_pd
            AND td_pdf = xpdf_id;

        SaveMessage('Розраховуємо суму щомісячної допомоги константою');
        INSERT INTO tmp_pd_detail_calc (tdc_ndp, tdc_row_order, tdc_key, tdc_pd, tdc_start_dt, tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value, tdc_npt)
          SELECT 300, 300, td_pdf, td_pd, td_begin, td_end,
                 'Нараховано допомоги з усиновлення - щомісячна допомога ('||uss_person.api$sc_tools.get_pib(xpdf_sc)||' дата народж. '||to_char(xpdf_birth_dt, 'DD.MM.YYYY')||')',
                 860.00, 40
          FROM tmp_tar_dates, tmp_pd_calc_params, tmp_pdf_calc_params
          WHERE td_begin >= ADD_MONTHS(TRUNC(xpd_ap_reg_dt, 'MM'), 1)
            AND td_pd = xpd_id
            AND xpd_calc_alg = 'CONST_SUM'
            AND td_pd = xpdf_pd
            AND td_pdf = xpdf_id;
        */

        SaveMessage (
            'Одноразова допомога константою. Алгоритм А1. Період FST');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            SELECT nncs_ndp,
                   nncs_row_order,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      CHR (38)
                   || nncs_nmt
                   || '#'
                   || uss_person.api$sc_tools.get_pib (xpdf_sc)
                   || '#'
                   || TO_CHAR (xpdf_birth_dt, 'DD.MM.YYYY'),
                   nncs_sum,
                   nncs_npt
              FROM tmp_tar_dates  ma,
                   tmp_pd_calc_params,
                   tmp_pdf_calc_params,
                   uss_ndi.v_ndi_nst_const_sum
             WHERE     td_begin = (SELECT MIN (sl.td_begin)
                                     FROM tmp_tar_dates sl
                                    WHERE sl.td_pdf = ma.td_pdf)
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'CONST_SUM'
                   AND td_pd = xpdf_pd
                   AND td_pdf = xpdf_id
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A1'
                   AND nncs_period_tp = 'FST';

        SaveMessage (
            'Щомісячна допомога константою. Алгоритм A1. Період NXM');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            SELECT nncs_ndp,
                   nncs_row_order,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      CHR (38)
                   || nncs_nmt
                   || '#'
                   || uss_person.api$sc_tools.get_pib (xpdf_sc)
                   || '#'
                   || TO_CHAR (xpdf_birth_dt, 'DD.MM.YYYY'),
                   nncs_sum,
                   nncs_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_pdf_calc_params,
                   uss_ndi.v_ndi_nst_const_sum
             WHERE     td_begin >=
                       ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 1)
                   AND td_end > xpdf_birth_dt
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'CONST_SUM'
                   AND td_pd = xpdf_pd
                   AND td_pdf = xpdf_id
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A1'
                   AND nncs_period_tp = 'NXM';

        SaveMessage (
            'Щомісячна допомога константою. Алгоритм A2. Період ORI');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            SELECT nncs_ndp,
                   nncs_row_order,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      CHR (38)
                   || nncs_nmt
                   || '#'
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || '#'
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY'),
                   nncs_sum,
                   nncs_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_nst_const_sum
             WHERE     td_pd = xpd_id
                   AND td_begin = tc_start_dt
                   AND td_end > tc_birth_dt
                   AND xpd_calc_alg = 'CONST_SUM'
                   AND td_pd = tc_pd
                   AND td_pdf = tc_pdf
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A2'
                   AND nncs_period_tp = 'ORI'
                   AND nncs_is_have18 = tc_is_have18_vpo
                   AND nncs_is_inv = tc_is_inv_vpo
                   AND tc_is_vpo = 'A'                      --#78022  20220616
                                      --      AND td_begin BETWEEN tc_sc_start_dt  AND tc_sc_stop_dt
                                      --      AND td_begin = tc_sc_start_dt
                                      --      AND tc_start_dt IS NOT NULL
                                      ;
    END;

    --Розраховуємо суму допомоги прожитковий мінімум з коефіцієнтом та надбавки аналогічно
    PROCEDURE compute_by_inv_category
    IS
    BEGIN
        SaveMessage (
            'Визначається розмір Державної соціальної допомоги особам з інвалідністю з дитинства та дітям з інвалідністю');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 290,
                   290,
                      'Розмір допомоги '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || CASE
                          WHEN tc_inv_state = 'IZ' AND tc_inv_group = '1'
                          THEN
                              ' (з інвалідністю з дитинства, група інвалідності 1)'
                          WHEN tc_inv_state = 'IZ' AND tc_inv_group = '2'
                          THEN
                              ' (з інвалідністю з дитинства, група інвалідності 2)'
                          WHEN tc_inv_state = 'IZ' AND tc_inv_group = '3'
                          THEN
                              ' (з інвалідністю з дитинства, група інвалідності 3)'
                          WHEN tc_inv_state = 'DI'
                          THEN
                              ' (дитина з інвалідністю)'
                          ELSE
                              ''
                      END,
                   tc_pdf,
                   tc_pd,
                   td_begin,
                   td_end,
                   CASE
                       WHEN tc_inv_state = 'IZ' AND tc_inv_group = '1'
                       THEN
                           lgw_work_unable_sum * 100 / 100
                       WHEN tc_inv_state = 'IZ' AND tc_inv_group = '2'
                       THEN
                           lgw_work_unable_sum * 80 / 100
                       WHEN tc_inv_state = 'IZ' AND tc_inv_group = '3'
                       THEN
                           lgw_work_unable_sum * 60 / 100
                       WHEN tc_inv_state = 'DI'
                       THEN
                           lgw_work_unable_sum * 70 / 100
                       ELSE
                           0
                   END,
                   1
              FROM tmp_tar_dates,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage,
                   tmp_pd_calc_params
             WHERE     td_begin = tc_start_dt
                   AND td_pdf = tc_pdf
                   AND td_pd = tc_pd
                   AND tc_inv_state IN ('IZ', 'DI')
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND history_status = 'A'
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'INV_BY_LGW';

        SaveMessage (
            'Визначається розмір підвищення дітям з інвалідністю внаслідок аварії на ЧАЕС');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 294,
                   294,
                   'Підвищення дітям з інвалідністю внаслідок аварії на ЧАЕС',
                   tc_pdf,
                   tc_pd,
                   tdc.tdc_start_dt,
                   tdc.tdc_stop_dt,
                   tdc_value * 50 / 100,
                   4
              FROM tmp_pd_detail_calc  tdc
                   JOIN tmp_calc_app_params tc
                       ON     tdc.tdc_pd = tc.tc_pd
                          AND tdc.tdc_key = tc.tc_pdf
                          AND tdc.tdc_start_dt = tc.tc_start_dt
             WHERE tdc.tdc_ndp = 290 AND tc.tc_is_child_inv_chaes = 'T';



        SaveMessage ('Визначається розмір надбавки на догляд');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 292,
                   292,
                      'Надбавка на догляд для '
                   || uss_person.api$sc_tools.get_pib (tc_sc),
                   tc_pdf,
                   tc_pd,
                   tdc_start_dt,
                   tdc_stop_dt,
                   CASE
                       WHEN     tc_inv_state = 'IZ'
                            AND tc_inv_group = '1'
                            AND tc_inv_sgroup = 'A'
                       THEN
                             lgw_work_unable_sum
                           * api$pc_decision.get_care_raise ('ALG1',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'IZ'
                            AND tc_inv_group = '1'
                            AND tc_inv_sgroup = 'B'
                       THEN
                             lgw_work_unable_sum
                           * api$pc_decision.get_care_raise ('ALG2',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'IZ'
                            AND tc_inv_group = '2'
                            AND tc_need_care = 'T'
                       THEN
                             lgw_work_unable_sum
                           * api$pc_decision.get_care_raise ('ALG3',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'IZ'
                            AND tc_inv_group = '3'
                            AND tc_need_care = 'T'
                       THEN
                             lgw_work_unable_sum
                           * api$pc_decision.get_care_raise ('ALG4',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'DI'
                            AND tc_inv_child = 'DIA'
                            AND tc_start_dt BETWEEN tc_birth_dt
                                                AND ADD_MONTHS (tc_birth_dt,
                                                                72)
                       THEN
                             lgw_6year_sum
                           * api$pc_decision.get_care_raise ('ALG5',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'DI'
                            AND tc_inv_child = 'DI'
                            AND tc_start_dt BETWEEN tc_birth_dt
                                                AND ADD_MONTHS (tc_birth_dt,
                                                                72)
                       THEN
                             lgw_6year_sum
                           * api$pc_decision.get_care_raise ('ALG6',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'DI'
                            AND tc_inv_child = 'DIA'
                            AND tc_start_dt BETWEEN ADD_MONTHS (tc_birth_dt,
                                                                72)
                                                AND ADD_MONTHS (tc_birth_dt,
                                                                216)
                       THEN
                             lgw_18year_sum
                           * api$pc_decision.get_care_raise ('ALG7',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'DI'
                            AND tc_inv_child = 'DI'
                            AND tc_start_dt BETWEEN ADD_MONTHS (tc_birth_dt,
                                                                72)
                                                AND ADD_MONTHS (tc_birth_dt,
                                                                216)
                       THEN
                             lgw_18year_sum
                           * api$pc_decision.get_care_raise ('ALG8',
                                                             tc_start_dt)
                           / 100
                       ELSE
                           0
                   END,
                   48
              FROM tmp_tar_dates,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage,
                   tmp_pd_detail_calc,
                   tmp_pd_calc_params
             WHERE     td_begin = tc_start_dt
                   AND td_pdf = tc_pdf
                   AND td_pd = tc_pd
                   AND tc_inv_state IN ('IZ', 'DI')
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND history_status = 'A'
                   AND td_begin = tdc_start_dt
                   AND td_pd = tdc_pd
                   AND td_pdf = tdc_key
                   AND tdc_ndp = 290
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND EXISTS
                           (SELECT 1           -- Улучшение #73313  2021.11.24
                              FROM pd_right_log              prl,
                                   uss_ndi.v_ndi_right_rule  nrr
                             WHERE     prl.prl_pd = tdc_pd
                                   AND prl.prl_result = 'T'
                                   AND nrr.nrr_id = prl.prl_nrr
                                   AND nrr.nrr_alg = 'ALG17');

        --      AND tc_is_state_alimony = 'F';

        SaveMessage (
            'Визначається розмір доплати "до ПМ" до Державної соціальної допомоги особам з інвалідністю з дитинства та дітям з інвалідністю');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
              SELECT 291,
                     291,
                     'Адресна допомога (доплата до розміру прожиткового мінімуму для осіб, що втратили працездатність)',
                     tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     CASE
                         WHEN SUM (tdc_value) < lgw_work_unable_sum
                         THEN
                             lgw_work_unable_sum - SUM (tdc_value)
                         ELSE
                             0
                     END,
                     180
                FROM tmp_tar_dates,
                     tmp_calc_app_params,
                     uss_ndi.v_ndi_living_wage,
                     tmp_pd_detail_calc,
                     tmp_pd_calc_params
               WHERE     td_begin = tc_start_dt
                     AND td_pdf = tc_pdf
                     AND td_pd = tc_pd
                     AND tc_inv_state IN ('IZ', 'DI')
                     AND td_begin >= lgw_start_dt
                     AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                     AND history_status = 'A'
                     AND td_begin = tdc_start_dt
                     AND td_pd = tdc_pd
                     AND td_pdf = tdc_key
                     AND tdc_ndp IN (290, 294)
                     AND tdc_value < lgw_work_unable_sum
                     AND td_pd = xpd_id
                     AND xpd_calc_alg = 'INV_BY_LGW'
                     AND NOT EXISTS
                             (SELECT 1
                                FROM tmp_pd_detail_calc pdc1
                               WHERE     pdc1.tdc_pd = tc_pd
                                     AND pdc1.tdc_key = tc_pdf
                                     AND pdc1.tdc_row_order = 292)
              HAVING SUM (tdc_value) < lgw_work_unable_sum
            GROUP BY tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     lgw_work_unable_sum;                  --#73565 2021.11.29

        SaveMessage (
            'Визначається розмір доплати собам з інвалідністю з дитинства I групи, віднесених до підгрупи А');
        SaveMessage (
            'до розміру розміру державної соціальної допомоги з надбавкою на догляд, що виплачується на дітей з інвалідністю підгрупи А віком від 6 до 18 років');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 293,
                   293,
                   'Доплата для осіб з інвалідністю з дитинства I групи, віднесених до підгрупи А',
                   x_pdf,
                   x_pd,
                   x_start_dt,
                   x_stop_dt,
                   CASE
                       WHEN x_value <
                              lgw_work_unable_sum * 70 / 100
                            +   lgw_18year_sum
                              * api$pc_decision.get_care_raise ('ALG7',
                                                                x_start_dt)
                              / 100
                       THEN
                             (  lgw_work_unable_sum * 70 / 100
                              +   lgw_18year_sum
                                * api$pc_decision.get_care_raise ('ALG7',
                                                                  x_start_dt)
                                / 100)
                           - x_value
                       ELSE
                           0
                   END,
                   195
              FROM (  SELECT tdc_pd              AS x_pd,
                             tdc_start_dt        AS x_start_dt,
                             tdc_stop_dt         AS x_stop_dt,
                             tdc_key             AS x_pdf,
                             SUM (tdc_value)     AS x_value
                        FROM tmp_calc_app_params,
                             tmp_pd_detail_calc,
                             tmp_tar_dates,
                             tmp_pd_calc_params
                       WHERE     td_begin = tdc_start_dt
                             AND td_pd = tdc_pd
                             AND td_pdf = tdc_key
                             AND tc_inv_state = 'IZ'
                             AND tc_inv_group = '1'
                             AND tc_inv_sgroup = 'A'
                             AND tdc_ndp IN (290, 292)
                             AND td_begin = tc_start_dt
                             AND td_pdf = tc_pdf
                             AND td_pd = tc_pd
                             AND td_pd = xpd_id
                             AND xpd_calc_alg = 'INV_BY_LGW'
                    GROUP BY tdc_pd,
                             tdc_start_dt,
                             tdc_stop_dt,
                             tdc_key),
                   uss_ndi.v_ndi_living_wage
             WHERE     x_start_dt >= lgw_start_dt
                   AND (x_start_dt <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND history_status = 'A';



        SaveMessage (
            'Визначається розмір "ЩОМІСЯЧНА ДОПЛАТА ДО ДСД (ПОСТ.№118 ВІД 16.02.22)" до Державної соціальної допомоги особам з інвалідністю з дитинства та дітям з інвалідністю');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
              SELECT 295,
                     295,
                     'ЩОМІСЯЧНА ДОПЛАТА ДО ДСД (ПОСТ.№118 ВІД 16.02.22)',
                     tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     CASE
                         WHEN SUM (tdc_value) < nmp_min_sum
                         THEN
                             nmp_min_sum - SUM (tdc_value)
                         ELSE
                             0
                     END,
                     NMP_NPT
                FROM tmp_pd_calc_params
                     JOIN tmp_tar_dates ON td_pd = xpd_id
                     JOIN tmp_calc_app_params
                         ON     tc_pd = td_pd
                            AND tc_pdf = td_pdf
                            AND tc_start_dt = td_begin
                     JOIN tmp_pd_detail_calc
                         ON     tdc_pd = td_pd
                            AND tdc_key = td_pdf
                            AND tdc_start_dt = td_begin
                     JOIN uss_ndi.v_ndi_min_payment m
                         ON     m.nmp_nst = xpd_nst
                            AND NMP_COMPARE_SUM_ALG = 'SALL'
                            AND NMP_MIN_SUM_ALG = 'ABS'
                            AND td_begin >= nmp_start_dt
                            AND (td_begin <= nmp_stop_dt OR nmp_stop_dt IS NULL)
                            AND history_status = 'A'
               WHERE     tdc_ndp IN (290,
                                     291,
                                     292,
                                     293,
                                     294)
                     AND xpd_calc_alg = 'INV_BY_LGW'
                     AND tdc_value < m.nmp_min_sum
              HAVING SUM (tdc_value) < nmp_min_sum
            GROUP BY tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     nmp_min_sum,
                     NMP_NPT;                             --#79928  2022.09.08
    END;

    --Розраховуємо суму допомоги як порівняння прожиткового мінімуму сім'ї та рівня забезпечення ПМ
    PROCEDURE compute_by_lgw_leveling
    IS
    BEGIN
        SaveMessage ('Розраховуємо розмір ПМ для сім`ї');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value)
            SELECT 130,
                   130,
                      --#74301 2021.12.22
                      'Прожитковий мінімум для '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || CASE
                          WHEN     tc_birth_dt IS NOT NULL
                               AND tc_inv_state IN ('I', 'IZ')
                               AND tc_is_working = 'F'
                          THEN
                                 ' (вік '
                              || TRUNC (
                                       MONTHS_BETWEEN (tc_start_dt,
                                                       tc_birth_dt)
                                     / 12,
                                     0)
                              || ' років, інвалідність, не працює)'
                          WHEN     tc_birth_dt IS NOT NULL
                               AND tc_inv_state IN ('I', 'IZ')
                               AND tc_is_working = 'T'
                          THEN
                                 ' (вік '
                              || TRUNC (
                                       MONTHS_BETWEEN (tc_start_dt,
                                                       tc_birth_dt)
                                     / 12,
                                     0)
                              || ' років, інвалідність, працює)'
                          WHEN     tc_birth_dt IS NULL
                               AND tc_inv_state IN ('I', 'IZ')
                               AND tc_is_working = 'F'
                          THEN
                              ' (відсутня дата народження, інвалідність, не працює)'
                          WHEN     tc_birth_dt IS NULL
                               AND tc_inv_state IN ('I', 'IZ')
                               AND tc_is_working = 'T'
                          THEN
                              ' (відсутня дата народження, інвалідність, працює)'
                          WHEN tc_birth_dt IS NOT NULL
                          THEN
                                 ' (вік '
                              || TRUNC (
                                       MONTHS_BETWEEN (tc_start_dt,
                                                       tc_birth_dt)
                                     / 12,
                                     0)
                              || ' років)'
                          ELSE
                              ' (відсутня дата народження)'
                      END,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   CASE
                       WHEN tc_start_dt BETWEEN tc_birth_dt
                                            AND ADD_MONTHS (tc_birth_dt, 72)
                       THEN
                           lgw_6year_sum
                       WHEN tc_start_dt BETWEEN ADD_MONTHS (tc_birth_dt, 72)
                                            AND ADD_MONTHS (tc_birth_dt, 216)
                       THEN
                           lgw_18year_sum
                       --особа з інвалідністю, яка непрацює
                       WHEN     tc_inv_state IN ('I', 'IZ')
                            AND tc_start_dt BETWEEN tc_inv_start_dt
                                                AND tc_inv_stop_dt
                            AND tc_is_working = 'F'
                       THEN
                           lgw_work_unable_sum
                       --#75892 2022,02,23
                       --Для особи вік якої більше рівне 60 років, визначати рівень забезпечення прожиткового мінімуму:
                       --% рівня забезпечення прожиткового мінімуму для осіб, які втратили працездатність * прожитковий мінімум для осіб, які втратили працездатність
                       WHEN tc_start_dt >= ADD_MONTHS (tc_birth_dt, 720)
                       THEN
                           lgw_work_unable_sum
                       WHEN     tc_start_dt > ADD_MONTHS (tc_birth_dt, 216)
                            AND tc_is_work_able = 'T'
                       THEN
                           lgw_work_able_sum
                       WHEN     tc_start_dt > ADD_MONTHS (tc_birth_dt, 216)
                            AND tc_is_work_able = 'F'
                       THEN
                           lgw_work_unable_sum
                       ELSE
                           lgw_cmn_sum
                   END
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'LGW_LEVEL'
                   AND history_Status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL);

        SaveMessage ('Розраховуємо розмір рівня забезпечення ПМ для сім`ї');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value)
            SELECT 131,
                   131,
                      'Розмір рівня забезпечення для '
                   || uss_person.api$sc_tools.get_pib (tc_sc),
                   tdc_key,
                   tdc_pd,
                   tdc_start_dt,
                   tdc_stop_dt,
                     tdc_value
                   * CASE
                         WHEN tc_start_dt BETWEEN tc_birth_dt
                                              AND ADD_MONTHS (tc_birth_dt,
                                                              216)
                         THEN
                             nlsl_18year_level
                         --Для особи, яка в зверненні щодо допомоги малозабезпеченій сім'ї має анкету, в якій ступінь родинного зв'язку=син/донька,
                         --у якої серед документів наявна довідка про навчання, у якій в період навчання входить "Дата подання заяви":
                         WHEN     XPD_AP_REG_DT BETWEEN tc_study_start_dt
                                                    AND tc_study_stop_dt
                              AND tc_FamilyConnect = 'B'
                         THEN
                             nlsl_18year_level
                         --особа з інвалідністю, яка непрацює
                         WHEN     tc_inv_state IN ('I', 'IZ')
                              AND tc_start_dt BETWEEN tc_inv_start_dt
                                                  AND tc_inv_stop_dt
                              AND tc_is_working = 'F'
                         THEN
                             nlsl_work_unable_level
                         --#75892 2022,02,23
                         --Для особи вік якої більше рівне 60 років, визначати рівень забезпечення прожиткового мінімуму:
                         --% рівня забезпечення прожиткового мінімуму для осіб, які втратили працездатність * прожитковий мінімум для осіб, які втратили працездатність
                         WHEN tc_start_dt >= ADD_MONTHS (tc_birth_dt, 720)
                         THEN
                             nlsl_work_unable_level
                         WHEN     tc_start_dt > ADD_MONTHS (tc_birth_dt, 216)
                              AND tc_is_work_able = 'T'
                         THEN
                             nlsl_work_able_level
                         WHEN     tc_start_dt > ADD_MONTHS (tc_birth_dt, 216)
                              AND tc_is_work_able = 'F'
                         THEN
                             nlsl_work_unable_level
                         ELSE
                             nlsl_work_able_level
                     END
                   * DECODE (xpd_mount_live, 'T', 1.2, 1)
                   / 100
              FROM tmp_pd_detail_calc,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_lgw_sub_level
             WHERE     tdc_pd = xpd_id
                   AND tdc_key = tc_pdf
                   AND tdc_start_dt = tc_start_dt
                   AND history_status = 'A'
                   AND tdc_start_dt >= nlsl_start_dt
                   AND (tdc_start_dt <= nlsl_stop_dt OR nlsl_stop_dt IS NULL);

        SaveMessage ('Розраховуємо сукупний ПМ для сім`ї');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value)
              SELECT 132,
                     132,
                     'Рівень забезпечення прожиткового мінімуму сім`ї',
                     NULL,
                     tdc_pd,
                     cd_begin,
                     cd_end,
                     SUM (tdc_value)
                FROM tmp_pd_detail_calc, tmp_calc_dates
               WHERE     tdc_ndp = 131
                     AND tdc_pd = cd_pd
                     AND tdc_start_dt BETWEEN cd_begin AND cd_end
            GROUP BY tdc_pd, cd_begin, cd_end;

        SaveMessage (
            'Розраховуємо сукупний рівень забезпечення ПМ для сім`ї');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value)
              SELECT 133,
                     133,
                     'Обмеження розміру допомоги (прожитковий мінімум сім`ї)',
                     NULL,
                     tdc_pd,
                     cd_begin,
                     cd_end,
                     SUM (tdc_value)
                FROM tmp_pd_detail_calc, tmp_calc_dates
               WHERE     tdc_ndp = 130
                     AND tdc_pd = cd_pd
                     AND tdc_start_dt BETWEEN cd_begin AND cd_end
            GROUP BY tdc_pd, cd_begin, cd_end;

        SaveMessage ('Розраховуємо суму допомоги малозабезпеченим сім’ям');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            WITH
                periods
                AS
                    (SELECT cd_pd        AS i_pd,
                            cd_begin     AS i_start_dt,
                            cd_end       AS i_end
                       FROM tmp_calc_dates),
                sums
                AS
                    (  SELECT tdc_pd
                                  AS z_pd,
                              tdc_start_dt
                                  AS z_start_dt,
                              tdc_stop_dt
                                  AS z_stop_dt,
                              SUM (DECODE (tdc_ndp, 133, tdc_value, 0))
                                  AS z_rpms_sum,
                              SUM (DECODE (tdc_ndp, 132, tdc_value, 0))
                                  AS z_zpms_sum
                         FROM tmp_pd_detail_calc
                        WHERE tdc_ndp IN (132, 133)
                     GROUP BY tdc_pd, tdc_start_dt, tdc_stop_dt)
            SELECT 300,
                   300,
                   NULL,
                   i_pd,
                   i_start_dt,
                   i_end,
                   'Допомога малозабезпеченим сім`ям',
                   CASE
                       WHEN     z_zpms_sum - xpd_family_income > z_rpms_sum
                            AND xpd_mount_live = 'T'
                       THEN
                           z_zpms_sum - xpd_family_income
                       WHEN     z_zpms_sum - xpd_family_income > z_rpms_sum
                            AND xpd_mount_live = 'F'
                       THEN
                           z_rpms_sum
                       ELSE
                           z_zpms_sum - xpd_family_income
                   END,
                   45
              FROM periods, sums, tmp_pd_calc_params
             WHERE     i_pd = xpd_id
                   AND i_pd = z_pd
                   AND i_start_dt BETWEEN z_start_dt AND z_stop_dt;

        --AND i_start_dt = z_start_dt;

        --#73911 2021,12,14
        SaveMessage (
            'Скоригуємо суму допомоги малозабезпеченим сім’ям, якщо вона від''ємна');

        UPDATE tmp_pd_detail_calc
           SET tdc_value =
                   (CASE WHEN tdc_value < 0 THEN 0 ELSE tdc_value END)
         WHERE tdc_ndp = 300;
    END;

    PROCEDURE collect_breakpoints
    IS
    BEGIN
        SaveMessage ('Отримуємо розриви за періодом розрахунку');

        --Отримуємо розриви за періодом розрахунку (для послуг з групуванням по утриманцям xpdf_id=-c_pd, тому зайвих записів не буде)
        INSERT INTO tmp_tar_dates1 (ttd_pd,
                                    ttd_pdf,
                                    ttd_dt,
                                    ttd_source)
            SELECT c_pd,
                   xpdf_id,
                   c_start_dt,
                   1
              FROM tmp_calc_pd, tmp_pd_calc_params, tmp_pdf_calc_params
             WHERE c_pd = xpd_id AND c_pd = xpdf_pd
            UNION ALL
            SELECT c_pd,
                   xpdf_id,
                   ADD_MONTHS (c_start_dt, 1),
                   1
              FROM tmp_calc_pd,
                   tmp_pd_calc_params,
                   tmp_pdf_calc_params,
                   uss_ndi.v_ndi_nst_calc_config
             WHERE     c_pd = xpd_id
                   AND c_pd = xpdf_pd
                   AND xpd_nst = ncc_nst
                   AND ncc_break_1months = 'T'
            UNION ALL
            SELECT c_pd,
                   xpdf_id,
                   c_stop_dt,
                   2
              FROM tmp_calc_pd, tmp_pd_calc_params, tmp_pdf_calc_params
             WHERE c_pd = xpd_id AND c_pd = xpdf_pd;

        IF is_have_nst_by_alg ('BREAK_LGW', 'T') > 0
        THEN
            SaveMessage (
                'Розриви по зміні прожиткового мінімуму в періоді розрахунку');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT c_pd,
                       xpdf_id,
                       lgw_start_dt,
                       3
                  FROM tmp_calc_pd,
                       tmp_pdf_calc_params,
                       tmp_pd_calc_params,
                       uss_ndi.v_ndi_living_wage  lw,
                       uss_ndi.v_ndi_nst_calc_config
                 WHERE     c_pd = xpdf_pd
                       AND c_pd = xpd_id
                       AND lw.history_status = 'A'
                       AND lgw_start_dt BETWEEN c_start_dt AND c_stop_dt
                       AND xpd_nst = ncc_nst
                       AND ncc_break_lgw = 'T';
        END IF;

        IF is_have_nst_by_alg ('BREAK_LGW_LEVEL', 'T') > 0
        THEN
            SaveMessage (
                'Розриви по зміні прожиткового мінімуму в періоді розрахунку');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT c_pd,
                       xpdf_id,
                       nlsl_start_dt,
                       3
                  FROM tmp_calc_pd,
                       tmp_pdf_calc_params,
                       tmp_pd_calc_params,
                       uss_ndi.v_ndi_lgw_sub_level  nl,
                       uss_ndi.v_ndi_nst_calc_config
                 WHERE     c_pd = xpdf_pd
                       AND c_pd = xpd_id
                       AND nl.history_status = 'A'
                       AND nlsl_start_dt BETWEEN c_start_dt AND c_stop_dt
                       AND xpd_nst = ncc_nst
                       AND ncc_break_lgw_level = 'T';
        END IF;

        IF is_have_nst_by_alg ('BREAK_BIRTH', 'T') > 0
        THEN
            SaveMessage ('Дати народження утриманців - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       4
                  FROM (SELECT c_pd              AS z_pd,
                               xpdf_id           AS z_pdf,
                               xpdf_birth_dt     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_birth = 'T')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_BIRTH', 'TR') > 0
        THEN
            SaveMessage ('Дати народження утриманців - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       4
                  FROM (SELECT c_pd                            AS z_pd,
                               xpdf_id                         AS z_pdf,
                               TRUNC (xpdf_birth_dt, 'mm')     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_birth = 'TR')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_6YEARS', 'T') > 0
        THEN
            SaveMessage (
                'Дати настання повних 6 років утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       5
                  FROM (SELECT c_pd                               AS z_pd,
                               xpdf_id                            AS z_pdf,
                               ADD_MONTHS (xpdf_birth_dt, 72)     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_6years = 'T')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_18YEARS', 'T') > 0
        THEN
            SaveMessage (
                'Дати настання повних 18 років утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       6
                  FROM (SELECT c_pd                                AS z_pd,
                               xpdf_id                             AS z_pdf,
                               ADD_MONTHS (xpdf_birth_dt, 216)     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'T')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        ELSIF is_have_nst_by_alg ('BREAK_18YEARS', 'EM') > 0
        THEN
            SaveMessage (
                'Місяць настання повних 18 років утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       6
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               LAST_DAY (ADD_MONTHS (xpdf_birth_dt, 216)) + 1
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt                       --Ошибка #73294
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'EM')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;


        IF is_have_nst_by_alg ('BREAK_23YEARS', 'T') > 0
        THEN
            SaveMessage (
                'Дати настання повних 23 років утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       7
                  FROM (SELECT c_pd                                AS z_pd,
                               xpdf_id                             AS z_pdf,
                               ADD_MONTHS (xpdf_birth_dt, 276)     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_6years = 'T')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_INV', 'T') > 0
        THEN
            SaveMessage (
                'Дати початку та періоду періоду, на який встановлено інвалідність - теж розриви');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       8
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf, --Медичний висновок (для дітей інвалідів до 18 років) - встановлено на період по
                               Api$account.get_docx_dt (xpdf_pd,
                                                        xpdf_sc,
                                                        200,
                                                        793,
                                                        xpd_calc_dt)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'T')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                --Дата встановлення інвалідністі - теж розрив
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       9
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf, --Медичний висновок (для дітей інвалідів до 18 років) - встановлено на період по
                               --API$PC_DECISION.get_doc_dt(xpdf_app, 200, 792, xpd_calc_dt) AS z_dt, c_start_dt, c_stop_dt
                               Api$account.get_docx_dt (xpdf_pd,
                                                        xpdf_sc,
                                                        200,
                                                        793,
                                                        xpd_calc_dt)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'T')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        ELSIF is_have_nst_by_alg ('BREAK_INV', 'X') > 0
        THEN
            SaveMessage (
                'Дати початку та періоду періоду, на який встановлено інвалідність учасника - теж розриви');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       10
                  FROM (SELECT tc_pd                  AS z_pd,
                               tc_pdf                 AS z_pdf,
                               tc_inv_stop_dt + 1     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_calc_app_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'X')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                --Дата встановлення інвалідністі - теж розрив
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       11
                  FROM (SELECT tc_pd               AS z_pd,
                               tc_pdf              AS z_pdf,
                               tc_inv_start_dt     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_calc_app_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'X')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        ELSIF is_have_nst_by_alg ('BREAK_INV', 'TR') > 0
        THEN
            SaveMessage (
                'Дати початку та періоду періоду, на який встановлено інвалідність учасника - теж розриви');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       10
                  FROM (SELECT tc_pd                                 AS z_pd,
                               tc_pdf                                AS z_pdf,
                               LAST_DAY (TRUNC (tc_inv_stop_dt))     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_calc_app_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'TR')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                --Дата встановлення інвалідністі - теж розрив
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       11
                  FROM (SELECT tc_pd                             AS z_pd,
                               tc_pdf                            AS z_pdf,
                               TRUNC (tc_inv_start_dt, 'mm')     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_calc_app_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'TR')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_RAISE', 'T') > 0
        THEN
            SaveMessage ('Дати зміни проценту надбавки - розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT c_pd,
                       xpdf_id,
                       ncr_start_dt,
                       12
                  FROM tmp_calc_pd,
                       tmp_pdf_calc_params,
                       uss_ndi.v_ndi_care_raise  ncr,
                       tmp_pd_calc_params,
                       uss_ndi.v_ndi_nst_calc_config
                 WHERE     c_pd = xpdf_pd
                       AND ncr.history_status = 'A'
                       AND ncr_start_dt BETWEEN c_start_dt AND c_stop_dt
                       AND xpd_id = c_pd
                       AND xpd_nst = ncc_nst
                       AND ncc_break_raise = 'T';
        END IF;

        IF is_have_nst_by_alg ('BREAK_DN', 'T') > 0
        THEN
            SaveMessage (
                'Дати зміни історії відрахувань - розрив для відповідних послуг');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT c_pd,
                       xpdf_id,
                       dnd_start_dt,
                       13
                  FROM tmp_calc_pd,
                       tmp_pdf_calc_params,
                       deduction,
                       dn_detail  dnd,
                       tmp_pd_calc_params,
                       uss_ndi.v_ndi_nst_calc_config,
                       uss_ndi.v_ndi_nst_dn_config
                 WHERE     c_pd = xpdf_pd
                       AND xpd_pc = dn_pc
                       AND dnd_dn = dn_id
                       --AND dn_st = 'R'
                       AND dnd.history_status = 'A'
                       AND dnd_start_dt BETWEEN c_start_dt AND c_stop_dt
                       AND xpd_id = c_pd
                       AND xpd_nst = ncc_nst
                       AND ncc_break_dn = 'T'
                       AND xpd_nst = nnnc_nst
                       AND nnnc_ndn = dn_ndn;
        END IF;

        IF is_have_nst_by_alg ('BREAK_BD', 'T') > 0
        THEN
            SaveMessage ('Дати зміни історії бойових дій - розрив для ВПО');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                WITH
                    kaots_prev_next
                    AS
                        (SELECT kaots_id,
                                kaots_kaot,
                                kaots_start_dt,
                                kaots_stop_dt,
                                LAG (kaots_stop_dt)
                                    OVER (PARTITION BY kaots_kaot
                                          ORDER BY kaots_start_dt ASC)
                                    PREV_stop_dt,
                                LEAD (kaots_id)
                                    OVER (PARTITION BY kaots_kaot
                                          ORDER BY kaots_start_dt ASC)
                                    NEXT_id,
                                LEAD (kaots_start_dt)
                                    OVER (PARTITION BY kaots_kaot
                                          ORDER BY kaots_start_dt ASC)
                                    NEXT_start_dt
                           FROM uss_ndi.v_NDI_KAOT_STATE
                          WHERE history_status = 'A' AND kaots_tp = 'BD'),
                    kaots_start
                    AS
                        (SELECT S.kaots_id,
                                S.kaots_kaot,
                                S.kaots_start_dt,
                                S.kaots_stop_dt
                           FROM kaots_prev_next s
                          WHERE    PREV_stop_dt IS NULL
                                OR S.kaots_start_dt != PREV_stop_dt + 1),
                    kaots_history
                    AS
                        (SELECT S.kaots_id,
                                S.kaots_kaot,
                                S.kaots_start_dt,
                                S.kaots_stop_dt,
                                CASE
                                    WHEN S.kaots_stop_dt + 1 = next_start_dt
                                    THEN
                                        NEXT_id
                                END    AS NEXT_id
                           FROM kaots_prev_next s)
                    SELECT z_pd,
                           z_pdf,
                           z_dt,
                           14
                      FROM (SELECT tc_pd                            AS z_pd,
                                   tc_pdf                           AS z_pdf,
                                   c_start_dt,
                                   c_stop_dt,
                                   TRUNC (kaots_start_dt, 'MM')     AS z_dt
                              FROM tmp_calc_pd
                                   JOIN tmp_pd_calc_params ON xpd_id = c_pd
                                   JOIN tmp_calc_app_params ON tc_pd = c_pd
                                   JOIN uss_ndi.v_NDI_KATOTTG
                                       ON     kaot_id = tc_bd_kaot_id
                                          AND kaot_st = 'A'
                                   JOIN kaots_start kh
                                       ON kaot_kaot_l3 = kaots_kaot
                                   JOIN uss_ndi.v_ndi_nst_calc_config
                                       ON xpd_nst = ncc_nst
                             WHERE     ncc_break_BD = 'T'
                                   AND kaots_start_dt BETWEEN c_start_dt
                                                          AND c_stop_dt)
                     WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                    UNION ALL
                    SELECT z_pd,
                           z_pdf,
                           z_dt,
                           15
                      FROM (SELECT z_pd, z_pdf, LAST_DAY (z_dt) + 1 AS z_dt
                              FROM (SELECT tc_pd                         AS z_pd,
                                           tc_pdf                        AS z_pdf,
                                           c_start_dt,
                                           c_stop_dt,
                                           --                           ( SELECT MAX(kaots_stop_dt)
                                            (    SELECT MAX (
                                                            NVL (
                                                                kaots_stop_dt,
                                                                TO_DATE (
                                                                    '01.01.3000',
                                                                    'dd.mm.yyyy')))
                                                   FROM kaots_history nkh
                                             START WITH nkh.kaots_id =
                                                        kh.kaots_id
                                             CONNECT BY PRIOR nkh.NEXT_id =
                                                        nkh.kaots_id)    AS z_dt
                                      FROM tmp_calc_pd
                                           JOIN tmp_pd_calc_params
                                               ON xpd_id = c_pd
                                           JOIN tmp_calc_app_params
                                               ON tc_pd = c_pd
                                           JOIN uss_ndi.v_NDI_KATOTTG
                                               ON     kaot_id = tc_bd_kaot_id
                                                  AND kaot_st = 'A'
                                           JOIN kaots_start kh
                                               ON kaot_kaot_l3 = kaots_kaot
                                           JOIN uss_ndi.v_ndi_nst_calc_config
                                               ON xpd_nst = ncc_nst
                                     WHERE ncc_break_BD = 'T')
                             WHERE z_dt BETWEEN c_start_dt AND c_stop_dt);
        END IF;

        IF is_have_nst_by_alg ('BREAK_PDF_PERIOD', 'T') > 0
        THEN
            SaveMessage ('Дати додавання та видалення персон - розрив ');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       16
                  FROM (SELECT tc_pd                              AS z_pd,
                               tc_pdf                             AS z_pdf,
                               TRUNC (a.tc_sc_start_dt, 'MM')     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON xpd_id = c_pd
                               JOIN tmp_calc_app_params a ON tc_pd = c_pd
                               JOIN uss_ndi.v_ndi_nst_calc_config
                                   ON xpd_nst = ncc_nst
                         WHERE ncc_break_pdf_period = 'T')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       161
                  FROM (SELECT tc_pd
                                   AS z_pd,
                               tc_pdf
                                   AS z_pdf,
                               ADD_MONTHS (TRUNC (a.tc_sc_start_dt, 'MM'), 1)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON xpd_id = c_pd
                               JOIN tmp_calc_app_params a ON tc_pd = c_pd
                               JOIN uss_ndi.v_ndi_nst_calc_config
                                   ON xpd_nst = ncc_nst
                         WHERE ncc_break_pdf_period = 'T')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       17
                  FROM (SELECT tc_pd                 AS z_pd,
                               tc_pdf                AS z_pdf,
                               tc_sc_stop_dt + 1     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON xpd_id = c_pd
                               JOIN tmp_calc_app_params ON tc_pd = c_pd
                               JOIN uss_ndi.v_ndi_nst_calc_config
                                   ON xpd_nst = ncc_nst
                         WHERE ncc_break_pdf_period = 'T')
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;
    END;

    PROCEDURE collect_features
    IS
    BEGIN
        SaveMessage ('Обраховуємо ознаки рішень');

        INSERT INTO pd_features (pde_pd,
                                 pde_nft,
                                 pde_val_dt,
                                 pde_val_string,
                                 pde_pdf)
            SELECT pd_id,
                   nft_id,
                   DECODE (nft_id,  2, nft_2,  7, nft_7,  8, nft_8),
                   DECODE (nft_id,
                           1, nft_1,
                           3, nft_3,
                           4, nft_4,
                           5, nft_5,
                           6, nft_6),
                   (SELECT pdf_id
                      FROM pd_family
                     WHERE pdf_sc = app_sc AND pdf_pd = pd_id)
              FROM (SELECT pd_id,
                           app.app_sc,
                           nft_id,
                           (SELECT MIN (API$PC_DECISION.get_doc_dt (
                                            p.app_id,
                                            10034,
                                            923,
                                            pd_start_dt))
                              FROM ap_person p
                             WHERE     p.app_ap = ps_ap
                                   AND p.history_status = 'A')
                               AS nft_2,                    --Дата зарахування
                           COALESCE (
                               API$PC_DECISION.get_doc_dt (app.app_id,
                                                           200,
                                                           792,
                                                           pd_start_dt),
                               API$PC_DECISION.get_doc_dt (app.app_id,
                                                           201,
                                                           352,
                                                           pd_start_dt),
                               API$PC_DECISION.get_doc_dt (app.app_id,
                                                           809,
                                                           1939,
                                                           pd_start_dt))
                               AS nft_7, --  Дата встановлення інвалідності з медогляду МСЕК або мед.висновнку по дитині
                           COALESCE (
                               API$PC_DECISION.get_doc_dt (app.app_id,
                                                           200,
                                                           793,
                                                           pd_start_dt),
                               API$PC_DECISION.get_doc_dt (app.app_id,
                                                           201,
                                                           347,
                                                           pd_start_dt),
                               API$PC_DECISION.get_doc_dt (app.app_id,
                                                           809,
                                                           1806,
                                                           pd_start_dt))
                               AS nft_8,          --  встановлено на період по
                           uss_person.api$sc_tools.get_pib (app.app_sc)
                               AS nft_1,
                           COALESCE (API$PC_DECISION.get_doc_string (
                                         app.app_id,
                                         201,
                                         349,
                                         pd_start_dt),
                                     API$PC_DECISION.get_doc_string (
                                         app.app_id,
                                         809,
                                         1937,
                                         pd_start_dt))
                               AS nft_3,                  --група інвалідності
                           COALESCE (API$PC_DECISION.get_doc_string (
                                         app.app_id,
                                         201,
                                         791,
                                         pd_start_dt),
                                     API$PC_DECISION.get_doc_string (
                                         app.app_id,
                                         809,
                                         1938,
                                         pd_start_dt))
                               AS nft_4,               --підгрупа інвалідності
                           API$PC_DECISION.get_doc_string (app.app_id,
                                                           201,
                                                           353,
                                                           pd_start_dt)
                               AS nft_5,                --причина інвалідності
                           API$PC_DECISION.get_doc_string (app.app_id,
                                                           200,
                                                           797,
                                                           pd_start_dt)
                               AS nft_6                            --категорія
                      FROM tmp_work_ids,
                           pc_decision,
                           ap_person         app,
                           pc_state_alimony  psa,
                           uss_ndi.v_ndi_pd_feature_type
                     WHERE     pd_nst = 248
                           AND nft_id BETWEEN 1 AND 8
                           AND x_id = pd_id
                           AND pd_ap = app_ap
                           AND app.history_status = 'A'
                           AND psa.ps_id(+) = pd_ps
                           AND EXISTS
                                   (SELECT 1
                                      FROM ap_document
                                     WHERE     apd_app = app.app_id
                                           AND apd_ndt IN (200,
                                                           201,
                                                           809,
                                                           10034)));
    END;


    PROCEDURE calc_service
    IS
    BEGIN
        SaveMessage ('Чистимо допоміжні таблиці');
        clean_temp_tables;

        --  Функція формування історіі персон та документів звернення
        --  на підставі звернень у tmp_work_ids
        API$ACCOUNT.init_tmp_for_pd;

        SaveMessage ('Отримання параметрів рішення та звернення');
        obtain_pd_params;

        SaveMessage ('Видаляємо ознаки по рішенню');                         --Всі - бо невідомо, які будуть утриманці та нові ознаки

        DELETE FROM pd_features
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_work_ids
                          WHERE pde_pd = x_id);

        IF is_have_nst_by_alg ('APP_GROUP', 'PER_APP') > 0
        THEN
            SaveMessage ('Рахуємо утриманців');
            SaveMessage ('Видаляємо всіх утриманців з рішення');

            DELETE FROM pd_family
                  WHERE EXISTS
                            (SELECT 1
                               FROM tmp_work_ids,
                                    tmp_pd_calc_params,
                                    uss_ndi.v_ndi_nst_calc_config
                              WHERE     xpd_id = x_id
                                    AND xpd_id = pdf_pd
                                    AND xpd_nst = ncc_nst
                                    AND ncc_app_group = 'PER_APP');

            SaveMessage (
                'Добавляємо тих утримацнців зі звернення, яких немає в рішенні');

            INSERT INTO pd_family (pdf_id,
                                   pdf_sc,
                                   pdf_pd,
                                   pdf_birth_dt)
                SELECT 0,
                       tpp_sc,
                       xpd_id, --Свідоцтво про народження дитини - Дата народження або дата народження з соцкартки
                       COALESCE (
                           API$ACCOUNT.get_docx_dt (tpp_pd,
                                                    tpp_sc,
                                                    37,
                                                    91,
                                                    xpd_calc_dt),
                           API$ACCOUNT.get_docx_dt (tpp_pd,
                                                    tpp_sc,
                                                    165,
                                                    331,
                                                    xpd_calc_dt),
                           API$ACCOUNT.get_docx_dt (tpp_pd,
                                                    tpp_sc,
                                                    6,
                                                    606,
                                                    xpd_calc_dt),
                           API$ACCOUNT.get_docx_dt (tpp_pd,
                                                    tpp_sc,
                                                    7,
                                                    607,
                                                    xpd_calc_dt),
                           API$ACCOUNT.get_docx_dt (tpp_pd,
                                                    tpp_sc,
                                                    8,
                                                    2014,
                                                    xpd_calc_dt),
                           API$ACCOUNT.get_docx_dt (tpp_pd,
                                                    tpp_sc,
                                                    9,
                                                    2015,
                                                    xpd_calc_dt),
                           API$ACCOUNT.get_docx_dt (tpp_pd,
                                                    tpp_sc,
                                                    11,
                                                    2329,
                                                    xpd_calc_dt),
                           API$ACCOUNT.get_docx_dt (tpp_pd,
                                                    tpp_sc,
                                                    13,
                                                    2016,
                                                    xpd_calc_dt),
                           API$ACCOUNT.get_docx_dt (tpp_pd,
                                                    tpp_sc,
                                                    673,
                                                    762,
                                                    xpd_calc_dt),
                           uss_person.api$sc_tools.get_birthdate (tpp_sc))
                  FROM tmp_pd_calc_params
                       JOIN tmp_pa_persons
                           ON     tpp_pd = xpd_id
                              AND xpd_calc_dt BETWEEN tpp_dt_from
                                                  AND tpp_dt_to,
                       uss_ndi.v_ndi_nst_calc_config
                 WHERE     (   (ncc_app_list_alg = 'FP' AND tpp_app_tp = 'FP')
                            OR (    ncc_app_list_alg = 'FML'
                                AND tpp_app_tp IN ('Z', 'FM', 'FP')))
                       AND xpd_nst = ncc_nst
                       AND ncc_app_group = 'PER_APP'
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM pd_family
                                 WHERE pdf_pd = xpd_id AND pdf_sc = tpp_sc);
        /*
              FROM tmp_pd_calc_params
                   JOIN tmp_pa_persons ON tpp_pd = xpd_id AND xpd_calc_dt BETWEEN tpp_dt_from AND tpp_dt_to
                   JOIN ap_person ON tpp_app = app_id AND ap_person.history_status = 'A',
                   uss_ndi.v_ndi_nst_calc_config
              WHERE
                ( (ncc_app_list_alg = 'FP' AND app_tp = 'FP')
                  OR
                  (ncc_app_list_alg = 'FML' AND app_tp IN ('Z', 'FM', 'FP'))
                )
                AND xpd_nst = ncc_nst
                AND ncc_app_group = 'PER_APP'
                AND NOT EXISTS (SELECT 1
                                FROM pd_family
                                WHERE pdf_pd = xpd_id
                                  AND pdf_sc = app_sc);
        */
        /*
              FROM tmp_pd_calc_params, ap_person, uss_ndi.v_ndi_nst_calc_config
              WHERE xpd_ap = app_ap
                AND ((ncc_app_list_alg = 'FP' AND app_tp = 'FP')
                  OR (ncc_app_list_alg = 'FML' AND app_tp IN ('Z', 'FM', 'FP')))
                AND ap_person.history_status = 'A'
                AND xpd_nst = ncc_nst
                AND ncc_app_group = 'PER_APP'
                AND NOT EXISTS (SELECT 1
                                FROM pd_family
                                WHERE pdf_pd = xpd_id
                                  AND pdf_sc = app_sc);
        */
        END IF;

        SaveMessage ('Отримання параметрів утриманців, якщо потрібно');
        obtain_pdf_params;


        SaveMessage ('Обраховуємо період розрахунку');

        IF is_have_nst_by_alg ('CALC_PERIOD', '6MONTHS') > 0
        THEN
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                SELECT xpd_id,
                       TRUNC (xpd_ap_reg_dt, 'MM'),
                       ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 6)
                  FROM tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config
                 WHERE     xpd_nst = ncc_nst
                       AND ncc_calc_period = '6MONTHS'
                       AND NCC_PD_PERIOD_ALG = 'TR_AP_REG'
                UNION ALL
                SELECT xpd_id, xpd_ap_reg_dt, ADD_MONTHS (xpd_ap_reg_dt, 6) --#73932 2021.12.10
                  FROM tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config
                 WHERE     xpd_nst = ncc_nst
                       AND ncc_calc_period = '6MONTHS'
                       AND NCC_PD_PERIOD_ALG = 'AP_REG';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', '12MONTHS') > 0
        THEN
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                SELECT xpd_id,
                       TRUNC (xpd_ap_reg_dt, 'MM'),
                       ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 12)
                  FROM tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config
                 WHERE xpd_nst = ncc_nst AND ncc_calc_period = '12MONTHS';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', '37MONTHS') > 0
        THEN
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                SELECT xpd_id,
                       TRUNC (xpd_ap_reg_dt, 'MM'),
                       ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 37)
                  FROM tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config
                 WHERE xpd_nst = ncc_nst AND ncc_calc_period = '37MONTHS';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', 'INV_END') > 0
        THEN
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                  SELECT xpd_id,
                         TRUNC (xpd_ap_reg_dt, 'MM'),
                         NVL (
                             LEAST (MAX (tc_inv_stop_dt),
                                    MAX (ADD_MONTHS (tc_birth_dt, 216))),
                             ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 12))
                    FROM tmp_pd_calc_params
                         JOIN tmp_calc_app_params ON xpd_id = tc_pd
                         JOIN uss_ndi.v_ndi_nst_calc_config
                             ON xpd_nst = ncc_nst
                   WHERE --допомога особам з інвалідністю с дитинства та дітям з інвалідністю надається до дати закінчення періоду інвалідності або 18річча дитини
                             (   tc_inv_stop_dt > xpd_ap_reg_dt
                              OR ADD_MONTHS (tc_birth_dt, 216) > xpd_ap_reg_dt)
                         AND ncc_calc_period = 'INV_END'
                         AND NCC_PD_PERIOD_ALG = 'TR_AP_REG'
                GROUP BY xpd_id, xpd_ap_reg_dt
                UNION ALL
                  SELECT xpd_id,
                         CASE
                             WHEN xpd_src = 'SA' --Для держутримань - дату початку вже розрахували
                                                 THEN xpd_start_dt
                             ELSE xpd_ap_reg_dt
                         END,
                         CASE
                             WHEN xpd_ap_reg_dt >
                                  MAX (ADD_MONTHS (tc_birth_dt, 216))
                             THEN
                                 NVL (
                                     MAX (tc_inv_stop_dt),
                                     ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'),
                                                 12))
                             ELSE
                                 NVL (
                                     LEAST (
                                         MAX (tc_inv_stop_dt),
                                         MAX (ADD_MONTHS (tc_birth_dt, 216))),
                                     ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'),
                                                 12))
                         END
                    FROM tmp_pd_calc_params
                         JOIN tmp_calc_app_params ON xpd_id = tc_pd
                         JOIN uss_ndi.v_ndi_nst_calc_config
                             ON xpd_nst = ncc_nst
                   WHERE --допомога особам з інвалідністю с дитинства та дітям з інвалідністю надається до дати закінчення періоду інвалідності або 18річча дитини
                             (   tc_inv_stop_dt > xpd_ap_reg_dt
                              OR ADD_MONTHS (tc_birth_dt, 216) > xpd_ap_reg_dt)
                         AND ncc_calc_period = 'INV_END'
                         AND NCC_PD_PERIOD_ALG = 'AP_REG'
                GROUP BY xpd_id,
                         xpd_ap_reg_dt,
                         xpd_src,
                         xpd_start_dt;
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', 'WAREND+1M') > 0
        THEN
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                WITH
                    kaot_state
                    AS
                        (  SELECT nks.kaots_kaot,
                                  nks.kaots_tp,
                                  MIN (nks.kaots_start_dt)     kaots_start_dt --,
                             --MAX(NVL(nks.kaots_stop_dt, to_date('01013000','ddmmyyyy'))) kaots_stop_dt
                             FROM uss_ndi.v_ndi_kaot_state nks
                            WHERE     nks.history_status = 'A'
                                  AND nks.kaots_tp IN ('TO', 'BL', 'BD')
                         GROUP BY nks.kaots_kaot, nks.kaots_tp)
                --#79932
                --Для звернень за допомогою ВПО до 23.08.2022 (до дати набрання чинності норми) система перевіряє чи особа перемістилася з територіальної громади,
                --яка визначена у Переліку станом на дату звернення та у разі належності територіальної громади до Переліку допомога призначається з місяця звернення.
                --Для звернень з 24.08.2022 система перевіряє дату, з якої територіальну громаду включено до переліку.
                --Якщо територіальну громаду включено до Переліку в місяці, що передує місяцю звернення, то допомогу буде призначено з місяця звернення.
                --Якщо територіальну громаду включено до Переліку в місяці звернення, то допомогу буде призначено з наступного місяця.
                SELECT xpd_id,
                       CASE
                           WHEN xpd_ap_reg_dt < TO_DATE ('23.08.2022', 'dd.mm.yyyy')
                           THEN
                               TRUNC (xpd_ap_reg_dt, 'MM')
                           WHEN TRUNC (kaots_start_dt, 'MM') < TRUNC (xpd_ap_reg_dt, 'MM')
                           THEN
                               TRUNC (xpd_ap_reg_dt, 'MM')
                           WHEN TRUNC (kaots_start_dt, 'MM') = TRUNC (xpd_ap_reg_dt, 'MM')
                           THEN
                               TRUNC (ADD_MONTHS (xpd_ap_reg_dt, 1), 'MM')
                           ELSE
                               TRUNC (xpd_ap_reg_dt, 'MM')
                       END
                           AS start_dt,
                         LAST_DAY (
                             ADD_MONTHS (TOOLS.GGPD ('WAR_MARTIAL_LAW_END'),
                                         1))
                       + 1 --ADD_MONTHS(TRUNC(TOOLS.GGPD('WAR_2PHASE_START'), 'MM'), 11)
                  FROM tmp_pd_calc_params
                       JOIN uss_ndi.v_ndi_nst_calc_config
                           ON xpd_nst = ncc_nst
                       JOIN ap_person app
                           ON     app.app_ap = xpd_ap
                              AND app.app_tp = 'Z'
                              AND app.history_status = 'A'
                       JOIN uss_ndi.v_ndi_katottg nk
                           ON nk.kaot_id =
                              API$PC_DECISION.get_doc_id (app.app_id,
                                                          605,
                                                          1775)
                       LEFT JOIN kaot_state nks
                           ON nks.kaots_kaot = nk.kaot_kaot_l3
                 WHERE     ncc_calc_period = 'WAREND+1M'
                       AND ncc_pd_period_alg = 'TR_AP_REG';
        END IF;

        --RETURN;

        --Збір всіх необхідних точок розриву
        collect_breakpoints;

        SaveMessage ('Знаходимо унікальний набр дат розривів');

        INSERT INTO tmp_tar_dates td (td_pd, td_pdf, td_begin)
            SELECT DISTINCT ttd_pd, ttd_pdf, TRUNC (ttd_dt)
              FROM tmp_tar_dates1               /*
                             WHERE ttd_source !=14*/
                                 ;

        SaveMessage ('Проставляємо кінці періодів');

        UPDATE /*+full(ma1)*/
               tmp_tar_dates ma1
           SET td_end =
                   (SELECT /*+index(sl I_ttd_set1)*/
                           MIN (td_begin) - 1
                      FROM tmp_tar_dates sl
                     WHERE     sl.td_pd = ma1.td_pd
                           AND sl.td_pdf = ma1.td_pdf
                           AND sl.td_begin > ma1.td_begin)
         WHERE 1 = 1;

        DELETE FROM tmp_tar_dates ma1
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_tar_dates1
                          WHERE     td_pd = ttd_pd
                                AND td_pdf = ttd_pdf
                                AND td_begin = ttd_dt
                                AND ttd_source = 15);

        SaveMessage (
            'Видаляємо останній в історії шматок, якому не знайшлося дати закінчення');

        DELETE FROM tmp_tar_dates
              WHERE td_end IS NULL;

        SaveMessage ('Знаходимо унікальний набр дат розривів без учасників');

        INSERT INTO tmp_calc_dates (cd_pd, cd_begin)
            SELECT td_pd, td_begin FROM tmp_tar_dates
            UNION
            SELECT td_pd, td_end + 1 FROM tmp_tar_dates;

        SaveMessage ('Проставляємо кінці періодів');

        UPDATE /*+full(ma1)*/
               tmp_calc_dates ma1
           SET cd_end =
                   (SELECT /*+index(sl i_tcd_set1)*/
                           MIN (cd_begin) - 1
                      FROM tmp_calc_dates sl
                     WHERE     sl.cd_pd = ma1.cd_pd
                           AND sl.cd_begin > ma1.cd_begin)
         WHERE 1 = 1;

        SaveMessage ('Видаляємо зайві записи періодів');

        DELETE FROM tmp_calc_dates
              WHERE cd_end IS NULL;

        SaveMessage (
            'Формуємо таблицю параметрів на кожну дату розривів для кожної особи');

        INSERT INTO tmp_calc_app_params (tc_pd,
                                         tc_sc,                    /*tc_app,*/
                                         tc_tp,
                                         tc_pdf,
                                         tc_start_dt,
                                         tc_inv_state,
                                         tc_inv_group,
                                         tc_need_care,
                                         tc_is_lonely,
                                         tc_inv_child,
                                         tc_state_care,
                                         tc_is_working,
                                         tc_is_study,
                                         tc_is_military,
                                         tc_is_3year_care,
                                         tc_is_pregnant,
                                         tc_is_unpaid_live,
                                         tc_birth_dt,
                                         tc_inv_start_dt,
                                         tc_inv_stop_dt,
                                         tc_inv_sgroup,
                                         tc_is_work_able,
                                         tc_is_state_alimony,
                                         tc_is_child_inv_chaes,
                                         tc_is_child_sick,
                                         tc_study_start_dt,
                                         tc_study_stop_dt,
                                         tc_FamilyConnect,
                                         tc_is_vpo,
                                         tc_calc_dt,
                                         tc_sc_start_dt,
                                         tc_sc_stop_dt)
            SELECT tc_pd,
                   tc_sc,                                          /*tc_app,*/
                   tc_tp,
                   tc_pdf,
                   --Якщо розрив не в періоді інвалідності, то нічого рахуватись не повинно
                   td_begin,
                   CASE
                       WHEN td_begin BETWEEN tc_inv_start_dt
                                         AND tc_inv_stop_dt
                       THEN
                           tc_inv_state
                       ELSE
                           '-'
                   END,
                   tc_inv_group,
                   tc_need_care,
                   tc_is_lonely,
                   tc_inv_child,
                   tc_state_care,
                   tc_is_working,
                   tc_is_study,
                   tc_is_military,
                   tc_is_3year_care,
                   tc_is_pregnant,
                   tc_is_unpaid_live,
                   tc_birth_dt,
                   tc_inv_start_dt,
                   tc_inv_stop_dt,
                   tc_inv_sgroup,
                   tc_is_work_able,
                   tc_is_state_alimony,
                   tc_is_child_inv_chaes,
                   tc_is_child_sick,
                   tc_study_start_dt,
                   tc_study_stop_dt,
                   tc_FamilyConnect,
                   tc_is_vpo,
                   tc_calc_dt,
                   tc_sc_start_dt,
                   tc_sc_stop_dt
              FROM tmp_tar_dates, tmp_calc_app_params
             WHERE     td_pd = tc_pd
                   AND td_pdf = tc_pdf
                   AND tc_start_dt IS NULL
                   AND td_begin BETWEEN tc_sc_start_dt AND tc_sc_stop_dt;

        --Перераховуємо додаткові параметри по учасникам
        recalc_pdf_params;

        --Основний блок, який, власне, і рахує суми допомог, надбавок тощо
        FOR xx
            IN (SELECT ncc_calc_procedure, ncc_calc_alg, nst_name
                  FROM uss_ndi.v_ndi_nst_calc_config,
                       uss_ndi.v_ndi_service_type
                 WHERE     ncc_nst = nst_id
                       AND EXISTS
                               (SELECT 1
                                  FROM tmp_pd_calc_params
                                 WHERE ncc_nst = xpd_nst))
        LOOP
            SaveMessage (
                   'Виконуємо алгоритм <'
                || xx.ncc_calc_alg
                || '> для послуги <'
                || xx.nst_name
                || '>');

            EXECUTE IMMEDIATE xx.ncc_calc_procedure;
        END LOOP;

        CALC$DEDUCTION.calc_deductions_for_pd;

        collect_features;

        SaveMessage ('Знаходимо точки розриву розрахованих нарахувань');

        INSERT INTO tmp_pay_dates1 (tpd_pd, tpd_dt, tpd_source)
            SELECT tdc_pd, tdc_start_dt, 1
              FROM tmp_pd_detail_calc, uss_ndi.v_ndi_pd_row_type
             WHERE tdc_ndp = ndp_id AND ndp_use_for_period = 'T'
            UNION
            SELECT tdc_pd, tdc_stop_dt + 1, 1
              FROM tmp_pd_detail_calc, uss_ndi.v_ndi_pd_row_type
             WHERE tdc_ndp = ndp_id AND ndp_use_for_period = 'T';

        SaveMessage ('Знаходимо унікальний набр дат розривів');

        INSERT INTO tmp_pay_dates (tp_pd, tp_begin)
            SELECT DISTINCT tpd_pd, tpd_dt
              FROM tmp_pay_dates1;

        SaveMessage ('Проставляємо кінці періодів');

        UPDATE /*+full(ma1)*/
               tmp_pay_dates ma1
           SET tp_end =
                   (SELECT /*+index(sl I_ttd_set1)*/
                           MIN (tp_begin) - 1
                      FROM tmp_pay_dates sl
                     WHERE     sl.tp_pd = ma1.tp_pd
                           AND sl.tp_begin > ma1.tp_begin)
         WHERE 1 = 1;

        SaveMessage ('Видаляємо зайві записи періодів');

        DELETE FROM tmp_pay_dates
              WHERE tp_end IS NULL;


        SaveMessage ('Видаляємо існуючі деталі розрахунку рішення');

        DELETE FROM pd_detail
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_calc_pd, pd_payment
                          WHERE c_pd = pdp_pd AND pdd_pdp = pdp_id);

        SaveMessage ('Видаляємо існуючі розрахунки рішення');

        DELETE FROM pd_payment
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_calc_pd
                          WHERE c_pd = pdp_pd);

        SaveMessage (
            'Формуємо нарахування по кожному розриву і агрегуємо по типу виплати');

        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum)
              SELECT 0,
                     tp_pd,
                     tdc_npt,
                     tp_begin,
                     tp_end,
                     NVL (SUM (tdc_value), 0)
                FROM tmp_pay_dates,
                     tmp_pd_detail_calc,
                     uss_ndi.v_ndi_pd_row_type
               WHERE     tp_pd = tdc_pd
                     AND tp_begin BETWEEN tdc_start_dt AND tdc_stop_dt
                     AND tdc_npt IS NOT NULL
                     AND tdc_ndp = ndp_id
                     AND ndp_alg IS NULL
            GROUP BY tp_pd,
                     tdc_npt,
                     tp_begin,
                     tp_end/*HAVING SUM(tdc_value) <> 0*/
                           ;

        /*
        "Не переносить розрахунок, яущо нуль"
        "нехай переносить, потім переробимо" - Тетяна Д
          */
        SaveMessage (
            'Прописуємо період дії рішення - повний період призначення');

        UPDATE pc_decision
           SET (pd_start_dt, pd_stop_dt) =
                   (SELECT MIN (pdp_start_dt), MAX (pdp_stop_dt)
                      FROM pd_payment
                     WHERE pdp_pd = pd_id)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_calc_pd
                         WHERE c_pd = pd_id)
               AND (pd_start_dt IS NULL OR pd_src = 'FS'); --# 74919   2022.01.21

        -- # #81405  2022.11.11
        UPDATE pc_decision
           SET pd_scc =
                   (SELECT MAX (app_scc)
                      FROM ap_person app
                     WHERE     app_ap = pd_ap
                           AND app.history_status = 'A'
                           AND app.app_tp = 'Z')
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_calc_pd
                     WHERE c_pd = pd_id);

        UPDATE pd_pay_method
           SET (pdm_start_dt, pdm_stop_dt) =
                   (SELECT pd_start_dt, pd_stop_dt
                      FROM pc_decision
                     WHERE pdm_pd = pd_id)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_calc_pd
                     WHERE c_pd = pdm_pd);



        SaveMessage ('Пишемо деталі нарахування');

        INSERT INTO pd_detail (pdd_id,
                               pdd_pdp,
                               pdd_row_order,
                               pdd_row_name,
                               pdd_value,
                               pdd_key,
                               pdd_ndp,
                               pdd_start_dt,
                               pdd_stop_dt)
            SELECT 0,
                   pdp_id,
                   tdc_row_order,
                   tdc_row_name,
                   tdc_value,
                   tdc_key,
                   tdc_ndp,
                   tdc_start_dt,
                   tdc_stop_dt
              FROM tmp_pd_detail_calc, pd_payment, uss_ndi.v_ndi_pd_row_type
             WHERE     tdc_pd = pdp_pd
                   AND tdc_ndp = ndp_id
                   AND (   tdc_npt = pdp_npt
                        OR tdc_npt IS NULL AND ndp_alg = 'SHOW')
                   AND pdp_start_dt BETWEEN tdc_start_dt AND tdc_stop_dt;
    END;

    PROCEDURE calc_various_pd_params
    IS
    BEGIN
        /* !!! тільки для ВПО обраховуємо дата виплати по даті звернення ?!?*/

        UPDATE Pd_Pay_Method
           SET pdm_pay_dt =
                   (SELECT CASE
                               WHEN EXTRACT (DAY FROM ap_reg_dt) < 4 THEN 4
                               WHEN EXTRACT (DAY FROM ap_reg_dt) > 25 THEN 25
                               ELSE EXTRACT (DAY FROM ap_reg_dt)
                           END
                      FROM appeal JOIN pc_decision ON ap_id = pd_ap
                     WHERE pd_id = pdm_pd)
         WHERE     EXISTS
                       (SELECT 1
                          FROM pc_decision
                         WHERE pd_id = pdm_pd AND pd_nst = 664)
               AND pdm_pay_dt IS NULL
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE pdm_pd = x_id);
    END;



    --Функція розрахунку виплат по проектам рішень на виплату
    PROCEDURE calc_pd (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                       p_pd_id          pc_decision.pd_id%TYPE,
                       p_messages   OUT SYS_REFCURSOR)
    IS
        --g_messages TOOLS.t_messages := TOOLS.t_messages();
        l_cnt   INTEGER;
        l_hs    histsession.hs_id%TYPE;

        FUNCTION check_is_have_nst (p_nst_id pc_decision.pd_nst%TYPE)
            RETURN BOOLEAN
        IS
            l_nst_cnt   INTEGER;
        BEGIN
            SELECT COUNT (*)
              INTO l_nst_cnt
              FROM tmp_work_ids, pc_decision, uss_ndi.v_ndi_service_type
             WHERE     x_id = pd_id
                   AND pd_nst = nst_id
                   AND (pd_nst = p_nst_id OR nst_nst_main = p_nst_id);

            RETURN l_nst_cnt > 0;
        END;

        /*
        У вікні "Рішення про призначення допомоги" можна здійснювати розрахунок лише у випадку,
        якщо користувач підтвердив право на сторінці "Визначення права" - в усіх правилах перевірки зазначено "Так".
        Якщо хоча б в одному чекбоксі правил відсутнє "ТАК",
        то видавати повідомлення "Розрахунок можна здійснювати, у випадку наявності у особи права на призначення допомоги"
        */
        PROCEDURE Check_pd_right
        IS
            CURSOR pd_right IS
                  SELECT x_id,
                         nst_id                                                AS x_nst,
                         nst_name                                              AS x_nst_name,
                         SUM (CASE WHEN prl_result = 'F' THEN 1 ELSE 0 END)    x_err_cnt
                    FROM tmp_work_ids
                         JOIN pd_right_log ON prl_pd = x_id
                         JOIN uss_ndi.v_ndi_right_rule nrr
                             ON     prl_nrr = nrr.nrr_id
                                AND NVL (nrr.nrr_tp, 'E') = 'E' -- Аналізуємо тільки помилки
                         JOIN pc_decision ON pd_id = x_id
                         JOIN uss_ndi.v_ndi_service_type ON pd_nst = nst_id
                GROUP BY x_id, nst_id, nst_name
                  HAVING SUM (CASE WHEN prl_result = 'F' THEN 1 ELSE 0 END) >
                         0;
        BEGIN
            FOR r IN pd_right
            LOOP
                TOOLS.add_message (
                    g_messages,
                    'E',
                       'Розрахунок можна здійснювати, у випадку наявності у особи права на призначення допомоги <'
                    || r.x_nst_name
                    || '>!');
                API$PC_DECISION.write_pd_log (
                    r.x_id,
                    l_hs,
                    'R0',
                    CHR (38) || '36#' || r.x_nst_name,
                    NULL);

                DELETE FROM tmp_work_ids
                      WHERE x_id = r.x_id;
            END LOOP;
        END;
    BEGIN
        g_messages := TOOLS.t_messages ();
        TOOLS.add_message (g_messages, 'I', 'Починаю розрахунок!');

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
            TOOLS.add_message (
                g_messages,
                'E',
                'В функцію розрахунку сум виплати не передано ідентифікаторів проектів рішень на виплату!');
        ELSE
            l_hs := TOOLS.GetHistSession;

            Check_pd_right;

            calc_service;

            FOR xx
                IN (SELECT DISTINCT nst_id AS x_nst, nst_name AS x_nst_name
                      FROM tmp_work_ids,
                           pc_decision,
                           uss_ndi.v_ndi_service_type
                     WHERE x_id = pd_id AND pd_nst = nst_id)
            LOOP
                TOOLS.add_message (
                    g_messages,
                    'I',
                    'Розраховано допомогу <' || xx.x_nst_name || '>!');
            END LOOP;

            calc_various_pd_params;

            TOOLS.add_message (g_messages, 'I', 'Завершено розрахунок!');
        END IF;

        FOR xx IN (SELECT x_id FROM tmp_work_ids)
        LOOP
            API$PC_DECISION.write_pd_log (xx.x_id,
                                          l_hs,
                                          'R0',
                                          CHR (38) || '13',
                                          NULL);
        END LOOP;

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;

    --+++++++++++++++++++++
    PROCEDURE Test_calc_pd (id NUMBER DEFAULT NULL)
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
        IF id IS NULL
        THEN
            calc_pd (2, NULL, p_messages);
        ELSE
            calc_pd (1, id, p_messages);
        END IF;

        fetch2andclose (p_messages);
    END;

    PROCEDURE Check_accrual_period (
        p_pd_src     pc_decision%ROWTYPE,
        p_start_dt   pc_decision.pd_start_dt%TYPE,
        p_stop_dt    pc_decision.pd_stop_dt%TYPE,
        p_hs         histsession.hs_id%TYPE,
        p_src        VARCHAR2)
    IS
        cnt_err   NUMBER;
    BEGIN
        WITH
            all_dt
            AS
                (SELECT TRUNC (pdap_start_dt)     AS u_dt
                   FROM uss_esr.pd_accrual_period pdap
                  WHERE     pdap_pd = p_pd_src.pd_id
                        AND pdap.history_status = 'A'
                 UNION
                 SELECT TRUNC (
                            NVL (pdap_stop_dt,
                                 TO_DATE ('31.12.3000', 'DD.MM.YYYY')))
                   FROM uss_esr.pd_accrual_period pdap
                  WHERE     pdap_pd = p_pd_src.pd_id
                        AND pdap.history_status = 'A')
        SELECT COUNT (1)
          INTO cnt_err
          FROM all_dt
         WHERE 1 <
               (SELECT COUNT (*)
                  FROM uss_esr.pc_decision
                       JOIN uss_esr.pd_accrual_period pdap
                           ON pdap_pd = pd_id AND pdap.history_status = 'A'
                 WHERE     pd_pa = p_pd_src.pd_pa
                       AND u_dt BETWEEN TRUNC (pdap_start_dt)
                                    AND TRUNC (
                                            NVL (
                                                pdap_stop_dt,
                                                TO_DATE ('31.12.3000',
                                                         'DD.MM.YYYY'))));

        IF cnt_err > 0
        THEN
            IF p_src = '1'
            THEN
                write_pd_log (
                    p_pdl_pd        => p_pd_src.pd_id,
                    p_pdl_hs        => p_hs,
                    p_pdl_st        => p_pd_src.pd_st,
                    p_pdl_message   =>
                           'Помилка формування періоду дії рішення. '
                        || 'Новий період з '
                        || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                        || ' по '
                        || TO_CHAR (p_stop_dt, 'dd.mm.yyyy'),
                    p_pdl_st_old    => p_pd_src.pd_st);
            ELSIF p_src = '2'
            THEN
                write_pd_log (
                    p_pdl_pd        => p_pd_src.pd_id,
                    p_pdl_hs        => p_hs,
                    p_pdl_st        => p_pd_src.pd_st,
                    p_pdl_message   =>
                           'Помилка формування періоду дії рішення при розблокуванні. '
                        || 'Новий період з '
                        || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                        || ' по '
                        || TO_CHAR (p_stop_dt, 'dd.mm.yyyy'),
                    p_pdl_st_old    => p_pd_src.pd_st);
            ELSIF p_src = '3'
            THEN
                write_pd_log (
                    p_pdl_pd        => p_pd_src.pd_id,
                    p_pdl_hs        => p_hs,
                    p_pdl_st        => p_pd_src.pd_st,
                    p_pdl_message   =>
                        'Помилка сформованних періодів дії рішення.',
                    p_pdl_st_old    => p_pd_src.pd_st);
            END IF;

            IF p_src IN ('1', '2')
            THEN
                raise_application_error (
                    -20000,
                       'Виявлено помилку формування періоду дії рішення '
                    || p_pd_src.pd_num
                    || '. Перетинаються діапазони дії рішення по рахунку.');
            ELSE
                raise_application_error (
                    -20000,
                       'Виявлено помилку сформованних періодів дії рішення '
                    || p_pd_src.pd_num
                    || '. Перетинаються діапазони дії рішення по рахунку.');
            END IF;
        END IF;
    END;

    PROCEDURE Check_accrual_period (p_pd_src   pc_decision%ROWTYPE,
                                    p_hs       histsession.hs_id%TYPE)
    IS
    BEGIN
        Check_accrual_period (p_pd_src,
                              NULL,
                              NULL,
                              p_hs,
                              '3');
    END;

    --Процедура перерахунку реальних періодів дії рішень для кореткного врахування в нарухуваннях, при появі нових рішень по ключу (pc,nst)
    PROCEDURE recalc_pd_periods (p_pd_id   pc_decision.pd_id%TYPE,
                                 p_hs      histsession.hs_id%TYPE)
    IS
        l_src_pd   pc_decision%ROWTYPE;
        l_src_dn   deduction.dn_id%TYPE;
    BEGIN
        SELECT *
          INTO l_src_pd
          FROM pc_decision
         WHERE pd_id = p_pd_id;

        l_src_pd.pd_stop_dt :=
            NVL (l_src_pd.pd_stop_dt, TO_DATE ('31.12.2100', 'DD.MM.YYYY'));

        IF     l_src_pd.pd_pcb IS NOT NULL
           AND l_src_pd.pd_suspend_reason != 'VPOE'
        THEN
            SELECT                                --trunc(ap.ap_reg_dt,'MM')-1
                   LAST_DAY (ap.ap_reg_dt)
              INTO l_src_pd.pd_stop_dt
              FROM pc_block pcb JOIN appeal ap ON ap.ap_id = pcb.pcb_ap_src
             WHERE pcb.pcb_id = l_src_pd.pd_pcb;
        END IF;

        API$HIST.init_work;

        --Збираємо наявну історію
        INSERT INTO tmp_unh_old_list (ol_obj,
                                      ol_hst,
                                      ol_begin,
                                      ol_end)
            SELECT 0,
                   pdap_id,
                   pdap_start_dt,
                   pdap_stop_dt
              FROM pc_decision, pd_accrual_period acr
             WHERE     pd_pa = l_src_pd.pd_pa
                   AND pd_st IN ('S', 'PS')
                   AND pdap_pd = pd_id
                   AND acr.history_status = 'A'
                   --      AND (
                   --            (pdap_start_dt <= l_src_pd.pd_stop_dt AND pdap_stop_dt >= l_src_pd.pd_start_dt)
                   --            OR
                   --            (pdap_start_dt > l_src_pd.pd_stop_dt)
                   --          );
                   AND pdap_start_dt <= l_src_pd.pd_stop_dt
                   AND pdap_stop_dt >= l_src_pd.pd_start_dt;


        INSERT INTO tmp_unh_work_list (work_obj,
                                       work_hst,
                                       work_begin,
                                       work_end)
             VALUES (0,
                     0,
                     l_src_pd.pd_start_dt,
                     l_src_pd.pd_stop_dt);

        -- формування історії
        API$HIST.setup_history (0,
                                0,
                                l_src_pd.pd_start_dt,
                                l_src_pd.pd_stop_dt);

        -- закриття недіючих
        /*
          UPDATE pd_accrual_period h
            SET h.history_status = 'H'
            WHERE EXISTS (SELECT 1 FROM tmp_unh_to_prp WHERE tprp_hst = pdap_id)
                  OR
                  (h.pdap_start_dt > (SELECT MAX(pd.pd_stop_dt) FROM pc_decision pd  WHERE pd_pa = l_src_pd.pd_pa)
                   and h.pdap_pd = l_src_pd.pd_id
                   );
        */
        UPDATE pd_accrual_period h
           SET h.history_status = 'H'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = pdap_id);

        UPDATE pd_accrual_period h
           SET h.history_status = 'H'
         WHERE     h.pdap_start_dt > (SELECT MAX (pd.pd_stop_dt)
                                        FROM pc_decision pd
                                       WHERE pd_pa = l_src_pd.pd_pa)
               AND h.pdap_pd = l_src_pd.pd_id;



        -- додавання нових періодів
        INSERT INTO pd_accrual_period (pdap_id,
                                       pdap_pd,
                                       pdap_start_dt,
                                       pdap_stop_dt,
                                       pdap_change_pd,
                                       history_status)
            SELECT 0,
                   pdap_pd,
                   rz.rz_begin,
                   rz.rz_end,
                   l_src_pd.pd_id,
                   'A'
              FROM tmp_unh_rz_list rz, pd_accrual_period
             WHERE     rz_hst <> 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND pdap_id = rz_hst
                   AND rz_begin < l_src_pd.pd_stop_dt
            UNION ALL
            SELECT 0,
                   l_src_pd.pd_id,
                   rz_begin,
                   rz_end,
                   l_src_pd.pd_id,
                   'A'
              FROM tmp_unh_rz_list
             WHERE     rz_hst = 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND rz_begin < l_src_pd.pd_stop_dt;

        Check_accrual_period (l_src_pd,
                              l_src_pd.pd_start_dt,
                              l_src_pd.pd_stop_dt,
                              p_hs,
                              '1');


        IF l_src_pd.pd_src = 'SA'
        THEN
            SELECT MIN (dn_id)
              INTO l_src_dn
              FROM deduction
             WHERE dn_ps = l_src_pd.pd_ps;
        END IF;

        API$PERSONALCASE.add_pc_accrual_queue (
            l_src_pd.pd_pc,
            CASE l_src_pd.pd_src
                WHEN 'FS' THEN 'PD'
                WHEN 'PV' THEN 'PD'
                WHEN 'SA' THEN 'PS'
            END,
            l_src_pd.pd_start_dt,
            l_src_pd.pd_stop_dt,
            CASE l_src_pd.pd_src
                WHEN 'FS' THEN l_src_pd.pd_id
                WHEN 'PV' THEN l_src_pd.pd_id
                WHEN 'SA' THEN l_src_dn
            END);
    END;

    --=============================================================================--
    -- Для "Поновлення виплати" в картці рішення
    -- Процедура перерахунку реальних періодів дії рішень для кореткного врахування в нарухуваннях, при появі нових рішень по ключу (pc,nst)
    --=============================================================================--
    PROCEDURE recalc_pd_periods (
        p_pd_id         pc_decision.pd_id%TYPE,
        p_pd_start_dt   pc_decision.pd_start_dt%TYPE,
        p_pd_stop_dt    pc_decision.pd_stop_dt%TYPE,
        p_hs            histsession.hs_id%TYPE)
    IS
        l_src_pd   pc_decision%ROWTYPE;
        l_src_dn   deduction.dn_id%TYPE;
    BEGIN
        SELECT *
          INTO l_src_pd
          FROM pc_decision
         WHERE pd_id = p_pd_id;

        --Збираємо наявну історію
        INSERT INTO tmp_unh_old_list (ol_obj,
                                      ol_hst,
                                      ol_begin,
                                      ol_end)
            SELECT 0,
                   pdap_id,
                   pdap_start_dt,
                   pdap_stop_dt
              FROM pc_decision, pd_accrual_period acr
             WHERE     pd_pa = l_src_pd.pd_pa
                   AND pd_st IN ('S', 'PS')
                   AND pdap_pd = pd_id
                   AND acr.history_status = 'A'
                   AND (   pdap_start_dt <= p_pd_stop_dt
                        OR pdap_stop_dt >= p_pd_start_dt);

        INSERT INTO tmp_unh_work_list (work_obj,
                                       work_hst,
                                       work_begin,
                                       work_end)
             VALUES (0,
                     0,
                     p_pd_start_dt,
                     p_pd_stop_dt);

        -- формування історії
        API$HIST.setup_history (0,
                                0,
                                p_pd_start_dt,
                                p_pd_stop_dt);

        -- закриття недіючих
        /*
            UPDATE pd_accrual_period h
              SET h.history_status = 'H'
              WHERE EXISTS (SELECT 1 FROM tmp_unh_to_prp WHERE tprp_hst = pdap_id)
                    OR
                    (h.pdap_start_dt > (SELECT MAX(pd.pd_stop_dt) FROM pc_decision pd  WHERE pd_pa = l_src_pd.pd_pa)
                     and h.pdap_pd = l_src_pd.pd_id
                     );
        */
        UPDATE pd_accrual_period h
           SET h.history_status = 'H'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = pdap_id);

        UPDATE pd_accrual_period h
           SET h.history_status = 'H'
         WHERE     h.pdap_start_dt > (SELECT MAX (pd.pd_stop_dt)
                                        FROM pc_decision pd
                                       WHERE pd_pa = l_src_pd.pd_pa)
               AND h.pdap_pd = l_src_pd.pd_id;

        -- додавання нових періодів
        INSERT INTO pd_accrual_period (pdap_id,
                                       pdap_pd,
                                       pdap_start_dt,
                                       pdap_stop_dt,
                                       pdap_change_pd,
                                       history_status)
            SELECT 0,
                   pdap_pd,
                   rz.rz_begin,
                   rz.rz_end,
                   l_src_pd.pd_id,
                   'A'
              FROM tmp_unh_rz_list rz, pd_accrual_period
             WHERE     rz_hst <> 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND pdap_id = rz_hst
            --AND rz_begin < p_pd_stop_dt -- інакше не підхватує наступні періоди
            UNION ALL
            SELECT 0,
                   l_src_pd.pd_id,
                   rz_begin,
                   rz_end,
                   l_src_pd.pd_id,
                   'A'
              FROM tmp_unh_rz_list
             WHERE     rz_hst = 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND rz_begin < p_pd_stop_dt;

        Check_accrual_period (l_src_pd,
                              p_pd_start_dt,
                              p_pd_stop_dt,
                              p_hs,
                              '2');

        IF l_src_pd.pd_src = 'SA'
        THEN
            SELECT MIN (dn_id)
              INTO l_src_dn
              FROM deduction
             WHERE dn_ps = l_src_pd.pd_ps;
        END IF;

        API$PERSONALCASE.add_pc_accrual_queue (
            l_src_pd.pd_pc,
            CASE l_src_pd.pd_src
                WHEN 'FS' THEN 'PD'
                WHEN 'PV' THEN 'PD'
                WHEN 'SA' THEN 'PS'
            END,
            p_pd_start_dt,
            p_pd_stop_dt,
            CASE l_src_pd.pd_src
                WHEN 'FS' THEN l_src_pd.pd_id
                WHEN 'PV' THEN l_src_pd.pd_id
                WHEN 'SA' THEN l_src_dn
            END);
    END;

    FUNCTION Parse_Features (p_pd_Features IN CLOB)
        RETURN t_pd_Features
    IS
        l_pd_Features   t_pd_Features;
    BEGIN
        IF p_pd_Features IS NULL
        THEN
            RETURN NULL;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_pd_Features',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_pd_Features
            USING p_pd_Features;

        RETURN l_pd_Features;
    END;

    PROCEDURE Save_Features (
        p_pde_id           IN     pd_features.pde_id%TYPE,
        p_pde_pd           IN     pd_features.pde_pd%TYPE,
        p_pde_nft          IN     pd_features.pde_nft%TYPE,
        p_pde_val_int      IN     pd_features.pde_val_int%TYPE,
        p_pde_val_sum      IN     pd_features.pde_val_sum%TYPE,
        p_pde_val_id       IN     pd_features.pde_val_id%TYPE,
        p_pde_val_dt       IN     pd_features.pde_val_dt%TYPE,
        p_pde_val_string   IN     pd_features.pde_val_string%TYPE,
        p_pde_pdf          IN     pd_features.pde_pdf%TYPE,
        p_new_id              OUT pd_features.pde_id%TYPE)
    IS
        l_tp   VARCHAR2 (10);
    BEGIN
        SELECT MAX (t.nft_view)
          INTO l_tp
          FROM uss_ndi.v_ndi_pd_feature_type t
         WHERE t.nft_id = p_pde_nft;

        --IF p_pde_nft IS NOT NULL AND p_pde_nft!= 9 THEN
        IF l_tp IS NULL OR l_tp != 'SS'
        THEN
            RETURN;
        END IF;

        IF p_pde_id IS NULL OR p_pde_id < 0
        THEN
            INSERT INTO pd_features (pde_pd,
                                     pde_nft,
                                     pde_val_int,
                                     pde_val_sum,
                                     pde_val_id,
                                     pde_val_dt,
                                     pde_val_string,
                                     pde_pdf)
                 VALUES (p_pde_pd,
                         p_pde_nft,
                         p_pde_val_int,
                         p_pde_val_sum,
                         p_pde_val_id,
                         p_pde_val_dt,
                         p_pde_val_string,
                         p_pde_pdf)
              RETURNING pde_id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_pde_id;

            UPDATE pd_features
               SET pde_pd = p_pde_pd,
                   pde_nft = p_pde_nft,
                   pde_val_int = p_pde_val_int,
                   pde_val_sum = p_pde_val_sum,
                   pde_val_id = p_pde_val_id,
                   pde_val_dt = p_pde_val_dt,
                   pde_val_string = p_pde_val_string,
                   pde_pdf = p_pde_pdf
             WHERE pde_id = p_pde_id;
        END IF;
    END;

    PROCEDURE Delete_Features (p_pde_id IN pd_features.pde_id%TYPE)
    IS
    BEGIN
        DELETE FROM pd_features s
              WHERE pde_id = p_pde_id AND NVL (pde_nft, -1) = 9;
    END;
END API$PD_TEST;
/