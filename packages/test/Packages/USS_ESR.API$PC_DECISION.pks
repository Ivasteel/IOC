/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PC_DECISION
IS
    -- Author  : VANO
    -- Created : 16.07.2021 11:09:28
    -- Purpose : Функції роботи з рішеннями про призначення

    g_save_job_messages     INTEGER := 2;

    --===========================================--
    --  Відключає перевірку права перед розрахунком. Для розрахунку мігрованих рішень.
    --===========================================--
    PROCEDURE Not_Check_Calc_Right;

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

    FUNCTION get_attr_id (p_doc_id NUMBER, p_nda_id NUMBER)
        RETURN NUMBER;

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

    /*
      PROCEDURE write_pd_logA(p_pdl_pd pd_log.pdl_pd%TYPE,
                             p_pdl_hs pd_log.pdl_hs%TYPE,
                             p_pdl_st pd_log.pdl_st%TYPE,
                             p_pdl_message pd_log.pdl_message%TYPE,
                             p_pdl_st_old pd_log.pdl_st_old%TYPE,
                             p_pdl_tp pd_log.pdl_tp%TYPE := 'SYS');
    */
    PROCEDURE set_pa_stage_2 (p_pa_id    pc_account.pa_id%TYPE,
                              p_pal_hs   pa_log.pal_hs%TYPE);

    --==============================================================--
    --  Генерація номера рахунка
    --==============================================================--
    FUNCTION gen_pa_num (p_pc_id personalcase.pc_id%TYPE)
        RETURN VARCHAR2;

    --==============================================================--
    --  Генерація номера рішення
    --==============================================================--
    FUNCTION gen_pd_num (p_pc_id personalcase.pc_id%TYPE)
        RETURN VARCHAR2;

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

    --Отримання параметру Дата з документу через рішення
    FUNCTION get_pd_doc_dt (p_pd_id    NUMBER,
                            p_sc_id    NUMBER,
                            p_ndt_id   ap_document.apd_ndt%TYPE,
                            p_nda_id   ap_document_attr.apda_nda%TYPE)
        RETURN DATE;


    --Отримання параметру Дата з документу по учаснику через рішення
    FUNCTION get_pd_doc_200_dt (p_pd_id    NUMBER,
                                p_sc_id    NUMBER,
                                p_nda_id   NUMBER)
        RETURN DATE;

    --Отримання параметру String з документу по учаснику через рішення
    FUNCTION get_pd_doc_200_str (p_pd_id    NUMBER,
                                 p_sc_id    NUMBER,
                                 p_nda_id   NUMBER)
        RETURN VARCHAR2;

    --Отримання параметру String з фіч
    FUNCTION get_features_string (p_pd_id     pc_decision.pd_id%TYPE,
                                  p_pde_nft   pd_features.pde_nft%TYPE,
                                  p_default   VARCHAR2:= '')
        RETURN VARCHAR2;

    --Отримання параметру String з фіч як число
    FUNCTION get_features_str2n (p_pd_id     pc_decision.pd_id%TYPE,
                                 p_pde_nft   pd_features.pde_nft%TYPE,
                                 p_default   NUMBER:= '')
        RETURN NUMBER;

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
    --  Необхідно здійснювати прив'язку ОР до органу ОСЗН
    --=============================================================
    PROCEDURE Update_PA_Org (p_pd_id     NUMBER,
                             p_from_st   VARCHAR2,
                             p_to_st     VARCHAR2);

    --=============================================================
    --  При переведенні рішення в стан "Нараховано" для типу виплати "Пошта" заповнбвати поле pd_pay_method.pdm_nd
    --=============================================================
    PROCEDURE Update_pdm_nd (p_pd_id NUMBER);

    --=============================================================
    --  При переведенні рішення в стан "Нараховано" - змінювати стан запису pd_income_session на F - фіксовано.
    --=============================================================
    PROCEDURE Update_pin (p_pd_id NUMBER);

    --=============================================================
    --  Перевірка, що в нас тільки один запис буде з pdm_is_actual = 'T'
    --=============================================================
    PROCEDURE Check_pd_pay_method (p_pd_id NUMBER);

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

    PROCEDURE decision_block_pap (
        p_pd         pc_decision.pd_id%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE,
        p_pnp_code   VARCHAR2,
        p_ap_src     appeal.ap_id%TYPE,
        p_hs         histsession.hs_id%TYPE DEFAULT NULL);

    PROCEDURE ReCreate_Decision_Dead (p_pd_id   NUMBER,
                                      p_dt      DATE,
                                      p_ap_id   NUMBER,
                                      p_hs      NUMBER);

    --#98793  доопрацювати припинення рішення за послугою 248
    PROCEDURE decision_block_dead (
        p_ap_id   pc_decision.pd_ap%TYPE,
        p_hs      histsession.hs_id%TYPE DEFAULT NULL);

    PROCEDURE decision_UnBlock (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE);

    PROCEDURE get_month_max (p_nst NUMBER, p_months OUT DATE);

    PROCEDURE activate_accrual (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE);

    --=============================================================
    --  Додати контроль щодо доставочної дільниці в параметрах виплати
    --=============================================================
    --#87878 20230530
    PROCEDURE Chec_pdm_nd (p_pd_id NUMBER);

    PROCEDURE proces_pc_decision_by_664;

    PROCEDURE proces_pc_decision_by_appeals;

    /*
      --Функція формування проектів рішень про призначення на основі звернення
      PROCEDURE init_pc_decision_by_appeals (p_mode INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                             p_ap_id appeal.ap_id%TYPE,
                                             p_messages OUT SYS_REFCURSOR);

    */
    --Розрахунок сукупного доходу
    PROCEDURE calc_income_for_pd (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                                  p_pd_id          pc_decision.pd_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR);

    --Розрахунок сукупного доходу альтернативний
    PROCEDURE calc_income_for_pd_alt (p_pd_id          pc_decision.pd_id%TYPE,
                                      p_messages   OUT SYS_REFCURSOR);

    --Функція отримання доходу з декларації за попередній місяць
    /*
      FUNCTION Get_apri_income(p_pd          NUMBER,
                               p_sc          NUMBER,
                               p_list_inc_tp VARCHAR2,
                               p_calc_dt     DATE,
                               p_start_dt    DATE
                               ) RETURN NUMBER;
    */
    /*
      --Функція розрахунку виплат по проектам рішень на виплату
      PROCEDURE calc_pd(p_mode INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                        p_pd_id pc_decision.pd_id%TYPE,
                        p_messages OUT SYS_REFCURSOR);
    */

    --Процедура перевірки періоду дії рішення
    PROCEDURE Check_accrual_period (p_pd_src   pc_decision%ROWTYPE,
                                    p_hs       histsession.hs_id%TYPE);

    -- визначення дати початку дії рішення для послуги 265 на підставі попереднього рішення
    FUNCTION get_start_date_265 (p_pd_pa          NUMBER,
                                 p_ap_reg_dt      DATE,
                                 p_ap_is_second   VARCHAR2)
        RETURN DATE;

    --Пошук рішкень для перевірки та побудови pd_accrual_period
    PROCEDURE init_related_decisions (p_pd_id    NUMBER,
                                      p_pd_pa    NUMBER,
                                      p_pd_nst   NUMBER);

    --Процедура перерахунку реальних періодів дії рішень для кореткного врахування в нарухуваннях, при появі нових рішень по ключу (pc,nst)
    PROCEDURE recalc_pd_periods_fs (p_pd_id   pc_decision.pd_id%TYPE,
                                    p_hs      histsession.hs_id%TYPE);

    PROCEDURE recalc_pd_periods_pv (p_pd_id      pc_decision.pd_id%TYPE,
                                    p_start_dt   DATE,
                                    p_hs         histsession.hs_id%TYPE);

    --=============================================================================--
    -- Для "Поновлення виплати" в картці рішення
    -- Процедура перерахунку реальних періодів дії рішень для кореткного врахування в нарухуваннях, при появі нових рішень по ключу (pc,nst)
    --=============================================================================--
    PROCEDURE recalc_pd_periods_1 (
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
        p_new_id              OUT pd_features.pde_id%TYPE,
        p_pd_nst           IN     NUMBER DEFAULT NULL);

    PROCEDURE Delete_Features (p_pde_id IN pd_features.pde_id%TYPE);

    -- Блокування рішення
    PROCEDURE decision_block (
        p_pd        pc_decision.pd_id%TYPE,
        p_stop_dt   pd_accrual_period.pdap_stop_dt%TYPE,
        p_PCB_RNP   pc_block.PCB_RNP%TYPE);

    -- Поновлення рішення після блокування
    PROCEDURE decision_Unblock (p_pd   pc_decision.pd_id%TYPE,
                                p_hs   histsession.hs_id%TYPE);

    PROCEDURE Recalc_pd_payment_for_unblock (p_pd_id      NUMBER,
                                             p_start_dt   DATE,
                                             p_stop_dt    DATE,
                                             p_hs         NUMBER);

    -- #100803 Необхідно надати можливість поновлювати призначені суми тим, кому допомога була обнулена по перерахунку з типом S_VPO_51
    PROCEDURE restore_payment_detail (p_pdd_id   IN NUMBER,
                                      p_reason   IN VARCHAR2,
                                      p_op       IN VARCHAR2);

    -- IC #103369
    -- Зробити процедуру для аналізу наявності діючих рішень по допомогам по особі при міграції
    FUNCTION getLastDatePayment (p_sc_id NUMBER)
        RETURN DATE;
END API$PC_DECISION;
/


