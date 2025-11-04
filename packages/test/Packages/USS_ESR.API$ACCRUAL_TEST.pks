/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACCRUAL_TEST
IS
    -- Author  : VANO
    -- Created : 07.09.2021 15:09:52
    -- Purpose : Функції роботи з нарахуваннями

    g_write_messages_to_output   INTEGER := 0;

    PROCEDURE write_ac_log (p_acl_ac        ac_log.acl_ac%TYPE,
                            p_acl_hs        ac_log.acl_hs%TYPE,
                            p_acl_st        ac_log.acl_st%TYPE,
                            p_acl_message   ac_log.acl_message%TYPE,
                            p_acl_st_old    ac_log.acl_st_old%TYPE,
                            p_acl_tp        ac_log.acl_tp%TYPE:= 'SYS');

    --Встановлення режиму розрахунку: 0 - по ЕОС, 1 - по ЕОС та додатково по вхідній множині особових рахунків (tmp_work_pa_ids)
    PROCEDURE set_calc_mode (p_mode INTEGER);

    --Функція отримання дати початку періоду при перетинанні періодів
    FUNCTION dstart (p_date DATE, p_start_dt DATE, p_stop_dt DATE)
        RETURN DATE;

    --Функція отримання дати закінчення періоду при перетинанні періодів
    FUNCTION dstop (p_date DATE, p_start_dt DATE, p_stop_dt DATE)
        RETURN DATE;

    --Функція отримання прожиткового мінімуму на дату
    FUNCTION get_lgw_cmn (p_date DATE)
        RETURN DECIMAL;

    --Функція отримання прожиткового мінімуму на дату відповідно до дати народження (режим p_mode = 2)
    FUNCTION get_lgw_cmn (p_mode INTEGER, p_date DATE, p_birth_dt DATE)
        RETURN DECIMAL;

    --Знак для іду операції
    FUNCTION xsign (p_op_id NUMBER)
        RETURN NUMBER;

    --Розрахунок нарахувань
    PROCEDURE calc_accrual (p_in_mode         INTEGER,
                            p_calc_mode       INTEGER,
                            p_pc_id           personalcase.pc_id%TYPE,
                            p_month           DATE := SYSDATE,
                            p_messages    OUT SYS_REFCURSOR);

    PROCEDURE approve_accrual (p_ac_id accrual.ac_id%TYPE);

    PROCEDURE approve_accrual_by_params (p_org            accrual.com_org%TYPE,
                                         p_nst            pc_decision.pd_nst%TYPE,
                                         p_month          accrual.ac_month%TYPE,
                                         p_messages   OUT SYS_REFCURSOR);

    PROCEDURE return_accrual (p_ac_id       accrual.ac_id%TYPE,
                              p_reason   IN VARCHAR2);

    --Отримання параметрів, за якими користувач може виконати масовий розрахунок нарахувань
    PROCEDURE get_actual_params (p_tp                INTEGER := 1,
                                 p_months_list   OUT SYS_REFCURSOR,
                                 p_org_list      OUT SYS_REFCURSOR);

    --Отримання списку місяців, доступних для розрахунку користувачу
    PROCEDURE get_month_list (p_tp                INTEGER := 1,
                              p_months_list   OUT SYS_REFCURSOR);

    --Отримання останього місяця, доступного для розрахунку користувачу
    --  PROCEDURE get_month_max( p_months OUT DATE);

    --Отримання списку районів, доступних для розрахунку користувачу
    PROCEDURE get_org_list (p_tp INTEGER:= 1, p_org_list OUT SYS_REFCURSOR);

    --Функція для запуску масового розрахуку з шедулеру
    PROCEDURE calc_accrual_job (p_session   VARCHAR2,
                                p_rc_id     recalculates.rc_id%TYPE);

    --Функція виконання масового розрахунку - реєструє власне перерахунок в таблицю  recalculates і створює відкладену задачу IKIS
    PROCEDURE mass_calc_accrual (
        p_rc_id            OUT recalculates.rc_id%TYPE,
        p_rc_jb            OUT recalculates.rc_jb%TYPE,
        p_rc_month      IN     recalculates.rc_month%TYPE,
        p_rc_org_list   IN     recalculates.rc_org_list%TYPE);

    --Попередній розрахунок нарахувань з врахуванням незавершеного рівшення про призначення
    PROCEDURE prev_calc_accrual (p_pd_id personalcase.pc_id%TYPE);

    --Підтвердження масового розрахунку нарахувань
    PROCEDURE approve_recalculates (p_rc_id recalculates.rc_id%TYPE);

    --Повернення масового розрахунку нарахувань
    PROCEDURE return_recalculates (p_rc_id recalculates.rc_id%TYPE);

    --Функція зупинки виплати
    PROCEDURE stop_pay (p_mode INTEGER);

    --Оновлення реєстраційних записів нарахувань в частині "виплачено"
    PROCEDURE actuilize_payed_sum (p_mode INTEGER);

    --Ініціалізація переліку послуг в залежності від типу органу користувача
    PROCEDURE init_nst_list (p_calc_mode INTEGER:= 1); --1 - індивідуальний розрахунок з інтерфейсу, 2 - масовий розрахунок з шедулера, 3 - попреденій розрахунок з врахуванням незавершеного рішення

    PROCEDURE return_accrual_int (p_mode        INTEGER,
                                  p_ac_id       accrual.ac_id%TYPE,
                                  p_reason   IN VARCHAR2,
                                  p_hs          histsession.hs_id%TYPE);

    PROCEDURE approve_accrual_int (p_mode    INTEGER, --1=для індивідуального підтверждення з картки справи, 2=для масового підтвердження одразу в "діюче"
                                   p_ac_id   accrual.ac_id%TYPE,
                                   p_hs      histsession.hs_id%TYPE);

    PROCEDURE get_acd_sums_to_manipulate (
        p_pd_id          pc_decision.pd_id%TYPE,
        p_acd_data   OUT SYS_REFCURSOR);

    PROCEDURE manipulate_with_acd (p_pc_id          personalcase.pc_id%TYPE,
                                   p_pd_id          pc_decision.pd_id%TYPE,
                                   p_month          ac_detail.acd_start_dt%TYPE,
                                   p_sum            ac_detail.acd_sum%TYPE,
                                   p_acd_ids_list   VARCHAR2,
                                   p_decision       VARCHAR2);

    FUNCTION get_exclude_sum_by_pd (p_pd_id     pd_payment.pdp_id%TYPE,
                                    p_npt_id    pd_payment.pdp_npt%TYPE,
                                    p_nnnc_id   pd_payment.pdp_id%TYPE,
                                    p_dt        pd_payment.pdp_start_dt%TYPE)
        RETURN NUMBER;
END API$ACCRUAL_TEST;
/


