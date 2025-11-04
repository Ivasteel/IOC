/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$CALC_PD
IS
    g_save_job_messages   INTEGER := 2;

    TYPE Type_Rec_break IS RECORD
    (
        br_nst    NUMBER (14),
        br_dt     DATE
    );

    TYPE Table_break IS TABLE OF Type_Rec_break;

    g_break               Table_break := Table_break ();

    -- least без null як мінімального значення
    --========================================
    FUNCTION least_nn (dt1   DATE,
                       dt2   DATE DEFAULT NULL,
                       dt3   DATE DEFAULT NULL,
                       dt4   DATE DEFAULT NULL,
                       dt5   DATE DEFAULT NULL,
                       dt6   DATE DEFAULT NULL)
        RETURN DATE;

    --=========================================================--
    --  Розрахунки послуг
    --=========================================================--
    FUNCTION get_stop_date_664 (p_pd_pa          NUMBER,
                                p_ap_reg_dt      DATE,
                                p_ap_is_second   VARCHAR2)
        RETURN DATE;

    --=========================================================--

    FUNCTION get_death_sum (p_pd_id NUMBER, p_pdf_id NUMBER, p_death_dt DATE)
        RETURN NUMBER;

    --=========================================--
    FUNCTION Get_apri_income (p_pd            NUMBER,
                              p_sc            NUMBER,
                              p_list_inc_tp   VARCHAR2,
                              p_calc_dt       DATE,
                              p_start_dt      DATE)
        RETURN NUMBER;

    --
    FUNCTION Get_apri_income_stop_dt (p_pd            NUMBER,
                                      p_sc            NUMBER,
                                      p_list_inc_tp   VARCHAR2,
                                      p_calc_dt       DATE)
        RETURN DATE;

    --=========================================--
    --Розраховуємо суму допомоги як суму прожиткового мінімуму на дату розриву
    PROCEDURE COMPUTE_BY_SIMPLE_LGW;

    --
    PROCEDURE COMPUTE_BY_DIFF_INCOME_LGW;

    --
    PROCEDURE COMPUTE_BY_KOEF_LGW;

    --
    PROCEDURE COMPUTE_BY_CONST_SUM;

    --
    PROCEDURE COMPUTE_BY_LGW_LEVELING;

    --
    PROCEDURE COMPUTE_BY_INV_CATEGORY;

    --Розраховуємо суму допомоги для декретна відпустка
    PROCEDURE COMPUTE_BY_MATERNITY_LEAVE;

    --Розрахунок допомоги на дітей з багатодітної сім_ї
    PROCEDURE COMPUTE_BY_6YEARS;

    --Розраховуємо суму допомоги для прийомна сім'я
    PROCEDURE COMPUTE_BY_FOSTER_FM;

    --Розраховуємо суму допомоги для прийомна сім'я
    PROCEDURE COMPUTE_BY_FOSTER_FM_7DAY;

    --Розрахунок допомоги на поховання
    PROCEDURE COMPUTE_BY_DEAD;

    --Розрахунок "Новонароджена дитина"
    PROCEDURE COMPUTE_BY_NEWBORN;


    --=========================================================--
    --  Функція розрахунку виплат по проектам рішень на виплату
    --=========================================================--
    PROCEDURE calc_pd (p_mode              INTEGER, --1=з p_pd_id, 2=з таблиці TMP_IN_CALC_PD
                       p_pd_id             pc_decision.pd_id%TYPE,
                       p_ic_tp             VARCHAR2 DEFAULT 'R0',
                       p_ic_start_dt       DATE DEFAULT NULL,
                       p_ic_stop_dt        DATE DEFAULT NULL,
                       p_rc_ic             NUMBER DEFAULT NULL,
                       p_messages      OUT SYS_REFCURSOR);

    --=========================================================--
    --  Функція розрахунку виплат по проектам рішень на виплату
    --=========================================================--
    PROCEDURE calc_pd (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці TMP_IN_CALC_PD
                       p_pd_id          pc_decision.pd_id%TYPE,
                       p_messages   OUT SYS_REFCURSOR);

    --=========================================================--
    --  Функція розрахунку виплат по проектам рішень на виплату, для перерахунків
    --=========================================================--
    PROCEDURE calc_pd (p_rc_ic NUMBER);

    --=========================================================--
    --  Функція розрахунку виплат по проектам рішень на виплату
    --  p_pd_id    id рішення
    --  p_ic_tp    тип перерахунку:
    --             'RC.START_DT' - перерахунок по бюджетних показниках
    --  p_rc_dt    дата перерахунку
    --  p_messages інформація по розрахунку,
    --=========================================================--
    PROCEDURE calc_pd_RC (p_pd_id          pc_decision.pd_id%TYPE,
                          p_ic_tp          VARCHAR2,
                          p_rc_dt          DATE,
                          p_messages   OUT SYS_REFCURSOR);

    --========================================
    PROCEDURE Test_calc_pd (id        NUMBER DEFAULT NULL,
                            p_rc_ic   NUMBER DEFAULT NULL);

    --========================================
    FUNCTION Get_break
        RETURN Table_break
        PIPELINED;
--========================================
END API$CALC_PD;
/


/* Formatted on 8/12/2025 5:48:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$CALC_PD
IS
    g_messages   TOOLS.t_messages;
    G_hs         histsession.hs_id%TYPE;
    G_rc_id      NUMBER (14);

    -- least без null як мінімального значення
    --========================================
    FUNCTION least_nn (dt1   DATE,
                       dt2   DATE DEFAULT NULL,
                       dt3   DATE DEFAULT NULL,
                       dt4   DATE DEFAULT NULL,
                       dt5   DATE DEFAULT NULL,
                       dt6   DATE DEFAULT NULL)
        RETURN DATE
    AS
        ret   DATE;

        -----------------------------------------------------
        PROCEDURE compare (ret_dt IN OUT DATE, val_dt IN DATE)
        IS
        BEGIN
            IF ret_dt IS NULL
            THEN
                ret_dt := val_dt;
            ELSIF val_dt IS NOT NULL AND val_dt < ret_dt
            THEN
                ret_dt := val_dt;
            END IF;
        END;
    -----------------------------------------------------
    BEGIN
        ret := dt1;
        compare (ret, dt2);
        compare (ret, dt3);
        compare (ret, dt4);
        compare (ret, dt5);
        compare (ret, dt6);
        RETURN ret;
    END;

    --========================================
    FUNCTION Get_break
        RETURN Table_break
        PIPELINED
    IS
    BEGIN
        IF g_break.COUNT > 0
        THEN
            FOR i IN g_break.FIRST .. g_break.LAST
            LOOP
                PIPE ROW (g_break (i));
            END LOOP;
        END IF;

        RETURN;
    END;

    --========================================
    PROCEDURE Set_break (l_nst NUMBER, l_dt VARCHAR2)
    IS
        l_rec_break   Type_Rec_break;
    BEGIN
        g_break.EXTEND;
        l_rec_break.br_nst := l_nst;
        l_rec_break.br_dt := TO_DATE (l_dt, 'dd.mm.yyyy');
        g_break (g_break.COUNT) := l_rec_break;
    END;

    --=========================================================--
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

    --=========================================================--
    PROCEDURE write_pd_log (p_pdl_pd        pd_log.pdl_pd%TYPE,
                            p_pdl_hs        pd_log.pdl_hs%TYPE,
                            p_pdl_st        pd_log.pdl_st%TYPE,
                            p_pdl_message   pd_log.pdl_message%TYPE,
                            p_pdl_st_old    pd_log.pdl_st_old%TYPE,
                            p_pdl_tp        pd_log.pdl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --друга частина буде завжди виконуватись, неважливо перша is null чи is not null
        --а отже будуть кожний раз створюватись нові сесії
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

    --=========================================================--
    --  Чистимо допоміжні таблиці
    --=========================================================--
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

    --=========================================--
    FUNCTION Get_apri_income (p_pd            NUMBER,
                              p_sc            NUMBER,
                              p_list_inc_tp   VARCHAR2,
                              p_calc_dt       DATE,
                              p_start_dt      DATE)
        RETURN NUMBER
    IS
        ret   NUMBER;
    BEGIN
        --5 аліментів,
        --1 пенсії,
        --6 допомоги,
        --4, 28 стипендії – відсутній
        WITH
            itp_list
            AS
                (    SELECT REGEXP_SUBSTR (p_list_inc_tp,
                                           '[^,]+',
                                           1,
                                           LEVEL)    AS inc_tp
                       FROM DUAL
                 CONNECT BY LEVEL <=
                              LENGTH (
                                  REGEXP_REPLACE (p_list_inc_tp, '[^,]*'))
                            + 1),
            income
            AS
                (SELECT inc_tp,
                        API$Calc_Income.ToDate (
                            SUBSTR (TRIM (COLUMN_VALUE),
                                    1,
                                    INSTR (TRIM (COLUMN_VALUE), '=') - 1))
                            aim_month,
                        API$Calc_Income.ToNumber (
                            SUBSTR (TRIM (COLUMN_VALUE),
                                    INSTR (TRIM (COLUMN_VALUE), '=') + 1))
                            aim_sum,
                        API$ACCOUNT.get_docx_507_start_dt (p_pd,
                                                           p_sc,
                                                           inc_tp,
                                                           p_calc_dt)
                            AS x_start_dt
                   FROM itp_list,
                        XMLTABLE (
                            (   '"'
                             || REPLACE (
                                    REGEXP_REPLACE (
                                        API$ACCOUNT.get_docx_507_string (
                                            p_pd,
                                            p_sc,
                                            inc_tp,
                                            p_calc_dt),
                                        CHR (13) || '|' || CHR (10),
                                        ''),
                                    ',',
                                    '","')
                             || '"'))),
            inc_mn
            AS
                (SELECT inc_tp, aim_month, aim_sum
                   FROM income
                  --WHERE trunc(aim_month,'MM')  = trunc(add_months(p_start_dt, -1),'MM')
                  WHERE TRUNC (aim_month, 'MM') =
                        TRUNC (ADD_MONTHS (x_start_dt, -1), 'MM')) /*,
                                                      last_inc AS (SELECT DISTINCT inc_tp,
                                                                          last_value (aim_sum) OVER (PARTITION BY inc_tp
                                                                                                     ORDER BY aim_month ASC
                                                                                                     RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_aim_sum
                                                                   FROM income
                                                                  )*/
        SELECT SUM (aim_sum)
          INTO ret
          FROM inc_mn;

        RETURN NVL (ret, 0);
    END;

    --=========================================--
    FUNCTION Get_apri_income_stop_dt (p_pd            NUMBER,
                                      p_sc            NUMBER,
                                      p_list_inc_tp   VARCHAR2,
                                      p_calc_dt       DATE)
        RETURN DATE
    IS
        ret   DATE;
    BEGIN
        --5 аліментів,
        --1 пенсії,
        --6 допомоги,
        --4, 28 стипендії – відсутній
        WITH
            itp_list
            AS
                (    SELECT REGEXP_SUBSTR (p_list_inc_tp,
                                           '[^,]+',
                                           1,
                                           LEVEL)    AS inc_tp
                       FROM DUAL
                 CONNECT BY LEVEL <=
                              LENGTH (
                                  REGEXP_REPLACE (p_list_inc_tp, '[^,]*'))
                            + 1),
            income
            AS
                (SELECT inc_tp,
                        API$Calc_Income.ToDate (
                            SUBSTR (TRIM (COLUMN_VALUE),
                                    1,
                                    INSTR (TRIM (COLUMN_VALUE), '=') - 1))
                            aim_month,
                        API$Calc_Income.ToNumber (
                            SUBSTR (TRIM (COLUMN_VALUE),
                                    INSTR (TRIM (COLUMN_VALUE), '=') + 1))
                            aim_sum,
                        API$ACCOUNT.get_docx_507_start_dt (p_pd,
                                                           p_sc,
                                                           inc_tp,
                                                           p_calc_dt)
                            AS x_start_dt
                   FROM itp_list,
                        XMLTABLE (
                            (   '"'
                             || REPLACE (
                                    REGEXP_REPLACE (
                                        API$ACCOUNT.get_docx_507_string (
                                            p_pd,
                                            p_sc,
                                            inc_tp,
                                            p_calc_dt),
                                        CHR (13) || '|' || CHR (10),
                                        ''),
                                    ',',
                                    '","')
                             || '"'))),
            inc_mn
            AS
                (SELECT inc_tp, aim_month, aim_sum
                   FROM income
                  WHERE NVL (aim_sum, 0) > 0)
        SELECT MAX (aim_month)
          INTO ret
          FROM inc_mn;

        IF ret IS NOT NULL
        THEN
            ret := TRUNC (ADD_MONTHS (ret, 1), 'MM');
        END IF;

        RETURN ret;
    END;

    --=========================================--
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
    FUNCTION get_start_date_248 (p_pd_pa          NUMBER,
                                 p_ap_reg_dt      DATE,
                                 p_ap_is_second   VARCHAR2)
        RETURN DATE
    IS
        ret_dt   DATE;
    BEGIN
        SELECT NVL (MAX (pd.pd_stop_dt + 1), p_ap_reg_dt)
          INTO ret_dt
          FROM pc_decision pd
         WHERE pd.pd_pa = p_pd_pa AND pd.pd_st = 'S';

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
    --#98188
    /*
    Якщо в зверненні по послузі з Ід=664 (тип V-допомога) встановлено "так" в "Ознака повторного", то:
      якщо у зверненні "Дата подання заяви" за період до 30.09.2023 включно, то період призначення до 29.02.2024 (дата буде в подовженні - обговорити)
      якщо у зверненні "Дата подання заяви" за період після 01.10.2023 включно і до 29.02.2024 включно
          і наявні інші рішення, які діяли до 01.10.2023, то період призначення до 29.02.2024 (дата буде в подовженні - обговорити)
      якщо у зверненні "Дата подання заяви" за період після 01.10.2023 включно і до 29.02.2024 включно
          і відсутні рішення, які діяли до 01.10.2023, то період призначення 6 місяців з дати першого рішення в період з 01.10.2023 включно і до 29.02.2024
    */
    FUNCTION get_stop_date_664 (p_pd_pa          NUMBER,
                                p_ap_reg_dt      DATE,
                                p_ap_is_second   VARCHAR2)
        RETURN DATE
    IS
        l_cnt    NUMBER;
        ret_dt   DATE;
    BEGIN
        --   dbms_output_put_lines ('get_stop_date_664('||p_pd_pa||', '||p_ap_reg_dt||', '||p_ap_is_second||')');

        IF     NVL (p_ap_is_second, 'F') = 'T'
           AND p_ap_reg_dt <= TO_DATE ('30.09.2023', 'dd.mm.yyyy')
        THEN
            ret_dt := TO_DATE ('29.02.2024', 'dd.mm.yyyy') + 1;
            dbms_output_put_lines (
                'get_stop_date_664()  p_ap_reg_dt <= 30.09.2023');
        ELSIF     NVL (p_ap_is_second, 'F') = 'T'
              AND p_ap_reg_dt <= TO_DATE ('29.02.2024', 'dd.mm.yyyy')
        THEN
            dbms_output_put_lines (
                'get_stop_date_664()  p_ap_reg_dt <= 29.02.2024');

            SELECT COUNT (1)
              INTO l_cnt
              FROM pc_decision  pd
                   JOIN pd_accrual_period pdap
                       ON     pdap.pdap_pd = pd.pd_id
                          AND pdap.history_status = 'A'
             WHERE     pd.pd_pa = p_pd_pa
                   AND pd.pd_st IN ('S', 'PS')
                   AND EXISTS
                           (SELECT 1
                              FROM pd_accrual_period pdap
                             WHERE     pdap.pdap_pd = pd.pd_id
                                   AND pdap.history_status = 'A'
                                   AND pdap.pdap_start_dt <
                                       TO_DATE ('01.10.2023', 'dd.mm.yyyy'))--        AND NOT EXISTS (SELECT 1
                                                                            --                        FROM pd_accrual_period pdap
                                                                            --                        WHERE pdap.pdap_pd = pd.pd_id
                                                                            --                          AND pdap.history_status = 'A'
                                                                            --                          AND pdap.pdap_stop_dt > to_date('01.10.2023', 'dd.mm.yyyy'))
                                                                            ;

            IF l_cnt > 0
            THEN
                ret_dt := TO_DATE ('29.02.2024', 'dd.mm.yyyy') + 1;
            ELSE
                SELECT ADD_MONTHS (MAX (pd.pd_start_dt), 6)
                  INTO ret_dt
                  FROM pc_decision pd
                 WHERE     pd.pd_pa = p_pd_pa
                       AND pd.pd_st IN ('S', 'PS')
                       AND pd.pd_start_dt BETWEEN TO_DATE ('01.10.2023',
                                                           'dd.mm.yyyy')
                                              AND TO_DATE ('29.02.2024',
                                                           'dd.mm.yyyy');

                IF ret_dt IS NULL
                THEN
                    ret_dt := ADD_MONTHS (TRUNC (p_ap_reg_dt, 'MM'), 6);
                END IF;
            END IF;
        ELSIF     NVL (p_ap_is_second, 'F') = 'T'
              AND p_ap_reg_dt > TO_DATE ('01.03.2024', 'dd.mm.yyyy')
        THEN
            dbms_output_put_lines (
                'get_stop_date_664()  p_ap_reg_dt > 01.03.2024');

            SELECT MAX (pd.pd_stop_dt) + 1
              INTO ret_dt
              FROM pc_decision pd
             WHERE     pd.pd_pa = p_pd_pa
                   AND pd.pd_st IN ('S', 'PS')
                   AND pd.pd_start_dt BETWEEN TO_DATE ('01.03.2024',
                                                       'dd.mm.yyyy')
                                          AND TO_DATE ('01.08.2024',
                                                       'dd.mm.yyyy');

            IF ret_dt IS NULL
            THEN
                ret_dt := ADD_MONTHS (TRUNC (p_ap_reg_dt, 'MM'), 6);
            END IF;
        ELSE
            dbms_output_put_lines ('get_stop_date_664 = ELSE');
            ret_dt := ADD_MONTHS (TRUNC (p_ap_reg_dt, 'MM'), 6);
        END IF;

        RETURN ret_dt;
    END;

    --=========================================================--
    FUNCTION get_death_sum (p_pd_id NUMBER, p_pdf_id NUMBER, p_death_dt DATE)
        RETURN NUMBER
    IS
        l_ret   NUMBER;
    BEGIN
        SELECT SUM (pdd.pdd_value)
          INTO l_ret
          FROM pd_payment  pdp
               JOIN pd_detail pdd
                   ON pdd.pdd_pdp = pdp.pdp_id AND pdd.pdd_key = p_pdf_id
         WHERE     pdp.pdp_pd = p_pd_id
               AND pdp.history_status = 'A'
               AND p_death_dt BETWEEN pdp.pdp_start_dt AND pdp.pdp_stop_dt
               AND (pdp_npt = 1 OR (pdp_npt != 1 AND pdd_npt != 219));

        RETURN l_ret;
    END;

    --=========================================================--
    FUNCTION is_have_nst_by_alg (p_alg_tp VARCHAR2, p_alg_value VARCHAR2)
        RETURN INTEGER
    IS
        l_cnt   INTEGER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_pd_calc_params
               JOIN pc_decision ON pd_id = xpd_id
               JOIN uss_ndi.v_ndi_nst_calc_config ncc ON pd_nst = ncc_nst
         WHERE     xpd_calc_dt BETWEEN ncc.ncc_start_dt AND ncc.ncc_stop_dt
               AND (   (    p_alg_tp = 'CALC_PERIOD'
                        AND ncc_calc_period = p_alg_value)
                    OR (    p_alg_tp = 'APP_GROUP'
                        AND ncc_app_group = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_LGW'
                        AND ncc_break_lgw = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_BIRTH'
                        AND ncc_break_birth = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_1YEARS'
                        AND ncc_break_1years = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_6YEARS'
                        AND ncc_break_6years = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_18YEARS'
                        AND ncc_break_18years = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_23YEARS'
                        AND ncc_break_23years = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_60YEARS'
                        AND ncc_break_60years = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_INV'
                        AND ncc_break_inv = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_SICK'
                        AND ncc_break_sick = p_alg_value)
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
                    OR (    p_alg_tp = 'BREAK_PD_PERIOD_ALG'
                        AND ncc_pd_period_alg = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_STUDY'
                        AND ncc_break_study = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_INCOME'
                        AND ncc_break_income = p_alg_value)
                    OR (    p_alg_tp = 'BREAK_CRTF_WR_PRT'
                        AND ncc_break_crtf_wr_prt = p_alg_value)
                    OR 1 = 2);

        RETURN l_cnt;
    END;

    --=========================================================--
    --Отримання параметрів рішення та звернення
    PROCEDURE obtain_pd_calc_params
    IS
    BEGIN
        dbms_output_put_lines ('obtain_pd_calc_params');

        INSERT INTO tmp_pd_calc_params (xpd_id,
                                        xpd_ap,
                                        xpd_nst,
                                        xpd_ap_reg_dt,
                                        xpd_calc_alg,
                                        xpd_mount_live,
                                        xpd_family_income,
                                        xpd_members_income,
                                        xpd_pc,
                                        xpd_src,
                                        xpd_start_dt,
                                        xpd_calc_dt,
                                        xpd_ic_tp)
            SELECT pd_id,
                   pd_ap,
                   pd_nst,
                   TRUNC (
                       CASE
                           WHEN pd_nst = 269 --!!! Какая-то хрень. Почему MAX, а не MIN?
                           THEN
                               (SELECT NVL (
                                           MIN (
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
                       END)                     AS ap_reg_dt,
                   ncc_calc_alg,
                   NVL (
                       API$PC_DECISION.get_ap_z_doc_string (ap_id, 605, -999),
                       'F')                     AS is_mount, --стан Проживає в гірському НП ---!!!! ще немає в Анкеті - 605.
                   NVL (pic_month_income, 0)    AS x_month_income, --Середньомісячний сукупний дохід
                   pic_member_month_income, --Середньомісячний дохід на члена сімї
                   --NVL(pic_member_month_income, 0), --Середньомісячний дохід на члена сімї
                   pd_pc,
                   pd_src,
                   TRUNC (
                       CASE
                           WHEN pd_nst = 1201
                           THEN
                               pd_start_dt
                           WHEN ic_tp = 'RC.START_DT'
                           THEN
                               ic_start_dt
                           WHEN pd_nst = 20
                           THEN
                               TO_DATE ('01.06.2023', 'dd.mm.yyyy')
                           WHEN pd_nst = 21
                           THEN
                               TRUNC (ap_reg_dt, 'MM')
                           WHEN pd_nst = 23
                           THEN
                               (SELECT NVL (
                                           MIN (
                                               API$PC_DECISION.get_doc_dt (
                                                   app_id,
                                                   10342,
                                                   8625)),
                                           ap_reg_dt)
                                  FROM ap_person app
                                 WHERE     app_tp = 'Z'
                                       AND history_status = 'A'
                                       AND app_ap = ap_id)
                           --ньому обов''язково є документ з Ід=10035, у ньому два атрибути з датами Ід=907 і Ід=908,
                           --перерахунок слід робити з першого числа місяця, який більш ранній з двох у атрибутах   Ід=907 і Ід=908
                           WHEN pd_nst = 248 AND pd_src = 'SA'
                           THEN
                               COALESCE (
                                   (SELECT TRUNC (
                                               API$CALC_PD.least_nn (
                                                   API$PC_DECISION.get_doc_dt (
                                                       app_id,
                                                       10035,
                                                       907),
                                                   API$PC_DECISION.get_doc_dt (
                                                       app_id,
                                                       10035,
                                                       908),
                                                   ADD_MONTHS (
                                                       API$PC_DECISION.get_doc_dt (
                                                           app_id,
                                                           10034,
                                                           923),
                                                       1)),
                                               'MM')
                                      FROM ap_person app
                                     WHERE     app_tp = 'O'
                                           AND history_status = 'A'
                                           AND app_ap = pd.pd_ap),
                                   (SELECT TRUNC (
                                               API$CALC_PD.least_nn (
                                                   API$PC_DECISION.get_doc_dt (
                                                       app_id,
                                                       10035,
                                                       907),
                                                   API$PC_DECISION.get_doc_dt (
                                                       app_id,
                                                       10035,
                                                       908),
                                                   ADD_MONTHS (
                                                       API$PC_DECISION.get_doc_dt (
                                                           app_id,
                                                           10034,
                                                           923),
                                                       1)),
                                               'MM')
                                      FROM ap_person app
                                     WHERE     app_tp = 'O'
                                           AND history_status = 'A'
                                           AND app_ap = pd.pd_ap_reason),
                                   pd_start_dt)
                           WHEN pd_nst = 248
                           THEN
                               pd_start_dt
                           WHEN pd_nst = 250
                           THEN
                               (SELECT TRUNC (
                                           NVL (
                                               MAX (
                                                   API$PC_DECISION.get_doc_dt (
                                                       app_id,
                                                       37,
                                                       91)),
                                               ap_reg_dt),
                                           'MM')
                                  FROM ap_person app
                                 WHERE     app_tp != 'Z'
                                       AND history_status = 'A'
                                       AND app_ap = ap_id
                                       AND API$PC_DECISION.get_doc_string (
                                               app_id,
                                               605,
                                               8458) =
                                           ''--API$ACCOUNT.get_docx_string(tc_pd, tc_sc, 605,  8458, tc_calc_dt, 'F')
                                             )
                           WHEN pd_nst = 251
                           THEN
                               (SELECT COALESCE (
                                           MAX (api$calc_pd.Get_apri_income_stop_dt (
                                                    pd_id,
                                                    app_sc,
                                                    '1,4,5,28',
                                                    ap_reg_dt)),
                                           MAX (
                                               API$PC_DECISION.get_doc_dt (
                                                   app_id,
                                                   10196,
                                                   2579)),
                                           ap_reg_dt)
                                  FROM ap_person app
                                 WHERE     app_tp = 'Z'
                                       AND history_status = 'A'
                                       AND app_ap = ap_id)
                           WHEN pd_nst = 265
                           THEN
                               API$PC_DECISION.get_start_date_265 (
                                   pd.pd_pa,
                                   ap_reg_dt,
                                   ap_is_second)
                           WHEN     pd_nst = 269
                                AND ADD_MONTHS (ap_reg_dt, -12) >
                                    (SELECT NVL (
                                                MIN (
                                                    API$PC_DECISION.get_doc_dt (
                                                        app_id,
                                                        114,
                                                        708)),
                                                ap_reg_dt)
                                       FROM ap_person app
                                      WHERE     app_tp = 'FP'
                                            AND history_status = 'A'
                                            AND app_ap = ap_id)
                           THEN
                               TO_DATE (NULL) -- це не корректна ситуація, рахувати не потрібно
                           WHEN pd_nst = 269
                           THEN
                               TRUNC (
                                   (SELECT NVL (
                                               MIN (
                                                   API$PC_DECISION.get_doc_dt (
                                                       app_id,
                                                       114,
                                                       708)),
                                               ap_reg_dt)
                                      FROM ap_person app
                                     WHERE     app_tp = 'FP'
                                           AND history_status = 'A'
                                           AND app_ap = ap_id),
                                   'MM')
                           WHEN pd_nst = 275
                           THEN
                               (SELECT NVL (
                                           MIN (
                                               COALESCE (
                                                   API$PC_DECISION.get_doc_dt (
                                                       app_id,
                                                       661,
                                                       2666),
                                                   API$PC_DECISION.get_doc_dt (
                                                       app_id,
                                                       662,
                                                       2667))),
                                           ap_reg_dt)
                                  FROM ap_person app
                                 WHERE     app_tp = 'FP'
                                       AND history_status = 'A'
                                       AND app_ap = ap_id)
                           WHEN pd_nst = 901
                           THEN
                               (SELECT NVL (
                                           MAX (
                                               API$PC_DECISION.get_doc_dt (
                                                   app_id,
                                                   10205,
                                                   2688)),
                                           ap_reg_dt)
                                  FROM ap_person app
                                 WHERE     app_tp = 'FP'
                                       AND history_status = 'A'
                                       AND app_ap = ap_id)
                           --WHEN pd_nst = 1201 THEN

                           WHEN pd_nst = 241
                           THEN
                               TRUNC (ap_reg_dt, 'MM')
                           ELSE
                               pd_start_dt
                       END)                     AS pd_start_dt,
                   --pd_start_dt,
                   CASE
                       WHEN pd_nst = 1201
                       THEN
                           pd_start_dt
                       WHEN ic_tp = 'RC.START_DT' AND ic_start_dt < ap_reg_dt
                       THEN
                           ap_reg_dt
                       WHEN ic_tp = 'RC.START_DT'
                       THEN
                           ic_start_dt
                       WHEN pd_nst = 23
                       THEN
                           (SELECT MIN (t.tpp_dt_from)
                              FROM tmp_pa_persons t
                             WHERE t.tpp_pd = pd.pd_id)
                       WHEN     pd_nst = 664
                            AND ap_reg_dt_prev IS NOT NULL
                            AND ap_reg_dt_prev > ap_reg_dt
                            AND pd.pd_ap = pd.pd_ap_reason
                       THEN                                          --#103949
                           ap_reg_dt_prev
                       WHEN pd_ap_reason IS NOT NULL
                       THEN
                           (SELECT MAX (ap_r.ap_reg_dt)
                              FROM appeal ap_r
                             WHERE ap_r.ap_id = pd_ap_reason)
                       ELSE
                           ap_reg_dt
                   END                          AS x_calc_dt,
                   ic_tp
              FROM tmp_in_calc_pd
                   JOIN pc_decision pd ON pd_id = ic_pd
                   JOIN (SELECT ap_id,
                                ap_reg_dt,
                                ap_is_second,
                                (SELECT MAX (a.apda_val_dt)
                                   FROM ap_document_attr  a
                                        JOIN ap_document d
                                            ON     d.apd_id = a.apda_apd
                                               AND d.history_status = 'A'
                                               AND d.apd_ap = ap_id
                                  WHERE a.apda_nda = 7902)    AS ap_reg_dt_prev
                           FROM appeal)
                       ON pd_ap = ap_id
                   JOIN uss_ndi.v_ndi_nst_calc_config ncc
                       ON     pd_nst = ncc_nst
                          AND ap_reg_dt BETWEEN ncc.ncc_start_dt
                                            AND ncc.ncc_stop_dt
                   LEFT JOIN pd_income_calc pic ON pic_pd = pd_id;

        UPDATE tmp_pd_calc_params
           SET xpd_start_dt =
                   (SELECT CASE
                               WHEN x_10035_dt IS NULL AND x_10034_dt IS NULL
                               THEN
                                   xpd_start_dt
                               WHEN x_10035_dt IS NULL
                               THEN
                                   x_10034_dt
                               WHEN x_10034_dt IS NULL
                               THEN
                                   x_10035_dt
                               WHEN x_10035_dt > x_10034_dt
                               THEN
                                   x_10035_dt
                               ELSE
                                   x_10034_dt
                           END
                      FROM (SELECT LEAST (NVL (API$ACCOUNT.get_docx_dt_min (
                                                   xpd_id,
                                                   NULL,
                                                   10035,
                                                   907,
                                                   xpd_calc_dt),
                                               TO_DATE ('3000', 'yyyy')),
                                          NVL (API$ACCOUNT.get_docx_dt_min (
                                                   xpd_id,
                                                   NULL,
                                                   10035,
                                                   908,
                                                   xpd_calc_dt),
                                               TO_DATE ('3000', 'yyyy')))
                                       AS x_10035_dt,
                                   TRUNC (ADD_MONTHS (API$ACCOUNT.get_docx_dt_min (
                                                          xpd_id,
                                                          NULL,
                                                          10034,
                                                          923,
                                                          xpd_calc_dt),
                                                      1),
                                          'MM')
                                       AS x_10034_dt
                              FROM DUAL))
         WHERE xpd_src = 'SA' AND xpd_nst = 248;
    END;

    --=========================================================--
    --Отримання параметрів рішення та звернення
    PROCEDURE obtain_pd_family
    IS
    BEGIN
        IF is_have_nst_by_alg ('APP_GROUP', 'PER_APP') > 0
        THEN
            SaveMessage ('Видаляємо всіх утриманців з рішення');

            DELETE FROM pd_family
                  WHERE     EXISTS
                                (SELECT 1
                                   FROM tmp_pd_calc_params,
                                        uss_ndi.v_ndi_nst_calc_config  ncc
                                  WHERE     xpd_id = pdf_pd
                                        AND xpd_nst = ncc_nst
                                        AND ncc_app_group = 'PER_APP'
                                        AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                            AND ncc.ncc_stop_dt)
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM tmp_pd_calc_params p
                                  WHERE     xpd_id = pdf_pd
                                        AND p.xpd_ic_tp = 'RC.START_DT')
                        AND history_status = 'A';

            SaveMessage (
                'Добавляємо тих утримацнців зі звернення, яких немає в рішенні');

            INSERT INTO pd_family (pdf_id,
                                   pdf_sc,
                                   pdf_pd,
                                   pdf_birth_dt,
                                   history_status,
                                   pdf_tp,
                                   pdf_hs_ins,
                                   pdf_start_dt,
                                   pdf_stop_dt)
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
                           uss_person.api$sc_tools.get_birthdate (tpp_sc)),
                       'A',
                       'NOT',
                       g_hs,
                       tpp_dt_from,
                       tpp_dt_to
                  FROM tmp_pd_calc_params
                       JOIN tmp_pa_persons p ON tpp_pd = xpd_id --AND xpd_calc_dt BETWEEN tpp_dt_from AND tpp_dt_to
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                 WHERE     (   (ncc_app_list_alg = 'FP' AND tpp_app_tp = 'FP')
                            OR (    ncc_app_list_alg = 'FML'
                                AND tpp_app_tp IN ('Z',
                                                   'FM',
                                                   'FP',
                                                   'DU'))
                            OR (    ncc_app_list_alg = 'FML+ANF'
                                AND tpp_app_tp IN ('Z',
                                                   'FM',
                                                   'FP',
                                                   'ANF'))
                            OR (    ncc_app_list_alg = 'Z+FP'
                                AND tpp_app_tp IN ('Z', 'FP'))
                            OR (    ncc_app_list_alg = 'Z+DP'
                                AND tpp_app_tp IN ('Z', 'DP')))
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND ncc_app_group = 'PER_APP'
                       AND (NOT EXISTS
                                (SELECT 1
                                   FROM pd_family pdf
                                  WHERE     pdf_pd = xpd_id
                                        AND pdf_sc = tpp_sc
                                        AND pdf.history_status = 'A'
                                        AND (   pdf_start_dt = tpp_dt_from
                                             OR xpd_nst = 249)));

            UPDATE pd_family f
               SET f.pdf_stop_dt =
                       (SELECT p.tpp_dt_to
                          FROM tmp_pa_persons p
                         WHERE     tpp_pd = f.pdf_pd
                               AND p.tpp_sc = f.pdf_sc
                               AND p.tpp_dt_from = f.pdf_start_dt)
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_pd_calc_params t
                             WHERE     t.xpd_id = f.pdf_pd
                                   AND t.xpd_nst IN (275, 901))
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_pa_persons p
                             WHERE     tpp_pd = f.pdf_pd
                                   AND p.tpp_sc = f.pdf_sc
                                   AND p.tpp_dt_from = f.pdf_start_dt);


            ---Шукаємо попередне рішення для 248 та віку 18 років
            UPDATE tmp_pd_calc_params
               SET (                                        /*xpd_start_dt ,*/
                    xpd_prev_pd, xpd_prev_stop_dt, xpd_prev_summ) =
                       (SELECT       /*nvl(old_pdp_stop_dt+1, xpd_start_dt),*/
                               old_pdf_pd, old_pdp_stop_dt, old_SUM
                          FROM (  SELECT                           --f.pdf_sc,
                                         ff.pdf_pd                                 AS old_pdf_pd,
                                         pdp.pdp_stop_dt                           AS old_pdp_stop_dt,
                                         SUM (pdd.pdd_value)                       AS old_SUM,
                                         --SUM(pdd.pdd_value) OVER (PARTITION BY ff.pdf_pd ORDER BY pdp.pdp_stop_dt DESC) AS old_SUM,
                                         ROW_NUMBER ()
                                             OVER (
                                                 PARTITION BY ff.pdf_pd
                                                 ORDER BY pdp.pdp_stop_dt DESC)    AS rn
                                    FROM pd_family f
                                         JOIN tmp_pa_persons
                                             ON     tpp_pd = pdf_pd
                                                AND tpp_sc = pdf_sc
                                                AND tpp_app_tp = 'Z'
                                         JOIN pd_family ff
                                             ON     ff.pdf_sc = f.pdf_sc
                                                AND ff.pdf_pd != f.pdf_pd
                                                AND ff.history_status = 'A'
                                         JOIN pc_decision pd
                                             ON     pd.pd_id = ff.pdf_pd
                                                AND pd.pd_nst = 248
                                                AND pd.pd_st IN ('S', 'PS')
                                         LEFT JOIN pd_payment pdp
                                             ON     pdp.pdp_pd = pd.pd_id
                                                AND pdp.pdp_npt = 1
                                                AND pdp.history_status = 'A'
                                         LEFT JOIN pd_detail pdd
                                             ON     pdd.pdd_pdp = pdp.pdp_id
                                                AND pdd.pdd_npt = 219
                                   WHERE     f.pdf_pd = xpd_id
                                         AND f.history_status = 'A'
                                         --AND xpd_ap_reg_dt  BETWEEN ADD_MONTHS(f.pdf_birth_dt, 216) AND ADD_MONTHS(f.pdf_birth_dt, 228)-1
                                         AND xpd_start_dt BETWEEN ADD_MONTHS (
                                                                      f.pdf_birth_dt,
                                                                      216)
                                                              AND   ADD_MONTHS (
                                                                        f.pdf_birth_dt,
                                                                        228)
                                                                  - 1
                                GROUP BY                         /*f.pdf_sc,*/
                                         ff.pdf_pd, pdp.pdp_stop_dt)
                         WHERE rn < 2
                         FETCH FIRST ROWS ONLY)
             WHERE     xpd_ic_tp = 'R0'
                   AND xpd_nst = 248
                   AND EXISTS
                           (SELECT 1
                              FROM pd_family
                                   JOIN tmp_pa_persons
                                       ON     tpp_pd = pdf_pd
                                          AND tpp_sc = pdf_sc
                                          AND tpp_app_tp = 'Z'
                                   JOIN pc_decision
                                       ON     pd_id = pdf_pd
                                          AND pd_ap = pd_ap_reason
                             WHERE     pdf_pd = xpd_id
                                   AND pd_family.history_status = 'A'
                                   AND XPD_AP_REG_DT BETWEEN ADD_MONTHS (
                                                                 pdf_birth_dt,
                                                                 216)
                                                         AND   ADD_MONTHS (
                                                                   pdf_birth_dt,
                                                                   228)
                                                             - 1);

            ---Шукаємо попередне рішення для 250
            UPDATE tmp_pd_calc_params
               SET (xpd_prev_pd, xpd_prev_stop_dt) =
                       (SELECT old_pd_id, old_pd_stop_dt
                          FROM (SELECT pd.pd_id                             AS old_pd_id, -- pd.pd_stop_dt  AS old_pd_stop_dt,
                                       TRUNC (API$ACCOUNT.get_docx_dt (
                                                  z.tpp_pd,
                                                  z.tpp_sc,
                                                  605,
                                                  8543,
                                                  xpd_calc_dt),
                                              'MM')                         AS old_pd_stop_dt,
                                       ROW_NUMBER ()
                                           OVER (PARTITION BY xpd_id
                                                 ORDER BY pd.pd_id DESC)    AS rn
                                  FROM tmp_pd_calc_params
                                       JOIN tmp_pa_persons z
                                           ON     z.tpp_pd = xpd_id
                                              AND z.tpp_app_tp = 'Z'
                                       JOIN tmp_pa_persons fp
                                           ON     fp.tpp_pd = xpd_id
                                              AND fp.tpp_app_tp = 'FP'
                                       JOIN pd_family f
                                           ON     f.pdf_sc = fp.tpp_sc
                                              AND f.history_status = 'A'
                                       JOIN pc_decision pd
                                           ON     pd.pd_id = f.pdf_pd
                                              AND pd.pd_nst = 250
                                              AND pd.pd_id != xpd_id
                                              AND pd.pd_st IN ('S', 'PS')
                                 WHERE xpd_nst = 250)
                         WHERE rn < 2
                         FETCH FIRST ROWS ONLY)
             WHERE     xpd_nst = 250
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_pa_persons tpp
                             WHERE     tpp_pd = xpd_id
                                   AND tpp_app_tp = 'Z'
                                   AND API$ACCOUNT.get_docx_dt (tpp_pd,
                                                                tpp_sc,
                                                                605,
                                                                8543,
                                                                xpd_calc_dt)
                                           IS NOT NULL);



            ---Шукаємо попередне рішення для 248 та віку 18 років
            UPDATE tmp_pd_calc_params
               SET (                                        /*xpd_start_dt ,*/
                    xpd_prev_pd, xpd_prev_stop_dt, xpd_prev_summ) =
                       (SELECT       /*nvl(old_pdp_stop_dt+1, xpd_start_dt),*/
                               old_pdf_pd, old_pdp_stop_dt, old_SUM
                          FROM (SELECT                             --f.pdf_sc,
                                       ff.pdf_pd                                 AS old_pdf_pd,
                                       pdp.pdp_stop_dt                           AS old_pdp_stop_dt,
                                       pdp.pdp_sum                               AS old_SUM,
                                       ROW_NUMBER ()
                                           OVER (
                                               PARTITION BY ff.pdf_pd
                                               ORDER BY pdp.pdp_stop_dt DESC)    AS rn
                                  FROM pd_family  f
                                       JOIN tmp_pa_persons
                                           ON     tpp_pd = pdf_pd
                                              AND tpp_sc = pdf_sc
                                              AND tpp_app_tp = 'Z'
                                       JOIN pd_family ff
                                           ON     ff.pdf_sc = f.pdf_sc
                                              AND ff.pdf_pd != f.pdf_pd
                                              AND ff.history_status = 'A'
                                       JOIN pc_decision pd
                                           ON     pd.pd_id = ff.pdf_pd
                                              AND pd.pd_nst = 901
                                              AND pd.pd_st IN ('S', 'PS')
                                       LEFT JOIN pd_payment pdp
                                           ON     pdp.pdp_pd = pd.pd_id
                                              AND pdp.pdp_npt = 839
                                              AND pdp.history_status = 'A'
                                 WHERE     f.pdf_pd = xpd_id
                                       AND f.history_status = 'A'
                                       AND xpd_start_dt > pdp.pdp_stop_dt)
                         WHERE rn < 2
                         FETCH FIRST ROWS ONLY)
             WHERE xpd_ic_tp = 'R0' AND xpd_nst = 23;

            ---Шукаємо попередне рішення для 1201
            UPDATE tmp_pd_calc_params t
               SET (xpd_prev_pd, xpd_prev_stop_dt, xpd_prev_summ) =
                       (SELECT pd_id, old_pdp_stop_dt, old_SUM
                          FROM (SELECT opd.pd_id,
                                       pdp.pdp_stop_dt                           AS old_pdp_stop_dt,
                                       pdp.pdp_sum                               AS old_SUM,
                                       ROW_NUMBER ()
                                           OVER (
                                               PARTITION BY opd.pd_id
                                               ORDER BY pdp.pdp_stop_dt DESC)    AS rn
                                  FROM pc_decision  npd
                                       JOIN pc_decision opd
                                           ON opd.pd_id = npd.pd_src_id
                                       LEFT JOIN pd_payment pdp
                                           ON     pdp.pdp_pd = opd.pd_id
                                              AND pdp.pdp_npt IN (839, 854)
                                              AND pdp.history_status = 'A'
                                 WHERE npd.pd_id = t.xpd_id)
                         WHERE rn < 2
                         FETCH FIRST ROWS ONLY)
             WHERE xpd_nst = 1201;

            UPDATE tmp_pd_calc_params t
               SET t.xpd_prev_start_dt =
                       (SELECT MIN (pdp.pdp_start_dt)
                          FROM pd_payment pdp
                         WHERE     pdp.pdp_pd = t.xpd_prev_pd
                               AND pdp.pdp_npt IN (839, 854)
                               AND pdp.history_status = 'A')
             WHERE xpd_nst = 1201;


            ---Шукаємо попередне рішення 248 для померлої особи
            /*    UPDATE tmp_pd_calc_params  SET
                    (xpd_prev_pd, xpd_prev_stop_dt, xpd_prev_summ) =
                    ( SELECT old_pdf_pd, old_pdp_stop_dt, old_SUM
                      FROM  (   SELECT --f.pdf_sc,
                                       ff.pdf_pd        AS old_pdf_pd,
                                       pdp.pdp_stop_dt  AS old_pdp_stop_dt,
                                       SUM(pdp.pdp_sum) AS old_SUM,
                                       row_number() OVER (PARTITION BY ff.pdf_pd ORDER BY pdp.pdp_stop_dt DESC)  AS rn
                                FROM pd_family f
                                     JOIN tmp_pa_persons ON tpp_pd = pdf_pd AND tpp_sc = pdf_sc AND tpp_app_tp = 'DP'
                                     JOIN pd_family ff ON ff.pdf_sc = f.pdf_sc AND ff.pdf_pd != f.pdf_pd
                                     JOIN pc_decision pd ON pd.pd_id = ff.pdf_pd AND pd.pd_nst = 248 AND pd.pd_st IN ('S', 'PS')
                                     LEFT JOIN pd_payment pdp ON pdp.pdp_pd = pd.pd_id AND pdp.history_status = 'A'
                                                                 AND xpd_start_dt  BETWEEN pdp.pdp_start_dt AND pdp.pdp_stop_dt
                                WHERE f.pdf_pd = xpd_id
                                GROUP BY ff.pdf_pd, pdp.pdp_stop_dt
                            )
                      WHERE rn < 2
                      FETCH FIRST rows ONLY
                    )
                  WHERE xpd_ic_tp = 'R0'
                    and xpd_nst = 241;*/


            MERGE INTO pd_source pds
                 USING (SELECT NVL (so.pds_id, 0)                               AS x_pds,
                               xpd_prev_pd,
                               'DP'                                             AS x_tp,
                               xpd_ap,
                               api$appeal.Get_ap_Doc_Dt (xpd_ap, 'DP', /*10295,*/
                                                                       7260)    AS x_dt
                          FROM tmp_pd_calc_params  p
                               LEFT JOIN pd_source so
                                   ON     so.pds_tp = 'DP'
                                      AND so.pds_ap = p.xpd_ap
                                      AND so.history_status = 'A'
                         WHERE     xpd_ic_tp = 'R0'
                               AND xpd_nst = 1061
                               AND xpd_prev_pd IS NOT NULL) S
                    ON (pds.pds_id = s.x_pds)
            WHEN MATCHED
            THEN
                UPDATE SET
                    pds.pds_pd = s.xpd_prev_pd, pds.pds_create_dt = s.x_dt
            WHEN NOT MATCHED
            THEN
                INSERT     (pds.pds_id,
                            pds.pds_pd,
                            pds.pds_tp,
                            pds.pds_ap,
                            pds.pds_create_dt,
                            pds.history_status)
                    VALUES (S.X_PDS,
                            S.XPD_PREV_PD,
                            S.X_TP,
                            S.XPD_AP,
                            S.X_DT,
                            'A');
        /*
              SELECT 0 AS x_pds, xpd_prev_pd, 'DP', xpd_ap, SYSDATE AS x_dt, 'A'
              FROM tmp_pd_calc_params p
              WHERE xpd_ic_tp = 'R0'
                and xpd_nst = 1061
                AND xpd_prev_pd IS NOT NULL;
        */
        END IF;
    END;

    --=========================================================--
    --Отримання параметрів утриманців
    PROCEDURE obtain_pdf_params
    IS
    BEGIN
        IF is_have_nst_by_alg ('APP_GROUP', 'PER_APP') > 0
        THEN
            INSERT INTO tmp_pdf_calc_params (xpdf_id,
                                             xpdf_pd,
                                             xpdf_sc,            /*xpdf_app,*/
                                             xpdf_birth_dt,
                                             xpdf_start_dt,
                                             xpdf_stop_dt,
                                             xpdf_rn)
                SELECT DISTINCT pdf_id,
                                pdf_pd,
                                pdf_sc,                            /*app_id,*/
                                pdf_birth_dt,
                                pdf.pdf_start_dt,
                                pdf.pdf_stop_dt,
                                1
                  FROM pd_family                      pdf,
                       tmp_pd_calc_params,
                       uss_ndi.v_ndi_nst_calc_config  ncc
                 WHERE     pdf_pd = xpd_id
                       AND pdf.history_status = 'A'
                       AND xpd_nst = ncc_nst
                       AND ncc_app_group = 'PER_APP'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt;



            INSERT INTO tmp_calc_app_params (tc_pd,
                                             tc_sc,                /*tc_app,*/
                                             tc_tp,
                                             tc_pdf,
                                             tc_calc_dt,
                                             tc_sc_start_dt,
                                             tc_sc_stop_dt,
                                             tc_npt,
                                             tc_koef_value)
                SELECT xpdf_pd,
                       xpdf_sc,                                  /*xpdf_app,*/
                       tpp_app_tp,
                       xpdf_id,
                       xpd_calc_dt,
                       CASE
                           WHEN xpd_src = 'SA'
                           THEN
                               xpd_start_dt
                           WHEN pd_nst = 20
                           THEN
                               TRUNC (xpd_start_dt)
                           WHEN pd_nst = 21
                           THEN
                               TRUNC (xpd_start_dt)
                           WHEN pd_nst = 664 AND tpp.tpp_ch_fm = 'BB'
                           THEN
                               TRUNC (xpdf_birth_dt, 'MM')
                           WHEN pd_nst = 664
                           THEN
                               TRUNC (tpp.tpp_dt_from, 'MM')
                           WHEN pd_nst = 249
                           THEN
                               TRUNC (tpp.tpp_dt_from, 'MM')
                           WHEN tpp.tpp_ch_fm = 'BB'
                           THEN
                               TRUNC (xpdf_birth_dt, 'MM')
                           WHEN tpp.tpp_ch_fm = 'INS'
                           THEN
                               TRUNC (tpp.tpp_dt_from, 'MM')
                           WHEN pd_nst = 250
                           THEN
                               xpd_start_dt
                           WHEN pd_nst = 251
                           THEN
                               COALESCE (API$ACCOUNT.get_docx_dt (
                                             xpd_id,
                                             tpp_sc,
                                             10196,
                                             2579,
                                             xpd_calc_dt),
                                         xpd_start_dt)
                           WHEN pd_nst = 265
                           THEN
                               xpd_start_dt
                           --               WHEN pd_nst = 275 THEN COALESCE(API$ACCOUNT.get_docx_dt(xpd_id, tpp_sc, 661, 2666, xpd_calc_dt),
                           --                                               API$ACCOUNT.get_docx_dt(xpd_id, tpp_sc, 662, 2667, xpd_calc_dt),
                           --                                               xpd_start_dt  )
                           WHEN pd_nst = 275
                           THEN
                               COALESCE (API$ACCOUNT.get_docx_dt (
                                             xpd_id,
                                             tpp_sc,
                                             661,
                                             2666,
                                             tpp.tpp_dt_from),
                                         API$ACCOUNT.get_docx_dt (
                                             xpd_id,
                                             tpp_sc,
                                             662,
                                             2667,
                                             tpp.tpp_dt_from),
                                         xpd_start_dt)
                           WHEN pd_nst = 862
                           THEN
                               TRUNC (tpp.tpp_dt_from, 'MM')
                           WHEN pd_nst = 901 AND tpp.tpp_app_tp = 'Z'
                           THEN
                               COALESCE (API$ACCOUNT.get_docx_dt_min (
                                             xpd_id,
                                             NULL,
                                             10205,
                                             2688,
                                             xpd_calc_dt),
                                         xpd_start_dt)
                           WHEN pd_nst = 901
                           THEN --COALESCE(API$ACCOUNT.get_docx_dt(xpd_id, tpp_sc, 10205, 2688, xpd_calc_dt), xpd_start_dt )
                               tpp.tpp_dt_from
                           WHEN pd_nst = 1061
                           THEN
                               TRUNC (xpd_start_dt, 'MM')
                           WHEN pd_nst = 1221
                           THEN
                               LEAST (API$ACCOUNT.get_docx_dt_min (
                                          xpd_id,
                                          tpp_sc,
                                          10323,
                                          8522,
                                          xpd_calc_dt),
                                      TRUNC (tpp.tpp_dt_from))
                           --least (API$ACCOUNT.get_docx_dt(xpd_id, tpp_sc, 10323, 8522, xpd_calc_dt), trunc(tpp.tpp_dt_from))
                           WHEN pd_nst = 241
                           THEN
                               TRUNC (xpd_start_dt, 'MM')
                           ELSE
                               TRUNC (tpp.tpp_dt_from)
                       END    AS dt_from,
                       CASE
                           --WHEN pd_nst = 20 THEN last_day(xpd_start_dt )
                           WHEN pd_nst = 664
                           THEN
                               LAST_DAY (TRUNC (tpp.tpp_dt_to, 'MM'))
                           WHEN     tpp.tpp_ch_fm = 'DEL'
                                AND pd_nst NOT IN (901, 275)
                           THEN
                               LAST_DAY (TRUNC (tpp.tpp_dt_to, 'MM'))
                           WHEN pd_nst = 251
                           THEN
                               COALESCE (API$ACCOUNT.get_docx_dt (
                                             xpd_id,
                                             tpp_sc,
                                             10196,
                                             2580,
                                             xpd_calc_dt),
                                         tpp.tpp_dt_to)
                           /*
                                               --#101786
                                               WHEN tc.TC_STUDY_STOP_DT > add_months(f.pdf_birth_dt, 12*23) THEN
                                                 add_months(f.pdf_birth_dt, 12*23)
                                               WHEN tc.TC_STUDY_STOP_DT > add_months(f.pdf_birth_dt, 12*18) THEN
                                                 tc.TC_STUDY_STOP_DT
                           */

                           WHEN pd_nst = 275 AND tpp.tpp_app_tp = 'FP'
                           THEN
                               CASE
                                   WHEN API$ACCOUNT.get_docx_dt (xpd_id,
                                                                 tpp_sc,
                                                                 98,
                                                                 688,
                                                                 xpd_calc_dt) >
                                        ADD_MONTHS (xpdf_birth_dt, 12 * 23)
                                   THEN              --Кінець періоду навчання
                                       LEAST (
                                           tpp_dt_to,
                                           ADD_MONTHS (xpdf_birth_dt,
                                                       12 * 23))
                                   WHEN API$ACCOUNT.get_docx_dt (xpd_id,
                                                                 tpp_sc,
                                                                 98,
                                                                 688,
                                                                 xpd_calc_dt) >
                                        ADD_MONTHS (xpdf_birth_dt, 12 * 18)
                                   THEN              --Кінець періоду навчання
                                       LEAST (tpp_dt_to,
                                              API$ACCOUNT.get_docx_dt (
                                                  xpd_id,
                                                  tpp_sc,
                                                  98,
                                                  688,
                                                  xpd_calc_dt))
                                   WHEN ADD_MONTHS (API$ACCOUNT.get_docx_dt (
                                                        xpd_id,
                                                        tpp_sc,
                                                        10318,
                                                        8488,
                                                        xpd_calc_dt),
                                                    4) >
                                        ADD_MONTHS (xpdf_birth_dt, 12 * 18)
                                   THEN              --Кінець періоду навчання
                                       LEAST (tpp_dt_to,
                                              ADD_MONTHS (API$ACCOUNT.get_docx_dt (
                                                              xpd_id,
                                                              tpp_sc,
                                                              10318,
                                                              8488,
                                                              xpd_calc_dt),
                                                          4))
                                   --
                                   WHEN API$ACCOUNT.get_docx_dt (xpd_id,
                                                                 tpp_sc,
                                                                 200,
                                                                 793,
                                                                 xpd_calc_dt) >
                                        ADD_MONTHS (xpdf_birth_dt, 12 * 23)
                                   THEN              --Кінець періоду навчання
                                       LEAST (
                                           tpp_dt_to,
                                           ADD_MONTHS (xpdf_birth_dt,
                                                       12 * 793))
                                   WHEN API$ACCOUNT.get_docx_dt (xpd_id,
                                                                 tpp_sc,
                                                                 200,
                                                                 793,
                                                                 xpd_calc_dt) >
                                        ADD_MONTHS (xpdf_birth_dt, 12 * 18)
                                   THEN              --Кінець періоду навчання
                                       LEAST (tpp_dt_to,
                                              API$ACCOUNT.get_docx_dt (
                                                  xpd_id,
                                                  tpp_sc,
                                                  200,
                                                  793,
                                                  xpd_calc_dt))
                                   --
                                   WHEN API$ACCOUNT.get_docx_dt (xpd_id,
                                                                 tpp_sc,
                                                                 201,
                                                                 347,
                                                                 xpd_calc_dt) >
                                        ADD_MONTHS (xpdf_birth_dt, 12 * 23)
                                   THEN              --Кінець періоду навчання
                                       LEAST (
                                           tpp_dt_to,
                                           ADD_MONTHS (xpdf_birth_dt,
                                                       12 * 793))
                                   WHEN API$ACCOUNT.get_docx_dt (xpd_id,
                                                                 tpp_sc,
                                                                 201,
                                                                 347,
                                                                 xpd_calc_dt) >
                                        ADD_MONTHS (xpdf_birth_dt, 12 * 18)
                                   THEN              --Кінець періоду навчання
                                       LEAST (tpp_dt_to,
                                              API$ACCOUNT.get_docx_dt (
                                                  xpd_id,
                                                  tpp_sc,
                                                  201,
                                                  347,
                                                  xpd_calc_dt))
                                   --
                                   ELSE
                                       LEAST (
                                           tpp_dt_to,
                                           COALESCE (
                                               ADD_MONTHS (xpdf_birth_dt,
                                                           216),
                                               tpp.tpp_dt_to))
                               END
                           WHEN pd_nst = 901 AND tpp.tpp_app_tp = 'Z'
                           THEN
                               COALESCE (API$ACCOUNT.get_docx_dt_max (xpd_id,
                                                                      NULL,
                                                                      10205,
                                                                      2689,
                                                                      NULL /*xpd_calc_dt*/
                                                                          ),
                                         tpp.tpp_dt_to)
                           WHEN pd_nst = 901
                           THEN
                               --COALESCE(API$ACCOUNT.get_docx_dt_max(xpd_id, tpp_sc, 10205, 2689, NULL/*xpd_calc_dt*/), tpp.tpp_dt_to )
                               tpp_dt_to
                           WHEN     pd_nst = 21
                                AND API$ACCOUNT.get_docx_count (xpd_id,
                                                                tpp_sc,
                                                                10312,
                                                                xpd_calc_dt) >
                                    0
                           THEN
                               LEAST (
                                   LAST_DAY (API$ACCOUNT.get_docx_dt (
                                                 xpd_id,
                                                 tpp_sc,
                                                 10312,
                                                 8434,
                                                 xpd_calc_dt)),
                                   LAST_DAY (
                                       ADD_MONTHS (xpdf_birth_dt, 12 * 18)))
                           ELSE
                               tpp.tpp_dt_to
                       END    AS dt_to,
                       CASE pd_nst
                           WHEN 21
                           THEN
                               CASE
                                   WHEN     API$ACCOUNT.get_docx_string (
                                                xpd_id,
                                                tpp_sc,
                                                605,
                                                649,
                                                xpd_calc_dt,
                                                'F') = 'TAB'
                                        AND tpp.tpp_app_tp = 'FP'
                                   THEN
                                       21
                                   WHEN     API$ACCOUNT.get_docx_string (
                                                xpd_id,
                                                tpp_sc,
                                                605,
                                                8436,
                                                xpd_calc_dt,
                                                'F') = 'T'
                                        AND tpp.tpp_app_tp = 'Z'
                                   THEN
                                       21
                               END
                           WHEN 23
                           THEN
                               856 -- 540 Грошове забезпечення за накопичені дні
                           WHEN 251
                           THEN
                               CASE
                                   WHEN API$ACCOUNT.get_docx_string (
                                            xpd_id,
                                            tpp_sc,
                                            605,
                                            2636,
                                            xpd_calc_dt,
                                            'F') = 'T'
                                   THEN
                                       830
                                   WHEN API$ACCOUNT.get_docx_string (
                                            xpd_id,
                                            tpp_sc,
                                            605,
                                            652,
                                            xpd_calc_dt,
                                            'F') = 'T'
                                   THEN
                                       831
                                   WHEN API$ACCOUNT.get_docx_string (
                                            xpd_id,
                                            tpp_sc,
                                            605,
                                            662,
                                            xpd_calc_dt,
                                            'F') = 'T'
                                   THEN
                                       832
                                   WHEN API$ACCOUNT.get_docx_string (
                                            xpd_id,
                                            tpp_sc,
                                            605,
                                            663,
                                            xpd_calc_dt,
                                            'F') = 'T'
                                   THEN
                                       833
                                   WHEN API$ACCOUNT.get_docx_string (
                                            xpd_id,
                                            tpp_sc,
                                            605,
                                            651,
                                            xpd_calc_dt,
                                            'F') = 'T'
                                   THEN
                                       834
                               END
                           WHEN 275
                           THEN
                               CASE
                                   WHEN     tpp.tpp_app_tp = 'Z'
                                        AND API$ACCOUNT.get_docx_string (
                                                xpd_id,
                                                tpp_sc,
                                                605,
                                                2654,
                                                xpd_calc_dt,
                                                'F') = 'T'
                                   THEN
                                       835                               --515
                                   WHEN     tpp.tpp_app_tp = 'Z'
                                        AND API$ACCOUNT.get_docx_string (
                                                xpd_id,
                                                tpp_sc,
                                                605,
                                                1858,
                                                xpd_calc_dt,
                                                'F') = 'T'
                                   THEN
                                       836                               --516
                                   WHEN     tpp.tpp_app_tp = 'ANF'
                                        AND API$ACCOUNT.get_docx_string (
                                                xpd_id,
                                                tpp_sc,
                                                605,
                                                1858,
                                                xpd_calc_dt,
                                                'F') = 'T'
                                   THEN
                                       836                               --516
                                   WHEN tpp.tpp_app_tp = 'FP'
                                   THEN
                                       837                               --517
                               END
                           WHEN 248
                           THEN
                               CASE    API$ACCOUNT.get_docx_string (
                                           xpd_id,
                                           tpp_sc,
                                           605,
                                           8427,
                                           xpd_calc_dt,
                                           'F')
                                    ||              --"Підвищення дітям війни"
                                       API$ACCOUNT.get_docx_string (
                                           xpd_id,
                                           tpp_sc,
                                           605,
                                           8428,
                                           xpd_calc_dt,
                                           'F')
                                    || --"Підвищення жертвам нацистських переслідувань"
                                       API$ACCOUNT.get_docx_string (
                                           xpd_id,
                                           tpp_sc,
                                           605,
                                           8429,
                                           xpd_calc_dt,
                                           'F') --"Підвищення ветеранам війни"
                                   WHEN 'TFF' THEN 184 --260 "ПІДВИЩЕННЯ ДІТЯМ ВІЙНИ"
                                   WHEN 'FTF' THEN 245 --250 ПІДВ.КОЛИШ.ВЯЗНЯМ КОНЦТ.,ІН.МІСЦЬ ТРИМАННЯ СТ6(3)
                                   WHEN 'FFT' THEN 235 --249 ПІДВИЩ. УЧАСНИКАМ ВІЙНИ
                               END
                           WHEN 901
                           THEN
                               CASE
                                   --WHEN tpp.tpp_app_tp = 'Z'  THEN 840 --524
                                   --WHEN tpp.tpp_app_tp = 'FP' THEN 839 --523 -- #97825
                                   WHEN tpp.tpp_app_tp = 'FP' THEN 840   --524
                                   WHEN tpp.tpp_app_tp = 'Z' THEN 839    --523
                               END
                           WHEN 1221
                           THEN
                               854 --527 Грошове забезпечення помічника патронатного вихователя
                       END    AS x_npt,
                       1
                  FROM tmp_pd_calc_params
                       JOIN pc_decision ON pd_id = xpd_id
                       JOIN tmp_pdf_calc_params ON xpdf_pd = xpd_id
                       JOIN tmp_pa_persons tpp
                           ON     tpp_pd = xpdf_pd
                              AND tpp_sc = xpdf_sc
                              AND tpp.tpp_dt_from = xpdf_start_dt,
                       uss_ndi.v_ndi_nst_calc_config  ncc
                 WHERE     xpd_nst = ncc_nst
                       AND ncc_calc_app_params = 'T'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt;

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
                           WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             115,
                                                             2564,
                                                             tc_calc_dt,
                                                             '-') <> '-'
                           THEN
                               'I'
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
                                 API$ACCOUNT.get_docx_string (tc_pd,
                                                              tc_sc,
                                                              115,
                                                              2564,
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
                   tc_is_Pensioner =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    661,
                                                    tc_calc_dt,
                                                    'F'),          --Пенсіонер
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
                       (SELECT CASE
                                   WHEN xpd_nst = 664
                                   THEN
                                       TRUNC (
                                           COALESCE (
                                               API$ACCOUNT.get_docx_dt_not_less_ap (
                                                   tc_pd,
                                                   tc_sc,
                                                   201,
                                                   352,
                                                   tc_calc_dt),
                                               API$ACCOUNT.get_docx_dt_not_less_ap (
                                                   tc_pd,
                                                   tc_sc,
                                                   809,
                                                   1939,
                                                   tc_calc_dt),
                                               API$ACCOUNT.get_docx_dt_not_less_ap (
                                                   tc_pd,
                                                   tc_sc,
                                                   200,
                                                   792,
                                                   tc_calc_dt),
                                               (SELECT tpd.tpd_dt_from
                                                  FROM tmp_pa_documents tpd
                                                 WHERE     tpd.tpd_pd = tc_pd
                                                       AND tpd.tpd_sc = tc_sc
                                                       AND tpd.tpd_ndt = 115)),
                                           'MM')
                                   --WHEN  xpd_nst = 248 AND xpd_src = 'RC' THEN
                                   --  xpd_start_dt
                                   ELSE
                                       COALESCE (
                                           API$ACCOUNT.get_docx_dt (
                                               tc_pd,
                                               tc_sc,
                                               201,
                                               352,
                                               tc_calc_dt),
                                           API$ACCOUNT.get_docx_dt (
                                               tc_pd,
                                               tc_sc,
                                               809,
                                               1939,
                                               tc_calc_dt),
                                           API$ACCOUNT.get_docx_dt (
                                               tc_pd,
                                               tc_sc,
                                               200,
                                               792,
                                               tc_calc_dt),
                                           (SELECT tpd.tpd_dt_from
                                              FROM tmp_pa_documents tpd
                                             WHERE     tpd.tpd_pd = tc_pd
                                                   AND tpd.tpd_sc = tc_sc
                                                   AND tpd.tpd_ndt = 115))
                               END
                          FROM tmp_pd_calc_params
                         WHERE xpd_id = tc_pd), --Дата встановлення інвалідності з медогляду МСЕК або мед.висновнку по дитині
                   tc_inv_stop_dt =
                         (SELECT CASE
                                     WHEN xpd_nst = 664
                                     THEN
                                         COALESCE (
                                             ADD_MONTHS (API$ACCOUNT.get_docx_dt (
                                                             tc_pd,
                                                             tc_sc,
                                                             201,
                                                             347,
                                                             tc_calc_dt),
                                                         CASE API$ACCOUNT.get_docx_string (
                                                                  tc_pd,
                                                                  tc_sc,
                                                                  201,
                                                                  4188,
                                                                  tc_calc_dt,
                                                                  'F')
                                                             WHEN 'F' THEN 3
                                                             ELSE 100
                                                         END),
                                             ADD_MONTHS (API$ACCOUNT.get_docx_dt (
                                                             tc_pd,
                                                             tc_sc,
                                                             809,
                                                             1806,
                                                             tc_calc_dt),
                                                         CASE API$ACCOUNT.get_docx_string (
                                                                  tc_pd,
                                                                  tc_sc,
                                                                  809,
                                                                  4189,
                                                                  tc_calc_dt,
                                                                  'F')
                                                             WHEN 'F' THEN 3
                                                             ELSE 100
                                                         END),
                                             API$ACCOUNT.get_docx_dt (
                                                 tc_pd,
                                                 tc_sc,
                                                 200,
                                                 793,
                                                 tc_calc_dt),
                                             (SELECT tpd.tpd_dt_to
                                                FROM tmp_pa_documents tpd
                                               WHERE     tpd.tpd_pd = tc_pd
                                                     AND tpd.tpd_sc = tc_sc
                                                     AND tpd.tpd_ndt = 115))
                                     ELSE
                                         COALESCE (
                                             API$ACCOUNT.get_docx_dt (
                                                 tc_pd,
                                                 tc_sc,
                                                 201,
                                                 347,
                                                 tc_calc_dt),
                                             API$ACCOUNT.get_docx_dt (
                                                 tc_pd,
                                                 tc_sc,
                                                 809,
                                                 1806,
                                                 tc_calc_dt),
                                             API$ACCOUNT.get_docx_dt (
                                                 tc_pd,
                                                 tc_sc,
                                                 200,
                                                 793,
                                                 tc_calc_dt),
                                             (SELECT tpd.tpd_dt_to
                                                FROM tmp_pa_documents tpd
                                               WHERE     tpd.tpd_pd = tc_pd
                                                     AND tpd.tpd_sc = tc_sc
                                                     AND tpd.tpd_ndt = 115))
                                 END
                            FROM tmp_pd_calc_params
                           WHERE xpd_id = tc_pd)
                       - 1, --Встановлено на період до з медогляду МСЕК або мед.висновнку по дитині
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
                   tc_is_child_inv_Reason =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    200,
                                                    804,
                                                    tc_calc_dt,
                                                    '-'), --Причина інвалідності дитини
                   tc_is_child_sick =
                       API$ACCOUNT.check_docx_exists (tc_pd,
                                                      tc_sc,
                                                      669,
                                                      tc_calc_dt), --Довідка про захворювання дитини
                   tc_child_sick_stop_dt =
                       API$ACCOUNT.get_docx_dt (tc_pd,
                                                tc_sc,
                                                669,
                                                695,
                                                tc_calc_dt), --Довідка про захворювання дитини, Дата кінця дії
                   tc_study_start_dt =
                       API$ACCOUNT.get_docx_dt (tc_pd,
                                                tc_sc,
                                                98,
                                                687,
                                                tc_calc_dt), --Початок періоду навчання   --#75887 2022.02.22
                   tc_study_stop_dt =
                       COALESCE (API$ACCOUNT.get_docx_dt (tc_pd,
                                                          tc_sc,
                                                          98,
                                                          688,
                                                          tc_calc_dt),
                                 ADD_MONTHS (API$ACCOUNT.get_docx_dt (
                                                 tc_pd,
                                                 tc_sc,
                                                 10318,
                                                 8488,
                                                 tc_calc_dt),
                                             4)),    --Кінець періоду навчання
                   /*
                            apd_ndt=10318  Клопотання ССД щодо призначення ДСД на період участі у вступній кампанії
                            apd_id = 236850
                               8486  номер документа = 15
                               8487  дата документа = 07.07.2024
                               8488  Дата закінчення навчання = 15.07.2024
                   */
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
                   tc_is_vpo_home =
                       CASE API$ACCOUNT.get_docx_string (tc_pd,
                                                         tc_sc,
                                                         605,
                                                         2101,
                                                         tc_calc_dt,
                                                         '-')
                           WHEN 'T'
                           THEN
                               API$ACCOUNT.get_docx_string (tc_pd,
                                                            tc_sc,
                                                            10090,
                                                            2100,
                                                            tc_calc_dt,
                                                            '-')
                           ELSE
                               '-'
                       END,                       -- ознака СТАНУ ЖИТЛА #84260
                   tc_bd_kaot_id =
                       COALESCE (API$ACCOUNT.get_docx_id (tc_pd,
                                                          tc_sc,
                                                          10052,
                                                          2292,
                                                          tc_calc_dt), --#82444 2022.12.23
                                 API$ACCOUNT.get_docx_id (tc_pd,
                                                          tc_sc,
                                                          605,
                                                          1775,
                                                          tc_calc_dt)),
                   --tc_bd_kaot_id     = API$ACCOUNT.get_docx_id(tc_pd, tc_sc, 605, 1775, tc_calc_dt)
                   tc_income =
                       CASE tc_npt
                           WHEN 830
                           THEN
                               API$ACCOUNT.get_docx_sum (tc_pd,
                                                         tc_sc,
                                                         10197,
                                                         2655,
                                                         tc_calc_dt,
                                                         0)
                           WHEN 831
                           THEN
                               API$ACCOUNT.get_docx_sum (tc_pd,
                                                         tc_sc,
                                                         10198,
                                                         2656,
                                                         tc_calc_dt,
                                                         0)
                           WHEN 832
                           THEN
                               (SELECT DISTINCT
                                       LAST_VALUE (aim_sum)
                                           OVER (
                                               ORDER BY aim_month ASC
                                               RANGE BETWEEN UNBOUNDED
                                                             PRECEDING
                                                     AND     UNBOUNDED
                                                             FOLLOWING)
                                  FROM (SELECT API$Calc_Income.ToDate (
                                                   SUBSTR (
                                                       TRIM (COLUMN_VALUE),
                                                       1,
                                                         INSTR (
                                                             TRIM (
                                                                 COLUMN_VALUE),
                                                             '=')
                                                       - 1))    aim_month,
                                               API$Calc_Income.ToNumber (
                                                   SUBSTR (
                                                       TRIM (COLUMN_VALUE),
                                                         INSTR (
                                                             TRIM (
                                                                 COLUMN_VALUE),
                                                             '=')
                                                       + 1))    aim_sum
                                          FROM XMLTABLE (
                                                   (   '"'
                                                    || REPLACE (
                                                           REGEXP_REPLACE (
                                                               API$ACCOUNT.get_docx_507_string (
                                                                   tc_pd,
                                                                   tc_sc,
                                                                   '4',
                                                                   tc_calc_dt),
                                                                  CHR (13)
                                                               || '|'
                                                               || CHR (10),
                                                               ''),
                                                           ',',
                                                           '","')
                                                    || '"')))
                                 WHERE aim_month < TRUNC (tc_calc_dt, 'MM'))
                           WHEN 837
                           THEN
                               api$calc_pd.Get_apri_income (tc_pd,
                                                            tc_sc,
                                                            '1,4,5,28',
                                                            tc_calc_dt,
                                                            tc_sc_start_dt) --1 пенсії, --5 аліментів, --6 допомоги, --4, 28 стипендії
                           --WHEN 839  THEN   api$pc_decision.Get_apri_income(tc_pd, tc_sc, '4,28', tc_calc_dt, tc_sc_start_dt)--1 пенсії, --5 аліментів, --6 допомоги, --4, 28 стипендії
                           WHEN 840
                           THEN
                               api$calc_pd.Get_apri_income (tc_pd,
                                                            tc_sc,
                                                            '4,28',
                                                            tc_calc_dt,
                                                            tc_sc_start_dt) -- #97825
                       END,
                   TC_PERCENT_DECREASE =
                       (SELECT CASE
                                   WHEN xpd_nst IN (249, 267)
                                   THEN
                                       (SELECT TO_NUMBER (
                                                   f.pde_val_string
                                                       DEFAULT 0 ON CONVERSION ERROR)
                                          FROM pd_features f
                                         WHERE     f.pde_pd = xpd_id
                                               AND f.pde_nft = 83)
                                   ELSE
                                       0
                               END
                          FROM tmp_pd_calc_params
                         WHERE xpd_id = tc_pd),
                   TC_CARE_LEAVE =
                       (SELECT CASE
                                   WHEN     ank.Working = 'T'
                                        AND ank.CaringChildUnder3 = 'T'
                                   THEN
                                       'CRNG_CH_3'
                                   WHEN     ank.Working = 'T'
                                        AND ank.CaringChildUnder6 = 'T'
                                   THEN
                                       'CRNG_CH_6'
                                   WHEN     ank.Working = 'T'
                                        AND ank.CaringInvUnder18 = 'T'
                                   THEN
                                       'CRNG_INV_18'
                               END
                          FROM TABLE (API$ANKETA.Get_Anketa) ank
                         WHERE pd_id = tc_pd AND app_sc = TC_SC),
                   TC_MOUNTAIN_VILLAGE =
                       CASE
                           WHEN API$ACCOUNT.get_docx_count (tc_pd,
                                                            tc_sc,
                                                            92,
                                                            tc_calc_dt) > 0
                           THEN
                               'T'
                           WHEN (SELECT COUNT (1)
                                   FROM tmp_pd_calc_params
                                        JOIN tmp_pa_documents
                                            ON xpd_id = tpd_pd
                                  WHERE     xpd_id = tc_pd
                                        AND tpd_app_tp = 'Z'
                                        AND tpd_ndt = 92
                                        AND tc_calc_dt BETWEEN tpd_dt_from
                                                           AND tpd_dt_to
                                        AND xpd_nst = 265) >
                                0
                           THEN
                               'T'
                           ELSE
                               NULL
                       END,
                   tc_underage_pregnant =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    2664,
                                                    tc_calc_dt,
                                                    'F'),
                   tc_child_vil =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    2665,
                                                    tc_calc_dt,
                                                    'F'),
                   tc_death_dt =
                       API$ACCOUNT.get_docx_dt (tc_pd,
                                                tc_sc,
                                                10295,
                                                7260,
                                                tc_calc_dt),
                   tc_child_newborn =
                       API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    8458,
                                                    tc_calc_dt,
                                                    'F'),
                   tc_is_fop =
                       CASE
                           WHEN     API$ACCOUNT.get_docx_string (tc_pd,
                                                                 tc_sc,
                                                                 605,
                                                                 651,
                                                                 tc_calc_dt,
                                                                 'F') = 'T'
                                AND API$ACCOUNT.get_docx_count (tc_pd,
                                                                tc_sc,
                                                                154,
                                                                tc_calc_dt) >
                                    0
                           THEN
                               'T'
                           WHEN API$ACCOUNT.get_docx_count (tc_pd,
                                                            tc_sc,
                                                            10321,
                                                            tc_calc_dt) > 0
                           THEN
                               'T'
                           ELSE
                               'F'
                       END
             WHERE 1 = 1;



            UPDATE tmp_pd_calc_params
               SET xpd_mount_live = 'T'
             WHERE     xpd_nst = 249
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_calc_app_params tc
                             WHERE     tc.tc_pd = xpd_id
                                   AND tc.tc_tp = 'Z'
                                   AND tc.TC_MOUNTAIN_VILLAGE = 'T');


            ---Шукаємо попередне рішення 248 для померлої особи

            UPDATE tmp_calc_app_params t
               SET t.tc_death_sum =
                       (SELECT MAX (
                                   (SELECT SUM (pdd.pdd_value)
                                      FROM pd_payment  pdp
                                           JOIN pd_detail pdd
                                               ON     pdd.pdd_pdp =
                                                      pdp.pdp_id
                                                  AND pdd.pdd_key = ff.pdf_id
                                     WHERE     pdp.pdp_pd = pd.pd_id
                                           AND pdp.history_status = 'A'
                                           AND t.tc_death_dt BETWEEN pdp.pdp_start_dt
                                                                 AND pdp.pdp_stop_dt
                                           AND (   pdp_npt = 1
                                                OR (    pdp_npt != 1
                                                    AND pdd_npt != 219
                                                    AND pdd_npt != 48))))    AS old_SUM
                          FROM pd_family  f
                               JOIN tmp_pa_persons
                                   ON     tpp_pd = pdf_pd
                                      AND tpp_sc = pdf_sc
                                      AND tpp_app_tp = 'DP'
                               JOIN pd_family ff
                                   ON     ff.pdf_sc = f.pdf_sc
                                      AND ff.pdf_pd != f.pdf_pd
                                      AND ff.history_status = 'A'
                               JOIN pc_decision pd
                                   ON     pd.pd_id = ff.pdf_pd
                                      AND pd.pd_nst = 248
                                      AND pd.pd_st IN ('S', 'PS')
                         WHERE     f.pdf_pd = t.tc_pd
                               AND f.history_status = 'A'
                               AND EXISTS
                                       (SELECT 1
                                          FROM pd_accrual_period ac
                                         WHERE     ac.pdap_pd = pd.pd_id
                                               AND ac.history_status = 'A'
                                               AND t.tc_death_dt BETWEEN ac.pdap_start_dt
                                                                     AND ac.pdap_stop_dt))
             WHERE t.tc_tp = 'DP';

            /*
                  UPDATE tmp_calc_app_params t SET
                    t.tc_death_sum =
                    ( SELECT MAX(get_death_sum(pd.pd_id, ff.pdf_id, t.tc_death_dt)) AS old_SUM
                      FROM pd_family f
                           JOIN tmp_pa_persons ON tpp_pd = pdf_pd AND tpp_sc = pdf_sc AND tpp_app_tp = 'DP'
                           JOIN pd_family ff ON ff.pdf_sc = f.pdf_sc AND ff.pdf_pd != f.pdf_pd
                           JOIN pc_decision pd ON pd.pd_id = ff.pdf_pd AND pd.pd_nst = 248 AND pd.pd_st IN ('S', 'PS')
                      WHERE f.pdf_pd = t.tc_pd
                        AND EXISTS (SELECT 1
                                    FROM pd_accrual_period ac
                                    WHERE ac.pdap_pd = pd.pd_id
                                      AND ac.history_status = 'A'
                                      AND t.tc_death_dt BETWEEN ac.pdap_start_dt AND ac.pdap_stop_dt
                                   )
            --          GROUP BY pd.pd_id
            --          FETCH FIRST rows ONLY
                    )
                  WHERE t.tc_tp = 'DP';
            */

            UPDATE tmp_calc_app_params p
               SET TC_MOUNTAIN_VILLAGE = 'T'
             WHERE     p.tc_tp != 'Z'
                   AND TRUNC (
                           MONTHS_BETWEEN (p.tc_calc_dt, tc_birth_dt) / 12,
                           0) <
                       14
                   AND TC_MOUNTAIN_VILLAGE IS NULL
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_calc_app_params pp
                             WHERE     pp.tc_pd = p.tc_pd
                                   AND pp.tc_tp = 'Z'
                                   AND pp.TC_MOUNTAIN_VILLAGE = 'T');

            --#98268
            UPDATE tmp_calc_app_params tc
               SET tc_is_vpo_evac = 'T'                     --ознака евакуації
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_pd_calc_params
                             WHERE xpd_id = tc_pd AND xpd_nst = 664)
                   AND EXISTS
                           (SELECT 1
                              FROM src_evacuees_reestr r
                             WHERE r.ser_sc = tc_sc)
                   AND API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    10052,
                                                    1855,
                                                    tc_calc_dt,
                                                    '-') = 'A'      -- #103923
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_family  pdf
                                   JOIN pd_features pde
                                       ON     pdf.pdf_id = pde.pde_pdf
                                          AND pde.pde_nft = 92
                                   JOIN pc_decision pd
                                       ON     pd.pd_id = pdf.pdf_pd
                                          AND pd.pd_st IN ('R0',
                                                           'K',
                                                           'PS',
                                                           'S')
                             WHERE     pdf.pdf_sc = tc_sc
                                   AND pdf.history_status = 'A'
                                   AND pdf.pdf_pd != tc_pd
                                   AND pde.pde_val_string = 'T');

            -- #96922
            UPDATE tmp_calc_app_params tc
               SET tc_koef_value =
                       (CASE tc_tp
                            WHEN 'Z' THEN 0.5
                            WHEN 'ANF' THEN 0
                            ELSE 1
                        END)
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_pd_calc_params
                             WHERE xpd_id = tc_pd AND xpd_nst = 275)
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_calc_app_params t
                             WHERE t.tc_pd = tc.tc_pd AND t.tc_tp = 'Z')
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_calc_app_params t
                             WHERE t.tc_pd = tc.tc_pd AND t.tc_tp = 'ANF')
                   AND tc_tp IN ('Z', 'ANF');

            UPDATE tmp_calc_app_params tc
               SET tc_koef_value =
                       (CASE tc_tp
                            WHEN 'ANF' THEN 0.5
                            WHEN 'FP' THEN 0
                            ELSE 1
                        END)
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_pd_calc_params
                             WHERE xpd_id = tc_pd AND xpd_nst = 275)
                   AND NOT EXISTS
                           (SELECT 1
                              FROM tmp_calc_app_params t
                             WHERE t.tc_pd = tc.tc_pd AND t.tc_tp = 'Z')
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_calc_app_params t
                             WHERE t.tc_pd = tc.tc_pd AND t.tc_tp = 'ANF');

            UPDATE tmp_calc_app_params tc
               SET tc.tc_sc_stop_dt =
                       (CASE
                            WHEN tc.tc_inv_stop_dt >
                                 ADD_MONTHS (tc_birth_dt, 12 * 23)
                            THEN
                                ADD_MONTHS (tc_birth_dt, 12 * 23)
                            WHEN tc.tc_inv_stop_dt >
                                 ADD_MONTHS (tc_birth_dt, 12 * 18)
                            THEN
                                tc.tc_inv_stop_dt
                            ELSE
                                tc.tc_sc_stop_dt
                        END)
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_pd_calc_params
                             WHERE xpd_id = tc_pd AND xpd_nst = 275)
                   AND tc.tc_tp = 'FP'
                   AND tc.tc_inv_state = 'DI';

            /*
                     apd_ndt=675    Копія наказу (розпорядження) роботодавця про надання відпустки
                        4364  Початок періоду відпустки, з = 10.08.2023
                        4365  Кінець періоду відпустки, по = 10.02.2024
                        4366  Вид відпустки = WTHT
                        769  серія та номер документа = 1236
                        770  дата видачі = 11.08.2023
                     apd_ndt=676    Довідка  про потребу дитини (дитини з інвалідністю) у домашньому догляді
                        4368  Дата видачі довідки = 04.08.2023
                        4369  Дата, з якої дитина  (дитина-інвалід) потребує домашнього догляду  = 10.08.2023
                        4370  Довідка  дійсна до  = 10.02.2024
                        772  Серія та номер довідки = 123
            */
            /*
            4) Тут зазначені умови для працюючих:
               В атрибуті анкети щодо Заявника  зазначено «ТАК» в атрибуті з Ід= 820
               AND в атрибуті 653 (Доглядає за дитиною до 3-х років або перебуває у відпустці по вагітності та пологах)
               AND Наявний документ "Копія наказу (розпорядження) роботодавця про надання відпустки" Ід=675
            5) В атрибуті анкети щодо Заявника  зазначено «ТАК» в атрибуті з Ід= 820
               AND ( в атрибуті 654 (Доглядає за дитиною до 6-х років)
                    OR
                    в атрибуті 659 (Доглядає за дитиною з інвалідністю до 18-років)
                    )
               AND Наявний документ "Копія наказу (розпорядження) роботодавця про надання відпустки" Ід=675
               AND Наявний документ Довідка про потребу дитини (дитини-інваліда) у домашньому догляді Ід=676

            У випадку розрахунку для осіб зазначених у:
              п 4 стовпця «Умови надання надбавки»,
              надбавка призначається на період зазначений у документі "Копія наказу (розпорядження) роботодавця про надання відпустки" Ід=675
              З дати зазначеної в атрибуті з Ід=4364 по дату зазначену в атрибуті з Ід=4365

              п 5 стовпця «Умови надання надбавки»,
              надбавка призначається на період зазначений у документі "Копія наказу (розпорядження) роботодавця про надання відпустки" Ід=675
              але не більший ніж зазначено у атрибутах  документу Довідка про потребу дитини (дитини-інваліда) у домашньому догляді Ід=676
              з дата в атрибуті з Ід=4369 по дату в атрибуті Ід=4370
            */

            UPDATE tmp_calc_app_params p
               SET (TC_CARE_START_DT, TC_CARE_STOP_DT) =
                       (SELECT CASE
                                   WHEN TC_CARE_LEAVE = 'CRNG_CH_3'
                                   THEN
                                       X_START_DT
                                   WHEN X_START_DT < X_MAX_START_DT
                                   THEN
                                       X_MAX_START_DT
                                   ELSE
                                       X_START_DT
                               END    START_DT,
                               CASE
                                   WHEN TC_CARE_LEAVE = 'CRNG_CH_3'
                                   THEN
                                       X_STOP_DT
                                   WHEN X_STOP_DT > X_MAX_STOP_DT
                                   THEN
                                       X_MAX_STOP_DT
                                   ELSE
                                       X_STOP_DT
                               END    STOP_DT
                          FROM (SELECT API$ACCOUNT.get_docx_dt (tc_pd,
                                                                tc_sc,
                                                                675,
                                                                4364,
                                                                tc_calc_dt)
                                           AS X_START_DT,
                                       API$ACCOUNT.get_docx_dt (tc_pd,
                                                                tc_sc,
                                                                675,
                                                                4365,
                                                                tc_calc_dt)
                                           AS X_STOP_DT,
                                       API$ACCOUNT.get_docx_dt (tc_pd,
                                                                tc_sc,
                                                                676,
                                                                4369,
                                                                tc_calc_dt)
                                           AS X_MAX_START_DT,
                                       API$ACCOUNT.get_docx_dt (tc_pd,
                                                                tc_sc,
                                                                676,
                                                                4370,
                                                                tc_calc_dt)
                                           AS X_MAX_STOP_DT
                                  --API$ACCOUNT.get_docx_dt(tc_pd, tc_sc,10028,  863, tc_calc_dt) AS X_MAX_START_DT,
                                  --API$ACCOUNT.get_docx_dt(tc_pd, tc_sc,10028,  864, tc_calc_dt) AS X_MAX_STOP_DT
                                  FROM DUAL))
             WHERE TC_CARE_LEAVE IN ('CRNG_CH_3', 'CRNG_CH_6', 'CRNG_INV_18');

            UPDATE tmp_calc_app_params p
               SET (TC_CARE_LEAVE, TC_CARE_START_DT, TC_CARE_STOP_DT) =
                       (SELECT TC_CARE_LEAVE,
                               TC_CARE_START_DT,
                               TC_CARE_STOP_DT
                          FROM tmp_calc_app_params p1
                         WHERE     p1.tc_pd = p.tc_pd
                               AND p1.tc_tp = 'Z'
                               AND p1.TC_CARE_LEAVE IN
                                       ('CRNG_CH_3',
                                        'CRNG_CH_6',
                                        'CRNG_INV_18'))
             WHERE     p.tc_tp != 'Z'
                   AND p.tc_inv_state = 'DI'
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_calc_app_params p1
                             WHERE     p1.tc_pd = p.tc_pd
                                   AND p1.tc_tp = 'Z'
                                   AND p1.TC_CARE_LEAVE IN
                                           ('CRNG_CH_3',
                                            'CRNG_CH_6',
                                            'CRNG_INV_18'));


            UPDATE tmp_calc_app_params p
               SET tc_appeal_vpo =
                       (CASE
                            WHEN (SELECT COUNT (1)
                                    FROM appeal
                                         JOIN ap_service aps
                                             ON     aps_ap = ap_id
                                                AND aps.history_status = 'A'
                                                AND aps_nst = 20
                                         JOIN ap_person app
                                             ON     app_ap = ap_id
                                                AND app.history_status = 'A'
                                                AND app_sc = tc_sc
                                   WHERE appeal.ap_reg_dt BETWEEN TO_DATE (
                                                                      '01.05.2023',
                                                                      'dd.mm.yyyy')
                                                              AND TO_DATE (
                                                                      '05.06.2023',
                                                                      'dd.mm.yyyy')) =
                                 0
                            THEN
                                'F'
                            ELSE
                                'T'
                        END),
                   tc_receives_vpo =
                       (CASE
                            WHEN (SELECT COUNT (1)
                                    FROM pd_family  f
                                         JOIN pc_decision pd
                                             ON     pd.pd_id = f.pdf_pd
                                                AND pd_nst = 664
                                   WHERE     f.pdf_pd != tc_pd
                                         AND f.history_status = 'A'
                                         AND f.pdf_sc = tc_sc
                                         AND EXISTS
                                                 (SELECT 1
                                                    FROM payroll, pr_sheet
                                                   WHERE     prs_pr = pr_id
                                                         AND prs_pc = pd_pc
                                                         AND (   pr_month IN
                                                                     (TO_DATE (
                                                                          '01.05.2023',
                                                                          'DD.MM.YYYY'))
                                                              OR     (    pr_tp =
                                                                          'M'
                                                                      AND pr_month IN
                                                                              (TO_DATE (
                                                                                   '01.06.2023',
                                                                                   'DD.MM.YYYY')))
                                                                 AND pr_npc =
                                                                     24
                                                                 AND prs_st IN
                                                                         ('NA',
                                                                          'KV1',
                                                                          'KV2')))) =
                                 0
                            THEN
                                'F'
                            ELSE
                                'T'
                        END)
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE xpd_nst = 20 AND xpd_id = tc_pd);

            /*
                FOR d IN (SELECT * FROM tmp_calc_app_params t) LOOP
                  dbms_output_put_lines('-2  tc_sc='||d.tc_sc||'   tc_is_vpo      = '||d.tc_is_vpo||'   tc_is_vpo_home      = '||d.tc_is_vpo_home);
                END LOOP;
                dbms_output_put_lines('');
            */

            UPDATE tmp_calc_app_params p
               SET p.tc_is_vpo_home =
                       (SELECT tc_is_vpo_home
                          FROM tmp_calc_app_params pp
                         WHERE pp.tc_pd = p.tc_pd AND pp.tc_tp = 'Z')
             WHERE     p.tc_tp != 'Z'
                   AND API$ACCOUNT.get_docx_string (tc_pd,
                                                    tc_sc,
                                                    605,
                                                    4372,
                                                    tc_calc_dt,
                                                    'F') = 'F'
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_pd_calc_params
                             WHERE xpd_nst = 664 AND xpd_id = tc_pd);

            /*
                     apd_ndt=605    Анкета учасника звернення
                        2668  Патронатний вихователь = T
                        8462  Помічник патронатного вихователя = T
            */
            --
            UPDATE tmp_calc_app_params p
               SET p.tc_subtp =
                       CASE
                           WHEN api$account.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             605,
                                                             8462,
                                                             tc_calc_dt) =
                                'T'
                           THEN
                               'ANF'
                           WHEN api$account.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             605,
                                                             2668,
                                                             tc_calc_dt) =
                                'T'
                           THEN
                               'Z'
                           ELSE
                               NULL
                       END
             WHERE     p.tc_tp = 'Z'
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_pd_calc_params
                             WHERE xpd_nst IN (23, 1201) AND xpd_id = tc_pd);

            --api$appeal.Get_Ap_z_Doc_String(a.ap_id, 605, 2668) AS x_Pat,
            --api$appeal.Get_Ap_z_Doc_String(a.ap_id, 605, 8462) AS x_Anf

            /*
                FOR d IN (SELECT * FROM tmp_calc_app_params t) LOOP
                  dbms_output_put_lines('-1  tc_sc='||d.tc_sc||'   tc_is_vpo      = '||d.tc_is_vpo||'   tc_is_vpo_home      = '||d.tc_is_vpo_home);
                END LOOP;
                dbms_output_put_lines('');
            */
            /*
            Відсутня перерва (дата в Номер атрибута=352 зазначена дата, до якої призначено інвалідність +1 день)
                     З дати зазначеної в Номер атрибута=352
            Перерва менше ніж 1 місяць
                    З дати, до якої була призначена попередня допомога+1 день
            Перерва більше ніж 1 місяць
                    З дати зазначеної в Номер атрибута=352 мінус один місяць
            */

            UPDATE tmp_pd_calc_params xpd
               SET (xpd_start_dt, xpd_src) =
                       (SELECT new_start_dt, 'RC'
                          FROM (SELECT CASE
                                           WHEN tc_inv_start_dt =
                                                ADD_MONTHS (tc_birth_dt, 216)
                                           THEN
                                               ADD_MONTHS (tc_birth_dt, 216)
                                           WHEN tc_inv_start_dt BETWEEN ADD_MONTHS (
                                                                            tc_birth_dt,
                                                                            216)
                                                                    AND ADD_MONTHS (
                                                                            tc_birth_dt,
                                                                            217)
                                           THEN
                                               ADD_MONTHS (tc_birth_dt, 216)
                                           WHEN tc_inv_start_dt >
                                                ADD_MONTHS (p.tc_birth_dt,
                                                            217)
                                           THEN
                                               ADD_MONTHS (tc_inv_start_dt,
                                                           -1)
                                           ELSE
                                               p.tc_start_dt
                                       END    AS new_start_dt
                                  FROM tmp_calc_app_params p
                                 WHERE xpd_id = p.tc_pd AND p.tc_tp = 'Z'))
             WHERE     xpd_prev_pd IS NOT NULL
                   AND xpd_nst = 248
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_calc_app_params
                             WHERE tc_tp = 'Z' AND tc_inv_state = 'IZ');

            UPDATE tmp_calc_app_params p
               SET (p.tc_sc_start_dt,
                    p.tc_inv_prev_state,
                    p.tc_inv_prev_start_dt,
                    p.tc_inv_prev_stop_dt,
                    tc_inv_rc_alg) =
                       (SELECT xpd_start_dt,
                               'DI', --api$pc_decision.get_pd_doc_200_str(xpd., xpd., 797),
                               api$pc_decision.get_pd_doc_200_dt (
                                   xpd.xpd_prev_pd,
                                   p.tc_sc,
                                   792),
                               api$pc_decision.get_pd_doc_200_dt (
                                   xpd.xpd_prev_pd,
                                   p.tc_sc,
                                   793),
                               CASE
                                   WHEN tc_inv_start_dt =
                                        ADD_MONTHS (tc_birth_dt, 216)
                                   THEN
                                       '1'
                                   WHEN tc_inv_start_dt BETWEEN ADD_MONTHS (
                                                                    tc_birth_dt,
                                                                    216)
                                                            AND ADD_MONTHS (
                                                                    tc_birth_dt,
                                                                    217)
                                   THEN
                                       '2'
                                   WHEN tc_inv_start_dt >
                                        ADD_MONTHS (p.tc_birth_dt, 217)
                                   THEN
                                       '3'
                                   ELSE
                                       ''
                               END
                          FROM tmp_pd_calc_params xpd
                         WHERE xpd_id = p.tc_pd)
             WHERE     p.tc_tp = 'Z'
                   AND p.tc_inv_state = 'IZ'
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_pd_calc_params
                             WHERE     xpd_id = p.tc_pd
                                   AND xpd_prev_pd IS NOT NULL
                                   AND xpd_nst = 248);
        /*
                UPDATE tmp_calc_app_params p SET
                  p.tc_child_number = ( SELECT CASE x_birth_cnt
                                                 WHEN 1 THEN rn
                                                 ELSE x_birth_cnt + x_prev_cnt
                                               END AS rn
                                        FROM ( SELECT tc.tc_sc,
                                                      ROW_NUMBER() OVER (PARTITION BY tc.tc_pd, tc.tc_tp, tc.tc_start_dt ORDER BY tc_birth_dt) AS rn,
                                                      (SELECT COUNT(1)
                                                       FROM tmp_calc_app_params tt
                                                       WHERE tt.tc_pd = tc.tc_pd
                                                         AND tt.tc_tp = tc.tc_tp
                                                         AND tt.tc_birth_dt BETWEEN  tc.tc_birth_dt-2 AND tc.tc_birth_dt+2
                                                         AND tt.tc_start_dt IS NULL
                                                      ) AS x_birth_cnt,
                                                      (SELECT COUNT(1)
                                                       FROM tmp_calc_app_params tt
                                                       WHERE tt.tc_pd = tc.tc_pd
                                                         AND tt.tc_tp = tc.tc_tp
                                                         AND tt.tc_birth_dt < tc.tc_birth_dt - 2
                                                         AND tt.tc_start_dt IS NULL
                                                      ) AS x_prev_cnt
                                               FROM tmp_calc_app_params tc
                                               WHERE tc.tc_pd = p.tc_pd AND tc.tc_tp = p.tc_tp)  pp
                                        WHERE pp.tc_sc = p.tc_sc)
                WHERE p.tc_tp = 'FP';
          */
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
                  FROM tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config ncc
                 WHERE     xpd_nst = ncc_nst
                       AND ncc_app_group = 'ONE_BY_PD'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt;
        END IF;
    END;

    --=========================================================--
    --Обраховуємо період розрахунку
    PROCEDURE obtain_calc_pd
    IS
    BEGIN
        -- для RC.START_DT все обчислено до нас
        /*
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
              SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
              FROM tmp_in_calc_pd
              WHERE ic_tp = 'RC.START_DT';

            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
              SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
              FROM tmp_in_calc_pd
              WHERE ic_tp = 'RC.FULL';
        */
        IF is_have_nst_by_alg ('CALC_PERIOD', '1MONTHS') > 0
        THEN
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                SELECT xpd_id, xpd_start_dt, LAST_DAY (xpd_start_dt) + 1
                  FROM tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config ncc
                 WHERE     xpd_nst = ncc_nst
                       AND ncc_calc_period = '1MONTHS'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND xpd_ic_tp = 'R0'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.START_DT'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.FULL';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', '6MONTHS') > 0
        THEN
            --dbms_output_put_lines ('6MONTHS');
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                SELECT xpd_id,
                       CASE
                           WHEN XPD_SRC = 'RC' AND PD_START_DT IS NOT NULL
                           THEN
                               PD_START_DT
                           WHEN     XPD_SRC = 'PV'
                                AND EXISTS
                                        (SELECT *
                                           FROM pd_source s
                                          WHERE s.pds_pd = xpd_id)
                                AND XPD_START_DT IS NOT NULL
                           THEN
                               PD_START_DT
                           ELSE
                               TRUNC (xpd_ap_reg_dt, 'MM')
                       END    AS start_dt,
                       CASE
                           --               WHEN xpd_nst = 664 THEN
                           --                 api$calc_pd.get_stop_date_664(pd_pa,  xpd_ap_reg_dt, ap.ap_is_second)
                           WHEN XPD_SRC = 'RC' AND PD_STOP_DT IS NOT NULL
                           THEN
                               PD_STOP_DT + 1
                           WHEN     XPD_SRC = 'PV'
                                AND EXISTS
                                        (SELECT *
                                           FROM pd_source s
                                          WHERE s.pds_pd = xpd_id)
                                AND XPD_START_DT IS NOT NULL
                           THEN
                               PD_STOP_DT + 1
                           WHEN xpd_nst = 664
                           THEN
                               get_stop_date_664 (pd_pa,
                                                  xpd_ap_reg_dt,
                                                  ap.ap_is_second)
                           ELSE
                               ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 6)
                       END    AS stop_dt
                  FROM tmp_pd_calc_params
                       JOIN pc_decision ON xpd_id = pd_id
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                       JOIN appeal ap ON ap.ap_id = xpd_ap
                 WHERE     ncc_calc_period = '6MONTHS'
                       AND NCC_PD_PERIOD_ALG = 'TR_AP_REG'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND xpd_ic_tp = 'R0'
                UNION ALL
                SELECT xpd_id,
                       CASE
                           WHEN xpd_nst = 265 AND XPD_START_DT IS NOT NULL
                           THEN
                               XPD_START_DT
                           ELSE
                               xpd_ap_reg_dt
                       END    AS start_dt,
                       CASE
                           --WHEN nvl(child_sick_stop_dt,ADD_MONTHS(xpd_ap_reg_dt, 6)) < ADD_MONTHS(xpd_ap_reg_dt, 6) THEN
                           --  child_sick_stop_dt
                           WHEN xpd_nst = 265 AND XPD_START_DT IS NOT NULL
                           THEN
                               ADD_MONTHS (XPD_START_DT, 6)
                           WHEN xpd_nst = 664
                           THEN
                               api$calc_pd.get_stop_date_664 (
                                   pd_pa,
                                   xpd_ap_reg_dt,
                                   ap.ap_is_second)
                           ELSE
                               ADD_MONTHS (xpd_ap_reg_dt, 6)
                       END    AS stop_dt
                  FROM tmp_pd_calc_params
                       JOIN
                       (  SELECT tt.tc_pd,
                                 MAX (tt.tc_child_sick_stop_dt)    AS child_sick_stop_dt
                            FROM tmp_calc_app_params tt
                        GROUP BY tt.tc_pd)
                           ON xpd_id = tc_pd
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                       JOIN appeal ap ON ap.ap_id = xpd_ap
                       JOIN pc_decision pd ON pd.pd_id = xpd_id
                 WHERE     ncc_calc_period = '6MONTHS'
                       AND NCC_PD_PERIOD_ALG = 'AP_REG'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND xpd_ic_tp = 'R0'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.START_DT'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.FULL';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', '12MONTHS') > 0
        THEN
            --dbms_output_put_lines ('12MONTHS');
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                SELECT xpd_id,
                       TRUNC (xpd_ap_reg_dt, 'MM'),
                       ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 12)
                  FROM tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config ncc
                 WHERE     xpd_nst = ncc_nst
                       AND ncc_calc_period = '12MONTHS'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND xpd_ic_tp = 'R0'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.START_DT'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.FULL';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', '36MONTHS') > 0
        THEN
            --dbms_output_put_lines ('12MONTHS');
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                SELECT xpd_id,
                       TRUNC (xpd_ap_reg_dt, 'MM'),
                       ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 36)
                  FROM tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config ncc
                 WHERE     xpd_nst = ncc_nst
                       AND ncc_calc_period = '36MONTHS'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND xpd_ic_tp = 'R0'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.START_DT'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.FULL';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', '37MONTHS') > 0
        THEN
            dbms_output_put_lines ('37MONTHS');

            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                --SELECT xpd_id, TRUNC(xpd_ap_reg_dt, 'MM'), ADD_MONTHS(TRUNC(xpd_ap_reg_dt, 'MM'), 37)
                SELECT xpd_id,
                       t.xpd_start_dt,
                       ADD_MONTHS (t.xpd_start_dt, 37)
                  FROM tmp_pd_calc_params  t
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON     xpd_nst = ncc_nst
                              AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                  AND ncc.ncc_stop_dt
                 WHERE     ncc_calc_period = '37MONTHS'
                       AND xpd_ic_tp = 'R0'
                       AND t.xpd_prev_pd IS NULL
                UNION ALL
                SELECT xpd_id,
                       ADD_MONTHS (t.xpd_prev_stop_dt, 1),
                       ADD_MONTHS (pd.pd_start_dt, 37)
                  FROM tmp_pd_calc_params  t
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON     xpd_nst = ncc_nst
                              AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                  AND ncc.ncc_stop_dt
                       JOIN pc_decision pd ON pd_id = xpd_prev_pd
                 WHERE ncc_calc_period = '37MONTHS' AND xpd_ic_tp = 'R0'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.START_DT'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.FULL';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', 'INV_END') > 0
        THEN
            dbms_output_put_lines ('INV_END');

            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                WITH
                    calc_params
                    AS
                        (  SELECT xpd_id,
                                  xpd_src,
                                  xpd_start_dt,
                                  xpd_ap_reg_dt,
                                  MAX (tc_inv_stop_dt) + 1
                                      max_inv_stop_dt,
                                  MAX (ADD_MONTHS (tc_birth_dt, 216))
                                      AS max_18_dt,
                                  SUM (
                                      CASE tc_inv_state
                                          WHEN 'I' THEN 0
                                          WHEN 'IZ' THEN 1
                                          WHEN 'DI' THEN 0
                                      END)
                                      AS x_iz
                             FROM tmp_pd_calc_params
                                  JOIN tmp_calc_app_params ON xpd_id = tc_pd
                                  JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                      ON xpd_nst = ncc_nst
                            WHERE --допомога особам з інвалідністю с дитинства та дітям з інвалідністю надається до дати закінчення періоду інвалідності або 18річча дитини
                                      (   tc_inv_stop_dt > xpd_ap_reg_dt
                                       OR ADD_MONTHS (tc_birth_dt, 216) >
                                          xpd_ap_reg_dt)
                                  AND ncc_calc_period = 'INV_END'
                                  AND NCC_PD_PERIOD_ALG = 'AP_REG'
                                  AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                      AND ncc.ncc_stop_dt
                                  AND xpd_ic_tp = 'R0'
                         GROUP BY xpd_id,
                                  xpd_src,
                                  xpd_start_dt,
                                  xpd_ap_reg_dt)
                      SELECT xpd_id,
                             TRUNC (xpd_ap_reg_dt, 'MM'),
                             NVL (
                                 LEAST (MAX (tc_inv_stop_dt),
                                        MAX (ADD_MONTHS (tc_birth_dt, 216))),
                                 ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 12))
                        FROM tmp_pd_calc_params
                             JOIN tmp_calc_app_params ON xpd_id = tc_pd
                             JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                 ON xpd_nst = ncc_nst
                       WHERE --допомога особам з інвалідністю с дитинства та дітям з інвалідністю надається до дати закінчення періоду інвалідності або 18річча дитини
                                 (   tc_inv_stop_dt > xpd_ap_reg_dt
                                  OR ADD_MONTHS (tc_birth_dt, 216) >
                                     xpd_ap_reg_dt)
                             AND ncc_calc_period = 'INV_END'
                             AND NCC_PD_PERIOD_ALG = 'TR_AP_REG'
                             AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                 AND ncc.ncc_stop_dt
                             AND xpd_ic_tp = 'R0'
                    GROUP BY xpd_id, xpd_ap_reg_dt
                    UNION ALL
                    SELECT xpd_id,
                           CASE
                               WHEN xpd_src = 'SA' --Для держутримань - дату початку вже розрахували
                                                   THEN xpd_start_dt
                               WHEN xpd_src = 'RC' --Для подовження інвалідності - дату початку вже розрахували
                                                   THEN xpd_start_dt
                               ELSE xpd_ap_reg_dt
                           END    AS x_start_dt,
                           CASE
                               WHEN xpd_src = 'RC'
                               THEN
                                   CASE
                                       WHEN xpd_start_dt >= max_18_dt
                                       THEN
                                           NVL (
                                               max_inv_stop_dt,
                                               ADD_MONTHS (xpd_start_dt, 12))
                                       WHEN     xpd_start_dt < max_18_dt
                                            AND x_iz > 0
                                       THEN
                                           NVL (
                                               max_inv_stop_dt,
                                               ADD_MONTHS (xpd_start_dt, 12))
                                       ELSE
                                           NVL (
                                               LEAST (max_inv_stop_dt,
                                                      max_18_dt),
                                               ADD_MONTHS (xpd_start_dt, 12))
                                   END
                               ELSE
                                   CASE
                                       WHEN xpd_ap_reg_dt >= max_18_dt
                                       THEN
                                           NVL (
                                               max_inv_stop_dt,
                                               ADD_MONTHS (
                                                   TRUNC (xpd_ap_reg_dt,
                                                          'MM'),
                                                   12))
                                       WHEN     xpd_ap_reg_dt < max_18_dt
                                            AND x_iz > 0
                                       THEN
                                           NVL (
                                               max_inv_stop_dt,
                                               ADD_MONTHS (
                                                   TRUNC (xpd_ap_reg_dt,
                                                          'MM'),
                                                   12))
                                       ELSE
                                           NVL (
                                               LEAST (max_inv_stop_dt,
                                                      max_18_dt),
                                               ADD_MONTHS (
                                                   TRUNC (xpd_ap_reg_dt,
                                                          'MM'),
                                                   12))
                                   END
                           END    AS x_stop_dt
                      FROM calc_params
                    UNION ALL
                    SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                      FROM tmp_in_calc_pd
                     WHERE ic_tp = 'RC.START_DT'
                    UNION ALL
                    SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                      FROM tmp_in_calc_pd
                     WHERE ic_tp = 'RC.FULL';
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
                               WHEN     XPD_SRC = 'PV'
                                    AND EXISTS
                                            (SELECT *
                                               FROM pd_source s
                                              WHERE s.pds_pd = xpd_id)
                                    AND XPD_START_DT IS NOT NULL
                               THEN
                                   XPD_START_DT
                               WHEN xpd_ap_reg_dt <
                                    TO_DATE ('23.08.2022', 'dd.mm.yyyy')
                               THEN
                                   TRUNC (xpd_ap_reg_dt, 'MM')
                               WHEN TRUNC (kaots_start_dt, 'MM') <
                                    TRUNC (xpd_ap_reg_dt, 'MM')
                               THEN
                                   TRUNC (xpd_ap_reg_dt, 'MM')
                               WHEN TRUNC (kaots_start_dt, 'MM') =
                                    TRUNC (xpd_ap_reg_dt, 'MM')
                               THEN
                                   TRUNC (ADD_MONTHS (xpd_ap_reg_dt, 1),
                                          'MM')
                               ELSE
                                   TRUNC (xpd_ap_reg_dt, 'MM')
                           END    AS start_dt,
                           --             last_day(ADD_MONTHS(TOOLS.GGPD('WAR_MARTIAL_LAW_END'), 1))+1--ADD_MONTHS(TRUNC(TOOLS.GGPD('WAR_2PHASE_START'), 'MM'), 11)
                           --             last_day(TOOLS.GGPD('VPO_END_BY_709'))+1
                           LAST_DAY (TOOLS.GGPD ('VPO_END_BY_94')) + 1
                      --api$calc_pd.get_stop_date_664(pd_pa,  xpd_ap_reg_dt, ap.ap_is_second) AS stop_dt
                      FROM tmp_pd_calc_params
                           JOIN uss_ndi.v_ndi_nst_calc_config ncc
                               ON xpd_nst = ncc_nst
                           JOIN ap_person app
                               ON     app.app_ap = xpd_ap
                                  AND app.app_tp = 'Z'
                                  AND app.history_status = 'A'
                           --           JOIN uss_ndi.v_ndi_katottg nk ON nk.kaot_id = API$PC_DECISION.get_doc_id(app.app_id, 605, 1775)
                           JOIN uss_ndi.v_ndi_katottg nk
                               ON nk.kaot_id =
                                  COALESCE (
                                      API$ACCOUNT.get_docx_id (
                                          xpd_id,
                                          app_sc,
                                          10052,
                                          2292,
                                          xpd_calc_dt),    --#82444 2022.12.23
                                      API$PC_DECISION.get_doc_id (app.app_id,
                                                                  605,
                                                                  1775))
                           LEFT JOIN kaot_state nks
                               ON nks.kaots_kaot = nk.kaot_kaot_l3
                     WHERE     ncc_calc_period = 'WAREND+1M'
                           AND ncc_pd_period_alg = 'TR_AP_REG'
                           AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                               AND ncc.ncc_stop_dt
                           AND xpd_ic_tp = 'R0'
                    UNION ALL
                    SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                      FROM tmp_in_calc_pd
                     WHERE ic_tp = 'RC.START_DT'
                    UNION ALL
                    SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                      FROM tmp_in_calc_pd
                     WHERE ic_tp = 'RC.FULL';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', 'DOCUMENT') > 0
        THEN
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                SELECT xpd_id,
                       --             trunc(API$ACCOUNT.get_docx_dt(xpd_id, app_sc, 10196, 2579, xpd_calc_dt), 'mm'),
                       --             last_day(API$ACCOUNT.get_docx_dt(xpd_id, app_sc, 10196, 2579, xpd_calc_dt))+1
                       COALESCE (api$calc_pd.Get_apri_income_stop_dt (
                                     xpd_id,
                                     app_sc,
                                     '1,4,5,28',
                                     xpd_calc_dt),
                                 API$ACCOUNT.get_docx_dt (xpd_id,
                                                          app_sc,
                                                          10196,
                                                          2579,
                                                          xpd_calc_dt)),
                         --API$ACCOUNT.get_docx_dt(xpd_id, app_sc, 10196, 2579, xpd_calc_dt),
                         API$ACCOUNT.get_docx_dt (xpd_id,
                                                  app_sc,
                                                  10196,
                                                  2580,
                                                  xpd_calc_dt)
                       + 1
                  FROM tmp_pd_calc_params
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                       JOIN ap_person app
                           ON     app.app_ap = xpd_ap
                              AND app.app_tp = 'Z'
                              AND app.history_status = 'A'
                 WHERE     ncc_calc_period = 'DOCUMENT'
                       AND NCC_PD_PERIOD_ALG = 'DOC10196'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND xpd_ic_tp = 'R0'
                UNION ALL
                SELECT xpd_id,
                       NVL (API$ACCOUNT.get_docx_dt_min (xpd_id,
                                                         NULL,
                                                         10205,
                                                         2688,
                                                         xpd_calc_dt),
                            xpd_start_dt),
                         API$ACCOUNT.get_docx_dt_max (xpd_id,
                                                      NULL,
                                                      10205,
                                                      2689,
                                                      NULL     /*xpd_calc_dt*/
                                                          )
                       + 1
                  --MIN(API$ACCOUNT.get_docx_dt(xpd_id, tpp_sc, 10205, 2688, xpd_calc_dt)),
                  --MAX(API$ACCOUNT.get_docx_dt(xpd_id, tpp_sc, 10205, 2689, xpd_calc_dt))+1
                  FROM tmp_pd_calc_params
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                 --JOIN ap_person app ON app.app_ap = xpd_ap AND app.app_tp = 'FP' AND app.history_status = 'A'
                 --JOIN tmp_pa_persons tpp ON tpp.tpp_pd = xpd_id AND tpp.tpp_app_tp = 'FP'
                 WHERE     ncc_calc_period = 'DOCUMENT'
                       AND NCC_PD_PERIOD_ALG = 'DOC10205'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND xpd_ic_tp = 'R0'
                --GROUP BY xpd_id
                UNION ALL
                  SELECT xpd_id,
                         TRUNC (xpd_ap_reg_dt, 'MM'),
                         MAX (
                             LEAST (
                                 ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 6),
                                   LAST_DAY (API$ACCOUNT.get_docx_dt (
                                                 xpd_id,
                                                 tc_sc,
                                                 10312,
                                                 8434,
                                                 xpd_calc_dt))
                                 + 1,
                                   LAST_DAY (ADD_MONTHS (tc_birth_dt, 12 * 18))
                                 + 1))
                    FROM tmp_pd_calc_params
                         JOIN tmp_calc_app_params ON xpd_id = tc_pd
                         JOIN uss_ndi.v_ndi_nst_calc_config ncc
                             ON xpd_nst = ncc_nst
                   WHERE     ncc_calc_period = 'DOCUMENT'
                         AND NCC_PD_PERIOD_ALG = 'DOC10312'
                         AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                             AND ncc.ncc_stop_dt
                         AND xpd_ic_tp = 'R0'
                         AND API$ACCOUNT.get_docx_count (xpd_id,
                                                         tc_sc,
                                                         10312,
                                                         xpd_calc_dt) > 0
                GROUP BY TRUNC (xpd_ap_reg_dt, 'MM'), xpd_id
                UNION ALL
                SELECT xpd_id,
                       API$ACCOUNT.get_docx_dt_min (xpd_id,
                                                    app_sc,
                                                    10323,
                                                    8522,
                                                    NULL       /*xpd_calc_dt*/
                                                        ),
                         API$ACCOUNT.get_docx_dt_max (xpd_id,
                                                      app_sc,
                                                      10323,
                                                      8523,
                                                      NULL     /*xpd_calc_dt*/
                                                          )
                       + 1
                  FROM tmp_pd_calc_params
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                       JOIN ap_person app
                           ON     app.app_ap = xpd_ap
                              AND app.app_tp = 'Z'
                              AND app.history_status = 'A'
                 WHERE     ncc_calc_period = 'DOCUMENT'
                       AND NCC_PD_PERIOD_ALG = 'DOC10323'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND xpd_ic_tp = 'R0'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.START_DT'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.FULL'
                UNION ALL
                SELECT xpd_id,
                       API$ACCOUNT.get_docx_dt (xpd_id,
                                                app_sc,
                                                10342,
                                                8625,
                                                xpd_calc_dt),
                         API$ACCOUNT.get_docx_dt (xpd_id,
                                                  app_sc,
                                                  10342,
                                                  8626,
                                                  xpd_calc_dt)
                       + 1
                  FROM tmp_pd_calc_params
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                       JOIN ap_person app
                           ON     app.app_ap = xpd_ap
                              AND app.app_tp = 'Z'
                              AND app.history_status = 'A'
                 WHERE     ncc_calc_period = 'DOCUMENT'
                       AND NCC_PD_PERIOD_ALG = 'DOC10342'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND xpd_ic_tp = 'R0'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.START_DT'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.FULL';
        --#107323
        --2. Відновити контроль щодо періоду призначення допомоги.
        --А саме: встановити, що допомога для дитини (код виплати NPT_CODE 537) призначається до останнього дня місяця,
        --в якому дитині виповниться 6 років, але не пізніше ніж останній день місяця,
        --в якому закінчується термін дії "Посвідчення батьків багатодітної сім’ї" NDT_ID=10108 (дата зазначається в атрибуті "Документ дійсний до" nda_id= 2275).

        ELSIF is_have_nst_by_alg ('CALC_PERIOD', '6YEARS') > 0
        THEN
            dbms_output_put_lines ('6YEARS');

            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                  SELECT xpd_id,
                         TRUNC (xpd_ap_reg_dt, 'MM'),
                           --MAX( last_day( ADD_MONTHS(fp.tc_birth_dt,12*6) ) ) + 1
                           MAX (
                               LAST_DAY (
                                   CASE
                                       WHEN ADD_MONTHS (fp.tc_birth_dt, 12 * 6) <=
                                            doc_dt
                                       THEN
                                           ADD_MONTHS (fp.tc_birth_dt, 12 * 6)
                                       ELSE
                                           doc_dt
                                   END))
                         + 1
                    FROM tmp_pd_calc_params
                         JOIN uss_ndi.v_ndi_nst_calc_config ncc
                             ON xpd_nst = ncc_nst
                         JOIN tmp_calc_app_params fp
                             ON xpd_id = fp.tc_pd AND fp.tc_tp != 'Z'
                         JOIN (SELECT tc_pd,
                                      COALESCE (API$ACCOUNT.get_docx_dt (
                                                    tc_pd,
                                                    tc_sc,
                                                    10108,
                                                    2275,
                                                    tc_calc_dt), --#104496 25.06.2024
                                                API$ACCOUNT.get_docx_dt (
                                                    tc_pd,
                                                    tc_sc,
                                                    10202,
                                                    2649,
                                                    tc_calc_dt))    AS doc_dt
                                 FROM tmp_calc_app_params
                                WHERE tc_tp = 'Z') zz
                             ON xpd_id = zz.tc_pd
                   WHERE     ncc_calc_period = '6YEARS'
                         AND NCC_PD_PERIOD_ALG = 'TR_AP_REG'
                         AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                             AND ncc.ncc_stop_dt
                         AND xpd_ic_tp = 'R0'
                GROUP BY xpd_id, TRUNC (xpd_ap_reg_dt, 'MM')
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.START_DT'
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.FULL';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', '18YEARS.U') > 0
        THEN
            dbms_output_put_lines ('18YEARS.U');

            -- Утриманцям, яким встановлено інвалідність (у зверненні додано документ "Виписка з акту огляду МСЕК" NDT_ID 201 або
            --"Медичний висновок (для дітей з інвалідністю до 18 років)" NDT_ID 200), державна соціальна допомога (код виплати Npt_code 517)
            --призначається до досягнення ними 23-річного віку.
            -- Але не пізніше ніж дата (атрибут NDA_ID 793 - "Встановлено на період до"), зазначена в документі (NDT_ID 200- Медичний висновок
            --(для дітей з інвалідністю до 18 років).
            --#96381
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                  SELECT xpd_id,
                         MIN (
                             COALESCE (
                                 API$PC_DECISION.get_doc_dt (app_id, 661, 2666),
                                 API$PC_DECISION.get_doc_dt (app_id, 662, 2667))),
                         MAX (
                             CASE
                                 WHEN tc.tc_inv_stop_dt >
                                      ADD_MONTHS (f.pdf_birth_dt, 12 * 23)
                                 THEN
                                     ADD_MONTHS (f.pdf_birth_dt, 12 * 23)
                                 WHEN tc.tc_inv_stop_dt >
                                      ADD_MONTHS (f.pdf_birth_dt, 12 * 18)
                                 THEN
                                     tc.tc_inv_stop_dt
                                 --#101786
                                 WHEN tc.TC_STUDY_STOP_DT >
                                      ADD_MONTHS (f.pdf_birth_dt, 12 * 23)
                                 THEN
                                     ADD_MONTHS (f.pdf_birth_dt, 12 * 23)
                                 WHEN tc.TC_STUDY_STOP_DT >
                                      ADD_MONTHS (f.pdf_birth_dt, 12 * 18)
                                 THEN
                                     tc.TC_STUDY_STOP_DT
                                 --
                                 ELSE
                                     ADD_MONTHS (f.pdf_birth_dt, 12 * 18)
                             END)
                    FROM tmp_pd_calc_params
                         JOIN uss_ndi.v_ndi_nst_calc_config ncc
                             ON xpd_nst = ncc_nst
                         JOIN ap_person app
                             ON     app.app_ap = xpd_ap
                                AND app.app_tp = 'FP'
                                AND app.history_status = 'A'
                         JOIN pd_family f
                             ON     f.pdf_pd = xpd_id
                                AND f.pdf_sc = app_sc
                                AND f.history_status = 'A'
                         JOIN tmp_calc_app_params tc
                             ON tc.tc_pd = xpd_id AND tc.tc_sc = f.pdf_sc
                   WHERE     ncc_calc_period = '18YEARS.U'
                         AND NCC_PD_PERIOD_ALG = 'BIRTH_18Y'
                         AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                             AND ncc.ncc_stop_dt
                         AND xpd_ic_tp = 'R0'
                GROUP BY xpd_id
                UNION ALL
                  --Обробка ситуації, коли пр коригуванні змінюється дата, до якої призначено
                  SELECT xpd_id,
                         ic_start_dt,
                         MAX (
                             CASE
                                 WHEN tc.tc_inv_stop_dt >
                                      ADD_MONTHS (f.pdf_birth_dt, 12 * 23)
                                 THEN
                                     ADD_MONTHS (f.pdf_birth_dt, 12 * 23)
                                 WHEN tc.tc_inv_stop_dt >
                                      ADD_MONTHS (f.pdf_birth_dt, 12 * 18)
                                 THEN
                                     tc.tc_inv_stop_dt
                                 --#101786
                                 WHEN tc.TC_STUDY_STOP_DT >
                                      ADD_MONTHS (f.pdf_birth_dt, 12 * 23)
                                 THEN
                                     ADD_MONTHS (f.pdf_birth_dt, 12 * 23)
                                 WHEN tc.TC_STUDY_STOP_DT >
                                      ADD_MONTHS (f.pdf_birth_dt, 12 * 18)
                                 THEN
                                     tc.TC_STUDY_STOP_DT
                                 --
                                 ELSE
                                     ADD_MONTHS (f.pdf_birth_dt, 12 * 18)
                             END)
                    FROM tmp_pd_calc_params
                         JOIN tmp_in_calc_pd ON ic_pd = xpd_id
                         --JOIN ap_person app  ON app.app_ap = xpd_ap AND app.app_tp = 'FP' AND app.history_status = 'A'
                         JOIN pd_family f
                             ON f.pdf_pd = xpd_id AND /*f.pdf_sc = app_sc AND*/
                                                      f.history_status = 'A'
                         JOIN tmp_calc_app_params tc
                             ON tc.tc_pd = xpd_id AND tc.tc_sc = f.pdf_sc
                         JOIN uss_ndi.v_ndi_nst_calc_config ncc
                             ON xpd_nst = ncc_nst
                   WHERE     ncc_calc_period = '18YEARS.U'
                         AND NCC_PD_PERIOD_ALG = 'BIRTH_18Y'
                         AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                             AND ncc.ncc_stop_dt
                         AND xpd_ic_tp = 'RC.START_DT'
                GROUP BY xpd_id, ic_start_dt
                UNION ALL
                SELECT ic_pd, ic_start_dt, ic_stop_dt + 1
                  FROM tmp_in_calc_pd
                 WHERE ic_tp = 'RC.FULL';
        ELSIF is_have_nst_by_alg ('CALC_PERIOD', '7DAY+30DAY') > 0
        THEN
            dbms_output_put_lines ('7DAY+30DAY');

            -- Утриманцям, яким встановлено інвалідність (у зверненні додано документ "Виписка з акту огляду МСЕК" NDT_ID 201 або
            --"Медичний висновок (для дітей з інвалідністю до 18 років)" NDT_ID 200), державна соціальна допомога (код виплати Npt_code 517)
            --призначається до досягнення ними 23-річного віку.
            -- Але не пізніше ніж дата (атрибут NDA_ID 793 - "Встановлено на період до"), зазначена в документі (NDT_ID 200- Медичний висновок
            --(для дітей з інвалідністю до 18 років).
            --#96381
            INSERT INTO tmp_calc_pd (c_pd, c_start_dt, c_stop_dt)
                SELECT xpd_id, xpd_start_dt, xpd_start_dt + 7 + 30
                  FROM tmp_pd_calc_params
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                 WHERE     ncc_calc_period = '7DAY+30DAY'
                       --          AND NCC_PD_PERIOD_ALG = 'BIRTH_18Y'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt;
        END IF;
    END;

    --=========================================================--
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
             WHERE     c_pd = xpd_id
                   AND c_pd = xpdf_pd
                   AND (   xpd_ic_tp = 'R0'
                        OR xpd_ic_tp = 'RC.START_DT'
                        OR xpd_ic_tp = 'RC.FULL')
            UNION ALL
            SELECT c_pd,
                   xpdf_id,
                   ADD_MONTHS (c_start_dt, 1),
                   1
              FROM tmp_calc_pd,
                   tmp_pd_calc_params,
                   tmp_pdf_calc_params,
                   uss_ndi.v_ndi_nst_calc_config  ncc
             WHERE     c_pd = xpd_id
                   AND c_pd = xpdf_pd
                   AND xpd_nst = ncc_nst
                   AND ncc_break_1months = 'T'
                   AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                       AND ncc.ncc_stop_dt
                   AND xpd_ic_tp = 'R0'
            UNION ALL
            SELECT c_pd,
                   xpdf_id,
                   c_stop_dt,
                   2
              FROM tmp_calc_pd, tmp_pd_calc_params, tmp_pdf_calc_params
             WHERE c_pd = xpd_id AND c_pd = xpdf_pd;

        SaveMessage ('Отримуємо розриви за законодавчими змінами розрахунку');

        INSERT INTO tmp_tar_dates1 (ttd_pd,
                                    ttd_pdf,
                                    ttd_dt,
                                    ttd_source)
            SELECT c_pd,
                   xpdf_id,
                   br_dt,
                   0
              FROM tmp_calc_pd  t
                   JOIN tmp_pd_calc_params ON xpd_id = c_pd
                   JOIN tmp_pdf_calc_params ON xpdf_pd = c_pd
                   JOIN TABLE (Get_break) ON br_nst = xpd_nst
             WHERE     br_dt BETWEEN t.c_start_dt AND t.c_stop_dt
                   AND br_dt BETWEEN xpdf_start_dt AND xpdf_stop_dt
            UNION ALL
            SELECT c_pd,
                   xpdf_id,
                   x_dt,
                   0
              FROM tmp_calc_pd  t
                   JOIN tmp_pd_calc_params ON xpd_id = c_pd
                   JOIN tmp_pdf_calc_params ON xpdf_pd = c_pd
                   JOIN (SELECT t.ndv_start_dt AS x_dt, 251 AS x_nst
                           FROM uss_ndi.V_NDI_DEC_VALUES t
                          WHERE t.history_status = 'A')
                       ON x_nst = xpd_nst
             WHERE x_dt BETWEEN t.c_start_dt AND t.c_stop_dt;

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
                       uss_ndi.v_ndi_living_wage      lw,
                       uss_ndi.v_ndi_nst_calc_config  ncc
                 WHERE     c_pd = xpdf_pd
                       AND c_pd = xpd_id
                       AND lw.history_status = 'A'
                       AND lgw_start_dt BETWEEN c_start_dt AND c_stop_dt
                       AND xpd_nst = ncc_nst
                       AND ncc_break_lgw = 'T'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt;
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
                       uss_ndi.v_ndi_lgw_sub_level    nl,
                       uss_ndi.v_ndi_nst_calc_config  ncc
                 WHERE     c_pd = xpdf_pd
                       AND c_pd = xpd_id
                       AND nl.history_status = 'A'
                       AND nlsl_start_dt BETWEEN c_start_dt AND c_stop_dt
                       AND xpd_nst = ncc_nst
                       AND ncc_break_lgw_level = 'T'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt;
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
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_birth = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
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
                       xpdf_id                                       /*z_pdf*/
                              ,
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
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_birth = 'TR'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_pdf_calc_params ON z_pd = xpdf_pd -- Размножили точку разріва на всю семью
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
                       xpdf_id                                       /*z_pdf*/
                              ,
                       z_dt,
                       5
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               TOOLS.ADD_MONTHS_LEAP (xpdf_birth_dt, 72)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_6years = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_pdf_calc_params ON z_pd = xpdf_pd -- Размножили точку разріва на всю семью
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt /*
                    AND z_dt BETWEEN xpdf_start_dt AND xpdf_stop_dt*/
                                                            ;
        END IF;

        IF is_have_nst_by_alg ('BREAK_6YEARS', 'TR') > 0
        THEN
            SaveMessage (
                'Дати настання повних 6 років утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT DISTINCT z_pd,
                                xpdf_id                              /*z_pdf*/
                                       ,
                                z_dt,
                                5
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               LAST_DAY (ADD_MONTHS (xpdf_birth_dt, 72)) + 1
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_6years = 'TR'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_pdf_calc_params ON z_pd = xpdf_pd -- Размножили точку разріва на всю семью
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
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               TOOLS.ADD_MONTHS_LEAP (xpdf_birth_dt, 216)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
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
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND xpd_nst = 267
                               AND ncc_break_18years = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        ELSIF is_have_nst_by_alg ('BREAK_18YEARS', 'T2Z') > 0
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
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               TOOLS.ADD_MONTHS_LEAP (xpdf_birth_dt, 216)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'T2Z'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       6
                  FROM (SELECT c_pd
                                   AS z_pd,
                               (SELECT xf.xpdf_id
                                  FROM tmp_pdf_calc_params  xf
                                       JOIN tmp_calc_app_params xtc
                                           ON     xtc.tc_pd = xf.xpdf_pd
                                              AND xtc.tc_sc = xf.xpdf_sc
                                 WHERE xf.xpdf_pd = c.c_pd AND tc_tp = 'Z')
                                   AS z_pdf,
                               ADD_MONTHS (xpdf_birth_dt, 216)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd                    c,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'T2Z'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       6
                  FROM (SELECT c_pd
                                   AS z_pd,
                               (SELECT xf.xpdf_id
                                  FROM tmp_pdf_calc_params  xf
                                       JOIN tmp_calc_app_params xtc
                                           ON     xtc.tc_pd = xf.xpdf_pd
                                              AND xtc.tc_sc = xf.xpdf_sc
                                 WHERE xf.xpdf_pd = c.c_pd AND tc_tp = 'ANF')
                                   AS z_pdf,
                               ADD_MONTHS (xpdf_birth_dt, 216)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd                    c,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'T2Z'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        ELSIF is_have_nst_by_alg ('BREAK_18YEARS', 'T2ALL') > 0
        THEN
            SaveMessage (
                'Дати настання повних 18 років утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       xpdf_id                                       /*z_pdf*/
                              ,
                       z_dt,
                       6
                  FROM (SELECT c_pd                                AS z_pd,
                               xpdf_id                             AS z_pdf,
                               ADD_MONTHS (xpdf_birth_dt, 216)     AS z_dt,
                               c_start_dt,
                               c_stop_dt                       --Ошибка #73294
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'T2ALL'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_pdf_calc_params ON z_pd = xpdf_pd -- Размножили точку разріва на всю семью
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
                       xpdf_id                                       /*z_pdf*/
                              ,
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
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'EM'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_pdf_calc_params ON z_pd = xpdf_pd -- Размножили точку разріва на всю семью
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
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               TOOLS.ADD_MONTHS_LEAP (xpdf_birth_dt, 276)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_6years = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        ELSIF is_have_nst_by_alg ('BREAK_23YEARS', 'T2ALL') > 0
        THEN
            SaveMessage (
                'Дати настання повних 23 років утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       xpdf_id                                       /*z_pdf*/
                              ,
                       z_dt,
                       7
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               TOOLS.ADD_MONTHS_LEAP (xpdf_birth_dt, 276)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt                       --Ошибка #73294
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'T2ALL'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_pdf_calc_params ON z_pd = xpdf_pd -- Размножили точку разріва на всю семью
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        ELSIF is_have_nst_by_alg ('BREAK_23YEARS', 'EM') > 0
        THEN
            SaveMessage (
                'Місяць настання повних 23 років утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       xpdf_id                                       /*z_pdf*/
                              ,
                       z_dt,
                       7
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               LAST_DAY (ADD_MONTHS (xpdf_birth_dt, 276)) + 1
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt                       --Ошибка #73294
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_18years = 'EM'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_pdf_calc_params ON z_pd = xpdf_pd -- Размножили точку разріва на всю семью
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
                /*
                        SELECT z_pd, xpdf_id, z_dt, 8
                        FROM (SELECT c_pd AS z_pd, xpdf_id AS z_pdf, --Медичний висновок (для дітей інвалідів до 18 років) - встановлено на період по
                                     Api$account.get_docx_dt(xpdf_pd, xpdf_sc, 200, 793, xpd_calc_dt) AS z_dt, c_start_dt, c_stop_dt
                              FROM tmp_calc_pd, tmp_pdf_calc_params, tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config ncc
                              WHERE xpdf_pd = c_pd
                                AND xpd_id = c_pd
                                AND xpd_nst = ncc_nst
                                AND ncc_break_inv = 'T'
                                AND xpd_calc_dt BETWEEN ncc.ncc_start_dt AND ncc.ncc_stop_dt)
                             JOIN tmp_pdf_calc_params ON z_pd = xpdf_pd -- Размножили точку разріва на всю семью
                        WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                */
                SELECT z_pd,
                       xpdf_id,
                       z_dt,
                       8
                  FROM (SELECT c_pd                   AS z_pd,
                               tc_pdf                 AS z_pdf, --Медичний висновок (для дітей інвалідів до 18 років) - встановлено на період по
                               tc_inv_stop_dt + 1     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_calc_app_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_pdf_calc_params ON z_pd = xpdf_pd -- Размножили точку разріва на всю семью
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                /*
                        SELECT z_pd, z_pdf, z_dt, 8
                        FROM (SELECT tc_pd AS z_pd, tc_pdf AS z_pdf, tc_inv_stop_dt + 1 AS z_dt, c_start_dt, c_stop_dt
                              FROM tmp_calc_pd, tmp_calc_app_params, tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config ncc
                              WHERE tc_pd = c_pd
                                AND xpd_id = c_pd
                                AND xpd_nst = ncc_nst
                                AND ncc_break_inv = 'T'
                                and tc_inv_stop_dt < to_date('3000', 'yyyy')
                                AND xpd_calc_dt BETWEEN ncc.ncc_start_dt AND ncc.ncc_stop_dt )
                        WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                */
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
                                                        792,
                                                        xpd_calc_dt)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
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
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'X'
                               AND tc_inv_stop_dt < TO_DATE ('3000', 'yyyy')
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
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
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'X'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                --Дата 01.07.2022 при наявності tc_is_child_inv_reason = 'EXPLOSE' - теж розрив
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       19
                  FROM (SELECT tc_pd
                                   AS z_pd,
                               tc_pdf
                                   AS z_pdf,
                               TO_DATE ('01.07.2022', 'dd.mm.yyyy')
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_calc_app_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'X'
                               AND tc_is_child_inv_reason = 'EXPLOSE'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                --Дата початку наступного місяця пр перерахунку інвалідності - теж розрив
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       23
                  FROM (SELECT tc_pd
                                   AS z_pd,
                               tc_pdf
                                   AS z_pdf,
                               TRUNC (ADD_MONTHS (tc_inv_start_dt, 1), 'MM')
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_calc_app_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'X'
                               AND tc_inv_rc_alg = '1'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                --Дата, з якої встановлено догляд за інвалідом - теж розрив
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       26
                  FROM (SELECT tc_pd                   AS z_pd,
                               tc_pdf                  AS z_pdf,
                               tc.tc_care_start_dt     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_calc_app_params            tc,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'X'
                               AND TC_CARE_LEAVE IN
                                       ('CRNG_CH_3',
                                        'CRNG_CH_6',
                                        'CRNG_INV_18')
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                --Дата, до якої встановлено догляд за інвалідом - теж розрив
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       27
                  FROM (SELECT tc_pd                      AS z_pd,
                               tc_pdf                     AS z_pdf,
                               tc.tc_care_stop_dt + 1     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_calc_app_params            tc,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     tc_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_inv = 'X'
                               AND TC_CARE_LEAVE IN
                                       ('CRNG_CH_3',
                                        'CRNG_CH_6',
                                        'CRNG_INV_18')
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
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
                  FROM (SELECT tc_pd
                                   AS z_pd,
                               tc_pdf
                                   AS z_pdf,
                               LAST_DAY (TRUNC (tc_inv_stop_dt)) + 1
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_calc_app_params ON tc_pd = c_pd
                               JOIN tmp_pd_calc_params ON xpd_id = c_pd
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_break_inv = 'TR'
                               AND ncc_calc_app_params = 'T'
                               AND tc_inv_stop_dt < TO_DATE ('3000', 'yyyy')
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
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
                          FROM tmp_calc_pd
                               JOIN tmp_calc_app_params ON tc_pd = c_pd
                               JOIN tmp_pd_calc_params ON xpd_id = c_pd
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_break_inv = 'TR'
                               AND ncc_calc_app_params = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       8
                  FROM (SELECT c_pd       AS z_pd,
                               xpdf_id    AS z_pdf, --Медичний висновок (для дітей інвалідів до 18 років) - встановлено на період по
                                 LAST_DAY (TRUNC (Api$account.get_docx_dt (
                                                      xpdf_pd,
                                                      xpdf_sc,
                                                      200,
                                                      793,
                                                      xpd_calc_dt)))
                               + 1        AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pdf_calc_params ON xpdf_pd = c_pd
                               JOIN tmp_pd_calc_params ON xpd_id = c_pd
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_break_inv = 'TR'
                               AND ncc_calc_app_params = 'F'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt/*
                                                                  UNION ALL
                                                                  --Дата встановлення інвалідністі - теж розрив
                                                                  SELECT z_pd, z_pdf, z_dt, 9
                                                                  FROM (SELECT c_pd AS z_pd, xpdf_id AS z_pdf, --Медичний висновок (для дітей інвалідів до 18 років) - встановлено на період по
                                                                               --API$PC_DECISION.get_doc_dt(xpdf_app, 200, 792, xpd_calc_dt) AS z_dt, c_start_dt, c_stop_dt
                                                                               trunc(Api$account.get_docx_dt(xpdf_pd, xpdf_sc, 200, 793, xpd_calc_dt), 'mm') AS z_dt, c_start_dt, c_stop_dt
                                                                        FROM tmp_calc_pd
                                                                             JOIN tmp_pdf_calc_params ON  xpdf_pd = c_pd
                                                                             JOIN tmp_pd_calc_params  ON  xpd_id = c_pd
                                                                             JOIN uss_ndi.v_ndi_nst_calc_config ON xpd_nst = ncc_nst
                                                                        WHERE ncc_break_inv = 'TR'
                                                                              AND ncc_calc_app_params = 'F')
                                                                  WHERE z_dt BETWEEN c_start_dt AND c_stop_dt*/
                                                            ;
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
                       uss_ndi.v_ndi_care_raise       ncr,
                       tmp_pd_calc_params,
                       uss_ndi.v_ndi_nst_calc_config  ncc
                 WHERE     c_pd = xpdf_pd
                       AND ncr.history_status = 'A'
                       AND ncr_start_dt BETWEEN c_start_dt AND c_stop_dt
                       AND xpd_id = c_pd
                       AND xpd_nst = ncc_nst
                       AND ncc_break_raise = 'T'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt;
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
                       dn_detail                      dnd,
                       tmp_pd_calc_params,
                       uss_ndi.v_ndi_nst_calc_config  ncc,
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
                       AND nnnc_ndn = dn_ndn
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_BD', 'T') > 0
        THEN
            SaveMessage ('Дати зміни історії бойових дій - розрив для ВПО');

            /*
            TMP_KAOTS(TKS_ID,
                                      TKS_KAOT,
                                      TKS_TP,
                                      TKS_START_DT,
                                      TKS_STOP_DT)
            */
            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       14
                  FROM (SELECT tc_pd                          AS z_pd,
                               tc_pdf                         AS z_pdf,
                               c_start_dt,
                               c_stop_dt,
                               TRUNC (tks_start_dt, 'MM')     AS z_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON xpd_id = c_pd
                               JOIN tmp_calc_app_params ON tc_pd = c_pd
                               JOIN TMP_KAOTS kh
                                   ON tks_kaot_init = tc_bd_kaot_id
                               /*                 JOIN uss_ndi.v_NDI_KATOTTG ON kaot_id = tc_bd_kaot_id AND kaot_st = 'A'
                                                JOIN TMP_KAOTS kh          --ON tks_kaot = kaot_kaot_l3
                                                                           ON ( kaot_id = kaot_kaot_l3 AND kh.tks_kaot = kaot_kaot_l3 )
                                                                              OR
                                                                              ( kaot_id = kaot_kaot_l4 AND ( kh.tks_kaot = kaot_kaot_l3 OR kh.tks_kaot = kaot_kaot_l4 ))
                                                                              OR
                                                                              ( kaot_id = kaot_kaot_l5 AND ( kh.tks_kaot = kaot_kaot_l3 OR kh.tks_kaot = kaot_kaot_l4 OR kh.tks_kaot = kaot_kaot_l5))*/
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_break_BD = 'T'
                               AND tks_start_dt BETWEEN c_start_dt
                                                    AND c_stop_dt
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
                UNION ALL
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       15
                  FROM (SELECT tc_pd                          AS z_pd,
                               tc_pdf                         AS z_pdf,
                               c_start_dt,
                               c_stop_dt,
                               LAST_DAY (tks_stop_dt) + 1     AS z_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON xpd_id = c_pd
                               JOIN tmp_calc_app_params ON tc_pd = c_pd
                               JOIN TMP_KAOTS kh
                                   ON tks_kaot_init = tc_bd_kaot_id
                               /*                 JOIN uss_ndi.v_NDI_KATOTTG ON kaot_id = tc_bd_kaot_id AND kaot_st = 'A'
                                                JOIN TMP_KAOTS kh          --ON tks_kaot = kaot_kaot_l3
                                                                           ON ( kaot_id = kaot_kaot_l3 AND kh.tks_kaot = kaot_kaot_l3 )
                                                                              OR
                                                                              ( kaot_id = kaot_kaot_l4 AND ( kh.tks_kaot = kaot_kaot_l3 OR kh.tks_kaot = kaot_kaot_l4 ))
                                                                              OR
                                                                              ( kaot_id = kaot_kaot_l5 AND ( kh.tks_kaot = kaot_kaot_l3 OR kh.tks_kaot = kaot_kaot_l4 OR kh.tks_kaot = kaot_kaot_l5))*/
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_break_BD = 'T'
                               AND tks_stop_dt BETWEEN c_start_dt
                                                   AND c_stop_dt
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
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
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_break_pdf_period = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
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
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_break_pdf_period = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_SICK', 'T') > 0
        THEN
            SaveMessage (
                'Дата завершення документу по строку захворювання - розрив ');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       18
                  FROM (SELECT tc_pd                           AS z_pd,
                               tc_pdf                          AS z_pdf,
                               a.tc_child_sick_stop_dt + 1     AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON xpd_id = c_pd
                               JOIN tmp_calc_app_params a ON tc_pd = c_pd
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_break_sick = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_PD_PERIOD_ALG', 'DOC10196') > 0
        THEN
            SaveMessage ('Розриви по не повному місяцю');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT c_pd,
                       xpdf_id,
                       LAST_DAY (c_start_dt) + 1,
                       21
                  FROM tmp_calc_pd,
                       tmp_pd_calc_params,
                       tmp_pdf_calc_params,
                       uss_ndi.v_ndi_nst_calc_config  ncc
                 WHERE     c_pd = xpd_id
                       AND c_pd = xpdf_pd
                       --          AND c_start_dt != last_day(c_start_dt)
                       AND c_start_dt != TRUNC (c_start_dt, 'MM')
                       AND xpd_nst = ncc_nst
                       AND ncc_pd_period_alg = 'DOC10196'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                UNION ALL
                SELECT c_pd,
                       xpdf_id,
                       TRUNC (c_stop_dt, 'MM'),
                       22
                  FROM tmp_calc_pd,
                       tmp_pd_calc_params,
                       tmp_pdf_calc_params,
                       uss_ndi.v_ndi_nst_calc_config  ncc
                 WHERE     c_pd = xpd_id
                       AND c_pd = xpdf_pd
                       AND c_start_dt != TRUNC (c_stop_dt, 'MM')
                       AND xpd_nst = ncc_nst
                       AND ncc_pd_period_alg = 'DOC10196'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_PD_PERIOD_ALG', 'BIRTH_18Y') > 0
        THEN
            SaveMessage ('Розриви по початку дії документу 661, 662');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT c_pd,
                       xpdf_id,
                       apda_val_dt,
                       23
                  FROM tmp_calc_pd
                       JOIN tmp_pd_calc_params ON xpd_id = c_pd
                       JOIN tmp_pdf_calc_params ON xpdf_pd = c_pd
                       JOIN tmp_calc_app_params
                           ON     tc_pd = c_pd
                              AND tc_sc = xpdf_sc
                              AND tc_start_dt IS NULL
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                       JOIN tmp_pa_documents d
                           ON     d.tpd_pd = c_pd
                              AND d.tpd_sc = xpdf_sc
                              AND d.tpd_ndt IN (661, 662)
                       JOIN ap_document_attr atr
                           ON     apda_apd = tpd_apd
                              AND atr.history_status = 'A'
                              AND atr.apda_nda IN (2666, 2667)
                 WHERE     ncc_pd_period_alg = 'BIRTH_18Y'
                       AND tc_tp = 'FP'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND apda_val_dt IS NOT NULL
                UNION ALL
                SELECT c_pd,
                       (SELECT MAX (xf.xpdf_id)
                          FROM tmp_pdf_calc_params  xf
                               JOIN tmp_calc_app_params xtc
                                   ON     xtc.tc_pd = xf.xpdf_pd
                                      AND xtc.tc_sc = xf.xpdf_sc
                                      AND tc_start_dt IS NULL
                         WHERE xf.xpdf_pd = c_pd AND tc_tp = 'Z')
                           AS xpdf_id,
                       apda_val_dt,
                       23
                  FROM tmp_calc_pd
                       JOIN tmp_pd_calc_params ON xpd_id = c_pd
                       JOIN tmp_pdf_calc_params ON xpdf_pd = c_pd
                       JOIN tmp_calc_app_params
                           ON     tc_pd = c_pd
                              AND tc_sc = xpdf_sc
                              AND tc_start_dt IS NULL
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                       JOIN tmp_pa_documents d
                           ON     d.tpd_pd = c_pd
                              AND d.tpd_sc = xpdf_sc
                              AND d.tpd_ndt IN (661, 662)
                       JOIN ap_document_attr atr
                           ON     apda_apd = tpd_apd
                              AND atr.history_status = 'A'
                              AND atr.apda_nda IN (2666, 2667)
                 WHERE     ncc_pd_period_alg = 'BIRTH_18Y'
                       AND tc_tp = 'FP'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND apda_val_dt IS NOT NULL;
        /*
                SELECT c_pd, xpdf_id,
                       COALESCE(API$ACCOUNT.get_docx_dt(xpdf_pd , xpdf_sc , 661, 2666, xpd_calc_dt ),
                                API$ACCOUNT.get_docx_dt(xpdf_pd , xpdf_sc , 662, 2667, xpd_calc_dt )),
                       23
                FROM tmp_calc_pd
                     JOIN tmp_pd_calc_params ON c_pd = xpd_id
                     JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                     JOIN tmp_calc_app_params ON tc_pd = c_pd AND tc_sc = xpdf_sc
                     JOIN uss_ndi.v_ndi_nst_calc_config ncc ON xpd_nst = ncc_nst
                WHERE ncc_pd_period_alg = 'BIRTH_18Y'
                  AND tc_tp = 'FP'
                  AND xpd_calc_dt BETWEEN ncc.ncc_start_dt AND ncc.ncc_stop_dt
                UNION ALL
                SELECT c_pd,
                       --xpdf_id,
                       (SELECT xf.xpdf_id
                        FROM tmp_pdf_calc_params xf
                             JOIN tmp_calc_app_params xtc ON xtc.tc_pd = xf.xpdf_pd AND xtc.tc_sc = xf.xpdf_sc
                        WHERE xf.xpdf_pd = c.c_pd
                          AND tc_tp = 'Z') AS xpdf_id,
                       COALESCE(API$ACCOUNT.get_docx_dt(xpdf_pd , xpdf_sc , 661, 2666, xpd_calc_dt ),
                                API$ACCOUNT.get_docx_dt(xpdf_pd , xpdf_sc , 662, 2667, xpd_calc_dt )),
                       23
                FROM tmp_calc_pd c
                     JOIN tmp_pd_calc_params ON c_pd = xpd_id
                     JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                     JOIN tmp_calc_app_params ON tc_pd = c_pd AND tc_sc = xpdf_sc
                     JOIN uss_ndi.v_ndi_nst_calc_config ncc ON xpd_nst = ncc_nst
                WHERE ncc_pd_period_alg = 'BIRTH_18Y'
                  AND tc_tp = 'FP'
                  AND xpd_calc_dt BETWEEN ncc.ncc_start_dt AND ncc.ncc_stop_dt
                  ;
        */
        END IF;

        IF is_have_nst_by_alg ('BREAK_PD_PERIOD_ALG', 'DOC10205') > 0
        THEN
            SaveMessage (
                'Розриви по початку та закунченню дії документу DOC10205');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                /*
                        SELECT c_pd, xpdf_id, API$ACCOUNT.get_docx_dt(xpdf_pd , xpdf_sc , 10205, 2688, xpd_calc_dt ) AS z_dt, 24
                        FROM tmp_calc_pd
                             JOIN tmp_pd_calc_params ON c_pd = xpd_id
                             JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                             JOIN tmp_calc_app_params ON tc_pd = c_pd AND tc_sc = xpdf_sc
                             JOIN uss_ndi.v_ndi_nst_calc_config ncc ON xpd_nst = ncc_nst
                        WHERE ncc_pd_period_alg = 'DOC10205'
                          AND tc_tp = 'FP'
                          AND xpd_calc_dt BETWEEN ncc.ncc_start_dt AND ncc.ncc_stop_dt
                        UNION ALL
                        SELECT c_pd, xpdf_id, API$ACCOUNT.get_docx_dt(xpdf_pd , xpdf_sc , 10205, 2689, xpd_calc_dt )+1 AS z_dt,  25
                        FROM tmp_calc_pd
                             JOIN tmp_pd_calc_params ON c_pd = xpd_id
                             JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                             JOIN tmp_calc_app_params ON tc_pd = c_pd AND tc_sc = xpdf_sc
                             JOIN uss_ndi.v_ndi_nst_calc_config ncc ON xpd_nst = ncc_nst
                        WHERE ncc_pd_period_alg = 'DOC10205'
                          AND tc_tp = 'FP'
                          AND xpd_calc_dt BETWEEN ncc.ncc_start_dt AND ncc.ncc_stop_dt
                        --розмножемо для заявителя
                        UNION ALL
                */
                SELECT z_pd,
                       tc_pdf                                        /*z_pdf*/
                             ,
                       z_dt,
                       24
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               API$ACCOUNT.get_docx_dt (xpdf_pd,
                                                        xpdf_sc,
                                                        10205,
                                                        2688,
                                                        xpd_calc_dt)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON c_pd = xpd_id
                               JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                               JOIN tmp_calc_app_params
                                   ON tc_pd = c_pd AND tc_sc = xpdf_sc
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_pd_period_alg = 'DOC10205'
                               AND tc_tp = 'FP'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_calc_app_params ON tc_pd = z_pd -- Размножили точку разріва на всю семью
                 WHERE     z_dt BETWEEN c_start_dt AND c_stop_dt
                       AND z_dt BETWEEN tc_sc_start_dt AND tc_sc_stop_dt
                --WHERE tc_tp = 'Z'
                UNION ALL
                SELECT z_pd,
                       tc_pdf                                        /*z_pdf*/
                             ,
                       z_dt,
                       25
                  FROM (SELECT c_pd       AS z_pd,
                               xpdf_id    AS z_pdf,
                                 API$ACCOUNT.get_docx_dt (xpdf_pd,
                                                          xpdf_sc,
                                                          10205,
                                                          2689,
                                                          xpd_calc_dt)
                               + 1        AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON c_pd = xpd_id
                               JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                               JOIN tmp_calc_app_params
                                   ON tc_pd = c_pd AND tc_sc = xpdf_sc
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_pd_period_alg = 'DOC10205'
                               AND tc_tp = 'FP'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_calc_app_params ON tc_pd = z_pd -- Размножили точку разріва на всю семью
                 WHERE     z_dt BETWEEN c_start_dt AND c_stop_dt
                       AND z_dt BETWEEN tc_sc_start_dt AND tc_sc_stop_dt;
        --WHERE tc_tp = 'Z'
        END IF;

        IF is_have_nst_by_alg ('BREAK_PD_PERIOD_ALG', 'DOC10312') > 0
        THEN
            SaveMessage (
                'Розриви по початку та закунченню дії документу DOC10312');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       tc_pdf                                        /*z_pdf*/
                             ,
                       z_dt,
                       25
                  FROM (SELECT c_pd       AS z_pd,
                               xpdf_id    AS z_pdf,
                                 LAST_DAY (API$ACCOUNT.get_docx_dt (
                                               xpdf_pd,
                                               xpdf_sc,
                                               10312,
                                               8434,
                                               xpd_calc_dt))
                               + 1        AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON c_pd = xpd_id
                               JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                               JOIN tmp_calc_app_params
                                   ON tc_pd = c_pd AND tc_sc = xpdf_sc
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                         WHERE     ncc_pd_period_alg = 'DOC10312'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt
                               AND tc_start_dt IS NULL)
                       JOIN tmp_calc_app_params ON tc_pd = z_pd -- Размножили точку разріва на всю семью
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_PD_PERIOD_ALG', 'DOC10323') > 0
        THEN
            SaveMessage (
                'Розриви по початку та закунченню дії документу DOC10323');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT c_pd,
                       xpdf_id,
                       apda_val_dt,
                       23
                  FROM tmp_calc_pd
                       JOIN tmp_pd_calc_params ON xpd_id = c_pd
                       JOIN tmp_pdf_calc_params ON xpdf_pd = c_pd
                       JOIN tmp_calc_app_params
                           ON     tc_pd = c_pd
                              AND tc_sc = xpdf_sc
                              AND tc_start_dt IS NULL
                       JOIN uss_ndi.v_ndi_nst_calc_config ncc
                           ON xpd_nst = ncc_nst
                       JOIN tmp_pa_documents d
                           ON     d.tpd_pd = c_pd
                              AND d.tpd_sc = xpdf_sc
                              AND d.tpd_ndt IN (10323)
                       JOIN ap_document_attr atr
                           ON     apda_apd = tpd_apd
                              AND atr.history_status = 'A'
                              AND atr.apda_nda IN (8522)
                 WHERE     ncc_pd_period_alg = 'DOC10323'
                       AND tc_tp = 'Z'
                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                           AND ncc.ncc_stop_dt
                       AND apda_val_dt IS NOT NULL;
        END IF;

        IF is_have_nst_by_alg ('BREAK_1YEARS', 'T') > 0
        THEN
            SaveMessage ('Дати настання повних 1 рок утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       tc_pdf                                        /*z_pdf*/
                             ,
                       z_dt,
                       26
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               TOOLS.ADD_MONTHS_LEAP (xpdf_birth_dt, 12)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_1years = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_calc_app_params ON tc_pd = z_pd -- Размножили точку разріва на всю семью
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_60YEARS', 'T') > 0
        THEN
            SaveMessage ('Дати настання повних 1 рок утриманця - теж розрив');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       z_pdf,
                       z_dt,
                       26
                  FROM (SELECT c_pd
                                   AS z_pd,
                               xpdf_id
                                   AS z_pdf,
                               TOOLS.ADD_MONTHS_LEAP (xpdf_birth_dt, 12 * 60)
                                   AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND ncc_break_60years = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_STUDY', 'T') > 0
        THEN
            SaveMessage ('Розриви по закінченню навчання');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       tc_pdf,
                       z_dt,
                       30
                  FROM (SELECT c_pd                 AS z_pd,
                               xpdf_id              AS z_pdf, --Медичний висновок (для дітей інвалідів до 18 років) - встановлено на період по
                               --Api$account.get_docx_dt(xpdf_pd, xpdf_sc, 98, 688, xpd_calc_dt)+1 AS z_dt,
                               tc_study_stop_dt     AS z_dt, --Кінець періоду навчання
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_calc_app_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND tc_pd = c_pd
                               AND tc_sc = xpdf_sc
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND NCC_BREAK_STUDY = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_calc_app_params ON tc_pd = z_pd -- Размножили точку разріва на всю семью
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_INCOME', 'T') > 0
        THEN
            SaveMessage ('Розриви по зміні доходів');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       tc_pdf,
                       z_dt,
                       31
                  FROM (SELECT DISTINCT c_pd            AS z_pd,
                                        xpdf_id         AS z_pdf,
                                        --last_day(tpd_dt_from)+1 AS z_dt, --
                                        --tpd_dt_from + 1 AS z_dt,
                                        tpd_dt_from     AS z_dt,
                                        c_start_dt,
                                        c_stop_dt
                          FROM tmp_calc_pd
                               JOIN tmp_pd_calc_params ON c_pd = xpd_id
                               JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                               JOIN tmp_calc_app_params
                                   ON tc_pd = c_pd AND tc_sc = xpdf_sc
                               JOIN uss_ndi.v_ndi_nst_calc_config ncc
                                   ON xpd_nst = ncc_nst
                               JOIN tmp_pa_documents
                                   ON     tpd_pd = xpdf_pd
                                      AND tpd_sc = xpdf_sc
                                      AND tpd_ndt = 507
                         WHERE     NCC_BREAK_INCOME = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt
                               AND tc_start_dt IS NULL)
                       JOIN tmp_calc_app_params ON tc_pd = z_pd -- Размножили точку разріва на всю семью
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        IF is_have_nst_by_alg ('BREAK_CRTF_WR_PRT', 'T') > 0
        THEN
            SaveMessage ('Розриви по "Посвідчення учасника війни"');

            INSERT INTO tmp_tar_dates1 (ttd_pd,
                                        ttd_pdf,
                                        ttd_dt,
                                        ttd_source)
                SELECT z_pd,
                       tc_pdf,
                       z_dt,
                       34
                  FROM (SELECT c_pd       AS z_pd,
                               xpdf_id    AS z_pdf, --"Посвідчення учасника війни" - встановлено на період по
                                 Api$account.get_docx_dt (xpdf_pd,
                                                          xpdf_sc,
                                                          70,
                                                          4328,
                                                          xpd_calc_dt)
                               + 1        AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND NCC_BREAK_CRTF_WR_PRT = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt
                        UNION ALL
                        SELECT c_pd       AS z_pd,
                               xpdf_id    AS z_pdf, --"Посвідчення учасника бойових дій" - встановлено на період по
                                 Api$account.get_docx_dt (xpdf_pd,
                                                          xpdf_sc,
                                                          71,
                                                          4329,
                                                          xpd_calc_dt)
                               + 1        AS z_dt,
                               c_start_dt,
                               c_stop_dt
                          FROM tmp_calc_pd,
                               tmp_pdf_calc_params,
                               tmp_pd_calc_params,
                               uss_ndi.v_ndi_nst_calc_config  ncc
                         WHERE     xpdf_pd = c_pd
                               AND xpd_id = c_pd
                               AND xpd_nst = ncc_nst
                               AND NCC_BREAK_CRTF_WR_PRT = 'T'
                               AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                   AND ncc.ncc_stop_dt)
                       JOIN tmp_calc_app_params ON tc_pd = z_pd -- Размножили точку разріва на всю семью
                 WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;
        END IF;

        SaveMessage ('Отримуємо розриви за періодом дії утриманця');

        INSERT INTO tmp_tar_dates1 (ttd_pd,
                                    ttd_pdf,
                                    ttd_dt,
                                    ttd_source)
            SELECT z_pd,
                   tc_pdf,
                   z_dt,
                   32
              FROM (SELECT DISTINCT c_pd              AS z_pd,
                                    xpdf_id           AS z_pdf,
                                    xpdf_start_dt     AS z_dt,
                                    c_start_dt,
                                    c_stop_dt
                      FROM tmp_calc_pd
                           JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                           JOIN tmp_pd_calc_params
                               ON xpd_id = xpdf_pd AND xpd_nst IN (275, 901))
                   JOIN tmp_calc_app_params ON tc_pd = z_pd -- Размножили точку разріва на всю семью
             WHERE z_dt BETWEEN c_start_dt AND c_stop_dt
            UNION ALL
            SELECT z_pd,
                   tc_pdf,
                   z_dt,
                   33
              FROM (SELECT DISTINCT c_pd                 AS z_pd,
                                    xpdf_id              AS z_pdf,
                                    xpdf_stop_dt + 1     AS z_dt,
                                    c_start_dt,
                                    c_stop_dt
                      FROM tmp_calc_pd
                           JOIN tmp_pdf_calc_params ON c_pd = xpdf_pd
                           JOIN tmp_pd_calc_params
                               ON xpd_id = xpdf_pd AND xpd_nst IN (275, 901))
                   JOIN tmp_calc_app_params ON tc_pd = z_pd -- Размножили точку разріва на всю семью
             WHERE z_dt BETWEEN c_start_dt AND c_stop_dt;

        -- Не потрібно нічого за межами періоду розрахунку
        DELETE FROM tmp_tar_dates1 t
              WHERE NOT EXISTS
                        (SELECT 1
                           FROM tmp_calc_pd
                          WHERE     c_pd = t.ttd_pd
                                AND t.ttd_dt BETWEEN c_start_dt AND c_stop_dt);
    END;

    --=========================================================--
    PROCEDURE recalc_pdf_params
    IS
    BEGIN
        /**/
        FOR d IN (SELECT *
                    FROM tmp_calc_app_params t)
        LOOP
            dbms_output_put_lines (
                   '0  tc_sc='
                || d.tc_sc
                || '   tc_is_vpo      = '
                || d.tc_is_vpo
                || '   tc_is_vpo_home      = '
                || d.tc_is_vpo_home
                || ' tc_npt = '
                || d.tc_npt);
        END LOOP;

        dbms_output_put_lines ('');

        /**/
        UPDATE tmp_calc_app_params
           SET tc_is_have18_vpo =
                   CASE
                       WHEN tc_start_dt < ADD_MONTHS (tc_birth_dt, 216)
                       THEN
                           'F'
                       ELSE
                           'T'
                   END,
               tc_inv_start_dt =
                   (SELECT CASE
                               WHEN xpd_nst = 664
                               THEN
                                   COALESCE (
                                       API$ACCOUNT.get_docx_dt_not_less_ap (
                                           tc_pd,
                                           tc_sc,
                                           201,
                                           352,
                                           tc_calc_dt),
                                       API$ACCOUNT.get_docx_dt_not_less_ap (
                                           tc_pd,
                                           tc_sc,
                                           809,
                                           1939,
                                           tc_calc_dt),
                                       API$ACCOUNT.get_docx_dt_not_less_ap (
                                           tc_pd,
                                           tc_sc,
                                           200,
                                           792,
                                           tc_calc_dt),
                                       (SELECT tpd.tpd_dt_from
                                          FROM tmp_pa_documents tpd
                                         WHERE     tpd.tpd_pd = tc_pd
                                               AND tpd.tpd_sc = tc_sc
                                               AND tpd.tpd_ndt = 115))
                               WHEN xpd_nst = 248 AND xpd_src = 'RC'
                               THEN
                                   xpd_start_dt
                               ELSE
                                   COALESCE (
                                       API$ACCOUNT.get_docx_dt (
                                           tc_pd,
                                           tc_sc,
                                           201,
                                           352,
                                           tc_calc_dt),
                                       API$ACCOUNT.get_docx_dt (
                                           tc_pd,
                                           tc_sc,
                                           809,
                                           1939,
                                           tc_calc_dt),
                                       API$ACCOUNT.get_docx_dt (
                                           tc_pd,
                                           tc_sc,
                                           200,
                                           792,
                                           tc_calc_dt),
                                       (SELECT tpd.tpd_dt_from
                                          FROM tmp_pa_documents tpd
                                         WHERE     tpd.tpd_pd = tc_pd
                                               AND tpd.tpd_sc = tc_sc
                                               AND tpd.tpd_ndt = 115))
                           END
                      FROM tmp_pd_calc_params
                     WHERE xpd_id = tc_pd), --Дата встановлення інвалідності з медогляду МСЕК або мед.висновнку по дитині
               /*        tc_inv_start_dt = COALESCE( API$ACCOUNT.get_docx_dt(tc_pd, tc_sc, 201, 352, tc_calc_dt),
                                                     API$ACCOUNT.get_docx_dt(tc_pd, tc_sc, 809, 1939, tc_calc_dt),
                                                     API$ACCOUNT.get_docx_dt(tc_pd, tc_sc, 200, 792, tc_calc_dt),
                                                     (SELECT tpd.tpd_dt_from FROM tmp_pa_documents tpd WHERE tpd.tpd_pd = tc_pd AND tpd.tpd_sc = tc_sc AND tpd.tpd_ndt = 115)
                                                     ), --Дата встановлення інвалідності з медогляду МСЕК або мед.висновнку по дитині*/
               tc_inv_stop_dt =
                     (SELECT CASE
                                 WHEN xpd_nst = 664
                                 THEN
                                     COALESCE (
                                         ADD_MONTHS (API$ACCOUNT.get_docx_dt (
                                                         tc_pd,
                                                         tc_sc,
                                                         201,
                                                         347,
                                                         tc_calc_dt),
                                                     CASE API$ACCOUNT.get_docx_string (
                                                              tc_pd,
                                                              tc_sc,
                                                              201,
                                                              4188,
                                                              tc_calc_dt,
                                                              'F')
                                                         WHEN 'F' THEN 3
                                                         ELSE 100
                                                     END),
                                         ADD_MONTHS (API$ACCOUNT.get_docx_dt (
                                                         tc_pd,
                                                         tc_sc,
                                                         809,
                                                         1806,
                                                         tc_calc_dt),
                                                     CASE API$ACCOUNT.get_docx_string (
                                                              tc_pd,
                                                              tc_sc,
                                                              809,
                                                              4189,
                                                              tc_calc_dt,
                                                              'F')
                                                         WHEN 'F' THEN 3
                                                         ELSE 100
                                                     END),
                                         API$ACCOUNT.get_docx_dt (tc_pd,
                                                                  tc_sc,
                                                                  200,
                                                                  793,
                                                                  tc_calc_dt),
                                         (SELECT tpd.tpd_dt_to
                                            FROM tmp_pa_documents tpd
                                           WHERE     tpd.tpd_pd = tc_pd
                                                 AND tpd.tpd_sc = tc_sc
                                                 AND tpd.tpd_ndt = 115))
                                 ELSE
                                     COALESCE (
                                         API$ACCOUNT.get_docx_dt (
                                             tc_pd,
                                             tc_sc,
                                             201,
                                             347,
                                             tc_calc_dt),
                                         API$ACCOUNT.get_docx_dt (
                                             tc_pd,
                                             tc_sc,
                                             809,
                                             1806,
                                             tc_calc_dt),
                                         API$ACCOUNT.get_docx_dt (
                                             tc_pd,
                                             tc_sc,
                                             200,
                                             793,
                                             tc_calc_dt),
                                         (SELECT tpd.tpd_dt_to
                                            FROM tmp_pa_documents tpd
                                           WHERE     tpd.tpd_pd = tc_pd
                                                 AND tpd.tpd_sc = tc_sc
                                                 AND tpd.tpd_ndt = 115))
                             END
                        FROM tmp_pd_calc_params
                       WHERE xpd_id = tc_pd)
                   - 1, --Встановлено на період до з медогляду МСЕК або мед.висновнку по дитині
               tc_is_vpo =
                   (CASE
                        WHEN     0 <
                                 (SELECT COUNT (1)
                                    FROM TMP_KAOTS kh
                                   WHERE     tks_kaot_init = tc_bd_kaot_id
                                         AND tc_start_dt BETWEEN TRUNC (
                                                                     kh.tks_start_dt,
                                                                     'MM')
                                                             AND kh.tks_stop_dt)
                             AND API$ACCOUNT.get_docx_string (tc_pd,
                                                              tc_sc,
                                                              605,
                                                              4372,
                                                              tc_calc_dt,
                                                              'F') = 'F'
                        THEN
                            'A'
                        ELSE
                            'F'
                    END)                     --Перевіряємо, що довідка ВПО діє
         WHERE tc_start_dt IS NOT NULL;

        UPDATE tmp_calc_app_params
           SET tc_inv_stop_dt =
                   CASE
                       WHEN API$ACCOUNT.get_docx_count (tc_pd,
                                                        tc_sc,
                                                        10302,
                                                        tc_calc_dt) > 0
                       THEN
                           tc_inv_stop_dt + 1000000
                       WHEN API$ACCOUNT.get_docx_count (tc_pd,
                                                        tc_sc,
                                                        10303,
                                                        tc_calc_dt) > 0
                       THEN
                           tc_inv_stop_dt + 1000000
                       ELSE
                           tc_inv_stop_dt
                   END
         WHERE     tc_start_dt IS NOT NULL
               AND tc_inv_stop_dt IS NOT NULL
               AND EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE xpd_id = tc_pd AND xpd_nst = 275);

        FOR d IN (SELECT *
                    FROM tmp_calc_app_params t)
        LOOP
            dbms_output_put_lines (
                   '1  tc_sc='
                || d.tc_sc
                || '   tc_is_vpo      = '
                || d.tc_is_vpo
                || '   tc_is_vpo_home      = '
                || d.tc_is_vpo_home);
        END LOOP;

        dbms_output_put_lines ('');

        /*
            UPDATE tmp_calc_app_params t SET
              tc_is_vpo      = NULL,
              tc_is_vpo_home = NULL
            WHERE tc_start_dt IS NOT NULL
              AND tc_calc_dt >= to_date('01.08.2023', 'dd.mm.yyyy')
              AND EXISTS (SELECT 1
                            FROM pd_family  f_
                                 JOIN pc_decision d_ ON d_.pd_id = f_.pdf_pd
                                 JOIN appeal      a_ ON a_.ap_id = d_.pd_ap
                            WHERE d_.pd_nst = 664
                              AND d_.pd_st IN ('S', 'PS', 'P', 'R0', 'V')
                              AND a_.ap_reg_dt < trunc(tc_calc_dt, 'MM')--to_date('01.08.2023', 'dd.mm.yyyy')
                              AND f_.pdf_sc = t.tc_sc
                              --AND d_.pd_id != t.tc_pd
                              AND d_.pd_ap NOT IN (SELECT pd_ap FROM pc_decision pd WHERE pd.pd_id = t.tc_pd)
                              AND NOT EXISTS (SELECT 1
                                              FROM pd_accrual_period ac
                                              WHERE pdap_pd = d_.pd_id
                                                AND ac.history_status = 'A'
                                                AND trunc(tc_calc_dt, 'MM')-1--to_date('31.07.2023', 'dd.mm.yyyy')
                                                    BETWEEN ac.pdap_start_dt AND ac.pdap_stop_dt)
                              AND EXISTS (SELECT 1
                                          FROM pd_accrual_period ac
                                          WHERE pdap_pd = d_.pd_id
                                            AND ac.history_status = 'A')
                              AND ( API$ACCOUNT.get_docx_count( t.tc_pd, NULL, 10090, t.tc_calc_dt) = 0
                                    OR
                                    ( API$ACCOUNT.get_docx_string(t.tc_pd, NULL, 10090, 2100, t.tc_calc_dt, '-') IN ('D', 'UH')
                                      AND
                                      EXISTS ( SELECT 1
                                               FROM pd_accrual_period ac
                                               WHERE pdap_pd = d_.pd_id
                                                 AND ac.pdap_stop_dt > API$ACCOUNT.get_docx_dt(t.tc_pd, NULL, 10090, 5850, t.tc_calc_dt)
                                                 AND ac.history_status = 'A'
                                              )
                                    )
                                  )
                           )
                        AND NOT EXISTS (SELECT 1
                                        FROM pd_family  f_
                                             JOIN pc_decision d_ ON d_.pd_id = f_.pdf_pd
                                             JOIN appeal      a_ ON a_.ap_id = d_.pd_ap
                                        WHERE d_.pd_nst = 664
                                          AND d_.pd_id != tc_pd
                                          AND d_.pd_st IN ('S', 'PS')
                                          AND a_.ap_reg_dt < trunc(tc_calc_dt, 'MM')--to_date('01.08.2023', 'dd.mm.yyyy')
                                          AND f_.pdf_sc = tc_sc
                                          AND EXISTS (SELECT 1
                                                      FROM pd_accrual_period ac
                                                      WHERE pdap_pd = d_.pd_id
                                                        AND ac.history_status = 'A'
                                                        AND trunc(tc_calc_dt, 'MM')-1--to_date('31.07.2023', 'dd.mm.yyyy')
                                                            BETWEEN ac.pdap_start_dt AND ac.pdap_stop_dt)
                                    )
              AND (    NOT EXISTS ( SELECT *
                                    FROM tmp_kaots k
                                    WHERE k.tks_kaot = t.tc_bd_kaot_id
                                      AND k.tks_start_dt >= to_date('01.12.2023','dd.mm.yyyy')
                                      AND k.tks_stop_dt >= to_date('01.01.2099','dd.mm.yyyy')
                                   )
                  )
              ;
        */
        --    FOR d IN (SELECT * FROM tmp_calc_app_params t) LOOP
        --      dbms_output_put_lines('2  tc_sc='||d.tc_sc||'   tc_is_vpo = '||d.tc_is_vpo||'   tc_is_vpo_home = '||d.tc_is_vpo_home||'   tc_inv_state = '||d.tc_inv_state);
        --    END LOOP;
        --    dbms_output_put_lines('');

        --#99123
        --Якщо в учасника звернення зазначено "так" в атрибуті з Ід=8219, то допомогу такій особі не призначати
        --++++
        --#99128
        -- 1)Якщо користувач обрав в перевірці права серед трьох пунктів п.12-п.14 лише один п. 13. "Подовження згідно п. 13-2 та п.13-3 Порядку 332 ",
        --   і розмір доходу на одну особу є більшим за 9444 грн, то допомогу не призначати нікому з учасників звернення
        -- 2)Якщо користувач обрав в перевірці права п. 13. "Подовження згідно п. 13-2 та п.13-3 Порядку 332 ",
        --   і не розрахував середньомісячний дохід, то розмір допомоги не розраховувати
        UPDATE tmp_calc_app_params t
           SET tc_is_vpo = NULL, tc_is_vpo_home = NULL
         WHERE     (tc_is_vpo = 'A' OR tc_is_vpo_home != '-')
               AND (   API$ACCOUNT.get_docx_string (t.tc_pd,
                                                    t.tc_sc,
                                                    605,
                                                    8219,
                                                    t.tc_calc_dt,
                                                    'F') = 'T'
                    OR (    EXISTS
                                (SELECT 1
                                   FROM pd_right_log  prl
                                        JOIN uss_ndi.v_ndi_right_rule nrr
                                            ON nrr.nrr_id = prl_nrr
                                  WHERE     prl_pd = tc_pd
                                        AND prl_result = 'T'
                                        AND nrr.nrr_alg IN ('ALG64'))
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM pd_right_log  prl
                                        JOIN uss_ndi.v_ndi_right_rule nrr
                                            ON nrr.nrr_id = prl_nrr
                                  WHERE     prl_pd = tc_pd
                                        AND prl_result = 'T'
                                        AND nrr.nrr_alg IN ('ALG63', 'ALG65'))
                        AND (SELECT NVL (xpd.xpd_members_income, 0)
                               FROM tmp_pd_calc_params xpd
                              WHERE xpd.xpd_id = tc_pd) > 9444)
                    OR (    EXISTS
                                (SELECT 1
                                   FROM pd_right_log  prl
                                        JOIN uss_ndi.v_ndi_right_rule nrr
                                            ON nrr.nrr_id = prl_nrr
                                  WHERE     prl_pd = tc_pd
                                        AND prl_result = 'T'
                                        AND nrr.nrr_alg IN ('ALG64'))
                        AND (SELECT xpd.xpd_members_income
                               FROM tmp_pd_calc_params xpd
                              WHERE xpd.xpd_id = tc_pd)
                                IS NULL)
                    /**/
                    OR (    EXISTS
                                (SELECT 1
                                   FROM pd_right_log  prl
                                        JOIN uss_ndi.v_ndi_right_rule nrr
                                            ON nrr.nrr_id = prl_nrr
                                  WHERE     prl_pd = tc_pd
                                        AND prl_result = 'T'
                                        AND nrr.nrr_alg IN ('ALG65'))
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM pd_right_log  prl
                                        JOIN uss_ndi.v_ndi_right_rule nrr
                                            ON nrr.nrr_id = prl_nrr
                                  WHERE     prl_pd = tc_pd
                                        AND prl_result = 'T'
                                        AND nrr.nrr_alg IN ('ALG63', 'ALG64'))
                        AND (SELECT NVL (xpd.xpd_members_income, 0)
                               FROM tmp_pd_calc_params xpd
                              WHERE xpd.xpd_id = tc_pd) > 9444
                        AND API$ACCOUNT.get_docx_string (t.tc_pd,
                                                         t.tc_sc,
                                                         605,
                                                         8218,
                                                         t.tc_calc_dt,
                                                         'F') = 'T')
                    OR                                                --#99806
                       (    (SELECT COUNT (1)
                               FROM pd_right_log  prl
                                    JOIN uss_ndi.v_ndi_right_rule nrr
                                        ON nrr.nrr_id = prl_nrr
                              WHERE     prl_pd = tc_pd
                                    AND prl_result = 'T'
                                    AND nrr.nrr_alg IN ('ALG63', 'ALG64')) =
                            2
                        AND (SELECT NVL (xpd.xpd_members_income, 0)
                               FROM tmp_pd_calc_params xpd
                              WHERE xpd.xpd_id = tc_pd) >
                            (SELECT NVL (MAX (l.lgw_work_unable_sum * 4), 0)
                               FROM uss_ndi.v_ndi_living_wage l
                              WHERE     l.history_status = 'A'
                                    AND tc_start_dt BETWEEN l.lgw_start_dt
                                                        AND l.lgw_stop_dt)
                        AND NOT (   API$ACCOUNT.get_docx_count (t.tc_pd,
                                                                t.tc_sc,
                                                                669,
                                                                t.tc_calc_dt) >
                                    0
                                 OR (    tc_inv_state = 'DI'
                                     AND tc_inv_stop_dt >= t.tc_calc_dt)
                                 OR (    tc_inv_state IN ('I', 'IZ')
                                     AND t.tc_inv_group IN ('1', '2')
                                     AND tc_inv_stop_dt >
                                         TRUNC (t.tc_calc_dt, 'MM') - 1)))/**/
                                                                          );

        FOR d IN (SELECT *
                    FROM tmp_calc_app_params t)
        LOOP
            dbms_output_put_lines (
                   '3  tc_sc='
                || d.tc_sc
                || '   tc_is_vpo = '
                || d.tc_is_vpo
                || '   tc_is_vpo_home = '
                || d.tc_is_vpo_home
                || '   tc_inv_state = '
                || d.tc_inv_state);
        END LOOP;

        dbms_output_put_lines ('');

        /*
            --Дичина. Для перерахунку, коли різниця між довідками мсек мінше місяця, переносимо початок діїї довідки МСЕК
            UPDATE tmp_pa_documents SET
              (tpd_dt_from)  = ( SELECT  xpd_start_dt
                                 FROM tmp_calc_app_params
                                 JOIN tmp_pd_calc_params ON xpd_id = tc_pd AND xpd_nst = 248 AND xpd_src = 'RC'
                                 WHERE tpd_pd = tc_pd
                                   AND tpd_sc = tc_sc
                                   AND tpd_ndt IN (201)
                               )
            WHERE EXISTS ( SELECT 1
                           FROM tmp_calc_app_params
                           JOIN tmp_pd_calc_params ON xpd_id = tc_pd AND xpd_nst = 248 AND xpd_src = 'RC'
                           WHERE tpd_pd = tc_pd
                             AND tpd_sc = tc_sc
                         )
              AND tpd_ndt IN (201);
        */

        UPDATE tmp_calc_app_params
           SET tc_inv_state =
                   CASE
                       WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                         tc_sc,
                                                         201,
                                                         353,
                                                         tc_start_dt,
                                                         '-') = 'ID'
                       THEN
                           'IZ'
                       WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                         tc_sc,
                                                         201,
                                                         353,
                                                         tc_start_dt,
                                                         '-') <> '-'
                       THEN
                           'I'
                       WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                         tc_sc,
                                                         809,
                                                         1937,
                                                         tc_start_dt,
                                                         '-') <> '-'
                       THEN
                           'I'
                       WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                         tc_sc,
                                                         200,
                                                         797,
                                                         tc_start_dt,
                                                         '-') <> '-'
                       THEN
                           'DI'
                       WHEN API$ACCOUNT.get_docx_string (tc_pd,
                                                         tc_sc,
                                                         115,
                                                         2564,
                                                         tc_start_dt,
                                                         '-') <> '-'
                       THEN
                           'I'
                       ELSE
                           'N'
                   END,                           --стан інвалідності з анкети
               tc_inv_group =
                   COALESCE (API$ACCOUNT.get_docx_string (tc_pd,
                                                          tc_sc,
                                                          201,
                                                          349,
                                                          tc_start_dt),
                             API$ACCOUNT.get_docx_string (tc_pd,
                                                          tc_sc,
                                                          809,
                                                          1937,
                                                          tc_start_dt),
                             API$ACCOUNT.get_docx_string (tc_pd,
                                                          tc_sc,
                                                          115,
                                                          2564,
                                                          tc_start_dt),
                             '-'),      --група інвалідності з медогляду МСЕК,
               tc_inv_sgroup =
                   COALESCE (API$ACCOUNT.get_docx_string (tc_pd,
                                                          tc_sc,
                                                          201,
                                                          791,
                                                          tc_start_dt),
                             API$ACCOUNT.get_docx_string (tc_pd,
                                                          tc_sc,
                                                          809,
                                                          1938,
                                                          tc_start_dt),
                             '-'),    --підгрупа інвалідності з медогляду МСЕК
               tc_inv_reason =
                   API$ACCOUNT.get_docx_string (tc_pd,
                                                tc_sc,
                                                201,
                                                353,
                                                tc_start_dt,
                                                '-') --причина інвалідності з медогляду МСЕК
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE     xpd_id = tc_pd
                               AND xpd_nst = 248
                               AND xpd_src = 'RC')
               AND tc_start_dt IS NOT NULL;



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
                                                             '-') IN
                                    ('1', '2', '3')
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
                                                'F') = 'T'
                                        AND API$ACCOUNT.get_docx_count (
                                                tc_pd,
                                                tc_sc,
                                                201,
                                                tc_calc_dt) = 0
                                        AND API$ACCOUNT.get_docx_count (
                                                tc_pd,
                                                tc_sc,
                                                809,
                                                tc_calc_dt) = 0)
                       THEN
                           'T'
                       WHEN     NVL (API$ACCOUNT.get_docx_dt (tc_pd,
                                                              tc_sc,
                                                              115,
                                                              2565,
                                                              tc_calc_dt),
                                     SYSDATE) >
                                TO_DATE ('23.02.2022', 'dd.mm.yyyy')
                            AND API$ACCOUNT.get_docx_count (tc_pd,
                                                            tc_sc,
                                                            115,
                                                            tc_calc_dt) = 1
                            AND TRUNC (tc_start_dt, 'mm') >=
                                TRUNC (tc_inv_start_dt, 'mm')
                       THEN
                           'T'
                       --#86485 2023.04.20
                       WHEN     NVL (API$ACCOUNT.get_docx_dt (tc_pd,
                                                              tc_sc,
                                                              201,
                                                              352,
                                                              tc_calc_dt),
                                     SYSDATE) <=
                                TO_DATE ('24.02.2022', 'dd.mm.yyyy')
                            AND API$ACCOUNT.get_docx_count (tc_pd,
                                                            tc_sc,
                                                            201,
                                                            tc_calc_dt) = 1
                            AND TRUNC (tc_start_dt, 'mm') >=
                                TRUNC (tc_inv_start_dt, 'mm')
                            AND tc_calc_dt <
                                TO_DATE ('01.08.2023', 'dd.mm.yyyy')
                       THEN
                           'T'
                       WHEN     NVL (API$ACCOUNT.get_docx_dt (tc_pd,
                                                              tc_sc,
                                                              809,
                                                              1939,
                                                              tc_calc_dt),
                                     SYSDATE) <=
                                TO_DATE ('24.02.2022', 'dd.mm.yyyy')
                            AND API$ACCOUNT.get_docx_count (tc_pd,
                                                            tc_sc,
                                                            809,
                                                            tc_calc_dt) = 1
                            AND TRUNC (tc_start_dt, 'mm') >=
                                TRUNC (tc_inv_start_dt, 'mm')
                            AND tc_calc_dt <
                                TO_DATE ('01.08.2023', 'dd.mm.yyyy')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE 1 = 1;

        /*
              nst_id = 275
                835 --515
                836 --516
                837 --517
              nst_id = 901
                840 --524
                839 --523
        */
        UPDATE tmp_calc_app_params p
           SET p.tc_child_number =
                   (SELECT SUM (1)
                      FROM tmp_calc_app_params pp
                     WHERE     pp.tc_pd = p.tc_pd
                           AND pp.tc_npt IN (837)
                           AND pp.tc_start_dt IS NULL
                           --AND p.tc_start_dt BETWEEN pp.tc_birth_dt AND add_months(pp.tc_birth_dt, 216) - 1
                           --AND p.tc_start_dt BETWEEN pp.tc_sc_start_dt AND pp.tc_sc_stop_dt
                           AND p.tc_start_dt >= pp.tc_sc_start_dt
                           AND p.tc_start_dt < pp.tc_sc_stop_dt
                           AND p.tc_start_dt <=
                               (CASE
                                    --#101786
                                    WHEN     pp.tc_study_stop_dt IS NOT NULL
                                         AND pp.tc_study_stop_dt >
                                             ADD_MONTHS (pp.tc_birth_dt,
                                                         12 * 23)
                                    THEN
                                        ADD_MONTHS (pp.tc_birth_dt, 12 * 23)
                                    WHEN     pp.tc_study_stop_dt IS NOT NULL
                                         AND pp.tc_study_stop_dt >
                                             ADD_MONTHS (pp.tc_birth_dt,
                                                         12 * 18)
                                    THEN
                                        pp.tc_study_stop_dt
                                    WHEN    pp.tc_inv_stop_dt IS NULL
                                         OR pp.tc_inv_stop_dt <
                                            ADD_MONTHS (pp.tc_birth_dt, 216)
                                    THEN
                                        ADD_MONTHS (pp.tc_birth_dt, 216) - 1
                                    ELSE
                                        LEAST (
                                            pp.tc_inv_stop_dt,
                                            ADD_MONTHS (pp.tc_birth_dt,
                                                        12 * 23))
                                END)--AND p.tc_start_dt BETWEEN pp.tc_sc_start_dt AND add_months(pp.tc_birth_dt, 216) - 1
                                    )
         WHERE p.tc_npt IN (835, 836) AND p.tc_start_dt IS NOT NULL;


        UPDATE tmp_calc_app_params p
           SET (p.tc_child_cnt, p.tc_child_cnt_plus10) =
                   (SELECT SUM (
                               CASE
                                   WHEN p.tc_start_dt >=
                                        ADD_MONTHS (pp.tc_birth_dt, 216)
                                   THEN
                                       0
                                   ELSE
                                       1
                               END)    AS child_cnt,
                           SUM (
                               CASE
                                   WHEN p.tc_start_dt >=
                                        ADD_MONTHS (pp.tc_birth_dt, 216)
                                   THEN
                                       0
                                   WHEN p.tc_start_dt BETWEEN pp.tc_birth_dt
                                                          AND   ADD_MONTHS (
                                                                    pp.tc_birth_dt,
                                                                    12)
                                                              - 1
                                   THEN
                                       1
                                   WHEN pp.tc_inv_state = 'DI'
                                   THEN
                                       1
                                   WHEN pp.tc_underage_pregnant = 'T'
                                   THEN
                                       1
                                   WHEN pp.tc_child_vil = 'T'
                                   THEN
                                       1
                                   ELSE
                                       0
                               END)    AS child_is_10
                      FROM tmp_calc_app_params pp
                     WHERE     pp.tc_pd = p.tc_pd
                           --AND pp.tc_npt IN ( 839 ) -- #97825
                           AND pp.tc_npt IN (840)
                           AND pp.tc_start_dt IS NULL
                           AND p.tc_start_dt BETWEEN pp.tc_sc_start_dt
                                                 AND pp.tc_sc_stop_dt
                           AND pp.tc_start_dt IS NULL)
         --WHERE p.tc_npt IN ( 840)  -- #97825
         WHERE p.tc_npt IN (839) AND p.tc_start_dt IS NOT NULL;

        UPDATE tmp_calc_app_params p
           SET p.tc_subtp =
                   api$account.get_docx_string (tc_pd,
                                                tc_sc,
                                                10323,
                                                9014,
                                                tc_calc_dt)
         WHERE p.tc_npt IN (854)                                    -- #115801
                                 AND p.tc_start_dt IS NOT NULL;

        /*
              UPDATE tmp_calc_app_params p SET
                p.tc_child_number = ( SELECT rn
                                      FROM ( SELECT tc.tc_sc,
                                                    ROW_NUMBER() OVER (PARTITION BY tc.tc_pd, tc.tc_tp, tc.tc_start_dt ORDER BY tc_birth_dt) AS rn
                                             FROM tmp_calc_app_params tc
                                             WHERE tc.tc_pd = p.tc_pd
                                               AND tc.tc_tp = p.tc_tp
                                               AND p.tc_start_dt BETWEEN tc.tc_birth_dt AND add_months(tc.tc_birth_dt, 12*18)-1
                                               AND tc.tc_start_dt = p.tc_start_dt
                                           )  pp
                                      WHERE pp.tc_sc = p.tc_sc
                                    )
              WHERE p.tc_tp = 'FP'
                AND p.tc_npt IS NULL
                AND p.tc_start_dt IS NOT NULL
                AND EXISTS (SELECT 1 FROM tmp_pd_calc_params  WHERE xpd_id = tc_pd AND xpd_nst = 862 );
        */
        /*
              UPDATE tmp_calc_app_params p SET
                p.tc_child_number = ( SELECT CASE x_birth_cnt
                                                 WHEN 1 THEN rn
                                                 ELSE x_birth_cnt + x_prev_cnt
                                               END AS rn
                                      FROM ( SELECT tc.tc_sc,
                                                    ROW_NUMBER() OVER (PARTITION BY tc.tc_pd, tc.tc_tp, tc.tc_start_dt ORDER BY tc_birth_dt) AS rn,
                                                    (SELECT COUNT(1)
                                                     FROM tmp_calc_app_params tt
                                                     WHERE tt.tc_pd = tc.tc_pd
                                                       AND tt.tc_tp = tc.tc_tp
                                                       AND tt.tc_birth_dt BETWEEN  tc.tc_birth_dt-2 AND tc.tc_birth_dt+2
                                                       AND tt.tc_start_dt = tc.tc_start_dt
                                                    ) AS x_birth_cnt,
                                                    (SELECT COUNT(1)
                                                     FROM tmp_calc_app_params tt
                                                     WHERE tt.tc_pd = tc.tc_pd
                                                       AND tt.tc_tp = tc.tc_tp
                                                       AND tt.tc_birth_dt < tc.tc_birth_dt - 2
                                                       AND tt.tc_start_dt = tc.tc_start_dt
                                                       -- #106239
                                                       AND ( p.tc_start_dt BETWEEN tt.tc_birth_dt AND add_months(tt.tc_birth_dt, 12*18)-1
                                                             OR
                                                             (     p.tc_start_dt BETWEEN tt.tc_birth_dt AND add_months(tt.tc_birth_dt, 12*23)-1
                                                               AND p.tc_start_dt BETWEEN tt.TC_STUDY_START_DT AND tt.TC_STUDY_STOP_DT
                                                               AND Api$account.get_docx_string(tt.tc_pd, tt.tc_sc, 98, 690,  p.tc_calc_dt ) IN ('D')
                                                             )
                                                           )
                                                       --
                                                    ) AS x_prev_cnt
                                             FROM tmp_calc_app_params tc
                                             WHERE tc.tc_pd = p.tc_pd
                                               AND tc.tc_tp = p.tc_tp
                                               AND ( p.tc_start_dt BETWEEN tc.tc_birth_dt AND add_months(tc.tc_birth_dt, 12*18)-1
                                                     OR
                                                     (     p.tc_start_dt BETWEEN tc.tc_birth_dt AND add_months(tc.tc_birth_dt, 12*23)-1
                                                       AND p.tc_start_dt BETWEEN TC_STUDY_START_DT AND TC_STUDY_STOP_DT
                                                       AND Api$account.get_docx_string(tc_pd, tc_sc, 98, 690, p.tc_calc_dt) IN ('D')
                                                     )
                                                   )
                                               AND tc.tc_start_dt = p.tc_start_dt
                                           )  pp
                                      WHERE pp.tc_sc = p.tc_sc
                                    )
              WHERE p.tc_tp = 'FP'
                AND p.tc_npt IS NULL
                AND p.tc_start_dt IS NOT NULL
                AND EXISTS (SELECT 1 FROM tmp_pd_calc_params  WHERE xpd_id = tc_pd AND xpd_nst = 862 );
        */
        UPDATE tmp_calc_app_params p
           SET p.tc_child_number =
                   (SELECT CASE x_birth_cnt
                               WHEN 1 THEN rn
                               ELSE x_birth_cnt + x_prev_cnt
                           END    AS rn
                      FROM (SELECT tc.tc_sc,
                                   ROW_NUMBER ()
                                       OVER (
                                           PARTITION BY tc.tc_pd,
                                                        tc.tc_tp,
                                                        tc.tc_start_dt
                                           ORDER BY tc_birth_dt)
                                       AS rn,
                                   (SELECT COUNT (1)
                                      FROM tmp_calc_app_params tt
                                     WHERE     tt.tc_pd = tc.tc_pd
                                           AND tt.tc_tp = tc.tc_tp
                                           AND tt.tc_birth_dt BETWEEN   tc.tc_birth_dt
                                                                      - 2
                                                                  AND   tc.tc_birth_dt
                                                                      + 2
                                           AND tt.tc_start_dt =
                                               tc.tc_start_dt)
                                       AS x_birth_cnt,
                                   (SELECT COUNT (1)
                                      FROM tmp_calc_app_params tt
                                     WHERE     tt.tc_pd = tc.tc_pd
                                           AND tt.tc_tp = tc.tc_tp
                                           AND tt.tc_birth_dt <
                                               tc.tc_birth_dt - 2
                                           AND tt.tc_start_dt =
                                               tc.tc_start_dt
                                           -- #107323
                                           AND p.tc_start_dt BETWEEN tt.tc_birth_dt
                                                                 AND   ADD_MONTHS (
                                                                           tt.tc_birth_dt,
                                                                             12
                                                                           * 23)
                                                                     - 1)
                                       AS x_prev_cnt
                              FROM tmp_calc_app_params tc
                             WHERE     tc.tc_pd = p.tc_pd
                                   AND tc.tc_tp = p.tc_tp
                                   -- #107323
                                   AND p.tc_start_dt BETWEEN tc.tc_birth_dt
                                                         AND   ADD_MONTHS (
                                                                   tc.tc_birth_dt,
                                                                   12 * 23)
                                                             - 1
                                   AND tc.tc_start_dt = p.tc_start_dt) pp
                     WHERE pp.tc_sc = p.tc_sc)
         WHERE     p.tc_tp = 'FP'
               AND p.tc_npt IS NULL
               AND p.tc_start_dt IS NOT NULL
               AND EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE xpd_id = tc_pd AND xpd_nst = 862);

        UPDATE tmp_calc_app_params p
           SET p.tc_child_number =
                   (SELECT CASE x_birth_cnt
                               WHEN 1 THEN rn
                               ELSE x_birth_cnt + x_prev_cnt
                           END    AS rn
                      FROM (SELECT tc.tc_sc,
                                   ROW_NUMBER ()
                                       OVER (
                                           PARTITION BY tc.tc_pd,
                                                        tc.tc_tp,
                                                        tc.tc_start_dt
                                           ORDER BY tc_birth_dt)
                                       AS rn,
                                   (SELECT COUNT (1)
                                      FROM tmp_calc_app_params tt
                                     WHERE     tt.tc_pd = tc.tc_pd
                                           AND tt.tc_tp = tc.tc_tp
                                           AND tt.tc_birth_dt BETWEEN   tc.tc_birth_dt
                                                                      - 2
                                                                  AND   tc.tc_birth_dt
                                                                      + 2
                                           AND tt.tc_start_dt =
                                               tc.tc_start_dt)
                                       AS x_birth_cnt,
                                   (SELECT COUNT (1)
                                      FROM tmp_calc_app_params tt
                                     WHERE     tt.tc_pd = tc.tc_pd
                                           AND tt.tc_tp = tc.tc_tp
                                           AND tt.tc_birth_dt <
                                               tc.tc_birth_dt - 2
                                           AND tt.tc_start_dt =
                                               tc.tc_start_dt)
                                       AS x_prev_cnt
                              FROM tmp_calc_app_params tc
                             WHERE     tc.tc_pd = p.tc_pd
                                   AND tc.tc_tp = p.tc_tp
                                   AND tc.tc_sc = p.tc_sc
                                   AND tc.tc_start_dt = p.tc_start_dt) pp--WHERE pp.tc_sc = p.tc_sc
                                                                         )
         WHERE     p.tc_tp = 'FP'
               AND p.tc_npt IS NULL
               AND p.tc_start_dt IS NOT NULL
               AND NOT EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE xpd_id = tc_pd AND xpd_nst = 862);



        UPDATE tmp_calc_app_params p
           SET tc_income =
                   api$calc_pd.Get_apri_income (tc_pd,
                                                tc_sc,
                                                '1,4,5,28',
                                                p.tc_start_dt,
                                                p.tc_start_dt) --1 пенсії, --5 аліментів, --6 допомоги, --4, 28 стипендії
         WHERE p.tc_npt IN (837) AND p.tc_start_dt IS NOT NULL;



        UPDATE tmp_calc_app_params p
           SET tc_inv_rc_alg = '-'
         WHERE    (    tc_inv_rc_alg = '1'
                   AND p.tc_start_dt >=
                       TRUNC (ADD_MONTHS (tc_inv_start_dt, 1), 'MM'))
               OR (    tc_inv_rc_alg = '2'
                   AND p.tc_start_dt >=
                       TRUNC (ADD_MONTHS (tc_inv_start_dt, 1), 'MM'))
               OR (    tc_inv_rc_alg = '3'
                   AND p.tc_start_dt >=
                       TRUNC (ADD_MONTHS (tc_inv_start_dt, 1), 'MM'));
    END;

    --=========================================================--
    PROCEDURE collect_features
    IS
    BEGIN
        --92
        DELETE FROM pd_features
              WHERE     pde_nft = 92
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_in_calc_pd t
                              WHERE pde_pd = t.ic_pd);


        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_nft,
                                 pde_val_string,
                                 pde_pdf)
            SELECT DISTINCT
                   0
                       AS x_pde_id,
                   t.tc_pd
                       AS x_pd_id,
                   92
                       AS x_nft_id,
                   'T'
                       AS x_val,
                   (SELECT pdf_id
                      FROM pd_family
                     WHERE     pdf_sc = t.tc_sc
                           AND pdf_pd = t.tc_pd
                           AND pd_family.history_status = 'A')
              FROM tmp_calc_app_params t
             WHERE t.tc_is_vpo_evac = 'T' AND t.tc_start_dt IS NULL;

        --37 Знаходиться в закладі держутримання
        DELETE FROM pd_features
              WHERE     pde_nft = 37
                    AND EXISTS
                            (SELECT pd_id
                               FROM pc_decision
                                    JOIN tmp_work_ids ON pd_ap = x_id
                              WHERE pde_pd = pd_id);

        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_nft,
                                 pde_val_string,
                                 pde_pdf)
            SELECT DISTINCT
                   0
                       AS x_pde_id,
                   pd.pd_id
                       AS x_pd_id,
                   nft_id
                       AS x_nft_id,
                   'T'
                       AS x_val,
                   (SELECT pdf_id
                      FROM pd_family
                     WHERE     pdf_sc = tpp_sc
                           AND pdf_pd = pd_id
                           AND pd_family.history_status = 'A')
              FROM tmp_work_ids
                   JOIN pc_decision pd ON pd_ap = x_id
                   JOIN tmp_pa_persons app
                       ON     app.tpp_pd = pd.pd_id
                          AND app.tpp_app_tp IN ('Z', 'FP')
                   JOIN uss_ndi.v_ndi_pd_feature_type nft
                       ON nft.nft_id IN (37)
             WHERE    Api$account.get_docx_string (app.tpp_pd,
                                                   app.tpp_sc,
                                                   98,
                                                   856,
                                                   pd_stop_dt,
                                                   'F') = 'T'
                   OR Api$account.get_docx_dt (app.tpp_pd,
                                               app.tpp_sc,
                                               10034,
                                               923,
                                               pd_stop_dt)
                          IS NOT NULL;


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
                      FROM pd_family f
                     WHERE     pdf_sc = tpp_sc
                           AND pdf_pd = pd_id
                           AND f.history_status = 'A')
              FROM (SELECT pd_id,
                           app.tpp_sc,
                           nft_id,
                           (SELECT MIN (
                                       Api$account.get_docx_dt (app.tpp_pd,
                                                                app.tpp_sc,
                                                                10034,
                                                                923,
                                                                pd_start_dt))
                              FROM ap_person p
                             WHERE     p.app_ap = ps_ap
                                   AND p.history_status = 'A')
                               AS nft_2,                    --Дата зарахування
                           COALESCE (Api$account.get_docx_dt (app.tpp_pd,
                                                              app.tpp_sc,
                                                              200,
                                                              792,
                                                              pd_stop_dt),
                                     Api$account.get_docx_dt (app.tpp_pd,
                                                              app.tpp_sc,
                                                              201,
                                                              352,
                                                              pd_stop_dt),
                                     Api$account.get_docx_dt (app.tpp_pd,
                                                              app.tpp_sc,
                                                              809,
                                                              1939,
                                                              pd_stop_dt))
                               AS nft_7, --  Дата встановлення інвалідності з медогляду МСЕК або мед.висновнку по дитині
                           COALESCE (Api$account.get_docx_dt (app.tpp_pd,
                                                              app.tpp_sc,
                                                              200,
                                                              793,
                                                              pd_stop_dt),
                                     Api$account.get_docx_dt (app.tpp_pd,
                                                              app.tpp_sc,
                                                              201,
                                                              347,
                                                              pd_stop_dt),
                                     Api$account.get_docx_dt (app.tpp_pd,
                                                              app.tpp_sc,
                                                              809,
                                                              1806,
                                                              pd_stop_dt))
                               AS nft_8,          --  встановлено на період по
                           uss_person.api$sc_tools.get_pib (app.tpp_sc)
                               AS nft_1,
                           COALESCE (
                               Api$account.get_docx_string (app.tpp_pd,
                                                            app.tpp_sc,
                                                            201,
                                                            349,
                                                            pd_stop_dt),
                               Api$account.get_docx_string (app.tpp_pd,
                                                            app.tpp_sc,
                                                            809,
                                                            1937,
                                                            pd_stop_dt))
                               AS nft_3,                  --група інвалідності
                           COALESCE (
                               Api$account.get_docx_string (app.tpp_pd,
                                                            app.tpp_sc,
                                                            201,
                                                            791,
                                                            pd_stop_dt),
                               Api$account.get_docx_string (app.tpp_pd,
                                                            app.tpp_sc,
                                                            809,
                                                            1938,
                                                            pd_stop_dt))
                               AS nft_4,               --підгрупа інвалідності
                           Api$account.get_docx_string (app.tpp_pd,
                                                        app.tpp_sc,
                                                        201,
                                                        353,
                                                        pd_stop_dt)
                               AS nft_5,                --причина інвалідності
                           Api$account.get_docx_string (app.tpp_pd,
                                                        app.tpp_sc,
                                                        200,
                                                        797,
                                                        pd_stop_dt)
                               AS nft_6                            --категорія
                      FROM tmp_work_ids,
                           pc_decision,
                           tmp_pa_persons    app,
                           pc_state_alimony  psa,
                           uss_ndi.v_ndi_pd_feature_type
                     WHERE     pd_nst = 248
                           AND nft_id BETWEEN 1 AND 8
                           AND x_id = pd_id
                           AND pd_id = app.tpp_pd
                           AND psa.ps_id(+) = pd_ps
                           AND EXISTS
                                   (SELECT 1
                                      FROM tmp_pa_documents
                                     WHERE     tpd_pd = app.tpp_pd
                                           AND tpd_sc = app.tpp_sc
                                           AND tpd_ndt IN (200,
                                                           201,
                                                           809,
                                                           10034)));
    END;

    --=========================================================--
    PROCEDURE Recalc_pd_accrual_period
    IS
    BEGIN
        FOR rec
            IN (SELECT pd_id, cp.xpd_start_dt
                  FROM pc_decision  pd
                       JOIN tmp_pd_calc_params cp ON cp.xpd_id = pd_id
                       JOIN uss_ndi.v_ndi_nst_calc_config t
                           ON     t.ncc_nst = cp.xpd_nst
                              AND cp.xpd_calc_dt BETWEEN t.ncc_start_dt
                                                     AND t.ncc_stop_dt
                 WHERE pd_st = 'S' AND t.ncc_calc_period = '18YEARS.U')
        LOOP
            api$pc_decision.recalc_pd_periods_PV (rec.pd_id,
                                                  rec.xpd_start_dt,
                                                  G_hs);
        END LOOP;
    END;

    --=========================================================--
    -- #75610 20220214
    --Розраховуємо суму допомоги як суму прожиткового мінімуму на дату розриву
    PROCEDURE COMPUTE_BY_SIMPLE_LGW
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
                      'Призначено допомогу по догляду за хворою дитиною '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' (вік '
                   || TRUNC (MONTHS_BETWEEN (tc_start_dt, tc_birth_dt) / 12,
                             0)
                   || ')'                                                /* ||
' у розмірі прожиткового мінімуму для осіб, що втратили працездатність'*/
                         ,
                   lgw_work_unable_sum,
                   37
              FROM tmp_tar_dates,
                   uss_ndi.v_ndi_living_wage  lw,
                   tmp_pd_calc_params,
                   tmp_calc_app_params
             WHERE     td_begin = tc_start_dt
                   AND td_pdf = tc_pdf
                   AND td_pd = tc_pd
                   AND lw.history_status = 'A'
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
                      'Призначено допомогу по догляду за хворою дитиною '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' (вік '
                   || TRUNC (MONTHS_BETWEEN (tc_start_dt, tc_birth_dt) / 12,
                             0)
                   || ')'                                                 /*||
' у розмірі прожиткового мінімуму'*/
                         ,
                   CASE
                       WHEN tc_start_dt BETWEEN tc_birth_dt
                                            AND   ADD_MONTHS (tc_birth_dt,
                                                              72)
                                                - 1
                       THEN
                           lgw_6year_sum * 2
                       WHEN tc_start_dt BETWEEN ADD_MONTHS (tc_birth_dt, 72)
                                            AND   ADD_MONTHS (tc_birth_dt,
                                                              216)
                                                - 1
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
                   AND td_begin < tc_child_sick_stop_dt                     --
                   AND history_status = 'A'
                   AND td_pd = xpd_id
                   AND xpd_ap_reg_dt >= TO_DATE ('01.01.2022', 'dd.mm.yyyy')
                   --      AND xpd_ap_reg_dt >= to_date('10.12.2021', 'dd.mm.yyyy')
                   AND tc_is_child_sick = 'T'
                   AND td_begin < ADD_MONTHS (tc_birth_dt, 216)
                   AND xpd_calc_alg = 'SIMPLE_LGW';

        SaveMessage (
            'Розраховуємо Підвищення за проживання в гірському населеному пункті');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt,
                                        tdc_sub_npt)
            SELECT 294,
                   294,
                   tdc_key,
                   tdc_pd,
                   tdc_start_dt,
                   tdc_stop_dt,
                      CHR (38)
                   || '152#'
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                       AS x_row_name,
                   tdc_value * 0.2
                       AS x_val,
                   37
                       AS x_npt,
                   844
                       AS x_sub_npt
              FROM tmp_pd_detail_calc
                   JOIN tmp_calc_app_params tc
                       ON     NVL (tc_pdf, 0) = NVL (tdc_key, 0)
                          AND tc_pd = tdc_pd
                          AND tc_start_dt = tdc_start_dt
             WHERE tdc_ndp = 300 AND tc.tc_mountain_village = 'T';
    END;

    --=========================================================--
    PROCEDURE COMPUTE_BY_DIFF_INCOME_LGW
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
                   /*
                              CASE WHEN (SELECT COUNT(*)
                                         FROM tmp_pa_documents, --ap_document,
                                              ap_document_attr
                                         WHERE tpd_pd = xpdf_pd    --apd_app = xpdf_app
                                           AND tpd_sc = xpdf_sc
                                           AND apda_apd = tpd_apd--apd_id
                                           --AND ap_document.history_status = 'A'
                                           AND tpd_ndt = 98 --Довідки про денну форму навч. (п. 2, част. 2, ст. 36 ЗУ №1058)
                                           AND apda_nda = 690 --Форма навчання (денна, дуальна, заочна)
                                           AND apda_val_string IN ('T', 'D', 'U') --Так, Денна, Дуальна
                                        ) > 0
                                   THEN 1
                                ELSE 0
                              END
                   */
                   CASE
                       WHEN     Api$account.get_docx_string (xpdf_pd,
                                                             xpdf_sc,
                                                             98,
                                                             690,
                                                             xpd_calc_dt) IN
                                    ('T', 'D', 'U')      --Так, Денна, Дуальна
                            AND Api$account.get_docx_dt (xpdf_pd,
                                                         xpdf_sc,
                                                         98,
                                                         688,
                                                         xpd_calc_dt) >
                                td_begin
                       THEN
                           1
                       ELSE
                           0
                   END    AS is_study
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

        /*
                           Api$account.get_docx_dt(xpdf_pd, xpdf_sc, 98, 688, xpd_calc_dt) AS z_dt, c_start_dt, c_stop_dt
                    FROM tmp_calc_pd, tmp_pdf_calc_params, tmp_pd_calc_params, uss_ndi.v_ndi_nst_calc_config
                    WHERE xpdf_pd = c_pd
        */

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
                   || TO_CHAR (xpdf_birth_dt, 'DD.MM.YYYY')    AS txt,
                   CASE
                       WHEN td_begin < xpd_calc_dt
                       THEN
                           CASE
                               WHEN     xpd_calc_dt BETWEEN xpdf_birth_dt
                                                        AND (  ADD_MONTHS (
                                                                   xpdf_birth_dt,
                                                                   72)
                                                             - 1)
                                    AND lgw_6year_sum >
                                        pic_member_month_income --для до6річних
                               THEN
                                   lgw_6year_sum - pic_member_month_income
                               WHEN     xpd_calc_dt BETWEEN ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                72)
                                                        AND (  ADD_MONTHS (
                                                                   xpdf_birth_dt,
                                                                   216)
                                                             - 1)
                                    AND lgw_18year_sum >
                                        pic_member_month_income --для до 18річних
                               THEN
                                   lgw_18year_sum - pic_member_month_income --для до18річних - різниця між прож.мін та доходом сім'ї
                               WHEN     xpd_calc_dt BETWEEN ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                216)
                                                        AND LAST_DAY (
                                                                  ADD_MONTHS (
                                                                      xpdf_birth_dt,
                                                                      216)
                                                                - 1)
                                    AND lgw_18year_sum >
                                        pic_member_month_income --для до 18річних до кінця місяця
                               --AND 0 = NVL((SELECT tdc_value FROM tmp_pd_detail_calc WHERE tdc_pd = td_pd AND tdc_key = td_pdf AND tdc_start_dt = td_begin AND tdc_ndp = 100), 0) --для учбовців на денній/дуальній формі
                               THEN
                                   lgw_18year_sum - pic_member_month_income --для 18річних до кінця місяця
                               WHEN     xpd_calc_dt BETWEEN ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                216)
                                                        AND LAST_DAY (
                                                                  ADD_MONTHS (
                                                                      xpdf_birth_dt,
                                                                      216)
                                                                - 1)
                                    AND lgw_work_able_sum >
                                        pic_member_month_income --для до23річних
                                    AND 1 =
                                        NVL (
                                            (SELECT tdc_value
                                               FROM tmp_pd_detail_calc
                                              WHERE     tdc_pd = td_pd
                                                    AND tdc_key = td_pdf
                                                    AND tdc_start_dt =
                                                        td_begin
                                                    AND tdc_ndp = 100),
                                            0) --для учбовців на денній/дуальній формі
                               THEN
                                     lgw_work_able_sum
                                   - pic_member_month_income --для 18річних до кінця місяця
                               WHEN     xpd_calc_dt BETWEEN ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                216)
                                                        AND (  ADD_MONTHS (
                                                                   xpdf_birth_dt,
                                                                   276)
                                                             - 1)
                                    AND lgw_work_able_sum >
                                        pic_member_month_income --для до23річних
                                    AND 1 =
                                        NVL (
                                            (SELECT tdc_value
                                               FROM tmp_pd_detail_calc
                                              WHERE     tdc_pd = td_pd
                                                    AND tdc_key = td_pdf
                                                    AND tdc_start_dt =
                                                        td_begin
                                                    AND tdc_ndp = 100),
                                            0) --для учбовців на денній/дуальній формі
                                    AND 0 =
                                        NVL (
                                            (SELECT tdc_value
                                               FROM tmp_pd_detail_calc
                                              WHERE     tdc_pd = td_pd
                                                    AND tdc_key = td_pdf
                                                    AND tdc_start_dt =
                                                        td_begin
                                                    AND tdc_ndp = 200),
                                            1)               --для непрацюючих
                               THEN
                                     lgw_work_able_sum
                                   - pic_member_month_income
                               ELSE
                                   0
                           END
                       ELSE
                           CASE
                               WHEN     td_begin BETWEEN xpdf_birth_dt
                                                     AND (  ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                72)
                                                          - 1)
                                    AND lgw_6year_sum >
                                        pic_member_month_income --для до6річних
                               THEN
                                   lgw_6year_sum - pic_member_month_income
                               WHEN     td_begin BETWEEN ADD_MONTHS (
                                                             xpdf_birth_dt,
                                                             72)
                                                     AND (  ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                216)
                                                          - 1)
                                    AND lgw_18year_sum >
                                        pic_member_month_income --для до18річних
                               THEN
                                   lgw_18year_sum - pic_member_month_income --для до18річних - різниця між прож.мін та доходом сім'ї
                               WHEN     td_begin BETWEEN ADD_MONTHS (
                                                             xpdf_birth_dt,
                                                             216)
                                                     AND LAST_DAY (
                                                               ADD_MONTHS (
                                                                   xpdf_birth_dt,
                                                                   216)
                                                             - 1)
                                    AND lgw_18year_sum >
                                        pic_member_month_income --для до 18річних до кінця місяця
                               --                          AND 0 = NVL((SELECT tdc_value FROM tmp_pd_detail_calc WHERE tdc_pd = td_pd AND tdc_key = td_pdf AND tdc_start_dt = td_begin AND tdc_ndp = 100), 0) --для учбовців на денній/дуальній формі
                               THEN
                                   lgw_18year_sum - pic_member_month_income --для 18річних до кінця місяця
                               WHEN     td_begin BETWEEN ADD_MONTHS (
                                                             xpdf_birth_dt,
                                                             216)
                                                     AND LAST_DAY (
                                                               ADD_MONTHS (
                                                                   xpdf_birth_dt,
                                                                   216)
                                                             - 1)
                                    AND lgw_work_able_sum >
                                        pic_member_month_income --для до23річних
                                    AND 1 =
                                        NVL (
                                            (SELECT tdc_value
                                               FROM tmp_pd_detail_calc
                                              WHERE     tdc_pd = td_pd
                                                    AND tdc_key = td_pdf
                                                    AND tdc_start_dt =
                                                        td_begin
                                                    AND tdc_ndp = 100),
                                            0) --для учбовців на денній/дуальній формі
                               THEN
                                     lgw_work_able_sum
                                   - pic_member_month_income --для 18річних до кінця місяця
                               WHEN     td_begin BETWEEN ADD_MONTHS (
                                                             xpdf_birth_dt,
                                                             216)
                                                     AND (  ADD_MONTHS (
                                                                xpdf_birth_dt,
                                                                276)
                                                          - 1)
                                    AND lgw_work_able_sum >
                                        pic_member_month_income --для до23річних
                                    AND 1 =
                                        NVL (
                                            (SELECT tdc_value
                                               FROM tmp_pd_detail_calc
                                              WHERE     tdc_pd = td_pd
                                                    AND tdc_key = td_pdf
                                                    AND tdc_start_dt =
                                                        td_begin
                                                    AND tdc_ndp = 100),
                                            0) --для учбовців на денній/дуальній формі
                                    AND 0 =
                                        NVL (
                                            (SELECT tdc_value
                                               FROM tmp_pd_detail_calc
                                              WHERE     tdc_pd = td_pd
                                                    AND tdc_key = td_pdf
                                                    AND tdc_start_dt =
                                                        td_begin
                                                    AND tdc_ndp = 200),
                                            1)               --для непрацюючих
                               THEN
                                     lgw_work_able_sum
                                   - pic_member_month_income
                               ELSE
                                   0
                           END
                   END                                         AS val,
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

        /*
            SELECT 300, 300, td_pdf, td_pd, td_begin, td_end,
                   uss_person.api$sc_tools.get_pib(xpdf_sc)||' дата народж. '||to_char(xpdf_birth_dt, 'DD.MM.YYYY'),
                   CASE WHEN td_begin BETWEEN xpdf_birth_dt AND (ADD_MONTHS(xpdf_birth_dt, 72) - 1) AND lgw_6year_sum > pic_member_month_income --для до6річних
                          THEN lgw_6year_sum - pic_member_month_income
                        WHEN td_begin BETWEEN ADD_MONTHS(xpdf_birth_dt, 72) AND (ADD_MONTHS(xpdf_birth_dt, 216) - 1) AND lgw_18year_sum > pic_member_month_income --для до18річних
                          THEN lgw_18year_sum - pic_member_month_income --для до18річних - різниця між прож.мін та доходом сім'ї

                        WHEN td_begin BETWEEN ADD_MONTHS(xpdf_birth_dt, 216) AND last_day(ADD_MONTHS(xpdf_birth_dt, 216) - 1) AND lgw_work_able_sum > pic_member_month_income --для до23річних
                            AND 0 = NVL((SELECT tdc_value FROM tmp_pd_detail_calc WHERE tdc_pd = td_pd AND tdc_key = td_pdf AND tdc_start_dt = td_begin AND tdc_ndp = 100), 0) --для учбовців на денній/дуальній формі
                          THEN lgw_18year_sum - pic_member_month_income --для 18річних до кінця місяця

                        WHEN td_begin BETWEEN ADD_MONTHS(xpdf_birth_dt, 216) AND last_day(ADD_MONTHS(xpdf_birth_dt, 216) - 1) AND lgw_work_able_sum > pic_member_month_income --для до23річних
                            AND 1 = NVL((SELECT tdc_value FROM tmp_pd_detail_calc WHERE tdc_pd = td_pd AND tdc_key = td_pdf AND tdc_start_dt = td_begin AND tdc_ndp = 100), 0) --для учбовців на денній/дуальній формі
                          THEN lgw_work_able_sum - pic_member_month_income --для 18річних до кінця місяця

                        WHEN td_begin BETWEEN ADD_MONTHS(xpdf_birth_dt, 216) AND (ADD_MONTHS(xpdf_birth_dt, 276) - 1) AND lgw_work_able_sum > pic_member_month_income --для до23річних
                            AND 1 = NVL((SELECT tdc_value FROM tmp_pd_detail_calc WHERE tdc_pd = td_pd AND tdc_key = td_pdf AND tdc_start_dt = td_begin AND tdc_ndp = 100), 0) --для учбовців на денній/дуальній формі
                            AND 0 = NVL((SELECT tdc_value FROM tmp_pd_detail_calc WHERE tdc_pd = td_pd AND tdc_key = td_pdf AND tdc_start_dt = td_begin AND tdc_ndp = 200), 1) --для непрацюючих
                          THEN lgw_work_able_sum - pic_member_month_income
                        ELSE 0
                   END, 23
            FROM tmp_tar_dates, pd_income_calc, uss_ndi.v_ndi_living_wage lw, tmp_pdf_calc_params, tmp_pd_calc_params
            WHERE td_pd = pic_pd
              AND td_pdf = xpdf_id
              AND lw.history_status = 'A'
              AND td_begin >= lgw_start_dt
              AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
              AND td_pd = xpd_id
              AND xpd_calc_alg = 'DIFF_W_LGW';
        */

        UPDATE tmp_pd_detail_calc
           SET tdc_value =
                   CASE
                       WHEN api$pc_decision.get_features_string (tdc_pd,
                                                                 82,
                                                                 'F') =
                            'T'
                       THEN
                             tdc_value
                           * (  100
                              - api$pc_decision.get_features_str2n (tdc_pd,
                                                                    83,
                                                                    0))
                           / 100
                       ELSE
                           tdc_value
                   END
         WHERE tdc_npt = 23;

        SaveMessage ('Підвищєня');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt,
                                        tdc_sub_npt)
              SELECT 294,
                     294,
                     tdc_key,
                     tdc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                        CHR (38)
                     || '152#'
                     || uss_person.api$sc_tools.get_pib (xpdf_sc)
                         AS x_row_name,
                     SUM (tdc_value) * 0.2
                         AS x_value,
                     23
                         AS x_NPT,
                     845
                         AS x_sub_npt
                FROM tmp_pd_detail_calc
                     JOIN tmp_pdf_calc_params ON xpdf_id = tdc_key
               WHERE     tdc_npt IN (23)
                     AND EXISTS
                             (SELECT 1
                                FROM pd_features
                               WHERE     pde_pd = tdc_pd
                                     AND pde_nft = 90
                                     AND pde_val_string = 'T')
            GROUP BY tdc_key,
                     tdc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     xpdf_sc;
    END;

    --=========================================================--
    PROCEDURE COMPUTE_BY_KOEF_LGW
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
                       AS val
              /*             CASE
                           WHEN xpd_ic_tp = 'RC.START_DT' THEN
                             ( SELECT MAX(d.pdd_value)
                               FROM pd_detail d
                               WHERE d.pdd_row_order = 110
                                 AND d.pdd_key = xpdf_id
                                 AND xpd_start_dt-1 BETWEEN d.pdd_start_dt AND d.pdd_stop_dt)
                           ELSE
                                 NVL((SELECT ROUND(SUM(pid_calc_sum)/ 12, 2)
                                      FROM pd_income_calc, pd_income_detail, tmp_pdf_calc_params
                                      WHERE pic_pd = td_pd
                                        AND pid_pic = pic_id
                                        AND pid_sc = xpdf_sc
                                        AND td_pd = xpdf_pd
                                        AND td_pdf = xpdf_id
                                        AND pid_calc_sum > 0), 0)
                           END */
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
                                                  AS x_inv_end, --#75883 2022,02,22
                                              LAST_DAY (
                                                  ADD_MONTHS (xpdf_birth_dt,
                                                              216))
                                                  AS x_birth_dt_18
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
                                     GROUP BY xpdf_id,
                                              LAST_DAY (
                                                  ADD_MONTHS (xpdf_birth_dt,
                                                              216)))
                              WHERE     td_pdf = x_pdf
                                    AND (   (    td_begin BETWEEN x_inv_begin
                                                              AND x_inv_end
                                             AND TRUNC (x_inv_end, 'MM') !=
                                                 TRUNC (x_birth_dt_18, 'MM'))
                                         OR (    td_begin BETWEEN x_inv_begin
                                                              AND x_birth_dt_18
                                             AND TRUNC (x_inv_end, 'MM') =
                                                 TRUNC (x_birth_dt_18, 'MM')))) >
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
                   || TO_CHAR (xpdf_birth_dt, 'DD.MM.YYYY')    AS x_PIB,
                   CASE /*WHEN tc_is_state_alimony = 'T' --#88512 Знаходиться на держутриманні
                          THEN 0*/
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
                                                   AND LAST_DAY (
                                                             ADD_MONTHS (
                                                                 xpdf_birth_dt,
                                                                 216)
                                                           - 1) --для до18річних
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
                                                     AND LAST_DAY (
                                                               ADD_MONTHS (
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
                   END                                         AS x_val,
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
                   AND xpd_calc_alg = 'KOEF_LGW'
                   AND API$ACCOUNT.get_docx_string (xpdf_pd,
                                                    xpdf_sc,
                                                    605,
                                                    677,
                                                    xpd_calc_dt,
                                                    'F') = 'F'        --#88512
                   AND API$ACCOUNT.get_docx_string (xpdf_pd,
                                                    xpdf_sc,
                                                    98,
                                                    856,
                                                    xpd_calc_dt,
                                                    'F') = 'F'        --#88512
                                                              ;

        SaveMessage ('Занулюємо відємні значення');

        UPDATE tmp_pd_detail_calc
           SET tdc_value = 0
         WHERE     tdc_value < 0
               AND tdc_ndp = 300
               AND EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE tdc_pd = xpd_id AND xpd_calc_alg = 'KOEF_LGW');

        SaveMessage ('Підвищєня');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt,
                                        tdc_sub_npt)
              SELECT 294,
                     294,
                     tdc_key,
                     tdc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                        CHR (38)
                     || '152#'
                     || uss_person.api$sc_tools.get_pib (xpdf_sc)
                         AS x_row_name,
                     SUM (tdc_value) * 0.2
                         AS x_value,
                     31
                         AS x_NPT,
                     843
                         AS x_sub_npt
                FROM tmp_pd_detail_calc
                     JOIN tmp_pdf_calc_params ON xpdf_id = tdc_key
               WHERE     tdc_npt IN (31)
                     AND EXISTS
                             (SELECT 1
                                FROM pd_features
                               WHERE     pde_pd = tdc_pd
                                     AND pde_nft = 90
                                     AND pde_val_string = 'T')
            GROUP BY tdc_key,
                     tdc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     xpdf_sc;
    END;

    --=========================================================--
    PROCEDURE COMPUTE_BY_CONST_SUM
    IS
    BEGIN
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
            'Підвищєня до одноразова допомога константою. Алгоритм А1. Період FST');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt,
                                        tdc_sub_npt)
            SELECT 294
                       AS x_ndp,
                   294
                       AS x_row_order,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      CHR (38)
                   || '152#'
                   || uss_person.api$sc_tools.get_pib (xpdf_sc)
                       AS x_row_name,
                   nncs_sum * 0.2,
                   nncs_npt,
                   846
                       AS x_sub_npt
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
                   AND nncs_period_tp = 'FST'
                   AND EXISTS
                           (SELECT 1
                              FROM pd_features
                             WHERE     pde_pd = td_pd
                                   AND pde_nft = 90
                                   AND pde_val_string = 'T');

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
             --      WHERE td_begin >= ADD_MONTHS(TRUNC(xpd_ap_reg_dt, 'MM'), 1)
             WHERE     td_begin > xpd_start_dt
                   AND td_end > xpdf_birth_dt
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'CONST_SUM'
                   AND td_pd = xpdf_pd
                   AND td_pdf = xpdf_id
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A1'
                   AND nncs_period_tp = 'NXM';

        SaveMessage (
            'Підвищєня до щомісячна допомога константою. Алгоритм A1. Період NXM');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt,
                                        tdc_sub_npt)
            SELECT 294
                       AS x_ndp,
                   294
                       AS x_row_order,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      CHR (38)
                   || '152#'
                   || uss_person.api$sc_tools.get_pib (xpdf_sc)
                       AS x_row_name,
                   nncs_sum * 0.2,
                   nncs_npt,
                   846
                       AS x_sub_npt
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
                   AND nncs_period_tp = 'NXM'
                   AND EXISTS
                           (SELECT 1
                              FROM pd_features
                             WHERE     pde_pd = td_pd
                                   AND pde_nft = 90
                                   AND pde_val_string = 'T');

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
                   AND (   tc_is_vpo = 'A'                  --#78022  20220616
                        OR tc_is_vpo_home IN ('D', 'UH')
                        OR tc_is_vpo_evac = 'T')--      AND td_begin BETWEEN tc_sc_start_dt  AND tc_sc_stop_dt
                                                --      AND td_begin = tc_sc_start_dt
                                                --      AND tc_start_dt IS NOT NULL
                                                ;

        SaveMessage (
            'Щомісячна допомога константою. Алгоритм A4. Період FST');

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
                   AND nncs_alg = 'A4'
                   AND nncs_period_tp = 'FST'--      AND tc_appeal_vpo =  'F'
                                             --      AND tc_receives_vpo = 'F'
                                             ;
    END;

    --=========================================================--
    PROCEDURE COMPUTE_BY_LGW_LEVELING
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
            WITH
                tc
                AS
                    (SELECT tc.*,
                            CASE tc.tc_mountain_village
                                WHEN 'T' THEN 1.2
                                ELSE 1
                            END    AS x_koef
                       FROM tmp_calc_app_params tc)
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
                          WHEN     tc_start_dt < tc_calc_dt
                               AND tc_birth_dt IS NOT NULL
                          THEN
                                 ' (вік '
                              || TRUNC (
                                       MONTHS_BETWEEN (tc_calc_dt,
                                                       tc_birth_dt)
                                     / 12,
                                     0)
                              || ' років)'
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
                      END    AS info,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   CASE
                       --особа з інвалідністю, яка непрацює
                       WHEN     tc_inv_state IN ('I', 'IZ')
                            AND tc_start_dt BETWEEN tc_inv_start_dt
                                                AND tc_inv_stop_dt
                            AND tc_is_working = 'F'
                       THEN
                           lgw_work_unable_sum * x_koef
                       WHEN     tc_inv_state IN ('I', 'IZ')
                            AND xpd.xpd_nst IN (249)
                            AND tc_is_working = 'F'
                       THEN
                           lgw_work_unable_sum * x_koef
                       WHEN     tc_start_dt < tc_calc_dt
                            AND tc_calc_dt BETWEEN tc_birth_dt
                                               AND   tools.ADD_MONTHS_LEAP (
                                                         tc_birth_dt,
                                                         72)
                                                   - 1
                       THEN
                           lgw_6year_sum * x_koef
                       WHEN     tc_start_dt < tc_calc_dt
                            AND tc_calc_dt BETWEEN tools.ADD_MONTHS_LEAP (
                                                       tc_birth_dt,
                                                       72)
                                               AND   tools.ADD_MONTHS_LEAP (
                                                         tc_birth_dt,
                                                         216)
                                                   - 1
                       THEN
                           lgw_18year_sum * x_koef
                       WHEN     tc_start_dt < tc_calc_dt
                            AND tc_is_Pensioner = 'T'
                       THEN
                           lgw_work_unable_sum * x_koef
                       WHEN     tc_start_dt < tc_calc_dt
                            AND tc_calc_dt >=
                                ADD_MONTHS (tc_birth_dt, 12 * 60)
                       THEN
                           lgw_work_unable_sum * x_koef
                       WHEN     tc_start_dt < tc_calc_dt
                            AND tc_calc_dt >= ADD_MONTHS (tc_birth_dt, 216)
                            AND tc_is_work_able = 'T'
                       THEN
                           lgw_work_able_sum * x_koef
                       WHEN     tc_start_dt < tc_calc_dt
                            AND tc_calc_dt >= ADD_MONTHS (tc_birth_dt, 216)
                            AND tc_is_work_able = 'F'
                       THEN
                           lgw_work_unable_sum * x_koef
                       ---==================================================================
                       WHEN tc_start_dt BETWEEN tc_birth_dt
                                            AND   tools.ADD_MONTHS_LEAP (
                                                      tc_birth_dt,
                                                      72)
                                                - 1
                       THEN
                           lgw_6year_sum * x_koef
                       WHEN tc_start_dt < tc_birth_dt AND xpd_nst = 249
                       THEN
                           lgw_6year_sum * x_koef
                       WHEN tc_start_dt BETWEEN tools.ADD_MONTHS_LEAP (
                                                    tc_birth_dt,
                                                    72)
                                            AND   tools.ADD_MONTHS_LEAP (
                                                      tc_birth_dt,
                                                      216)
                                                - 1
                       THEN
                           lgw_18year_sum * x_koef
                       --особа з інвалідністю, яка непрацює
                       WHEN     tc_inv_state IN ('I', 'IZ')
                            AND tc_start_dt BETWEEN tc_inv_start_dt
                                                AND tc_inv_stop_dt
                            AND tc_is_working = 'F'
                       THEN
                           lgw_work_unable_sum * x_koef
                       --#75892 2022,02,23
                       --Для особи вік якої більше рівне 60 років, визначати рівень забезпечення прожиткового мінімуму:
                       --% рівня забезпечення прожиткового мінімуму для осіб, які втратили працездатність * прожитковий мінімум для осіб, які втратили працездатність
                       WHEN tc_start_dt >= ADD_MONTHS (tc_birth_dt, 720)
                       THEN
                           lgw_work_unable_sum * x_koef
                       --#85242 2023,03,16
                       --Для особи, у якої в анкеті зазначено "Так" в атрибуті "Пенсіонер", то визначати рівень забезпечення прожиткового мінімуму:
                       --% рівня забезпечення прожиткового мінімуму для осіб, які втратили працездатність * прожитковий мінімум для осіб, які втратили працездатність
                       WHEN tc_is_Pensioner = 'T'
                       THEN
                           lgw_work_unable_sum * x_koef
                       WHEN tc_start_dt >= ADD_MONTHS (tc_birth_dt, 12 * 60)
                       THEN
                           lgw_work_unable_sum * x_koef
                       WHEN     tc_start_dt >= ADD_MONTHS (tc_birth_dt, 216)
                            AND tc_is_work_able = 'T'
                       THEN
                           lgw_work_able_sum * x_koef
                       WHEN     tc_start_dt >= ADD_MONTHS (tc_birth_dt, 216)
                            AND tc_is_work_able = 'F'
                       THEN
                           lgw_work_unable_sum * x_koef
                       ELSE
                           lgw_cmn_sum
                   END       AS val
              FROM tmp_tar_dates
                   JOIN tmp_pd_calc_params xpd ON xpd_id = td_pd
                   --JOIN tmp_calc_app_params tc ON tc.tc_pdf = td_pdf AND tc_start_dt = td_begin
                   JOIN tc ON tc.tc_pdf = td_pdf AND tc_start_dt = td_begin
                   JOIN uss_ndi.v_ndi_living_wage
                       ON     td_begin >= lgw_start_dt
                          AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                          AND history_Status = 'A'
             WHERE xpd_calc_alg = 'LGW_LEVEL';

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
                   || uss_person.api$sc_tools.get_pib (tc_sc)    AS info,
                   tdc_key,
                   tdc_pd,
                   tdc_start_dt,
                   tdc_stop_dt,
                     tdc_value
                   * CASE
                         -------- tc_calc_dt > tc_start_dt ----------------
                         WHEN     tc_calc_dt > tc_start_dt
                              AND tc_calc_dt BETWEEN tc_birth_dt
                                                 AND   ADD_MONTHS (
                                                           tc_birth_dt,
                                                           216)
                                                     - 1
                         THEN
                             nlsl_18year_level
                         WHEN tc_start_dt < tc_birth_dt
                         THEN
                             nlsl_18year_level
                         --Для особи, яка в зверненні щодо допомоги малозабезпеченій сім'ї має анкету, в якій ступінь родинного зв'язку=син/донька,
                         --у якої серед документів наявна довідка про навчання, у якій в період навчання входить "Дата подання заяви":
                         WHEN     tc_calc_dt > tc_start_dt
                              AND XPD_AP_REG_DT BETWEEN tc_study_start_dt
                                                    AND tc_study_stop_dt --AND tc_FamilyConnect = 'B'
                              AND tc_start_dt <
                                  ADD_MONTHS (tc_birth_dt, 12 * 23)
                              AND TC_TP IN ('Z', 'FP', 'FM')          --#99585
                         THEN
                             nlsl_18year_level
                         --особа з інвалідністю, яка непрацює
                         WHEN     tc_calc_dt > tc_start_dt
                              AND tc_inv_state IN ('I', 'IZ')
                              AND tc_start_dt BETWEEN tc_inv_start_dt
                                                  AND tc_inv_stop_dt
                              AND tc_is_working = 'F'
                         THEN
                             nlsl_work_unable_level
                         WHEN     tc_calc_dt > tc_start_dt
                              AND tc_inv_state IN ('I', 'IZ')
                              AND xpd_nst IN (249)
                              AND tc_is_working = 'F'
                         THEN
                             nlsl_work_unable_level
                         --#75892 2022,02,23
                         --Для особи вік якої більше рівне 60 років, визначати рівень забезпечення прожиткового мінімуму:
                         --% рівня забезпечення прожиткового мінімуму для осіб, які втратили працездатність * прожитковий мінімум для осіб, які втратили працездатність
                         WHEN     tc_calc_dt > tc_start_dt
                              AND tc_calc_dt >= ADD_MONTHS (tc_birth_dt, 720)
                         THEN
                             nlsl_work_unable_level
                         --#85242 2023,03,16
                         --Для особи, у якої в анкеті зазначено "Так" в атрибуті "Пенсіонер", то визначати рівень забезпечення прожиткового мінімуму:
                         --% рівня забезпечення прожиткового мінімуму для осіб, які втратили працездатність * прожитковий мінімум для осіб, які втратили працездатність
                         WHEN tc_is_Pensioner = 'T'
                         THEN
                             nlsl_work_unable_level
                         WHEN     tc_calc_dt > tc_start_dt
                              AND tc_calc_dt > ADD_MONTHS (tc_birth_dt, 216)
                              AND tc_is_work_able = 'T'
                         THEN
                             nlsl_work_able_level
                         WHEN     tc_calc_dt > tc_start_dt
                              AND tc_calc_dt > ADD_MONTHS (tc_birth_dt, 216)
                              AND tc_is_work_able = 'F'
                         THEN
                             nlsl_work_unable_level
                         -------- tc_calc_dt <= tc_start_dt ----------------
                         WHEN tc_start_dt BETWEEN tc_birth_dt
                                              AND   ADD_MONTHS (tc_birth_dt,
                                                                216)
                                                  - 1
                         THEN
                             nlsl_18year_level
                         WHEN tc_start_dt < tc_birth_dt
                         THEN
                             nlsl_18year_level
                         --Для особи, яка в зверненні щодо допомоги малозабезпеченій сім'ї має анкету, в якій ступінь родинного зв'язку=син/донька,
                         --у якої серед документів наявна довідка про навчання, у якій в період навчання входить "Дата подання заяви":
                         WHEN     XPD_AP_REG_DT BETWEEN tc_study_start_dt
                                                    AND tc_study_stop_dt --AND tc_FamilyConnect = 'B'
                              AND tc_start_dt <
                                  ADD_MONTHS (tc_birth_dt, 12 * 23)
                              AND TC_TP IN ('Z', 'FP', 'FM')          --#99585
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
                         --#85242 2023,03,16
                         --Для особи, у якої в анкеті зазначено "Так" в атрибуті "Пенсіонер", то визначати рівень забезпечення прожиткового мінімуму:
                         --% рівня забезпечення прожиткового мінімуму для осіб, які втратили працездатність * прожитковий мінімум для осіб, які втратили працездатність
                         WHEN tc_is_Pensioner = 'T'
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
                   * DECODE (xpd_mount_live, 'T', 1                    /*1.2*/
                                                   , 1)
                   / 100                                         AS val
              FROM tmp_pd_detail_calc,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_lgw_sub_level
             WHERE     tdc_pd = xpd_id
                   AND tdc_key = tc_pdf
                   AND tdc_start_dt = tc_start_dt
                   AND history_status = 'A'
                   AND tdc_start_dt >= nlsl_start_dt
                   AND (tdc_start_dt <= nlsl_stop_dt OR nlsl_stop_dt IS NULL)
                   AND tdc_ndp = 130;

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
                     --AND tdc_start_dt BETWEEN cd_begin AND cd_end
                     AND cd_begin BETWEEN tdc_start_dt AND tdc_stop_dt
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
                     --AND tdc_start_dt BETWEEN cd_begin AND cd_end
                     AND cd_begin BETWEEN tdc_start_dt AND tdc_stop_dt
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
            SELECT 134,
                   134,
                   NULL,
                   i_pd,
                   i_start_dt,
                   i_end,
                   'Розрахована допомога малозабезпеченим сім`ям',
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
                   NULL
              FROM periods, sums, tmp_pd_calc_params
             WHERE     i_pd = xpd_id
                   AND i_pd = z_pd
                   AND i_start_dt BETWEEN z_start_dt AND z_stop_dt;


        /*
        SELECT tc.*,
                               CASE tc.tc_mountain_village
                                 WHEN 'T' THEN 1.2
                                 ELSE  1
                               END AS x_koef
                        FROM tmp_calc_app_params tc
        */

        SaveMessage (
            'Скоригуємо суму допомоги малозабезпеченим сім’ям, якщо вона від''ємна');

        UPDATE tmp_pd_detail_calc
           SET tdc_value =
                   (CASE WHEN tdc_value < 0 THEN 0 ELSE tdc_value END)
         WHERE tdc_ndp = 134;

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
                   tdc_key,
                   tdc_pd,
                   tdc_start_dt,
                   tdc_stop_dt,
                   'Допомога малозабезпеченим сім`ям'
                       AS x_row_name,
                   (SELECT MAX (tt.tdc_value)
                      FROM tmp_pd_detail_calc tt
                     WHERE     tt.tdc_pd = t.tdc_pd
                           AND tt.tdc_ndp = t.tdc_ndp
                           AND tt.tdc_start_dt <= t.tdc_start_dt)
                       AS x_value,
                   45
                       AS x_npt
              FROM tmp_pd_detail_calc t
             WHERE tdc_ndp = 134;

        /*
              SELECT 300, 300, tdc_key, tdc_pd, tdc_start_dt, tdc_stop_dt,
                     'Допомога малозабезпеченим сім`ям' AS x_row_name,
                     MAX(t.tdc_value) OVER (PARTITION BY t.tdc_pd
                                            ORDER BY t.tdc_start_dt ASC
                                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS x_value,
                     45 AS x_npt
              FROM tmp_pd_detail_calc t
              WHERE tdc_ndp = 134;
        */
        --#96210
        --Покращення перерахунку по бюджетних показниках по малозабезпеченій сім'ї (послуга з Ід=249)
        --Сума розрахованої допомоги малозабезпеченій свм'ї не може зменшуватися в періоді призначення, відповідповідно в процесі перерахунку,
        --якщо сума призначеної допомоги по послузі з ІД=249 за результатами перерахунку є меншою, ніж сума до перерахунку (станом на 31.12.2023),
        --то сума призначеної допомоги має = сумі станом на 31.12.2023.
        UPDATE tmp_pd_detail_calc dc
           SET tdc_value =
                   (SELECT CASE
                               WHEN NVL (MAX (pdd.pdd_value), 0) > tdc_value
                               THEN
                                   NVL (MAX (pdd.pdd_value), 0)
                               ELSE
                                   tdc_value
                           END
                      FROM tmp_pd_calc_params  xpd
                           JOIN pd_payment pdp ON pdp.pdp_pd = xpd.xpd_id
                           JOIN pd_detail pdd
                               ON     pdd.pdd_pdp = pdp.pdp_id
                                  AND (   pdd.pdd_ndp = 134
                                       OR pdd.pdd_ndp = 290
                                       OR pdd.pdd_ndp = tdc_ndp)
                     WHERE     xpd.xpd_id = dc.tdc_pd
                           AND (xpd.xpd_start_dt - 1) BETWEEN pdp.pdp_start_dt
                                                          AND pdp.pdp_stop_dt
                           AND pdp.history_status = 'A')
         WHERE tdc_npt = 45;

        /*
            UPDATE tmp_pd_detail_calc dc SET
              tdc_value = ( SELECT CASE
                                   WHEN NVL(MAX(pdd.pdd_value),0) > tdc_value THEN
                                       NVL(MAX(pdd.pdd_value),0)
                                   ELSE
                                       tdc_value
                                   END
                            FROM pd_payment pdp
                            JOIN pd_detail  pdd ON pdd.pdd_pdp = pdp.pdp_id
                                                   AND ( pdd.pdd_ndp = 134 OR  pdd.pdd_ndp = 290)
                            WHERE pdp.pdp_pd = dc.tdc_pd
                              AND pdp.history_status = 'A'
                          )
            WHERE tdc_npt = 45;
          */
        UPDATE tmp_pd_detail_calc
           SET tdc_value =
                   (SELECT CASE
                               WHEN NVL (p.tc_percent_decrease, 0) != 0
                               THEN
                                     tdc_value
                                   * (100 - p.tc_percent_decrease)
                                   / 100
                               ELSE
                                   tdc_value
                           END
                      FROM tmp_calc_app_params p
                     WHERE     tdc_pd = tc_pd
                           AND tc_start_dt IS NULL
                           AND ROWNUM < 2)
         WHERE tdc_npt = 45;
    /*
       WITH periods AS (SELECT cd_pd AS i_pd, cd_begin AS i_start_dt, cd_end AS i_end FROM tmp_calc_dates),
            sums AS (SELECT tdc_pd AS z_pd, tdc_start_dt AS z_start_dt, tdc_stop_dt AS z_stop_dt,
                            SUM(DECODE(tdc_ndp, 133, tdc_value, 0)) AS z_rpms_sum,
                            SUM(DECODE(tdc_ndp, 132, tdc_value, 0)) AS z_zpms_sum
                     FROM tmp_pd_detail_calc
                     WHERE tdc_ndp IN (132, 133)
                     GROUP BY tdc_pd, tdc_start_dt, tdc_stop_dt)
        SELECT 300, 300, NULL, i_pd, i_start_dt, i_end,
               'Допомога малозабезпеченим сім`ям',
               CASE WHEN z_zpms_sum - xpd_family_income > z_rpms_sum AND xpd_mount_live = 'T'
                      THEN z_zpms_sum - xpd_family_income
                    WHEN z_zpms_sum - xpd_family_income > z_rpms_sum AND xpd_mount_live = 'F'
                      THEN z_rpms_sum
                    ELSE z_zpms_sum - xpd_family_income
               END, 45
        FROM periods, sums, tmp_pd_calc_params
        WHERE i_pd = xpd_id
          AND i_pd = z_pd
          AND i_start_dt BETWEEN z_start_dt AND z_stop_dt;
          --AND i_start_dt = z_start_dt;
    */
    --#73911 2021,12,14
    END;

    --=========================================================--
    PROCEDURE COMPUTE_BY_INV_CATEGORY
    IS
    BEGIN
        -- 1) Розраховуємо  основну суму допомоги:
        -- npt_id = 219  npt_code = '129'
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
            WITH
                pay
                AS
                    (SELECT 280                         AS x_ndp,
                            280                         AS x_row_order,
                               'Розмір допомоги '
                            || uss_person.api$sc_tools.get_pib (tc_sc)
                            || CASE
                                   WHEN     tc_inv_state = 'IZ'
                                        AND tc_inv_group = '1'
                                   THEN
                                       ' (з інвалідністю з дитинства, група інвалідності 1)'
                                   WHEN     tc_inv_state = 'IZ'
                                        AND tc_inv_group = '2'
                                   THEN
                                       ' (з інвалідністю з дитинства, група інвалідності 2)'
                                   WHEN     tc_inv_state = 'IZ'
                                        AND tc_inv_group = '3'
                                   THEN
                                       ' (з інвалідністю з дитинства, група інвалідності 3)'
                                   WHEN tc_inv_state = 'DI'
                                   THEN
                                       ' (дитина з інвалідністю)'
                                   ELSE
                                       ''
                               END                      AS x_row_name,
                            tc_pdf                      AS x_key,
                            tc_pd                       AS x_pd,
                            td_begin                    AS x_begin,
                            td_end                      AS x_end,
                            CASE
                                WHEN     tc_inv_state = 'IZ'
                                     AND tc_inv_group = '1'
                                THEN
                                    lgw_work_unable_sum * 100 / 100
                                WHEN     tc_inv_state = 'IZ'
                                     AND tc_inv_group = '2'
                                THEN
                                    lgw_work_unable_sum * 80 / 100
                                WHEN     tc_inv_state = 'IZ'
                                     AND tc_inv_group = '3'
                                THEN
                                    lgw_work_unable_sum * 60 / 100
                                WHEN tc_inv_state = 'DI'
                                THEN
                                    lgw_work_unable_sum * 70 / 100
                                ELSE
                                    0
                            END                         AS x_value,        --1
                            CASE
                                WHEN tc_inv_prev_state = 'DI'
                                THEN
                                    lgw_work_unable_sum * 70 / 100
                                ELSE
                                    0
                            END                         AS x_prev_value,   --1
                            219                         AS x_npt, --#82076 2022.12.08
                            tc_inv_state                AS x_inv_state,
                            NVL (xpd_prev_summ, 0)      AS x_prev_summ,
                            NVL (tc_inv_rc_alg, '-')    AS x_inv_rc_alg
                       FROM tmp_tar_dates,
                            tmp_calc_app_params,
                            uss_ndi.v_ndi_living_wage,
                            tmp_pd_calc_params
                      WHERE     td_begin = tc_start_dt
                            AND td_pdf = tc_pdf
                            AND td_pd = tc_pd
                            --AND tc_inv_state IN ('IZ', 'DI')
                            AND td_begin >= lgw_start_dt
                            AND (   td_begin <= lgw_stop_dt
                                 OR lgw_stop_dt IS NULL)
                            AND history_status = 'A'
                            AND td_pd = xpd_id
                            AND xpd_calc_alg = 'INV_BY_LGW')
                --Загальний випадок
                SELECT x_ndp,
                       x_row_order,
                       x_row_name,
                       x_key,
                       x_pd,
                       x_begin,
                       x_end,
                       x_value,
                       x_npt
                  FROM pay
                 WHERE x_inv_state IN ('IZ', 'DI') AND x_inv_rc_alg = '-'
                UNION ALL
                --коли попередня сума менша - стандартний
                SELECT x_ndp,
                       x_row_order,
                       x_row_name,
                       x_key,
                       x_pd,
                       x_begin,
                       x_end,
                       x_value,
                       x_npt
                  FROM pay
                 WHERE     x_inv_state IN ('IZ', 'DI')
                       AND x_inv_rc_alg = '1'
                       AND x_prev_summ <= x_value
                UNION ALL
                --коли попередня сума бульша - беремо попереднью
                SELECT x_ndp,
                       x_row_order,
                       x_row_name,
                       x_key,
                       x_pd,
                       x_begin,
                       x_end,
                       x_value,
                       x_npt
                  FROM pay
                 WHERE     x_inv_state IN ('IZ', 'DI')
                       AND x_inv_rc_alg = '1'
                       AND x_prev_summ > x_value
                UNION ALL
                --коли попередня сума бульша - беремо попереднью
                SELECT x_ndp,
                       x_row_order,
                       x_row_name,
                       x_key,
                       x_pd,
                       x_begin,
                       x_end,
                       x_value,
                       x_npt
                  FROM pay
                 WHERE     x_inv_state IN ('IZ', 'DI')
                       AND x_inv_rc_alg = '2'
                       AND x_prev_summ > x_value
                UNION ALL
                --для другого та третьго - розоахунк для дтини
                SELECT x_ndp,
                       x_row_order,
                       x_row_name,
                       x_key,
                       x_pd,
                       x_begin,
                       x_end,
                       x_prev_value,
                       x_npt
                  FROM pay
                 WHERE x_inv_rc_alg IN ('2', '3') AND x_prev_summ > x_value;


        SaveMessage ('Визначається розмір надбавки на догляд');

        -- 2) Розраховуємо надбавку на догляд:
        -- npt_id = 48  code = '290'
        --f( npt_id = 219  code = '129' )

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 282,
                   282,
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
                                                AND   TOOLS.ADD_MONTHS_LEAP (
                                                          tc_birth_dt,
                                                          72)
                                                    - 1
                       THEN
                             lgw_6year_sum
                           * api$pc_decision.get_care_raise ('ALG5',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'DI'
                            AND tc_inv_child = 'DI'
                            AND tc_start_dt BETWEEN tc_birth_dt
                                                AND   TOOLS.ADD_MONTHS_LEAP (
                                                          tc_birth_dt,
                                                          72)
                                                    - 1
                       THEN
                             lgw_6year_sum
                           * api$pc_decision.get_care_raise ('ALG6',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'DI'
                            AND tc_inv_child = 'DIA'
                            AND tc_start_dt BETWEEN TOOLS.ADD_MONTHS_LEAP (
                                                        tc_birth_dt,
                                                        72)
                                                AND   TOOLS.ADD_MONTHS_LEAP (
                                                          tc_birth_dt,
                                                          216)
                                                    - 1
                       THEN
                             lgw_18year_sum
                           * api$pc_decision.get_care_raise ('ALG7',
                                                             tc_start_dt)
                           / 100
                       WHEN     tc_inv_state = 'DI'
                            AND tc_inv_child = 'DI'
                            AND tc_start_dt BETWEEN TOOLS.ADD_MONTHS_LEAP (
                                                        tc_birth_dt,
                                                        72)
                                                AND   TOOLS.ADD_MONTHS_LEAP (
                                                          tc_birth_dt,
                                                          216)
                                                    - 1
                       THEN
                             lgw_18year_sum
                           * api$pc_decision.get_care_raise ('ALG8',
                                                             tc_start_dt)
                           / 100
                       ELSE
                           0
                   END
                       AS x_val,
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
                   --AND tdc_ndp = 280
                   AND tdc_npt = 219
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND (   EXISTS
                               (SELECT 1       -- Улучшение #73313  2021.11.24
                                  FROM pd_right_log              prl,
                                       uss_ndi.v_ndi_right_rule  nrr
                                 WHERE     prl.prl_pd = tdc_pd
                                       AND prl.prl_result = 'T'
                                       AND nrr.nrr_id = prl.prl_nrr
                                       AND nrr.nrr_alg = 'ALG17')
                        OR td_begin BETWEEN TC_CARE_START_DT
                                        AND TC_CARE_STOP_DT);

        SaveMessage (
            'Визначається розмір доплати собам з інвалідністю з дитинства I групи, віднесених до підгрупи А');
        SaveMessage (
            'до розміру розміру державної соціальної допомоги з надбавкою на догляд, що виплачується на дітей з інвалідністю підгрупи А віком від 6 до 18 років');

        /*
        3) Розраховуємо доплату особам з інвалідністю з дитинства I групи, віднесених до підгрупи А:
        npt_id =  195 (npt_code='986')  = f( npt_id = 219  code = '129',
                                             npt_id = 48  code = '290'
                                           )
       */
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
                             AND tdc_npt IN (219, 48)
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

        /*
        Розраховуємо інші надбавки, у випадку наявності права :
        */
        SaveMessage (
            'Визначається розмір підвищення дітям з інвалідністю внаслідок аварії на ЧАЕС');

        /*
        4) ЧАЕС
        npt_id = 176  code = '291' f( npt_id = 219  code = '129' )
       */
        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 284,
                   284,
                   'Підвищення дітям з інвалідністю внаслідок аварії на ЧАЕС',
                   tc_pdf,
                   tc_pd,
                   tdc.tdc_start_dt,
                   tdc.tdc_stop_dt,
                   tdc_value * 50 / 100,                                   --4
                   176                                     --#82076 2022.12.08
              FROM tmp_pd_detail_calc  tdc
                   JOIN tmp_calc_app_params tc
                       ON     tdc.tdc_pd = tc.tc_pd
                          AND tdc.tdc_key = tc.tc_pdf
                          AND tdc.tdc_start_dt = tc.tc_start_dt
             WHERE tc.tc_is_child_inv_chaes = 'T' --AND tdc.tdc_ndp = 280
                                                  AND tdc_npt = 219;

        SaveMessage ('Визначається розмір "Підвищення дітям війни"');

        /*
        5) ПІДВИЩЕННЯ ДІТЯМ ВІЙНИ
        npt_id = 184 npt_code='260'  f( uss_ndi.v_ndi_nst_const_sum.nncs_sum )
        */
        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 284,
                   284,
                   'Підвищення дітям війни',
                   tc_pdf,
                   tc_pd,
                   td.td_begin,
                   td.td_end,
                   cs.nncs_sum,
                   tc_npt
              FROM tmp_tar_dates  td
                   JOIN tmp_calc_app_params tc
                       ON     td_begin = tc_start_dt
                          AND td_pdf = tc_pdf
                          AND td_pd = tc_pd
                   JOIN uss_ndi.v_ndi_nst_const_sum cs
                       ON     cs.nncs_npt = tc.tc_npt
                          AND cs.history_status = 'A'
                          AND cs.nncs_alg = 'A5'
             WHERE     tc.tc_start_dt BETWEEN cs.nncs_start_dt
                                          AND cs.nncs_stop_dt
                   AND TO_DATE ('02.09.1945', 'dd.mm.yyyy') BETWEEN tc.tc_birth_dt
                                                                AND ADD_MONTHS (
                                                                        tc.tc_birth_dt,
                                                                          12
                                                                        * 18);

        SaveMessage (
            'Визначається розмір "ПІДВ.ПОДРУЖЖЮ ПОМЕРЛИХ ІHВАЛІДІВ ВІЙHИ"');

        /*
        6)  ПІДВ.ПОДРУЖЖЮ ПОМЕРЛИХ ІHВАЛІДІВ ВІЙHИ
        npt_id = 222 npt_code='251' f( uss_ndi.v_ndi_living_wage.lgw_work_unable_sum )
        */
        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 283,
                   283,
                   'ПІДВ.ПОДРУЖЖЮ ПОМЕРЛИХ ІHВАЛІДІВ ВІЙHИ',
                   tc_pdf,
                   tc_pd,
                   td_begin,
                   td_end,
                   lgw_work_unable_sum * 0.25     AS s,
                   222
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
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND (   (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8491,
                                                             tc_calc_dt,
                                                             '-') = 'DE'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8492,
                                                             tc_calc_dt,
                                                             '-') = 'INVW')
                        OR (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8502,
                                                             tc_calc_dt,
                                                             '-') = 'DE'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8503,
                                                             tc_calc_dt,
                                                             '-') = 'INVW'));

        /*
        Розраховуємо інші надбавки, у випадку наявності права (перелік надбавок, які найближчим часом (сьогодні 20240801) планується впровадити:
        */

        SaveMessage (
            'Визначається розмір "ПІДВИЩ. ЧЛ.СІМЕЙ ЗАГИБЛ.ВІЙСЬКОВОСЛУЖБ"');

        /*
        7)  ПІДВИЩ. ЧЛ.СІМЕЙ ЗАГИБЛ.ВІЙСЬКОВОСЛУЖБ
        npt_id = 204 npt_code='239' f( uss_ndi.v_ndi_living_wage.lgw_work_unable_sum )
        */
        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 285,
                   285,
                   'ПІДВИЩ. ЧЛ.СІМЕЙ ЗАГИБЛ.ВІЙСЬКОВОСЛУЖБ',
                   tc_pdf,
                   tc_pd,
                   td_begin,
                   td_end,
                   lgw_work_unable_sum * 0.25     AS s,
                   204
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
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND (   (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8491,
                                                             tc_calc_dt,
                                                             '-') = 'DSP'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8492,
                                                             tc_calc_dt,
                                                             '-') = 'SM')
                        OR (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8502,
                                                             tc_calc_dt,
                                                             '-') = 'DSP'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8503,
                                                             tc_calc_dt,
                                                             '-') = 'SM'));

        SaveMessage (
            'Визначається розмір "ПІДВ. ЧЛ. СІМЕЙ ПОМЕРЛИХ ВІЙСЬКОВОСЛ"');

        /*
        8)  ПІДВ. ЧЛ. СІМЕЙ ПОМЕРЛИХ ВІЙСЬКОВОСЛ
        npt_id = 207  npt_code='252' f( uss_ndi.v_ndi_living_wage.lgw_work_unable_sum )
        */

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 286,
                   286,
                   'ПІДВ. ЧЛ. СІМЕЙ ПОМЕРЛИХ ВІЙСЬКОВОСЛ',
                   tc_pdf,
                   tc_pd,
                   td_begin,
                   td_end,
                   lgw_work_unable_sum * 0.25     AS s,
                   207
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
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND (   (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8491,
                                                             tc_calc_dt,
                                                             '-') = 'DE'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8492,
                                                             tc_calc_dt,
                                                             '-') = 'SM')
                        OR (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8502,
                                                             tc_calc_dt,
                                                             '-') = 'DE'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8503,
                                                             tc_calc_dt,
                                                             '-') = 'SM'));

        SaveMessage (
            'Визначається розмір "ПІДВ. ЧЛ.СІМЕЙ ПОМЕРЛИХ ОСІБ,ПРИР.ДО В/С"');

        /*
        9)  ПІДВ. ЧЛ.СІМЕЙ ПОМЕРЛИХ ОСІБ,ПРИР.ДО В/С
        npt_id = 234  npt_code='253' f( uss_ndi.v_ndi_living_wage.lgw_work_unable_sum )
        */
        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 287,
                   287,
                   'ПІДВ. ЧЛ.СІМЕЙ ПОМЕРЛИХ ОСІБ,ПРИР.ДО В/С',
                   tc_pdf,
                   tc_pd,
                   td_begin,
                   td_end,
                   lgw_work_unable_sum * 0.25     AS s,
                   234
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
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND (   (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8491,
                                                             tc_calc_dt,
                                                             '-') = 'DE'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8492,
                                                             tc_calc_dt,
                                                             '-') = 'EQSM')
                        OR (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8502,
                                                             tc_calc_dt,
                                                             '-') = 'DE'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8503,
                                                             tc_calc_dt,
                                                             '-') = 'EQSM'));

        SaveMessage (
            'Визначається розмір "ПІДВ. ЧЛ.СІМЕЙ ЗАГИБЛИХ ОСІБ, ПРИР.ДО В/С"');

        /*
        10)  ПІДВ. ЧЛ.СІМЕЙ ЗАГИБЛИХ ОСІБ, ПРИР.ДО В/С
        npt_id = 239  npt_code='254' f( uss_ndi.v_ndi_living_wage.lgw_work_unable_sum )
        */
        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 288,
                   288,
                   'ПІДВ. ЧЛ.СІМЕЙ ЗАГИБЛИХ ОСІБ, ПРИР.ДО В/С',
                   tc_pdf,
                   tc_pd,
                   td_begin,
                   td_end,
                   lgw_work_unable_sum * 0.25     AS s,
                   239
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
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND (   (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8491,
                                                             tc_calc_dt,
                                                             '-') = 'DSP'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10133,
                                                             8492,
                                                             tc_calc_dt,
                                                             '-') = 'EQSM')
                        OR (    API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8502,
                                                             tc_calc_dt,
                                                             '-') = 'DSP'
                            AND API$ACCOUNT.get_docx_string (tc_pd,
                                                             tc_sc,
                                                             10322,
                                                             8503,
                                                             tc_calc_dt,
                                                             '-') = 'EQSM'));

        /*
        Якщо виконуються одночасно такі умови:
        в особи одночасно наявно документ з Ід=201 при цьому

        Якщо прикріплено документ з Ід=70 "Посвідчення учасника війни", то необхідно розраховувати виплату з npt_id='235' (npt_code='249') ПІДВИЩ. УЧАСНИКАМ ВІЙНИ в складі 169 коду виплати, у розмірі 10% від прожиткового мінімуму для осіб, що втратили працездатність.
        Надбавку призначати на весь термін призначення допомоги, але не більше ніж до дати зазначеної у атрибуті з Ід=4328 (документ з Ід=70 )
        */
        /*
        11) npt_id = 237  npt_code='228'
        */
        SaveMessage (
            'Визначається розмір "ПІДВ. УЧАСHИКАМ ВІЙHИ (БОЙОВИХ ДІЙ)"');

        /*
        12) ПІДВ. УЧАСHИКАМ ВІЙHИ (БОЙОВИХ ДІЙ)
        npt_id = 178  npt_code='229'
        */
        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 270,
                   270,
                   'ПІДВ. УЧАСHИКАМ ВІЙHИ (БОЙОВИХ ДІЙ)',
                   tc_pdf,
                   tc_pd,
                   td_begin,
                   td_end,
                   lgw_work_unable_sum * 0.25     AS s,
                   178
              FROM tmp_tar_dates,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage,
                   tmp_pd_calc_params
             WHERE     td_begin = tc_start_dt
                   AND td_pdf = tc_pdf
                   AND td_pd = tc_pd
                   AND tc_inv_state IN ('IZ', 'I')
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND history_status = 'A'
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND API$ACCOUNT.get_docx_count (tc_pd,
                                                   tc_sc,
                                                   71,
                                                   tc_calc_dt) > 0
                   AND Api$account.get_docx_dt (tc_pd,
                                                tc_sc,
                                                71,
                                                4329,
                                                xpd_calc_dt) > tc_start_dt
            UNION ALL
            SELECT 270,
                   270,
                   'ПІДВ. УЧАСHИКАМ ВІЙHИ (БОЙОВИХ ДІЙ)',
                   tc_pdf,
                   tc_pd,
                   td_begin,
                   td_end,
                   lgw_work_unable_sum * 0.25     AS s,
                   178
              FROM tmp_tar_dates,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage,
                   tmp_pd_calc_params
             WHERE     td_begin = tc_start_dt
                   AND td_pdf = tc_pdf
                   AND td_pd = tc_pd
                   AND tc_inv_state IN ('IZ', 'I')
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND history_status = 'A'
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND API$ACCOUNT.get_docx_count (tc_pd,
                                                   tc_sc,
                                                   70,
                                                   tc_calc_dt) > 0   --#109685
                   AND API$ACCOUNT.get_docx_count (tc_pd,
                                                   tc_sc,
                                                   267,
                                                   tc_calc_dt) > 0
                   AND Api$account.get_docx_dt (tc_pd,
                                                tc_sc,
                                                70,
                                                4328,
                                                xpd_calc_dt) > tc_start_dt;


        SaveMessage ('Визначається розмір "ПІДВИЩ. УЧАСНИКАМ ВІЙНИ"');

        /*
        13)  ПІДВИЩ. УЧАСНИКАМ ВІЙНИ
        npt_id = 235  npt_code='249' f( uss_ndi.v_ndi_living_wage.lgw_work_unable_sum )
        */
        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 289,
                   289,
                   'ПІДВИЩ. УЧАСНИКАМ ВІЙНИ',
                   tc_pdf,
                   tc_pd,
                   td_begin,
                   td_end,
                   lgw_work_unable_sum * 0.1     AS s,
                   235
              FROM tmp_tar_dates,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage,
                   tmp_pd_calc_params
             WHERE     td_begin = tc_start_dt
                   AND td_pdf = tc_pdf
                   AND td_pd = tc_pd
                   AND tc_inv_state IN ('IZ', 'I')
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND history_status = 'A'
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'INV_BY_LGW'
                   AND API$ACCOUNT.get_docx_count (tc_pd,
                                                   tc_sc,
                                                   70,
                                                   tc_calc_dt) > 0
                   AND Api$account.get_docx_dt (tc_pd,
                                                tc_sc,
                                                70,
                                                4328,
                                                xpd_calc_dt) > tc_start_dt
                   AND API$ACCOUNT.get_docx_count (tc_pd,
                                                   tc_sc,
                                                   267,
                                                   tc_calc_dt) = 0  -- #109686
                                                                  ;

        /*
        14) npt_id = 308  npt_code='2229'
        */

        SaveMessage ('Визначається розмір гірської надбавки ');

        /*
        15) Гірська надбавка
        npt_id = 288 npt_code='256' f( 20% від суми таких виплат
                                        npt_id = 219 npt_code='129'
                                        npt_id =  48 npt_code='290'
                                        npt_id = 195 npt_code='986'
                                        npt_id = 176 npt_code='291'
                                        npt_id = 469 npt_code='223'
                                        npt_id = 184 npt_code='260'
                                        npt_id = 222 npt_code='251'
                                        npt_id = 204 npt_code='239'
                                        npt_id = 207 npt_code='252'
                                        npt_id = 234 npt_code='253'
                                        npt_id = 239 npt_code='254'
                                        npt_id = 237 npt_code='228'
                                        npt_id = 178 npt_code='229'
                                        npt_id = 235 npt_code='249'
                                        npt_id = 308 npt_code='2229'
                                     )
        */
        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt,
                                        tdc_sub_npt)
              SELECT 294,
                     294,
                     tdc_key,
                     tdc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                        CHR (38)
                     || '152#'
                     || uss_person.api$sc_tools.get_pib (tc_sc)
                         AS x_row_name,
                     SUM (tdc_value) * 0.2
                         AS x_value,
                     1
                         AS x_NPT,
                     288
                         AS x_sub_npt
                FROM tmp_pd_detail_calc
                     JOIN tmp_calc_app_params tc
                         ON     NVL (tc_pdf, 0) = NVL (tdc_key, 0)
                            AND tc_pd = tdc_pd
                            AND tc_start_dt = tdc_start_dt
               WHERE     tdc_npt IN (219,
                                     48,
                                     195,
                                     176,
                                     469,
                                     184,
                                     222,
                                     204,
                                     207,
                                     234,
                                     239,
                                     237,
                                     178,
                                     235,
                                     308)
                     AND tc.tc_mountain_village = 'T'
            GROUP BY tdc_key,
                     tdc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     tc_sc;

        SaveMessage ('Визначається розмір допомоги ');

        /*
        16) Усі вищезазначені виплати є складовими виплати npt_id = 1 npt_code='169'  крім npt_id =  195 (npt_code='986')
        npt_id = 1 npt_code='169' f(розраховується як сума усіх зазначених вище виплат Відповідно в рішенні в деталізації виплати)
        */
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
                     tdc.tdc_start_dt,
                     tdc.tdc_stop_dt,
                     SUM (tdc_value),
                     1
                FROM tmp_pd_detail_calc tdc
                     JOIN tmp_calc_app_params tc
                         ON     tdc.tdc_pd = tc.tc_pd
                            AND tdc.tdc_key = tc.tc_pdf
                            AND tdc.tdc_start_dt = tc.tc_start_dt
               WHERE tdc_npt IN (219,
                                 48,                                  /*195,*/
                                 176,
                                 469,
                                 184,
                                 222,
                                 204,
                                 207,
                                 234,
                                 239,
                                 237,
                                 178,
                                 235,
                                 308)
            --OR tdc.tdc_sub_npt IN (288)
            GROUP BY tc_sc,
                     tc_pdf,
                     tc_pd,
                     tdc.tdc_start_dt,
                     tdc.tdc_stop_dt,
                     tc_inv_state,
                     tc_inv_group;


        SaveMessage (
            'Визначається розмір доплати "до ПМ" до Державної соціальної допомоги особам з інвалідністю з дитинства та дітям з інвалідністю');

        /*
        Розраховуємо доплату до прожиткового мінімуму, встановленого законом для осіб, які втратили працездатність
        npt_id = 180  code = '995' f( npt_id = 1  code = '199'  - lgw_work_unable_sum )
        */
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
                     --AND tdc_ndp IN (280, 284, 294)
                     AND tdc_npt IN (1, 195)
                     --AND tdc_sub_npt IS NULL
                     AND td_pd = xpd_id
                     AND xpd_calc_alg = 'INV_BY_LGW'
                     AND NOT EXISTS
                             (SELECT 1
                                FROM tmp_pd_detail_calc pdc1
                               WHERE     pdc1.tdc_pd = tc_pd
                                     AND pdc1.tdc_key = tc_pdf
                                     AND pdc1.tdc_row_order = 282
                                     AND pdc1.tdc_value > 0
                                     AND td_begin BETWEEN pdc1.tdc_start_dt
                                                      AND pdc1.tdc_stop_dt)
              HAVING SUM (tdc_value) < lgw_work_unable_sum
            GROUP BY tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     lgw_work_unable_sum;                  --#73565 2021.11.29


        SaveMessage (
            'Визначається розмір "ЩОМІСЯЧНА ДОПЛАТА ДО ДСД (ПОСТ.№118 ВІД 16.02.22)" до Державної соціальної допомоги особам з інвалідністю з дитинства та дітям з інвалідністю');

        /*
        18) Розраховуємо доплату до 2100, тільки для періодів з 01.03.2022
        npt_id = 815 npt_code='998'
        Формула для розрахунку:
        Якщо «2100» «мінус» «npt_id = 1 npt_code='169'» «мінус» «npt_id = 308 npt_code='995'» «мінус» npt_id =  195 (npt_code='986') >0, то різниця є npt_id = 815 npt_code='998'
        Відповідно в рішенні в деталізації виплати npt_id = 815 npt_code='998' має відображатися лише сума npt_id = 815 npt_code='998'
        */
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
               WHERE tdc_npt IN (1, 180, 195) --AND tdc_sub_npt IS NULL
                                              AND xpd_calc_alg = 'INV_BY_LGW'
              HAVING SUM (tdc_value) < nmp_min_sum        --#79928  2022.09.08
            GROUP BY tc_sc,
                     tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     nmp_min_sum,
                     NMP_NPT                  /*, tc_inv_state, tc_inv_group*/
                            ;



        SaveMessage (
            'Визначається розмір підвищення дітям, які постраждали від ВНП)');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt,
                                        tdc_sub_npt)
              SELECT 223,
                     223,
                     'Підвищення дітям, які постраждали від ВНП)',
                     tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     SUM (tdc_value) * 0.5,
                     --469, 1
                     1,
                     469
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
               WHERE     tdc_npt IN (1, 180, 815)
                     AND tdc_sub_npt IS NULL
                     AND xpd_calc_alg = 'INV_BY_LGW'
                     AND tc_is_child_inv_reason = 'EXPLOSE'
                     AND tc_start_dt >= TO_DATE ('01.07.2022', 'dd.mm.yyyy')
            GROUP BY tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt;


        /*
        в атрибуті з Ід=8427 "Підвищення дітям війни" - "ТАК" тим особам, яким у деталях рішення з джерелом АСОПД, призначено тип виплати
          184  npt_code=260 "ПІДВИЩЕННЯ ДІТЯМ ВІЙНИ"
        в атрибуті з Ід=8428 "Підвищення жертвам нацистських переслідувань" - "ТАК" тим особам, яким у деталях рішення з джерелом АСОПД, призначено тип виплати
          245  npt_code=250 ПІДВ.КОЛИШ.ВЯЗНЯМ КОНЦТ.,ІН.МІСЦЬ ТРИМАННЯ СТ6(3)
        в атрибуті з Ід=8429 "Підвищення ветеранам війни" - "ТАК" тим особам, яким у деталях рішення з джерелом АСОПД, призначено тип виплати
          235 npt_code=249 ПІДВИЩ. УЧАСНИКАМ ВІЙНИ
        */


        SaveMessage (
            'Визначається розмір "Підвищення жертвам нацистських переслідувань"');
        SaveMessage ('Визначається розмір "Підвищення ветеранам війни"');
    /*

        INSERT INTO tmp_pd_detail_calc (tdc_ndp, tdc_row_order, tdc_key, tdc_pd, tdc_start_dt, tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value, tdc_npt, tdc_sub_npt)
          SELECT 294, 294, tdc_key, tdc_pd, tdc_start_dt, tdc_stop_dt,
                 CHR(38)||'152#'||uss_person.api$sc_tools.get_pib(tc_sc) AS x_row_name,
                 SUM(tdc_value) * 0.2 AS x_value, 1 AS x_NPT, 288 AS x_sub_npt
          FROM tmp_pd_detail_calc
            JOIN tmp_calc_app_params tc ON nvl(tc_pdf,0) = nvl(tdc_key,0) AND tc_pd = tdc_pd AND tc_start_dt = tdc_start_dt
          WHERE tdc_npt IN (219, 176, 48, 180, 195, 469 , 815)
            AND tc.tc_mountain_village = 'T'
          GROUP BY  tdc_key, tdc_pd, tdc_start_dt, tdc_stop_dt, tc_sc;
    */
    /*
    EXPLOSE
    'Визначається розмір підвищення дітям, які постраждали від ВНП);
    SELECT * FROM uss_ndi.v_ndi_payment_type WHERE npt_id = 469

    1. Суму підвищення npt_id = 469 необхідно розраховувати для дітей віком до 18 років (вік визначається за одним із документів з категорією 13) для яких в документі «Медичний висновок (для дітей з інвалідністю до 18 років)» в атрибуті «Причина» вибрано причину «від вибухонебезпечних предметів поранення чи інше ушкодження».
    2. Підвищення розраховувати з дати звернення але не раніше ніж з 01.07.2022.
    Розраховувати на весь термін інвалідності але не більш ніж по дату досягнення дитиною 18 років
    3. Розрахунок:
    Розрахунок підвищення з npt_id = 469 (формула по npt_id):
    469=(219+176+48+180)*50%

    Розрахунок підвищення з npt_ code = 469 (формула по npt_ code):
    223=(129+291+290+995)*50%

    4. Підвищення дітям, які постраждали від ВНП npt_id = 469 включається в розмір npt_id = 1 (npt_ code=’169’)

    5. Під час опису в деталізації npt_id = 469 застосовувати такі записи:
    */

    END;

    --=========================================================--
    --Розраховуємо суму допомоги для декретна відпустка
    PROCEDURE COMPUTE_BY_MATERNITY_LEAVE
    IS
    BEGIN
        SAVEMESSAGE ('Розраховуємо суму допомоги для декретна відпустка');

        INSERT INTO TMP_PD_DETAIL_CALC (TDC_NDP,
                                        TDC_ROW_ORDER,
                                        TDC_ROW_NAME,
                                        TDC_KEY,
                                        TDC_PD,
                                        TDC_START_DT,
                                        TDC_STOP_DT,
                                        TDC_VALUE,
                                        TDC_NPT)
            WITH
                LESHA
                AS
                    (SELECT    'Допомога для '
                            || USS_PERSON.API$SC_TOOLS.GET_PIB (TC_SC)
                                AS X_TEXT,
                            TD_PDF,
                            TD_PD,
                            TD_BEGIN,
                            TD_END,
                            TC_NPT,
                            TC_INCOME,
                            LGW_WORK_ABLE_SUM,
                            CASE
                                WHEN    LAST_DAY (TD_BEGIN) = TD_END
                                     OR TD_BEGIN = TRUNC (TD_END, 'MM')
                                THEN
                                    'DAYS'
                                WHEN TRUNC (TD_BEGIN, 'MM') =
                                     TRUNC (TD_END, 'MM')
                                THEN
                                    'DAYS'
                                ELSE
                                    'MONTHS'
                            END
                                AS X_CNT_TP,
                            CASE
                                WHEN    LAST_DAY (TD_BEGIN) = TD_END
                                     OR TD_BEGIN = TRUNC (TD_END, 'MM')
                                THEN
                                    TD_END - TD_BEGIN + 1
                                WHEN TRUNC (TD_BEGIN, 'MM') =
                                     TRUNC (TD_END, 'MM')
                                THEN
                                    TD_END - TD_BEGIN + 1
                                ELSE
                                    NULL
                            END
                                AS X_CNT_DAYS,
                            CASE
                                WHEN    LAST_DAY (TD_BEGIN) = TD_END
                                     OR TD_BEGIN = TRUNC (TD_END, 'MM')
                                THEN
                                    NULL
                                ELSE
                                    ABS (
                                        MONTHS_BETWEEN (TD_BEGIN, TD_END + 1))
                            END
                                AS X_CNT_MONTHS,
                            CASE
                                WHEN    LAST_DAY (TD_BEGIN) = TD_END
                                     OR TD_BEGIN = TRUNC (TD_END, 'MM')
                                THEN
                                      LAST_DAY (TD_BEGIN)
                                    - TRUNC (TD_BEGIN, 'MM')
                                    + 1
                                WHEN TRUNC (TD_BEGIN, 'MM') =
                                     TRUNC (TD_END, 'MM')
                                THEN
                                      LAST_DAY (TD_BEGIN)
                                    - TRUNC (TD_BEGIN, 'MM')
                                    + 1
                                ELSE
                                    NULL
                            END
                                AS X_CNT_DAY_IN_MONTHS,
                            --api$account.get_docx_string(tc_pd, tc_sc,10198,4361, tc_calc_dt,'-'),
                             (SELECT CASE api$account.get_docx_string (
                                              tc_pd,
                                              tc_sc,
                                              10198,
                                              4361,
                                              tc_calc_dt,
                                              '-')
                                         WHEN 'P_2_ST_6' THEN NDV_VALUE2
                                         WHEN 'PART_ONE' THEN NDV_VALUE1
                                         WHEN 'PART_TWO' THEN 0
                                         WHEN 'P_3_ST_22' THEN NDV_VALUE1
                                         WHEN 'P_3_ST_23' THEN NDV_VALUE2
                                         WHEN 'P_4_ST_7' THEN NDV_VALUE1
                                         WHEN 'ANOTHER' THEN 0
                                         ELSE 0
                                     END    AS x_value
                                FROM uss_ndi.V_NDI_DEC_VALUES dic
                               WHERE     dic.ndv_nds = 1
                                     AND TC_START_DT BETWEEN dic.ndv_start_dt
                                                         AND NVL (
                                                                 dic.ndv_stop_dt,
                                                                 TO_DATE (
                                                                     '31.12.3000',
                                                                     'dd.mm.yyyy'))
                                     AND dic.history_status = 'A')
                                AS XX_WORK_ABLE_SUM
                       FROM TMP_TAR_DATES,
                            TMP_PD_CALC_PARAMS,
                            TMP_CALC_APP_PARAMS,
                            USS_NDI.V_NDI_LIVING_WAGE
                      WHERE     TD_PD = XPD_ID
                            AND TD_PDF = TC_PDF
                            AND TD_BEGIN = TC_START_DT
                            AND XPD_CALC_ALG = 'MATERNITY'
                            AND HISTORY_STATUS = 'A'
                            AND TD_BEGIN >= LGW_START_DT
                            AND (   TD_BEGIN <= LGW_STOP_DT
                                 OR LGW_STOP_DT IS NULL))
            SELECT 500,
                   500,
                   X_TEXT,
                   TD_PDF,
                   TD_PD,
                   TD_BEGIN,
                   TD_END,
                   CASE
                       WHEN TC_NPT IN (831)
                       THEN
                           CASE X_CNT_TP
                               WHEN 'DAYS'
                               THEN
                                     XX_WORK_ABLE_SUM
                                   / X_CNT_DAY_IN_MONTHS
                                   * X_CNT_DAYS
                               ELSE
                                   XX_WORK_ABLE_SUM * X_CNT_MONTHS
                           END
                       WHEN     TC_NPT IN (830                       /*, 831*/
                                              , 832)
                            AND LGW_WORK_ABLE_SUM * 0.25 < TC_INCOME
                       THEN
                           CASE X_CNT_TP
                               WHEN 'DAYS'
                               THEN
                                     TC_INCOME
                                   / X_CNT_DAY_IN_MONTHS
                                   * X_CNT_DAYS
                               ELSE
                                   TC_INCOME * X_CNT_MONTHS
                           END
                       WHEN TC_NPT IN (830                           /*, 831*/
                                          , 832)
                       THEN
                           CASE X_CNT_TP
                               WHEN 'DAYS'
                               THEN
                                     LGW_WORK_ABLE_SUM
                                   * 0.25
                                   / X_CNT_DAY_IN_MONTHS
                                   * X_CNT_DAYS
                               ELSE
                                   LGW_WORK_ABLE_SUM * 0.25 * X_CNT_MONTHS
                           END
                       ELSE
                           CASE X_CNT_TP
                               WHEN 'DAYS'
                               THEN
                                     LGW_WORK_ABLE_SUM
                                   * 0.25
                                   / X_CNT_DAY_IN_MONTHS
                                   * X_CNT_DAYS
                               ELSE
                                   LGW_WORK_ABLE_SUM * 0.25 * X_CNT_MONTHS
                           END
                   END    AS S,
                   /*NULL AS*/
                   TC_NPT
              FROM LESHA;

        SAVEMESSAGE (
            'Розраховуємо Підвищення за проживання в гірському населеному пункті');

        INSERT INTO TMP_PD_DETAIL_CALC (TDC_NDP,
                                        TDC_ROW_ORDER,
                                        TDC_KEY,
                                        TDC_PD,
                                        TDC_START_DT,
                                        TDC_STOP_DT,
                                        TDC_ROW_NAME,
                                        TDC_VALUE,
                                        TDC_NPT,
                                        TDC_SUB_NPT)
            SELECT 296,
                   296,
                   TDC_KEY,
                   TDC_PD,
                   TDC_START_DT,
                   TDC_STOP_DT,
                      CHR (38)
                   || '152#'
                   || USS_PERSON.API$SC_TOOLS.GET_PIB (TC_SC)
                       AS X_ROW_NAME,
                   TDC_VALUE * 0.2
                       AS X_VAL,
                   --37 AS X_NPT,
                   TC_NPT
                       AS X_NPT,
                   850
                       AS X_SUB_NPT
              FROM TMP_PD_DETAIL_CALC
                   JOIN TMP_CALC_APP_PARAMS TC
                       ON     NVL (TC_PDF, 0) = NVL (TDC_KEY, 0)
                          AND TC_PD = TDC_PD
                          AND TC_START_DT = TDC_START_DT
             WHERE TDC_NDP = 500 AND TC.TC_MOUNTAIN_VILLAGE = 'T';

        NULL;
    END;

    --=========================================================--
    --Розрахунок допомоги на дітей з багатодітної сім_ї
    PROCEDURE COMPUTE_BY_6YEARS
    IS
    BEGIN
        SaveMessage (
            'Розраховуємо суму допомоги на дітей з багатодітної сім''ї');

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
                      --CHR(38)||nncs_nmt||'#'||uss_person.api$sc_tools.get_pib(tc_sc)||'#'||to_char(tc_birth_dt, 'DD.MM.YYYY'),
                      'Допомога на дітей, які виховуються у багатодітних сім''ях ('
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')
                   || ')'    AS x_txt,
                   CASE
                       WHEN tc_child_number < 3
                       THEN
                           0
                       WHEN tc_start_dt BETWEEN TRUNC (tc_birth_dt, 'MM')
                                            AND   ADD_MONTHS (tc_birth_dt,
                                                              72)
                                                - 1
                       THEN
                           nncs_sum
                       ELSE
                           0
                   END       AS nncs_sum,
                   NULL      AS nncs_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_nst_const_sum
             WHERE     td_pd = xpd_id
                   AND td_begin = tc_start_dt
                   AND tc_tp = 'FP'
                   AND xpd_calc_alg = '6YEARS'
                   AND td_pd = tc_pd
                   AND td_pdf = tc_pdf
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A3'
                   AND nncs_period_tp = 'ORI';

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
              SELECT 511,
                     511,
                     'Сума допомоги',
                     tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt,
                     SUM (tdc_value),
                     838
                FROM tmp_pd_calc_params
                     JOIN tmp_tar_dates ON td_pd = xpd_id
                     JOIN tmp_calc_app_params
                         ON     tc_pd = td_pd
                            AND tc_start_dt = td_begin
                            AND tc_tp = 'Z'
                     JOIN tmp_pd_detail_calc
                         ON     tdc_pd = td_pd
                            AND tdc_key = td_pdf
                            AND tdc_start_dt = td_begin
               WHERE tdc_ndp IN (510) AND xpd_calc_alg = '6YEARS'
            GROUP BY tc_pdf,
                     tc_pd,
                     tdc_start_dt,
                     tdc_stop_dt;                         --#79928  2022.09.08
    END;

    --=========================================================--
    --Розраховуємо суму допомоги для прийомна сім'я
    PROCEDURE COMPUTE_BY_FOSTER_FM
    IS
    BEGIN
        --Грошове забезпечення прийомним батькам
        --Грошове забезпечення батькам - вихователям
        --Державна соціальна допомога дітям-сиротам, дітям позбавленим батьківського піклування.
        /*
                     WHEN 275 THEN
                              CASE
                              WHEN tpp.tpp_app_tp = 'Z'   AND API$ACCOUNT.get_docx_string(xpd_id, tpp_sc, 605, 2654 , xpd_calc_dt, 'F') = 'T' THEN 835 --515
                              WHEN tpp.tpp_app_tp = 'Z'   AND API$ACCOUNT.get_docx_string(xpd_id, tpp_sc, 605, 1858 , xpd_calc_dt, 'F') = 'T' THEN 836 --516
                              WHEN tpp.tpp_app_tp = 'ANF' AND API$ACCOUNT.get_docx_string(xpd_id, tpp_sc, 605, 1858 , xpd_calc_dt, 'F') = 'T' THEN 836 --516
                              WHEN tpp.tpp_app_tp = 'FP' THEN 837 --517
                              END
        */
        -- Утриманцям, яким встановлено інвалідність (у зверненні додано документ "Виписка з акту огляду МСЕК" NDT_ID 201 або
        --"Медичний висновок (для дітей з інвалідністю до 18 років)" NDT_ID 200), державна соціальна допомога (код виплати Npt_code 517)
        --призначається до досягнення ними 23-річного віку.
        -- Але не пізніше ніж дата (атрибут NDA_ID 793 - "Встановлено на період до"), зазначена в документі (NDT_ID 200- Медичний висновок
        --(для дітей з інвалідністю до 18 років).
        --#96381
        SaveMessage ('Розраховуємо суму допомоги для прийомна сім''я');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 521,
                   521,
                      --#74301 2021.12.22
                      'Державна соціальна допомога '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                     (    CASE
                              WHEN     tc_start_dt >= tc_birth_dt
                                   AND tc_start_dt <
                                       ADD_MONTHS (tc_birth_dt, 72)
                              THEN
                                  w.lgw_6year_sum
                              WHEN     tc_start_dt >=
                                       ADD_MONTHS (tc_birth_dt, 72)
                                   AND tc_start_dt <
                                       ADD_MONTHS (tc_birth_dt, 216)
                              THEN
                                  w.lgw_18year_sum
                              WHEN     tc_start_dt >=
                                       ADD_MONTHS (tc_birth_dt, 12 * 18)
                                   AND tc_start_dt <
                                       ADD_MONTHS (tc_birth_dt, 12 * 23)
                                   AND tc_start_dt < tc_study_stop_dt
                              THEN
                                  w.lgw_work_able_sum
                              WHEN     tc_start_dt >=
                                       ADD_MONTHS (tc_birth_dt, 12 * 18)
                                   AND tc_start_dt <
                                       ADD_MONTHS (tc_birth_dt, 12 * 23)
                                   AND tc_start_dt < tc_inv_stop_dt
                              THEN
                                  w.lgw_work_able_sum
                          END
                        * CASE
                              WHEN     tc_inv_state IN ('DI', 'IZ')
                                   AND tc_start_dt < tc_inv_stop_dt
                              THEN
                                  3.5
                              ELSE
                                  2.5
                          END
                      - tc_income)
                   * tc_koef_value                           AS s,
                   /*NULL AS*/
                   tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage  w
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   AND tc_npt IN (837)                               -- #97825
                   AND history_Status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND tc_koef_value > 0;

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 521,
                   521,
                      --#74301 2021.12.22
                      'Державна соціальна допомога '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                     (    CASE
                              WHEN     tc_start_dt >= tc_birth_dt
                                   AND tc_start_dt <
                                       ADD_MONTHS (tc_birth_dt, 72)
                              THEN
                                  w.lgw_6year_sum
                              WHEN     tc_start_dt >=
                                       ADD_MONTHS (tc_birth_dt, 72)
                                   AND tc_start_dt <
                                       ADD_MONTHS (tc_birth_dt, 216)
                              THEN
                                  w.lgw_18year_sum
                              WHEN     tc_start_dt >=
                                       ADD_MONTHS (tc_birth_dt, 12 * 18)
                                   AND tc_start_dt <
                                       ADD_MONTHS (tc_birth_dt, 12 * 23)
                                   AND tc_start_dt < tc_study_stop_dt
                              THEN
                                  w.lgw_work_able_sum
                          END
                        * CASE
                              WHEN     tc_inv_state = 'DI'
                                   AND tc_start_dt < tc_inv_stop_dt
                              THEN
                                  3.5
                              ELSE
                                  2.5
                          END
                      - tc_income)
                   * tc_koef_value                           AS s,
                   /*NULL AS*/
                   tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage  w
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   AND tc_npt IN (840)                               -- #97825
                   AND history_Status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND tc_koef_value > 0
                   AND tc_start_dt < TO_DATE ('01.07.2024', 'dd.mm.yyyy')
            UNION ALL
            SELECT 521,
                   521,
                      --#74301 2021.12.22
                      'Державна соціальна допомога '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                     (  CASE
                            WHEN     tc_start_dt >= tc_birth_dt
                                 AND tc_start_dt <
                                     ADD_MONTHS (tc_birth_dt, 72)
                            THEN
                                w.lgw_6year_sum
                            WHEN     tc_start_dt >=
                                     ADD_MONTHS (tc_birth_dt, 72)
                                 AND tc_start_dt <
                                     ADD_MONTHS (tc_birth_dt, 216)
                            THEN
                                w.lgw_18year_sum
                            WHEN     tc_start_dt >=
                                     ADD_MONTHS (tc_birth_dt, 12 * 18)
                                 AND tc_start_dt <
                                     ADD_MONTHS (tc_birth_dt, 12 * 23)
                                 AND tc_start_dt < tc_study_stop_dt
                            THEN
                                w.lgw_work_able_sum
                        END
                      * CASE
                            WHEN     tc_inv_state = 'DI'
                                 AND tc_start_dt < tc_inv_stop_dt
                            THEN
                                3.5
                            ELSE
                                2.5
                        END--             - tc_income
                           )
                   * tc_koef_value                           AS s,
                   /*NULL AS*/
                   tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage  w
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   AND tc_npt IN (840)                               -- #97825
                   AND history_Status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND tc_koef_value > 0
                   AND tc_start_dt >= TO_DATE ('01.07.2024', 'dd.mm.yyyy');

        DELETE FROM tmp_pd_detail_calc
              WHERE    tdc_npt IN (837, 840) AND tdc_value = 0
                    OR tdc_value IS NULL;

        UPDATE tmp_pd_detail_calc
           SET tdc_value = 0
         WHERE tdc_npt IN (837, 840                                    /*839*/
                                   )                                 -- #97825
                                     AND tdc_value < 0;

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 522,
                   522,
                      --#74301 2021.12.22
                      'Грошове забезпечення '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')
                       AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   w.lgw_work_able_sum * tc_child_number * tc_koef_value
                       AS s,
                   /*NULL AS*/
                   tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage  w
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   AND tc_npt IN (835, 836)
                   AND history_Status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND tc_koef_value > 0
                   AND COALESCE (tc_child_number, 0) > 0;

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 521,
                   521,
                      --#74301 2021.12.22
                      'Державна соціальна допомога '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                     (  CASE
                            WHEN     tc_start_dt >= tc_birth_dt
                                 AND tc_start_dt <
                                     ADD_MONTHS (tc_birth_dt, 72)
                            THEN
                                w.lgw_6year_sum
                            WHEN     tc_start_dt >=
                                     ADD_MONTHS (tc_birth_dt, 72)
                                 AND tc_start_dt <
                                     ADD_MONTHS (tc_birth_dt, 216)
                            THEN
                                w.lgw_18year_sum
                            WHEN     tc_start_dt >=
                                     ADD_MONTHS (tc_birth_dt, 12 * 18)
                                 AND tc_start_dt <
                                     ADD_MONTHS (tc_birth_dt, 12 * 23)
                                 AND tc_start_dt < tc_study_stop_dt
                            THEN
                                w.lgw_work_able_sum
                        END
                      * CASE
                            WHEN     tc_inv_state = 'DI'
                                 AND tc_start_dt < tc_inv_stop_dt
                            THEN
                                3.5
                            ELSE
                                2.5
                        END)
                   * tc_koef_value                           AS s,
                   /*NULL AS*/
                   tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage  w
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   AND tc_npt IN (21)                               -- #103390
                   AND history_Status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND tc_koef_value > 0;

        /*
        - Статус інвалідності (NDA_ID 1789) або "Дитина з інвалідністю" (NDA_ID 2661):
        - Дитина віком до одного року (NDA_ID 2663)
        - Малолітня або неповнолітня вагітна (NDA_ID 2663)
        - ВІЛ-інфікована дитина (NDA_ID 2665)
        */

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 522,
                   522,
                      --#74301 2021.12.22
                      'Грошове забезпечення '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                     (w.lgw_work_able_sum * 5)
                   *                                            --базова сумма
                     (CASE
                          WHEN tc_child_cnt = 0
                          THEN
                              0
                          WHEN tc_child_cnt = 1 AND tc_child_cnt_plus10 > 0
                          THEN
                              1 + 0.1
                          WHEN tc_child_cnt = 1
                          THEN
                              1
                          WHEN tc_child_cnt <= 5
                          THEN
                              1 + 0.1 * tc_child_cnt
                          ELSE
                              1.5
                      END)                                   AS s, --підвищення в залежності від кількості дітей
                   /*NULL AS*/
                   tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.v_ndi_living_wage  w
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   --AND tc_npt IN (840) -- #97825
                   AND tc_npt IN (839)                               -- #97825
                   AND history_Status = 'A'
                   AND td_begin >= lgw_start_dt
                   AND (td_begin <= lgw_stop_dt OR lgw_stop_dt IS NULL)
                   AND tc_start_dt < TO_DATE ('01.07.2024', 'dd.mm.yyyy')
            UNION ALL
            SELECT 522,
                   522,
                      --#74301 2021.12.22
                      'Грошове забезпечення '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                     (  m.nmz_month_sum
                      * (CASE tc_is_fop WHEN 'T' THEN 3.5 ELSE 3 END))
                   *                                            --базова сумма
                     (CASE
                          WHEN tc_child_cnt = 0
                          THEN
                              0
                          WHEN tc_child_cnt = 1 AND tc_child_cnt_plus10 > 0
                          THEN
                              1 + 0.1
                          WHEN tc_child_cnt = 1
                          THEN
                              1
                          WHEN tc_child_cnt = 2 AND tc_child_cnt_plus10 > 0
                          THEN
                              1 + 0.1
                          WHEN tc_child_cnt = 2
                          THEN
                              1
                          --WHEN tc_child_number <= 5 THEN 1 + 0.1 * tc_child_number
                          --ELSE 1.5
                          ELSE
                              1 + 0.1 * tc_child_cnt
                      END)                                   AS s, --підвищення в залежності від кількості дітей
                   /*NULL AS*/
                   tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.V_NDI_MIN_ZP  m
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   --AND tc_npt IN (840) -- #97825
                   AND tc_npt IN (839)                               -- #97825
                   AND history_Status = 'A'
                   AND td_begin >= m.nmz_start_dt
                   AND (td_begin <= m.nmz_stop_dt OR m.nmz_stop_dt IS NULL)
                   AND tc_start_dt >= TO_DATE ('01.07.2024', 'dd.mm.yyyy')
                   AND tc_start_dt < TO_DATE ('01.01.2025', 'dd.mm.yyyy')
            ----------------------------
            UNION ALL
            SELECT 522,
                   522,
                      --#113765
                      'Грошове забезпечення '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')                AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                     (  m.nmz_month_sum
                      * (CASE tc_is_fop WHEN 'T' THEN 3 ELSE 3 END))
                   *                                            --базова сумма
                     (CASE
                          WHEN tc_child_cnt = 0
                          THEN
                              0
                          WHEN tc_child_cnt = 1 AND tc_child_cnt_plus10 > 0
                          THEN
                              1 + 0.1
                          WHEN tc_child_cnt = 1
                          THEN
                              1
                          WHEN tc_child_cnt = 2 AND tc_child_cnt_plus10 > 0
                          THEN
                              1 + 0.1
                          WHEN tc_child_cnt = 2
                          THEN
                              1
                          ELSE
                              1 + 0.1 * tc_child_cnt
                      END)                                               AS s, --підвищення в залежності від кількості дітей
                   (CASE tc_is_fop WHEN 'T' THEN 896 ELSE tc_npt END)    AS tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.V_NDI_MIN_ZP  m
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   AND tc_npt IN (839)                               -- #97825
                   AND history_Status = 'A'
                   AND td_begin >= m.nmz_start_dt
                   AND (td_begin <= m.nmz_stop_dt OR m.nmz_stop_dt IS NULL)
                   AND tc_start_dt >= TO_DATE ('01.01.2025', 'dd.mm.yyyy')
            ----------------------------
            UNION ALL                                               -- #105633
            SELECT 522,
                   522,
                      'Грошове забезпечення '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   CASE
                       WHEN td_begin < TO_DATE ('01.01.2025', 'dd.mm.yyyy')
                       THEN
                           m.nmz_month_sum
                       WHEN tc_subtp = '40'
                       THEN
                           m.nmz_month_sum
                       WHEN tc_subtp = '24'
                       THEN
                           m.nmz_month_sum * 24 / 40
                       ELSE
                           0
                   END                                       AS s,
                   /*NULL AS*/
                   tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.V_NDI_MIN_ZP  m
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   AND tc_npt IN (854)                              -- #105633
                   AND history_Status = 'A'
                   AND td_begin >= m.nmz_start_dt
                   AND (td_begin <= m.nmz_stop_dt OR m.nmz_stop_dt IS NULL);


        --TC_DEATH_SUM N NUMBER(18,2) Y   N N  Базова сума допомоги на поховання


        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            SELECT 522,
                   522,
                      --#112997
                      'Грошове забезпечення за накопичені дні '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   m.nmz_month_sum                           AS s,
                   875                                       AS x_tc_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_calc_app_params,
                   uss_ndi.V_NDI_MIN_ZP  m
             WHERE     td_pd = xpd_id
                   AND td_pdf = tc_pdf
                   AND td_begin = tc_start_dt
                   AND xpd_calc_alg = 'FOSTER_FM'
                   AND tc_npt IN (856)
                   AND history_Status = 'A'
                   AND td_begin >= m.nmz_start_dt
                   AND (td_begin <= m.nmz_stop_dt OR m.nmz_stop_dt IS NULL)
                   AND tc_subtp = 'ANF'
            UNION ALL
            SELECT 522,
                   522,
                      --#112997
                      'Грошове забезпечення за накопичені дні '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                   xpd.xpd_prev_summ                         AS s,
                   tc_npt
              FROM tmp_tar_dates
                   JOIN tmp_pd_calc_params xpd ON td_pd = xpd_id
                   JOIN tmp_calc_app_params tc
                       ON tc_pdf = td_pdf AND tc_start_dt = td_begin
             WHERE     xpd_calc_alg = 'FOSTER_FM'
                   AND tc_npt IN (856)
                   AND tc_subtp = 'Z';


        --856
        /*
        В разі якщо в зверненні за послугою з Ід=275 прикріплено документ з Ід=92 (Документи про надання статусу особи (гірський нас. пункт):
        1. до учасника звернення з типом "заявник", то під час обчислення розміру допомоги необхідно розраховувати надбавку з npt_id=847 (ПІДВ.П-РАМ,ЩО ПРОЖИВАЮТЬ В ГІРСЬКИХ НАСЕЛ. ПУНКТАХ) для виплат цього виду допомоги (npt_id=836) Грошове забезпечення батькам-вихователям
        npt_id=847 становить 20% від суми розрахованої по npt_id=836
        В деталях рішення необхідно зазначати розрахований розмір допомоги по npt_id=836 для заяника та підвишення по npt_id=847 для нього.
        В самому рішенні необхідно зазначати загальну суму грошового забезпечення по npt_id=836, яка дорівнює npt_id=836 (без надбавки) + npt_id=847 (від npt_id=836)

        2. до учасника звернення з типом "заявник", то під час обчислення розміру допомоги необхідно розраховувати надбавку з npt_id=847 (ПІДВ.П-РАМ,ЩО ПРОЖИВАЮТЬ В ГІРСЬКИХ НАСЕЛ. ПУНКТАХ) для виплат цього виду допомоги (npt_id=835) Грошове забезпечення прийомному батьку (матері)
        npt_id=847 становить 20% від суми розрахованої по npt_id=835
        В деталях рішення необхідно зазначати розрахований розмір допомоги по npt_id=835 для заяника та підвишення по npt_id=847 для нього.
        В самому рішенні необхідно зазначати загальну суму грошового забезпечення по npt_id=835, яка дорівнює npt_id=835 (без надбавки) + npt_id=847 (від npt_id=835)

        3. до учасника звернення з типом "утриманець", то під час обчислення розміру допомоги необхідно розраховувати надбавку з npt_id=847 (ПІДВ.П-РАМ,ЩО ПРОЖИВАЮТЬ В ГІРСЬКИХ НАСЕЛ. ПУНКТАХ) для виплат цього виду допомоги (npt_id=837) Державна соціальна допомога дітям-сиротам, дітям позбавленим батьківського піклування
        npt_id=847 становить 20% від суми розрахованої по npt_id=837
        В деталях рішення необхідно зазначати розрахований розмір допомоги по npt_id=837 для заяника та підвишення по npt_id=847 для нього.
        В самому рішенні необхідно зазначати загальну суму грошового забезпечення по npt_id=837, яка дорівнює npt_id=837 (без надбавки) + npt_id=847 (від npt_id=837)

        */
        SAVEMESSAGE (
            'Розраховуємо Підвищення за проживання в гірському населеному пункті');

        INSERT INTO TMP_PD_DETAIL_CALC (TDC_NDP,
                                        TDC_ROW_ORDER,
                                        TDC_KEY,
                                        TDC_PD,
                                        TDC_START_DT,
                                        TDC_STOP_DT,
                                        TDC_ROW_NAME,
                                        TDC_VALUE,
                                        TDC_NPT,
                                        TDC_SUB_NPT)
            SELECT 294,
                   294,
                   TDC_KEY,
                   TDC_PD,
                   TDC_START_DT,
                   TDC_STOP_DT,
                      CHR (38)
                   || '152#'
                   || USS_PERSON.API$SC_TOOLS.GET_PIB (TC_SC)
                       AS X_ROW_NAME,
                   TDC_VALUE * 0.2
                       AS X_VAL,
                   --836 AS X_NPT,
                   TC_NPT
                       AS X_NPT,
                   847
                       AS X_SUB_NPT
              FROM TMP_PD_DETAIL_CALC
                   JOIN TMP_CALC_APP_PARAMS TC
                       ON     NVL (TC_PDF, 0) = NVL (TDC_KEY, 0)
                          AND TC_PD = TDC_PD
                          AND TC_START_DT = TDC_START_DT
             WHERE TC_NPT IN (835, 836, 837)                   --TDC_NDP = 522
                                             AND TC.TC_MOUNTAIN_VILLAGE = 'T';

        --895 1020 Сплата ЄСВ на ЗДСС патронатного вихователя
        --#113765

        SAVEMESSAGE (
            'Розраховуємо "Сплата ЄСВ на ЗДСС патронатного вихователя"');

        INSERT INTO TMP_PD_DETAIL_CALC (TDC_NDP,
                                        TDC_ROW_ORDER,
                                        TDC_KEY,
                                        TDC_PD,
                                        TDC_START_DT,
                                        TDC_STOP_DT,
                                        TDC_ROW_NAME,
                                        TDC_VALUE,
                                        TDC_NPT                --, TDC_SUB_NPT
                                               )
            SELECT 297,
                   297,
                   TDC_KEY,
                   TDC_PD,
                   TDC_START_DT,
                   TDC_STOP_DT,
                      CHR (38)
                   || '155#'
                   || USS_PERSON.API$SC_TOOLS.GET_PIB (TC_SC)
                       AS X_ROW_NAME,
                   TDC_VALUE * 0.22
                       AS X_VAL,
                   --TC_NPT AS X_NPT,
                   --895 AS X_SUB_NPT
                   895
                       AS X_NPT
              FROM TMP_PD_DETAIL_CALC
                   JOIN TMP_CALC_APP_PARAMS TC
                       ON     NVL (TC_PDF, 0) = NVL (TDC_KEY, 0)
                          AND TC_PD = TDC_PD
                          AND TC_START_DT = TDC_START_DT
             WHERE TDC_NPT IN (896);

        NULL;
    END;

    --=========================================================--
    --Розраховуємо суму допомоги для прийомна сім'я
    PROCEDURE COMPUTE_BY_FOSTER_FM_7DAY
    IS
    BEGIN
        SaveMessage (
            'Розраховуємо суму допомоги для прийомна сім''я за 7 днів');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_row_name,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_value,
                                        tdc_npt)
            -- 7 днів
            SELECT 522,
                   522,
                      'Грошове забезпечення за 7 днів '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   tc_pdf,
                   tc_pd,
                   xpd.xpd_start_dt,
                   xpd.xpd_start_dt + 6,
                   m.nmz_month_sum                           AS s,
                   876                                       AS x_tc_npt
              FROM tmp_pd_calc_params  xpd
                   JOIN tmp_calc_app_params tc ON tc.tc_pd = xpd.xpd_id
                   JOIN uss_ndi.V_NDI_MIN_ZP m
                       ON     history_Status = 'A'
                          AND tc.tc_start_dt >= m.nmz_start_dt
                          AND (   tc.tc_start_dt <= m.nmz_stop_dt
                               OR m.nmz_stop_dt IS NULL)
             WHERE     xpd_calc_alg = 'FOSTER_FM7'
                   AND tc_tp = 'Z'
                   AND tc_subtp = 'ANF'
                   AND tc.tc_start_dt IS NOT NULL
                   AND ADD_MONTHS (xpd.xpd_prev_start_dt, 3) - 1 <=
                       xpd.xpd_prev_stop_dt
            UNION ALL
            SELECT 522,
                   522,
                      'Грошове забезпечення за 7 днів '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   tc_pdf,
                   tc_pd,
                   xpd.xpd_start_dt,
                   xpd.xpd_start_dt + 6,
                   xpd.xpd_prev_summ                         AS s,
                   855                                       AS x_tc_npt
              FROM tmp_pd_calc_params  xpd
                   JOIN tmp_calc_app_params tc ON tc.tc_pd = xpd.xpd_id
             WHERE     xpd_calc_alg = 'FOSTER_FM7'
                   AND tc_tp = 'Z'
                   AND tc_subtp = 'Z'
                   AND tc.tc_start_dt IS NOT NULL
                   AND ADD_MONTHS (xpd.xpd_prev_start_dt, 3) - 1 <=
                       xpd.xpd_prev_stop_dt
            UNION ALL
            -- місяць
            SELECT 522,
                   522,
                      'Грошова компенсація очікування '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   tc_pdf,
                   tc_pd,
                   xpd.xpd_start_dt + 7,
                   ADD_MONTHS (xpd.xpd_start_dt + 7, 1) - 1,
                   m.nmz_month_sum                           AS s,
                   857                                       AS x_tc_npt
              FROM tmp_pd_calc_params  xpd
                   JOIN tmp_calc_app_params tc ON tc.tc_pd = xpd.xpd_id
                   JOIN uss_ndi.V_NDI_MIN_ZP m
                       ON     history_Status = 'A'
                          AND tc.tc_start_dt >= m.nmz_start_dt
                          AND (   tc.tc_start_dt <= m.nmz_stop_dt
                               OR m.nmz_stop_dt IS NULL)
             WHERE     xpd_calc_alg = 'FOSTER_FM7'
                   AND tc_tp = 'Z'
                   AND tc_subtp = 'Z'
                   AND tc.tc_start_dt IS NOT NULL
                   AND ADD_MONTHS (xpd.xpd_prev_start_dt, 3) - 1 <=
                       xpd.xpd_prev_stop_dt
            UNION ALL
            SELECT 522,
                   522,
                      'Грошова компенсація очікування '
                   || uss_person.api$sc_tools.get_pib (tc_sc)
                   || ' дата народж. '
                   || TO_CHAR (tc_birth_dt, 'DD.MM.YYYY')    AS x_txt,
                   tc_pdf,
                   tc_pd,
                   xpd.xpd_start_dt,
                   ADD_MONTHS (xpd.xpd_start_dt, 1) - 1,
                   m.nmz_month_sum                           AS s,
                   857                                       AS x_tc_npt
              FROM tmp_pd_calc_params  xpd
                   JOIN tmp_calc_app_params tc ON tc.tc_pd = xpd.xpd_id
                   JOIN uss_ndi.V_NDI_MIN_ZP m
                       ON     history_Status = 'A'
                          AND tc.tc_start_dt >= m.nmz_start_dt
                          AND (   tc.tc_start_dt <= m.nmz_stop_dt
                               OR m.nmz_stop_dt IS NULL)
             WHERE     xpd_calc_alg = 'FOSTER_FM7'
                   AND tc_tp = 'Z'
                   AND tc_subtp = 'Z'
                   AND tc.tc_start_dt IS NOT NULL
                   AND NOT (ADD_MONTHS (xpd.xpd_prev_start_dt, 3) - 1 <=
                            xpd.xpd_prev_stop_dt);
    END;

    --=========================================================--
    -- #98549
    --Розрахунок допомоги на поховання
    PROCEDURE COMPUTE_BY_DEAD
    IS
    BEGIN
        SaveMessage (
            'Розраховуємо суму допомоги як подвійний розмір допомоги на місяць (для послуги 248)');

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
                   CASE
                       WHEN tc_death_sum IS NULL
                       THEN
                              'Призначено допомогу на поховання '
                           || uss_person.api$sc_tools.get_pib (tc_sc)
                           || ' (вік '
                           || TRUNC (
                                    MONTHS_BETWEEN (tc_start_dt, tc_birth_dt)
                                  / 12,
                                  0)
                           || ', на дату смерті не має діючого рішення про допомогу)'
                       ELSE
                              'Призначено допомогу на поховання '
                           || uss_person.api$sc_tools.get_pib (tc_sc)
                           || ' (вік '
                           || TRUNC (
                                    MONTHS_BETWEEN (tc_start_dt, tc_birth_dt)
                                  / 12,
                                  0)
                           || ')'
                   END,
                   tc_death_sum * 2,
                   565
              FROM tmp_tar_dates, tmp_pd_calc_params, tmp_calc_app_params
             WHERE     td_begin = tc_start_dt
                   AND td_pdf = tc_pdf
                   AND td_pd = tc_pd
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'DEAD_SUM'
                   AND tc_tp = 'DP';
    /*
        SaveMessage('Розраховуємо Підвищення за проживання в гірському населеному пункті');
        INSERT INTO tmp_pd_detail_calc (tdc_ndp, tdc_row_order, tdc_key, tdc_pd, tdc_start_dt, tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value, tdc_npt, tdc_sub_npt)
          SELECT 294, 294, tdc_key, tdc_pd, tdc_start_dt, tdc_stop_dt,
                 CHR(38)||'152#'||uss_person.api$sc_tools.get_pib(tc_sc) AS x_row_name,
                 tdc_value * 0.2 AS x_val, 37 AS x_npt, 844 AS x_sub_npt
          FROM tmp_pd_detail_calc
            JOIN tmp_calc_app_params tc ON nvl(tc_pdf,0) = nvl(tdc_key,0) AND tc_pd = tdc_pd AND tc_start_dt = tdc_start_dt
          WHERE tdc_ndp = 300
            AND tc.tc_mountain_village = 'T';
    */
    END;

    --=========================================================--
    -- #103769
    --Розрахунок "Новонароджена дитина"
    PROCEDURE COMPUTE_BY_NEWBORN
    IS
    BEGIN
        SaveMessage (
            'Одноразова допомога константою. Алгоритм А6. Період FST');

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
              FROM tmp_tar_dates       ma,
                   tmp_pd_calc_params  xpd,
                   tmp_pdf_calc_params,
                   uss_ndi.v_ndi_nst_const_sum
             WHERE     td_begin = (SELECT MIN (sl.td_begin)
                                     FROM tmp_tar_dates sl
                                    WHERE sl.td_pdf = ma.td_pdf)
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'NEWBORN'
                   AND td_pd = xpdf_pd
                   AND td_pdf = xpdf_id
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A6'
                   AND nncs_period_tp = 'FST'
                   AND EXISTS
                           (SELECT *
                              FROM tmp_calc_app_params tc
                             WHERE     tc.tc_pd = xpd_id
                                   AND tc.tc_child_newborn = 'T'
                                   AND tc.tc_pdf = td_pdf
                                   AND tc.tc_start_dt IS NULL)
                   AND xpd.xpd_prev_pd IS NULL;

        SaveMessage (
            'Підвищєня до одноразова допомога константою. Алгоритм А6. Період FST');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt,
                                        tdc_sub_npt)
            SELECT 294
                       AS x_ndp,
                   294
                       AS x_row_order,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      CHR (38)
                   || '152#'
                   || uss_person.api$sc_tools.get_pib (xpdf_sc)
                       AS x_row_name,
                   nncs_sum * 0.2,
                   nncs_npt,
                   846
                       AS x_sub_npt
              FROM tmp_tar_dates       ma,
                   tmp_pd_calc_params  xpd,
                   tmp_pdf_calc_params,
                   uss_ndi.v_ndi_nst_const_sum
             WHERE     td_begin = (SELECT MIN (sl.td_begin)
                                     FROM tmp_tar_dates sl
                                    WHERE sl.td_pdf = ma.td_pdf)
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'NEWBORN'
                   AND td_pd = xpdf_pd
                   AND td_pdf = xpdf_id
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A6'
                   AND nncs_period_tp = 'FST'
                   AND EXISTS
                           (SELECT 1
                              FROM pd_features
                             WHERE     pde_pd = td_pd
                                   AND pde_nft = 90
                                   AND pde_val_string = 'T')
                   AND EXISTS
                           (SELECT *
                              FROM tmp_calc_app_params tc
                             WHERE     tc.tc_pd = xpd_id
                                   AND tc.tc_child_newborn = 'T'
                                   AND tc.tc_pdf = td_pdf
                                   AND tc.tc_start_dt IS NULL)
                   AND xpd.xpd_prev_pd IS NULL;

        SaveMessage (
            'Щомісячна допомога константою. Алгоритм A6. Період NXM');

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
                   tmp_pd_calc_params  xpd,
                   tmp_pdf_calc_params,
                   uss_ndi.v_ndi_nst_const_sum
             --      WHERE td_begin >= ADD_MONTHS(TRUNC(xpd_ap_reg_dt, 'MM'), 1)
             WHERE     td_begin > xpd_start_dt
                   AND td_end > xpdf_birth_dt
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'NEWBORN'
                   AND td_pd = xpdf_pd
                   AND td_pdf = xpdf_id
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A6'
                   AND nncs_period_tp = 'NXM'
                   AND EXISTS
                           (SELECT *
                              FROM tmp_calc_app_params tc
                             WHERE     tc.tc_pd = xpd_id
                                   AND tc.tc_child_newborn = 'T'
                                   AND tc.tc_pdf = td_pdf
                                   AND tc.tc_start_dt IS NULL)
                   AND xpd.xpd_prev_pd IS NULL
            UNION ALL
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
                   tmp_pd_calc_params  xpd,
                   tmp_pdf_calc_params,
                   uss_ndi.v_ndi_nst_const_sum
             --      WHERE td_begin >= ADD_MONTHS(TRUNC(xpd_ap_reg_dt, 'MM'), 1)
             WHERE     td_begin >= xpd_start_dt
                   AND td_end >= xpdf_birth_dt
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'NEWBORN'
                   AND td_pd = xpdf_pd
                   AND td_pdf = xpdf_id
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A6'
                   AND nncs_period_tp = 'NXM'
                   AND EXISTS
                           (SELECT *
                              FROM tmp_calc_app_params tc
                             WHERE     tc.tc_pd = xpd_id
                                   AND tc.tc_child_newborn = 'T'
                                   AND tc.tc_pdf = td_pdf
                                   AND tc.tc_start_dt IS NULL)
                   AND xpd.xpd_prev_pd IS NOT NULL;

        SaveMessage (
            'Підвищєня до щомісячна допомога константою. Алгоритм A6. Період NXM');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt,
                                        tdc_sub_npt)
            SELECT 294
                       AS x_ndp,
                   294
                       AS x_row_order,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      CHR (38)
                   || '152#'
                   || uss_person.api$sc_tools.get_pib (xpdf_sc)
                       AS x_row_name,
                   nncs_sum * 0.2,
                   nncs_npt,
                   846
                       AS x_sub_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_pdf_calc_params,
                   uss_ndi.v_ndi_nst_const_sum
             WHERE     td_begin >=
                       ADD_MONTHS (TRUNC (xpd_ap_reg_dt, 'MM'), 1)
                   AND td_end > xpdf_birth_dt
                   AND td_pd = xpd_id
                   AND xpd_calc_alg = 'NEWBORN'
                   AND td_pd = xpdf_pd
                   AND td_pdf = xpdf_id
                   AND xpd_nst = nncs_nst
                   AND nncs_alg = 'A6'
                   AND nncs_period_tp = 'NXM'
                   AND EXISTS
                           (SELECT 1
                              FROM pd_features
                             WHERE     pde_pd = td_pd
                                   AND pde_nft = 90
                                   AND pde_val_string = 'T')
                   AND EXISTS
                           (SELECT *
                              FROM tmp_calc_app_params tc
                             WHERE     tc.tc_pd = xpd_id
                                   AND tc.tc_child_newborn = 'T'
                                   AND tc.tc_pdf = td_pdf
                                   AND tc.tc_start_dt IS NULL);
    END;

    --=========================================================--
    PROCEDURE Recalc_pd_payment
    IS
    BEGIN
        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1, x_id2, x_dt1)
            SELECT pdp.pdp_id, id_pd_payment (0) AS new_id, cp.xpd_start_dt
              FROM pd_payment  pdp
                   JOIN tmp_pd_calc_params cp
                       ON xpd_id = pdp_pd AND xpd_ic_tp = 'RC.START_DT'
             WHERE     pdp.pdp_start_dt < cp.xpd_start_dt
                   AND pdp.pdp_stop_dt > cp.xpd_start_dt
                   AND pdp.history_status = 'A';


        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                pdp_hs_ins,
                                history_status,
                                pdp_src)
            SELECT x_id2,
                   pdp.pdp_pd,
                   pdp.pdp_npt,
                   pdp.pdp_start_dt,
                   x_dt1 - 1,
                   pdp_sum,
                   g_hs,
                   'A',
                   'RC'
              FROM tmp_work_set1 JOIN pd_payment pdp ON pdp.pdp_id = x_id1;

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
            SELECT 0     AS x_pdd_id,
                   x_id2,
                   pdd_row_order,
                   pdd_row_name,
                   pdd_value,
                   pdd_key,
                   pdd_ndp,
                   pdd.pdd_start_dt,
                   x_dt1 - 1,
                   pdd_npt
              FROM tmp_work_set1 JOIN pd_detail pdd ON pdd.pdd_pdp = x_id1;

        UPDATE pd_payment pdp
           SET pdp.history_status = 'H', pdp.pdp_hs_del = g_hs
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set1
                     WHERE x_id1 = pdp_id);


        UPDATE uss_esr.PD_PAYMENT PDP
           SET PDP.HISTORY_STATUS = 'H', PDP.PDP_HS_DEL = g_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM uss_esr.TMP_PD_CALC_PARAMS zz
                         WHERE     XPD_ID = PDP_PD
                               AND XPD_IC_TP = 'RC.START_DT'
                               AND PDP.PDP_START_DT >= XPD_START_DT)
               AND EXISTS
                       (SELECT 1
                          FROM uss_esr.TMP_PD_CALC_PARAMS zz
                         WHERE XPD_ID = PDP_PD AND XPD_IC_TP = 'RC.START_DT');

        UPDATE uss_esr.PD_PAYMENT PDP
           SET PDP.HISTORY_STATUS = 'H', PDP.PDP_HS_DEL = g_hs
         WHERE EXISTS
                   (SELECT 1
                      FROM uss_esr.TMP_PD_CALC_PARAMS zz
                     WHERE XPD_ID = PDP_PD AND XPD_IC_TP = 'RC.FULL');
    --    WHERE EXISTS (SELECT /*+ index(zz) */ 1 FROM uss_esr.TMP_PD_CALC_PARAMS zz WHERE XPD_ID = PDP_PD AND XPD_IC_TP = 'RC.START_DT' AND PDP.PDP_START_DT >= XPD_START_DT )
    --      and EXISTS (SELECT /*+ index(zz) */ 1 FROM uss_esr.TMP_PD_CALC_PARAMS zz WHERE XPD_ID = PDP_PD AND XPD_IC_TP = 'RC.START_DT');

    END;

    --=========================================================--
    PROCEDURE calc_service
    IS
    BEGIN
        SaveMessage ('Чистимо допоміжні таблиці');
        clean_temp_tables;

        --Про всяк випадок
        UPDATE TMP_IN_CALC_PD
           SET ic_tp = 'R0'
         WHERE ic_tp IS NULL;

        -- для перерахунку на дату потрібно визначити кінечну дату
        UPDATE TMP_IN_CALC_PD
           SET ic_stop_dt =
                   NVL (
                       (SELECT MAX (pdp.pdp_stop_dt)
                          FROM pd_payment  pdp
                               LEFT JOIN pd_payment pdp1
                                   ON     pdp1.pdp_pd = pdp.pdp_pd
                                      AND pdp1.history_status = 'A'
                                      AND pdp.PDP_HS_DEL = pdp1.PDP_HS_INS
                         WHERE     pdp.pdp_pd = ic_pd
                               AND (   pdp.history_status = 'A'
                                    OR (    pdp.history_status = 'H'
                                        AND pdp1.pdp_id IS NOT NULL))),
                       ic_stop_dt)
         WHERE ic_tp = 'RC.START_DT' AND ic_stop_dt IS NULL;

        UPDATE TMP_IN_CALC_PD
           SET ic_start_dt =
                   NVL (
                       (SELECT MIN (pdd.pdd_start_dt)
                          FROM pd_payment  pdp
                               JOIN pd_detail pdd ON pdd_pdp = pdp_id
                               LEFT JOIN pd_payment pdp1
                                   ON     pdp1.pdp_pd = pdp.pdp_pd
                                      AND pdp1.history_status = 'A'
                                      AND pdp.PDP_HS_DEL = pdp1.PDP_HS_INS
                         WHERE     pdp.pdp_pd = ic_pd
                               AND (   pdp.history_status = 'A'
                                    OR (    pdp.history_status = 'H'
                                        AND pdp1.pdp_id IS NOT NULL))),
                       ic_start_dt),
               ic_stop_dt =
                   NVL (
                       (SELECT MAX (pdd.pdd_stop_dt)
                          FROM pd_payment  pdp
                               JOIN pd_detail pdd ON pdd_pdp = pdp_id
                               LEFT JOIN pd_payment pdp1
                                   ON     pdp1.pdp_pd = pdp.pdp_pd
                                      AND pdp1.history_status = 'A'
                                      AND pdp.PDP_HS_DEL = pdp1.PDP_HS_INS
                         WHERE     pdp.pdp_pd = ic_pd
                               AND (   pdp.history_status = 'A'
                                    OR (    pdp.history_status = 'H'
                                        AND pdp1.pdp_id IS NOT NULL))),
                       ic_stop_dt)
         WHERE ic_tp = 'RC.FULL';

        /*
            UPDATE TMP_IN_CALC_PD SET
              ic_stop_dt = (SELECT MAX(pdp.pdp_stop_dt)
                            FROM pd_payment pdp
                            WHERE pdp.pdp_pd = ic_pd AND pdp.history_status = 'A')
            WHERE ic_tp = 'RC.START_DT';
        */
        --  Функція формування історіі персон та документів звернення
        --  на підставі звернень у tmp_work_ids, котрий заповнено в calc_pd
        api$account.init_tmp_kaots;

        SaveMessage ('Отримання параметрів рішення та звернення');
        obtain_pd_calc_params;

        SaveMessage ('Видаляємо ознаки по рішенню');                         --Всі - бо невідомо, які будуть утриманці та нові ознаки

        DELETE FROM pd_features f
              WHERE     EXISTS
                            (SELECT 1
                               FROM TMP_IN_CALC_PD
                              WHERE pde_pd = ic_pd)
                    AND f.pde_nft NOT IN (37,
                                          82,
                                          83,
                                          90,
                                          91);

        SaveMessage ('Рахуємо утриманців');
        obtain_pd_family;

        SaveMessage ('Отримання параметрів утриманців, якщо потрібно');
        obtain_pdf_params;

        MERGE INTO pd_features
             USING (SELECT DISTINCT
                           0            AS x_pde_id,
                           pd.pd_id     AS x_pd_id,
                           nft_id       AS x_nft_id
                      FROM tmp_in_calc_pd
                           JOIN pc_decision pd ON pd_id = ic_pd
                           JOIN ap_person app
                               ON     app.app_ap = pd.pd_ap
                                  AND app.app_tp = 'Z'
                                  AND app.history_status = 'A'
                           JOIN uss_ndi.v_ndi_pd_feature_type nft
                               ON nft.nft_id IN (90)
                     WHERE     pd.pd_nst IN (249,
                                             267,
                                             265,
                                             248,
                                             269,
                                             268)
                           AND api$appeal.Get_Doc_List_Cnt (app.app_id, '92') >
                               0)
                ON (pde_pd = x_pd_id AND pde_nft = x_nft_id)
        WHEN MATCHED
        THEN
            UPDATE SET pde_val_string = 'T'
        WHEN NOT MATCHED
        THEN
            INSERT     (pde_id,
                        pde_pd,
                        pde_nft,
                        pde_val_string)
                VALUES (x_pde_id,
                        x_pd_id,
                        x_nft_id,
                        'T');

        SaveMessage ('Обраховуємо період розрахунку');
        obtain_calc_pd;

        --Збір всіх необхідних точок розриву
        collect_breakpoints;

        SaveMessage ('Знаходимо унікальний набір дат розривів');

        INSERT INTO tmp_tar_dates td (td_pd, td_pdf, td_begin)
            SELECT DISTINCT ttd_pd, ttd_pdf, TRUNC (ttd_dt)
              FROM tmp_tar_dates1;

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

        SaveMessage (
            'Видаляємо останній в історії шматок, якому не знайшлося дати закінчення');

        DELETE FROM tmp_tar_dates
              WHERE td_end IS NULL;

        SaveMessage ('Знаходимо унікальний набір дат розривів без учасників');

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
                                         tc_child_sick_stop_dt,
                                         tc_study_start_dt,
                                         tc_study_stop_dt,
                                         tc_FamilyConnect,
                                         tc_bd_kaot_id,
                                         tc_is_vpo,
                                         tc_calc_dt,
                                         tc_sc_start_dt,
                                         tc_sc_stop_dt,
                                         tc_is_child_inv_reason,
                                         tc_is_vpo_home,
                                         tc_npt,
                                         tc_income,
                                         tc_child_number,
                                         tc_is_Pensioner,
                                         tc_appeal_vpo,
                                         tc_receives_vpo,
                                         tc_inv_prev_state,
                                         tc_inv_prev_start_dt,
                                         tc_inv_prev_stop_dt,
                                         tc_inv_rc_alg,
                                         TC_PERCENT_DECREASE,
                                         TC_CARE_LEAVE,
                                         tc_care_start_dt,
                                         tc_care_stop_dt,
                                         tc_mountain_village,
                                         tc_underage_pregnant,
                                         tc_child_vil,
                                         tc_koef_value,
                                         tc_is_vpo_evac,
                                         tc_death_dt,
                                         tc_death_sum,
                                         tc_child_newborn,
                                         tc_is_fop,
                                         tc_subtp)
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
                       WHEN xpd.xpd_nst IN (249)
                       THEN
                           tc_inv_state
                       ELSE
                           '-'
                   END    AS x_inv_state,
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
                   tc_child_sick_stop_dt,
                   tc_study_start_dt,
                   tc_study_stop_dt,
                   tc_FamilyConnect,
                   tc_bd_kaot_id,
                   tc_is_vpo,
                   tc_calc_dt,
                   tc_sc_start_dt,
                   tc_sc_stop_dt,
                   tc_is_child_inv_reason,
                   tc_is_vpo_home,
                   tc_npt,
                   tc_income,
                   tc_child_number,
                   tc_is_Pensioner,
                   tc_appeal_vpo,
                   tc_receives_vpo,
                   tc_inv_prev_state,
                   tc_inv_prev_start_dt,
                   tc_inv_prev_stop_dt,
                   tc_inv_rc_alg,
                   TC_PERCENT_DECREASE,
                   TC_CARE_LEAVE,
                   tc_care_start_dt,
                   tc_care_stop_dt,
                   tc_mountain_village,
                   tc_underage_pregnant,
                   tc_child_vil,
                   tc_koef_value,
                   tc_is_vpo_evac,
                   tc_death_dt,
                   tc_death_sum,
                   tc_child_newborn,
                   tc_is_fop,
                   tc_subtp
              FROM tmp_tar_dates,
                   tmp_calc_app_params  tc,
                   tmp_pd_calc_params   xpd
             WHERE     td_pd = tc_pd
                   AND td_pdf = tc_pdf
                   AND tc_start_dt IS NULL
                   AND td_begin BETWEEN tc_sc_start_dt AND tc_sc_stop_dt
                   AND tc.tc_pd = xpd.xpd_id;

        SaveMessage ('Перераховуємо додаткові параметри по учасникам');
        recalc_pdf_params;

        --Основний блок, який, власне, і рахує суми допомог, надбавок тощо
        FOR xx
            IN (SELECT REPLACE (ncc_calc_procedure,
                                'API$PC_DECISION.',
                                'API$CALC_PD.')    AS ncc_calc_procedure,
                       ncc_calc_alg,
                       nst_name
                  FROM uss_ndi.v_ndi_nst_calc_config  ncc,
                       uss_ndi.v_ndi_service_type
                 WHERE     ncc_nst = nst_id
                       AND EXISTS
                               (SELECT 1
                                  FROM tmp_pd_calc_params
                                 WHERE     ncc_nst = xpd_nst
                                       AND xpd_calc_dt BETWEEN ncc.ncc_start_dt
                                                           AND ncc.ncc_stop_dt))
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

        SaveMessage ('Знаходимо точки розриву розрахованих нарахувань');

        INSERT INTO tmp_pay_dates1 (tpd_pd, tpd_dt, tpd_source)
            SELECT tdc_pd, tdc_start_dt, 1
              FROM tmp_pd_detail_calc, uss_ndi.v_ndi_pd_row_type
             WHERE tdc_ndp = ndp_id AND ndp_use_for_period = 'T'
            UNION
            SELECT tdc_pd, tdc_stop_dt + 1, 1
              FROM tmp_pd_detail_calc, uss_ndi.v_ndi_pd_row_type
             WHERE tdc_ndp = ndp_id AND ndp_use_for_period = 'T'
            UNION ALL
              SELECT tdc_pd, MIN (tdc_start_dt), 1
                FROM tmp_pd_detail_calc, uss_ndi.v_ndi_pd_row_type
               WHERE tdc_ndp = ndp_id AND ndp_use_for_period = 'B'
            GROUP BY tdc_pd
            UNION
              SELECT tdc_pd, MAX (tdc_stop_dt + 1), 1
                FROM tmp_pd_detail_calc, uss_ndi.v_ndi_pd_row_type
               WHERE tdc_ndp = ndp_id AND ndp_use_for_period = 'B'
            GROUP BY tdc_pd;


        SaveMessage ('Знаходимо унікальний набір дат розривів');

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

        -- Для ic_tp = 'R0' видаляємо
        SaveMessage ('Видаляємо існуючі деталі розрахунку рішення');

        DELETE FROM pd_detail
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_pd_calc_params
                                JOIN pd_payment p ON xpd_id = pdp_pd
                          WHERE     p.history_status = 'A'
                                AND pdd_pdp = pdp_id
                                AND xpd_ic_tp = 'R0');

        SaveMessage ('Видаляємо існуючі розрахунки рішення');

        DELETE FROM pd_payment p
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_pd_calc_params
                          WHERE     xpd_id = pdp_pd
                                AND xpd_ic_tp = 'R0'
                                AND p.history_status = 'A');

        -- А для ic_tp = 'RC.START_DT' Все куди складніше
        Recalc_pd_payment;
        /*
            FROM  pd_payment pdp
               JOIN tmp_pd_calc_params cp ON xpd_id = pdp_pd AND xpd_ic_tp = 'RC.START_DT'
            WHERE pdp.pdp_start_dt < cp.xpd_start_dt
              AND pdp.pdp_stop_dt > cp.xpd_start_dt
              AND pdp.history_status = 'A';


            INSERT INTO pd_payment(pdp_id, pdp_pd, pdp_npt, pdp_start_dt, pdp_stop_dt,
                                   pdp_sum, pdp_hs_ins, history_status, pdp_src)
            SELECT  x_id2, pdp.pdp_pd, pdp.pdp_npt, pdp.pdp_start_dt,  x_dt1-1,
                    pdp_sum, g_hs, 'A', 'RC'
            FROM tmp_work_set1
                 JOIN pd_payment pdp ON pdp.pdp_id = x_id1;
                 */

        SaveMessage (
            'Формуємо нарахування по кожному розриву і агрегуємо по типу виплати');

        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_Status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
              SELECT 0,
                     tp_pd,
                     tdc_npt,
                     tp_begin,
                     tp_end,
                     NVL (SUM (tdc_value), 0),
                     'A',
                     g_hs,
                     CASE xpd_ic_tp
                         WHEN 'RC.START_DT' THEN 'RC'
                         WHEN 'RC.FULL' THEN 'RC'
                     END,
                     g_rc_id
                FROM tmp_pay_dates,
                     tmp_pd_detail_calc,
                     uss_ndi.v_ndi_pd_row_type,
                     tmp_pd_calc_params cp
               WHERE     tp_pd = tdc_pd
                     AND tp_begin BETWEEN tdc_start_dt AND tdc_stop_dt
                     AND tdc_npt IS NOT NULL
                     AND tdc_ndp = ndp_id
                     AND xpd_id = tp_pd
                     AND ndp_alg IS NULL
                     AND NVL (ndp_use_for_period, 'F') != 'B'
            GROUP BY tp_pd,
                     tdc_npt,
                     tp_begin,
                     tp_end,
                     CASE xpd_ic_tp
                         WHEN 'RC.START_DT' THEN 'RC'
                         WHEN 'RC.FULL' THEN 'RC'
                     END
            UNION ALL
              SELECT 0,
                     tp_pd,
                     tdc_npt,
                     tp_begin,
                     tp_end,
                     NVL (SUM (tdc_value), 0),
                     'A',
                     g_hs,
                     CASE xpd_ic_tp
                         WHEN 'RC.START_DT' THEN 'RC'
                         WHEN 'RC.FULL' THEN 'RC'
                     END,
                     g_rc_id
                FROM tmp_pay_dates,
                     tmp_pd_detail_calc,
                     uss_ndi.v_ndi_pd_row_type,
                     tmp_pd_calc_params cp
               WHERE     tp_pd = tdc_pd
                     AND tdc_start_dt BETWEEN tp_begin AND tp_end
                     AND tdc_npt IS NOT NULL
                     AND tdc_ndp = ndp_id
                     AND xpd_id = tp_pd
                     AND ndp_alg IS NULL
                     AND NVL (ndp_use_for_period, 'F') = 'B'
            GROUP BY tp_pd,
                     tdc_npt,
                     tp_begin,
                     tp_end,
                     CASE xpd_ic_tp
                         WHEN 'RC.START_DT' THEN 'RC'
                         WHEN 'RC.FULL' THEN 'RC'
                     END/*HAVING SUM(tdc_value) <> 0*/
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
                      FROM pd_payment pdp
                     WHERE pdp_pd = pd_id AND pdp.history_status = 'A')
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_calc_pd
                         WHERE c_pd = pd_id)
               AND (   pd_start_dt IS NULL
                    OR pd_src = 'FS'
                    OR pd_src = 'SA'
                    OR pd_nst = 265
                    OR pd_nst = 268
                    OR pd_nst = 664)                    --# 74919   2022.01.21
               AND EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE xpd_id = pd_id AND xpd_ic_tp = 'R0');

        UPDATE pc_decision
           SET (pd_stop_dt) =
                   (SELECT MAX (pdp_stop_dt)
                      FROM pd_payment pdp
                     WHERE pdp_pd = pd_id AND pdp.history_status = 'A')
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_pd_calc_params  cp
                           JOIN uss_ndi.v_ndi_nst_calc_config t
                               ON     t.ncc_nst = cp.xpd_nst
                                  AND cp.xpd_calc_dt BETWEEN t.ncc_start_dt
                                                         AND t.ncc_stop_dt
                     WHERE xpd_id = pd_id AND t.ncc_calc_period = '18YEARS.U');


        UPDATE pc_decision
           SET (pd_stop_dt) =
                   (SELECT MAX (pdp_stop_dt)
                      FROM pd_payment pdp
                     WHERE pdp_pd = pd_id AND pdp.history_status = 'A')
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_calc_pd
                         WHERE c_pd = pd_id)
               AND (pd_src = 'RC')                      --# 74919   2022.01.21
               AND EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE xpd_id = pd_id AND xpd_ic_tp = 'R0');

        -- # #81405  2022.11.11
        UPDATE pc_decision
           SET pd_scc =
                   (SELECT MAX (app_scc)
                      FROM ap_person app
                     WHERE     app_ap = pd_ap
                           AND app.history_status = 'A'
                           AND app.app_tp = 'Z')
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_calc_pd
                         WHERE c_pd = pd_id)
               AND EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE xpd_id = pd_id AND xpd_ic_tp = 'R0');

        UPDATE pd_pay_method
           SET (pdm_start_dt, pdm_stop_dt) =
                   (SELECT pd_start_dt, pd_stop_dt
                      FROM pc_decision
                     WHERE pdm_pd = pd_id)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_calc_pd
                     WHERE c_pd = pdm_pd);


        SaveMessage ('Обраховуємо ознаки рішень');
        collect_features;

        SaveMessage ('Пишемо деталі нарахування');

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
            SELECT 0,
                   pdp_id,
                   tdc_row_order,
                   tdc_row_name,
                   tdc_value,
                   tdc_key,
                   tdc_ndp,
                   tdc_start_dt,
                   tdc_stop_dt,
                   NVL (tdc_sub_npt, tdc_npt)     AS x_npt
              FROM tmp_pd_detail_calc,
                   pd_payment  pdp,
                   uss_ndi.v_ndi_pd_row_type
             WHERE     tdc_pd = pdp_pd
                   AND tdc_ndp = ndp_id
                   --      AND (tdc_npt = pdp_npt OR tdc_npt IS NULL AND ndp_alg = 'SHOW') -- Тут нужно явно сделать нормально, но как....
                   AND (   tdc_npt = pdp_npt
                        OR tdc_npt IS NULL AND ndp_alg = 'SHOW'
                        OR ndp_alg = 'DEDUCT')
                   --      AND NVL(tdc_npt, 0) !=1
                   AND (   NVL (tdc_npt, 0) != 1
                        OR (tdc_npt = 1 AND tdc_sub_npt IS NOT NULL))
                   AND pdp_start_dt BETWEEN tdc_start_dt AND tdc_stop_dt
                   AND pdp.history_status = 'A'
                   AND NVL (ndp_use_for_period, 'F') != 'B'
            UNION ALL
            SELECT 0,
                   pdp_id,
                   tdc_row_order,
                   tdc_row_name,
                   tdc_value,
                   tdc_key,
                   tdc_ndp,
                   tdc_start_dt,
                   tdc_stop_dt,
                   NVL (tdc_sub_npt, tdc_npt)     AS x_npt
              FROM tmp_pd_detail_calc,
                   pd_payment  pdp,
                   uss_ndi.v_ndi_pd_row_type
             WHERE     tdc_pd = pdp_pd
                   AND tdc_ndp = ndp_id
                   --      AND (tdc_npt = pdp_npt OR tdc_npt IS NULL AND ndp_alg = 'SHOW') -- Тут нужно явно сделать нормально, но как....
                   AND (   tdc_npt = pdp_npt
                        OR tdc_npt IS NULL AND ndp_alg = 'SHOW'
                        OR ndp_alg = 'DEDUCT')
                   --AND tdc_npt !=1
                   AND NVL (tdc_npt, 0) != 1
                   AND tdc_start_dt BETWEEN pdp_start_dt AND pdp_stop_dt
                   AND pdp.history_status = 'A'
                   AND NVL (ndp_use_for_period, 'F') = 'B';

        --#93392 2023/10/19
        UPDATE pd_payment
           SET pdp_start_dt = TRUNC (pdp_start_dt, 'MM'),
               pdp_stop_dt = LAST_DAY (pdp_start_dt)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_pay_dates,
                               tmp_pd_detail_calc,
                               uss_ndi.v_ndi_pd_row_type
                         WHERE     tp_pd = tdc_pd
                               AND tdc_start_dt BETWEEN tp_begin AND tp_end
                               AND tdc_npt IS NOT NULL
                               AND tdc_ndp = ndp_id
                               AND ndp_alg IS NULL
                               AND NVL (ndp_use_for_period, 'F') = 'B'
                               AND tp_pd = pdp_pd
                               AND (   tdc_npt = 830
                                    OR tdc_npt = 831
                                    OR tdc_npt = 832
                                    OR tdc_npt = 833
                                    OR tdc_npt = 834))
               AND EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE     xpd_id = pdp_pd
                               AND xpd_ic_tp IN ('R0', 'RC.FULL'));

        UPDATE pc_decision
           SET pd_start_dt = TRUNC (pd_start_dt, 'MM'),
               pd_stop_dt = LAST_DAY (pd_start_dt)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_pay_dates,
                               tmp_pd_detail_calc,
                               uss_ndi.v_ndi_pd_row_type
                         WHERE     tp_pd = tdc_pd
                               AND tdc_start_dt BETWEEN tp_begin AND tp_end
                               AND tdc_npt IS NOT NULL
                               AND tdc_ndp = ndp_id
                               AND ndp_alg IS NULL
                               AND NVL (ndp_use_for_period, 'F') = 'B'
                               AND tp_pd = pd_id
                               AND (   tdc_npt = 830
                                    OR tdc_npt = 831
                                    OR tdc_npt = 832
                                    OR tdc_npt = 833
                                    OR tdc_npt = 834))
               AND EXISTS
                       (SELECT 1
                          FROM tmp_pd_calc_params
                         WHERE xpd_id = pd_id AND xpd_ic_tp = 'R0');

        UPDATE (SELECT f.pdf_start_dt,
                       f.pdf_stop_dt,
                       f.pdf_tp,
                       pd.pd_start_dt,
                       pd.pd_stop_dt,
                       --            (SELECT MIN(tc.tc_sc_start_dt )
                       --             FROM tmp_calc_app_params tc
                       --             WHERE tc.tc_pd = f.pdf_pd AND tc.tc_sc = f.pdf_sc AND tc.tc_start_dt IS NULL
                       --             ) AS x_sc_start_dt,
                       --            (SELECT MAX(tc.tc_sc_stop_dt)
                       --             FROM tmp_calc_app_params tc
                       --             WHERE tc.tc_pd = f.pdf_pd AND tc.tc_sc = f.pdf_sc AND tc.tc_start_dt IS NULL
                       --             ) AS x_sc_stop_dt,
                        (SELECT MIN (d.pdd_start_dt)
                           FROM pd_detail  d
                                JOIN pd_payment p
                                    ON     p.pdp_id = d.pdd_pdp
                                       AND p.history_status = 'A'
                          WHERE pdd_key = f.pdf_id)    AS x_start_dt,
                       (SELECT MAX (d.pdd_stop_dt)
                          FROM pd_detail  d
                               JOIN pd_payment p
                                   ON     p.pdp_id = d.pdd_pdp
                                      AND p.history_status = 'A'
                         WHERE pdd_key = f.pdf_id)     AS x_stop_dt,
                       (SELECT COUNT (1)
                          FROM pd_detail  d
                               JOIN pd_payment p
                                   ON     p.pdp_id = d.pdd_pdp
                                      AND p.history_status = 'A'
                         WHERE pdd_key = f.pdf_id)     AS x_pdd_cnt
                  FROM pd_family f JOIN pc_decision pd ON pd_id = f.pdf_pd
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM tmp_pd_calc_params
                                 WHERE xpd_id = pdf_pd)
                       AND f.history_status = 'A')
           SET --pdf_start_dt = (CASE WHEN pd_start_dt < x_sc_start_dt THEN x_sc_start_dt ELSE pd_start_dt END),
               --pdf_stop_dt  = (CASE WHEN pd_stop_dt  > x_sc_stop_dt  THEN x_sc_stop_dt  ELSE pd_stop_dt  END),
               --pdf_start_dt = (CASE WHEN pd_start_dt < x_start_dt THEN x_start_dt ELSE pd_start_dt END),
               --pdf_stop_dt  = (CASE WHEN pd_stop_dt  > x_stop_dt  THEN x_stop_dt  ELSE pd_stop_dt  END),
               pdf_tp = (CASE x_pdd_cnt WHEN 0 THEN 'INFO' ELSE 'CALC' END);

        Recalc_pd_accrual_period;
    END;

    --=========================================================--
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
                          FROM TMP_IN_CALC_PD
                         WHERE pdm_pd = ic_pd);
    END;

    --====================================--
    --  У вікні "Рішення про призначення допомоги" можна здійснювати розрахунок лише у випадку,
    --  якщо користувач підтвердив право на сторінці "Визначення права" - в усіх правилах перевірки зазначено "Так".
    --  Якщо хоча б в одному чекбоксі правил відсутнє "ТАК",
    --  то видавати повідомлення "Розрахунок можна здійснювати, у випадку наявності у особи права на призначення допомоги"
    --====================================--
    PROCEDURE Check_pd_right
    IS
        ------------------------------------------------------------------
        CURSOR pd_right IS
              SELECT ic_pd,
                     nst_id                                                AS x_nst,
                     nst_name                                              AS x_nst_name,
                     SUM (CASE WHEN prl_result = 'F' THEN 1 ELSE 0 END)    x_err_cnt
                FROM TMP_IN_CALC_PD
                     JOIN pd_right_log ON prl_pd = ic_pd
                     JOIN uss_ndi.v_ndi_right_rule nrr
                         ON     prl_nrr = nrr.nrr_id
                            AND NVL (nrr.nrr_tp, 'E') = 'E' -- Аналізуємо тільки помилки
                     JOIN pc_decision ON pd_id = ic_pd
                     JOIN uss_ndi.v_ndi_service_type ON pd_nst = nst_id
               WHERE ic_tp = 'R0'
            GROUP BY ic_pd, nst_id, nst_name
              HAVING SUM (CASE WHEN prl_result = 'F' THEN 1 ELSE 0 END) > 0
            UNION ALL
            SELECT ic_pd,
                   nst_id       AS x_nst,
                   nst_name     AS x_nst_name,
                   1            AS x_err_cnt
              FROM TMP_IN_CALC_PD
                   JOIN pc_decision ON pd_id = ic_pd
                   JOIN uss_ndi.v_ndi_service_type ON pd_nst = nst_id
             WHERE     NOT EXISTS
                           (SELECT 1
                              FROM pd_right_log
                             WHERE prl_pd = ic_pd)
                   AND nst_id NOT IN (21, 1201)
                   AND ic_tp = 'R0';

        ------------------------------------------------------------------
        CURSOR pd_right_664 IS
            SELECT ic_pd,
                   tpp_pd,
                   tpp_sc,
                   ap_reg_dt     AS calc_dt
              FROM TMP_IN_CALC_PD
                   JOIN pc_decision pd ON pd_id = ic_pd
                   JOIN v_tmp_person_for_decision app
                       ON app.pd_id = ic_pd AND app.tpp_app_tp = 'Z'
                   JOIN appeal ON ap_id = pd_ap_reason
             WHERE     app.pd_nst = 664
                   AND ap_reg_dt BETWEEN TO_DATE ('01.05.2022', 'dd.mm.yyyy')
                                     AND TO_DATE ('31.07.2023', 'dd.mm.yyyy')
                   AND ic_tp = 'R0';

        ------------------------------------------------------------------
        CURSOR pd_right_1101 IS
            SELECT ic_pd, nst_name AS x_nst_name
              FROM TMP_IN_CALC_PD
                   JOIN pc_decision pd ON pd_id = ic_pd
                   JOIN uss_ndi.v_ndi_service_type ON pd_nst = nst_id
             WHERE pd_nst IN (                                       /*1101,*/
                              250                                   /*, 1221*/
                                                                     /*, 901*/
                                 );
    --         щодо послуг "Допомога при народженні" (NST_ID 250) та "Надання послуги помічника патронатного вихователя" (NST_ID 1221)
    ------------------------------------------------------------------
    BEGIN
        --RETURN;
        FOR r IN pd_right
        LOOP
            TOOLS.add_message (
                g_messages,
                'E',
                   'Розрахунок можна здійснювати, у випадку наявності у особи права на призначення допомоги <'
                || r.x_nst_name
                || '>!');
            API$PC_DECISION.write_pd_log (r.ic_pd,
                                          g_hs,
                                          'R0',
                                          CHR (38) || '36#' || r.x_nst_name,
                                          NULL);

            DELETE FROM TMP_IN_CALC_PD
                  WHERE ic_pd = r.ic_pd;
        END LOOP;

        FOR r IN pd_right_664
        LOOP
            IF    Api$account.get_docx_count (r.tpp_pd,
                                              r.tpp_sc,
                                              10250,
                                              r.calc_dt) = 0
               OR Api$account.Get_Docx_String (r.tpp_pd,
                                               r.tpp_sc,
                                               10250,
                                               4360,
                                               r.calc_dt)
                      IS NULL
               OR Api$calc_Right.Get_Docx_Scan (r.tpp_pd,
                                                r.tpp_sc,
                                                10250,
                                                r.calc_dt) = 0
            THEN
                TOOLS.add_message (
                    g_messages,
                    'E',
                    'Розрахунок допомоги не виконується в зв''язку із тим, що не додано документ «Підстава щодо призначення допомоги за попередній період» або сканкопія, або не визначено підставу!');
                API$PC_DECISION.write_pd_log (
                    r.ic_pd,
                    g_hs,
                    'R0',
                    'Розрахунок допомоги не виконується в зв''язку із тим, що не додано документ «Підстава щодо призначення допомоги за попередній період» або сканкопія, або не визначено підставу!',
                    NULL);

                DELETE FROM TMP_IN_CALC_PD
                      WHERE ic_pd = r.ic_pd;
            END IF;
        END LOOP;

        IF ikis_sys.ikis_parameter_util.GetParameter1 (
               p_par_code      => 'APP_INSTNACE_TYPE',
               p_par_ss_code   => 'IKIS_SYS') IN
               ('TEST', 'PROM')
        THEN
            FOR r IN pd_right_1101
            LOOP
                TOOLS.add_message (
                    g_messages,
                    'E',
                       'Заборонено разраховувати допомогу <'
                    || r.x_nst_name
                    || '>!');

                DELETE FROM TMP_IN_CALC_PD
                      WHERE ic_pd = r.ic_pd;
            END LOOP;
        END IF;
    /*
        FOR r IN pd_right_1101 LOOP
          TOOLS.add_message(g_messages, 'E', 'Заборонено разраховувати допомогу <'||r.x_nst_name||'>!');
          DELETE FROM TMP_IN_CALC_PD WHERE ic_pd = r.ic_pd;
        END LOOP;
    */
    END;

    --=========================================================--
    --  Функція розрахунку виплат по проектам рішень на виплату
    --=========================================================--
    PROCEDURE calc_pd (p_mode              INTEGER, --1=з p_pd_id, 2=з таблиці TMP_IN_CALC_PD
                       p_pd_id             pc_decision.pd_id%TYPE,
                       p_ic_tp             VARCHAR2 DEFAULT 'R0',
                       p_ic_start_dt       DATE DEFAULT NULL,
                       p_ic_stop_dt        DATE DEFAULT NULL,
                       p_rc_ic             NUMBER DEFAULT NULL,
                       p_messages      OUT SYS_REFCURSOR)
    IS
        l_cnt   INTEGER;

        --====================================--
        FUNCTION check_is_have_nst (p_nst_id pc_decision.pd_nst%TYPE)
            RETURN BOOLEAN
        IS
            l_nst_cnt   INTEGER;
        BEGIN
            SELECT COUNT (*)
              INTO l_nst_cnt
              FROM TMP_IN_CALC_PD, pc_decision, uss_ndi.v_ndi_service_type
             WHERE     ic_pd = pd_id
                   AND pd_nst = nst_id
                   AND (pd_nst = p_nst_id OR nst_nst_main = p_nst_id);

            RETURN l_nst_cnt > 0;
        END;
    --====================================--
    BEGIN
        g_messages := TOOLS.t_messages ();
        G_rc_id := p_rc_ic;
        TOOLS.add_message (g_messages, 'I', 'Починаю розрахунок!');

        IF p_mode = 1 AND p_pd_id IS NOT NULL
        THEN
            DELETE FROM TMP_IN_CALC_PD
                  WHERE 1 = 1;

            INSERT INTO TMP_IN_CALC_PD (IC_PD,
                                        IC_TP,
                                        IC_START_DT,
                                        IC_STOP_DT)
                SELECT pd_id,
                       p_ic_tp,
                       p_ic_start_dt,
                       p_ic_stop_dt
                  FROM pc_decision
                 WHERE pd_id = p_pd_id;

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM TMP_IN_CALC_PD, pc_decision
             WHERE ic_pd = pd_id;
        END IF;

        IF l_cnt = 0
        THEN
            TOOLS.add_message (
                g_messages,
                'E',
                'В функцію розрахунку сум виплати не передано ідентифікаторів проектів рішень на виплату!');
        ELSE
            -- Інщі системи працюють з цією таблицею
            DELETE FROM Tmp_Work_Ids
                  WHERE 1 = 1;

            INSERT INTO Tmp_Work_Ids (x_id)
                SELECT ic_pd FROM TMP_IN_CALC_PD;


            g_hs := TOOLS.GetHistSession;

            API$ACCOUNT.init_tmp_for_pd;

            Check_pd_right;

            API$ANKETA.Set_Anketa;

            calc_service;

            FOR xx
                IN (SELECT DISTINCT nst_id AS x_nst, nst_name AS x_nst_name
                      FROM TMP_IN_CALC_PD,
                           pc_decision,
                           uss_ndi.v_ndi_service_type
                     WHERE ic_pd = pd_id AND pd_nst = nst_id)
            LOOP
                TOOLS.add_message (
                    g_messages,
                    'I',
                    'Розраховано допомогу <' || xx.x_nst_name || '>!');
            END LOOP;

            calc_various_pd_params;

            TOOLS.add_message (g_messages, 'I', 'Завершено розрахунок!');
        END IF;

        FOR xx IN (SELECT * FROM TMP_IN_CALC_PD)
        LOOP
            IF xx.ic_tp = 'R0'
            THEN
                API$PC_DECISION.write_pd_log (xx.ic_pd,
                                              g_hs,
                                              'R0',
                                              CHR (38) || '13',
                                              NULL);
            ELSE
                API$PC_DECISION.write_pd_log (xx.ic_pd,
                                              g_hs,
                                              'S',
                                              CHR (38) || '13',
                                              NULL);
            END IF;
        END LOOP;

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;

    --=========================================================--
    --  Функція розрахунку виплат по проектам рішень на виплату
    --=========================================================--
    PROCEDURE calc_pd (p_mode           INTEGER, --1=з p_pd_id, 2=з таблиці TMP_IN_CALC_PD
                       p_pd_id          pc_decision.pd_id%TYPE,
                       p_messages   OUT SYS_REFCURSOR)
    IS
    BEGIN
        calc_pd (p_mode          => p_mode,
                 p_pd_id         => p_pd_id,
                 p_ic_tp         => 'R0',
                 p_ic_start_dt   => NULL,
                 p_ic_stop_dt    => NULL,
                 p_rc_ic         => NULL,
                 p_messages      => p_messages);
    END;

    --=========================================================--
    --  Функція розрахунку виплат по проектам рішень на виплату, для перерахунків
    --=========================================================--
    PROCEDURE calc_pd (p_rc_ic NUMBER)
    IS
        p_messages   SYS_REFCURSOR;
    BEGIN
        calc_pd (p_mode          => 2,
                 p_pd_id         => NULL,
                 p_ic_tp         => NULL,
                 p_ic_start_dt   => NULL,
                 p_ic_stop_dt    => NULL,
                 p_rc_ic         => p_rc_ic,
                 p_messages      => p_messages);
    END;

    --=========================================================--
    --  Функція розрахунку виплат по проектам рішень на виплату
    --  p_pd_id    id рішення
    --  p_ic_tp    тип перерахунку:
    --             'RC.START_DT' - перерахунок по бюджетних показниках
    --  p_rc_dt    дата перерахунку
    --  p_messages інформація по розрахунку,
    --=========================================================--
    PROCEDURE calc_pd_RC (p_pd_id          pc_decision.pd_id%TYPE,
                          p_ic_tp          VARCHAR2,
                          p_rc_dt          DATE,
                          p_messages   OUT SYS_REFCURSOR)
    IS
        l_pd_st               VARCHAR2 (200);
        l_pd_dt               DATE;
        l_cnt_ext             NUMBER;
        l_cnt_payment         NUMBER;
        l_cnt_dubl_f          NUMBER;
        l_Is_Correct_income   NUMBER;
        l_Is_Correct_nst      NUMBER;
        l_nst                 NUMBER;
    BEGIN
        --      raise_application_error(-20000, 'calc_pd_RC!');


        IF p_ic_tp NOT IN ('RC.START_DT', 'RC.START_DT.STOP_DT')
        THEN
            raise_application_error (-20000,
                                     'Не корректний тип перерахунку!');
        ELSIF    p_rc_dt IS NULL
              OR p_rc_dt < TO_DATE ('01.01.2024', 'dd.mm.yyyy')
        THEN
            raise_application_error (
                -20000,
                'Дата перерахунку не може бути менща за 01.01.2024!');
        END IF;

        IF p_ic_tp = 'RC.START_DT'
        THEN
            SELECT pd_st,
                   pd.pd_dt,
                   pd_nst,
                   (SELECT COUNT (1)
                      FROM pd_payment  p
                           JOIN recalculates rc ON p.pdp_rc = rc_id
                     WHERE     pdp_pd = pd_id
                           AND p.pdp_start_dt >= p_rc_dt
                           AND p.history_status = 'A'
                           AND (   (    rc_tp = 'S_EXT_VS'
                                    AND pd_nst IN (268, 248, 265))
                                OR (    rc_tp = 'S_EXT_2NST'
                                    AND pd_nst IN (249, 267))))
                       AS cnt_ext,
                   (SELECT COUNT (1)
                      FROM pd_payment p
                     WHERE pdp_pd = pd_id --AND p.pdp_start_dt >= p_rc_dt
                                          AND p.pdp_stop_dt > p_rc_dt--AND p.history_status = 'A'
                                                                     )
                       AS cnt_payment,
                   (  SELECT COUNT (1)
                        FROM pd_family f
                       WHERE f.pdf_pd = pd_id AND f.history_status = 'A'
                    GROUP BY pdf_sc
                      HAVING COUNT (1) > 1)
                       AS cnt_dubl_f,
                   CASE
                       WHEN pd_nst IN (248, 265, 901)
                       THEN
                           1
                       WHEN pd_nst IN (249, 267, 268)
                       THEN
                           (SELECT COUNT (1)
                              FROM pd_income_calc c
                             WHERE c.pic_pd = pd_id)
                       ELSE
                           0
                   END
                       AS Is_Correct_income,
                   CASE
                       WHEN pd_nst IN (248,
                                       249,
                                       265,
                                       267,
                                       268,
                                       901)
                       THEN
                           1
                       ELSE
                           0
                   END
                       AS Is_Correct_nst
              INTO l_pd_st,
                   l_pd_dt,
                   l_nst,
                   l_cnt_ext,
                   l_cnt_payment,
                   l_cnt_dubl_f,
                   l_Is_Correct_income,
                   l_Is_Correct_nst
              FROM pc_decision pd
             WHERE pd_id = p_pd_id;

            IF p_rc_dt != TRUNC (p_rc_dt, 'MM')
            THEN
                raise_application_error (
                    -20000,
                    'Дата перерахунку по бюджетних показниках може бути тільки першим числом місяця!');
            ELSIF NVL (l_Is_Correct_nst, 0) = 0
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: не вірна послуга!');
            ELSIF l_pd_st != 'S'
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: не в статусі "Нараховано"!');
            ELSIF     l_pd_dt > TO_DATE ('20.12.2023', 'dd.mm.yyyy')
                  AND l_nst NOT IN (249, 901)
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: дата рішення після 20.12.2023!');
            ELSIF     p_rc_dt < TO_DATE ('01.01.2024', 'dd.mm.yyyy')
                  AND l_nst = 901
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: дата перерахунку до 01.01.2024!');
            ELSIF     p_rc_dt < TO_DATE ('01.01.2025', 'dd.mm.yyyy')
                  AND l_nst = 249
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: дата перерахунку до 01.01.2025!');
            ELSIF l_pd_st NOT IN ('S') AND l_nst = 249
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: рішення не в статусі "Нараховано"');
            ELSIF NVL (l_cnt_payment, 0) = 0
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: не діє у січні 2024 року!');
            ELSIF NVL (l_cnt_ext, 0) > 0
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: було подовжено масовим перерахунком!');
            ELSIF NVL (l_cnt_ext, 0) > 0
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: має задвоєння членів сімї!');
            ELSIF NVL (l_Is_Correct_income, 0) = 0
            THEN
                raise_application_error (
                    -20000,
                    'Рішення не відповідає критеріям для перерахунку: відсутні доходи!');
            END IF;
        END IF;

        calc_pd (p_mode          => 1,
                 p_pd_id         => p_pd_id,
                 p_ic_tp         => p_ic_tp,
                 p_ic_start_dt   => p_rc_dt,
                 p_ic_stop_dt    => NULL,
                 p_rc_ic         => NULL,
                 p_messages      => p_messages);
    END;

    --+++++++++++++++++++++
    PROCEDURE Test_calc_pd (id        NUMBER DEFAULT NULL,
                            p_rc_ic   NUMBER DEFAULT NULL)
    IS
        p_messages   SYS_REFCURSOR;

        PROCEDURE fetch2andclose (rc IN SYS_REFCURSOR)
        IS
            Is_Out        BOOLEAN := FALSE;
            msg_tp        VARCHAR2 (10);
            msg_tp_name   VARCHAR2 (20);
            msg_text      VARCHAR2 (4000);
        BEGIN
            LOOP
                FETCH rc INTO msg_tp, msg_tp_name, msg_text;

                EXIT WHEN rc%NOTFOUND;

                IF msg_text LIKE 'Виконуємо алгоритм%'
                THEN
                    Is_Out := TRUE;
                END IF;

                IF Is_Out
                THEN
                    --DBMS_OUTPUT.PUT_LINE ( msg_tp||'   '||msg_tp_name||'   '||msg_text );
                    DBMS_OUTPUT.PUT_LINE (msg_text);
                END IF;
            END LOOP;

            CLOSE rc;
        END;
    BEGIN
        --Not_Check_Calc_Right;
        IF id IS NULL AND p_rc_ic IS NOT NULL
        THEN
            calc_pd (p_mode          => 2,
                     p_pd_id         => NULL,
                     p_ic_tp         => NULL,
                     p_ic_start_dt   => NULL,
                     p_ic_stop_dt    => NULL,
                     p_rc_ic         => p_rc_ic,
                     p_messages      => p_messages);
        ELSIF id IS NULL
        THEN
            calc_pd (2, NULL, p_messages);
        ELSE
            calc_pd (1, id, p_messages);
        END IF;

        fetch2andclose (p_messages);
    END;
--========================================
BEGIN
    Set_break (251, '01.10.2024');

    Set_break (901, '01.07.2024');
    Set_break (901, '01.01.2025');

    Set_break (1221, '01.01.2025');
END API$CALC_PD;
/