GRANT EXECUTE ON USS_ESR.API$PC_DECISION TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$PC_DECISION TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$PC_DECISION TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$PC_DECISION TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$PC_DECISION TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:09 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PC_DECISION
IS
    g_messages       TOOLS.t_messages;
    g_Is_Not_Right   BOOLEAN := FALSE;

    --===========================================--
    PROCEDURE Not_Check_Calc_Right
    IS
    BEGIN
        g_Is_Not_Right := TRUE;
    END;

    --===========================================--

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

    /*
    PROCEDURE write_pd_logA(p_pdl_pd pd_log.pdl_pd%TYPE,
                           p_pdl_hs pd_log.pdl_hs%TYPE,
                           p_pdl_st pd_log.pdl_st%TYPE,
                           p_pdl_message pd_log.pdl_message%TYPE,
                           p_pdl_st_old pd_log.pdl_st_old%TYPE,
                           p_pdl_tp pd_log.pdl_tp%TYPE := 'SYS')
    IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_hs histsession.hs_id%TYPE;
    BEGIN
      --l_hs := NVL(p_pdl_hs, TOOLS.GetHistSession);
      l_hs := p_pdl_hs;
      IF l_hs IS NULL THEN
         l_hs := TOOLS.GetHistSession;
      END IF;

      INSERT INTO pd_log (pdl_id, pdl_pd, pdl_hs, pdl_st, pdl_message, pdl_st_old, pdl_tp)
        VALUES (0, p_pdl_pd, l_hs, p_pdl_st, p_pdl_message, p_pdl_st_old, NVL(p_pdl_tp, 'SYS'));
      COMMIT;
    END;
    */
    PROCEDURE write_pa_log (p_pal_pa        pa_log.pal_pa%TYPE,
                            p_pal_hs        pa_log.pal_hs%TYPE,
                            p_pal_st        pa_log.pal_st%TYPE,
                            p_pal_message   pa_log.pal_message%TYPE,
                            p_pal_st_old    pa_log.pal_st_old%TYPE,
                            p_pal_tp        pa_log.pal_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --l_hs := NVL(p_pal_hs, TOOLS.GetHistSession);
        l_hs := p_pal_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

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

    FUNCTION get_attr_id (p_doc_id NUMBER, p_nda_id NUMBER)
        RETURN NUMBER
    IS
        l_date   NUMBER;
    BEGIN
        SELECT MAX (aa.apda_val_id)
          INTO l_date
          FROM ap_document_attr aa
         WHERE aa.apda_apd = p_doc_id AND aa.apda_nda = p_nda_id;

        RETURN l_date;
    END;

    FUNCTION get_attr_date (p_doc_id NUMBER, p_nda_id NUMBER)
        RETURN DATE
    IS
        l_date   DATE;
    BEGIN
        SELECT MAX (aa.apda_val_dt)
          INTO l_date
          FROM ap_document_attr aa
         WHERE aa.apda_apd = p_doc_id AND aa.apda_nda = p_nda_id;

        RETURN l_date;
    END;

    FUNCTION get_attr_str (p_doc_id NUMBER, p_nda_id NUMBER)
        RETURN VARCHAR2
    IS
        l_str   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (aa.apda_val_string)
          INTO l_str
          FROM ap_document_attr aa
         WHERE aa.apda_apd = p_doc_id AND aa.apda_nda = p_nda_id;

        RETURN l_str;
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

    --==============================================================--
    --  Генерація номера рішення
    --==============================================================--
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

        --  dbms_output.put_line(l_cnt);
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

    --Отримання параметру Дата з документу через рішення
    FUNCTION get_pd_doc_dt (p_pd_id    NUMBER,
                            p_sc_id    NUMBER,
                            p_ndt_id   ap_document.apd_ndt%TYPE,
                            p_nda_id   ap_document_attr.apda_nda%TYPE)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        IF p_sc_id IS NOT NULL
        THEN
            SELECT MAX (apda.apda_val_dt)
              INTO l_rez
              FROM pc_decision
                   JOIN ap_person app
                       ON     app.app_ap IN (pd_ap, pd_ap_reason)
                          AND app.history_status = 'A'
                   JOIN ap_document apd
                       ON     apd_app = app_id
                          AND apd_ndt = p_ndt_id
                          AND apd.history_status = 'A'
                   JOIN ap_document_attr apda
                       ON     apda_apd = apd_id
                          AND apda_nda = p_nda_id
                          AND apda.history_status = 'A'
             WHERE     pd_id = p_pd_id
                   AND app.app_sc = p_sc_id
                   AND app.history_status = 'A';
        ELSE
            SELECT MAX (apda.apda_val_dt)
              INTO l_rez
              FROM pc_decision
                   JOIN ap_person app
                       ON     app.app_ap IN (pd_ap, pd_ap_reason)
                          AND app.history_status = 'A'
                   JOIN ap_document apd
                       ON     apd_app = app_id
                          AND apd_ndt = p_ndt_id
                          AND apd.history_status = 'A'
                   JOIN ap_document_attr apda
                       ON     apda_apd = apd_id
                          AND apda_nda = p_nda_id
                          AND apda.history_status = 'A'
             WHERE pd_id = p_pd_id AND app.history_status = 'A';
        END IF;

        RETURN l_rez;
    END;

    --Отримання параметру Дата з документу по учаснику через рішення
    FUNCTION get_pd_doc_200_dt (p_pd_id    NUMBER,
                                p_sc_id    NUMBER,
                                p_nda_id   NUMBER)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        SELECT apda.apda_val_dt
          INTO l_rez
          FROM pc_decision
               JOIN ap_person app
                   ON     app.app_ap IN (pd_ap, pd_ap_reason)
                      AND app.history_status = 'A'
               JOIN ap_document apd
                   ON     apd_app = app_id
                      AND apd_ndt = 200
                      AND apd.history_status = 'A'
               JOIN ap_document_attr apda
                   ON     apda_apd = apd_id
                      AND apda_nda = p_nda_id
                      AND apda.history_status = 'A'
         WHERE     pd_id = p_pd_id
               AND app.app_sc = p_sc_id
               --AND app.app_tp = 'FP'
               AND app.history_status = 'A';

        RETURN l_rez;
    END;

    --Отримання параметру String з документу по учаснику через рішення
    FUNCTION get_pd_doc_200_str (p_pd_id    NUMBER,
                                 p_sc_id    NUMBER,
                                 p_nda_id   NUMBER)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (2000);
    BEGIN
        SELECT apda.apda_val_string
          INTO l_rez
          FROM pc_decision
               JOIN ap_person app
                   ON     app.app_ap IN (pd_ap, pd_ap_reason)
                      AND app.history_status = 'A'
               JOIN ap_document apd
                   ON     apd_app = app_id
                      AND apd_ndt = 200
                      AND apd.history_status = 'A'
               JOIN ap_document_attr apda
                   ON     apda_apd = apd_id
                      AND apda_nda = p_nda_id
                      AND apda.history_status = 'A'
         WHERE     pd_id = p_pd_id
               AND app.app_sc = p_sc_id
               --AND app.app_tp = 'FP'
               AND app.history_status = 'A';

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

    FUNCTION get_features_string (p_pd_id     pc_decision.pd_id%TYPE,
                                  p_pde_nft   pd_features.pde_nft%TYPE,
                                  p_default   VARCHAR2:= '')
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (f.pde_val_string)
          INTO l_rez
          FROM pd_features f
         WHERE f.pde_pd = p_pd_id AND f.pde_nft = p_pde_nft;

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        ELSE
            RETURN l_rez;
        END IF;
    END;

    FUNCTION get_features_str2n (p_pd_id     pc_decision.pd_id%TYPE,
                                 p_pde_nft   pd_features.pde_nft%TYPE,
                                 p_default   NUMBER:= '')
        RETURN NUMBER
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        l_rez := get_features_string (p_pd_id, p_pde_nft, '');

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (
                       TO_NUMBER (
                           l_rez DEFAULT p_default ON CONVERSION ERROR),
                       p_default);
        ELSE
            RETURN TO_NUMBER (l_rez DEFAULT p_default ON CONVERSION ERROR);
        END IF;
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
        l_new_Id   NUMBER;

        ------------------------------
        CURSOR adr IS
            SELECT App.App_Ap,
                   App.App_Id,
                   App.App_Sc,
                   App.App_Tp,
                   Apd.apd_id
                       AS apd_id,
                   Apd_alt.apd_id
                       AS alt_apd_id,
                   --1 Адреса реєстрації
                   api$pc_decision.get_attr_id (apd.Apd_Id, 580)
                       AS r_katottg, -- КАТОТТГ адреси реєстрації ID V_MF_KOATUU_TEST
                   api$pc_decision.get_attr_str (apd.Apd_Id, 582)
                       AS r_apartment,    -- Квартира адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 583)
                       AS r_corps,          -- Корпус адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 584)
                       AS r_House,         -- Будинок адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 585)
                       AS r_Strit_id, -- Вулиця адреси реєстрації (довідник) ID V_NDI_STREET
                   api$pc_decision.get_attr_str (apd.Apd_Id, 586)
                       AS r_city,            -- Місто адреси реєстрації STRING
                   api$pc_decision.get_attr_id (apd.Apd_Id, 587)
                       AS r_Index,   -- Індекс адреси реєстрації ID v_mf_index
                   api$pc_decision.get_attr_str (apd.Apd_Id, 588)
                       AS r_District,        -- Район адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 589)
                       AS r_region,        -- Область адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 591)
                       AS r_country,        -- Країна адреси реєстрації STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 787)
                       AS r_Strit, -- Вулиця адреси реєстрації STRING V_NDI_STREET
                   api$pc_decision.get_attr_str (apd.Apd_Id, 2303)
                       AS r_Strit_tp,          -- Тип вулиці адреси реєстрації
                   --2 Адреса проживання
                   api$pc_decision.get_attr_id (apd.Apd_Id, 604)
                       AS l_katottg, -- КАТОТТГ адреси проживання ID V_MF_KOATUU_TEST
                   api$pc_decision.get_attr_str (apd.Apd_Id, 594)
                       AS l_apartment,    -- Квартира адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 595)
                       AS l_corps,          -- Корпус адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 596)
                       AS l_House,         -- Будинок адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 597)
                       AS l_Strit_id, -- Вулиця адреси проживання (довідник) ID V_NDI_STREET
                   api$pc_decision.get_attr_str (apd.Apd_Id, 598)
                       AS l_city,            -- Місто адреси проживання STRING
                   api$pc_decision.get_attr_id (apd.Apd_Id, 599)
                       AS l_Index,   -- Індекс адреси проживання ID v_mf_index
                   api$pc_decision.get_attr_str (apd.Apd_Id, 600)
                       AS l_District,        -- Район адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 601)
                       AS l_region,        -- Область адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 603)
                       AS l_country,        -- Країна адреси проживання STRING
                   api$pc_decision.get_attr_str (apd.Apd_Id, 788)
                       AS l_Strit, -- Вулиця адреси проживання STRING V_NDI_STREET
                   api$pc_decision.get_attr_str (apd.Apd_Id, 2304)
                       AS l_Strit_tp,          -- Тип вулиці адреси проживання
                   --3 Додаткові параметри
                   api$pc_decision.get_attr_str (apd.Apd_Id, 592)
                       AS Is_equality, -- Ознака співпадіння адреси реєстрації та проживання STRING
                   --4 Адреса реєстрації алтернативна
                   api$pc_decision.get_attr_id (Apd_alt.Apd_Id, 3477)
                       AS alt_katottg, -- КАТОТТГ адреси реєстрації ID V_MF_KOATUU_TEST
                   api$pc_decision.get_attr_str (Apd_alt.Apd_Id, 3485)
                       AS alt_apartment,  -- Квартира адреси реєстрації STRING
                   api$pc_decision.get_attr_str (Apd_alt.Apd_Id, 3484)
                       AS alt_corps,        -- Корпус адреси реєстрації STRING
                   api$pc_decision.get_attr_str (Apd_alt.Apd_Id, 3483)
                       AS alt_House,       -- Будинок адреси реєстрації STRING
                   api$pc_decision.get_attr_str (Apd_alt.Apd_Id, 3480)
                       AS alt_Strit_id, -- Вулиця адреси реєстрації (довідник) ID V_NDI_STREET
                   api$pc_decision.get_attr_id (Apd_alt.Apd_Id, 3478)
                       AS alt_Index, -- Індекс адреси реєстрації ID v_mf_index
                   api$pc_decision.get_attr_str (Apd_alt.Apd_Id, 3481)
                       AS alt_Strit, -- Вулиця адреси реєстрації STRING V_NDI_STREET
                   api$pc_decision.get_attr_str (Apd_alt.Apd_Id, 3479)
                       AS alt_Strit_tp -- Вулиця адреси реєстрації STRING V_NDI_STREET
              FROM Ap_Person  App
                   LEFT JOIN Ap_Document Apd
                       ON     Apd.Apd_App = App.App_Id
                          AND Apd.Apd_Ndt = 600
                          AND Apd.History_Status = 'A'
                   LEFT JOIN Ap_Document Apd_alt
                       ON     Apd_alt.Apd_App = App.App_Id
                          AND Apd_alt.Apd_Ndt = 10221
                          AND Apd_alt.History_Status = 'A'
             WHERE     App.App_Ap = p_Ap
                   AND App.App_Tp IN ('Z', 'FP')
                   AND App.History_Status = 'A'
                   AND App_Sc IS NOT NULL;
    ------------------------------
    BEGIN
        --#84282 2023.02.21
        FOR rec IN adr
        LOOP
            --3 2011  3 3 Місце реєстрації  Місце реєстрації  A 3
            --4 2011  2 2 Місце проживання  Місце проживання  A 2
            --106 1 UA Україна Україна A
            IF rec.apd_id IS NOT NULL
            THEN
                Uss_Person.Api$socialcard.Save_Sc_Address (
                    p_Sca_Sc          => rec.app_sc,
                    p_Sca_Tp          => 3,
                    p_Sca_Kaot        => rec.r_katottg,
                    p_Sca_Nc          => 1,
                    p_Sca_Country     => NVL (rec.r_country, 'Україна'),
                    p_Sca_Region      => rec.r_region,
                    p_Sca_District    => rec.r_district,
                    p_Sca_Postcode    => rec.r_index,
                    p_Sca_City        => rec.r_city,
                    p_Sca_Street      => NVL (rec.r_strit_id, rec.r_strit),
                    p_Sca_Building    => rec.r_house,
                    p_Sca_Block       => rec.r_corps,
                    p_Sca_Apartment   => rec.r_apartment,
                    p_Sca_Note        => '',
                    p_Sca_Src         => 'ESR',
                    p_Sca_Create_Dt   => SYSDATE,
                    o_Sca_Id          => l_new_Id);

                IF rec.is_equality != 'T'
                THEN
                    Uss_Person.Api$socialcard.Save_Sc_Address (
                        p_Sca_Sc          => rec.app_sc,
                        p_Sca_Tp          => 2,
                        p_Sca_Kaot        => rec.l_katottg,
                        p_Sca_Nc          => 1,
                        p_Sca_Country     => NVL (rec.l_country, 'Україна'),
                        p_Sca_Region      => rec.l_region,
                        p_Sca_District    => rec.l_district,
                        p_Sca_Postcode    => rec.l_index,
                        p_Sca_City        => rec.l_city,
                        p_Sca_Street      => NVL (rec.l_strit_id, rec.l_strit),
                        p_Sca_Building    => rec.l_house,
                        p_Sca_Block       => rec.l_corps,
                        p_Sca_Apartment   => rec.l_apartment,
                        p_Sca_Note        => '',
                        p_Sca_Src         => 'ESR',
                        p_Sca_Create_Dt   => SYSDATE,
                        o_Sca_Id          => l_new_Id);
                END IF;
            ELSIF rec.alt_apd_id IS NOT NULL
            THEN
                Uss_Person.Api$socialcard.Save_Sc_Address (
                    p_Sca_Sc          => rec.app_sc,
                    p_Sca_Tp          => 3,
                    p_Sca_Kaot        => rec.alt_katottg,
                    p_Sca_Nc          => 1,
                    p_Sca_Country     => 'Україна',
                    p_Sca_Region      => NULL,               --rec.alt_region,
                    p_Sca_District    => NULL,             --rec.alt_district,
                    p_Sca_Postcode    => rec.alt_index,
                    p_Sca_City        => NULL,                 --rec.alt_city,
                    p_Sca_Street      => NVL (rec.alt_strit_id, rec.alt_strit),
                    p_Sca_Building    => rec.alt_house,
                    p_Sca_Block       => rec.alt_corps,
                    p_Sca_Apartment   => rec.alt_apartment,
                    p_Sca_Note        => '',
                    p_Sca_Src         => 'ESR',
                    p_Sca_Create_Dt   => SYSDATE,
                    o_Sca_Id          => l_new_Id);
            END IF;
        END LOOP;

        api$appeal.Copy_Document2Socialcard (p_ap, 0);
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

        API$PC_BLOCK.decision_block (p_hs);
    END;

    --=============================================================
    PROCEDURE decision_block_pap (
        p_pd         pc_decision.pd_id%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE,
        p_pnp_code   VARCHAR2,
        p_ap_src     appeal.ap_id%TYPE,
        p_hs         histsession.hs_id%TYPE DEFAULT NULL)
    IS
        l_pcb        pc_block.pcb_id%TYPE;
        l_hs         histsession.hs_id%TYPE;
        l_start_dt   pc_decision.pd_start_dt%TYPE;
        l_stop_dt    pc_decision.pd_stop_dt%TYPE;
    BEGIN
        API$PC_BLOCK.CLEAR_BLOCK;

        SELECT pd.pd_start_dt, pd.pd_stop_dt
          INTO l_start_dt, l_stop_dt
          FROM pc_decision pd
         WHERE pd.pd_id = p_pd;

        IF l_start_dt > p_stop_dt
        THEN
            raise_application_error (
                -20000,
                   'Дата "'
                || TO_CHAR (p_stop_dt, 'dd.mm.yyyy')
                || '" не може бути менша за номінальний початок строку дії рішення "'
                || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
                || '"!');
        END IF;

        IF L_stop_dt + 1 < p_stop_dt
        THEN
            raise_application_error (
                -20000,
                'Така дата не може бути більша за наступний день від закінчення номінального періоду дії рішення!');
        END IF;


        l_hs := NVL (p_hs, tools.GetHistSession);

        INSERT INTO tmp_pc_block (b_id,
                                  b_pc,
                                  b_pd,
                                  b_tp,
                                  b_rnp,
                                  b_locl_pnp_tp,
                                  b_hs_lock,
                                  b_ap_src,
                                  b_dt)
            (SELECT l_pcb,
                    pd.pd_pc,
                    pd.pd_id,
                    'PAP',
                    np.rnp_id,
                    np.rnp_pnp_tp,
                    l_hs,
                    p_ap_src,
                    p_stop_dt
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

        API$PC_BLOCK.decision_block (l_hs);
    END;

    --=============================================================
    PROCEDURE ReCreate_Decision_Dead (p_pd_id   NUMBER,
                                      p_dt      DATE,
                                      p_ap_id   NUMBER,
                                      p_hs      NUMBER)
    IS
        l_cnt        NUMBER;
        l_sql_cnt    NUMBER;
        l_pd_id      NUMBER;
        l_start_dt   DATE;
        l_stop_dt    DATE;
        pay_method   pd_pay_method%ROWTYPE;
        l_lock       TOOLS.t_lockhandler;
        l_num        VARCHAR2 (200);

        p_messages   SYS_REFCURSOR;

        CURSOR pdm (p_pd NUMBER)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE p.pdm_pd = p_pd AND p.history_status = 'A'
            ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;
    BEGIN
        --
        api$account.init_tmp_for_pd (p_pd_id);

        --
        SELECT COUNT (1)
          INTO l_cnt
          FROM tmp_pa_persons
         WHERE     tpp_app_tp = 'FP'
               AND NVL (tpp_ch_fm, '-') != 'DEL'
               AND tpp_pd = p_pd_id;

        IF l_cnt = 0
        THEN
            RETURN;
        END IF;

        l_pd_id := id_pc_decision (0);
        l_start_dt := p_dt + 1;

        SELECT pd_stop_dt
          INTO l_stop_dt
          FROM pc_decision pd
         WHERE pd.pd_id = p_pd_id;

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
                   'S'      AS x_st,
                   pd_nst,
                   com_org,
                   com_wu,
                   'PV'     AS x_pd_src,
                   pd_ps,
                   pd_id,
                   pd_has_right,
                   l_start_dt,
                   pd_stop_dt,
                   p_ap_id,
                   pd_scc
              FROM pc_decision pd
             WHERE pd.pd_id = p_pd_id;

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
             WHERE pds_pd = p_pd_id AND history_status = 'A'
            UNION ALL
            SELECT 0,
                   l_pd_id     AS pds_pd,
                   'AN'        AS pds_tp,
                   p_ap_id     AS pds_ap,
                   SYSDATE,
                   'A'
              FROM DUAL;

        FOR pm IN pdm (p_pd_id)
        LOOP
            pay_method := pm;
        END LOOP;

        IF pay_method.pdm_pd IS NOT NULL
        THEN
            pay_method.pdm_id := NULL;
            pay_method.pdm_pd := l_pd_id;
            pay_method.pdm_start_dt := l_start_dt;

            INSERT INTO pd_pay_method
                 VALUES pay_method;
        END IF;

        INSERT INTO pd_right_log (prl_id,
                                  prl_pd,
                                  prl_nrr,
                                  prl_result,
                                  prl_hs_rewrite,
                                  prl_calc_result,
                                  prl_calc_info)
            SELECT 0           AS x_id,
                   l_pd_id     AS x_pd,
                   prl_nrr,
                   prl_result,
                   prl_hs_rewrite,
                   prl_calc_result,
                   prl_calc_info
              FROM pd_right_log prl
             WHERE prl.prl_pd = p_pd_id;

        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_nft,
                                 pde_val_int,
                                 pde_val_sum,
                                 pde_val_id,
                                 pde_val_dt,
                                 pde_val_string,
                                 pde_pdf)
            SELECT 0           AS x_id,
                   l_pd_id     AS x_pd,
                   pde_nft,
                   pde_val_int,
                   pde_val_sum,
                   pde_val_id,
                   pde_val_dt,
                   pde_val_string,
                   pde_pdf
              FROM pd_features pde
             WHERE pde.pde_pd = p_pd_id;

        INSERT INTO pd_family (pdf_id,
                               pdf_pd,
                               pdf_sc,
                               pdf_birth_dt,
                               history_status,
                               pdf_hs_ins,
                               pdf_tp,
                               pdf_start_dt,
                               pdf_stop_dt)
            SELECT 0           AS x_id,
                   l_pd_id     AS x_pd,
                   pdf_sc,
                   pdf_birth_dt,
                   'A',
                   p_hs,
                   pdf.pdf_tp,
                   t.tpp_dt_from,
                   t.tpp_dt_to
              FROM pd_family  pdf
                   LEFT JOIN tmp_pa_persons t
                       ON     tpp_sc = pdf.pdf_sc
                          AND tpp_pd = pdf.pdf_pd
                          AND history_status = 'A'
             WHERE pdf.pdf_pd = p_pd_id;

        /*
            INSERT INTO tmp_in_calc_pd (ic_pd,ic_tp, ic_start_dt)
            VALUES ( l_pd_ID, 'RC.START_DT', l_start_dt);
        */

        --dbms_output_put_lines('l_start_dt = '||l_start_dt||'   l_stop_dt='||l_stop_dt);

        api$calc_pd.calc_pd (1,
                             l_pd_ID,
                             'RC.START_DT',
                             l_start_dt,
                             l_stop_dt,
                             NULL,
                             p_messages);



        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1, x_id2)
            SELECT pdp_id, id_pd_payment (0)
              FROM pd_payment pdp
             WHERE pdp.pdp_pd = p_pd_id AND pdp.pdp_stop_dt > l_start_dt;

        l_sql_cnt := SQL%ROWCOUNT;
        /*
            IF l_sql_cnt > 0 THEN
              INSERT INTO pd_payment (pdp_id, pdp_pd, pdp_npt, pdp_start_dt, pdp_stop_dt, pdp_sum, pdp_hs_ins, pdp_hs_del, history_status)
              SELECT x_id2, l_pd_id AS x_pd, pdp_npt,
                     CASE
                       WHEN pdp_start_dt < l_start_dt THEN
                         l_start_dt
                       ELSE
                         pdp_start_dt
                     END AS x_start_dt,
                     pdp_stop_dt, pdp_sum, pdp_hs_ins, pdp_hs_del, history_status
              FROM pd_payment pdp
                   JOIN tmp_work_set1 ON x_id1 = pdp_id;

              INSERT INTO pd_detail (pdd_id, pdd_pdp, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp, pdd_start_dt, pdd_stop_dt, pdd_npt)
              SELECT 0 AS x_id, x_new_pdp, pdd_row_order, pdd_row_name, pdd_value, pdf.pdf_id, pdd_ndp,
                     CASE
                       WHEN pdd_start_dt < l_start_dt THEN
                         l_start_dt
                       ELSE
                         pdd_start_dt
                     END AS x_start_dt,
                     pdd_stop_dt, pdd_npt
              FROM (SELECT pdd.*, x_id2 AS x_new_pdp, pdf.pdf_sc AS x_sc
                    FROM pd_detail pdd
                         JOIN tmp_work_set1 ON x_id1 = pdd_pdp
                         JOIN pd_family pdf ON pdf.pdf_pd = p_pd_id AND pdf.pdf_id = pdd.pdd_key AND pdf.history_status = 'A'
                   ) pdd
                   JOIN pd_family pdf ON pdf.pdf_pd = l_pd_id AND pdf.history_status = 'A' AND pdf.pdf_sc = pdd.x_sc
              WHERE l_start_dt BETWEEN pdf.pdf_start_dt AND pdf.pdf_stop_dt;

            ELSE
              INSERT INTO tmp_work_set1 (x_id1, x_id2)
              SELECT pdp_id, id_pd_payment(0)
              FROM pd_payment pdp
              WHERE pdp.pdp_pd = p_pd_id
                AND (pdp.pdp_stop_dt + 1) > l_start_dt ;

              INSERT INTO pd_payment (pdp_id, pdp_pd, pdp_npt, pdp_start_dt, pdp_stop_dt, pdp_sum, pdp_hs_ins, pdp_hs_del, history_status)
              SELECT x_id2, l_pd_id AS x_pd, pdp_npt,
                     CASE
                       WHEN pdp_start_dt < l_start_dt THEN
                         l_start_dt
                       ELSE
                         pdp_start_dt
                     END AS x_start_dt,
                     pdp_stop_dt,
                     pdp_sum, pdp_hs_ins, pdp_hs_del, history_status
              FROM pd_payment pdp
                   JOIN tmp_work_set1 ON x_id1 = pdp_id;

              INSERT INTO pd_detail (pdd_id, pdd_pdp, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp, pdd_start_dt, pdd_stop_dt, pdd_npt)
              SELECT 0 AS x_id, x_new_pdp, pdd_row_order, pdd_row_name, pdd_value, pdf.pdf_id, pdd_ndp,
                     CASE
                       WHEN pdd_start_dt < l_start_dt THEN
                         l_start_dt
                       ELSE
                         pdd_start_dt
                     END AS x_start_dt,
                     pdd_stop_dt, pdd_npt
              FROM (SELECT pdd.*, x_id2 AS x_new_pdp, pdf.pdf_sc AS x_sc
                    FROM pd_detail pdd
                         JOIN tmp_work_set1 ON x_id1 = pdd_pdp
                         JOIN pd_family pdf ON pdf.pdf_pd = p_pd_id AND pdf.pdf_id = pdd.pdd_key AND pdf.history_status = 'A'
                   ) pdd
                   JOIN pd_family pdf ON pdf.pdf_pd = l_pd_id AND pdf.history_status = 'A' AND pdf.pdf_sc = pdd.x_sc
              WHERE l_start_dt BETWEEN pdf.pdf_start_dt AND pdf.pdf_stop_dt;

        --      INSERT INTO pd_detail (pdd_id, pdd_pdp, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp, pdd_start_dt, pdd_stop_dt, pdd_npt)
        --      SELECT 0 AS x_id, x_id2, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp,
        --             CASE
        --               WHEN pdd_start_dt < l_start_dt THEN
        --                 l_start_dt
        --               ELSE
        --                 pdd_start_dt
        --             END AS x_start_dt,
        --             pdd_stop_dt,
        --             pdd_npt
        --      FROM pd_detail pdd
        --           JOIN tmp_work_set1 ON x_id1 = pdd_pdp;

            END IF;
        */
        api$pc_decision.recalc_pd_periods_fs (l_pd_id, p_hs);

        --Проставляємо номери рішень
        FOR xx
            IN (SELECT pd_id,
                       pc_id,
                       pc_num,
                       nst_name,
                       pa_num
                  FROM (  SELECT pd_id,
                                 pc_id,
                                 pc_num,
                                 nst_name,
                                 pa_num
                            FROM personalcase,
                                 pc_decision,
                                 uss_ndi.v_ndi_service_type,
                                 pc_account
                           WHERE     pd_pc = pc_id
                                 AND pd_id = l_pd_id
                                 AND pd_nst = nst_id
                                 AND pd_num IS NULL
                                 AND pd_pa = pa_id
                        ORDER BY LPAD (pa_num, 10, '0') ASC, pd_id ASC))
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

            TOOLS.release_lock (l_lock);
            --TOOLS.add_message(g_messages, 'I', 'Створено проект рішення рахунок № '||l_num||' для ЕОС № '||xx.pc_num||' по послузі: '||xx.nst_name||'.');
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                p_hs,
                'S',
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
            API$ESR_Action.PrepareCopy_ESR2Visit (
                p_ap_id,
                'V',
                   CHR (38)
                || '11#'
                || l_num
                || '#'
                || xx.pc_num
                || '#'
                || xx.nst_name);
        END LOOP;
    -- api$pc_decision.recalc_pd_periods(p_pd_id => l_pd_id, p_hs => p_hs);

    END;

    --=============================================================
    --#98793  доопрацювати припинення рішення за послугою 248
    --Потрібно доопрацювати припинення виплати із зазначенням причини RNP_ID = 2 (СМЕРТЬ ОДЕРЖУВАЧА), без можливості поновлення виплати.
    PROCEDURE decision_block_dead (
        p_ap_id   pc_decision.pd_ap%TYPE,
        p_hs      histsession.hs_id%TYPE DEFAULT NULL)
    IS
        l_pd_id      NUMBER;
        l_block_dt   DATE;
    BEGIN
        SELECT MAX (pds.pds_pd), MAX (pds.pds_create_dt)
          INTO l_pd_id, l_block_dt
          FROM pd_source pds
         WHERE     pds.pds_ap = p_ap_id
               AND pds.pds_tp = 'DP'
               AND pds.history_status = 'A';

        IF l_pd_id IS NOT NULL AND l_block_dt IS NOT NULL
        THEN
            decision_block_pap (l_pd_id,
                                LAST_DAY (l_block_dt),
                                'DE',
                                p_ap_id,
                                p_hs);
            ReCreate_Decision_Dead (l_pd_id,
                                    LAST_DAY (l_block_dt),
                                    p_ap_id,
                                    p_hs);
        END IF;

        NULL;
    END;

    --=============================================================
    --#95767
    --Виклик функції decision_UnBlock з інтерфейсу для послуг:
    --ВПО (664);
    --(267,268);
    --супроводжується заповненням таблиці tmp_work_set3: поля x_id1, x_id2, x_sum1, x_string1 заповнюватимуться відповідно pdf_id, pdd_id, pdd_value,
    --обраний варіант для рядка варіант - 1/0 - Поновлювати особі виплату чи ні.
    --
    --Відповідно, при формуванні з вказаної дати записів pd_payment та pd_detail, необхідно виключити осіб, для яких вибрано код "0".
    --=============================================================
    PROCEDURE Recalc_pd_payment_for_unblock (p_pd_id      NUMBER,
                                             p_start_dt   DATE,
                                             p_stop_dt    DATE,
                                             p_hs         NUMBER)
    IS
        l_tmp_cnt   NUMBER;
        l_str       VARCHAR2 (4000);
    BEGIN
        --    RETURN;

        SELECT LISTAGG (
                      'insert into tmp_work_set3 (x_id1,x_id2,x_sum1,x_string1) values ('
                   || x_id1
                   || ', '
                   || x_id2
                   || ', '
                   || x_sum1
                   || ', '''
                   || x_string1
                   || ''');',
                   CHR (13) || CHR (10)
                   ON OVERFLOW TRUNCATE '...')
               WITHIN GROUP (ORDER BY x_id1)
          INTO l_str
          FROM tmp_work_set3;

        API$PC_DECISION.write_pd_log (
            p_pd_Id,
            NULL,
            'S',
               'Період: '
            || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
            || ' - '
            || TO_CHAR (p_stop_dt, 'dd.mm.yyyy'),
            '');
        API$PC_DECISION.write_pd_log (p_pd_Id,
                                      NULL,
                                      'S',
                                      l_str,
                                      '');


        SELECT COUNT (1) INTO l_tmp_cnt FROM tmp_work_set3;

        -- таблиця пуста - нічого не робимо.
        IF l_tmp_cnt = 0
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_tmp_cnt
          FROM tmp_work_set3
         WHERE x_string1 = '-1';

        -- Немає осіб під виключення - нічого не робимо.
        IF l_tmp_cnt = 0
        THEN
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO l_tmp_cnt
          FROM tmp_work_set3 JOIN pd_family ON pdf_id = x_id1
         WHERE pdf_pd != p_pd_id;

        -- Є записи не нашого pc_decision
        IF l_tmp_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'Є записи не нашого pc_decision (pd_id = '
                || p_pd_id
                || ') !');
        END IF;

        SELECT COUNT (1)
          INTO l_tmp_cnt
          FROM pc_decision
         WHERE pd_id = p_pd_id AND pd_nst NOT IN (664             /*,267,268*/
                                                     );

        -- Є записи не нашого pc_decision
        IF l_tmp_cnt > 0
        THEN
            RETURN;
        --      raise_application_error(-20000, 'Не допустима послуга !');
        END IF;

        WITH
            t
            AS
                (SELECT x_id1         AS x_pdf,
                        x_id2         AS x_pdd,
                        x_sum1        AS x_value,
                        x_string1     AS x_bool
                   FROM tmp_work_set3)
        SELECT COUNT (1)
          INTO l_tmp_cnt
          FROM t
               JOIN pd_detail pdd
                   ON pdd.pdd_id = t.x_pdd AND pdd.pdd_stop_dt > p_start_dt;

        --    WHERE pdf_pd != p_pd_id;

        --SELECT x_id1 AS x_pdf, x_id2 AS x_pdd, x_sum1 AS x_value, x_string1 AS x_bool FROM tmp_work_set3

        /*
        DELETE FROM tmp_work_set3 WHERE 1=1;
        INSERT INTO tmp_work_set3(x_id1, x_id2, x_sum1, x_string1)
        SELECT pdd_key, pdd_id, pdd_value, CASE pdd_key WHEN 814474 THEN '0' ELSE '1' END
        FROM pd_detail
        WHERE pdd_key IN (SELECT pdf_id FROM pd_family pdf WHERE pdf.pdf_pd = 772566);
        */
        --SELECT x_id1 AS x_pdf, x_id2 AS x_pdd, x_sum1 AS x_val, x_string1 AS Is_include
        --FROM tmp_work_set3

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1,
                                   x_id2,
                                   x_dt1,
                                   x_dt2)
            SELECT pdp.pdp_id,
                   id_pd_payment (0)     AS new_id,
                   pdp.pdp_start_dt,
                   p_start_dt - 1
              FROM pd_payment pdp
             WHERE     pdp.pdp_pd = p_pd_id
                   AND p_start_dt BETWEEN pdp.pdp_start_dt
                                      AND pdp.pdp_stop_dt
                   AND pdp.pdp_start_dt < (p_start_dt - 1)
                   AND pdp.history_status = 'A'
            UNION ALL
            SELECT pdp.pdp_id,
                   id_pd_payment (0)     AS new_id,
                   p_start_dt,
                   pdp.pdp_stop_dt
              FROM pd_payment pdp
             WHERE     pdp.pdp_pd = p_pd_id
                   AND p_start_dt BETWEEN pdp.pdp_start_dt
                                      AND pdp.pdp_stop_dt
                   AND pdp.history_status = 'A'
            UNION ALL
            SELECT pdp.pdp_id,
                   id_pd_payment (0)     AS new_id,
                   pdp.pdp_start_dt,
                   pdp.pdp_stop_dt
              FROM pd_payment pdp
             WHERE     pdp.pdp_pd = p_pd_id
                   AND p_start_dt < pdp.pdp_start_dt
                   AND pdp.history_status = 'A';

        UPDATE pd_payment pdp
           SET pdp.history_status = 'H',
               pdp.pdp_src = 'UB',
               pdp.pdp_hs_del = p_hs
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set1
                     WHERE x_id1 = pdp_id);

        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                pdp_hs_ins,
                                history_status,
                                pdp_src)
            WITH
                tmp_pdp
                AS
                    (SELECT x_id1     AS x_pdp_old,
                            x_id2     AS x_pdp_new,
                            x_dt1     AS x_start_dt,
                            x_dt2     AS x_stop_dt
                       FROM tmp_work_set1)
            SELECT x_pdp_new,
                   pdp.pdp_pd,
                   pdp.pdp_npt,
                   x_start_dt,
                   x_stop_dt,
                   pdp_sum,
                   p_hs,
                   'A',
                   'UB'
              FROM tmp_pdp JOIN pd_payment pdp ON pdp.pdp_id = x_pdp_old;

        /*
            INSERT INTO pd_detail (pdd_id, pdd_pdp, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp,
                                   pdd_start_dt, pdd_stop_dt, pdd_npt)
            WITH tmp_pdp AS (SELECT x_id1 AS x_pdp_old, x_id2 AS x_pdp_new, x_dt1 AS x_start_dt, x_dt2 AS x_stop_dt
                             FROM tmp_work_set1  ),
                 tmp_pdd AS (SELECT x_id1 AS x_pdf, x_id2 AS x_pdd, x_sum1 AS x_val, x_string1 AS Is_include
                             FROM tmp_work_set3  )
            SELECT 0 AS x_pdd_id, x_pdp_new, pdd_row_order, pdd_row_name, pdd_value, pdd_key,
                   CASE
                   WHEN NVL(Is_include, '1') = '-1' AND p_start_dt <= x_start_dt THEN -300
                   ELSE  pdd_ndp
                   END AS x_pdd_ndp,
                   x_start_dt,  x_stop_dt, pdd_npt
            FROM tmp_pdp
                 JOIN pd_detail pdd ON pdd.pdd_pdp = x_pdp_old
                 LEFT JOIN tmp_pdd ON x_pdf = pdd.pdd_key;*/
        INSERT INTO pd_detail (pdd_id,
                               pdd_pdp,
                               pdd_row_order,
                               pdd_row_name,
                               pdd_value,
                               pdd_key,
                               pdd_ndp,
                               pdd_start_dt,
                               pdd_stop_dt,
                               pdd_npt)
            WITH
                tmp_pdp
                AS
                    (SELECT x_id1     AS x_pdp_old,
                            x_id2     AS x_pdp_new,
                            x_dt1     AS x_start_dt,
                            x_dt2     AS x_stop_dt
                       FROM tmp_work_set1),
                tmp_pdd
                AS
                    (SELECT x_id1         AS x_pdf,
                            x_id2         AS x_pdd,
                            x_sum1        AS x_val,
                            x_string1     AS Is_include
                       FROM tmp_work_set3)
            SELECT 0      AS x_pdd_id,
                   x_pdp_new,
                   pdd_row_order,
                   pdd_row_name,
                   pdd_value,
                   pdd_key,
                   CASE
                       WHEN NVL (
                                (SELECT MIN (Is_include)
                                   FROM tmp_pdd
                                  WHERE     x_pdf = pdd.pdd_key
                                        AND p_start_dt <= x_start_dt),
                                '1') =
                            '-1'
                       THEN
                           -300
                       ELSE
                           pdd_ndp
                   END    AS x_pdd_ndp,
                   x_start_dt,
                   x_stop_dt,
                   pdd_npt
              FROM tmp_pdp JOIN pd_detail pdd ON pdd.pdd_pdp = x_pdp_old;


        UPDATE pd_payment pdp
           SET pdp.pdp_sum =
                   (SELECT NVL (SUM (pdd.pdd_value), 0)
                      FROM pd_detail  pdd
                           JOIN uss_ndi.v_ndi_pd_row_type ON pdd_ndp = ndp_id
                     WHERE     pdd.pdd_pdp = pdp.pdp_id
                           AND pdd.pdd_npt IS NOT NULL
                           AND pdd_ndp > 0
                           AND ndp_alg IS NULL)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set1
                         WHERE x_id2 = pdp_id)
               AND p_start_dt <= pdp_start_dt;
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
                   'Дата "'
                || TO_CHAR (p_stop_dt, 'dd.mm.yyyy')
                || '" не може бути менша за номінальний початок строку дії рішення "'
                || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
                || '"!');
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

        API$PC_BLOCK.decision_block (l_hs);
    END;

    --=============================================================
    PROCEDURE decision_Unblock (p_pd   pc_decision.pd_id%TYPE,
                                p_hs   histsession.hs_id%TYPE)
    IS
        l_suspend_reason   VARCHAR2 (200);
        IsNotUnLock        NUMBER (10);
        l_start_dt         DATE;
    BEGIN
        /*
             write_pd_logA(p_pdl_pd      => p_pd,
                          p_pdl_hs      => p_hs,
                          p_pdl_st      => 'PS',
                          p_pdl_message => 'API$PC_DECISION.decision_UnBlock(' || p_pd || ', ' || p_hs || ')',
                          p_pdl_st_old  => 'PS');
        */
        l_suspend_reason :=
            tools.ggp ('CHANGE_PAYMENT_CODE_UNBLOCK', SYSDATE);

        /*
            SELECT COUNT(1)
              INTO IsNotUnLock
            FROM pc_block b
            WHERE b.pcb_hs_unlock IS NULL
              AND pcb_lock_pnp_tp = 'CPX'
               OR pcb_lock_pnp_tp = 'CRX';
        */

        SELECT MIN (b.pcb_acc_stop_dt)
          INTO l_start_dt
          FROM pc_block b
         WHERE b.pcb_pd = p_pd AND b.pcb_hs_unlock IS NULL;

        UPDATE pc_block b
           SET b.pcb_unlock_pnp_tp =
                   (SELECT rup_id
                      FROM uss_ndi.v_ndi_reason_unlock_pay
                     WHERE rup_code = l_suspend_reason),
               b.pcb_hs_unlock = p_hs,
               b.pcb_acc_start_dt = TRUNC (SYSDATE)
         WHERE b.pcb_pd = p_pd AND b.pcb_hs_unlock IS NULL;

        UPDATE pc_decision pd
           SET pd.pd_pcb = NULL, pd.pd_suspend_reason = NULL
         WHERE pd.pd_id = p_pd;

        write_pd_log (p_pdl_pd        => p_pd,
                      p_pdl_hs        => p_hs,
                      p_pdl_st        => 'S',
                      p_pdl_message   => CHR (38) || '120',
                      p_pdl_st_old    => 'PS');

        recalc_pd_periods_pv (p_pd_id      => p_pd,
                              p_start_dt   => l_start_dt,
                              p_hs         => p_hs);
    END;

    --=============================================================
    PROCEDURE decision_UnBlock (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE)
    IS
        l_suspend_reason   VARCHAR2 (200);
        l_hs               histsession.hs_id%TYPE;
        IsNotUnLock        NUMBER (10);
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

        /*
             write_pd_logA(p_pdl_pd      => p_pd,
                          p_pdl_hs      => l_hs,
                          p_pdl_st      => l_pd.pd_st,
                          p_pdl_message => 'API$PC_DECISION.decision_UnBlock('||p_pd||', '||to_char(p_start_dt,'dd.mm.yyyy')||', '||to_char(p_stop_dt,'dd.mm.yyyy'||')'),
                          p_pdl_st_old  => l_pd.pd_st);
        */
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

        IF l_pd.pd_start_dt > p_start_dt
        THEN
            raise_application_error (
                -20000,
                'Дата початку періоду не може бути менша за номінальний початок строку дії рішення!');
        ELSIF l_pd.pd_stop_dt < p_start_dt
        THEN
            raise_application_error (
                -20000,
                'Дата початку періоду не може бути більша за номінальне закінченя строку дії рішення!');
        END IF;

        IF l_pd.pd_start_dt > p_stop_dt
        THEN
            raise_application_error (
                -20000,
                'Дата завершення періоду не може бути менша за номінальний початок строку дії рішення!');
        ELSIF l_pd.pd_stop_dt + 1 < p_stop_dt
        THEN
            raise_application_error (
                -20000,
                'Дата завершення періоду не може бути більша за наступний день від закінчення номінального періоду дії рішення!');
        END IF;

        SELECT COUNT (1)
          INTO IsNotUnLock
          FROM pc_block b
         WHERE        b.pcb_pd = p_pd
                  AND b.pcb_hs_unlock IS NULL
                  AND pcb_lock_pnp_tp = 'CPX'
               OR pcb_lock_pnp_tp = 'CRX';

        IF IsNotUnLock > 0
        THEN
            raise_application_error (
                -20000,
                'Рішення заблоковано без можливості поновлення!');
        END IF;

        UPDATE pc_block b
           SET b.pcb_unlock_pnp_tp =
                   (SELECT rup_id
                      FROM uss_ndi.v_ndi_reason_unlock_pay
                     WHERE rup_code = l_suspend_reason),
               b.pcb_hs_unlock = l_hs,
               b.pcb_acc_start_dt = p_start_dt
         WHERE b.pcb_pd = p_pd AND b.pcb_hs_unlock IS NULL;

        UPDATE pc_decision pd
           SET pd.pd_st = 'S', pd.pd_pcb = NULL, pd.pd_suspend_reason = NULL
         WHERE pd.pd_id = p_pd;

        Recalc_pd_payment_for_unblock (l_pd.pd_id,
                                       p_start_dt,
                                       p_stop_dt,
                                       l_hs);

        --перерахуєм періоди, новій період створюється по (p_start_dt - p_stop_dt)
        recalc_pd_periods_1 (l_pd.pd_id,
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
                   'Не дозволяється виконувати перерахунки після <'
                || TO_CHAR (l_max_dt, 'dd.mm.yyyy')
                || '> -  - останнього дня місяця розрахункового періоду!');
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
    --  Необхідно здійснювати прив'язку ОР до органу ОСЗН
    --=============================================================
    --#94685 20231116
    PROCEDURE Update_PA_Org (p_pd_id     NUMBER,
                             p_from_st   VARCHAR2,
                             p_to_st     VARCHAR2)
    IS
        l_com_org   pc_decision.com_org%TYPE;
        l_pd_pa     pc_decision.pd_pa%TYPE;
    BEGIN
        SELECT pd.com_org, pd.pd_pa
          INTO l_com_org, l_pd_pa
          FROM pc_decision pd
         WHERE pd_id = p_pd_id;

        IF p_to_st = 'S'
        THEN
            UPDATE pc_account
               SET PA_Org = l_com_org
             WHERE pa_id = l_pd_pa;
        ELSIF p_to_st = 'V'
        THEN
            UPDATE pc_account
               SET PA_Org = l_com_org
             WHERE     pa_id = l_pd_pa
                   AND NOT EXISTS
                           (SELECT pd.com_org
                              FROM pc_decision pd
                             WHERE     pd_pa = l_pd_pa
                                   AND pd_id != p_pd_id
                                   AND pd_st IN ('S', 'PS'));
        END IF;
    END;

    --=============================================================
    --  При переведенні рішення в стан "Нараховано" для типу виплати "Пошта" заповнбвати поле pd_pay_method.pdm_nd
    --=============================================================
    --#81545 20221101
    PROCEDURE Update_pdm_nd (p_pd_id NUMBER)
    IS
    BEGIN
        UPDATE uss_esr.pd_pay_method
           SET pdm_nd =
                   (SELECT MAX (nd_id)
                      FROM uss_ndi.v_ndi_post_office, uss_ndi.v_ndi_delivery
                     WHERE     nd_npo = npo_id
                           AND npo_index = pdm_index
                           AND nd_code = '000')
         WHERE     pdm_pay_tp = 'POST'
               AND pdm_pd = p_pd_id
               AND history_status = 'A'
               AND pdm_nd IS NULL;

        UPDATE uss_esr.pd_pay_method
           SET pdm_nd =
                   (SELECT MAX (nd_id)
                      FROM uss_ndi.v_ndi_post_office,
                           uss_ndi.v_ndi_delivery,
                           uss_esr.pc_decision  z
                     WHERE     nd_npo = npo_id
                           AND npo_org = z.com_org
                           AND nd_code = '000'
                           AND pdm_pd = pd_id)
         WHERE     pdm_pay_tp = 'POST'
               AND pdm_pd = p_pd_id
               AND history_status = 'A'
               AND pdm_nd IS NULL;
    END;

    --=============================================================
    --  При переведенні рішення в стан "Нараховано" - змінювати стан запису pd_income_session на F - фіксовано.
    --=============================================================
    -- #108496
    PROCEDURE Update_pin (p_pd_id NUMBER)
    IS
    BEGIN
        UPDATE pd_income_session
           SET pin_st = 'F'
         WHERE pin_pd = p_pd_id AND pin_st = 'E';
    END;

    --=============================================================
    --  Додати контроль щодо доставочної дільниці в параметрах виплати
    --=============================================================
    --#87878 20230530
    PROCEDURE Chec_pdm_nd (p_pd_id NUMBER)
    IS
        l_err   VARCHAR2 (2000);
    BEGIN
        SELECT MAX (
                      'Для типу виплати "Поштою" не заповнено обов''язкові поля, а саме, '
                   || CASE
                          WHEN PDM_INDEX IS NULL AND PDM_ND IS NULL
                          THEN
                              '"Індекс", "Доставочна дільниця"'
                          WHEN PDM_INDEX IS NULL AND PDM_ND IS NOT NULL
                          THEN
                              '"Індекс"'
                          WHEN PDM_INDEX IS NOT NULL AND PDM_ND IS NULL
                          THEN
                              '"Доставочна дільниця"'
                      END)    AS ERR
          INTO l_err
          FROM pd_pay_method
         WHERE     pdm_pd = p_pd_id
               AND HISTORY_STATUS = 'A'
               AND PDM_PAY_TP = 'POST'
               AND (PDM_INDEX IS NULL OR PDM_ND IS NULL);

        IF l_err IS NOT NULL
        THEN
            raise_application_error (-20000, l_err);
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
            API$PD_INIT.init_pc_decision_by_appeals (4, NULL, l_messages);
        END IF;

        -- Перевіремо право та розрахуємо

        -- Дістаємо нові звернення
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT pd_id
              FROM pc_decision pd
             WHERE     NOT EXISTS
                           (SELECT 1
                              FROM pd_right_log
                             WHERE prl_pd = pd_id)
                   --AND com_wu = l_com_wu
                   AND pd_nst = 664
                   AND pd_st = 'R0'
                   AND pd.pd_ap = pd.pd_ap_reason;

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
        DELETE FROM tmp_in_calc_pd
              WHERE 1 = 1;

        INSERT INTO tmp_in_calc_pd (ic_pd, ic_tp)
            (SELECT x_ID, 'R0' FROM tmp_work_ids);

        api$calc_pd.calc_pd (2, NULL, l_messages);

        INSERT INTO tmp_in_calc_pd (ic_pd, ic_tp, ic_start_dt)
            (SELECT pd_ID, 'R0', NULL
               FROM pc_decision
              WHERE pd_ap = 43587);


        -- видалимо те, що не пораховано
        DELETE FROM tmp_work_ids
              WHERE NOT EXISTS
                        (SELECT 1
                           FROM pd_payment
                          WHERE pdp_pd = x_id AND history_status = 'A');

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
        v_pd_st       pc_decision.pd_st%TYPE;
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
                                    pdp_sum,
                                    history_status)
                SELECT --+ index(t) index(ap) use_nl(t ap) index(pd) use_nl(ap pd)
                       NULL,
                       pd.pd_id,
                       NULL,
                       ap.ap_reg_dt,
                       NULL,
                       0,
                       'A'
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
                                       pdm_account,
                                       pdm_is_actual)
                SELECT --+ index(t) index(ap) use_nl(t ap) index(pd) use_nl(ap pd)
                       NULL,
                       pd.pd_id,
                       pd.pd_start_dt,
                       pd.pd_stop_dt,
                       'A',
                       'BANK',
                       apm.apm_account,
                       'T'
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
                             pd.pd_start_dt,
                             pd.pd_stop_dt,
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
                                       pdf_birth_dt,
                                       history_status,
                                       pdf_start_dt,
                                       pdf_stop_dt,
                                       pdf_tp)
                    SELECT NULL,
                           rec_f.app_sc,
                           rec_f.pd_id,
                           rec_f.birth_dt,
                           'A',
                           rec_f.pd_start_dt,
                           rec_f.pd_stop_dt,
                           'NOT'
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
                               ON     epdp.pdp_pd = epd.pd_id
                                  AND epdp.history_status = 'A'
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
                            WHERE t.pd_id = fr.pd_id
                        RETURNING t.pd_st
                             INTO v_pd_st;

                        l_txt := '74#' || fr.npt_legal_act; -- 'Інша Заявка члена вашої сім’ї знаходиться в очікуванні на виплату від міжнародної організації.';
                        api$pc_decision.write_pd_log (fr.pd_id,
                                                      NULL,
                                                      'V',
                                                      CHR (38) || l_txt, /*'R0'*/
                                                      v_pd_st);
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
                            WHERE t.pd_id = fr.pd_id
                        RETURNING t.pd_st
                             INTO v_pd_st;

                        l_txt := '74#'; -- 'Інша Заявка члена вашої сім’ї знаходиться в очікуванні на виплату від міжнародної організації.';
                        api$pc_decision.write_pd_log (fr.pd_id,
                                                      NULL,
                                                      'WD',
                                                      CHR (38) || l_txt, /*'R0'*/
                                                      v_pd_st);
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
                            WHERE t.pd_id = fr.pd_id
                        RETURNING t.pd_st
                             INTO v_pd_st;

                        l_txt := '73#' || fr.npt_legal_act; -- 'Виплата членам вашій сім’ї вже відбулась від '
                        api$pc_decision.write_pd_log (fr.pd_id,
                                                      NULL,
                                                      'V',
                                                      CHR (38) || l_txt, /*'R0'*/
                                                      v_pd_st);
                        api$esr_action.preparewrite_visit_ap_log (
                            fr.pd_id,
                            CHR (38) || l_txt);
                    END IF;
                ----------------------------------------------------------------------------------------------------------------------------
                ELSIF fr.rn = 1 AND fr.is_error_pd = 0
                THEN               -- переводим решение в Данні заяви прийнято
                       UPDATE pc_decision t
                          SET t.pd_st = 'AP'
                        WHERE t.pd_id = fr.pd_id
                    RETURNING t.pd_st
                         INTO v_pd_st;

                    l_txt := NULL;
                    l_txt := '72'; --'Ваші дані підтверджено. Заявка буде передана міжнародній організації за умови відповідності вашої соціальної категорії (статусу) до умов виплат, які визначають міжнародні організації.';
                    api$pc_decision.write_pd_log (fr.pd_id,
                                                  NULL,
                                                  'AP',
                                                  CHR (38) || l_txt,  /*'R0'*/
                                                  v_pd_st);
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
    --  Функція автоматичного перевода звернення в 'WD' по послузі 1141.
    --=============================================================
    PROCEDURE proces_pc_decision_by_1141
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
                             WHERE aps_ap = ap_id AND aps_nst = 1141)
                   AND ap_st IN ('O')
                   AND ap_tp IN ('REG')
                   --        AND ap_id = 48760
                   AND ROWNUM <= 500;

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt > 0
        THEN
            FOR rec IN (SELECT x_id FROM tmp_work_ids)
            LOOP
                API$ESR_Action.preparewrite_visit_ap_aps_log (rec.x_id, '');
            END LOOP;


            UPDATE Appeal
               SET Ap_St = 'WD'
             WHERE EXISTS
                       (SELECT 1
                          FROM Tmp_Work_Ids
                         WHERE x_Id = Ap_Id);
        END IF;
    END;

    --=============================================================
    --  Функція автоматичного перевода звернення в 'WD' по послузі 1201. Також відправляємо документи в СРКО
    --=============================================================
    PROCEDURE proces_pc_decision_by_1201
    IS
        l_cnt   PLS_INTEGER;
    BEGIN
        -- Створемо рішення по 664
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ap_id
              FROM appeal
             WHERE     EXISTS
                           (SELECT 1
                              FROM ap_service
                             WHERE aps_ap = ap_id AND aps_nst = 1201)
                   AND ap_st IN ('O')
                   AND ap_tp IN ('V')
                   AND ROWNUM <= 500;

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt > 0
        THEN
            FOR rec IN (SELECT x_id FROM tmp_work_ids)
            LOOP
                api$appeal.Copy_Document2Socialcard (rec.x_id, 1);
            END LOOP;


            UPDATE Appeal
               SET Ap_St = 'WD'
             WHERE EXISTS
                       (SELECT 1
                          FROM Tmp_Work_Ids
                         WHERE x_Id = Ap_Id);
        END IF;
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
         WHERE     EXISTS
                       (SELECT 1
                          FROM ap_service
                         WHERE     aps_ap = ap_id
                               AND aps_nst = 1201
                               AND history_status = 'A')
               AND ap_st IN ('O')
               AND ap_tp IN ('V');

        IF l_cnt > 0
        THEN
            proces_pc_decision_by_1201;
        END IF;

        SELECT COUNT (ap_id)
          INTO l_cnt
          FROM appeal
         WHERE ap_st IN ('O') AND ap_tp IN ('IA');

        IF l_cnt > 0
        THEN
            proces_pc_decision_by_IA;
        END IF;

        SELECT COUNT (ap_id)
          INTO l_cnt
          FROM appeal
         WHERE     EXISTS
                       (SELECT 1
                          FROM ap_service
                         WHERE     aps_ap = ap_id
                               AND aps_nst = 1141
                               AND history_status = 'A')
               AND ap_st IN ('O')
               AND ap_tp IN ('REG');

        IF l_cnt > 0
        THEN
            proces_pc_decision_by_1141;
        END IF;

        --Обробка зверененнь щодо виробництва/видачі ДЗР (генерація актів тощо)
        API$ACT_NDZR.process_act_ndzr_by_appeals;
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
        ELSIF p_mode = 3
        THEN
            l_month := 0 + TO_CHAR (p_dt, 'MM');

            l_rez :=
                CASE l_month
                    WHEN 1 THEN 0
                    WHEN 2 THEN 1
                    WHEN 3 THEN 2
                    WHEN 4 THEN 0
                    WHEN 5 THEN 1
                    WHEN 6 THEN 2
                    WHEN 7 THEN 0
                    WHEN 8 THEN 1
                    WHEN 9 THEN 2
                    WHEN 10 THEN 0
                    WHEN 11 THEN 1
                    WHEN 12 THEN 2
                END;
        END IF;

        RETURN l_rez;
    END;

    --Розрахунок сукупного доходу
    PROCEDURE calc_income_for_pd (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці tmp_work_ids
                                  p_pd_id          pc_decision.pd_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$calc_income.calc_income_for_pd (p_mode,
                                            p_pd_id,
                                            0,
                                            p_messages);
    END;

    --Розрахунок сукупного доходу альтернативний
    PROCEDURE calc_income_for_pd_alt (p_pd_id          pc_decision.pd_id%TYPE,
                                      p_messages   OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$calc_income.calc_income_for_pd (1,
                                            p_pd_id,
                                            1,
                                            p_messages);
    END;

    --===========================================================--
    /*
      FUNCTION Get_apri_income(p_pd          NUMBER,
                               p_sc          NUMBER,
                               p_list_inc_tp VARCHAR2,
                               p_calc_dt     DATE,
                               p_start_dt    DATE
                               ) RETURN NUMBER IS
        ret NUMBER;
      BEGIN
    --5 аліментів,
    --1 пенсії,
    --6 допомоги,
    --4, 28 стипендії – відсутній
          WITH itp_list AS (SELECT REGEXP_SUBSTR (p_list_inc_tp, '[^,]+', 1, level) AS inc_tp
                            FROM dual
                            CONNECT BY level <= length(regexp_replace(p_list_inc_tp,'[^,]*')) + 1
                           ),
               income AS   (select inc_tp,
                                   API$Calc_Income.ToDate (  substr(trim(COLUMN_VALUE),1,instr(trim(COLUMN_VALUE),'=')-1)) aim_month,
                                   API$Calc_Income.ToNumber( substr(trim(COLUMN_VALUE),instr(trim(COLUMN_VALUE),'=')+1)) aim_sum
                            from itp_list,
                                 xmltable(('"'  || REPLACE(  regexp_replace(
                                                                            API$ACCOUNT.get_docx_507_string(p_pd, p_sc, inc_tp, p_calc_dt),
                                                                            chr(13)||'|'||chr(10),'' )  , ',', '","')    || '"'))
                           ),
               inc_mn AS   (select inc_tp, aim_month, aim_sum
                            from income
                            WHERE trunc(aim_month,'MM')  = trunc(add_months(p_start_dt, -1),'MM')
                           ),
               last_inc AS (SELECT DISTINCT inc_tp,
                                   last_value (aim_sum) OVER (PARTITION BY inc_tp
                                                              ORDER BY aim_month ASC
                                                              RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_aim_sum
                            FROM income
                           )
               SELECT SUM(aim_sum)
                  INTO ret
               FROM inc_mn;
        RETURN nvl(ret, 0);
      END;
    */
    --===========================================================--
    FUNCTION get_start_date_265 (p_pd_pa          NUMBER,
                                 p_ap_reg_dt      DATE,
                                 p_ap_is_second   VARCHAR2)
        RETURN DATE
    IS
        ret_dt   DATE;
    BEGIN
        SELECT NVL (MAX (pdap.pdap_stop_dt + 1), p_ap_reg_dt) --nvl(MAX(pd.pd_stop_dt+1), p_ap_reg_dt)
          INTO ret_dt
          FROM pc_decision  pd
               JOIN pd_accrual_period pdap
                   ON pdap.pdap_pd = pd.pd_id AND pdap.history_status = 'A'
         WHERE pd.pd_pa = p_pd_pa AND pd.pd_st IN ('S', 'PS');

        IF    ret_dt < ADD_MONTHS (p_ap_reg_dt, -1)
           OR NVL (p_ap_is_second, 'F') = 'F'
        THEN
            ret_dt := p_ap_reg_dt;
        ELSIF ret_dt > p_ap_reg_dt AND NVL (p_ap_is_second, 'F') = 'T'
        THEN
            ret_dt := p_ap_reg_dt;
        ELSE
            ret_dt := ret_dt;
        END IF;

        RETURN ret_dt;
    END;

    --=========================================--

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

    PROCEDURE Check_accrual_period (
        p_pd_src     pc_decision%ROWTYPE,
        p_start_dt   pc_decision.pd_start_dt%TYPE,
        p_stop_dt    pc_decision.pd_stop_dt%TYPE,
        p_hs         histsession.hs_id%TYPE,
        p_src        VARCHAR2)
    IS
        cnt_err   NUMBER;
    BEGIN
        init_related_decisions (p_pd_src.pd_id,
                                p_pd_src.pd_pa,
                                p_pd_src.pd_nst);

        WITH
            all_dt
            AS
                (SELECT pdf_sc AS u_sc, TRUNC (pdap_start_dt) AS u_dt
                   FROM uss_esr.pd_accrual_period  pdap
                        JOIN uss_esr.pd_family ON pdf_pd = pdap_pd
                  WHERE     pdap_pd = p_pd_src.pd_id
                        AND pdap.history_status = 'A'
                 UNION
                 SELECT pdf_sc
                            AS u_sc,
                        TRUNC (
                            NVL (pdap_stop_dt,
                                 TO_DATE ('31.12.3000', 'DD.MM.YYYY')))
                   FROM uss_esr.pd_accrual_period  pdap
                        JOIN uss_esr.pd_family ON pdf_pd = pdap_pd
                  WHERE     pdap_pd = p_pd_src.pd_id
                        AND pdap.history_status = 'A')
        SELECT COUNT (1)
          INTO cnt_err
          FROM all_dt
         WHERE 1 <
               (SELECT COUNT (DISTINCT pd_id)
                  FROM tmp_work_ids1
                       JOIN uss_esr.pc_decision ON pd_id = x_id
                       JOIN uss_esr.pd_accrual_period pdap
                           ON pdap_pd = x_id AND pdap.history_status = 'A'
                       JOIN uss_esr.pd_payment pdp
                           ON pdp_pd = x_id AND pdp.history_status = 'A'
                       JOIN uss_esr.pd_detail
                           ON pdd_pdp = pdp_id AND NVL (pdd_value, 0) > 0
                       JOIN uss_esr.pd_family
                           ON pdf_id = pdd_key AND pdf_sc = u_sc
                 WHERE     u_dt BETWEEN TRUNC (pdap_start_dt)
                                    AND TRUNC (
                                            NVL (
                                                pdap_stop_dt,
                                                TO_DATE ('31.12.3000',
                                                         'DD.MM.YYYY')))
                       AND u_dt BETWEEN pdp_start_dt AND pdp_stop_dt
                       AND pdd_ndp =
                           CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END);

        /*
           FROM all_dt
           where 1 < (SELECT count(*)
                      --from uss_esr.pc_decision
                      --     JOIN uss_esr.pd_accrual_period pdap ON pdap_pd = pd_id AND pdap.history_status = 'A'
                      from tmp_work_ids1
                           JOIN uss_esr.pd_accrual_period pdap ON pdap_pd = x_id AND pdap.history_status = 'A'
                      where u_dt between TRUNC(pdap_start_dt) and TRUNC(NVL(pdap_stop_dt, to_date('31.12.3000', 'DD.MM.YYYY') ))
                     );
        */
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

    --Пошук рішкень для перевірки та побудови pd_accrual_period
    PROCEDURE init_related_decisions (p_pd_id    NUMBER,
                                      p_pd_pa    NUMBER,
                                      p_pd_nst   NUMBER)
    IS
        l_not_Z_248   NUMBER;
    BEGIN
        IF p_pd_nst = 248
        THEN
            SELECT COUNT (1)
              INTO l_not_Z_248
              FROM ap_person
                   JOIN pc_decision
                       ON app_ap = pd_ap OR app_ap = pd_ap_reason
             WHERE pd_id = p_pd_id AND app_tp NOT IN ('Z', 'O');
        END IF;

        DELETE FROM tmp_work_ids1
              WHERE 1 = 1;

        IF p_pd_nst IN (265, 268, 269)
        THEN
            INSERT INTO tmp_work_ids1 (x_id)
                SELECT DISTINCT pd_id
                  FROM pc_decision JOIN pd_family ON pdf_pd = pd_id
                 WHERE     pd_pa = p_pd_pa
                       AND pd_st IN ('S', 'PS')
                       AND pdf_sc IN (SELECT pdf_sc
                                        FROM pd_family pdf1
                                       WHERE pdf1.pdf_pd = p_pd_id);
        ELSIF p_pd_nst IN (248) AND l_not_Z_248 = 0
        THEN
            INSERT INTO tmp_work_ids1 (x_id)
                SELECT pd_id
                  FROM pc_decision
                 WHERE     pd_pa = p_pd_pa
                       AND pd_st IN ('S', 'PS')
                       AND (SELECT COUNT (1)
                              FROM ap_person
                             WHERE     (   app_ap = pd_ap
                                        OR app_ap = pd_ap_reason)
                                   AND app_tp NOT IN ('Z', 'O')) =
                           0;
        ELSIF p_pd_nst IN (248) AND l_not_Z_248 > 0
        THEN
            INSERT INTO tmp_work_ids1 (x_id)
                WITH
                    all_pd
                    AS
                        (SELECT pd_id, pdf_sc
                           FROM pc_decision
                                JOIN ap_person ON app_ap = pd_ap
                                JOIN pd_family
                                    ON pdf_pd = pd_id AND pdf_sc = app_sc
                          WHERE pd_pa = p_pd_pa AND app_tp IN ('FM', 'FP'))
                SELECT pd_id
                  FROM all_pd
                 WHERE pdf_sc IN (SELECT c.pdf_sc
                                    FROM all_pd c
                                   WHERE c.pd_id = p_pd_id);
        ELSE
            INSERT INTO tmp_work_ids1 (x_id)
                SELECT pd_id
                  FROM pc_decision
                 WHERE pd_pa = p_pd_pa AND pd_st IN ('S', 'PS');
        END IF;
    END;

    --Процедура перерахунку реальних періодів дії рішень для кореткного врахування в нарухуваннях, при появі нових рішень по ключу (pc,nst)
    PROCEDURE recalc_pd_periods_FS (p_pd_id   pc_decision.pd_id%TYPE,
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
           AND l_src_pd.pd_suspend_reason NOT IN ('VPOE', 'VPOREF')
        THEN
            SELECT                                --trunc(ap.ap_reg_dt,'MM')-1
                   LAST_DAY (ap.ap_reg_dt)
              INTO l_src_pd.pd_stop_dt
              FROM pc_block pcb JOIN appeal ap ON ap.ap_id = pcb.pcb_ap_src
             WHERE pcb.pcb_id = l_src_pd.pd_pcb;
        END IF;

        init_related_decisions (l_src_pd.pd_id,
                                l_src_pd.pd_pa,
                                l_src_pd.pd_nst);
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
              FROM tmp_work_ids1, pd_accrual_period acr
             WHERE     pdap_pd = x_id
                   AND acr.history_status = 'A'
                   AND pdap_start_dt <= l_src_pd.pd_stop_dt
                   AND pdap_stop_dt >= l_src_pd.pd_start_dt;

        /*
          INSERT INTO tmp_unh_old_list (ol_obj, ol_hst, ol_begin, ol_end)
            SELECT 0, pdap_id, pdap_start_dt, pdap_stop_dt
            FROM pc_decision, pd_accrual_period acr
            WHERE pd_pa = l_src_pd.pd_pa
              AND pd_st IN ( 'S', 'PS')
              AND pdap_pd = pd_id
              AND acr.history_status = 'A'
        --      AND (
        --            (pdap_start_dt <= l_src_pd.pd_stop_dt AND pdap_stop_dt >= l_src_pd.pd_start_dt)
        --            OR
        --            (pdap_start_dt > l_src_pd.pd_stop_dt)
        --          );
              AND pdap_start_dt <= l_src_pd.pd_stop_dt
              AND pdap_stop_dt >= l_src_pd.pd_start_dt;
        */

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
    --Процедура перерахунку реальних періодів дії рішень для кореткного врахування в нарухуваннях, при появі нових рішень по ключу (pc,nst)
    PROCEDURE recalc_pd_periods_PV (p_pd_id      pc_decision.pd_id%TYPE,
                                    p_start_dt   DATE,
                                    p_hs         histsession.hs_id%TYPE)
    IS
        l_src_pd   pc_decision%ROWTYPE;
        l_src_dn   deduction.dn_id%TYPE;
    BEGIN
        SELECT *
          INTO l_src_pd
          FROM pc_decision
         WHERE pd_id = p_pd_id;

        l_src_pd.pd_start_dt := NVL (p_start_dt, l_src_pd.pd_start_dt);
        l_src_pd.pd_stop_dt :=
            NVL (l_src_pd.pd_stop_dt, TO_DATE ('31.12.2100', 'DD.MM.YYYY'));


        IF     l_src_pd.pd_pcb IS NOT NULL
           AND l_src_pd.pd_suspend_reason NOT IN ('VPOE', 'VPOREF')
        THEN
            SELECT                                --trunc(ap.ap_reg_dt,'MM')-1
                   LAST_DAY (ap.ap_reg_dt)
              INTO l_src_pd.pd_stop_dt
              FROM pc_block pcb JOIN appeal ap ON ap.ap_id = pcb.pcb_ap_src
             WHERE pcb.pcb_id = l_src_pd.pd_pcb;
        END IF;

        init_related_decisions (l_src_pd.pd_id,
                                l_src_pd.pd_pa,
                                l_src_pd.pd_nst);

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
              FROM tmp_work_ids1, pd_accrual_period acr
             WHERE     pdap_pd = x_id
                   AND acr.history_status = 'A'
                   AND pdap_start_dt <= l_src_pd.pd_stop_dt
                   AND pdap_stop_dt >= l_src_pd.pd_start_dt;

        /*
          INSERT INTO tmp_unh_old_list (ol_obj, ol_hst, ol_begin, ol_end)
            SELECT 0, pdap_id, pdap_start_dt, pdap_stop_dt
            FROM pc_decision, pd_accrual_period acr
            WHERE pd_pa = l_src_pd.pd_pa
              AND pd_st IN ( 'S', 'PS')
              AND pdap_pd = pd_id
              AND acr.history_status = 'A'
        --      AND (
        --            (pdap_start_dt <= l_src_pd.pd_stop_dt AND pdap_stop_dt >= l_src_pd.pd_start_dt)
        --            OR
        --            (pdap_start_dt > l_src_pd.pd_stop_dt)
        --          );
              AND pdap_start_dt <= l_src_pd.pd_stop_dt
              AND pdap_stop_dt >= l_src_pd.pd_start_dt;
          */

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
           SET h.history_status = 'H', pdap_hs_del = p_hs
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = pdap_id);

        UPDATE pd_accrual_period h
           SET h.history_status = 'H', pdap_hs_del = p_hs
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
                                       history_status,
                                       pdap_hs_ins)
            SELECT 0,
                   pdap_pd,
                   rz.rz_begin,
                   rz.rz_end,
                   l_src_pd.pd_id,
                   'A',
                   p_hs
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
                   'A',
                   p_hs
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
    PROCEDURE recalc_pd_periods_1 (
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
           SET h.history_status = 'H', pdap_hs_del = p_hs
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = pdap_id);

        UPDATE pd_accrual_period h
           SET h.history_status = 'H', pdap_hs_del = p_hs
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
                                       history_status,
                                       pdap_hs_ins)
            SELECT 0,
                   pdap_pd,
                   rz.rz_begin,
                   rz.rz_end,
                   l_src_pd.pd_id,
                   'A',
                   p_hs
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
                   'A',
                   p_hs
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
        p_new_id              OUT pd_features.pde_id%TYPE,
        p_pd_nst           IN     NUMBER DEFAULT NULL)
    IS
        l_tp   VARCHAR2 (10);
    BEGIN
        SELECT MAX (t.nft_view)
          INTO l_tp
          FROM uss_ndi.v_ndi_pd_feature_type t
         WHERE t.nft_id = p_pde_nft;

        --IF p_pde_nft IS NOT NULL AND p_pde_nft!= 9 THEN
        IF l_tp IS NULL OR l_tp != 'SS' AND p_pd_nst NOT IN (249, 267)
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

    --============================================================--
    -- #100803 Необхідно надати можливість поновлювати призначені суми тим, кому допомога була обнулена по перерахунку з типом S_VPO_51
    PROCEDURE restore_payment_detail (p_pdd_id   IN NUMBER,
                                      p_reason   IN VARCHAR2,
                                      p_op       IN VARCHAR2)
    IS
        l_pdp_id_old   NUMBER;
        l_pd_id        NUMBER;
        l_pdp_hist     VARCHAR2 (20);
        l_pdd_ndp      NUMBER;
        l_pdd_key      NUMBER;
        l_rc_tp        VARCHAR2 (20);
        l_pdp_id_new   NUMBER;
        l_hs           NUMBER (10);
        l_log_txt      VARCHAR2 (4000);
    BEGIN
        IF p_op != '1'
        THEN
            RETURN;
        END IF;

        SELECT p.pdp_id,
               p.history_status    AS pdp_history_status,
               d.pdd_key,
               d.pdd_ndp,
               rc.rc_tp,
               p.pdp_pd,
                  CHR (38)
               || '285'
               || '#'
               || (SELECT uss_person.api$sc_tools.get_pib (f.pdf_sc)
                     FROM pd_family f
                    WHERE pdf_id = d.pdd_key)
               || '#'
               || TO_CHAR (d.pdd_value)
               || '#'
               || TO_CHAR (d.pdd_start_dt, 'dd.mm.yyy')
               || '#'
               || TO_CHAR (d.pdd_stop_dt, 'dd.mm.yyy')
               || '#'
               || p_reason         AS x_log_txt
          INTO l_pdp_id_old,
               l_pdp_hist,
               l_pdd_key,
               l_pdd_ndp,
               l_rc_tp,
               l_pd_id,
               l_log_txt
          FROM recalculates  rc
               JOIN pd_payment p ON p.pdp_rc = rc.rc_id
               JOIN pd_detail d ON d.pdd_pdp = p.pdp_id
         WHERE d.pdd_id = p_pdd_id;

        IF l_pdp_hist != 'A'
        THEN
            raise_application_error (-20000, 'Архівний платіж!');
        ELSIF l_pdd_ndp != 137
        THEN
            raise_application_error (-20000, 'Не відповідний платіж!');
        ELSIF l_rc_tp NOT IN ('S_VPO_51', 'S_VPO_133')
        THEN
            raise_application_error (-20000, 'Не відповідний перерахунок!');
        END IF;

        l_hs := tools.GetHistSession ();
        l_pdp_id_new := id_pd_payment (0);

        UPDATE pd_payment p
           SET p.history_status = 'H', p.pdp_hs_del = l_hs
         WHERE p.pdp_id = l_pdp_id_old;

        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                pdp_hs_ins,
                                history_status,
                                pdp_src,
                                pdp_rc)
            SELECT l_pdp_id_new,
                   pdp_pd,
                   pdp_npt,
                   pdp_start_dt,
                   pdp_stop_dt,
                   (SELECT SUM (d.pdd_value)
                      FROM pd_detail d
                     WHERE     d.pdd_pdp = p.pdp_id
                           AND (pdd_ndp IN (290, 300) OR pdd_id = p_pdd_id))
                       AS x_sum,
                   l_hs,
                   'A',
                   pdp_src,
                   pdp_rc
              FROM pd_payment p
             WHERE p.pdp_id = l_pdp_id_old;

          INSERT ALL
            WHEN pdd_key <> l_pdd_key
            THEN
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_value,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt)
                  VALUES (x_pdd_id,
                          x_pdp_id,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_value,
                          pdd_key,
                          pdd_ndp,
                          pdd_start_dt,
                          pdd_stop_dt,
                          pdd_npt)
            WHEN pdd_key = l_pdd_key AND pdd_ndp = 137
            THEN
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_value,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt)
                  VALUES (x_pdd_id,
                          x_pdp_id,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_value,
                          pdd_key,
                          300,
                          pdd_start_dt,
                          pdd_stop_dt,
                          pdd_npt)
            ---
            SELECT 0                AS x_pdd_id,
                   l_pdp_id_new     AS x_pdp_id,
                   d.pdd_row_order,
                   d.pdd_row_name,
                   d.pdd_value,
                   d.pdd_key,
                   d.pdd_ndp,
                   d.pdd_start_dt,
                   d.pdd_stop_dt,
                   d.pdd_npt
              FROM pd_detail d
             WHERE d.pdd_pdp = l_pdp_id_old;

        API$PC_DECISION.write_pd_log (l_pd_id,
                                      l_hs,
                                      'S',
                                      l_log_txt,
                                      'S');
    --Поновлено виплату # на суму # в період з # по #. Користувач зазначив підставу для поновлення - #
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (-20000,
                                     'Не знайдено запис для подовженя!');
        WHEN OTHERS
        THEN
            RAISE;
    END;

    -- IC #103369
    -- Зробити процедуру для аналізу наявності діючих рішень по допомогам по особі при міграції
    FUNCTION getLastDatePayment (p_sc_id NUMBER)
        RETURN DATE
    IS
        l_last_stop_date   DATE;
    BEGIN
        SELECT MAX (pp.pdp_stop_dt)
          INTO l_last_stop_date
          FROM uss_esr.pd_family  f
               INNER JOIN uss_esr.pc_decision d ON d.pd_id = f.pdf_pd
               INNER JOIN uss_esr.pd_payment pp ON pp.pdp_pd = d.pd_id
         WHERE pp.history_status = 'A' AND f.pdf_sc = p_sc_id;

        RETURN l_last_stop_date;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END getLastDatePayment;
--============================================================--
END API$PC_DECISION;
/