/* Formatted on 8/12/2025 5:48:36 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACCRUAL_TEST
IS
    TYPE cache_op_info_type IS TABLE OF VARCHAR2 (10)
        INDEX BY VARCHAR2 (40);

    g_op_info          cache_op_info_type;

    g_messages         TOOLS.t_messages;

    g_ac_month         DATE;
    g_max_calc_month   DATE;

    g_user_type        VARCHAR2 (250);
    g_bp_class         billing_period.bp_class%TYPE;

    g_pa_mode_calc     INTEGER := 0;

    PROCEDURE write_ac_log (p_acl_ac        ac_log.acl_ac%TYPE,
                            p_acl_hs        ac_log.acl_hs%TYPE,
                            p_acl_st        ac_log.acl_st%TYPE,
                            p_acl_message   ac_log.acl_message%TYPE,
                            p_acl_st_old    ac_log.acl_st_old%TYPE,
                            p_acl_tp        ac_log.acl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := NVL (p_acl_hs, TOOLS.GetHistSession);

        INSERT INTO ac_log (acl_id,
                            acl_ac,
                            acl_hs,
                            acl_st,
                            acl_message,
                            acl_st_old,
                            acl_tp)
             VALUES (0,
                     p_acl_ac,
                     l_hs,
                     p_acl_st,
                     p_acl_message,
                     p_acl_st_old,
                     NVL (p_acl_tp, 'SYS'));
    END;

    PROCEDURE calc_write_message (p_mode              INTEGER,
                                  p_message           VARCHAR2,
                                  p_tp                VARCHAR2,
                                  p_messages   IN OUT TOOLS.t_messages)
    IS
    BEGIN
        IF g_write_messages_to_output = 1
        THEN
            DBMS_OUTPUT.put_line (SYSTIMESTAMP || ' : ' || p_message);
        END IF;

        DBMS_APPLICATION_INFO.set_action (action_name => p_message);

        IF p_tp NOT IN ('DIAG')
        THEN
            IF p_mode = 1
            THEN
                TOOLS.add_message (p_messages, p_tp, p_message);
            ELSIF p_mode = 2
            THEN
                TOOLS.JobSaveMessage (p_message, p_tp);
            END IF;
        END IF;
    END;

    PROCEDURE diag_msg (p_message VARCHAR2)
    IS
    BEGIN
        calc_write_message (10,
                            p_message,
                            'DIAG',
                            g_messages);
    END;

    --Встановлення режиму розрахунку: 0 - по ЕОС, 1 - по ЕОС та додатково по вхідній множині особових рахунків (tmp_work_pa_ids)
    PROCEDURE set_calc_mode (p_mode INTEGER)
    IS
    BEGIN
        IF p_mode IN (0, 1)
        THEN
            g_pa_mode_calc := p_mode;
        ELSE
            g_pa_mode_calc := 0;
        END IF;
    END;

    PROCEDURE init_access_params
    IS
    BEGIN
        g_user_type :=
            SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gUserTP);
        g_bp_class := CASE WHEN g_user_type = '41' THEN 'VPO' ELSE 'V' END;
    END;

    --Функція отримання дати початку періоду при перетинанні періоду з місяцем
    FUNCTION dstart (p_date DATE, p_start_dt DATE, p_stop_dt DATE)
        RETURN DATE
    IS
    BEGIN
        IF p_date BETWEEN p_start_dt AND p_stop_dt
        THEN
            RETURN p_date;
        ELSIF p_date < p_start_dt
        THEN
            RETURN p_start_dt;
        ELSE
            RETURN NULL;
        END IF;
    END;

    --Функція отримання дати закінчення періоду при перетинанні періоду з місяцем
    FUNCTION dstop (p_date DATE, p_start_dt DATE, p_stop_dt DATE)
        RETURN DATE
    IS
    BEGIN
        IF p_date BETWEEN p_start_dt AND p_stop_dt
        THEN
            RETURN p_date;
        ELSIF p_date > p_stop_dt
        THEN
            RETURN p_stop_dt;
        ELSE
            RETURN NULL;
        END IF;
    END;

    --Функція отримання прожиткового мінімуму на дату
    FUNCTION get_lgw_cmn (p_date DATE)
        RETURN DECIMAL
    IS
        l_rez   DECIMAL;
    BEGIN
        SELECT lgw_cmn_sum
          INTO l_rez
          FROM uss_ndi.v_ndi_living_wage lgw
         WHERE     lgw.history_status = 'A'
               AND p_date >= lgw_start_dt
               AND (p_date <= lgw_stop_dt OR lgw_stop_dt IS NULL);

        RETURN l_rez;
    END;

    --Функція отримання прожиткового мінімуму на дату
    FUNCTION get_lgw_cmn (p_mode INTEGER, p_date DATE, p_birth_dt DATE)
        RETURN DECIMAL
    IS
        l_rez   DECIMAL;
    BEGIN
        SELECT CASE
                   WHEN p_mode = 1
                   THEN
                       lgw_cmn_sum
                   WHEN     p_mode = 2
                        AND p_birth_dt > ADD_MONTHS (p_date, 0 - 72)
                   THEN
                       lgw_6year_sum
                   WHEN     p_mode = 2
                        AND p_birth_dt > ADD_MONTHS (p_date, 0 - 216)
                   THEN
                       lgw_18year_sum
                   WHEN     p_mode = 2
                        AND p_birth_dt = ADD_MONTHS (p_date, 0 - 216)
                   THEN
                       lgw_work_able_sum
                   ELSE
                       lgw_work_able_sum
               END
          INTO l_rez
          FROM uss_ndi.v_ndi_living_wage lgw
         WHERE     lgw.history_status = 'A'
               AND p_date >= lgw_start_dt
               AND (p_date <= lgw_stop_dt OR lgw_stop_dt IS NULL);

        RETURN l_rez;
    END;

    FUNCTION get_op_tp1 (p_op_id NUMBER)
        RETURN VARCHAR2
    IS
        l_op_tp1   VARCHAR2 (10);
    BEGIN
        RETURN g_op_info (p_op_id);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            BEGIN
                SELECT op_tp1
                  INTO l_op_tp1
                  FROM uss_ndi.v_ndi_op
                 WHERE op_id = p_op_id;

                g_op_info (p_op_id) := l_op_tp1;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    g_op_info (p_op_id) := NULL;
            END;

            RETURN g_op_info (p_op_id);
    END;

    --Знак для іду операції
    FUNCTION xsign (p_op_id NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        RETURN CASE
                   WHEN p_op_id IS NULL
                   THEN
                       0
                   WHEN p_op_id IN (1, 2)
                   THEN
                       1
                   WHEN p_op_id IN (3,
                                    123,
                                    124,
                                    6)
                   THEN
                       -1
                   WHEN p_op_id IN (278, 280)
                   THEN
                       -1                 -- ASOPD 08.2022 OPERVIEIEV (?? 279)
                   WHEN get_op_tp1 (p_op_id) = 'NR'
                   THEN
                       1
                   WHEN get_op_tp1 (p_op_id) = 'DN'
                   THEN
                       -1
                   ELSE
                       1
               END;
    END;

    --Отримання параметрів, за якими користувач може виконати масовий розрахунок нарахувань
    PROCEDURE get_actual_params (p_tp                INTEGER := 1,
                                 p_months_list   OUT SYS_REFCURSOR,
                                 p_org_list      OUT SYS_REFCURSOR)
    IS
    BEGIN
        get_month_list (p_tp, p_months_list);
        get_org_list (p_tp, p_org_list);
    END;

    --Отримання списку місяців, доступних для розрахунку користувачу
    PROCEDURE get_month_list (p_tp                INTEGER := 1,
                              p_months_list   OUT SYS_REFCURSOR)
    IS
    BEGIN
        init_access_params;

        OPEN p_months_list FOR
              SELECT x_month,
                     TO_CHAR (x_month_ac,
                              'Month YYYY',
                              'NLS_DATE_LANGUAGE=UKRAINIAN')    AS x_month_name
                FROM (SELECT DISTINCT
                             bp_month AS x_month, bp_month /*CASE WHEN g_bp_class = 'V' THEN ADD_MONTHS(bp_month, 1) ELSE bp_month END*/
                                                           AS x_month_ac
                        FROM billing_period, tmp_org
                       WHERE     bp_org = u_org
                             AND bp_class = g_bp_class
                             AND bp_st = 'R')
            ORDER BY 1 DESC;
    --    raise_application_error('-20100', '!--!--!');
    END;

    --Отримання останього місяця, доступного для розрахунку користувачу
    PROCEDURE get_month_max (p_months OUT DATE)
    IS
    BEGIN
        init_access_params;

        SELECT MAX (x_month)
          INTO p_months
          FROM (SELECT DISTINCT bp_month     AS x_month
                  FROM billing_period, tmp_org
                 WHERE     bp_org = u_org
                       AND bp_class = g_bp_class
                       AND bp_st = 'R');
    END;


    --Отримання списку районів, доступних для розрахунку користувачу
    PROCEDURE get_org_list (p_tp INTEGER:= 1, p_org_list OUT SYS_REFCURSOR)
    IS
        l_org_to        NUMBER;
        l_org           NUMBER := NULL;
        l_org_acc_org   NUMBER := tools.getcurrorg;
    BEGIN
        l_org_to := TOOLS.GetCurrOrgTo;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg('l_org_to='||l_org_to);
        IF l_org_to = 32
        THEN
            l_org := TOOLS.GetCurrOrg;
        ELSIF l_org_to = 34
        THEN
            --  #80563
            --l_org := TOOLS.GetCurrOblOrg;
            OPEN p_org_list FOR
                  SELECT org_id                           AS x_org,
                         org_code || ': ' || org_name     AS x_org_name
                    FROM v_opfu t
                   WHERE     org_acc_org = l_org_acc_org
                         AND org_id != l_org_acc_org
                         AND org_st = 'A'
                ORDER BY t.org_code;

            RETURN;
        ELSIF (l_org_to = 40)
        THEN
            OPEN p_org_list FOR
                    SELECT org_id                           AS x_org,
                           org_code || ': ' || org_name     AS x_org_name
                      FROM v_opfu
                     WHERE org_to IN (31, 32) AND org_st = 'A'       -- #80563
                CONNECT BY org_org = org_id
                  ORDER BY org_code;

            RETURN;
        END IF;

        OPEN p_org_list FOR
                SELECT org_id                           AS x_org,
                       org_code || ': ' || org_name     AS x_org_name
                  FROM v_opfu
                 WHERE org_to = 32 AND org_st = 'A'
            START WITH org_id = l_org
            CONNECT BY org_org = PRIOR org_id;
    END;

    PROCEDURE authcheck (p_operation VARCHAR2)
    IS
        l_curr_to         NUMBER;
        l_curr_acc_mode   VARCHAR2 (250);
        l_curr_acc_org    NUMBER;
        l_curr_org        NUMBER;
    BEGIN
        l_curr_to := TOOLS.GetCurrOrgTo;
        l_curr_acc_mode := TOOLS.GetCurrOrgAccMode;
        l_curr_acc_org := TOOLS.GetCurrOrgAcc;
        l_curr_org := TOOLS.GetCurrOrg;

        --  ikis_sysweb.ikis_debug_pipe.WriteMsg('l_curr_to='||l_curr_to);
        --  ikis_sysweb.ikis_debug_pipe.WriteMsg('l_curr_acc_mode='||l_curr_acc_mode);

        IF p_operation = 'calc_accrual'
        THEN
            IF l_curr_to IN (32) AND l_curr_acc_org = l_curr_org
            THEN --районному користувачу району, який сам себе обліковує - дозволено
                NULL;
            ELSIF l_curr_to IN (34)
            THEN --користувачу обласного центру - дозволено (в TMP_COM_ORGS повинні залишитись тільки підходящі по org_acc_org
                NULL;
            ELSIF l_curr_to IN (40)
            THEN                                 --користувачу ІОЦ - дозволено
                NULL;
            ELSIF l_curr_to IN (32) AND l_curr_acc_org <> l_curr_org
            THEN
                raise_application_error (
                    '-20100',
                       'Розрахунок нарахувань в '
                    || TOOLS.GetCurrOrgName
                    || ' повинен робити користувач обласного центру нарахувань та виплат!');
            ELSE
                raise_application_error (
                    '-20100',
                    'У вас немає доступу до цієї функції!');
            END IF;
        /*IF l_curr_to IN (32) AND l_curr_acc_mode = 'R' THEN --районному користувачу з режимом обілку "районний" - дозволено
          NULL;
        ELSIF l_curr_to IN (34) AND l_curr_acc_mode = 'O' THEN --користувачу обласного центру з режимом обліку "обласний" - дозволено
          NULL;
        ELSIF l_curr_to IN (40) THEN --користувачу ІОЦ - дозволено
          NULL;
        ELSIF l_curr_to IN (30, 31, 33) THEN
          raise_application_error('-20100', 'У вас немає доступу до цієї функції!');
        ELSIF l_curr_to IN (32) AND l_curr_acc_mode = 'O' THEN
          raise_application_error('-20100', 'Розрахунок нарахувань в '||TOOLS.GetCurrOrgName||' повинен робити користувач обласного центру нарахувань та виплат!');
        ELSIF l_curr_to IN (34) AND l_curr_acc_mode = 'R' THEN
          raise_application_error('-20100', 'Розрахунок нарахувань повинен робити користувач відповідного району!');
        ELSE
          raise_application_error('-20100', 'У вас немає доступу до цієї функції!');
        END IF;*/
        ELSE
            raise_application_error ('-20100',
                                     'У вас немає доступу до цієї функції!');
        END IF;
    END;

    PROCEDURE get_month (p_month                DATE,
                         p_ac_month         OUT DATE,
                         p_max_calc_month   OUT DATE)
    IS
        l_bp_month   billing_period.bp_month%TYPE;
    BEGIN
        init_access_params;

        --dbms_output.put_line('g_bp_class='||g_bp_class);

        IF g_pa_mode_calc = 1
        THEN
            SELECT MAX (bp_month)
              INTO l_bp_month
              FROM billing_period
             WHERE     bp_st = 'R'
                   AND bp_class = g_bp_class
                   AND bp_tp = 'PR'
                   AND bp_org IN (SELECT x_id FROM tmp_com_orgs)
                   AND bp_org IN
                           (SELECT p.com_org
                              FROM tmp_work_pa_ids, pc_decision p
                             WHERE pd_pa = x_pa AND pd_st IN ('S', 'PS'));
        ELSE
            SELECT MAX (bp_month)
              INTO l_bp_month
              FROM billing_period
             WHERE     bp_st = 'R'
                   AND bp_class = g_bp_class
                   AND bp_tp = 'PR'
                   AND bp_org IN (SELECT x_id FROM tmp_com_orgs)
                   AND bp_org IN (SELECT p.com_org
                                    FROM tmp_work_ids, personalcase p
                                   WHERE pc_id = x_id);
        END IF;

        --  dbms_output.put_line('l_bp_month='||l_bp_month);

        p_ac_month :=
            NVL (TRUNC (l_bp_month, 'MM'),
                 ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 0));

        --  dbms_output.put_line('p_ac_month='||p_ac_month);

        IF g_user_type = '41'
        THEN
            p_max_calc_month := p_ac_month;
        ELSE
            p_max_calc_month := p_ac_month;
        --    p_max_calc_month := ADD_MONTHS(p_ac_month, 1);
        END IF;
    --  dbms_output.put_line('p_max_calc_month='||p_max_calc_month);
    END;

    --Попередній розрахунок нарахувань з врахуванням незавершеного рівшення про призначення
    PROCEDURE prev_calc_accrual (p_pd_id personalcase.pc_id%TYPE)
    IS
        l_pc_id      personalcase.pc_id%TYPE;
        l_messages   SYS_REFCURSOR;
    BEGIN
        SELECT pd_pc
          INTO l_pc_id
          FROM pc_decision
         WHERE pd_id = p_pd_id;

        INSERT INTO tmp_work_set1 (x_id1)
             VALUES (p_pd_id);

        ---!!! треба підготувати правильну табличку tmp_pd_accrual_period, тобто сформувати історію дії рішень, змоделювавши перевід рішення p_pd_id в стан Призначено.
        calc_accrual (1,
                      3,
                      l_pc_id,
                      NULL,
                      l_messages);
    END;

    PROCEDURE get_accrual_periods (p_calc_mode INTEGER)
    IS
    BEGIN
        IF p_calc_mode IN (1, 2)
        THEN
            INSERT INTO tmp_pd_accrual_period (d_pd, d_start_dt, d_stop_dt)
                SELECT DISTINCT pdap_pd, TRUNC (pdap_start_dt), pdap_stop_dt
                  FROM pd_accrual_period pdap, pc_decision, tmp_wac_ids
                 WHERE     pd_pc = x_id
                       AND pd_st IN ('PS', 'S')
                       --        AND pd_st = 'S'
                       --        AND pd_hs_head IS NOT NULL
                       AND pdap_pd = pd_id
                       AND pdap.history_status = 'A';
        ELSIF p_calc_mode = 3
        THEN
            --Формуємо таблицю tmp_pd_accrual_period з новою історією по рішенням, яка повинна була бути після переведення рішення з tmp_work_set1 в стан Призначено
            API$HIST.init_work;

            --Збираємо наявну історію
            INSERT INTO tmp_unh_old_list (ol_obj,
                                          ol_hst,
                                          ol_begin,
                                          ol_end)
                SELECT nw.pd_pa,
                       pdap_id,
                       pdap_start_dt,
                       pdap_stop_dt
                  FROM pc_decision        al,
                       pd_accrual_period  acr,
                       tmp_work_set1,
                       pc_decision        nw
                 WHERE     al.pd_pa = nw.pd_pa
                       AND al.pd_st IN ('PS', 'S')
                       --        AND al.pd_st = 'S'
                       AND pdap_pd = al.pd_id
                       AND acr.history_status = 'A'
                       AND pdap_start_dt <= nw.pd_stop_dt
                       AND pdap_stop_dt >=
                           NVL (nw.pd_stop_dt,
                                TO_DATE ('31.12.2100', 'DD.MM.YYYY'))
                       AND nw.pd_id = x_id1;

            INSERT INTO tmp_unh_work_list (work_obj,
                                           work_hst,
                                           work_begin,
                                           work_end)
                SELECT nw.pd_pa,
                       0,
                       pd_start_dt,
                       NVL (nw.pd_stop_dt,
                            TO_DATE ('31.12.2100', 'DD.MM.YYYY'))
                  FROM tmp_work_set1, pc_decision nw
                 WHERE x_id1 = pd_id;

            API$HIST.setup_history (0,
                                    0,
                                    NULL,
                                    NULL);

            INSERT INTO tmp_pd_accrual_period (d_pd, d_start_dt, d_stop_dt)
                SELECT pdap_pd, rz_begin, rz_end
                  FROM tmp_unh_rz_list, pd_accrual_period
                 WHERE rz_hst = pdap_id
                UNION ALL
                SELECT x_id1, rz_begin, rz_end
                  FROM tmp_unh_rz_list, tmp_work_set1
                 WHERE rz_hst = 0;
        ELSE
            raise_application_error (
                -20000,
                   'Режим розрахунку нарахувань '
                || p_calc_mode
                || ' не підтримується!');
        END IF;
    END;

    PROCEDURE clean_temp_tables
    IS
    BEGIN
        DELETE FROM tmp_ac_dates1
              WHERE 1 = 1;

        DELETE FROM tmp_ac_dates
              WHERE 1 = 1;

        DELETE FROM tmp_dn_dates1
              WHERE 1 = 1;

        DELETE FROM tmp_dn_dates
              WHERE 1 = 1;

        DELETE FROM tmp_ac_to_del
              WHERE 1 = 1;

        DELETE FROM tmp_pc_accrual_queue
              WHERE 1 = 1;

        DELETE FROM tmp_pd_accrual_period
              WHERE 1 = 1;

        DELETE FROM tmp_ac_dn_src
              WHERE 1 = 1;

        DELETE FROM tmp_wac_ids
              WHERE 1 = 1;

        DELETE FROM tmp_ac_detail
              WHERE 1 = 1;

        DELETE FROM tmp_accrual
              WHERE 1 = 1;

        DELETE FROM tmp_ac_income
              WHERE 1 = 1;

        DELETE FROM tmp_ac_income_for_dn
              WHERE 1 = 1;

        DELETE FROM tmp_ac_nst_list
              WHERE 1 = 1;

        DELETE FROM tmp_ac_npt_calculated
              WHERE 1 = 1;

        DELETE FROM tmp_ac_diff
              WHERE 1 = 1;

        DELETE FROM tmp_ac_dn_params
              WHERE 1 = 1;
    END;

    --Ініціалізація переліку послуг в залежності від типу органу користувача
    PROCEDURE init_nst_list (p_calc_mode INTEGER:= 1) --1 - індивідуальний розрахунок з інтерфейсу, 2 - масовий розрахунок з шедулера, 3 - попреденій розрахунок з врахуванням незавершеного рішення
    IS
        l_curr_to   NUMBER;
    BEGIN
        l_curr_to := TOOLS.GetCurrOrgTo;

        IF l_curr_to = 40
        THEN
            INSERT INTO tmp_ac_nst_list (x_nst)
                 VALUES (664);

            INSERT INTO tmp_ac_nst_list (x_nst)
                 VALUES (20);
        ELSE
            INSERT INTO tmp_ac_nst_list (x_nst)
                SELECT DISTINCT ncc_nst
                  FROM uss_ndi.v_ndi_nst_calc_config
                 WHERE ncc_nst NOT IN (664, 20) OR p_calc_mode IN (1, 3); --Для немасового розрахунку - всі послуги
        END IF;
    END;

    FUNCTION get_exclude_sum_by_pd (p_pd_id     pd_payment.pdp_id%TYPE,
                                    p_npt_id    pd_payment.pdp_npt%TYPE,
                                    p_nnnc_id   pd_payment.pdp_id%TYPE,
                                    p_dt        pd_payment.pdp_start_dt%TYPE)
        RETURN NUMBER
    IS
        l_pdp           pd_payment%ROWTYPE;
        l_koef          NUMBER;
        l_cnt           INTEGER;
        l_exclude_sum   pd_detail.pdd_value%TYPE;
    BEGIN
        SELECT *
          INTO l_pdp
          FROM pd_payment
         WHERE     pdp_pd = p_pd_id
               AND history_Status = 'A'
               AND pdp_npt = p_npt_id
               AND p_dt BETWEEN pdp_start_dt AND pdp_stop_dt;

        IF l_pdp.pdp_sum > 0
        THEN
            SELECT /*+index(pd_payment IFK_PDD_PDP)*/
                   SUM (pdd_value)
              INTO l_exclude_sum
              FROM uss_esr.pd_detail, uss_ndi.v_ndi_nst_dn_exclude
             WHERE     pdd_pdp = l_pdp.pdp_id
                   AND pdd_ndp IN (290, 300)
                   AND pdd_npt = nnde_npt
                   AND history_status = 'A'
                   AND nnde_nnnc = p_nnnc_id;

            IF l_exclude_sum IS NULL OR l_exclude_sum = 0
            THEN
                RETURN 1;
            ELSIF     l_exclude_sum > 0
                  AND l_pdp.pdp_sum > 0
                  AND l_pdp.pdp_sum > l_exclude_sum
            THEN
                RETURN l_exclude_sum / l_pdp.pdp_sum;
            ELSE
                RETURN 1;
            END IF;
        ELSE
            RETURN 1;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN 1;
    END;

    PROCEDURE print_diag_tables
    IS
        FUNCTION p (p_msg VARCHAR2, p_length INTEGER)
            RETURN VARCHAR2
        IS
        BEGIN
            RETURN    SUBSTR (LPAD (NVL (p_msg, ' '), p_length, ' '),
                              1,
                              p_length)
                   || '|';
        END;
    BEGIN
        IF g_write_messages_to_output = 1
        THEN                             --| dn_first_step--start_usable_sum |
            diag_msg (
                'full_income | dn_second_step | sd_usable_sum | npt | used_sum | id | npt_usable_sum | nst |       pd | used_by_dn | pd_income | sd_pa |');

            FOR x IN (  SELECT sd_pc,
                               sd_month,
                               sd_ndn,
                               sd_full_income,
                               sd_dn_first_step,
                               sd_dn_second_step,
                               sd_usable_sum,
                               sd_npt,
                               sd_start_usable_sum,
                               sd_used_sum,
                               sd_id,
                               sd_npt_usable_sum,
                               sd_nst,
                               sd_pd,
                               sd_used_by_dn,
                               sd_pd_income,
                               sd_pa
                          FROM tmp_ac_income_for_dn
                      ORDER BY sd_id)
            LOOP
                diag_msg (
                       p (x.sd_full_income, 12)
                    || p (x.sd_dn_second_step, 16)
                    || p (x.sd_usable_sum, 15)
                    || p (x.sd_npt, 5)
                    || p (x.sd_used_sum, 10)
                    || p (x.sd_id, 4)
                    || p (x.sd_npt_usable_sum, 16)
                    || p (x.sd_nst, 5)
                    || p (x.sd_pd, 10)
                    || p (x.sd_used_by_dn, 12)
                    || p (x.sd_pd_income, 11)
                    || p (x.sd_pa, 8));
            END LOOP;
        END IF;
    END;

    PROCEDURE calc_dn_debts
    IS
        l_inc                  INTEGER := 0;
        l_have_dn              INTEGER := 0;
        l_income_found         INTEGER;
        l_deduction            tmp_ac_dn_src%ROWTYPE;
        l_income               tmp_ac_income_for_dn%ROWTYPE;
        l_new_deduction_debt   tmp_ac_dn_src%ROWTYPE;
        l_dn_used_sum          NUMBER (18, 2);
        l_dn_new_debt_sum      NUMBER (18, 2);
        l_limit                NUMBER (18, 2);
        l_pd_limit             NUMBER (18, 2);
        l_s_start_dt           DATE := NULL;
        l_dn_params            tmp_ac_dn_params%ROWTYPE;
    BEGIN
        UPDATE tmp_ac_dn_src
           SET s_id = ROWNUM,
               s_st = 'W',
               s_ori_start_dt = s_start_dt,
               s_ori_stop_dt = s_stop_dt
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_ac_dn_params
                     WHERE s_dn = d_dn AND d_calc_step = 'S');

        l_inc := SQL%ROWCOUNT + 1;

        --Обраховуємо суми доходів для типів помісячно - для можливості рознесення в рамках цих доходів накопичених боргів всіх типів
        INSERT INTO tmp_ac_income_for_dn (sd_id,
                                          sd_pc,
                                          sd_pa,
                                          sd_pd,
                                          sd_month,
                                          sd_ndn,
                                          sd_nst,
                                          sd_npt,
                                          sd_pd_income)
            SELECT ROWNUM,
                   k_pc,
                   k_pa,
                   k_pd,
                   k_dt,
                   k_ndn,
                   k_nst,
                   k_npt,
                   k_sum * k_can_use_koef
              FROM (  SELECT a_pc
                                 AS k_pc,
                             a_pa
                                 AS k_pa,
                             a_pd
                                 AS k_pd,
                             TRUNC (a_start_dt, 'MM')
                                 AS k_dt,
                             a_nst
                                 AS k_nst,
                             nnnc_ndn
                                 AS k_ndn,
                             a_npt
                                 AS k_npt,
                             SUM (API$ACCTOOLS.xsign (a_op) * a_sum)
                                 AS k_sum,
                             NVL (
                                 MAX (
                                     CASE
                                         WHEN 0 <
                                              (SELECT COUNT (*)
                                                 FROM uss_ndi.v_ndi_nst_dn_exclude
                                                WHERE nnde_nnnc = nnnc_id) --Якщо в таблиці виключеннь є записи, рахуємо по кожній проводці - яку саме частку суми виключаемо
                                         THEN
                                             api$accrual_test.get_exclude_sum_by_pd (
                                                 a_pd,
                                                 a_npt,
                                                 nnnc_id,
                                                 a_start_dt)
                                         ELSE
                                             1 --Якщо в таблиці виключеннь немає відповідних записів - значить 100%
                                     END),
                                 1)
                                 AS k_can_use_koef
                        FROM tmp_ac_detail t, uss_ndi.v_ndi_nst_dn_config
                       WHERE     a_nst = nnnc_nst
                             AND history_status = 'A'
                             AND a_need_write_2_base = 'T'
                             AND nnnc_ndn IN
                                     (SELECT d_ndn
                                        FROM tmp_ac_dn_params
                                       WHERE     (   LAST_DAY (a_start_dt) >=
                                                     d_start_dt
                                                  OR d_start_dt IS NULL)
                                             AND d_pc = a_pc)
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM uss_ndi.v_ndi_nst_dn_exclude
                                       WHERE     nnde_nnnc = nnnc_id
                                             AND t.a_npt = nnde_npt)
                    GROUP BY a_pc,
                             a_pa,
                             a_pd,
                             TRUNC (a_start_dt, 'MM'),
                             nnnc_ndn,
                             a_nst,
                             a_npt);


        UPDATE tmp_ac_income_for_dn ma
           SET sd_full_income =
                   (SELECT SUM (sd_pd_income)
                      FROM tmp_ac_income_for_dn sl
                     WHERE     ma.sd_pc = sl.sd_pc
                           AND ma.sd_pa = sl.sd_pa
                           AND ma.sd_month = sl.sd_month
                           AND ma.sd_ndn = sl.sd_ndn
                           AND ma.sd_nst = sl.sd_nst/*AND ma.sd_npt = sl.sd_npt*/
                                                    )
         WHERE 1 = 1;

        UPDATE tmp_ac_income_for_dn
           SET sd_used_sum = 0
         WHERE 1 = 1;

        --Проставляємо суму ліміту, який можна використовувати.
        UPDATE tmp_ac_income_for_dn
           SET (sd_usable_sum, sd_npt_usable_sum) =
                   (SELECT sd_pd_income - sd_used_sum,
                           sd_pd_income - sd_used_sum
                      FROM DUAL)
         WHERE 1 = 1;

        --Визначаємо кількість наявних записів відрахувань - вихід з алгоритму, коли ліміт закінчиться
        SELECT COUNT (*)
          INTO l_have_dn
          FROM tmp_ac_dn_src
         WHERE s_st = 'W';

        diag_msg ('l_have_dn=' || l_have_dn);

        --return;
        LOOP
            EXIT WHEN l_have_dn = 0; --Якщо немає лімітів на задовільнення боргів - вихід

            --Беремо черговий запис боргу по відрахуванням
            SELECT *
              INTO l_deduction
              FROM (  SELECT *
                        FROM tmp_ac_dn_src
                       WHERE s_st IN ('W', 'P')
                    ORDER BY s_pc,
                             s_ndn_order,
                             TRUNC (s_start_dt, 'MM'),
                             NVL (s_npt, 100000000),
                             s_ndn,
                             s_dn,
                             s_id)
             WHERE ROWNUM = 1;

            diag_msg (
                   'l_deduction.s_id='
                || l_deduction.s_id
                || '; l_deduction.s_start_dt='
                || l_deduction.s_start_dt
                || '; l_deduction.s_sum='
                || l_deduction.s_sum);

            SELECT *
              INTO l_dn_params
              FROM tmp_ac_dn_params
             WHERE d_id = l_deduction.s_d_id;

            diag_msg (
                   'l_dn_params.d_value='
                || l_dn_params.d_value
                || '; l_dn_params.d_value_prefix='
                || l_dn_params.d_value_prefix
                || '; l_dn_params.d_tp='
                || l_dn_params.d_tp
                || '; l_dn_params.d_dn_tp='
                || l_dn_params.d_dn_tp
                || '; l_dn_params.d_debt_limit_prc='
                || l_dn_params.d_debt_limit_prc
                || '; l_dn_params.d_max_prc='
                || l_dn_params.d_max_prc);

            print_diag_tables;
            --return;
            --Шукаємо підходящий запис доходів (по справі + періоду + типу відрахування + наявна сума для використання)
            l_income_found := 0;

            BEGIN
                SELECT *
                  INTO l_income
                  FROM (  SELECT *
                            FROM tmp_ac_income_for_dn
                           WHERE     sd_month BETWEEN l_deduction.s_start_dt
                                                  AND l_deduction.s_stop_dt -- >= l_deduction.s_start_dt
                                 AND l_deduction.s_pc = sd_pc
                                 AND l_deduction.s_pa = sd_pa            --???
                                 AND l_deduction.s_ndn = sd_ndn
                                 AND sd_npt_usable_sum > 0
                                 AND (   sd_used_by_dn IS NULL
                                      OR sd_used_by_dn NOT LIKE
                                             '%#' || l_deduction.s_id || '#%')
                                 AND sd_nst = l_deduction.s_nst
                                 AND (   (    l_deduction.s_stage = '2'
                                          AND l_deduction.s_npt = sd_npt)
                                      OR l_deduction.s_stage <> '2')
                        ORDER BY sd_month,
                                 DECODE (l_deduction.s_dnd_tp,
                                         'AS', sd_pd_income,
                                         0) DESC,
                                 sd_npt)
                 WHERE ROWNUM = 1;

                  SELECT COUNT (*)
                    INTO l_income_found
                    FROM tmp_ac_income_for_dn
                   WHERE     sd_month BETWEEN l_deduction.s_start_dt
                                          AND l_deduction.s_stop_dt -- >= l_deduction.s_start_dt
                         AND l_deduction.s_pc = sd_pc
                         AND l_deduction.s_pa = sd_pa                    --???
                         AND l_deduction.s_ndn = sd_ndn
                         AND sd_npt_usable_sum > 0
                         AND (   sd_used_by_dn IS NULL
                              OR sd_used_by_dn NOT LIKE
                                     '%#' || l_deduction.s_id || '#%')
                         AND sd_nst = l_deduction.s_nst
                         AND (   (    l_deduction.s_stage = '2'
                                  AND l_deduction.s_npt = sd_npt)
                              OR l_deduction.s_stage <> '2')
                ORDER BY sd_month,
                         DECODE (l_deduction.s_dnd_tp, 'AS', sd_pd_income, 0) DESC,
                         sd_npt;

                --      l_income_found := 1;
                diag_msg (
                       'Знайдено дохід sd_id='
                    || l_income.sd_id
                    || ' всього ('
                    || l_income_found
                    || '), з якого можна зняти: l_income.sd_month='
                    || l_income.sd_month
                    || '; l_income.sd_npt_usable_sum='
                    || l_income.sd_npt_usable_sum
                    || '; l_income.sd_pd_income='
                    || l_income.sd_pd_income
                    || '; l_income.sd_used_sum='
                    || l_income.sd_used_sum);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    diag_msg ('НЕ знайдено дохід, з якого можна зняти');
                    NULL;
            END;

            IF l_income_found > 0
            THEN
                diag_msg ('Розраховуємо суму ліміту!');

                IF l_dn_params.d_dn_tp IN ('R', 'HM')
                THEN  --Для переплат - ліміт на основі параметрів відрахування
                    CASE l_dn_params.d_tp
                        WHEN 'PD'
                        THEN
                            l_limit :=
                                  l_income.sd_full_income
                                * l_dn_params.d_max_prc
                                / 100;
                            l_pd_limit :=
                                  l_income.sd_pd_income
                                * l_dn_params.d_value
                                / 100;
                        WHEN 'AS'
                        THEN
                            l_limit := l_dn_params.d_value;
                            l_pd_limit := l_income.sd_pd_income;
                        WHEN 'SD'
                        THEN
                            l_limit :=
                                  l_income.sd_full_income
                                * l_dn_params.d_value
                                / l_dn_params.d_value_prefix;
                            l_pd_limit :=
                                  l_income.sd_pd_income
                                * l_dn_params.d_value
                                / l_dn_params.d_value_prefix;
                        WHEN 'PL'
                        THEN
                            l_limit :=
                                  get_lgw_cmn (
                                      2,
                                      TRUNC (l_deduction.s_start_dt, 'MM'),
                                      l_dn_params.d_birth_dt)
                                * l_dn_params.d_value
                                / 100;
                            l_pd_limit := l_income.sd_pd_income;
                        ELSE
                            l_limit := 0;
                    END CASE;
                ELSIF l_dn_params.d_dn_tp = 'D'
                THEN --Для звичайних відрахувань - ліміт на основі параметрів довідника
                    IF l_deduction.s_op = 123
                    THEN --Поточні відрахування беремо за відсотком з довідника
                        l_limit :=
                              l_income.sd_full_income
                            * l_dn_params.d_max_prc
                            / 100;
                        l_pd_limit :=
                              l_income.sd_pd_income
                            * l_dn_params.d_max_prc
                            / 100;
                    ELSIF l_deduction.s_op = 40
                    THEN --"Борги" беремо по обмеженню "для боргів" або, якщо це обмеження нульове, по обмеженню з довідника
                        l_limit :=
                              l_income.sd_full_income
                            * CASE
                                  WHEN l_dn_params.d_debt_limit_prc > 0
                                  THEN
                                      l_dn_params.d_debt_limit_prc
                                  ELSE
                                      l_dn_params.d_max_prc
                              END
                            / 100;
                        l_pd_limit :=
                              l_income.sd_pd_income
                            * CASE
                                  WHEN l_dn_params.d_debt_limit_prc > 0
                                  THEN
                                      l_dn_params.d_debt_limit_prc
                                  ELSE
                                      l_dn_params.d_max_prc
                              END
                            / 100;
                    ELSE
                        l_limit := 0;
                        l_pd_limit := 0;
                    END IF;
                END IF;

                diag_msg ('Сума ліміту абсолютна: l_limit=' || l_limit);
                diag_msg (
                       'Сума ліміту по рішенню + коду выплаты: l_pd_limit='
                    || l_pd_limit);
                diag_msg (
                       'Сума використаного доходу: l_income.sd_used_sum='
                    || l_income.sd_used_sum);

                IF l_limit > l_pd_limit
                THEN
                    l_limit := l_pd_limit;
                    diag_msg (
                           'Коригуємо ліміт до ліміту по рішенню: l_limit='
                        || l_limit);
                END IF;

                IF l_limit <= l_income.sd_used_sum
                THEN --Якщо обрахований абсолютний ліміт відрахування менший за використану раніше суму - то дохід не підходить, все вже використано
                    l_limit := 0;
                    l_income_found := 0;
                ELSIF l_limit > l_income.sd_used_sum
                THEN --Якщо обрахований абсолютний ліміт відрахування більший за використану раніше суму - то лімітом встановлюємо різницю
                    l_limit := l_limit - l_income.sd_used_sum;
                END IF;

                diag_msg (
                       'Сума ліміту скоригована на суму використаного доходу: l_limit='
                    || l_limit);
            END IF;

            diag_msg (
                   'Сума відрахування повна: l_deduction.s_sum='
                || l_deduction.s_sum);
            l_deduction.s_sum :=
                l_deduction.s_sum - NVL (l_deduction.s_used_sum, 0);
            diag_msg (
                   'Сума відрахування скоригована на вже погашену суму: l_deduction.s_sum='
                || l_deduction.s_sum);

            IF l_income_found = 0
            THEN --Якщо не знайдено рядка доходів, то сума відрахування повністю переходить в борг
                l_dn_used_sum := 0;
                l_dn_new_debt_sum := l_deduction.s_sum;
                diag_msg (
                       'Сума відрахування повністю переходить в борг. l_dn_used_sum='
                    || l_dn_used_sum
                    || ';l_dn_new_debt_sum='
                    || l_dn_new_debt_sum);
            ELSE
                IF l_deduction.s_sum <= l_limit
                THEN
                    --Сума повністю в ліміті - пишемо її в результуючий список відрахувань
                    l_dn_used_sum := l_deduction.s_sum;
                    l_dn_new_debt_sum := 0;
                    diag_msg (
                           'Сума відрахування повністю нарахована. l_dn_used_sum='
                        || l_dn_used_sum
                        || ';l_dn_new_debt_sum='
                        || l_dn_new_debt_sum);
                ELSIF l_deduction.s_sum > l_limit
                THEN
                    --Сума відрахування більша за суму ліміту - пишемо в результуючий список тільки суму ліміту
                    l_dn_used_sum := l_limit;
                    l_dn_new_debt_sum := l_deduction.s_sum - l_limit;
                    diag_msg (
                           'Сума відрахування нарахована частково. l_dn_used_sum='
                        || l_dn_used_sum
                        || ';l_dn_new_debt_sum='
                        || l_dn_new_debt_sum);
                END IF;
            END IF;

            --Якщо виявлено можливість погасити частину боргу
            IF l_dn_used_sum > 0
            THEN
                diag_msg (
                       'Використано суму доходу: l_dn_used_sum='
                    || l_dn_used_sum);

                --Пишему у результуючу таблицю суму, яку вдалось погасити
                INSERT INTO tmp_ac_detail (a_pc,
                                           a_pa,
                                           a_op,
                                           a_npt,
                                           a_start_dt,
                                           a_stop_dt,
                                           a_sum,
                                           a_month_sum,
                                           a_ac_start_dt,
                                           a_ac_stop_dt,
                                           a_delta_recalc,
                                           a_delta_pay,
                                           a_dn,
                                           a_pd,
                                           a_stage,
                                           a_need_write_2_base)
                         VALUES (
                                    l_deduction.s_pc,
                                    l_deduction.s_pa,
                                    CASE l_deduction.s_sum_tp
                                        WHEN 'CURRM' THEN 123
                                        WHEN 'DEBT' THEN 124
                                        ELSE 123
                                    END,
                                    l_income.sd_npt,
                                    l_deduction.s_start_dt,
                                    l_deduction.s_stop_dt,
                                    l_dn_used_sum,
                                    l_dn_used_sum,
                                    g_ac_month,
                                    LAST_DAY (g_ac_month),
                                    l_dn_used_sum,
                                    NULL,
                                    l_deduction.s_dn,
                                    l_income.sd_pd,
                                    '6',
                                    'T');

                --Актуалізуємо суми "відрахування другого шагу" (додаємо суму) та "сума доходу, що може бути використана" (зменшуємо суму)
                UPDATE tmp_ac_income_for_dn
                   SET sd_dn_second_step =
                           NVL (sd_dn_second_step, 0) + l_dn_used_sum,
                       sd_usable_sum = NVL (sd_usable_sum, 0) - l_dn_used_sum,
                       sd_used_sum = NVL (sd_used_sum, 0) + l_dn_used_sum
                 WHERE     sd_month = l_income.sd_month
                       AND sd_pc = l_deduction.s_pc
                       AND sd_pa = l_deduction.s_pa
                       AND sd_ndn IN (SELECT nnnc_ndn
                                        FROM uss_ndi.v_ndi_nst_dn_config
                                       WHERE nnnc_nst = l_income.sd_nst)
                       AND sd_npt = l_income.sd_npt;

                --          AND ((l_dn_params.d_tp IN ('PD', 'SD') AND sd_npt = l_income.sd_npt)
                --            OR l_dn_params.d_tp IN ('AS', 'PL'));

                diag_msg ('updated sd_usable_sum rows: ' || SQL%ROWCOUNT);

                UPDATE tmp_ac_income_for_dn
                   SET sd_npt_usable_sum =
                           NVL (sd_npt_usable_sum, 0) - l_dn_used_sum
                 WHERE     sd_pc = l_deduction.s_pc
                       AND sd_pa = l_deduction.s_pa
                       AND sd_npt = l_income.sd_npt
                       --          AND ((l_dn_params.d_tp IN ('PD', 'SD') AND sd_npt = l_income.sd_npt)
                       --            OR l_dn_params.d_tp IN ('AS', 'PL'))
                       AND sd_ndn IN (SELECT nnnc_ndn
                                        FROM uss_ndi.v_ndi_nst_dn_config
                                       WHERE nnnc_nst = l_income.sd_nst)
                       AND sd_month = l_income.sd_month;

                diag_msg ('updated sd_npt_usable_sum rows: ' || SQL%ROWCOUNT);

                UPDATE tmp_ac_dn_src
                   SET s_used_sum = NVL (s_used_sum, 0) + l_dn_used_sum,
                       s_st =
                           CASE
                               WHEN NVL (s_used_sum, 0) + l_dn_used_sum =
                                    s_sum
                               THEN
                                   'S'
                               ELSE
                                   'P'
                           END
                 WHERE s_id = l_deduction.s_id;

                diag_msg (
                       'Проставляємо у використаний рядок доходу '
                    || l_income.sd_id
                    || ' позначку, що він використаний рядком відрахування '
                    || l_deduction.s_id
                    || ' для недопущення повторного використання.');

                UPDATE tmp_ac_income_for_dn
                   SET sd_used_by_dn =
                           sd_used_by_dn || '#' || l_deduction.s_id || '#'
                 WHERE sd_id = l_income.sd_id;
            END IF;

            IF l_income_found = 0 AND l_deduction.s_op = 40
            THEN --Для початкових боргів - одразу знаходимо наступний місяць, аби пересунути борг у відповідний місяць з доходами
                --Визначаємо наступний місяць з доходами
                SELECT MIN (sd_month)
                  INTO l_s_start_dt
                  FROM tmp_ac_income_for_dn
                 WHERE     sd_month > l_deduction.s_stop_dt
                       AND sd_pc = l_deduction.s_pc
                       AND sd_pa = l_deduction.s_pa
                       AND sd_ndn = l_deduction.s_ndn
                       AND sd_nst = l_deduction.s_nst;

                diag_msg (
                       'Визначаємо наступний місяць з доходами для початкових боргів - 40. Це: '
                    || l_s_start_dt);
            ELSIF l_income_found > 1 AND l_dn_new_debt_sum > 0
            THEN
                SELECT MIN (sd_month)
                  INTO l_s_start_dt
                  FROM tmp_ac_income_for_dn
                 WHERE     sd_month >= l_deduction.s_start_dt
                       AND sd_pc = l_deduction.s_pc
                       AND sd_pa = l_deduction.s_pa
                       AND sd_ndn = l_deduction.s_ndn
                       AND (   sd_used_by_dn IS NULL
                            OR sd_used_by_dn NOT LIKE
                                   '%#' || l_deduction.s_id || '#%')
                       AND sd_nst = l_deduction.s_nst;
            END IF;

            diag_msg ('----------l_income_found: ' || l_income_found);
            diag_msg ('----------l_dn_new_debt_sum: ' || l_dn_new_debt_sum);
            diag_msg ('----------l_dn_used_sum: ' || l_dn_used_sum);
            diag_msg (
                   '----------l_income.sd_usable_sum: '
                || l_income.sd_usable_sum);
            diag_msg ('----------l_deduction.s_op: ' || l_deduction.s_op);
            diag_msg ('----------l_s_start_dt: ' || l_s_start_dt);

            --Якщо не можемо погасити повністю суму по рядку боргу, то формуємо рядок "нового боргу". Фактично - перенесення боргу на наступні періоди
            IF    l_income_found = 0
               OR (    l_income_found = 0
                   AND l_dn_new_debt_sum > 0
                   AND l_s_start_dt IS NOT NULL /*AND (l_dn_used_sum = l_income.sd_usable_sum)*/
                                               )
               OR (    l_income_found = 0
                   AND l_deduction.s_op = 40
                   AND l_s_start_dt IS NOT NULL)
            THEN
                diag_msg (
                    'формуємо рядок "нового боргу". Фактично - перенесення боргу на наступні періоди');

                IF l_s_start_dt IS NULL
                THEN
                    --Визначаємо наступний місяць з доходами
                    SELECT MIN (sd_month)
                      INTO l_s_start_dt
                      FROM tmp_ac_income_for_dn
                     WHERE     sd_month >= l_deduction.s_stop_dt
                           AND sd_pc = l_deduction.s_pc
                           AND sd_pa = l_deduction.s_pa
                           AND sd_ndn = l_deduction.s_ndn
                           AND (   sd_used_by_dn IS NULL
                                OR sd_used_by_dn NOT LIKE
                                       '%#' || l_deduction.s_id || '#%')
                           AND sd_nst = l_deduction.s_nst;
                END IF;

                l_new_deduction_debt := l_deduction;
                l_new_deduction_debt.s_sum := l_dn_new_debt_sum;
                l_new_deduction_debt.s_stage := '7';
                l_new_deduction_debt.s_id := l_inc;
                l_new_deduction_debt.s_used_sum := 0;
                l_new_deduction_debt.s_op := 40; --!!! Всі новостворені борги просуваютсья вперед вже як "борг", навіть якщо починали як 123. Бо спочатку - поточні, а потім "борги", що не зняті вчасно


                l_new_deduction_debt.s_start_dt := l_s_start_dt;
                l_new_deduction_debt.s_stop_dt := LAST_DAY (l_s_start_dt);

                diag_msg (
                       '>>>l_dn_new_debt_sum='
                    || l_dn_new_debt_sum
                    || '>>>>s_id='
                    || l_inc
                    || '>>>>l_s_start_dt='
                    || l_s_start_dt);

                IF l_s_start_dt IS NOT NULL
                THEN
                    l_new_deduction_debt.s_st := 'W';
                ELSE
                    l_new_deduction_debt.s_st := 'N';
                END IF;

                l_inc := l_inc + 1;

                INSERT INTO tmp_ac_dn_src
                     VALUES l_new_deduction_debt;

                UPDATE tmp_ac_dn_src
                   SET s_st = 'T'
                 WHERE s_id = l_deduction.s_id;

                l_s_start_dt := NULL;
            END IF;

            print_diag_tables;

            SELECT COUNT (*)
              INTO l_have_dn
              FROM tmp_ac_dn_src
             WHERE s_st IN ('W', 'P');

            diag_msg ('l_have_dn=' || l_have_dn);
        END LOOP;

        --Записуємо в вихідну множину записів неоплачені борги одержувача допомоги перед одержувачами відпрахувань
        INSERT INTO tmp_ac_detail (a_pc,
                                   a_pa,
                                   a_op,
                                   a_npt,
                                   a_start_dt,
                                   a_stop_dt,
                                   a_sum,
                                   a_month_sum,
                                   a_ac_start_dt,
                                   a_ac_stop_dt,
                                   a_delta_recalc,
                                   a_delta_pay,
                                   a_dn,
                                   a_pd,
                                   a_stage,
                                   a_need_write_2_base)
            SELECT s_pc,
                   s_pa,
                   5,
                   s_npt,
                   g_ac_month,
                   LAST_DAY (g_ac_month),
                   s_sum,
                   NULL,
                   g_ac_month,
                   LAST_DAY (g_ac_month),
                   s_sum,
                   s_id,
                   s_dn,
                   s_pd,
                   '8',
                   'T'
              FROM tmp_ac_dn_src z
             WHERE s_st IN ('W', 'N');
    END;

    PROCEDURE calc_dn
    IS
    BEGIN
        --Готуємо повні дані про всі відрахування, аби не лазити більше в декілька таблиць.
        --По відрахуванням без осіб
        INSERT INTO tmp_ac_dn_params (d_dn,
                                      d_pc,
                                      d_pa,
                                      d_ndn,
                                      d_tp,
                                      d_value,
                                      d_value_prefix,
                                      d_max_prc,
                                      d_src_sum_tp,
                                      d_calc_step,
                                      d_start_debt,
                                      d_global_start_dt,
                                      d_debt_limit_prc,
                                      d_ndn_order,
                                      d_start_dt,
                                      d_stop_dt,
                                      d_part_of_month,
                                      d_id,
                                      d_dn_tp,
                                      d_prc_above,
                                      d_nst,
                                      d_nl_tp,
                                      d_nl_value,
                                      d_nl_value_prefix)
            SELECT dn_id,
                   dn_pc,
                   dn_pa,
                   dn_ndn,
                   dnd_tp,
                   dnd_value,
                   dnd_value_prefix,
                   CASE
                       WHEN dn_tp IN ('R', 'HM')
                       THEN
                           NVL (dn_debt_limit_prc, 20)
                       ELSE
                           NVL (ndn_max_prc, 50)
                   END,
                   ndn_src_sum_tp,
                   ndn_calc_step,
                   dn_debt_current,
                   CASE
                       WHEN dn_tp IN ('R', 'HM') THEN dnd_start_dt
                       ELSE dn_start_dt
                   END,
                   NVL (dn_debt_limit_prc, 0),
                   ndn_order,
                   API$ACCRUAL_TEST.dstart (
                       nm_start_dt,
                       dnd_start_dt,
                       NVL (dnd_stop_dt, TRUNC (SYSDATE) + 100000)),
                   API$ACCRUAL_TEST.dstop (
                       nm_stop_dt,
                       dnd_start_dt,
                       NVL (dnd_stop_dt, TRUNC (SYSDATE) + 100000)),
                   TOOLS.part_of_month (
                       nm_start_dt,
                       API$ACCRUAL_TEST.dstart (
                           nm_start_dt,
                           dnd_start_dt,
                           NVL (dnd_stop_dt, SYSDATE + 100000)),
                       API$ACCRUAL_TEST.dstop (
                           nm_stop_dt,
                           dnd_start_dt,
                           NVL (dnd_stop_dt, SYSDATE + 100000))),
                   ROWNUM,
                   dn_tp,
                   dn_prc_above,
                   pa_nst,
                   dnd_nl_tp,
                   dnd_nl_value,
                   dnd_nl_value_prefix
              FROM tmp_wac_ids,
                   deduction,
                   dn_detail  dd,
                   uss_ndi.v_ndi_deduction,
                   uss_ndi.v_ndi_months,
                   pc_account
             WHERE     x_id = dn_pc
                   AND dnd_dn = dn_id
                   AND dd.history_status = 'A'
                   --AND x_start_dt <= NVL(dnd_stop_dt, sysdate + 100000)
                   AND x_stop_dt >= dnd_start_dt
                   AND dnd_start_dt <= nm_stop_dt
                   --AND NVL(dnd_stop_dt, sysdate + 100000) >= nm_start_dt
                   AND nm_start_dt BETWEEN x_start_dt AND x_stop_dt
                   AND dnd_value > 0
                   AND dn_ndn = ndn_id
                   AND dn_st = 'R'
                   AND dn_pa = pa_id
                   AND NOT EXISTS
                           (SELECT 1
                              FROM dn_person dnp
                             WHERE     dnp_dn = dn_id
                                   AND dnp.history_status = 'A' /* AND dnp_value > 0*/
                                                               )
                   AND (   g_pa_mode_calc = 0
                        OR (    g_pa_mode_calc = 1
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_pa_ids
                                      WHERE pa_id = x_pa)));

        --По відрахуванням з особами
        INSERT INTO tmp_ac_dn_params (d_dn,
                                      d_pc,
                                      d_pa,
                                      d_ndn,
                                      d_tp,
                                      d_value,
                                      d_value_prefix,
                                      d_max_prc,
                                      d_src_sum_tp,
                                      d_calc_step,
                                      d_start_debt,
                                      d_global_start_dt,
                                      d_debt_limit_prc,
                                      d_ndn_order,
                                      d_start_dt,
                                      d_stop_dt,
                                      d_part_of_month,
                                      d_id,
                                      d_dn_tp,
                                      d_prc_above,
                                      d_nst,
                                      d_nl_tp,
                                      d_nl_value,
                                      d_nl_value_prefix,
                                      d_birth_dt)
            SELECT dn_id,
                   dn_pc,
                   dn_pa,
                   dn_ndn,
                   NVL (dnp_tp, dnd_tp),
                   NVL (dnp_value, dnd_value),
                   NVL (dnp_value_prefix, dnd_value_prefix),
                   CASE
                       WHEN dn_tp IN ('R', 'HM')
                       THEN
                           NVL (dn_debt_limit_prc, 20)
                       ELSE
                           NVL (ndn_max_prc, 50)
                   END
                       AS ddn_max_prc,
                   ndn_src_sum_tp,
                   ndn_calc_step,
                   --dn_debt_current,
                   CASE
                       WHEN (MIN (dnp_id) OVER (PARTITION BY dnp_dn)) =
                            dnp_id
                       THEN
                           dn_debt_current
                   END
                       ddn_start_debt,
                   CASE
                       WHEN dn_tp IN ('R', 'HM') THEN dnd_start_dt
                       ELSE dn_start_dt
                   END,
                   NVL (dn_debt_limit_prc, 0)
                       AS dd_debt_limit_prc,
                   ndn_order,
                   API$ACCRUAL_TEST.dstart (
                       nm_start_dt,
                       dnd_start_dt,
                       NVL (dnd_stop_dt, TRUNC (SYSDATE) + 100000))
                       AS ddn_start_dt,
                   API$ACCRUAL_TEST.dstop (
                       nm_stop_dt,
                       dnd_start_dt,
                       NVL (dnd_stop_dt, TRUNC (SYSDATE) + 100000))
                       AS ddn_stop_dt,
                   TOOLS.part_of_month (
                       nm_start_dt,
                       API$ACCRUAL_TEST.dstart (
                           nm_start_dt,
                           dnd_start_dt,
                           NVL (dnd_stop_dt, SYSDATE + 100000)),
                       API$ACCRUAL_TEST.dstop (
                           nm_stop_dt,
                           dnd_start_dt,
                           NVL (dnd_stop_dt, SYSDATE + 100000)))
                       AS ddn_part_of_month,
                   1000000 + ROWNUM
                       AS ddn_id,
                   dn_tp,
                   dn_prc_above,
                   pa_nst,
                   NVL (dnp_nl_tp, dnd_nl_tp),
                   NVL (dnp_nl_value, dnd_nl_value),
                   NVL (dnp_nl_value_prefix, dnd_nl_value_prefix),
                   dnp_birth_dt
              FROM tmp_wac_ids,
                   deduction,
                   dn_detail  dd,
                   uss_ndi.v_ndi_deduction,
                   uss_ndi.v_ndi_months,
                   pc_account,
                   dn_person  dnp
             WHERE     x_id = dn_pc
                   AND dnd_dn = dn_id
                   AND dd.history_status = 'A'
                   --AND x_start_dt <= NVL(dnd_stop_dt, sysdate + 100000)
                   AND x_stop_dt >= dnd_start_dt
                   AND dnd_start_dt <= nm_stop_dt
                   --AND NVL(dnd_stop_dt, sysdate + 100000) >= nm_start_dt
                   AND nm_start_dt BETWEEN x_start_dt AND x_stop_dt
                   AND dn_ndn = ndn_id
                   AND dn_st = 'R'
                   AND dn_pa = pa_id
                   --AND dnp_value > 0
                   AND dnp_dn = dn_id
                   AND dnp.history_status = 'A'
                   AND x_stop_dt >= dnp_start_dt
                   AND dnp_start_dt <= nm_stop_dt
                   AND (   g_pa_mode_calc = 0
                        OR (    g_pa_mode_calc = 1
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_pa_ids
                                      WHERE pa_id = x_pa)));

        --Обраховуєомо мінімальний з максимальних відсотоків відрахувань - як "загальний" відсоток для кожного "кроку" розрахунку відрахувань
        UPDATE tmp_ac_dn_params ma
           SET d_max_prc =
                   (SELECT MIN (d_max_prc)
                      FROM tmp_ac_dn_params sl
                     WHERE     sl.d_pc = ma.d_pc
                           AND sl.d_calc_step = sl.d_calc_step)
         WHERE d_dn_tp NOT IN ('R', 'HM');

        --Пишемо в перший місяць суму початкового боргу по відрахуванню, якщо ще не записано в tmp_ac_detail - в результуючу таблицю
        INSERT INTO tmp_ac_detail (a_pc,
                                   a_pa,
                                   a_op,
                                   a_npt,
                                   a_start_dt,
                                   a_stop_dt,
                                   a_sum,
                                   a_month_sum,
                                   a_delta_recalc,
                                   a_delta_pay,
                                   a_dn,
                                   a_pd,
                                   a_ac_start_dt,
                                   a_ac_stop_dt,
                                   a_stage)
            SELECT DISTINCT d_pc,
                            d_pa,
                            40,
                            NULL,
                            TRUNC (d_global_start_dt, 'MM'),
                            LAST_DAY (d_global_start_dt),
                            d_start_debt,
                            NULL,
                            d_start_debt,
                            NULL,
                            d_dn,
                            NULL,
                            x_ac_start_dt,
                            x_ac_stop_dt,
                            '2'
              FROM tmp_wac_ids, tmp_ac_dn_params ma
             WHERE     x_id = d_pc
                   AND d_start_debt > 0
                   AND (   d_start_dt = (SELECT MIN (sl.d_start_dt)
                                           FROM tmp_ac_dn_params sl
                                          WHERE ma.d_dn = sl.d_dn)
                        OR d_start_dt IS NULL)
                   AND NOT EXISTS
                           (SELECT 1
                              FROM ac_detail
                             WHERE     acd_op = 40
                                   AND acd_dn = d_dn
                                   AND history_status = 'A');

        --Пишему суму початкового боргу по відрахуванню, якщо ще не записано в tmp_ac_dn_src - в таблицю, з якої виконуватиметься розподіл боргів
        INSERT INTO tmp_ac_dn_src (s_pc,
                                   s_pa,
                                   s_op,
                                   s_npt,
                                   s_start_dt,
                                   s_stop_dt,
                                   s_sum,
                                   s_dn,
                                   s_pd,
                                   s_full_sum,
                                   s_limit_ndn,
                                   s_limit_debt,
                                   s_debt_sum,
                                   s_stage,
                                   s_ndn_order,
                                   s_ndn,
                                   s_d_id,
                                   s_dnd_tp,
                                   s_dn_tp,
                                   s_nst,
                                   s_sum_tp)
              SELECT d_pc,
                     d_pa,
                     40,
                     NULL,
                     TRUNC (d_global_start_dt, 'MM'),
                     LAST_DAY (d_global_start_dt),
                     d_start_debt,
                     d_dn,
                     NULL,
                     d_start_debt,
                     NULL,
                     NULL,
                     NULL,
                     '1',
                     d_ndn_order * 100000,
                     d_ndn,
                     d_id,
                     MAX (d_tp),
                     d_dn_tp,
                     d_nst,
                     'DEBT'
                FROM tmp_wac_ids, tmp_ac_dn_params ma
               WHERE     x_id = d_pc
                     AND d_start_debt > 0
                     AND (   d_start_dt = (SELECT MIN (sl.d_start_dt)
                                             FROM tmp_ac_dn_params sl
                                            WHERE ma.d_dn = sl.d_dn)
                          OR d_start_dt IS NULL)
                     AND NOT EXISTS
                             (SELECT 1
                                FROM ac_detail
                               WHERE     acd_op = 40
                                     AND acd_dn = d_dn
                                     AND history_status = 'A')
            GROUP BY d_pc,
                     d_pa,
                     TRUNC (d_global_start_dt, 'MM'),
                     LAST_DAY (d_global_start_dt),
                     d_start_debt,
                     d_dn,
                     d_start_debt,
                     d_ndn_order * 100000,
                     d_ndn,
                     d_id,
                     d_dn_tp,
                     d_nst;

        --Знаходимо новонараховані "доходи" по справам за визначений період з деталізацією по tmp_ac_dates.
        INSERT INTO tmp_ac_income (tai_pc,
                                   tai_pa,
                                   tai_pd,
                                   tai_nst,
                                   tai_npt,
                                   tai_start_dt,
                                   tai_stop_dt,
                                   tai_sum,
                                   tai_dn_f_step)
              SELECT a_pc,
                     a_pa,
                     a_pd,
                     a_nst,
                     a_npt,
                     td_begin,
                     td_end,
                     SUM (  a_sum
                          * TOOLS.p_o_p (a_start_dt,
                                         a_stop_dt,
                                         td_begin,
                                         td_end)),
                     0
                FROM tmp_ac_detail, tmp_ac_dates
               WHERE     a_need_write_2_base = 'T'
                     AND a_op IN (1, 2)
                     AND a_pc = td_pc
                     AND a_start_dt BETWEEN td_begin AND td_end
                     AND a_npt = td_npt
                     AND a_pa = td_pa
            GROUP BY a_pc,
                     a_pa,
                     a_pd,
                     a_nst,
                     a_npt,
                     td_begin,
                     td_end;

        diag_msg (
            'Знаходимо точки розриву по доходам та параметрам відрахуваннь');

        INSERT INTO tmp_dn_dates1 (tdd_pc, tdd_pa, tdd_dt)
            SELECT tai_pc,
                   tai_pa,
                   DECODE (x_row, 1, tai_start_dt, tai_stop_dt + 1)
              FROM tmp_ac_income,
                   (    SELECT LEVEL     AS x_row
                          FROM DUAL
                    CONNECT BY LEVEL < 3)
            UNION ALL
            SELECT d_pc, d_pa, DECODE (x_row, 1, d_start_dt, d_stop_dt + 1)
              FROM tmp_ac_dn_params,
                   (    SELECT LEVEL     AS x_row
                          FROM DUAL
                    CONNECT BY LEVEL < 3);

        diag_msg ('Знаходимо унікальний набр дат розривів');

        INSERT INTO tmp_dn_dates (td_pc, td_pa, td_begin)
            SELECT DISTINCT tdd_pc, tdd_pa, tdd_dt
              FROM tmp_dn_dates1;

        diag_msg ('Проставляємо кінці періодів');

        UPDATE /*+full(ma1)*/
               tmp_dn_dates ma1
           SET td_end =
                   (SELECT /*+index(sl I_ttd_set1)*/
                           MIN (td_begin) - 1
                      FROM tmp_dn_dates sl
                     WHERE     sl.td_pc = ma1.td_pc
                           AND sl.td_pa = ma1.td_pa
                           AND sl.td_begin > ma1.td_begin)
         WHERE 1 = 1;

        diag_msg ('Видаляємо зайві записи періодів');

        DELETE FROM tmp_dn_dates
              WHERE td_end IS NULL;

        --Відрахування Першого (F) етапу розрахунку
        --З даних рішень про призначення допомоги - рахуємо відрахування "звичайні", по яким немає даних в рішеннях (беремо рішення в статусі "Нараховано") - операція відрахування
        --Відрахування, що залежать від розрахованих сум.
        --Так як відрахування напряму залежать від доходу, то одразу можна порахувати обмеження та борг по відрахуванням. Отже, в a_sum - результуюча сума відрахування, а в a_debt_sum - сума боргу
        --Пишемо одразу в результуючу таблицю, бо ніякі борги на дані суми не впливають - саме тому вони "першочергові".
        INSERT INTO tmp_ac_detail (a_pc,
                                   a_pa,
                                   a_op,
                                   a_npt,
                                   a_start_dt,
                                   a_stop_dt,
                                   a_sum,
                                   a_month_sum,
                                   a_delta_recalc,
                                   a_delta_pay,
                                   a_dn,
                                   a_pd,
                                   a_ac_start_dt,
                                   a_ac_stop_dt,
                                   a_stage,
                                   a_need_write_2_base,
                                   a_nst)
            SELECT q_pc,
                   q_pa,
                   q_op,
                   q_npt,
                   q_start_dt,
                   q_stop_dt,
                   q_corrected_by_limit_dn_sum     AS q_sum,
                   q_month_sum,
                   q_corrected_by_limit_dn_sum     AS q_delta_recalc,
                   NULL                            AS q_delta_pay,
                   q_dn,
                   q_pd,
                   q_ac_start_dt,
                   q_ac_stop_dt,
                   '3',
                   'T',
                   q_nst
              FROM (SELECT x_id                        AS q_pc,
                           q_pa,
                           123                         AS q_op,
                           q_npt,
                           q_nst,
                           q_start_dt,
                           q_stop_dt,
                           --ROUND(tai_sum * q_part_of_income * d_can_use_koef, 2) AS q_dn_sum,
                           --ROUND(tai_sum * q_part_of_income, 2) AS q_income_sum,
                           --ROUND(tai_sum * q_part_of_income, 2) * d_max_prc / 100 AS q_limit_sum,
                           tai_sum * d_can_use_koef    AS q_month_sum,
                           NULL                        AS q_delta_pay,
                           q_dn,
                           q_pd,
                           x_ac_start_dt               AS q_ac_start_dt,
                           x_ac_stop_dt                AS q_ac_stop_dt,
                           d_max_prc                   AS q_max_prc,
                           ROUND (
                               q_dn_sum * q_part_of_income * d_can_use_koef,
                               2)                      AS q_corrected_by_limit_dn_sum
                      FROM tmp_wac_ids,
                           uss_ndi.v_ndi_months,
                           (SELECT tai_pc
                                       AS q_pc,
                                   tai_pa
                                       AS q_pa,
                                   tai_pd
                                       AS q_pd,
                                   d_dn
                                       AS q_dn,
                                   tai_npt
                                       AS q_npt,
                                   tai_nst
                                       AS q_nst,
                                   td_begin
                                       AS q_start_dt,
                                   td_end
                                       AS q_stop_dt,
                                   CASE d_tp
                                       WHEN 'PD'
                                       THEN
                                           ROUND (tai_sum * d_value / 100, 2)
                                       WHEN 'SD'
                                       THEN
                                           ROUND (
                                                 tai_sum
                                               * d_value
                                               / d_value_prefix,
                                               2)
                                       ELSE
                                           0
                                   END
                                       AS q_dn_sum,
                                   tmp_ac_income.*,
                                   d_tp,
                                   TOOLS.p_o_p (tai_start_dt,
                                                tai_stop_dt,
                                                td_begin,
                                                td_end)
                                       AS q_part_of_income,
                                   d_max_prc,
                                   NVL (
                                       CASE
                                           WHEN 0 <
                                                (SELECT COUNT (*)
                                                   FROM uss_ndi.v_ndi_nst_dn_exclude
                                                  WHERE nnde_nnnc = nnnc_id) --Якщо в таблиці виключеннь є записи, рахуємо по кожній проводці - яку саме частку суми виключаемо
                                           THEN
                                               api$accrual_test.get_exclude_sum_by_pd (
                                                   tai_pd,
                                                   tai_npt,
                                                   nnnc_id,
                                                   tai_start_dt)
                                           ELSE
                                               1 --Якщо в таблиці виключеннь немає відповідних записів - значить 100%
                                       END,
                                       1)
                                       AS d_can_use_koef
                              FROM tmp_ac_income,
                                   tmp_ac_dn_params,
                                   uss_ndi.v_ndi_nst_dn_config,
                                   tmp_dn_dates
                             WHERE     tai_pc = d_pc
                                   AND tai_pa = d_pa
                                   AND tai_nst = nnnc_nst
                                   AND d_ndn = nnnc_ndn
                                   AND d_tp IN ('PD', 'SD')
                                   AND tai_start_dt <= d_stop_dt
                                   AND tai_stop_dt >= d_start_dt
                                   AND td_pc = tai_pc
                                   AND td_pc = d_pc
                                   AND td_pa = tai_pa
                                   AND NOT EXISTS
                                           (SELECT 1
                                              FROM uss_ndi.v_ndi_nst_dn_exclude
                                             WHERE     nnde_nnnc = nnnc_id
                                                   AND tai_npt = nnde_npt)
                                   AND td_begin BETWEEN d_start_dt
                                                    AND d_stop_dt
                                   AND td_begin BETWEEN tai_start_dt
                                                    AND tai_stop_dt
                                   AND d_value > 0
                                   AND d_calc_step = 'F')
                     WHERE     x_id = q_pc
                           AND nm_start_dt BETWEEN x_start_dt AND x_stop_dt
                           AND q_start_dt BETWEEN nm_start_dt AND nm_stop_dt);

        --!!!Увага! На поточний момент відрахувань "першого кроку" (а це держутримання) з типами "Абс.сума" та "% ПМ" не бувають. Тому вони на даному кроці і не розраховуються!
        --Так як відрахування "першого кроку" розраховуються завжди від доходу та відомий NTP,
        --то не потрбібно на даному кроці обраховувати "алгоритмом наповнення" реальні відрахування по рядках, в яких не відомий NTP

        --Оновлюємо таблицю доходів в рядках "нараховано" сумою обрахованих відрахувань "першого етапу".
        UPDATE tmp_ac_income
           SET tai_dn_f_step =
                   NVL (
                       (SELECT SUM (a_sum)
                          FROM tmp_ac_detail
                         WHERE     tai_pc = a_pc
                               AND tai_pa = a_pa
                               AND a_op = 123
                               AND tai_npt = a_npt
                               AND tai_start_dt <= a_stop_dt
                               AND tai_stop_dt >= a_start_dt),
                       0)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_ac_detail
                     WHERE     tai_pc = a_pc
                           AND tai_pa = a_pa
                           AND a_op = 123
                           AND tai_npt = a_npt
                           AND tai_start_dt <= a_stop_dt
                           AND tai_stop_dt >= a_start_dt);

        --Відрахування Другого (S) етапу розрахунку
        --З даних рішень про призначення допомоги - рахуємо відрахування "звичайні", по яким немає даних в рішеннях (беремо рішення в статусі "Нараховано") - операція відрахування
        --Відрахування, що залежать від розрахованих сум. Сума доходу, з якої беруться відрахування - це різниця суми доходу та суми відрахувань "першого кроку"

        --Розраховуємо повну суму відрахування (без урахування будь-яких обмежень) для типів розрахунку "% доходу" та "частка доходу"
        --Пишему в таблицю, з якої виконуватиметься розподіл боргів - це визначена сума боргу, яка повинна або знятись/виплатитись в поточному розрахунковому місяці або перенестись на наступні періоди
        INSERT INTO tmp_ac_dn_src (s_pc,
                                   s_pa,
                                   s_op,
                                   s_npt,
                                   s_start_dt,
                                   s_stop_dt,
                                   s_sum,
                                   s_dn,
                                   s_pd,
                                   s_full_sum,
                                   s_limit_ndn,
                                   s_limit_debt,
                                   s_debt_sum,
                                   s_stage,
                                   s_ndn_order,
                                   s_ndn,
                                   s_d_id,
                                   s_nst,
                                   s_sum_tp)
            SELECT x_id      AS q_pc,
                   q_pa,
                   123       AS q_op,
                   q_npt,
                   q_start_dt,
                   q_stop_dt,
                   ROUND (
                         GREATEST (q_month_sum, NVL (q_nl_month_sum, 0))
                       * q_part_of_month
                       * d_can_use_koef,
                       2)    AS q_dn_sum,
                   q_dn,
                   q_pd,
                   NULL,
                   q_limit_ndn,
                   q_limit_debt,
                   NULL,
                   '2',
                   d_ndn_order,
                   d_ndn,
                   d_id,
                   d_nst,
                   'CURRM'
              FROM tmp_wac_ids,
                   uss_ndi.v_ndi_months,
                   (SELECT tai_pc                  AS q_pc,
                           tai_pa                  AS q_pa,
                           tai_pd                  AS q_pd,
                           d_dn                    AS q_dn,
                           tai_npt                 AS q_npt,
                           td_begin                AS q_start_dt,
                           td_end                  AS q_stop_dt,
                           CASE d_tp
                               WHEN 'PD'
                               THEN
                                   ROUND (
                                         (tai_sum - tai_dn_f_step)
                                       * d_value
                                       / 100,
                                       2)
                               WHEN 'SD'
                               THEN
                                   ROUND (
                                         (tai_sum - tai_dn_f_step)
                                       * d_value
                                       / d_value_prefix,
                                       2)
                               ELSE
                                   0
                           END                     AS q_month_sum,
                           CASE d_nl_tp
                               WHEN 'PD'
                               THEN
                                   ROUND (
                                         (tai_sum - tai_dn_f_step)
                                       * d_nl_value
                                       / 100,
                                       2)
                               WHEN 'SD'
                               THEN
                                   ROUND (
                                         (tai_sum - tai_dn_f_step)
                                       * d_nl_value
                                       / d_nl_value_prefix,
                                       2)
                               WHEN 'AS'
                               THEN
                                   d_nl_value
                               WHEN 'PL'
                               THEN
                                   ROUND (
                                         API$ACCRUAL.get_lgw_cmn (
                                             2,
                                             TRUNC (d_start_dt, 'MM'),
                                             d_birth_dt)
                                       * d_nl_value
                                       / 100,
                                       2)
                               ELSE
                                   0
                           END                     AS q_nl_month_sum,
                             ROUND (  (tai_sum - tai_dn_f_step)
                                    * TOOLS.p_o_p (tai_start_dt,
                                                   tai_stop_dt,
                                                   td_begin,
                                                   td_end),
                                    2)
                           * d_max_prc
                           / 100                   AS q_limit_ndn,
                             ROUND (  (tai_sum - tai_dn_f_step)
                                    * TOOLS.p_o_p (tai_start_dt,
                                                   tai_stop_dt,
                                                   td_begin,
                                                   td_end),
                                    2)
                           * d_debt_limit_prc
                           / 100                   AS q_limit_debt,
                           tmp_ac_income.*,
                           d_tp,
                           TOOLS.p_o_p (tai_start_dt,
                                        tai_stop_dt,
                                        td_begin,
                                        td_end)    AS q_part_of_month,
                           d_ndn_order,
                           d_ndn,
                           d_id,
                           d_nst,
                           NVL (
                               CASE
                                   WHEN 0 <
                                        (SELECT COUNT (*)
                                           FROM uss_ndi.v_ndi_nst_dn_exclude
                                          WHERE nnde_nnnc = nnnc_id) --Якщо в таблиці виключеннь є записи, рахуємо по кожній проводці - яку саме частку суми виключаемо
                                   THEN
                                       api$accrual_test.get_exclude_sum_by_pd (
                                           tai_pd,
                                           tai_npt,
                                           nnnc_id,
                                           tai_start_dt)
                                   ELSE
                                       1 --Якщо в таблиці виключеннь немає відповідних записів - значить 100%
                               END,
                               1)                  AS d_can_use_koef
                      FROM tmp_ac_income,
                           tmp_ac_dn_params,
                           uss_ndi.v_ndi_nst_dn_config,
                           tmp_dn_dates
                     WHERE     tai_pc = d_pc
                           AND tai_pa = d_pa
                           AND tai_nst = nnnc_nst
                           AND d_ndn = nnnc_ndn
                           AND d_tp IN ('PD', 'SD')
                           AND tai_start_dt <= d_stop_dt
                           AND tai_stop_dt >= d_start_dt
                           AND td_pc = tai_pc
                           AND td_pc = d_pc
                           AND td_pa = tai_pa
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM uss_ndi.v_ndi_nst_dn_exclude
                                     WHERE     nnde_nnnc = nnnc_id
                                           AND tai_npt = nnde_npt)
                           AND td_begin BETWEEN d_start_dt AND d_stop_dt
                           AND td_begin BETWEEN tai_start_dt AND tai_stop_dt
                           AND d_value > 0
                           AND d_calc_step = 'S'
                           AND d_dn_tp = 'D')
             WHERE     x_id = q_pc
                   AND nm_start_dt BETWEEN x_start_dt AND x_stop_dt
                   AND q_start_dt BETWEEN nm_start_dt AND nm_stop_dt;

        --Розраховуємо повну суму відрахування (без урахування будь-яких обмежень) для типів розрахунку "Абсолютна сума" та "Відсоток прожиткового мінімуму"
        --Пишему в таблицю, з якої виконуватиметься розподіл боргів - це визначена сума боргу, яка повинна або знятись/виплатитись в поточному розрахунковому місяці або перенестись на наступні періоди
        INSERT INTO tmp_ac_dn_src (s_pc,
                                   s_pa,
                                   s_op,
                                   s_npt,
                                   s_start_dt,
                                   s_stop_dt,
                                   s_sum,
                                   s_dn,
                                   s_pd,
                                   s_full_sum,
                                   s_limit_ndn,
                                   s_limit_debt,
                                   s_debt_sum,
                                   s_stage,
                                   s_ndn_order,
                                   s_ndn,
                                   s_d_id,
                                   s_nst,
                                   s_sum_tp)
            SELECT x_id,
                   q_pa,
                   123,
                   q_npt,
                   q_start_dt,
                   q_stop_dt,
                   ROUND (
                       GREATEST (q_sum, NVL (q_nl_sum, 0)) * d_part_of_month,
                       2)    AS a_sum,
                   q_dn,
                   q_pd,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   '3',
                   d_ndn_order,
                   d_ndn,
                   d_id,
                   d_nst,
                   'CURRM'
              FROM tmp_wac_ids,
                   uss_ndi.v_ndi_months,
                   (SELECT x_id
                               AS q_pc,
                           d_pa
                               AS q_pa,
                           NULL
                               AS q_pd,
                           d_dn
                               AS q_dn,
                           NULL
                               AS q_npt,
                           d_start_dt
                               AS q_start_dt,
                           d_stop_dt
                               AS q_stop_dt,
                           CASE d_tp
                               WHEN 'AS'
                               THEN
                                   d_value
                               WHEN 'PL'
                               THEN
                                   ROUND (
                                         API$ACCRUAL_TEST.get_lgw_cmn (
                                             2,
                                             TRUNC (d_start_dt, 'MM'),
                                             d_birth_dt)
                                       * d_value
                                       / 100,
                                       2)
                               --THEN ROUND(API$ACCRUAL_TEST.get_lgw_cmn(TRUNC(d_start_dt, 'MM')) * d_value/100, 2)
                               ELSE
                                   0
                           END
                               AS q_sum,
                           (SELECT SUM (
                                       CASE d_nl_tp
                                           WHEN 'PD'
                                           THEN
                                               ROUND (
                                                     (tai_sum - tai_dn_f_step)
                                                   * d_nl_value
                                                   / 100,
                                                   2)
                                           WHEN 'SD'
                                           THEN
                                               ROUND (
                                                     (tai_sum - tai_dn_f_step)
                                                   * d_nl_value
                                                   / d_nl_value_prefix,
                                                   2)
                                           WHEN 'AS'
                                           THEN
                                               d_nl_value
                                           WHEN 'PL'
                                           THEN
                                               ROUND (
                                                     API$ACCRUAL_TEST.get_lgw_cmn (
                                                         2,
                                                         TRUNC (d_start_dt,
                                                                'MM'),
                                                         d_birth_dt)
                                                   * d_nl_value
                                                   / 100,
                                                   2)
                                           ELSE
                                               0
                                       END)
                              FROM tmp_ac_income, uss_ndi.v_ndi_nst_dn_config
                             WHERE     tai_pc = d_pc
                                   AND tai_pa = d_pa
                                   AND tai_nst = nnnc_nst
                                   AND d_ndn = nnnc_ndn
                                   AND tai_start_dt <= d_stop_dt
                                   AND tai_stop_dt >= d_start_dt)
                               AS q_nl_sum,
                           d_tp,
                           d_part_of_month,
                           d_ndn_order,
                           d_ndn,
                           d_id,
                           d_nst
                      FROM tmp_wac_ids, tmp_ac_dn_params
                     WHERE     x_id = d_pc
                           AND d_tp IN ('AS', 'PL')
                           AND x_start_dt <= d_stop_dt
                           AND x_stop_dt >= d_start_dt
                           AND d_value > 0
                           AND d_calc_step = 'S'
                           AND d_dn_tp = 'D')
             WHERE     x_id = q_pc
                   AND q_start_dt BETWEEN nm_start_dt AND nm_stop_dt
                   AND nm_start_dt BETWEEN x_start_dt AND x_stop_dt;
    END;

    --Розрахунок нарахувань
    PROCEDURE calc_accrual (p_in_mode         INTEGER,
                            p_calc_mode       INTEGER, --1 - індивідуальний розрахунок з інтерфейсу, 2 - масовий розрахунок з шедулера, 3 - попреденій розрахунок з врахуванням незавершеного рішення
                            p_pc_id           personalcase.pc_id%TYPE,
                            p_month           DATE := SYSDATE,
                            p_messages    OUT SYS_REFCURSOR)
    IS
        l_cnt          INTEGER;
        l_cnt1         INTEGER;
        l_id           accrual.ac_id%TYPE;
        l_month_name   VARCHAR2 (100);
        l_hs           histsession.hs_id%TYPE;
        l_org          accrual.com_org%TYPE;
        l_msg          VARCHAR2 (4000);
    BEGIN
        clean_temp_tables;

        l_org := TOOLS.GetCurrOrg;
        init_access_params;
        CALC$PAYROLL.init_com_orgs (NULL);
        authcheck ('calc_accrual');

        --SELECT COUNT(*) INTO l_cnt1 FROM tmp_work_ids;
        --calc_write_message(p_calc_mode, 'Отримано '||l_cnt1||' справ.', 'I', g_messages);

        g_messages := TOOLS.t_messages ();

        IF p_in_mode = 1 AND p_pc_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT DISTINCT pc_id
                  FROM personalcase pc, pc_decision pd, tmp_com_orgs
                 WHERE     pc_id = p_pc_id
                       AND pd_pc = pc_id
                       AND (   (g_pa_mode_calc = 0 AND pc.com_org = x_id)
                            OR (g_pa_mode_calc = 1 AND pd.com_org = x_id));

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (DISTINCT pc_id)
              INTO l_cnt
              FROM tmp_work_ids  tpc,
                   personalcase  pc,
                   pc_decision   pd,
                   tmp_com_orgs  orgs
             WHERE     tpc.x_id = pc_id
                   AND pd_pc = pc_id
                   AND (   (g_pa_mode_calc = 0 AND pc.com_org = orgs.x_id)
                        OR (g_pa_mode_calc = 1 AND pd.com_org = orgs.x_id));
        END IF;

        --SELECT COUNT(*) INTO l_cnt1 FROM tmp_com_orgs;
        --calc_write_message(p_calc_mode, 'Районів: '||l_cnt1, 'I', g_messages);

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування нарахувань не передано ні однієї ЕОС!');
        END IF;

        IF l_org IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не можу визначити організацію користувача, що запустив розрахунок!');
        END IF;

        IF g_pa_mode_calc = 1
        THEN
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_pa_ids
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_com_orgs, pc_decision
                         WHERE pd_pa = x_pa AND com_org = x_id);

            IF l_cnt = 0
            THEN
                raise_application_error (
                    -20000,
                    'В функцію формування нарахувань в режимі "по особовим рахункам" не передано ні одного особового рахунку з рішеннями!');
            END IF;
        END IF;

        calc_write_message (p_calc_mode,
                            'Починаю розрахунок!',
                            'I',
                            g_messages);
        --TOOLS.add_message(g_messages, 'I', 'Починаю розрахунок!');

        get_month (p_month, g_ac_month, g_max_calc_month);
        diag_msg ('g_ac_month=' || g_ac_month);

        --Визначаємо параметри початку розрахунку нарахувань по кожній справі (за чергою обрахунку нарахувань)
        INSERT INTO tmp_pc_accrual_queue (q_id,
                                          q_pc,
                                          q_tp,
                                          q_start_dt,
                                          q_stop_dt,
                                          q_pd,
                                          q_dn,
                                          q_st)
            SELECT paq_id,
                   paq_pc,
                   paq_tp,
                   paq_start_dt,
                   paq_stop_dt,
                   paq_pd,
                   paq_dn,
                   paq_st
              FROM tmp_work_ids, pc_accrual_queue
             WHERE x_id = paq_pc AND paq_st = 'W';

        IF p_calc_mode = 3
        THEN
            INSERT INTO tmp_pc_accrual_queue (q_id,
                                              q_pc,
                                              q_tp,
                                              q_start_dt,
                                              q_stop_dt,
                                              q_pd,
                                              q_dn,
                                              q_st)
                SELECT 0,
                       pd_pc,
                       CASE pd_src
                           WHEN 'FS' THEN 'PD'
                           WHEN 'PV' THEN 'PD'
                           WHEN 'SA' THEN 'PS'
                       END,
                       pd_start_dt,
                       pd_stop_dt,
                       pd_id,
                       NULL,
                       'W'
                  FROM tmp_work_set1, pc_decision
                 WHERE x_id1 = pd_id;
        END IF;

        --Перерахунок виконується з: найбільша дата з (найменша дата черги на перерахунок, дата початку перерахунків в залежності від ВПО/послуги)
        INSERT INTO tmp_wac_ids (x_id,
                                 x_calc_mode,
                                 x_start_dt,
                                 x_stop_dt,
                                 x_ac_start_dt,
                                 x_ac_stop_dt)
            SELECT x_id,
                   p_calc_mode,
                   GREATEST (
                       TRUNC (NVL ( (SELECT MIN (q_start_dt)
                                       FROM tmp_pc_accrual_queue
                                      WHERE q_pc = x_id AND q_st = 'W'),
                                   g_ac_month),
                              'MM'),
                       DECODE (g_bp_class,
                               'V', TO_DATE ('01.09.2022', 'DD.MM.YYYY'),
                               TO_DATE ('01.03.2022', 'DD.MM.YYYY'))),
                   LAST_DAY (g_max_calc_month),
                   g_ac_month,
                   LAST_DAY (g_ac_month)
              FROM tmp_work_ids
             WHERE (   p_calc_mode = 3 --для попереднього розрахунку - можна будь-яку справу брати
                    OR (    p_calc_mode IN (1, 2) --для індивідуального/масового - беруться тільки ті справи, по яких немає нарахувань в станах "передано на візування" "завізовано".
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM accrual
                                  WHERE     ac_pc = x_id
                                        AND ac_month = g_ac_month
                                        AND ac_st IN
                                                ('W',
                                                 'R',
                                                 DECODE (g_bp_class,
                                                         'V', 'RV',
                                                         'RP')))));

        IF SQL%ROWCOUNT = 0
        THEN
            calc_write_message (
                p_calc_mode,
                'Множина справ для розрахунку - порожня (нарахування поточного місяця в стані Підтверджено або не надано множину для розрахунку!',
                'E',
                g_messages);

            OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);

            set_calc_mode (1); --Встановлюємо (відновлюємо) режим розрахунку - по вхідній множині особових рахунків.

            RETURN;
        END IF;

        ---(обмежити нижню границю перерахунку по справі з відрахуваннями найбільшою датою з 2 дат:
        ---1. найменша дата по черзі перерахунку
        ---2. найбільша дата по параметрам Впорядкування даних АСОПД + 1 місяць для справ з помилками відповідності нарахованого та призначеного або діблікатами періодів
        UPDATE uss_esr.tmp_wac_ids
           SET x_start_dt =
                   GREATEST (x_start_dt,
                             NVL ( (SELECT ADD_MONTHS (MAX (pco_month), 1)
                                      FROM uss_esr.pc_data_ordering
                                     WHERE pco_pc = x_id AND pco_st = 'N'),
                                  x_start_dt))
         WHERE EXISTS
                   (SELECT 1
                      FROM uss_esr.pc_data_ordering
                     WHERE pco_pc = x_id AND pco_st = 'N');

        IF p_calc_mode IN (1, 2)
        THEN
            SELECT COUNT (*), MAX (ac_id)
              INTO l_cnt, l_id
              FROM accrual, tmp_wac_ids
             WHERE     ac_pc = x_id
                   AND ac_st NOT IN
                           ('E', DECODE (g_bp_class, 'V', 'RP', 'RV'))
                   AND ac_month = g_ac_month;

            IF l_cnt > 0
            THEN
                SELECT dic_name
                  INTO l_month_name
                  FROM uss_ndi.v_ddn_month_names
                 WHERE dic_value = TO_CHAR (g_ac_month, 'MM');

                raise_application_error (
                    -20000,
                       'Розраховувати справу, по якій є нарахування не в стані "Редагується" на '
                    || l_month_name
                    || ' '
                    || TO_CHAR (g_ac_month, 'YYYY')
                    || ' - не можна!'
                    || l_id
                    || '>>');
            END IF;
        END IF;

        --Отримуємо періоди розрахунку нарахувань
        get_accrual_periods (p_calc_mode);

        --Отримуємо перелік послуг для розрахунку нарахувань
        init_nst_list (p_calc_mode);

        IF p_calc_mode IN (1, 2)
        THEN
            /*    --Видаляємо протоколи нарахування за період нарахування
                DELETE
                  FROM ac_log
                  WHERE EXISTS (SELECT 1
                                FROM accrual, tmp_wac_ids
                                WHERE acl_ac = ac_id
                                  AND ac_pc = x_id
                                  AND ac_st = 'E');*/

            --Знаходимо всі деталі нарахувань, які будуть видалені
            INSERT INTO tmp_ac_to_del (x_acd, x_ac, x_dn)
                SELECT acd_id, acd_ac, acd_dn
                  FROM ac_detail
                 WHERE     acd_op IN (1,
                                      2,
                                      3,
                                      5,
                                      40,
                                      123,
                                      124,
                                      6)
                       AND history_status = 'A'
                       AND acd_prsd IS NULL
                       AND acd_imp_pr_num IS NULL
                       AND acd_st IN ('E', 'U')
                       AND EXISTS
                               (SELECT 1
                                  FROM accrual, tmp_wac_ids
                                 WHERE     acd_ac = ac_id
                                       AND ac_pc = x_id
                                       AND ac_st IN
                                               ('E',
                                                DECODE (g_bp_class,
                                                        'V', 'RP',
                                                        'RV'))
                                       AND ac_month = g_ac_month)
                       AND (   EXISTS
                                   (SELECT 1
                                      FROM uss_ndi.v_ndi_npt_config,
                                           tmp_ac_nst_list
                                     WHERE     nptc_nst = x_nst
                                           AND nptc_npt = acd_npt)
                            OR acd_npt IS NULL)
                       AND (   g_pa_mode_calc = 0
                            OR (    g_pa_mode_calc = 1
                                AND EXISTS
                                        (SELECT 1
                                           FROM pc_decision, tmp_work_pa_ids
                                          WHERE     pd_pa = x_pa
                                                AND acd_pd = pd_id)));

            --Відновлюємо суму поточного боргу відрахувань з рядків операцій 123/124, які видаляємо
            UPDATE deduction
               SET dn_debt_current =
                         dn_debt_current
                       + NVL (
                             (SELECT SUM (acd_sum)
                                FROM ac_detail, tmp_ac_to_del
                               WHERE     acd_dn = dn_id
                                     AND acd_id = x_acd
                                     AND acd_op IN
                                             (124,
                                              CASE
                                                  WHEN dn_tp = 'D' THEN 124
                                                  ELSE 123
                                              END)),
                             0)
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_ac_to_del
                             WHERE x_dn = dn_id)
                   AND dn_tp IN ('R', 'HM');

            --Оновлюємо поле "поточний борг" у відрахуванні на основі нерознесених залишків по ід-у операції 5
            UPDATE deduction
               SET dn_debt_current =
                       (SELECT SUM (acd_sum)
                          FROM ac_detail, tmp_ac_to_del
                         WHERE     acd_dn = dn_id
                               AND acd_id = x_acd
                               AND acd_op = 5
                               AND acd_dn = dn_id
                               AND acd_npt IS NULL --суми з npt - це новоотримані суми по боргу, а сума без npt - це сума боргу до початку розрахунку, з 40 коду.
                               AND acd_start_dt =
                                   (SELECT MAX (s.acd_start_dt)
                                      FROM ac_detail s, tmp_ac_to_del sd
                                     WHERE     s.acd_dn = dn_id
                                           AND s.acd_id = sd.x_acd
                                           AND s.acd_op = 5
                                           AND s.acd_dn = dn_id))
             WHERE     EXISTS
                           (SELECT 1
                              FROM ac_detail, tmp_ac_to_del ad
                             WHERE     acd_id = x_acd
                                   AND acd_op = 5
                                   AND acd_dn = dn_id)
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_ac_to_del
                             WHERE x_dn = dn_id)
                   AND dn_tp = 'D';

            UPDATE deduction
               SET dn_st = 'R'
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_ac_to_del
                             WHERE x_dn = dn_id)
                   AND dn_debt_current > 0
                   /*AND dn_tp = 'R'*/
                   AND dn_st = 'Z';

            --Готуємо множину для оновленя accrual - ДО видалення рядків проводок. Саме оновлення - після видалення рядків.
            DELETE FROM tmp_work_ids1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids1 (x_id)
                SELECT DISTINCT acd_ac
                  FROM ac_detail
                 WHERE     history_status = 'A'
                       AND EXISTS
                               (SELECT 1
                                  FROM tmp_ac_to_del
                                 WHERE acd_id = x_acd);

            --Видаляємо всі деталі нарахування за період нарахування
            DELETE FROM ac_detail
                  WHERE     history_status = 'A'
                        AND EXISTS
                                (SELECT 1
                                   FROM tmp_ac_to_del
                                  WHERE acd_id = x_acd);

            actuilize_payed_sum (1);

            --Видаляємо створені в поточному періоді відрахування по переплатам, якщо видаляються рядки, по яким вони створені
            DELETE FROM dn_log
                  WHERE EXISTS
                            (SELECT 1
                               FROM tmp_ac_to_del, deduction
                              WHERE     dnl_dn = x_dn
                                    AND x_dn = dn_id
                                    AND dn_st IN ('E', 'W'));

            DELETE FROM dn_detail
                  WHERE     EXISTS
                                (SELECT 1
                                   FROM tmp_ac_to_del, deduction
                                  WHERE     dnd_dn = x_dn
                                        AND x_dn = dn_id
                                        AND dn_st IN ('E', 'W'))
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM ac_detail
                                  WHERE acd_dn = dnd_dn);

            DELETE FROM deduction
                  WHERE     dn_st IN ('E', 'W')
                        AND EXISTS
                                (SELECT 1
                                   FROM tmp_ac_to_del
                                  WHERE dn_id = x_dn)
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM ac_detail
                                  WHERE acd_dn = dn_id);
        /*--Видаляємо всі нарахування за період нарахування
        DELETE
          FROM accrual
          WHERE ac_st = 'E'
            AND EXISTS (SELECT 1
                        FROM tmp_wac_ids
                        WHERE ac_pc = x_id);*/
        END IF;

        --Формуємо деталі нарахування
        --З даних рішень на призначення допомоги (беремо рішення в статусі "Нараховано") - операція "нарахування"
        INSERT INTO tmp_ac_detail (a_pc,
                                   a_pa,
                                   a_op,
                                   a_npt,
                                   a_start_dt,
                                   a_stop_dt,
                                   a_sum,
                                   a_month_sum,
                                   a_delta_recalc,
                                   a_delta_pay,
                                   a_dn,
                                   a_pd,
                                   a_ac_start_dt,
                                   a_ac_stop_dt,
                                   a_stage,
                                   a_nst)
            SELECT q_pc,
                   q_pa,
                   1,
                   q_npt,
                   q_start_dt,
                   q_stop_dt,
                   ROUND (
                         q_sum
                       * TOOLS.part_of_month (q_month, q_start_dt, q_stop_dt),
                       2)    AS a_sum,
                   q_sum,
                   ROUND (
                         q_sum
                       * TOOLS.part_of_month (q_month, q_start_dt, q_stop_dt),
                       2)    AS a_delta_recalc,
                   NULL,
                   NULL,
                   q_pd,
                   q_ac_start_dt,
                   q_ac_stop_dt,
                   '1',
                   q_nst
              FROM (SELECT pd_pc            AS q_pc,
                           pd_id            AS q_pd,
                           pd_pa            AS q_pa,
                           pdp_npt          AS q_npt,
                           nm_month         AS q_month,
                           CASE
                               WHEN TRUNC (
                                        CASE
                                            WHEN pdp_start_dt < d_start_dt
                                            THEN
                                                d_start_dt
                                            ELSE
                                                pdp_start_dt
                                        END) BETWEEN nm_start_dt
                                                 AND nm_stop_dt
                               THEN
                                   TRUNC (
                                       CASE
                                           WHEN pdp_start_dt < d_start_dt
                                           THEN
                                               d_start_dt
                                           ELSE
                                               pdp_start_dt
                                       END)
                               ELSE
                                   nm_start_dt
                           END              AS q_start_dt,
                           CASE
                               WHEN TRUNC (
                                        CASE
                                            WHEN pdp_stop_dt > d_stop_dt
                                            THEN
                                                d_stop_dt
                                            ELSE
                                                pdp_stop_dt
                                        END) BETWEEN nm_start_dt
                                                 AND nm_stop_dt
                               THEN
                                   TRUNC (
                                       CASE
                                           WHEN pdp_stop_dt > d_stop_dt
                                           THEN
                                               d_stop_dt
                                           ELSE
                                               pdp_stop_dt
                                       END)
                               ELSE
                                   nm_stop_dt
                           END              AS q_stop_dt,
                           pdp_sum          AS q_sum,
                           x_start_dt,
                           x_stop_dt,
                           x_ac_start_dt    AS q_ac_start_dt,
                           x_ac_stop_dt     AS q_ac_stop_dt,
                           pd_nst           AS q_nst
                      FROM tmp_wac_ids,
                           pc_decision,
                           pd_payment             pdp,
                           uss_ndi.v_ndi_months,
                           tmp_pd_accrual_period  pdap,
                           tmp_ac_nst_list
                     WHERE     pd_pc = x_id
                           AND pdp_pd = pd_id
                           AND d_pd = pd_id
                           AND nm_start_dt BETWEEN x_start_dt AND x_stop_dt
                           AND x_start_dt <= pdp_stop_dt
                           AND x_stop_dt >= pdp_start_dt
                           AND nm_start_dt <= pdp_stop_dt
                           AND nm_stop_dt >= pdp_start_dt
                           AND nm_start_dt <= d_stop_dt
                           AND nm_stop_dt >= d_start_dt
                           AND x_start_dt <= NVL (d_stop_dt, SYSDATE + 10000)
                           AND x_stop_dt >= d_start_dt
                           AND pd_nst = x_nst
                           AND pdp.history_status = 'A'
                           AND (   g_pa_mode_calc = 0
                                OR (    g_pa_mode_calc = 1
                                    AND EXISTS
                                            (SELECT 1
                                               FROM tmp_work_pa_ids
                                              WHERE pd_pa = x_pa))))
             WHERE q_sum <> 0;

        diag_msg (
            'Знаходимо точки розриву розрахованих та збережених нарахувань');

        INSERT INTO tmp_ac_dates1 (tad_pc,
                                   tad_pa,
                                   tad_npt,
                                   tad_dt)
            SELECT a_pc,
                   a_pa,
                   a_npt,
                   DECODE (x_row, 1, a_start_dt, a_stop_dt + 1)
              FROM tmp_ac_detail,
                   (    SELECT LEVEL     AS x_row
                          FROM DUAL
                    CONNECT BY LEVEL < 3)
             WHERE a_op IN (1)
            UNION ALL
            SELECT x_id,
                   pd_pa,
                   acd_npt,
                   DECODE (x_row, 1, acd_start_dt, acd_stop_dt + 1)
              FROM ac_detail,
                   accrual,
                   tmp_wac_ids,
                   pc_decision,
                   tmp_ac_nst_list,
                   uss_ndi.v_ndi_npt_config,
                   uss_ndi.v_ndi_op,
                   (    SELECT LEVEL     AS x_row
                          FROM DUAL
                    CONNECT BY LEVEL < 3)
             WHERE     acd_ac = ac_id
                   AND ac_pc = x_id
                   AND acd_start_dt BETWEEN x_start_dt AND x_stop_dt
                   AND acd_op = op_id
                   AND (acd_op IN (1, 2, 3) OR op_tp1 IN ('NR')) --всі наявні нарахування в ac_detail
                   AND acd_op = op_id
                   AND acd_npt = nptc_npt
                   AND nptc_nst = x_nst
                   AND ac_detail.history_status = 'A'
                   AND acd_pd = pd_id
                   AND (   g_pa_mode_calc = 0
                        OR (    g_pa_mode_calc = 1
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_pa_ids
                                      WHERE pd_pa = x_pa)));

        diag_msg ('Знаходимо унікальний набр дат розривів');

        INSERT INTO tmp_ac_dates (td_pc,
                                  td_pa,
                                  td_npt,
                                  td_begin)
            SELECT DISTINCT tad_pc,
                            tad_pa,
                            tad_npt,
                            tad_dt
              FROM tmp_ac_dates1;

        diag_msg ('Проставляємо кінці періодів');

        UPDATE /*+full(ma1)*/
               tmp_ac_dates ma1
           SET td_end =
                   (SELECT /*+index(sl I_ttd_set1)*/
                           MIN (td_begin) - 1
                      FROM tmp_ac_dates sl
                     WHERE     sl.td_pc = ma1.td_pc
                           AND sl.td_pa = ma1.td_pa
                           AND sl.td_npt = ma1.td_npt
                           AND sl.td_begin > ma1.td_begin)
         WHERE 1 = 1;

        diag_msg ('Видаляємо зайві записи періодів');

        DELETE FROM tmp_ac_dates
              WHERE td_end IS NULL;

        --Обраховуємо суми нарахувань: новонарахованих, раніше записаних в ac_detail, раніше виплачених. Для формування дельт та нових сум нарахувань
        INSERT INTO uss_esr.tmp_ac_diff (a2_pc,
                                         a2_pa,
                                         a2_npt,
                                         a2_start_dt,
                                         a2_stop_dt,
                                         a2_pd,
                                         a2_new_calc_sum,
                                         a2_old_saved_sum,
                                         a2_old_payed_sum,
                                         a2_dn_fixed_sum,
                                         a2_is_early_calc)
              SELECT c_pc,
                     c_pa,
                     c_npt,
                     c_start_dt,
                     c_stop_dt,
                     MAX (c_pd),
                     SUM (DECODE (c_tp, 0, c_sum, 0))
                         AS a2_new_calc_sum,
                     SUM (DECODE (c_tp, 1, c_sum, 0))
                         AS a2_old_saved_sum,
                     SUM (DECODE (c_tp, 1, c_payed_sum, 0))
                         a2_old_payed_sum,
                     SUM (DECODE (c_tp, 1, c_dn_fixed_sum, 0))
                         a2_dn_fixed_sum,
                     CASE WHEN SUM (c_tp) > 0 THEN 'T' ELSE 'F' END
                         a2_is_early_calc
                FROM (  SELECT a_pc
                                   AS c_pc,
                               a_pa
                                   AS c_pa,
                               a_npt
                                   AS c_npt,
                               td_begin
                                   AS c_start_dt,
                               td_end
                                   AS c_stop_dt,
                               MAX (a_pd)
                                   AS c_pd,
                               SUM (  uss_esr.API$ACCRUAL_TEST.xsign (a_op)
                                    * a_sum
                                    * uss_esr.TOOLS.p_o_p (a_start_dt,
                                                           a_stop_dt,
                                                           td_begin,
                                                           td_end))
                                   AS c_sum,
                               0.00
                                   AS c_payed_sum,
                               0.00
                                   AS c_dn_fixed_sum,
                               0
                                   AS c_tp
                          FROM uss_esr.tmp_ac_detail, uss_esr.tmp_ac_dates
                         WHERE     a_op IN (1)    --первинні повні нарахування
                               AND a_pc = td_pc
                               AND td_begin BETWEEN a_start_dt AND a_stop_dt
                               AND a_npt = td_npt
                               AND a_pa = td_pa
                      GROUP BY a_pc,
                               a_pa,
                               a_npt,
                               td_begin,
                               td_end
                      UNION ALL
                        SELECT x_id         AS a_pc,
                               pd_pa        AS c_pa,
                               acd_npt,
                               td_begin,
                               td_end,
                               MAX (acd_pd),
                               SUM (
                                   CASE
                                       WHEN acd_op = 6
                                       THEN
                                           0
                                       ELSE
                                             uss_esr.API$ACCRUAL_TEST.xsign (
                                                 acd_op)
                                           * acd_sum
                                           * uss_esr.TOOLS.p_o_p (acd_start_dt,
                                                                  acd_stop_dt,
                                                                  td_begin,
                                                                  td_end)
                                   END)     AS c_sum,
                               SUM (
                                   CASE
                                       WHEN    acd_prsd IS NOT NULL
                                            OR ACD_IMP_PR_NUM IS NOT NULL
                                       THEN
                                             uss_esr.API$ACCRUAL_TEST.xsign (
                                                 acd_op)
                                           * acd_sum
                                           * uss_esr.TOOLS.p_o_p (acd_start_dt,
                                                                  acd_stop_dt,
                                                                  td_begin,
                                                                  td_end)
                                       ELSE
                                           0
                                   END)     AS c_payed_sum,
                               SUM (CASE
                                        WHEN acd_op = 6
                                        THEN
                                              acd_sum
                                            * uss_esr.TOOLS.p_o_p (acd_start_dt,
                                                                   acd_stop_dt,
                                                                   td_begin,
                                                                   td_end)
                                        ELSE
                                            0
                                    END)    AS c_dn_fixed_sum,
                               1            AS c_tp
                          FROM uss_esr.ac_detail,
                               uss_esr.accrual,
                               uss_esr.tmp_wac_ids,
                               uss_esr.tmp_ac_nst_list,
                               uss_ndi.v_ndi_npt_config,
                               uss_ndi.v_ndi_op,
                               uss_esr.tmp_ac_dates,
                               pc_decision
                         WHERE     acd_ac = ac_id
                               AND ac_pc = x_id
                               AND acd_start_dt BETWEEN x_start_dt AND x_stop_dt
                               AND acd_op = op_id
                               AND (   acd_op IN (1,
                                                  2,
                                                  3,
                                                  6)
                                    OR op_tp1 IN ('NR')) --всі наявні нарахування в ac_detail
                               AND acd_op = op_id
                               AND acd_npt = nptc_npt
                               AND nptc_nst = x_nst
                               AND ac_detail.history_status = 'A'
                               AND ac_pc = td_pc
                               AND td_begin BETWEEN acd_start_dt AND acd_stop_dt
                               AND acd_npt = td_npt
                               AND acd_pd = pd_id
                               AND td_pa = pd_pa
                               AND (   g_pa_mode_calc = 0
                                    OR (    g_pa_mode_calc = 1
                                        AND EXISTS
                                                (SELECT 1
                                                   FROM tmp_work_pa_ids
                                                  WHERE pd_pa = x_pa)))
                      GROUP BY x_id,
                               pd_pa,
                               acd_npt,
                               td_begin,
                               td_end)
            GROUP BY c_pc,
                     c_pa,
                     c_npt,
                     c_start_dt,
                     c_stop_dt;

        --return;
        --Визначаємо записи первинних повних нарахувань, які підуть у ac_detail без змін (перший розрахунок) - це записи, по яким в періоді не було ніяких записів раніше
        UPDATE tmp_ac_detail
           SET a_need_write_2_base = 'T'
         WHERE    EXISTS
                      (SELECT 1
                         FROM tmp_ac_diff
                        WHERE     a_pc = a2_pc
                              AND a_pa = a2_pa
                              AND a_npt = a2_npt
                              AND a_start_dt BETWEEN a2_start_dt
                                                 AND a2_stop_dt
                              AND a2_is_early_calc = 'F')
               OR p_calc_mode = 3;

          --Формуємо записи донарахування, якщо сума раніше розрахованого - менша за знов розраховану суму
          --І записи відрахування переплат, якщо сума раніше розрахованого - більша за знов розраховану суму
          INSERT ALL
            WHEN a2_dn_sum > 0
            THEN          --Пишему суми, які треба перетворити на відрахування
                INTO tmp_ac_detail (a_pc,
                                    a_pa,
                                    a_op,
                                    a_npt,
                                    a_start_dt,
                                    a_stop_dt,
                                    a_sum,
                                    a_delta_recalc,
                                    a_pd,
                                    a_ac_start_dt,
                                    a_ac_stop_dt,
                                    a_stage,
                                    a_need_write_2_base,
                                    a_nst)
                  VALUES (a2_pc,
                          a2_pa,
                          6,
                          a2_npt,
                          a2_start_dt,
                          a2_stop_dt,
                          a2_dn_sum,
                          a2_dn_sum,
                          a2_pd,
                          x_ac_start_dt,
                          x_ac_stop_dt,
                          a2_stage,
                          a2_need_write_2_base,
                          pd_nst)
            WHEN a2_sum_corr_plus > 0
            THEN                                   --Пишемо коригування в плюс
                INTO tmp_ac_detail (a_pc,
                                    a_pa,
                                    a_op,
                                    a_npt,
                                    a_start_dt,
                                    a_stop_dt,
                                    a_sum,
                                    a_delta_recalc,
                                    a_pd,
                                    a_ac_start_dt,
                                    a_ac_stop_dt,
                                    a_stage,
                                    a_need_write_2_base,
                                    a_nst)
                  VALUES (a2_pc,
                          a2_pa,
                          2,
                          a2_npt,
                          a2_start_dt,
                          a2_stop_dt,
                          a2_sum_corr_plus,
                          a2_sum_corr_plus,
                          a2_pd,
                          x_ac_start_dt,
                          x_ac_stop_dt,
                          a2_stage,
                          a2_need_write_2_base,
                          pd_nst)
            WHEN a2_sum_corr_minus > 0
            THEN                                  --Пишемо коригування в мінус
                INTO tmp_ac_detail (a_pc,
                                    a_pa,
                                    a_op,
                                    a_npt,
                                    a_start_dt,
                                    a_stop_dt,
                                    a_sum,
                                    a_delta_recalc,
                                    a_pd,
                                    a_ac_start_dt,
                                    a_ac_stop_dt,
                                    a_stage,
                                    a_need_write_2_base,
                                    a_nst)
                  VALUES (a2_pc,
                          a2_pa,
                          3,
                          a2_npt,
                          a2_start_dt,
                          a2_stop_dt,
                          a2_sum_corr_minus,
                          a2_sum_corr_minus,
                          a2_pd,
                          x_ac_start_dt,
                          x_ac_stop_dt,
                          a2_stage,
                          a2_need_write_2_base,
                          pd_nst)
            SELECT a2_pc,
                   a2_pa,
                   a2_npt,
                   a2_start_dt,
                   a2_stop_dt,
                   pd_nst,
                   a2_pd,
                   x_ac_start_dt,
                   x_ac_stop_dt,
                   '1.1'    AS a2_stage,
                   'T'      AS a2_need_write_2_base, --a2_new_calc_sum, a2_old_saved_sum,
                   --Якщо сума знов нарахованого менше суми виплаченого - є сума відрахування
                   CASE
                       WHEN a2_new_calc_sum < a2_old_payed_sum
                       THEN
                           CASE
                               WHEN a2_old_payed_sum - a2_new_calc_sum >
                                    a2_dn_fixed_sum --Якщо новорозрахована сума відрахувань більша за вже зафіксовану суму відрахувань - то різниця є новим відрахуванням
                               THEN
                                     a2_old_payed_sum
                                   - a2_new_calc_sum
                                   - a2_dn_fixed_sum
                               ELSE
                                   0
                           END
                       ELSE
                           0
                   END      AS a2_dn_sum,
                   --Якщо сума знов нарахованого більше суми раніше нарахованого - є сума коригування в плюс
                   CASE
                       WHEN a2_new_calc_sum > a2_old_saved_sum
                       THEN
                           a2_new_calc_sum - a2_old_saved_sum
                       ELSE
                           0
                   END      AS a2_sum_corr_plus,
                   --Якщо сума знов нарахованого менше суми раніше нарахованого та більша суми раніше вилаченого - є сума коригування (різниця знов нарахованого і раніше сплаченого)
                   CASE
                       WHEN     a2_new_calc_sum < a2_old_saved_sum
                            AND a2_new_calc_sum >= a2_old_payed_sum
                       THEN
                           a2_old_saved_sum - a2_new_calc_sum
                       --Якщо сума знов нарахованого менше суми раніше нарахованого та менша суми раніше вилаченого - є сума коригування (різниця знов нарахованого і раніше сплаченого, зменшена на відрахування)
                       WHEN     a2_new_calc_sum < a2_old_saved_sum
                            AND a2_new_calc_sum < a2_old_payed_sum
                       THEN
                             a2_old_saved_sum
                           - a2_new_calc_sum
                           - (a2_old_payed_sum - a2_new_calc_sum)
                       ELSE
                           0
                   END      AS a2_sum_corr_minus
              FROM tmp_ac_diff, tmp_wac_ids, pc_decision
             WHERE     a2_pc = x_id
                   AND a2_pd = pd_id
                   AND a2_pa = pd_pa
                   AND NOT EXISTS
                           (SELECT 1 --Коригування ідуть тільки по тим періодам, по яким визначено, що немає ще записів в ac_detail на період.
                              FROM tmp_ac_detail
                             WHERE     a2_pc = a_pc
                                   AND a2_npt = a_npt
                                   AND a2_pa = a_pa
                                   AND a_start_dt BETWEEN a2_start_dt
                                                      AND a2_stop_dt
                                   AND a_op = 1
                                   AND a_need_write_2_base = 'T');

        --ikis_sysweb.ikis_debug_pipe.WriteMsg('tmp_ac_detail='||SQL%ROWCOUNT);

        --Розрахунок початкового боргу по відрахуванням та первинних сум відарахувань
        calc_dn;


        --!!! 1. видалити обрахунок відрахувань на держутримання за даними рішення - там "орієнтовний розрахунок"!
        --2. Реалізувати обрахунок всіх відрахувань з дотриманням умов "макс відсоток відрахування" тощо.
        --3. Реалізувати черговість застосування відрахувань, якщо воно таке є!

        --Розраховуємо суми боргу по відрахуванням з врахуванням всіх лімітів на відрахування
        calc_dn_debts;

        --Генеруємо ІД-и записів деталей нарахувань
        UPDATE tmp_ac_detail
           SET a_id =
                   CASE
                       WHEN p_calc_mode IN (1, 2) THEN id_ac_detail (0)
                       ELSE ROWNUM
                   END
         WHERE a_need_write_2_base = 'T';

        --Створюємо записи нарахувань
        INSERT INTO tmp_accrual (c_pc,
                                 c_month,
                                 c_assign_sum,
                                 c_else_dn_sum,
                                 c_delta_recalc,
                                 c_delta_pay)
              SELECT a_pc
                         AS a_pc,
                     a_ac_start_dt
                         AS a_month,
                     SUM (CASE WHEN a_op IN (1, 2) THEN a_sum ELSE NULL END)
                         AS a_sum,
                     SUM (
                         CASE
                             WHEN a_op IN (123, 124, 6) THEN a_sum
                             ELSE NULL
                         END)
                         AS a_else_dn_sum,
                       SUM (
                           CASE WHEN a_op IN (1, 2, 3) THEN a_sum ELSE NULL END)
                     - NVL (
                           SUM (
                               CASE
                                   WHEN a_op IN (123, 124, 6) THEN a_sum
                                   ELSE NULL
                               END),
                           0)
                         AS a_delta_recalc,
                     NULL
                         AS a_delta_pay
                FROM tmp_ac_detail
               WHERE a_need_write_2_base = 'T'
            GROUP BY a_pc, a_ac_start_dt;

        --Використовуємо наявні записи нарахувань
        UPDATE tmp_accrual
           SET c_id =
                   (SELECT ac_id
                      FROM accrual
                     WHERE ac_pc = c_pc AND ac_month = c_month)
         WHERE c_id IS NULL;

        --Генеруємо ІД-и записів нарахувань
        UPDATE tmp_accrual
           SET c_id =
                   CASE
                       WHEN p_calc_mode IN (1, 2) THEN id_accrual (0)
                       ELSE ROWNUM
                   END
         WHERE c_id IS NULL;

        l_cnt := SQL%ROWCOUNT;

        --Прив'язуємо деталі до рядків нарахувань
        UPDATE tmp_ac_detail
           SET a_ac =
                   (SELECT c_id
                      FROM tmp_accrual ac
                     WHERE a_pc = c_pc AND a_ac_start_dt = c_month)
         WHERE a_need_write_2_base = 'T';

        IF p_calc_mode IN (1, 2)
        THEN
            --Записуємо в постійну таблицю записи нарахувань
            MERGE INTO accrual
                 USING (SELECT c_id,
                               c_pc,
                               c_month,
                               c_assign_sum,
                               c_else_dn_sum,
                               'E'         AS c_st,
                               'A'         AS c_history_status,
                               c_delta_recalc,
                               c_delta_pay,
                               com_org     AS c_com_org
                          FROM tmp_accrual, personalcase
                         WHERE c_pc = pc_id)
                    ON (ac_id = c_id)
            WHEN MATCHED
            THEN
                UPDATE SET ac_assign_sum = c_assign_sum,
                           ac_else_dn_sum = c_else_dn_sum,
                           ac_delta_recalc = c_delta_recalc,
                           ac_delta_pay = c_delta_pay,
                           ac_st = 'E',
                           com_org = c_com_org
            WHEN NOT MATCHED
            THEN
                INSERT     (ac_id,
                            ac_pc,
                            ac_month,
                            ac_assign_sum,
                            ac_else_dn_sum,
                            ac_st,
                            history_status,
                            ac_delta_recalc,
                            ac_delta_pay,
                            com_org)
                    VALUES (c_id,
                            c_pc,
                            c_month,
                            c_assign_sum,
                            c_else_dn_sum,
                            c_st,
                            c_history_status,
                            c_delta_recalc,
                            c_delta_pay,
                            c_com_org);

            --Записуємо в постійну таблицю записи деталей нарахувань
            INSERT INTO ac_detail (acd_id,
                                   acd_ac,
                                   acd_op,
                                   acd_npt,
                                   acd_start_dt,
                                   acd_stop_dt,
                                   acd_sum,
                                   acd_month_sum,
                                   acd_delta_recalc,
                                   acd_delta_pay,
                                   acd_dn,
                                   acd_pd,
                                   acd_ac_start_dt,
                                   acd_ac_stop_dt,
                                   acd_is_indexed,
                                   acd_st,
                                   history_status)
                SELECT a_id,
                       a_ac,
                       a_op,
                       a_npt,
                       a_start_dt,
                       a_stop_dt,
                       a_sum,
                       a_month_sum,
                       a_delta_recalc,
                       a_delta_pay,
                       a_dn,
                       a_pd,
                       a_ac_start_dt,
                       a_ac_stop_dt,
                       'F'     AS a_is_indexed,
                       'E'     AS a_st,
                       'A'     AS a_history_status
                  FROM tmp_ac_detail
                 WHERE a_need_write_2_base = 'T';

            --Формуємо множину переплат, на основі яких створюють відрахування переплат
            DELETE FROM tmp_work_ids2
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids2 (x_id)
                SELECT a_id
                  FROM tmp_ac_detail
                 WHERE a_need_write_2_base = 'T' AND a_op = 6;

            API$DEDUCTION.init_deduction_by_accrual (2, g_messages);

            --Оновлюємо поле "поточний борг" у відрахуванні на основі нерознесених залишків по ід-у операції 5
            UPDATE deduction
               SET dn_debt_current =
                       (SELECT SUM (a_sum)
                          FROM tmp_ac_detail ma
                         WHERE     a_op = 5
                               AND a_dn = dn_id
                               AND a_start_dt =
                                   (SELECT MAX (s.a_start_dt)
                                      FROM tmp_ac_detail s
                                     WHERE s.a_op = 5 AND s.a_dn = ma.a_dn))
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_ac_detail ad
                             WHERE a_op = 5 AND a_dn = dn_id)
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_wac_ids
                             WHERE dn_pc = x_id)
                   AND dn_tp = 'D';

            --Оновлюємо поле "поточний борг" у відрахуванні на основі рознесених залишків по ід-у операції 123
            UPDATE deduction
               SET dn_debt_current =
                         dn_debt_current
                       - (SELECT SUM (a_sum)
                            FROM tmp_ac_detail
                           WHERE     a_op IN
                                         (124,
                                          CASE
                                              WHEN dn_tp = 'D' THEN 124
                                              ELSE 123
                                          END)
                                 AND a_dn = dn_id
                                 AND a_id > 0)
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_ac_detail
                             WHERE     a_op IN
                                           (124,
                                            CASE
                                                WHEN dn_tp = 'D' THEN 124
                                                ELSE 123
                                            END)
                                   AND a_dn = dn_id
                                   AND a_id > 0)
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_wac_ids
                             WHERE dn_pc = x_id)
                   AND dn_tp IN ('R', 'HM');

            --Переводимо Відрахування по переплатам в стан "Зактито", якщо сума поточного боргу стала рівна 0 - все, що треба було, стягнуто
            UPDATE deduction
               SET dn_st = 'Z'
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_ac_detail
                             WHERE a_op IN (5, 123, 124) AND a_dn = dn_id)
                   AND dn_debt_current = 0
                   AND dn_tp IN ('R', 'HM')
                   AND dn_st = 'R';

            --Формуємо множину ОР, які треба захистити від переміграції - а це всі, по яких хоч 1 запис ми нарахували
            INSERT INTO tmp_work_idpa (x_id)
                SELECT DISTINCT pa_id
                  FROM tmp_ac_detail, v_pc_account
                 WHERE     a_need_write_2_base = 'T'
                       AND pa_pc = a_pc
                       AND pa_nst = a_nst;

            API$PC_ACCOUNT.make_pa_non_remigratable (2, NULL);

            --Формуємо множину перерахунків, для яких треба актуалізувати індикативні суми
            DELETE FROM tmp_work_ids1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids1 (x_id)
                SELECT DISTINCT c_id
                  FROM tmp_accrual;

            actuilize_payed_sum (1);

            IF l_cnt > 0
            THEN
                l_hs := TOOLS.GetHistSession ();
            END IF;

            FOR xx IN (SELECT c_id FROM tmp_accrual)
            LOOP
                write_ac_log (xx.c_id,
                              l_hs,
                              'E',
                              CHR (38) || '47#',
                              NULL);
            END LOOP;
        END IF;


        calc_write_message (p_calc_mode,
                            'Завершую розрахунок!',
                            'I',
                            g_messages);
        --TOOLS.add_message(g_messages, 'I', 'Завершую розрахунок!');

        set_calc_mode (0); --Встановлюємо (відновлюємо) режим розрахунку - по ЕОС.

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;


    --Підтвердження нарахування
    PROCEDURE approve_accrual_int (p_mode    INTEGER, --1=для індивідуального підтверждення з картки справи, 2=для масового підтвердження одразу в "діюче"
                                   p_ac_id   accrual.ac_id%TYPE,
                                   p_hs      histsession.hs_id%TYPE)
    IS
        l_accrual   accrual%ROWTYPE;
        l_new_st    accrual.ac_st%TYPE := '-';
        l_msg       ac_log.acl_message%TYPE;
        l_hs        histsession.hs_id%TYPE;
    BEGIN
        init_access_params;

        SELECT *
          INTO l_accrual
          FROM accrual
         WHERE ac_id = p_ac_id;

        IF p_mode = 1 AND l_accrual.ac_st = 'E'
        THEN
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'W';
            l_msg := CHR (38) || '48#';
        ELSIF p_mode = 1 AND l_accrual.ac_st = 'W'
        THEN
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'R';
            l_msg := CHR (38) || '49#';
        ELSIF     p_mode IN (1, 2)
              AND l_accrual.ac_st IN ('E', 'W')
              AND g_bp_class = 'VPO'
        THEN
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'RP';
            l_msg := CHR (38) || '49#';
        ELSIF     p_mode IN (1, 2)
              AND l_accrual.ac_st IN ('E', 'W')
              AND g_bp_class = 'V'
        THEN
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'RV';
            l_msg := CHR (38) || '49#';
        ELSIF p_mode IN (1, 2) AND l_accrual.ac_st IN ('RP', 'RV')
        THEN
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'R';
            l_msg := CHR (38) || '49#';
        END IF;

        IF l_new_st <> '-'
        THEN
            UPDATE accrual
               SET ac_st = l_new_st
             WHERE ac_id = p_ac_id;

            l_hs := NVL (p_hs, TOOLS.GetHistSession);

            write_ac_log (p_ac_id,
                          l_hs,
                          l_new_st,
                          l_msg,
                          l_accrual.ac_st);
        ELSIF p_mode = 1
        THEN
            BEGIN
                SELECT dic_name
                  INTO l_msg
                  FROM uss_ndi.v_ddn_ac_st
                 WHERE dic_value = l_accrual.ac_st;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_msg := 'не визначено';
            END;

            raise_application_error (
                -20000,
                   'Підтверджувати/візувати нарахування в стані <'
                || l_msg
                || '> не можна! id='
                || p_ac_id);
        ELSE
            NULL; --нарахування в стані Діюче і режим 2 - помилок не генерувати.
        END IF;
    END;

    PROCEDURE approve_accrual (p_ac_id accrual.ac_id%TYPE)
    IS
    BEGIN
        approve_accrual_int (1, p_ac_id, NULL);
    END;

    PROCEDURE approve_accrual_by_params (p_org            accrual.com_org%TYPE,
                                         p_nst            pc_decision.pd_nst%TYPE,
                                         p_month          accrual.ac_month%TYPE,
                                         p_messages   OUT SYS_REFCURSOR)
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        init_access_params;
        authcheck ('calc_accrual');

        g_messages := TOOLS.t_messages ();

        calc_write_message (1,
                            'Починаю масове підтвердження нарахувань!',
                            'I',
                            g_messages);

        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ac_id
              FROM accrual, tmp_org
             WHERE     ac_month = p_month
                   AND com_org = u_org
                   AND ac_st IN
                           ('E', 'W', DECODE (g_bp_class, 'V', 'RV', 'RP'));

        IF SQL%ROWCOUNT > 0
        THEN
            l_hs := TOOLS.GetHistSession;

            FOR xx IN (SELECT x_id FROM tmp_work_ids)
            LOOP
                approve_accrual_int (2, xx.x_id, l_hs);
            END LOOP;
        ELSE
            calc_write_message (
                1,
                'Не знайдено нарахувань в статусах "Редагується" або "Передано на візування" для переводу в стан "Діючий"!',
                'I',
                g_messages);
        END IF;

        calc_write_message (1,
                            'Завершую масове підтвердження нарахувань!',
                            'I',
                            g_messages);

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;

    PROCEDURE return_accrual_int (p_mode        INTEGER,
                                  p_ac_id       accrual.ac_id%TYPE,
                                  p_reason   IN VARCHAR2,
                                  p_hs          histsession.hs_id%TYPE)
    IS
        l_accrual   accrual%ROWTYPE;
        l_new_st    accrual.ac_st%TYPE := '-';
        l_msg       ac_log.acl_message%TYPE;
        l_hs        histsession.hs_id%TYPE;
    BEGIN
        init_access_params;

        SELECT *
          INTO l_accrual
          FROM accrual
         WHERE ac_id = p_ac_id;

        --  raise_application_error(-20000, l_accrual.ac_id);
        /*IF p_mode = 1 AND l_accrual.ac_rc IS NOT NULL THEN
          raise_application_error(-20000, 'Нарахування отримано масовим розрахунком - повернення на розрахунок повинно виконуватись з картки масового розрахунку!');
        END IF;*/

        IF l_accrual.ac_st = 'W'
        THEN
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'E';
            l_msg := CHR (38) || '64#';
        ELSIF p_mode = 2 AND l_accrual.ac_st IN ('RV', 'RP')
        THEN
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'E';
            l_msg := CHR (38) || '64#';
        ELSIF p_mode = 2 AND l_accrual.ac_st IN ('R') AND g_bp_class = 'VPO'
        THEN
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'RV';
            l_msg := CHR (38) || '64#';
        ELSIF p_mode = 2 AND l_accrual.ac_st IN ('R') AND g_bp_class = 'V'
        THEN
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'RP';
            l_msg := CHR (38) || '64#';
        ELSIF     p_mode = 1
              AND l_accrual.ac_st IN ('R',
                                      'RP',
                                      'RV',
                                      'W')
        THEN --Индивидуальный возврат в Редагується - из любого статуса. Юзеру нуно срочно пересчитать справу!
            --!!!Тут должны быть вписаны контроли на возможность выполнить переход
            l_new_st := 'E';
            l_msg := CHR (38) || '64#';
        END IF;

        IF l_new_st <> '-'
        THEN
            UPDATE accrual
               SET ac_st = l_new_st
             WHERE ac_id = p_ac_id;

            l_hs := NVL (p_hs, TOOLS.GetHistSession);
            write_ac_log (p_ac_id,
                          l_hs,
                          l_new_st,
                          l_msg,
                          l_accrual.ac_st);

            IF p_reason IS NOT NULL
            THEN
                write_ac_log (p_ac_id,
                              l_hs,
                              l_new_st,
                              p_reason,
                              l_accrual.ac_st,
                              'USR');
            END IF;
        ELSE
            IF p_mode = 1
            THEN --для масового розрахунку - не робимо нічого. Для індивідуального - виключення
                BEGIN
                    SELECT dic_name
                      INTO l_msg
                      FROM uss_ndi.v_ddn_ac_st
                     WHERE dic_value = l_accrual.ac_st;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        l_msg := 'не визначено';
                END;

                raise_application_error (
                    -20000,
                       'Повертати нарахування в стані <'
                    || l_msg
                    || '> не можна! id='
                    || p_ac_id);
            END IF;
        END IF;
    END;

    PROCEDURE return_accrual (p_ac_id       accrual.ac_id%TYPE,
                              p_reason   IN VARCHAR2)
    IS
    BEGIN
        return_accrual_int (1,
                            p_ac_id,
                            p_reason,
                            NULL);
    END;

    --Оновлення реєстраційних записів нарахувань в частині "виплачено"
    --Вхідна множина нарахувань - в таблиці tmp_work_ids1
    PROCEDURE actuilize_payed_sum (p_mode INTEGER)
    IS
    BEGIN
        --Очищаємо вхідну множину від дублікатів
        DELETE FROM tmp_work_ids3
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids3 (x_id)
            SELECT DISTINCT x_id
              FROM tmp_work_ids1;

        UPDATE accrual
           SET ac_assign_sum = 0,
               ac_else_dn_sum = 0,
               ac_delta_recalc = 0,
               ac_payed_sum = 0
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE ac_id = x_id)
               AND NOT EXISTS
                       (SELECT 1
                          FROM ac_detail d
                         WHERE acd_ac = ac_id AND d.history_status = 'A');

        MERGE INTO accrual
             USING ( -- запит може бути використаний для оновлення за будь якими критеріями
                     -- а також для порівняння поточного стану даних з бажаним
                     SELECT acd_ac      c_id,
                            SUM (
                                CASE
                                    WHEN acd_op NOT IN (5, 6, 40)
                                    THEN
                                        DECODE (
                                            API$ACCRUAL_TEST.xsign (acd_op),
                                            1, acd_sum,
                                            0)
                                    ELSE
                                        0
                                END)    c_plus,
                            SUM (
                                CASE
                                    WHEN acd_op NOT IN (5, 6, 40)
                                    THEN
                                        DECODE (
                                            API$ACCRUAL_TEST.xsign (acd_op),
                                            -1, acd_sum,
                                            0)
                                    ELSE
                                        0
                                END)    c_minus,
                            SUM (
                                CASE
                                    WHEN acd_op NOT IN (5, 6, 40)
                                    THEN
                                        CASE
                                            WHEN (   acd_imp_pr_num IS NOT NULL
                                                  OR prs_st = 'KV2')
                                            THEN
                                                  API$ACCRUAL_TEST.xsign (
                                                      acd_op)
                                                * acd_sum
                                            ELSE
                                                0
                                        END
                                    ELSE
                                        0
                                END)    c_payed,
                            SUM (
                                CASE
                                    WHEN acd_op NOT IN (5, 6, 40)
                                    THEN
                                        CASE
                                            WHEN     acd_imp_pr_num IS NULL
                                                 AND NVL (prs_st, 'XX') IN
                                                         ('NA', 'KV1', 'XX')
                                            THEN
                                                  API$ACCRUAL_TEST.xsign (
                                                      acd_op)
                                                * acd_sum
                                            ELSE
                                                0
                                        END
                                    ELSE
                                        0
                                END)    c_rolled
                       FROM tmp_work_ids3
                            LEFT JOIN ac_detail acd ON acd_ac = x_id -- filter HERE
                            LEFT JOIN pr_sheet_detail prsd
                                ON acd_prsd = prsd_id
                            LEFT JOIN pr_sheet prs ON prsd_prs = prs_id
                      WHERE acd.history_status = 'A' AND acd_st != 'U' /*exclude acd_op=125*/
                   GROUP BY acd_ac)
                ON (ac_id = c_id)
        WHEN MATCHED
        THEN                                                         -- always
            UPDATE SET ac_assign_sum = c_plus, -- усіляких нарахувань та інших "плюсів"
                       ac_else_dn_sum = c_minus, -- усіляких відрахувань та "мінусів"
                       ac_delta_recalc = c_rolled, -- у відомостях : не виплачено, не заблоковано (назва поля не відповідає змісту)
                       ac_payed_sum = c_payed; -- у відомостях : виплачено або закрито АСОПД

        -- в цій частині в рамках задачі #81114 нічого не змінено !
        UPDATE ac_detail
           SET acd_payed_sum = acd_sum, acd_delta_recalc = NULL
         WHERE     history_status = 'A'
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE x_id = acd_ac)
               AND (   EXISTS
                           (SELECT 1
                              FROM pr_sheet_detail, pr_sheet
                             WHERE     acd_prsd = prsd_id
                                   AND prsd_prs = prs_id
                                   AND prs_st = 'KV2')
                    OR acd_imp_pr_num IS NOT NULL)
               AND acd_payed_sum IS NULL
               AND acd_delta_recalc IS NOT NULL;

        UPDATE ac_detail
           SET acd_payed_sum = NULL, acd_delta_recalc = acd_sum
         WHERE     history_status = 'A'
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE x_id = acd_ac)
               AND NOT EXISTS
                       (SELECT 1
                          FROM pr_sheet_detail, pr_sheet
                         WHERE     acd_prsd = prsd_id
                               AND prsd_prs = prs_id
                               AND prs_st = 'KV2')
               AND acd_imp_pr_num IS NULL
               AND acd_payed_sum IS NOT NULL
               AND acd_delta_recalc IS NULL;
    END;

    --Функція зупинки виплати
    PROCEDURE stop_pay (p_mode INTEGER)
    IS
        l_hs   histsession.hs_id%TYPE := NULL;
    BEGIN
        --Формуємо перелік операцій, які потребують копіювання ("відновлення")
        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        INSERT INTO tmp_work_set3 (x_id1, x_id2)
            SELECT acd_id, acd_prsd
              FROM ac_detail, tmp_ac_stop_pay
             WHERE history_status = 'A' AND acd_prsd = x_prsd
            UNION
            SELECT acd_id, acd_prsd
              FROM ac_detail, tmp_ac_stop_pay
             WHERE history_status = 'A' AND acd_id = x_acd;

        --Переводимо записи нарахувань, які прив'язані до відповідних рядків деталей відомостей в історичний стан
        UPDATE ac_detail
           SET history_status = 'H'
         WHERE     history_status = 'A'
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_set3
                         WHERE acd_id = x_id1);

        UPDATE tmp_work_set3
           SET x_id3 = id_ac_detail (0)
         WHERE 1 = 1;

        --Створюємо копії рядків нарахувань - аби вони без перешкод були використані при створенні наступної відомості
        --!!! Власне тут і потрібно розвивати створення інших типів рядків, групування в документи - для можливості побудови
        --!! життєвого циклу та участі користувача в просуванні цих сум до виплат/тощо.
        INSERT INTO ac_detail (acd_id,
                               acd_ac,
                               acd_op,
                               acd_npt,
                               acd_start_dt,
                               acd_stop_dt,
                               acd_sum,
                               acd_month_sum,
                               acd_delta_recalc,
                               acd_delta_pay,
                               acd_dn,
                               acd_pd,
                               acd_ac_start_dt,
                               acd_ac_stop_dt,
                               acd_is_indexed,
                               acd_st,
                               history_status,
                               acd_payed_sum,
                               acd_prsd,
                               acd_can_use_in_pr)
            SELECT x_id3,
                   acd_ac,
                   acd_op,
                   acd_npt,
                   acd_start_dt,
                   acd_stop_dt,
                   acd_sum,
                   acd_month_sum,
                   acd_delta_recalc,
                   acd_delta_pay,
                   acd_dn,
                   acd_pd,
                   acd_ac_start_dt,
                   acd_ac_stop_dt,
                   acd_is_indexed,
                   acd_st,
                   'A',
                   acd_payed_sum,
                   NULL,
                   acd_can_use_in_pr
              FROM ac_detail, tmp_work_set3
             WHERE history_status = 'H' AND acd_id = x_id1;

        --Створюємо "реєстр блоквання операцій для відомості".
        l_hs := TOOLS.GetHistSession;

        INSERT INTO pr_blocked_acd (prsa_id,
                                    prsa_prsd,
                                    prsa_acd_blocked,
                                    prsa_acd_inserted,
                                    history_status,
                                    prsa_hs_ins,
                                    prsa_hs_del)
            SELECT 0,
                   x_id2,
                   x_id1,
                   x_id3,
                   'A',
                   l_hs,
                   NULL
              FROM tmp_work_set3
             WHERE x_id2 IS NOT NULL;

        --Готуємо множину нарахувань, для яких треба оновити дані про суми виплаченого
        DELETE FROM tmp_work_ids1
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids1 (x_id)
            SELECT DISTINCT acd_ac
              FROM tmp_work_set3, ac_detail
             WHERE acd_id = x_id1;

        --Оновлюємо дані про суми виплаченого (включеного у відомості) по реєстраційному запису нарахувань
        actuilize_payed_sum (1);
    END stop_pay;

    -- масові перерахунки - тимчасовий WRAPPER
    PROCEDURE return_recalculates (p_rc_id recalculates.rc_id%TYPE)
    IS
    BEGIN
        API$RECALCULATES.return_recalculates (p_rc_id);
    END return_recalculates;

    PROCEDURE approve_recalculates (p_rc_id recalculates.rc_id%TYPE)
    IS
    BEGIN
        API$RECALCULATES.approve_recalculates (p_rc_id);
    END approve_recalculates;

    PROCEDURE calc_accrual_job (p_session   VARCHAR2,
                                p_rc_id     recalculates.rc_id%TYPE)
    IS
    BEGIN
        API$RECALCULATES.calc_accrual_job (p_session, p_rc_id);
    END calc_accrual_job;

    PROCEDURE mass_calc_accrual (
        p_rc_id            OUT recalculates.rc_id%TYPE,
        p_rc_jb            OUT recalculates.rc_jb%TYPE,
        p_rc_month      IN     recalculates.rc_month%TYPE,
        p_rc_org_list   IN     recalculates.rc_org_list%TYPE)
    IS
    BEGIN
        API$RECALCULATES.mass_calc_accrual (p_rc_id,
                                            p_rc_jb,
                                            p_rc_month,
                                            p_rc_org_list);
    END mass_calc_accrual;

    PROCEDURE get_acd_sums_to_manipulate (
        p_pd_id          pc_decision.pd_id%TYPE,
        p_acd_data   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_acd_data FOR
            SELECT x_pd,
                   x_month,
                   x_sum_tp,
                   x_sum,
                   x_acd_list,
                   dic_name     AS x_sum_tp_name
              FROM uss_ndi.v_ddn_acdm_tp,
                   (  SELECT acd_pd
                                 AS x_pd,
                             TRUNC (acd_start_dt, 'MM')
                                 AS x_month,
                             'V1'
                                 AS x_sum_tp,
                             SUM (
                                   acd_sum
                                 * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                                 AS x_sum,
                             LISTAGG (acd_id, ',')
                                 WITHIN GROUP (ORDER BY acd_id)
                                 AS x_acd_list
                        FROM uss_esr.pc_decision,
                             uss_esr.ac_detail,
                             uss_ndi.v_ndi_op --Включено в відомості АСОПД - дозволити включити в відомості ЄІССС
                       WHERE     acd_pd = pd_id
                             AND pd_nst = 664
                             AND acd_start_dt BETWEEN TO_DATE ('01.03.2022',
                                                               'DD.MM.YYYY')
                                                  AND TO_DATE ('31.10.2022',
                                                               'DD.MM.YYYY')
                             AND acd_imp_pr_num IS NOT NULL
                             AND acd_pd = p_pd_id
                             AND acd_op = op_id
                             AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                             AND history_Status = 'A'
                             AND acd_npt = 167
                    GROUP BY acd_pd, TRUNC (acd_start_dt, 'MM')
                    UNION ALL
                      SELECT acd_pd
                                 AS x_pd,
                             TRUNC (acd_start_dt, 'MM')
                                 AS x_month,
                             'V2'
                                 AS x_sum_tp,
                             SUM (
                                   acd_sum
                                 * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                                 AS x_sum,
                             LISTAGG (acd_id, ',')
                                 WITHIN GROUP (ORDER BY acd_id)
                                 AS x_acd_list
                        FROM uss_esr.pc_decision,
                             uss_esr.ac_detail,
                             uss_ndi.v_ndi_op
                       WHERE     acd_pd = pd_id
                             AND pd_nst = 664
                             AND acd_start_dt BETWEEN TO_DATE ('01.03.2022',
                                                               'DD.MM.YYYY')
                                                  AND TO_DATE ('31.10.2022',
                                                               'DD.MM.YYYY')
                             AND acd_imp_pr_num IS NULL
                             AND acd_prsd IS NULL
                             AND acd_pd = p_pd_id
                             AND acd_op = op_id
                             AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                             AND history_Status = 'A'
                             AND acd_npt = 167
                    GROUP BY acd_pd, TRUNC (acd_start_dt, 'MM')
                    UNION ALL
                      SELECT acd_pd
                                 AS x_pd,
                             TRUNC (acd_start_dt, 'MM')
                                 AS x_month,
                             'V3'
                                 AS x_sum_tp,
                             SUM (
                                   acd_sum
                                 * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                                 AS x_sum,
                             LISTAGG (acd_id, ',')
                                 WITHIN GROUP (ORDER BY acd_id)
                                 AS x_acd_list
                        FROM uss_esr.pc_decision pd,
                             uss_esr.ac_detail,
                             uss_ndi.v_ndi_op,
                             uss_esr.personalcase pc
                       WHERE     pd_pc = pc_id
                             AND acd_pd = pd_id
                             AND pd_nst = 664
                             AND pd_st = 'PS'
                             AND acd_start_dt >=
                                 TO_DATE ('01.11.2022', 'DD.MM.YYYY')
                             AND acd_imp_pr_num IS NULL
                             AND acd_prsd IS NULL
                             AND acd_can_use_in_pr IS NULL
                             AND (   (pd_st = 'PS' AND pd.com_org = pc.com_org)
                                  OR (    pd_st IN ('S', 'PS')
                                      AND pd.com_org <> pc.com_org))
                             AND acd_pd = p_pd_id
                             AND acd_op = op_id
                             AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                             AND history_Status = 'A'
                             AND acd_npt = 167
                    GROUP BY acd_pd, TRUNC (acd_start_dt, 'MM')
                    UNION ALL
                      SELECT acd_pd
                                 AS x_pd,
                             TRUNC (acd_start_dt, 'MM')
                                 AS x_month,
                             'V4'
                                 AS x_sum_tp,
                             SUM (
                                   acd_sum
                                 * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                                 AS x_sum,
                             LISTAGG (acd_id, ',')
                                 WITHIN GROUP (ORDER BY acd_id)
                                 AS x_acd_list
                        FROM uss_esr.pc_decision pd,
                             uss_esr.ac_detail,
                             uss_ndi.v_ndi_op,
                             uss_esr.personalcase pc
                       WHERE     pd_pc = pc_id
                             AND acd_pd = pd_id
                             AND pd_nst = 664
                             --  AND pd_st = 'PS'
                             AND acd_start_dt >=
                                 TO_DATE ('01.11.2022', 'DD.MM.YYYY')
                             AND acd_imp_pr_num IS NULL
                             AND acd_prsd IS NULL
                             AND acd_can_use_in_pr = 'T'
                             AND (   (pd_st = 'PS' AND pd.com_org = pc.com_org)
                                  OR (    pd_st IN ('S', 'PS')
                                      AND pd.com_org <> pc.com_org))
                             AND acd_pd = p_pd_id
                             AND acd_op = op_id
                             AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                             AND history_Status = 'A'
                             AND acd_npt = 167
                    GROUP BY acd_pd, TRUNC (acd_start_dt, 'MM')
                    UNION ALL
                      SELECT acd_pd
                                 AS x_pd,
                             TRUNC (acd_start_dt, 'MM')
                                 AS x_month,
                             'V1'
                                 AS x_sum_tp,
                             SUM (
                                   acd_sum
                                 * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                                 AS x_sum,
                             LISTAGG (acd_id, ',')
                                 WITHIN GROUP (ORDER BY acd_id)
                                 AS x_acd_list
                        FROM uss_esr.pc_decision,
                             uss_esr.ac_detail,
                             uss_ndi.v_ndi_op --Включено в відомості АСОПД - дозволити включити в відомості ЄІССС
                       WHERE     acd_pd = pd_id
                             AND acd_imp_pr_num IS NOT NULL
                             AND acd_pd = p_pd_id
                             AND acd_op = op_id
                             AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                             AND history_Status = 'A'
                             AND acd_npt NOT IN (166, 167)
                    GROUP BY acd_pd, TRUNC (acd_start_dt, 'MM')
                    UNION ALL
                      SELECT acd_pd
                                 AS x_pd,
                             TRUNC (acd_start_dt, 'MM')
                                 AS x_month,
                             'V2'
                                 AS x_sum_tp,
                             SUM (
                                   acd_sum
                                 * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                                 AS x_sum,
                             LISTAGG (acd_id, ',')
                                 WITHIN GROUP (ORDER BY acd_id)
                                 AS x_acd_list
                        FROM uss_esr.pc_decision,
                             uss_esr.ac_detail,
                             uss_ndi.v_ndi_op --НЕ включено в відомості АСОПД - заборонити включати в відомості ЄІССС
                       WHERE     acd_pd = pd_id
                             AND acd_imp_pr_num IS NULL
                             AND acd_prsd IS NULL
                             AND acd_pd = p_pd_id
                             AND acd_op = op_id
                             AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                             AND history_Status = 'A'
                             AND acd_npt NOT IN (166, 167)
                    GROUP BY acd_pd, TRUNC (acd_start_dt, 'MM')
                    UNION ALL
                      SELECT acd_pd
                                 AS x_pd,
                             TRUNC (acd_start_dt, 'MM')
                                 AS x_month,
                             'V3'
                                 AS x_sum_tp,
                             SUM (
                                   acd_sum
                                 * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                                 AS x_sum,
                             LISTAGG (acd_id, ',')
                                 WITHIN GROUP (ORDER BY acd_id)
                                 AS x_acd_list
                        FROM uss_esr.pc_decision pd,
                             uss_esr.ac_detail,
                             uss_ndi.v_ndi_op,
                             uss_esr.personalcase pc --НЕ виплачено і на призупиненому рішенні - дозволити включити в відомості ЄІССС
                       WHERE     pd_pc = pc_id
                             AND acd_pd = pd_id
                             AND acd_imp_pr_num IS NULL
                             AND acd_prsd IS NULL
                             AND acd_can_use_in_pr IS NULL
                             AND pd_st = 'PS'
                             AND acd_pd = p_pd_id
                             AND acd_op = op_id
                             AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                             AND history_Status = 'A'
                             AND acd_npt NOT IN (166, 167)
                    GROUP BY acd_pd, TRUNC (acd_start_dt, 'MM')
                    UNION ALL
                      SELECT acd_pd
                                 AS x_pd,
                             TRUNC (acd_start_dt, 'MM')
                                 AS x_month,
                             'V4'
                                 AS x_sum_tp,
                             SUM (
                                   acd_sum
                                 * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                                 AS x_sum,
                             LISTAGG (acd_id, ',')
                                 WITHIN GROUP (ORDER BY acd_id)
                                 AS x_acd_list
                        FROM uss_esr.pc_decision pd,
                             uss_esr.ac_detail,
                             uss_ndi.v_ndi_op,
                             uss_esr.personalcase pc --Дозволено включити в відомості ЄІССС по призупиненому рішенню - заборонити
                       WHERE     pd_pc = pc_id
                             AND acd_pd = pd_id
                             AND pd_st = 'PS'
                             AND acd_imp_pr_num IS NULL
                             AND acd_prsd IS NULL
                             AND acd_can_use_in_pr = 'T'
                             AND acd_pd = p_pd_id
                             AND acd_op = op_id
                             AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                             AND history_Status = 'A'
                             AND acd_npt NOT IN (166, 167)
                    GROUP BY acd_pd, TRUNC (acd_start_dt, 'MM'))
             WHERE x_sum_tp = dic_value AND x_sum <> 0;
    END;

    PROCEDURE manipulate_with_acd (p_pc_id          personalcase.pc_id%TYPE,
                                   p_pd_id          pc_decision.pd_id%TYPE,
                                   p_month          ac_detail.acd_start_dt%TYPE,
                                   p_sum            ac_detail.acd_sum%TYPE,
                                   p_acd_ids_list   VARCHAR2,
                                   p_decision       VARCHAR2)
    IS
        l_new_sum        ac_detail.acd_sum%TYPE;
        l_new_acd_list   VARCHAR2 (4000);
        l_sum_name       VARCHAR2 (4000);
        l_hs             histsession.hs_id%TYPE;
        l_pd_st          pc_decision.pd_st%TYPE;
    BEGIN
        --raise_application_error('-20000', 'Розробляється ще, от нетерплячі!');
        l_hs := TOOLS.GetHistSession;

        --Розраховуємо відповідну суму та перелік ідентифікаторов рядків знову - для переверки переданого з інтерфейсу
        IF p_decision = 'V1'
        THEN --Включено в відомості АСОПД - дозволити включити в відомості ЄІССС
            SELECT SUM (acd_sum * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                       AS x_sum,
                   LISTAGG (acd_id, ',') WITHIN GROUP (ORDER BY acd_id)
                       AS x_acd_list
              INTO l_new_sum, l_new_acd_list
              FROM (SELECT d.*
                      FROM uss_esr.pc_decision,
                           uss_esr.ac_detail  d,
                           uss_ndi.v_ndi_op,
                           uss_esr.accrual
                     WHERE     acd_ac = ac_id
                           AND acd_pd = pd_id
                           AND pd_nst = 664
                           AND acd_imp_pr_num IS NOT NULL
                           AND acd_op = op_id
                           AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                           AND d.history_Status = 'A'
                           AND acd_npt = 167
                           AND acd_pd = p_pd_id
                           AND ac_pc = p_pc_id
                           AND acd_start_dt BETWEEN TO_DATE ('01.03.2022',
                                                             'DD.MM.YYYY')
                                                AND TO_DATE ('31.10.2022',
                                                             'DD.MM.YYYY')
                           AND acd_start_dt BETWEEN p_month
                                                AND LAST_DAY (p_month)
                    UNION ALL
                    SELECT d.*
                      FROM uss_esr.pc_decision,
                           uss_esr.ac_detail  d,
                           uss_ndi.v_ndi_op --Включено в відомості АСОПД - дозволити включити в відомості ЄІССС
                     WHERE     acd_pd = pd_id
                           AND acd_imp_pr_num IS NOT NULL
                           AND acd_pd = p_pd_id
                           AND acd_op = op_id
                           AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                           AND history_Status = 'A'
                           AND acd_npt NOT IN (166, 167)
                           AND acd_start_dt BETWEEN p_month
                                                AND LAST_DAY (p_month));
        ELSIF p_decision = 'V2'
        THEN --НЕ включено в відомості АСОПД - заборонити включати в відомості ЄІССС
            SELECT SUM (acd_sum * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                       AS x_sum,
                   LISTAGG (acd_id, ',') WITHIN GROUP (ORDER BY acd_id)
                       AS x_acd_list
              INTO l_new_sum, l_new_acd_list
              FROM (SELECT d.*
                      FROM uss_esr.pc_decision,
                           uss_esr.ac_detail  d,
                           uss_ndi.v_ndi_op,
                           uss_esr.accrual
                     WHERE     acd_ac = ac_id
                           AND acd_pd = pd_id
                           AND pd_nst = 664
                           AND acd_imp_pr_num IS NULL
                           AND acd_prsd IS NULL
                           AND acd_op = op_id
                           AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                           AND d.history_Status = 'A'
                           AND acd_npt = 167
                           AND acd_pd = p_pd_id
                           AND ac_pc = p_pc_id
                           AND acd_start_dt BETWEEN TO_DATE ('01.03.2022',
                                                             'DD.MM.YYYY')
                                                AND TO_DATE ('31.10.2022',
                                                             'DD.MM.YYYY')
                           AND acd_start_dt BETWEEN p_month
                                                AND LAST_DAY (p_month)
                    UNION ALL
                    SELECT d.*
                      FROM uss_esr.pc_decision,
                           uss_esr.ac_detail  d,
                           uss_ndi.v_ndi_op --НЕ включено в відомості АСОПД - заборонити включати в відомості ЄІССС
                     WHERE     acd_pd = pd_id
                           AND acd_imp_pr_num IS NULL
                           AND acd_prsd IS NULL
                           AND acd_pd = p_pd_id
                           AND acd_op = op_id
                           AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                           AND history_Status = 'A'
                           AND acd_npt NOT IN (166, 167)
                           AND acd_start_dt BETWEEN p_month
                                                AND LAST_DAY (p_month));
        ELSIF p_decision = 'V3'
        THEN --НЕ виплачено і на призупиненому рішенні - дозволити включити в відомості ЄІССС
            SELECT SUM (acd_sum * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                       AS x_sum,
                   LISTAGG (acd_id, ',') WITHIN GROUP (ORDER BY acd_id)
                       AS x_acd_list
              INTO l_new_sum, l_new_acd_list
              FROM (SELECT d.*
                      FROM uss_esr.pc_decision   pd,
                           uss_esr.ac_detail     d,
                           uss_ndi.v_ndi_op,
                           uss_esr.accrual,
                           uss_esr.personalcase  pc
                     WHERE     pd_pc = pc_id
                           AND acd_ac = ac_id
                           AND acd_pd = pd_id
                           AND pd_nst = 664
                           AND acd_imp_pr_num IS NULL
                           AND acd_prsd IS NULL
                           AND acd_can_use_in_pr IS NULL
                           AND (   (pd_st = 'PS' AND pd.com_org = pc.com_org)
                                OR (    pd_st IN ('S', 'PS')
                                    AND pd.com_org <> pc.com_org))
                           AND acd_op = op_id
                           AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                           AND d.history_Status = 'A'
                           AND acd_npt = 167
                           AND acd_pd = p_pd_id
                           AND acd_pd = p_pd_id
                           AND acd_start_dt >=
                               TO_DATE ('01.11.2022', 'DD.MM.YYYY')
                           AND acd_start_dt BETWEEN p_month
                                                AND LAST_DAY (p_month)
                    UNION ALL
                    SELECT d.*
                      FROM uss_esr.pc_decision   pd,
                           uss_esr.ac_detail     d,
                           uss_ndi.v_ndi_op,
                           uss_esr.personalcase  pc --НЕ виплачено і на призупиненому рішенні - дозволити включити в відомості ЄІССС
                     WHERE     pd_pc = pc_id
                           AND acd_pd = pd_id
                           AND acd_imp_pr_num IS NULL
                           AND acd_prsd IS NULL
                           AND acd_can_use_in_pr IS NULL
                           AND pd_st = 'PS'
                           AND acd_pd = p_pd_id
                           AND acd_op = op_id
                           AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                           AND history_Status = 'A'
                           AND acd_npt NOT IN (166, 167)
                           AND acd_start_dt BETWEEN p_month
                                                AND LAST_DAY (p_month));
        ELSIF p_decision = 'V4'
        THEN --Дозволено включити в відомості ЄІССС по призупиненому рішенню - заборонити
            SELECT SUM (acd_sum * uss_esr.API$ACCRUAL_TEST.xsign (acd_op))
                       AS x_sum,
                   LISTAGG (acd_id, ',') WITHIN GROUP (ORDER BY acd_id)
                       AS x_acd_list
              INTO l_new_sum, l_new_acd_list
              FROM (SELECT d.*
                      FROM uss_esr.pc_decision   pd,
                           uss_esr.ac_detail     d,
                           uss_ndi.v_ndi_op,
                           uss_esr.accrual,
                           uss_esr.personalcase  pc
                     WHERE     pd_pc = pc_id
                           AND acd_ac = ac_id
                           AND acd_pd = pd_id
                           AND pd_nst = 664
                           --  AND pd_st = 'PS'
                           AND acd_imp_pr_num IS NULL
                           AND acd_prsd IS NULL
                           AND acd_can_use_in_pr = 'T'
                           AND (   (pd_st = 'PS' AND pd.com_org = pc.com_org)
                                OR (    pd_st IN ('S', 'PS')
                                    AND pd.com_org <> pc.com_org))
                           AND acd_pd = p_pd_id
                           AND acd_op = op_id
                           AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                           AND d.history_Status = 'A'
                           AND acd_npt = 167
                           AND acd_pd = p_pd_id
                           AND acd_pd = p_pd_id
                           AND acd_start_dt >=
                               TO_DATE ('01.11.2022', 'DD.MM.YYYY')
                           AND acd_start_dt BETWEEN p_month
                                                AND LAST_DAY (p_month)
                    UNION ALL
                    SELECT d.*
                      FROM uss_esr.pc_decision   pd,
                           uss_esr.ac_detail     d,
                           uss_ndi.v_ndi_op,
                           uss_esr.personalcase  pc --Дозволено включити в відомості ЄІССС по призупиненому рішенню - заборонити
                     WHERE     pd_pc = pc_id
                           AND acd_pd = pd_id
                           AND pd_st = 'PS'
                           AND acd_imp_pr_num IS NULL
                           AND acd_prsd IS NULL
                           AND acd_can_use_in_pr = 'T'
                           AND acd_pd = p_pd_id
                           AND acd_op = op_id
                           AND (op_tp1 IN ('NR', 'DN') OR op_id IN (1, 2, 3))
                           AND history_Status = 'A'
                           AND acd_npt NOT IN (166, 167)
                           AND acd_start_dt BETWEEN p_month
                                                AND LAST_DAY (p_month));
        ELSE
            raise_application_error (
                '-20000',
                'Режим ' || p_decision || ' - не підтримується!');
        END IF;

        IF p_sum IS NULL
        THEN
            raise_application_error (
                '-20000',
                'Не надано суми нарахувань для обробки. Виконувати дію не маю з чим!');
        END IF;

        IF l_new_sum IS NULL
        THEN
            raise_application_error (
                '-20000',
                   'Не знайдено суми нарахувань для обробки. Виконувати дію не маю з чим! diag('
                || 'p_pc_id='
                || p_pc_id
                || ',p_pd_id='
                || p_pd_id
                || ',p_month='
                || p_month
                || ',p_sum='
                || p_sum
                || ',p_acd_ids_list='
                || p_acd_ids_list
                || ',p_decision='
                || p_decision
                || ')');
        END IF;

        IF l_new_sum <> p_sum
        THEN
            raise_application_error (
                '-20000',
                   'Змінилась сума: передана '
                || p_sum
                || ', а в базі наявна '
                || l_new_sum
                || ', виконати дію не можу - оновіть форму і спробуйте ще!');
        END IF;

        IF p_acd_ids_list IS NULL
        THEN
            raise_application_error (
                '-20000',
                'Не передано рядків нарахувань для обробки. Виконувати дію не маю з чим!');
        END IF;

        IF l_new_acd_list IS NULL
        THEN
            raise_application_error (
                '-20000',
                'Не зайдено рядків нарахувань для обробки. Виконувати дію не маю з чим!');
        END IF;

        IF l_new_acd_list <> p_acd_ids_list
        THEN
            raise_application_error (
                '-20000',
                'Змінився перелік рядків нарахувань для обробки, виконати дію не можу - оновіть форму і спробуйте ще!');
        END IF;

        TOOLS.list_to_work_ids (3, l_new_acd_list);

        IF p_decision = 'V1'
        THEN --Включено в відомості АСОПД - дозволити включити в відомості ЄІССС
            UPDATE ac_detail z
               SET acd_imp_pr_num = NULL, acd_can_use_in_pr = 'T'
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE x_id = acd_id);
        ELSIF p_decision = 'V2'
        THEN --НЕ включено в відомості АСОПД - заборонити включати в відомості ЄІССС
            UPDATE ac_detail z
               SET acd_imp_pr_num = '998', acd_can_use_in_pr = NULL
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE x_id = acd_id);
        ELSIF p_decision = 'V3'
        THEN --НЕ виплачено і на призупиненому рішенні - дозволити включити в відомості ЄІССС
            UPDATE ac_detail z
               SET acd_can_use_in_pr = 'T'
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE x_id = acd_id);
        ELSIF p_decision = 'V4'
        THEN --Дозволено включити в відомості ЄІССС по призупиненому рішенню - заборонити
            UPDATE ac_detail z
               SET acd_can_use_in_pr = NULL
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_ids3
                         WHERE x_id = acd_id);
        ELSE
            raise_application_error (
                '-20000',
                'Режим ' || p_decision || ' - не підтримується!');
        END IF;

        FOR xx
            IN (  SELECT ac_id,
                         ac_st,
                         LISTAGG (acd_id, ',') WITHIN GROUP (ORDER BY acd_id)    AS x_acd_list
                    FROM accrual, ac_detail, tmp_work_ids3
                   WHERE acd_ac = ac_id AND acd_id = x_id
                GROUP BY ac_id, ac_st)
        LOOP
            write_ac_log (
                xx.ac_id,
                l_hs,
                xx.ac_st,
                   CHR (38)
                || '182#'
                || l_new_sum
                || '#@23@'
                || p_decision
                || '#'
                || xx.x_acd_list
                || '#'
                || TO_CHAR (p_month, 'MM.YYYY'),
                xx.ac_st);
        END LOOP;

        SELECT pd_st
          INTO l_pd_st
          FROM pc_decision
         WHERE pd_id = p_pd_id;

        API$PC_DECISION.write_pd_log (
            p_pd_id,
            l_hs,
            l_pd_st,
               CHR (38)
            || '182#'
            || l_new_sum
            || '#@23@'
            || p_decision
            || '#'
            || l_new_acd_list
            || '#'
            || TO_CHAR (p_month, 'MM.YYYY'),
            l_pd_st);
    END;
BEGIN
    -- Initialization
    NULL;
END API$ACCRUAL_TEST;
/